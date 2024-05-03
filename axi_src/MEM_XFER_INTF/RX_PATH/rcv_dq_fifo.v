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

module rcv_dq_fifo 
  (
   // Outputs
   dout, 
   fifo_empty, 
   fifo_pre_empty,
   fifo_full,
   fifo_pre_full,
   fifo_almost_full,
   fifo_almost_full_early,
   fifo_almost_empty,
   fifo_non_empty,
   rd_en_final,
   rcv_dq_fifo_data_avail,
   g2b_read_waddr,
   dqs_pulse,

   // Inputs
   rst_n, 
   mem_clk,
   rd_en, 
   flush,
   dqs_inv, 
   wr_en, 
   din
   );

   parameter FIFO_ADDR_WIDTH = 4;
   parameter FIFO_DATA_WIDTH = 16;
   
   localparam FIFO_DEPTH = 1<<FIFO_ADDR_WIDTH;
   localparam ALMOST_FULL_REM_DEPTH = 10; // not lesser than this - PSRAM-AHB read prefetch
   localparam ALMOST_FULL_EARLY_REM_DEPTH = 16;
   localparam ALMOST_EMPTY_REM_DEPTH = 8;
   localparam NON_EMPTY_REM_DEPTH = FIFO_DEPTH - ALMOST_FULL_REM_DEPTH - 5 ; // don't make the value of 5 lesser than this..

   localparam FIFO_DEPTH_INT = 1<<(FIFO_ADDR_WIDTH+1);
   
   // Outputs
   output [FIFO_DATA_WIDTH-1:0] dout;
   output                       fifo_empty;
   output                       fifo_pre_empty;
   output                       fifo_full;
   output                       fifo_pre_full;
   output                       fifo_almost_full;
   output                       fifo_almost_full_early;
   output                       fifo_almost_empty;
   output                       fifo_non_empty;
   output                       rd_en_final;
   output [FIFO_ADDR_WIDTH:0]    rcv_dq_fifo_data_avail;
   output [FIFO_ADDR_WIDTH:0]   g2b_read_waddr;
   output dqs_pulse;
   
   // Inputs
   input                        rst_n;
   input                        mem_clk;
   input                        rd_en;
   input                        flush;
   input                        dqs_inv;
   input                        wr_en;
   input [FIFO_DATA_WIDTH-1:0]  din;
   
   reg [FIFO_DATA_WIDTH-1:0]   dout;
   reg                         fifo_empty;
   reg                         fifo_full;

   wire                        rd_en_final;
   wire                        wr_en_final;
   wire [FIFO_ADDR_WIDTH:0]    read_addr;
   wire [FIFO_ADDR_WIDTH:0]    next_read_addr;
   wire [FIFO_ADDR_WIDTH:0]    write_addr;
   wire [FIFO_ADDR_WIDTH:0]    next_write_addr;
   wire [FIFO_ADDR_WIDTH-1:0]  read_ptr;
   wire [FIFO_ADDR_WIDTH-1:0]  write_ptr;
   
   // for sync
   wire[FIFO_ADDR_WIDTH:0]  rd_addr_sync2;
   wire [FIFO_ADDR_WIDTH:0]  wr_addr_sync2;

   reg [FIFO_DATA_WIDTH-1:0] memory_block [0:(1<<FIFO_ADDR_WIDTH)-1];

   wire                      fifo_pre_empty;
   wire                      fifo_pre_full;
   reg                       fifo_almost_full;
   reg                       fifo_almost_full_early;
   reg                       fifo_almost_empty;
   reg                       fifo_non_empty;
   wire                      fifo_pre_almost_full;
   wire                      fifo_pre_almost_full_early;
   wire                      fifo_pre_almost_empty;
   wire                      fifo_pre_non_empty;

wire [FIFO_ADDR_WIDTH:0]   g2b_write_raddr;
wire [FIFO_ADDR_WIDTH:0]   g2b_write_waddr;
wire [FIFO_ADDR_WIDTH:0]   g2b_write_waddr_int;
wire [FIFO_ADDR_WIDTH:0]   waddr_plus;
wire [FIFO_ADDR_WIDTH:0]   waddr_plus_early;

wire [FIFO_ADDR_WIDTH:0]   g2b_read_raddr;
wire [FIFO_ADDR_WIDTH:0]   g2b_read_waddr;
wire [FIFO_ADDR_WIDTH:0]   raddr_plus;
wire [FIFO_ADDR_WIDTH:0]   raddr_plus_non_empty;
   
   assign rd_en_final = rd_en && ~fifo_empty;
   assign wr_en_final = wr_en;
   //assign wr_en_final = wr_en && ~fifo_full;


   assign fifo_pre_full = (next_write_addr == {~rd_addr_sync2[FIFO_ADDR_WIDTH:FIFO_ADDR_WIDTH-1], rd_addr_sync2[FIFO_ADDR_WIDTH-2:0]});
   assign fifo_pre_empty = (next_read_addr == wr_addr_sync2); 

