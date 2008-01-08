onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_asteroids/pace_1/clk_6
add wave -noupdate -format Logic /tb_asteroids/clk_24M
add wave -noupdate -format Logic /tb_asteroids/pace_1/erase
add wave -noupdate -format Literal /tb_asteroids/pace_1/x_vector
add wave -noupdate -format Literal /tb_asteroids/pace_1/y_vector
add wave -noupdate -format Literal /tb_asteroids/pace_1/z_vector
add wave -noupdate -format Logic /tb_asteroids/pace_1/beam_on
add wave -noupdate -format Logic /tb_asteroids/pace_1/beam_ena
add wave -noupdate -format Literal /tb_asteroids/red
add wave -noupdate -format Literal -radix hexadecimal /tb_asteroids/pace_1/vram_addr
add wave -noupdate -format Literal /tb_asteroids/pace_1/vram_q
add wave -noupdate -format Literal /tb_asteroids/pace_1/pixel_data
add wave -noupdate -format Literal /tb_asteroids/pace_1/vram_data
add wave -noupdate -format Logic /tb_asteroids/pace_1/vram_wren
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {419022817899 ps} 0}
configure wave -namecolwidth 231
configure wave -valuecolwidth 41
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
WaveRestoreZoom {419022328541 ps} {419022865432 ps}
