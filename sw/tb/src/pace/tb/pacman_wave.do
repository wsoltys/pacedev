onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_pace/clk_20m
add wave -noupdate -format Logic /tb_pace/clk_40m
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/u_up/mem_rd
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/u_up/mem_wr
add wave -noupdate -format Literal /tb_pace/pace_inst/platform_inst/u_up/addr
add wave -noupdate -format Literal /tb_pace/pace_inst/platform_inst/u_up/datai
add wave -noupdate -format Literal /tb_pace/pace_inst/platform_inst/u_up/datao
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/rom_cs
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/vram_cs
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/wram_cs
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/interrupts_inst/vblank
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/interrupts_inst/vblank_int
add wave -noupdate -format Literal /tb_pace/pace_inst/platform_inst/u_up/intvec
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/interrupts_inst/intena_s
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/u_up/int_n
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/u_up/nmi_n
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/u_up/intack
add wave -noupdate -divider CPU
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/u_up/z80_up/u0/int_n
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/u_up/z80_up/u0/int_s
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/u_up/z80_up/u0/mcode/setdi
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/u_up/z80_up/u0/mcode/setei
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/u_up/z80_up/u0/inte_ff1
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/u_up/z80_up/u0/inte_ff2
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/u_up/z80_up/u0/intcycle
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/u_up/z80_up/u0/i_retn
add wave -noupdate -format Literal /tb_pace/pace_inst/platform_inst/u_up/z80_up/u0/di_reg
add wave -noupdate -format Literal /tb_pace/pace_inst/platform_inst/u_up/z80_up/u0/tstate
add wave -noupdate -format Logic /tb_pace/pace_inst/platform_inst/u_up/z80_up/u0/save_alu_r
add wave -noupdate -format Literal /tb_pace/pace_inst/platform_inst/u_up/z80_up/u0/alu_op_r
add wave -noupdate -format Literal /tb_pace/pace_inst/platform_inst/u_up/z80_up/u0/read_to_reg_r
add wave -noupdate -format Literal /tb_pace/pace_inst/platform_inst/u_up/z80_up/u0/save_mux
add wave -noupdate -divider SRAM
add wave -noupdate -format Literal /tb_pace/sram_o
add wave -noupdate -format Literal /tb_pace/sram_a
add wave -noupdate -format Literal /tb_pace/sram_d
add wave -noupdate -format Literal /tb_pace/sram_ncs
add wave -noupdate -format Logic /tb_pace/sram_noe
add wave -noupdate -format Logic /tb_pace/sram_nwe
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {314356075 ns} 0} {{Cursor 2} {314358025 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
update
WaveRestoreZoom {314357166 ns} {314359030 ns}
