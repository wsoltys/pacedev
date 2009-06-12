onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_inst/wb_clk_i
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_inst/wb_rst_i
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_inst/blk_dsp/dsp_rst
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_inst/sb16_io_arena
add wave -noupdate -format Literal /tb_sb16/test_p/dat
add wave -noupdate -format Literal /tb_sb16/sb16_hw/sb16_inst/audio_l
add wave -noupdate -format Literal /tb_sb16/sb16_hw/sb16_inst/audio_r
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_inst/pc_speaker
add wave -noupdate -divider WISHBONE
add wave -noupdate -format Literal /tb_sb16/sb16_hw/sb16_inst/wb_adr_i
add wave -noupdate -format Literal /tb_sb16/sb16_hw/sb16_inst/wb_adr
add wave -noupdate -format Literal /tb_sb16/sb16_hw/sb16_inst/wb_dat_i
add wave -noupdate -format Literal /tb_sb16/sb16_hw/sb16_inst/wb_dat_o
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_inst/wb_cyc_i
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_inst/wb_stb_i
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_inst/wb_we_i
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_inst/wb_ack_o
add wave -noupdate -divider MIXER
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_inst/mxr_stb
add wave -noupdate -format Literal /tb_sb16/sb16_hw/sb16_inst/blk_mixer/mxr_adr
add wave -noupdate -format Literal /tb_sb16/sb16_hw/sb16_inst/mxr_dat_o
add wave -noupdate -format Literal /tb_sb16/sb16_hw/sb16_inst/blk_mixer/pc_spkr_vol
add wave -noupdate -format Literal /tb_sb16/sb16_hw/sb16_inst/mxr_audio_l
add wave -noupdate -format Literal /tb_sb16/sb16_hw/sb16_inst/mxr_audio_r
add wave -noupdate -divider DSP
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_inst/dsp_stb
add wave -noupdate -format Literal /tb_sb16/sb16_hw/sb16_inst/dsp_dat_o
add wave -noupdate -format Literal /tb_sb16/sb16_hw/sb16_inst/blk_dsp/state
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_inst/blk_dsp/clr_dsp_rd_sts
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_inst/blk_dsp/set_dsp_rd_sts
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_inst/blk_dsp/dsp_rd_sts
add wave -noupdate -format Literal /tb_sb16/sb16_hw/sb16_inst/blk_dsp/dsp_rd_dat
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_inst/blk_dsp/clr_dsp_wr_sts
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_inst/blk_dsp/set_dsp_wr_sts
add wave -noupdate -format Logic /tb_sb16/sb16_hw/sb16_inst/blk_dsp/dsp_wr_sts
add wave -noupdate -format Literal /tb_sb16/sb16_hw/sb16_inst/blk_dsp/dsp_wr_dat
add wave -noupdate -format Literal /tb_sb16/sb16_hw/sb16_inst/dsp_audio_l
add wave -noupdate -format Literal /tb_sb16/sb16_hw/sb16_inst/dsp_audio_r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8200 ns} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {9450 ns}
