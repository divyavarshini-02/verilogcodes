// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------

// This block indicates the data_shifter about the write transfer's page
// boundary expiry and the tcem_expiry to split the on-going write transfer
// and initiate a pending write transfer to the memory.
// In case of any of the above, it provides the next required write address
// for the pending transfer.

`timescale 1ns/1ps
module wr_tcem_pg_bndry_checker
   (
mem_clk,
rst_n,

//From TIMER_CHECKER
tcem_expired, // pulse

//From CSR
mem_page_size,

//From data shifter
start_track, // pulse
first_addr,
wr_rd,// wr_rd =1 is for write
xfer_btype,
xfer_mem_len,
sclk_en,
ce_n_ip,

// To data shifter
wr_tcem_pg_bndry_expired, 
wr_last_addr
   );

//----------------BUS WIDTH Declartaions------------------------

parameter AXI_ADDR_WIDTH = 32;
parameter AXI_DATA_WIDTH = 32; // 32/64

//--------------STATE declarations------------------------------

localparam IDLE       = 1'b0;
localparam WR_CHECK   = 1'b1;

//
localparam INCR = 2'b01;
localparam WRAP = 2'b10;
localparam DQS_CNT_WIDTH = (AXI_DATA_WIDTH==32) ? 10: ((AXI_DATA_WIDTH==64) ? 11 : 12);

input mem_clk;
input rst_n;

//From TIMER_CHECKER
input tcem_expired; // pulse

//From CSR
input [3:0] mem_page_size;

//From data shifter
input                      start_track; // pulse
input [AXI_ADDR_WIDTH-1:0] first_addr;
input                      wr_rd;
input [1:0]                xfer_btype;
input [DQS_CNT_WIDTH-1:0] xfer_mem_len;
input                      sclk_en;
input                      ce_n_ip;

// To data shifter
output                       wr_tcem_pg_bndry_expired; 
output [AXI_ADDR_WIDTH -1:0] wr_last_addr; 

//---------------------REG declarations------------------------------

reg                       pres_state, next_state;
reg [AXI_ADDR_WIDTH -1:0] addr_cntr, next_addr_cntr;
reg [DQS_CNT_WIDTH-1:0]   xfer_cnt,next_xfer_cnt;
reg [AXI_ADDR_WIDTH -1:0] wr_last_addr, next_wr_last_addr;
reg                       wr_tcem_pg_bndry_expired, next_wr_tcem_pg_bndry_expired;
reg pg_bndry_reached;
reg wrap_size_reach;
reg wrap_size_reach_reg, next_wrap_size_reach_reg;

//wrap boundary check
always @ *
begin
case(xfer_mem_len)  // extra transfer length is not possible for wrap transfers henceforth
'd8:  wrap_size_reach = addr_cntr[3:0]==0;    // wrap size = 16 bytes
'd16: wrap_size_reach = addr_cntr[4:0]==0;    // wrap size = 32 bytes
'd32: wrap_size_reach = addr_cntr[5:0]==0;    // wrap size = 64 bytes
default:  wrap_size_reach = 1'b0;
endcase
end

// sequential block
always @ (posedge mem_clk or negedge rst_n)
begin
   if(~rst_n)
   begin
      pres_state               <=  IDLE;
      addr_cntr                <= {AXI_ADDR_WIDTH{1'b0}};
      xfer_cnt                 <= {DQS_CNT_WIDTH{1'b0}};
      wr_tcem_pg_bndry_expired <= 1'b0; 
      wr_last_addr             <= {AXI_ADDR_WIDTH{1'b0}};
      wrap_size_reach_reg      <= 1'b0;
   end
   else
   begin
      pres_state               <=  next_state;
      addr_cntr                <= next_addr_cntr;
      xfer_cnt                 <= next_xfer_cnt;
      wr_tcem_pg_bndry_expired <= next_wr_tcem_pg_bndry_expired;
      wr_last_addr             <= next_wr_last_addr;
      wrap_size_reach_reg      <= next_wrap_size_reach_reg;
   end
end

//adder 2 function
function  [AXI_ADDR_WIDTH-1:0] add_2 (input  [AXI_ADDR_WIDTH-1:0]  data_in);
begin
add_2 = data_in + 2;
end
endfunction

//write page boundary detection based on the page size programmed in C
always @ *
begin
   case(mem_page_size)
   'd6: pg_bndry_reached = addr_cntr[5:0]==6'd0;    // 64    Bytes
   'd7: pg_bndry_reached = addr_cntr[6:0]==7'd0;    // 128   Bytes
   'd8: pg_bndry_reached = addr_cntr[7:0]==8'd0;    // 256   Bytes
   'd9: pg_bndry_reached = addr_cntr[8:0]==9'd0;    // 512   Bytes
   'd10: pg_bndry_reached = addr_cntr[9:0]==10'd0;  // 1024  Bytes
   'd11: pg_bndry_reached = addr_cntr[10:0]==11'd0; // 2048  Bytes
   'd12: pg_bndry_reached = addr_cntr[11:0]==12'd0; // 4096  Bytes
   'd13: pg_bndry_reached = addr_cntr[12:0]==13'd0; // 8192  Bytes
   'd14: pg_bndry_reached = addr_cntr[13:0]==14'd0; // 16384 Bytes
   'd15: pg_bndry_reached = addr_cntr[14:0]==15'd0; // 32768 Bytes
    default: pg_bndry_reached = 1'b0;
   endcase
end

// combinational block
always @ *
begin

next_addr_cntr                = addr_cntr; // always contains extra 4 address (2 SCLK) corresponding to the current data on DQ line. Since it takes 2 SCLK for the de-assertion of sclk_en after the pg_bndry_reach detection. Hence the address counter is started 2 SCLK before the actual write data phase starts on the DQ line
next_xfer_cnt                 = xfer_cnt;
next_wr_last_addr             = wr_last_addr;
next_wr_tcem_pg_bndry_expired = wr_tcem_pg_bndry_expired;
next_wrap_size_reach_reg      = wrap_size_reach_reg; // to stop incrementing the adderss once current transfer wrap size is reached. Then start incrementing for the continous INCR write data in the same transfer, if any

case(pres_state)
IDLE:
begin
   if(start_track) // trigger to start detecting the page boundary and tcem_expiry; wr_rd= 1 is for write
   begin
      next_addr_cntr = wr_rd ? add_2 (first_addr) : addr_cntr; // first_addr +2; 
      next_state     = wr_rd ? WR_CHECK : pres_state;
      next_xfer_cnt  = wr_rd ? xfer_mem_len-1 : xfer_cnt;
      next_wrap_size_reach_reg  = 1'b0;
   end
   else 
   begin
      next_addr_cntr = addr_cntr; 
      next_state     = pres_state;
   end
end

WR_CHECK:
begin
   next_addr_cntr = xfer_btype==WRAP ? (wrap_size_reach_reg ? addr_cntr : 
                    (wrap_size_reach ? addr_cntr + 'd4 : add_2(addr_cntr))) :add_2(addr_cntr);
   next_wrap_size_reach_reg  = wrap_size_reach && (xfer_btype==WRAP) ? 1'b1 : 
			       (xfer_btype!=WRAP ? 1'b0 : wrap_size_reach_reg);
   next_xfer_cnt  = |xfer_cnt ? xfer_cnt-1 : xfer_cnt;
   if(ce_n_ip)  // write transfer is complete
   begin
      next_wr_tcem_pg_bndry_expired = 1'b0;
      next_wr_last_addr           = wr_last_addr;
      next_addr_cntr              = addr_cntr;
      next_xfer_cnt               = xfer_cnt;
      next_state                  = IDLE;
   end
   else if(tcem_expired)
   begin
      next_wr_tcem_pg_bndry_expired = 1'b1;
      //next_wr_last_addr           = sclk_en ? addr_cntr - 2 : addr_cntr - 4;  // this fix is required
      next_wr_last_addr           = sclk_en ? addr_cntr: addr_cntr - 2; 
      next_addr_cntr              = addr_cntr;
      next_xfer_cnt               = xfer_cnt;
      next_state                  = IDLE;
   end
   else if(!sclk_en)
   begin
      next_wr_tcem_pg_bndry_expired = wr_tcem_pg_bndry_expired ;
      next_state                  = pres_state;
      next_xfer_cnt               = xfer_cnt;
      next_addr_cntr              = xfer_btype==WRAP ? (wrap_size_reach_reg || pg_bndry_reached ? addr_cntr : 
                                    (wrap_size_reach ? addr_cntr + 'd4 : addr_cntr)) :addr_cntr;
   end
   else if(pg_bndry_reached && xfer_btype==WRAP) // assert the wr_tcem_pg_bndry_expired once all the wrap data (xfer_cnt==0 )is transmitted
   begin
      next_wr_tcem_pg_bndry_expired = (|xfer_cnt) || wr_tcem_pg_bndry_expired /* and sclk_en, hene it can be de-asserted for data_shifter*/ ? 1'b0 : 1'b1;
      next_wr_last_addr             = addr_cntr;
      next_addr_cntr                = addr_cntr;
      next_state                    = pres_state;
   end
   else if(pg_bndry_reached && xfer_btype!=WRAP)
   begin
      next_wr_tcem_pg_bndry_expired = 1'b1;
      next_wr_last_addr             = addr_cntr;
      //next_wr_last_addr             = addr_cntr -3;
      next_addr_cntr              = addr_cntr;
      next_state                  = pres_state;
   end
   else
   begin
      next_wr_tcem_pg_bndry_expired = 1'b0;
      next_state                  = pres_state;
   end
end
endcase
end
endmodule
