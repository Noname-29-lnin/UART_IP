## Generated SDC file "fifo.out.sdc"

## Copyright (C) 2025  Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and any partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, the Altera Quartus Prime License Agreement,
## the Altera IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Altera and sold by Altera or its authorized distributors.  Please
## refer to the Altera Software License Subscription Agreements 
## on the Quartus Prime software download page.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 24.1std.0 Build 1077 03/04/2025 SC Lite Edition"

## DATE    "Tue Jun 17 22:24:19 2025"

##
## DEVICE  "10CL120ZF484I8G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {50Mhz} -period 20.000 -waveform { 0.000 10.000 } [get_ports {i_clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {i_data[0]}]
set_input_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {i_data[1]}]
set_input_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {i_data[2]}]
set_input_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {i_data[3]}]
set_input_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {i_data[4]}]
set_input_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {i_data[5]}]
set_input_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {i_data[6]}]
set_input_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {i_data[7]}]
set_input_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {i_en_rd}]
set_input_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {i_en_wr}]
set_input_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {i_rst_n}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {o_data[0]}]
set_output_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {o_data[1]}]
set_output_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {o_data[2]}]
set_output_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {o_data[3]}]
set_output_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {o_data[4]}]
set_output_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {o_data[5]}]
set_output_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {o_data[6]}]
set_output_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {o_data[7]}]
set_output_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {o_fifo_empty}]
set_output_delay -add_delay  -clock [get_clocks {50Mhz}]  0.500 [get_ports {o_fifo_full}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



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

