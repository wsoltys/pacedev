## Generated SDC file "simple_top_level.sdc"

## Copyright (C) 1991-2012 Altera Corporation
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
## VERSION "Version 12.1 Build 243 01/31/2013 Service Pack 1 SJ Full Version"

## DATE    "Mon Mar 04 11:26:02 2013"

##
## DEVICE  "5CEBA4F23C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3 



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clock} -period 20.000 -waveform { 0.000 10.000 } [get_ports {clock}]

set_false_path -from [get_clocks {clock}] -to [get_clocks {inst|mem_if_ddr3_emif_0|pll0|pll_afi_clk}]
set_false_path -from [get_clocks {inst|mem_if_ddr3_emif_0|pll0|pll_afi_clk}] -to [get_clocks {clock}]
