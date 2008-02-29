onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_top/reset
add wave -noupdate -format Logic /tb_top/clk_32m
add wave -noupdate -format Logic /tb_top/clk_4m_en
add wave -noupdate -divider SN76489
add wave -noupdate -format Logic /tb_top/sn76489_inst/clk_div16_en
add wave -noupdate -format Literal -expand /tb_top/sn76489_inst/reg
add wave -noupdate -format Literal /tb_top/sn76489_inst/d
add wave -noupdate -format Logic /tb_top/sn76489_inst/we_n
add wave -noupdate -format Literal -expand /tb_top/sn76489_inst/audio_d
add wave -noupdate -format Logic /tb_top/sn76489_inst/shift_s
add wave -noupdate -divider T1
add wave -noupdate -format Logic /tb_top/sn76489_inst/clk_div16_en
add wave -noupdate -format Literal /tb_top/sn76489_inst/gen_tone_gens__0/tone_inst/freq
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {13317588664 ps} 0} {{Cursor 2} {5369967356 ps} 0}
configure wave -namecolwidth 225
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
WaveRestoreZoom {0 ps} {21 ms}
