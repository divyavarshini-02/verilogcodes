// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------
//====================================================================================
// 
//====================================================================================

`include "xspi_axi_slv.vh"

module slv_wresp_ifc  (

     mem_clk, 
     mem_rst_n, 
     slv_arb_awid, 
     slv_arb_awready , 
     slv_aw_burst_complete,
     mem_slv_wdata_err,
     axi_clk, 
     axi_rst_n,

     S_BID, 
     S_BRESP, 
     S_BVALID, 
     S_BREADY

);

parameter SLV_AXI_ID_WIDTH   = 4;


//*********************************INPUTS & OUTPUTS************************************

input                                  mem_clk;
input                                  mem_rst_n;
input                                  slv_aw_burst_complete;
input [1:0]                            mem_slv_wdata_err;
input                                  slv_arb_awready;
input [SLV_AXI_ID_WIDTH -1 : 0]        slv_arb_awid;


input                                  axi_clk;
input                                  axi_rst_n;

output  [SLV_AXI_ID_WIDTH-1 : 0 ]      S_BID;
output  [ 1 : 0 ]                      S_BRESP;
output                                 S_BVALID;
input                                  S_BREADY; 


//===================================================================================

reg     [SLV_AXI_ID_WIDTH-1 : 0 ]      S_BID;
reg     [ 1 : 0 ]                      S_BRESP;
reg                                    S_BVALID;

reg     [SLV_AXI_ID_WIDTH-1 : 0 ]      wresp_awid;
reg     [ 1 : 0 ]                      wresp_err;

//********************************CODE START HERE************************************

parameter WRESP_IDLE = 2'b00;
parameter WRESP_RD   = 2'b01;
parameter WRESP_VALID= 2'b10;

reg [1:0] cur_slv_wresp_state;
reg [1:0] nxt_slv_wresp_state;


//===================================================================================

always @ ( posedge mem_clk or negedge mem_rst_n )
begin
   if ( ~mem_rst_n )
   begin
      wresp_awid  <= 'd0; 
   end
   else
   begin
      if ( slv_arb_awready )
      begin
         wresp_awid  <= slv_arb_awid;
      end
      else if ( slv_aw_burst_complete )
      begin
         wresp_awid  <= 'd0; 
      end
   end
end


wire wresp_ff_empty;
wire wresp_ff_full;
wire [SLV_AXI_ID_WIDTH+1 : 0] wresp_ff_wdata;
wire [SLV_AXI_ID_WIDTH+1 : 0] wresp_ff_rdata;
wire rdata_valid;

assign wresp_ff_wdata = {mem_slv_wdata_err,wresp_awid}; 


parameter	PTR_WIDTH = 3;
parameter	DEPTH  = 7;
parameter	DATA_WIDTH = SLV_AXI_ID_WIDTH + 2;

wire [PTR_WIDTH-1:0] ram_write_addr;
wire [PTR_WIDTH-1:0] ram_read_addr; 


assign wresp_ff_wr_en   = slv_aw_burst_complete & ~wresp_ff_full ; 
assign wresp_ff_rd_en   = ( cur_slv_wresp_state == WRESP_IDLE ) & ~wresp_ff_empty;


gen_fifo_async_ctl # ( PTR_WIDTH ) u_slv_wresp_ff (
   // Outputs
   .wdepth               ( ), 
   .rdepth               ( ), 
   .ram_write_strobe     ( ram_write_strobe ), 
   .ram_write_addr       ( ram_write_addr ), 
   .ram_read_strobe      ( ram_read_strobe ), 
   .ram_read_addr        ( ram_read_addr ), 
   .full                 ( wresp_ff_full ), 
   .empty                ( wresp_ff_empty ), 
   .dout_v               ( rdata_valid ), 
   // Inputs
   .wusable              ( 1'b1), 
   .wreset               ( ~mem_rst_n ), 
   .wclk                 ( mem_clk ), 
   .rusable              ( 1'b1), 
   .rreset               ( ~axi_rst_n ), 
   .rclk                 ( axi_clk ), 
   .push                 ( wresp_ff_wr_en), 
   .pop                  ( wresp_ff_rd_en)
);

`ifdef FPGA_OR_SIMULATION

