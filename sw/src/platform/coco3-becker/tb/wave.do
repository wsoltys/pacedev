onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_coco3/pace_inst/reset
add wave -noupdate -format Logic /tb_coco3/pace_inst/clk_50m
add wave -noupdate -format Literal /tb_coco3/pace_inst/blk_sram/state
add wave -noupdate -format Literal -expand /tb_coco3/pace_inst/sram_i
add wave -noupdate -format Literal -expand /tb_coco3/pace_inst/sram_o
add wave -noupdate -divider PACE
add wave -noupdate -format Literal /tb_coco3/pace_inst/ram0_di
add wave -noupdate -format Literal /tb_coco3/pace_inst/ram0_do
add wave -noupdate -format Literal /tb_coco3/pace_inst/ram0_be_n
add wave -noupdate -format Logic /tb_coco3/pace_inst/ram0_cs_n
add wave -noupdate -format Logic /tb_coco3/pace_inst/ram_oe_n
add wave -noupdate -format Logic /tb_coco3/pace_inst/ram_rw_n
add wave -noupdate -divider COCO3
add wave -noupdate -format Literal /tb_coco3/pace_inst/coco_inst/RAM_ADDRESS
add wave -noupdate -format Logic /tb_coco3/pace_inst/coco_inst/PH_2
add wave -noupdate -divider VIDEO
add wave -noupdate -format Logic /tb_coco3/pace_inst/coco_inst/COCOVID/RESET_N
add wave -noupdate -format Logic /tb_coco3/pace_inst/coco_inst/COCOVID/PIX_CLK
add wave -noupdate -format Literal /tb_coco3/pace_inst/coco_inst/COCOVID/PIXEL_COUNT
add wave -noupdate -format Logic /tb_coco3/pace_inst/coco_inst/COCOVID/READMEM
add wave -noupdate -format Logic /tb_coco3/pace_inst/coco_inst/COCOVID/READROM1
add wave -noupdate -format Logic /tb_coco3/pace_inst/coco_inst/COCOVID/READROM2
add wave -noupdate -divider CPU09
add wave -noupdate -format Literal /tb_coco3/pace_inst/coco_inst/GLBCPU09/address
add wave -noupdate -format Literal /tb_coco3/pace_inst/coco_inst/GLBCPU09/data_in
add wave -noupdate -format Literal /tb_coco3/pace_inst/coco_inst/GLBCPU09/data_out
add wave -noupdate -divider SRAM
add wave -noupdate -format Literal /tb_coco3/sram/a
add wave -noupdate -format Literal /tb_coco3/sram/d
add wave -noupdate -format Logic /tb_coco3/sram/nbhe
add wave -noupdate -format Logic /tb_coco3/sram/nble
add wave -noupdate -format Logic /tb_coco3/sram/ce2
add wave -noupdate -format Logic /tb_coco3/sram/noe
add wave -noupdate -format Logic /tb_coco3/sram/nwe
add wave -noupdate -format Literal /tb_coco3/sram_di
add wave -noupdate -format Literal /tb_coco3/sram_do
add wave -noupdate -format Literal /tb_coco3/sram/sram_core/adr_hold
add wave -noupdate -format Literal /tb_coco3/sram/sram_core/adr_setup
add wave -noupdate -format Literal /tb_coco3/sram/sram_core/valid_adr
add wave -noupdate -format Logic /tb_coco3/sram/sram_core/read_valid
add wave -noupdate -format Logic /tb_coco3/sram/sram_core/read_active
add wave -noupdate -format Logic /tb_coco3/sram/sram_core/do_write
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1846151169 ps} 0} {{Cursor 2} {1853460104 ps} 0}
configure wave -namecolwidth 314
configure wave -valuecolwidth 81
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
WaveRestoreZoom {1846020426 ps} {1846276779 ps}
