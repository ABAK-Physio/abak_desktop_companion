#pragma once
#include <windows.h>
#include <array>
#include <string>

namespace docx_probe {
struct SyntheticFileAccessResult {
 bool expected=true;
 std::string diagnostic;
};

// Open existing synthetic files with ONE exact access right at a time.
// Never write, truncate, delete, change security, or follow a reparse point.
inline SyntheticFileAccessResult ProbeSyntheticFileAccess(const std::wstring& root) {
 struct Fixture { const wchar_t* file; const char* label; bool read; bool write; };
 const std::array<Fixture,5> fixtures{{
  {L"service.txt","SERVICE_SID",true,true},
  {L"localservice.txt","LOCALSERVICE_ONLY",true,false},
  {L"everyone.txt","EVERYONE",true,true},
  {L"admin.txt","ADMIN_SYSTEM_ONLY",false,false},
  {L"readonly.txt","SERVICE_READ_ONLY",true,false}
 }};
 struct Right { DWORD mask; const char* label; };
 const std::array<Right,5> rights{{
  {FILE_READ_DATA,"READ_DATA"}, {FILE_WRITE_DATA,"WRITE_DATA"},
  {DELETE,"DELETE"}, {WRITE_DAC,"CHANGE_DACL"}, {WRITE_OWNER,"CHANGE_OWNER"}
 }};
 SyntheticFileAccessResult result;
 result.diagnostic="FILE_ACCESS_DIAGNOSTIC=v12\r\nTOKEN_PROFILE=SERVICE_PLUS_WORLD\r\n"
     "SCOPE=FIVE_ADMIN_OWNED_SYNTHETIC_FIXTURES_ONLY\r\n"
     "METHOD=OPEN_EXISTING_EXACT_RIGHT_NO_CONTENT_OR_ACL_CHANGE\r\n";
 for(const auto& fixture:fixtures) {
  for(std::size_t i=0;i<rights.size();++i) {
   const auto& right=rights[i];
   const bool expected=i==0?fixture.read:(i==1?fixture.write:false);
   SetLastError(ERROR_SUCCESS);
   const HANDLE file=CreateFileW((root+L"\\"+fixture.file).c_str(),right.mask,
       FILE_SHARE_READ|FILE_SHARE_WRITE|FILE_SHARE_DELETE,nullptr,OPEN_EXISTING,
       FILE_FLAG_OPEN_REPARSE_POINT,nullptr);
   const bool granted=file!=INVALID_HANDLE_VALUE;
   DWORD error=granted?ERROR_SUCCESS:GetLastError();
   bool valid_file=true;
   if(granted) {
    BY_HANDLE_FILE_INFORMATION info{};
    valid_file=GetFileInformationByHandle(file,&info)!=FALSE;
    if(!valid_file) error=GetLastError();
    else if((info.dwFileAttributes & (FILE_ATTRIBUTE_DIRECTORY|FILE_ATTRIBUTE_REPARSE_POINT))!=0) {
     valid_file=false; error=ERROR_INVALID_DATA;
    }
    if(!CloseHandle(file)) { valid_file=false; error=GetLastError(); }
   }
   // A missing file, sharing violation or other failure is never accepted as
   // proof that the DACL denied access.
   const bool matches=valid_file && (expected?granted:(!granted && error==ERROR_ACCESS_DENIED));
   result.expected=result.expected && matches;
   result.diagnostic+=std::string("FIXTURE=")+fixture.label+" RIGHT="+right.label+
       " EXPECTED="+(expected?"ALLOW":"DENY")+" ACTUAL="+(granted?"ALLOW":"DENY")+
       " ERROR="+std::to_string(error)+" MATCH="+(matches?"true":"false")+"\r\n";
  }
 }
 result.diagnostic+=std::string("FILE_ACCESS_MATRIX=")+(result.expected?"EXPECTED_RESULTS":"MISMATCH")+"\r\n";
 result.diagnostic+="LIMITATION=EVERYONE_WRITABLE_RESOURCES_REMAIN_WRITABLE\r\n"
     "LIMITATION=WRITE_RESTRICTED_DOES_NOT_CONFINE_READS_TO_JOB\r\n"
     "LIMITATION=SERVICE_SID_DOES_NOT_SEPARATE_JOBS_OF_SAME_SERVICE\r\n"
     "APPLICATION_INTEGRATED=false\r\nISOLATION_QUALIFIED=false\r\n";
 return result;
}
}
