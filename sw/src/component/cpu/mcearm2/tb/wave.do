onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_top/clk
add wave -noupdate -format Logic /tb_top/reset
add wave -noupdate -format Logic /tb_top/ph1_ena
add wave -noupdate -format Logic /tb_top/ph2_ena
add wave -noupdate -format Logic /tb_top/syn_reset
add wave -noupdate -divider ARM2
add wave -noupdate -format Logic /tb_top/reset
add wave -noupdate -format Literal -radix hexadecimal /tb_top/syn_cpu/pc
add wave -noupdate -format Literal /tb_top/syn_cpu/m
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
WaveRestoreZoom {0 ps} {4200 ns}
