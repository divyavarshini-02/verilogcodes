--Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2014.2 (win64) Build 932637 Wed Jun 11 13:33:10 MDT 2014
--Date        : Wed Sep 17 15:00:39 2014
--Host        : ca-irv-vti0244 running 64-bit Service Pack 1  (build 7601)
--Command     : generate_target data_mover_ip.bd
--Design      : data_mover_ip
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity data_mover_32ch_ip is
  port (
    ACLK : in STD_LOGIC;
    ARESETN : in STD_LOGIC;
-- AXI Lite interface
  S00_AXI1_0_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI1_0_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI1_0_arcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI1_0_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  S00_AXI1_0_arlock : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
  S00_AXI1_0_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI1_0_arqos : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI1_0_arready : OUT STD_LOGIC;
  S00_AXI1_0_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI1_0_arvalid : IN STD_LOGIC;
  S00_AXI1_0_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI1_0_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI1_0_awcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI1_0_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  S00_AXI1_0_awlock : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
  S00_AXI1_0_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI1_0_awqos : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI1_0_awready : OUT STD_LOGIC;
  S00_AXI1_0_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI1_0_awvalid : IN STD_LOGIC;
  S00_AXI1_0_bready : IN STD_LOGIC;
  S00_AXI1_0_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI1_0_bvalid : OUT STD_LOGIC;
  S00_AXI1_0_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI1_0_rlast : OUT STD_LOGIC;
  S00_AXI1_0_rready : IN STD_LOGIC;
  S00_AXI1_0_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI1_0_rvalid : OUT STD_LOGIC;
  S00_AXI1_0_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI1_0_wlast : IN STD_LOGIC;
  S00_AXI1_0_wready : OUT STD_LOGIC;
  S00_AXI1_0_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI1_0_wvalid : IN STD_LOGIC;

	
	
-- AXI Stream Interface	
  S00_AXI_0_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI_0_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI_0_arcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_0_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  S00_AXI_0_arlock : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
  S00_AXI_0_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI_0_arqos : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_0_arready : OUT STD_LOGIC;
  S00_AXI_0_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI_0_arvalid : IN STD_LOGIC;
  S00_AXI_0_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI_0_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI_0_awcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_0_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  S00_AXI_0_awlock : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
  S00_AXI_0_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI_0_awqos : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_0_awready : OUT STD_LOGIC;
  S00_AXI_0_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI_0_awvalid : IN STD_LOGIC;
  S00_AXI_0_bready : IN STD_LOGIC;
  S00_AXI_0_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI_0_bvalid : OUT STD_LOGIC;
  S00_AXI_0_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI_0_rlast : OUT STD_LOGIC;
  S00_AXI_0_rready : IN STD_LOGIC;
  S00_AXI_0_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI_0_rvalid : OUT STD_LOGIC;
  S00_AXI_0_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI_0_wlast : IN STD_LOGIC;
  S00_AXI_0_wready : OUT STD_LOGIC;
  S00_AXI_0_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_0_wvalid : IN STD_LOGIC;
  interrupt		: out std_logic; 

--    AXI Stream from FMC 0	
  S00_AXIS_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
--    S_AXIS_tid : in STD_LOGIC_VECTOR ( 2 downto 0 );
--    S_AXIS_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
  S00_AXIS_tlast : in STD_LOGIC;
  S00_AXIS_tready : out STD_LOGIC;
  S00_AXIS_aclk  : in std_logic;
  S00_AXIS_tvalid : in STD_LOGIC;

-- dio interface
  S01_AXI_STR_RXD_32_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0); 
  S01_AXI_STR_RXD_32_tlast : IN STD_LOGIC;
  S01_AXI_STR_RXD_32_tready : OUT STD_LOGIC;
  S01_AXI_STR_RXD_32_tvalid : IN STD_LOGIC;

  data_mover_enable : in STD_LOGIC
    
  );
end data_mover_32ch_ip;

architecture STRUCTURE of data_mover_32ch_ip is
COMPONENT dma_top
  PORT (
    ACLK : IN STD_LOGIC;
  ARESETN : IN STD_LOGIC;

  AXI_STR_RXD_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_tlast : IN STD_LOGIC;
  AXI_STR_RXD_tready : OUT STD_LOGIC;
  AXI_STR_RXD_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_1_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_1_tlast : IN STD_LOGIC;
  AXI_STR_RXD_1_tready : OUT STD_LOGIC;
  AXI_STR_RXD_1_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_2_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_2_tlast : IN STD_LOGIC;
  AXI_STR_RXD_2_tready : OUT STD_LOGIC;
  AXI_STR_RXD_2_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_3_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_3_tlast : IN STD_LOGIC;
  AXI_STR_RXD_3_tready : OUT STD_LOGIC;
  AXI_STR_RXD_3_tvalid : IN STD_LOGIC;
 
  AXI_STR_RXD_4_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_4_tlast : IN STD_LOGIC;
  AXI_STR_RXD_4_tready : OUT STD_LOGIC;
  AXI_STR_RXD_4_tvalid : IN STD_LOGIC;
 
  AXI_STR_RXD_5_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_5_tlast : IN STD_LOGIC;
  AXI_STR_RXD_5_tready : OUT STD_LOGIC;
  AXI_STR_RXD_5_tvalid : IN STD_LOGIC;
 
  AXI_STR_RXD_6_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_6_tlast : IN STD_LOGIC;
  AXI_STR_RXD_6_tready : OUT STD_LOGIC;
  AXI_STR_RXD_6_tvalid : IN STD_LOGIC;
  
  AXI_STR_RXD_7_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_7_tlast : IN STD_LOGIC;
  AXI_STR_RXD_7_tready : OUT STD_LOGIC;
  AXI_STR_RXD_7_tvalid : IN STD_LOGIC;
 
  AXI_STR_RXD_8_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_8_tlast : IN STD_LOGIC;
  AXI_STR_RXD_8_tready : OUT STD_LOGIC;
  AXI_STR_RXD_8_tvalid : IN STD_LOGIC;
 
  AXI_STR_RXD_9_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_9_tlast : IN STD_LOGIC;
  AXI_STR_RXD_9_tready : OUT STD_LOGIC;
  AXI_STR_RXD_9_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_10_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_10_tlast : IN STD_LOGIC;
  AXI_STR_RXD_10_tready : OUT STD_LOGIC;
  AXI_STR_RXD_10_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_11_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_11_tlast : IN STD_LOGIC;
  AXI_STR_RXD_11_tready : OUT STD_LOGIC;
  AXI_STR_RXD_11_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_12_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_12_tlast : IN STD_LOGIC;
  AXI_STR_RXD_12_tready : OUT STD_LOGIC;
  AXI_STR_RXD_12_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_13_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_13_tlast : IN STD_LOGIC;
  AXI_STR_RXD_13_tready : OUT STD_LOGIC;
  AXI_STR_RXD_13_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_14_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_14_tlast : IN STD_LOGIC;
  AXI_STR_RXD_14_tready : OUT STD_LOGIC;
  AXI_STR_RXD_14_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_15_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_15_tlast : IN STD_LOGIC;
  AXI_STR_RXD_15_tready : OUT STD_LOGIC;
  AXI_STR_RXD_15_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_16_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_16_tlast : IN STD_LOGIC;
  AXI_STR_RXD_16_tready : OUT STD_LOGIC;
  AXI_STR_RXD_16_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_17_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_17_tlast : IN STD_LOGIC;
  AXI_STR_RXD_17_tready : OUT STD_LOGIC;
  AXI_STR_RXD_17_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_18_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_18_tlast : IN STD_LOGIC;
  AXI_STR_RXD_18_tready : OUT STD_LOGIC;
  AXI_STR_RXD_18_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_19_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_19_tlast : IN STD_LOGIC;
  AXI_STR_RXD_19_tready : OUT STD_LOGIC;
  AXI_STR_RXD_19_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_20_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_20_tlast : IN STD_LOGIC;
  AXI_STR_RXD_20_tready : OUT STD_LOGIC;
  AXI_STR_RXD_20_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_21_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_21_tlast : IN STD_LOGIC;
  AXI_STR_RXD_21_tready : OUT STD_LOGIC;
  AXI_STR_RXD_21_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_22_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_22_tlast : IN STD_LOGIC;
  AXI_STR_RXD_22_tready : OUT STD_LOGIC;
  AXI_STR_RXD_22_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_23_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_23_tlast : IN STD_LOGIC;
  AXI_STR_RXD_23_tready : OUT STD_LOGIC;
  AXI_STR_RXD_23_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_24_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_24_tlast : IN STD_LOGIC;
  AXI_STR_RXD_24_tready : OUT STD_LOGIC;
  AXI_STR_RXD_24_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_25_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_25_tlast : IN STD_LOGIC;
  AXI_STR_RXD_25_tready : OUT STD_LOGIC;
  AXI_STR_RXD_25_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_26_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_26_tlast : IN STD_LOGIC;
  AXI_STR_RXD_26_tready : OUT STD_LOGIC;
  AXI_STR_RXD_26_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_27_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_27_tlast : IN STD_LOGIC;
  AXI_STR_RXD_27_tready : OUT STD_LOGIC;
  AXI_STR_RXD_27_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_28_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_28_tlast : IN STD_LOGIC;
  AXI_STR_RXD_28_tready : OUT STD_LOGIC;
  AXI_STR_RXD_28_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_29_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_29_tlast : IN STD_LOGIC;
  AXI_STR_RXD_29_tready : OUT STD_LOGIC;
  AXI_STR_RXD_29_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_30_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_30_tlast : IN STD_LOGIC;
  AXI_STR_RXD_30_tready : OUT STD_LOGIC;
  AXI_STR_RXD_30_tvalid : IN STD_LOGIC;

  AXI_STR_RXD_31_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_31_tlast : IN STD_LOGIC;
  AXI_STR_RXD_31_tready : OUT STD_LOGIC;
  AXI_STR_RXD_31_tvalid : IN STD_LOGIC;
 
  AXI_STR_RXD_32_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  AXI_STR_RXD_32_tlast : IN STD_LOGIC;
  AXI_STR_RXD_32_tready : OUT STD_LOGIC;
  AXI_STR_RXD_32_tvalid : IN STD_LOGIC;  
  
  S00_AXI1_0_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI1_0_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI1_0_arcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI1_0_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  S00_AXI1_0_arlock : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
  S00_AXI1_0_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI1_0_arqos : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI1_0_arready : OUT STD_LOGIC;
  S00_AXI1_0_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI1_0_arvalid : IN STD_LOGIC;
  S00_AXI1_0_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI1_0_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI1_0_awcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI1_0_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  S00_AXI1_0_awlock : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
  S00_AXI1_0_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI1_0_awqos : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI1_0_awready : OUT STD_LOGIC;
  S00_AXI1_0_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI1_0_awvalid : IN STD_LOGIC;
  S00_AXI1_0_bready : IN STD_LOGIC;
  S00_AXI1_0_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI1_0_bvalid : OUT STD_LOGIC;
  S00_AXI1_0_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI1_0_rlast : OUT STD_LOGIC;
  S00_AXI1_0_rready : IN STD_LOGIC;
  S00_AXI1_0_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI1_0_rvalid : OUT STD_LOGIC;
  S00_AXI1_0_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI1_0_wlast : IN STD_LOGIC;
  S00_AXI1_0_wready : OUT STD_LOGIC;
  S00_AXI1_0_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI1_0_wvalid : IN STD_LOGIC;
 
  S00_AXI_0_araddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI_0_arburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI_0_arcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_0_arlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  S00_AXI_0_arlock : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
  S00_AXI_0_arprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI_0_arqos : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_0_arready : OUT STD_LOGIC;
  S00_AXI_0_arsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI_0_arvalid : IN STD_LOGIC;
  S00_AXI_0_awaddr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI_0_awburst : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI_0_awcache : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_0_awlen : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  S00_AXI_0_awlock : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
  S00_AXI_0_awprot : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI_0_awqos : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_0_awready : OUT STD_LOGIC;
  S00_AXI_0_awsize : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI_0_awvalid : IN STD_LOGIC;
  S00_AXI_0_bready : IN STD_LOGIC;
  S00_AXI_0_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI_0_bvalid : OUT STD_LOGIC;
  S00_AXI_0_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI_0_rlast : OUT STD_LOGIC;
  S00_AXI_0_rready : IN STD_LOGIC;
  S00_AXI_0_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI_0_rvalid : OUT STD_LOGIC;
  S00_AXI_0_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI_0_wlast : IN STD_LOGIC;
  S00_AXI_0_wready : OUT STD_LOGIC;
  S00_AXI_0_wstrb : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_0_wvalid : IN STD_LOGIC;
 
  control_reg_16b : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
  control_reg_16b_wr : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
  control_reg_32b : OUT STD_LOGIC_VECTOR(351 DOWNTO 0);
  control_reg_32b_wr : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
  control_reg_8b : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  control_reg_8b_wr : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);


  interrupt_0 : OUT STD_LOGIC;
  interrupt_1 : OUT STD_LOGIC;
  interrupt_2 : OUT STD_LOGIC;
  interrupt_3 : OUT STD_LOGIC;  
  interrupt_4 : OUT STD_LOGIC;  
  interrupt_5 : OUT STD_LOGIC;  
  interrupt_6 : OUT STD_LOGIC;  
  interrupt_7 : OUT STD_LOGIC;  
  interrupt_8 : OUT STD_LOGIC;  
  interrupt_9 : OUT STD_LOGIC;
  interrupt_10 : OUT STD_LOGIC;
  interrupt_11 : OUT STD_LOGIC;
  interrupt_12 : OUT STD_LOGIC;
  interrupt_13 : OUT STD_LOGIC;
  interrupt_14 : OUT STD_LOGIC;
  interrupt_15 : OUT STD_LOGIC;
  interrupt_16 : OUT STD_LOGIC;
  interrupt_17 : OUT STD_LOGIC;
  interrupt_18 : OUT STD_LOGIC;
  interrupt_19 : OUT STD_LOGIC;  
  interrupt_20 : OUT STD_LOGIC;
  interrupt_21 : OUT STD_LOGIC;
  interrupt_22 : OUT STD_LOGIC;
  interrupt_23 : OUT STD_LOGIC;
  interrupt_24 : OUT STD_LOGIC;
  interrupt_25 : OUT STD_LOGIC;
  interrupt_26 : OUT STD_LOGIC;
  interrupt_27 : OUT STD_LOGIC;
  interrupt_28 : OUT STD_LOGIC;
  interrupt_29 : OUT STD_LOGIC;
  interrupt_30 : OUT STD_LOGIC;
  interrupt_31 : OUT STD_LOGIC;
  interrupt_32 : OUT STD_LOGIC;
 
  status_reg_16b : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
  status_reg_16b_rd : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
  status_reg_32b : IN STD_LOGIC_VECTOR(351 DOWNTO 0);
  status_reg_32b_rd : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
  status_reg_8b : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  status_reg_8b_rd : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );

