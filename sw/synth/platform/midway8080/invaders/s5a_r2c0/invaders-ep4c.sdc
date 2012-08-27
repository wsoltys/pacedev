## Generated SDC file "S5A-sw-MF2-ep4c.sdc"

## Copyright (C) 1991-2010 Altera Corporation
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
## VERSION "Version 9.1 Build 350 03/24/2010 Service Pack 2 SJ Full Version"

## DATE    "Tue Aug 24 00:56:20 2010"

##
## DEVICE  "EP4CE15F23C6"
##


set_time_format -unit ns -decimal_places 3

# Timing settings

set bridge_period 41.667
set bridge_tsu 28.0
set bridge_th -0.5
set bridge_tco_min 0.0
set bridge_tco_max 22.0

set veb_period 41.667
#set veb_period 13.889
set veb_m_tco_min 0.0
set veb_m_tco_max 10.0
set veb_s_tco_min 0.0
set veb_s_tco_max 15.0

set def_in_min 0.0
set def_in_max 10.0
set def_out_min 0.0
set def_out_max 4.5

set usb_in_min 0.0
set usb_in_max 10.0
set usb_out_min 6.5
set usb_out_max 2.0	
# Because of UH_D[1] we need to accept > 1 clk tco
#set usb_out_max -1.5	

# Clocks

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 

create_clock -name clk24_a -period [expr $bridge_period] [get_ports {clk24_a}]
create_clock -name veb_ck_a -period [expr $veb_period] [get_ports {veb_ck_a}]
create_clock -name veb_ck_sp -period [expr $veb_period] [get_ports {veb_ck_sp}]

create_generated_clock -name clk_nios -source [get_nets {\BLK_NIOS:nios_inst|the_altmemddr_0|altmemddr_0_controller_phy_inst|altmemddr_0_phy_inst|altmemddr_0_phy_alt_mem_phy_inst|clk|pll|altpll_component|auto_generated|clk[0]}] 
create_generated_clock -name vid_clk_virt -source [get_nets {\BLK_NIOS:nios_pll_inst|altpll_component|auto_generated|wire_pll1_clk[2]}] 

set nios_period [get_clock_info [get_clocks {clk_nios}] -period]

# Clock Uncertainty

set_clock_uncertainty -from { vid_clk_virt } -setup 0.25
set_clock_uncertainty -from { vid_clk_virt } -hold 0.25
derive_clock_uncertainty

# Timing constraints

# Video I2C buses and misc control signals
set_input_delay -min [expr $def_in_min] -clock clk_nios [get_ports {dvo_scl dvo_sda vai_scl vai_sda}]
set_input_delay -max [expr $def_in_max] -clock clk_nios [get_ports {dvo_scl dvo_sda vai_scl vai_sda}]
set_output_delay -min [expr $def_out_min] -clock clk_nios [get_ports {dvo_scl dvo_sda vai_scl vai_sda dvi_dis_eep_ddc dvi_eep_wp dvi_dis_fpg_ddc dvi_en_i2c dvi_connect dvi_oen}]
set_output_delay -max [expr $def_out_max] -clock clk_nios [get_ports {dvo_scl dvo_sda vai_scl vai_sda dvi_dis_eep_ddc dvi_eep_wp dvi_dis_fpg_ddc dvi_en_i2c dvi_connect dvi_oen}]

# EDID I2C buses
set_input_delay -min [expr $def_in_min] -clock clk_nios [get_ports {dvi_eep_scl dvi_eep_sda dvi_fpg_scl dvi_fpg_sda vdo_scl vdo_sda sdvo_scl sdvo_sda lvds_i2c_dat lvds_i2c_ck}]
set_input_delay -max [expr $def_in_max] -clock clk_nios [get_ports {dvi_eep_scl dvi_eep_sda dvi_fpg_scl dvi_fpg_sda vdo_scl vdo_sda sdvo_scl sdvo_sda lvds_i2c_dat lvds_i2c_ck}]
set_output_delay -min [expr $def_out_min] -clock clk_nios [get_ports {dvi_eep_scl dvi_eep_sda dvi_fpg_scl dvi_fpg_sda vdo_scl vdo_sda sdvo_scl sdvo_sda lvds_i2c_dat lvds_i2c_ck}]
set_output_delay -max [expr $def_out_max] -clock clk_nios [get_ports {dvi_eep_scl dvi_eep_sda dvi_fpg_scl dvi_fpg_sda vdo_scl vdo_sda sdvo_scl sdvo_sda lvds_i2c_dat lvds_i2c_ck}]
    
