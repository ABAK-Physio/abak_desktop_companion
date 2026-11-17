#include "runtime.h"
#include "policy.h"
#include "../runner/document_controls_installation_loader.h"
#include "../runner/document_controls_peer_identity.h"
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Data.Json.h>
#include <sddl.h>
#include <aclapi.h>
#include <algorithm>
#include <array>
#include <cmath>
#include <set>
#include <stdexcept>
#include <vector>

namespace document_controls_runtime {
namespace ipc=document_controls::windows_ipc;
using namespace winrt::Windows::Data::Json;
namespace {
void Check(bool value,const char* text){if(!value) throw std::runtime_error(text);}
void Check(const ipc::Error& error){if(error) throw std::runtime_error(error.code+": "+error.message);}
void LogRequestFailure(const std::string& message) {
 const auto work=WorkDirectory();if(work.empty()) return;
 OwnedHandle file(CreateFileW((work+L"\\request-error.txt").c_str(),GENERIC_WRITE,FILE_SHARE_READ,
     nullptr,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,nullptr));
 if(!file) return;
 const auto text=message.substr(0,8192);DWORD written=0;
 WriteFile(file.get(),text.data(),static_cast<DWORD>(text.size()),&written,nullptr);
}
struct Apartment {
 Apartment(){winrt::init_apartment(winrt::apartment_type::multi_threaded);}
 ~Apartment(){winrt::uninit_apartment();}
};
// Both peers inspect process/token identity. The client grants QUERY to the
// dedicated service SID for an exchange; the service grants QUERY to the exact
// installed accounts before accepting clients. Never grant VM access, token
// duplication or impersonation. Restore both original DACLs at scope exit.
class PeerQueryGrant {
 public:
  explicit PeerQueryGrant(const std::vector<std::string>& identities) {
   Check(!identities.empty() && identities.size()<=ipc::kMaxInstallationUsers,"Comptes de verification absents.");
   sids_.reserve(identities.size());
   try {
    for(const auto& identity:identities) {
     PSID sid=nullptr;
     Check(ConvertStringSidToSidW(Wide(identity).c_str(),&sid)!=FALSE,"SID de verification indisponible.");
     sids_.push_back(sid);
    }
   } catch(...) {FreeSids();throw;}
  }
  void Apply() {
   process_.reset(OpenProcess(READ_CONTROL|WRITE_DAC,FALSE,GetCurrentProcessId()));
   Check(static_cast<bool>(process_),"Permissions du processus indisponibles.");
   HANDLE token=nullptr;
   Check(OpenProcessToken(GetCurrentProcess(),TOKEN_QUERY|READ_CONTROL|WRITE_DAC,&token)!=FALSE,
       "Autorisation de lecture du jeton indisponible.");
   token_.reset(token);
   Grant(process_.get(),PROCESS_QUERY_LIMITED_INFORMATION|SYNCHRONIZE,&process_descriptor_);
   Grant(token_.get(),TOKEN_QUERY,&token_descriptor_);
  }
  ~PeerQueryGrant() {
   Restore(token_.get(),token_descriptor_);Restore(process_.get(),process_descriptor_);
   FreeSids();
  }
  PeerQueryGrant(const PeerQueryGrant&)=delete;
  PeerQueryGrant& operator=(const PeerQueryGrant&)=delete;
  void Close() {
   const bool token_ok=Restore(token_.get(),token_descriptor_);
   const bool process_ok=Restore(process_.get(),process_descriptor_);
   Check(token_ok && process_ok,"Restauration des permissions du processus impossible.");
  }
 private:
  void Grant(HANDLE object,DWORD rights,PSECURITY_DESCRIPTOR* previous) {
   PACL before=nullptr;
   Check(GetSecurityInfo(object,SE_KERNEL_OBJECT,DACL_SECURITY_INFORMATION,nullptr,nullptr,&before,nullptr,previous)==ERROR_SUCCESS,
       "Permissions de lecture du processus indisponibles.");
   std::vector<EXPLICIT_ACCESS_W> entries(sids_.size());
   for(std::size_t i=0;i<sids_.size();++i) {
    auto& entry=entries[i];entry.grfAccessPermissions=rights;entry.grfAccessMode=GRANT_ACCESS;
    entry.Trustee.TrusteeForm=TRUSTEE_IS_SID;entry.Trustee.ptstrName=static_cast<LPWSTR>(sids_[i]);
   }
   PACL after=nullptr;
   Check(SetEntriesInAclW(static_cast<ULONG>(entries.size()),entries.data(),before,&after)==ERROR_SUCCESS,"Autorisation de verification impossible.");
   const DWORD result=SetSecurityInfo(object,SE_KERNEL_OBJECT,DACL_SECURITY_INFORMATION,nullptr,nullptr,after,nullptr);
   LocalFree(after);Check(result==ERROR_SUCCESS,"Autorisation de verification impossible.");
  }
  static bool Restore(HANDLE object,PSECURITY_DESCRIPTOR& descriptor) {
   if(!descriptor) return true;
   BOOL present=FALSE,defaulted=FALSE;PACL acl=nullptr;
   const bool ok=GetSecurityDescriptorDacl(descriptor,&present,&acl,&defaulted) && present &&
       SetSecurityInfo(object,SE_KERNEL_OBJECT,DACL_SECURITY_INFORMATION,nullptr,nullptr,acl,nullptr)==ERROR_SUCCESS;
   LocalFree(descriptor);descriptor=nullptr;return ok;
  }
  void FreeSids() {for(const auto sid:sids_) LocalFree(sid);sids_.clear();}
  std::vector<PSID> sids_;
  OwnedHandle process_,token_;
  PSECURITY_DESCRIPTOR process_descriptor_=nullptr,token_descriptor_=nullptr;
};
bool Hex(const std::string& value,std::size_t count) {
 return value.size()==count && value.find_first_not_of("0123456789abcdef")==std::string::npos;
}
void Fields(const JsonObject& object,std::initializer_list<const wchar_t*> fields,
    std::initializer_list<const wchar_t*> extra={}) {
 Check(object.Size()==fields.size()+extra.size(),"Metadonnees documentaires incompletes.");
 for(const auto* name:fields) Check(object.HasKey(name),"Metadonnees documentaires inconnues.");
 for(const auto* name:extra) Check(object.HasKey(name),"Metadonnees CDA incompletes.");
}
std::string Text(const JsonObject& object,const wchar_t* key) {return winrt::to_string(object.GetNamedString(key));}
std::uint32_t Number(const JsonObject& object,const wchar_t* key,std::uint32_t maximum) {
 const double value=object.GetNamedNumber(key);
 Check(std::isfinite(value) && value>=0 && value<=maximum && std::floor(value)==value,"Taille documentaire invalide.");
 return static_cast<std::uint32_t>(value);
}
void Put(JsonObject& object,const wchar_t* key,const std::string& value){object.Insert(key,JsonValue::CreateStringValue(winrt::to_hstring(value)));}
void Put(JsonObject& object,const wchar_t* key,std::uint32_t value){object.Insert(key,JsonValue::CreateNumberValue(value));}
void PutBool(JsonObject& object,const wchar_t* key,bool value){object.Insert(key,JsonValue::CreateBooleanValue(value));}
void Validate(const Request& request) {
 Check(Hex(request.id,32),"Identifiant documentaire invalide.");
 Check(request.operation=="docx" || request.operation=="pdfa" || request.operation=="version" || request.operation=="cda","Operation documentaire non autorisee.");
 const std::uint32_t limit=request.operation=="version"?10000:request.operation=="docx"?120000:240000;
 Check(request.timeout_ms>0 && request.timeout_ms<=limit,"Delai documentaire invalide.");
 Check(request.input.size()<=(request.operation=="cda"?MaxCdaDocument:MaxDocument),"Document trop volumineux.");
 if(request.operation=="version") Check(request.input.empty() && request.input_hash.empty(),"La version ne prend aucun document.");
 else Check(!request.input.empty() && Hex(request.input_hash,64) && HashBytes(request.input)==request.input_hash,"Empreinte du document incoherente.");
 if(request.operation=="docx") Check(!request.office.empty() && request.office.find('\0')==std::string::npos && request.office.size()<32760,"Chemin LibreOffice invalide.");
 else Check(request.office.empty(),"Chemin d executable non autorise.");
}
struct Packet {JsonObject metadata;std::vector<std::uint8_t> payload;};
constexpr std::array<std::uint8_t,8> ReplyAcknowledgement={'A','B','A','K','E','N','D','1'};
void AcknowledgeReply(HANDLE pipe,ipc::IoBudget* budget) {
 Check(ipc::PipeWriteExact(pipe,ReplyAcknowledgement.data(),ReplyAcknowledgement.size(),budget));
}
void AwaitReplyAcknowledgement(HANDLE pipe,ipc::IoBudget* budget) {
 std::array<std::uint8_t,ReplyAcknowledgement.size()> received{};
 Check(ipc::PipeReadExact(pipe,received.data(),received.size(),budget));
 Check(received==ReplyAcknowledgement,"Accuse de reception documentaire invalide.");
}
Packet Read(HANDLE pipe,ipc::IoBudget* budget,std::size_t maximum) {
 std::array<std::uint8_t,12> prefix{};
 Check(ipc::PipeReadExact(pipe,prefix.data(),prefix.size(),budget));
 std::uint32_t metadata=0;std::uint64_t payload=0;
 for(unsigned i=0;i<4;++i) metadata|=static_cast<std::uint32_t>(prefix[i])<<(8*i);
 for(unsigned i=0;i<8;++i) payload|=static_cast<std::uint64_t>(prefix[i+4])<<(8*i);
 Check(metadata>0 && metadata<=65536 && payload<=maximum,"Reponse documentaire trop volumineuse.");
 std::string text(metadata,'\0');
 Check(ipc::PipeReadExact(pipe,reinterpret_cast<std::uint8_t*>(text.data()),text.size(),budget));
 Check(ipc::ValidUtf8(text),"Metadonnees UTF-8 invalides.");
 Packet packet;packet.metadata=JsonObject::Parse(winrt::to_hstring(text));
 packet.payload.resize(static_cast<std::size_t>(payload));
 Check(ipc::PipeReadExact(pipe,packet.payload.data(),packet.payload.size(),budget));
 return packet;
}
void Write(HANDLE pipe,const JsonObject& metadata,const std::vector<std::uint8_t>& body,ipc::IoBudget* budget,
    std::size_t maximum=MaxReply) {
 const auto text=winrt::to_string(metadata.Stringify());
 Check(!text.empty() && text.size()<=65536 && body.size()<=maximum,"Reponse documentaire trop volumineuse.");
 std::array<std::uint8_t,12> prefix{};
 for(unsigned i=0;i<4;++i) prefix[i]=static_cast<std::uint8_t>((text.size()>>(8*i))&255);
 for(unsigned i=0;i<8;++i) prefix[i+4]=static_cast<std::uint8_t>((static_cast<std::uint64_t>(body.size())>>(8*i))&255);
 Check(ipc::PipeWriteExact(pipe,prefix.data(),prefix.size(),budget));
 Check(ipc::PipeWriteExact(pipe,reinterpret_cast<const std::uint8_t*>(text.data()),text.size(),budget));
 Check(ipc::PipeWriteExact(pipe,body.data(),body.size(),budget));
}
JsonObject RequestMetadata(const Request& request) {
 JsonObject object;
 Put(object,L"contract",Contract);Put(object,L"operation",request.operation);Put(object,L"id",request.id);
 Put(object,L"office",request.office);Put(object,L"inputHash",request.input_hash);
 Put(object,L"inputSize",static_cast<std::uint32_t>(request.input.size()));Put(object,L"timeoutMs",request.timeout_ms);
 return object;
}
Request DecodeRequest(Packet packet) {
 const auto& object=packet.metadata;
 Fields(object,{L"contract",L"operation",L"id",L"office",L"inputHash",L"inputSize",L"timeoutMs"});
 Check(Text(object,L"contract")==Contract,"Protocole documentaire incompatible.");
 Request request;
 request.operation=Text(object,L"operation");request.id=Text(object,L"id");request.office=Text(object,L"office");
 request.input_hash=Text(object,L"inputHash");request.timeout_ms=Number(object,L"timeoutMs",240000);
 Check(Number(object,L"inputSize",static_cast<std::uint32_t>(MaxCdaDocument))==packet.payload.size(),"Document incomplet.");
 request.input=std::move(packet.payload);Validate(request);return request;
}
JsonObject ReplyMetadata(const Reply& reply) {
 JsonObject object;
 Put(object,L"contract",Contract);Put(object,L"operation",reply.operation);Put(object,L"id",reply.id);
 Put(object,L"error",reply.error);Put(object,L"inputHash",reply.input_hash);Put(object,L"pdfHash",reply.pdf_hash);
 Put(object,L"reportedPath",reply.reported_path);Put(object,L"officeVersion",reply.office_version);Put(object,L"officeLauncherHash",reply.office_launcher_hash);
 Put(object,L"officeBinaryHash",reply.office_binary_hash);Put(object,L"pid",reply.pid);
 object.Insert(L"exitCode",JsonValue::CreateNumberValue(reply.exit_code));
 Put(object,L"stdoutSize",static_cast<std::uint32_t>(reply.output.size()));
 Put(object,L"stderrSize",static_cast<std::uint32_t>(reply.diagnostic.size()));
 Put(object,L"pdfSize",static_cast<std::uint32_t>(reply.pdf.size()));
 PutBool(object,L"executed",reply.executed);PutBool(object,L"networkDenied",reply.network_denied);
 PutBool(object,L"writeRestricted",reply.write_restricted);PutBool(object,L"jobObject",reply.job_object);
 PutBool(object,L"privateProfile",reply.private_profile);PutBool(object,L"macrosDisabled",reply.macros_disabled);
 PutBool(object,L"engineVerified",reply.engine_verified);
 if(reply.operation=="cda") {
  Put(object,L"cdaReportsSize",static_cast<std::uint32_t>(reply.cda_reports.size()));
  Put(object,L"cdaReportsHash",reply.cda_reports_hash);
  Put(object,L"referenceManifestHash",reply.cda_manifest_hash);
  Put(object,L"referenceFilesHash",reply.cda_references_hash);
  Put(object,L"helperHash",reply.cda_helper_hash);
 }
 return object;
}
std::vector<std::uint8_t> ReplyBody(const Reply& reply) {
 std::vector<std::uint8_t> body(reply.output.begin(),reply.output.end());
 body.insert(body.end(),reply.diagnostic.begin(),reply.diagnostic.end());
 body.insert(body.end(),reply.pdf.begin(),reply.pdf.end());
 body.insert(body.end(),reply.cda_reports.begin(),reply.cda_reports.end());return body;
}
Reply DecodeReply(Packet packet,const Request& request) {
 const auto& object=packet.metadata;
 Fields(object,{L"contract",L"operation",L"id",L"error",L"inputHash",L"pdfHash",L"reportedPath",L"officeVersion",
     L"officeLauncherHash",L"officeBinaryHash",L"pid",L"exitCode",L"stdoutSize",L"stderrSize",L"pdfSize",L"executed",L"networkDenied",L"writeRestricted",
     L"jobObject",L"privateProfile",L"macrosDisabled",L"engineVerified"},
     request.operation=="cda"?std::initializer_list<const wchar_t*>{L"cdaReportsSize",L"cdaReportsHash",
         L"referenceManifestHash",L"referenceFilesHash",L"helperHash"}:std::initializer_list<const wchar_t*>{});
 Check(Text(object,L"contract")==Contract && Text(object,L"id")==request.id &&
     Text(object,L"operation")==request.operation && Text(object,L"inputHash")==request.input_hash,
     "Reponse liee a un autre travail.");
 Reply reply;reply.id=request.id;reply.operation=request.operation;reply.input_hash=request.input_hash;
 reply.error=Text(object,L"error");reply.pdf_hash=Text(object,L"pdfHash");reply.reported_path=Text(object,L"reportedPath");
 reply.office_version=Text(object,L"officeVersion");
 reply.office_launcher_hash=Text(object,L"officeLauncherHash");reply.office_binary_hash=Text(object,L"officeBinaryHash");
 reply.pid=Number(object,L"pid",0xffffffffu);
 const double exit=object.GetNamedNumber(L"exitCode");
 Check(exit>=-1 && exit<=1 && std::floor(exit)==exit,"Code d execution invalide.");
 reply.exit_code=static_cast<int>(exit);
 const auto out=Number(object,L"stdoutSize",8*1024*1024),err=Number(object,L"stderrSize",1024*1024);
 const auto pdf=Number(object,L"pdfSize",static_cast<std::uint32_t>(MaxDocument));
 const auto reports=request.operation=="cda"?
     Number(object,L"cdaReportsSize",static_cast<std::uint32_t>(MaxCdaReports)):0;
 Check(static_cast<std::size_t>(out)+err+pdf+reports==packet.payload.size(),"Reponse documentaire incomplete.");
 reply.output.assign(packet.payload.begin(),packet.payload.begin()+out);
 reply.diagnostic.assign(packet.payload.begin()+out,packet.payload.begin()+out+err);
 reply.pdf.assign(packet.payload.begin()+out+err,packet.payload.begin()+out+err+pdf);
 if(request.operation=="cda") {
  reply.cda_reports.assign(packet.payload.begin()+out+err+pdf,packet.payload.end());
  reply.cda_reports_hash=Text(object,L"cdaReportsHash");
  reply.cda_manifest_hash=Text(object,L"referenceManifestHash");
  reply.cda_references_hash=Text(object,L"referenceFilesHash");
  reply.cda_helper_hash=Text(object,L"helperHash");
 }
 Check(ipc::ValidUtf8(reply.output) && ipc::ValidUtf8(reply.diagnostic),"Rapport UTF-8 invalide.");
 reply.executed=object.GetNamedBoolean(L"executed");reply.network_denied=object.GetNamedBoolean(L"networkDenied");
 reply.write_restricted=object.GetNamedBoolean(L"writeRestricted");reply.job_object=object.GetNamedBoolean(L"jobObject");
 reply.private_profile=object.GetNamedBoolean(L"privateProfile");reply.macros_disabled=object.GetNamedBoolean(L"macrosDisabled");
 reply.engine_verified=object.GetNamedBoolean(L"engineVerified");
 if(reply.error.empty()) {
  Check(reply.executed && reply.pid>0 && reply.network_denied && reply.write_restricted && reply.job_object,
      "Protections du processus non confirmees.");
  if(request.operation=="docx") Check(reply.exit_code==0 && !reply.pdf.empty() && reply.pdf_hash==HashBytes(reply.pdf) &&
      reply.engine_verified && reply.private_profile && reply.macros_disabled &&
      Hex(reply.office_launcher_hash,64) && Hex(reply.office_binary_hash,64),"Conversion native incomplete.");
  else Check(reply.pdf.empty() && reply.pdf_hash.empty(),"Resultat PDF inattendu.");
  if(request.operation=="cda") {
   Check(reply.cda_reports_hash==HashBytes(reply.cda_reports) && Hex(reply.cda_manifest_hash,64) &&
       Hex(reply.cda_references_hash,64) && Hex(reply.cda_helper_hash,64),"Preuves du controle CDA incoherentes.");
   if(reply.exit_code==0) (void)UnpackCdaReports(reply.cda_reports);
   else Check(reply.exit_code==1 && reply.cda_reports.empty(),"Echec CDA mal forme.");
  }
 }
 return reply;
}
} // namespace

void ClientCancellation::Cancel() {
 cancelled=true;std::lock_guard<std::mutex> lock(mutex);
 if(pipe!=INVALID_HANDLE_VALUE) CancelIoEx(pipe,nullptr);
}
Reply Exchange(const Request& request,ClientCancellation* cancellation) noexcept {
 Reply reply;reply.operation=request.operation;reply.id=request.id;
 try {
  Apartment apartment;Validate(request);
  Check(cancellation && !cancellation->cancelled,"Operation annulee.");
  ipc::InstalledControls installation;Check(ipc::LoadInstalledControls(&installation));
  ipc::PeerPolicy policy;Check(installation.ServicePolicy(&policy));
  PeerQueryGrant query_grant({policy.service_sid});query_grant.Apply();
  OwnedHandle pipe;Check(ipc::OpenLocalPipe(PipeName,&pipe));
  struct Borrow {
   ClientCancellation* cancel;
   ~Borrow(){std::lock_guard<std::mutex> lock(cancel->mutex);cancel->pipe=INVALID_HANDLE_VALUE;}
  } borrow{cancellation};
  {std::lock_guard<std::mutex> lock(cancellation->mutex);cancellation->pipe=pipe.get();}
  Check(!cancellation->cancelled,"Operation annulee.");
  ipc::IoBudget handshake(GetTickCount64(),5000,5000);ipc::PeerLease peer;
  Check(ipc::AuthenticatePipePeer(pipe.get(),ipc::PipePeer::kServer,policy,&handshake,&peer));
  Check(!cancellation->cancelled,"Operation annulee.");
  const auto deadline=request.timeout_ms+60000;
  ipc::IoBudget budget(GetTickCount64(),deadline,deadline);
  Check(installation.Recheck());Check(ipc::RecheckPipePeer(pipe.get(),ipc::PipePeer::kServer,policy,peer));
  Write(pipe.get(),RequestMetadata(request),request.input,&budget,MaxCdaDocument);
  Check(!cancellation->cancelled,"Operation annulee.");
  reply=DecodeReply(Read(pipe.get(),&budget,MaxReply),request);
  Check(installation.Recheck());Check(ipc::RecheckPipePeer(pipe.get(),ipc::PipePeer::kServer,policy,peer));
  // The service keeps this exact connection alive through the final identity
  // check, including when the reply carries an execution error.
  Check(!cancellation->cancelled,"Operation annulee.");
  AcknowledgeReply(pipe.get(),&budget);
  query_grant.Close();
 } catch(const winrt::hresult_error& error) {reply=Reply{};reply.error="Service documentaire : "+winrt::to_string(error.message());}
 catch(const std::exception& error){reply=Reply{};reply.error=error.what();}
 catch(...){reply=Reply{};reply.error="Service documentaire indisponible.";}
 return reply;
}
void Serve(HANDLE stop,void(*ready)()) {
 Apartment apartment;
 ipc::InstalledControls installation;Check(ipc::LoadInstalledControls(&installation));
 Check(CheckBrokerToken(GetCurrentProcess()),"Identite du service invalide.");
  std::vector<std::string> inspection_users;Check(installation.InspectionUsers(&inspection_users));
  PeerQueryGrant query_grant(inspection_users);query_grant.Apply();
 std::string policy_error;if(!VerifyPolicy(&policy_error)) throw std::runtime_error(policy_error);
 PSECURITY_DESCRIPTOR descriptor=nullptr;
 Check(ConvertStringSecurityDescriptorToSecurityDescriptorW(
     L"D:P(A;;GA;;;SY)(A;;GA;;;BA)(A;;GA;;;LS)(A;;0x00100083;;;IU)",SDDL_REVISION_1,&descriptor,nullptr)!=FALSE,
     "Permissions du canal local indisponibles.");
 struct Descriptor {PSECURITY_DESCRIPTOR value;~Descriptor(){LocalFree(value);}} descriptor_guard{descriptor};
 SECURITY_ATTRIBUTES security{sizeof(security),descriptor,FALSE};
 OwnedHandle pipe(CreateNamedPipeW(PipeName,PIPE_ACCESS_DUPLEX|FILE_FLAG_OVERLAPPED|FILE_FLAG_FIRST_PIPE_INSTANCE,
     PIPE_TYPE_BYTE|PIPE_READMODE_BYTE|PIPE_WAIT|PIPE_REJECT_REMOTE_CLIENTS,1,65536,65536,0,&security));
 Check(static_cast<bool>(pipe),"Creation du canal documentaire impossible.");
 if(ready) ready();
 while(WaitForSingleObject(stop,0)==WAIT_TIMEOUT) {
  ipc::IoBudget connect(GetTickCount64(),1000,1000);
  const auto accepted=ipc::AcceptPipe(pipe.get(),&connect);
  if(accepted) {
   if(accepted.code=="PIPE_TIMEOUT") continue;
   DisconnectNamedPipe(pipe.get());
   Check(accepted);
  }
  try {
   ipc::IoBudget handshake(GetTickCount64(),5000,5000);ipc::PeerPolicy policy;ipc::PeerLease peer;
   // Authentication consumes the native hello before any metadata/document.
   Check(installation.CompanionPolicyForPipe(pipe.get(),&policy));
   Check(ipc::AuthenticatePipePeer(pipe.get(),ipc::PipePeer::kClient,policy,&handshake,&peer));
   ipc::IoBudget input_budget(GetTickCount64(),15000,5000);
   auto request=DecodeRequest(Read(pipe.get(),&input_budget,MaxCdaDocument));
   Check(installation.Recheck());Check(ipc::RecheckPipePeer(pipe.get(),ipc::PipePeer::kClient,policy,peer));
   Reply reply;
   try {reply=RunWorker(request,stop,peer.process.get());}
   catch(const std::exception& error){reply.error=error.what();}
   catch(...){reply.error="Execution documentaire interrompue.";}
   reply.id=request.id;reply.operation=request.operation;reply.input_hash=request.input_hash;
   Check(installation.Recheck());Check(ipc::RecheckPipePeer(pipe.get(),ipc::PipePeer::kClient,policy,peer));
   ipc::IoBudget output_budget(GetTickCount64(),15000,5000);
   Write(pipe.get(),ReplyMetadata(reply),ReplyBody(reply),&output_budget);
   // An overlapped write may complete while bytes remain buffered. Do not
   // disconnect until the client has read the reply and checked our identity.
   // The existing I/O budget bounds this wait and a closed client aborts it.
   AwaitReplyAcknowledgement(pipe.get(),&output_budget);
  } catch(const winrt::hresult_error& error) {LogRequestFailure(winrt::to_string(error.message()));}
  catch(const std::exception& error) {LogRequestFailure(error.what());}
  catch(...) {LogRequestFailure("Requete documentaire interrompue.");}
  DisconnectNamedPipe(pipe.get());
 }
}
}