END COMPONENT;

   component axi_stream_control 
   generic (
      no_of_channels : integer := 32
      );
      port
      (
        aclk     : in std_logic;
        aresetn  : in std_logic;

        S_AXIS_tdata  : in  std_logic_vector (31 downto 0);
        S_AXIS_tid    : in  std_logic_vector (2 downto 0);
        S_AXIS_tkeep   : in  std_logic_vector (3 downto 0);
        S_AXIS_tlast  : in  std_logic;
        S_AXIS_tready : out std_logic;
        S_AXIS_tvalid : in  std_logic;

        channel_en		: in std_logic_vector(31 downto 0);
        dma_en			: in std_logic;	

-- AXI stream Master Interface		 
        M_AXIS_0_tdata   : out std_logic_vector (31 downto 0);
        M_AXIS_0_tid     : out std_logic_vector (2 downto 0);
        M_AXIS_0_tkeep   : out std_logic_vector (3 downto 0);
        M_AXIS_0_tlast   : out std_logic;
        M_AXIS_0_tready  : in  std_logic;
        M_AXIS_0_tvalid  : out std_logic;
    
        M_AXIS_1_tdata   : out std_logic_vector (31 downto 0);
        M_AXIS_1_tid     : out std_logic_vector (2 downto 0);
        M_AXIS_1_tkeep   : out std_logic_vector (3 downto 0);
        M_AXIS_1_tlast   : out std_logic;
        M_AXIS_1_tready  : in  std_logic;
        M_AXIS_1_tvalid  : out std_logic;
    
        M_AXIS_2_tdata   : out std_logic_vector (31 downto 0);
        M_AXIS_2_tid     : out std_logic_vector (2 downto 0);
        M_AXIS_2_tkeep   : out std_logic_vector (3 downto 0);
        M_AXIS_2_tlast   : out std_logic;
        M_AXIS_2_tready  : in  std_logic;
        M_AXIS_2_tvalid  : out std_logic;
    
        M_AXIS_3_tdata   : out std_logic_vector (31 downto 0);
        M_AXIS_3_tid     : out std_logic_vector (2 downto 0);
        M_AXIS_3_tkeep   : out std_logic_vector (3 downto 0);
        M_AXIS_3_tlast   : out std_logic;
        M_AXIS_3_tready  : in  std_logic;
        M_AXIS_3_tvalid  : out std_logic;
    
        M_AXIS_4_tdata   : out std_logic_vector (31 downto 0);
        M_AXIS_4_tid     : out std_logic_vector (2 downto 0);
        M_AXIS_4_tkeep   : out std_logic_vector (3 downto 0);
        M_AXIS_4_tlast   : out std_logic;
        M_AXIS_4_tready  : in  std_logic;
        M_AXIS_4_tvalid  : out std_logic;
    
        M_AXIS_5_tdata   : out std_logic_vector (31 downto 0);
        M_AXIS_5_tid     : out std_logic_vector (2 downto 0);
        M_AXIS_5_tkeep   : out std_logic_vector (3 downto 0);
        M_AXIS_5_tlast   : out std_logic;
        M_AXIS_5_tready  : in  std_logic;
        M_AXIS_5_tvalid  : out std_logic;
    
        M_AXIS_6_tdata   : out std_logic_vector (31 downto 0);
        M_AXIS_6_tid     : out std_logic_vector (2 downto 0);
        M_AXIS_6_tkeep   : out std_logic_vector (3 downto 0);
        M_AXIS_6_tlast   : out std_logic;
        M_AXIS_6_tready  : in  std_logic;
        M_AXIS_6_tvalid  : out std_logic;
    
        M_AXIS_7_tdata   : out std_logic_vector (31 downto 0);
        M_AXIS_7_tid     : out std_logic_vector (2 downto 0);
        M_AXIS_7_tkeep   : out std_logic_vector (3 downto 0);
        M_AXIS_7_tlast   : out std_logic;
        M_AXIS_7_tready  : in  std_logic;
        M_AXIS_7_tvalid  : out std_logic;
    
        M_AXIS_8_tdata   : out std_logic_vector (31 downto 0);
        M_AXIS_8_tid     : out std_logic_vector (2 downto 0);
        M_AXIS_8_tkeep   : out std_logic_vector (3 downto 0);
        M_AXIS_8_tlast   : out std_logic;
        M_AXIS_8_tready  : in  std_logic;
        M_AXIS_8_tvalid  : out std_logic;
    
        M_AXIS_9_tdata   : out std_logic_vector (31 downto 0);
        M_AXIS_9_tid     : out std_logic_vector (2 downto 0);
        M_AXIS_9_tkeep   : out std_logic_vector (3 downto 0);
        M_AXIS_9_tlast   : out std_logic;
        M_AXIS_9_tready  : in  std_logic;
        M_AXIS_9_tvalid  : out std_logic;
    
        M_AXIS_10_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_10_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_10_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_10_tlast  : out std_logic;
        M_AXIS_10_tready : in  std_logic;
        M_AXIS_10_tvalid : out std_logic;
    
        M_AXIS_11_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_11_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_11_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_11_tlast  : out std_logic;
        M_AXIS_11_tready : in  std_logic;
        M_AXIS_11_tvalid : out std_logic;
    
        M_AXIS_12_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_12_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_12_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_12_tlast  : out std_logic;
        M_AXIS_12_tready : in  std_logic;
        M_AXIS_12_tvalid : out std_logic;
    
        M_AXIS_13_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_13_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_13_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_13_tlast  : out std_logic;
        M_AXIS_13_tready : in  std_logic;
        M_AXIS_13_tvalid : out std_logic;
    
        M_AXIS_14_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_14_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_14_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_14_tlast  : out std_logic;
        M_AXIS_14_tready : in  std_logic;
        M_AXIS_14_tvalid : out std_logic;
    
        M_AXIS_15_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_15_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_15_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_15_tlast  : out std_logic;
        M_AXIS_15_tready : in  std_logic;
        M_AXIS_15_tvalid : out std_logic;
    
        M_AXIS_16_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_16_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_16_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_16_tlast  : out std_logic;
        M_AXIS_16_tready : in  std_logic;
        M_AXIS_16_tvalid : out std_logic;
    
        M_AXIS_17_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_17_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_17_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_17_tlast  : out std_logic;
        M_AXIS_17_tready : in  std_logic;
        M_AXIS_17_tvalid : out std_logic;
    
        M_AXIS_18_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_18_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_18_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_18_tlast  : out std_logic;
        M_AXIS_18_tready : in  std_logic;
        M_AXIS_18_tvalid : out std_logic;
    
        M_AXIS_19_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_19_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_19_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_19_tlast  : out std_logic;
        M_AXIS_19_tready : in  std_logic;
        M_AXIS_19_tvalid : out std_logic;
    
        M_AXIS_20_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_20_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_20_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_20_tlast  : out std_logic;
        M_AXIS_20_tready : in  std_logic;
        M_AXIS_20_tvalid : out std_logic;
    
        M_AXIS_21_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_21_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_21_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_21_tlast  : out std_logic;
        M_AXIS_21_tready : in  std_logic;
        M_AXIS_21_tvalid : out std_logic;
    
        M_AXIS_22_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_22_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_22_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_22_tlast  : out std_logic;
        M_AXIS_22_tready : in  std_logic;
        M_AXIS_22_tvalid : out std_logic;
    
        M_AXIS_23_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_23_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_23_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_23_tlast  : out std_logic;
        M_AXIS_23_tready : in  std_logic;
        M_AXIS_23_tvalid : out std_logic;         

        M_AXIS_24_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_24_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_24_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_24_tlast  : out std_logic;
        M_AXIS_24_tready : in  std_logic;
        M_AXIS_24_tvalid : out std_logic;

        M_AXIS_25_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_25_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_25_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_25_tlast  : out std_logic;
        M_AXIS_25_tready : in  std_logic;
        M_AXIS_25_tvalid : out std_logic;

        M_AXIS_26_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_26_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_26_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_26_tlast  : out std_logic;
        M_AXIS_26_tready : in  std_logic;
        M_AXIS_26_tvalid : out std_logic;

        M_AXIS_27_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_27_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_27_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_27_tlast  : out std_logic;
        M_AXIS_27_tready : in  std_logic;
        M_AXIS_27_tvalid : out std_logic;

        M_AXIS_28_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_28_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_28_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_28_tlast  : out std_logic;
        M_AXIS_28_tready : in  std_logic;
        M_AXIS_28_tvalid : out std_logic;

        M_AXIS_29_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_29_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_29_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_29_tlast  : out std_logic;
        M_AXIS_29_tready : in  std_logic;
        M_AXIS_29_tvalid : out std_logic;

        M_AXIS_30_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_30_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_30_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_30_tlast  : out std_logic;
        M_AXIS_30_tready : in  std_logic;
        M_AXIS_30_tvalid : out std_logic;

        M_AXIS_31_tdata  : out std_logic_vector (31 downto 0);
        M_AXIS_31_tid    : out std_logic_vector (2 downto 0);
        M_AXIS_31_tkeep  : out std_logic_vector (3 downto 0);
        M_AXIS_31_tlast  : out std_logic;
        M_AXIS_31_tready : in  std_logic;
        M_AXIS_31_tvalid : out std_logic




         );
