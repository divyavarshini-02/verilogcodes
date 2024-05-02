// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------

// This block generates the memory interface signals:
//  ce_n_ip,
//  dq_out_ip - posedge and negedge SCLK data
//  dm_ip = posedge and ngegedge SCLK write mask data
//  dq_oe_ip = write data output enable; 0 = read, 1= write
//  dm_oe_ip = data mask output enable; 0 = read DQS ; 1= write DM 



`timescale 1ns/1ps
module data_shifter
   (
//clock and reset
   mem_clk,
   rst_n,

// From AXI4 SLV CNTRL
   mem_mr_xfer_valid,
   mem_mr_error,
   cont_wr_rd_req,
   mem_mr_xfer_wr_rd,
   mem_mr_xfer_btype,
   mem_mr_xfer_addr,
   mem_mr_xfer_len,

   mem_mr_wdata_valid,
   mem_mr_wdata,
   mem_mr_wlast,
   mem_mr_wstrb,

// To AXI4 SLV CNTRL
   mr8_bsize,

// To mem_mr_xfer_ack resolver
   xmittr_ack,

// From mem_mr_xfer_ack resolver
   mem_mr_xfer_ack,

// To mem_mr_wdata_ack_resolver
   xmit_engn_wdata_ack,

// From mem_mr_wdata_ack resolver
   mem_mr_wdata_ack,

//From SPL_INSTRN_HANDLER
   spl_dpd_entry_valid,
   spl_dpd_exit_valid,
   spl_hs_entry_valid,
   spl_hs_exit_valid,
   spl_glbl_reset_valid,

//To SPL_INSTRN_HANDLER
   mem_spl_xfer_in_prgrs,

// To DQS_INV clock gater
   mr_access_reg,

// From CSR
   mr_access,
   dpd_exit_cycle_cnt,
   hs_exit_cycle_cnt,
   mem_base_addr,
   mem_top_addr,

// From CMD_SELECTOR
   cmd,

// To CMD_SELECTOR, To AXI4_SLV_CNTRL
   mr8_btype,

// To WR_TCEM_PG_BNDRY_CHECKER
   start_track, // also to RD_PG_BNDRY_CHECKER 
   wr_rd,       // also to RD_PG_BNDRY_CHECKER 
   first_addr,  // also to RD_PG_BNDRY_CHECKER 
   xfer_btype,
   xfer_mem_len,

// From WR_TCEM_PG_BNDRY_CHECKER
   wr_tcem_pg_bndry_expired,
   wr_last_addr,

// To RD_PG_BNDRY_CHECKER
  mr8_rbx,
  prev_cmd,
  rd_done_reg,

// From RD_PG_BNDRY_CHECKER
  rd_pg_bndry_expired_sync,
  rd_last_addr,
  rd_cnt_sync,
  min_dqs_cnt_rch,

// From RCV_CNTRL
   rd_done,
   rd_stretch,
   dqs_timeout,
   almost_full_reg,

// To RCV_CNTRL
   pending_xfer,

//To RDATA packer (mem_axi_rd)
   rcv_dq_fifo_flush_en,
   rcv_dq_fifo_flush_done,
   
// To TIMER_CHECKER
   spl_instrn_dpd_exit_prgrs,
   spl_instrn_hs_exit_prgrs,
   spl_instrn_glbl_rst_prgrs,

// From TIMER_CHECKER
   tcem_expired,
   tcph_expired,
   trc_expired,
   trst_expired,
   txhs_expired,
   txdpd_expired,

//PHY interface
   sclk_en,
   ce_n_ip,
   dq_out_ip,
   dm_ip,
   dq_oe_ip,
   dm_oe_ip
   );

//=====================parameter====================================

parameter AXI_DATA_WIDTH = 32; // 32/64
parameter FIFO_ADDR_WIDTH = 4;

localparam DQS_CNT_WIDTH = (AXI_DATA_WIDTH==32) ? 10: ((AXI_DATA_WIDTH==64) ? 11 : 12);

localparam INCR = 2'b01;
localparam WRAP = 2'b10;

//======================I/O==========================================

//==================states======================================
parameter IDLE               = 4'd0;
parameter SEND_CMD                = 4'd1;
parameter ADDR               = 4'd2;
parameter TX_LATENCY         = 4'd3;
parameter TX_DATA            = 4'd4; 
parameter WAIT_TR_EXPIRY     = 4'd5;
parameter HS_EXIT            = 4'd6;
parameter DPD_EXIT           = 4'd7;
parameter RD_DATA            = 4'd8;
parameter RD_ERR_FINISH      = 4'd9;
parameter WR_ERR_FINISH      = 4'd10;
parameter WAIT_RCV_DQ_FIFO_FLUSH = 4'd11;


//clock and reset
input                      mem_clk;
input                      rst_n;


// From AXI4 SLV CNTRL
input                      mem_mr_xfer_valid;
input [1:0]                mem_mr_error;
input                      cont_wr_rd_req;
input                      mem_mr_xfer_wr_rd;
input [1:0]                mem_mr_xfer_btype;
input [31:0]               mem_mr_xfer_addr;
input [DQS_CNT_WIDTH-1:0]  mem_mr_xfer_len;

input                      mem_mr_wdata_valid;
input [31:0]               mem_mr_wdata;
input [3:0]                mem_mr_wstrb;
input                      mem_mr_wlast;

// To AXI4 SLV CNTRL
output [1:0]               mr8_bsize;

// To mem_mr_xfer_ack resolver
output                     xmittr_ack;
// From mem_mr_xfer_ack resolver
input                      mem_mr_xfer_ack;

// To mem_mr_wdata_ack_resolver
output                     xmit_engn_wdata_ack;
// From mem_mr_wdata_ack resolver
input                      mem_mr_wdata_ack;

//From SPL_INSTRN_HANDLER
input                      spl_dpd_entry_valid;
input                      spl_dpd_exit_valid;
input                      spl_hs_entry_valid;
input                      spl_hs_exit_valid;
input                      spl_glbl_reset_valid;

//To SPL_INSTRN_HANDLER
output                     mem_spl_xfer_in_prgrs;

// To DQS_INV clock gater
output                     mr_access_reg;

// From CSR
input                      mr_access;
input [3:0]                dpd_exit_cycle_cnt;
input [3:0]                hs_exit_cycle_cnt;
input [24:0]               mem_base_addr;
input [24:0]               mem_top_addr;

// From CMD_SELECTOR
input   [7:0]              cmd;

// To WR_TCEM_PG_BNDRY_CHECKER
output                     start_track; // also to RD_PG_BNDRY_CHECKER 
output                     wr_rd;       // also to RD_PG_BNDRY_CHECKER 
output  [31:0]             first_addr;  // also to RD_PG_BNDRY_CHECKER 
output [1:0]               xfer_btype;
output [DQS_CNT_WIDTH-1:0] xfer_mem_len;

// From WR_TCEM_PG_BNDRY_CHECKER
input                      wr_tcem_pg_bndry_expired;
input   [31:0]             wr_last_addr;

// To RD_PG_BNDRY_CHECKER
output                     mr8_rbx;
output  [7:0]              prev_cmd;
output                     rd_done_reg;

// From RD_PG_BNDRY_CHECKER
input                      rd_pg_bndry_expired_sync;
input  [31:0]              rd_last_addr;
input                      rd_cnt_sync;
input                      min_dqs_cnt_rch;

input tcem_expired;

// From RCV_CNTRL
input                      rd_done;
input                      rd_stretch;
input                      dqs_timeout;
input                      almost_full_reg;

// To RCV_CNTRL
output                     pending_xfer;

//To RDATA packer
output                     rcv_dq_fifo_flush_en;
input                      rcv_dq_fifo_flush_done;

// To CMD_SELECTOR, To AXI4_SLV_CNTRL
output                     mr8_btype;

// To TIMER_CHECKER
output                     spl_instrn_dpd_exit_prgrs;
output                     spl_instrn_hs_exit_prgrs;
output                     spl_instrn_glbl_rst_prgrs;

// From TIMER_CHECKER
input                      tcph_expired;
input                      trc_expired;
input                      trst_expired;
input                      txhs_expired;
input                      txdpd_expired;

//PHY interface
output                     sclk_en;
output                     ce_n_ip;
output   [15:0]            dq_out_ip;
output   [1:0]             dm_ip;
output                     dq_oe_ip;
output                     dm_oe_ip;

//===========================registers========================================

reg [3:0]               pres_state, next_state;
reg [1:0]               mr8_bsize, next_mr8_bsize;                     
reg                     xmittr_ack, next_xmittr_ack;
reg                     xmit_engn_wdata_ack_int, next_xmit_engn_wdata_ack_int;
reg                     mem_spl_xfer_in_prgrs, next_mem_spl_xfer_in_prgrs;
reg                     rcv_dq_fifo_flush_en, next_rcv_dq_fifo_flush_en;
reg                     mr8_btype, next_mr8_btype;
reg                     cmd_ack, next_cmd_ack;
reg                     start_track, next_start_track;
reg                     wr_rd, next_wr_rd;
reg [31:0]              first_addr, next_first_addr;
reg [1:0]               xfer_btype, next_xfer_btype;
reg [DQS_CNT_WIDTH-1:0] xfer_mem_len, next_xfer_mem_len;

reg                     mr8_rbx, next_mr8_rbx;
reg                     sclk_en, next_sclk_en;
reg                     ce_n_ip, next_ce_n_ip;
reg [15:0]              dq_out_ip, next_dq_out_ip;
reg [1:0]               dm_ip, next_dm_ip;
reg                     dq_oe_ip, next_dq_oe_ip;
reg                     dm_oe_ip, next_dm_oe_ip;

reg                     rd_done_reg, next_rd_done_reg; 
reg [3:0]               ce_low_to_low_cntr, next_ce_low_to_low_cntr;
reg                     success_xfer, next_success_xfer;
reg [2:0]               mr4_wr_lat , next_mr4_wr_lat;
reg [7:0]               next_prev_cmd       , prev_cmd;
reg                     next_addr_cycle_cnt , addr_cycle_cnt;
reg [2:0]               next_wait_cntr      , wait_cntr;
reg [1:0]               next_addr_cntr             , addr_cntr             ;
reg                     tcem_expired_reg, next_tcem_expired_reg;
reg                     next_pending_xfer          , pending_xfer          ;
reg                     next_reg_1                  , reg_1                  ;
reg                     next_cnt                   , cnt                   ;
reg [36:0]              next_wr_data_reg0          , wr_data_reg0          ;
reg [36:0]              next_wr_data_reg1          , wr_data_reg1          ;
reg [1:0]               next_wdata_avail_cnt       , wdata_avail_cnt       ;
reg                     next_trc_expired_reg       , trc_expired_reg       ;
reg                     next_tcph_expired_reg      , tcph_expired_reg      ;
reg                     spl_instrn_hs_exit_prgrs, next_spl_instrn_hs_exit_prgrs;
reg                     spl_instrn_dpd_exit_prgrs, next_spl_instrn_dpd_exit_prgrs;
reg                     spl_instrn_glbl_rst_prgrs, next_spl_instrn_glbl_rst_prgrs;
reg                     wr_tcem_pg_bndry_expired_reg, next_wr_tcem_pg_bndry_expired_reg;
reg                     min_one_wr_xfer_cmplt, next_min_one_wr_xfer_cmplt;

reg odd_wrap_wr_xfer, next_odd_wrap_wr_xfer;
reg odd_wrap_wr_rem, next_odd_wrap_wr_rem;
reg [8:0] rem_wr_data, next_rem_wr_data;

reg mr_access_reg, next_mr_access_reg;
reg next_spl_dpd_exit_valid_reg     , spl_dpd_exit_valid_reg   ; 
reg next_spl_dpd_entry_valid_reg    , spl_dpd_entry_valid_reg   ;
reg next_spl_hs_exit_valid_reg      , spl_hs_exit_valid_reg     ;
reg next_spl_hs_entry_valid_reg     , spl_hs_entry_valid_reg    ;
reg next_spl_glbl_reset_valid_reg , spl_glbl_reset_valid_reg;
reg [31:0] wrap_wr_addr; 
reg pending_mr8_wr, next_pending_mr8_wr;
reg mr8_wr_complete, next_mr8_wr_complete;

//-------------------wire declarations-------------------------

wire [31:0]              first_addr_dur_rd_tcem_expiry;
wire last_xfer;
wire cont_wr_xfer_valid;
wire last_xfer_lsb;
wire [3:0]                mem_mr_wmask;
wire mem_boundary_cross;

//-------------- assignments----------------

assign first_addr_dur_rd_tcem_expiry = rd_last_addr + 1;
assign mem_boundary_cross = tcem_expired_reg ? ((first_addr_dur_rd_tcem_expiry < mem_base_addr) || (first_addr_dur_rd_tcem_expiry > mem_top_addr)) : 
                             ((first_addr < mem_base_addr) || (first_addr > mem_top_addr));
assign last_xfer          = reg_1 ? wr_data_reg1[36] : wr_data_reg0 [36];
assign cont_wr_xfer_valid = cont_wr_rd_req & mem_mr_xfer_valid & (!(|mem_mr_error)) & mem_mr_xfer_wr_rd;
//assign cont_rd_xfer_valid = cont_wr_rd_req & mem_mr_xfer_valid & (!(|mem_mr_error)) & (!mem_mr_xfer_wr_rd);
assign last_xfer_lsb      = last_xfer && (reg_1 ? (&wr_data_reg1[35:34]) : (&wr_data_reg0[35:34]));
assign mem_mr_wmask = {!mem_mr_wstrb[3],!mem_mr_wstrb[2], !mem_mr_wstrb[1], !mem_mr_wstrb[0]};
assign xmit_engn_wdata_ack = wdata_avail_cnt==2 ? 1'b0 : xmit_engn_wdata_ack_int;
// wdata_avail_cnt==2, is checked to avoid giving ack when both data_reg0 and data_reg1 are updated

wire 			[6:0] 	req_in_wrap_size;
wire 			[6:0] 	ap_mem_wrap_size;

assign ap_mem_wrap_size= ('b10000) << mr8_bsize;
assign req_in_wrap_size  = mem_mr_xfer_len << 1;

//========================sequential block===============================

always @ (posedge mem_clk or negedge rst_n)
begin
if(~rst_n)
begin
   pres_state                   <= IDLE;
   mr8_bsize                    <= 2'b01;
   xmittr_ack                   <= 1'b0;
   xmit_engn_wdata_ack_int      <= 1'b0;
   mem_spl_xfer_in_prgrs        <= 1'b0;
   mr8_btype                    <= 1'b1;
   rcv_dq_fifo_flush_en         <= 1'b0;
   cmd_ack                      <= 1'b0;
   start_track                  <= 1'b0;
   wr_rd                        <= 1'b0;
   first_addr                   <= 32'd0;
   xfer_btype                   <= 2'd0;
   xfer_mem_len                 <= {DQS_CNT_WIDTH{1'b0}};
   mr8_rbx                      <= 1'b0; // doubt
   sclk_en                      <= 1'b0;
   ce_n_ip                      <= 1'b1;
   dq_out_ip                    <= 16'd0;
   dm_ip                        <= 2'd0;
   dq_oe_ip                     <= 1'b0;
   dm_oe_ip                     <= 1'b0; 

   rd_done_reg                  <= 1'b0;
   ce_low_to_low_cntr           <= 4'd0;
   success_xfer                 <= 1'b0;
   mr4_wr_lat                   <= 3'd5;
   prev_cmd                     <= 8'd0; 
   addr_cycle_cnt               <= 1'b0;
   wait_cntr                    <= 3'd0;
   addr_cntr                    <= 2'd0;
   tcem_expired_reg             <= 1'b0;
   pending_xfer                 <= 1'b0;
   reg_1                        <= 1'b0;
   cnt                          <= 1'b0;
   wr_data_reg0                 <= 37'd0;
   wr_data_reg1                 <= 37'd0;
   wdata_avail_cnt              <= 2'd0;
   trc_expired_reg              <= 1'b0;
   tcph_expired_reg             <= 1'b0;
   spl_instrn_hs_exit_prgrs     <= 1'b0; 
   spl_instrn_dpd_exit_prgrs    <= 1'b0; 
   spl_instrn_glbl_rst_prgrs    <= 1'b0;
   wr_tcem_pg_bndry_expired_reg <= 1'b0;
   min_one_wr_xfer_cmplt        <= 1'b0;

   odd_wrap_wr_xfer             <= 1'b0; 
   odd_wrap_wr_rem              <= 1'b0; 
   rem_wr_data                  <= 9'd0;
   mr_access_reg                <= 1'b1;
   spl_dpd_exit_valid_reg       <= 1'b0; 
   spl_dpd_entry_valid_reg      <= 1'b0;
   spl_hs_exit_valid_reg        <= 1'b0;
   spl_hs_entry_valid_reg       <= 1'b0;
   spl_glbl_reset_valid_reg     <= 1'b0;
pending_mr8_wr  <= 1'b0; 
mr8_wr_complete <= 1'b0; 
end
else
begin
   pres_state                <= next_state;
   mr8_bsize                 <= next_mr8_bsize;
   xmittr_ack                <= next_xmittr_ack           ;
   xmit_engn_wdata_ack_int   <= next_xmit_engn_wdata_ack_int  ;
   mem_spl_xfer_in_prgrs     <= next_mem_spl_xfer_in_prgrs;
   mr8_btype                 <= next_mr8_btype            ;
   rcv_dq_fifo_flush_en      <= next_rcv_dq_fifo_flush_en;
   cmd_ack                   <= next_cmd_ack              ;
   start_track               <= next_start_track          ;
   wr_rd                     <= next_wr_rd                ;
   first_addr                <= next_first_addr           ;
   xfer_btype                <= next_xfer_btype;
   xfer_mem_len              <= next_xfer_mem_len;
   mr8_rbx                   <= next_mr8_rbx              ;
   sclk_en                   <= next_sclk_en              ;
   ce_n_ip                   <= next_ce_n_ip              ;
   dq_out_ip                 <= next_dq_out_ip            ;
   dm_ip                     <= next_dm_ip                ;
   dq_oe_ip                  <= next_dq_oe_ip          ;
   dm_oe_ip                  <= next_dm_oe_ip          ;

   rd_done_reg                  <= next_rd_done_reg;
   ce_low_to_low_cntr           <= next_ce_low_to_low_cntr   ;
   success_xfer                 <= next_success_xfer         ;
   mr4_wr_lat                   <= next_mr4_wr_lat;
   prev_cmd                     <= next_prev_cmd;
   addr_cycle_cnt               <= next_addr_cycle_cnt;
   wait_cntr                    <= next_wait_cntr;     
   addr_cntr                    <= next_addr_cntr              ;
   tcem_expired_reg             <= next_tcem_expired_reg;
   pending_xfer                 <= next_pending_xfer           ;
   reg_1                        <= next_reg_1                   ;
   cnt                          <= next_cnt                    ;
   wr_data_reg0                 <= next_wr_data_reg0           ;
   wr_data_reg1                 <= next_wr_data_reg1           ;
   wdata_avail_cnt              <= next_wdata_avail_cnt        ;
   trc_expired_reg              <= next_trc_expired_reg        ;
   tcph_expired_reg             <= next_tcph_expired_reg       ;
   spl_instrn_hs_exit_prgrs     <= next_spl_instrn_hs_exit_prgrs;
   spl_instrn_dpd_exit_prgrs    <= next_spl_instrn_dpd_exit_prgrs;
   spl_instrn_glbl_rst_prgrs    <=  next_spl_instrn_glbl_rst_prgrs;
   wr_tcem_pg_bndry_expired_reg <= next_wr_tcem_pg_bndry_expired_reg;
   min_one_wr_xfer_cmplt        <= next_min_one_wr_xfer_cmplt;

   odd_wrap_wr_xfer             <= next_odd_wrap_wr_xfer;
   odd_wrap_wr_rem              <= next_odd_wrap_wr_rem;
   rem_wr_data                  <= next_rem_wr_data;     
   mr_access_reg                <= next_mr_access_reg;
   spl_dpd_exit_valid_reg       <= next_spl_dpd_exit_valid_reg   ; 
   spl_dpd_entry_valid_reg      <= next_spl_dpd_entry_valid_reg   ;
   spl_hs_exit_valid_reg        <= next_spl_hs_exit_valid_reg     ;
   spl_hs_entry_valid_reg       <= next_spl_hs_entry_valid_reg    ;
   spl_glbl_reset_valid_reg     <= next_spl_glbl_reset_valid_reg;
pending_mr8_wr  <=  next_pending_mr8_wr  ;
mr8_wr_complete <=  next_mr8_wr_complete ;
end                                                       
end                                                      

//======================combinational block==============================

// logic to increment the incoming wrap address to the start of the same wrap
// boundary size rather than incrementing to the next wrap bounary, when the
// incoming wrap address is already at the end of its wrap boundary.
// This calculation is required only if incoming wrap write address is odd.
always @ *
begin
   case(mr8_bsize)
   'b00: wrap_wr_addr = &mem_mr_xfer_addr[3:0] ? {mem_mr_xfer_addr[31:4],4'd0} : mem_mr_xfer_addr + 32'd1; // 16 byte wrap size
   'b01: wrap_wr_addr = &mem_mr_xfer_addr[4:0] ? {mem_mr_xfer_addr[31:5],5'd0} : mem_mr_xfer_addr + 32'd1; // 32 byte wrap size
   'b10: wrap_wr_addr = &mem_mr_xfer_addr[5:0] ? {mem_mr_xfer_addr[31:6],6'd0} : mem_mr_xfer_addr + 32'd1; // 64 byte wrap size
    default : wrap_wr_addr = mem_mr_xfer_addr;
   endcase
end

//FSM
always @ *
begin

next_state                   = pres_state;
next_mr8_bsize               = mr8_bsize;            
next_xmittr_ack              = 1'b0;
next_mem_spl_xfer_in_prgrs   = mem_spl_xfer_in_prgrs;
next_mr8_btype               = mr8_btype;            
next_rcv_dq_fifo_flush_en    = 1'b0;
next_cmd_ack                 = 1'b0;
next_start_track             = wr_rd ? 1'b0 : start_track;
next_wr_rd                   = wr_rd;     
next_first_addr              = first_addr;
next_xfer_btype              = xfer_btype;
next_xfer_mem_len            = xfer_mem_len;
next_mr8_rbx                 = mr8_rbx;              
next_sclk_en                 = sclk_en;              
next_ce_n_ip                 = ce_n_ip;              
next_dq_out_ip               = dq_out_ip;
next_dm_ip                   = dm_ip;   
next_dq_oe_ip                = dq_oe_ip;          
next_dm_oe_ip                = dm_oe_ip;          
next_rd_done_reg             = rd_done ? 1'b1 : rd_done_reg;
next_ce_low_to_low_cntr      = ce_low_to_low_cntr;   
next_success_xfer            = success_xfer;
next_mr4_wr_lat              = mr4_wr_lat;           
next_prev_cmd                = prev_cmd;
next_addr_cycle_cnt          = addr_cycle_cnt;
next_wait_cntr               = wait_cntr;
next_addr_cntr               = addr_cntr; 
next_tcem_expired_reg        = tcem_expired_reg;
next_pending_xfer            = pending_xfer;
next_reg_1                   = reg_1;
next_cnt                     = cnt==0 && mem_mr_wdata_valid && xmit_engn_wdata_ack ? 1'b1 : cnt;
next_wr_data_reg0            = cnt==0 && mem_mr_wdata_valid && xmit_engn_wdata_ack ?{mem_mr_wlast,mem_mr_wmask,mem_mr_wdata} :wr_data_reg0;
next_wr_data_reg1            = cnt==1 && mem_mr_wdata_valid && xmit_engn_wdata_ack ?{mem_mr_wlast,mem_mr_wmask,mem_mr_wdata} :wr_data_reg1;
next_wdata_avail_cnt         = mem_mr_wdata_valid && xmit_engn_wdata_ack && success_xfer ? wdata_avail_cnt + 1 : wdata_avail_cnt;
next_xmit_engn_wdata_ack_int = cnt==0 && success_xfer ? 1'b1:
                               cnt==1 && success_xfer && (!reg_1) && mem_mr_wdata_valid ? 1'b0 : xmit_engn_wdata_ack_int && success_xfer; 

//next_xmit_engn_wdata_ack_int   = cnt==0 && mem_mr_wdata_valid && success_xfer && (!xmit_engn_wdata_ack_int) ? 1'b1:
//                             cnt==1 && mem_mr_wdata_valid && success_xfer && (!xmit_engn_wdata_ack_int) && (!reg_1) && (wdata_avail_cnt!=2'd2) ? 1'b1 : 1'b0; // wdata_avail_cnt!=2, is checked to avoid giving ack when both data_reg0 and data_reg1 are updated
next_trc_expired_reg           = trc_expired ? 1'b1 : trc_expired_reg  ;
next_tcph_expired_reg          = tcph_expired ? 1'b1 : tcph_expired_reg;
next_spl_instrn_hs_exit_prgrs  = spl_instrn_hs_exit_prgrs;
next_spl_instrn_dpd_exit_prgrs = spl_instrn_dpd_exit_prgrs;
next_spl_instrn_glbl_rst_prgrs = spl_instrn_glbl_rst_prgrs;
next_wr_tcem_pg_bndry_expired_reg = wr_tcem_pg_bndry_expired ? 1'b1 : wr_tcem_pg_bndry_expired_reg;
next_min_one_wr_xfer_cmplt     = min_one_wr_xfer_cmplt;
next_xfer_btype                = mem_mr_xfer_ack ? mem_mr_xfer_btype : xfer_btype;
next_xfer_mem_len              = mem_mr_xfer_ack ? mem_mr_xfer_len : xfer_mem_len;
next_odd_wrap_wr_xfer          = odd_wrap_wr_xfer;
next_odd_wrap_wr_rem           = odd_wrap_wr_rem;
next_rem_wr_data               = rem_wr_data;
next_mr_access_reg             = mr_access_reg;// register the mr_access signal; since it might be de-asserted in the middle of write/read transfer once it gets response in the AXI BRESP' AXI RRESP
next_spl_dpd_exit_valid_reg    = spl_dpd_exit_valid ? 1'b1 : spl_dpd_exit_valid_reg  ;
next_spl_dpd_entry_valid_reg   = spl_dpd_entry_valid ? 1'b1 : spl_dpd_entry_valid_reg ;
next_spl_hs_exit_valid_reg     = spl_hs_exit_valid ? 1'b1 : spl_hs_exit_valid_reg   ;
next_spl_hs_entry_valid_reg    = spl_hs_entry_valid? 1'b1 : spl_hs_entry_valid_reg  ;
next_spl_glbl_reset_valid_reg  = spl_glbl_reset_valid ? 1'b1 : spl_glbl_reset_valid_reg  ;
next_pending_mr8_wr  = pending_mr8_wr;
next_mr8_wr_complete = mr8_wr_complete;

case(pres_state)

IDLE:
begin
next_sclk_en = 1'b0;
next_ce_n_ip = 1'b1;
next_mem_spl_xfer_in_prgrs = 1'b0;
next_dq_oe_ip      = 1'b0;
next_dm_oe_ip         = 1'b0;
next_trc_expired_reg   = 1'b0; // reset required during HS entry and DPD entry
next_tcph_expired_reg  = 1'b0; // reset required during HS entry and DPD entry

   if(mem_mr_xfer_valid)
   begin
      if(|mem_mr_error)
      begin
         next_success_xfer = 1'b0; 
         next_xmittr_ack   = 1'b1;
         next_state        = mem_mr_xfer_wr_rd ? WR_ERR_FINISH : RD_ERR_FINISH;
      end
      else
      begin
        if(mem_mr_xfer_btype==WRAP && (|(req_in_wrap_size^ap_mem_wrap_size)) && (!pending_mr8_wr)) 
         // New MR8 write to change the wrap settings
         begin
	 next_pending_mr8_wr = 1'b1;   // Use this for FSM also to assert the mr_access from CSR block during MR8 write
         next_mr8_btype     = 1'b1; 
         next_mr8_bsize     = (mem_mr_xfer_len[3] ? 2'b00 : mem_mr_xfer_len[4] ? 2'b01 : 2'b10);
         next_success_xfer  = 1'b0; 
         next_xmittr_ack    = 1'b0;
         next_mr_access_reg = 1'b1;
         next_start_track   = 1'b0;
         next_wr_rd         = 1'b1;
         next_first_addr    = {24'd0, 8'd8}; // MR8 
         next_addr_cntr     = addr_cntr; // don't care
         next_ce_n_ip       = 1'b0;
         next_state         = SEND_CMD;
         end
         else
         begin
         next_mr8_wr_complete = 1'b0;
         next_success_xfer  = 1'b1; 
         next_xmittr_ack    = 1'b1;
         next_mr_access_reg = mr_access ? 1'b1 : 1'b0;
         next_start_track   = mr_access ? 1'b0 : (mem_mr_xfer_wr_rd ? 1'b0: 1'b1) ;
         next_wr_rd         = mem_mr_xfer_wr_rd;         
         next_first_addr    = mr_access ? {mem_mr_xfer_addr[31:1],1'b0} : (mem_mr_xfer_btype==WRAP && mem_mr_xfer_wr_rd && mem_mr_xfer_addr[0]) ? 				  wrap_wr_addr : {mem_mr_xfer_addr[31:1],1'b0};
         //next_first_addr    = mem_mr_xfer_addr : (mem_mr_xfer_btype==WRAP && mem_mr_xfer_wr_rd && mem_mr_xfer_addr[0]) ? 				  wrap_wr_addr : {mem_mr_xfer_addr[31:1],1'b0};
         //next_addr_cntr        = {mem_mr_xfer_addr[1],1'b0}; // maintain the previous odd address even for odd wrap write xfer
         next_addr_cntr        = {mem_mr_xfer_addr[1],1'b0}; // maintain the previous odd address even for odd wrap write xfer
         next_odd_wrap_wr_xfer = mem_mr_xfer_btype==WRAP && mem_mr_xfer_wr_rd && mem_mr_xfer_addr[0]; // odd wrap wirte xfer
         next_ce_n_ip       = 1'b0;
         next_state         = SEND_CMD;
         end
      end
   end
   else if (spl_dpd_entry_valid || spl_hs_entry_valid || spl_glbl_reset_valid || 
            spl_dpd_entry_valid_reg || spl_hs_entry_valid_reg || spl_glbl_reset_valid_reg ) 
// mr_access bit is set by CSR module rather than the F/W: During hs_entry, dpd_entry and
// global_reset_en 
   begin
      next_mr_access_reg             = 1'b1;
      //next_mr_access_reg             = mr_access ? 1'b1 : 1'b0; 
      next_spl_dpd_entry_valid_reg   = 1'b0 ;
      next_spl_hs_entry_valid_reg    = 1'b0 ;
      next_spl_glbl_reset_valid_reg  = 1'b0 ;
      next_ce_n_ip                   = 1'b0;
      next_state                     = SEND_CMD;
      next_wr_rd                     = 1'b1;     
      next_mem_spl_xfer_in_prgrs     = 1'b1;
      next_first_addr                = {24'd0, 8'd6}; // MR6 for hs entry and dpd entry; global reset address is don't care 
      next_wr_data_reg0              = spl_dpd_entry_valid || spl_dpd_entry_valid_reg ? {wr_data_reg0 [36:8],8'hC0} : 
                                       spl_hs_entry_valid || spl_hs_entry_valid_reg ? {wr_data_reg0 [36:8],8'hF0} : wr_data_reg0;
      next_mr8_btype                 = spl_hs_entry_valid || spl_hs_entry_valid_reg ? mr8_btype  : 1'b1;  // restore to default values
      next_mr8_bsize                 = spl_hs_entry_valid || spl_hs_entry_valid_reg ? mr8_bsize  : 2'b01;
      next_mr8_rbx                   = spl_hs_entry_valid || spl_hs_entry_valid_reg ? mr8_rbx    : 1'b0; 
      next_mr4_wr_lat                = spl_hs_entry_valid || spl_hs_entry_valid_reg ? mr4_wr_lat : 3'd5;
      next_spl_instrn_glbl_rst_prgrs = spl_glbl_reset_valid || spl_glbl_reset_valid_reg ? 1'b1 : spl_instrn_glbl_rst_prgrs;
   end
   else if (spl_dpd_exit_valid || spl_dpd_exit_valid_reg)
   begin
      //next_mr_access_reg = mr_access ? 1'b1 : 1'b0; // already registered
      //during DPD entry
      next_spl_dpd_exit_valid_reg    = 1'b0;
      next_ce_n_ip                   = 1'b0;
      next_state                     = DPD_EXIT;
      next_mem_spl_xfer_in_prgrs     = 1'b1;
      next_ce_low_to_low_cntr        = dpd_exit_cycle_cnt;
      next_spl_instrn_dpd_exit_prgrs = 1'b1;
   end
   else if(spl_hs_exit_valid || spl_hs_exit_valid_reg)
   begin
      //next_mr_access_reg = mr_access ? 1'b1 : 1'b0; // already registered
      //during HS entry
      next_spl_hs_exit_valid_reg    = 1'b0;
      next_ce_n_ip                  = 1'b0;
      next_state                    = HS_EXIT;
      next_mem_spl_xfer_in_prgrs    = 1'b1;
      next_ce_low_to_low_cntr       = hs_exit_cycle_cnt;
      next_spl_instrn_hs_exit_prgrs = 1'b1;
   end
   else
   begin
      next_state        = pres_state;
   end
end

SEND_CMD:
begin
next_addr_cycle_cnt    = 1'b0;
   if(pending_xfer) // to complete the split transfer during write (due to tcem_expiry, page boundary crossing) and read (due to tcem_expiry, page boundary crossing(mr8_rbx=0))
   begin
      next_pending_xfer = 1'b0; 
      next_sclk_en     = 1'b1;
      next_dq_oe_ip    = 1'b1;
      next_dm_oe_ip    = wr_rd ? 1'b1 : 1'b0;
      next_dq_out_ip   = (wr_rd ? {8'hA0,8'hA0} : {8'h20,8'h20}); // if previous had sync_wr command with wrap setting, new pending xfer has to to given linear burst write command.
      //next_dq_out_ip = {prev_cmd, prev_cmd};
      next_dm_ip     = 2'b00;
      next_state     = ADDR;
      next_prev_cmd  =  wr_rd ? 8'hA0 : 8'h20; // if previous had sync_wr command with wrap setting, new pending xfer has to to given linear burst write command.
      //next_dq_out_ip   = mr_access_reg || mr_access ?(wr_rd ? {8'hC0,8'hC0} : {8'h40,8'h40}) : 
      //                   (wr_rd ? {8'hA0,8'hA0} : {8'h20,8'h20}); // if previous had sync_wr command with wrap setting, new pending xfer has to to given linear burst write command.
      //next_prev_cmd  = mr_access_reg || mr_access ?(wr_rd ? {8'hC0,8'hC0} : {8'h40,8'h40}) : 
      //                 (wr_rd ? {8'hA0,8'hA0} : {8'h20,8'h20}); // if previous had sync_wr command with wrap setting, new pending xfer has to to given linear burst write command.
   end
   else
   begin
      next_sclk_en     = 1'b1;
      next_dq_oe_ip = 1'b1;
      next_dm_oe_ip    = wr_rd ? 1'b1 : 1'b0;
      next_cmd_ack   = pending_mr8_wr ? 1'b0 : 1'b1;
      next_dq_out_ip = pending_mr8_wr ? { 8'hC0, 8'hC0} : {cmd, cmd};
      next_dm_ip     = 2'b00;
      next_state     = ADDR;
      next_prev_cmd  = cmd;
   end
end

ADDR:
begin
   if(|addr_cycle_cnt) // 2nd addr cycle placement
   begin
      next_addr_cycle_cnt = 1'b0;
      //next_dq_out_ip      = first_addr[15:0];
      next_dq_out_ip      = {first_addr[7:0],first_addr[15:8]};
      next_dm_ip          = 2'b00;
      next_state          = mr_access_reg ? (wr_rd ? TX_DATA : RD_DATA) : (wr_rd ? TX_LATENCY : RD_DATA);
      next_wait_cntr      = (!mr_access_reg) && wr_rd ? mr4_wr_lat - 3'd1 : wait_cntr;
      next_start_track    = mr_access_reg ? 1'b0 : start_track;
      //next_start_track    = mr_access ? 1'b0 : (wr_rd ? ((mr4_wr_lat-3'd1)==3): start_track);
      //next_start_track    = mr_access ? 1'b0 : (wr_rd ? ((mr4_wr_lat-3'd1)==2): (start_xfer_ack ? 1'b0 : start_track));
   end
   else // 1st addr cycle placement
   begin
      next_addr_cycle_cnt = 1'b1;
      next_dq_out_ip      = {first_addr[23:16],first_addr[31:24]};
      //next_dq_out_ip      = first_addr[31:16];
      next_dm_ip          = 2'b00;
      next_state          = pres_state;
   end
end

TX_LATENCY:
begin
   next_start_track = (wait_cntr==3'd2); // pulse for write ; level for read
   if(wait_cntr==3'd0)
   begin
      next_wait_cntr = 3'd0;
      if (|wdata_avail_cnt)
      begin
      next_min_one_wr_xfer_cmplt = 1'b1;
      next_sclk_en = odd_wrap_wr_xfer ? 1'b0 : 1'b1;
      next_rem_wr_data  = odd_wrap_wr_xfer ? (addr_cntr[1] /*addr_cntr=2*/ ? {wr_data_reg0[35],wr_data_reg0[31:24]} : 
                          {wr_data_reg0[33],wr_data_reg0[15:8]} ) : rem_wr_data;
      next_odd_wrap_wr_xfer = 1'b0;
      next_odd_wrap_wr_rem  = odd_wrap_wr_xfer ? 1'b1 : odd_wrap_wr_rem ;
         case(addr_cntr)       
            2'b00:
            begin
               next_dq_out_ip       = reg_1 ?  wr_data_reg1[15:0] : wr_data_reg0[15:0];
               next_dm_ip           = reg_1 ?  wr_data_reg1[33:32] : wr_data_reg0[33:32];
               next_addr_cntr       = last_xfer_lsb & cont_wr_xfer_valid ? {mem_mr_xfer_addr[1],1'b0} : 2'd2;
               //next_addr_cntr     = 2'd2;
               next_state           = last_xfer_lsb ? 
			              (cont_wr_xfer_valid ? TX_DATA : WAIT_TR_EXPIRY) : pres_state;
               next_xmittr_ack      = last_xfer_lsb ? 
                                      cont_wr_xfer_valid : 1'b0;
               next_reg_1           = last_xfer_lsb ? 1'b0 : reg_1;
               next_cnt             = last_xfer_lsb ? 1'b0 : (cnt==0 && mem_mr_wdata_valid && xmit_engn_wdata_ack) || cnt;
               //next_cnt             = last_xfer_lsb ? 1'b0 : cnt /*check this value*/;
               next_wdata_avail_cnt = last_xfer_lsb ? 2'd0 : (mem_mr_wdata_valid && xmit_engn_wdata_ack ?wdata_avail_cnt+1 : wdata_avail_cnt);
               next_pending_xfer  = last_xfer_lsb ? cont_wr_xfer_valid : 1'b1;
            end
            2'b10: 
            begin
               next_dq_out_ip       = reg_1 ?  wr_data_reg1[31:16] : wr_data_reg0[31:16];
               next_dm_ip           = reg_1 ?  wr_data_reg1[35:34] : wr_data_reg0[35:34];
               next_addr_cntr       = last_xfer & cont_wr_xfer_valid ? {mem_mr_xfer_addr[1],1'b0} : 2'd0;
               //next_addr_cntr       = 2'd0;
               next_state           = last_xfer ? (cont_wr_xfer_valid ? TX_DATA : WAIT_TR_EXPIRY) : TX_DATA;
               next_xmittr_ack      = last_xfer ? cont_wr_xfer_valid : 1'b0;
               next_reg_1           = last_xfer ? 1'b0 : (reg_1 ? 1'b0: 1'b1);
               next_cnt             = last_xfer ? 1'b0 : (reg_1 ? ((cnt==0 && mem_mr_wdata_valid  && xmit_engn_wdata_ack) || cnt) : 1'b0);
               next_wdata_avail_cnt = last_xfer ? 2'd0 : (mem_mr_wdata_valid && xmit_engn_wdata_ack ? wdata_avail_cnt : wdata_avail_cnt-1); 
               next_pending_xfer  = last_xfer ? cont_wr_xfer_valid : 1'b1;
            end
         endcase
      end
      else
      begin
         next_state        = TX_DATA;
         next_reg_1        = 1'b0; // once data is not available new data will be available in wr_data_reg0 only.
         next_sclk_en      = 1'b0;
      end
   end
   else
   begin
      next_wait_cntr = wait_cntr - 3'd1;
      next_state     = pres_state;
   end
end

TX_DATA:
begin
   if(mem_spl_xfer_in_prgrs) // hs entry/ dpd entry/global reset
   begin
      next_dq_out_ip = wr_data_reg0[15:0]; // for global reset, address and data is don't care
      next_dm_ip         = 2'b10;
      next_state         = spl_instrn_glbl_rst_prgrs ? WAIT_TR_EXPIRY : IDLE;
   end
   else if(mr_access_reg) // mode register access - 
   begin
      if(|wdata_avail_cnt || pending_mr8_wr)
      begin
         next_pending_mr8_wr  = 1'b0;
         next_mr8_wr_complete = pending_mr8_wr;
         next_sclk_en         = 1'b1;
         next_addr_cntr       = 2'd0;
         next_state           = WAIT_TR_EXPIRY;
         next_reg_1            = 1'b0;
         next_cnt             = 1'b0;
         next_wdata_avail_cnt = 2'd0;
         next_dq_out_ip       = pending_mr8_wr ? {2{4'd0,mr8_rbx, mr8_btype, mr8_bsize}} : 
                                |first_addr[1:0] /* which is 2'd2 */ ? wr_data_reg0[31:16] : {8'd0,wr_data_reg0[7:0]};
         next_dm_ip           = pending_mr8_wr ? 2'b00 : |first_addr[1:0] /* which is 2'd2 */ ? wr_data_reg0[35:34] : {1'b1,wr_data_reg0[32]};
         //next_dq_out_ip       = pending_mr8_wr ? {2{4'd0,mr8_rbx, mr8_btype, mr8_bsize}} : 
         //                       |first_addr[1:0] /* which is 2'd2 */ ? wr_data_reg0[31:16] : wr_data_reg0[15:0];
         //next_dm_ip           = pending_mr8_wr ? 2'b00 : |first_addr[1:0] /* which is 2'd2 */ ? wr_data_reg0[35:34] : wr_data_reg0[33:32];
         case(first_addr[3:0])
         4'd8: 
         begin
            next_mr8_bsize  = pending_mr8_wr ? mr8_bsize: wr_data_reg0[1:0]; 
            next_mr8_btype  = pending_mr8_wr ? mr8_btype: wr_data_reg0[2]; 
            next_mr8_rbx    = pending_mr8_wr ? mr8_rbx  : wr_data_reg0[3]; 
         end
         4'd4:
         begin
            next_mr4_wr_lat = wr_data_reg0[7:5] ==3'd0 ? 3'd3 :
	          	      wr_data_reg0[7:5] ==3'd4 ? 3'd4 :
	          	      wr_data_reg0[7:5] ==3'd2 ? 3'd5 :
	          	      wr_data_reg0[7:5] ==3'd6 ? 3'd6 :
	          	      wr_data_reg0[7:5] ==3'd1 ? 3'd7 : 3'd5;
         end
         default;
         endcase
      end
      else
      begin
         next_state   = pres_state;
         next_sclk_en = 1'b0;
      end 
   end
   else // memory array access
   begin
      if(wr_tcem_pg_bndry_expired && ((xfer_btype==WRAP && sclk_en) || xfer_btype==INCR))
      begin
         next_sclk_en    = 1'b0;
         next_first_addr = sclk_en ? wr_last_addr : wr_last_addr-2;
         next_reg_1      = |wdata_avail_cnt ? reg_1 : 1'b0; // once data is not available new data will be available in wr_data_reg0 only.
         next_state      = WAIT_TR_EXPIRY; 
         next_pending_xfer  = min_one_wr_xfer_cmplt ? pending_xfer : 1'b1;
         //next_pending_xfer  = 1'b1;
      end
      //else if((wr_tcem_pg_bndry_expired || wr_tcem_pg_bndry_expired_reg ) && sclk_en)                                        
      //begin
      //   next_wr_tcem_pg_bndry_expired_reg = 1'b0;
      //   next_sclk_en    = 1'b0;
      //   next_first_addr = wr_last_addr;
      //   next_reg_1      = |wdata_avail_cnt ? reg_1 : 1'b0; // once data is not available new data will be available in wr_data_reg0 only.
      //   next_state      = WAIT_TR_EXPIRY; 
      //   //next_pending_xfer  = 1'b1;
      //end
      else if(|wdata_avail_cnt)
      begin
         next_sclk_en          = odd_wrap_wr_xfer ? 1'b0 : 1'b1;
         next_rem_wr_data      = odd_wrap_wr_xfer ? (addr_cntr[1] /*addr_cntr=2*/ ? {wr_data_reg0[35],wr_data_reg0[31:24]} : 
                                 {wr_data_reg0[33],wr_data_reg0[15:8]} ) : rem_wr_data;
         next_odd_wrap_wr_xfer = 1'b0;
         //next_odd_wrap_wr_rem  = odd_wrap_wr_xfer ? 1'b1 : odd_wrap_wr_rem ;
         //next_sclk_en          = 1'b1;
         case(addr_cntr[1:0])
         2'b00:
         begin
         next_odd_wrap_wr_rem  = last_xfer_lsb ? 1'b0 : (odd_wrap_wr_xfer ? 1'b1 : odd_wrap_wr_rem);
         //next_odd_wrap_wr_rem  = last_xfer_lsb ? 1'b0 : odd_wrap_wr_rem;
         next_dq_out_ip    = last_xfer_lsb && odd_wrap_wr_rem ? 
                             (reg_1 ? {rem_wr_data[7:0],wr_data_reg1[7:0]} : {rem_wr_data[7:0],wr_data_reg0[7:0]}) :
			     (reg_1 ? wr_data_reg1[15:0] : wr_data_reg0[15:0]);
         next_dm_ip        = last_xfer_lsb && odd_wrap_wr_rem ?
                             (reg_1 ? {rem_wr_data[8],wr_data_reg1[32]} : {rem_wr_data[8],wr_data_reg0[32]}) :
   			     (reg_1 ? wr_data_reg1[33:32] : wr_data_reg0[33:32]); 
         next_addr_cntr    = last_xfer_lsb & cont_wr_xfer_valid ? {mem_mr_xfer_addr[1],1'b0} : 2'd2;
         //next_addr_cntr    = 2'd2;
         next_state        = last_xfer_lsb ? 
	  	             (cont_wr_xfer_valid ? pres_state : WAIT_TR_EXPIRY) : pres_state;
         next_xmittr_ack   = last_xfer_lsb ? 
                                cont_wr_xfer_valid : 1'b0;
         next_reg_1        = last_xfer_lsb ? 1'b0 : reg_1;
         next_cnt          = last_xfer_lsb ? 1'b0 : (cnt==0 && mem_mr_wdata_valid && xmit_engn_wdata_ack) || cnt;
         //next_cnt          = last_xfer_lsb ? 1'b0 : cnt /*check this value*/;
         next_wdata_avail_cnt = last_xfer_lsb ? 2'd0 : (mem_mr_wdata_valid && xmit_engn_wdata_ack ? wdata_avail_cnt+1 : wdata_avail_cnt);
         next_pending_xfer  = last_xfer_lsb ? cont_wr_xfer_valid : 1'b1;
         end
         2'b10:
         begin
         next_odd_wrap_wr_rem  = last_xfer ? 1'b0 : (odd_wrap_wr_xfer ? 1'b1 : odd_wrap_wr_rem);
         //next_odd_wrap_wr_rem  = last_xfer ? 1'b0 : odd_wrap_wr_rem;
         next_dq_out_ip    = last_xfer && odd_wrap_wr_rem ? 
                             (reg_1 ? {rem_wr_data[7:0],wr_data_reg1[23:16]} : {rem_wr_data[7:0],wr_data_reg0[23:16]}) :
			     (reg_1 ? wr_data_reg1[31:16] : wr_data_reg0[31:16]);
         next_dm_ip        = last_xfer && odd_wrap_wr_rem ?
                             (reg_1 ? {rem_wr_data[8],wr_data_reg1[34]} : {rem_wr_data[8],wr_data_reg0[34]}) :
   			     (reg_1 ? wr_data_reg1[35:34] : wr_data_reg0[35:34]); 
         next_addr_cntr    = last_xfer & cont_wr_xfer_valid ? {mem_mr_xfer_addr[1],1'b0} : 2'd0;
         //next_addr_cntr  = 2'd0;
         next_state        = last_xfer ? (cont_wr_xfer_valid ? pres_state : WAIT_TR_EXPIRY) : pres_state;
         next_xmittr_ack   = last_xfer ? cont_wr_xfer_valid : 1'b0;
         next_reg_1        = last_xfer ? 1'b0 : (reg_1 ? 1'b0: 1'b1);
         next_cnt          = last_xfer ? 1'b0 : (reg_1 ? ((cnt==0 && mem_mr_wdata_valid  && xmit_engn_wdata_ack) || cnt) : 1'b0);
         next_wdata_avail_cnt = last_xfer ? 2'd0 : (mem_mr_wdata_valid && xmit_engn_wdata_ack ? wdata_avail_cnt : wdata_avail_cnt-1); 
         next_pending_xfer  = last_xfer ? cont_wr_xfer_valid : 1'b1;
         end
         default;
         endcase
      end
      else
      begin
         next_state   = pres_state;
         next_sclk_en = 1'b0;
         next_reg_1   = 1'b0; // once data is not available new data will be available in wr_data_reg0 only.
      end 
   end
end

HS_EXIT:
begin
   if(|ce_low_to_low_cntr)
   begin
      next_ce_low_to_low_cntr = ce_low_to_low_cntr - 1;
      next_state              = pres_state;      
   end
   else 
   begin
      next_ce_n_ip               = 1'b1;
      next_mem_spl_xfer_in_prgrs = txhs_expired ? 1'b0 : mem_spl_xfer_in_prgrs;
      next_spl_instrn_hs_exit_prgrs = txhs_expired ? 1'b0 : spl_instrn_hs_exit_prgrs;
      next_state                 = txhs_expired ? IDLE : pres_state;
   end
end

DPD_EXIT:
begin
   if(|ce_low_to_low_cntr)
   begin
      next_ce_low_to_low_cntr = ce_low_to_low_cntr - 1;
      next_state              = pres_state;      
   end
   else 
   begin
      next_ce_n_ip               = 1'b1;
      next_mem_spl_xfer_in_prgrs = txdpd_expired ? 1'b0 : mem_spl_xfer_in_prgrs;
      next_state                 = txdpd_expired ? IDLE : pres_state;
      next_spl_instrn_dpd_exit_prgrs = txdpd_expired ? 1'b0 : spl_instrn_dpd_exit_prgrs;
   end
end

RD_DATA:
begin
next_dq_oe_ip = 1'b0;
next_dm_oe_ip    = 1'b0; // already at zero during whole read operation

   if(dqs_timeout) // do not re-initiate this transfer again. Instead the AXI_RDATA_CTRL block will close the xfer with junk data and error response
   begin
      next_pending_xfer      = 1'b0;
      next_start_track       = 1'b0;
      next_rd_done_reg       = 1'b0;      
      next_state             = WAIT_RCV_DQ_FIFO_FLUSH;
      next_wait_cntr         = 3'd3; // use this to wait for n number of clocks before flushing the rcv_dq_fifo 
   end
   else if(rd_done || rd_done_reg) 
   // It is asserted only after all read and continuous read transfers if any are complete- from rcv_cntrl block
   begin
      //next_sclk_en       = rd_cnt_sync ? 1'b1 : 1'b0; - This causes error
      //when rd_cnt_sync is not yet synced when rd_done is asserted
      next_sclk_en           = 1'b1;
      next_state             = start_track ? pres_state : (rd_cnt_sync ? pres_state : (rd_pg_bndry_expired_sync ? pres_state : WAIT_RCV_DQ_FIFO_FLUSH)) ; 
      next_start_track       = min_dqs_cnt_rch ? 1'b0 : start_track;
      next_rd_done_reg      = rd_done ? 1'b1 : rd_done_reg;// de-assert once flush_en is asserted
      next_wait_cntr        = 3'd3; // use this to wait for n number of clocks before flushing the rcv_dq_fifo
   end
   else if( tcem_expired || rd_pg_bndry_expired_sync) 
   // added tcem_expired directly since tcem_expired_sync does not reach when no dqs_inv during read stretch. Hence it is missed by the rd_pg_bndry_expired block.
   begin
      next_tcem_expired_reg       = tcem_expired ? 1'b1 : tcem_expired_reg;
      next_pending_xfer           = 1'b1;
      //next_first_addr           = rd_last_addr + 1;
      next_first_addr             = tcem_expired ? first_addr :rd_last_addr + 1; // reverted latching rd_last_addr during tcem_expiry; Instead registered that the tcem_expired happened through tcem_expired_reg. Used this flag in calculation of mem_boundary_cross
      next_state                  = WAIT_TR_EXPIRY;         
      next_start_track            = min_dqs_cnt_rch ? 1'b0 : start_track;
      //next_start_track          = 1'b0;
      next_sclk_en                = 1'b1;
   end
   else if (rd_stretch) // stretch the xfer as the read data fifo is almost full
   begin
      next_sclk_en  = 1'b0;
      next_state    = pres_state;
   end
   else
   begin
      next_sclk_en              = 1'b1;
      next_state                = pres_state;
   end
end


WAIT_TR_EXPIRY:
begin
   if(spl_instrn_glbl_rst_prgrs) // global reset trst expiry
   begin
      next_mem_spl_xfer_in_prgrs = trst_expired ? 1'b0 : mem_spl_xfer_in_prgrs;
      next_sclk_en          = 1'b0;
      next_ce_n_ip          = sclk_en ? ce_n_ip : 1'b1;
      //next_ce_n_ip          = 1'b1;
      next_dq_oe_ip      = 1'b0;
      next_dm_oe_ip      = 1'b0;
      next_dm_ip         = 2'd0;
      next_spl_instrn_glbl_rst_prgrs = trst_expired ? 1'b0 : spl_instrn_glbl_rst_prgrs;
      next_state            = trst_expired ? IDLE : pres_state;
   end
   else //write/read - memory array access; write/read - mode register access (except dpd entry and hs entry - this is taken care by F/W)
   begin
      next_min_one_wr_xfer_cmplt = 1'b0;
      next_wr_tcem_pg_bndry_expired_reg = 1'b0;
      next_sclk_en       = wr_rd ? 1'b0 : (start_track ? sclk_en : (rd_cnt_sync ? 1'b1 : (rd_pg_bndry_expired_sync ? 1'b1 : 1'b0))); // added during taking care of rcv_dq_fifio_flush
      //next_sclk_en       = rd_cnt_sync && mr8_rbx ? 1'b1 : 1'b0; // added during taking care of rcv_dq_fifio_flush
      next_ce_n_ip       = sclk_en ? ce_n_ip : 1'b1;
      next_dq_oe_ip      = 1'b0;
      next_dm_oe_ip      = 1'b0;
      next_dm_ip         = 2'd0;
      next_start_track   = min_dqs_cnt_rch ? 1'b0 : start_track;
      if(rd_done || rd_done_reg)
      begin
      next_pending_xfer  = 1'b0;
      next_state         = start_track ? pres_state : (rd_cnt_sync ? pres_state : (rd_pg_bndry_expired_sync ? pres_state : WAIT_RCV_DQ_FIFO_FLUSH)) ; 
      next_rd_done_reg   = 1'b1;
      next_wait_cntr     = 3'd3; // use this to wait for n number of clocks before flushing the rcv_dq_fifo
      //next_state         = rd_cnt_sync && mr8_rbx ? pres_state : WAIT_RCV_DQ_FIFO_FLUSH; // During Row boundary crossing, due to tRBX_wait DQS is not toggling hence F/Fs in the rd_pg_bndry_checker are not reset. To ensure this, wait for the rd_cnt_sync de-assertion during RBX=1 . This is applicable during both WRAP transfer completion at page boundary and INCR transfer completion at page boundary
      end
      else if((trc_expired || trc_expired_reg) && (tcph_expired || tcph_expired_reg) && (!almost_full_reg))
      begin
         next_trc_expired_reg  = 1'b0;
         next_tcph_expired_reg = 1'b0;
         next_tcem_expired_reg = 1'b0;
         next_first_addr       = mem_boundary_cross ? {7'd0,mem_base_addr} : wr_rd ? first_addr : rd_last_addr + 1;
         //next_first_addr       = mem_boundary_cross ? {7'd0,mem_base_addr} : (rd_tcem_expiry ? (rd_last_addr + 1) : first_addr);
         //next_rd_tcem_expiry   = 1'b0;
         if(pending_xfer && ((!rd_done_reg) || (!rd_done)) )
         begin
            next_success_xfer    = success_xfer; // maintain 1
            next_state           = SEND_CMD; 
            next_ce_n_ip         = 1'b0;
            next_start_track     = (wr_rd ? 1'b0: 1'b1) ;
            next_xfer_btype      = 2'd1; // newly added to make the xfer_btype to INCR when an ongoing hybrid wrap transfer is split due to large AXI_R_READY delays
            //next_cnt             = cnt            ; // dont; overwrite
            //next_wdata_avail_cnt = wdata_avail_cnt; // don't overwrite
         end
         else
         begin
            next_rd_done_reg     = rd_done_reg || rd_done ? 1'b0 : rd_done_reg;
            next_success_xfer    = 1'b0; // transfer complete
            next_state           = IDLE;
            next_ce_n_ip         = 1'b1; // chip remains de-asserted
            next_cnt             = 1'b0;
            next_reg_1           = 1'b0;
            next_wdata_avail_cnt = 2'd0;
         end
      end      
      else
      begin
            next_state         = pres_state;
      end
   end
end

RD_ERR_FINISH:
begin
 next_rd_done_reg = 1'b0;
 next_state = rd_done ? IDLE : pres_state; // no need to flush RCV_DQ_FIFO , since no read transaction is intitated to the memory.
end

WR_ERR_FINISH:
begin
 next_state = mem_mr_wdata_valid && mem_mr_wlast && mem_mr_wdata_ack ? IDLE : pres_state;
end

WAIT_RCV_DQ_FIFO_FLUSH:
begin
   next_sclk_en   = 1'b0;
   next_ce_n_ip   = sclk_en ? ce_n_ip : 1'b1;
   next_wait_cntr  = |wait_cntr ? wait_cntr-1 : wait_cntr; 
   next_rd_done_reg = wait_cntr==1 ? 1'b0 : rd_done_reg;
   next_rcv_dq_fifo_flush_en = wait_cntr==1 ? 1'b1 : 1'b0;
   next_state     = rcv_dq_fifo_flush_done ? WAIT_TR_EXPIRY :pres_state; 
end


endcase
end

endmodule
