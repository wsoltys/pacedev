onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mce6309_tb/fail
add wave -noupdate -divider SYN_CPU
add wave -noupdate -radix hexadecimal /mce6309_tb/syn_cpu/address
add wave -noupdate -radix hexadecimal /mce6309_tb/syn_cpu/data_i
add wave -noupdate -radix hexadecimal /mce6309_tb/syn_cpu/data_o
add wave -noupdate -radix hexadecimal /mce6309_tb/syn_cpu/acca
add wave -noupdate -radix hexadecimal /mce6309_tb/syn_cpu/accb
add wave -noupdate -divider BEH_CPU
add wave -noupdate -radix hexadecimal /mce6309_tb/beh_cpu/acca
add wave -noupdate -radix hexadecimal /mce6309_tb/beh_cpu/accb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {244297 ps} 0}
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
WaveRestoreZoom {0 ps} {1050 ns}
