onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /tb_top/pace_inst/red
add wave -noupdate -format Literal /tb_top/pace_inst/green
add wave -noupdate -format Literal /tb_top/pace_inst/blue
add wave -noupdate -divider TIMING/VIDEO
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/reset
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/reset_n
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/sys_cycle
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/clk_16m
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/clk_8m_en
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/clk_4m_en
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/clk_2m_en
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/clk_1m_en
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/via6522_p2
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/via6522_clk4
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/clk_2m_180_en
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/clk_1m_90_en
add wave -noupdate -divider CPU
add wave -noupdate -format Literal /tb_top/pace_inst/sram_o
add wave -noupdate -format Literal /tb_top/pace_inst/sram_i
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/cpu_clk_en
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/cpu_a
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/cpu_d_i
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/cpu_d_o
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/cpu_rw_n
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/cpu_inst/x
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/cpu_inst/alu/p_in
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/cpu_irq_n
add wave -noupdate -divider SHEILA
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/sheila_d
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/sysvia_cs
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/blk_sheila/sysvia_d
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/sysvia_pa_i
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/sysvia_pa_o
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/kbd_col
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/kbd_row
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/kbd_bit
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/kbd_int
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/vsync_int
add wave -noupdate -divider SYSVIA
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/blk_sheila/sysvia_inst/cs
add wave -noupdate -divider VIDEO
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/blk_video/crtc6845_hsync
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/blk_video/crtc6845_vsync
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/video_a
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/video_d
add wave -noupdate -divider CRTC6845S
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/blk_video/crtc6845s_inst/O_RA
add wave -noupdate -format Literal /tb_top/pace_inst/u_game/blk_video/crtc6845s_inst/O_MA
add wave -noupdate -format Logic /tb_top/pace_inst/u_game/blk_video/crtc6845s_inst/O_DISPTMG
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {98360 ns} 0} {{Cursor 2} {62899 ns} 0}
configure wave -namecolwidth 279
configure wave -valuecolwidth 56
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
WaveRestoreZoom {97947 ns} {100779 ns}
