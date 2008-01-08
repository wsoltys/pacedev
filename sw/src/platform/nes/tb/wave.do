onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_top/clk
add wave -noupdate -format Logic /tb_top/reset
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/clk
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/frame
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/hsync
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/hblank
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/vsync
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/vblank
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/scanline
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/renderline
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/cycle
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/ppu_cycle
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/ppu_sub_cycle
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/ppu_pixel
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/ppu_sub_tick
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/pixel_tick
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/ciram_a
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/chr_a
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/chr_d_i
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/name_table_data
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/attr_table_data
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/patt_table_data
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/r
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/g
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/b
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/prg_a
add wave -noupdate -format Literal /tb_top/pace_inst/nes_cart_inst/prg_a
add wave -noupdate -format Literal /tb_top/pace_inst/nes_cart_inst/prg_d_o
add wave -noupdate -format Literal /tb_top/pace_inst/prg_d
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/prg_d_i
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/prg_cs
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/clk_1m77_en
add wave -noupdate -format Literal /tb_top/pace_inst/nes_inst/ppu_inst/n_spttmp
add wave -noupdate -format Logic /tb_top/pace_inst/nes_inst/ppu_inst/more_than_8_flag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1458760 ns} 0} {{Cursor 2} {18244344 ns} 0}
configure wave -namecolwidth 247
configure wave -valuecolwidth 100
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
WaveRestoreZoom {17506521 ns} {18621640 ns}
