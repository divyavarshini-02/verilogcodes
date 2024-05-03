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
module rcv_cntrl
   (
   mem_clk,
   reset_n,

// AXI slave controller interface
   mem_mr_xfer_valid,
   mem_mr_error,
   mem_mr_xfer_addr_lsb,
   mem_mr_xfer_wr_rd,
   cont_rd_req,
   mem_mr_axi_len,
   mem_mr_xfer_btype,
   mem_mr_xfer_bsize,
   
   mem_mr_rdata_valid,
   mem_mr_rlast,
   mem_mr_rdata_ack,

// From TX_PATH
   xmittr_ack, //pulse

// From DQS non-toggle checker - pulse
   dqs_timeout,

//From MEM_XFER_INTF
   mem_illegal_instrn_err, // level - mem_clk

// TO transmit engine - To control SCLK_EN and CE de-assertion
   rd_done, // pulse - Asserted after all continuous read transfers, if any, are complete

//To mem_mr_xfer_ack resolver
   cont_rd_ack, // pulse - Asserted only for continuous read transfers, provided dqs_timeout event is not happened

// TO AXI_RDATA_CTRL block
   rd_start,  // during every read and continuous read transfer
   rd_addr_lsb,
   rd_xfer_axi_len,
   rd_xfer_btype,
   rd_xfer_bsize,
   rd_err

   );
parameter IDLE               = 2'd0;
parameter RD_PROGRS          = 2'd1;
parameter CONT_RD_PROGRS     = 2'd2;

parameter AHB_DATA_WIDTH=32;
localparam DQS_CNT_WIDTH = (AHB_DATA_WIDTH==32) ? 10: ((AHB_DATA_WIDTH==64) ? 11 : 12);

input          mem_clk;
input          reset_n;

// AXI slave controller interface
input          mem_mr_xfer_valid;
input     mem_mr_error;
input [3:0]    mem_mr_xfer_addr_lsb;
input          mem_mr_xfer_wr_rd;
input          cont_rd_req;

input [7:0]   mem_mr_axi_len;
input [1:0]   mem_mr_xfer_btype;
input [2:0]   mem_mr_xfer_bsize;

input          mem_mr_rdata_valid;
input          mem_mr_rlast;
input          mem_mr_rdata_ack;

// From transmit engine
input          xmittr_ack; //pulse

// From DQS non-toggle checker
input          dqs_timeout;

//From MEM_XFER_INTF
input   mem_illegal_instrn_err; // level - mem_clk

// TO transmit engine - To control SCLK_EN and CE de-assertion
output         rd_done;

//To mem_mr_xfer_ack resolver
output         cont_rd_ack;

// TO AXI_RDATA_CTRL block
output                     rd_start;
output [3:0]               rd_addr_lsb;
output [7:0]               rd_xfer_axi_len;
output [1:0]               rd_xfer_btype;
output [2:0]               rd_xfer_bsize;
output                rd_err;

reg [1:0] pres_state        , next_state;
reg       rd_done           , next_rd_done;
reg       dqs_to_reg        , next_dqs_to_reg;
reg err_xfer, next_err_xfer;
reg mem_illegal_instrn_err_d1, mem_illegal_instrn_err_redge_reg, nxt_mem_illegal_instrn_err_redge_reg;

wire [3:0]  rd_addr_lsb;      
wire  [7:0] rd_xfer_axi_len;
wire  [1:0] rd_xfer_btype;
wire  [2:0] rd_xfer_bsize;
wire rd_err;

assign rd_addr_lsb     = mem_mr_xfer_addr_lsb;
assign rd_xfer_axi_len = mem_mr_axi_len;
assign rd_xfer_btype   = mem_mr_xfer_btype;
assign rd_xfer_bsize   = mem_mr_xfer_bsize;
assign rd_err          = mem_mr_error;

always @ (posedge mem_clk or negedge reset_n)
begin
   if(!reset_n)
   begin
      pres_state          <= IDLE;
      rd_done             <= 1'b0;
      dqs_to_reg          <= 1'b0;
     err_xfer <= 1'b0;
      mem_illegal_instrn_err_d1 <= 1'b0;
      mem_illegal_instrn_err_redge_reg <= 1'b0;
   end
   else
   begin
      pres_state          <= next_state;
      rd_done             <= next_rd_done;
      dqs_to_reg          <= next_dqs_to_reg;
     err_xfer <= next_err_xfer;
      mem_illegal_instrn_err_d1 <= mem_illegal_instrn_err;
      mem_illegal_instrn_err_redge_reg <= nxt_mem_illegal_instrn_err_redge_reg; 
   end
end

assign mem_illegal_instrn_err_redge = mem_illegal_instrn_err & (!mem_illegal_instrn_err_d1);

