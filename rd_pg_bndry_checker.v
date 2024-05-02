// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------

// This block indicates the data_shifter about the read transfer's page
// boundary expiry to split the on-going read transfer
// and initiate a pending read transfer to the memory.
// In case of any of the above, it provides the next required read address
// for the pending transfer.

`timescale 1ns/1ps
module rd_pg_bndry_checker
   (
dqs_inv,
rst_n,

//From CSR
mem_page_size,
mr_access_reg,

//From data shifter
start_track, // level
stop_read,
min_dqs_cnt_rch,
first_addr,
wr_rd,// wr_rd =0 is for read
xfer_btype,
xfer_mem_len,
mr8_rbx,
cmd,
rd_done_reg,

// To RCV_DQ_FIFO
rcv_dq_fifo_wr_en,
//To block dqs_inv during write; To dqs_non_tgl_checker - rx_path 
cnt,

// To data shifter
rd_pg_bndry_expired, 
rd_last_addr
   );

//----------------BUS WIDTH Declartaions------------------------
parameter AXI_ADDR_WIDTH = 32;
parameter AXI_DATA_WIDTH = 32; // 32 or 64

//--------------STATE declarations------------------------------
localparam IDLE       = 1'b0;
localparam RD_CHECK   = 1'b1;

//
localparam INCR = 2'b01;
localparam WRAP = 2'b10;
localparam DQS_CNT_WIDTH = (AXI_DATA_WIDTH==32) ? 10: ((AXI_DATA_WIDTH==64) ? 11 : 12);

input dqs_inv;
input rst_n;

//From CSR
input [3:0] mem_page_size;
input mr_access_reg;

//From data shifter
input                      start_track; // level
input                      stop_read; // level
output                     min_dqs_cnt_rch;
input [AXI_ADDR_WIDTH-1:0] first_addr;
input                      wr_rd;
input [1:0]                xfer_btype;
input [DQS_CNT_WIDTH-1:0] xfer_mem_len;
input                      mr8_rbx;
input [7:0]                cmd;
input                      rd_done_reg;

// To RCV_DQ_FIFO
output                     rcv_dq_fifo_wr_en;
//To block dqs_inv during write; To dqs_non_tgl_checker - rx_path 
output                     cnt;

// To data shifter
output                       rd_pg_bndry_expired; 
output [AXI_ADDR_WIDTH -1:0] rd_last_addr; // this value holds the current write data address in DQ line .

//---------------------REG declarations------------------------------
reg                       cnt, next_cnt;
reg [AXI_ADDR_WIDTH -1:0] rd_last_addr, next_rd_last_addr;
reg                       rcv_dq_fifo_wr_en_int, next_rcv_dq_fifo_wr_en_int;
reg                       rd_pg_bndry_expired, next_rd_pg_bndry_expired;
reg pg_bndry_reached_add3;
reg pg_bndry_reached_add2;
reg [DQS_CNT_WIDTH-1:0] xfer_cnt, next_xfer_cnt;
reg wrap_bndry_reach, next_wrap_bndry_reach; 
reg wrap_size_reach;
reg wrap_size_reach_reg, next_wrap_size_reach_reg;
reg wrap_rchd, next_wrap_rchd;


//---------------------wire declarations------------------------------
wire xfer_type_ne_wrap;
wire xfer_type_eq_wrap;
wire wrap_pg_bnd_rch_wire;
wire [AXI_ADDR_WIDTH-1:0] rd_last_addr_plus3; 
wire [AXI_ADDR_WIDTH-1:0] first_addr_plus2;   

assign xfer_type_ne_wrap = xfer_btype != WRAP;
assign xfer_type_eq_wrap = xfer_btype == WRAP;
assign wrap_pg_bnd_rch_wire = (cnt ? (pg_bndry_reached_add3 && xfer_type_eq_wrap)  :
                              (pg_bndry_reached_add2&&xfer_type_eq_wrap)); // find the page boundary crossing during the wrap read transfer. 
assign rd_last_addr_plus3 = add_3(rd_last_addr);
assign first_addr_plus2   = add_2(first_addr);
assign rcv_dq_fifo_wr_en = mr_access_reg ? 1'b1 : 
                           (rcv_dq_fifo_wr_en_int || ((!rd_pg_bndry_expired) && start_track && (!wr_rd)) );  // removed rd_done_reg since due to this RD_DQ_FIFO data is not written into RCV_DQ_FIFO when a new transfer starts. This makes DQS_TIMEOUT issues unnecessarily. However it is ensured that before starting a new transfer, the RCV_DQ_FIFO is made empty and then only a transfer is triggered. Hence there wont be any scenario like "rcv_dq_fifo getting full once the transfer was already stretching due to almost_fifo_full condition"

//assign rcv_dq_fifo_wr_en = mr_access_reg ? 1'b1 : 
//                           (rcv_dq_fifo_wr_en_int || ((!rd_pg_bndry_expired) && start_track) )  && (!rd_done_reg); // added (!rd_done_reg) to de-assert the rcv_dq_fifo_wr_en once rd_done_reg is asserted. To avoid the rcv_dq_fifo getting full once the transfer was already stretching due to almost_fifo_full condition"

//adder 2 function
function [AXI_ADDR_WIDTH-1:0] add_2 (input [AXI_ADDR_WIDTH-1:0] data_in);
begin
add_2 = data_in + 2;
end
endfunction

//adder 3 function
function  [AXI_ADDR_WIDTH-1:0]  add_3 (input  [AXI_ADDR_WIDTH-1:0] data_in);
begin
add_3 = data_in + 3;
end
endfunction

//Sequential block
always @ (posedge dqs_inv or negedge rst_n)
begin
if(!rst_n)
begin
   cnt                 <= 1'b0;
   rd_last_addr        <= {AXI_ADDR_WIDTH{1'b0}};
   rcv_dq_fifo_wr_en_int   <= 1'b1;
   rd_pg_bndry_expired <= 1'b0; 
   xfer_cnt                  <= {DQS_CNT_WIDTH{1'b0}};
   wrap_bndry_reach    <= 1'b0;
   wrap_size_reach_reg <= 1'b0;
   wrap_rchd           <= 1'b0;
end
else
begin
   cnt                 <= next_cnt;
   rd_last_addr        <= next_rd_last_addr;   
   rcv_dq_fifo_wr_en_int   <= next_rcv_dq_fifo_wr_en_int;
   rd_pg_bndry_expired <= next_rd_pg_bndry_expired;
   xfer_cnt           <= next_xfer_cnt; 
   wrap_bndry_reach   <= next_wrap_bndry_reach;
   wrap_size_reach_reg <= next_wrap_size_reach_reg;
   wrap_rchd           <= next_wrap_rchd;
end
end

//wrap boundary check
always @ *
begin
case(xfer_mem_len)  // extra transfer length is not possible for wrap transfers henceforth
'd8:  wrap_size_reach = cnt ? rd_last_addr_plus3[3:0]==0 : first_addr_plus2[3:0]==0;    // wrap size = 16 bytes
'd16: wrap_size_reach = cnt ? rd_last_addr_plus3[4:0]==0 : first_addr_plus2[4:0]==0;    // wrap size = 32 bytes
'd32: wrap_size_reach = cnt ? rd_last_addr_plus3[5:0]==0 : first_addr_plus2[5:0]==0;    // wrap size = 64 bytes
default:  wrap_size_reach = 1'b0;
endcase
end

//read page boundary detection based on the page size programmed in CSR - for
//the subsequent read data in a read transfer
always @ *
begin
   case(mem_page_size)
   'd6: pg_bndry_reached_add3 = rd_last_addr_plus3[5:0]==6'd0;   // 64     
   'd7: pg_bndry_reached_add3 = rd_last_addr_plus3[6:0]==7'd0;   // 128 
   'd8: pg_bndry_reached_add3 = rd_last_addr_plus3[7:0]==8'd0;   // 256
   'd9: pg_bndry_reached_add3 = rd_last_addr_plus3[8:0]==9'd0;   // 512
   'd10: pg_bndry_reached_add3 = rd_last_addr_plus3[9:0]==10'd0;  // 1024
   'd11: pg_bndry_reached_add3 = rd_last_addr_plus3[10:0]==11'd0; // 2048
   'd12: pg_bndry_reached_add3 = rd_last_addr_plus3[11:0]==12'd0; // 4096
   'd13: pg_bndry_reached_add3 = rd_last_addr_plus3[12:0]==13'd0; // 8192
   'd14: pg_bndry_reached_add3 = rd_last_addr_plus3[13:0]==14'd0; // 16384
   'd15: pg_bndry_reached_add3 = rd_last_addr_plus3[14:0]==15'd0; // 32768
    default: pg_bndry_reached_add3 = 1'b0;
   endcase
end

//read page boundary detection based on the page size programmed in CSR - for
//the first read data in a read transfer
always @ *
begin
   case(mem_page_size)
   'd6: pg_bndry_reached_add2 = first_addr_plus2[5:0]==6'd0;   // 64     
   'd7: pg_bndry_reached_add2 = first_addr_plus2[6:0]==7'd0;   // 128 
   'd8: pg_bndry_reached_add2 = first_addr_plus2[7:0]==8'd0;   // 256
   'd9: pg_bndry_reached_add2 = first_addr_plus2[8:0]==9'd0;   // 512
   'd10: pg_bndry_reached_add2 = first_addr_plus2[9:0]==10'd0;  // 1024
   'd11: pg_bndry_reached_add2 = first_addr_plus2[10:0]==11'd0; // 2048
   'd12: pg_bndry_reached_add2 = first_addr_plus2[11:0]==12'd0; // 4096
   'd13: pg_bndry_reached_add2 = first_addr_plus2[12:0]==13'd0; // 8192
   'd14: pg_bndry_reached_add2 = first_addr_plus2[13:0]==14'd0; // 16384
   'd15: pg_bndry_reached_add2 = first_addr_plus2[14:0]==15'd0; // 32768
    default: pg_bndry_reached_add2 = 1'b0;
   endcase
end

// combinational logic
reg [1:0] min_dqs_cnt, next_min_dqs_cnt;
reg min_dqs_cnt_rch, next_min_dqs_cnt_rch;

always @ (posedge dqs_inv or negedge rst_n)
begin
if(~rst_n)
begin
   min_dqs_cnt     <= 2'd0; 
   min_dqs_cnt_rch <= 1'b0;
end
else
begin
   min_dqs_cnt     <= next_min_dqs_cnt;
   min_dqs_cnt_rch <= next_min_dqs_cnt_rch;
end
end

always @ *
begin

next_min_dqs_cnt = min_dqs_cnt;
next_min_dqs_cnt_rch = min_dqs_cnt_rch;

   if(stop_read) 
   begin
      next_min_dqs_cnt     = 2'd0;
      next_min_dqs_cnt_rch = 1'b0 ;
   end
   else
   begin
      next_min_dqs_cnt     = min_dqs_cnt==3 ? min_dqs_cnt : min_dqs_cnt + 1;
      next_min_dqs_cnt_rch = min_dqs_cnt==3;
   end
end

// combinational logic
always @ *
begin

next_cnt                      = cnt;
next_rd_last_addr             = rd_last_addr;       
next_rcv_dq_fifo_wr_en_int    = rcv_dq_fifo_wr_en_int;  
next_rd_pg_bndry_expired = rd_pg_bndry_expired;
next_xfer_cnt                 = xfer_cnt;
next_wrap_bndry_reach         = wrap_bndry_reach;
next_wrap_size_reach_reg      = wrap_size_reach_reg; // to stop incrementing the adderss once current transfer wrap size is reached. Then start incrementing for the continous INCR read data in the same transfer, if any
next_wrap_rchd                = wrap_rchd;

   if(stop_read) 
   begin
    next_cnt                      = 1'b0;
    next_rd_last_addr             = rd_pg_bndry_expired || (!rcv_dq_fifo_wr_en_int) ? rd_last_addr : rd_last_addr + 2;
    next_rcv_dq_fifo_wr_en_int    = 1'b0;
    //next_rd_last_addr             = rd_pg_bndry_expired || (!rcv_dq_fifo_wr_en_int) ? rd_last_addr : rd_last_addr + 2;
    //next_rcv_dq_fifo_wr_en_int    = mr_access_reg ? 1'b1 : rd_pg_bndry_expired ? 1'b0 : rcv_dq_fifo_wr_en_int;
    //next_rcv_dq_fifo_wr_en_int    = mr_access_reg ? 1'b1 : 1'b0; // need to
    //assert wr_en when start_track is de-asserted due to tcem_expiry. After
    //start_track de-assetion only one DQS toggling is possible and hence it
    //wont write for page boundary crossed data
    next_xfer_cnt                 = {DQS_CNT_WIDTH{1'b0}};
    next_rd_pg_bndry_expired      = 1'b0;
    next_wrap_bndry_reach         = 1'b0;
    next_wrap_size_reach_reg      = 1'b0;
    next_wrap_rchd                = 1'b0;
   end
   else
   begin
      if(rd_pg_bndry_expired)
      begin
         next_xfer_cnt                 = {DQS_CNT_WIDTH{1'b0}};
         next_cnt                      = 1'b0;
         next_rd_last_addr             = rd_last_addr;
         next_rcv_dq_fifo_wr_en_int    = 1'b0; 
         next_rd_pg_bndry_expired = 1'b1;
         next_wrap_bndry_reach         = 1'b0;
         next_wrap_size_reach_reg      = 1'b0;
         next_wrap_rchd                = 1'b0;
      end
      else
      begin
         next_cnt                      = 1'b1;
         next_xfer_cnt                 = cnt && (|xfer_cnt) ? xfer_cnt-1 :  xfer_mem_len-1;
         next_rd_last_addr             = rd_pg_bndry_expired || wrap_bndry_reach || (wrap_size_reach_reg && xfer_cnt!=0)  ? rd_last_addr : 
					 (cnt ? rd_last_addr + 2 : first_addr + 1);
         next_rcv_dq_fifo_wr_en_int    = mr8_rbx && cmd== 'h 20 ? 1'b1 : rd_pg_bndry_expired ? rcv_dq_fifo_wr_en_int :
                                         (cnt ? !(pg_bndry_reached_add3 && xfer_type_ne_wrap) : 
					 !(pg_bndry_reached_add2 && xfer_type_ne_wrap)) && (!(wrap_bndry_reach && xfer_cnt==1)) && 
                                         (!(wrap_pg_bnd_rch_wire && xfer_cnt==1));
         next_rd_pg_bndry_expired = mr8_rbx && cmd == 'h 20 ? 1'b0 : rd_pg_bndry_expired ? rd_pg_bndry_expired :
                                	 (cnt ? (pg_bndry_reached_add3 && xfer_type_ne_wrap)  : 
					 (pg_bndry_reached_add2&&xfer_type_ne_wrap)) || (wrap_pg_bnd_rch_wire && xfer_cnt==1) ||
	                                 (wrap_bndry_reach && (xfer_cnt==1)); // xfer_cnt is always > 8 for wrap; they are 8, 16, 32
         next_wrap_bndry_reach         = mr8_rbx && cmd == 'h 20 ? 1'b0 : wrap_bndry_reach ? wrap_bndry_reach : 
                                         wrap_pg_bnd_rch_wire;
         next_wrap_size_reach_reg      = wrap_size_reach && xfer_type_eq_wrap && (!wrap_rchd) ? 1'b1 : ((xfer_cnt==1 || xfer_cnt==0) ? 1'b0 :  wrap_size_reach_reg);
         next_wrap_rchd                = wrap_size_reach && xfer_type_eq_wrap ? 1'b1 : wrap_rchd;

      end
   end
end
endmodule
