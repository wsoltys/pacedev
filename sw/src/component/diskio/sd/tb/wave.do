onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_sd/arst
add wave -noupdate -format Logic /tb_sd/clk_20
add wave -noupdate -format Literal /tb_sd/sd_gen_0/blk0/sd_if_1/state_s
add wave -noupdate -format Literal /tb_sd/sd_gen_0/blk0/sd_if_1/cmd_s
add wave -noupdate -format Literal /tb_sd/sd_gen_0/blk0/sd_if_1/proc_msg/state
add wave -noupdate -format Literal /tb_sd/sd_gen_0/blk0/sd_if_1/proc_msg/cnt
add wave -noupdate -format Literal /tb_sd/sd_gen_0/blk0/sd_if_1/proc_msg/msg_cnt
add wave -noupdate -format Literal /tb_sd/sd_gen_0/blk0/sd_if_1/card_ocr
add wave -noupdate -format Literal /tb_sd/sd_gen_0/blk0/sd_if_1/resp_s
add wave -noupdate -divider SD_CARD
add wave -noupdate -format Logic /tb_sd/sd_clk
add wave -noupdate -format Logic /tb_sd/sd_cmd
add wave -noupdate -format Literal -expand /tb_sd/sd_dat
add wave -noupdate -format Literal /tb_sd/sd_card/state
add wave -noupdate -format Literal /tb_sd/sd_card/OCR
add wave -noupdate -format Logic /tb_sd/sd_card/ValidCmd
add wave -noupdate -format Logic /tb_sd/sd_card/inValidCmd
add wave -noupdate -format Logic {/tb_sd/sd_card/inCmd[45]}
add wave -noupdate -format Logic {/tb_sd/sd_card/inCmd[44]}
add wave -noupdate -format Logic {/tb_sd/sd_card/inCmd[43]}
add wave -noupdate -format Logic {/tb_sd/sd_card/inCmd[42]}
add wave -noupdate -format Logic {/tb_sd/sd_card/inCmd[41]}
add wave -noupdate -format Logic {/tb_sd/sd_card/inCmd[40]}
add wave -noupdate -format Logic /tb_sd/sd_card/cardIdentificationState
add wave -noupdate -format Literal /tb_sd/sd_card/responseType
add wave -noupdate -format Literal /tb_sd/sd_card/response_CMD
add wave -noupdate -format Literal /tb_sd/sd_card/cmdRead
add wave -noupdate -format Literal /tb_sd/sd_card/cmdWrite
add wave -noupdate -format Logic /tb_sd/sd_card/cmdOut
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {27887 ns} 0}
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
WaveRestoreZoom {21127 ns} {35387 ns}
