onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider VIDEO
add wave -noupdate -format Logic /video_tb/clk
add wave -noupdate -format Logic /video_tb/reset
add wave -noupdate -format Logic /video_tb/strobe
add wave -noupdate -format Literal /video_tb/x
add wave -noupdate -format Literal /video_tb/y
add wave -noupdate -format Literal /video_tb/vid_r
add wave -noupdate -format Literal /video_tb/vid_g
add wave -noupdate -format Literal /video_tb/vid_b
add wave -noupdate -format Logic /video_tb/hblank
add wave -noupdate -format Logic /video_tb/vblank
add wave -noupdate -format Literal /video_tb/red
add wave -noupdate -format Literal /video_tb/green
add wave -noupdate -format Literal /video_tb/blue
add wave -noupdate -format Logic /video_tb/vid_outsel
add wave -noupdate -format Literal /video_tb/vgacontroller_1/count_v_s
add wave -noupdate -format Literal /video_tb/vgacontroller_1/active_v_s
add wave -noupdate -divider PACMAN
add wave -noupdate -format Logic /video_tb/mapctl_pacman/clk_ena
add wave -noupdate -format Logic /video_tb/mapctl_pacman/vblank
add wave -noupdate -format Logic /video_tb/mapctl_pacman/hblank
add wave -noupdate -format Literal /video_tb/mapctl_pacman/pix_x
add wave -noupdate -format Literal /video_tb/mapctl_pacman/pix_y
add wave -noupdate -format Literal /video_tb/mapctl_pacman/tilemap_a
add wave -noupdate -format Literal /video_tb/mapctl_pacman/tilemap_d
add wave -noupdate -format Literal /video_tb/mapctl_pacman/tile_a
add wave -noupdate -format Literal /video_tb/mapctl_pacman/tile_d
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5911939893 ps} 0}
configure wave -namecolwidth 248
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
WaveRestoreZoom {7282168616 ps} {7426501639 ps}
