## Generated SDC file "mixer_test.sdc"

## Copyright (C) 1991-2009 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 9.1 Build 222 10/21/2009 SJ Full Version"

## DATE    "Mon Mar 22 19:24:09 2010"

##
## DEVICE  "EP3SE50F780C2"
##

# Video input clock
# 108MHz = 1280x1024 @ 60Hz
#set vi_period 9.259
# 147.14MHz = 1600x1050 @ 60Hz
#set vi_period 6.795
# 156MHz = 1600x1200 @ 60Hz
#set vi_period 6.409
# 25MHz (DVI min)
#set vdi_period_low 40.0
set vdi_period_low 10.0
# 165MHz (DVI max)
set vdi_period_high 6.061
# 25MHz (VGA min)
#set vai_period_low 40.0
set vai_period_low 10.0
# 165MHz (VGA max)
set vai_period_high 6.061

set vsi_period 8.929
set vid_sp_period 8.929

# TFP401 register timing (timing defined as source synchronous)
set vdi_odck_tsu_max 2.1
set vdi_odck_th_min 0.5

# TFP401 board trace delays relative to clock trace
set vdi_data_delay_max 0.200
set vdi_data_delay_min 0
#set vdi_data_delay_max 1.00
#set vdi_data_delay_min -0.800

# VGA register timing (timing defined as clock to out delay)
set vai_dataclk_tco_max 1.5
set vai_dataclk_tco_min 0.0

# VGA board trace delays relative to clock trace
set vai_data_delay_max 0.150
set vai_data_delay_min -0.150

set vdo_phase -2.975
set vdo_rise $vdo_phase
set vdo_fall_low [expr $vdi_period_low / 2 + $vdo_phase]
set vdo_fall_high [expr $vdi_period_high / 2 + $vdo_phase]

set bridge_period 41.667
set bridge_tsu 28.0
set bridge_th -0.5
set bridge_tco_min 0.0
set bridge_tco_max 22.0

#set vli_period 10.938
set vli_period 8.929
set vli_tsu 7.5
set vli_th 0.5

set def_in_min 0.0
set def_in_max 10.0
set def_out_min 0.0
set def_out_max 4.5


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk24_c} -period 41.667 [get_ports {clk24_c}]
create_clock -name {clk24_d} -period 41.667 [get_ports {clk24_d}]
create_clock -name {veb_ck_c} -period 41.667 [get_ports {veb_ck_c}]
create_clock -name {veb_ck_d} -period 41.667 [get_ports {veb_ck_d}]
create_clock -name {vdi_odck_low} -period $vdi_period_low [get_ports {vdi_odck}]
create_clock -add -name {vdi_odck_high} -period $vdi_period_high [get_ports {vdi_odck}]
create_clock -name {vai_dataclk_low} -period $vai_period_low [get_ports {vai_dataclk}]
create_clock -add -name {vai_dataclk_high} -period $vai_period_high [get_ports {vai_dataclk}]
#create_clock -name {vdo_idck} -period 6.061 -waveform { 0.000 3.030 } [get_ports {vdo_idck}]
create_clock -name {vsi_clk0} -period 8.929 -waveform { 0.000 4.464 } [get_ports {vsi_clk[0]}]
create_clock -name {vsi_clk1} -period 8.929 -waveform { 0.000 4.464 } [get_ports {vsi_clk[1]}]
create_clock -name {vli_clk} -period [expr $vli_period] [get_ports {vli_clk}]
create_clock -name {vli_clk_virt} -period [expr $vli_period]
create_clock -name {vid_clk} -period [expr $bridge_period] [get_ports {vid_clk}]
create_clock -name {vid_clk_virt} -period [expr $bridge_period]

#create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
#set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 

#**************************************************************
# Create Generated Clock
#**************************************************************

#create_generated_clock -name vdo_clk -source [get_pins {\BLK_PLL:vip_pll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 77 -divide_by 12 -master_clock {clk24_d} [get_pins {\BLK_PLL:vip_pll_inst|altpll_component|auto_generated|pll1|clk[1]}] 
#create_generated_clock -name vdo_idck -source [get_pins {\BLK_PLL:vip_pll_inst|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 77 -divide_by 12 -phase -165.000 -master_clock {clk24_d} [vdo_idck}] 

