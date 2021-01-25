#include <utils.hpp>
#include <magiskpolicy.hpp>

#include "sepolicy.hpp"

using namespace std;

void sepolicy::magisk_rules() {
    // Temp suppress warnings
    auto bak = log_cb.w;
    log_cb.w = nop_log;

    // Prevent anything to change sepolicy except ourselves
    deny(ALL, "kernel", "security", "load_policy");

    allow("system_server", "system_server", "process", "execmem");
    allow("system_server", "system_server", "memprotect", "mmap_zero");
    allow("coredomain", "coredomain", "process", "execmem");
    allow("coredomain", "app_data_file", ALL, ALL);
    allow("zygote", "apk_data_file", ALL, ALL);
    typeattribute("system_app", "mlstrustedsubject");
    typeattribute("platform_app", "mlstrustedsubject");

#if 0
    // Remove all dontaudit in debug mode
    impl->strip_dontaudit();
#endif

    log_cb.w = bak;
}