end component; 

component dma_fifo_control 
  port (
  reset 					: in std_logic;
  sys_clk					: in std_logic;
  sys_ce					: in std_logic;
  interrupt_control_reg		: in std_logic_vector(31 downto 0);
  fifo_interrupt			: out std_logic;  
  fifo_we					: in std_logic;
  fifo_addr					: out std_logic_vector(9 downto 0);
  interrupt_status_reg		: out std_logic_vector(31 downto 0);
  dma_enabled				: in std_logic    
  );
end component;

signal    AXI_STR_RXD_0_tdata        : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_0_tid          : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_0_tkeep        : STD_LOGIC_VECTOR ( 3 downto 0 ) := "0000";
signal    AXI_STR_RXD_0_tlast        : STD_LOGIC := '0';
signal    AXI_STR_RXD_0_tready       : STD_LOGIC;
signal    AXI_STR_RXD_0_tvalid       : STD_LOGIC := '0';

signal    AXI_STR_RXD_1_tdata        : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_1_tid          : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_1_tkeep        : STD_LOGIC_VECTOR ( 3 downto 0 ) := "0000";
signal    AXI_STR_RXD_1_tlast        : STD_LOGIC := '0';
signal    AXI_STR_RXD_1_tready       : STD_LOGIC ;
signal    AXI_STR_RXD_1_tvalid       : STD_LOGIC:='0';

signal    AXI_STR_RXD_2_tdata        : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_2_tid          : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_2_tkeep        : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_2_tlast        : STD_LOGIC:='0';
signal    AXI_STR_RXD_2_tready       : STD_LOGIC;
signal    AXI_STR_RXD_2_tvalid       : STD_LOGIC := '0';

signal    AXI_STR_RXD_3_tdata        : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_3_tid          : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_3_tkeep        : STD_LOGIC_VECTOR ( 3 downto 0 ):="0000";
signal    AXI_STR_RXD_3_tlast        : STD_LOGIC := '0';
signal    AXI_STR_RXD_3_tready       : STD_LOGIC;
signal    AXI_STR_RXD_3_tvalid       : STD_LOGIC := '0';

signal    AXI_STR_RXD_4_tdata        : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_4_tid          : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_4_tkeep        : STD_LOGIC_VECTOR ( 3 downto 0 ) := "0000";
signal    AXI_STR_RXD_4_tlast        : STD_LOGIC := '0';
signal    AXI_STR_RXD_4_tready       : STD_LOGIC;
signal    AXI_STR_RXD_4_tvalid       : STD_LOGIC := '0';

signal    AXI_STR_RXD_5_tdata        : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_5_tid          : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_5_tkeep        : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_5_tlast        : STD_LOGIC:='0';
signal    AXI_STR_RXD_5_tready       : STD_LOGIC ;
signal    AXI_STR_RXD_5_tvalid       : STD_LOGIC := '0';

signal    AXI_STR_RXD_6_tdata        : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_6_tid          : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_6_tkeep        : STD_LOGIC_VECTOR ( 3 downto 0 ):="0000";
signal    AXI_STR_RXD_6_tlast        : STD_LOGIC :='0';
signal    AXI_STR_RXD_6_tready       : STD_LOGIC;
signal    AXI_STR_RXD_6_tvalid       : STD_LOGIC := '0';

signal    AXI_STR_RXD_7_tdata        : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_7_tid          : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_7_tkeep        : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_7_tlast        : STD_LOGIC:='0';
signal    AXI_STR_RXD_7_tready       : STD_LOGIC;
signal    AXI_STR_RXD_7_tvalid       : STD_LOGIC := '0';

signal    AXI_STR_RXD_8_tdata        : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_8_tid          : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_8_tkeep        : STD_LOGIC_VECTOR ( 3 downto 0 ) := "0000";
signal    AXI_STR_RXD_8_tlast        : STD_LOGIC :='0';
signal    AXI_STR_RXD_8_tready       : STD_LOGIC;
signal    AXI_STR_RXD_8_tvalid       : STD_LOGIC := '0';

signal    AXI_STR_RXD_9_tdata        : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_9_tid          : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_9_tkeep        : STD_LOGIC_VECTOR ( 3 downto 0 ) := "0000";
signal    AXI_STR_RXD_9_tlast        : STD_LOGIC :='0';
signal    AXI_STR_RXD_9_tready       : STD_LOGIC;
signal    AXI_STR_RXD_9_tvalid       : STD_LOGIC := '0';

