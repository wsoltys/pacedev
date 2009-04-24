onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_ems/clk
add wave -noupdate -format Logic /tb_ems/reset
add wave -noupdate -format Literal /tb_ems/sdram_seg_i
add wave -noupdate -format Literal /tb_ems/sdram_seg_o
add wave -noupdate -divider EMS
add wave -noupdate -format Logic /tb_ems/ems_hw/ems_io_area
add wave -noupdate -format Logic /tb_ems/ems_hw/wb_cyc_i
add wave -noupdate -format Logic /tb_ems/ems_hw/wb_stb_i
add wave -noupdate -format Logic /tb_ems/ems_hw/wb_we_i
add wave -noupdate -format Literal /tb_ems/ems_hw/wb_adr_i
add wave -noupdate -format Literal /tb_ems/wb_sel_i
add wave -noupdate -format Logic /tb_ems/ems_hw/wb_ack_o
add wave -noupdate -format Literal /tb_ems/ems_hw/wb_dat_i
add wave -noupdate -format Literal /tb_ems/wb_dat_o
add wave -noupdate -format Logic /tb_ems/ems_hw/ems_enable
add wave -noupdate -format Literal -radix hexadecimal /tb_ems/ems_hw/umb_base_adr
add wave -noupdate -format Literal /tb_ems/ems_hw/page_reg
add wave -noupdate -format Literal -expand /tb_ems/ems_hw/page_adr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1585051 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 47
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
WaveRestoreZoom {793951 ps} {1961865 ps}
