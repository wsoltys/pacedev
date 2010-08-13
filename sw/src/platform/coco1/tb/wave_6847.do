onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /tb_coco/pace_inst/platform_inst/clk_57m272
add wave -noupdate -format Logic /tb_coco/pace_inst/platform_inst/clk_14m318_ena
add wave -noupdate -format Literal /tb_coco/pace_inst/platform_inst/cycle
add wave -noupdate -divider 6883
add wave -noupdate -format Logic /tb_coco/pace_inst/platform_inst/clk_e
add wave -noupdate -format Logic /tb_coco/pace_inst/platform_inst/clk_q
add wave -noupdate -divider 6847
add wave -noupdate -format Logic /tb_coco/pace_inst/platform_inst/vdg_inst/vga_vsync
add wave -noupdate -format Logic /tb_coco/pace_inst/platform_inst/vdg_inst/vga_vblank
add wave -noupdate -format Logic /tb_coco/pace_inst/platform_inst/vdg_inst/vga_hsync
add wave -noupdate -format Logic /tb_coco/pace_inst/platform_inst/vdg_inst/vga_hblank
add wave -noupdate -format Logic /tb_coco/pace_inst/platform_inst/vdg_inst/cvbs_pix_clk
add wave -noupdate -format Literal /tb_coco/pace_inst/platform_inst/vdg_inst/cvbs_dd
add wave -noupdate -divider PROC_CVBS
add wave -noupdate -format Logic /tb_coco/pace_inst/platform_inst/vdg_inst/cvbs_vblank
add wave -noupdate -format Logic /tb_coco/pace_inst/platform_inst/vdg_inst/cvbs_hblank
add wave -noupdate -format Literal /tb_coco/pace_inst/platform_inst/vdg_inst/v_count
add wave -noupdate -format Literal /tb_coco/pace_inst/platform_inst/vdg_inst/row_v
add wave -noupdate -format Literal /tb_coco/pace_inst/platform_inst/vdg_inst/proc_cvbs/h_count
add wave -noupdate -format Literal /tb_coco/pace_inst/platform_inst/vdg_inst/proc_cvbs/pix_count
add wave -noupdate -format Literal /tb_coco/pace_inst/platform_inst/vdg_inst/proc_cvbs/active_v_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0} {{Cursor 2} {2931586 ns} 0}
configure wave -namecolwidth 159
configure wave -valuecolwidth 86
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
WaveRestoreZoom {15135 ns} {19865 ns}