derive_pll_clocks


#create_clock -period $vi_period -name vi_odck [get_ports {vi_odck}]
# Virtual clock to represent clock at device pin
create_clock -period $vdi_period_low -name vdi_odck_low_virt
create_clock -period $vdi_period_high -name vdi_odck_high_virt
create_clock -period $vai_period_low -name vai_dataclk_low_virt
create_clock -period $vai_period_high -name vai_dataclk_high_virt
create_clock -period $vsi_period -name vsi_odck_virt

# Video output clock
#set vo_period 9.259
#set vo_period 6.409
#set vo_period [get_clock_info [get_clocks {dvopll_inst|altpll_component|auto_generated|pll1|clk[1]}] -period]
#create_generated_clock -name vdo_idck_virt -source vdo_idck
#create_generated_clock -name vdo_clk -source [get_nets {\BLK_VIDOUT:vip_pll_inst|altpll_component|auto_generated|wire_pll1_clk[1]}] [get_ports {vdo_clk}]
create_generated_clock -name vdo_clk -source [get_nets {\BLK_PLL:vip_pll_inst|altpll_component|auto_generated|wire_pll1_clk[1]}] 
create_generated_clock -name vdo_idck -source [get_nets {\BLK_PLL:vip_pll_inst|altpll_component|auto_generated|wire_pll1_clk[2]}] [get_ports {vdo_idck}]
#create_clock -name vdo_idck_low_virt -period $vdi_period_low -waveform {$vdo_rise $vdo_fall_low} [get_ports {vdo_idck}]
#create_clock -name vdo_idck_high_virt -period $vdi_period_high -waveform {$vdo_rise $vdo_fall_high} [get_ports {vdo_idck}]

#create_generated_clock -name vdo_idck_virt -offset $vdo_phase -source [get_clocks vdo_idck_low_base]
#create_generated_clock -add -name vdo_idck_virt -offset $vdo_phase -source vdo_idck_high_base
#create_clock -name vdo_idck_low_virt -period $vdi_period_low -waveform {37.025 17.025} [get_ports {vdo_idck}]
#create_clock -name vdo_idck_high_virt -period $vdi_period_high -waveform {3.086 0.056} [get_ports {vdo_idck}]

#create_clock -period $vo_period -name vo_idck_virt

#create_generated_clock -name vao_clk_virt -source vao_clk
#create_generated_clock -name vao_clk -source [get_nets {\BLK_PLL:vip_pll_inst|altpll_component|auto_generated|pll1|clk[1]}] [get_ports {vao_clk}]
create_generated_clock -name vao_clk -source [get_nets {\BLK_PLL:vip_pll_inst|altpll_component|auto_generated|wire_pll1_clk[1]}] [get_ports {vao_clk}]

# 33MHz LPC bus clock(s)
#create_clock -period 30 -name clk_lpc_a [get_ports {mix_ckp_a}]
#create_generated_clock -name vo_clk -source [get_nets {dvopll_inst|altpll_component|auto_generated|wire_pll1_clk[0]}] [get_ports {vo_idck}]



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -from { vdi_odck_low_virt } -setup 0.25
set_clock_uncertainty -from { vdi_odck_high_virt } -setup 0.25
set_clock_uncertainty -from { vai_dataclk_low_virt } -setup 0.25
set_clock_uncertainty -from { vai_dataclk_high_virt } -setup 0.25
set_clock_uncertainty -from { vsi_odck_virt } -setup 0.25
set_clock_uncertainty -from { vid_clk_virt } -setup 0.25
set_clock_uncertainty -from { vid_clk_virt } -hold 0.25
derive_clock_uncertainty


#**************************************************************
# Set Input Delay
#**************************************************************

