#include "runtime.h"
#include "../runner/document_controls_installation_security.h"
#include "../runner/document_controls_peer_identity.h"
#include <bcrypt.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.Foundation.Collections.h>
#include <winrt/Windows.Data.Json.h>
#include <array>
#include <stdexcept>
#include <map>
#include <set>
#include <cwctype>

namespace document_controls_runtime {
namespace ipc=document_controls::windows_ipc;
namespace {
void Check(bool value,const char* message) {if(!value) throw std::runtime_error(message);}
std::string ReadSmall(HANDLE file) {
 LARGE_INTEGER length{};
 Check(GetFileSizeEx(file,&length) && length.QuadPart>0 && length.QuadPart<=4*1024*1024,
     "Manifeste des outils absent ou trop volumineux.");
 std::string text(static_cast<std::size_t>(length.QuadPart),'\0');
 DWORD count=0;
 Check(ReadFile(file,text.data(),static_cast<DWORD>(text.size()),&count,nullptr) && count==text.size(),
     "Lecture du manifeste des outils impossible.");
 if(text.compare(0,3,"\xef\xbb\xbf")==0) text.erase(0,3);
 return text;
}
ToolLease Pin(const std::wstring& path) {
 ToolLease lease;
 lease.file.reset(CreateFileW(path.c_str(),GENERIC_READ|READ_CONTROL,FILE_SHARE_READ,
     nullptr,OPEN_EXISTING,FILE_FLAG_OPEN_REPARSE_POINT,nullptr));
 Check(static_cast<bool>(lease.file),"Outil installe absent ou occupe.");
 if(auto e=ipc::VerifyProtectedFile(lease.file.get(),path,&lease.ancestors))
  throw std::runtime_error(e.code+": "+e.message);
 return lease;
}
}
std::wstring Wide(const std::string& value) {
 if(value.empty()) return {};
 Check(value.size()<=32760,"Texte de chemin trop long.");
 const int size=MultiByteToWideChar(CP_UTF8,MB_ERR_INVALID_CHARS,value.data(),static_cast<int>(value.size()),nullptr,0);
 Check(size>0,"Texte UTF-8 invalide.");
 std::wstring result(static_cast<std::size_t>(size),L'\0');
 Check(MultiByteToWideChar(CP_UTF8,MB_ERR_INVALID_CHARS,value.data(),static_cast<int>(value.size()),result.data(),size)==size,
     "Conversion du chemin impossible.");
 return result;
}
std::string Utf8Text(const std::wstring& value) {
 if(value.empty()) return {};
 Check(value.size()<=32760,"Texte de chemin trop long.");
 const int size=WideCharToMultiByte(CP_UTF8,WC_ERR_INVALID_CHARS,value.data(),static_cast<int>(value.size()),nullptr,0,nullptr,nullptr);
 Check(size>0,"Texte UTF-16 invalide.");
 std::string result(static_cast<std::size_t>(size),'\0');
 Check(WideCharToMultiByte(CP_UTF8,WC_ERR_INVALID_CHARS,value.data(),static_cast<int>(value.size()),result.data(),size,nullptr,nullptr)==size,
     "Conversion du chemin impossible.");
 return result;
}
std::wstring ApplicationRoot() {
 std::array<wchar_t,32768> image{};
 const DWORD size=GetModuleFileNameW(nullptr,image.data(),static_cast<DWORD>(image.size()));
 Check(size>0 && size<image.size(),"Chemin de Companion indisponible.");
 std::wstring path(image.data(),size);
 const auto slash=path.find_last_of(L'\\');
 Check(slash!=std::wstring::npos,"Dossier de Companion indisponible.");
 return path.substr(0,slash);
}
std::string HashBytes(const std::vector<std::uint8_t>& bytes) {
 BCRYPT_ALG_HANDLE algorithm=nullptr;
 BCRYPT_HASH_HANDLE hash=nullptr;
 Check(BCryptOpenAlgorithmProvider(&algorithm,BCRYPT_SHA256_ALGORITHM,nullptr,0)>=0,"SHA-256 indisponible.");
 struct Algorithm {BCRYPT_ALG_HANDLE value;~Algorithm(){BCryptCloseAlgorithmProvider(value,0);}} alg{algorithm};
 DWORD object_size=0,returned=0;
 Check(BCryptGetProperty(algorithm,BCRYPT_OBJECT_LENGTH,reinterpret_cast<PUCHAR>(&object_size),sizeof(object_size),&returned,0)>=0,
     "SHA-256 indisponible.");
 std::vector<BYTE> object(object_size);
 Check(BCryptCreateHash(algorithm,&hash,object.data(),object_size,nullptr,0,0)>=0,"SHA-256 indisponible.");
 struct Hash {BCRYPT_HASH_HANDLE value;~Hash(){BCryptDestroyHash(value);}} guard{hash};
 Check(bytes.size()<=MaxCdaDocument,"Contenu trop volumineux.");
 if(!bytes.empty()) Check(BCryptHashData(hash,const_cast<PUCHAR>(bytes.data()),static_cast<ULONG>(bytes.size()),0)>=0,"SHA-256 en echec.");
 std::array<BYTE,32> digest{};
 Check(BCryptFinishHash(hash,digest.data(),static_cast<ULONG>(digest.size()),0)>=0,"SHA-256 en echec.");
 constexpr char hex[]="0123456789abcdef";
 std::string text;
 for(const BYTE value:digest) {text+=hex[value>>4];text+=hex[value&15];}
 return text;
}
VerifiedTools LoadTools() {
 using namespace winrt::Windows::Data::Json;
 const auto root=ApplicationRoot()+L"\\data\\DmpTools\\x64\\";
 VerifiedTools result;
 result.leases.push_back(Pin(root+L"manifest.json"));
 const auto manifest=JsonObject::Parse(winrt::to_hstring(ReadSmall(result.leases.back().file.get())));
 Check(manifest.GetNamedNumber(L"protocol")==1 && manifest.GetNamedString(L"profile")==L"PDF/A-1b" &&
     manifest.GetNamedString(L"arch")==L"x64","Manifeste des outils incompatible.");
 const auto files=manifest.GetNamedObject(L"files");
 Check(files.Size()>0 && files.Size()<=2048 && files.HasKey(L"java/bin/java.exe") && files.HasKey(L"vera/cli.jar"),
     "Outils Java/veraPDF incomplets.");
 for(const auto& entry:files) {
  std::wstring relative(entry.Key());
  Check(!relative.empty() && relative.size()<1024 && relative.front()!=L'/' && relative.back()!=L'/' &&
      relative.find(L'\\')==std::wstring::npos && relative.find(L':')==std::wstring::npos &&
      relative.find(L'\0')==std::wstring::npos,"Chemin du manifeste invalide.");
  std::size_t start=0;
  for(;;) {
   const auto end=relative.find(L'/',start);
   const auto part=relative.substr(start,end==std::wstring::npos?end:end-start);
   Check(!part.empty() && part!=L"." && part!=L"..","Chemin du manifeste invalide.");
   if(end==std::wstring::npos) break;
   start=end+1;
  }
  for(auto& c:relative) if(c==L'/') c=L'\\';
  auto lease=Pin(root+relative);
  std::string actual;
  if(auto e=ipc::HashOpenImage(lease.file.get(),&actual)) throw std::runtime_error(e.message);
  Check(actual==winrt::to_string(entry.Value().GetString()),"Outil DMP modifie : reinstallez Companion.");
  result.leases.push_back(std::move(lease));
 }
 result.java=root+L"java\\bin\\java.exe";result.jar=root+L"vera\\cli.jar";
 return result;
}
namespace {
std::string CdaFileHash(HANDLE file) {
 LARGE_INTEGER size{};
 Check(GetFileSizeEx(file,&size) && size.QuadPart>=0 && size.QuadPart<=64LL*1024*1024,
     "Reference CDA trop volumineuse.");
 if(size.QuadPart==0) return HashBytes({});
 std::string hash;
 if(auto error=ipc::HashOpenImage(file,&hash)) throw std::runtime_error(error.message);
 return hash;
}
void CopyCdaFile(HANDLE source,const std::wstring& target) {
 OwnedHandle file(CreateFileW(target.c_str(),GENERIC_WRITE,0,nullptr,CREATE_NEW,
     FILE_ATTRIBUTE_NORMAL,nullptr));
 Check(static_cast<bool>(file),"Impossible de creer la copie privee CDA.");
 LARGE_INTEGER zero{};
 Check(SetFilePointerEx(source,zero,nullptr,FILE_BEGIN)!=FALSE,"Reference CDA illisible.");
 std::array<BYTE,65536> buffer{};
 for(;;) {
  DWORD count=0,written=0;
  Check(ReadFile(source,buffer.data(),static_cast<DWORD>(buffer.size()),&count,nullptr)!=FALSE,
      "Lecture de reference CDA interrompue.");
  if(!count) break;
  Check(WriteFile(file.get(),buffer.data(),count,&written,nullptr) && written==count,
      "Copie de reference CDA interrompue.");
 }
 Check(FlushFileBuffers(file.get())!=FALSE,"Copie CDA non conservee.");
}
void CdaParentDirectories(const std::wstring& root,const std::wstring& relative) {
 std::size_t end=0;
 while((end=relative.find(L'\\',end))!=std::wstring::npos) {
  const auto path=root+L"\\"+relative.substr(0,end);
  if(!CreateDirectoryW(path.c_str(),nullptr)) Check(GetLastError()==ERROR_ALREADY_EXISTS,
      "Repertoire prive CDA indisponible.");
  const auto attrs=GetFileAttributesW(path.c_str());
  Check(attrs!=INVALID_FILE_ATTRIBUTES && (attrs&FILE_ATTRIBUTE_DIRECTORY) &&
      !(attrs&FILE_ATTRIBUTE_REPARSE_POINT),"Repertoire CDA redirige.");
  ++end;
 }
}
}
CdaResources PrepareCdaResources(const std::wstring& job) {
 using namespace winrt::Windows::Data::Json;
 CdaResources result;
 const auto installed=ApplicationRoot()+L"\\data\\CdaReferences\\x64";
 auto manifest_file=Pin(installed+L"\\manifest.json");
 result.manifest_hash=CdaFileHash(manifest_file.file.get());
 const auto manifest=JsonObject::Parse(winrt::to_hstring(ReadSmall(manifest_file.file.get())));
 Check(manifest.GetNamedNumber(L"protocol")==1 && manifest.GetNamedString(L"profile")==L"CDA" &&
     manifest.GetNamedString(L"source")==L"ANS/TestContenuCDA-3-0" &&
     manifest.GetNamedString(L"revision")==L"b10ff7b0bdcad0a0f9006d7054ca670d60d8720c",
     "Referentiel CDA installe incompatible.");
 const auto entries=manifest.GetNamedObject(L"files");
 Check(entries.Size()>0 && entries.Size()<=18000,"Manifeste CDA vide ou trop volumineux.");
 std::map<std::string,std::string> hashes;
 std::set<std::wstring> folded;
 for(const auto& entry:entries) {
  const auto name=winrt::to_string(entry.Key());
  auto hash=winrt::to_string(entry.Value().GetString());
  for(auto& c:hash) if(c>='A' && c<='F') c=static_cast<char>(c-'A'+'a');
  Check(ValidCdaReferencePath(name) && name!="manifest.json","Chemin du referentiel CDA invalide.");
  auto lower=Wide(name);
  for(auto& c:lower) c=static_cast<wchar_t>(std::towlower(c));
  Check(folded.insert(lower).second,"Chemin du referentiel CDA duplique.");
  Check(hashes.emplace(name,hash).second,"Reference CDA dupliquee.");
 }
 for(const auto* name:{"infrastructure/cda/CDA_extended.xsd","schematrons/moteur/saxon9he.jar",
     "schematrons/profils/IHE.sch"}) Check(hashes.count(name)==1,"Referentiel CDA incomplet.");
 const auto fingerprint=CdaReferenceFingerprintInput(hashes);
 result.references_hash=HashBytes(std::vector<std::uint8_t>(fingerprint.begin(),fingerprint.end()));
 const auto copy_root=job+L"\\references";
 Check(CreateDirectoryW(copy_root.c_str(),nullptr)!=FALSE,"Un espace CDA neuf est requis.");
 std::uint64_t total=0;
 for(const auto& entry:hashes) {
  auto relative=Wide(entry.first);
  for(auto& c:relative) if(c==L'/') c=L'\\';
  auto source=Pin(installed+L"\\"+relative);
  LARGE_INTEGER size{};
  Check(GetFileSizeEx(source.file.get(),&size) && size.QuadPart>=0,"Reference CDA illisible.");
  total+=static_cast<std::uint64_t>(size.QuadPart);
  Check(total<=800ULL*1024*1024 && CdaFileHash(source.file.get())==entry.second,
      "Referentiel CDA incomplet ou modifie : reinstallez Companion.");
  if(!IncludedCdaReference(entry.first)) continue;
  CdaParentDirectories(copy_root,relative);
  const auto target=copy_root+L"\\"+relative;
  CopyCdaFile(source.file.get(),target);
  result.copies.emplace_back(target,entry.second);
 }
 auto helper=Pin(ApplicationRoot()+L"\\data\\DocumentControls\\CdaCheck.java");
 result.helper_hash=CdaFileHash(helper.file.get());
 result.helper=job+L"\\CdaCheck.java";
 CopyCdaFile(helper.file.get(),result.helper);
 result.copies.emplace_back(result.helper,result.helper_hash);
 result.saxon=copy_root+L"\\schematrons\\moteur\\saxon9he.jar";
 RecheckCdaResources(result);
 return result;
}
void RecheckCdaResources(const CdaResources& resources) {
 // Run only before the restricted child starts and after its whole job ends.
 // Neither the caller nor another request can access this private workspace.
 for(const auto& item:resources.copies) {
  OwnedHandle file(CreateFileW(item.first.c_str(),GENERIC_READ,FILE_SHARE_READ,nullptr,
      OPEN_EXISTING,FILE_FLAG_OPEN_REPARSE_POINT,nullptr));
  BY_HANDLE_FILE_INFORMATION info{};
  Check(file && GetFileInformationByHandle(file.get(),&info) &&
      !(info.dwFileAttributes&(FILE_ATTRIBUTE_DIRECTORY|FILE_ATTRIBUTE_REPARSE_POINT)) &&
      CdaFileHash(file.get())==item.second,"Copie CDA modifiee pendant le controle.");
 }
}
}
