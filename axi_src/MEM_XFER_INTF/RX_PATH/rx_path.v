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
module rx_path
   (

mem_clk,
reset_n,

//From AXI4_SLV_CNTRL
mem_mr_xfer_valid,
mem_mr_error,
mem_mr_xfer_addr_lsb,
mem_mr_xfer_wr_rd,
mem_mr_axi_len,
mem_mr_xfer_btype,
cont_rd_req,
mem_mr_xfer_bsize,

//To AXI4_SLV_CNTRL
mem_mr_xfer_ack,

mem_mr_rdata_valid,
mem_mr_rdata,
mem_mr_rlast,
mem_mr_rresp,

//From AXI4_SLV_CNTRL
mem_mr_rdata_ack,

//From Instruction handler
xmittr_ack,
ddr_en,                     //Indicates the read instruction is SDR/DDR
bits_enabled,               //Indicates the number of pins to be used for read transfer
start_read,                 //Trigger for the read; asserted when read instruction is executed from instruction handler
csr_trigger,                //Memory status register read is triggered by CSR. So the read data has to be sent to CSR rather than data packer
axi_trigger,                //Memory status register read is triggered by AXI. So the read data has to be sent to AXI
instrn_dlp_en,              //DLP read enabled through instruction
instrn_dlp_pattern,         //DLP pattern for the DLP instruction
rcv_dq_fifo_flush_en,       //Flush dqfifo afer every read
// To instruction handler
rcv_dq_fifo_flush_done,
dlp_read_stop,                  //dlp end detected one clock earlier than usual ending of dlp
csr_read_end,                        //Indicates dqs non toggle err condition
//From write engine
sclk_en,
dq_oe_ip,
ce_n_ip,

//To write engine
rd_done,
rd_clk_stretch,

//From instruction handler
mem_illegal_instrn_err, // level - mem_clk

//From CSR
dqs_non_tgl_to,
csr_dlp_cyc_cnt,              //DLP cycle count in terms of sclk; allowed values are : 
                              //if DLP is enabled through instruction - value 1 to 4;
no_of_data_bytes,
mem_rd_data_ack,
predrive_en,
dummy_cycle_config,
//To CSR
calib_tap_valid,
calib_tap_out,
mem_rd_valid,
mem_rd_data, 
csr_dqs_non_toggle_err,
axi_dqs_non_toggle_err,

//From memory
dqs_ip,
dq_in_ip

   );

//=======================parameters===================================

parameter MEM_AXI_DATA_WIDTH=32;
parameter RCV_DQ_FIFO_ADDR_WIDTH = 4;
localparam DQS_CNT_WIDTH = (MEM_AXI_DATA_WIDTH==32) ? 10: ((MEM_AXI_DATA_WIDTH==64) ? 11 : 12);


// =======================I/O=========================================

input                       mem_clk;
input                       reset_n;
//From AXI4_SLV_CNTRL
input                       mem_mr_xfer_valid;
input                       mem_mr_error;
input [3:0]                 mem_mr_xfer_addr_lsb;
input                       mem_mr_xfer_wr_rd;
input [7:0]                 mem_mr_axi_len;
input [1:0]                 mem_mr_xfer_btype;
input                       cont_rd_req;
input [2:0]                 mem_mr_xfer_bsize;

//To AXI4_SLV_CNTRL
output                      mem_mr_xfer_ack;

output                      mem_mr_rdata_valid;
output [MEM_AXI_DATA_WIDTH-1:0] mem_mr_rdata;
output                      mem_mr_rlast;
output [1:0]                mem_mr_rresp;

//From AXI4_SLV_CNTRL
input                       mem_mr_rdata_ack;

//From Instruction Handler
input                       xmittr_ack;
input                       ddr_en;
input [1:0]                 bits_enabled;
input                       start_read;
input                       csr_trigger;
input                       axi_trigger;
input                       instrn_dlp_en;
input [7:0]                 instrn_dlp_pattern;
input                       rcv_dq_fifo_flush_en;
// To instruction handler
output                      rcv_dq_fifo_flush_done;
output                      dlp_read_stop;
output                      csr_read_end;

//From write engine
input sclk_en;
input                       dq_oe_ip;
input                       ce_n_ip;
//To write engine
output                      rd_done;
output                      rd_clk_stretch;

//From instrucntion handler
input mem_illegal_instrn_err; // level - mem_clk

