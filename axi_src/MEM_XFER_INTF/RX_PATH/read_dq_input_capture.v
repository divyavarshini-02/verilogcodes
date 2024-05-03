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
module  read_dq_input_capture(
   // O/P's
   dout, 
   fifo_empty,
   fifo_full,        
   fifo_almost_full,    
   fifo_almost_full_early,    
   fifo_almost_empty,    
   fifo_non_empty,    
   rd_en_final,
   rcv_dq_fifo_data_avail,
   dqs_pulse,
   // I/P's
   mem_clk, 
   rst_n, 
   rd_en, 
   flush,
   dqs, 
   wr_en,
   dq_in
   );

parameter FIFO_ADDR_WIDTH = 4;
parameter FIFO_DATA_WIDTH = 16;
//localparam FIFO_DEPTH = 16;

// ==============================I/Os==========================
   output [15:0] dout;
   output        fifo_empty;
   output        fifo_full;
   output        fifo_almost_full;
   output        fifo_almost_full_early;
   output        fifo_almost_empty;
   output        fifo_non_empty;
   output        rd_en_final;
   output [FIFO_ADDR_WIDTH:0]    rcv_dq_fifo_data_avail;
   output dqs_pulse;

   input         mem_clk;
   input         rst_n;    
   input         rd_en;
   input         flush;
   input         dqs;
   input         wr_en;
   input  [7:0]  dq_in;

// ==============================wires==========================
wire dqs_inv;
wire [15:0] rcv_dqfifo_din;
reg  [7:0]  dq_in_ff;

assign dqs_inv =  ~dqs;
//assign rcv_dqfifo_din = {dq_in[7:0], dq_in_ff[7:0]};
assign rcv_dqfifo_din = {dq_in_ff[7:0], dq_in[7:0]};
   
// DQ MSB data
always @(posedge dqs or negedge rst_n) begin
   if (~rst_n)
     dq_in_ff <=  8'h00;
   else
     dq_in_ff <=  dq_in[7:0];
end

rcv_dq_fifo 
   #(
   . FIFO_ADDR_WIDTH (FIFO_ADDR_WIDTH), 
   . FIFO_DATA_WIDTH (FIFO_DATA_WIDTH))

  rcv_dq_fifo (
            // Outputs
            .dout              (dout[15:0]),   
            .fifo_empty        (fifo_empty),
            .fifo_pre_empty    (),
            .fifo_full         (fifo_full),
            .fifo_pre_full     (),
            .fifo_almost_full  (fifo_almost_full), //pulse
            .fifo_almost_full_early  (fifo_almost_full_early), //pulse
            .fifo_almost_empty (fifo_almost_empty), //pulse
            .fifo_non_empty (fifo_non_empty), //pulse
            .rd_en_final       (rd_en_final),
            .rcv_dq_fifo_data_avail  (rcv_dq_fifo_data_avail ),
            .g2b_read_waddr    (),
            .dqs_pulse (dqs_pulse),
            // Inputs
            .rst_n             (rst_n),
            .mem_clk           (mem_clk),
            .rd_en             (rd_en),
            .flush             (flush),
            .dqs_inv           (dqs_inv),              
            .wr_en             (wr_en),
            .din               (rcv_dqfifo_din[15:0]));

//gen_fifo_async_ctl 
//#(
//  .PTR_WIDTH (FIFO_ADDR_WIDTH)
//)
//rcv_dq_fifo
//   (
//   // Outputs
//   . wdepth            (), 
//   . rdepth            (),
//   . ram_write_strobe  (ram_write_strobe),
//   . ram_write_addr    (ram_write_addr  ),
//   . ram_read_strobe   (ram_read_strobe ),
//   . ram_read_addr     (ram_read_addr   ),
//   . full              (fifo_full),
//   . almost_full       (fifo_almost_full),
//   . empty             (fifo_empty),
//   . dout_v            (),
//   // Inputs          
//   . wusable           (1'b1),
//   . wreset            (~rst_n),
//   . wclk              (dqs_inv),
//   . rusable           (1'b1),
//   . rreset            (~rst_n),
//   . rclk              (mem_clk),
//   . push              (wr_en),
//   . pop               (rd_en)
//);
//
//mem_1w1r # 
//   ( . PTR_WIDTH  (FIFO_ADDR_WIDTH),
//     . DATA_WIDTH (FIFO_DATA_WIDTH),
//     . DEPTH      (FIFO_DEPTH)
//   ) 
//
//rcv_dq_fifo_mem (
//    .wclk                ( dqs_inv),
//    .waddr               ( ram_write_addr ),
//    .wen                 ( ram_write_strobe ),
//    .wdata               ( rcv_dqfifo_din[15:0]),
//
//    .rclk                ( mem_clk ),
//    .raddr               ( ram_read_addr ),
//    .ren                 ( ram_read_strobe),
//    .rdata               ( dout[15:0])
//);
       

endmodule 