# TFP401 input min and max delays
set_input_delay -clock vdi_odck_low_virt -max [expr $vdi_period_low + $vdi_data_delay_max - $vdi_odck_tsu_max] [get_ports {vdi_blue[*] vdi_de vdi_green[*] vdi_hsync vdi_red[*] vdi_scdt vdi_vsync}]
set_input_delay -clock vdi_odck_low_virt -min [expr $vdi_odck_th_min + $vdi_data_delay_min] [get_ports {vdi_blue[*] vdi_de vdi_green[*] vdi_hsync vdi_red[*] vdi_scdt vdi_vsync}]
set_input_delay -add_delay -clock vdi_odck_high_virt -max [expr $vdi_period_high + $vdi_data_delay_max - $vdi_odck_tsu_max] [get_ports {vdi_blue[*] vdi_de vdi_green[*] vdi_hsync vdi_red[*] vdi_scdt vdi_vsync}]
set_input_delay -add_delay -clock vdi_odck_high_virt -min [expr $vdi_odck_th_min + $vdi_data_delay_min] [get_ports {vdi_blue[*] vdi_de vdi_green[*] vdi_hsync vdi_red[*] vdi_scdt vdi_vsync}]
#set_input_delay -clock vi_odck_virt -max 1 [get_ports {vi_blue[*] vi_de vi_green[*] vi_hsync vi_red[*] vi_scdt vi_vsync}]
#set_input_delay -clock vi_odck_virt -min 0.4 [get_ports {vi_blue[*] vi_de vi_green[*] vi_hsync vi_red[*] vi_scdt vi_vsync}]

# VGA input min and max delays
set_input_delay -clock vai_dataclk_low_virt -max [expr $vai_dataclk_tco_max + $vai_data_delay_max] [get_ports {vai_blue[*] vai_green[*] vai_hsync vai_red[*] vai_scdt vai_vsync vai_fidout vai_hsout vai_vsout vai_sogout vai_coast}]
set_input_delay -clock vai_dataclk_low_virt -min [expr $vai_dataclk_tco_min + $vai_data_delay_min] [get_ports {vai_blue[*] vai_green[*] vai_hsync vai_red[*] vai_scdt vai_vsync vai_fidout vai_hsout vai_vsout vai_sogout vai_coast}]
set_input_delay -add_delay -clock vai_dataclk_high_virt -max [expr $vai_dataclk_tco_max + $vai_data_delay_max] [get_ports {vai_blue[*] vai_green[*] vai_hsync vai_red[*] vai_scdt vai_vsync vai_fidout vai_hsout vai_vsout vai_sogout vai_coast}]
set_input_delay -add_delay -clock vai_dataclk_high_virt -min [expr $vai_dataclk_tco_min + $vai_data_delay_min] [get_ports {vai_blue[*] vai_green[*] vai_hsync vai_red[*] vai_scdt vai_vsync vai_fidout vai_hsout vai_vsout vai_sogout vai_coast}]

# FPGA bridge input delays
set_input_delay -min $bridge_tco_min -clock vid_clk_virt [get_ports {vid_address[*] vid_data[*] vid_read_n vid_reset vid_reset_core vid_write_n}]
set_input_delay -max [expr $bridge_period - $bridge_tco_max] -clock vid_clk_virt [get_ports {vid_address[*] vid_data[*] vid_read_n vid_reset vid_reset_core vid_write_n}]

set_input_delay -min [expr $vli_period - $vli_tsu] -clock vli_clk_virt [get_ports {vli_red[*] vli_green[*] vli_blue[*] vli_hsync vli_vsync vli_de vli_locked}]
set_input_delay -max [expr $vli_th] -clock vli_clk_virt [get_ports {vli_red[*] vli_green[*] vli_blue[*] vli_hsync vli_vsync vli_de vli_locked}]


#**************************************************************
# Set Output Delay
#**************************************************************

# FPGA bridge output delays
set_output_delay -min [expr $bridge_th] -clock vid_clk_virt [get_ports {vid_data[*] vid_waitrequest_n vid_irq_n}]
set_output_delay -max [expr $bridge_period - $bridge_tsu] -clock vid_clk_virt [get_ports {vid_data[*] vid_waitrequest_n vid_irq_n}]

# TFP410 register timing (timing defined as source synchronous)
set vdo_idck_tsu_min 1.2
set vdo_idck_th_min 1.3

# TFP410 board trace delays relative to clock trace
set vdo_data_delay_max 0.500
set vdo_data_delay_min -0.100

# TFP410 output min and max delays
set_output_delay -clock vdo_idck -max [expr $vdo_data_delay_max + $vdo_idck_tsu_min] [get_ports {vdo_blue[*] vdo_de vdo_green[*] vdo_hsync vdo_red[*] vdo_vsync}]
set_output_delay -clock vdo_idck -min [expr $vdo_data_delay_min - $vdo_idck_th_min] [get_ports {vdo_blue[*] vdo_de vdo_green[*] vdo_hsync vdo_red[*] vdo_vsync}]