//From CSR
input [4:0]                 dqs_non_tgl_to;
input [2:0]                 csr_dlp_cyc_cnt;
input [5:0]	            no_of_data_bytes;
input		            mem_rd_data_ack;
input		            predrive_en;
input [4:0]	            dummy_cycle_config;

//To CSR
output                      calib_tap_valid;
output  [7:0]               calib_tap_out;
output                      mem_rd_valid;
output [31:0]                mem_rd_data; 
output                      csr_dqs_non_toggle_err;
output                      axi_dqs_non_toggle_err;


input                       dqs_ip;
input [7:0]                 dq_in_ip;

// ============================wires=================================
wire         cont_rd_ack;
wire         rcv_dqfifo_empty;
wire         dqs_timeout;
wire         rd_start;
wire [3:0]   rd_addr_lsb;
wire    rd_err;
wire [7:0]   rd_xfer_axi_len;
wire [1:0]   rd_xfer_btype;
wire [2:0]   rd_xfer_bsize;
wire         rcv_dqfifo_rden;
wire [15:0]  mem_16bit_rdata;
wire         mem_16bit_rdata_ack;

/////////////////////////////////////////////////////////////////////////////////////////////////
//Module instances
/////////////////////////////////////////////////////////////////////////////////////////////////

//Receiver control block
//It receives read data and control signals from read engine and group the
//data as needed by the AXI read path inputs and send the read data to AXI
//slave read data interface

rcv_cntrl 
   # (.AXI_DATA_WIDTH (MEM_AXI_DATA_WIDTH)
     ) 
   rcv_cntrl_dut

   (
   .mem_clk (mem_clk),
   .reset_n (reset_n),

// AXI slave controller interface
   .mem_mr_xfer_valid (mem_mr_xfer_valid),
   .mem_mr_error (mem_mr_error),
   .mem_mr_xfer_addr_lsb (mem_mr_xfer_addr_lsb),
   .mem_mr_xfer_wr_rd (mem_mr_xfer_wr_rd),
   .cont_rd_req    (cont_rd_req),
   .mem_mr_axi_len (mem_mr_axi_len),
   .mem_mr_xfer_btype (mem_mr_xfer_btype),
   .mem_mr_xfer_bsize (mem_mr_xfer_bsize),
   
   .mem_mr_rdata_valid(mem_mr_rdata_valid),
   .mem_mr_rlast      (mem_mr_rlast),
   .mem_mr_rdata_ack  (mem_mr_rdata_ack),

// From TX_PATH
   .xmittr_ack        (xmittr_ack),

// From DQS non-toggle checker
   .dqs_timeout (dqs_timeout),

//From MEM_XFER_INTF
   .mem_illegal_instrn_err (mem_illegal_instrn_err), // level - mem_clk
// To ACK resolver
   .cont_rd_ack (cont_rd_ack), // pulse - Asserted only for continuous read transfers, provided dqs_timeout event is not happened

// TO transmit engine (To control SCLK_EN and CE de-assertion) and to control rd_stretch 
   .rd_done (rd_done), // pulse - Asserted after all continuous read transfers, if any, are complete

// TO AXI_RDATA_CTRL block
   .rd_start (rd_start),  // during every read and continuous read transfer
   .rd_addr_lsb (rd_addr_lsb),
   .rd_xfer_axi_len (rd_xfer_axi_len),
   .rd_xfer_btype (rd_xfer_btype),
   .rd_xfer_bsize (rd_xfer_bsize),
   .rd_err (rd_err)

   );

mem_mr_xfer_ack_resolver ack_resolver
   (
   . xmittr_ack (xmittr_ack),
   . cont_rd_ack (cont_rd_ack),
   . mem_mr_xfer_ack (mem_mr_xfer_ack)
   );

mem_axi_rd  
   # ( 
     .SLV_AXI_DATA_WIDTH (MEM_AXI_DATA_WIDTH),
     .MEM_FIFO_DATA_WIDTH (16)
     )