# Carrier LPC bus interface
set_input_delay -min [expr $veb_m_tco_min] -clock veb_ck_a [get_ports {veb_a[*] veb_framen veb_reset}]
set_input_delay -max [expr $veb_m_tco_max] -clock veb_ck_a [get_ports {veb_a[*] veb_framen veb_reset}]
set_output_delay -min [expr $veb_s_tco_min] -clock veb_ck_a [get_ports {veb_a[*] veb_irqn}]
set_output_delay -max [expr $veb_period - $veb_s_tco_max] -clock veb_ck_a [get_ports {veb_a[*] veb_irqn}]
#		veb_sp			    : inout std_logic_vector(4 downto 0);

# I2C to the carrier
set_input_delay -min [expr $def_in_min] -clock clk_nios [get_ports {veb_i2c_clk veb_i2c_dat veb_smb_clk veb_smb_dat}]
set_input_delay -max [expr $def_in_max] -clock clk_nios [get_ports {veb_i2c_clk veb_i2c_dat veb_smb_clk veb_smb_dat}]
set_output_delay -min [expr $def_out_min] -clock clk_nios [get_ports {veb_i2c_clk veb_i2c_dat veb_smb_clk veb_smb_dat}]
set_output_delay -max [expr $def_out_max] -clock clk_nios [get_ports {veb_i2c_clk veb_i2c_dat veb_smb_clk veb_smb_dat}]

# Touchscreen serial ports
set_input_delay -min [expr $def_in_min] -clock clk_nios [get_ports {ser_ts_rx ser_ts_cts ser_pc_rx ser_pc_cts}]
set_input_delay -max [expr $def_in_max] -clock clk_nios [get_ports {ser_ts_rx ser_ts_cts ser_pc_rx ser_pc_cts}]
set_output_delay -min [expr $def_out_min] -clock clk_nios [get_ports {ser_ts_tx ser_ts_rts ser_pc_tx ser_pc_rts}]
set_output_delay -max [expr $def_out_max] -clock clk_nios [get_ports {ser_ts_tx ser_ts_rts ser_pc_tx ser_pc_rts}]

#	Internal USB controller, external PHY
set_input_delay -min [expr $def_in_min] -clock clk_nios [get_ports {ul_rcv ul_v_p ul_v_n ul_vbusdet}]
set_input_delay -max [expr $def_in_max] -clock clk_nios [get_ports {ul_rcv ul_v_p ul_v_n ul_vbusdet}]
set_output_delay -min [expr $def_out_min] -clock clk_nios [get_ports {ul_spd ul_v_p ul_v_n ul_con ul_sus ul_rsel ul_oen}]
set_output_delay -max [expr $def_out_max] -clock clk_nios [get_ports {ul_spd ul_v_p ul_v_n ul_con ul_sus ul_rsel ul_oen}]

#	External USB controller
set_input_delay -min [expr $usb_in_min] -clock clk_nios [get_ports {uh_d[*] uh_intn uh_dreq[*]}]
set_input_delay -max [expr $usb_in_max] -clock clk_nios [get_ports {uh_d[*] uh_intn uh_dreq[*]}]
set_output_delay -min [expr $usb_out_min] -clock clk_nios [get_ports {uh_resetn uh_a[*] uh_d[*] uh_csn uh_rdn uh_wrn uh_be[*] uh_dack[*]}]
set_output_delay -max [expr $usb_out_max] -clock clk_nios [get_ports {uh_resetn uh_a[*] uh_d[*] uh_csn uh_rdn uh_wrn uh_be[*] uh_dack[*]}]

