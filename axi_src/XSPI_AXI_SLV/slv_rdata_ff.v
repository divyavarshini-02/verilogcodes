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
// 
// 
// 
//====================================================================================

`include "xspi_axi_slv.vh"

module slv_rdata_ff  (

     mem_clk, 
     mem_rst_n,
     mem_slv_rdata_valid, 
     mem_slv_rdata, 
     mem_slv_rdata_last, 
     mem_slv_rdata_resp,
     slv_mem_rdata_ack,
     slv_arb_arid, 
     slv_arb_arready,


     axi_clk, 
     axi_rst_n,
     
     S_RVALID, 
     S_RDATA, 
     S_RID, 
     S_RLAST, 
     S_RRESP, 
     S_RREADY
    

);

parameter SLV_AXI_DATA_WIDTH  = 32;
parameter SLV_AXI_ID_WIDTH    = 4;
parameter SLV_MEM_DATA_WIDTH  = 32;

//*********************************INPUTS & OUTPUTS************************************
 
input                                  mem_clk;
input                                  mem_rst_n;
input                                  mem_slv_rdata_valid;
input [SLV_MEM_DATA_WIDTH-1 : 0 ]      mem_slv_rdata;
input                                  mem_slv_rdata_last;
input [ 1 : 0 ]                        mem_slv_rdata_resp;
output                                 slv_mem_rdata_ack;
input [SLV_AXI_ID_WIDTH -1 : 0 ]       slv_arb_arid;
input                                  slv_arb_arready;

input                                  axi_clk;
input                                  axi_rst_n;

output                                 S_RVALID;
output [SLV_AXI_DATA_WIDTH -1 : 0]     S_RDATA;
output [SLV_AXI_ID_WIDTH - 1 : 0 ]     S_RID;
output                                 S_RLAST;
output [ 1 : 0 ]                       S_RRESP;
input                                  S_RREADY;

//===================================================================================

reg                                    S_RVALID;
reg    [SLV_AXI_DATA_WIDTH -1 : 0]     S_RDATA;
reg                                    S_RLAST;
reg    [ 1 : 0 ]                       S_RRESP;

reg  [SLV_AXI_DATA_WIDTH +3 :0]        rdata_ff_rdata_reg;
reg    [SLV_AXI_ID_WIDTH - 1 : 0 ]     rid_reg;


wire    [SLV_AXI_ID_WIDTH - 1 : 0 ]    S_RID;
wire [SLV_AXI_DATA_WIDTH +3 :0]        rdata_ff_wdata;
wire                                   rdata_ff_full;
wire                                   rdata_ff_empty;
wire                                   rdata_valid;
wire                                   rdata_ff_wren;
wire                                   rdata_ff_rden;
wire [SLV_AXI_DATA_WIDTH +3 :0]        rdata_ff_rdata;

wire [SLV_AXI_DATA_WIDTH-1 : 0]        mem_slv_ff_rdata;
wire [1 : 0]                           mem_slv_ff_rdata_resp;
wire                                   mem_slv_ff_rdata_valid;
wire                                   mem_slv_ff_rdata_last;

wire                                   rdata_last;

reg                                    rid_rd_start_lat;

//********************************CODE STARTHERE*************************************




//===================================================================================
//
//===================================================================================
//RID FIFO
//===================================================================================

wire [SLV_AXI_ID_WIDTH -1 :0]  rid_ff_wdata;
wire [SLV_AXI_ID_WIDTH -1 :0]  rid_ff_rdata;
wire rid_ff_full;
wire rid_ff_empty;
wire rid_ff_wren;
wire rid_ff_rden;


assign rid_ff_wren  = slv_arb_arready & ~rid_ff_full;
assign rid_ff_wdata = slv_arb_arid;

parameter	RID_PTR_WIDTH = 4;
parameter	RID_DEPTH = 15;
parameter	RID_DATA_WIDTH = SLV_AXI_ID_WIDTH ;


wire [RID_PTR_WIDTH-1:0] rid_ram_write_addr;
wire [RID_PTR_WIDTH-1:0] rid_ram_read_addr; 


gen_fifo_async_ctl # ( RID_PTR_WIDTH ) u_slv_rid_ff (
   // Outputs
   .wdepth               ( ), 
   .rdepth               ( ), 
   .ram_write_strobe     ( rid_ram_write_strobe ), 
   .ram_write_addr       ( rid_ram_write_addr ), 
   .ram_read_strobe      ( rid_ram_read_strobe ), 
   .ram_read_addr        ( rid_ram_read_addr ), 
   .full                 ( rid_ff_full ), 
   .empty                ( rid_ff_empty ), 
   .dout_v               ( rid_rdata_valid ), 
   // Inputs
   .wusable              ( 1'b1), 
   .wreset               ( ~mem_rst_n ), 
   .wclk                 ( mem_clk ), 
   .rusable              ( 1'b1), 
   .rreset               ( ~axi_rst_n ), 
   .rclk                 ( axi_clk ), 
   .push                 ( rid_ff_wren ), 
   .pop                  ( rid_ff_rden )
);

`ifdef FPGA_OR_SIMULATION
mem_1w1r_fpga_or_sim # ( RID_PTR_WIDTH, RID_DATA_WIDTH , RID_DEPTH  ) u_slv_rid_ff_mem (
    .wclk                ( mem_clk ),
    .waddr               ( rid_ram_write_addr ),
    .wen                 ( rid_ram_write_strobe ),
    .wdata               ( rid_ff_wdata ),

    .rclk                ( axi_clk ),
    .raddr               ( rid_ram_read_addr ),
    .ren                 ( rid_ram_read_strobe),
    .rdata               ( rid_ff_rdata )
);

