onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_coco/clkrst_i.arst
add wave -noupdate -format Logic /tb_coco/clkrst_i.rst(0)
add wave -noupdate -format Logic /tb_coco/clkrst_i.clk(0)
add wave -noupdate -divider CPU09
add wave -noupdate -format Logic /tb_coco/pace_inst/platform_inst/gen_cpu09/cpu_inst/clk
add wave -noupdate -format Logic /tb_coco/pace_inst/platform_inst/gen_cpu09/cpu_inst/rst
add wave -noupdate -format Literal /tb_coco/pace_inst/platform_inst/gen_cpu09/cpu_inst/address
add wave -noupdate -format Literal /tb_coco/pace_inst/platform_inst/gen_cpu09/cpu_inst/data_in
add wave -noupdate -format Literal /tb_coco/pace_inst/platform_inst/gen_cpu09/cpu_inst/data_out
add wave -noupdate -divider SRAM
add wave -noupdate -format Literal /tb_coco/pace_inst/sram_i.d
add wave -noupdate -format Literal /tb_coco/pace_inst/sram_o.a
add wave -noupdate -format Literal /tb_coco/pace_inst/sram_o.d
add wave -noupdate -format Literal /tb_coco/pace_inst/sram_o.be
add wave -noupdate -format Logic /tb_coco/pace_inst/sram_o.cs
add wave -noupdate -format Logic /tb_coco/pace_inst/sram_o.oe
add wave -noupdate -format Logic /tb_coco/pace_inst/sram_o.we
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {86455 ns} 0}
configure wave -namecolwidth 183
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
WaveRestoreZoom {0 ns} {2100 us}
