onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_lpcspi/clk(0)
add wave -noupdate -format Logic /tb_lpcspi/reset
add wave -noupdate -divider LPC_SPI
add wave -noupdate -format Logic /tb_lpcspi/lpc_spi_inst/chipselect
add wave -noupdate -format Literal /tb_lpcspi/lpc_spi_inst/di
add wave -noupdate -format Literal /tb_lpcspi/lpc_spi_inst/do
add wave -noupdate -format Logic /tb_lpcspi/lpc_spi_inst/rd
add wave -noupdate -format Logic /tb_lpcspi/lpc_spi_inst/wr
add wave -noupdate -format Logic /tb_lpcspi/lpc_spi_inst/waitrequest_n
add wave -noupdate -format Literal /tb_lpcspi/lpc_spi_inst/rsspcpsr
add wave -noupdate -format Literal /tb_lpcspi/lpc_spi_inst/rsspcr0
add wave -noupdate -format Literal /tb_lpcspi/lpc_spi_inst/rsspcr1
add wave -noupdate -format Literal /tb_lpcspi/lpc_spi_inst/rsspdr
add wave -noupdate -format Literal /tb_lpcspi/lpc_spi_inst/rsspicr
add wave -noupdate -format Literal /tb_lpcspi/lpc_spi_inst/rsspimsc
add wave -noupdate -format Literal /tb_lpcspi/lpc_spi_inst/rsspmis
add wave -noupdate -format Literal /tb_lpcspi/lpc_spi_inst/rsspris
add wave -noupdate -format Literal /tb_lpcspi/lpc_spi_inst/rsspsr
add wave -noupdate -divider FIFO
add wave -noupdate -format Logic /tb_lpcspi/lpc_spi_inst/blk_fifo/lpc_send_fifo/sclr
add wave -noupdate -format Logic /tb_lpcspi/lpc_spi_inst/blk_fifo/lpc_send_fifo/rdreq
add wave -noupdate -format Logic /tb_lpcspi/lpc_spi_inst/blk_fifo/lpc_send_fifo/wrreq
add wave -noupdate -format Literal /tb_lpcspi/lpc_spi_inst/blk_fifo/lpc_send_fifo/data
add wave -noupdate -format Literal /tb_lpcspi/lpc_spi_inst/blk_fifo/lpc_send_fifo/q
add wave -noupdate -format Logic /tb_lpcspi/lpc_spi_inst/blk_fifo/lpc_send_fifo/empty
add wave -noupdate -format Logic /tb_lpcspi/lpc_spi_inst/blk_fifo/lpc_send_fifo/full
add wave -noupdate -format Literal /tb_lpcspi/lpc_spi_inst/blk_fifo/lpc_send_fifo/usedw
add wave -noupdate -divider {RX FIFO}
add wave -noupdate -format Literal /tb_lpcspi/lpc_spi_inst/receive_fifo_data
add wave -noupdate -format Logic /tb_lpcspi/lpc_spi_inst/receive_fifo_rd
add wave -noupdate -format Logic /tb_lpcspi/lpc_spi_inst/receive_fifo_wr
add wave -noupdate -divider PROC_SEND
add wave -noupdate -format Literal /tb_lpcspi/lpc_spi_inst/blk_send/state
add wave -noupdate -format Logic /tb_lpcspi/lpc_spi_inst/busy
add wave -noupdate -format Logic /tb_lpcspi/lpc_spi_inst/send_fifo_empty
add wave -noupdate -format Logic /tb_lpcspi/lpc_spi_inst/blk_send/proc_send/spi_clk_r
add wave -noupdate -format Logic /tb_lpcspi/lpc_spi_inst/spi_clk_s
add wave -noupdate -divider SPI
add wave -noupdate -format Logic /tb_lpcspi/spi_clk
add wave -noupdate -format Logic /tb_lpcspi/spi_miso
add wave -noupdate -format Logic /tb_lpcspi/spi_mosi
add wave -noupdate -format Logic /tb_lpcspi/spi_ss
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {991869 ps} 0}
configure wave -namecolwidth 121
configure wave -valuecolwidth 59
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
WaveRestoreZoom {0 ps} {6300 ns}