# False paths (async bus using custom timing controller)
#set_false_path -from {uh_d[*]} -to {ep4c_sopc_system:\BLK_NIOS:nios_inst|*}
#set_false_path -from {ep4c_sopc_system:\BLK_NIOS:nios_inst|*} -to {uh_d[*]}
#set_false_path -from {ep4c_sopc_system:\BLK_NIOS:nios_inst|*} -to {uh_be[*]}
#set_false_path -from {ep4c_sopc_system:\BLK_NIOS:nios_inst|*} -to {uh_a[*]}

# Connection to video FPGA
set_output_delay -min -0.1 -clock vid_clk_virt [get_ports {vid_clk}]
set_output_delay -max 0.1 -clock vid_clk_virt [get_ports {vid_clk}]
set_input_delay -min [expr $bridge_th] -clock vid_clk_virt [get_ports {vid_data[*] vid_waitrequest vid_irq_n}]
set_input_delay -max [expr $bridge_period - $bridge_tsu] -clock vid_clk_virt [get_ports {vid_data[*] vid_waitrequest vid_irq_n}]
set_output_delay -min [expr $bridge_tco_min] -clock vid_clk_virt [get_ports {vid_address[*] vid_data[*] vid_read_n vid_write_n vid_reset vid_reset_core}]
set_output_delay -max [expr $bridge_period - $bridge_tco_max] -clock vid_clk_virt [get_ports {vid_address[*] vid_data[*] vid_read_n vid_write_n vid_reset vid_reset_core}]
		
# Power management and video control signals
set_input_delay -min [expr $def_in_min] -clock clk_nios [get_ports {veb_i2c_alertn lvds_sel vdo_po1 vsi_resetn vdi_present}]
set_input_delay -max [expr $def_in_max] -clock clk_nios [get_ports {veb_i2c_alertn lvds_sel vdo_po1 vsi_resetn vdi_present}]
set_output_delay -min [expr $def_out_min] -clock clk_nios [get_ports {v15_s3 v15_s5 lvds_sel vdi_pdn vai_pdn vdo_rstn dvi_hotplug_n vsi_resetn clk24_en}]
set_output_delay -max [expr $def_out_max] -clock clk_nios [get_ports {v15_s3 v15_s5 lvds_sel vdi_pdn vai_pdn vdo_rstn dvi_hotplug_n vsi_resetn clk24_en}]

# LEDs and debug I/O
set_input_delay -min [expr $def_in_min] -clock clk_nios [get_ports {dbgio[*]}]
set_input_delay -max [expr $def_in_max] -clock clk_nios [get_ports {dbgio[*]}]
set_output_delay -min [expr $def_out_min] -clock clk_nios [get_ports {led_lvds led_sdvo led_avo led_avo led_dvo led_avi led_avi led_dvi dbgio[*]}]
set_output_delay -max [expr $def_out_max] -clock clk_nios [get_ports {led_lvds led_sdvo led_avo led_avo led_dvo led_avi led_avi led_dvi dbgio[*]}]

# SPI eeprom
set_input_delay -min [expr $def_in_min] -clock clk_nios [get_ports {ee_so}]
set_input_delay -max [expr $def_in_max] -clock clk_nios [get_ports {ee_so}]
set_output_delay -min [expr $def_out_min] -clock clk_nios [get_ports {ee_ck ee_si ee_csn}]
set_output_delay -max [expr $def_out_max] -clock clk_nios [get_ports {ee_ck ee_si ee_csn}]

#    -- test points (default to in)
#		tp82            : in std_logic;
#		tp83            : in std_logic;
#		tp84            : in std_logic;
#		tp109           : in std_logic;
#		tp121           : in std_logic

# JTAG
set_input_delay -min [expr $def_in_min] -clock altera_reserved_tck [get_ports {altera_reserved_tdi altera_reserved_tms}]
set_input_delay -max [expr $def_in_max] -clock altera_reserved_tck [get_ports {altera_reserved_tdi altera_reserved_tms}]
set_output_delay -min [expr $def_out_min] -clock altera_reserved_tck [get_ports {altera_reserved_tdo}]
set_output_delay -max [expr $def_out_max] -clock altera_reserved_tck [get_ports {altera_reserved_tdo}]

