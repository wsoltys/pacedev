onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider VIDEO
add wave -noupdate -format Logic /video_tb/clk
add wave -noupdate -format Logic /video_tb/reset
add wave -noupdate -format Logic /video_tb/strobe
add wave -noupdate -format Literal -radix decimal /video_tb/x
add wave -noupdate -format Literal -radix decimal /video_tb/y
add wave -noupdate -format Logic /video_tb/hsync
add wave -noupdate -format Logic /video_tb/vsync
add wave -noupdate -format Logic /video_tb/hblank
add wave -noupdate -format Logic /video_tb/vblank
add wave -noupdate -format Literal /video_tb/red
add wave -noupdate -format Literal /video_tb/green
add wave -noupdate -format Literal /video_tb/blue
add wave -noupdate -format Logic /video_tb/vid_outsel
add wave -noupdate -divider DE1
add wave -noupdate -format Logic /video_tb/de1_inst/clock_27
add wave -noupdate -format Logic /video_tb/de1_inst/clock_50
add wave -noupdate -format Logic /video_tb/de1_inst/blk_clocking/gen_pll/pll_50_inst/inclk0
add wave -noupdate -format Logic /video_tb/de1_inst/blk_clocking/gen_pll/pll_50_inst/c0
add wave -noupdate -format Logic /video_tb/de1_inst/blk_clocking/gen_pll/pll_50_inst/c1
add wave -noupdate -format Literal /video_tb/de1_inst/clk_i
add wave -noupdate -format Logic /video_tb/de1_inst/init
add wave -noupdate -format Logic /video_tb/de1_inst/reset_i
add wave -noupdate -format Logic /video_tb/de1_inst/reset_n
add wave -noupdate -format Logic /video_tb/de1_inst/video_o.clk
add wave -noupdate -format Literal /video_tb/de1_inst/video_o.rgb.r
add wave -noupdate -format Literal /video_tb/de1_inst/video_o.rgb.g
add wave -noupdate -format Literal /video_tb/de1_inst/video_o.rgb.b
add wave -noupdate -format Logic /video_tb/de1_inst/video_o.hsync
add wave -noupdate -format Logic /video_tb/de1_inst/video_o.vsync
add wave -noupdate -format Logic /video_tb/de1_inst/video_o.hblank
add wave -noupdate -format Logic /video_tb/de1_inst/video_o.vblank
add wave -noupdate -divider VIDEO_CONTROLLER
add wave -noupdate -format Logic /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/clk
add wave -noupdate -format Logic /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/clk_ena
add wave -noupdate -format Logic /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/reset
add wave -noupdate -format Logic /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/extended_reset
add wave -noupdate -format Literal -radix decimal /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/x_count
add wave -noupdate -format Literal -radix decimal /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/y_count
add wave -noupdate -format Logic /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/hsync_s
add wave -noupdate -format Logic /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/vsync_s
add wave -noupdate -format Logic /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/video_o.clk
add wave -noupdate -format Literal /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/video_o.rgb.r
add wave -noupdate -format Literal /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/video_o.rgb.g
add wave -noupdate -format Literal /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/video_o.rgb.b
add wave -noupdate -format Logic /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/video_o.hsync
add wave -noupdate -format Logic /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/video_o.vsync
add wave -noupdate -format Logic /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/video_o.hblank
add wave -noupdate -format Logic /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/video_o.vblank
add wave -noupdate -format Logic /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/stb
add wave -noupdate -format Logic /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/hactive_s
add wave -noupdate -format Logic /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/vactive_s
add wave -noupdate -format Literal -radix decimal /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/x
add wave -noupdate -format Logic /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/hblank
add wave -noupdate -format Literal /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/y
add wave -noupdate -format Logic /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/vblank
add wave -noupdate -format Literal -radix decimal /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/h_front_porch_r
add wave -noupdate -format Literal -radix decimal /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/h_back_porch_r
add wave -noupdate -format Literal -radix decimal /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/h_sync_r
add wave -noupdate -format Literal -radix decimal /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/h_border_r
add wave -noupdate -format Literal -radix decimal /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/h_video_r
add wave -noupdate -format Literal -radix decimal /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/h_sync_start
add wave -noupdate -format Literal -radix decimal /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/h_back_porch_start
add wave -noupdate -format Literal -radix decimal /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/h_left_border_start
add wave -noupdate -format Literal -radix decimal /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/h_video_start
add wave -noupdate -format Literal -radix decimal /video_tb/de1_inst/pace_inst/u_graphics/pace_video_controller_inst/h_right_border_start
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2996933200 ps} 0} {{Cursor 2} {5124824700 ps} 0}
configure wave -namecolwidth 466
configure wave -valuecolwidth 60
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
WaveRestoreZoom {2996771600 ps} {2997337300 ps}