//assign cont_rd_ack = mem_mr_rdata_valid & mem_mr_rlast & mem_mr_rdata_ack & (!err_xfer) ?
//                     (mem_mr_xfer_valid & (!mem_mr_xfer_wr_rd) & cont_rd_req) : 1'b0;

//assign rd_start = (mem_mr_xfer_valid & (!mem_mr_xfer_wr_rd) & xmittr_ack) || 
//                  ((mem_mr_rdata_valid & mem_mr_rlast & mem_mr_rdata_ack & (!err_xfer))  ?
//                  (mem_mr_xfer_valid & (!mem_mr_xfer_wr_rd) & cont_rd_req ) : 
//                  1'b0 );

assign cont_rd_ack = mem_mr_rdata_valid & mem_mr_rlast & mem_mr_rdata_ack && (!err_xfer) ?
                     (mem_mr_xfer_valid & (!mem_mr_xfer_wr_rd) & cont_rd_req && (!(|mem_mr_error))) : 1'b0;

assign rd_start = (mem_mr_xfer_valid & (!mem_mr_xfer_wr_rd) & xmittr_ack) || 
                  (mem_mr_rdata_valid & mem_mr_rlast & mem_mr_rdata_ack && (!err_xfer)  ?
                  (mem_mr_xfer_valid & (!mem_mr_xfer_wr_rd) & cont_rd_req && (!(|mem_mr_error))) : 
                  1'b0 );


always @ *
begin

next_state               = pres_state;
next_rd_done             = 1'b0;    
next_dqs_to_reg          = dqs_timeout ? 1'b1 : dqs_to_reg;
nxt_mem_illegal_instrn_err_redge_reg = mem_illegal_instrn_err_redge_reg;
next_err_xfer    = err_xfer;

case(pres_state)
   IDLE:
   begin
      if(mem_mr_xfer_valid & (!mem_mr_xfer_wr_rd) & xmittr_ack)  // fresh read transfer
      begin
         next_state       = RD_PROGRS;
         next_err_xfer    = mem_mr_error;
      end
      else 
      begin
         next_state             = pres_state;
      end
   end
   RD_PROGRS:
   begin
      nxt_mem_illegal_instrn_err_redge_reg = mem_illegal_instrn_err_redge ? 1'b1 : mem_illegal_instrn_err_redge_reg;
      if(mem_mr_rdata_valid & mem_mr_rlast & mem_mr_rdata_ack)
      begin
         if(dqs_to_reg || mem_illegal_instrn_err_redge_reg) 
         //if(dqs_to_reg || dqs_timeout) 
         begin
               next_dqs_to_reg = 1'b0;
               nxt_mem_illegal_instrn_err_redge_reg = 1'b0;
               next_rd_done    = 1'b1;
               next_state      = IDLE;
         end
         else if(err_xfer)
         begin
            next_rd_done    = 1'b1;
            next_state      = IDLE;
         end
         else if(mem_mr_xfer_valid & (!mem_mr_xfer_wr_rd) & cont_rd_req) // continuous read
         begin
            next_state       = mem_mr_error ? IDLE: CONT_RD_PROGRS;
            //next_err_xfer    = mem_mr_error;
            //next_rd_done     = 1'b0;
            next_rd_done   = mem_mr_error;
         end
         else
         begin
            next_rd_done    = 1'b1;
            next_state      = IDLE;
         end
      end
      else
      begin
            next_state      = pres_state;
      end
   end

   CONT_RD_PROGRS:
   begin
      nxt_mem_illegal_instrn_err_redge_reg = mem_illegal_instrn_err_redge ? 1'b1 : mem_illegal_instrn_err_redge_reg;
      if(mem_mr_rdata_valid & mem_mr_rlast & mem_mr_rdata_ack)
      begin
         if(dqs_to_reg || mem_illegal_instrn_err_redge_reg) 
         //if(dqs_to_reg || dqs_timeout) 
         begin
               next_dqs_to_reg = 1'b0;
               nxt_mem_illegal_instrn_err_redge_reg = 1'b0;
               next_rd_done    = 1'b1;
               next_state      = IDLE;
         end
         //else if(err_xfer)
         //begin
         //   next_rd_done    = 1'b1;
         //   next_state      = IDLE;
         //end
         else if(mem_mr_xfer_valid & (!mem_mr_xfer_wr_rd) & cont_rd_req) // continuous read
         begin
            next_state       = mem_mr_error ? IDLE : pres_state;
            //next_err_xfer    = mem_mr_error;
            //next_rd_done     = 1'b0;
            next_rd_done     = mem_mr_error;
         end
         else
         begin
            next_rd_done    = 1'b1;
            next_state      = IDLE;
         end
      end
      else
      begin
            next_state      = pres_state;
      end
   end
   default;
endcase

end
endmodule


