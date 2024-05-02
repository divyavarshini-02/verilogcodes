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
module tx_path 
   (

//clocks and reset
   mem_clk,
   rst_n,  
   dqs_inv,

//AXI error filter

   mem_mr_xfer_valid,
   cont_wr_rd_req,
   mem_mr_error,
   mr8_bsize,
   mr8_btype,
   xmit_engn_wdata_ack,
   mem_mr_wdata_ack,

//AXI4 slave interface
   mem_mr_xfer_btype,
   mem_mr_xfer_wr_rd,
   mem_mr_xfer_addr,
   mem_mr_xfer_len,
   mem_mr_xfer_ack,

   mem_mr_wdata_valid,
   mem_mr_wdata,
   mem_mr_wlast,
   mem_mr_wstrb,

// TO ack resolver
   xmittr_ack,

//SPL_INSTRN_HANDLER
   spl_dpd_entry_valid,
   spl_dpd_exit_valid,
   spl_hs_entry_valid,
   spl_hs_exit_valid,
   spl_glbl_reset_valid,
   mem_spl_xfer_in_prgrs,

//CSR
   mem_page_size,
   mr_access,
   linear_burst_wr,
   linear_burst_rd,
   sync_wr,
   sync_rd,
   global_reset_cmd,
   mode_reg_wr,
   mode_reg_rd,
   dpd_exit_cycle_cnt,
   hs_exit_cycle_cnt,
   tcem_cnt,        
   trc_cnt,         
   tcph_cnt,        
   trst_cnt,        
   txhs_cnt,        
   txdpd_cnt,       
   tcem_time_ignore,
   txhs_time_ignore,
   txdpd_time_ignore,
   mem_base_addr,
   mem_top_addr,

//RCV_CNTRL
   rd_done,
   rd_stretch,
   dqs_timeout,
   rcv_dq_fifo_wr_en,
   rd_pg_bndry_expired_sync,
   tcem_expired,
   start_track,
   pending_xfer,
   almost_full_reg,

//To RDATA packer
   rcv_dq_fifo_flush_en, 
   rcv_dq_fifo_flush_done, 

//To block dqs_inv during write; To dqs_non_tgl_checker - rx_path 
   wr_rd,
   rd_cnt_sync,

//PHY interface
   sclk_en,
   ce_n_ip,
   dq_out_ip,
   dm_ip,
   dq_oe_ip,
   dm_oe_ip
   );


parameter AXI_DATA_WIDTH = 32; // 32/64
parameter AXI_ADDR_WIDTH = 32;
parameter RCV_DQ_FIFO_ADDR_WIDTH = 4;

localparam DQS_CNT_WIDTH = (AXI_DATA_WIDTH==32) ? 10: ((AXI_DATA_WIDTH==64) ? 11 : 12);

//===================I/Os=======================

//clocks and reset
input   mem_clk;
input   rst_n;  
input   dqs_inv;

//AXI error filter

input         mem_mr_xfer_valid;
input         cont_wr_rd_req;
input [1:0]   mem_mr_error;
output [1:0]  mr8_bsize;
output        mr8_btype;
output        xmit_engn_wdata_ack;
input         mem_mr_wdata_ack;

//AXI4 slave interface
input [1:0]                mem_mr_xfer_btype;
input                      mem_mr_xfer_wr_rd;
input [31:0]               mem_mr_xfer_addr;
input [DQS_CNT_WIDTH-1:0]  mem_mr_xfer_len;
input                      mem_mr_xfer_ack;

input                      mem_mr_wdata_valid;
input [31:0]               mem_mr_wdata;
input [3:0]                mem_mr_wstrb;
input                      mem_mr_wlast;

// TO ack resolver
output                     xmittr_ack;

//SPL_INSTRN_HANDLER
input                      spl_dpd_entry_valid;
input                      spl_dpd_exit_valid;
input                      spl_hs_entry_valid;
input                      spl_hs_exit_valid;
input                      spl_glbl_reset_valid;
output                     mem_spl_xfer_in_prgrs;

//CSR
input [3:0]               mem_page_size;
input                     mr_access;
input [7:0]               linear_burst_wr;
input [7:0]               linear_burst_rd;
input [7:0]               sync_wr;
input [7:0]               sync_rd;
input [7:0]               global_reset_cmd;
input [7:0]               mode_reg_wr;
input [7:0]               mode_reg_rd;
input [3:0]               dpd_exit_cycle_cnt;
input [3:0]               hs_exit_cycle_cnt;

input [11:0]              tcem_cnt;        
input [3:0]               trc_cnt;         
input [2:0]               tcph_cnt;        
input [8:0]               trst_cnt;        
input [14:0]              txhs_cnt;        
input [15:0]              txdpd_cnt;       
input                     tcem_time_ignore;
input                     txhs_time_ignore;
input                     txdpd_time_ignore;
input [24:0]              mem_base_addr;
input [24:0]              mem_top_addr;

