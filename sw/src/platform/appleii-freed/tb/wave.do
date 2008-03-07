onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_top/reset
add wave -noupdate -format Logic /tb_top/clk_28m571
add wave -noupdate -divider SPI_CONTROLLER
add wave -noupdate -format Logic /tb_top/spi_controller_inst/CLK_14M
add wave -noupdate -format Logic /tb_top/spi_controller_inst/reset
add wave -noupdate -divider SPI
add wave -noupdate -format Logic /tb_top/spi_controller_inst/SCLK
add wave -noupdate -format Logic /tb_top/spi_controller_inst/CS_N
add wave -noupdate -format Logic /tb_top/spi_controller_inst/MOSI
add wave -noupdate -format Logic /tb_top/spi_controller_inst/MISO
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4770 ns} 0} {{Cursor 2} {4698 ns} 0}
configure wave -namecolwidth 220
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
WaveRestoreZoom {4631 ns} {4820 ns}