signal    AXI_STR_RXD_10_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_10_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_10_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_10_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_10_tready      : STD_LOGIC;
signal    AXI_STR_RXD_10_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_11_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_11_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_11_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_11_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_11_tready      : STD_LOGIC;
signal    AXI_STR_RXD_11_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_12_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_12_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_12_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_12_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_12_tready      : STD_LOGIC;
signal    AXI_STR_RXD_12_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_13_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_13_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_13_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_13_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_13_tready      : STD_LOGIC;
signal    AXI_STR_RXD_13_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_14_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_14_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_14_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_14_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_14_tready      : STD_LOGIC;
signal    AXI_STR_RXD_14_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_15_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_15_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_15_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_15_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_15_tready      : STD_LOGIC;
signal    AXI_STR_RXD_15_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_16_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_16_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_16_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_16_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_16_tready      : STD_LOGIC;
signal    AXI_STR_RXD_16_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_17_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_17_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_17_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_17_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_17_tready      : STD_LOGIC;
signal    AXI_STR_RXD_17_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_18_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_18_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_18_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_18_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_18_tready      : STD_LOGIC;
signal    AXI_STR_RXD_18_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_19_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_19_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_19_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_19_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_19_tready      : STD_LOGIC;
signal    AXI_STR_RXD_19_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_20_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_20_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_20_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_20_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_20_tready      : STD_LOGIC;
signal    AXI_STR_RXD_20_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_21_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_21_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_21_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_21_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_21_tready      : STD_LOGIC;
signal    AXI_STR_RXD_21_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_22_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_22_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_22_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_22_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_22_tready      : STD_LOGIC;
signal    AXI_STR_RXD_22_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_23_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_23_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_23_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_23_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_23_tready      : STD_LOGIC;
signal    AXI_STR_RXD_23_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_24_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_24_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_24_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_24_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_24_tready      : STD_LOGIC;
signal    AXI_STR_RXD_24_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_25_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_25_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_25_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_25_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_25_tready      : STD_LOGIC;
signal    AXI_STR_RXD_25_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_26_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_26_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_26_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_26_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_26_tready      : STD_LOGIC;
signal    AXI_STR_RXD_26_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_27_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_27_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_27_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_27_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_27_tready      : STD_LOGIC;
signal    AXI_STR_RXD_27_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_28_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_28_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_28_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_28_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_28_tready      : STD_LOGIC;
signal    AXI_STR_RXD_28_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_29_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_29_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_29_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_29_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_29_tready      : STD_LOGIC;
signal    AXI_STR_RXD_29_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_30_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_30_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_30_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_30_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_30_tready      : STD_LOGIC;
signal    AXI_STR_RXD_30_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_31_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_31_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_31_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_31_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_31_tready      : STD_LOGIC;
signal    AXI_STR_RXD_31_tvalid      : STD_LOGIC := '0';

signal    AXI_STR_RXD_32_tdata       : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
signal    AXI_STR_RXD_32_tid         : STD_LOGIC_VECTOR ( 2 downto 0 ) := "000";
signal    AXI_STR_RXD_32_tkeep       : STD_LOGIC_VECTOR ( 3 downto 0 ) :="0000";
signal    AXI_STR_RXD_32_tlast       : STD_LOGIC := '0';
signal    AXI_STR_RXD_32_tready      : STD_LOGIC;
signal    AXI_STR_RXD_32_tvalid      : STD_LOGIC := '0';




--FMC 0  interrupts 
signal interrupt_0					: std_logic;
signal interrupt_1					: std_logic;
signal interrupt_2					: std_logic;
signal interrupt_3					: std_logic;
signal interrupt_4					: std_logic;
signal interrupt_5					: std_logic;
signal interrupt_6					: std_logic;
signal interrupt_7					: std_logic;
signal interrupt_8					: std_logic;
signal interrupt_9					: std_logic;
signal interrupt_10					: std_logic;
signal interrupt_11					: std_logic;
signal interrupt_12					: std_logic;
signal interrupt_13					: std_logic;
signal interrupt_14					: std_logic;
signal interrupt_15					: std_logic;

--FMC 1  interrupts
signal interrupt_16					: std_logic;
signal interrupt_17					: std_logic;
signal interrupt_18					: std_logic;
signal interrupt_19					: std_logic;
signal interrupt_20					: std_logic;
signal interrupt_21					: std_logic;
signal interrupt_22					: std_logic;
signal interrupt_23					: std_logic;
signal interrupt_24					: std_logic;
signal interrupt_25					: std_logic;
signal interrupt_26					: std_logic;
signal interrupt_27 				: std_logic;
signal interrupt_28					: std_logic;
signal interrupt_29					: std_logic;
signal interrupt_30					: std_logic;
signal interrupt_31					: std_logic;
signal interrupt_32					: std_logic;



constant no_of_ublaze_32b_regs      : integer   :=11;
constant no_of_ublaze_16b_regs      : integer   :=1;
constant no_of_ublaze_8b_regs       : integer   :=1; 

signal    control_reg_32b_wr :  STD_LOGIC_VECTOR ( no_of_ublaze_32b_regs-1 downto 0 );
signal    status_reg_32b_rd :  STD_LOGIC_VECTOR ( no_of_ublaze_32b_regs-1 downto 0 );
signal    control_reg_16b_wr : STD_LOGIC_VECTOR ( 0 to 0 );
signal    status_reg_16b_rd :  STD_LOGIC_VECTOR ( 0 to 0 );
signal    control_reg_8b_wr :  STD_LOGIC_VECTOR ( 0 to 0 );
signal    status_reg_8b_rd :  STD_LOGIC_VECTOR ( 0 to 0 );


type ctl_ublaze_32bit_t is array (no_of_ublaze_32b_regs-1 downto 0) of std_logic_vector(31 downto 0);
type ctl_ublaze_16bit_t is array (no_of_ublaze_16b_regs-1 downto 0) of std_logic_vector(15 downto 0);
type ctl_ublaze_8bit_t  is array (no_of_ublaze_8b_regs-1 downto 0) of std_logic_vector(7 downto 0);

signal ctl_ublaze_32b       : ctl_ublaze_32bit_t;
signal status_ublaze_32b    : ctl_ublaze_32bit_t;

signal ctl_ublaze_16b       : ctl_ublaze_16bit_t;
signal status_ublaze_16b    : ctl_ublaze_16bit_t;

signal ctl_ublaze_8b       : ctl_ublaze_8bit_t;
signal status_ublaze_8b    : ctl_ublaze_8bit_t;

signal ublaze_ctl_reg_32b  : std_logic_vector(no_of_ublaze_32b_regs*32-1 downto 0); 
signal ublaze_ctl_reg_16b  : std_logic_vector(no_of_ublaze_16b_regs*16-1 downto 0);
signal ublaze_ctl_reg_8b   : std_logic_vector(no_of_ublaze_8b_regs*8-1 downto 0);

signal ublaze_status_reg_32b  : std_logic_vector(no_of_ublaze_32b_regs*32-1 downto 0); 
signal ublaze_status_reg_16b  : std_logic_vector(no_of_ublaze_16b_regs*16-1 downto 0);
signal ublaze_status_reg_8b   : std_logic_vector(no_of_ublaze_8b_regs*8-1 downto 0);


alias mfg_id_reg 		:std_logic_vector(31 downto 0) is ctl_ublaze_32b(0)(31 downto 0);     	-- 0000 
alias product_id_reg	:std_logic_vector(31 downto 0) is ctl_ublaze_32b(1)(31 downto 0);     	-- 0004
alias version_reg       :std_logic_vector(31 downto 0) is ctl_ublaze_32b(2)(31 downto 0);     	-- 0008
alias release_date_reg  :std_logic_vector(31 downto 0) is ctl_ublaze_32b(3)(31 downto 0);     	-- 000C
alias test_reg          :std_logic_vector(31 downto 0) is ctl_ublaze_32b(4)(31 downto 0);     	-- 0010
alias reset_reg         :std_logic_vector(31 downto 0) is ctl_ublaze_32b(5)(31 downto 0);     	-- 0014
alias int_reg           :std_logic_vector(31 downto 0) is ctl_ublaze_32b(6)(31 downto 0);     	-- 0018
alias fmc0_channel_en_reg    :std_logic_vector(31 downto 0) is ctl_ublaze_32b(7)(31 downto 0);     	-- 001C
alias fmc1_channel_en_reg    :std_logic_vector(31 downto 0) is ctl_ublaze_32b(8)(31 downto 0);     	-- 0020
alias fmc2_channel_en_reg    :std_logic_vector(31 downto 0) is ctl_ublaze_32b(9)(31 downto 0);     	-- 0024
alias fmc3_channel_en_reg    :std_logic_vector(31 downto 0) is ctl_ublaze_32b(10)(31 downto 0);     	-- 0028
	
signal interrupt_status	: std_logic_vector(31 downto 0);
signal areset : std_logic;
signal fifo_interrupt : std_logic;
signal fifo_we : std_logic;
signal fifo_addr : std_logic_vector(9 downto 0);
signal aresetn_in	: std_logic;

type   data_mover_state_t is		(idle,last_done1,last_done2,dwell,dwell_done);
signal data_mover_state			: data_mover_state_t;
signal dma_enabled : std_logic; 
attribute MAX_FANOUT : string;
attribute MAX_FANOUT of dma_enabled : signal is "8";
signal dma_enabled_sig	: std_logic;

attribute mark_debug : string;
attribute keep : string;
attribute mark_debug of dma_enabled_sig : signal is "true";

    

begin

-- 32 bit control registers hookups                   
 cntrl_32b_gen:  for i in 0 to no_of_ublaze_32b_regs-1  generate 
    begin 
             ctl_ublaze_32b(i) <= ublaze_ctl_reg_32b(((i+1)*32-1) downto i*32);        
    
    end generate;

-- 16 bit control registers hookups                   
 cntrl_16b_gen:  for i in 0 to no_of_ublaze_16b_regs-1  generate 
    begin 
             ctl_ublaze_16b(i) <= ublaze_ctl_reg_16b(((i+1)*16-1) downto i*16);        
    
    end generate;

-- 8 bit control registers hookups                   
 cntrl_8b_gen:  for i in 0 to no_of_ublaze_8b_regs-1  generate 
    begin 
             ctl_ublaze_8b(i) <= ublaze_ctl_reg_8b(((i+1)*8-1) downto i*8);        
    
    end generate;
    
-- 32 bit status register hookup
status_32b_gen:  for i in 0 to no_of_ublaze_32b_regs-1  generate 
   begin 
             ublaze_status_reg_32b(((i+1)*32-1) downto i*32) <= status_ublaze_32b(i);        
   
   end generate;

 -- 16 bit status register hookup
status_16b_gen:  for i in 0 to no_of_ublaze_16b_regs-1  generate 
   begin 
             ublaze_status_reg_16b(((i+1)*16-1) downto i*16) <= status_ublaze_16b(i);        
   end generate;      