`endif

`ifdef ASIC_SYNTH

mem_1w1r_asic4 # ( RID_PTR_WIDTH, RID_DATA_WIDTH , RID_DEPTH  ) u_slv_rid_ff_mem (
    .wclk                ( mem_clk ),
    .wrst_n                ( mem_rst_n),
    .waddr               ( rid_ram_write_addr ),
    .wen                 ( rid_ram_write_strobe ),
    .wdata               ( rid_ff_wdata ),

    .rclk                ( axi_clk ),
    .rrst_n                ( axi_rst_n ),
    .raddr               ( rid_ram_read_addr ),
    .ren                 ( rid_ram_read_strobe),
    .rdata               ( rid_ff_rdata )
);

`endif



//===================================================================================
//RDATA FIFO Write inteface
//===================================================================================

assign slv_mem_rdata_ack      =  ~rdata_ff_full;
assign rdata_ff_wren          =  mem_slv_rdata_valid & ~rdata_ff_full;
assign mem_slv_ff_rdata       =  mem_slv_rdata;
assign mem_slv_ff_rdata_valid =  mem_slv_rdata_valid;
assign mem_slv_ff_rdata_last  =  mem_slv_rdata_last;
assign mem_slv_ff_rdata_resp  =  mem_slv_rdata_resp;


//===================================================================================
//RDATA FIFO
//===================================================================================



assign rdata_ff_wdata = {mem_slv_ff_rdata_resp,mem_slv_ff_rdata_last,mem_slv_ff_rdata,mem_slv_ff_rdata_valid};

parameter	PTR_WIDTH = 8;
parameter	DEPTH = 255;
parameter	DATA_WIDTH = SLV_AXI_DATA_WIDTH + 4;


wire [PTR_WIDTH-1:0] ram_write_addr;
wire [PTR_WIDTH-1:0] ram_read_addr; 

gen_fifo_async_ctl # ( PTR_WIDTH ) u_slv_rdata_ff (
   // Outputs
   .wdepth               ( ), 
   .rdepth               ( ), 
   .ram_write_strobe     ( ram_write_strobe ), 
   .ram_write_addr       ( ram_write_addr ), 
   .ram_read_strobe      ( ram_read_strobe ), 
   .ram_read_addr        ( ram_read_addr ), 
   .full                 ( rdata_ff_full ), 
   .empty                ( rdata_ff_empty ), 
   .dout_v               ( rdata_valid ), 
   // Inputs
   .wusable              ( 1'b1), 
   .wreset               ( ~mem_rst_n ), 
   .wclk                 ( mem_clk ), 
   .rusable              ( 1'b1), 
   .rreset               ( ~axi_rst_n ), 
   .rclk                 ( axi_clk ), 
   .push                 ( rdata_ff_wren ), 
   .pop                  ( rdata_ff_rden )
);

`ifdef FPGA_OR_SIMULATION