# THS8135 register timing (timing defined as source synchronous)
set vao_idck_tsu_min 2.0
set vao_idck_th_min 0.5

# THS8135 board trace delays relative to clock trace
set vao_data_delay_max 0.500
set vao_data_delay_min -0.100

# THS8135 output min and max delays
set_output_delay -clock vao_clk -max [expr $vao_data_delay_max + $vao_idck_tsu_min] [get_ports {vao_blue[*] vao_de vao_green[*] vao_hsync vao_red[*] vao_vsync vao_sync_n}]
set_output_delay -clock vao_clk -min [expr $vao_data_delay_min - $vao_idck_th_min] [get_ports {vao_blue[*] vao_de vao_green[*] vao_hsync vao_red[*] vao_vsync vao_sync_n}]
#set_output_delay -clock vdo_clk -max 0.01 [get_ports {vao_clk}]
#set_output_delay -clock vdo_clk -min 0.01 [get_ports {vao_clk}]

# JTAG pins
#set_output_delay -clock altera_reserved_tck -clock_fall 1 [get_ports altera_reserved_tdo]

# JTAG
#set_input_delay -min [expr $def_in_min] -clock altera_reserved_tck [get_ports {altera_reserved_tdi altera_reserved_tms}]
#set_input_delay -max [expr $def_in_max] -clock altera_reserved_tck [get_ports {altera_reserved_tdi altera_reserved_tms}]
#set_output_delay -min [expr $def_out_min] -clock altera_reserved_tck [get_ports {altera_reserved_tdo}]
#set_output_delay -max [expr $def_out_max] -clock altera_reserved_tck [get_ports {altera_reserved_tdo}]


#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -exclusive -group [get_clocks {vai_dataclk_low vai_dataclk_low_virt}] -group [get_clocks {vai_dataclk_high vai_dataclk_high_virt}]
set_clock_groups -exclusive -group [get_clocks {vai_dataclk_low vai_dataclk_low_virt}] -group [get_clocks {vdi_odck_high vdi_odck_high_virt}]
set_clock_groups -exclusive -group [get_clocks {vdi_odck_low vdi_odck_low_virt}] -group [get_clocks {vdi_odck_high vdi_odck_high_virt}]
set_clock_groups -exclusive -group [get_clocks {vdi_odck_low vdi_odck_low_virt}] -group [get_clocks {vai_dataclk_high vai_dataclk_high_virt}]
set_clock_groups -exclusive -group [get_clocks {vai_dataclk_low vai_dataclk_low_virt}] -group [get_clocks {vdi_odck_low vdi_odck_low_virt}]
set_clock_groups -exclusive -group [get_clocks {vai_dataclk_high vai_dataclk_high_virt}] -group [get_clocks {vdi_odck_high vdi_odck_high_virt}]
#set_clock_groups -exclusive -group [get_clocks {vdo_idck_low_base}] -group [get_clocks {vdo_idck_high_base}]
#set_clock_groups -asynchronous -group [get_clocks altera_reserved_tck]


#**************************************************************
# Set False Path
#**************************************************************

