// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------

// This block provides the write/read command to the data_shifter during memory array, mode
// register and sepecial instruction transfers. This command is placed during
// the command phase of a PSRAM transfer.

`timescale 1ns/1ps
module cmd_selector
   (
mem_clk,
rst_n,

// From AXI4_SLV_CNTRL
mem_mr_xfer_valid,
mem_mr_error,
mem_mr_xfer_wr_rd,
mem_mr_xfer_btype,

//From SPL_INSTRN_HANDLR
spl_dpd_entry_valid, // pulse
spl_hs_entry_valid,
spl_global_reset_valid,

//From Data shifter
mr8_btype,

// From CSR
mr_access,
linear_burst_wr,
linear_burst_rd,
sync_wr,
sync_rd,
global_reset_cmd,
mode_reg_wr,
mode_reg_rd,

// To data_shifter
cmd
   );

localparam WRAP = 2'b10;

input mem_clk;
input rst_n;

// From AXI4_SLV_CNTRL
input       mem_mr_xfer_valid;
input [1:0] mem_mr_error;
input       mem_mr_xfer_wr_rd;
input [1:0] mem_mr_xfer_btype;

//From SPL_INSTRN_HANDLR
input       spl_dpd_entry_valid; // pulse
input       spl_hs_entry_valid;
input       spl_global_reset_valid;

//From Data shifter
input        mr8_btype;

// From CSR
input       mr_access;
input [7:0] linear_burst_wr;
input [7:0] linear_burst_rd;
input [7:0] sync_wr;
input [7:0] sync_rd;
input [7:0] global_reset_cmd;
input [7:0] mode_reg_wr;
input [7:0] mode_reg_rd;

// To data_shifter
output [7:0] cmd;

reg [7:0] cmd, next_cmd;

always @ (posedge mem_clk or negedge rst_n)
begin
if(~rst_n)
begin
   cmd  <= 8'd0;
end
else
begin
   cmd  <= next_cmd;
end
end

always @ *
begin


if(spl_dpd_entry_valid ||spl_hs_entry_valid) 
begin
   next_cmd  = mode_reg_wr; 
end 
else if(spl_global_reset_valid) 
begin
   next_cmd       = global_reset_cmd; 
end
else if(mem_mr_xfer_valid && (!(|mem_mr_error))) 
begin
   if(mr_access) // mode register
   begin
      next_cmd       = mem_mr_xfer_wr_rd ? mode_reg_wr : mode_reg_rd;
   end
   else // memory array access 
   begin
      if(mem_mr_xfer_wr_rd) // write
      begin
         next_cmd       = mem_mr_xfer_btype==WRAP ? sync_wr : linear_burst_wr;
      end
      else // read
      begin
         next_cmd       = mem_mr_xfer_btype==WRAP ? sync_rd : linear_burst_rd;
      end
   end
end
else 
begin
         next_cmd = cmd;
end
end

endmodule
