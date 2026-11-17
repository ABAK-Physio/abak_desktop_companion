#include "../windows/runner/webps/webps_policy.h"
#include <iostream>
#include <stdexcept>
#include <vector>

void Require(bool value, const char* message) {
  if (!value) throw std::runtime_error(message);
}
int main() {
  using namespace abak_webps;
  const std::string root = "https://wps-cps.dev1.dmp.gouv.fr";
  const std::string patient = "/AccesDirect/DossierPatient/287019143596041/1.2.250.1.213.1.4.10";
  Require(ValidUrl(root + "/AccesDirect/TableauDeBord"), "Dashboard rejected");
  Require(ValidUrl(root + patient), "Cas1 rejected");
  const std::vector<std::string> invalid = {
    "http://wps-cps.dev1.dmp.gouv.fr/AccesDirect/TableauDeBord",
    "https://wps-cps.dev1.dmp.gouv.fr.evil/AccesDirect/TableauDeBord",
    "https://user@wps-cps.dev1.dmp.gouv.fr/AccesDirect/TableauDeBord",
    root + ":443/AccesDirect/TableauDeBord", root + "/AccesDirect/TableauDeBord?next=evil",
    root + "/AccesDirect/TableauDeBord#fragment", root + "/AccesDirect/TableauDeBord/",
    root + "/AccesDirect/DossierPatient/287019143596042/1.2.250.1.213.1.4.10",
    root + "/AccesDirect/DossierPatient/287019143596041/1.2.250.1.213.1.4.9",
    root + "/AccesDirect/DossierPatient/000000000000000/1.2.250.1.213.1.4.10",
    root + patient + " --profile C:\\other", root + "/AccesDirect/../AccesDirect/TableauDeBord",
    root + "/AccesDirect/%54ableauDeBord", root + "/AccesDirect/TableauDeBord\r\n",
  };
  for (const auto& address : invalid) Require(!ValidUrl(address), "Unsafe URL accepted");
  Require(Quote(L"C:\\Program Files (x86)\\Mozilla Firefox\\firefox.exe") ==
      L"\"C:\\Program Files (x86)\\Mozilla Firefox\\firefox.exe\"", "Path quoting failed");
  Require(Quote(L"a\"b") == L"\"a\\\"b\"", "Embedded quote escaped incorrectly");
  Require(Quote(L"C:\\profil\\") == L"\"C:\\profil\\\\\"", "Trailing slash escaped incorrectly");
  Require(Quote(L"") == L"\"\"", "Empty argument escaped incorrectly");
  Require(ValidSessionName(L"session-{00000000-0000-0000-0000-000000000000}"), "Owned profile rejected");
  for (const auto& name : {L"session-{../../outside}", L"profile", L"session-{NOT-A-GUID}",
      L"session-{00000000-0000-0000-0000-000000000000}/outside"})
    Require(!ValidSessionName(name), "Unsafe cleanup name accepted");
  Require(SupportedBrowser("com.microsoft.edge"), "Edge rejected");
  Require(SupportedBrowser("org.mozilla.firefox"), "Firefox rejected");
  Require(!SupportedBrowser("com.google.Chrome"), "Unreviewed browser accepted");
  const auto edge = CommandLine("com.microsoft.edge", L"C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe",
      L"C:\\ABAK profile", L"https://wps-cps.dev1.dmp.gouv.fr/AccesDirect/TableauDeBord");
  Require(edge.find(L"--user-data-dir=\"C:\\ABAK profile\"") != std::wstring::npos, "Edge profile not explicit");
  Require(edge.find(L"--new-window \"https://wps-cps.dev1.dmp.gouv.fr/AccesDirect/TableauDeBord\"") != std::wstring::npos, "Edge target not explicit");
  Require(edge.find(L"--disable-background-mode") != std::wstring::npos, "Edge background process not limited");
  Require(edge.find(L"--no-remote") == std::wstring::npos, "Firefox flags passed to Edge");
  Require(edge.find(L"ignore-certificate") == std::wstring::npos && edge.find(L"no-sandbox") == std::wstring::npos,
      "Browser security bypass found");
  Require(CommandLine("unknown", L"unused", L"unused", L"unused").empty(), "Implicit browser fallback");
  std::cout << "PASS: 34 URL, argument, browser and owned-profile checks; no browser or network" << std::endl;
}
