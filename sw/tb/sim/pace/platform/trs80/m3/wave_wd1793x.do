onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_wd179x/floppy_inst/reset
add wave -noupdate -format Logic /tb_wd179x/clk_20m
add wave -noupdate -divider WD1793
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/mr_n
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/cs_n
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/we_n
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/cmd_wr_stb
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/cmd
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/type_i_stb
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/type_i_ack
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/blk_command/state
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/cmd_busy
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/trk_upd_f
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/hd_load_f
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/rclk
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/blk_read/raw_data_r
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/blk_read/state
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/raw_data_rdy
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/sector_data_rdy
add wave -noupdate -divider FLOPPY
add wave -noupdate -format Logic /tb_wd179x/floppy_inst/step
add wave -noupdate -format Logic /tb_wd179x/floppy_inst/dirc
add wave -noupdate -format Literal /tb_wd179x/floppy_inst/mem_a
add wave -noupdate -format Literal /tb_wd179x/floppy_inst/mem_d_i
add wave -noupdate -format Logic /tb_wd179x/floppy_inst/tr00_n
add wave -noupdate -format Logic /tb_wd179x/floppy_inst/ip_n
add wave -noupdate -format Literal /tb_wd179x/floppy_inst/track_r
add wave -noupdate -format Logic /tb_wd179x/floppy_inst/rclk
add wave -noupdate -format Logic /tb_wd179x/floppy_inst/raw_read_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {93689 ns} 0} {{Cursor 2} {876020 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
WaveRestoreZoom {4999739 ns} {5000416 ns}