#set_false_path -from [get_clocks {vli_clk_virt}] -to [get_clocks {vpll0|altpll_component|auto_generated|pll1|clk[2]}]
#set_false_path -from {vdi_odck} -to {clkcount:\BLK_VID1_SELECT:VID_CLK_COUNT|\VID_CLK_CNT:slow_clk_r[1]}
#set_false_path -from {lvdsa|altlvds_rx_component|auto_generated|pll|clk[2]} -to {clkcount:\BLK_VID2_SELECT:VID_CLK_COUNT|\VID_CLK_CNT:slow_clk_r[1]}
#set_false_path -from [get_ports {altera_reserved_tdi}] -to {sld_hub:*}
#set_false_path -from [get_ports {altera_reserved_tms}] -to {sld_hub:*}
set_false_path -from {vid_reset_core} -to {irn_r[0]}
set_false_path -from {vdi_scdt} -to {ep3sl_sopc_system:vip_inst|pio_egmvid:the_pio_egmvid|*}
#set_false_path -from [get_clocks {vdi_odck_low}] -to [get_clocks {vai_dataclk_high}]
#set_false_path -from [get_clocks {vai_dataclk_high}] -to [get_clocks {vdi_odck_low}]
#set_false_path -from [get_clocks {vai_dataclk_high_virt}] -to [get_clocks {vdi_odck_low}]
#set_false_path -from [get_clocks {vai_dataclk_low}] -to [get_clocks {vai_dataclk_high}] 
#set_false_path -from [get_clocks {vai_dataclk_low_virt}] -to [get_clocks {vai_dataclk_high}]
#set_false_path -from [get_clocks {vdi_odck_high}] -to [get_clocks {vai_dataclk_low}]
#set_false_path -from [get_clocks {vai_dataclk_high}] -to [get_clocks {vai_dataclk_low}]
#set_false_path -from [get_clocks {vai_dataclk_low}] -to [get_clocks {vdi_odck_high}]
set_false_path -from [get_clocks {vdi_odck_low_virt}] -to [get_clocks {vip_inst|the_altmemddr_0|altmemddr_0_controller_phy_inst|altmemddr_0_phy_inst|altmemddr_0_phy_alt_mem_phy_inst|clk|half_rate.pll|altpll_component|auto_generated|pll1|clk[7]}]
set_false_path -from [get_clocks {vip_inst|the_altmemddr_0|altmemddr_0_controller_phy_inst|altmemddr_0_phy_inst|altmemddr_0_phy_alt_mem_phy_inst|clk|half_rate.pll|altpll_component|auto_generated|pll1|clk[7]}] -to [get_clocks {vdi_odck_high}]
set_false_path -from [get_clocks {vip_inst|the_altmemddr_0|altmemddr_0_controller_phy_inst|altmemddr_0_phy_inst|altmemddr_0_phy_alt_mem_phy_inst|clk|half_rate.pll|altpll_component|auto_generated|pll1|clk[7]}] -to [get_clocks {vdi_odck_low}]
set_false_path -from [get_clocks {vip_inst|the_altmemddr_0|altmemddr_0_controller_phy_inst|altmemddr_0_phy_inst|altmemddr_0_phy_alt_mem_phy_inst|clk|half_rate.pll|altpll_component|auto_generated|pll1|clk[7]}] -to [get_clocks {vai_dataclk_low}]
set_false_path -from [get_clocks {vip_inst|the_altmemddr_0|altmemddr_0_controller_phy_inst|altmemddr_0_phy_inst|altmemddr_0_phy_alt_mem_phy_inst|clk|half_rate.pll|altpll_component|auto_generated|pll1|clk[7]}] -to [get_clocks {vai_dataclk_high}]
set_false_path -from {*} -to {*:presence_*}