assign g2b_write_raddr = gray2bin(rd_addr_sync2);
assign g2b_write_waddr = gray2bin(next_write_addr);
assign waddr_plus = g2b_write_waddr + ALMOST_FULL_REM_DEPTH;
assign waddr_plus_early = g2b_write_waddr + ALMOST_FULL_EARLY_REM_DEPTH;

//wire [FIFO_ADDR_WIDTH:0] rem_data_avail;
wire [FIFO_ADDR_WIDTH:0] rcv_dq_fifo_data_avail;
assign g2b_write_waddr_int =  gray2bin(write_addr);

//assign rem_data_avail = g2b_write_waddr[FIFO_ADDR_WIDTH-1:0] > g2b_write_raddr[FIFO_ADDR_WIDTH-1:0] ? (g2b_write_waddr[FIFO_ADDR_WIDTH-1:0] - g2b_write_raddr[FIFO_ADDR_WIDTH-1:0]) : (FIFO_DEPTH - (g2b_write_raddr[FIFO_ADDR_WIDTH-1:0] - g2b_write_waddr[FIFO_ADDR_WIDTH-1:0]));

assign rcv_dq_fifo_data_avail = |(g2b_write_waddr_int[FIFO_ADDR_WIDTH-1:0]^g2b_write_raddr[FIFO_ADDR_WIDTH-1:0]) ? 
(g2b_write_waddr_int[FIFO_ADDR_WIDTH-1:0] > g2b_write_raddr[FIFO_ADDR_WIDTH-1:0] ? (g2b_write_waddr_int[FIFO_ADDR_WIDTH-1:0] - g2b_write_raddr[FIFO_ADDR_WIDTH-1:0]) : (FIFO_DEPTH - (g2b_write_raddr[FIFO_ADDR_WIDTH-1:0] - g2b_write_waddr_int[FIFO_ADDR_WIDTH-1:0])) ) : 'd0;

assign fifo_pre_almost_full = (bin2gray(waddr_plus) == {~rd_addr_sync2[FIFO_ADDR_WIDTH:FIFO_ADDR_WIDTH-1], rd_addr_sync2[FIFO_ADDR_WIDTH-2:0]});
assign fifo_pre_almost_full_early = (bin2gray(waddr_plus_early) == {~rd_addr_sync2[FIFO_ADDR_WIDTH:FIFO_ADDR_WIDTH-1], rd_addr_sync2[FIFO_ADDR_WIDTH-2:0]});
assign fifo_pre_almost_empty = (bin2gray(raddr_plus)) == wr_addr_sync2;
assign fifo_pre_non_empty = (bin2gray(raddr_plus_non_empty)) == wr_addr_sync2;

//assign fifo_pre_almost_full_1 = (waddr_plus[FIFO_ADDR_WIDTH] != g2b_write_raddr[FIFO_ADDR_WIDTH]) && 
//                              (waddr_plus[FIFO_ADDR_WIDTH-1:0] == g2b_write_raddr[FIFO_ADDR_WIDTH-1:0]) ;


//assign fifo_pre_full_1 = (g2b_write_waddr[FIFO_ADDR_WIDTH] != g2b_write_raddr[FIFO_ADDR_WIDTH]) && 
//                       (g2b_write_waddr[FIFO_ADDR_WIDTH-1:0] == g2b_write_raddr[FIFO_ADDR_WIDTH-1:0]) ;

assign g2b_read_waddr = gray2bin(wr_addr_sync2);
assign g2b_read_raddr = gray2bin(next_read_addr);
assign raddr_plus = g2b_read_raddr + ALMOST_EMPTY_REM_DEPTH;
assign raddr_plus_non_empty = g2b_read_raddr + NON_EMPTY_REM_DEPTH;


function[FIFO_ADDR_WIDTH:0] bin2gray (
   input[FIFO_ADDR_WIDTH:0] binary
   );

   reg [FIFO_ADDR_WIDTH:0] i;
   begin
        bin2gray[FIFO_ADDR_WIDTH] = binary[FIFO_ADDR_WIDTH];
       for (i=FIFO_ADDR_WIDTH; i>0; i = i - 1)
           bin2gray[i-1] = binary[i] ^ binary[i - 1];
   end
endfunction