//RCV_CNTRL
input                     rd_done;
input                     rd_stretch;
input                     dqs_timeout;
output                    rcv_dq_fifo_wr_en;
output                    rd_pg_bndry_expired_sync; 
output                    tcem_expired;
output                    start_track;
output                    pending_xfer; 
input                     almost_full_reg;

//To RDATA packer
output                    rcv_dq_fifo_flush_en; 
input                     rcv_dq_fifo_flush_done;

//To block dqs_inv during write
output                    wr_rd;
output                    rd_cnt_sync;

//PHY interface
output                     sclk_en;
output                     ce_n_ip;
output   [15:0]            dq_out_ip;
output   [1:0]             dm_ip;
output                     dq_oe_ip;
output                     dm_oe_ip;

//===========================wires=============================

wire [7:0]                 cmd;
wire [AXI_ADDR_WIDTH-1:0]  first_addr;
wire [AXI_ADDR_WIDTH-1:0]  wr_last_addr;
wire [AXI_ADDR_WIDTH-1:0]  rd_last_addr;
wire [1:0] xfer_btype;
wire [DQS_CNT_WIDTH-1:0]  xfer_mem_len;
wire [7:0] prev_cmd;
wire dqs_inv_final;

//assign dqs_inv_final = mr_access_reg ? 1'b1 :  dqs_inv;


clock_gate DQS_CLK_GATE

(
 .clkA   (1'b1),
 .clkB   (dqs_inv),
 .clksel (mr_access_reg),
 .clkout (dqs_inv_final)
);

stop_rd_pg_bndry_tracking STOP_RD_PG_BNDRY_TRACKING
(
 .start_track (start_track),
 .start_track_sync (start_track_sync),
 .stop_read   (stop_read)
);


cmd_selector CMD_SELECTOR
   (
   .mem_clk                         (mem_clk),
   .rst_n                           (rst_n),
                                    
// From AXI4_SLV_CNTRL               
   .mem_mr_xfer_valid           (mem_mr_xfer_valid),
   .mem_mr_error                    (mem_mr_error),
   .mem_mr_xfer_wr_rd               (mem_mr_xfer_wr_rd),
   .mem_mr_xfer_btype               (mem_mr_xfer_btype),
                                   
//From SPL_INSTRN_HANDLR             
   .spl_dpd_entry_valid             (spl_dpd_entry_valid),
   .spl_hs_entry_valid              (spl_hs_entry_valid),
   .spl_global_reset_valid          (spl_glbl_reset_valid),
                                 
//From Data shifter                  
   .mr8_btype                       (mr8_btype),
                                  
// From CSR                          
   .mr_access                       (mr_access),
   .linear_burst_wr                 (linear_burst_wr),
   .linear_burst_rd                 (linear_burst_rd),
   .sync_wr                         (sync_wr),
   .sync_rd                         (sync_rd),
   .global_reset_cmd                (global_reset_cmd),
   .mode_reg_wr                     (mode_reg_wr),
   .mode_reg_rd                     (mode_reg_rd),
                                   
// To XMIT_ENGINE                    
   .cmd                             (cmd)
   );

wr_tcem_pg_bndry_checker 
   #(
   .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH),
   .AXI_DATA_WIDTH (AXI_DATA_WIDTH)
    )
WR_TCEM_PG_BNDRY_CHECKER
   (
   .mem_clk                        (mem_clk),  
   .rst_n                          (rst_n),
                                   
//From TIMER_CHECKER
   .tcem_expired                   (tcem_expired),
                                  
//From CSR                      
   .mem_page_size                  (mem_page_size),
                                 
//From data shifter           
   .start_track                    (start_track),
   .first_addr                     (first_addr),
   .wr_rd                          (wr_rd),
   .xfer_btype                     (xfer_btype),
   .xfer_mem_len                   (xfer_mem_len),
   .sclk_en                        (sclk_en),
   .ce_n_ip                        (ce_n_ip),
                             
// To data shifter          
   .wr_tcem_pg_bndry_expired       (wr_tcem_pg_bndry_expired),
   .wr_last_addr                   (wr_last_addr)
   );

rd_pg_bndry_checker 
   #(
   .AXI_ADDR_WIDTH (AXI_ADDR_WIDTH), 
   .AXI_DATA_WIDTH (AXI_DATA_WIDTH)
    )
