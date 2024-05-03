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
module rcv_dqfifo_gcntr_wr (
   // Outputs
   count, gcount, next_gcount, 
   // Inputs
   clk, rst_n, en
   );
   parameter WIDTH = 'd9;

   input clk;
   input rst_n;
   input en;

   output [WIDTH-2:0] count;
   output [WIDTH-1:0] gcount;
   output [WIDTH-1:0] next_gcount;
   
   reg  [WIDTH-1:0]  next_bin_count;
   wire [WIDTH-2:0]  next_bin_count_by2;
   reg  [WIDTH-1:0]  next_gcount;
   reg  [WIDTH-1:0]  gcount;
   reg  [WIDTH-1:0]  bin_count;

 assign next_bin_count_by2 = (next_bin_count>>1);
 assign count = bin_count[WIDTH-2:0];

   always @(posedge clk or negedge rst_n) begin
      if (~rst_n) begin
         bin_count <=  {WIDTH{1'b0}};
         gcount <=  {WIDTH{1'b0}};
      end
      else begin
         bin_count <=  next_bin_count[WIDTH-1:0];
         gcount <=  next_gcount[WIDTH-1:0];
      end
   end

always @ *
begin
next_bin_count = bin_count + en;
next_gcount = next_bin_count ^ {1'b0, next_bin_count_by2};
end
         
endmodule  
