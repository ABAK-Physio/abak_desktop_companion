#include "document_controls_channel.h"
#include "document_controls_launcher.h"
#include "../document_controls_runtime/runtime.h"
#include <flutter/standard_method_codec.h>
#include <bcrypt.h>
#include <array>
#include <mutex>
#include <thread>

namespace runtime=document_controls_runtime;
namespace {
using Value=flutter::EncodableValue;
using Map=flutter::EncodableMap;
using Result=flutter::MethodResult<Value>;
template<class T> const T* Get(const Map& map,const char* name) {
 const auto item=map.find(Value(name));
 return item==map.end()?nullptr:std::get_if<T>(&item->second);
}
std::string RequestId() {
 std::array<UCHAR,16> bytes{};
 if(BCryptGenRandom(nullptr,bytes.data(),static_cast<ULONG>(bytes.size()),BCRYPT_USE_SYSTEM_PREFERRED_RNG)<0) return {};
 constexpr char hex[]="0123456789abcdef";
 std::string text;for(const auto value:bytes){text+=hex[value>>4];text+=hex[value&15];}return text;
}
Map Response(runtime::Reply reply) {
 Map isolation{{Value("platform"),Value("windows")},{Value("serviceIdentifier"),Value("ABAKDocumentControls")},
     {Value("networkDenied"),Value(reply.network_denied)},{Value("writeRestricted"),Value(reply.write_restricted)},
     {Value("jobObject"),Value(reply.job_object)},{Value("restrictingSids"),Value("service+World")}};
 Map response{{Value("protocol"),Value(1)},{Value("operation"),Value(reply.operation)},
     {Value("requestId"),Value(reply.id)},{Value("pid"),Value(static_cast<std::int64_t>(reply.pid))},
     {Value("exitCode"),Value(reply.exit_code)},{Value("stdout"),Value(reply.output)},
     {Value("stderr"),Value(reply.diagnostic)},{Value("isolation"),Value(isolation)},
     {Value("inputHash"),Value(reply.input_hash)},{Value("sourceHash"),Value(reply.input_hash)},
     {Value("pdfHash"),Value(reply.pdf_hash)},{Value("pdf"),Value(std::move(reply.pdf))},
     {Value("reportedPath"),Value(reply.reported_path)},{Value("officeVersion"),Value(reply.office_version)},
     {Value("officeLauncherHash"),Value(reply.office_launcher_hash)},{Value("officeBinaryHash"),Value(reply.office_binary_hash)},
     {Value("engineSignatureVerified"),Value(reply.engine_verified)},
     {Value("networkDenied"),Value(reply.network_denied)},{Value("privateProfile"),Value(reply.private_profile)},
     {Value("macrosDisabled"),Value(reply.macros_disabled)}};
 if(reply.operation=="cda") {
  response.emplace(Value("cdaReports"),Value(std::move(reply.cda_reports)));
  response.emplace(Value("cdaReportsHash"),Value(reply.cda_reports_hash));
  response.emplace(Value("referenceManifestHash"),Value(reply.cda_manifest_hash));
  response.emplace(Value("referenceFilesHash"),Value(reply.cda_references_hash));
  response.emplace(Value("helperHash"),Value(reply.cda_helper_hash));
 }
 return response;
}
}
struct DocumentControlsChannel::Pending {
 std::unique_ptr<Result> result;
 runtime::ClientCancellation cancellation;
 runtime::Request request;
 runtime::Reply reply;
 std::thread thread;
 std::mutex mutex;
 HWND window=nullptr;
 bool ready=false;
};
DocumentControlsChannel::DocumentControlsChannel(flutter::BinaryMessenger* messenger,HWND window):window_(window) {
 channel_=std::make_unique<flutter::MethodChannel<Value>>(messenger,"abak/document_controls",
     &flutter::StandardMethodCodec::GetInstance());
 channel_->SetMethodCallHandler([this](const flutter::MethodCall<Value>& call,std::unique_ptr<Result> result) {
  const auto* arguments=std::get_if<Map>(call.arguments());
  if(call.method_name()=="runWindows") {
   if(pending_) {result->Error("DOCUMENT_CONTROLS_BUSY","Un controle documentaire est deja en cours.");return;}
   if(!arguments) {result->Error("INVALID_ARGUMENTS","Parametres documentaires absents.");return;}
   const auto* operation=Get<std::string>(*arguments,"operation");
   const auto* protocol=Get<std::int32_t>(*arguments,"protocol");
   const auto* input=Get<std::vector<std::uint8_t>>(*arguments,"input");
   const auto* expected=Get<std::string>(*arguments,"inputHash");
   if(!operation || !protocol || *protocol!=1 || !input || !expected ||
       input->size()>(*operation=="cda"?runtime::MaxCdaDocument:runtime::MaxDocument) ||
       (*operation!="docx" && *operation!="pdfa" && *operation!="version" && *operation!="cda")) {
    result->Error("INVALID_ARGUMENTS","Operation ou contenu documentaire invalide.");return;
   }
   auto pending=std::make_shared<Pending>();
   pending->request.operation=*operation;pending->request.input=*input;pending->request.input_hash=*expected;
   pending->request.id=RequestId();pending->window=window_;
   pending->request.timeout_ms=*operation=="version"?10000:*operation=="docx"?120000:240000;
   if(*operation=="docx") {
    const auto* office=Get<std::string>(*arguments,"office");
    if(!office) {result->Error("INVALID_ARGUMENTS","Chemin LibreOffice absent.");return;}
    pending->request.office=*office;
   }
   pending->result=std::move(result);pending_=pending;
   pending->thread=std::thread([pending] {
    auto reply=runtime::Exchange(pending->request,&pending->cancellation);
    {std::lock_guard<std::mutex> lock(pending->mutex);pending->reply=std::move(reply);pending->ready=true;}
    PostMessageW(pending->window,CompletionMessage,0,0);
   });
   return;
  }
  // The old W1-W5 channel is retained for operations not ported here.
  if(call.method_name()=="run") {
   const auto* name=arguments?Get<std::string>(*arguments,"operation"):nullptr;
   document_controls::Operation operation;
   if(!name || !document_controls::ParseOperation(*name,&operation)) {
    result->Error("INVALID_OPERATION","Operation documentaire non autorisee.");return;
   }
   const auto launch=document_controls::Launch(operation);
   result->Error(launch.error_code,launch.message);return;
  }
  result->NotImplemented();
 });
}
void DocumentControlsChannel::Complete() {
 auto pending=pending_;
 if(!pending) return;
 {std::lock_guard<std::mutex> lock(pending->mutex);if(!pending->ready) return;}
 if(pending->thread.joinable()) pending->thread.join();
 std::lock_guard<std::mutex> lock(pending->mutex);
 if(pending->reply.error.empty()) pending->result->Success(Value(Response(std::move(pending->reply))));
 else pending->result->Error("WINDOWS_DOCUMENT_CONTROLS_FAILED",
     "Controle documentaire non execute. "+pending->reply.error);
 pending_.reset();
}
DocumentControlsChannel::~DocumentControlsChannel() {
 if(channel_) channel_->SetMethodCallHandler(nullptr);
 if(pending_) {
  if(pending_->thread.joinable()) {
   // Repeat cancellation until the exchange has ended, including an I/O that
   // started just after a previous CancelIoEx call during window destruction.
   do {pending_->cancellation.Cancel();}
   while(WaitForSingleObject(pending_->thread.native_handle(),25)==WAIT_TIMEOUT);
   pending_->thread.join();
  }
  pending_.reset();
 }
}
