onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic {/tb_zx81/clk[1]}
add wave -noupdate -format Logic /tb_zx81/fpga_rst
add wave -noupdate -format Logic {/tb_zx81/red[9]}
add wave -noupdate -format Logic {/tb_zx81/green[9]}
add wave -noupdate -format Logic {/tb_zx81/blue[9]}
add wave -noupdate -format Logic /tb_zx81/hsync
add wave -noupdate -format Logic /tb_zx81/vsync
add wave -noupdate -divider PACE
add wave -noupdate -format Logic /tb_zx81/PACE_1/csync
add wave -noupdate -divider ZX01
add wave -noupdate -format Logic /tb_zx81/PACE_1/zx01_inst/n_reset
add wave -noupdate -format Logic /tb_zx81/PACE_1/zx01_inst/clock
add wave -noupdate -format Logic /tb_zx81/PACE_1/zx01_inst/i_n_sync
add wave -noupdate -divider VIDEO81
add wave -noupdate -format Logic /tb_zx81/PACE_1/zx01_inst/c_top/c_video81/hsync
add wave -noupdate -format Logic /tb_zx81/PACE_1/zx01_inst/c_top/c_video81/hsync3
add wave -noupdate -format Logic /tb_zx81/PACE_1/zx01_inst/c_top/c_video81/vsync
add wave -noupdate -format Logic /tb_zx81/PACE_1/zx01_inst/c_top/c_video81/n_sync
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {214643075686 ps} 0} {{Cursor 2} {214706768758 ps} 0}
configure wave -namecolwidth 308
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
WaveRestoreZoom {213870368906 ps} {215469180057 ps}