function [FIFO_ADDR_WIDTH:0] gray2bin (
    input [FIFO_ADDR_WIDTH:0] gray
    );

    reg [FIFO_ADDR_WIDTH:0] index;
    reg [FIFO_ADDR_WIDTH:0] result;
begin
    result = gray;
    for (index = 1; index <= FIFO_ADDR_WIDTH; index = index + 1) begin
        result = result ^ (gray >> index);
    end
    gray2bin = result;
end
endfunction

wire [FIFO_ADDR_WIDTH-1:0] write_ptr_in;
assign write_ptr_in = g2b_read_waddr;

// read w.r.t mem_clk 
   rcv_dqfifo_gcntr_rd #(FIFO_ADDR_WIDTH+1) 
   read_gcounter (
                    // Outputs
                    .count              (read_ptr),      
                    .gcount             (read_addr),     
                    .next_gcount        (next_read_addr),
                    // Input
                    .clk                (mem_clk),           
                    .rst_n              (rst_n),       
                    .flush              (flush),
                    .write_ptr_in       (write_ptr_in),
                    .write_addr_in      (wr_addr_sync2),
                    .en                 (rd_en_final));

// syncing to dqs_inv
double_flop_sync
   #(
   .DATA_WIDTH (FIFO_ADDR_WIDTH+1)
    )
   RD_ADDR_SYNC
   (
   . clk      (dqs_inv),
   . rst_n    (rst_n),
   . async_in (read_addr[FIFO_ADDR_WIDTH:0]),
   . sync_out (rd_addr_sync2)
   );

// write w.r.t dqs_inv

   rcv_dqfifo_gcntr_wr #(FIFO_ADDR_WIDTH+1) 
   write_gcounter (
                    // Outputs
                    .count                (write_ptr),      
                    .gcount               (write_addr),     
                    .next_gcount          (next_write_addr),
                    // Inputs
                    .clk                  (dqs_inv),        
                    .rst_n                (rst_n),        
                    .en                   (wr_en_final));         
   
// syncing to mem_clk

double_flop_sync
   #(
   .DATA_WIDTH (FIFO_ADDR_WIDTH+1)
    )
   WR_ADDR_SYNC
   (
   . clk      (mem_clk),
   . rst_n    (rst_n),
   . async_in (write_addr[FIFO_ADDR_WIDTH:0]),
   . sync_out (wr_addr_sync2)
   );

reg dqs_pulse;

always @(posedge dqs_inv or negedge rst_n)
begin
  if(~rst_n)
  dqs_pulse <= 1'b0;
  else
  dqs_pulse <= ~ dqs_pulse;
end
//-------------------------------
// Register Array
//-------------------------------

//write
always @(posedge dqs_inv) begin
   if (wr_en_final)
     memory_block[write_ptr] <=  din[FIFO_DATA_WIDTH-1:0];
end

//read
always @(posedge mem_clk) begin
   if (rd_en_final)
     dout <=  memory_block[read_ptr];
end

always @(posedge mem_clk or negedge rst_n) begin
   if (~rst_n)
     fifo_empty <=  1'b1;
   else if (fifo_pre_empty)
     fifo_empty <=  1'b1;
   else
     fifo_empty <=  1'b0;
end

always @(posedge dqs_inv or negedge rst_n) begin
   if (~rst_n)
     fifo_full <=  1'b0;
   else if (fifo_pre_full)
     fifo_full <=  1'b1;
   else
     fifo_full <=  1'b0;
end

always @(posedge dqs_inv or negedge rst_n) begin
   if (~rst_n)
     fifo_almost_full <=  1'b0;
   else if (fifo_pre_almost_full)
     fifo_almost_full <=  1'b1;
   else
     fifo_almost_full <=  1'b0;
end

always @(posedge dqs_inv or negedge rst_n) begin
   if (~rst_n)
     fifo_almost_full_early <=  1'b0;
   else if (fifo_pre_almost_full_early)
     fifo_almost_full_early <=  1'b1;
   else
     fifo_almost_full_early <=  1'b0;
end

always @(posedge mem_clk or negedge rst_n) begin
   if (~rst_n)
     fifo_almost_empty <=  1'b0;
   else if (fifo_pre_almost_empty)
     fifo_almost_empty <=  1'b1;
   else
     fifo_almost_empty <=  1'b0;
end

always @(posedge mem_clk or negedge rst_n) begin
   if (~rst_n)
     fifo_non_empty <=  1'b0;
   else if (fifo_pre_non_empty)
     fifo_non_empty <=  1'b1;
   else
     fifo_non_empty <=  1'b0;
end

endmodule  
