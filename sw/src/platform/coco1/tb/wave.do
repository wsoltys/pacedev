onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_coco/fpga_rst
add wave -noupdate -format Logic {/tb_coco/clk[0]}
add wave -noupdate -format Logic {/tb_coco/clk[1]}
add wave -noupdate -divider game
add wave -noupdate -format Logic /tb_coco/pace_inst/u_game/sys_clk
add wave -noupdate -format Logic /tb_coco/pace_inst/u_game/clk_e
add wave -noupdate -format Logic /tb_coco/pace_inst/u_game/clk_q
add wave -noupdate -format Literal /tb_coco/pace_inst/u_game/sys_count
add wave -noupdate -format Literal /tb_coco/pace_inst/u_game/upaddr
add wave -noupdate -format Literal /tb_coco/pace_inst/u_game/mpu_addr
add wave -noupdate -format Literal /tb_coco/pace_inst/u_game/rom_datao
add wave -noupdate -format Literal /tb_coco/pace_inst/u_game/ram_datao
add wave -noupdate -divider CPU
add wave -noupdate -format Logic /tb_coco/pace_inst/u_game/gen_not_test_vga/cpu_inst/clk
add wave -noupdate -format Literal /tb_coco/pace_inst/u_game/gen_not_test_vga/cpu_inst/address
add wave -noupdate -format Literal /tb_coco/pace_inst/u_game/gen_not_test_vga/cpu_inst/data_in
add wave -noupdate -format Literal /tb_coco/pace_inst/u_game/gen_not_test_vga/cpu_inst/data_out
add wave -noupdate -divider SRAM
add wave -noupdate -format Logic /tb_coco/SRAM/cs_n
add wave -noupdate -format Logic /tb_coco/SRAM/oe_n
add wave -noupdate -format Logic /tb_coco/SRAM/we_n
add wave -noupdate -format Literal /tb_coco/SRAM/addr
add wave -noupdate -format Literal /tb_coco/SRAM/data
add wave -noupdate -divider SAM
add wave -noupdate -format Logic /tb_coco/pace_inst/u_game/gen_not_test_vga/sam_inst/sel_cr
add wave -noupdate -format Logic /tb_coco/pace_inst/u_game/gen_not_test_vga/sam_inst/ty
add wave -noupdate -format Literal /tb_coco/pace_inst/u_game/gen_not_test_vga/sam_inst/m
add wave -noupdate -format Literal /tb_coco/pace_inst/u_game/gen_not_test_vga/sam_inst/f
add wave -noupdate -format Literal /tb_coco/pace_inst/u_game/gen_not_test_vga/sam_inst/z
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {69167790 ps} 0}
configure wave -namecolwidth 382
configure wave -valuecolwidth 40
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
WaveRestoreZoom {83120618 ps} {341140869 ps}
