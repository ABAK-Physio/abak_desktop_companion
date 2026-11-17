#pragma once
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#include <array>
#include <cstdint>
#include <string>

namespace document_controls_runtime {
inline constexpr wchar_t ServiceName[] = L"ABAKDocumentControls";

std::wstring WorkDirectory();
bool ServiceSid(std::wstring* text);
// Preparation: LocalService + enabled service SID, without restricting SIDs.
bool CheckBrokerToken(HANDLE process);
// Worker: LocalService + enabled/restricting service SID, no privilege other
// than SeChangeNotifyPrivilege may remain in the process primary token.
bool CheckServiceToken(HANDLE process);
// Four temporary WFP filters match only the dedicated service SID, including
// children that inherit it. Not the paths used by ordinary LibreOffice users.
bool InstallPersistentPolicy(std::string* error);
bool RemovePersistentPolicy(std::string* error);
bool VerifyPolicy(std::string* error);
bool OutboundFilterIds(HANDLE engine,std::array<std::uint64_t,2>* ids);
void ClosePolicy(HANDLE engine);
}
