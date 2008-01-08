onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_vic20/pace_1/vic/ena_1mhz
add wave -noupdate -format Logic /tb_vic20/pace_1/vic/clk_4
add wave -noupdate -format Logic /tb_vic20/pace_1/vic/p2_h
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 241
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
WaveRestoreZoom {55399962 ps} {69925721 ps}
