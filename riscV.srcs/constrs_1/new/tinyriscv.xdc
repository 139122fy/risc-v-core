# ʱ��Լ��50MHz
set_property -dict { PACKAGE_PIN H4 IOSTANDARD LVCMOS33 } [get_ports {clk}]; 
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports {clk}];



# ��λ����
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN C3 [get_ports rst]

# ����ִ�����ָʾ����
set_property IOSTANDARD LVCMOS33 [get_ports over]
set_property PACKAGE_PIN P13 [get_ports over]

#����ִ�гɹ�ָʾ����
set_property IOSTANDARD LVCMOS33 [get_ports succ]
set_property PACKAGE_PIN P12 [get_ports succ]

# CPUͣסָʾ����
set_property IOSTANDARD LVCMOS33 [get_ports halted_ind]
set_property PACKAGE_PIN L12 [get_ports halted_ind]

# ��������ʹ������
set_property IOSTANDARD LVCMOS33 [get_ports uart_debug_pin]
set_property PACKAGE_PIN A12 [get_ports uart_debug_pin]

# ���ڷ�������
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx_pin]
set_property PACKAGE_PIN C12 [get_ports uart_tx_pin]

# ���ڽ�������
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx_pin]
set_property PACKAGE_PIN A10 [get_ports uart_rx_pin]

# GPIO0����
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[0]}]
set_property PACKAGE_PIN N14 [get_ports {gpio[0]}]

# GPIO1����
set_property IOSTANDARD LVCMOS33 [get_ports {gpio[1]}]
set_property PACKAGE_PIN M14 [get_ports {gpio[1]}]

# JTAG TCK����
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TCK]
set_property PACKAGE_PIN A2 [get_ports jtag_TCK]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_TCK_IBUF]


# JTAG TMS����
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TMS]
set_property PACKAGE_PIN H2 [get_ports jtag_TMS]

# JTAG TDI����
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TDI]
set_property PACKAGE_PIN L5  [get_ports jtag_TDI]

# JTAG TDO����
set_property IOSTANDARD LVCMOS33 [get_ports jtag_TDO]
set_property PACKAGE_PIN H13 [get_ports jtag_TDO]

