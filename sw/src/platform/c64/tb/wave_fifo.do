onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_top/fpga_rst
add wave -noupdate -format Logic /tb_top/ref_clk
add wave -noupdate -format Logic /tb_top/fifo_wrclk
add wave -noupdate -format Literal /tb_top/fifo_data
add wave -noupdate -format Logic /tb_top/fifo_wrreq
add wave -noupdate -divider C1541_CORE
add wave -noupdate -format Logic /tb_top/c1541_core_inst/fifo_rdreq
add wave -noupdate -format Logic /tb_top/c1541_core_inst/fifo_rdclk_en
add wave -noupdate -format Literal /tb_top/c1541_core_inst/stp
add wave -noupdate -format Logic /tb_top/c1541_core_inst/stp_in
add wave -noupdate -format Logic /tb_top/c1541_core_inst/stp_out
add wave -noupdate -format Logic /tb_top/c1541_core_inst/fifo_aclr
add wave -noupdate -divider FIFO_INST
add wave -noupdate -format Logic /tb_top/c1541_core_inst/mtr
add wave -noupdate -format Logic /tb_top/c1541_core_inst/fifo_inst/rdclk
add wave -noupdate -format Logic /tb_top/c1541_core_inst/fifo_inst/rdreq
add wave -noupdate -format Logic /tb_top/c1541_core_inst/fifo_inst/wrfull
add wave -noupdate -format Literal /tb_top/c1541_core_inst/fifo_inst/wrusedw
add wave -noupdate -format Literal /tb_top/c1541_core_inst/fifo_wrusedw_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {147966464 ps} 0}
configure wave -namecolwidth 244
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
WaveRestoreZoom {0 ps} {693462 ns}
