#pragma once
#include "cps_profile_reader.h"
#include <atomic>
namespace cps_windows {
Reply RunOperation(Request request, const std::atomic<bool>* cancelled,
                   std::uint32_t timeout_ms = 45000);
Reply RunReader(std::vector<Byte> pin, const std::atomic<bool>* cancelled,
                std::uint32_t timeout_ms = 45000);
}
