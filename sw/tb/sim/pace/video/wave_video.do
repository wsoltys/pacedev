onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /video_tb/clk_20m
add wave -noupdate -format Logic /video_tb/clk_40m
add wave -noupdate -divider {BITMAP CTL}
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/gen_bitmap_1/bitmapctl_inst/clk
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/gen_bitmap_1/bitmapctl_inst/stb
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/gen_bitmap_1/bitmapctl_inst/hblank
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/gen_bitmap_1/bitmapctl_inst/vblank
add wave -noupdate -format Literal -radix decimal /video_tb/pace_inst/u_graphics/gen_bitmap_1/bitmapctl_inst/x
add wave -noupdate -format Literal -radix decimal /video_tb/pace_inst/u_graphics/gen_bitmap_1/bitmapctl_inst/y
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/gen_bitmap_1/bitmapctl_inst/rgb.r
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/gen_bitmap_1/bitmapctl_inst/rgb.g
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/gen_bitmap_1/bitmapctl_inst/rgb.b
add wave -noupdate -divider VIDEO_CONTROLLER
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/pace_video_controller_inst/hactive_s
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o.hblank
add wave -noupdate -format Logic /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o.vblank
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o.rgb.r
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o.rgb.g
add wave -noupdate -format Literal /video_tb/pace_inst/u_graphics/pace_video_controller_inst/video_o.rgb.b
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2107732900 ps} 0}
configure wave -namecolwidth 421
configure wave -valuecolwidth 42
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
WaveRestoreZoom {2999631400 ps} {3000019500 ps}
