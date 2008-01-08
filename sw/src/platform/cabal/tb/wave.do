onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_cabal/fpga_rst
add wave -noupdate -format Logic {/tb_cabal/clk[1]}
add wave -noupdate -format Logic /tb_cabal/sram_cs
add wave -noupdate -format Logic /tb_cabal/sram_we
add wave -noupdate -format Logic /tb_cabal/sram_oe
add wave -noupdate -format Literal -radix hexadecimal /tb_cabal/sram_addr
add wave -noupdate -format Literal /tb_cabal/rom_data
add wave -noupdate -divider GAME
add wave -noupdate -format Logic /tb_cabal/Game_1/reset_n
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_reset_out_en
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_reset_n
add wave -noupdate -format Literal /tb_cabal/Game_1/sram_di
add wave -noupdate -format Literal /tb_cabal/Game_1/sram_do
add wave -noupdate -format Literal /tb_cabal/Game_1/sram_do
add wave -noupdate -format Logic /tb_cabal/Game_1/rom_cs
add wave -noupdate -format Logic /tb_cabal/Game_1/wram_cs
add wave -noupdate -divider 68K
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/clk
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/reset_coren
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/reset_inn_s
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/halt_inn
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/wf68k00ip_top_soc_inst/reset_rdy_i
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/reset_out_en
add wave -noupdate -format Literal /tb_cabal/Game_1/cpu_inst/fc_out
add wave -noupdate -format Literal -radix hexadecimal /tb_cabal/Game_1/cpu_inst/adr_out
add wave -noupdate -format Literal /tb_cabal/CPU_ROM/sram_core/a
add wave -noupdate -format Literal /tb_cabal/CPU_ROM/sram_core/d
add wave -noupdate -format Literal /tb_cabal/CPU_ROM/sram_core/valid_adr
add wave -noupdate -format Logic /tb_cabal/CPU_ROM/sram_core/read_active
add wave -noupdate -format Logic /tb_cabal/CPU_ROM/sram_core/read_valid
add wave -noupdate -format Literal /tb_cabal/CPU_ROM/sram_core/read_data
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/as_outn
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/uds_outn
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/lds_outn
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/rwn_out
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/dtackn
add wave -noupdate -format Literal /tb_cabal/Game_1/cpu_inst/data_in
add wave -noupdate -format Literal /tb_cabal/Game_1/cpu_inst/data_out
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/data_en
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/adr_en
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/brn
add wave -noupdate -divider CONTROL
add wave -noupdate -format Literal /tb_cabal/Game_1/cpu_inst/wf68k00ip_top_soc_inst/i_ctrl/exec_state
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/wf68k00ip_top_soc_inst/i_ctrl/pc_init_hi
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/wf68k00ip_top_soc_inst/i_ctrl/pc_init_lo
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/wf68k00ip_top_soc_inst/i_ctrl/pc_wr
add wave -noupdate -divider BUS_IF
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/wf68k00ip_top_soc_inst/i_bus_if/clk
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/wf68k00ip_top_soc_inst/i_bus_if/resetn
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/wf68k00ip_top_soc_inst/i_bus_if/reset_en
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/wf68k00ip_top_soc_inst/i_bus_if/reset_rdy
add wave -noupdate -format Logic /tb_cabal/Game_1/cpu_inst/wf68k00ip_top_soc_inst/i_bus_if/reset_out_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {17081016 ps} 0}
configure wave -namecolwidth 272
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
update
WaveRestoreZoom {15930295 ps} {18727217 ps}
