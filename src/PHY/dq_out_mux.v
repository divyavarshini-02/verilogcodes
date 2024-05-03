// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------
`timescale 1ps/1ps
module dq_out_mux(
      dq_out_16,
      clk,
      clk_180,
      reset_n,
      dq_out
);

parameter DATA_WIDTH = 16;
localparam DATA_WIDTH_HALF = DATA_WIDTH/2;

input [DATA_WIDTH-1:0]      dq_out_16;
input             clk;
input             clk_180;
input             reset_n;
output [DATA_WIDTH_HALF-1:0]      dq_out;


wire              mux_en ;
reg    [DATA_WIDTH_HALF-1:0]      dq_out_16_reg; 

`ifdef ASIC_PHY //For glitch-free mux
  MXGL2_X0P5B_A12TS_C31 dq_clk_mux0_inst  (.Y(dq_out[0]), .A(dq_out_16_reg[0]), .B(dq_out_16[0]), .S0(clk));
  MXGL2_X0P5B_A12TS_C31 dq_clk_mux1_inst  (.Y(dq_out[1]), .A(dq_out_16_reg[1]), .B(dq_out_16[1]), .S0(clk));
  MXGL2_X0P5B_A12TS_C31 dq_clk_mux2_inst  (.Y(dq_out[2]), .A(dq_out_16_reg[2]), .B(dq_out_16[2]), .S0(clk));
  MXGL2_X0P5B_A12TS_C31 dq_clk_mux3_inst  (.Y(dq_out[3]), .A(dq_out_16_reg[3]), .B(dq_out_16[3]), .S0(clk));
  MXGL2_X0P5B_A12TS_C31 dq_clk_mux4_inst  (.Y(dq_out[4]), .A(dq_out_16_reg[4]), .B(dq_out_16[4]), .S0(clk));
  MXGL2_X0P5B_A12TS_C31 dq_clk_mux5_inst  (.Y(dq_out[5]), .A(dq_out_16_reg[5]), .B(dq_out_16[5]), .S0(clk));
  MXGL2_X0P5B_A12TS_C31 dq_clk_mux6_inst  (.Y(dq_out[6]), .A(dq_out_16_reg[6]), .B(dq_out_16[6]), .S0(clk));
  MXGL2_X0P5B_A12TS_C31 dq_clk_mux7_inst  (.Y(dq_out[7]), .A(dq_out_16_reg[7]), .B(dq_out_16[7]), .S0(clk));
`elsif FPGA_PHY  
  BUFGMUX dq_clk_mux0_inst  (.O(dq_out[0]), .I0(dq_out_16_reg[0]), .I1(dq_out_16[0]), .S(clk));
  BUFGMUX dq_clk_mux1_inst  (.O(dq_out[1]), .I0(dq_out_16_reg[1]), .I1(dq_out_16[1]), .S(clk));
  BUFGMUX dq_clk_mux2_inst  (.O(dq_out[2]), .I0(dq_out_16_reg[2]), .I1(dq_out_16[2]), .S(clk));
  BUFGMUX dq_clk_mux3_inst  (.O(dq_out[3]), .I0(dq_out_16_reg[3]), .I1(dq_out_16[3]), .S(clk));
  BUFGMUX dq_clk_mux4_inst  (.O(dq_out[4]), .I0(dq_out_16_reg[4]), .I1(dq_out_16[4]), .S(clk));
  BUFGMUX dq_clk_mux5_inst  (.O(dq_out[5]), .I0(dq_out_16_reg[5]), .I1(dq_out_16[5]), .S(clk));
  BUFGMUX dq_clk_mux6_inst  (.O(dq_out[6]), .I0(dq_out_16_reg[6]), .I1(dq_out_16[6]), .S(clk));
  BUFGMUX dq_clk_mux7_inst  (.O(dq_out[7]), .I0(dq_out_16_reg[7]), .I1(dq_out_16[7]), .S(clk));
`else
  assign dq_out = clk ? dq_out_16[DATA_WIDTH_HALF-1:0] : dq_out_16_reg;

`endif

always @ (posedge clk_180 or negedge reset_n)
begin
      if (!reset_n)
           dq_out_16_reg <=  {DATA_WIDTH_HALF{1'b0}};
      else
           dq_out_16_reg  <=  dq_out_16[DATA_WIDTH-1:DATA_WIDTH_HALF];
end

endmodule
