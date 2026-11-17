#include "cps_profile_reader.h"
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <stdexcept>
#include <utility>

using namespace cps_windows;
namespace {
int checks = 0;
void Check(bool condition, const char* name) {
  if (!condition) { std::cerr << name << '\n'; std::exit(1); }
  ++checks;
}
struct State {
  int initialize = 0, finalize = 0, open = 0, login = 0, logout = 0, close = 0;
  int searches = 0, find_finals = 0;
  std::string fail, label;
  Ulong slots = 1;
  bool attributes_valid = true, login_valid = true, pin_erased = false;
  Byte* pin_memory = nullptr;
  Ulong pin_size = 0;
} state;
Ulong Initialize(void*) { ++state.initialize; return state.fail == "initialize" ? 0x191U : 0U; }
Ulong Finalize(void*) { ++state.finalize; return state.fail == "finalize" ? 0x30U : 0U; }
Ulong Slots(Byte present, Ulong* slots, Ulong* count) {
  Check(present == 1, "Only inserted tokens enumerated");
  if (state.fail == "slots") return 0xe0;
  if (slots) {
    if (state.fail == "slots-changed") { *count = 2; return 0x150; }
    *slots = 17;
  }
  *count = state.slots; return 0;
}
Ulong Open(Ulong slot, Ulong flags, void* app, Notify notify, Ulong* session) {
  ++state.open; Check(slot == 17 && flags == 4 && !app && !notify, "Read-only serial session");
  if (state.fail == "open") return 0x30;
  *session = 23; return 0;
}
Ulong Login(Ulong session, Ulong user, Byte* pin, Ulong size) {
  ++state.login;
  state.login_valid = session == 23 && user == 1 && size == 4 &&
      pin[0] == '1' && pin[1] == '2' && pin[2] == '3' && pin[3] == '4';
  state.pin_memory = pin; state.pin_size = size;
  if (state.fail == "pin") return 0xa0;
  if (state.fail == "pin-locked") return 0xa4;
  if (state.fail == "already-logged") return 0x100;
  return 0;
}
Ulong Logout(Ulong session) {
  Check(session == 23, "Logout owned session"); ++state.logout;
  return state.fail == "logout" ? 0x30U : 0U;
}
Ulong Close(Ulong session) { Check(session == 23, "Close owned session"); ++state.close; return state.fail == "close" ? 0x30U : 0U; }
Ulong FindInit(Ulong session, Attribute* attrs, Ulong count) {
  ++state.searches;
  state.pin_erased = true;
  for (Ulong i = 0; i < state.pin_size; ++i) if (state.pin_memory[i] != 0) state.pin_erased = false;
  state.attributes_valid = state.attributes_valid && session == 23 && count == 4 &&
      attrs[0].type == 0 && attrs[0].length == 4 && *static_cast<Ulong*>(attrs[0].value) == 0 &&
      attrs[1].type == 1 && attrs[1].length == 1 && *static_cast<Byte*>(attrs[1].value) == 1 &&
      attrs[2].type == 2 && attrs[2].length == 1 && attrs[3].type == 3;
  state.label.assign(static_cast<char*>(attrs[3].value), attrs[3].length);
  const Byte is_private = state.label.rfind("CPS_ACTIVITY_", 0) == 0 ? 1 : 0;
  state.attributes_valid = state.attributes_valid && *static_cast<Byte*>(attrs[2].value) == is_private;
  return state.fail == "find-init" ? 0x30U : 0U;
}
Ulong Find(Ulong session, Ulong* handles, Ulong capacity, Ulong* count) {
  Check(session == 23 && capacity == 2, "Bounded duplicate search");
  if (state.fail == "find") return 0x30;
  if (state.fail == "duplicate") { *count = 2; return 0; }
  const bool exists = state.label == "CPS_NAME_PS" || state.label == "CPS_INFO_PS" ||
      (state.label == "CPS_ACTIVITY_01_PS" && state.fail != "no-activity");
  *count = exists && !(state.fail == "missing-name" && state.label == "CPS_NAME_PS") ? 1U : 0U;
  handles[0] = 31; return 0;
}
Ulong FindFinal(Ulong session) { Check(session == 23, "Finish owned search"); ++state.find_finals; return state.fail == "find-final" ? 0x30U : 0U; }
Ulong AttributeValue(Ulong session, Ulong object, Attribute* attr, Ulong count) {
  Check(session == 23 && object == 31 && attr->type == 0x11 && count == 1,
      "Only CKA_VALUE of selected business data read");
  if (!attr->value) {
    if (state.fail == "size-error") return 0x30;
    attr->length = state.fail == "huge" ? 65537U : state.fail == "unavailable" ? 0xffffffffU :
        state.fail == "zero" ? 0U : 4U;
  } else {
    if (state.fail == "value-error") return 0x30;
    if (state.fail == "grew") { attr->length = 5; return 0; }
    static const Byte bytes[]{0xe4, 2, 0x84, 0};
    std::memcpy(attr->value, bytes, sizeof(bytes));
    if (state.fail == "shrunk") attr->length = 3;
  }
  return 0;
}
Api Functions() {
  Api api;
  api.initialize=Initialize; api.finalize=Finalize; api.slots=Slots; api.open=Open;
  api.login=Login; api.logout=Logout; api.close=Close; api.find_init=FindInit;
  api.find=Find; api.find_final=FindFinal; api.attribute=AttributeValue; return api;
}
Reply Run(const std::string& fail = "") {
  state = State{}; state.fail = fail;
  return ReadProfile(Functions(), {'1','2','3','4'});
}
}
int main() {
  auto reply = Run();
  Check(reply.success && reply.objects.size() == 3, "Complete read with optional objects absent");
  Check(state.searches == 19 && state.find_finals == 19 && state.attributes_valid,
      "All and only exact CPS profile labels searched");
  Check(state.login == 1 && state.login_valid && state.pin_erased, "One login then PIN erased before data reads");
  Check(state.logout == 1 && state.close == 1 && state.finalize == 1, "Success fully cleaned up");
  for (const auto& mode : {"pin","pin-locked","already-logged"}) {
    reply = Run(mode);
    Check(!reply.success && reply.step == "C_Login", "Login failure preserved");
    Check(state.login == 1 && state.searches == 0, "No PIN retry or reads on login failure");
    Check(state.logout == 0 && state.close == 1 && state.finalize == 1, "No logout of authentication not owned");
  }
  reply = Run("initialize");
  Check(!reply.success && state.finalize == 0 && state.open == 0, "Failed initialize not finalized");
  for (const Ulong count : {0U,2U,0xffffffffU}) {
    state = State{}; state.slots = count;
    reply = ReadProfile(Functions(), {'1','2','3','4'});
    Check(!reply.success && reply.slot_count == count && state.login == 0 && state.finalize == 1,
        "Zero/multiple cards rejected before PIN");
  }
  for (const auto& mode : {"slots","slots-changed","open"}) {
    reply = Run(mode);
    Check(!reply.success && state.login == 0 && state.close == 0 && state.finalize == 1,
        "Pre-login failure cleaned up");
  }
  for (const auto& mode : {"find-init","find","find-final","duplicate","size-error","huge",
                           "unavailable","zero","value-error","grew","no-activity","missing-name"}) {
    reply = Run(mode);
    Check(!reply.success && reply.objects.empty() && state.logout == 1 && state.close == 1 &&
        state.finalize == 1 && state.login == 1, "Read failure cleared and session cleaned");
    Check(state.find_finals == state.searches - (std::string(mode)=="find-init"?1:0),
        "Every started search finalized");
  }
  reply = Run("shrunk");
  Check(reply.success && reply.objects.at("CPS_NAME_PS").size() == 3, "Returned attribute length honored");
  for (const auto& mode : {"logout","close","finalize"}) {
    reply = Run(mode);
    Check(!reply.success && reply.objects.empty() && state.logout == 1 && state.close == 1 && state.finalize == 1,
        "Cleanup failure blocks success but all cleanup attempted");
  }
  for (const std::vector<Byte>& pin : {std::vector<Byte>{}, std::vector<Byte>{'x'}, std::vector<Byte>(17,'1')}) {
    state=State{}; reply=ReadProfile(Functions(),pin);
    Check(!reply.success && reply.step=="PIN_FORMAT" && state.initialize==0,"Bad PIN format never reaches card");
  }
  state=State{}; auto missing=Functions(); missing.attribute=nullptr;
  reply=ReadProfile(missing,{'1','2','3','4'});
  Check(!reply.success && reply.step=="GetProcAddress" && state.initialize==0,"Missing API rejected before card");
  std::cout << checks << " CPS profile checks passed; fake PKCS11 only.\n";
}
