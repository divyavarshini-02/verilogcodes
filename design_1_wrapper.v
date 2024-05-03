//Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2021.1 (lin64) Build 3247384 Thu Jun 10 19:36:07 MDT 2021
//Date        : Tue Nov 22 11:23:22 2022
//Host        : K2 running 64-bit CentOS Linux release 7.9.2009 (Core)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (CS_N,
    DQ,
    SCLK,
    clk_in_n,
    clk_in_p,
    reset_n);
  output CS_N;
  output [3:0]DQ;
  output SCLK;
  input clk_in_n;
  input clk_in_p;
  input reset_n;

  wire CS_N;
  wire [3:0]DQ;
  wire SCLK;
  wire clk_in_n;
  wire clk_in_p;
  wire reset_n;

  design_1 design_1_i
       (.CS_N(CS_N),
        .DQ(DQ),
        .SCLK(SCLK),
        .clk_in_n(clk_in_n),
        .clk_in_p(clk_in_p),
        .reset_n(reset_n));
endmodule