mem_1w1r_fpga_or_sim # ( PTR_WIDTH, DATA_WIDTH , DEPTH  ) u_slv_rdata_ff_mem (
    .wclk                ( mem_clk ),
    .waddr               ( ram_write_addr ),
    .wen                 ( ram_write_strobe ),
    .wdata               ( rdata_ff_wdata ),

    .rclk                ( axi_clk ),
    .raddr               ( ram_read_addr ),
    .ren                 ( ram_read_strobe),
    .rdata               ( rdata_ff_rdata )
);

`endif

`ifdef ASIC_SYNTH

mem_1w1r_asic5 # ( PTR_WIDTH, DATA_WIDTH , DEPTH  ) u_slv_rdata_ff_mem (
    .wclk                ( mem_clk ),
    .wrst_n                ( mem_rst_n ),
    .waddr               ( ram_write_addr ),
    .wen                 ( ram_write_strobe ),
    .wdata               ( rdata_ff_wdata ),

    .rclk                ( axi_clk ),
    .rrst_n                ( axi_rst_n ),
    .raddr               ( ram_read_addr ),
    .ren                 ( ram_read_strobe),
    .rdata               ( rdata_ff_rdata )
);

`endif






//===================================================================================
// AXI READ DATA INTERFACE 
//===================================================================================

reg  [1:0] slv_rd_cur_state;
reg  [1:0] slv_rd_nxt_state;

parameter [1:0]  SLV_RD_IDLE   = 0;
parameter [1:0]  SLV_RD_FF_RD  = 1;
parameter [1:0]  SLV_RD_DATA   = 2;

//===================================================================================


always @ (*)
begin
   case (slv_rd_cur_state )
      SLV_RD_IDLE :
      begin
         if ( ~rdata_ff_empty & rid_rd_start_lat )
            slv_rd_nxt_state = SLV_RD_FF_RD;
         else 
            slv_rd_nxt_state = SLV_RD_IDLE;
      end
      SLV_RD_FF_RD  :
      begin
        if ( (S_RREADY & rdata_ff_empty ) | ( S_RREADY & rdata_last )  )
            slv_rd_nxt_state = SLV_RD_IDLE;
        else if ( S_RREADY & ~rdata_ff_empty )
            slv_rd_nxt_state = SLV_RD_DATA;
        else
            slv_rd_nxt_state = SLV_RD_FF_RD;
      end
      SLV_RD_DATA :
      begin
        if ( (S_RREADY & rdata_ff_empty ) | ( S_RREADY & rdata_last ) )
            slv_rd_nxt_state = SLV_RD_IDLE;
        else if ( S_RREADY & ~rdata_ff_empty )
            slv_rd_nxt_state = SLV_RD_FF_RD;
        else
            slv_rd_nxt_state = SLV_RD_DATA;
      end
      default :
      begin
         slv_rd_nxt_state = SLV_RD_IDLE;
      end
   endcase
end

assign rdata_ff_rden =  ((slv_rd_cur_state == SLV_RD_IDLE) & ( slv_rd_nxt_state == SLV_RD_FF_RD)) |
                        ((slv_rd_cur_state == SLV_RD_FF_RD)& ( slv_rd_nxt_state == SLV_RD_DATA)) |
                        ((slv_rd_cur_state == SLV_RD_DATA) & ( slv_rd_nxt_state == SLV_RD_FF_RD ));


always @ ( posedge axi_clk or negedge axi_rst_n )
begin
   if ( ~axi_rst_n )
   begin
      slv_rd_cur_state   <= SLV_RD_IDLE; 
      rdata_ff_rdata_reg <= 'd0;
   end
   else
   begin
      slv_rd_cur_state <= slv_rd_nxt_state; 
      if ( rdata_valid )
         rdata_ff_rdata_reg <= rdata_ff_rdata;
      else if ( slv_rd_cur_state == SLV_RD_IDLE )
         rdata_ff_rdata_reg <= 'd0; 
   end
end


always @ ( * )
begin
    if (( slv_rd_cur_state == SLV_RD_FF_RD ) || ( slv_rd_cur_state == SLV_RD_DATA ) )
    begin
       S_RVALID     =  (rdata_valid) ? rdata_ff_rdata[0] : rdata_ff_rdata_reg[0] ;
       S_RDATA      =  (rdata_valid) ? rdata_ff_rdata[SLV_AXI_DATA_WIDTH:1] :
                                       rdata_ff_rdata_reg[SLV_AXI_DATA_WIDTH:1] ;
       S_RLAST      =  (rdata_valid) ? rdata_ff_rdata[SLV_AXI_DATA_WIDTH+1] :
                                       rdata_ff_rdata_reg[SLV_AXI_DATA_WIDTH+1];
       S_RRESP      =  (rdata_valid) ? rdata_ff_rdata[SLV_AXI_DATA_WIDTH+3 :SLV_AXI_DATA_WIDTH+2] :
                                       rdata_ff_rdata_reg[SLV_AXI_DATA_WIDTH+3 : SLV_AXI_DATA_WIDTH+2 ];
    end
    else
    begin
       S_RVALID     =  'd0;
       S_RDATA      =  'd0;
       S_RLAST      =  'd0;
       S_RRESP      =  'd0;
    end
end

assign rdata_last = (rdata_valid) ? rdata_ff_rdata[SLV_AXI_DATA_WIDTH+1] : rdata_ff_rdata_reg[SLV_AXI_DATA_WIDTH+1]; 




//===================================================================================
// AXI RID State machine   
//===================================================================================

reg  [1:0] slv_rid_cur_state;
reg  [1:0] slv_rid_nxt_state;

parameter [1:0]  SLV_RID_IDLE   = 0;
parameter [1:0]  SLV_RID_FF_RD  = 1;
parameter [1:0]  SLV_RID_DATA   = 2;

//===================================================================================


always @ (*)
begin
   case (slv_rid_cur_state )
      SLV_RID_IDLE :
      begin
         if ( ~rid_ff_empty )
            slv_rid_nxt_state = SLV_RID_FF_RD;
         else 
            slv_rid_nxt_state = SLV_RID_IDLE;
      end
      SLV_RID_FF_RD  :
      begin
         slv_rid_nxt_state = SLV_RID_DATA;
      end
      SLV_RID_DATA :
      begin
         if ( rdata_last & S_RREADY )
            slv_rid_nxt_state = SLV_RID_IDLE ;
         else 
            slv_rid_nxt_state = SLV_RID_DATA ;
      end
      default :
      begin
         slv_rid_nxt_state = SLV_RID_IDLE;
      end
   endcase
end

assign rid_ff_rden = ( slv_rid_cur_state == SLV_RID_IDLE) & ~rid_ff_empty ; 

always @ ( posedge axi_clk or negedge axi_rst_n )
begin
   if ( ~axi_rst_n )
   begin
      slv_rid_cur_state <= SLV_RID_IDLE; 
      rid_reg  <= 'd0;
      rid_rd_start_lat <= 1'b0;
   end
   else
   begin
      slv_rid_cur_state <= slv_rid_nxt_state; 
      if ( rid_rdata_valid ) 
         rid_reg <= rid_ff_rdata;

      if ( rid_ff_rden )
         rid_rd_start_lat <= 1'b1;
      else if ( rdata_last )
         rid_rd_start_lat <= 1'b0; 
   end
end


assign S_RID = ( rid_rdata_valid ) ? rid_ff_rdata : rid_reg;

endmodule // slv_rdata_ff 
