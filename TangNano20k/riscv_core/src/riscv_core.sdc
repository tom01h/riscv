//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.8.11 Education
//Created Time: 2023-06-21 08:08:20
create_clock -name clk_in -period 37 -waveform {0 18.5} [get_ports {clk_i}]
create_generated_clock -name pll_clk -source [get_ports {clk_i}] -master_clock clk_in -multiply_by 2 -add [get_pins {RPLL/rpll_inst/CLKOUT}]
report_timing -setup -from_clock [get_clocks {pll_clk}] -to_clock [get_clocks {pll_clk}] -max_paths 25 -max_common_paths 1
report_timing -hold -from_clock [get_clocks {pll_clk}] -to_clock [get_clocks {pll_clk}] -max_paths 25 -max_common_paths 1
report_timing -recovery -from_clock [get_clocks {pll_clk}] -to_clock [get_clocks {pll_clk}] -max_paths 25 -max_common_paths 1
report_timing -removal -from_clock [get_clocks {pll_clk}] -to_clock [get_clocks {pll_clk}] -max_paths 25 -max_common_paths 1
