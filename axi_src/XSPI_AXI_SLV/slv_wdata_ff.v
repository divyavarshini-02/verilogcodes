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
// AXI write data FIFO 
//====================================================================================

`include "xspi_axi_slv.vh"
module slv_wdata_ff  (

     axi_clk, 
     axi_rst_n,
     si_wvalid,
     si_wdata,
     si_wstrb,
     si_wlast,
     si_wready,
     
     mem_clk, 
     mem_rst_n,

     hyperflash_en,
     slv_arb_wr_start_en,
     slv_arb_addr,
     slv_wdata_ready,
     slv_awsize, 
     slv_awburst, 
//     slv_awlen, 
    
     slv_wdata, 
     slv_wvalid, 
     slv_wstrb, 
     slv_wlast,
     slv_aw_burst_complete     

);

parameter SLV_AXI_ADDR_WIDTH = 32;
parameter SLV_AXI_DATA_WIDTH = 32;
parameter SLV_MEM_DATA_WIDTH = 32;



//*********************************INPUTS & OUTPUTS************************************

input                                  axi_clk;
input                                  axi_rst_n;
input [SLV_AXI_DATA_WIDTH-1:0 ]        si_wdata;
input                                  si_wvalid;
input [(SLV_AXI_DATA_WIDTH/8) -1:0 ]   si_wstrb;
input                                  si_wlast;
output                                 si_wready;

 
input                                  mem_clk;
input                                  mem_rst_n;
input                                  slv_arb_wr_start_en;
input                                  hyperflash_en;
input [SLV_AXI_ADDR_WIDTH-1:0 ]        slv_arb_addr;
input  [2:0]                           slv_awsize;
input  [1:0]                           slv_awburst;
input                                  slv_wdata_ready;

output [31:0]        slv_wdata;
output                                 slv_wvalid;
output [3:0]    slv_wstrb;
output                                 slv_wlast;
output                                 slv_aw_burst_complete;

//===================================================================================

reg   [31:0]        			slv_wdata;
reg                                   slv_wvalid;
reg   [3:0]    				slv_wstrb;
reg                                   slv_wlast;

reg                                    slv_arb_wr_start_en_reg;
reg   [2:0]                            slv_awsize_reg;
reg   [3:0]                            slv_arb_addr_reg;

reg   [SLV_AXI_DATA_WIDTH+(SLV_AXI_DATA_WIDTH/8)+1:0]  wdata_ff_rdata_reg;

wire                                   slv_arb_wr_start_en_sig;
wire   [2:0]                           slv_awsize_sig;
wire   [3:0]                           slv_arb_addr_sig;
//===================================================================================




//********************************CODE STARTHERE*************************************




//===================================================================================

wire [SLV_AXI_DATA_WIDTH+(SLV_AXI_DATA_WIDTH/8)+1:0]  wdata_ff_wdata;
wire [SLV_AXI_DATA_WIDTH+(SLV_AXI_DATA_WIDTH/8)+1:0]  wdata_ff_rdata;
wire wdata_ff_full;
wire wdata_ff_empty;
wire rdata_valid;
wire wdata_ff_wr_en;
wire wdata_ff_rd_en;

assign wdata_ff_wdata = {si_wlast,si_wvalid,si_wstrb,si_wdata};

parameter	PTR_WIDTH = 8;
parameter	DEPTH = 255;
parameter	DATA_WIDTH = SLV_AXI_DATA_WIDTH+(SLV_AXI_DATA_WIDTH/8)+2 ;


wire [PTR_WIDTH-1:0] ram_write_addr;
wire [PTR_WIDTH-1:0] ram_read_addr; 


gen_fifo_async_ctl # ( PTR_WIDTH ) u_slv_wdata_ff (
   // Outputs
   .wdepth               ( ), 
   .rdepth               ( ), 
   .ram_write_strobe     ( ram_write_strobe ), 
   .ram_write_addr       ( ram_write_addr ), 
   .ram_read_strobe      ( ram_read_strobe ), 
   .ram_read_addr        ( ram_read_addr ), 
   .full                 ( wdata_ff_full ), 
   .empty                ( wdata_ff_empty ), 
   .dout_v               ( rdata_valid ), 
   // Inputs
   .wusable              ( 1'b1), 
   .wreset               ( ~axi_rst_n ), 
   .wclk                 ( axi_clk ), 
   .rusable              ( 1'b1), 
   .rreset               ( ~mem_rst_n ), 
   .rclk                 ( mem_clk ), 
   .push                 ( wdata_ff_wr_en ), 
   .pop                  ( wdata_ff_rd_en )
);

`ifdef FPGA_OR_SIMULATION

mem_1w1r_fpga_or_sim # ( PTR_WIDTH, DATA_WIDTH , DEPTH  ) u_slv_wdata_ff_mem (
    .wclk                ( axi_clk ),
    .waddr               ( ram_write_addr ),
    .wen                 ( ram_write_strobe ),
    .wdata               ( wdata_ff_wdata ),

    .rclk                ( mem_clk ),
    .raddr               ( ram_read_addr ),
    .ren                 ( ram_read_strobe),
    .rdata               ( wdata_ff_rdata )
);

`endif

`ifdef ASIC_SYNTH

mem_1w1r_asic3 # ( PTR_WIDTH, DATA_WIDTH , DEPTH  ) u_slv_wdata_ff_mem (
    .wclk                ( axi_clk ),
    .wrst_n                ( axi_rst_n ),
    .waddr               ( ram_write_addr ),
    .wen                 ( ram_write_strobe ),
    .wdata               ( wdata_ff_wdata ),

    .rclk                ( mem_clk ),
    .rrst_n                ( mem_rst_n ),
    .raddr               ( ram_read_addr ),
    .ren                 ( ram_read_strobe),
    .rdata               ( wdata_ff_rdata )
);

