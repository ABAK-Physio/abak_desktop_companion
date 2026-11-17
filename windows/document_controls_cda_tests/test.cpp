#include "../document_controls_runtime/cda_reports.h"
#include <algorithm>
#include <cstdlib>
#include <iostream>
#include <stdexcept>

using namespace document_controls_runtime;
namespace {
int checks=0;
void Check(bool ok,const char* message) {
 if(!ok) {std::cerr<<message<<'\n';std::exit(1);} ++checks;
}
template<class F> void Reject(F function) {
 bool rejected=false;
 try {function();} catch(const std::exception&) {rejected=true;}
 Check(rejected,"Malformed CDA data accepted");
}
std::vector<std::uint8_t> Bytes(const std::string& text) {return {text.begin(),text.end()};}
CdaReportFiles Reports() {
 CdaReportFiles files;
 for(const auto& name:CdaReportNames())
  if(name!="xsd-error.txt") files.emplace(name,Bytes(name=="completed.txt"?"ABAK-CDA-1":"<synthetic/>"));
 return files;
}
}
int main() {
 const auto files=Reports();
 const auto packet=PackCdaReports(files);
 Check(UnpackCdaReports(packet)==files,"Complete report reply changed");
 auto error=files;error.emplace("xsd-error.txt",Bytes("Synthetic schema rejection"));
 Check(UnpackCdaReports(PackCdaReports(error))==error,"Optional XSD diagnostic lost");
 for(const auto& name:CdaReportNames()) {
  if(name=="xsd-error.txt") continue;
  auto missing=files;missing.erase(name);Reject([&]{PackCdaReports(missing);});
  auto empty=files;empty[name].clear();Reject([&]{PackCdaReports(empty);});
 }
 auto wrong=files;wrong["completed.txt"]=Bytes("unfinished");Reject([&]{PackCdaReports(wrong);});
 auto unknown=files;unknown.emplace("../outside.xml",Bytes("x"));Reject([&]{PackCdaReports(unknown);});
 auto huge=files;huge["xsd.xml"].resize(MaxCdaReports,1);Reject([&]{PackCdaReports(huge);});
 for(std::size_t n=0;n<packet.size();++n) {
  const std::vector<std::uint8_t> truncated(packet.begin(),packet.begin()+n);
  Reject([&]{UnpackCdaReports(truncated);});
 }
 for(std::size_t n=0;n<8;++n) {
  auto magic=packet;magic[n]^=1;Reject([&]{UnpackCdaReports(magic);});
 }
 auto trailing=packet;trailing.push_back(0);Reject([&]{UnpackCdaReports(trailing);});
 auto count=packet;count[8]=255;Reject([&]{UnpackCdaReports(count);});
 auto length=packet;length[12]=255;Reject([&]{UnpackCdaReports(length);});
 auto duplicate=packet;
 const auto name=Bytes("profile-1.xml");
 const auto where=std::search(duplicate.begin(),duplicate.end(),name.begin(),name.end());
 Check(where!=duplicate.end(),"Synthetic profile missing");
 *(where+8)='0';Reject([&]{UnpackCdaReports(duplicate);});
 for(const auto* path:{"", "/absolute", "a/../b", "a/./b", "a//b", "a/", "C:/b", "a\\b",
     "a\nb", "a:b", "a*", "a?", "a\"", "a<", "a>", "a|", "a.", "a /b"})
  Check(!ValidCdaReferencePath(path),"Unsafe reference path accepted");
 Check(ValidCdaReferencePath("schematrons/profils/IHE.sch"),"Valid reference path rejected");
 const std::string a(64,'a'),b(64,'b');
 const auto fingerprint=CdaReferenceFingerprintInput({{"b/file",b},{"a/file",a}});
 std::string expected="a/file";expected.push_back('\0');expected+=a+"\nb/file";
 expected.push_back('\0');expected+=b+"\n";
 Check(fingerprint==expected,"Reference identity not deterministic");
 Check(CdaReferenceFingerprintInput({{"a/file",a},{"b/file",b},{"a/abak-0-0.xsl",a},
     {".bench-test/file",a},{"unified-configuration.json",b}})==fingerprint,
     "Bench products entered the reference identity");
 Reject([&]{CdaReferenceFingerprintInput({});});
 Reject([&]{CdaReferenceFingerprintInput({{"manifest.json",a}});});
 Reject([&]{CdaReferenceFingerprintInput({{"a",std::string(64,'A')}});});
 Reject([&]{CdaReferenceFingerprintInput({{"../a",a}});});
 std::cout<<checks<<" CDA report checks passed; synthetic data only.\n";
}
