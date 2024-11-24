set_property -dict { PACKAGE_PIN R2    IOSTANDARD SSTL135 } [get_ports { cpu_clock }]; 
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5.000}  [get_ports { cpu_clock }];

set_property -dict { PACKAGE_PIN R12   IOSTANDARD LVCMOS33 } [get_ports { uart_rxd_out }]; #IO_25_14 Sch=uart_rxd_out
#set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { uart_txd_in }]; #IO_L24N_T3_A00_D16_14 Sch=uart_txd_in

#set_property -dict { PACKAGE_PIN H14   IOSTANDARD LVCMOS33 } [get_ports { sw0 }]; #IO_L20N_T3_A19_15 Sch=sw[0]
#set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { btn0 }]; #IO_L18N_T2_A23_15 Sch=btn[0]
