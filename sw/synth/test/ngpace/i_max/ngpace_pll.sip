set_global_assignment -entity "ngpace_pll" -library "lib_ngpace_pll" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "ngpace_pll" -library "lib_ngpace_pll" -name IP_TOOL_VERSION "12.1sp1"
set_global_assignment -entity "ngpace_pll" -library "lib_ngpace_pll" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_ngpace_pll" -name SPD_FILE [file join $::quartus(sip_path) "ngpace_pll.spd"]

set_global_assignment -library "lib_ngpace_pll" -name MISC_FILE [file join $::quartus(sip_path) "ngpace_pll_sim/ngpace_pll.vho"]
