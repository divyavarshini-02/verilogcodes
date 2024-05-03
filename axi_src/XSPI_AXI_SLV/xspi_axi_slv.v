// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------
/*************************************************************************************


*************************************************************************************/


`include "xspi_axi_slv.vh"

module xspi_axi_slv ( 

   axi_clk,
   axi_rst_n,
   mem_clk,
   mem_rst_n,

//AXI4-MEM Master interface
   S_AWADDR,
   S_AWVALID,
   S_AWSIZE,
   S_AWLEN,
   S_AWBURST,
   S_AWID,
   S_AWREADY,

   S_WDATA,
   S_WVALID,
   S_WSTRB,
   S_WLAST,             
   S_WREADY,

   S_ARADDR,
   S_ARVALID,
   S_ARSIZE,
   S_ARLEN,
   S_ARBURST,
   S_ARID,
   S_ARREADY,

   S_BREADY,
   S_BVALID,
   S_BRESP,
   S_BID, 
   
   S_RREADY,
   S_RDATA,
   S_RVALID,
   S_RID,
   S_RLAST,             
   S_RRESP,

//From CSR 
   mem_upper_bound_addr_0,
   mem_lower_bound_addr_0,
   hybrid_wrap_cmd_en,
   mem_xfer_pending,
   hyperflash_en,
   mem_page_size,

//To Main controller
   slv_mem_cmd_valid,
   slv_mem_addr,
   slv_arb_bytes_len,
   slv_mem_err,
   slv_mem_write,
   slv_mem_axi_len,
   slv_mem_burst,
   slv_mem_size,
   slv_mem_cont_rd_req,
   slv_mem_cont_wr_req,

//From Main controller
   mem_slv_cmd_ready, 
   current_xfer, 

//To Mem transfer Interface
   slv_mem_wvalid,
   slv_mem_wstrb,
   slv_mem_wlast,
   slv_mem_wdata,
//From Mem transfer Interface
   mem_slv_wdata_err,
   mem_slv_wdata_ready,

//From Mem transfer Interface
   mem_slv_rdata_valid,
   mem_slv_rdata,
   mem_slv_rdata_last,
   mem_slv_rdata_resp,
//To Mem transfer Interface
   slv_mem_rdata_ready,


//From Main controller 
   spl_instr_req,
   spl_instr_stall,

//To Main controller
   spl_instr_ack

 
);

///////////////////////
// Parameters
///////////////////////

parameter SLV_AXI_ADDR_WIDTH = `AXI_ADDR_WIDTH;
parameter SLV_AXI_DATA_WIDTH = `AXI_DATA_WIDTH;
parameter SLV_AXI_ID_WIDTH   = `AXI_ID_WIDTH;
parameter SLV_AXI_LEN_WIDTH  = `AXI_LEN_WIDTH;
parameter SLV_MEM_DATA_WIDTH = `MEM_DATA_WIDTH;
parameter SLV_WR_ACCEPT      = `AXI_WR_ACCEPT;
parameter SLV_RD_ACCEPT      = `AXI_RD_ACCEPT;

parameter SLV_MEM_LEN_WIDTH  = ( SLV_AXI_DATA_WIDTH == 32 ) ? 11 :
                               ( SLV_AXI_DATA_WIDTH == 64 ) ? 12 : 13 ;
