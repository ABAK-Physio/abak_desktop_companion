#include "cps_wire.h"
#include <cstdlib>
#include <iostream>
using namespace cps_windows;
namespace {
int count=0;
void Check(bool value,const char* label){if(!value){std::cerr<<label<<'\n';std::exit(1);}++count;}
Reply Good(){Reply r;r.success=true;r.slot_count=1;r.objects["CPS_NAME_PS"]={1,2};r.objects["CPS_INFO_PS"]={3};r.objects["CPS_ACTIVITY_01_PS"]={4};return r;}
}
int main(){
  for(const auto size:{21U,kMaximumRequest}){auto h=MakeHeader(false,size);std::uint32_t n=0;Check(ParseHeader(h,false,&n)&&n==size,"request bounds");}
  for(const auto size:{0U,20U,kMaximumRequest+1,0xffffffffU}){auto h=MakeHeader(false,size);std::uint32_t n=0;Check(!ParseHeader(h,false,&n),"request oversized");}
  auto h=MakeHeader(true,28);std::uint32_t n=0;Check(ParseHeader(h,true,&n),"reply minimum");
  h[0]^=1;Check(!ParseHeader(h,true,&n),"magic mismatch");h=MakeHeader(true,28);h[8]=1;Check(!ParseHeader(h,true,&n),"protocol version mismatch");
  h=MakeHeader(true,kMaximumReply+1);Check(!ParseHeader(h,true,&n),"huge reply rejected");
  Reply output;std::vector<Byte> data;auto good=Good();
  Check(Encode(good,&data)&&Decode(data,&output)&&output.success&&output.objects==good.objects,"reply round trip");
  const auto whole=data;
  for(std::size_t i=0;i<whole.size();++i){data.assign(whole.begin(),whole.begin()+static_cast<std::ptrdiff_t>(i));Check(!Decode(data,&output),"truncated reply");}
  data=whole;data.push_back(0);Check(!Decode(data,&output),"trailing bytes rejected");
  data=whole;Put32(data.data(),2);Check(!Decode(data,&output),"unknown status rejected");
  data=whole;Put32(data.data()+4,0xa0);Check(!Decode(data,&output),"success with error code rejected");
  auto invalid=Good();invalid.objects["PRIVATE_KEY"]={1};Check(!Encode(invalid,&data),"foreign object rejected");
  invalid=Good();invalid.objects["CPS_NAME_PS"].clear();Check(!Encode(invalid,&data),"empty object rejected");
  invalid=Good();invalid.objects["CPS_NAME_PS"].resize(65537);Check(!Encode(invalid,&data),"huge object rejected");
  invalid=Good();invalid.objects.erase("CPS_ACTIVITY_01_PS");Check(!Encode(invalid,&data),"missing activity rejected");
  invalid=Good();invalid.slot_count=2;Check(!Encode(invalid,&data),"ambiguous success rejected");
  invalid=Good();invalid.objects["CPS_NAME_PS"].resize(65536,3);Check(Encode(invalid,&data)&&Decode(data,&output),"maximum object round trip");
  Reply failure;failure.step="C_Login";failure.code=0xa0;Check(Encode(failure,&data)&&Decode(data,&output)&&!output.success&&output.code==0xa0,"PIN error round trip");
  failure.objects["CPS_NAME_PS"]={1};Check(!Encode(failure,&data),"failed reply contains no card data");
  failure.objects.clear();failure.step="PIN 123456";Check(!Encode(failure,&data),"unknown error field rejected");
  data=whole;Put32(data.data()+28,0xffffffffU);Check(!Decode(data,&output),"unbounded label length rejected");
  std::cout<<count<<" CPS wire checks passed.\n";
}