mem_1w1r_fpga_or_sim # ( PTR_WIDTH, DATA_WIDTH , DEPTH  ) slv_wr_resp_ff_mem (
    .wclk                ( mem_clk ),
    .waddr               ( ram_write_addr ),
    .wen                 ( ram_write_strobe ),
    .wdata               ( wresp_ff_wdata),

    .rclk                ( axi_clk ),
    .raddr               ( ram_read_addr ),
    .ren                 ( ram_read_strobe),
    .rdata               ( wresp_ff_rdata)
);

`endif

`ifdef ASIC_SYNTH

mem_1w1r_asic6 # ( PTR_WIDTH, DATA_WIDTH , DEPTH  ) slv_wr_resp_ff_mem (
    .wclk                ( mem_clk ),
    .wrst_n                ( mem_rst_n ),
    .waddr               ( ram_write_addr ),
    .wen                 ( ram_write_strobe ),
    .wdata               ( wresp_ff_wdata),

    .rclk                ( axi_clk ),
    .rrst_n                ( axi_rst_n ),
    .raddr               ( ram_read_addr ),
    .ren                 ( ram_read_strobe),
    .rdata               ( wresp_ff_rdata)
);

`endif


//+++++++++++++++++++++++++++++++
// WR RESPONSE  
//+++++++++++++++++++++++++++++++

//===================================================================================
//===================================================================================


always @ ( * )
begin
   case ( cur_slv_wresp_state )
     WRESP_IDLE :
     begin
        if ( ~wresp_ff_empty )
           nxt_slv_wresp_state  = WRESP_RD ;
        else 
           nxt_slv_wresp_state  = WRESP_IDLE;
     end 
     WRESP_RD :
     begin
        nxt_slv_wresp_state  = WRESP_VALID;
     end 
     WRESP_VALID :
     begin
        if ( S_BREADY )
           nxt_slv_wresp_state  = WRESP_IDLE;
        else
           nxt_slv_wresp_state  = WRESP_VALID;
     end 
     default :
     begin
        nxt_slv_wresp_state  = WRESP_IDLE;
     end 
   endcase
end

always @ ( posedge axi_clk or negedge axi_rst_n )
begin
   if ( ~axi_rst_n )
   begin
      cur_slv_wresp_state <= WRESP_IDLE; 
      S_BRESP             <= 2'd0;
      S_BID               <= {SLV_AXI_ID_WIDTH{1'b0}};
      S_BVALID            <= 1'b0;
   end
   else
   begin
      cur_slv_wresp_state <= nxt_slv_wresp_state; 
      case ( nxt_slv_wresp_state )
         WRESP_IDLE :
         begin
            S_BRESP             <= 2'd0;
            S_BID               <= {SLV_AXI_ID_WIDTH{1'b0}};
            S_BVALID            <= 1'b0;
         end 
         WRESP_RD :
         begin
            S_BRESP             <= 2'd0;
            S_BID               <= {SLV_AXI_ID_WIDTH{1'b0}};
            S_BVALID            <= 1'b0;
         end 
         WRESP_VALID :
         begin
            if ( rdata_valid )
            begin
               S_BRESP             <= wresp_ff_rdata[SLV_AXI_ID_WIDTH+1:SLV_AXI_ID_WIDTH];  
               S_BID               <= wresp_ff_rdata[SLV_AXI_ID_WIDTH-1:0];
               S_BVALID            <= 1'b1;
            end
         end 
         default :
         begin
            S_BRESP             <= 2'd0;
            S_BID               <= {SLV_AXI_ID_WIDTH{1'b0}};
            S_BVALID            <= 1'b0;
         end 
      endcase 
   end
end


endmodule // slv_wresp_ifc 
