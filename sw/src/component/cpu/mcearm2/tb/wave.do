onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_top/clk
add wave -noupdate -format Logic /tb_top/reset
add wave -noupdate -format Logic /tb_top/ph1_ena
add wave -noupdate -format Logic /tb_top/ph2_ena
add wave -noupdate -format Logic /tb_top/syn_reset
add wave -noupdate -divider ARM2
add wave -noupdate -format Logic /tb_top/reset
add wave -noupdate -format Literal /tb_top/syn_cpu/a
add wave -noupdate -format Literal /tb_top/syn_cpu/d_i
add wave -noupdate -format Literal -radix hexadecimal /tb_top/syn_cpu/pc
add wave -noupdate -format Literal /tb_top/syn_cpu/m
add wave -noupdate -divider FETCH
add wave -noupdate -format Logic /tb_top/syn_cpu/blk_fetch/proc_fetch/fetchok
add wave -noupdate -format Literal /tb_top/syn_cpu/blk_fetch/proc_fetch/fetchinstr
add wave -noupdate -format Literal /tb_top/syn_cpu/fetchedinstr
add wave -noupdate -format Literal /tb_top/syn_cpu/prevfetchedinstr
add wave -noupdate -divider DECODE
add wave -noupdate -format Logic /tb_top/syn_cpu/blk_decode/proc_decode/decodeok
add wave -noupdate -format Literal /tb_top/syn_cpu/blk_decode/proc_decode/decodeinstr
add wave -noupdate -divider EXECUTE
add wave -noupdate -format Literal /tb_top/syn_cpu/executemode
add wave -noupdate -format Logic /tb_top/syn_cpu/blk_execute/proc_execute/executeok
add wave -noupdate -format Literal /tb_top/syn_cpu/executeinstr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 340
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
WaveRestoreZoom {0 ps} {4819030 ps}
