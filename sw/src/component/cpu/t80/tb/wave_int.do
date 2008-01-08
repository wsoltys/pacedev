onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_int/fpga_rst
add wave -noupdate -format Logic /tb_int/ref_clk
add wave -noupdate -format Logic /tb_int/clk2M_en
add wave -noupdate -format Literal /tb_int/a
add wave -noupdate -format Literal /tb_int/di
add wave -noupdate -format Literal /tb_int/do
add wave -noupdate -format Logic /tb_int/intack
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12856215 ps} 0}
configure wave -namecolwidth 150
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
WaveRestoreZoom {0 ps} {36933750 ps}
