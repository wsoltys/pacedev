onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /video_tb/clk_20m
add wave -noupdate -format Logic /video_tb/clk_40m
add wave -noupdate -divider {BITMAP CTL}
add wave -noupdate -divider TILEMAPCTL
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/gen_tilemap_1/foreground_mapctl_inst/vblank
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/gen_tilemap_1/foreground_mapctl_inst/hblank
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/gen_tilemap_1/foreground_mapctl_inst/stb
add wave -noupdate -format Literal -radix decimal /video_tb/pace_inst/u_graphics/gen_tilemap_1/foreground_mapctl_inst/x
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/gen_tilemap_1/foreground_mapctl_inst/y
add wave -noupdate -format Literal -radix decimal /video_tb/pace_inst/u_graphics/gen_tilemap_1/foreground_mapctl_inst/tilemap_a
add wave -noupdate -format Literal -radix decimal /video_tb/pace_inst/u_graphics/gen_tilemap_1/foreground_mapctl_inst/tilemap_d
add wave -noupdate -format Literal -radix hexadecimal /video_tb/pace_inst/u_graphics/gen_tilemap_1/foreground_mapctl_inst/tile_a
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/gen_tilemap_1/foreground_mapctl_inst/tile_d
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/gen_tilemap_1/foreground_mapctl_inst/rgb.r
add wave -noupdate -divider Variables
add wave -noupdate -format Literal -radix decimal /video_tb/pace_inst/u_graphics/gen_tilemap_1/foreground_mapctl_inst/tilemapproc/scroll_x
add wave -noupdate -format Literal -radix octal /video_tb/pace_inst/u_graphics/gen_tilemap_1/foreground_mapctl_inst/tilemapproc/x_r
add wave -noupdate -divider video_o_proc
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o_proc/hsync_v_r
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o_proc/vsync_v_r
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o_proc/hactive_v_r
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o_proc/vactive_v_r
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o_proc/hblank_v_r
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o_proc/vblank_v_r
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o_proc/hsync_v
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o_proc/vsync_v
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o_proc/hactive_v
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o_proc/vactive_v
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o_proc/hblank_v
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o_proc/vblank_v
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o_proc/stb_cnt_v
add wave -noupdate -divider VIDEO_CONTROLLER
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/pace_video_controller_inst/hactive_s
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o.hblank
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o.vblank
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/pace_video_controller_inst/rgb_i.r
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o.rgb.r
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o.rgb.g
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o.rgb.b
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2999701 ns} 0}
configure wave -namecolwidth 163
configure wave -valuecolwidth 42
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
update
WaveRestoreZoom {1991011 ns} {1991595 ns}
