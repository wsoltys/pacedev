onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /ps2_tb/host_inst/clk
add wave -noupdate -format Logic /ps2_tb/host_inst/reset
add wave -noupdate -format Literal /ps2_tb/host_inst/fifo_data
add wave -noupdate -format Logic /ps2_tb/host_inst/fifo_wrreq
add wave -noupdate -format Logic /ps2_tb/host_inst/ps2_kclk
add wave -noupdate -format Logic /ps2_tb/host_inst/ps2_kdat
add wave -noupdate -divider HOST_SM
add wave -noupdate -format Literal /ps2_tb/host_inst/blk_sm/state
add wave -noupdate -format Logic /ps2_tb/host_inst/fifo_rdreq
add wave -noupdate -format Logic /ps2_tb/host_inst/fifo_empty
add wave -noupdate -divider DEVICE
add wave -noupdate -format Logic /ps2_tb/device_inst/press
add wave -noupdate -format Logic /ps2_tb/device_inst/release
add wave -noupdate -format Logic /ps2_tb/device_inst/reset
add wave -noupdate -format Literal /ps2_tb/device_inst/scancode
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
WaveRestoreZoom {0 ps} {69300550006 ps}
