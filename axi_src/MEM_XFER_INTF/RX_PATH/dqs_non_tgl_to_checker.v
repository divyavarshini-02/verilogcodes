// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------
`timescale 1ns/1ps
module dqs_non_tgl_to_checker
(
 mem_clk,
 reset_n,
 rd_progress, // from data shifter: rd_progress = 1 --> read operation
 ce_n_ip, // from data shifter: ce_n_ip= 0 --> memory array transfer is in progress
 rcv_dq_fifo_empty,
dqs_pulse,
 sclk_en,
 dq_oe,
 dqs_non_tgl_to,

 dqs_timeout
);

input       mem_clk;
input       reset_n;
input       rd_progress;
input       ce_n_ip;
input       rcv_dq_fifo_empty;
input dqs_pulse;
input       sclk_en;
input [4:0] dqs_non_tgl_to;
input       dq_oe;
output      dqs_timeout;

reg dqs_timeout, next_dqs_timeout;
reg [4:0] dqs_to_cntr, next_dqs_to_cntr;
reg dq_oe_d1, dq_oe_d2;
reg dq_oe_fedge_dtd, next_dq_oe_fedge_dtd;
reg dqs_pulse_reg;

always @ (posedge mem_clk or negedge reset_n)
begin
if(~reset_n)
begin
 dqs_timeout     <=  1'b0;
 dqs_to_cntr     <=  5'd0;
 dq_oe_d1        <=  1'b0; // made it zero, since after reset release dq_oe_fedge is detected on setting this to 1. (dq_oe is active low by default)
 dq_oe_d2        <=  1'b0;
 dq_oe_fedge_dtd <=  1'b0;
  dqs_pulse_reg <= 1'b0;
end
else
begin
 dqs_timeout     <=  next_dqs_timeout; 
 dqs_to_cntr     <=  next_dqs_to_cntr;
 dq_oe_d1        <=  dq_oe;
 dq_oe_d2        <=  dq_oe_d1;
 dq_oe_fedge_dtd <=  next_dq_oe_fedge_dtd;
  dqs_pulse_reg <= dqs_pulse;
end
end

wire dq_oe_fedge;
//wire dq_oe_redge;
assign dq_oe_fedge = (!dq_oe_d1) && dq_oe_d2;
//assign dq_oe_redge = dq_oe_d1 && (!dq_oe_d2);

//dq_oe :
//1 - write
//0 - read
always @ *
begin
next_dq_oe_fedge_dtd = dq_oe_fedge ? 1'b1 : ce_n_ip || dqs_timeout ? 1'b0 : dq_oe_fedge_dtd;
next_dqs_to_cntr     = dq_oe_fedge ? dqs_non_tgl_to : dqs_to_cntr;
next_dqs_timeout = 1'b0;

   if(dq_oe_fedge_dtd && (!dqs_timeout) && (!ce_n_ip) && (rd_progress)) // check during read operation alone
   begin
     if(|dqs_to_cntr)
     begin
      next_dqs_timeout = 1'b0;
      next_dqs_to_cntr = rcv_dq_fifo_empty ? dqs_to_cntr - 5'd1 : 
                         (sclk_en && (!(|( dqs_pulse_reg ^ dqs_pulse)))) ? dqs_to_cntr - 5'd1 : 
                         dqs_non_tgl_to;
     end
     else
     begin
     next_dqs_timeout = 1'b1;
     next_dqs_to_cntr = dqs_to_cntr;
     end
   end
   else
   begin
    next_dqs_timeout = 1'b0;
   end
end
endmodule
