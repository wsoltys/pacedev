onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_top/clk
add wave -noupdate -format Logic /tb_top/reset
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/clk
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/vsync
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/vblank
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/prg_a
add wave -noupdate -format Literal /tb_top/pace_inst/prg_d
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/cpu_clken
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/cpu_cs
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/cpu_d_i
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/cpu_d_o
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/cpu_rw_n
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/vbl
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/ciram_wr_r
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/ciram_a_r
add wave -noupdate -divider NES_APU
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/apu_inst/clk
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/apu_inst/clk3m58_en
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/apu_inst/enable
add wave -noupdate -divider DMA
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/dma_wr
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/dma_in_progress
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/dma_a
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/dma_d
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/dma_ppu_wr
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/cpu_a
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/cpu_d_i
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/cpu_cs
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/ppu_sptmem_a
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/cpu_rw_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {999439 ns} 0} {{Cursor 2} {15074689 ns} 0}
configure wave -namecolwidth 295
configure wave -valuecolwidth 48
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
WaveRestoreZoom {998854 ns} {1000434 ns}
