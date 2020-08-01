# 时钟约束50MHz
set_property -dict { PACKAGE_PIN H4 IOSTANDARD LVCMOS33 } [get_ports {clk}]; 
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports {clk}];

# CLOCK
#set_property IOSTANDARD LVCMOS33 [get_ports clk]
#set_property PACKAGE_PIN H4 [get_ports clk]

# rst  button  One
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN C3 [get_ports rst]

# over  led
set_property IOSTANDARD LVCMOS33 [get_ports over]
set_property PACKAGE_PIN P13 [get_ports over]

#succ  led
set_property IOSTANDARD LVCMOS33 [get_ports succ]
set_property PACKAGE_PIN P12 [get_ports succ]

# CPU停住指示引脚
set_property IOSTANDARD LVCMOS33 [get_ports halted_ind]
set_property PACKAGE_PIN L12 [get_ports halted_ind]

# 串口下载使能引脚
set_property IOSTANDARD LVCMOS33 [get_ports uart_debug_pin]
set_property PACKAGE_PIN A12 [get_ports uart_debug_pin]

# 串口发�?�引�?
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx_pin]
set_property PACKAGE_PIN C12 [get_ports uart_tx_pin]

# 串口接收引脚
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx_pin]
set_property PACKAGE_PIN A10 [get_ports uart_rx_pin]

# GPIO0引脚
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[0]}]
set_property PACKAGE_PIN B6 [get_ports {gpio[0]}]

# GPIO1引脚
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[1]}]
set_property PACKAGE_PIN D3 [get_ports {gpio[1]}]

# JTAG TCK引脚
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TCK]
set_property PACKAGE_PIN A2 [get_ports jtag_TCK]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_TCK_IBUF]
#create_clock -name jtag_clk_pin -period 300 [get_ports {jtag_TCK}];

# JTAG TMS引脚
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TMS]
set_property PACKAGE_PIN H2 [get_ports jtag_TMS]

# JTAG TDI引脚
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TDI]
set_property PACKAGE_PIN L5  [get_ports jtag_TDI]

# JTAG TDO引脚
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TDO]
set_property PACKAGE_PIN H13 [get_ports jtag_TDO]

# SPI MISO引脚
#set_property IOSTANDARD LVCMOS33 [get_ports spi_miso]
#set_property PACKAGE_PIN P1 [get_ports spi_miso]

# SPI MOSI引脚
#set_property IOSTANDARD LVCMOS33 [get_ports spi_mosi]
#set_property PACKAGE_PIN N1 [get_ports spi_mosi]

# SPI SS引脚
#set_property IOSTANDARD LVCMOS33 [get_ports spi_ss]
#set_property PACKAGE_PIN M5 [get_ports spi_ss]

# SPI CLK引脚
#set_property IOSTANDARD LVCMOS33 [get_ports spi_clk]
#
#set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]  
#set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
