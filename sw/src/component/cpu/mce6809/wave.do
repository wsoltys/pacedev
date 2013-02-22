onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mce6309_tb/fail
add wave -noupdate /mce6309_tb/reset
add wave -noupdate -divider SYN_CPU
add wave -noupdate -radix hexadecimal /mce6309_tb/syn_cpu/address
add wave -noupdate -radix hexadecimal /mce6309_tb/syn_cpu/data_i
add wave -noupdate -radix hexadecimal /mce6309_tb/syn_cpu/data_o
add wave -noupdate -radix hexadecimal /mce6309_tb/syn_cpu/acca
add wave -noupdate -radix hexadecimal /mce6309_tb/syn_cpu/accb
add wave -noupdate -divider {SYN_CPU MCODE}
add wave -noupdate /mce6309_tb/syn_cpu/mcode/bdm_rdy
add wave -noupdate -radix hexadecimal /mce6309_tb/syn_cpu/mcode/bdm_ir
add wave -noupdate /mce6309_tb/syn_cpu/mcode/mc_addr
add wave -noupdate /mce6309_tb/syn_cpu/mcode/mc_jump
add wave -noupdate /mce6309_tb/syn_cpu/mcode/mc_jump_addr
add wave -noupdate /mce6309_tb/syn_cpu/mcode/pc_ctrl
add wave -noupdate /mce6309_tb/syn_cpu/mcode/ir_ctrl
add wave -noupdate /mce6309_tb/syn_cpu/mcode/dbus_ctrl
add wave -noupdate -divider {SYN_CPU BDM}
add wave -noupdate /mce6309_tb/syn_cpu/mcode/bdm_cr
add wave -noupdate /mce6309_tb/syn_cpu/gen_bdm/bdm_inst/bdm_clk
add wave -noupdate /mce6309_tb/syn_cpu/gen_bdm/bdm_inst/bdm_mosi
add wave -noupdate /mce6309_tb/syn_cpu/gen_bdm/bdm_inst/bdm_i
add wave -noupdate /mce6309_tb/syn_cpu/gen_bdm/bdm_inst/bdm_miso
add wave -noupdate -radix hexadecimal /mce6309_tb/syn_cpu/gen_bdm/bdm_inst/bdm_ir
add wave -noupdate /mce6309_tb/syn_cpu/gen_bdm/bdm_inst/bdm_rdy
add wave -noupdate -divider BEH_CPU
add wave -noupdate -divider BDM
add wave -noupdate /mce6309_tb/bdm_clk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2823499 ps} 0}
configure wave -namecolwidth 106
configure wave -valuecolwidth 56
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {8400 ns}
