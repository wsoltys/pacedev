onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_wd179x/floppy_inst/reset
add wave -noupdate -format Logic /tb_wd179x/clk_20m
add wave -noupdate -divider WD1793
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/mr_n
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/cs_n
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/re_n
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/we_n
add wave -noupdate -format Literal /tb_wd179x/fdc_dat_i
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/data_i_r
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/command_r
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/sector_r
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/data_o_r
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/cmd_wr_stb
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/sec_wr_stb
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/idam_track
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/idam_side
add wave -noupdate -format Literal -radix decimal /tb_wd179x/wd179x_inst/idam_sector
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/idam_seclen
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/idam_dam
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/status_r
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/irq_mask
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/irq_clr
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/irq_set
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/intrq
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/drq
add wave -noupdate -divider CMD
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/blk_command/state
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/cmd_busy
add wave -noupdate -divider type_i
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/type_i_stb
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/type_i_ack
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/blk_type_i/state
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/blk_type_i/proc_type_i/count
add wave -noupdate -divider type_ii
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/type_ii_stb
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/blk_type_ii/state
add wave -noupdate -divider {read block}
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/trk_upd_f
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/hd_load_f
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/rclk
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/blk_read/raw_data_r
add wave -noupdate -format Literal /tb_wd179x/wd179x_inst/blk_read/state
add wave -noupdate -format Literal -radix decimal /tb_wd179x/wd179x_inst/blk_read/proc_i_dam/count
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/raw_data_rdy
add wave -noupdate -format Logic /tb_wd179x/wd179x_inst/sector_data_rdy
add wave -noupdate -divider FLOPPY
add wave -noupdate -format Logic /tb_wd179x/floppy_inst/clk_1m_ena
add wave -noupdate -format Logic /tb_wd179x/floppy_inst/step
add wave -noupdate -format Logic /tb_wd179x/floppy_inst/dirc
add wave -noupdate -format Literal /tb_wd179x/floppy_inst/mem_a
add wave -noupdate -format Literal /tb_wd179x/floppy_inst/mem_d_i
add wave -noupdate -format Logic /tb_wd179x/floppy_inst/tr00_n
add wave -noupdate -format Logic /tb_wd179x/floppy_inst/ip_n
add wave -noupdate -format Literal /tb_wd179x/floppy_inst/track_r
add wave -noupdate -format Logic /tb_wd179x/floppy_inst/rclk
add wave -noupdate -format Logic /tb_wd179x/floppy_inst/raw_read_n
add wave -noupdate -format Literal -radix decimal /tb_wd179x/floppy_inst/blk_read/proc_rd/count
add wave -noupdate -format Literal /tb_wd179x/floppy_inst/blk_read/proc_rd/phase
add wave -noupdate -format Literal /tb_wd179x/floppy_inst/blk_read/proc_rd/bbit
add wave -noupdate -format Literal /tb_wd179x/floppy_inst/blk_read/proc_rd/byte
add wave -noupdate -format Literal /tb_wd179x/floppy_inst/blk_read/proc_rd/read_data_r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7845 ns} 0} {{Cursor 2} {11365 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 64
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
WaveRestoreZoom {0 ns} {231 ms}
