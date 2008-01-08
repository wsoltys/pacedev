onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_c64/fpga_rst
add wave -noupdate -format Logic /tb_c64/pace_1/reset
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/clk_1m_en
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/clk_1m_pulse
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/clk_4m_en
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/p2_h
add wave -noupdate -divider CPU
add wave -noupdate -format Literal /tb_c64/pace_1/gen_1541/drive_1541_inst/cpu_inst/a
add wave -noupdate -format Literal /tb_c64/pace_1/gen_1541/drive_1541_inst/cpu_inst/di
add wave -noupdate -format Literal /tb_c64/pace_1/gen_1541/drive_1541_inst/cpu_inst/do
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/cpu_inst/r_w_n
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/cpu_inst/irq_n
add wave -noupdate -format Literal /tb_c64/pace_1/gen_1541/drive_1541_inst/cpu_inst/abc
add wave -noupdate -format Literal /tb_c64/pace_1/gen_1541/drive_1541_inst/cpu_inst/alu/busa
add wave -noupdate -format Literal /tb_c64/pace_1/gen_1541/drive_1541_inst/cpu_inst/alu/busb
add wave -noupdate -divider UC1
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/uc1_via6522_inst/cs1
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/uc1_via6522_inst/cs2_l
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/uc1_via6522_inst/ca1_in
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/uc1_via6522_inst/irq_l
add wave -noupdate -divider UC3
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/uc3_via6522_inst/cs1
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/uc3_via6522_inst/cs2_l
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/uc3_via6522_inst/ca1_in
add wave -noupdate -format Literal /tb_c64/pace_1/gen_1541/drive_1541_inst/uc3_do
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/uc3_do_oe_n
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/uc3_via6522_inst/irq_l
add wave -noupdate -divider SERIAL
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/sb_atn_in
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/sb_atn_oe
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/sb_clk_in
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/sb_clk_oe
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/sb_data_in
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/sb_data_oe
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/atn
add wave -noupdate -format Logic /tb_c64/pace_1/gen_1541/drive_1541_inst/atna
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {16171484375 ps} 0}
configure wave -namecolwidth 371
configure wave -valuecolwidth 47
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
WaveRestoreZoom {0 ps} {17216078906 ps}