# vl_dualpix_source and related components
set_false_path -from {*|vl_dualpix_source:*l_vc_sync[*]} -to {*|vl_dualpix_source:*ystart_cnt_r[1][*]}
set_false_path -from {*|vl_dualpix_source:*l_vc_pre[*]} -to {*|vl_dualpix_source:*ystart_cnt_r[1][*]}
set_false_path -from {*|vl_dualpix_source:*l_vc_sync[*]} -to {*|vl_dualpix_source:*video_first_line_r[1][*]} 
set_false_path -from {*|vl_dualpix_source:*l_vc_pre[*]} -to {*|vl_dualpix_source:*video_first_line_r[1][*]} 
set_false_path -from {*|vl_dualpix_source:*l_vc_pre[*]} -to {*|vl_dualpix_source:*yfront_cnt_r[1][*]}
set_false_path -from {*|vl_dualpix_source:*l_vc_sync[*]} -to {*|vl_dualpix_source:*ysync_cnt_r[1][*]}
set_false_path -from {*|vl_dualpix_source:*l_hc_act[*]} -to {*|vl_dualpix_source:*video_width_r[1][*]}
set_false_path -from {*|vl_dualpix_source:*l_vc[*]} -to {*|vl_dualpix_source:*ytotal_cnt_r[1][*]};
set_false_path -from {*|vl_dualpix_source:*l_hc_act[*]} -to {*|vl_dualpix_source:*xactive_cnt_r[1][*]}; 
set_false_path -from {*|vl_dualpix_source:*l_vc_act[*]} -to {*|vl_dualpix_source:*video_height_r[1][*]}; 
set_false_path -from {*|vl_dualpix_source:*l_hc_post[*]} -to {*|vl_dualpix_source:*xback_cnt_r[1][*]}; 
set_false_path -from {*|vl_dualpix_source:*l_vc_act[*]} -to {*|vl_dualpix_source:*video_height_r[1][*]}; 
set_false_path -from {*|vl_dualpix_source:*l_hc_act[*]} -to {*|vl_dualpix_source:*xactive_cnt_r[1][*]}; 
set_false_path -from {*|vl_dualpix_source:*l_vc_act[*]} -to {*|vl_dualpix_source:*yactive_cnt_r[1][*]}; 
set_false_path -from {*|vl_dualpix_source:*l_hc[*]} -to {*|vl_dualpix_source:*xtotal_cnt_r[1][*]}; 
set_false_path -from {*|vl_dualpix_source:*l_hc_sync[*]} -to {*|vl_dualpix_source:*xsync_cnt_r[1][*]}; 
set_false_path -from {*|vl_dualpix_source:*l_vc_post[*]} -to {*|vl_dualpix_source:*yback_cnt_r[1][*]}; 
set_false_path -from {*|vl_dualpix_source:*l_hc_pre[*]} -to {*|vl_dualpix_source:*xfront_cnt_r[1][*]}; 
set_false_path -from {*|vl_dualpix_source:*video_sof_sh[*]} -to {*|vl_dualpix_source:*start_frame_r[1]}
set_false_path -from {*|vl_dualpix_source:*video_sof_sh[*]} -to {*|vl_dualpix_source:*video_sof_r[1]}
set_false_path -from {*|vl_dualpix_source:*video_sol_sh[*]} -to {*|vl_dualpix_source:*start_line_r[1]}
set_false_path -from {*|vl_dualpix_source:*video_stable} -to {*|vl_dualpix_source:*video_stable_r[1]}
set_false_path -from {*|vl_dualpix_source:*video_res_ok} -to {*|vl_dualpix_source:*video_res_ok_r[1]}
set_false_path -from {*|vl_dualpix_source:*video_status[*]} -to {*|vl_dualpix_source:*video_status_r[1][*]} 
set_false_path -from {*|vl_dualpix_source:*:Ucoolest|hsync_strt_*_reg_r[*]} -to {*|vl_dualpix_source:*start_pxl_x_*_r[1][*]}; 
set_false_path -from {*|vl_dualpix_source:*:Ucoolest|vsync_strt_*_reg_r[*]} -to {*|vl_dualpix_source:*start_pxl_y_*_r[1][*]}; 
#set_false_path -from {*|vl_dualpix_source:*:Ucool|de_r} -to {*|vl_dualpix_source:*overflow_r[1]}; 
set_false_path -from {*} -to {*|vl_dualpix_source:*:overflow_r[1]}; 
set_false_path -from {*|vl_dualpix_source:*clk_cnt[1]} -to {*|vl_dualpix_source:vip_egmvid_in*ck4_um[1]}

# False paths related to EGMVID clock mux
set_false_path -from [get_clocks {vid_clk}] -to [get_clocks {vai_dataclk_high}]
set_false_path -from [get_clocks {vid_clk}] -to [get_clocks {vai_dataclk_low}]
set_false_path -from [get_clocks {vid_clk}] -to [get_clocks {vdi_odck_high}]
set_false_path -from [get_clocks {vid_clk}] -to [get_clocks {vdi_odck_low}]

set_false_path -from {*} -to {*clkcount*:slow_clk_r[1]}; 
set_false_path -from {vid_reset_core} -to {unmeta_reset_n:*|um_reg[1]}
set_false_path -from {*} -to {\BLK_EGMVID_SELECT:v1_hsync_r[0]}
set_false_path -from {*} -to {\BLK_EGMVID_SELECT:v1_vsync_r[0]}
set_false_path -from {*} -to {\BLK_EGMVID_SELECT:v1_hsync_v_r[0]}
set_false_path -from {*} -to {\BLK_EGMVID_SELECT:v1_vsync_v_r[0]}
set_false_path -from {*} -to {sync_inverter:*|sync_r[0]}
set_false_path -from {*} -to {sync_inverter:*|sync_r[0]}


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

