####################################################################################
#
#  SKK  06-MAR-2018  Initial Version Generated
#
####################################################################################

####################################################################################
#BANK 0
####################################################################################

####################################################################################
#BANK 13
####################################################################################

set_property IOSTANDARD LVCMOS25 [get_ports FPGA_HBLED]
set_property PACKAGE_PIN L21 [get_ports FPGA_HBLED]
set_property IOSTANDARD LVCMOS25 [get_ports FPGA_GENLED]
set_property PACKAGE_PIN AB1 [get_ports FPGA_GENLED]


set_property PACKAGE_PIN T20 [get_ports {PCB_REV[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {PCB_REV[0]}]
set_property PULLDOWN true [get_ports {PCB_REV[0]}]

set_property PACKAGE_PIN T18 [get_ports {PCB_REV[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {PCB_REV[1]}]
set_property PULLDOWN true [get_ports {PCB_REV[1]}]

set_property PACKAGE_PIN W19 [get_ports {PCB_REV[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {PCB_REV[2]}]
set_property PULLDOWN true [get_ports {PCB_REV[2]}]

#set_property PACKAGE_PIN AH28 [get_ports extTrigOutput]
#set_property IOSTANDARD LVCMOS25 [get_ports extTrigOutput]

set_property IOSTANDARD LVCMOS33 [get_ports {spi_0_ss_io[0]}]
set_property PACKAGE_PIN T19 [get_ports {spi_0_ss_io[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {spi_0_ss_io[1]}]
#set_property PACKAGE_PIN V24 [get_ports {spi_0_ss_io[1]}]

#set_property IOSTANDARD LVCMOS33 [get_ports mig_sys_rst]
#set_property PACKAGE_PIN Y26 [get_ports mig_sys_rst]
#set_property PULLUP true [get_ports mig_sys_rst]

#set_property IOSTANDARD LVCMOS33 [get_ports EEPROM_WP]
#set_property PACKAGE_PIN W25 [get_ports EEPROM_WP]
#set_property IOSTANDARD LVCMOS33 [get_ports PS_POS1V8_SYNC]
#set_property PACKAGE_PIN AB7 [get_ports PS_POS1V8_SYNC]
#set_property IOSTANDARD LVCMOS33 [get_ports {MOD_LED[2]}]
#set_property PACKAGE_PIN Y28 [get_ports {MOD_LED[2]}]

#??
#set_property IOSTANDARD LVCMOS33 [get_ports UB_RST]
#set_property PACKAGE_PIN L4 [get_ports UB_RST]
#set_property IOSTANDARD LVCMOS33 [get_ports UB_RX]
#set_property PACKAGE_PIN V32 [get_ports UB_RX]
set_property IOSTANDARD LVCMOS33 [get_ports UB_TX]
set_property PACKAGE_PIN M18 [get_ports UB_TX]
#set_property IOSTANDARD LVCMOS33 [get_ports FP_EEPROM_CS]
#set_property PACKAGE_PIN W34 [get_ports FP_EEPROM_CS]


#set_property IOSTANDARD LVCMOS33 [get_ports SI5338C_INTR]
#set_property PACKAGE_PIN V33 [get_ports SI5338C_INTR]
#set_property IOSTANDARD LVCMOS33 [get_ports FP_EEPROM_DOUT]
#set_property PULLUP true [get_ports FP_EEPROM_DOUT]
#set_property PACKAGE_PIN V34 [get_ports FP_EEPROM_DOUT]
#set_property IOSTANDARD LVCMOS33 [get_ports TEDS_RX]
#set_property PACKAGE_PIN Y32 [get_ports TEDS_RX]
#set_property IOSTANDARD LVCMOS33 [get_ports {MOD_LED[0]}]
#set_property PACKAGE_PIN Y33 [get_ports {MOD_LED[0]}]
#set_property DIFF_TERM TRUE [get_ports BACQ_CLK_P]
#set_property IOSTANDARD LVCMOS33 [get_ports BACQ_CLK_P]
#set_property PACKAGE_PIN Y30 [get_ports BACQ_CLK_P]

set_property DIFF_TERM FALSE [get_ports acqClkIn_N]
set_property IOSTANDARD LVDS_25 [get_ports acqClkIn_N]
set_property PACKAGE_PIN U5 [get_ports acqClkIn_N]

set_property IOSTANDARD LVCMOS33 [get_ports pxiStar]
set_property PACKAGE_PIN AA6 [get_ports pxiStar]

set_property IOSTANDARD LVCMOS33 [get_ports {pxiTrigBus[0]}]
set_property PACKAGE_PIN V7 [get_ports {pxiTrigBus[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pxiTrigBus[1]}]
set_property PACKAGE_PIN W5 [get_ports {pxiTrigBus[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pxiTrigBus[2]}]
set_property PACKAGE_PIN AB8 [get_ports {pxiTrigBus[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pxiTrigBus[3]}]
set_property PACKAGE_PIN AA3 [get_ports {pxiTrigBus[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pxiTrigBus[4]}]
set_property PACKAGE_PIN Y8 [get_ports {pxiTrigBus[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pxiTrigBus[5]}]
set_property PACKAGE_PIN Y6 [get_ports {pxiTrigBus[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pxiTrigBus[6]}]
set_property PACKAGE_PIN T1 [get_ports {pxiTrigBus[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {pxiTrigBus[7]}]
set_property PACKAGE_PIN Y2 [get_ports {pxiTrigBus[7]}]

set_property IOSTANDARD LVCMOS25 [get_ports {pxiTrigOEn_L[0]}]
set_property PACKAGE_PIN V8 [get_ports {pxiTrigOEn_L[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {pxiTrigOEn_L[1]}]
set_property PACKAGE_PIN W6 [get_ports {pxiTrigOEn_L[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {pxiTrigOEn_L[2]}]
set_property PACKAGE_PIN AA1 [get_ports {pxiTrigOEn_L[2]}]
set_property IOSTANDARD LVCMOS25 [get_ports {pxiTrigOEn_L[3]}]
set_property PACKAGE_PIN V2 [get_ports {pxiTrigOEn_L[3]}]
set_property IOSTANDARD LVCMOS25 [get_ports {pxiTrigOEn_L[4]}]
set_property PACKAGE_PIN W1 [get_ports {pxiTrigOEn_L[4]}]
set_property IOSTANDARD LVCMOS25 [get_ports {pxiTrigOEn_L[5]}]
set_property PACKAGE_PIN Y7 [get_ports {pxiTrigOEn_L[5]}]
set_property IOSTANDARD LVCMOS25 [get_ports {pxiTrigOEn_L[6]}]
set_property PACKAGE_PIN Y1 [get_ports {pxiTrigOEn_L[6]}]
set_property IOSTANDARD LVCMOS25 [get_ports {pxiTrigOEn_L[7]}]
set_property PACKAGE_PIN Y3 [get_ports {pxiTrigOEn_L[7]}]

#set_property IOSTANDARD LVCMOS33 [get_ports PXI_CLK10]
#set_property PACKAGE_PIN AB30 [get_ports PXI_CLK10]

#set_property IOSTANDARD LVCMOS33 [get_ports FP_SPI_SYNC_L]
#set_property PACKAGE_PIN AA32 [get_ports FP_SPI_SYNC_L]
#set_property IOSTANDARD LVCMOS33 [get_ports {MOD_LED[1]}]
#set_property PACKAGE_PIN AA33 [get_ports {MOD_LED[1]}]

#set_property IOSTANDARD LVCMOS33 [get_ports FP_SPI_RCLK]
#set_property PACKAGE_PIN AC31 [get_ports FP_SPI_RCLK]

#set_property IOSTANDARD LVCMOS33 [get_ports FP_SPI_SCLK]
#set_property PACKAGE_PIN AC32 [get_ports FP_SPI_SCLK]
#set_property IOSTANDARD LVCMOS33 [get_ports TEDS_TX]
#set_property PACKAGE_PIN AA34 [get_ports TEDS_TX]

#set_property IOSTANDARD LVCMOS33 [get_ports FP_ADG_SDO]
#set_property PACKAGE_PIN AB34 [get_ports FP_ADG_SDO]

#set_property IOSTANDARD LVCMOS33 [get_ports FP_SPI_SDI]
#set_property PACKAGE_PIN AC28 [get_ports FP_SPI_SDI]

#set_property IOSTANDARD LVCMOS33 [get_ports FP_595_SDO]
#set_property PACKAGE_PIN AC29 [get_ports FP_595_SDO]

#set_property IOSTANDARD LVCMOS15 [get_ports PIC_TO_FPGA_INT]
#set_property PACKAGE_PIN N32 [get_ports PIC_TO_FPGA_INT]
#set_property IOSTANDARD LVCMOS33 [get_ports FPGA_TO_PIC_INT]
#set_property PACKAGE_PIN AA28 [get_ports FPGA_TO_PIC_INT]

#set_property IOSTANDARD LVCMOS33 [get_ports spi_0_io0_io]
#set_property PACKAGE_PIN P22 [get_ports spi_0_io0_io]
#set_property IOSTANDARD LVCMOS33 [get_ports spi_0_io1_io]
#set_property PACKAGE_PIN R22 [get_ports spi_0_io1_io]
#set_property IOSTANDARD LVCMOS33 [get_ports spi_0_io2_io]
#set_property PACKAGE_PIN V26 [get_ports spi_0_io2_io]
#set_property IOSTANDARD LVCMOS33 [get_ports spi_0_io3_io]
#set_property PACKAGE_PIN V27 [get_ports spi_0_io3_io]

#set_property IOSTANDARD LVCMOS33 [get_ports {UART_txd[1]}]
#set_property PACKAGE_PIN AA34 [get_ports {UART_txd[1]}]

#set_property IOSTANDARD LVCMOS33 [get_ports {UART_rxd[1]}]
#set_property PACKAGE_PIN Y32 [get_ports {UART_rxd[1]}]

#set_property IOSTANDARD LVCMOS33 [get_ports {UART_txd[3]}]
#set_property PACKAGE_PIN V32 [get_ports {UART_txd[3]}]

#set_property IOSTANDARD LVCMOS33 [get_ports {UART_rxd[3]}]
#set_property PACKAGE_PIN W33 [get_ports {UART_rxd[3]}]

#set_property PACKAGE_PIN AC34 [get_ports si5338_scl]
#set_property IOSTANDARD LVCMOS33 [get_ports si5338_scl]

#set_property PACKAGE_PIN AC33 [get_ports si5338_sda]
#set_property IOSTANDARD LVCMOS33 [get_ports si5338_sda]

#set_property PACKAGE_PIN V33 [get_ports si5338_intr]
#set_property IOSTANDARD LVCMOS33 [get_ports si5338_intr]

#PS-POS12-SYNC bank 14
#set_property PACKAGE_PIN W28 [get_ports clock500KHzOut]
#set_property IOSTANDARD LVCMOS33 [get_ports clock500KHzOut]
#set_property DRIVE 4 [get_ports clock500KHzOut]
#set_property SLEW SLOW [get_ports clock500KHzOut]

set_property PACKAGE_PIN W29 [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst_n]
set_property PULLUP true [get_ports sys_rst_n]
set_false_path -from [get_ports sys_rst_n]

####################################################################################
#BANK 15
####################################################################################

set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[14]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_addr[14]}]
set_property PACKAGE_PIN A14 [get_ports {DDR3_addr[14]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[13]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_addr[13]}]
set_property PACKAGE_PIN A15 [get_ports {DDR3_addr[13]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[12]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_addr[12]}]
set_property PACKAGE_PIN D16 [get_ports {DDR3_addr[12]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[11]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_addr[11]}]
set_property PACKAGE_PIN D14 [get_ports {DDR3_addr[11]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[10]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_addr[10]}]
set_property PACKAGE_PIN B15 [get_ports {DDR3_addr[10]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[9]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_addr[9]}]
set_property PACKAGE_PIN B18 [get_ports {DDR3_addr[9]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[8]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_addr[8]}]
set_property PACKAGE_PIN A13 [get_ports {DDR3_addr[8]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[7]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_addr[7]}]
set_property PACKAGE_PIN B17 [get_ports {DDR3_addr[7]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[6]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_addr[6]}]
set_property PACKAGE_PIN C13 [get_ports {DDR3_addr[6]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[5]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_addr[5]}]
set_property PACKAGE_PIN D17 [get_ports {DDR3_addr[5]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[4]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_addr[4]}]
set_property PACKAGE_PIN F13 [get_ports {DDR3_addr[4]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[3]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_addr[3]}]
set_property PACKAGE_PIN C17 [get_ports {DDR3_addr[3]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[2]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_addr[2]}]
set_property PACKAGE_PIN E17 [get_ports {DDR3_addr[2]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[1]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_addr[1]}]
set_property PACKAGE_PIN E14 [get_ports {DDR3_addr[1]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_addr[0]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_addr[0]}]
set_property PACKAGE_PIN A16 [get_ports {DDR3_addr[0]}]



set_property IOSTANDARD SSTL15 [get_ports {DDR3_ba[2]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_ba[2]}]
set_property PACKAGE_PIN E16 [get_ports {DDR3_ba[2]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_ba[1]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_ba[1]}]
set_property PACKAGE_PIN E13 [get_ports {DDR3_ba[1]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_ba[0]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_ba[0]}]
set_property PACKAGE_PIN F16 [get_ports {DDR3_ba[0]}]



set_property IOSTANDARD DIFF_SSTL15 [get_ports {DDR3_ck_p[0]}]
set_property PACKAGE_PIN C14 [get_ports {DDR3_ck_p[0]}]
set_property IOSTANDARD DIFF_SSTL15 [get_ports {DDR3_ck_n[0]}]
set_property PACKAGE_PIN C15 [get_ports {DDR3_ck_n[0]}]

set_property IOSTANDARD SSTL15 [get_ports DDR3_ras_n]
set_property PACKAGE_PIN F14 [get_ports DDR3_ras_n]

set_property IOSTANDARD SSTL15 [get_ports DDR3_cas_n]
set_property PACKAGE_PIN D15 [get_ports DDR3_cas_n]

set_property IOSTANDARD SSTL15 [get_ports DDR3_we_n]
set_property PACKAGE_PIN B16 [get_ports DDR3_we_n]

set_property IOSTANDARD LVCMOS15 [get_ports DDR3_reset_n]
set_property PACKAGE_PIN F21 [get_ports DDR3_reset_n]

set_property IOSTANDARD SSTL15 [get_ports {DDR3_cke[0]}]
set_property PACKAGE_PIN F15 [get_ports {DDR3_cke[0]}]

set_property IOSTANDARD SSTL15 [get_ports {DDR3_odt[0]}]
set_property PACKAGE_PIN B13 [get_ports {DDR3_odt[0]}]

#set_property IOSTANDARD SSTL15 [get_ports {DDR3_cs_n[0]}]
#set_property PACKAGE_PIN L2 [get_ports {DDR3_cs_n[0]}]

set_property PACKAGE_PIN C19 [get_ports DDR3_CAL]
set_property IOSTANDARD LVCMOS15 [get_ports DDR3_CAL]



# Note that sys_clk clock period constraint is set in the MIG constraints file
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_n]
set_property PACKAGE_PIN H3 [get_ports sys_clk_n]


#set_property VCCAUX_IO NORMAL [get_ports PIC2FPGA_SPARE]
#set_property IOSTANDARD LVCMOS15 [get_ports PIC2FPGA_SPARE]
#set_property PACKAGE_PIN U29 [get_ports PIC2FPGA_SPARE]
#set_property VCCAUX_IO NORMAL [get_ports FPGA2PIC_SPARE]
#set_property IOSTANDARD LVCMOS15 [get_ports FPGA2PIC_SPARE]
#set_property PACKAGE_PIN U24 [get_ports FPGA2PIC_SPARE]
#set_property IOSTANDARD LVCMOS15 [get_ports BFPGA_SPARE3]
#set_property VCCAUX_IO NORMAL [get_ports BFPGA_SPARE3]
#set_property PACKAGE_PIN P25 [get_ports BFPGA_SPARE3]


#set_property VCCAUX_IO NORMAL [get_ports PIC_SPI_SDO]
#set_property IOSTANDARD LVCMOS15 [get_ports PIC_SPI_SDO]
#set_property PACKAGE_PIN T32 [get_ports PIC_SPI_SDO]
#set_property VCCAUX_IO NORMAL [get_ports PIC_SPI_SCK]
#set_property IOSTANDARD LVCMOS15 [get_ports PIC_SPI_SCK]
#set_property PACKAGE_PIN R32 [get_ports PIC_SPI_SCK]
#set_property IOSTANDARD LVCMOS15 [get_ports BGEN_IP1]
#set_property VCCAUX_IO NORMAL [get_ports BGEN_IP1]
#set_property PACKAGE_PIN N33 [get_ports BGEN_IP1]
#set_property VCCAUX_IO NORMAL [get_ports PIC_SPI_SDI]
#set_property IOSTANDARD LVCMOS15 [get_ports PIC_SPI_SDI]
#set_property PACKAGE_PIN T33 [get_ports PIC_SPI_SDI]
#set_property IOSTANDARD LVCMOS15 [get_ports BGEN_IP2]
#set_property VCCAUX_IO NORMAL [get_ports BGEN_IP2]
#set_property PACKAGE_PIN R33 [get_ports BGEN_IP2]
#set_property VCCAUX_IO NORMAL [get_ports rs232_uart_txd]
#set_property PACKAGE_PIN N34 [get_ports rs232_uart_txd]
#set_property VCCAUX_IO NORMAL [get_ports FPGA_TO_PIC_INT]
#set_property IOSTANDARD LVCMOS15 [get_ports BGEN_OP2]
#set_property VCCAUX_IO NORMAL [get_ports BGEN_OP2]
#set_property PACKAGE_PIN U34 [get_ports BGEN_OP2]
#set_property IOSTANDARD LVCMOS15 [get_ports BGEN_OP1]
#set_property VCCAUX_IO NORMAL [get_ports BGEN_OP1]
#set_property PACKAGE_PIN T34 [get_ports BGEN_OP1]
#set_property VCCAUX_IO NORMAL [get_ports rs232_uart_rxd]
#set_property PACKAGE_PIN P33 [get_ports rs232_uart_rxd]

# This used to be ROE, but for the RX0X24 version of the product it is a trigger input
#set_property PACKAGE_PIN U32 [get_ports extTrigInput]
#set_property IOSTANDARD LVCMOS15 [get_ports extTrigInput]

#set_property IOSTANDARD LVCMOS15 [get_ports FPGA2PIC_TXD]
#set_property PACKAGE_PIN P33 [get_ports FPGA2PIC_TXD]

#set_property IOSTANDARD LVCMOS15 [get_ports FPGA2PIC_RXD]
#set_property PACKAGE_PIN N34 [get_ports FPGA2PIC_RXD]

#set_property IOSTANDARD LVCMOS15 [get_ports reset]
#set_property PACKAGE_PIN M29 [get_ports reset]

set_property IOSTANDARD LVCMOS15 [get_ports TP1]
set_property PACKAGE_PIN T34 [get_ports TP1]

set_property IOSTANDARD LVCMOS15 [get_ports TP2]
set_property PACKAGE_PIN U34 [get_ports TP2]


####################################################################################
#BANK 16
####################################################################################

set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[0]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dq[0]}]
set_property PACKAGE_PIN C18 [get_ports {DDR3_dq[0]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[1]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dq[1]}]
set_property PACKAGE_PIN A18 [get_ports {DDR3_dq[1]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[2]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dq[2]}]
set_property PACKAGE_PIN B20 [get_ports {DDR3_dq[2]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[3]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dq[3]}]
set_property PACKAGE_PIN F19 [get_ports {DDR3_dq[3]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[4]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dq[4]}]
set_property PACKAGE_PIN A19 [get_ports {DDR3_dq[4]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[5]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dq[5]}]
set_property PACKAGE_PIN E19 [get_ports {DDR3_dq[5]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[6]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dq[6]}]
set_property PACKAGE_PIN A20 [get_ports {DDR3_dq[6]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[7]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dq[7]}]
set_property PACKAGE_PIN D19 [get_ports {DDR3_dq[7]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[8]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dq[8]}]
set_property PACKAGE_PIN D20 [get_ports {DDR3_dq[8]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[9]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dq[9]}]
set_property PACKAGE_PIN E21 [get_ports {DDR3_dq[9]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[10]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dq[10]}]
set_property PACKAGE_PIN G21 [get_ports {DDR3_dq[10]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[11]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dq[11]}]
set_property PACKAGE_PIN C22 [get_ports {DDR3_dq[11]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[12]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dq[12]}]
set_property PACKAGE_PIN G22 [get_ports {DDR3_dq[12]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[13]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dq[13]}]
set_property PACKAGE_PIN B22 [get_ports {DDR3_dq[13]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[14]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dq[14]}]
set_property PACKAGE_PIN D22 [get_ports {DDR3_dq[14]}]
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dq[15]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dq[15]}]
set_property PACKAGE_PIN E22 [get_ports {DDR3_dq[15]}]



# DDR3_LDM
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dm[0]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dm[0]}]
set_property PACKAGE_PIN F20 [get_ports {DDR3_dm[0]}]

# DDR3_UDM
set_property IOSTANDARD SSTL15 [get_ports {DDR3_dm[1]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dm[1]}]
set_property PACKAGE_PIN D21 [get_ports {DDR3_dm[1]}]

#DDR3_LDQS_P
set_property IOSTANDARD DIFF_SSTL15 [get_ports {DDR3_dqs_p[0]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dqs_p[0]}]
set_property PACKAGE_PIN F18 [get_ports {DDR3_dqs_p[0]}]

#DDR3_LDQS_N
set_property IOSTANDARD DIFF_SSTL15 [get_ports {DDR3_dqs_n[0]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dqs_n[0]}]
set_property PACKAGE_PIN E18 [get_ports {DDR3_dqs_n[0]}]

#DDR3_UDQS_P
set_property IOSTANDARD DIFF_SSTL15 [get_ports {DDR3_dqs_p[1]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dqs_p[1]}]
set_property PACKAGE_PIN B21 [get_ports {DDR3_dqs_p[1]}]

#DDR3_UDQS_N
set_property IOSTANDARD DIFF_SSTL15 [get_ports {DDR3_dqs_n[1]}]
#set_property VCCAUX_IO NORMAL [get_ports {DDR3_dqs_n[1]}]
set_property PACKAGE_PIN A21 [get_ports {DDR3_dqs_n[1]}]


####################################################################################
####################################################################################
#FMC1 Interface (BANK 12 & BANK 32)
####################################################################################

#FMC3_FPGACLK FMC 1 clock used? ##clock from SI5338
#set_property PACKAGE_PIN K19 [get_ports adcClk]
#set_property IOSTANDARD LVCMOS33 [get_ports adcClk]
#set_property PULLDOWN true [get_ports adcClk]
#create_clock -period 76.290 [get_ports adcClk]
# 76.29 is configured for 13.1Mhz ADC clock

#set_property IOSTANDARD LVCMOS33 [get_ports I2C_RST]
#I2C_RST
#set_property PACKAGE_PIN AL24 [get_ports I2C_RST]

#set_property IOSTANDARD LVCMOS33 [get_ports ADCRST]
#ADCRST
#set_property PACKAGE_PIN AN34 [get_ports ADCRST]

#set_property IOSTANDARD LVCMOS33 [get_ports G1_OCSC_int]
#G1_OCSC_int
#set_property PACKAGE_PIN AP34 [get_ports G1_OCSC_int]

#set_property IOSTANDARD LVCMOS33 [get_ports G2_OCSC_int]
#G2_OCSC_int
#set_property PACKAGE_PIN AK33 [get_ports G2_OCSC_int]

#set_property IOSTANDARD LVCMOS33 [get_ports G3_OCSC_int]
#G3_OCSC_int
#set_property PACKAGE_PIN AL33 [get_ports G3_OCSC_int]

#set_property PACKAGE_PIN AN7 [get_ports FPGA_I2C_CLK]
#FPGA_I2C_CLK
#set_property IOSTANDARD LVCMOS33 [get_ports FPGA_I2C_CLK]

#set_property PACKAGE_PIN AN6 [get_ports FPGA_I2C_DAT]
#FPGA_I2C_DAT
#set_property IOSTANDARD LVCMOS33 [get_ports FPGA_I2C_DAT]

#set_property PACKAGE_PIN AL9 [get_ports SPI0_SIMO_FMC]
##SPIO_SIMO_FMC
#set_property IOSTANDARD LVCMOS33 [get_ports SPI0_SIMO_FMC]

#set_property PACKAGE_PIN AN9 [get_ports SPI0_SOMI1_FMC]
##SPI0_SOMI1_FMC
#set_property IOSTANDARD LVCMOS33 [get_ports SPI0_SOMI1_FMC]

#set_property PACKAGE_PIN AP9 [get_ports SPI0_SOMI2_FMC]
##SPI0_SOMI2_FMC
#set_property IOSTANDARD LVCMOS33 [get_ports SPI0_SOMI2_FMC]

#set_property PACKAGE_PIN AM9 [get_ports SPI0_SOMI3_FMC]
##SPI0_SOMI3_FMC
#set_property IOSTANDARD LVCMOS33 [get_ports SPI0_SOMI3_FMC]

#set_property PACKAGE_PIN AK7 [get_ports SPI0_SCK_FMC]
##SPIO_CLK_FMC
#set_property IOSTANDARD LVCMOS33 [get_ports SPI0_SCK_FMC]

#set_property PACKAGE_PIN AL7 [get_ports {SPI0_SS_FMC[0]}]
##SPIO_CS1n_FMC
#set_property IOSTANDARD LVCMOS33 [get_ports {SPI0_SS_FMC[0]}]

#set_property PACKAGE_PIN AM11 [get_ports {SPI0_SS_FMC[1]}]
##SPIO_CS2n_FMC
#set_property IOSTANDARD LVCMOS33 [get_ports {SPI0_SS_FMC[1]}]

#set_property PACKAGE_PIN AN11 [get_ports {SPI0_SS_FMC[2]}]
##SPIO_CS3n_FMC
#set_property IOSTANDARD LVCMOS33 [get_ports {SPI0_SS_FMC[2]}]

#set_property PACKAGE_PIN AL34 [get_ports FPGA_TEDS_RXD]
##FPGA_TEDS_RXD
#set_property IOSTANDARD LVCMOS33 [get_ports FPGA_TEDS_RXD]

#set_property PACKAGE_PIN AM34 [get_ports FPGA_TEDS_TXD]
##FPGA_TEDS_TXD
#set_property IOSTANDARD LVCMOS33 [get_ports FPGA_TEDS_TXD]

#set_property PACKAGE_PIN AJ28 [get_ports VTHR_SCK]
##VTHR_SCK
#set_property IOSTANDARD LVCMOS33 [get_ports VTHR_SCK]

#set_property PACKAGE_PIN AK28 [get_ports VTHR_CS]
##VTHR_CS
#set_property IOSTANDARD LVCMOS33 [get_ports VTHR_CS]

#set_property PACKAGE_PIN AJ8 [get_ports VTHR_SDI]
##VTHR_SDI
#set_property IOSTANDARD LVCMOS33 [get_ports VTHR_SDI]

#set_property PACKAGE_PIN AK8 [get_ports VTHR_SDO]
##VTHR_SDO
#set_property IOSTANDARD LVCMOS33 [get_ports VTHR_SDO]

#set_property PACKAGE_PIN AL10 [get_ports CH1_AC_RLYON]
##CH1_AC_RLYON
#set_property IOSTANDARD LVCMOS33 [get_ports CH1_AC_RLYON]

#set_property PACKAGE_PIN AM10 [get_ports CH1_25V_RLYON]
##CH1_25V_RLYON
#set_property IOSTANDARD LVCMOS33 [get_ports CH1_25V_RLYON]

#set_property PACKAGE_PIN AN8 [get_ports CH2_AC_RLYON]
##CH2_AC_RLYON
#set_property IOSTANDARD LVCMOS33 [get_ports CH2_AC_RLYON]

#set_property PACKAGE_PIN AM7 [get_ports CH2_25V_RLYON]
##CH2_25V_RLYON
#set_property IOSTANDARD LVCMOS33 [get_ports CH2_25V_RLYON]

#set_property PACKAGE_PIN AP11 [get_ports CH1_LVL_COMP_OUT]
##CH1_LVL_COMP_OUT
#set_property IOSTANDARD LVCMOS33 [get_ports CH1_LVL_COMP_OUT]

#set_property PACKAGE_PIN AP10 [get_ports CH1_HYST_COMP_OUT]
##CH1_HYST_COMP_OUT
#set_property IOSTANDARD LVCMOS33 [get_ports CH1_HYST_COMP_OUT]

#set_property PACKAGE_PIN AP8 [get_ports CH2_LVL_COMP_OUT]
##CH2_LVL_COMP_OUT
#set_property IOSTANDARD LVCMOS33 [get_ports CH2_LVL_COMP_OUT]

#set_property PACKAGE_PIN AM6 [get_ports CH2_HYST_COMP_OUT]
##CH2_HYST_COMP_OUT
#set_property IOSTANDARD LVCMOS33 [get_ports CH2_HYST_COMP_OUT]

set_property PACKAGE_PIN K22 [get_ports SMPS_Clk1]
#SMPS_Clk1
set_property IOSTANDARD LVCMOS33 [get_ports SMPS_Clk1]

set_property PACKAGE_PIN H17 [get_ports SMPS_Clk2]
#SMPS_Clk2
set_property IOSTANDARD LVCMOS33 [get_ports SMPS_Clk2]

#set_property PACKAGE_PIN AL25 [get_ports SMPS_Clk3]
##SMPS_Clk3
#set_property IOSTANDARD LVCMOS33 [get_ports SMPS_Clk3]


set_property PACKAGE_PIN L14 [get_ports fpga_power_en]
set_property IOSTANDARD LVCMOS33 [get_ports fpga_power_en]

####################################################################################
####################################################################################
#FMC2 Interface (For Debug)
####################################################################################

####################################################################################
#
# Transceiver instance placement.  This constraint selects the
# transceivers to be used, which also dictates the pinout for the
# transmit and receive differential pairs.  Please refer to the
# Virtex-7 GT Transceiver User Guide (UG) for more information.
#

# PCIe Lane 0
set_property LOC GTPE2_CHANNEL_X0Y0 [get_cells {mb_subsystem_i/axi_pcie_0/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtp_channel.gtpe2_channel_i}]

# GTP Common Placement
#set_property LOC GTPE2_COMMON_X0Y1 [get_cells {mb_subsystem_i/axi_pcie_0/U0/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_lane[0].pipe_quad.pipe_common.qpll_wrapper_i/gtp_common.gtpe2_common_i}]
set_property LOC GTPE2_COMMON_X0Y0 [get_cells {mb_subsystem_i/axi_pcie_0/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_lane[0].pipe_quad.gt_common_enabled.gt_common_int.gt_common_i/qpll_wrapper_i/gtp_common.gtpe2_common_i}]

#
# PCI Express Block placement. This constraint selects the PCI Express
# Block to be used.
#

set_property LOC PCIE_X0Y0 [get_cells mb_subsystem_i/axi_pcie_0/inst/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.pcie_top_i/pcie_7x_i/pcie_block_i]

#
# BlockRAM placement
#

set_property LOC RAMB36_X1Y45 [get_cells {mb_subsystem_i/axi_pcie_0/U0/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.pcie_top_i/pcie_7x_i/pcie_bram_top/pcie_brams_rx/brams[0].ram/use_tdp.ramb36/genblk5_0.bram36_tdp_bl.bram36_tdp_bl}]
set_property LOC RAMB36_X1Y44 [get_cells {mb_subsystem_i/axi_pcie_0/U0/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.pcie_top_i/pcie_7x_i/pcie_bram_top/pcie_brams_rx/brams[1].ram/use_tdp.ramb36/genblk5_0.bram36_tdp_bl.bram36_tdp_bl}]
set_property LOC RAMB36_X1Y42 [get_cells {mb_subsystem_i/axi_pcie_0/U0/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.pcie_top_i/pcie_7x_i/pcie_bram_top/pcie_brams_tx/brams[0].ram/use_tdp.ramb36/genblk5_0.bram36_tdp_bl.bram36_tdp_bl}]
set_property LOC RAMB36_X1Y41 [get_cells {mb_subsystem_i/axi_pcie_0/U0/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.pcie_top_i/pcie_7x_i/pcie_bram_top/pcie_brams_tx/brams[1].ram/use_tdp.ramb36/genblk5_0.bram36_tdp_bl.bram36_tdp_bl}]

###############################################################################
# Timing Constraints
###############################################################################
#
create_clock -period 10.000 [get_pins {mb_subsystem_i/axi_pcie_0/U0/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_lane[0].gt_wrapper_i/gtp_channel.gtpe2_channel_i/TXOUTCLK}]
#

#
set_false_path -to [get_pins mb_subsystem_i/axi_pcie_0/U0/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S*]
#
#
set_case_analysis 1 [get_pins mb_subsystem_i/axi_pcie_0/U0/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S0]
set_case_analysis 0 [get_pins mb_subsystem_i/axi_pcie_0/U0/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1/S1]
#
#
###################CDC constraints####################

#set_max_delay -datapath_only -from [get_clocks clk_pll_i] -to [get_clocks adcClk] 10.000
#set_max_delay -datapath_only -from [get_clocks adcClk] -to [get_clocks clk_pll_i] 10.000

#set_max_delay -datapath_only -from [get_clocks clk_pll_i] -to [get_clocks clk_out_180_adc_clk_dly] 10.000
#set_max_delay -datapath_only -from [get_clocks clk_out_180_adc_clk_dly] -to [get_clocks clk_pll_i] 10.000

#set_max_delay -datapath_only -from [get_clocks clk_pll_i] -to [get_clocks clk_out_0_adc_clk_dly] 10.000
#set_max_delay -datapath_only -from [get_clocks clk_out_0_adc_clk_dly] -to [get_clocks clk_pll_i] 10.000
#
#
###############################################################################
# Physical Constraints
###############################################################################

###############################################################################
# End
###############################################################################

set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN DISABLE [current_design]
set_property BITSTREAM.STARTUP.STARTUPCLK CCLK [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 26 [current_design]

set_property IOSTANDARD DIFF_HSTL_II_18 [get_ports REFCLK_P]
set_property PACKAGE_PIN F10 [get_ports REFCLK_P]

#set_property IOSTANDARD DIFF_HSTL_II_18 [get_ports REFCLK_N]
#set_property PACKAGE_PIN AH20 [get_ports REFCLK_N]

set_property LOC STARTUP_X0Y0 [get_cells mb_subsystem_i/axi_quad_spi_0/U0/QSPI_LEGACY_MD_GEN.QSPI_CORE_INTERFACE_I/LOGIC_FOR_MD_0_GEN.SCK_MISO_STARTUP_USED.QSPI_STARTUP_BLOCK_I/STARTUP_7SERIES_GEN.STARTUP2_7SERIES_inst]

set_false_path -from [get_pins {mb_subsystem_i/target_regs_0/U0/ublaze_lite_inst/U0/axi4lite_regs_v1_0_S00_AXI_inst/cntrl_8b_gen[6].control_reg_8b_s_reg[1][0]/C}] -to [get_pins {mb_subsystem_i/target_regs_0/U0/host_intr_reg_reg[0]/D}]

#set_property DONT_TOUCH true [get_cells mb_subsystem_i/axi_pcie_0/U0/comp_axi_enhanced_pcie/comp_enhanced_core_top_wrap/axi_pcie_enhanced_core_top_i/pcie_7x_v2_0_2_inst/pcie_top_with_gt_top.gt_ges.gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/pclk_i1_bufgctrl.pclk_i1_i_1]

set_property LOC XADC_X0Y0 [get_cells mb_subsystem_i/mig_7series_0/u_mb_top_mig_7series_0_0_mig/temp_mon_enabled.u_tempmon/xadc_supplied_temperature.XADC_inst]

create_generated_clock -name DDR3_ck_p[0] -source [get_pins {mb_subsystem_i/mig_7series_0/u_mb_top_mig_7series_0_0_mig/u_memc_ui_top_axi/mem_intfc0/ddr_phy_top0/u_ddr_mc_phy_wrapper/u_ddr_mc_phy/ddr_phy_4lanes_1.u_ddr_phy_4lanes/ddr_byte_lane_C.ddr_byte_lane_C/ddr_ck_gen_loop[0].ddr_ck_gen.ddr_ck/C}] -divide_by 1 -invert [get_ports {DDR3_ck_p[0]}]


create_pblock pblock_decimation_filter_0
add_cells_to_pblock [get_pblocks pblock_decimation_filter_0] [get_cells -quiet [list mb_subsystem_i/decimation_filter_0]]
resize_pblock [get_pblocks pblock_decimation_filter_0] -add {SLICE_X2Y51:SLICE_X163Y102}
resize_pblock [get_pblocks pblock_decimation_filter_0] -add {DSP48_X0Y22:DSP48_X8Y39}
resize_pblock [get_pblocks pblock_decimation_filter_0] -add {RAMB18_X0Y22:RAMB18_X8Y39}
resize_pblock [get_pblocks pblock_decimation_filter_0] -add {RAMB36_X0Y11:RAMB36_X8Y19}
set_property LOC BSCAN_X0Y1 [get_cells mb_subsystem_i/debug_module/U0/Use_E2.BSCANE2_I]


set_property BEL F7AMUX [get_cells mb_subsystem_i/Ov_DetIP/U0/axitoReg_inst_i_26]
set_property BEL C6LUT [get_cells {mb_subsystem_i/Ov_DetIP/U0/meminterface/axitoReg_inst/axi_rdata[6]_i_1}]
set_property BEL D6LUT [get_cells {mb_subsystem_i/Ov_DetIP/U0/meminterface/axitoReg_inst/axi_rdata[6]_i_6}]
set_property BEL F7BMUX [get_cells mb_subsystem_i/Ov_DetIP/U0/axitoReg_inst_i_321]
set_property BEL D6LUT [get_cells {mb_subsystem_i/Ov_DetIP/U0/meminterface/axitoReg_inst/axi_rdata[6]_i_2}]
set_property BEL CFF [get_cells {mb_subsystem_i/Ov_DetIP/U0/meminterface/axitoReg_inst/U0/axi4lite_regs_v1_0_S00_AXI_inst/axi_rdata_reg[6]}]
set_property BEL A6LUT [get_cells mb_subsystem_i/Ov_DetIP/U0/axitoReg_inst_i_65]
set_property BEL AFF [get_cells {mb_subsystem_i/Ov_DetIP/U0/meminterface/axitoReg_inst/U0/axi4lite_regs_v1_0_S00_AXI_inst/cntrl_32b_gen[22].control_reg_32b_s_reg[22][6]}]
set_property LOC SLICE_X144Y15 [get_cells mb_subsystem_i/Ov_DetIP/U0/axitoReg_inst_i_150]
set_property LOC SLICE_X116Y34 [get_cells mb_subsystem_i/Ov_DetIP/U0/axitoReg_inst_i_26]
set_property LOC SLICE_X44Y47 [get_cells {mb_subsystem_i/Ov_DetIP/U0/meminterface/axitoReg_inst/axi_rdata[6]_i_1}]
set_property LOC SLICE_X46Y35 [get_cells {mb_subsystem_i/Ov_DetIP/U0/meminterface/axitoReg_inst/axi_rdata[6]_i_6}]
set_property LOC SLICE_X144Y15 [get_cells mb_subsystem_i/Ov_DetIP/U0/axitoReg_inst_i_321]
set_property LOC SLICE_X44Y46 [get_cells {mb_subsystem_i/Ov_DetIP/U0/meminterface/axitoReg_inst/axi_rdata[6]_i_2}]
set_property LOC SLICE_X44Y47 [get_cells {mb_subsystem_i/Ov_DetIP/U0/meminterface/axitoReg_inst/U0/axi4lite_regs_v1_0_S00_AXI_inst/axi_rdata_reg[6]}]
set_property LOC SLICE_X116Y34 [get_cells mb_subsystem_i/Ov_DetIP/U0/axitoReg_inst_i_65]
set_property LOC SLICE_X88Y50 [get_cells {mb_subsystem_i/Ov_DetIP/U0/meminterface/axitoReg_inst/U0/axi4lite_regs_v1_0_S00_AXI_inst/cntrl_32b_gen[22].control_reg_32b_s_reg[22][6]}]
set_property BEL A6LUT [get_cells {mb_subsystem_i/Ov_DetIP/U0/intindex_gen[22].intIndex[22][4]_i_3}]
set_property BEL DFF [get_cells {mb_subsystem_i/Ov_DetIP/U0/inst_ovld_control/overloadstatus_gen[22].overload_status_current_reg[22][4]}]
set_property BEL C6LUT [get_cells {mb_subsystem_i/Ov_DetIP/U0/overloadstatus_gen[22].overload_status_current[22][3]_i_2}]
set_property BEL D6LUT [get_cells {mb_subsystem_i/Ov_DetIP/U0/overloadstatus_gen[22].overload_status_current[22][4]_i_1}]
set_property BEL D5FF [get_cells {mb_subsystem_i/Ov_DetIP/U0/inst_ovld_control/adc_counter_reg[2]_rep__0}]
set_property LOC SLICE_X51Y38 [get_cells {mb_subsystem_i/Ov_DetIP/U0/intindex_gen[22].intIndex[22][4]_i_3}]
set_property LOC SLICE_X49Y21 [get_cells {mb_subsystem_i/Ov_DetIP/U0/inst_ovld_control/overloadstatus_gen[22].overload_status_current_reg[22][4]}]
set_property LOC SLICE_X114Y43 [get_cells {mb_subsystem_i/Ov_DetIP/U0/overloadstatus_gen[22].overload_status_current[22][3]_i_2}]
set_property LOC SLICE_X49Y21 [get_cells {mb_subsystem_i/Ov_DetIP/U0/overloadstatus_gen[22].overload_status_current[22][4]_i_1}]
set_property LOC SLICE_X51Y41 [get_cells {mb_subsystem_i/Ov_DetIP/U0/inst_ovld_control/adc_counter_reg[2]_rep__0}]
set_property BEL AFF [get_cells {mb_subsystem_i/Ov_DetIP/U0/inst_ovld_control/overload_regs_ram_addr_sync_reg[8]}]
set_property BEL DFF [get_cells {mb_subsystem_i/Ov_DetIP/U0/meminterface/axitoReg_inst/U0/axi4lite_regs_v1_0_S00_AXI_inst/cntrl_32b_gen[22].control_reg_32b_s_reg[22][8]}]
set_property LOC SLICE_X50Y17 [get_cells {mb_subsystem_i/Ov_DetIP/U0/inst_ovld_control/overload_regs_ram_addr_sync_reg[8]}]
set_property LOC SLICE_X98Y53 [get_cells {mb_subsystem_i/Ov_DetIP/U0/meminterface/axitoReg_inst/U0/axi4lite_regs_v1_0_S00_AXI_inst/cntrl_32b_gen[22].control_reg_32b_s_reg[22][8]}]









#set_property IOSTANDARD LVCMOS25 [get_ports PHY_MDIO]
#set_property PACKAGE_PIN AD23 [get_ports PHY_MDIO]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_TXD0]
#set_property PACKAGE_PIN AF34 [get_ports PHY_TXD0]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_RXD0]
#set_property PACKAGE_PIN AG34 [get_ports PHY_RXD0]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_TXD2]
#set_property PACKAGE_PIN AD33 [get_ports PHY_TXD2]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_TXD3]
#set_property PACKAGE_PIN AD34 [get_ports PHY_TXD3]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_TXCTL_TXEN]
#set_property PACKAGE_PIN AH33 [get_ports PHY_TXCTL_TXEN]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_MDC]
#set_property PACKAGE_PIN AH34 [get_ports PHY_MDC]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_TXD1]
#set_property PACKAGE_PIN AE33 [get_ports PHY_TXD1]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_RXD1]
#set_property PACKAGE_PIN AF33 [get_ports PHY_RXD1]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_RXD2]
#set_property PACKAGE_PIN AG32 [get_ports PHY_RXD2]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_RXD3]
#set_property PACKAGE_PIN AH32 [get_ports PHY_RXD3]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_INT]
#set_property PACKAGE_PIN AE32 [get_ports PHY_INT]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_RESET]
#set_property PACKAGE_PIN AF32 [get_ports PHY_RESET]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_CRS]
#set_property PACKAGE_PIN AD31 [get_ports PHY_CRS]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_COL]
#set_property PACKAGE_PIN AE31 [get_ports PHY_COL]

#set_property PACKAGE_PIN W11 [get_ports configSerialClk]
#set_property IOSTANDARD LVCMOS33 [get_ports configSerialClk]
#set_property PACKAGE_PIN AD29 [get_ports UART_txd]
#set_property IOSTANDARD LVCMOS25 [get_ports UART_out1n]
#set_property PACKAGE_PIN AD28 [get_ports UART_out1n]
#set_property PACKAGE_PIN AG31 [get_ports UART_rxd]


#set_property IOSTANDARD LVCMOS25 [get_ports PCIe_MMCM_Lock]
#set_property PACKAGE_PIN AH27 [get_ports PCIe_MMCM_Lock]

#set_property IOSTANDARD LVCMOS25 [get_ports PPHY_TXC_GTXCLK]
#set_property PACKAGE_PIN AF29 [get_ports PPHY_TXC_GTXCLK]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_RXCTL_RXDV]
#set_property PACKAGE_PIN AF30 [get_ports PHY_RXCTL_RXDV]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_RXCLK]
#set_property PACKAGE_PIN AG29 [get_ports PHY_RXCLK]
#set_property IOSTANDARD LVCMOS25 [get_ports PHY_125CLK]
#set_property PACKAGE_PIN AG30 [get_ports PHY_125CLK]

#set_property IOSTANDARD LVCMOS25 [get_ports UART_dtrn]
#set_property PACKAGE_PIN AE28 [get_ports UART_dtrn]

#set_property IOSTANDARD LVCMOS25 [get_ports UART_rtsn]
#set_property PACKAGE_PIN AF28 [get_ports UART_rtsn]

#set_property IOSTANDARD LVCMOS25 [get_ports BFMC_PG_C2M2]
#set_property PACKAGE_PIN AD26 [get_ports BFMC_PG_C2M2]
#set_property IOSTANDARD LVCMOS25 [get_ports BOE_TRIG3]
#set_property PACKAGE_PIN AE26 [get_ports BOE_TRIG3]
#set_property IOSTANDARD LVCMOS25 [get_ports BFMC1_PG_C2M]
#set_property PACKAGE_PIN AC26 [get_ports BFMC1_PG_C2M]
#set_property IOSTANDARD LVCMOS25 [get_ports BFMC3_PG_C2M]
#set_property PACKAGE_PIN AC27 [get_ports BFMC3_PG_C2M]
#set_property IOSTANDARD LVCMOS25 [get_ports BALERT_EN]
#set_property PACKAGE_PIN AG27 [get_ports BALERT_EN]
#set_property IOSTANDARD LVCMOS25 [get_ports BOE_TRIG7]
#set_property PACKAGE_PIN AF27 [get_ports BOE_TRIG7]
#set_property IOSTANDARD LVCMOS25 [get_ports BOE_TRIG4]
#set_property PACKAGE_PIN AG26 [get_ports BOE_TRIG4]
#set_property IOSTANDARD LVCMOS25 [get_ports BFMC2_PRSNT_M2C_L]
#set_property PACKAGE_PIN AE23 [get_ports BFMC2_PRSNT_M2C_L]
#set_property IOSTANDARD LVCMOS25 [get_ports BFMC3_PRSNT_M2C_L]
#set_property PACKAGE_PIN AF23 [get_ports BFMC3_PRSNT_M2C_L]
#set_property IOSTANDARD LVCMOS25 [get_ports BOE_TRIG0]
#set_property PACKAGE_PIN AG24 [get_ports BOE_TRIG0]
#set_property IOSTANDARD LVCMOS25 [get_ports BOE_TRIG1]
#set_property PACKAGE_PIN AH24 [get_ports BOE_TRIG1]

#set_property IOSTANDARD LVCMOS25 [get_ports BFMC1_PRSNT_M2C_L]
#set_property PACKAGE_PIN AD24 [get_ports BFMC1_PRSNT_M2C_L]
#set_property IOSTANDARD LVCMOS25 [get_ports BOE_TRIG5]
#set_property PACKAGE_PIN AF25 [get_ports BOE_TRIG5]
#set_property IOSTANDARD LVCMOS25 [get_ports BOE_TRIG6]
#set_property PACKAGE_PIN AG25 [get_ports BOE_TRIG6]
#set_property IOSTANDARD LVCMOS25 [get_ports BFMC4_PG_C2M]
#set_property PACKAGE_PIN AD25 [get_ports BFMC4_PG_C2M]
#set_property IOSTANDARD LVCMOS25 [get_ports BOE_TRIG2]
#set_property PACKAGE_PIN AE25 [get_ports BOE_TRIG2]
#set_property IOSTANDARD LVCMOS25 [get_ports BFMC4_PRSNT_M2C_L]
#set_property PACKAGE_PIN AF24 [get_ports BFMC4_PRSNT_M2C_L]

#set_property PACKAGE_PIN AE27 [get_ports {PCB_REV[3]}]
#set_property IOSTANDARD LVCMOS25 [get_ports {PCB_REV[3]}]
#set_property PULLDOWN true [get_ports {PCB_REV[3]}]

#set_property IOSTANDARD LVCMOS25 [get_ports {UART_txd[0]}]
#set_property PACKAGE_PIN AD29 [get_ports {UART_txd[0]}]

#set_property IOSTANDARD LVCMOS25 [get_ports {UART_rxd[0]}]
#set_property PACKAGE_PIN AG31 [get_ports {UART_rxd[0]}]