RD_PG_BNDRY_CHECKER
   (
   .dqs_inv                          (dqs_inv_final),
   .rst_n                            (rst_n),
                                     
//From CSR                           
   .mem_page_size                    (mem_page_size),
   .mr_access_reg                    (mr_access_reg),
                                    
//From data shifter                
   .start_track                      (start_track), // need to sync (though it is level, and asserted and becomes stable during first dqs_inv posedge). since the rcv_dq_fifo_wr_en is asserted again for the extra dqs_inv clock edge during page boundary crossing.
   .stop_read                      (stop_read), // need to sync (though it is level, and asserted and becomes stable during first dqs_inv posedge). since the rcv_dq_fifo_wr_en is asserted again for the extra dqs_inv clock edge during page boundary crossing.
   .min_dqs_cnt_rch                      (min_dqs_cnt_rch),
   .first_addr                       (first_addr),
   .wr_rd                            (wr_rd),
   .xfer_btype                     (xfer_btype),
   .xfer_mem_len                   (xfer_mem_len),
   .mr8_rbx                          (mr8_rbx),
   .cmd                               (prev_cmd),
   .rd_done_reg  (rd_done_reg),
                                  

// To RCV_CNTRL                   
   .rcv_dq_fifo_wr_en                (rcv_dq_fifo_wr_en),
   .cnt                              (rd_cnt),
                                 
// To data shifter               
   .rd_pg_bndry_expired         (rd_pg_bndry_expired),
   .rd_last_addr                     (rd_last_addr)
   );

data_shifter 
   #(
   .AXI_DATA_WIDTH (AXI_DATA_WIDTH),
   .FIFO_ADDR_WIDTH (RCV_DQ_FIFO_ADDR_WIDTH)
   )
DATA_SHIFTER
   (
//clock and reset
   .mem_clk                          (mem_clk), 
   .rst_n                            (rst_n),
                                     
//AXI4_ERROR filter                  
   .mem_mr_xfer_valid            (mem_mr_xfer_valid),
   .mem_mr_error                     (mem_mr_error),
   .cont_wr_rd_req               (cont_wr_rd_req),
   .mr8_bsize                        (mr8_bsize),
                                    
//AXI4 SLV CNTRL                    
   .mem_mr_xfer_wr_rd                (mem_mr_xfer_wr_rd),
   .mem_mr_xfer_addr                 (mem_mr_xfer_addr),
   .mem_mr_xfer_btype                (mem_mr_xfer_btype),
   .mem_mr_xfer_len                  (mem_mr_xfer_len),
   .mem_mr_xfer_ack                (mem_mr_xfer_ack),
   .xmittr_ack                       (xmittr_ack),
                                   
   .mem_mr_wdata_valid               (mem_mr_wdata_valid),
   .mem_mr_wdata                     (mem_mr_wdata),
   .mem_mr_wlast                     (mem_mr_wlast),
   .mem_mr_wstrb                     (mem_mr_wstrb),
   .xmit_engn_wdata_ack              (xmit_engn_wdata_ack),
   .mem_mr_wdata_ack                 (mem_mr_wdata_ack),
                                  
//SPL_INSTRN_HANDLER              
   .spl_dpd_entry_valid              (spl_dpd_entry_valid),
   .spl_dpd_exit_valid               (spl_dpd_exit_valid),
   .spl_hs_entry_valid               (spl_hs_entry_valid),
   .spl_hs_exit_valid                (spl_hs_exit_valid),
   .spl_glbl_reset_valid             (spl_glbl_reset_valid),
   .mem_spl_xfer_in_prgrs            (mem_spl_xfer_in_prgrs),

// To DQS_INV clock gater and rd_pg_bndry_checker
   .mr_access_reg                    (mr_access_reg),
                                 
//CSR                            
   .mr_access                        (mr_access),
   .dpd_exit_cycle_cnt               (dpd_exit_cycle_cnt),
   .hs_exit_cycle_cnt                (hs_exit_cycle_cnt),
   .mem_base_addr                    (mem_base_addr),
   .mem_top_addr                     (mem_top_addr ),
                                
//CMD_SELECTOR                  
   .cmd                              (cmd),
                               
//WR_TCEM_PG_BNDRY_CHECKER     
   .start_track                      (start_track),
   .min_dqs_cnt_rch                  (min_dqs_cnt_rch_sync),
   .wr_rd                            (wr_rd),
   .first_addr                       (first_addr),
   .wr_tcem_pg_bndry_expired         (wr_tcem_pg_bndry_expired),
   .wr_last_addr                     (wr_last_addr),
   .xfer_btype                     (xfer_btype),
   .xfer_mem_len                   (xfer_mem_len),
                              
//RD_PG_BNDRY_CHECKER    
   .mr8_rbx                          (mr8_rbx),
   .prev_cmd                          (prev_cmd),
   .rd_pg_bndry_expired_sync    (rd_pg_bndry_expired_sync),
   .rd_last_addr                     (rd_last_addr),
   .rd_cnt_sync                      (rd_cnt_sync),
   .rd_done_reg  (rd_done_reg),

//TIMER checker
   .tcem_expired                     (tcem_expired),

//RCV_CNTRL                  
   .rd_done                          (rd_done),
   .rd_stretch                       (rd_stretch),
   .dqs_timeout                      (dqs_timeout),
   .pending_xfer                     (pending_xfer),
   .almost_full_reg                  (almost_full_reg),

//To RDATA packer
   .rcv_dq_fifo_flush_en             (rcv_dq_fifo_flush_en),
   .rcv_dq_fifo_flush_done           (rcv_dq_fifo_flush_done),

                                    
//CMD_SELECTOR,AXI4 ERROR filter
   .mr8_btype                        (mr8_btype),
                               
//Timers                       
   .spl_instrn_dpd_exit_prgrs        (spl_instrn_dpd_exit_prgrs),
   .spl_instrn_hs_exit_prgrs         (spl_instrn_hs_exit_prgrs),
   .spl_instrn_glbl_rst_prgrs        (spl_instrn_glbl_rst_prgrs),
                                    
   .tcph_expired                     (tcph_expired),
   .trc_expired                      (trc_expired),
   .trst_expired                     (trst_expired),
   .txhs_expired                     (txhs_expired),
   .txdpd_expired                    (txdpd_expired),
                                   
//PHY interface                    
   .sclk_en                          (sclk_en),
   .ce_n_ip                          (ce_n_ip),
   .dq_out_ip                        (dq_out_ip),
   .dm_ip                            (dm_ip),
   .dq_oe_ip                      (dq_oe_ip),
   .dm_oe_ip                      (dm_oe_ip)

   );