# EPCS SPI
set_input_delay -min [expr $def_in_min] -clock clk_nios [get_ports {cfg_data}]
set_input_delay -max [expr $def_in_max] -clock clk_nios [get_ports {cfg_data}]
set_output_delay -min [expr $def_out_min] -clock clk_nios [get_ports {cfg_asdo cfg_cson cfg_dclk}]
set_output_delay -max [expr $def_out_max] -clock clk_nios [get_ports {cfg_asdo cfg_cson cfg_dclk}]

# False Paths

set_false_path -from [get_registers {*|alt_jtag_atlantic:*|jupdate}] -to [get_registers {*|alt_jtag_atlantic:*|jupdate1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|rdata[*]}] -to [get_registers {*|alt_jtag_atlantic*|td_shift[*]}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|read_req}] 
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|read_write}] -to [get_registers {*|alt_jtag_atlantic:*|read_write1*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|rvalid}] -to [get_registers {*|alt_jtag_atlantic*|td_shift[*]}]
set_false_path -from [get_registers {*|t_dav}] -to [get_registers {*|alt_jtag_atlantic:*|td_shift[0]*}]
set_false_path -from [get_registers {*|t_dav}] -to [get_registers {*|alt_jtag_atlantic:*|write_stalled*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|user_saw_rvalid}] -to [get_registers {*|alt_jtag_atlantic:*|rvalid0*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|wdata[*]}] -to [all_registers]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_stalled}] -to [get_registers {*|alt_jtag_atlantic:*|t_ena*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_stalled}] -to [get_registers {*|alt_jtag_atlantic:*|t_pause*}]
set_false_path -from [get_registers {*|alt_jtag_atlantic:*|write_valid}] 
set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]
set_false_path -from [get_keepers {*cpu_0:the_cpu_0|cpu_0_nios2_oci:the_cpu_0_nios2_oci|cpu_0_nios2_oci_break:the_cpu_0_nios2_oci_break|break_readreg*}] -to [get_keepers {*cpu_0:the_cpu_0|cpu_0_nios2_oci:the_cpu_0_nios2_oci|cpu_0_jtag_debug_module_wrapper:the_cpu_0_jtag_debug_module_wrapper|cpu_0_jtag_debug_module_tck:the_cpu_0_jtag_debug_module_tck|*sr*}]
set_false_path -from [get_keepers {*cpu_0:the_cpu_0|cpu_0_nios2_oci:the_cpu_0_nios2_oci|cpu_0_nios2_oci_debug:the_cpu_0_nios2_oci_debug|*resetlatch}] -to [get_keepers {*cpu_0:the_cpu_0|cpu_0_nios2_oci:the_cpu_0_nios2_oci|cpu_0_jtag_debug_module_wrapper:the_cpu_0_jtag_debug_module_wrapper|cpu_0_jtag_debug_module_tck:the_cpu_0_jtag_debug_module_tck|*sr[33]}]
set_false_path -from [get_keepers {*cpu_0:the_cpu_0|cpu_0_nios2_oci:the_cpu_0_nios2_oci|cpu_0_nios2_oci_debug:the_cpu_0_nios2_oci_debug|monitor_ready}] -to [get_keepers {*cpu_0:the_cpu_0|cpu_0_nios2_oci:the_cpu_0_nios2_oci|cpu_0_jtag_debug_module_wrapper:the_cpu_0_jtag_debug_module_wrapper|cpu_0_jtag_debug_module_tck:the_cpu_0_jtag_debug_module_tck|*sr[0]}]
set_false_path -from [get_keepers {*cpu_0:the_cpu_0|cpu_0_nios2_oci:the_cpu_0_nios2_oci|cpu_0_nios2_oci_debug:the_cpu_0_nios2_oci_debug|monitor_error}] -to [get_keepers {*cpu_0:the_cpu_0|cpu_0_nios2_oci:the_cpu_0_nios2_oci|cpu_0_jtag_debug_module_wrapper:the_cpu_0_jtag_debug_module_wrapper|cpu_0_jtag_debug_module_tck:the_cpu_0_jtag_debug_module_tck|*sr[34]}]
set_false_path -from [get_keepers {*cpu_0:the_cpu_0|cpu_0_nios2_oci:the_cpu_0_nios2_oci|cpu_0_nios2_ocimem:the_cpu_0_nios2_ocimem|*MonDReg*}] -to [get_keepers {*cpu_0:the_cpu_0|cpu_0_nios2_oci:the_cpu_0_nios2_oci|cpu_0_jtag_debug_module_wrapper:the_cpu_0_jtag_debug_module_wrapper|cpu_0_jtag_debug_module_tck:the_cpu_0_jtag_debug_module_tck|*sr*}]
set_false_path -from [get_keepers {*cpu_0:the_cpu_0|cpu_0_nios2_oci:the_cpu_0_nios2_oci|cpu_0_jtag_debug_module_wrapper:the_cpu_0_jtag_debug_module_wrapper|cpu_0_jtag_debug_module_tck:the_cpu_0_jtag_debug_module_tck|*sr*}] -to [get_keepers {*cpu_0:the_cpu_0|cpu_0_nios2_oci:the_cpu_0_nios2_oci|cpu_0_jtag_debug_module_wrapper:the_cpu_0_jtag_debug_module_wrapper|cpu_0_jtag_debug_module_sysclk:the_cpu_0_jtag_debug_module_sysclk|*jdo*}]
set_false_path -from [get_keepers {sld_hub:*|irf_reg*}] -to [get_keepers {*cpu_0:the_cpu_0|cpu_0_nios2_oci:the_cpu_0_nios2_oci|cpu_0_jtag_debug_module_wrapper:the_cpu_0_jtag_debug_module_wrapper|cpu_0_jtag_debug_module_sysclk:the_cpu_0_jtag_debug_module_sysclk|ir*}]
set_false_path -from [get_keepers {sld_hub:*|sld_shadow_jsm:shadow_jsm|state[1]}] -to [get_keepers {*cpu_0:the_cpu_0|cpu_0_nios2_oci:the_cpu_0_nios2_oci|cpu_0_nios2_oci_debug:the_cpu_0_nios2_oci_debug|monitor_go}]
set_false_path -from {ep4c_sopc_system:\BLK_NIOS:nios_inst|reset_pio:the_reset_pio|data_out[1]} -to {vr_r[1]}
set_false_path -from {ep4c_sopc_system:\BLK_NIOS:nios_inst|reset_pio:the_reset_pio|data_out[0]} -to {cr_r[1]}
#set_false_path -from {ep4c_sopc_system:\BLK_NIOS:nios_inst|cmd_fifo_if:the_cmd_fifo_if|cmd_fifo_if_avalon:cmd_fifo_if|wb_irq} -to {ep4c_sopc_system:\BLK_NIOS:nios_inst|cmd_fifo_if:the_cmd_fifo_if|cmd_fifo_if_avalon:cmd_fifo_if|irq_r[0]}
#set_false_path -from {ep4c_sopc_system:\BLK_NIOS:nios_inst|gfx_fifo_if:the_gfx_fifo_if|cmd_fifo_if_avalon:gfx_fifo_if|wb_irq} -to {ep4c_sopc_system:\BLK_NIOS:nios_inst|gfx_fifo_if:the_gfx_fifo_if|cmd_fifo_if_avalon:gfx_fifo_if|irq_r[0]}
#set_false_path -from {ep4c_sopc_system:\BLK_NIOS:nios_inst|cmd_fifo_if:the_cmd_fifo_if|cmd_fifo_if_avalon:cmd_fifo_if|wb_irq} -to {ep4c_sopc_system:\BLK_NIOS:nios_inst|cmd_fifo_if:the_cmd_fifo_if|cmd_fifo_if_avalon:cmd_fifo_if|irq_r[0]}
set_false_path -from {ep4c_sopc_system:\BLK_NIOS:nios_inst|version_pio:the_version_pio|data_out[*]} -to {\GEN_MIXER_BUS:BLK_MIXER_BUS:reg_dat_o[*]};

