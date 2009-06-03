onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_sb16/sb16_hw/wb_clk_i
add wave -noupdate -format Logic /tb_sb16/sb16_hw/wb_rst_i
add wave -noupdate -format Logic /tb_sb16/sb16_hw/blk_dsp/dsp_rst
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_io_arena
add wave -noupdate -format Literal /tb_sb16/test_p/dat
add wave -noupdate -format Literal /tb_sb16/sb16_hw/audio_l
add wave -noupdate -format Literal /tb_sb16/sb16_hw/audio_r
add wave -noupdate -divider WISHBONE
add wave -noupdate -format Literal /tb_sb16/sb16_hw/wb_adr_i
add wave -noupdate -format Literal /tb_sb16/sb16_hw/wb_adr
add wave -noupdate -format Literal /tb_sb16/sb16_hw/wb_dat_i
add wave -noupdate -format Literal /tb_sb16/sb16_hw/wb_dat_o
add wave -noupdate -format Logic /tb_sb16/sb16_hw/wb_cyc_i
add wave -noupdate -format Logic /tb_sb16/sb16_hw/wb_stb_i
add wave -noupdate -format Logic /tb_sb16/sb16_hw/wb_we_i
add wave -noupdate -format Logic /tb_sb16/sb16_hw/wb_ack_o
add wave -noupdate -divider MIXER
add wave -noupdate -format Logic /tb_sb16/sb16_hw/mxr_stb
add wave -noupdate -format Literal /tb_sb16/sb16_hw/mxr_dat_o
add wave -noupdate -format Literal /tb_sb16/sb16_hw/mxr_audio_l
add wave -noupdate -format Literal /tb_sb16/sb16_hw/mxr_audio_r
add wave -noupdate -divider DSP
add wave -noupdate -format Logic /tb_sb16/sb16_hw/dsp_stb
add wave -noupdate -format Literal /tb_sb16/sb16_hw/dsp_dat_o
add wave -noupdate -format Literal /tb_sb16/sb16_hw/blk_dsp/state
add wave -noupdate -format Logic /tb_sb16/sb16_hw/blk_dsp/clr_dsp_rd_sts
add wave -noupdate -format Logic /tb_sb16/sb16_hw/blk_dsp/set_dsp_rd_sts
add wave -noupdate -format Logic /tb_sb16/sb16_hw/blk_dsp/dsp_rd_sts
add wave -noupdate -format Literal /tb_sb16/sb16_hw/blk_dsp/dsp_rd_dat
add wave -noupdate -format Logic /tb_sb16/sb16_hw/blk_dsp/clr_dsp_wr_sts
add wave -noupdate -format Logic /tb_sb16/sb16_hw/blk_dsp/set_dsp_wr_sts
add wave -noupdate -format Logic /tb_sb16/sb16_hw/blk_dsp/dsp_wr_sts
add wave -noupdate -format Literal /tb_sb16/sb16_hw/blk_dsp/dsp_wr_dat
add wave -noupdate -format Literal /tb_sb16/sb16_hw/dsp_audio_l
add wave -noupdate -format Literal /tb_sb16/sb16_hw/dsp_audio_r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2915 ns} 0}
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
WaveRestoreZoom {0 ns} {8400 ns}
