# Generate Clock 
create_clock -period 40.000 -name clk -waveform {0.000 20.000} [get_ports {clk}]

# Set Gate Outputs
set_property -dict { PACKAGE_PIN F19   IOSTANDARD LVCMOS33 } [get_ports gate_u]; 
set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports gate_u_l]; 
set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33 } [get_ports gate_v]; 
set_property -dict { PACKAGE_PIN W10   IOSTANDARD LVCMOS33 } [get_ports gate_v_l]; 
set_property -dict { PACKAGE_PIN B20   IOSTANDARD LVCMOS33 } [get_ports gate_w]; 
set_property -dict { PACKAGE_PIN W8    IOSTANDARD LVCMOS33 } [get_ports gate_w_l]; 

# Other Inputs
set_property -dict { PACKAGE_PIN V6    IOSTANDARD LVCMOS33 } [get_ports reset_n]; 
