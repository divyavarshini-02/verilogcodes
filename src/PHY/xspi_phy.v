// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------
module xspi_phy
   (

//Inputs
   mem_clk_0,
   mem_clk_90,
   mem_clk_180,
   rst_n,

   sclk_en,
   ce_n_ip,
   dq_out_ip,
   dq_oe_ip,

//From CSR
   ddr_delay_tap,
   dqs_mode,

//To CNTRL
   dq_in_ip,
   dqs_ip,

//To memory
   ce_n,
   sclk,
   dq,
   dqs
   );

parameter MEM_DQ_BUS_WIDTH              = 8;

input mem_clk_0;
input mem_clk_90;
input mem_clk_180;
input rst_n;

input sclk_en;
input ce_n_ip;
input [15:0]dq_out_ip;
input [15:0] dq_oe_ip;

//From CSR
input [7:0]   ddr_delay_tap;
input         dqs_mode;

//To CNTRL
output [7:0] dq_in_ip;
output       dqs_ip;

//To memory
output                    ce_n;
output                    sclk;

inout  [MEM_DQ_BUS_WIDTH-1:0] dq;
input                     dqs;

//To memory
assign ce_n    = ce_n_ip;

wire [7:0]  dq_in_ip;
wire [15:0] dq_oe_ip;
wire [7:0] dq_out;

assign dq_in_ip = dq[MEM_DQ_BUS_WIDTH-1:0];

genvar i;
for(i=0; i<MEM_DQ_BUS_WIDTH; i=i+1)
begin
assign dq[i] = dq_oe_ip[i] ? dq_out[i] : 1'bz;
end

wire dqs_wire;
wire dqs_delayed;
assign dqs_wire = (dqs_mode) ? sclk : dqs;
//Adesto - data is aligned with dqs, so need to delay dqs and sample
//Macronix spi - sclk will be able to capture the data

clk_gate SCLK_GATE_INST (
      .clk     (mem_clk_90),
      .reset_n (rst_n),
      .en      (sclk_en),
      .gclk    (sclk)
);

dq_out_mux 
   #( .DATA_WIDTH(16))
 
   DQ_OUT_MUX_INST (
      .clk        (mem_clk_0),
      .clk_180    (mem_clk_180),
      .reset_n    (rst_n),
      .dq_out_16  (dq_out_ip),
      .dq_out     (dq_out)
);

uspif_delay_chain DQS_MUXED_DELAY_INST
(
      .tap_in      (ddr_delay_tap),
      .dqs_in      (dqs_wire),
      .dqs_delayed (dqs_delayed)
);

dqs_ip_gated DQS_IP_GATED_INST
( 
   .mem_clk_0(mem_clk_0),
   .mem_rst_n(rst_n),
   .dqs_ip(dqs_delayed),
   .ce_n_ip(ce_n_ip),
   .dq_oe_ip(dq_oe_ip[0]),
   .dqs_ip_gated(dqs_ip)
);

endmodule