axi_rdata_packer
     (
     .mem_clk              (mem_clk        ),
     .reset_n              (reset_n          ),
     
     .mem_axi_rd_start     (rd_start       ),
     .mem_axi_rd_addr_lsb  (rd_addr_lsb),
     .mem_axi_rd_err       (rd_err         ),
     .mem_slv_axi_len      (rd_xfer_axi_len    ),
     .mem_axi_btype        (rd_xfer_btype  ),
     .mem_axi_size         (rd_xfer_bsize  ),
     .mem_dqs_time_out     (dqs_timeout    ),
     .mem_illegal_instrn_err (mem_illegal_instrn_err),

     .mem_16bit_rdata_valid (mem_16bit_rdata_valid),
     .mem_16bit_rdata_in       (mem_16bit_rdata      ),
     .mem_16bit_rdata_ack   (mem_16bit_rdata_ack  ),

     .mem_slv_rdata_valid  (mem_mr_rdata_valid ),
     .mem_slv_rdata        (mem_mr_rdata       ),
     .mem_slv_rdata_last   (mem_mr_rlast  ),
     .mem_slv_rdata_resp   (mem_mr_rresp  ),
     .slv_mem_rdata_ack    (mem_mr_rdata_ack   )

);

dqs_non_tgl_to_checker dqs_non_tgl_to_checker_dut
(
 .mem_clk           (mem_clk),
 .reset_n           (reset_n),
 .rd_progress       (start_read),
 .ce_n_ip           (ce_n_ip),
 .rcv_dq_fifo_empty (rcv_dqfifo_empty),
 .dqs_pulse   (dqs_pulse_sync),
 .sclk_en     (sclk_en),
 .dq_oe             (dq_oe_ip),
 .dqs_non_tgl_to    (dqs_non_tgl_to),
                    
 .dqs_timeout       (dqs_timeout)
);


read_engine 
#(.RCV_DQ_FIFO_ADDR_WIDTH (RCV_DQ_FIFO_ADDR_WIDTH)
 )
READ_ENGINE (

//INPUT PORTS 
   .mem_clk                    (mem_clk),
   .reset_n                    (reset_n),

//From Memory                
   .dqs                        (dqs_ip),
   .dq_in                      (dq_in_ip),
                            
//From CSR                  
   .csr_dlp_cyc_cnt            (csr_dlp_cyc_cnt),
   .no_of_data_bytes	       (no_of_data_bytes),
   .predrive_en	               (predrive_en),
   .dummy_cycle_config         (dummy_cycle_config),
                           
//From write engine        
   .rcv_dq_fifo_flush_en       (rcv_dq_fifo_flush_en),
                          
//From Instruction Handler
   .ddr_en                     (ddr_en),
   .bits_enabled               (bits_enabled),
   .start_read                 (start_read),
   .csr_trigger                (csr_trigger),
   .axi_trigger                (axi_trigger),
   .instrn_dlp_en              (instrn_dlp_en),
   .instrn_dlp_pattern         (instrn_dlp_pattern),
                         
// FROM RCVR_CNTRL       
   .rd_done                    (rd_done),

//From RX DATA PACKER
   .mem_16bit_rdata_ack                 (mem_16bit_rdata_ack),
   .dqs_timeout                (dqs_timeout),

//OUTPUT PORTS          
                       
//To Instruction Handler
   .dlp_read_stop              (dlp_read_stop),
   .rcv_dq_fifo_flush_done     (rcv_dq_fifo_flush_done),
   .csr_read_end                   (csr_read_end),
                            
//To CSR                    
   .calib_tap_out              (calib_tap_out  ),
   .calib_tap_valid            (calib_tap_valid),
   .mem_rd_valid    (mem_rd_valid),
   .mem_rd_data     (mem_rd_data),
   .mem_rd_data_ack (mem_rd_data_ack ),
  .csr_dqs_non_toggle_err      (csr_dqs_non_toggle_err),
  .axi_dqs_non_toggle_err      (axi_dqs_non_toggle_err),
                       
//To write engine      
   .rd_clk_stretch             (rd_clk_stretch),
                      
//To RX DATA PACKER
   .mem_16bit_rdata                     (mem_16bit_rdata),
   .mem_16bit_rdata_valid               (mem_16bit_rdata_valid),
//To timeout checker
   .rcv_dqfifo_empty           (rcv_dqfifo_empty),
   .dqs_pulse                  (dqs_pulse) 


);

double_flop_sync 
   #(
   .DATA_WIDTH (1)
    )
   DQS_PULSE__SYNCHRONIZER
   (
   . clk   (mem_clk),
   . rst_n (reset_n),
   . async_in (dqs_pulse),
   . sync_out (dqs_pulse_sync)
  );



endmodule