timer_checker TIMER_CHECKER
   (
   .mem_clk                     (mem_clk),
   .rst_n                       (rst_n),
                              
//From data shifter 
   .ce_n_ip                     (ce_n_ip),
   .spl_instrn_hs_exit_prgrs    (spl_instrn_hs_exit_prgrs),
   .spl_instrn_dpd_exit_prgrs   (spl_instrn_dpd_exit_prgrs),
   .spl_instrn_glbl_rst_prgrs   (spl_instrn_glbl_rst_prgrs),
                   
//From CSR           
   .tcem_cnt                    (tcem_cnt ),
   .trc_cnt                     (trc_cnt  ),
   .tcph_cnt                    (tcph_cnt ),
   .trst_cnt                    (trst_cnt ),
   .txhs_cnt                    (txhs_cnt ),
   .txdpd_cnt                   (txdpd_cnt),
                             
   .tcem_time_ignore            (tcem_time_ignore ),
   .txhs_time_ignore            (txhs_time_ignore ),
   .txdpd_time_ignore           (txdpd_time_ignore),
          
//To wr_tcem_pg_bndry_checker rd_pg_bndry_checker                                        
   .tcem_expired                (tcem_expired     ),

// To data shifter
   .trc_expired                 (trc_expired      ),
   .tcph_expired                (tcph_expired     ),
   .trst_expired                (trst_expired     ),
   .txhs_expired                (txhs_expired     ),
   .txdpd_expired               (txdpd_expired    )
   );

//double_flop_sync 
//   #(
//   .DATA_WIDTH (1)
//    )
//   TCEM_EXPIRED_DQS_SYNC
//   (
//   . clk   (dqs_inv),
//   . rst_n (rst_n),
//   . async_in (tcem_expired),
//   . sync_out (tcem_expired_sync)
//   );

double_flop_sync 
   #(
   .DATA_WIDTH (1)
    )
   RD_PG_BNDRY_EXPIRED_SYNCHRONIZER
   (
   . clk   (mem_clk),
   . rst_n (rst_n),
   . async_in (rd_pg_bndry_expired),
   . sync_out (rd_pg_bndry_expired_sync)
   );

double_flop_sync 
   #(
   .DATA_WIDTH (1)
    )
   RD_PG_BNDRY_RD_CNT_SYNC
   (
   . clk   (mem_clk),
   . rst_n (rst_n),
   . async_in (rd_cnt),
   . sync_out (rd_cnt_sync)
   );


double_flop_sync 
   #(
   .DATA_WIDTH (1),
   .DEF_VAL (1)
    )
   START_TRACK_SYNC
   (
   . clk   (dqs_inv),
   . rst_n (rst_n),
   . async_in (start_track),
   . sync_out (start_track_sync)
   );


double_flop_sync 
   #(
   .DATA_WIDTH (1),
   .DEF_VAL (1)
    )
   MIN_DQS_CNT_RCH_SYNC
   (
   . clk   (mem_clk),
   . rst_n (rst_n),
   . async_in (min_dqs_cnt_rch),
   . sync_out (min_dqs_cnt_rch_sync)
   );

endmodule
