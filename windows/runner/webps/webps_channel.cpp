#include "webps_channel.h"
#include "webps_policy.h"
#include <flutter/standard_method_codec.h>
#include <atomic>
#include <exception>
#include <thread>
#include <utility>

namespace {
using Value = flutter::EncodableValue;
using Map = flutter::EncodableMap;
Map Response(const abak_webps::State& state) {
  return {{Value("active"), Value(state.active)}, {Value("opening"), Value(false)},
      {Value("browserPath"), Value(state.browser)}};
}
}
struct WebPsChannel::Pending {
  std::unique_ptr<Result> result;
  abak_webps::State state;
  std::string error;
  std::thread thread;
  std::atomic<bool> cancelled{false}, ready{false};
};
WebPsChannel::WebPsChannel(flutter::BinaryMessenger* messenger, HWND window) : window_(window) {
  channel_ = std::make_unique<flutter::MethodChannel<Value>>(messenger, "abak/webps_browser",
      &flutter::StandardMethodCodec::GetInstance());
  channel_->SetMethodCallHandler([this](const flutter::MethodCall<Value>& call, std::unique_ptr<Result> result) {
    const auto method = call.method_name();
    if (method != "discover" && method != "open" && method != "status" && method != "close") {
      result->NotImplemented(); return;
    }
    if (method == "discover") {
      try {
        flutter::EncodableList installed;
        for (const auto* browser : {"com.microsoft.edge", "org.mozilla.firefox"}) {
          try {
            const auto path = abak_webps::Utf8(abak_webps::Browser::Find(browser));
            installed.emplace_back(Map{{Value("browser"), Value(browser)}, {Value("path"), Value(path)}});
          } catch (const std::exception&) { /* Discovery does not launch a browser. */ }
        }
        result->Success(Value(Map{{Value("browsers"), Value(std::move(installed))}}));
      } catch (const std::exception& error) { result->Error("WEBPS_BROWSER", error.what()); }
      return;
    }
    if (pending_) {
      if (method == "close" && !queued_close_) {
        pending_->cancelled.store(true); queued_close_ = std::move(result); return;
      }
      result->Error("WEBPS_BUSY", "Une operation du navigateur DMP est en cours."); return;
    }
    std::string url, browser;
    if (method == "open") {
      const auto* map = call.arguments() ? std::get_if<Map>(call.arguments()) : nullptr;
      const auto text = [&](const char* name) -> std::string {
        if (!map) return {};
        const auto found = map->find(Value(name));
        if (found == map->end()) return {};
        const auto* value = std::get_if<std::string>(&found->second);
        return value ? *value : std::string{};
      };
      const auto confirmed = map ? map->find(Value("confirmed")) : Map::const_iterator{};
      const auto* yes = map && confirmed != map->end() ? std::get_if<bool>(&confirmed->second) : nullptr;
      url = text("url"); browser = text("browser");
      if (!map || map->size() != 3 || !yes || !*yes || !abak_webps::SupportedBrowser(browser) ||
          !abak_webps::ValidUrl(url)) {
        result->Error("WEBPS_REQUEST", "Confirmez une adresse Web-PS DV1 prise en charge."); return;
      }
    }
    // The browser id is validated independently of the URL.
    Start(method, url, std::move(result), browser);
  });
}
void WebPsChannel::Start(const std::string& method, const std::string& url, std::unique_ptr<Result> result, const std::string& browser) {
  auto pending = std::make_shared<Pending>(); pending->result = std::move(result); pending_ = pending;
  try {
    pending->thread = std::thread([this, pending, method, url, browser] {
      try {
        if (method == "open") pending->state = browser_.Open(browser, url, pending->cancelled);
        else if (method == "close") pending->state = browser_.Close();
        else pending->state = browser_.Status();
      } catch (const std::exception& error) { pending->error = error.what(); }
      catch (...) { pending->error = "Operation du navigateur DMP interrompue."; }
      pending->ready.store(true);
      PostMessageW(window_, CompletionMessage, 0, 0);
    });
  } catch (...) {
    pending_->result->Error("WEBPS_THREAD", "Impossible de preparer le navigateur DMP."); pending_.reset();
  }
}
void WebPsChannel::Complete() {
  if (!pending_ || !pending_->ready.load()) return;
  auto pending = std::move(pending_);
  if (pending->thread.joinable()) pending->thread.join();
  if (pending->error.empty()) pending->result->Success(Value(Response(pending->state)));
  else pending->result->Error("WEBPS_BROWSER", pending->error);
  if (queued_close_) Start("close", {}, std::move(queued_close_));
}
WebPsChannel::~WebPsChannel() {
  channel_->SetMethodCallHandler(nullptr);
  if (pending_) {
    pending_->cancelled.store(true);
    if (pending_->thread.joinable()) pending_->thread.join();
    pending_.reset();
  }
  queued_close_.reset();
  // browser_ closes only the owned Firefox job, before its handle is released.
}
