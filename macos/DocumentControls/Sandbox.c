#include <sandbox.h>
#include <unistd.h>
#include <dlfcn.h>
#include <errno.h>

// No network probe: ask the running kernel policy without opening a socket.
int abak_policy_denies_network(void) {
    int (*check)(pid_t, const char *, int, ...) = dlsym(RTLD_DEFAULT, "sandbox_check");
    if (!check) return 0;
    return check(getpid(), "network-outbound", 0) > 0 &&
           check(getpid(), "network-inbound", 0) > 0;
}
int abak_apply_sandbox(const char *profile) {
    char *error = NULL;
    int result = sandbox_init(profile, 0, &error);
    if (error) sandbox_free_error(error);
    return result;
}