# VEB FIFO interrupt set, clr crossing clock domains
set_false_path -from {ep4c_sopc_system:\BLK_NIOS:nios_inst|cmd_fifo_if:*|nios_irq_set} -to {ep4c_sopc_system:\BLK_NIOS:nios_inst|cmd_fifo_if:*|set_r[0]}
set_false_path -from {ep4c_sopc_system:\BLK_NIOS:nios_inst|gfx_fifo_if:*|nios_irq_set} -to {ep4c_sopc_system:\BLK_NIOS:nios_inst|gfx_fifo_if:*|set_r[0]}
set_false_path -from {ep4c_sopc_system:\BLK_NIOS:nios_inst|cmd_fifo_if:*|wb_irq_clr} -to {ep4c_sopc_system:\BLK_NIOS:nios_inst|cmd_fifo_if:*|irq_clr_r[0]}
set_false_path -from {ep4c_sopc_system:\BLK_NIOS:nios_inst|gfx_fifo_if:*|wb_irq_clr} -to {ep4c_sopc_system:\BLK_NIOS:nios_inst|gfx_fifo_if:*|irq_clr_r[0]}
set_false_path -from {ep4c_sopc_system:\BLK_NIOS:nios_inst|cmd_fifo_if:*|busy} -to {ep4c_sopc_system:\BLK_NIOS:nios_inst|cmd_fifo_if:*|busy_r[0]}
set_false_path -from {ep4c_sopc_system:\BLK_NIOS:nios_inst|gfx_fifo_if:*|busy} -to {ep4c_sopc_system:\BLK_NIOS:nios_inst|gfx_fifo_if:*|busy_r[0]}
set_false_path -from {ep4c_sopc_system:\BLK_NIOS:nios_inst|cmd_fifo_if:*|wb_irq} -to {ep4c_sopc_system:\BLK_NIOS:nios_inst|cmd_fifo_if:*|irq_r[0]}
set_false_path -from {ep4c_sopc_system:\BLK_NIOS:nios_inst|gfx_fifo_if:*|wb_irq} -to {ep4c_sopc_system:\BLK_NIOS:nios_inst|gfx_fifo_if:*|irq_r[0]}

