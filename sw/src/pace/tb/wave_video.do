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
add wave -noupdate -divider VIDEO_CONTROLLER
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/h_size
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/v_size
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/h_front_porch_r
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/h_sync_r
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/h_back_porch_r
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/h_border_r
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/h_video_r
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/h_sync_start
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/h_back_porch_start
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/h_left_border_start
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/h_video_start
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/h_right_border_start
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/h_line_end
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/v_front_porch_r
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/v_sync_r
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/v_back_porch_r
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/v_border_r
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/v_video_r
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/v_sync_start
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/v_back_porch_start
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/v_top_border_start
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/v_video_start
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/v_bottom_border_start
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/v_screen_end
add wave -noupdate -divider signals
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/x_count
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/y_count
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/x_active
add wave -noupdate -format Literal -radix decimal /video_tb/vgacontroller_1/y_active
add wave -noupdate -format Logic /video_tb/vgacontroller_1/hactive_s
add wave -noupdate -format Logic /video_tb/vgacontroller_1/vactive_s
add wave -noupdate -format Logic /video_tb/vgacontroller_1/hblank_s
add wave -noupdate -format Logic /video_tb/vgacontroller_1/vblank_s
add wave -noupdate -format Logic /video_tb/vgacontroller_1/hsync_s
add wave -noupdate -format Logic /video_tb/vgacontroller_1/vsync_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {16447516185 ps} 0} {{Cursor 2} {16458527439 ps} 0}
configure wave -namecolwidth 275
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
WaveRestoreZoom {16412215402 ps} {16486217503 ps}
