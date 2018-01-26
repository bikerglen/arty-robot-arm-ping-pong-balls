set_property CFGBVS VCCO [current_design];
set_property CONFIG_VOLTAGE 3.3 [current_design];

set_property PACKAGE_PIN E3 [get_ports clk100_in];
set_property IOSTANDARD LVCMOS33 [get_ports clk100_in];

set_property PACKAGE_PIN C2 [get_ports arst_n];
set_property IOSTANDARD LVCMOS33 [get_ports arst_n];

set_property PACKAGE_PIN E1 [get_ports ledHeartbeat];   # RGB 0 - BLUE
set_property IOSTANDARD LVCMOS33 [get_ports ledHeartbeat];

set_property PACKAGE_PIN A9 [get_ports uartRxd];
set_property IOSTANDARD LVCMOS33 [get_ports uartRxd];

set_property PACKAGE_PIN D10 [get_ports uartTxd];
set_property IOSTANDARD LVCMOS33 [get_ports uartTxd];

set_property PACKAGE_PIN G13 [get_ports mDir[5]];       # PMOD 1 - PIN 1
set_property IOSTANDARD LVCMOS33 [get_ports mDir[5]];

set_property PACKAGE_PIN D13 [get_ports mStep[5]];      # PMOD 1 - PIN 7
set_property IOSTANDARD LVCMOS33 [get_ports mStep[5]];

set_property PACKAGE_PIN B11 [get_ports mDir[4]];       # PMOD 1 - PIN 2
set_property IOSTANDARD LVCMOS33 [get_ports mDir[4]];

set_property PACKAGE_PIN B18 [get_ports mStep[4]];      # PMOD 1 - PIN 8
set_property IOSTANDARD LVCMOS33 [get_ports mStep[4]];

set_property PACKAGE_PIN A11 [get_ports mDir[3]];       # PMOD 1 - PIN 3
set_property IOSTANDARD LVCMOS33 [get_ports mDir[3]];

set_property PACKAGE_PIN A18 [get_ports mStep[3]];      # PMOD 1 - PIN 9
set_property IOSTANDARD LVCMOS33 [get_ports mStep[3]];

set_property PACKAGE_PIN E15 [get_ports mDir[2]];       # PMOD 2 - PIN 1
set_property IOSTANDARD LVCMOS33 [get_ports mDir[2]];

set_property PACKAGE_PIN J17 [get_ports mStep[2]];      # PMOD 2 - PIN 7
set_property IOSTANDARD LVCMOS33 [get_ports mStep[2]];

set_property PACKAGE_PIN E16 [get_ports mDir[1]];       # PMOD 2 - PIN 2
set_property IOSTANDARD LVCMOS33 [get_ports mDir[1]];   

set_property PACKAGE_PIN J18 [get_ports mStep[1]];      # PMOD 2 - PIN 8
set_property IOSTANDARD LVCMOS33 [get_ports mStep[1]];  

set_property PACKAGE_PIN D15 [get_ports mDir[0]];       # PMOD 2 - PIN 3
set_property IOSTANDARD LVCMOS33 [get_ports mDir[0]];

set_property PACKAGE_PIN K15 [get_ports mStep[0]];      # PMOD 2 - PIN 9
set_property IOSTANDARD LVCMOS33 [get_ports mStep[0]];

set_property PACKAGE_PIN H6 [get_ports {LED[7]}];       # RGB 3 - GREEN
set_property IOSTANDARD LVCMOS33 [get_ports {LED[7]}]; 

set_property PACKAGE_PIN K1 [get_ports {LED[6]}];       # RGB 3 - RED
set_property IOSTANDARD LVCMOS33 [get_ports {LED[6]}];

set_property PACKAGE_PIN J2 [get_ports {LED[5]}];       # RGB 2 - GREEN
set_property IOSTANDARD LVCMOS33 [get_ports {LED[5]}];

set_property PACKAGE_PIN J3 [get_ports {LED[4]}];       # RGB 2 - RED
set_property IOSTANDARD LVCMOS33 [get_ports {LED[4]}]; 

set_property PACKAGE_PIN J4 [get_ports {LED[3]}];       # RGB 1 - GREEN
set_property IOSTANDARD LVCMOS33 [get_ports {LED[3]}];

set_property PACKAGE_PIN G3 [get_ports {LED[2]}];       # RGB 1 - RED
set_property IOSTANDARD LVCMOS33 [get_ports {LED[2]}];

set_property PACKAGE_PIN F6 [get_ports {LED[1]}];       # RGB 0 - GREEN
set_property IOSTANDARD LVCMOS33 [get_ports {LED[1]}];

set_property PACKAGE_PIN G6 [get_ports {LED[0]}];       # RGB 0 - RED
set_property IOSTANDARD LVCMOS33 [get_ports {LED[0]}]; 

set_property PACKAGE_PIN U12 [get_ports {gpout[0]}];    # PMOD 3 - PIN 1     
set_property IOSTANDARD LVCMOS33 [get_ports {gpout[0]}]; 

set_property PACKAGE_PIN V12 [get_ports {gpout[1]}];    # PMOD 3 - PIN 2
set_property IOSTANDARD LVCMOS33 [get_ports {gpout[1]}]; 

set_property PACKAGE_PIN V10 [get_ports {gpout[2]}];    # PMOD 3 - PIN 3
set_property IOSTANDARD LVCMOS33 [get_ports {gpout[2]}]; 

set_property PACKAGE_PIN V11 [get_ports {gpout[3]}];    # PMOD 3 - PIN 4
set_property IOSTANDARD LVCMOS33 [get_ports {gpout[3]}];  

set_property PACKAGE_PIN D4 [get_ports {ps3in}];        # PMOD 4 - PIN 1     
set_property IOSTANDARD LVCMOS33 [get_ports {ps3in}];  