# LPC bus
set_false_path -from {irq_mask[*]} -to {altshift_taps:\BLK_INTERRUPTS:irq_mask_r*}
set_false_path -from {irq_ack[*]} -to {altshift_taps:\BLK_INTERRUPTS:irq_mask_r*}
set_false_path -from {\BLK_INTERRUPTS:irq_pending_nios[*]} -to {altshift_taps:\BLK_INTERRUPTS:veb_irqn_r*}
set_false_path -from {altshift_taps:\BLK_INTERRUPTS:irq_mask_r*} -to {altshift_taps:\BLK_INTERRUPTS:veb_irqn_r*}

# Video bus IRQ
set_false_path -from {vid_irq_n} -to {ep4c_sopc_system:\BLK_NIOS:nios_inst|*|data_in_d1}

# Debug signals to LEDs
set_false_path -from {*} -to {led_avi}
set_false_path -from {*} -to {led_dvi}
set_false_path -from {*} -to {led_lvds}
set_false_path -from {*} -to {led_avo}
set_false_path -from {*} -to {led_dvo}
set_false_path -from {*} -to {led_lvds}
set_false_path -from {*} -to {led_sdvo}
set_false_path -from {dvi_fpg_scl} -to {\BLK_DEBUG:*}

# DVI output reset
set_false_path -from {init} -to {vdo_rstn}

# Dedicated clock outputs from PLLs
set_false_path -to {uh_clkin0}
set_false_path -to {uh_clkin1}
set_false_path -to {vsi_extclk}
set_false_path -to {vid_clk(n)}


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