-- 8 bit status register hookup
status_8b_gen:  for i in 0 to no_of_ublaze_8b_regs-1  generate 
   begin 
             ublaze_status_reg_8b(((i+1)*8-1) downto i*8) <= status_ublaze_8b(i);        
   end generate;      

-- 32 status register definition
status_ublaze_32b(0) <= x"00001BF4"; -- Manufacturer ID
status_ublaze_32b(1) <= x"00015000"; -- Product ID 22-0015-000
status_ublaze_32b(2) <= x"0000000A"; -- Product ID 22-0015-000
status_ublaze_32b(3) <= x"04300230"; -- Release 9/22/2014 @ 2:30 pm
status_ublaze_32b(4) <= ctl_ublaze_32b(4);
status_ublaze_32b(5) <= ctl_ublaze_32b(5);
status_ublaze_32b(6) <= interrupt_status;
status_ublaze_32b(7) <= ctl_ublaze_32b(7);
-- 16 bit status register definition
status_ublaze_16b(0) <= ctl_ublaze_16b(0);
-- 8 bit status register definition
status_ublaze_8b(0) <= ctl_ublaze_8b(0);
aresetn_in <= ( not reset_reg(0));

dma_bd_i: component dma_top
    port map (
      ACLK => ACLK,
      ARESETN => aresetn,
      
      AXI_STR_RXD_tdata => AXI_STR_RXD_0_tdata,
      AXI_STR_RXD_tlast => AXI_STR_RXD_0_tlast,
      AXI_STR_RXD_tready => AXI_STR_RXD_0_tready,
      AXI_STR_RXD_tvalid => AXI_STR_RXD_0_tvalid,

      AXI_STR_RXD_1_tdata => AXI_STR_RXD_1_tdata,
      AXI_STR_RXD_1_tlast => AXI_STR_RXD_1_tlast,
      AXI_STR_RXD_1_tready => AXI_STR_RXD_1_tready,
      AXI_STR_RXD_1_tvalid => AXI_STR_RXD_1_tvalid,

      AXI_STR_RXD_2_tdata => AXI_STR_RXD_2_tdata,
      AXI_STR_RXD_2_tlast => AXI_STR_RXD_2_tlast,
      AXI_STR_RXD_2_tready => AXI_STR_RXD_2_tready,
      AXI_STR_RXD_2_tvalid => AXI_STR_RXD_2_tvalid,

      AXI_STR_RXD_3_tdata => AXI_STR_RXD_3_tdata,
      AXI_STR_RXD_3_tlast => AXI_STR_RXD_3_tlast,
      AXI_STR_RXD_3_tready => AXI_STR_RXD_3_tready,
      AXI_STR_RXD_3_tvalid => AXI_STR_RXD_3_tvalid,

      AXI_STR_RXD_4_tdata => AXI_STR_RXD_4_tdata,
      AXI_STR_RXD_4_tlast => AXI_STR_RXD_4_tlast,
      AXI_STR_RXD_4_tready => AXI_STR_RXD_4_tready,
      AXI_STR_RXD_4_tvalid => AXI_STR_RXD_4_tvalid,

      AXI_STR_RXD_5_tdata => AXI_STR_RXD_5_tdata,
      AXI_STR_RXD_5_tlast => AXI_STR_RXD_5_tlast,
      AXI_STR_RXD_5_tready => AXI_STR_RXD_5_tready,
      AXI_STR_RXD_5_tvalid => AXI_STR_RXD_5_tvalid,

      AXI_STR_RXD_6_tdata => AXI_STR_RXD_6_tdata,
      AXI_STR_RXD_6_tlast => AXI_STR_RXD_6_tlast,
      AXI_STR_RXD_6_tready => AXI_STR_RXD_6_tready,
      AXI_STR_RXD_6_tvalid => AXI_STR_RXD_6_tvalid,

      AXI_STR_RXD_7_tdata => AXI_STR_RXD_7_tdata,
      AXI_STR_RXD_7_tlast => AXI_STR_RXD_7_tlast,
      AXI_STR_RXD_7_tready => AXI_STR_RXD_7_tready,
      AXI_STR_RXD_7_tvalid => AXI_STR_RXD_7_tvalid,

      AXI_STR_RXD_8_tdata => AXI_STR_RXD_8_tdata,
      AXI_STR_RXD_8_tlast => AXI_STR_RXD_8_tlast,
      AXI_STR_RXD_8_tready => AXI_STR_RXD_8_tready,
      AXI_STR_RXD_8_tvalid => AXI_STR_RXD_8_tvalid,

      AXI_STR_RXD_9_tdata => AXI_STR_RXD_9_tdata,
      AXI_STR_RXD_9_tlast => AXI_STR_RXD_9_tlast,
      AXI_STR_RXD_9_tready => AXI_STR_RXD_9_tready,
      AXI_STR_RXD_9_tvalid => AXI_STR_RXD_9_tvalid,

      AXI_STR_RXD_10_tdata => AXI_STR_RXD_10_tdata,
      AXI_STR_RXD_10_tlast => AXI_STR_RXD_10_tlast,
      AXI_STR_RXD_10_tready => AXI_STR_RXD_10_tready,
      AXI_STR_RXD_10_tvalid => AXI_STR_RXD_10_tvalid,

      AXI_STR_RXD_11_tdata => AXI_STR_RXD_11_tdata,
      AXI_STR_RXD_11_tlast => AXI_STR_RXD_11_tlast,
      AXI_STR_RXD_11_tready => AXI_STR_RXD_11_tready,
      AXI_STR_RXD_11_tvalid => AXI_STR_RXD_11_tvalid,

      AXI_STR_RXD_12_tdata => AXI_STR_RXD_12_tdata,
      AXI_STR_RXD_12_tlast => AXI_STR_RXD_12_tlast,
      AXI_STR_RXD_12_tready => AXI_STR_RXD_12_tready,
      AXI_STR_RXD_12_tvalid => AXI_STR_RXD_12_tvalid,

      AXI_STR_RXD_13_tdata => AXI_STR_RXD_13_tdata,
      AXI_STR_RXD_13_tlast => AXI_STR_RXD_13_tlast,
      AXI_STR_RXD_13_tready => AXI_STR_RXD_13_tready,
      AXI_STR_RXD_13_tvalid => AXI_STR_RXD_13_tvalid,

      AXI_STR_RXD_14_tdata => AXI_STR_RXD_14_tdata,
      AXI_STR_RXD_14_tlast => AXI_STR_RXD_14_tlast,
      AXI_STR_RXD_14_tready => AXI_STR_RXD_14_tready,
      AXI_STR_RXD_14_tvalid => AXI_STR_RXD_14_tvalid,

      AXI_STR_RXD_15_tdata => AXI_STR_RXD_15_tdata,
      AXI_STR_RXD_15_tlast => AXI_STR_RXD_15_tlast,
      AXI_STR_RXD_15_tready => AXI_STR_RXD_15_tready,
      AXI_STR_RXD_15_tvalid => AXI_STR_RXD_15_tvalid,

      AXI_STR_RXD_16_tdata => AXI_STR_RXD_16_tdata,
      AXI_STR_RXD_16_tlast => AXI_STR_RXD_16_tlast,
      AXI_STR_RXD_16_tready => AXI_STR_RXD_16_tready,
      AXI_STR_RXD_16_tvalid => AXI_STR_RXD_16_tvalid,

      AXI_STR_RXD_17_tdata => AXI_STR_RXD_17_tdata,
      AXI_STR_RXD_17_tlast => AXI_STR_RXD_17_tlast,
      AXI_STR_RXD_17_tready => AXI_STR_RXD_17_tready,
      AXI_STR_RXD_17_tvalid => AXI_STR_RXD_17_tvalid,

      AXI_STR_RXD_18_tdata => AXI_STR_RXD_18_tdata,
      AXI_STR_RXD_18_tlast => AXI_STR_RXD_18_tlast,
      AXI_STR_RXD_18_tready => AXI_STR_RXD_18_tready,
      AXI_STR_RXD_18_tvalid => AXI_STR_RXD_18_tvalid,

      AXI_STR_RXD_19_tdata => AXI_STR_RXD_19_tdata,
      AXI_STR_RXD_19_tlast => AXI_STR_RXD_19_tlast,
      AXI_STR_RXD_19_tready => AXI_STR_RXD_19_tready,
      AXI_STR_RXD_19_tvalid => AXI_STR_RXD_19_tvalid,

      AXI_STR_RXD_20_tdata => AXI_STR_RXD_20_tdata,
      AXI_STR_RXD_20_tlast => AXI_STR_RXD_20_tlast,
      AXI_STR_RXD_20_tready => AXI_STR_RXD_20_tready,
      AXI_STR_RXD_20_tvalid => AXI_STR_RXD_20_tvalid,

      AXI_STR_RXD_21_tdata => AXI_STR_RXD_21_tdata,
      AXI_STR_RXD_21_tlast => AXI_STR_RXD_21_tlast,
      AXI_STR_RXD_21_tready => AXI_STR_RXD_21_tready,
      AXI_STR_RXD_21_tvalid => AXI_STR_RXD_21_tvalid,

      AXI_STR_RXD_22_tdata => AXI_STR_RXD_22_tdata,
      AXI_STR_RXD_22_tlast => AXI_STR_RXD_22_tlast,
      AXI_STR_RXD_22_tready => AXI_STR_RXD_22_tready,
      AXI_STR_RXD_22_tvalid => AXI_STR_RXD_22_tvalid,

      AXI_STR_RXD_23_tdata => AXI_STR_RXD_23_tdata,
      AXI_STR_RXD_23_tlast => AXI_STR_RXD_23_tlast,
      AXI_STR_RXD_23_tready => AXI_STR_RXD_23_tready,
      AXI_STR_RXD_23_tvalid => AXI_STR_RXD_23_tvalid,

      AXI_STR_RXD_24_tdata => AXI_STR_RXD_24_tdata,
      AXI_STR_RXD_24_tlast => AXI_STR_RXD_24_tlast,
      AXI_STR_RXD_24_tready => AXI_STR_RXD_24_tready,
      AXI_STR_RXD_24_tvalid => AXI_STR_RXD_24_tvalid,

      AXI_STR_RXD_25_tdata => AXI_STR_RXD_25_tdata,
      AXI_STR_RXD_25_tlast => AXI_STR_RXD_25_tlast,
      AXI_STR_RXD_25_tready => AXI_STR_RXD_25_tready,
      AXI_STR_RXD_25_tvalid => AXI_STR_RXD_25_tvalid,

      AXI_STR_RXD_26_tdata => AXI_STR_RXD_26_tdata,
      AXI_STR_RXD_26_tlast => AXI_STR_RXD_26_tlast,
      AXI_STR_RXD_26_tready => AXI_STR_RXD_26_tready,
      AXI_STR_RXD_26_tvalid => AXI_STR_RXD_26_tvalid,

      AXI_STR_RXD_27_tdata => AXI_STR_RXD_27_tdata,
      AXI_STR_RXD_27_tlast => AXI_STR_RXD_27_tlast,
      AXI_STR_RXD_27_tready => AXI_STR_RXD_27_tready,
      AXI_STR_RXD_27_tvalid => AXI_STR_RXD_27_tvalid,

      AXI_STR_RXD_28_tdata => AXI_STR_RXD_28_tdata,
      AXI_STR_RXD_28_tlast => AXI_STR_RXD_28_tlast,
      AXI_STR_RXD_28_tready => AXI_STR_RXD_28_tready,
      AXI_STR_RXD_28_tvalid => AXI_STR_RXD_28_tvalid,

      AXI_STR_RXD_29_tdata => AXI_STR_RXD_29_tdata,
      AXI_STR_RXD_29_tlast => AXI_STR_RXD_29_tlast,
      AXI_STR_RXD_29_tready => AXI_STR_RXD_29_tready,
      AXI_STR_RXD_29_tvalid => AXI_STR_RXD_29_tvalid,

      AXI_STR_RXD_30_tdata => AXI_STR_RXD_30_tdata,
      AXI_STR_RXD_30_tlast => AXI_STR_RXD_30_tlast,
      AXI_STR_RXD_30_tready => AXI_STR_RXD_30_tready,
      AXI_STR_RXD_30_tvalid => AXI_STR_RXD_30_tvalid,

      AXI_STR_RXD_31_tdata => AXI_STR_RXD_31_tdata,
      AXI_STR_RXD_31_tlast => AXI_STR_RXD_31_tlast,
      AXI_STR_RXD_31_tready => AXI_STR_RXD_31_tready,
      AXI_STR_RXD_31_tvalid => AXI_STR_RXD_31_tvalid,
      
      AXI_STR_RXD_32_tdata =>  S01_AXI_STR_RXD_32_tdata,
      AXI_STR_RXD_32_tlast =>  S01_AXI_STR_RXD_32_tlast,
      AXI_STR_RXD_32_tready => S01_AXI_STR_RXD_32_tready,
      AXI_STR_RXD_32_tvalid => S01_AXI_STR_RXD_32_tvalid,
    
	
    	S00_AXI1_0_araddr 	=> S00_AXI1_0_araddr, 
      S00_AXI1_0_arburst 	=> S00_AXI1_0_arburst,
      S00_AXI1_0_arcache 	=> S00_AXI1_0_arcache,
      S00_AXI1_0_arlen 	=> S00_AXI1_0_arlen, 
      S00_AXI1_0_arlock 	=> S00_AXI1_0_arlock,
      S00_AXI1_0_arprot 	=> S00_AXI1_0_arprot,
      S00_AXI1_0_arqos 	=> S00_AXI1_0_arqos, 
      S00_AXI1_0_arready 	=> S00_AXI1_0_arready,
      S00_AXI1_0_arsize 	=> S00_AXI1_0_arsize,
      S00_AXI1_0_arvalid 	=> S00_AXI1_0_arvalid,
      S00_AXI1_0_awaddr 	=> S00_AXI1_0_awaddr,
      S00_AXI1_0_awburst 	=> S00_AXI1_0_awburst,
      S00_AXI1_0_awcache 	=> S00_AXI1_0_awcache,
      S00_AXI1_0_awlen 	=> S00_AXI1_0_awlen,
      S00_AXI1_0_awlock 	=> S00_AXI1_0_awlock,
      S00_AXI1_0_awprot 	=> S00_AXI1_0_awprot,
      S00_AXI1_0_awqos	=> S00_AXI1_0_awqos,
      S00_AXI1_0_awready 	=> S00_AXI1_0_awready,
      S00_AXI1_0_awsize 	=> S00_AXI1_0_awsize,
      S00_AXI1_0_awvalid 	=> S00_AXI1_0_awvalid,
      S00_AXI1_0_bready 	=> S00_AXI1_0_bready,
      S00_AXI1_0_bresp 	=> S00_AXI1_0_bresp,
      S00_AXI1_0_bvalid 	=> S00_AXI1_0_bvalid,
      S00_AXI1_0_rdata 	=> S00_AXI1_0_rdata,
      S00_AXI1_0_rlast 	=> S00_AXI1_0_rlast, 
      S00_AXI1_0_rready 	=> S00_AXI1_0_rready,
      S00_AXI1_0_rresp 	=> S00_AXI1_0_rresp, 
      S00_AXI1_0_rvalid 	=> S00_AXI1_0_rvalid,
      S00_AXI1_0_wdata 	=> S00_AXI1_0_wdata, 
      S00_AXI1_0_wlast	=> S00_AXI1_0_wlast,
      S00_AXI1_0_wready 	=> S00_AXI1_0_wready,
      S00_AXI1_0_wstrb 	=> S00_AXI1_0_wstrb, 
      S00_AXI1_0_wvalid 	=> S00_AXI1_0_wvalid,
    
      S00_AXI_0_araddr 	=> S00_AXI_0_araddr, 
      S00_AXI_0_arburst 	=> S00_AXI_0_arburst,
      S00_AXI_0_arcache 	=> S00_AXI_0_arcache,
      S00_AXI_0_arlen 	=> S00_AXI_0_arlen, 
      S00_AXI_0_arlock 	=> S00_AXI_0_arlock, 
      S00_AXI_0_arprot 	=> S00_AXI_0_arprot, 
      S00_AXI_0_arqos 	=> S00_AXI_0_arqos, 
      S00_AXI_0_arready 	=> S00_AXI_0_arready,
      S00_AXI_0_arsize 	=> S00_AXI_0_arsize, 
      S00_AXI_0_arvalid 	=> S00_AXI_0_arvalid,
      S00_AXI_0_awaddr 	=> S00_AXI_0_awaddr, 
      S00_AXI_0_awburst 	=> S00_AXI_0_awburst,
      S00_AXI_0_awcache 	=> S00_AXI_0_awcache,
      S00_AXI_0_awlen 	=> S00_AXI_0_awlen, 
      S00_AXI_0_awlock 	=> S00_AXI_0_awlock, 
      S00_AXI_0_awprot 	=> S00_AXI_0_awprot, 
      S00_AXI_0_awqos 	=> S00_AXI_0_awqos, 
      S00_AXI_0_awready 	=> S00_AXI_0_awready,
      S00_AXI_0_awsize 	=> S00_AXI_0_awsize, 
      S00_AXI_0_awvalid 	=> S00_AXI_0_awvalid,
      S00_AXI_0_bready 	=> S00_AXI_0_bready, 
      S00_AXI_0_bresp 	=> S00_AXI_0_bresp, 
      S00_AXI_0_bvalid 	=> S00_AXI_0_bvalid, 
      S00_AXI_0_rdata 	=> S00_AXI_0_rdata, 
      S00_AXI_0_rlast 	=> S00_AXI_0_rlast, 
      S00_AXI_0_rready 	=> S00_AXI_0_rready, 
      S00_AXI_0_rresp 	=> S00_AXI_0_rresp, 
      S00_AXI_0_rvalid 	=> S00_AXI_0_rvalid, 
      S00_AXI_0_wdata 	=> S00_AXI_0_wdata,
      S00_AXI_0_wlast 	=> S00_AXI_0_wlast, 
      S00_AXI_0_wready 	=> S00_AXI_0_wready, 
      S00_AXI_0_wstrb 	=> S00_AXI_0_wstrb, 
      S00_AXI_0_wvalid 	=> S00_AXI_0_wvalid, 
    
 
      interrupt_0 => interrupt_0,
      interrupt_1 => interrupt_1,
      interrupt_2 => interrupt_2,
      interrupt_3 => interrupt_3,
      interrupt_4 => interrupt_4,
      interrupt_5 => interrupt_5,
      interrupt_6 => interrupt_6,
      interrupt_7 => interrupt_7,
      interrupt_8 => interrupt_8,
      interrupt_9 => interrupt_9,
      interrupt_10 => interrupt_10,
      interrupt_11 => interrupt_11,
      interrupt_12 => interrupt_12,
      interrupt_13 => interrupt_13,
      interrupt_14 => interrupt_14,
      interrupt_15 => interrupt_15,
      interrupt_16 => interrupt_16,
      interrupt_17 => interrupt_17,
      interrupt_18 => interrupt_18,
      interrupt_19 => interrupt_19,
      interrupt_20 => interrupt_20,
      interrupt_21 => interrupt_21,
      interrupt_22 => interrupt_22,
      interrupt_23 => interrupt_23,
      interrupt_24 => interrupt_24,
      interrupt_25 => interrupt_25,
      interrupt_26 => interrupt_26,
      interrupt_27 => interrupt_27,
      interrupt_28 => interrupt_28,
      interrupt_29 => interrupt_29,
      interrupt_30 => interrupt_30,
      interrupt_31 => interrupt_31,
      interrupt_32 => interrupt_32,
  
      control_reg_16b(15 downto 0) => ublaze_ctl_reg_16b,
      control_reg_16b_wr(0) => control_reg_16b_wr(0),
      control_reg_32b(351 downto 0) => ublaze_ctl_reg_32b,
      control_reg_32b_wr(10 downto 0) => control_reg_32b_wr(10 downto 0),
      control_reg_8b(7 downto 0) => ublaze_ctl_reg_8b,
      control_reg_8b_wr(0) => control_reg_8b_wr(0),
      
      status_reg_16b(15 downto 0) =>ublaze_status_reg_16b ,
      status_reg_16b_rd(0) => status_reg_16b_rd(0),
      status_reg_32b(351 downto 0) => ublaze_status_reg_32b,
      status_reg_32b_rd(10 downto 0) => status_reg_32b_rd(10 downto 0),
      status_reg_8b(7 downto 0) => ublaze_status_reg_8b,
      status_reg_8b_rd(0) => status_reg_8b_rd(0)
    );
	
      inst_fmc0_strm_control : axi_stream_control 
        generic  map(
            no_of_channels => 32
            )
            port map
            (
              aclk     		=> aclk,
              aresetn  		=> aresetn_in,
        
          
              S_AXIS_tdata     => S00_AXIS_tdata, 
              S_AXIS_tid       => "000",  
              S_AXIS_tkeep     => "1111", 
              S_AXIS_tlast     => S00_AXIS_tlast ,
              S_AXIS_tready    => S00_AXIS_tready,
              S_AXIS_tvalid    => S00_AXIS_tvalid,
            
          channel_en		  => ctl_ublaze_32b(7),
          dma_en			  => dma_enabled,	
-- AXI Stream Master		 
         M_AXIS_0_tdata   => AXI_STR_RXD_0_tdata, 
         M_AXIS_0_tid     => AXI_STR_RXD_0_tid,   
         M_AXIS_0_tkeep   => AXI_STR_RXD_0_tkeep,  
         M_AXIS_0_tlast   => AXI_STR_RXD_0_tlast, 
         M_AXIS_0_tready  => AXI_STR_RXD_0_tready,
         M_AXIS_0_tvalid  => AXI_STR_RXD_0_tvalid,

         M_AXIS_1_tdata   => AXI_STR_RXD_1_tdata, 
         M_AXIS_1_tid     => AXI_STR_RXD_1_tid,   
         M_AXIS_1_tkeep   => AXI_STR_RXD_1_tkeep,  
         M_AXIS_1_tlast   => AXI_STR_RXD_1_tlast, 
         M_AXIS_1_tready  => AXI_STR_RXD_1_tready,
         M_AXIS_1_tvalid  => AXI_STR_RXD_1_tvalid,

         M_AXIS_2_tdata   => AXI_STR_RXD_2_tdata, 
         M_AXIS_2_tid     => AXI_STR_RXD_2_tid,   
         M_AXIS_2_tkeep   => AXI_STR_RXD_2_tkeep,  
         M_AXIS_2_tlast   => AXI_STR_RXD_2_tlast, 
         M_AXIS_2_tready  => AXI_STR_RXD_2_tready,
         M_AXIS_2_tvalid  => AXI_STR_RXD_2_tvalid,

         M_AXIS_3_tdata   => AXI_STR_RXD_3_tdata, 
         M_AXIS_3_tid     => AXI_STR_RXD_3_tid,   
         M_AXIS_3_tkeep   => AXI_STR_RXD_3_tkeep,  
         M_AXIS_3_tlast   => AXI_STR_RXD_3_tlast, 
         M_AXIS_3_tready  => AXI_STR_RXD_3_tready,
         M_AXIS_3_tvalid  => AXI_STR_RXD_3_tvalid,

         M_AXIS_4_tdata   => AXI_STR_RXD_4_tdata, 
         M_AXIS_4_tid     => AXI_STR_RXD_4_tid,   
         M_AXIS_4_tkeep   => AXI_STR_RXD_4_tkeep,  
         M_AXIS_4_tlast   => AXI_STR_RXD_4_tlast, 
         M_AXIS_4_tready  => AXI_STR_RXD_4_tready,
         M_AXIS_4_tvalid  => AXI_STR_RXD_4_tvalid,

         M_AXIS_5_tdata   => AXI_STR_RXD_5_tdata, 
         M_AXIS_5_tid     => AXI_STR_RXD_5_tid,   
         M_AXIS_5_tkeep   => AXI_STR_RXD_5_tkeep,  
         M_AXIS_5_tlast   => AXI_STR_RXD_5_tlast, 
         M_AXIS_5_tready  => AXI_STR_RXD_5_tready,
         M_AXIS_5_tvalid  => AXI_STR_RXD_5_tvalid,

         M_AXIS_6_tdata   => AXI_STR_RXD_6_tdata, 
         M_AXIS_6_tid     => AXI_STR_RXD_6_tid,   
         M_AXIS_6_tkeep   => AXI_STR_RXD_6_tkeep,  
         M_AXIS_6_tlast   => AXI_STR_RXD_6_tlast, 
         M_AXIS_6_tready  => AXI_STR_RXD_6_tready,
         M_AXIS_6_tvalid  => AXI_STR_RXD_6_tvalid,

         M_AXIS_7_tdata   => AXI_STR_RXD_7_tdata, 
         M_AXIS_7_tid     => AXI_STR_RXD_7_tid,   
         M_AXIS_7_tkeep   => AXI_STR_RXD_7_tkeep,  
         M_AXIS_7_tlast   => AXI_STR_RXD_7_tlast, 
         M_AXIS_7_tready  => AXI_STR_RXD_7_tready,
         M_AXIS_7_tvalid  => AXI_STR_RXD_7_tvalid,

         M_AXIS_8_tdata   => AXI_STR_RXD_8_tdata, 
         M_AXIS_8_tid     => AXI_STR_RXD_8_tid,   
         M_AXIS_8_tkeep   => AXI_STR_RXD_8_tkeep,  
         M_AXIS_8_tlast   => AXI_STR_RXD_8_tlast, 
         M_AXIS_8_tready  => AXI_STR_RXD_8_tready,
         M_AXIS_8_tvalid  => AXI_STR_RXD_8_tvalid,

         M_AXIS_9_tdata   => AXI_STR_RXD_9_tdata, 
         M_AXIS_9_tid     => AXI_STR_RXD_9_tid,   
         M_AXIS_9_tkeep   => AXI_STR_RXD_9_tkeep,  
         M_AXIS_9_tlast   => AXI_STR_RXD_9_tlast, 
         M_AXIS_9_tready  => AXI_STR_RXD_9_tready,
         M_AXIS_9_tvalid  => AXI_STR_RXD_9_tvalid,

         M_AXIS_10_tdata  => AXI_STR_RXD_10_tdata, 
         M_AXIS_10_tid    => AXI_STR_RXD_10_tid,   
         M_AXIS_10_tkeep  => AXI_STR_RXD_10_tkeep,  
         M_AXIS_10_tlast  => AXI_STR_RXD_10_tlast, 
         M_AXIS_10_tready => AXI_STR_RXD_10_tready,
         M_AXIS_10_tvalid => AXI_STR_RXD_10_tvalid,

         M_AXIS_11_tdata  => AXI_STR_RXD_11_tdata, 
         M_AXIS_11_tid    => AXI_STR_RXD_11_tid,   
         M_AXIS_11_tkeep  => AXI_STR_RXD_11_tkeep,  
         M_AXIS_11_tlast  => AXI_STR_RXD_11_tlast, 
         M_AXIS_11_tready => AXI_STR_RXD_11_tready,
         M_AXIS_11_tvalid => AXI_STR_RXD_11_tvalid,

         M_AXIS_12_tdata  => AXI_STR_RXD_12_tdata, 
         M_AXIS_12_tid    => AXI_STR_RXD_12_tid,   
         M_AXIS_12_tkeep  => AXI_STR_RXD_12_tkeep,  
         M_AXIS_12_tlast  => AXI_STR_RXD_12_tlast, 
         M_AXIS_12_tready => AXI_STR_RXD_12_tready,
         M_AXIS_12_tvalid => AXI_STR_RXD_12_tvalid,

         M_AXIS_13_tdata  => AXI_STR_RXD_13_tdata, 
         M_AXIS_13_tid    => AXI_STR_RXD_13_tid,   
         M_AXIS_13_tkeep  => AXI_STR_RXD_13_tkeep,  
         M_AXIS_13_tlast  => AXI_STR_RXD_13_tlast, 
         M_AXIS_13_tready => AXI_STR_RXD_13_tready,
         M_AXIS_13_tvalid => AXI_STR_RXD_13_tvalid,

         M_AXIS_14_tdata  => AXI_STR_RXD_14_tdata, 
         M_AXIS_14_tid    => AXI_STR_RXD_14_tid,   
         M_AXIS_14_tkeep  => AXI_STR_RXD_14_tkeep,  
         M_AXIS_14_tlast  => AXI_STR_RXD_14_tlast, 
         M_AXIS_14_tready => AXI_STR_RXD_14_tready,
         M_AXIS_14_tvalid => AXI_STR_RXD_14_tvalid,

         M_AXIS_15_tdata  => AXI_STR_RXD_15_tdata, 
         M_AXIS_15_tid    => AXI_STR_RXD_15_tid,   
         M_AXIS_15_tkeep  => AXI_STR_RXD_15_tkeep,  
         M_AXIS_15_tlast  => AXI_STR_RXD_15_tlast, 
         M_AXIS_15_tready => AXI_STR_RXD_15_tready,
         M_AXIS_15_tvalid => AXI_STR_RXD_15_tvalid,

         M_AXIS_16_tdata  => AXI_STR_RXD_16_tdata, 
         M_AXIS_16_tid    => AXI_STR_RXD_16_tid,   
         M_AXIS_16_tkeep  => AXI_STR_RXD_16_tkeep,  
         M_AXIS_16_tlast  => AXI_STR_RXD_16_tlast, 
         M_AXIS_16_tready => AXI_STR_RXD_16_tready,
         M_AXIS_16_tvalid => AXI_STR_RXD_16_tvalid,

         M_AXIS_17_tdata  => AXI_STR_RXD_17_tdata, 
         M_AXIS_17_tid    => AXI_STR_RXD_17_tid,   
         M_AXIS_17_tkeep  => AXI_STR_RXD_17_tkeep,  
         M_AXIS_17_tlast  => AXI_STR_RXD_17_tlast, 
         M_AXIS_17_tready => AXI_STR_RXD_17_tready,
         M_AXIS_17_tvalid => AXI_STR_RXD_17_tvalid,

         M_AXIS_18_tdata  => AXI_STR_RXD_18_tdata, 
         M_AXIS_18_tid    => AXI_STR_RXD_18_tid,   
         M_AXIS_18_tkeep  => AXI_STR_RXD_18_tkeep,  
         M_AXIS_18_tlast  => AXI_STR_RXD_18_tlast, 
         M_AXIS_18_tready => AXI_STR_RXD_18_tready,
         M_AXIS_18_tvalid => AXI_STR_RXD_18_tvalid,

         M_AXIS_19_tdata  => AXI_STR_RXD_19_tdata, 
         M_AXIS_19_tid    => AXI_STR_RXD_19_tid,   
         M_AXIS_19_tkeep  => AXI_STR_RXD_19_tkeep,  
         M_AXIS_19_tlast  => AXI_STR_RXD_19_tlast, 
         M_AXIS_19_tready => AXI_STR_RXD_19_tready,
         M_AXIS_19_tvalid => AXI_STR_RXD_19_tvalid,

         M_AXIS_20_tdata  => AXI_STR_RXD_20_tdata, 
         M_AXIS_20_tid    => AXI_STR_RXD_20_tid,   
         M_AXIS_20_tkeep  => AXI_STR_RXD_20_tkeep,  
         M_AXIS_20_tlast  => AXI_STR_RXD_20_tlast, 
         M_AXIS_20_tready => AXI_STR_RXD_20_tready,
         M_AXIS_20_tvalid => AXI_STR_RXD_20_tvalid,

         M_AXIS_21_tdata  => AXI_STR_RXD_21_tdata, 
         M_AXIS_21_tid    => AXI_STR_RXD_21_tid,   
         M_AXIS_21_tkeep  => AXI_STR_RXD_21_tkeep,  
         M_AXIS_21_tlast  => AXI_STR_RXD_21_tlast, 
         M_AXIS_21_tready => AXI_STR_RXD_21_tready,
         M_AXIS_21_tvalid => AXI_STR_RXD_21_tvalid,

         M_AXIS_22_tdata  => AXI_STR_RXD_22_tdata, 
         M_AXIS_22_tid    => AXI_STR_RXD_22_tid,   
         M_AXIS_22_tkeep  => AXI_STR_RXD_22_tkeep,  
         M_AXIS_22_tlast  => AXI_STR_RXD_22_tlast, 
         M_AXIS_22_tready => AXI_STR_RXD_22_tready,
         M_AXIS_22_tvalid => AXI_STR_RXD_22_tvalid,

         M_AXIS_23_tdata  => AXI_STR_RXD_23_tdata, 
         M_AXIS_23_tid    => AXI_STR_RXD_23_tid,   
         M_AXIS_23_tkeep  => AXI_STR_RXD_23_tkeep,  
         M_AXIS_23_tlast  => AXI_STR_RXD_23_tlast, 
         M_AXIS_23_tready => AXI_STR_RXD_23_tready,
         M_AXIS_23_tvalid => AXI_STR_RXD_23_tvalid,

         M_AXIS_24_tdata  => AXI_STR_RXD_24_tdata, 
          M_AXIS_24_tid    => AXI_STR_RXD_24_tid,   
          M_AXIS_24_tkeep  => AXI_STR_RXD_24_tkeep,  
          M_AXIS_24_tlast  => AXI_STR_RXD_24_tlast, 
          M_AXIS_24_tready => AXI_STR_RXD_24_tready,
          M_AXIS_24_tvalid => AXI_STR_RXD_24_tvalid,

          M_AXIS_25_tdata  => AXI_STR_RXD_25_tdata, 
          M_AXIS_25_tid    => AXI_STR_RXD_25_tid,   
          M_AXIS_25_tkeep  => AXI_STR_RXD_25_tkeep,  
          M_AXIS_25_tlast  => AXI_STR_RXD_25_tlast, 
          M_AXIS_25_tready => AXI_STR_RXD_25_tready,
          M_AXIS_25_tvalid => AXI_STR_RXD_25_tvalid,

          M_AXIS_26_tdata  => AXI_STR_RXD_26_tdata, 
          M_AXIS_26_tid    => AXI_STR_RXD_26_tid,   
          M_AXIS_26_tkeep  => AXI_STR_RXD_26_tkeep,  
          M_AXIS_26_tlast  => AXI_STR_RXD_26_tlast, 
          M_AXIS_26_tready => AXI_STR_RXD_26_tready,
          M_AXIS_26_tvalid => AXI_STR_RXD_26_tvalid,

          M_AXIS_27_tdata  => AXI_STR_RXD_27_tdata, 
          M_AXIS_27_tid    => AXI_STR_RXD_27_tid,   
          M_AXIS_27_tkeep  => AXI_STR_RXD_27_tkeep,  
          M_AXIS_27_tlast  => AXI_STR_RXD_27_tlast, 
          M_AXIS_27_tready => AXI_STR_RXD_27_tready,
          M_AXIS_27_tvalid => AXI_STR_RXD_27_tvalid,

          M_AXIS_28_tdata  => AXI_STR_RXD_28_tdata, 
          M_AXIS_28_tid    => AXI_STR_RXD_28_tid,   
          M_AXIS_28_tkeep  => AXI_STR_RXD_28_tkeep,  
          M_AXIS_28_tlast  => AXI_STR_RXD_28_tlast, 
          M_AXIS_28_tready => AXI_STR_RXD_28_tready,
          M_AXIS_28_tvalid => AXI_STR_RXD_28_tvalid,

          M_AXIS_29_tdata  => AXI_STR_RXD_29_tdata, 
          M_AXIS_29_tid    => AXI_STR_RXD_29_tid,   
          M_AXIS_29_tkeep  => AXI_STR_RXD_29_tkeep,  
          M_AXIS_29_tlast  => AXI_STR_RXD_29_tlast, 
          M_AXIS_29_tready => AXI_STR_RXD_29_tready,
          M_AXIS_29_tvalid => AXI_STR_RXD_29_tvalid,

          M_AXIS_30_tdata  => AXI_STR_RXD_30_tdata, 
          M_AXIS_30_tid    => AXI_STR_RXD_30_tid,   
          M_AXIS_30_tkeep  => AXI_STR_RXD_30_tkeep,  
          M_AXIS_30_tlast  => AXI_STR_RXD_30_tlast, 
          M_AXIS_30_tready => AXI_STR_RXD_30_tready,
          M_AXIS_30_tvalid => AXI_STR_RXD_30_tvalid,

          M_AXIS_31_tdata  => AXI_STR_RXD_31_tdata, 
          M_AXIS_31_tid    => AXI_STR_RXD_31_tid,   
          M_AXIS_31_tkeep  => AXI_STR_RXD_31_tkeep,  
          M_AXIS_31_tlast  => AXI_STR_RXD_31_tlast, 
          M_AXIS_31_tready => AXI_STR_RXD_31_tready,
          M_AXIS_31_tvalid => AXI_STR_RXD_31_tvalid
         
         );	
		 



		 