`endif

assign si_wready      =  ~wdata_ff_full;
assign wdata_ff_wr_en =  si_wvalid & ~wdata_ff_full;

wire [SLV_AXI_DATA_WIDTH-1:0] wdata    = ( rdata_valid ) ? wdata_ff_rdata[SLV_AXI_DATA_WIDTH-1:0] : 
                                                           wdata_ff_rdata_reg[SLV_AXI_DATA_WIDTH-1:0];
wire [(SLV_AXI_DATA_WIDTH/8)-1:0] wstrb= ( rdata_valid ) ? wdata_ff_rdata[SLV_AXI_DATA_WIDTH+(SLV_AXI_DATA_WIDTH/8)-1: SLV_AXI_DATA_WIDTH] : 
                                                           wdata_ff_rdata_reg[SLV_AXI_DATA_WIDTH+(SLV_AXI_DATA_WIDTH/8)-1: SLV_AXI_DATA_WIDTH] ;
wire wvalid                            = ( rdata_valid ) ? wdata_ff_rdata[SLV_AXI_DATA_WIDTH+(SLV_AXI_DATA_WIDTH/8)] : 
                                                           wdata_ff_rdata_reg[SLV_AXI_DATA_WIDTH+(SLV_AXI_DATA_WIDTH/8)] ;
wire wlast                             = ( rdata_valid ) ? wdata_ff_rdata[SLV_AXI_DATA_WIDTH+(SLV_AXI_DATA_WIDTH/8)+1] : 
                                                           wdata_ff_rdata_reg[SLV_AXI_DATA_WIDTH+(SLV_AXI_DATA_WIDTH/8)+1];
 
always @ ( posedge mem_clk or negedge mem_rst_n )
begin
   if ( ~mem_rst_n )
   begin
      wdata_ff_rdata_reg    <= 'd0;
   end
   else
   begin
      wdata_ff_rdata_reg    <= wdata_ff_rdata;
   end
end

assign slv_aw_burst_complete = slv_wlast & slv_wdata_ready;

reg [1:0] slv_awburst_reg;

always @ ( posedge mem_clk or negedge mem_rst_n )
begin
   if ( ~mem_rst_n )
   begin
      slv_arb_wr_start_en_reg  <= 1'b0; 
      slv_awsize_reg           <= 'd0;
      slv_arb_addr_reg         <= 'd0;
      slv_awburst_reg  <= 2'd0;
   end
   else
   begin
      if ( slv_arb_wr_start_en )
      begin
         slv_arb_wr_start_en_reg  <= 1'b1 ;
         slv_awsize_reg   <= slv_awsize;
         slv_arb_addr_reg <= slv_arb_addr[3:0];
         slv_awburst_reg  <= slv_awburst;
      end
      else if ( slv_wlast )
         slv_arb_wr_start_en_reg  <= 1'b0 ; 
   end
end

wire [1:0] slv_awburst_sig;
assign slv_awsize_sig          = ( slv_arb_wr_start_en ) ? slv_awsize        : slv_awsize_reg;
assign slv_arb_addr_sig        = ( slv_arb_wr_start_en ) ? slv_arb_addr[3:0] : slv_arb_addr_reg[3:0] ;
assign slv_arb_wr_start_en_sig = ( slv_arb_wr_start_en | slv_arb_wr_start_en_reg );
assign slv_awburst_sig         = ( slv_arb_wr_start_en ) ? slv_awburst        : slv_awburst_reg;

reg [31:0]wrap_data_reg, nxt_wrap_data_reg;
reg [3:0] wrap_strb_reg, nxt_wrap_strb_reg;
reg       wrap_1st_xfer, nxt_wrap_1st_xfer; 
wire wrap_odd_xfer;

assign wrap_odd_xfer = slv_awburst_sig==2'b10 && (|slv_arb_addr_sig[1:0]);

//===================================================================================
// AXI DATA WIDTH 32 bits
//===================================================================================

generate 

if ( SLV_AXI_DATA_WIDTH == 32 ) // SLV DATA WIDTH == 32
begin

reg    [ 7 : 0 ]                       byte_0_reg;
reg    [ 7 : 0 ]                       byte_1_reg;
reg    [ 7 : 0 ]                       byte_2_reg;

reg    [15 : 0 ]                       hword_0_reg;
reg                                    strb_0_reg;
reg                                    strb_1_reg;
reg                                    strb_2_reg;
reg    [ 1 : 0 ]                       strb_10_reg;

reg  [3:0] slv_wr_cur_state;
reg  [3:0] slv_wr_nxt_state;

localparam [3:0]  SLV_WR_IDLE        = 0;
localparam [3:0]  SLV_WR_BYTE_0      = 1;
localparam [3:0]  SLV_WR_BYTE_1      = 2;
localparam [3:0]  SLV_WR_BYTE_2      = 3;
localparam [3:0]  SLV_WR_BYTE_3      = 4;
localparam [3:0]  SLV_WR_HWORD_0     = 5;
localparam [3:0]  SLV_WR_HWORD_1     = 6;
localparam [3:0]  SLV_WR_WORD        = 7;
localparam [3:0]  SLV_WR_BYTE_1_WAIT = 8;
localparam [3:0]  SLV_WR_BYTE_2_WAIT = 9;
localparam [3:0]  SLV_WR_BYTE_3_WAIT = 10;
localparam [3:0]  SLV_WR_BYTE_0_WAIT = 11;
localparam [3:0]  SLV_WR_HWORD_1_WAIT= 12;
localparam [3:0]  SLV_WR_HWORD_0_WAIT= 13;
localparam [3:0]  SLV_WR_WORD_WAIT   = 14;

//===================================================================================

//===================================================================================

always @ (*)
begin
           nxt_wrap_1st_xfer = wrap_1st_xfer;
           nxt_wrap_data_reg  = wrap_data_reg;
           nxt_wrap_strb_reg  = wrap_strb_reg;

   case (slv_wr_cur_state )
      SLV_WR_IDLE :
      begin
         // BYTE ACCESS
         if ( slv_arb_wr_start_en_sig & ~wdata_ff_empty & (slv_awsize_sig == 3'd0) ) 
         begin
            nxt_wrap_1st_xfer = slv_awburst_sig==2'b10 && (|slv_arb_addr_sig[1:0]);
            if ( slv_arb_addr_sig[1:0] == 2'b00 ) 
               slv_wr_nxt_state = SLV_WR_BYTE_0;
            else if ( slv_arb_addr_sig[1:0] == 2'b01 )
               slv_wr_nxt_state = SLV_WR_BYTE_1;
            else if ( slv_arb_addr_sig[1:0] == 2'b10 )
               slv_wr_nxt_state = SLV_WR_BYTE_2;
            else 
               slv_wr_nxt_state = SLV_WR_BYTE_3;
         end
         // HALF WORD ACCESS
         else if ( slv_arb_wr_start_en_sig & ~wdata_ff_empty & (slv_awsize_sig == 3'd1) ) 
         begin
            nxt_wrap_1st_xfer = slv_awburst_sig==2'b10 && (|slv_arb_addr_sig[1:0]);
            if ( (slv_arb_addr_sig[1:0] == 2'b00) | (slv_arb_addr_sig[1:0] == 2'b01 ) )
               slv_wr_nxt_state = SLV_WR_HWORD_0;
            else 
               slv_wr_nxt_state = SLV_WR_HWORD_1;
         end 
         // WORD ACCESS
         else if ( slv_arb_wr_start_en_sig & ~wdata_ff_empty &  (slv_awsize_sig == 3'd2) ) 
            slv_wr_nxt_state = SLV_WR_WORD ;
         else
            slv_wr_nxt_state = SLV_WR_IDLE ;
      end
      // BYTE 0
      SLV_WR_BYTE_0 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_BYTE_0;
         else if ( ~wlast & wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_BYTE_1_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_BYTE_1;
      end
      // BYTE 1 
      SLV_WR_BYTE_1 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_BYTE_1;
         else if ( ~wlast & wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_BYTE_2_WAIT;
         else 
            slv_wr_nxt_state = SLV_WR_BYTE_2;
      end
      // BYTE 2
      SLV_WR_BYTE_2 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_BYTE_2;
         else if ( ~wlast & wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_BYTE_3_WAIT;
         else 
            slv_wr_nxt_state = SLV_WR_BYTE_3;
      end
      // BYTE 3
      SLV_WR_BYTE_3 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( (slv_wdata_ready | wrap_1st_xfer) & ~wdata_ff_empty)
         begin
            nxt_wrap_1st_xfer = 1'b0;
            slv_wr_nxt_state = SLV_WR_BYTE_0;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[31:24],byte_2_reg,byte_1_reg,byte_0_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[3],strb_2_reg,strb_1_reg,strb_0_reg }   : wrap_strb_reg;
         end
         else if ( (slv_wdata_ready | wrap_1st_xfer) & wdata_ff_empty)
         begin
            nxt_wrap_1st_xfer = 1'b0;
            slv_wr_nxt_state = SLV_WR_BYTE_0_WAIT;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[31:24],byte_2_reg,byte_1_reg,byte_0_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[3],strb_2_reg,strb_1_reg,strb_0_reg }   : wrap_strb_reg;
         end
         else    
            slv_wr_nxt_state = SLV_WR_BYTE_3;
      end
      // HALF WORD 0
      SLV_WR_HWORD_0 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_HWORD_0;
         else if ( ~wlast & wdata_ff_empty  ) 
            slv_wr_nxt_state = SLV_WR_HWORD_1_WAIT;
         else 
            slv_wr_nxt_state = SLV_WR_HWORD_1;
      end
      // HALF WORD 1 
      SLV_WR_HWORD_1 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( (slv_wdata_ready|wrap_1st_xfer) & ~wdata_ff_empty)
         begin
            slv_wr_nxt_state = SLV_WR_HWORD_0;
            nxt_wrap_1st_xfer = 1'b0;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[31:16],hword_0_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[3:2],strb_10_reg } : wrap_strb_reg;
         end
         else if ( (slv_wdata_ready|wrap_1st_xfer) & wdata_ff_empty)
         begin
            slv_wr_nxt_state = SLV_WR_HWORD_0_WAIT;
            nxt_wrap_1st_xfer = 1'b0;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[31:16],hword_0_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[3:2],strb_10_reg } : wrap_strb_reg;
         end
         else    
            slv_wr_nxt_state = SLV_WR_HWORD_1;
      end
      // WORD 
      SLV_WR_WORD  :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( ~wlast & wdata_ff_empty & slv_wdata_ready )
            slv_wr_nxt_state = SLV_WR_WORD_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_WORD;
      end

      // BYTE 1 WAIT
      SLV_WR_BYTE_1_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_BYTE_1_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_BYTE_1;
      end
      // BYTE 2 WAIT
      SLV_WR_BYTE_2_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_BYTE_2_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_BYTE_2;
      end
      // BYTE 3 WAIT
      SLV_WR_BYTE_3_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_BYTE_3_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_BYTE_3;
      end
      // BYTE 0 WAIT
      SLV_WR_BYTE_0_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_BYTE_0_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_BYTE_0;
      end
      // HALF WORD 1 WAIT 
      SLV_WR_HWORD_1_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_HWORD_1_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_HWORD_1;
      end
      // HALF WORD 0 WAIT 
      SLV_WR_HWORD_0_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_HWORD_0_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_HWORD_0;
      end
      // WORD WAIT 
      SLV_WR_WORD_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_WORD_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_WORD;
      end
      default :
      begin
         slv_wr_nxt_state = SLV_WR_IDLE ;
      end
   endcase
end


always @ ( posedge mem_clk or negedge mem_rst_n )
begin
   if ( ~mem_rst_n )
   begin
      slv_wr_cur_state <= SLV_WR_IDLE; 
      byte_0_reg       <= 'd0;
      byte_1_reg       <= 'd0;
      byte_2_reg       <= 'd0;
      hword_0_reg      <= 'd0;
      strb_0_reg       <= 'd0;
      strb_1_reg       <= 'd0;
      strb_2_reg       <= 'd0;
      strb_10_reg      <= 'd0;
      wrap_data_reg <= 'd0; 
      wrap_strb_reg <= 'd0;
      wrap_1st_xfer <=  1'b0;
   end
   else
   begin
      slv_wr_cur_state <= slv_wr_nxt_state; 
      wrap_data_reg <= nxt_wrap_data_reg;
      wrap_strb_reg <= nxt_wrap_strb_reg;
      wrap_1st_xfer <= nxt_wrap_1st_xfer; 
      if ( (slv_wr_cur_state == SLV_WR_BYTE_0 ) & rdata_valid )
      begin
         byte_0_reg  <= wdata[7:0]; 
         strb_0_reg  <= wstrb[0]; 
      end
      else if ( slv_wr_cur_state == SLV_WR_IDLE )
      begin
         byte_0_reg  <= 'd0; 
         strb_0_reg  <= 'd0; 
      end 

      if ( (slv_wr_cur_state == SLV_WR_BYTE_1 ) & rdata_valid )
      begin
         byte_1_reg  <= wdata[15:8]; 
         strb_1_reg  <= wstrb[1]; 
      end
      else if ( slv_wr_cur_state == SLV_WR_IDLE )
      begin
         byte_1_reg  <= 'd0; 
         strb_1_reg  <= 'd0; 
      end 

      if ( (slv_wr_cur_state == SLV_WR_BYTE_2 ) & rdata_valid )
      begin
         byte_2_reg  <= wdata[23:16]; 
         strb_2_reg  <= wstrb[2]; 
      end
      else if ( slv_wr_cur_state == SLV_WR_IDLE )
      begin
         byte_2_reg  <= 'd0; 
         strb_2_reg  <= 'd0; 
      end 

      if ( (slv_wr_cur_state == SLV_WR_HWORD_0 ) & rdata_valid )
      begin
         hword_0_reg <= wdata[15:0]; 
         strb_10_reg <= wstrb[1:0]; 
      end
      else if ( slv_wr_cur_state == SLV_WR_IDLE )
      begin
         hword_0_reg  <= 'd0; 
         strb_10_reg  <= 'd0; 
      end 
   end
end


assign wdata_ff_rd_en = ( ~wdata_ff_empty & ( (( slv_wr_cur_state == SLV_WR_IDLE  ) & slv_arb_wr_start_en_sig ) | 
                                              (( slv_wr_cur_state == SLV_WR_BYTE_0) & ~wlast) | 
                                              (( slv_wr_cur_state == SLV_WR_BYTE_1) & ~wlast) |
                                              (( slv_wr_cur_state == SLV_WR_BYTE_2) & ~wlast) |
                                              (( slv_wr_cur_state == SLV_WR_BYTE_3) & ~wlast & (slv_wdata_ready | wrap_1st_xfer) ) |
                                              (( slv_wr_cur_state == SLV_WR_HWORD_0)& ~wlast) | 
                                              (( slv_wr_cur_state == SLV_WR_HWORD_1)& ~wlast & (slv_wdata_ready | wrap_1st_xfer)) |
                                              (( slv_wr_cur_state == SLV_WR_WORD) & ~wlast & (slv_wdata_ready | wrap_1st_xfer))  | 
                                               ( slv_wr_cur_state == SLV_WR_BYTE_1_WAIT )  | 
                                               ( slv_wr_cur_state == SLV_WR_BYTE_2_WAIT )  | 
                                               ( slv_wr_cur_state == SLV_WR_BYTE_3_WAIT )  | 
                                               ( slv_wr_cur_state == SLV_WR_BYTE_0_WAIT )  | 
                                               ( slv_wr_cur_state == SLV_WR_HWORD_1_WAIT )  | 
                                               ( slv_wr_cur_state == SLV_WR_HWORD_0_WAIT )  | 
                                               ( slv_wr_cur_state == SLV_WR_WORD_WAIT )   
                                              )); 

always @ ( posedge mem_clk or negedge mem_rst_n )
begin
   if ( ~mem_rst_n )
   begin
   slv_wdata <= 32'd0;
   slv_wstrb <= 4'd0;
   slv_wvalid <= 1'b0;
   slv_wlast <= 1'b0;
   end
   else
   begin
 
   slv_wdata  <= (( slv_wr_cur_state == SLV_WR_BYTE_3 ) & wvalid) ? { wdata[31:24],byte_2_reg,byte_1_reg,byte_0_reg } :
                    (( slv_wr_cur_state == SLV_WR_HWORD_1) & wvalid) ? { wdata[31:16],hword_0_reg } :
                    (( slv_wr_cur_state == SLV_WR_WORD   ) & wvalid) ? { wdata[31:0]} :
                    (( slv_wr_cur_state == SLV_WR_BYTE_0 ) & wlast ) ? { wrap_data_reg[31:8],wdata[7:0]} :
                    (( slv_wr_cur_state == SLV_WR_BYTE_1 ) & wlast ) ? { wrap_data_reg[31:16],wdata[15:8],byte_0_reg} :
                    (( slv_wr_cur_state == SLV_WR_BYTE_2 ) & wlast ) ? { wrap_data_reg[31:24],wdata[23:16],byte_1_reg,byte_0_reg} :
                    (( slv_wr_cur_state == SLV_WR_HWORD_0) & wlast ) ? { wrap_data_reg[31:16],wdata[15:0]} : 'd0;

   slv_wstrb  <= (( slv_wr_cur_state == SLV_WR_BYTE_3 ) & wvalid) ? { wstrb[3],strb_2_reg,strb_1_reg,strb_0_reg } :
                    (( slv_wr_cur_state == SLV_WR_HWORD_1) & wvalid) ? { wstrb[3:2],strb_10_reg } :
                    (( slv_wr_cur_state == SLV_WR_WORD   ) & wvalid) ? { wstrb[3:0]} :
                    (( slv_wr_cur_state == SLV_WR_BYTE_0 ) & wlast ) ? (wrap_odd_xfer ? { wrap_strb_reg[3:1],wstrb[0]} : wstrb) :
                    (( slv_wr_cur_state == SLV_WR_BYTE_1 ) & wlast ) ? (wrap_odd_xfer ? { wrap_strb_reg[3:2], wstrb[1],strb_0_reg} : 
                                                                       { wstrb[3:1],strb_0_reg}):
                    (( slv_wr_cur_state == SLV_WR_BYTE_2 ) & wlast ) ? (wrap_odd_xfer ? { wrap_strb_reg[3],wstrb[2],strb_1_reg,strb_0_reg} :                                                                       { wstrb[3:2],strb_1_reg,strb_0_reg}):
                    (( slv_wr_cur_state == SLV_WR_HWORD_0) & wlast ) ? (wrap_odd_xfer ? { wrap_strb_reg[3:2], wstrb[1:0]} : 
                                                                       { wstrb[3:0]}) : 'd0;

   slv_wvalid <= ((( slv_wr_cur_state == SLV_WR_BYTE_3 ) & wvalid) | 
                    (( slv_wr_cur_state == SLV_WR_HWORD_1) & wvalid) | 
                    (( slv_wr_cur_state == SLV_WR_WORD   ) & wvalid) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_0 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_1 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_2 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_HWORD_0) & wlast )) & (!wrap_1st_xfer) & (!slv_wdata_ready);

   slv_wlast  <= (( slv_wr_cur_state == SLV_WR_BYTE_0 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_1 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_2 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_3 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_HWORD_0) & wlast ) |
                    (( slv_wr_cur_state == SLV_WR_HWORD_1) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_WORD   ) & wlast ) ; 
   end
end

end 

//===================================================================================
// AXI DATA WIDTH 64 bits
//===================================================================================

else if ( SLV_AXI_DATA_WIDTH == 64 ) // SLV_AXI_DATA_WIDTH == 64 BEGIN 
begin

reg    [ 7 : 0 ]                       byte_0_reg;
reg    [ 7 : 0 ]                       byte_1_reg;
reg    [ 7 : 0 ]                       byte_2_reg;
reg    [ 7 : 0 ]                       byte_3_reg;
reg    [ 7 : 0 ]                       byte_4_reg;
reg    [ 7 : 0 ]                       byte_5_reg;
reg    [ 7 : 0 ]                       byte_6_reg;

reg                                    strb_0_reg;
reg                                    strb_1_reg;
reg                                    strb_2_reg;
reg                                    strb_3_reg;
reg                                    strb_4_reg;
reg                                    strb_5_reg;
reg                                    strb_6_reg;

reg    [15 : 0 ]                       hword_0_reg;
reg    [15 : 0 ]                       hword_1_reg;
reg    [15 : 0 ]                       hword_2_reg;

reg    [ 1 : 0 ]                       strb_10_reg;
reg    [ 1 : 0 ]                       strb_32_reg;
reg    [ 1 : 0 ]                       strb_54_reg;

reg    [ 3 : 0 ]                       strb_30_reg;
reg    [31 : 0 ]                       word_0_reg;

reg  [4:0] slv_wr_cur_state;
reg  [4:0] slv_wr_nxt_state;

localparam [4:0]  SLV_WR_IDLE        = 5'h00;
localparam [4:0]  SLV_WR_BYTE_0      = 5'h01;
localparam [4:0]  SLV_WR_BYTE_1      = 5'h02;
localparam [4:0]  SLV_WR_BYTE_2      = 5'h03;
localparam [4:0]  SLV_WR_BYTE_3      = 5'h04;
localparam [4:0]  SLV_WR_BYTE_4      = 5'h05;
localparam [4:0]  SLV_WR_BYTE_5      = 5'h06;
localparam [4:0]  SLV_WR_BYTE_6      = 5'h07;
localparam [4:0]  SLV_WR_BYTE_7      = 5'h08;
localparam [4:0]  SLV_WR_HWORD_0     = 5'h09;
localparam [4:0]  SLV_WR_HWORD_1     = 5'h0A;
localparam [4:0]  SLV_WR_HWORD_2     = 5'h0B;
localparam [4:0]  SLV_WR_HWORD_3     = 5'h0C;
localparam [4:0]  SLV_WR_WORD_0      = 5'h0D;
localparam [4:0]  SLV_WR_WORD_1      = 5'h0E;
localparam [4:0]  SLV_WR_DWORD_W0    = 5'h0F;
localparam [4:0]  SLV_WR_DWORD_W1    = 5'h10;
localparam [4:0]  SLV_WR_BYTE_1_WAIT = 5'h11;
localparam [4:0]  SLV_WR_BYTE_2_WAIT = 5'h12;
localparam [4:0]  SLV_WR_BYTE_3_WAIT = 5'h13;
localparam [4:0]  SLV_WR_BYTE_4_WAIT = 5'h14;
localparam [4:0]  SLV_WR_BYTE_5_WAIT = 5'h15;
localparam [4:0]  SLV_WR_BYTE_6_WAIT = 5'h16;
localparam [4:0]  SLV_WR_BYTE_7_WAIT = 5'h17;
localparam [4:0]  SLV_WR_BYTE_0_WAIT = 5'h18;
localparam [4:0]  SLV_WR_HWORD_1_WAIT= 5'h19;
localparam [4:0]  SLV_WR_HWORD_2_WAIT= 5'h1A;
localparam [4:0]  SLV_WR_HWORD_3_WAIT= 5'h1B;
localparam [4:0]  SLV_WR_HWORD_0_WAIT= 5'h1C;
localparam [4:0]  SLV_WR_WORD_1_WAIT = 5'h1D;
localparam [4:0]  SLV_WR_WORD_0_WAIT = 5'h1E;
localparam [4:0]  SLV_WR_DWORD_WAIT  = 5'h1F;

//===================================================================================


always @ (*)
begin
           nxt_wrap_1st_xfer = wrap_1st_xfer;
           nxt_wrap_data_reg  = wrap_data_reg;
           nxt_wrap_strb_reg  = wrap_strb_reg;
   case (slv_wr_cur_state )
      SLV_WR_IDLE :
      begin
         if ( slv_arb_wr_start_en_sig  & ~wdata_ff_empty & (slv_awsize_sig == 3'd0) ) 
         begin
            nxt_wrap_1st_xfer = slv_awburst_sig==2'b10 && (|slv_arb_addr_sig[1:0]);
            if ( slv_arb_addr_sig[2:0] == 3'b000 ) 
               slv_wr_nxt_state = SLV_WR_BYTE_0;
            else if ( slv_arb_addr_sig[2:0] == 3'b001 )
               slv_wr_nxt_state = SLV_WR_BYTE_1;
            else if ( slv_arb_addr_sig[2:0] == 3'b010 )
               slv_wr_nxt_state = SLV_WR_BYTE_2;
            else if ( slv_arb_addr_sig[2:0] == 3'b011 )
               slv_wr_nxt_state = SLV_WR_BYTE_3;
            else if ( slv_arb_addr_sig[2:0] == 3'b100 )
               slv_wr_nxt_state = SLV_WR_BYTE_4;
            else if ( slv_arb_addr_sig[2:0] == 3'b101 )
               slv_wr_nxt_state = SLV_WR_BYTE_5;
            else if ( slv_arb_addr_sig[2:0] == 3'b110 )
               slv_wr_nxt_state = SLV_WR_BYTE_6;
            else 
               slv_wr_nxt_state = SLV_WR_BYTE_7;
         end
         else if ( slv_arb_wr_start_en_sig & ~wdata_ff_empty & (slv_awsize_sig == 3'd1) ) 
         begin
            nxt_wrap_1st_xfer = slv_awburst_sig==2'b10 && (|slv_arb_addr_sig[1:0]);
            if ( (slv_arb_addr_sig[2:0] == 3'b000) | (slv_arb_addr_sig[2:0] == 3'b001 ) )
               slv_wr_nxt_state = SLV_WR_HWORD_0;
            else if ( (slv_arb_addr_sig[2:0] == 3'b010) | (slv_arb_addr_sig[2:0] == 3'b011 ) )
               slv_wr_nxt_state = SLV_WR_HWORD_1;
            else if ( (slv_arb_addr_sig[2:0] == 3'b100) | (slv_arb_addr_sig[2:0] == 3'b101 ) )
               slv_wr_nxt_state = SLV_WR_HWORD_2;
            else 
               slv_wr_nxt_state = SLV_WR_HWORD_3;
         end
         else if ( slv_arb_wr_start_en_sig & ~wdata_ff_empty & (slv_awsize_sig == 3'd2) ) 
         begin
            if ( (slv_arb_addr_sig[2] == 1'b0) ) 
               slv_wr_nxt_state = SLV_WR_WORD_0 ;
            else
               slv_wr_nxt_state = SLV_WR_WORD_1 ;
         end
         else if ( slv_arb_wr_start_en_sig & ~wdata_ff_empty & (slv_awsize_sig == 3'd3) ) 
         begin
            if ( (slv_arb_addr_sig[2] == 1'b0) ) 
               slv_wr_nxt_state = SLV_WR_DWORD_W0 ;
            else
               slv_wr_nxt_state = SLV_WR_DWORD_W1 ;
         end
         else
            slv_wr_nxt_state = SLV_WR_IDLE ;
      end
      // BYTE 0
      SLV_WR_BYTE_0 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_BYTE_0;
         else if ( ~wlast & wdata_ff_empty  ) 
            slv_wr_nxt_state = SLV_WR_BYTE_1_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_BYTE_1;
      end
      // BYTE 1
      SLV_WR_BYTE_1 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_BYTE_1;
         else if ( ~wlast & wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_BYTE_2_WAIT;
         else 
            slv_wr_nxt_state = SLV_WR_BYTE_2;
      end
      // BYTE 2
      SLV_WR_BYTE_2 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_BYTE_2;
         else if ( ~wlast & wdata_ff_empty  ) 
            slv_wr_nxt_state = SLV_WR_BYTE_3_WAIT;
         else 
            slv_wr_nxt_state = SLV_WR_BYTE_3;
      end
      // BYTE 3
      SLV_WR_BYTE_3 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( (slv_wdata_ready | wrap_1st_xfer) & ~wdata_ff_empty)
         begin
            nxt_wrap_1st_xfer = 1'b0;
            slv_wr_nxt_state = SLV_WR_BYTE_4;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[31:24],byte_2_reg,byte_1_reg,byte_0_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[3],strb_2_reg,strb_1_reg,strb_0_reg }   : wrap_strb_reg;
         end
         else if ( (slv_wdata_ready | wrap_1st_xfer) & wdata_ff_empty)
         begin
            nxt_wrap_1st_xfer = 1'b0;
            slv_wr_nxt_state = SLV_WR_BYTE_4_WAIT;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[31:24],byte_2_reg,byte_1_reg,byte_0_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[3],strb_2_reg,strb_1_reg,strb_0_reg }   : wrap_strb_reg;
         end
         else    
            slv_wr_nxt_state = SLV_WR_BYTE_3;
      end
      // BYTE 4
      SLV_WR_BYTE_4 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_BYTE_4;
         else if ( ~wlast & wdata_ff_empty  )
            slv_wr_nxt_state = SLV_WR_BYTE_5_WAIT;
         else    
            slv_wr_nxt_state = SLV_WR_BYTE_5;
      end
      // BYTE 5
      SLV_WR_BYTE_5 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_BYTE_5;
         else if ( ~wlast & wdata_ff_empty  )
            slv_wr_nxt_state = SLV_WR_BYTE_6_WAIT;
         else    
            slv_wr_nxt_state = SLV_WR_BYTE_6;
      end
      // BYTE 6
      SLV_WR_BYTE_6 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_BYTE_6;
         else if ( ~wlast & wdata_ff_empty  )
            slv_wr_nxt_state = SLV_WR_BYTE_7_WAIT;
         else    
            slv_wr_nxt_state = SLV_WR_BYTE_7;
      end
      // BYTE 7
      SLV_WR_BYTE_7 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( (slv_wdata_ready | wrap_1st_xfer) & ~wdata_ff_empty)
         begin
            nxt_wrap_1st_xfer = 1'b0;
            slv_wr_nxt_state = SLV_WR_BYTE_0;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[63:56],byte_6_reg,byte_5_reg,byte_4_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[7],strb_6_reg,strb_5_reg,strb_4_reg }   : wrap_strb_reg;
         end
         else if ( (slv_wdata_ready | wrap_1st_xfer) & wdata_ff_empty)
         begin
            nxt_wrap_1st_xfer = 1'b0;
            slv_wr_nxt_state = SLV_WR_BYTE_0_WAIT;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[63:56],byte_6_reg,byte_5_reg,byte_4_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[7],strb_6_reg,strb_5_reg,strb_4_reg }   : wrap_strb_reg;
         end
         else    
            slv_wr_nxt_state = SLV_WR_BYTE_7;
      end
      // HALF WORD 0
      SLV_WR_HWORD_0 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_HWORD_0;
         else if ( ~wlast & wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_HWORD_1_WAIT;
         else 
            slv_wr_nxt_state = SLV_WR_HWORD_1;
      end
      // HALF WORD 1 
      SLV_WR_HWORD_1 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( (slv_wdata_ready | wrap_1st_xfer) & ~wdata_ff_empty)
         begin
            slv_wr_nxt_state = SLV_WR_HWORD_2;
            nxt_wrap_1st_xfer = 1'b0;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[31:16],hword_0_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[3:2],strb_10_reg } : wrap_strb_reg;
         end
         else if ( (slv_wdata_ready | wrap_1st_xfer) & wdata_ff_empty)
         begin
            slv_wr_nxt_state = SLV_WR_HWORD_2_WAIT;
            nxt_wrap_1st_xfer = 1'b0;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[31:16],hword_0_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[3:2],strb_10_reg } : wrap_strb_reg;
         end
         else 
            slv_wr_nxt_state = SLV_WR_HWORD_1;
      end
      // HALF WORD 2 
      SLV_WR_HWORD_2 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_HWORD_2;
         else if ( ~wlast & wdata_ff_empty  )
            slv_wr_nxt_state = SLV_WR_HWORD_3_WAIT;
         else    
            slv_wr_nxt_state = SLV_WR_HWORD_3;
      end
      // HALF WORD 3 
      SLV_WR_HWORD_3 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( (slv_wdata_ready | wrap_1st_xfer) & ~wdata_ff_empty)
         begin
            slv_wr_nxt_state = SLV_WR_HWORD_0;
            nxt_wrap_1st_xfer = 1'b0;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[63:48],hword_2_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[7:6],strb_54_reg } : wrap_strb_reg;
         end
         else if ( (slv_wdata_ready | wrap_1st_xfer) & wdata_ff_empty)
         begin
            slv_wr_nxt_state = SLV_WR_HWORD_0_WAIT;
            nxt_wrap_1st_xfer = 1'b0;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[63:48],hword_2_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[7:6],strb_54_reg } : wrap_strb_reg;
         end

         else    
            slv_wr_nxt_state = SLV_WR_HWORD_3;
      end
      // WORD 0 
      SLV_WR_WORD_0  :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( ~wlast & slv_wdata_ready & ~wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_WORD_1;
         else if ( ~wlast & wdata_ff_empty  & slv_wdata_ready )
            slv_wr_nxt_state = SLV_WR_WORD_1_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_WORD_0;
      end
      // WORD 1 
      SLV_WR_WORD_1  :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE ;
         else if ( slv_wdata_ready & ~wdata_ff_empty )
            slv_wr_nxt_state = SLV_WR_WORD_0;
         else if ( slv_wdata_ready & wdata_ff_empty )
            slv_wr_nxt_state = SLV_WR_WORD_0_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_WORD_1;
      end

      // DWORD  

      SLV_WR_DWORD_W0  :
      begin
//         if ( slv_wdata_ready ) 
//            slv_wr_nxt_state = SLV_WR_DWORD_W1;
//         else
//            slv_wr_nxt_state = SLV_WR_DWORD_W0;
         if ( wlast & slv_wdata_ready & (!(&wstrb[3:0])) ) 
            slv_wr_nxt_state = SLV_WR_IDLE;
         else if ( slv_wdata_ready)
            slv_wr_nxt_state = SLV_WR_DWORD_W1;
         else
            slv_wr_nxt_state = SLV_WR_DWORD_W0;
      end

      SLV_WR_DWORD_W1  :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_wr_nxt_state = SLV_WR_IDLE;
         else if ( slv_wdata_ready & ~wdata_ff_empty )
            slv_wr_nxt_state = SLV_WR_DWORD_W0;
         else if ( slv_wdata_ready & wdata_ff_empty )
            slv_wr_nxt_state = SLV_WR_DWORD_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_DWORD_W1;
      end

      // BYTE 1 WAIT

      SLV_WR_BYTE_1_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_BYTE_1_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_BYTE_1;
      end
      // BYTE 2 WAIT
      SLV_WR_BYTE_2_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_BYTE_2_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_BYTE_2;
      end
      // BYTE 3 WAIT
      SLV_WR_BYTE_3_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_BYTE_3_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_BYTE_3;
      end
      // BYTE 4 WAIT
      SLV_WR_BYTE_4_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_BYTE_4_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_BYTE_4;
      end
      // BYTE 5 WAIT
      SLV_WR_BYTE_5_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_BYTE_5_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_BYTE_5;
      end
      // BYTE 6 WAIT
      SLV_WR_BYTE_6_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_BYTE_6_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_BYTE_6;
      end
      // BYTE 7 WAIT
      SLV_WR_BYTE_7_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_BYTE_7_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_BYTE_7;
      end
      // BYTE 0 WAIT
      SLV_WR_BYTE_0_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_BYTE_0_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_BYTE_0;
      end
      // HALF WORD 1 WAIT
      SLV_WR_HWORD_1_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_HWORD_1_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_HWORD_1;
      end
      // HALF WORD 2 WAIT
      SLV_WR_HWORD_2_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_HWORD_2_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_HWORD_2;
      end
      // HALF WORD 3 WAIT
      SLV_WR_HWORD_3_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_HWORD_3_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_HWORD_3;
      end
      // HALF WORD 0 WAIT
      SLV_WR_HWORD_0_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_HWORD_0_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_HWORD_0;
      end
      // WORD 1 WAIT
      SLV_WR_WORD_1_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_WORD_1_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_WORD_1;
      end
      // WORD 0 WAIT
      SLV_WR_WORD_0_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_WORD_0_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_WORD_0;
      end
      
      // DWORD WAIT
      SLV_WR_DWORD_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_wr_nxt_state = SLV_WR_DWORD_WAIT;
         else
            slv_wr_nxt_state = SLV_WR_DWORD_W0;
      end
      default :
      begin
         slv_wr_nxt_state = SLV_WR_IDLE ;
      end
   endcase
end


always @ ( posedge mem_clk or negedge mem_rst_n )
begin
   if ( ~mem_rst_n )
   begin
      slv_wr_cur_state <= SLV_WR_IDLE; 
      byte_0_reg       <= 'd0;
      byte_1_reg       <= 'd0;
      byte_2_reg       <= 'd0;
      byte_3_reg       <= 'd0;
      byte_4_reg       <= 'd0;
      byte_5_reg       <= 'd0;
      byte_6_reg       <= 'd0;
      hword_0_reg      <= 'd0;
      hword_1_reg      <= 'd0;
      hword_2_reg      <= 'd0;
      word_0_reg       <= 'd0;
      strb_0_reg       <= 'd0;
      strb_1_reg       <= 'd0;
      strb_2_reg       <= 'd0;
      strb_3_reg       <= 'd0;
      strb_4_reg       <= 'd0;
      strb_5_reg       <= 'd0;
      strb_6_reg       <= 'd0;
      strb_10_reg      <= 'd0;
      strb_32_reg      <= 'd0;
      strb_54_reg      <= 'd0;
      strb_30_reg      <= 'd0;
      wrap_data_reg <= 'd0; 
      wrap_strb_reg <= 'd0;
      wrap_1st_xfer <=  1'b0;
   end
   else
   begin
      slv_wr_cur_state <= slv_wr_nxt_state; 
      wrap_data_reg <= nxt_wrap_data_reg;
      wrap_strb_reg <= nxt_wrap_strb_reg;
      wrap_1st_xfer <= nxt_wrap_1st_xfer; 
      if ( (slv_wr_cur_state == SLV_WR_BYTE_0 ) & rdata_valid )
      begin
         byte_0_reg  <= wdata[7:0]; 
         strb_0_reg  <= wstrb[0]; 
      end
      else if ( slv_wr_cur_state == SLV_WR_IDLE )
      begin
         byte_0_reg  <= 'd0; 
         strb_0_reg  <= 'd0; 
      end

      if ( (slv_wr_cur_state == SLV_WR_BYTE_1 ) & rdata_valid )
      begin
         byte_1_reg  <= wdata[15:8]; 
         strb_1_reg  <= wstrb[1]; 
      end
      else if ( slv_wr_cur_state == SLV_WR_IDLE )
      begin
         byte_1_reg  <= 'd0; 
         strb_1_reg  <= 'd0; 
      end


      if ( (slv_wr_cur_state == SLV_WR_BYTE_2 ) & rdata_valid )
      begin
         byte_2_reg  <= wdata[23:16]; 
         strb_2_reg  <= wstrb[2]; 
      end
      else if ( slv_wr_cur_state == SLV_WR_IDLE )
      begin
         byte_2_reg  <= 'd0; 
         strb_2_reg  <= 'd0; 
      end

      if ( (slv_wr_cur_state == SLV_WR_BYTE_3 ) & rdata_valid )
      begin
         byte_3_reg  <= wdata[31:24]; 
         strb_3_reg  <= wstrb[3]; 
      end
      else if ( slv_wr_cur_state == SLV_WR_IDLE )
      begin
         byte_3_reg  <= 'd0; 
         strb_3_reg  <= 'd0; 
      end

      if ( (slv_wr_cur_state == SLV_WR_BYTE_4 ) & rdata_valid )
      begin
         byte_4_reg  <= wdata[39:32]; 
         strb_4_reg  <= wstrb[4]; 
      end
      else if ( slv_wr_cur_state == SLV_WR_IDLE )
      begin
         byte_4_reg  <= 'd0; 
         strb_4_reg  <= 'd0; 
      end

      if ( (slv_wr_cur_state == SLV_WR_BYTE_5 ) & rdata_valid )
      begin
         byte_5_reg  <= wdata[47:40]; 
         strb_5_reg  <= wstrb[5]; 
      end
      else if ( slv_wr_cur_state == SLV_WR_IDLE )
      begin
         byte_5_reg  <= 'd0; 
         strb_5_reg  <= 'd0; 
      end

      if ( (slv_wr_cur_state == SLV_WR_BYTE_6 ) & rdata_valid )
      begin
         byte_6_reg  <= wdata[55:48]; 
         strb_6_reg  <= wstrb[6]; 
      end
      else if ( slv_wr_cur_state == SLV_WR_IDLE )
      begin
         byte_6_reg  <= 'd0; 
         strb_6_reg  <= 'd0; 
      end

      if ( (slv_wr_cur_state == SLV_WR_HWORD_0 ) & rdata_valid )
      begin
         hword_0_reg <= wdata[15:0]; 
         strb_10_reg <= wstrb[1:0]; 
      end
      else if ( slv_wr_cur_state == SLV_WR_IDLE )
      begin
         hword_0_reg <= 'd0; 
         strb_10_reg <= 'd0; 
      end

      if ( (slv_wr_cur_state == SLV_WR_HWORD_1 ) & rdata_valid )
      begin
         hword_1_reg <= wdata[31:16]; 
         strb_32_reg <= wstrb[3:2]; 
      end
      else if ( slv_wr_cur_state == SLV_WR_IDLE )
      begin
         hword_1_reg <= 'd0; 
         strb_32_reg <= 'd0; 
      end

      if ( (slv_wr_cur_state == SLV_WR_HWORD_2 ) & rdata_valid )
      begin
         hword_2_reg <= wdata[47:32]; 
         strb_54_reg <= wstrb[5:4]; 
      end
      else if ( slv_wr_cur_state == SLV_WR_IDLE )
      begin
         hword_2_reg <= 'd0; 
         strb_54_reg <= 'd0; 
      end

      if ( (slv_wr_cur_state == SLV_WR_WORD_0 ) & rdata_valid )
      begin
         word_0_reg  <= wdata[31:0]; 
         strb_30_reg <= wstrb[ 3:0]; 
      end
      else if ( slv_wr_cur_state == SLV_WR_IDLE )
      begin
         word_0_reg  <= 'd0; 
         strb_30_reg <= 'd0; 
      end

   end
end

assign wdata_ff_rd_en = ( ~wdata_ff_empty & ( (( slv_wr_cur_state == SLV_WR_IDLE  ) & slv_arb_wr_start_en_sig ) | 
                                              (( slv_wr_cur_state == SLV_WR_BYTE_0) & ~wlast ) | 
                                              (( slv_wr_cur_state == SLV_WR_BYTE_1) & ~wlast )|
                                              (( slv_wr_cur_state == SLV_WR_BYTE_2) & ~wlast )|
                                              (( slv_wr_cur_state == SLV_WR_BYTE_3) & ~wlast & (slv_wdata_ready | wrap_1st_xfer)) |
                                              (( slv_wr_cur_state == SLV_WR_BYTE_4) & ~wlast )| 
                                              (( slv_wr_cur_state == SLV_WR_BYTE_5) & ~wlast )|
                                              (( slv_wr_cur_state == SLV_WR_BYTE_6) & ~wlast )|
                                              (( slv_wr_cur_state == SLV_WR_BYTE_7) & ~wlast & (slv_wdata_ready | wrap_1st_xfer)) |
                                              (( slv_wr_cur_state == SLV_WR_HWORD_0)& ~wlast )|
                                              (( slv_wr_cur_state == SLV_WR_HWORD_1)& ~wlast & (slv_wdata_ready | wrap_1st_xfer)) |
                                              (( slv_wr_cur_state == SLV_WR_HWORD_2)& ~wlast )|
                                              (( slv_wr_cur_state == SLV_WR_HWORD_3)& ~wlast & (slv_wdata_ready | wrap_1st_xfer)) |
                                              (( slv_wr_cur_state == SLV_WR_WORD_0) & ~wlast & slv_wdata_ready) | 
                                              (( slv_wr_cur_state == SLV_WR_WORD_1) & ~wlast & slv_wdata_ready) | 
                                              (( slv_wr_cur_state == SLV_WR_DWORD_W1) & ~wlast & slv_wdata_ready)  | 
                                               ( slv_wr_cur_state == SLV_WR_BYTE_1_WAIT ) | 
                                               ( slv_wr_cur_state == SLV_WR_BYTE_2_WAIT ) | 
                                               ( slv_wr_cur_state == SLV_WR_BYTE_3_WAIT ) | 
                                               ( slv_wr_cur_state == SLV_WR_BYTE_4_WAIT ) | 
                                               ( slv_wr_cur_state == SLV_WR_BYTE_5_WAIT ) | 
                                               ( slv_wr_cur_state == SLV_WR_BYTE_6_WAIT ) | 
                                               ( slv_wr_cur_state == SLV_WR_BYTE_7_WAIT ) | 
                                               ( slv_wr_cur_state == SLV_WR_BYTE_0_WAIT ) | 
                                               ( slv_wr_cur_state == SLV_WR_HWORD_1_WAIT ) |
                                               ( slv_wr_cur_state == SLV_WR_HWORD_2_WAIT ) |
                                               ( slv_wr_cur_state == SLV_WR_HWORD_3_WAIT ) |
                                               ( slv_wr_cur_state == SLV_WR_HWORD_0_WAIT ) |
                                               ( slv_wr_cur_state == SLV_WR_WORD_0_WAIT ) |
                                               ( slv_wr_cur_state == SLV_WR_WORD_1_WAIT  ) | 
                                               ( slv_wr_cur_state == SLV_WR_DWORD_WAIT  ) ) );
always @ ( posedge mem_clk or negedge mem_rst_n )
begin
   if ( ~mem_rst_n )
   begin
   slv_wdata <= 32'd0;
   slv_wstrb <= 4'd0;
   slv_wvalid <= 1'b0;
   slv_wlast <= 1'b0;
   end
   else
   begin
 
   slv_wdata  <= (( slv_wr_cur_state == SLV_WR_BYTE_7   ) & wvalid) ? { wdata[63:56],byte_6_reg,byte_5_reg,byte_4_reg } :
                    (( slv_wr_cur_state == SLV_WR_BYTE_3   ) & wvalid) ? { wdata[31:24],byte_2_reg,byte_1_reg,byte_0_reg } :
                    (( slv_wr_cur_state == SLV_WR_HWORD_3  ) & wvalid) ? { wdata[63:48],hword_2_reg } :
                    (( slv_wr_cur_state == SLV_WR_HWORD_1  ) & wvalid) ? { wdata[31:16],hword_0_reg } :
                    (( slv_wr_cur_state == SLV_WR_WORD_0   ) & wvalid) ? { wdata[31:0]} :
                    (( slv_wr_cur_state == SLV_WR_WORD_1   ) & wvalid) ? { wdata[63:32]} :
                    (( slv_wr_cur_state == SLV_WR_DWORD_W0 ) & wvalid) ? { wdata[31:0]} :
                    (( slv_wr_cur_state == SLV_WR_DWORD_W1 ) & wvalid) ? { wdata[63:32]} :
                    (( slv_wr_cur_state == SLV_WR_BYTE_0   ) & wlast ) ? {wrap_data_reg[31:8],wdata[7:0]} :
                    (( slv_wr_cur_state == SLV_WR_BYTE_1   ) & wlast ) ? {wrap_data_reg[31:16],wdata[15:8],byte_0_reg} :
                    (( slv_wr_cur_state == SLV_WR_BYTE_2   ) & wlast ) ? {wrap_data_reg[31:24],wdata[23:16],byte_1_reg,byte_0_reg} :
                    (( slv_wr_cur_state == SLV_WR_BYTE_3   ) & wlast ) ? { wdata[31:24],byte_2_reg,byte_1_reg,byte_0_reg} :
                    (( slv_wr_cur_state == SLV_WR_BYTE_4   ) & wlast ) ? {wrap_data_reg[31:8], wdata[39:32]} :
                    (( slv_wr_cur_state == SLV_WR_BYTE_5   ) & wlast ) ? {wrap_data_reg[31:16], wdata[47:40],byte_4_reg} :
                    (( slv_wr_cur_state == SLV_WR_BYTE_6   ) & wlast ) ? {wrap_data_reg[31:24], wdata[55:48],byte_5_reg,byte_4_reg} :
                    (( slv_wr_cur_state == SLV_WR_HWORD_0  ) & wlast ) ? { wrap_data_reg[31:16],wdata[15:0]} : 
                    (( slv_wr_cur_state == SLV_WR_HWORD_1  ) & wlast ) ? { wdata[31:16],hword_0_reg} : 
                    (( slv_wr_cur_state == SLV_WR_HWORD_2  ) & wlast ) ? { wrap_data_reg[31:16],wdata[47:32]} : 
                    (( slv_wr_cur_state == SLV_WR_WORD_0   ) & wlast ) ? { wdata[31:0]} : 'd0;


   slv_wstrb  <= (( slv_wr_cur_state == SLV_WR_BYTE_7 ) & wvalid) ? { wstrb[7],strb_6_reg,strb_5_reg,strb_4_reg } :
                    (( slv_wr_cur_state == SLV_WR_BYTE_3 ) & wvalid) ? { wstrb[3],strb_2_reg,strb_1_reg,strb_0_reg } :
                    (( slv_wr_cur_state == SLV_WR_HWORD_3) & wvalid) ? { wstrb[7:6],strb_54_reg } :
                    (( slv_wr_cur_state == SLV_WR_HWORD_1) & wvalid) ? { wstrb[3:2],strb_10_reg } :
                    (( slv_wr_cur_state == SLV_WR_WORD_0 ) & wvalid) ? { wstrb[3:0]} :
                    (( slv_wr_cur_state == SLV_WR_WORD_1 ) & wvalid) ? { wstrb[7:4]} :
                    (( slv_wr_cur_state == SLV_WR_DWORD_W0 ) & wvalid) ? { wstrb[3:0]} :
                    (( slv_wr_cur_state == SLV_WR_DWORD_W1 ) & wvalid) ? { wstrb[7:4]} :
                    (( slv_wr_cur_state == SLV_WR_BYTE_0 ) & wlast ) ? (  wrap_odd_xfer ? {wrap_strb_reg[3:1],wstrb[0]} : {3'd0,wstrb[0]}) :
                    (( slv_wr_cur_state == SLV_WR_BYTE_1 ) & wlast ) ? (  wrap_odd_xfer ? {wrap_strb_reg[3:2], wstrb[1],strb_0_reg} : 
                                                                       {2'd0,wstrb[1],strb_0_reg}) :
                    (( slv_wr_cur_state == SLV_WR_BYTE_2 ) & wlast ) ? (  wrap_odd_xfer ? {wrap_strb_reg[3],wstrb[2],strb_1_reg,strb_0_reg} : 
                                                                       {1'd0,wstrb[2],strb_1_reg,strb_0_reg}) :
                    (( slv_wr_cur_state == SLV_WR_BYTE_3 ) & wlast ) ? {  wstrb[3],strb_2_reg,strb_1_reg,strb_0_reg} :
                    (( slv_wr_cur_state == SLV_WR_BYTE_4 ) & wlast ) ? (wrap_odd_xfer ? {wrap_strb_reg[3:1],wstrb[4]} : {3'd0,wstrb[4]}):
                    (( slv_wr_cur_state == SLV_WR_BYTE_5 ) & wlast ) ? (wrap_odd_xfer ? {wrap_strb_reg[3:2], wstrb[5],strb_4_reg} : 
                                                                       {2'd0,wstrb[5],strb_4_reg}):
                    (( slv_wr_cur_state == SLV_WR_BYTE_6 ) & wlast ) ? (wrap_odd_xfer ? {wrap_strb_reg[3],wstrb[6],strb_5_reg,strb_4_reg} : 
                                                                       {1'd0,wstrb[6],strb_5_reg,strb_4_reg}) :
                    (( slv_wr_cur_state == SLV_WR_HWORD_0) & wlast ) ? ( wrap_odd_xfer ? { wrap_strb_reg[3:2], wstrb[1:0]} : {2'd0,wstrb[1:0]}) : 
                    (( slv_wr_cur_state == SLV_WR_HWORD_1) & wlast ) ? {  wstrb[3:2],strb_10_reg} : 
                    (( slv_wr_cur_state == SLV_WR_HWORD_2) & wlast ) ? ( wrap_odd_xfer ? { wrap_strb_reg[3:2], wstrb[5:4]} : {2'd0,wstrb[5:4]}) : 
                    (( slv_wr_cur_state == SLV_WR_WORD_0 ) & wlast ) ? {  strb_30_reg}  : 'd0 ; 

   slv_wvalid <= ((( slv_wr_cur_state == SLV_WR_BYTE_7 ) & wvalid) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_3 ) & wvalid) | 
                    (( slv_wr_cur_state == SLV_WR_HWORD_3) & wvalid) | 
                    (( slv_wr_cur_state == SLV_WR_HWORD_1) & wvalid) | 
                    (( slv_wr_cur_state == SLV_WR_WORD_0 ) & wvalid) | 
                    (( slv_wr_cur_state == SLV_WR_WORD_1 ) & wvalid) | 
                    (( slv_wr_cur_state == SLV_WR_DWORD_W0 ) & wvalid) | 
                    (( slv_wr_cur_state == SLV_WR_DWORD_W1 ) & wvalid) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_0 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_1 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_2 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_3 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_4 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_5 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_6 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_7 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_HWORD_0) & wlast ) |
                    (( slv_wr_cur_state == SLV_WR_HWORD_1) & wlast ) |
                    (( slv_wr_cur_state == SLV_WR_HWORD_2) & wlast ) |
                    (( slv_wr_cur_state == SLV_WR_WORD_0 ) & wlast )) & (!wrap_1st_xfer) & (!slv_wdata_ready);

   slv_wlast  <= (( slv_wr_cur_state == SLV_WR_BYTE_0 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_1 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_2 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_3 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_4 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_5 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_6 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_BYTE_7 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_HWORD_0) & wlast ) |
                    (( slv_wr_cur_state == SLV_WR_HWORD_1) & wlast ) |
                    (( slv_wr_cur_state == SLV_WR_HWORD_2) & wlast ) |
                    (( slv_wr_cur_state == SLV_WR_HWORD_3) & wlast ) |
                    (( slv_wr_cur_state == SLV_WR_WORD_0 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_WORD_1 ) & wlast ) | 
                    (( slv_wr_cur_state == SLV_WR_DWORD_W0 ) & wlast & (!(&wstrb[3:0]))) |
                    (( slv_wr_cur_state == SLV_WR_DWORD_W1 ) & wlast ) ;
	end
end
end

//===================================================================================
// AXI DATA WIDTH 128 bits
//===================================================================================

else // SLAVE DATA WIDTH 128 

begin // SLV DATA WIDTH 128 START 

reg    [ 7 : 0 ]                       byte_0_reg;
reg    [ 7 : 0 ]                       byte_1_reg;
reg    [ 7 : 0 ]                       byte_2_reg;
reg    [ 7 : 0 ]                       byte_3_reg;
reg    [ 7 : 0 ]                       byte_4_reg;
reg    [ 7 : 0 ]                       byte_5_reg;
reg    [ 7 : 0 ]                       byte_6_reg;
reg    [ 7 : 0 ]                       byte_7_reg;
reg    [ 7 : 0 ]                       byte_8_reg;
reg    [ 7 : 0 ]                       byte_9_reg;
reg    [ 7 : 0 ]                       byte_10_reg;
reg    [ 7 : 0 ]                       byte_11_reg;
reg    [ 7 : 0 ]                       byte_12_reg;
reg    [ 7 : 0 ]                       byte_13_reg;
reg    [ 7 : 0 ]                       byte_14_reg;

reg                                    strb_0_reg;
reg                                    strb_1_reg;
reg                                    strb_2_reg;
reg                                    strb_3_reg;
reg                                    strb_4_reg;
reg                                    strb_5_reg;
reg                                    strb_6_reg;
reg                                    strb_7_reg;
reg                                    strb_8_reg;
reg                                    strb_9_reg;
reg                                    strb_a_reg;
reg                                    strb_b_reg;
reg                                    strb_c_reg;
reg                                    strb_d_reg;
reg                                    strb_e_reg;

reg    [15 : 0 ]                       hword_0_reg;
reg    [15 : 0 ]                       hword_1_reg;
reg    [15 : 0 ]                       hword_2_reg;
reg    [15 : 0 ]                       hword_3_reg;
reg    [15 : 0 ]                       hword_4_reg;
reg    [15 : 0 ]                       hword_5_reg;
reg    [15 : 0 ]                       hword_6_reg;

reg    [ 1 : 0 ]                       strb_10_reg;
reg    [ 1 : 0 ]                       strb_32_reg;
reg    [ 1 : 0 ]                       strb_54_reg;
reg    [ 1 : 0 ]                       strb_76_reg;
reg    [ 1 : 0 ]                       strb_98_reg;
reg    [ 1 : 0 ]                       strb_1110_reg;
reg    [ 1 : 0 ]                       strb_1312_reg;

reg    [31 : 0 ]                       word_0_reg;
reg    [31 : 0 ]                       word_1_reg;
reg    [31 : 0 ]                       word_2_reg;

reg    [ 3 : 0 ]                       strb_30_reg;
reg    [ 3 : 0 ]                       strb_74_reg;
reg    [ 3 : 0 ]                       strb_118_reg;

wire   [31:0]        slv_b_wdata;
wire                                   slv_b_wvalid;
wire   [3:0]    slv_b_wstrb;
wire                                   slv_b_wlast;

wire   [31:0]        slv_hw_wdata;
wire                                   slv_hw_wvalid;
wire   [3:0]    slv_hw_wstrb;
wire                                   slv_hw_wlast;

wire   [SLV_MEM_DATA_WIDTH-1:0]        slv_w_wdata;
wire                                   slv_w_wvalid;
wire   [(SLV_MEM_DATA_WIDTH/8)-1:0]    slv_w_wstrb;
wire                                   slv_w_wlast;

wire   [SLV_MEM_DATA_WIDTH-1:0]        slv_dq_wdata;
wire                                   slv_dq_wvalid;
wire   [(SLV_MEM_DATA_WIDTH/8)-1:0]    slv_dq_wstrb;
wire                                   slv_dq_wlast;

reg                                    slv_b_sel_en;
reg                                    slv_hw_sel_en;
reg                                    slv_w_sel_en;
reg                                    slv_dq_sel_en;

//===================================================================================
// SIZE 0 State machine ( Single byte write )
//===================================================================================

reg  [5:0] slv_b_wr_cur_state;
reg  [5:0] slv_b_wr_nxt_state;

localparam [5:0]  SLV_B_WR_IDLE      = 6'h20;
localparam [5:0]  SLV_WR_BYTE_0      = 6'h00;
localparam [5:0]  SLV_WR_BYTE_1      = 6'h01;
localparam [5:0]  SLV_WR_BYTE_2      = 6'h02;
localparam [5:0]  SLV_WR_BYTE_3      = 6'h03;
localparam [5:0]  SLV_WR_BYTE_4      = 6'h04;
localparam [5:0]  SLV_WR_BYTE_5      = 6'h05;
localparam [5:0]  SLV_WR_BYTE_6      = 6'h06;
localparam [5:0]  SLV_WR_BYTE_7      = 6'h07;
localparam [5:0]  SLV_WR_BYTE_8      = 6'h08;
localparam [5:0]  SLV_WR_BYTE_9      = 6'h09;
localparam [5:0]  SLV_WR_BYTE_10     = 6'h0A;
localparam [5:0]  SLV_WR_BYTE_11     = 6'h0B;
localparam [5:0]  SLV_WR_BYTE_12     = 6'h0C;
localparam [5:0]  SLV_WR_BYTE_13     = 6'h0D;
localparam [5:0]  SLV_WR_BYTE_14     = 6'h0E;
localparam [5:0]  SLV_WR_BYTE_15     = 6'h0F;
localparam [5:0]  SLV_WR_BYTE_1_WAIT = 6'h10;
localparam [5:0]  SLV_WR_BYTE_2_WAIT = 6'h11;
localparam [5:0]  SLV_WR_BYTE_3_WAIT = 6'h12;
localparam [5:0]  SLV_WR_BYTE_4_WAIT = 6'h13;
localparam [5:0]  SLV_WR_BYTE_5_WAIT = 6'h14;
localparam [5:0]  SLV_WR_BYTE_6_WAIT = 6'h15;
localparam [5:0]  SLV_WR_BYTE_7_WAIT = 6'h16;
localparam [5:0]  SLV_WR_BYTE_8_WAIT = 6'h17;
localparam [5:0]  SLV_WR_BYTE_9_WAIT = 6'h18;
localparam [5:0]  SLV_WR_BYTE_10_WAIT= 6'h19;
localparam [5:0]  SLV_WR_BYTE_11_WAIT= 6'h1A;
localparam [5:0]  SLV_WR_BYTE_12_WAIT= 6'h1B;
localparam [5:0]  SLV_WR_BYTE_13_WAIT= 6'h1C;
localparam [5:0]  SLV_WR_BYTE_14_WAIT= 6'h1D;
localparam [5:0]  SLV_WR_BYTE_15_WAIT= 6'h1E;
localparam [5:0]  SLV_WR_BYTE_0_WAIT = 6'h1F;


always @ (*)
begin
           nxt_wrap_1st_xfer = wrap_1st_xfer;
           nxt_wrap_data_reg  = wrap_data_reg;
           nxt_wrap_strb_reg  = wrap_strb_reg;
   case (slv_b_wr_cur_state )
      SLV_B_WR_IDLE :
      begin
         if ( slv_arb_wr_start_en_sig  & ~wdata_ff_empty & (slv_awsize_sig == 3'd0) ) 
         begin
            nxt_wrap_1st_xfer = slv_awburst_sig==2'b10 && (|slv_arb_addr_sig[1:0]);
            if ( slv_arb_addr_sig[3:0] == 4'b0000 ) 
               slv_b_wr_nxt_state = SLV_WR_BYTE_0;
            else if ( slv_arb_addr_sig[3:0] == 4'b0001 )
               slv_b_wr_nxt_state = SLV_WR_BYTE_1;
            else if ( slv_arb_addr_sig[3:0] == 4'b0010 )
               slv_b_wr_nxt_state = SLV_WR_BYTE_2;
            else if ( slv_arb_addr_sig[3:0] == 4'b0011 )
               slv_b_wr_nxt_state = SLV_WR_BYTE_3;
            else if ( slv_arb_addr_sig[3:0] == 4'b0100 )
               slv_b_wr_nxt_state = SLV_WR_BYTE_4;
            else if ( slv_arb_addr_sig[3:0] == 4'b0101 )
               slv_b_wr_nxt_state = SLV_WR_BYTE_5;
            else if ( slv_arb_addr_sig[3:0] == 4'b0110 )
               slv_b_wr_nxt_state = SLV_WR_BYTE_6;
            else if ( slv_arb_addr_sig[3:0] == 4'b0111 ) 
               slv_b_wr_nxt_state = SLV_WR_BYTE_7;
            else if ( slv_arb_addr_sig[3:0] == 4'b1000 ) 
               slv_b_wr_nxt_state = SLV_WR_BYTE_8;
            else if ( slv_arb_addr_sig[3:0] == 4'b1001 )
               slv_b_wr_nxt_state = SLV_WR_BYTE_9;
            else if ( slv_arb_addr_sig[3:0] == 4'b1010 )
               slv_b_wr_nxt_state = SLV_WR_BYTE_10;
            else if ( slv_arb_addr_sig[3:0] == 4'b1011 )
               slv_b_wr_nxt_state = SLV_WR_BYTE_11;
            else if ( slv_arb_addr_sig[3:0] == 4'b1100 )
               slv_b_wr_nxt_state = SLV_WR_BYTE_12;
            else if ( slv_arb_addr_sig[3:0] == 4'b1101 )
               slv_b_wr_nxt_state = SLV_WR_BYTE_13;
            else if ( slv_arb_addr_sig[3:0] == 4'b1110 )
               slv_b_wr_nxt_state = SLV_WR_BYTE_14;
            else 
               slv_b_wr_nxt_state = SLV_WR_BYTE_15;
         end
         else
            slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
      end
      // BYTE 0
      SLV_WR_BYTE_0 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_0;
         else if ( ~wlast & wdata_ff_empty  ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_1_WAIT;
         else
            slv_b_wr_nxt_state = SLV_WR_BYTE_1;
      end
      // BYTE 1
      SLV_WR_BYTE_1 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_1;
         else if ( ~wlast & wdata_ff_empty ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_2_WAIT;
         else 
            slv_b_wr_nxt_state = SLV_WR_BYTE_2;
      end
      // BYTE 2
      SLV_WR_BYTE_2 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_2;
         else if ( ~wlast & wdata_ff_empty  ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_3_WAIT;
         else 
            slv_b_wr_nxt_state = SLV_WR_BYTE_3;
      end
      // BYTE 3
      SLV_WR_BYTE_3 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
         else if ( (slv_wdata_ready | wrap_1st_xfer) & ~wdata_ff_empty)
         begin
            nxt_wrap_1st_xfer = 1'b0;
            slv_b_wr_nxt_state = SLV_WR_BYTE_4;
            nxt_wrap_data_reg =wrap_1st_xfer ?  {wdata[31:24],byte_2_reg,byte_1_reg,byte_0_reg} : wrap_data_reg;
            nxt_wrap_strb_reg =wrap_1st_xfer ?    { wstrb[3],strb_2_reg,strb_1_reg,strb_0_reg } : wrap_strb_reg;
         end
         else if ( (slv_wdata_ready | wrap_1st_xfer) & wdata_ff_empty)
         begin
            nxt_wrap_1st_xfer = 1'b0;
            slv_b_wr_nxt_state = SLV_WR_BYTE_4_WAIT;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[31:24],byte_2_reg,byte_1_reg,byte_0_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ?   { wstrb[3],strb_2_reg,strb_1_reg,strb_0_reg } : wrap_strb_reg;
         end
         else    
            slv_b_wr_nxt_state = SLV_WR_BYTE_3;
      end
      // BYTE 4
      SLV_WR_BYTE_4 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_4;
         else if ( ~wlast & wdata_ff_empty  )
            slv_b_wr_nxt_state = SLV_WR_BYTE_5_WAIT;
         else    
            slv_b_wr_nxt_state = SLV_WR_BYTE_5;
      end
      // BYTE 5
      SLV_WR_BYTE_5 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_5;
         else if ( ~wlast & wdata_ff_empty  )
            slv_b_wr_nxt_state = SLV_WR_BYTE_6_WAIT;
         else    
            slv_b_wr_nxt_state = SLV_WR_BYTE_6;
      end
      // BYTE 6
      SLV_WR_BYTE_6 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_6;
         else if ( ~wlast & wdata_ff_empty  )
            slv_b_wr_nxt_state = SLV_WR_BYTE_7_WAIT;
         else    
            slv_b_wr_nxt_state = SLV_WR_BYTE_7;
      end
      // BYTE 7
      SLV_WR_BYTE_7 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
         else if ( (slv_wdata_ready | wrap_1st_xfer) & ~wdata_ff_empty)
         begin
            nxt_wrap_1st_xfer = 1'b0;
            slv_b_wr_nxt_state = SLV_WR_BYTE_8;
            nxt_wrap_data_reg =wrap_1st_xfer ?  {wdata[63:56],byte_6_reg,byte_5_reg,byte_4_reg} : wrap_data_reg;
            nxt_wrap_strb_reg =wrap_1st_xfer ?    { wstrb[7],strb_6_reg,strb_5_reg,strb_4_reg } : wrap_strb_reg;
         end
         else if ( (slv_wdata_ready | wrap_1st_xfer) & wdata_ff_empty)
         begin
            nxt_wrap_1st_xfer = 1'b0;
            slv_b_wr_nxt_state = SLV_WR_BYTE_8_WAIT;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[63:56],byte_6_reg,byte_5_reg,byte_4_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ?   { wstrb[7],strb_6_reg,strb_5_reg,strb_4_reg } : wrap_strb_reg;
         end
         else    
            slv_b_wr_nxt_state = SLV_WR_BYTE_7;
      end
      // BYTE 8 
      SLV_WR_BYTE_8 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready )
            slv_b_wr_nxt_state = SLV_WR_BYTE_8;
         else if ( ~wlast & wdata_ff_empty)
            slv_b_wr_nxt_state = SLV_WR_BYTE_9_WAIT;
         else    
            slv_b_wr_nxt_state = SLV_WR_BYTE_9;
      end
      // BYTE 9 
      SLV_WR_BYTE_9 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready )
            slv_b_wr_nxt_state = SLV_WR_BYTE_9;
         else if ( ~wlast & wdata_ff_empty)
            slv_b_wr_nxt_state = SLV_WR_BYTE_10_WAIT;
         else    
            slv_b_wr_nxt_state = SLV_WR_BYTE_10;
      end
      // BYTE 10 
      SLV_WR_BYTE_10 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready )
            slv_b_wr_nxt_state = SLV_WR_BYTE_10;
         else if ( ~wlast & wdata_ff_empty)
            slv_b_wr_nxt_state = SLV_WR_BYTE_11_WAIT;
         else    
            slv_b_wr_nxt_state = SLV_WR_BYTE_11;
      end
      // BYTE 11 
      SLV_WR_BYTE_11 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
         else if ( (slv_wdata_ready | wrap_1st_xfer) & ~wdata_ff_empty)
         begin
            nxt_wrap_1st_xfer = 1'b0;
            slv_b_wr_nxt_state = SLV_WR_BYTE_12;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[95:88],byte_10_reg,byte_9_reg,byte_8_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ?   { wstrb[11],strb_10_reg,strb_9_reg,strb_8_reg}  : wrap_strb_reg;
         end
         else if ( (slv_wdata_ready | wrap_1st_xfer) & wdata_ff_empty)
         begin
            nxt_wrap_1st_xfer = 1'b0;
            slv_b_wr_nxt_state = SLV_WR_BYTE_12_WAIT;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[95:88],byte_10_reg,byte_9_reg,byte_8_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ?   { wstrb[11],strb_10_reg,strb_9_reg,strb_8_reg}  : wrap_strb_reg;
         end
         else    
            slv_b_wr_nxt_state = SLV_WR_BYTE_11;
      end
      // BYTE 12 
      SLV_WR_BYTE_12 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready )
            slv_b_wr_nxt_state = SLV_WR_BYTE_12;
         else if ( ~wlast & wdata_ff_empty)
            slv_b_wr_nxt_state = SLV_WR_BYTE_13_WAIT;
         else    
            slv_b_wr_nxt_state = SLV_WR_BYTE_13;
      end
      // BYTE 13 
      SLV_WR_BYTE_13 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready )
            slv_b_wr_nxt_state = SLV_WR_BYTE_13;
         else if ( ~wlast & wdata_ff_empty)
            slv_b_wr_nxt_state = SLV_WR_BYTE_14_WAIT;
         else    
            slv_b_wr_nxt_state = SLV_WR_BYTE_14;
      end
      // BYTE 14 
      SLV_WR_BYTE_14 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready )
            slv_b_wr_nxt_state = SLV_WR_BYTE_14;
         else if ( ~wlast & wdata_ff_empty)
            slv_b_wr_nxt_state = SLV_WR_BYTE_15_WAIT;
         else    
            slv_b_wr_nxt_state = SLV_WR_BYTE_15;
      end
      // BYTE 15 
      SLV_WR_BYTE_15 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
         else if ( (slv_wdata_ready | wrap_1st_xfer) & ~wdata_ff_empty)
         begin
            nxt_wrap_1st_xfer = 1'b0;
            slv_b_wr_nxt_state = SLV_WR_BYTE_0;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[127:120],byte_14_reg,byte_13_reg,byte_12_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ?   { wstrb[15],strb_e_reg,strb_d_reg,strb_c_reg }     : wrap_strb_reg;
         end
         else if ( (slv_wdata_ready | wrap_1st_xfer) & wdata_ff_empty)
         begin
            nxt_wrap_1st_xfer = 1'b0;
            slv_b_wr_nxt_state = SLV_WR_BYTE_0_WAIT;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[127:120],byte_14_reg,byte_13_reg,byte_12_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ?   { wstrb[15],strb_e_reg,strb_d_reg,strb_c_reg }     : wrap_strb_reg;
         end
         else    
            slv_b_wr_nxt_state = SLV_WR_BYTE_15;
      end
      // BYTE 1 WAIT
      SLV_WR_BYTE_1_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_1_WAIT;
         else
            slv_b_wr_nxt_state = SLV_WR_BYTE_1;
      end
      // BYTE 2 WAIT
      SLV_WR_BYTE_2_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_2_WAIT;
         else
            slv_b_wr_nxt_state = SLV_WR_BYTE_2;
      end
      // BYTE 3 WAIT
      SLV_WR_BYTE_3_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_3_WAIT;
         else
            slv_b_wr_nxt_state = SLV_WR_BYTE_3;
      end
      // BYTE 4 WAIT
      SLV_WR_BYTE_4_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_4_WAIT;
         else
            slv_b_wr_nxt_state = SLV_WR_BYTE_4;
      end
      // BYTE 5 WAIT
      SLV_WR_BYTE_5_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_5_WAIT;
         else
            slv_b_wr_nxt_state = SLV_WR_BYTE_5;
      end
      // BYTE 6 WAIT
      SLV_WR_BYTE_6_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_6_WAIT;
         else
            slv_b_wr_nxt_state = SLV_WR_BYTE_6;
      end
      // BYTE 7 WAIT
      SLV_WR_BYTE_7_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_7_WAIT;
         else
            slv_b_wr_nxt_state = SLV_WR_BYTE_7;
      end
      // BYTE 8 WAIT
      SLV_WR_BYTE_8_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_8_WAIT;
         else
            slv_b_wr_nxt_state = SLV_WR_BYTE_8;
      end
      // BYTE 9 WAIT
      SLV_WR_BYTE_9_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_9_WAIT;
         else
            slv_b_wr_nxt_state = SLV_WR_BYTE_9;
      end
      // BYTE 10 WAIT
      SLV_WR_BYTE_10_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_10_WAIT;
         else
            slv_b_wr_nxt_state = SLV_WR_BYTE_10;
      end
      // BYTE 11 WAIT
      SLV_WR_BYTE_11_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_11_WAIT;
         else
            slv_b_wr_nxt_state = SLV_WR_BYTE_11;
      end
      // BYTE 12 WAIT
      SLV_WR_BYTE_12_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_12_WAIT;
         else
            slv_b_wr_nxt_state = SLV_WR_BYTE_12;
      end
      // BYTE 13 WAIT
      SLV_WR_BYTE_13_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_13_WAIT;
         else
            slv_b_wr_nxt_state = SLV_WR_BYTE_13;
      end
      // BYTE 14 WAIT
      SLV_WR_BYTE_14_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_14_WAIT;
         else
            slv_b_wr_nxt_state = SLV_WR_BYTE_14;
      end
      // BYTE 15 WAIT
      SLV_WR_BYTE_15_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_15_WAIT;
         else
            slv_b_wr_nxt_state = SLV_WR_BYTE_15;
      end

      // BYTE 0 WAIT
      SLV_WR_BYTE_0_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_b_wr_nxt_state = SLV_WR_BYTE_0_WAIT;
         else
            slv_b_wr_nxt_state = SLV_WR_BYTE_0;
      end
      default :
      begin
         slv_b_wr_nxt_state = SLV_B_WR_IDLE ;
      end
   endcase
end

always @ ( posedge mem_clk or negedge mem_rst_n )
begin
   if ( ~mem_rst_n )
   begin
      slv_b_wr_cur_state <= SLV_B_WR_IDLE; 
      byte_0_reg       <= 'd0;
      byte_1_reg       <= 'd0;
      byte_2_reg       <= 'd0;
      byte_3_reg       <= 'd0;
      byte_4_reg       <= 'd0;
      byte_5_reg       <= 'd0;
      byte_6_reg       <= 'd0;
      byte_7_reg       <= 'd0;
      byte_8_reg       <= 'd0;
      byte_9_reg       <= 'd0;
      byte_10_reg      <= 'd0;
      byte_11_reg      <= 'd0;
      byte_12_reg      <= 'd0;
      byte_13_reg      <= 'd0;
      byte_14_reg      <= 'd0;
      strb_0_reg       <= 'd0;
      strb_1_reg       <= 'd0;
      strb_2_reg       <= 'd0;
      strb_3_reg       <= 'd0;
      strb_4_reg       <= 'd0;
      strb_5_reg       <= 'd0;
      strb_6_reg       <= 'd0;
      strb_7_reg       <= 'd0;
      strb_8_reg       <= 'd0;
      strb_9_reg       <= 'd0;
      strb_a_reg       <= 'd0;
      strb_b_reg       <= 'd0;
      strb_c_reg       <= 'd0;
      strb_d_reg       <= 'd0;
      strb_e_reg       <= 'd0;
      slv_b_sel_en     <= 1'b0;
      wrap_1st_xfer    <= 1'b0;
   end
   else
   begin
      slv_b_wr_cur_state <= slv_b_wr_nxt_state; 
      wrap_1st_xfer    <= nxt_wrap_1st_xfer;
      if ( (slv_b_wr_cur_state == SLV_WR_BYTE_0 ) & rdata_valid )
      begin
         byte_0_reg  <= wdata[7:0]; 
         strb_0_reg  <= wstrb[0]; 
      end
      else if ( slv_b_wr_cur_state == SLV_B_WR_IDLE )
      begin
         byte_0_reg  <= 'd0; 
         strb_0_reg  <= 'd0; 
      end

      if ( (slv_b_wr_cur_state == SLV_WR_BYTE_1 ) & rdata_valid )
      begin
         byte_1_reg  <= wdata[15:8]; 
         strb_1_reg  <= wstrb[1]; 
      end
      else if ( slv_b_wr_cur_state == SLV_B_WR_IDLE )
      begin
         byte_1_reg  <= 'd0; 
         strb_1_reg  <= 'd0; 
      end

      if ( (slv_b_wr_cur_state == SLV_WR_BYTE_2 ) & rdata_valid )
      begin
         byte_2_reg  <= wdata[23:16]; 
         strb_2_reg  <= wstrb[2]; 
      end
      else if ( slv_b_wr_cur_state == SLV_B_WR_IDLE )
      begin
         byte_2_reg  <= 'd0; 
         strb_2_reg  <= 'd0; 
      end

      if ( (slv_b_wr_cur_state == SLV_WR_BYTE_3 ) & rdata_valid )
      begin
         byte_3_reg  <= wdata[31:24]; 
         strb_3_reg  <= wstrb[3]; 
      end
      else if ( slv_b_wr_cur_state == SLV_B_WR_IDLE )
      begin
         byte_3_reg  <= 'd0; 
         strb_3_reg  <= 'd0; 
      end

      if ( (slv_b_wr_cur_state == SLV_WR_BYTE_4 ) & rdata_valid )
      begin
         byte_4_reg  <= wdata[39:32]; 
         strb_4_reg  <= wstrb[4]; 
      end
      else if ( slv_b_wr_cur_state == SLV_B_WR_IDLE )
      begin
         byte_4_reg  <= 'd0; 
         strb_4_reg  <= 'd0; 
      end

      if ( (slv_b_wr_cur_state == SLV_WR_BYTE_5 ) & rdata_valid )
      begin
         byte_5_reg  <= wdata[47:40]; 
         strb_5_reg  <= wstrb[5]; 
      end
      else if ( slv_b_wr_cur_state == SLV_B_WR_IDLE )
      begin
         byte_5_reg  <= 'd0; 
         strb_5_reg  <= 'd0; 
      end

      if ( (slv_b_wr_cur_state == SLV_WR_BYTE_6 ) & rdata_valid )
      begin
         byte_6_reg  <= wdata[55:48]; 
         strb_6_reg  <= wstrb[6]; 
      end
      else if ( slv_b_wr_cur_state == SLV_B_WR_IDLE )
      begin
         byte_6_reg  <= 'd0; 
         strb_6_reg  <= 'd0; 
      end

      if ( (slv_b_wr_cur_state == SLV_WR_BYTE_7 ) & rdata_valid )
      begin
         byte_7_reg  <= wdata[63:56]; 
         strb_7_reg  <= wstrb[7]; 
      end
      else if ( slv_b_wr_cur_state == SLV_B_WR_IDLE )
      begin
         byte_7_reg  <= 'd0; 
         strb_7_reg  <= 'd0; 
      end

      if ( (slv_b_wr_cur_state == SLV_WR_BYTE_8 ) & rdata_valid )
      begin
         byte_8_reg  <= wdata[71:64]; 
         strb_8_reg  <= wstrb[8]; 
      end
      else if ( slv_b_wr_cur_state == SLV_B_WR_IDLE )
      begin
         byte_8_reg  <= 'd0; 
         strb_8_reg  <= 'd0; 
      end

      if ( (slv_b_wr_cur_state == SLV_WR_BYTE_9 ) & rdata_valid )
      begin
         byte_9_reg  <= wdata[79:72]; 
         strb_9_reg  <= wstrb[9]; 
      end
      else if ( slv_b_wr_cur_state == SLV_B_WR_IDLE )
      begin
         byte_9_reg  <= 'd0; 
         strb_9_reg  <= 'd0; 
      end

      if ( (slv_b_wr_cur_state == SLV_WR_BYTE_10 ) & rdata_valid )
      begin
         byte_10_reg  <= wdata[87:80]; 
         strb_a_reg  <= wstrb[10]; 
      end
      else if ( slv_b_wr_cur_state == SLV_B_WR_IDLE )
      begin
         byte_10_reg  <= 'd0; 
         strb_a_reg  <= 'd0; 
      end

      if ( (slv_b_wr_cur_state == SLV_WR_BYTE_11 ) & rdata_valid )
      begin
         byte_11_reg  <= wdata[95:88]; 
         strb_b_reg  <= wstrb[11]; 
      end
      else if ( slv_b_wr_cur_state == SLV_B_WR_IDLE )
      begin
         byte_11_reg  <= 'd0; 
         strb_b_reg  <= 'd0; 
      end

      if ( (slv_b_wr_cur_state == SLV_WR_BYTE_12 ) & rdata_valid )
      begin
         byte_12_reg  <= wdata[103:96]; 
         strb_c_reg  <= wstrb[12]; 
      end
      else if ( slv_b_wr_cur_state == SLV_B_WR_IDLE )
      begin
         byte_12_reg  <= 'd0; 
         strb_c_reg  <= 'd0; 
      end

      if ( (slv_b_wr_cur_state == SLV_WR_BYTE_13 ) & rdata_valid )
      begin
         byte_13_reg  <= wdata[111:104]; 
         strb_d_reg  <= wstrb[13]; 
      end
      else if ( slv_b_wr_cur_state == SLV_B_WR_IDLE )
      begin
         byte_13_reg  <= 'd0; 
         strb_d_reg  <= 'd0; 
      end

      if ( (slv_b_wr_cur_state == SLV_WR_BYTE_14 ) & rdata_valid )
      begin
         byte_14_reg  <= wdata[119:112]; 
         strb_e_reg  <= wstrb[14]; 
      end
      else if ( slv_b_wr_cur_state == SLV_B_WR_IDLE )
      begin
         byte_14_reg  <= 'd0; 
         strb_e_reg  <= 'd0; 
      end

      if ( ( slv_b_wr_cur_state == SLV_B_WR_IDLE  ) & slv_arb_wr_start_en_sig & (slv_awsize_sig == 3'd0) )
         slv_b_sel_en  <= 1'b1;
      else if ( wlast & slv_wdata_ready )
         slv_b_sel_en  <= 1'b0;
   end
end


assign wdata_b_ff_rd_en = ( ~wdata_ff_empty & ( (( slv_b_wr_cur_state == SLV_B_WR_IDLE  ) & slv_arb_wr_start_en_sig & (slv_awsize_sig == 3'd0)) | 
                                                (( slv_b_wr_cur_state == SLV_WR_BYTE_0) & ~wlast ) | 
                                                (( slv_b_wr_cur_state == SLV_WR_BYTE_1) & ~wlast ) |
                                                (( slv_b_wr_cur_state == SLV_WR_BYTE_2) & ~wlast ) |
                                                (( slv_b_wr_cur_state == SLV_WR_BYTE_3) & ~wlast & (slv_wdata_ready | wrap_1st_xfer)) |
                                                (( slv_b_wr_cur_state == SLV_WR_BYTE_4) & ~wlast ) | 
                                                (( slv_b_wr_cur_state == SLV_WR_BYTE_5) & ~wlast ) |
                                                (( slv_b_wr_cur_state == SLV_WR_BYTE_6) & ~wlast ) |
                                                (( slv_b_wr_cur_state == SLV_WR_BYTE_7) & ~wlast & (slv_wdata_ready | wrap_1st_xfer)) |
                                                (( slv_b_wr_cur_state == SLV_WR_BYTE_8) & ~wlast ) |
                                                (( slv_b_wr_cur_state == SLV_WR_BYTE_9) & ~wlast ) |
                                                (( slv_b_wr_cur_state == SLV_WR_BYTE_10)& ~wlast ) |
                                                (( slv_b_wr_cur_state == SLV_WR_BYTE_11)& ~wlast & (slv_wdata_ready | wrap_1st_xfer)) |
                                                (( slv_b_wr_cur_state == SLV_WR_BYTE_12)& ~wlast ) |
                                                (( slv_b_wr_cur_state == SLV_WR_BYTE_13)& ~wlast ) |
                                                (( slv_b_wr_cur_state == SLV_WR_BYTE_14)& ~wlast ) |
                                                (( slv_b_wr_cur_state == SLV_WR_BYTE_15)& ~wlast & (slv_wdata_ready | wrap_1st_xfer)) |
                                                 ( slv_b_wr_cur_state[4] == 1'b1 ) )); 
 
assign slv_b_wdata  = (( slv_b_wr_cur_state == SLV_WR_BYTE_15  ) ) ? { wdata[127:120],byte_14_reg,byte_13_reg,byte_12_reg } :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_11  ) ) ? { wdata[95:88],byte_10_reg,byte_9_reg,byte_8_reg } :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_7   ) ) ? { wdata[63:56],byte_6_reg,byte_5_reg,byte_4_reg } :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_3   ) ) ? { wdata[31:24],byte_2_reg,byte_1_reg,byte_0_reg } :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_0   ) & wlast ) ? {wrap_data_reg[31:8] ,wdata[7:0]} :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_1   ) & wlast ) ? {wrap_data_reg[31:16] ,wdata[15:8],byte_0_reg} :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_2   ) & wlast ) ? {wrap_data_reg[31:24] ,wdata[23:16],byte_1_reg,byte_0_reg} :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_4   ) & wlast ) ? {wrap_data_reg[31:8],wdata[39:32]} :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_5   ) & wlast ) ? {wrap_data_reg[31:16],wdata[47:40],byte_4_reg} :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_6   ) & wlast ) ? {wrap_data_reg[31:24],wdata[55:48],byte_5_reg,byte_4_reg} :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_8   ) & wlast ) ? {wrap_data_reg[31:8], wdata[71:64]} :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_9   ) & wlast ) ? {wrap_data_reg[31:16],wdata[79:72],byte_8_reg} :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_10  ) & wlast ) ? {wrap_data_reg[31:24],wdata[87:80],byte_9_reg,byte_8_reg} :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_12  ) & wlast ) ? {wrap_data_reg[31:8],wdata[103:96]} :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_13  ) & wlast ) ? {wrap_data_reg[31:16],wdata[111:104],byte_12_reg} :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_14  ) & wlast ) ? {wrap_data_reg[31:24],wdata[119:112],byte_13_reg,byte_12_reg} : 'd0;


assign slv_b_wstrb  = (( slv_b_wr_cur_state == SLV_WR_BYTE_15) & wvalid) ? { wstrb[15],strb_e_reg,strb_d_reg,strb_c_reg } :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_11) & wvalid) ? { wstrb[11],strb_a_reg,strb_9_reg,strb_8_reg } :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_7 ) & wvalid) ? { wstrb[7],strb_6_reg,strb_5_reg,strb_4_reg } :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_3 ) & wvalid) ? { wstrb[3],strb_2_reg,strb_1_reg,strb_0_reg } :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_0 )   & wlast ) ? ( wrap_odd_xfer ? {wrap_strb_reg[3:1],wstrb[0]} : {3'd0,wstrb[0]}) :
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_1 ) & wlast ) ? (  wrap_odd_xfer ? {wrap_strb_reg[3:2], wstrb[1],strb_0_reg} : 
                                                                           {2'd0,wstrb[1],strb_0_reg}) :
                    (( slv_b_wr_cur_state == SLV_WR_BYTE_2 ) & wlast ) ? (  wrap_odd_xfer ? {wrap_strb_reg[3],wstrb[2],strb_1_reg,strb_0_reg} : 
                                                                       {1'd0,wstrb[2],strb_1_reg,strb_0_reg}) :
                    (( slv_b_wr_cur_state == SLV_WR_BYTE_4 ) & wlast ) ? (wrap_odd_xfer ? {wrap_strb_reg[3:1],wstrb[4]} : {3'd0,wstrb[4]}):
                    (( slv_b_wr_cur_state == SLV_WR_BYTE_5 ) & wlast ) ? (wrap_odd_xfer ? {wrap_strb_reg[3:2], wstrb[5],strb_4_reg} : 
                                                                       {2'd0,wstrb[5],strb_4_reg}):
                    (( slv_b_wr_cur_state == SLV_WR_BYTE_6 ) & wlast ) ? (wrap_odd_xfer ? {wrap_strb_reg[3],wstrb[6],strb_5_reg,strb_4_reg} : 
                                                                       {1'd0,wstrb[6],strb_5_reg,strb_4_reg}) :

                    (( slv_b_wr_cur_state == SLV_WR_BYTE_8 ) & wlast ) ? (wrap_odd_xfer ? {wrap_strb_reg[3:1],wstrb[8]} : {3'd0,wstrb[8]}):
                    (( slv_b_wr_cur_state == SLV_WR_BYTE_9 ) & wlast ) ? (wrap_odd_xfer ? {wrap_strb_reg[3:2], wstrb[9],strb_8_reg} : 
                                                                       {2'd0,wstrb[9],strb_8_reg}):
                    (( slv_b_wr_cur_state == SLV_WR_BYTE_10 ) & wlast ) ? (wrap_odd_xfer ? {wrap_strb_reg[3],wstrb[10],strb_9_reg,strb_8_reg} : 
                                                                       {1'd0,wstrb[10],strb_9_reg,strb_8_reg}) :

                    (( slv_b_wr_cur_state == SLV_WR_BYTE_12 ) & wlast ) ? (wrap_odd_xfer ? {wrap_strb_reg[3:1],wstrb[12]} : {3'd0,wstrb[12]}):
                    (( slv_b_wr_cur_state == SLV_WR_BYTE_13 ) & wlast ) ? (wrap_odd_xfer ? {wrap_strb_reg[3:2], wstrb[13],strb_c_reg} : 
                                                                       {2'd0,wstrb[13],strb_c_reg}):
                    (( slv_b_wr_cur_state == SLV_WR_BYTE_14 ) & wlast ) ? (wrap_odd_xfer ? {wrap_strb_reg[3],wstrb[14],strb_d_reg,strb_c_reg} : 
                                                                       {1'd0,wstrb[14],strb_d_reg,strb_c_reg}) :'d0;

assign slv_b_wvalid = ((( slv_b_wr_cur_state == SLV_WR_BYTE_15) & wvalid) |
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_11) & wvalid) | 
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_7 ) & wvalid) | 
                      (( slv_b_wr_cur_state == SLV_WR_BYTE_3 ) & wvalid) | 
                      (( slv_b_wr_cur_state[5:4] == 2'b00) & wlast )) &&  (!wrap_1st_xfer) ; 

assign slv_b_wlast  = (( slv_b_wr_cur_state[5:4] == 2'b00) & wlast ) ; 


//===================================================================================
// SIZE 1 State machine ( 2 bytes write )
//===================================================================================


reg  [4:0] slv_hw_wr_cur_state;
reg  [4:0] slv_hw_wr_nxt_state;

localparam [4:0]  SLV_HW_WR_IDLE     = 5'h08;
localparam [4:0]  SLV_WR_HWORD_0     = 5'h00;
localparam [4:0]  SLV_WR_HWORD_1     = 5'h01;
localparam [4:0]  SLV_WR_HWORD_2     = 5'h02;
localparam [4:0]  SLV_WR_HWORD_3     = 5'h03;
localparam [4:0]  SLV_WR_HWORD_4     = 5'h04;
localparam [4:0]  SLV_WR_HWORD_5     = 5'h05;
localparam [4:0]  SLV_WR_HWORD_6     = 5'h06;
localparam [4:0]  SLV_WR_HWORD_7     = 5'h07;
localparam [4:0]  SLV_WR_HWORD_1_WAIT= 5'h10;
localparam [4:0]  SLV_WR_HWORD_2_WAIT= 5'h11;
localparam [4:0]  SLV_WR_HWORD_3_WAIT= 5'h12;
localparam [4:0]  SLV_WR_HWORD_4_WAIT= 5'h13;
localparam [4:0]  SLV_WR_HWORD_5_WAIT= 5'h14;
localparam [4:0]  SLV_WR_HWORD_6_WAIT= 5'h15;
localparam [4:0]  SLV_WR_HWORD_7_WAIT= 5'h16;
localparam [4:0]  SLV_WR_HWORD_0_WAIT= 5'h17;

//===================================================================================


always @ (*)
begin
   case (slv_hw_wr_cur_state )
      SLV_HW_WR_IDLE :
      begin
         if ( slv_arb_wr_start_en_sig & ~wdata_ff_empty & (slv_awsize_sig == 3'd1) ) 
         begin
            nxt_wrap_1st_xfer = slv_awburst_sig==2'b10 && (|slv_arb_addr_sig[1:0]);
            if ( (slv_arb_addr_sig[3:1] == 3'b000)  )
               slv_hw_wr_nxt_state = SLV_WR_HWORD_0;
            else if ( (slv_arb_addr_sig[3:1] == 3'b001)  )
               slv_hw_wr_nxt_state = SLV_WR_HWORD_1;
            else if ( (slv_arb_addr_sig[3:1] == 3'b010)  )
               slv_hw_wr_nxt_state = SLV_WR_HWORD_2;
            else if ( (slv_arb_addr_sig[3:1] == 3'b011)  )
               slv_hw_wr_nxt_state = SLV_WR_HWORD_3;
            else if ( (slv_arb_addr_sig[3:1] == 3'b100)  )
               slv_hw_wr_nxt_state = SLV_WR_HWORD_4;
            else if ( (slv_arb_addr_sig[3:1] == 3'b101)  )
               slv_hw_wr_nxt_state = SLV_WR_HWORD_5;
            else if ( (slv_arb_addr_sig[3:1] == 3'b110)  )
               slv_hw_wr_nxt_state = SLV_WR_HWORD_6;
            else 
               slv_hw_wr_nxt_state = SLV_WR_HWORD_7;
         end
         else
            slv_hw_wr_nxt_state = SLV_HW_WR_IDLE ;
      end

      // HALF WORD 0
      SLV_WR_HWORD_0 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_hw_wr_nxt_state = SLV_HW_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_hw_wr_nxt_state = SLV_WR_HWORD_0;
         else if ( ~wlast & wdata_ff_empty ) 
            slv_hw_wr_nxt_state = SLV_WR_HWORD_1_WAIT;
         else 
            slv_hw_wr_nxt_state = SLV_WR_HWORD_1;
      end
      // HALF WORD 1 
      SLV_WR_HWORD_1 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_hw_wr_nxt_state = SLV_HW_WR_IDLE ;
         else if ( (slv_wdata_ready | wrap_1st_xfer) & ~wdata_ff_empty)
         begin
            slv_hw_wr_nxt_state = SLV_WR_HWORD_2;
            nxt_wrap_1st_xfer = 1'b0;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[31:16],hword_0_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[3:2],strb_10_reg } : wrap_strb_reg;
         end
         else if ( (slv_wdata_ready | wrap_1st_xfer) & wdata_ff_empty)
         begin
            nxt_wrap_1st_xfer = 1'b0;
            slv_hw_wr_nxt_state = SLV_WR_HWORD_2_WAIT;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[31:16],hword_0_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[3:2],strb_10_reg } : wrap_strb_reg;
         end
         else 
            slv_hw_wr_nxt_state = SLV_WR_HWORD_1;
      end
      // HALF WORD 2 
      SLV_WR_HWORD_2 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_hw_wr_nxt_state = SLV_HW_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready ) 
            slv_hw_wr_nxt_state = SLV_WR_HWORD_2;
         else if ( ~wlast & wdata_ff_empty  )
            slv_hw_wr_nxt_state = SLV_WR_HWORD_3_WAIT;
         else    
            slv_hw_wr_nxt_state = SLV_WR_HWORD_3;
      end
      // HALF WORD 3 
      SLV_WR_HWORD_3 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_hw_wr_nxt_state = SLV_HW_WR_IDLE ;
         else if ( (slv_wdata_ready | wrap_1st_xfer) & ~wdata_ff_empty)
         begin
            slv_hw_wr_nxt_state = SLV_WR_HWORD_4;
            nxt_wrap_1st_xfer = 1'b0;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[63:48],hword_2_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[7:6],strb_54_reg } : wrap_strb_reg;
         end
         else if ( (slv_wdata_ready | wrap_1st_xfer) & wdata_ff_empty)
         begin
            slv_hw_wr_nxt_state = SLV_WR_HWORD_4_WAIT;
            nxt_wrap_1st_xfer = 1'b0;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[63:48],hword_2_reg} : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[7:6],strb_54_reg } : wrap_strb_reg;
         end
         else    
            slv_hw_wr_nxt_state = SLV_WR_HWORD_3;
      end
      // HALF WORD 4 
      SLV_WR_HWORD_4 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_hw_wr_nxt_state = SLV_HW_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready )
            slv_hw_wr_nxt_state = SLV_WR_HWORD_4;
         else if ( ~wlast & wdata_ff_empty)
            slv_hw_wr_nxt_state = SLV_WR_HWORD_5_WAIT;
         else    
            slv_hw_wr_nxt_state = SLV_WR_HWORD_5;
      end
      // HALF WORD 5 
      SLV_WR_HWORD_5 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_hw_wr_nxt_state = SLV_HW_WR_IDLE ;
         else if ( (slv_wdata_ready | wrap_1st_xfer) & ~wdata_ff_empty)
         begin
            slv_hw_wr_nxt_state = SLV_WR_HWORD_6;
            nxt_wrap_1st_xfer = 1'b0;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[95:80],hword_4_reg}   : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[11:10],strb_98_reg } : wrap_strb_reg;
         end
         else if ( (slv_wdata_ready | wrap_1st_xfer) & wdata_ff_empty)
         begin
            slv_hw_wr_nxt_state = SLV_WR_HWORD_6_WAIT;
            nxt_wrap_1st_xfer = 1'b0;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[95:80],hword_4_reg}   : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[11:10],strb_98_reg } : wrap_strb_reg;
         end
         else    
            slv_hw_wr_nxt_state = SLV_WR_HWORD_5;
      end
      // HALF WORD 6 
      SLV_WR_HWORD_6 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_hw_wr_nxt_state = SLV_HW_WR_IDLE ;
         else if ( wlast & ~slv_wdata_ready )
            slv_hw_wr_nxt_state = SLV_WR_HWORD_6;
         else if ( ~wlast & wdata_ff_empty)
            slv_hw_wr_nxt_state = SLV_WR_HWORD_7_WAIT;
         else    
            slv_hw_wr_nxt_state = SLV_WR_HWORD_7;
      end
      // HALF WORD 7 
      SLV_WR_HWORD_7 :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_hw_wr_nxt_state = SLV_HW_WR_IDLE ;
         else if ( (slv_wdata_ready | wrap_1st_xfer) & ~wdata_ff_empty)
         begin
            slv_hw_wr_nxt_state = SLV_WR_HWORD_0;
            nxt_wrap_1st_xfer = 1'b0;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[127:112],hword_6_reg}   : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[15:14],strb_1312_reg } : wrap_strb_reg;
         end
         else if ( (slv_wdata_ready | wrap_1st_xfer) & wdata_ff_empty)
         begin
            slv_hw_wr_nxt_state = SLV_WR_HWORD_0_WAIT;
            nxt_wrap_1st_xfer = 1'b0;
            nxt_wrap_data_reg = wrap_1st_xfer ? {wdata[127:112],hword_6_reg}   : wrap_data_reg;
            nxt_wrap_strb_reg = wrap_1st_xfer ? { wstrb[15:14],strb_1312_reg } : wrap_strb_reg;
         end
         else    
            slv_hw_wr_nxt_state = SLV_WR_HWORD_7;
      end
      // HALF WORD 1 WAIT
      SLV_WR_HWORD_1_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_hw_wr_nxt_state = SLV_WR_HWORD_1_WAIT;
         else
            slv_hw_wr_nxt_state = SLV_WR_HWORD_1;
      end
      // HALF WORD 2 WAIT
      SLV_WR_HWORD_2_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_hw_wr_nxt_state = SLV_WR_HWORD_2_WAIT;
         else
            slv_hw_wr_nxt_state = SLV_WR_HWORD_2;
      end
      // HALF WORD 3 WAIT
      SLV_WR_HWORD_3_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_hw_wr_nxt_state = SLV_WR_HWORD_3_WAIT;
         else
            slv_hw_wr_nxt_state = SLV_WR_HWORD_3;
      end
      // HALF WORD 4 WAIT
      SLV_WR_HWORD_4_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_hw_wr_nxt_state = SLV_WR_HWORD_4_WAIT;
         else
            slv_hw_wr_nxt_state = SLV_WR_HWORD_4;
      end
      // HALF WORD 5 WAIT
      SLV_WR_HWORD_5_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_hw_wr_nxt_state = SLV_WR_HWORD_5_WAIT;
         else
            slv_hw_wr_nxt_state = SLV_WR_HWORD_5;
      end
      // HALF WORD 6 WAIT
      SLV_WR_HWORD_6_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_hw_wr_nxt_state = SLV_WR_HWORD_6_WAIT;
         else
            slv_hw_wr_nxt_state = SLV_WR_HWORD_6;
      end
      // HALF WORD 7 WAIT
      SLV_WR_HWORD_7_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_hw_wr_nxt_state = SLV_WR_HWORD_7_WAIT;
         else
            slv_hw_wr_nxt_state = SLV_WR_HWORD_7;
      end
      // HALF WORD 0 WAIT
      SLV_WR_HWORD_0_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_hw_wr_nxt_state = SLV_WR_HWORD_0_WAIT;
         else
            slv_hw_wr_nxt_state = SLV_WR_HWORD_0;
      end
      default :
      begin
         slv_hw_wr_nxt_state = SLV_HW_WR_IDLE ;
      end
   endcase
end

always @ ( posedge mem_clk or negedge mem_rst_n )
begin
   if ( ~mem_rst_n )
   begin
      slv_hw_wr_cur_state <= SLV_HW_WR_IDLE; 
      hword_0_reg      <= 'd0;
      hword_1_reg      <= 'd0;
      hword_2_reg      <= 'd0;
      hword_3_reg      <= 'd0;
      hword_4_reg      <= 'd0;
      hword_5_reg      <= 'd0;
      hword_6_reg      <= 'd0;
      strb_10_reg      <= 'd0;
      strb_32_reg      <= 'd0;
      strb_54_reg      <= 'd0;
      strb_76_reg      <= 'd0;
      strb_98_reg      <= 'd0;
      strb_1110_reg    <= 'd0;
      strb_1312_reg    <= 'd0;
      slv_hw_sel_en    <= 1'b0;
   end
   else
   begin
      slv_hw_wr_cur_state <= slv_hw_wr_nxt_state; 

      if ( (slv_hw_wr_cur_state == SLV_WR_HWORD_0 ) & rdata_valid )
      begin
         hword_0_reg <= wdata[15:0]; 
         strb_10_reg <= wstrb[1:0]; 
      end
      else if ( slv_hw_wr_cur_state == SLV_HW_WR_IDLE )
      begin
         hword_0_reg <= 'd0; 
         strb_10_reg <= 'd0; 
      end

      if ( (slv_hw_wr_cur_state == SLV_WR_HWORD_1 ) & rdata_valid )
      begin
         hword_1_reg <= wdata[31:16]; 
         strb_32_reg <= wstrb[3:2]; 
      end
      else if ( slv_hw_wr_cur_state == SLV_HW_WR_IDLE )
      begin
         hword_1_reg <= 'd0; 
         strb_32_reg <= 'd0; 
      end

      if ( (slv_hw_wr_cur_state == SLV_WR_HWORD_2 ) & rdata_valid )
      begin
         hword_2_reg <= wdata[47:32]; 
         strb_54_reg <= wstrb[5:4]; 
      end
      else if ( slv_hw_wr_cur_state == SLV_HW_WR_IDLE )
      begin
         hword_2_reg <= 'd0; 
         strb_54_reg <= 'd0; 
      end

      if ( (slv_hw_wr_cur_state == SLV_WR_HWORD_3 ) & rdata_valid )
      begin
         hword_3_reg <= wdata[63:48]; 
         strb_76_reg <= wstrb[7:6]; 
      end
      else if ( slv_hw_wr_cur_state == SLV_HW_WR_IDLE )
      begin
         hword_3_reg <= 'd0; 
         strb_76_reg <= 'd0; 
      end

      if ( (slv_hw_wr_cur_state == SLV_WR_HWORD_4 ) & rdata_valid )
      begin
         hword_4_reg <= wdata[79:64]; 
         strb_98_reg <= wstrb[9:8]; 
      end
      else if ( slv_hw_wr_cur_state == SLV_HW_WR_IDLE )
      begin
         hword_4_reg <= 'd0; 
         strb_98_reg <= 'd0; 
      end

      if ( (slv_hw_wr_cur_state == SLV_WR_HWORD_5 ) & rdata_valid )
      begin
         hword_5_reg   <= wdata[95:80]; 
         strb_1110_reg <= wstrb[9:8]; 
      end
      else if ( slv_hw_wr_cur_state == SLV_HW_WR_IDLE )
      begin
         hword_5_reg   <= 'd0; 
         strb_1110_reg <= 'd0; 
      end

      if ( (slv_hw_wr_cur_state == SLV_WR_HWORD_6 ) & rdata_valid )
      begin
         hword_6_reg   <= wdata[111:96]; 
         strb_1312_reg <= wstrb[13:12]; 
      end
      else if ( slv_hw_wr_cur_state == SLV_HW_WR_IDLE )
      begin
         hword_6_reg   <= 'd0; 
         strb_1312_reg <= 'd0; 
      end

      if ( ( slv_hw_wr_cur_state == SLV_HW_WR_IDLE  ) & slv_arb_wr_start_en_sig & (slv_awsize_sig == 3'd1) )
         slv_hw_sel_en  <= 1'b1;
      else if ( wlast & slv_wdata_ready )
         slv_hw_sel_en  <= 1'b0;

   end
end

assign wdata_hw_ff_rd_en = ( ~wdata_ff_empty & ( (( slv_hw_wr_cur_state == SLV_HW_WR_IDLE  ) & slv_arb_wr_start_en_sig & (slv_awsize_sig == 3'd1) ) | 
                                                 (( slv_hw_wr_cur_state == SLV_WR_HWORD_0)& ~wlast )| 
                                                 (( slv_hw_wr_cur_state == SLV_WR_HWORD_1)& ~wlast & (slv_wdata_ready | wrap_1st_xfer)) |
                                                 (( slv_hw_wr_cur_state == SLV_WR_HWORD_2)& ~wlast )|
                                                 (( slv_hw_wr_cur_state == SLV_WR_HWORD_3)& ~wlast & (slv_wdata_ready | wrap_1st_xfer)) |
                                                 (( slv_hw_wr_cur_state == SLV_WR_HWORD_4)& ~wlast )|
                                                 (( slv_hw_wr_cur_state == SLV_WR_HWORD_5)& ~wlast & (slv_wdata_ready | wrap_1st_xfer)) |
                                                 (( slv_hw_wr_cur_state == SLV_WR_HWORD_6)& ~wlast )|
                                                 (( slv_hw_wr_cur_state == SLV_WR_HWORD_7)& ~wlast & (slv_wdata_ready | wrap_1st_xfer)) |
                                                  ( slv_hw_wr_cur_state[4] ) ) );
 
assign slv_hw_wdata  = (( slv_hw_wr_cur_state == SLV_WR_HWORD_7  ) ) ? { wdata[127:112],hword_6_reg } : 
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_5  ) ) ? { wdata[95:80],hword_4_reg }   :
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_3  ) ) ? { wdata[63:48],hword_2_reg }   :
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_1  ) ) ? { wdata[31:16],hword_0_reg }   :
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_0  ) & wlast ) ? {wrap_data_reg[31:16],wdata[15:0]}   : 
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_2  ) & wlast ) ? {wrap_data_reg[31:16],wdata[47:32]}  : 
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_4  ) & wlast ) ? {wrap_data_reg[31:16],wdata[79:64]}  : 
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_6  ) & wlast ) ? {wrap_data_reg[31:16],wdata[111:96]} : 'd0 ; 


assign slv_hw_wstrb  = (( slv_hw_wr_cur_state == SLV_WR_HWORD_7) ) ? { wstrb[15:14],strb_1312_reg } :
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_5) ) ? { wstrb[11:10],strb_98_reg } :
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_3) ) ? { wstrb[7:6],strb_54_reg } :
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_1) ) ? { wstrb[3:2],strb_10_reg } :
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_0) & wlast ) ? ( wrap_odd_xfer ? { wrap_strb_reg[3:2], wstrb[1:0]} :{ 2'd0,wstrb[1:0]}): 
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_2) & wlast ) ? ( wrap_odd_xfer ? { wrap_strb_reg[3:2], wstrb[5:4]} :{2'd0,wstrb[5:4]}) : 
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_4) & wlast ) ? ( wrap_odd_xfer ? { wrap_strb_reg[3:2], wstrb[9:8]} :{2'd0,wstrb[9:8]} ): 
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_6) & wlast ) ? ( wrap_odd_xfer ? { wrap_strb_reg[3:2], wstrb[13:12]} :{2'd0,wstrb[13:12]}) : 'd0; 

assign slv_hw_wvalid = ((( slv_hw_wr_cur_state == SLV_WR_HWORD_7) & wvalid) |
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_5) & wvalid) | 
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_3) & wvalid) | 
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_1) & wvalid) | 
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_0) & wlast ) |
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_2) & wlast ) |
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_4) & wlast ) |
                       (( slv_hw_wr_cur_state == SLV_WR_HWORD_6) & wlast )) & (!wrap_1st_xfer)  ; 

assign slv_hw_wlast  = ( (slv_hw_wr_cur_state[4:3] == 2'b00)  & wlast) ; 
                  
                    
//===================================================================================
// SIZE 2 State machine ( 4 bytes write )
//===================================================================================
                    
reg  [3:0] slv_w_wr_cur_state;
reg  [3:0] slv_w_wr_nxt_state;

localparam [3:0]  SLV_W_WR_IDLE      = 4'h8;
localparam [3:0]  SLV_WR_WORD_0      = 4'h0;
localparam [3:0]  SLV_WR_WORD_1      = 4'h1;
localparam [3:0]  SLV_WR_WORD_2      = 4'h2;
localparam [3:0]  SLV_WR_WORD_3      = 4'h3;
localparam [3:0]  SLV_WR_WORD_1_WAIT = 4'h4;
localparam [3:0]  SLV_WR_WORD_2_WAIT = 4'h5;
localparam [3:0]  SLV_WR_WORD_3_WAIT = 4'h6;
localparam [3:0]  SLV_WR_WORD_0_WAIT = 4'h7;

//===================================================================================


always @ (*)
begin
   case (slv_w_wr_cur_state )
      SLV_W_WR_IDLE :
      begin
         if ( slv_arb_wr_start_en_sig & ~wdata_ff_empty & (slv_awsize_sig == 3'd2) ) 
         begin
            if ( (slv_arb_addr_sig[3:2] == 2'b00) ) 
               slv_w_wr_nxt_state = SLV_WR_WORD_0 ;
            else if ( (slv_arb_addr_sig[3:2] == 2'b01) )
               slv_w_wr_nxt_state = SLV_WR_WORD_1 ;
            else if ( (slv_arb_addr_sig[3:2] == 2'b10) )
               slv_w_wr_nxt_state = SLV_WR_WORD_2 ;
            else 
               slv_w_wr_nxt_state = SLV_WR_WORD_3 ;
         end
         else
            slv_w_wr_nxt_state = SLV_W_WR_IDLE ;
      end
                    
      // WORD 0 
      SLV_WR_WORD_0  :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_w_wr_nxt_state = SLV_W_WR_IDLE ;
         else if ( slv_wdata_ready & ~wdata_ff_empty ) 
            slv_w_wr_nxt_state = SLV_WR_WORD_1;
         else if (  wdata_ff_empty  & slv_wdata_ready )
            slv_w_wr_nxt_state = SLV_WR_WORD_1_WAIT;
         else
            slv_w_wr_nxt_state = SLV_WR_WORD_0;
      end
      // WORD 1 
      SLV_WR_WORD_1  :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_w_wr_nxt_state = SLV_W_WR_IDLE ;
         else if ( slv_wdata_ready & ~wdata_ff_empty )
            slv_w_wr_nxt_state = SLV_WR_WORD_2;
         else if ( slv_wdata_ready & wdata_ff_empty )
            slv_w_wr_nxt_state = SLV_WR_WORD_2_WAIT;
         else
            slv_w_wr_nxt_state = SLV_WR_WORD_1;
      end
      // WORD 2 
      SLV_WR_WORD_2  :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_w_wr_nxt_state = SLV_W_WR_IDLE ;
         else if ( slv_wdata_ready & ~wdata_ff_empty )
            slv_w_wr_nxt_state = SLV_WR_WORD_3;
         else if ( slv_wdata_ready & wdata_ff_empty )
            slv_w_wr_nxt_state = SLV_WR_WORD_3_WAIT;
         else
            slv_w_wr_nxt_state = SLV_WR_WORD_2;
      end
      // WORD 3 
      SLV_WR_WORD_3  :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_w_wr_nxt_state = SLV_W_WR_IDLE ;
         else if ( slv_wdata_ready & ~wdata_ff_empty )
            slv_w_wr_nxt_state = SLV_WR_WORD_0;
         else if ( slv_wdata_ready & wdata_ff_empty )
            slv_w_wr_nxt_state = SLV_WR_WORD_0_WAIT;
         else
            slv_w_wr_nxt_state = SLV_WR_WORD_3;
      end

      // WORD 1 WAIT
      SLV_WR_WORD_1_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_w_wr_nxt_state = SLV_WR_WORD_1_WAIT;
         else
            slv_w_wr_nxt_state = SLV_WR_WORD_1;
      end
      // WORD 2 WAIT
      SLV_WR_WORD_2_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_w_wr_nxt_state = SLV_WR_WORD_2_WAIT;
         else
            slv_w_wr_nxt_state = SLV_WR_WORD_2;
      end
      // WORD 3 WAIT
      SLV_WR_WORD_3_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_w_wr_nxt_state = SLV_WR_WORD_3_WAIT;
         else
            slv_w_wr_nxt_state = SLV_WR_WORD_3;
      end
      // WORD 0 WAIT
      SLV_WR_WORD_0_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_w_wr_nxt_state = SLV_WR_WORD_0_WAIT;
         else
            slv_w_wr_nxt_state = SLV_WR_WORD_0;
      end
      default :
      begin
         slv_w_wr_nxt_state = SLV_HW_WR_IDLE ;
      end
   endcase
end

always @ ( posedge mem_clk or negedge mem_rst_n )
begin
   if ( ~mem_rst_n )
   begin
      slv_w_wr_cur_state <= SLV_W_WR_IDLE; 
      slv_w_sel_en       <= 1'b0;
   end
   else
   begin
      slv_w_wr_cur_state <= slv_w_wr_nxt_state; 
      if ( ( slv_w_wr_cur_state == SLV_W_WR_IDLE  ) & slv_arb_wr_start_en_sig & (slv_awsize_sig == 3'd2) )
         slv_w_sel_en  <= 1'b1;
      else if ( wlast & slv_wdata_ready )
         slv_w_sel_en  <= 1'b0;
   end
end

assign wdata_w_ff_rd_en = ( ~wdata_ff_empty & ( (( slv_w_wr_cur_state == SLV_W_WR_IDLE  ) & slv_arb_wr_start_en_sig & (slv_awsize_sig == 3'd2)) | 
                                                (( slv_w_wr_cur_state == SLV_WR_WORD_0) & ~wlast & slv_wdata_ready) | 
                                                (( slv_w_wr_cur_state == SLV_WR_WORD_1) & ~wlast & slv_wdata_ready) | 
                                                (( slv_w_wr_cur_state == SLV_WR_WORD_2) & ~wlast & slv_wdata_ready) | 
                                                (( slv_w_wr_cur_state == SLV_WR_WORD_3) & ~wlast & slv_wdata_ready) | 
                                                 ( slv_w_wr_cur_state[2] ) ) ); 
 
assign slv_w_wdata  = (( slv_w_wr_cur_state == SLV_WR_WORD_3   ) ) ? { wdata[127:96]} : 
                      (( slv_w_wr_cur_state == SLV_WR_WORD_2   ) ) ? { wdata[ 95:64]} :
                      (( slv_w_wr_cur_state == SLV_WR_WORD_1   ) ) ? { wdata[ 63:32]} :
                      (( slv_w_wr_cur_state == SLV_WR_WORD_0   ) ) ? { wdata[ 31: 0]} : 'd0;


assign slv_w_wstrb  = (( slv_w_wr_cur_state == SLV_WR_WORD_3 ) ) ? { wstrb[15:12]} :
                      (( slv_w_wr_cur_state == SLV_WR_WORD_2 ) ) ? { wstrb[11: 8]} :
                      (( slv_w_wr_cur_state == SLV_WR_WORD_1 ) ) ? { wstrb[ 7: 4]} :
                      (( slv_w_wr_cur_state == SLV_WR_WORD_0 ) ) ? { wstrb[ 3: 0]} : 'd0 ; 

assign slv_w_wvalid = (( slv_w_wr_cur_state == SLV_WR_WORD_3 ) ) | 
                      (( slv_w_wr_cur_state == SLV_WR_WORD_2 ) ) | 
                      (( slv_w_wr_cur_state == SLV_WR_WORD_1 ) ) | 
                      (( slv_w_wr_cur_state == SLV_WR_WORD_0 ) ) ;

assign slv_w_wlast  = (( slv_w_wr_cur_state == SLV_WR_WORD_3 ) & wlast ) |
                      (( slv_w_wr_cur_state == SLV_WR_WORD_2 ) & wlast ) | 
                      (( slv_w_wr_cur_state == SLV_WR_WORD_1 ) & wlast ) | 
                      (( slv_w_wr_cur_state == SLV_WR_WORD_0 ) & wlast ) ; 


//===================================================================================
// SIZE 3 and 4  State machine ( 64 bits and 128bits )
//===================================================================================


reg  [3:0] slv_dq_wr_cur_state;
reg  [3:0] slv_dq_wr_nxt_state;

localparam [3:0]  SLV_DQ_WR_IDLE     = 4'h0;
localparam [3:0]  SLV_WR_DWORD_W0    = 4'h1;
localparam [3:0]  SLV_WR_DWORD_W1    = 4'h2;
localparam [3:0]  SLV_WR_DWORD_W2    = 4'h3;
localparam [3:0]  SLV_WR_DWORD_W3    = 4'h4;
localparam [3:0]  SLV_WR_QWORD_W0    = 4'h5;
localparam [3:0]  SLV_WR_QWORD_W1    = 4'h6;
localparam [3:0]  SLV_WR_QWORD_W2    = 4'h7;
localparam [3:0]  SLV_WR_QWORD_W3    = 4'h8;
localparam [3:0]  SLV_WR_DWORD_2_WAIT= 4'h9;
localparam [3:0]  SLV_WR_DWORD_0_WAIT= 4'hA;
localparam [3:0]  SLV_WR_QWORD_0_WAIT= 4'hB;

//===================================================================================


always @ (*)
begin
   case (slv_dq_wr_cur_state )
      SLV_DQ_WR_IDLE :
      begin
         if ( slv_arb_wr_start_en_sig & ~wdata_ff_empty & (slv_awsize_sig == 3'd3) ) 
         begin
            if ( (slv_arb_addr_sig[3:2] == 2'b00) ) 
               slv_dq_wr_nxt_state = SLV_WR_DWORD_W0 ;
            else if ( (slv_arb_addr_sig[3:2] == 2'b01) )
               slv_dq_wr_nxt_state = SLV_WR_DWORD_W1 ;
            else if ( (slv_arb_addr_sig[3:2] == 2'b10) )
               slv_dq_wr_nxt_state = SLV_WR_DWORD_W2 ;
            else
               slv_dq_wr_nxt_state = SLV_WR_DWORD_W3 ;
         end
         else if ( slv_arb_wr_start_en_sig & ~wdata_ff_empty & (slv_awsize_sig == 3'd4) )
         begin
            if ( (slv_arb_addr_sig[3:2] == 2'b00) ) 
               slv_dq_wr_nxt_state = SLV_WR_QWORD_W0 ;
            else if ( (slv_arb_addr_sig[3:2] == 2'b01) )
               slv_dq_wr_nxt_state = SLV_WR_QWORD_W1 ;
            else if ( (slv_arb_addr_sig[3:2] == 2'b10) )
               slv_dq_wr_nxt_state = SLV_WR_QWORD_W2 ;
            else
               slv_dq_wr_nxt_state = SLV_WR_QWORD_W3 ;
         end
         else
            slv_dq_wr_nxt_state = SLV_DQ_WR_IDLE ;
      end
      
      // DWORD  

      SLV_WR_DWORD_W0  :
      begin
         //if ( slv_wdata_ready ) 
         //   slv_dq_wr_nxt_state = SLV_WR_DWORD_W1;
         //else
         //   slv_dq_wr_nxt_state = SLV_WR_DWORD_W0;
         if ( wlast & slv_wdata_ready & (!(&wstrb[3:0]))) 
            slv_dq_wr_nxt_state = SLV_DQ_WR_IDLE;
         else if ( slv_wdata_ready)
            slv_dq_wr_nxt_state = SLV_WR_DWORD_W1;
         else
            slv_dq_wr_nxt_state = SLV_WR_DWORD_W0;
      end

      SLV_WR_DWORD_W1  :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_dq_wr_nxt_state = SLV_DQ_WR_IDLE;
         else if ( slv_wdata_ready & ~wdata_ff_empty )
            slv_dq_wr_nxt_state = SLV_WR_DWORD_W2;
         else if ( slv_wdata_ready & wdata_ff_empty )
            slv_dq_wr_nxt_state = SLV_WR_DWORD_2_WAIT;
         else
            slv_dq_wr_nxt_state = SLV_WR_DWORD_W1;
      end

      SLV_WR_DWORD_W2  :
      begin
         //if ( slv_wdata_ready ) 
         //   slv_dq_wr_nxt_state = SLV_WR_DWORD_W3;
         //else
         //   slv_dq_wr_nxt_state = SLV_WR_DWORD_W2;
         if ( wlast & slv_wdata_ready & (!(&wstrb[11:8]))) 
            slv_dq_wr_nxt_state = SLV_DQ_WR_IDLE;
         else if ( slv_wdata_ready)
            slv_dq_wr_nxt_state = SLV_WR_DWORD_W3;
         else
            slv_dq_wr_nxt_state = SLV_WR_DWORD_W2;
      end

      SLV_WR_DWORD_W3  :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_dq_wr_nxt_state = SLV_DQ_WR_IDLE;
         else if ( slv_wdata_ready & ~wdata_ff_empty )
            slv_dq_wr_nxt_state = SLV_WR_DWORD_W0;
         else if ( slv_wdata_ready & wdata_ff_empty )
            slv_dq_wr_nxt_state = SLV_WR_DWORD_0_WAIT;
         else
            slv_dq_wr_nxt_state = SLV_WR_DWORD_W3;
      end

      // QWORD 

      SLV_WR_QWORD_W0  :
      begin
         if ( wlast & slv_wdata_ready & (!(&wstrb[3:0]))) 
            slv_dq_wr_nxt_state = SLV_DQ_WR_IDLE;
         else if ( slv_wdata_ready)
            slv_dq_wr_nxt_state = SLV_WR_QWORD_W1;
         else
            slv_dq_wr_nxt_state = SLV_WR_QWORD_W0;
      end

      SLV_WR_QWORD_W1  :
      begin
         if ( wlast & slv_wdata_ready & (!(&wstrb[7:4]))) 
            slv_dq_wr_nxt_state = SLV_DQ_WR_IDLE;
         else if ( slv_wdata_ready)
            slv_dq_wr_nxt_state = SLV_WR_QWORD_W2;
         else
            slv_dq_wr_nxt_state = SLV_WR_QWORD_W1;
      end

      SLV_WR_QWORD_W2  :
      begin
         if ( wlast & slv_wdata_ready & (!(&wstrb[11:8]))) 
            slv_dq_wr_nxt_state = SLV_DQ_WR_IDLE;
         else if ( slv_wdata_ready)
            slv_dq_wr_nxt_state = SLV_WR_QWORD_W3;
         else
            slv_dq_wr_nxt_state = SLV_WR_QWORD_W2;
      end

      SLV_WR_QWORD_W3  :
      begin
         if ( wlast & slv_wdata_ready ) 
            slv_dq_wr_nxt_state = SLV_DQ_WR_IDLE;
         else if ( slv_wdata_ready & ~wdata_ff_empty )
            slv_dq_wr_nxt_state = SLV_WR_QWORD_W0;
         else if ( slv_wdata_ready & wdata_ff_empty )
            slv_dq_wr_nxt_state = SLV_WR_QWORD_0_WAIT;
         else
            slv_dq_wr_nxt_state = SLV_WR_QWORD_W3;
      end

      // DWORD WAIT
      SLV_WR_DWORD_2_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_dq_wr_nxt_state = SLV_WR_DWORD_2_WAIT;
         else
            slv_dq_wr_nxt_state = SLV_WR_DWORD_W2;
      end

      SLV_WR_DWORD_0_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_dq_wr_nxt_state = SLV_WR_DWORD_0_WAIT;
         else
            slv_dq_wr_nxt_state = SLV_WR_DWORD_W0;
      end

      // QWORD WAIT 
      SLV_WR_QWORD_0_WAIT :
      begin
         if ( wdata_ff_empty ) 
            slv_dq_wr_nxt_state = SLV_WR_QWORD_0_WAIT;
         else
            slv_dq_wr_nxt_state = SLV_WR_QWORD_W0;
      end
      default :
      begin
         slv_dq_wr_nxt_state = SLV_DQ_WR_IDLE ;
      end
   endcase
end

always @ ( posedge mem_clk or negedge mem_rst_n )
begin
   if ( ~mem_rst_n )
   begin
      slv_dq_wr_cur_state <= SLV_DQ_WR_IDLE; 
      slv_dq_sel_en       <= 1'b0;
   end
   else
   begin
      slv_dq_wr_cur_state <= slv_dq_wr_nxt_state; 
      if (( slv_dq_wr_cur_state == SLV_DQ_WR_IDLE  ) & slv_arb_wr_start_en_sig & (slv_awsize_sig == 3'b011 ) | slv_awsize_sig[2] )  
         slv_dq_sel_en  <= 1'b1;
      else if ( wlast & ( slv_dq_wr_cur_state == SLV_DQ_WR_IDLE  ) )
         slv_dq_sel_en  <= 1'b0;
   end
end


assign wdata_dq_ff_rd_en = (~wdata_ff_empty & (((slv_dq_wr_cur_state == SLV_DQ_WR_IDLE  ) & slv_arb_wr_start_en_sig & 
                                                                        ((slv_awsize_sig == 3'b011 ) | slv_awsize_sig[2] )) | 
                                              (( slv_dq_wr_cur_state == SLV_WR_DWORD_W1) & ~wlast & slv_wdata_ready)  | 
                                              (( slv_dq_wr_cur_state == SLV_WR_DWORD_W3) & ~wlast & slv_wdata_ready)  | 
                                              (( slv_dq_wr_cur_state == SLV_WR_QWORD_W3) & ~wlast & slv_wdata_ready)  | 
                                               ( slv_dq_wr_cur_state == SLV_WR_DWORD_0_WAIT  ) |  
                                               ( slv_dq_wr_cur_state == SLV_WR_DWORD_2_WAIT  ) | 
                                               ( slv_dq_wr_cur_state == SLV_WR_QWORD_0_WAIT  ) ) );
 
assign slv_dq_wdata  = (( slv_dq_wr_cur_state == SLV_WR_DWORD_W0 ) ) ? { wdata[31:0]}   :
                       (( slv_dq_wr_cur_state == SLV_WR_DWORD_W1 ) ) ? { wdata[63:32]}  :
                       (( slv_dq_wr_cur_state == SLV_WR_DWORD_W2 ) ) ? { wdata[95:64]}  :
                       (( slv_dq_wr_cur_state == SLV_WR_DWORD_W3 ) ) ? { wdata[127:96]} :
                       (( slv_dq_wr_cur_state == SLV_WR_QWORD_W0 ) ) ? { wdata[31:0]}   :
                       (( slv_dq_wr_cur_state == SLV_WR_QWORD_W1 ) ) ? { wdata[63:32]}  :
                       (( slv_dq_wr_cur_state == SLV_WR_QWORD_W2 ) ) ? { wdata[95:64]}  :
                       (( slv_dq_wr_cur_state == SLV_WR_QWORD_W3 ) ) ? { wdata[127:96]} : 'd0;

assign slv_dq_wstrb  = (( slv_dq_wr_cur_state == SLV_WR_DWORD_W0 ) ) ? { wstrb[3:0]}   :
                       (( slv_dq_wr_cur_state == SLV_WR_DWORD_W1 ) ) ? { wstrb[7:4]}  :
                       (( slv_dq_wr_cur_state == SLV_WR_DWORD_W2 ) ) ? { wstrb[11:8]}  :
                       (( slv_dq_wr_cur_state == SLV_WR_DWORD_W3 ) ) ? { wstrb[15:12]} :
                       (( slv_dq_wr_cur_state == SLV_WR_QWORD_W0 ) ) ? { wstrb[3:0]}   :
                       (( slv_dq_wr_cur_state == SLV_WR_QWORD_W1 ) ) ? { wstrb[7:4]}  :
                       (( slv_dq_wr_cur_state == SLV_WR_QWORD_W2 ) ) ? { wstrb[11:8]}  :
                       (( slv_dq_wr_cur_state == SLV_WR_QWORD_W3 ) ) ? { wstrb[15:12]} : 'd0;

assign slv_dq_wvalid = (( slv_dq_wr_cur_state == SLV_WR_DWORD_W0 ) ) | 
                       (( slv_dq_wr_cur_state == SLV_WR_DWORD_W1 ) ) | 
                       (( slv_dq_wr_cur_state == SLV_WR_DWORD_W2 ) ) | 
                       (( slv_dq_wr_cur_state == SLV_WR_DWORD_W3 ) ) | 
                       (( slv_dq_wr_cur_state == SLV_WR_QWORD_W0 ) ) | 
                       (( slv_dq_wr_cur_state == SLV_WR_QWORD_W1 ) ) | 
                       (( slv_dq_wr_cur_state == SLV_WR_QWORD_W2 ) ) | 
                       (( slv_dq_wr_cur_state == SLV_WR_QWORD_W3 ) ) ; 


assign slv_dq_wlast  = (( slv_dq_wr_cur_state == SLV_WR_DWORD_W0 ) & wlast & (!(&wstrb[3:0]))) |  
                       (( slv_dq_wr_cur_state == SLV_WR_DWORD_W1 ) & wlast ) |  
                       (( slv_dq_wr_cur_state == SLV_WR_DWORD_W2 ) & wlast & (!(&wstrb[11:8]))) |  
                       (( slv_dq_wr_cur_state == SLV_WR_DWORD_W3 ) & wlast ) |  
                       (( slv_dq_wr_cur_state == SLV_WR_QWORD_W0 ) & wlast & (!(&wstrb[3:0]))) |
                       (( slv_dq_wr_cur_state == SLV_WR_QWORD_W1 ) & wlast & (!(&wstrb[7:4]))) |
                       (( slv_dq_wr_cur_state == SLV_WR_QWORD_W2 ) & wlast & (!(&wstrb[11:8]))) |
                       (( slv_dq_wr_cur_state == SLV_WR_QWORD_W3 ) & wlast ) ;


//===================================================================================


assign wdata_ff_rd_en = wdata_dq_ff_rd_en | wdata_w_ff_rd_en | wdata_hw_ff_rd_en | wdata_b_ff_rd_en;

always @ ( posedge mem_clk or negedge mem_rst_n )
begin
   if ( ~mem_rst_n )
   begin
   slv_wdata <= 32'd0;
   slv_wstrb <= 4'd0;
   slv_wvalid <= 1'b0;
   slv_wlast <= 1'b0;
   end
   else
   begin

   slv_wdata  <= ( slv_b_sel_en  ) ? slv_b_wdata :
                    ( slv_hw_sel_en ) ? slv_hw_wdata :
                    ( slv_w_sel_en  ) ? slv_w_wdata :
                    ( slv_dq_sel_en ) ? slv_dq_wdata : 'd0; 

   slv_wstrb  <= ( slv_b_sel_en  ) ? slv_b_wstrb :
                    ( slv_hw_sel_en ) ? slv_hw_wstrb :
                    ( slv_w_sel_en  ) ? slv_w_wstrb :
                    ( slv_dq_sel_en ) ? slv_dq_wstrb : 'd0;


   slv_wvalid <= (( slv_b_sel_en  ) ? slv_b_wvalid :
                    ( slv_hw_sel_en ) ? slv_hw_wvalid :
                    ( slv_w_sel_en  ) ? slv_w_wvalid :
                    ( slv_dq_sel_en ) ? slv_dq_wvalid : 1'b0) & !slv_wdata_ready;


   slv_wlast  <= ( slv_b_sel_en  ) ? slv_b_wlast :
                    ( slv_hw_sel_en ) ? slv_hw_wlast :
                    ( slv_w_sel_en  ) ? slv_w_wlast :
                    ( slv_dq_sel_en ) ? slv_dq_wlast : 1'b0;

   end

end   // SLV DATA WIDTH 128 END
end

endgenerate  // endgenerate 

endmodule // slv_wdata_ff 