parameter MEM_ADDR_WIDTH     = `PSMEM_ADDR_WIDTH;
parameter XSPI_MEM_ADDR_WIDTH = 32;

parameter CS_SEL = 1;
localparam CS_SEL_BITS = 1;
//localparam CS_SEL_BITS = SLV_AXI_ADDR_WIDTH-MEM_ADDR_WIDTH;

//*********************************INPUTS & OUTPUTS************************************

input                                  axi_clk;
input                                  axi_rst_n;
input                                  mem_clk;
input                                  mem_rst_n;

//AXI4-MEM Master interface
input [SLV_AXI_ADDR_WIDTH-1:0 ]        S_AWADDR;
input                                  S_AWVALID;
input [2:0]                            S_AWSIZE;
input [SLV_AXI_LEN_WIDTH-1 :0 ]        S_AWLEN;   
input [1:0 ]                           S_AWBURST;
input [SLV_AXI_ID_WIDTH-1:0 ]          S_AWID;
output                                 S_AWREADY;

input [SLV_AXI_DATA_WIDTH-1:0 ]        S_WDATA;
input                                  S_WVALID;
input [(SLV_AXI_DATA_WIDTH/8)-1 :0]    S_WSTRB;
input                                  S_WLAST;             
output                                 S_WREADY;

input [SLV_AXI_ADDR_WIDTH-1:0 ]        S_ARADDR;
input                                  S_ARVALID;
input [2:0 ]                           S_ARSIZE;
input [SLV_AXI_LEN_WIDTH-1 :0 ]        S_ARLEN;
input [1:0 ]                           S_ARBURST;
input [SLV_AXI_ID_WIDTH-1:0 ]          S_ARID;
output                                 S_ARREADY;

input                                  S_BREADY;
output                                 S_BVALID;
output [1:0 ]                          S_BRESP;
output [SLV_AXI_ID_WIDTH-1:0 ]         S_BID; 

input                                  S_RREADY;
output [SLV_AXI_DATA_WIDTH-1:0 ]       S_RDATA;
output                                 S_RVALID;
output                                 S_RLAST;             
output [SLV_AXI_ID_WIDTH-1:0 ]         S_RID;
output [1:0 ]                          S_RRESP;

//From CSR 
input [31:0]                           mem_upper_bound_addr_0;
input [31:0]                           mem_lower_bound_addr_0;
input                                  hybrid_wrap_cmd_en;
output				       mem_xfer_pending;	
input				       hyperflash_en;	
input [3:0] mem_page_size;

//To Main controller
output                                 slv_mem_cmd_valid;
output [XSPI_MEM_ADDR_WIDTH-1 : 0 ]                    slv_mem_addr;
output [SLV_MEM_LEN_WIDTH-1 : 0 ]      slv_arb_bytes_len;
output                          slv_mem_err;
output                                 slv_mem_write;
output [SLV_AXI_LEN_WIDTH-1 : 0 ]      slv_mem_axi_len;
output [1 : 0]                         slv_mem_burst;
output [2 : 0]                         slv_mem_size;
output                                 slv_mem_cont_rd_req;
output                                 slv_mem_cont_wr_req;
//From Main controller
input                                  mem_slv_cmd_ready; 
input                                  current_xfer; 

//To Mem transfer Interface
output                                 slv_mem_wvalid;
output [3 : 0 ]                        slv_mem_wstrb;
output                                 slv_mem_wlast;
output [31 : 0 ]                       slv_mem_wdata;
//From Mem transfer Interface
input  [1 :0 ]                         mem_slv_wdata_err;
input                                  mem_slv_wdata_ready;

//From Mem transfer Interface
input                                  mem_slv_rdata_valid;
input  [SLV_MEM_DATA_WIDTH-1 : 0 ]     mem_slv_rdata;
input                                  mem_slv_rdata_last;
input  [ 1 : 0 ]                       mem_slv_rdata_resp;
//To Mem transfer Interface
output                                 slv_mem_rdata_ready;
 
//From Main controller 
input                                  spl_instr_req;
input                                  spl_instr_stall;

//To Main controller
output                                 spl_instr_ack;




//=================================INTERNAL WIRES====================================

wire                                   si_awready;
wire                                   si_arready;
wire [XSPI_MEM_ADDR_WIDTH-1 : 0 ]                       slv_araddr;
wire [ 2 : 0 ]                         slv_arsize;
wire [SLV_AXI_LEN_WIDTH -1 : 0 ]       slv_arlen;
wire [ 1 : 0 ]                         slv_arburst;
wire [SLV_AXI_ID_WIDTH -1  : 0 ]       slv_arid;
 
wire [XSPI_MEM_ADDR_WIDTH-1 : 0 ]                       slv_awaddr;
wire [ 2 : 0 ]                         slv_awsize;
wire [SLV_AXI_LEN_WIDTH -1 : 0 ]       slv_awlen;
wire [ 1 : 0 ]                         slv_awburst;
wire [SLV_AXI_ID_WIDTH -1  : 0 ]       slv_awid;

wire [SLV_AXI_ID_WIDTH -1  : 0 ]       slv_arb_arid;
wire [SLV_AXI_ID_WIDTH -1  : 0 ]       slv_arb_awid;
wire [XSPI_MEM_ADDR_WIDTH-1 : 0 ]                       slv_arb_addr;
wire                      [1:0] slv_ar_err;
wire                      [1:0] slv_aw_err;
wire [ CS_SEL_BITS-1 : 0 ]             slv_aw_cs_sel;
wire [ CS_SEL_BITS-1 : 0 ]             slv_ar_cs_sel;
wire				       wr_pending;
wire				       rd_pending;
wire                                   mem_xfer_pending;

//=================================CODE START HERE===================================
  

assign slv_mem_addr = slv_arb_addr;
assign mem_xfer_pending = wr_pending | rd_pending;

//===================================================================================
//===================================================================================


slv_ard_cmd_ifc  # ( .SLV_AXI_ADDR_WIDTH  (SLV_AXI_ADDR_WIDTH ),
                     .MEM_ADDR_WIDTH      (MEM_ADDR_WIDTH ),
                     .XSPI_MEM_ADDR_WIDTH (XSPI_MEM_ADDR_WIDTH ),
                     .SLV_AXI_ID_WIDTH    (SLV_AXI_ID_WIDTH ),
                     .SLV_AXI_LEN_WIDTH   (SLV_AXI_LEN_WIDTH ),
                     .SLV_RD_ACCEPT       (SLV_RD_ACCEPT ),
                     . CS_SEL (CS_SEL)
                   )
       u_slv_ard_cmd_ifc (

          .si_araddr              ( S_ARADDR ),
          .si_arvalid             ( S_ARVALID ),
          .si_arsize              ( S_ARSIZE ),
          .si_arlen               ( S_ARLEN ),
          .si_arburst             ( S_ARBURST ),
          .si_arid                ( S_ARID ),
          .si_arready             ( S_ARREADY ),
          .si_rvalid              ( S_RVALID ),
          .si_rlast               ( S_RLAST ),
          .si_rready              ( S_RREADY ),
          .spl_instr_req          ( spl_instr_req ),
          .spl_instr_stall        ( spl_instr_stall ),
          .axi_clk                ( axi_clk ), 
          .axi_rst_n              ( axi_rst_n ),
          
          .mem_lower_bound_addr_0         ( mem_lower_bound_addr_0 ),
          .mem_upper_bound_addr_0          ( mem_upper_bound_addr_0 ),

          .mem_clk                ( mem_clk ), 
          .mem_rst_n              ( mem_rst_n ),

          .slv_araddr             ( slv_araddr ),
          .slv_arvalid            ( slv_arvalid ),
          .slv_arsize             ( slv_arsize ),
          .slv_arlen              ( slv_arlen ),
          .slv_arburst            ( slv_arburst ),
          .slv_arid               ( slv_arid ),
          .slv_ar_err             ( slv_ar_err ),
          .slv_ar_cs_sel          ( slv_ar_cs_sel),
          .slv_arready            ( slv_arb_arready ),
          .rd_pending             ( rd_pending  ) 
);

//===================================================================================
//===================================================================================

slv_awr_cmd_ifc  # ( .SLV_AXI_ADDR_WIDTH  (SLV_AXI_ADDR_WIDTH ),
                     .XSPI_MEM_ADDR_WIDTH (XSPI_MEM_ADDR_WIDTH ),
                     .SLV_AXI_ID_WIDTH    (SLV_AXI_ID_WIDTH ),
                     .SLV_AXI_LEN_WIDTH   (SLV_AXI_LEN_WIDTH ),
                     .SLV_WR_ACCEPT       (SLV_WR_ACCEPT ),
                     .MEM_ADDR_WIDTH      (MEM_ADDR_WIDTH ),
                     . CS_SEL (CS_SEL)
                   )
       u_slv_awr_cmd_ifc (

          .axi_clk                ( axi_clk ), 
          .axi_rst_n              ( axi_rst_n ),

          .si_awaddr              ( S_AWADDR ),
          .si_awvalid             ( S_AWVALID ),
          .si_awsize              ( S_AWSIZE ),
          .si_awlen               ( S_AWLEN ),
          .si_awburst             ( S_AWBURST ),
          .si_awid                ( S_AWID ),
          .si_bvalid              ( S_BVALID ),
          .si_bready              ( S_BREADY ),
          .si_awready             ( S_AWREADY ),

          .spl_instr_req          ( spl_instr_req ),
          .spl_instr_stall        ( spl_instr_stall ),

          .mem_lower_bound_addr_0         ( mem_lower_bound_addr_0 ),
          .mem_upper_bound_addr_0          ( mem_upper_bound_addr_0 ),
          
          .mem_clk                ( mem_clk ), 
          .mem_rst_n              ( mem_rst_n ),

          .slv_awaddr             ( slv_awaddr ),
          .slv_awvalid            ( slv_awvalid ),
          .slv_awsize             ( slv_awsize ),
          .slv_awlen              ( slv_awlen ),
          .slv_awburst            ( slv_awburst ),
          .slv_awid               ( slv_awid ),
          .slv_aw_err             ( slv_aw_err ),
          .slv_aw_cs_sel          ( slv_aw_cs_sel),
          .slv_awready            ( slv_arb_awready ),
          .wr_pending		  (wr_pending )

);

//===================================================================================
//===================================================================================

slv_rdwr_arb  # (    .SLV_AXI_ADDR_WIDTH  (SLV_AXI_ADDR_WIDTH ),
                     .XSPI_MEM_ADDR_WIDTH (XSPI_MEM_ADDR_WIDTH ),
                     .SLV_AXI_ID_WIDTH    (SLV_AXI_ID_WIDTH ),
                     .SLV_AXI_LEN_WIDTH   (SLV_AXI_LEN_WIDTH ),
                     .SLV_MEM_LEN_WIDTH   (SLV_MEM_LEN_WIDTH ),
                     .MEM_ADDR_WIDTH      (MEM_ADDR_WIDTH )
                   )

       u_slv_rdwr_arb ( 

          .mem_clk                ( mem_clk ), 
          .mem_rst_n              ( mem_rst_n ),

//From CSR
          .hybrid_wrap_cmd_en     (hybrid_wrap_cmd_en),
          .hyperflash_en	  (hyperflash_en     ),
          .mem_page_size (mem_page_size),
          .slv_araddr             ( slv_araddr ),
          .slv_arvalid            ( slv_arvalid ),
          .slv_arsize             ( slv_arsize ),
          .slv_arlen              ( slv_arlen ),
          .slv_arburst            ( slv_arburst ),
          .slv_arid               ( slv_arid ), 
          .slv_ar_err             ( slv_ar_err ),
          .slv_ar_cs_sel          ( slv_ar_cs_sel),
          .slv_arb_arready        ( slv_arb_arready ),
          .slv_awaddr             ( slv_awaddr ),
          .slv_awvalid            ( slv_awvalid ),
          .slv_awsize             ( slv_awsize ),
          .slv_awlen              ( slv_awlen ),
          .slv_awburst            ( slv_awburst ),
          .slv_awid               ( slv_awid ), 
          .slv_aw_err             ( slv_aw_err ),
          .slv_aw_cs_sel          ( slv_aw_cs_sel),
          .slv_arb_awready        ( slv_arb_awready ),  
          .slv_arb_wr_start_en    ( slv_arb_wr_start_en ),
          .slv_arb_addr           ( slv_arb_addr ),
          .slv_arb_valid          ( slv_mem_cmd_valid ),
          .slv_arb_write          ( slv_mem_write ), 
          .slv_arb_burst          ( slv_mem_burst ), 
          .slv_arb_axi_len        ( slv_mem_axi_len ), 
          .slv_arb_bytes_len        ( slv_arb_bytes_len ), 
          .slv_arb_size           ( slv_mem_size ),
          .slv_arb_err            ( slv_mem_err ),
          .slv_arb_cs_sel         ( slv_mem_cs_sel ),
          .slv_arb_awid           ( slv_arb_awid ),
          .slv_arb_arid           ( slv_arb_arid ), 
          .slv_arb_ready          ( mem_slv_cmd_ready ),
          .slv_mem_cont_rd_req ( slv_mem_cont_rd_req ),
          .slv_mem_cont_wr_req ( slv_mem_cont_wr_req )

);

//===================================================================================
//===================================================================================

slv_wdata_ff # (

                    .SLV_AXI_DATA_WIDTH (SLV_AXI_DATA_WIDTH ),
                    .SLV_MEM_DATA_WIDTH (SLV_MEM_DATA_WIDTH )
               )

       u_slv_wdata_ff ( 

          .axi_clk                ( axi_clk ),         
          .axi_rst_n              ( axi_rst_n ),
          .si_wvalid              ( S_WVALID ),
          .si_wdata               ( S_WDATA ),
          .si_wstrb               ( S_WSTRB ),
          .si_wlast               ( S_WLAST ),
          .si_wready              ( S_WREADY ),
         
          .mem_clk                ( mem_clk ), 
          .mem_rst_n              ( mem_rst_n ),
          .hyperflash_en	  (hyperflash_en     ),
          .slv_arb_wr_start_en    ( slv_arb_wr_start_en ),
          .slv_arb_addr           ( slv_arb_addr ),
          .slv_awsize             ( slv_awsize ), 
          .slv_awburst            ( slv_awburst ), 
          .slv_wdata_ready        ( mem_slv_wdata_ready ),
          .slv_wdata              ( slv_mem_wdata ), 
          .slv_wvalid             ( slv_mem_wvalid ), 
          .slv_wstrb              ( slv_mem_wstrb ), 
          .slv_wlast              ( slv_mem_wlast ),
          .slv_aw_burst_complete  ( slv_aw_burst_complete )

);

//===================================================================================
//===================================================================================

slv_wresp_ifc  # (
                     .SLV_AXI_ID_WIDTH    (SLV_AXI_ID_WIDTH )
                  )

        u_slv_wresp_ifc (

          .mem_clk                ( mem_clk ), 
          .mem_rst_n              ( mem_rst_n ), 
          .slv_arb_awid           ( slv_arb_awid ), 
          .slv_arb_awready        ( slv_arb_awready ), 
          .mem_slv_wdata_err      ( mem_slv_wdata_err ),
          .slv_aw_burst_complete  ( slv_aw_burst_complete ),
     
          .axi_clk                ( axi_clk ), 
          .axi_rst_n              ( axi_rst_n ),
          .S_BID                  ( S_BID ), 
          .S_BRESP                ( S_BRESP ), 
          .S_BVALID               ( S_BVALID ), 
          .S_BREADY               ( S_BREADY )

);

//===================================================================================
//===================================================================================

slv_rdata_ff  # (
                   .SLV_AXI_DATA_WIDTH (SLV_AXI_DATA_WIDTH), 
                   .SLV_AXI_ID_WIDTH   (SLV_AXI_ID_WIDTH), 
                   .SLV_MEM_DATA_WIDTH (SLV_MEM_DATA_WIDTH) 
                )
        u_slv_rdata_ff (

         .mem_clk                 ( mem_clk ), 
         .mem_rst_n               ( mem_rst_n ),
         .mem_slv_rdata_valid     ( mem_slv_rdata_valid ), 
         .mem_slv_rdata           ( mem_slv_rdata ), 
         .mem_slv_rdata_last      ( mem_slv_rdata_last ), 
         .mem_slv_rdata_resp      ( mem_slv_rdata_resp  ),
         .slv_mem_rdata_ack       ( slv_mem_rdata_ready ),
         .slv_arb_arid            ( slv_arb_arid), 
         .slv_arb_arready         ( slv_arb_arready ),

         .axi_clk                 ( axi_clk ), 
         .axi_rst_n               ( axi_rst_n ),
         .S_RVALID                ( S_RVALID ), 
         .S_RDATA                 ( S_RDATA ), 
         .S_RID                   ( S_RID ), 
         .S_RLAST                 ( S_RLAST ), 
         .S_RRESP                 ( S_RRESP ), 
         .S_RREADY                ( S_RREADY )
    

);

//===================================================================================
// SPL Instruction ACK State machine
//===================================================================================

parameter SPL_INST_IDLE      = 2'b00;
parameter SPL_INST_READY_CHK = 2'b01;
parameter SPL_INST_ACK       = 2'b10;

reg [1:0] cur_spl_inst_state;
reg [1:0] nxt_spl_inst_state;

always @ ( * )
begin
   case ( cur_spl_inst_state )
     SPL_INST_IDLE :
     begin
        if ( spl_instr_req )
          nxt_spl_inst_state  = SPL_INST_READY_CHK;
        else
          nxt_spl_inst_state  = SPL_INST_IDLE;
     end 
     SPL_INST_READY_CHK :
     begin
        if ( wr_pending  || rd_pending )
           nxt_spl_inst_state  = SPL_INST_READY_CHK;
        else
           nxt_spl_inst_state  = SPL_INST_ACK;
     end 
     SPL_INST_ACK :
     begin
        nxt_spl_inst_state  = SPL_INST_IDLE;
     end 
     default :
     begin
        nxt_spl_inst_state  = SPL_INST_IDLE;
     end 
   endcase
end

always @ ( posedge axi_clk or negedge axi_rst_n )
begin
   if ( ~axi_rst_n )
   begin
      cur_spl_inst_state  <= SPL_INST_IDLE;
   end
   else
   begin
      cur_spl_inst_state  <= nxt_spl_inst_state;
   end
end

assign spl_instr_ack = ( cur_spl_inst_state == SPL_INST_ACK ); 

//assign spl_instr_ack = spl_instr_req ? ( (!current_xfer) ? 1'b1 : 1'b0) : spl_instr_req; 
//assign spl_instr_ack = (spl_instr_req & !current_xfer) ? 1'b1 : spl_instr_req; 
endmodule // xspi_axi_slv