dma_enabled_sig <= data_mover_enable or reset_reg(31);
process(reset_reg,data_mover_state,aclk,dma_enabled_sig,S00_AXIS_tlast,S00_AXIS_tvalid)
begin
	if rising_edge(aclk) then
		if reset_reg(0)='1' then
			data_mover_state <= idle;
		else 
			case data_mover_state is 
				when idle =>
					if dma_enabled_sig ='1' and S00_AXIS_tlast='1' then
						data_mover_state <= last_done1;
					else
						data_mover_state <= idle;
					end if;
				when last_done1 =>
					if S00_AXIS_tlast='1' and S00_AXIS_tvalid ='1' then
						data_mover_state <=  last_done2;
					else
						data_mover_state <= last_done1;
					end if;
				
				when last_done2 =>
					if S00_AXIS_tlast='0'  then
						data_mover_state <=  dwell;
					else
						data_mover_state <= last_done2;
					end if;
								
				when dwell =>
					if dma_enabled_sig = '0' and S00_AXIS_tlast ='1' then
						data_mover_state <= dwell_done;	
					else
						data_mover_state <= dwell;
					end if;
				when dwell_done =>
					data_mover_state <= idle;
				when others =>
					data_mover_state <= idle;
			end case;
        end if;
	end if;
end process;

--dma_enabled <= '1' when ( data_mover_state /= idle) else '0';
dma_enabled <= '1' when dma_enabled_sig = '1' else '0';		 
fifo_we <= S00_AXIS_tlast and S00_AXIS_tvalid and dma_enabled;
interrupt <= fifo_interrupt;
inst_dma_control : dma_fifo_control 
  port map(
  reset 					=> reset_reg(0),
  sys_clk					=> ACLK,
  sys_ce					=>'1',
  interrupt_control_reg		=> int_reg,
  fifo_interrupt			=> fifo_interrupt,
  fifo_we					=> fifo_we,
  fifo_addr					=> fifo_addr,
  interrupt_status_reg		=> interrupt_status,
    dma_enabled				=> dma_enabled
  );


	
	
end STRUCTURE;
