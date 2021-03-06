###########################################################################
#
# Generated by : Version 9.1 Build 350 03/24/2010 Service Pack 2 SJ Full Version
#
# Project      : coco1
# Revision     : coco1
#
# Date         : Mon Nov 29 17:31:06 +1100 2010
#
###########################################################################
 
# SD card timings
# 25MHz (default), 50MHz (high-speed)
set sd_period 20.0
# 5.0 ns (default), 6.0 ns (high-speed)
set sd_tsu_min 5.0
# 5.0 ns (default), 2.0 ns (high-speed)
set sd_th_min 2.0
set sd_tco_min 2.5
set sd_tco_max 14.0

# SD card board trace delays relative to clock trace
set sd_data_delay_max 0.500
set sd_data_delay_min -0.500
 
#
# ------------------------------------------
#
# Create generated clocks based on PLLs
derive_pll_clocks -use_tan_name
#
# ------------------------------------------


# Original Clock Setting Name: clock_50
create_clock -period "20.000 ns" \
             -name {clock_50} {clock_50}
# ---------------------------------------------


# Original Clock Setting Name: clock_27
create_clock -period "37.037 ns" \
             -name {clock_27} {clock_27}
# ---------------------------------------------

# ---------------------------------------------

# ** Clock Latency
#    -------------

# ** Clock Uncertainty
#    -----------------

# ** Multicycles
#    -----------
# ** Cuts
#    ----

# ** Input/Output Delays
#    -------------------

# SD card input min and max delays
set_input_delay -clock sd_clk -max [expr $sd_tco_max + $sd_data_delay_max] [get_ports {sd_dat sd_cmd}]
set_input_delay -clock sd_clk -min [expr $sd_tco_min + $sd_data_delay_min] [get_ports {sd_dat sd_cmd}]

# SD card output min and max delays
set_output_delay -clock sd_clk -max [expr $sd_data_delay_max + $sd_tsu_min] [get_ports {sd_dat sd_cmd}]
set_output_delay -clock sd_clk -min [expr $sd_data_delay_min - $sd_th_min] [get_ports {sd_dat sd_cmd}]

# ** Tpd requirements
#    ----------------

# ** Setup/Hold Relationships
#    ------------------------

# ** Tsu/Th requirements
#    -------------------


# ** Tco/MinTco requirements
#    -----------------------

#
# Entity Specific Timing Assignments found in
# the Timing Analyzer Settings report panel
#


# ---------------------------------------------
# The following clock group is added to try to 
# match the behavior of:
#   CUT_OFF_PATHS_BETWEEN_CLOCK_DOMAINS = ON
# ---------------------------------------------

set_clock_groups -asynchronous \
                 -group { \
                       pll:\BLK_CLOCKING:pll_27_inst|altpll:altpll_component|_clk0 \
                       clock_27 \
                        } \
                 -group { \
                       custom_io:\BLK_CUSTOM_IO:custom_io_inst|sd_pll:\GEN_IDE:sd_pll_inst|altpll:altpll_component|_clk1 \
                       pll:\BLK_CLOCKING:GEN_PLL:pll_50_inst|altpll:altpll_component|_clk0 \
                       pll:\BLK_CLOCKING:GEN_PLL:pll_50_inst|altpll:altpll_component|_clk1 \
                       clock_50 \
                        } \

# ---------------------------------------------

