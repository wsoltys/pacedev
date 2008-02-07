onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_top/pace_inst/red
add wave -noupdate -format Literal /tb_top/pace_inst/green
add wave -noupdate -format Literal /tb_top/pace_inst/blue
add wave -noupdate -divider GAME
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/reset
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/reset_n
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/clk_16m
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/clk_8m_en
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/clk_4m_en
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/clk_2m_en
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/clk_1m_en
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/video_ram_a
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/video_ram_d
add wave -noupdate -divider VIDEO
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/blk_video/crtc6845_clk
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/blk_video/crtc6845_hsync
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/blk_video/crtc6845_vsync
add wave -noupdate -divider CRTC6845S
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/blk_video/crtc6845s_inst/O_RA
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/blk_video/crtc6845s_inst/O_MA
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/blk_video/crtc6845s_inst/O_DISPTMG
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19967284258 ps} 0} {{Cursor 2} {18035218750 ps} 0}
configure wave -namecolwidth 395
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
WaveRestoreZoom {0 ps} {42 ms}
