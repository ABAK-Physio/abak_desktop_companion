#include "cps_windows_client.h"
#include <atomic>
#include <cstdlib>
#include <filesystem>
#include <iostream>
using namespace cps_windows;
namespace {
int checks = 0;
void Check(bool ok, const char* label) { ++checks; if (!ok) { std::cerr << label << '\n'; std::exit(1); } }
Request Command(Operation operation) {
  Request q; q.operation = operation; q.pin = {'1','2','3','4'};
  if (operation != Operation::Read) q.expected_id = "800000000001";
  if (operation == Operation::Sign) { q.signed_info.assign(32768, 'X'); q.expected_certificate = "Ag=="; }
  return q;
}
}
int main() {
  const auto cwd = std::filesystem::current_path();
  for (auto operation : {Operation::Read, Operation::Prepare, Operation::Sign, Operation::Test}) {
    auto q = Command(operation); const auto info = q.signed_info;
    const auto result = RunOperation(std::move(q), nullptr, 5000);
    if (!result.transport_error.empty()) std::cerr << result.transport_error << '\n';
    Check(result.success && result.operation == operation, "isolated operation round trip");
    if (operation == Operation::Sign) Check(result.message == info && result.verified && result.signature.size() == 256, "full length signedInfo preserved");
    if (operation == Operation::Prepare) Check(!result.verified && result.signature.empty() && result.certificates.size() == 2, "prepare has no signature");
    Check(cwd == std::filesystem::current_path(), "parent working directory unchanged");
  }
  auto q = Command(Operation::Sign); q.expected_certificate = "different";
  auto result = RunOperation(std::move(q), nullptr, 5000);
  Check(!result.success && result.step == "identity" && result.transport_error.empty(), "signature error traverses protocol");
  q = Command(Operation::Sign); q.expected_certificate.assign(87384, 'A');
  result = RunOperation(std::move(q), nullptr, 5000);
  Check(!result.success && result.step == "identity" && result.transport_error.empty(), "maximum bounded request transmitted");
  std::atomic<bool> cancelled{true};
  result = RunOperation(Command(Operation::Sign), &cancelled, 5000);
  Check(!result.transport_error.empty() && result.signature.empty(), "cancelled operation never signs");
  std::cout << checks << " isolated signature protocol checks passed; fake provider, no card.\n";
}
