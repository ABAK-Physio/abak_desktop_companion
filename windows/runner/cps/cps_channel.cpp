#include "cps_channel.h"
#include "cps_windows_client.h"
#include "cps_signature.h"
#include <flutter/standard_method_codec.h>
#include <atomic>
#include <thread>
#include <utility>

namespace {
using Value = flutter::EncodableValue;
using Map = flutter::EncodableMap;
using Result = flutter::MethodResult<Value>;
Map Response(cps_windows::Reply reply) {
  Map result{{Value("success"), Value(reply.success)}, {Value("platform"), Value("windows")}};
  if (!reply.success) {
    result[Value("step")] = Value(reply.step);
    if (!reply.error.empty()) result[Value("error")] = Value(reply.error);
    result[Value("returnCode")] = Value(static_cast<std::int64_t>(reply.code));
    result[Value("windowsError")] = Value(static_cast<std::int64_t>(reply.windows_error));
    result[Value("tokenSlotCount")] = Value(static_cast<std::int64_t>(reply.slot_count));
    if (!reply.object_label.empty()) result[Value("objectLabel")] = Value(reply.object_label);
  } else {
    Map objects;
    for (auto& entry : reply.objects) objects[Value(entry.first)] = Value(std::move(entry.second));
    result[Value("objects")] = Value(std::move(objects));
    if (reply.operation != cps_windows::Operation::Read) {
      result[Value("nationalId")] = Value(reply.national_id);
      flutter::EncodableList certificates;
      for (const auto& c : reply.certificates) {
        certificates.emplace_back(Map{{Value("role"), Value(c.role)},
            {Value("nationalId"), Value(c.national_id)},
            {Value("certificateBase64"), Value(cps_windows::Base64(c.der))},
            {Value("sha256"), Value(c.sha256)}, {Value("validFrom"), Value(c.valid_from)},
            {Value("validUntil"), Value(c.valid_until)}});
      }
      result[Value("certificates")] = Value(std::move(certificates));
      if (reply.operation != cps_windows::Operation::Prepare) {
        result[Value("verified")] = Value(reply.verified);
        result[Value("tamperedMessageRejected")] = Value(reply.tampered_rejected);
        result[Value("algorithm")] = Value(reply.algorithm);
        result[Value("message")] = Value(reply.message);
        result[Value("signatureBase64")] = Value(cps_windows::Base64(reply.signature));
        result[Value("signingCertificateBase64")] = Value(cps_windows::Base64(reply.certificates[0].der));
      }
    }
  }
  return result;
}
bool UnavailableMethod(const std::string& method) {
  return method == "diagnosePkcs11" ||
      method == "loginPkcs11User" || method == "listPkcs11Objects" ||
      method == "getPkcs11SigningCertificate" || method == "signPkcs11TestMessage";
}
}
struct CpsChannel::Pending {
  std::unique_ptr<Result> result;
  cps_windows::Request request;
  cps_windows::Reply reply;
  std::thread thread;
  std::atomic<bool> cancelled{false}, ready{false};
  HWND window = nullptr;

};
CpsChannel::CpsChannel(flutter::BinaryMessenger* messenger, HWND window) : window_(window) {
  channel_ = std::make_unique<flutter::MethodChannel<Value>>(messenger, "abak_dmp_fr",
      &flutter::StandardMethodCodec::GetInstance());
  channel_->SetMethodCallHandler([this](const flutter::MethodCall<Value>& call,
                                      std::unique_ptr<Result> result) {
    if (call.method_name() == "windowsCpsLibraryPath") {
      wchar_t directory[32768]{};
      const UINT length = GetSystemDirectoryW(directory, 32768);
      if (!length || length >= 32768) {
        result->Error("CPS_SYSTEM_DIRECTORY", "Dossier systeme Windows indisponible."); return;
      }
      const std::wstring path = std::wstring(directory) + L"\\cps3_pkcs11_w64.dll";
      const int size = WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, path.data(),
          static_cast<int>(path.size()), nullptr, 0, nullptr, nullptr);
      if (size <= 0) { result->Error("CPS_SYSTEM_DIRECTORY", "Chemin Windows illisible."); return; }
      std::string utf8(static_cast<std::size_t>(size), '\0');
      if (WideCharToMultiByte(CP_UTF8, WC_ERR_INVALID_CHARS, path.data(),
          static_cast<int>(path.size()), utf8.data(), size, nullptr, nullptr) != size) {
        result->Error("CPS_SYSTEM_DIRECTORY", "Chemin Windows illisible."); return;
      }
      result->Success(Value(utf8)); return;
    }
    cps_windows::Operation operation;
    if (call.method_name() == "readCpsProfile") operation = cps_windows::Operation::Read;
    else if (call.method_name() == "prepareDmpLotLocal") operation = cps_windows::Operation::Prepare;
    else if (call.method_name() == "signDmpLotLocal") operation = cps_windows::Operation::Sign;
    else if (call.method_name() == "testCpsSignature") operation = cps_windows::Operation::Test;
    else {
      if (UnavailableMethod(call.method_name()))
        result->Error("CPS_WINDOWS_OPERATION_UNAVAILABLE",
            "Cette operation CPS n'est pas encore disponible sous Windows.");
      else result->NotImplemented();
      return;
    }
    if (pending_) { result->Error("CPS_BUSY", "Une lecture CPS est deja en cours."); return; }
    const auto* map = call.arguments() ? std::get_if<Map>(call.arguments()) : nullptr;
    const auto found = map ? map->find(Value("pin")) : Map::const_iterator{};
    const auto* pin = map && found != map->end() ? std::get_if<std::string>(&found->second) : nullptr;
    std::vector<cps_windows::Byte> bytes;
    if (pin && pin->size() <= 16) bytes.assign(pin->begin(), pin->end());
    if (!cps_windows::ValidPin(bytes)) {
      cps_windows::Erase(&bytes);
      result->Error("INVALID_PIN_FORMAT", "Saisissez le PIN numerique de votre CPS."); return;
    }
    cps_windows::Request request; request.operation = operation; request.pin = std::move(bytes);
    const auto parameter = [&](const char* name, std::size_t maximum, std::string* target) {
      const auto item = map->find(Value(name));
      const auto* value = item != map->end() ? std::get_if<std::string>(&item->second) : nullptr;
      if (!value || value->empty() || value->size() > maximum) return false;
      *target = *value; return true;
    };
    if ((operation != cps_windows::Operation::Read &&
        !parameter("expectedNationalId", 64, &request.expected_id)) ||
        (operation == cps_windows::Operation::Sign &&
        (!parameter("signedInfo", 32768, &request.signed_info) ||
         !parameter("certificateBase64", 87384, &request.expected_certificate))) ||
        !cps_windows::ValidRequest(request)) {
      result->Error("INVALID_CPS_REQUEST", "Preparation de signature CPS incomplete ou invalide."); return;
    }
    auto pending = std::make_shared<Pending>();
    pending->request = std::move(request); pending->result = std::move(result);
    pending->window = window_; pending_ = pending;
    try {
      pending->thread = std::thread([pending] {
        try {
          pending->reply = cps_windows::RunOperation(std::move(pending->request), &pending->cancelled);
        } catch (...) {
          cps_windows::Erase(&pending->request.pin);
          pending->reply = cps_windows::Reply{};
          pending->reply.transport_error = "La lecture CPS n'a pas pu etre terminee.";
        }
        pending->ready.store(true);
        PostMessageW(pending->window, CompletionMessage, 0, 0);
      });
    } catch (...) {
      cps_windows::Erase(&pending->request.pin);
      pending->result->Error("CPS_WORKER_START_FAILED", "Impossible de demarrer la lecture CPS.");
      pending_.reset();
    }
  });
}
void CpsChannel::Complete() {
  auto pending = pending_;
  if (!pending || !pending->ready.load()) return;
  if (pending->thread.joinable()) pending->thread.join();
  if (!pending->reply.transport_error.empty())
    pending->result->Error("CPS_WINDOWS_READER_FAILED", pending->reply.transport_error);
  else pending->result->Success(Value(Response(std::move(pending->reply))));
  pending_.reset();
}
CpsChannel::~CpsChannel() {
  if (channel_) channel_->SetMethodCallHandler(nullptr);
  if (pending_) {
    pending_->cancelled.store(true);
    if (pending_->thread.joinable()) pending_->thread.join();
    pending_.reset();
  }
}
