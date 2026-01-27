create_clock -period 10.000 -name Clk -waveform {0.000 5.000} [get_ports clk]

set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
