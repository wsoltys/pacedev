onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_spectrum/fpga_rst
add wave -noupdate -format Logic {/tb_spectrum/clk[1]}
add wave -noupdate -format Logic /tb_spectrum/PACE_1/red(9)
add wave -noupdate -format Logic /tb_spectrum/PACE_1/red(8)
add wave -noupdate -format Logic /tb_spectrum/PACE_1/green(9)
add wave -noupdate -format Logic /tb_spectrum/PACE_1/green(8)
add wave -noupdate -format Logic /tb_spectrum/PACE_1/blue(9)
add wave -noupdate -format Logic /tb_spectrum/PACE_1/blue(8)
add wave -noupdate -format Logic /tb_spectrum/vsync
add wave -noupdate -format Logic /tb_spectrum/hsync
add wave -noupdate -divider VID
add wave -noupdate -format Logic /tb_spectrum/PACE_1/spectrum_inst/u_vid/hsync
add wave -noupdate -format Logic /tb_spectrum/PACE_1/spectrum_inst/u_vid/vsync
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15838409428 ps} 0} {{Cursor 2} {41138812377 ps} 0}
configure wave -namecolwidth 298
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
WaveRestoreZoom {14407365237 ps} {17247278577 ps}
