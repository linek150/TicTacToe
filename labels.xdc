# Clock @ 125 MHz
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { clk }];

# Reset
set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports { rst }];

# Buttons
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports { B1 }];
set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33 } [get_ports { B4 }];
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { B3 }];
set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { B2 }];

# 7 segments - SEGMENTS
set_property -dict { PACKAGE_PIN V11   IOSTANDARD LVCMOS33 } [get_ports { segments[6] }]; # a
set_property -dict { PACKAGE_PIN U10   IOSTANDARD LVCMOS33 } [get_ports { segments[5] }]; # b
set_property -dict { PACKAGE_PIN Y12   IOSTANDARD LVCMOS33 } [get_ports { segments[4] }]; # c
set_property -dict { PACKAGE_PIN Y11   IOSTANDARD LVCMOS33 } [get_ports { segments[3] }]; # d
set_property -dict { PACKAGE_PIN F19   IOSTANDARD LVCMOS33 } [get_ports { segments[2] }]; # e
set_property -dict { PACKAGE_PIN B19   IOSTANDARD LVCMOS33 } [get_ports { segments[1] }]; # f
set_property -dict { PACKAGE_PIN C20   IOSTANDARD LVCMOS33 } [get_ports { segments[0] }]; # g

# 7 segments - SELECTOR
set_property -dict { PACKAGE_PIN B20   IOSTANDARD LVCMOS33 } [get_ports { selector[3] }]; # 0
set_property -dict { PACKAGE_PIN T5    IOSTANDARD LVCMOS33 } [get_ports { selector[2] }]; # 1
set_property -dict { PACKAGE_PIN A20   IOSTANDARD LVCMOS33 } [get_ports { selector[1] }]; # 2
set_property -dict { PACKAGE_PIN W11   IOSTANDARD LVCMOS33 } [get_ports { selector[0] }]; # 3

# LEDs
set_property -dict { PACKAGE_PIN U5    IOSTANDARD LVCMOS33 } [get_ports { leds[0] }];
set_property -dict { PACKAGE_PIN V5    IOSTANDARD LVCMOS33 } [get_ports { leds[2] }];
set_property -dict { PACKAGE_PIN V6    IOSTANDARD LVCMOS33 } [get_ports { leds[4] }];
set_property -dict { PACKAGE_PIN U7    IOSTANDARD LVCMOS33 } [get_ports { leds[6] }];
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { leds[1] }];
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { leds[3] }];
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { leds[5] }];
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { leds[7] }];

#speed and mode
set_property -dict { PACKAGE_PIN V7    IOSTANDARD LVCMOS33 } [get_ports { speed }];
set_property -dict { PACKAGE_PIN U8    IOSTANDARD LVCMOS33 } [get_ports { mode[0] }];
set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33 } [get_ports { mode[1] }];
