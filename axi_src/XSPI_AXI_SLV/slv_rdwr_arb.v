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
// AXI read address clock crossing interface,
//====================================================================================


`include "xspi_axi_slv.vh"

module slv_rdwr_arb  (

     mem_clk, 
     mem_rst_n,

//From CSR
     hybrid_wrap_cmd_en,
     hyperflash_en,
     mem_page_size,
     slv_araddr,
     slv_arvalid,
     slv_arsize,
     slv_arlen,
     slv_arburst,
     slv_arid, 
     slv_ar_err,
     slv_ar_cs_sel,
     slv_awaddr,
     slv_awvalid,
     slv_awsize,
     slv_awlen,
     slv_awburst,
     slv_awid, 
     slv_aw_err,
     slv_aw_cs_sel,

     slv_arb_addr,
     slv_arb_valid,
     slv_arb_write, 
     slv_arb_burst, 
     slv_arb_axi_len, 
     slv_arb_bytes_len,
     slv_arb_size,
     slv_arb_err,
     slv_arb_cs_sel,
     slv_arb_awid,
     slv_arb_arid, 
     slv_arb_ready,
     slv_arb_arready,
     slv_arb_awready,  
     slv_arb_wr_start_en,
     slv_mem_cont_rd_req,
     slv_mem_cont_wr_req
);

parameter SLV_AXI_ADDR_WIDTH = 32;
parameter SLV_AXI_ID_WIDTH   = 4;
parameter SLV_AXI_LEN_WIDTH  = 8;
parameter SLV_AXI_DATA_WIDTH = 32;
parameter SLV_MEM_LEN_WIDTH  = ( SLV_AXI_DATA_WIDTH == 32 ) ? 11 :
                               ( SLV_AXI_DATA_WIDTH == 64 ) ? 12 : 13 ;
parameter MEM_ADDR_WIDTH     = 30;
parameter XSPI_MEM_ADDR_WIDTH = 32;

localparam WRAP = 2'b10 ;

localparam CS_SEL_BITS = 1;
//localparam CS_SEL_BITS = SLV_AXI_ADDR_WIDTH-MEM_ADDR_WIDTH;

//*********************************INPUTS & OUTPUTS************************************

input                                  mem_clk;
input                                  mem_rst_n;

//From CSR
input                                  hybrid_wrap_cmd_en;
input				       hyperflash_en;
input [3:0]  mem_page_size;
input  [XSPI_MEM_ADDR_WIDTH-1:0 ]       slv_araddr;
input                                  slv_arvalid;
input  [2:0 ]                          slv_arsize;
input  [SLV_AXI_LEN_WIDTH-1 :0 ]       slv_arlen;
input  [1:0 ]                          slv_arburst;
input  [SLV_AXI_ID_WIDTH-1:0 ]         slv_arid;
input  [1:0]                     slv_ar_err;
input [ CS_SEL_BITS-1 : 0 ]            slv_ar_cs_sel;
output                                 slv_arb_arready;

input  [XSPI_MEM_ADDR_WIDTH-1:0 ]       slv_awaddr;
input                                  slv_awvalid;
input  [2:0 ]                          slv_awsize;
input  [SLV_AXI_LEN_WIDTH-1 :0 ]       slv_awlen;
input  [1:0 ]                          slv_awburst;
input  [SLV_AXI_ID_WIDTH-1:0 ]         slv_awid;
input  [1:0]                       slv_aw_err;
input [ CS_SEL_BITS-1 : 0 ]            slv_aw_cs_sel;
output                                 slv_arb_awready;

input                                  slv_arb_ready;

//===================================================================================

output  [XSPI_MEM_ADDR_WIDTH-1:0 ]                        slv_arb_addr;
output                                 slv_arb_valid;
output                                 slv_arb_write;
output  [SLV_AXI_LEN_WIDTH-1 :0 ]      slv_arb_axi_len;
output  [SLV_MEM_LEN_WIDTH-1 :0 ]      slv_arb_bytes_len;
output  [1:0 ]                         slv_arb_burst;
output  [2:0 ]                         slv_arb_size;
output                           slv_arb_err;
output [ CS_SEL_BITS-1 : 0 ]           slv_arb_cs_sel;

output  [SLV_AXI_ID_WIDTH-1:0 ]        slv_arb_arid;
output  [SLV_AXI_ID_WIDTH-1:0 ]        slv_arb_awid;
output                                 slv_arb_wr_start_en;
output                                 slv_mem_cont_rd_req;
output                                 slv_mem_cont_wr_req;

//===================================================================================

reg     [XSPI_MEM_ADDR_WIDTH-1:0 ]      slv_arb_addr;
reg                                    slv_arb_valid;
reg                                    slv_arb_write;
reg     [SLV_AXI_LEN_WIDTH-1 :0 ]      slv_arb_axi_len;
reg     [SLV_MEM_LEN_WIDTH-1 :0 ]      slv_arb_bytes_len;
reg     [1:0 ]                         slv_arb_burst;
reg     [2:0 ]                         slv_arb_size;
reg                             slv_arb_err; 
reg [ CS_SEL_BITS-1 : 0 ]              slv_arb_cs_sel;

reg     [SLV_AXI_ID_WIDTH-1:0 ]        slv_arb_arid;
reg     [SLV_AXI_ID_WIDTH-1:0 ]        slv_arb_awid;

reg                                    last_rd_sel;
reg                                    last_wr_sel;
reg     [XSPI_MEM_ADDR_WIDTH-1:0 ]      read_nxt_addr;
reg     [XSPI_MEM_ADDR_WIDTH-1:0 ]      write_nxt_addr;
reg     [XSPI_MEM_ADDR_WIDTH-1:0 ]      slv_awaddr_reg;

reg                                    slv_mem_cont_rd_req;
reg                                    slv_mem_cont_wr_req;


wire                                   slv_arb_arready;
wire                                   slv_arb_awready;

wire                                   cont_slv_wr_req;
wire                                   cont_slv_rd_req;

wire  [6:0]           			axi4_wrap_size;
reg  [6:0]           			axi4_wrap_size_reg;
reg [1:0] prev_aw_btype;
reg [1:0] prev_ar_btype;
wire  [SLV_AXI_LEN_WIDTH :0]           slv_awlen_nxt;
wire  [SLV_AXI_LEN_WIDTH :0]           slv_arlen_nxt;


wire     [XSPI_MEM_ADDR_WIDTH-1:0 ]     read_nxt_addr_sig;
reg     [XSPI_MEM_ADDR_WIDTH-1:0 ]     write_nxt_addr_sig;

wire  [XSPI_MEM_ADDR_WIDTH-1:0 ]        slv_araddr_sig;


//********************************CODE START HERE************************************


assign slv_awlen_nxt = slv_awlen + 1;
assign slv_arlen_nxt = slv_arlen + 1;

//===================================================================================

parameter SLV_ARB_IDLE        = 5'h01;
parameter SLV_ARB_WR          = 5'h02;
parameter SLV_ARB_NXT_WR_CHK  = 5'h04;
parameter SLV_ARB_RD          = 5'h08;
parameter SLV_ARB_NXT_RD_CHK  = 5'h10; 

parameter Idle          = 0;
parameter Write         = 1;
parameter NWCheck       = 2;
parameter Read          = 3;
parameter NRCheck       = 4;

reg [4:0] slv_arb_cur_state;
reg [4:0] slv_arb_nxt_state;

always @ ( * )
begin
   case ( slv_arb_cur_state )
     SLV_ARB_IDLE :
     begin
           if ( slv_awvalid )
              slv_arb_nxt_state = SLV_ARB_WR;
           else if ( slv_arvalid )
              slv_arb_nxt_state = SLV_ARB_RD;		
           else 
              slv_arb_nxt_state = SLV_ARB_IDLE;
     end 
     SLV_ARB_WR :
     begin
        if (slv_awvalid  & slv_arb_ready)
        //if ( (slv_awvalid  & slv_arb_ready) | cont_wr_flag_fedge)
           slv_arb_nxt_state = SLV_ARB_NXT_WR_CHK;
        else  
           slv_arb_nxt_state = SLV_ARB_WR;
     end 
     SLV_ARB_NXT_WR_CHK :
     begin
        if ( slv_mem_cont_wr_req  | slv_awvalid )
           slv_arb_nxt_state = SLV_ARB_WR;
        else
           slv_arb_nxt_state = SLV_ARB_IDLE;
     end
     SLV_ARB_RD :
     begin
        if ( slv_arvalid  & slv_arb_ready )
           slv_arb_nxt_state = SLV_ARB_NXT_RD_CHK;
        else  
           slv_arb_nxt_state = SLV_ARB_RD;
     end 
     SLV_ARB_NXT_RD_CHK :
     begin
        if ( slv_mem_cont_rd_req | slv_arvalid )
           slv_arb_nxt_state = SLV_ARB_RD;
        else
           slv_arb_nxt_state = SLV_ARB_IDLE;
     end
     default :
     begin
        slv_arb_nxt_state = SLV_ARB_IDLE;
     end 
   endcase
end


always @ ( posedge mem_clk or negedge mem_rst_n )
begin
   if ( ~mem_rst_n )
   begin
      slv_arb_cur_state      <= SLV_ARB_IDLE; 
      slv_arb_addr           <= 'd0;
      slv_arb_valid          <= 'd0;
      slv_arb_write          <= 'd0;
      slv_arb_axi_len        <= 'd0;
      slv_arb_bytes_len        <= 'd0;
      slv_arb_burst          <= 'd0;
      slv_arb_size           <= 'd0;
      slv_arb_err            <= 'd0;
      slv_arb_cs_sel         <= 'd0;
      slv_arb_arid           <= 'd0;
      slv_arb_awid           <= 'd0;
      slv_mem_cont_rd_req    <= 'd0;
      slv_mem_cont_wr_req    <= 'd0;
   end
   else
   begin
      slv_arb_cur_state <= slv_arb_nxt_state; 
      case ( slv_arb_nxt_state )
        SLV_ARB_IDLE :
        begin
           slv_arb_addr           <= 'd0;
           slv_arb_valid          <= 'd0;
           slv_arb_write          <= 'd0;
           slv_arb_axi_len        <= 'd0;
           slv_arb_bytes_len        <= 'd0;
           slv_arb_burst          <= 'd0;
           slv_arb_size           <= 'd0;
           slv_arb_err            <= 'd0;
           slv_arb_cs_sel         <= 'd0;
           slv_arb_arid           <= 'd0;
           slv_arb_awid           <= 'd0;
           slv_mem_cont_rd_req <= 'd0;
           slv_mem_cont_wr_req <= 'd0;
        end 
        SLV_ARB_WR :
        begin
           slv_arb_addr           <= slv_awaddr[31:0];
           slv_arb_valid          <= slv_awvalid;
           slv_arb_write          <= 1'b1;
           slv_arb_axi_len        <= slv_awlen;
           slv_arb_burst          <= slv_awburst;
           slv_arb_size           <= slv_awsize;
           slv_arb_awid           <= slv_awid;
           slv_arb_err            <= |slv_aw_err;
           slv_arb_bytes_len      <= slv_awsize == 3'b 000 ?  (slv_awlen_nxt) -'d1 :
                                     slv_awsize == 3'b 001 ?  (slv_awlen_nxt << 'd 1) - 'd1 - slv_awaddr[0]  : 
                                     slv_awsize == 3'b 010 ?  (slv_awlen_nxt << 'd 2) - 'd1 - slv_awaddr[1:0]  : 
                                     slv_awsize == 3'b 011 ?  (slv_awlen_nxt << 'd 3) - 'd1 - slv_awaddr[2:0]  : 
                                                              (slv_awlen_nxt << 'd 4) - 'd1 - slv_awaddr[3:0]; 

/*           slv_arb_bytes_len      <= slv_awsize == 3'b 000 ?  (slv_awlen_nxt) -'d1 :
                                     slv_awsize == 3'b 001 ?  (slv_awaddr[0] ? (slv_awlen_nxt << 'd 1) - 'd2 : 
                                                               (slv_awlen_nxt << 'd 1) - 'd1 ) : 
                                     slv_awsize == 3'b 010 ?  (slv_awaddr[1:0]==2'd3 ?  (slv_awlen_nxt << 'd 2) - 'd4 : 
                                                               slv_awaddr[1:0]==2'd2 ?  (slv_awlen_nxt << 'd 2) - 'd3 :
                                                               slv_awaddr[1:0]==2'd1 ?  (slv_awlen_nxt << 'd 2) - 'd2 :
                                                               (slv_awlen_nxt << 'd 2) - 'd1 ) :
                                     slv_awsize == 3'b 011 ?  (slv_awaddr[2:0]==2'd7 ?  (slv_awlen_nxt << 'd 3) - 'd8 : 
                                                               slv_awaddr[2:0]==2'd6 ?  (slv_awlen_nxt << 'd 3) - 'd7 :
                                                               slv_awaddr[2:0]==2'd5 ?  (slv_awlen_nxt << 'd 3) - 'd6 :
                                                               slv_awaddr[2:0]==2'd4 ?  (slv_awlen_nxt << 'd 3) - 'd5 :
                                                               slv_awaddr[2:0]==2'd3 ?  (slv_awlen_nxt << 'd 3) - 'd4 :
                                                               slv_awaddr[2:0]==2'd2 ?  (slv_awlen_nxt << 'd 3) - 'd3 :
                                                               slv_awaddr[2:0]==2'd1 ?  (slv_awlen_nxt << 'd 3) - 'd2 :
                                                               (slv_awlen_nxt << 'd 3) - 'd1 ) :
                                                               
                                     //slv_awsize == 3'b 011 ?  (slv_awlen_nxt << 'd 3) - 'd1 : (slv_awlen_nxt << 'd 4) - 'd1; */
           slv_arb_cs_sel         <= slv_aw_cs_sel;
           slv_mem_cont_wr_req <= cont_slv_wr_req;
        end 
        SLV_ARB_RD :
        begin
           slv_arb_addr           <= slv_araddr[31:0];
           slv_arb_valid          <= slv_arvalid;
           slv_arb_write          <= 1'b0; 
           slv_arb_axi_len        <= slv_arlen;
           slv_arb_burst          <= slv_arburst;
           slv_arb_size           <= slv_arsize;
           slv_arb_arid           <= slv_arid;
           slv_arb_err            <= |slv_ar_err;

           slv_arb_bytes_len      <= slv_arsize == 3'b 000 ?  (slv_arlen_nxt) -'d1 :
                                     slv_arsize == 3'b 001 ?  (slv_arlen_nxt << 'd 1) - 'd1 - slv_araddr[0]  : 
                                     slv_arsize == 3'b 010 ?  (slv_arlen_nxt << 'd 2) - 'd1 - slv_araddr[1:0]  : 
                                     slv_arsize == 3'b 011 ?  (slv_arlen_nxt << 'd 3) - 'd1 - slv_araddr[2:0]  : 
                                                              (slv_arlen_nxt << 'd 4) - 'd1 - slv_araddr[3:0]; 

//           slv_arb_bytes_len      <= slv_arsize == 3'b 000 ?  (slv_arlen_nxt) - 'd1:
//                                     slv_arsize == 3'b 001 ?  (slv_arlen_nxt << 'd 1 ) - 'd1 : 
//                                     slv_arsize == 3'b 010 ?  (slv_arlen_nxt << 'd 2 ) - 'd1 : 
//                                     slv_arsize == 3'b 011 ?  (slv_arlen_nxt << 'd 3 ) - 'd1 : (slv_arlen_nxt << 'd 4) - 'd1;
           slv_arb_cs_sel         <= slv_ar_cs_sel;
           slv_mem_cont_rd_req <= cont_slv_rd_req;
        end 
        default :
        begin
           slv_arb_addr           <= 'd0;
           slv_arb_valid          <= 'd0;
           slv_arb_write          <= 'd0;
           slv_arb_axi_len        <= 'd0;
           slv_arb_bytes_len        <= 'd0;
           slv_arb_burst          <= 'd0;
           slv_arb_size           <= 'd0;
           slv_arb_arid           <= 'd0;
           slv_arb_err            <= 'd0;
           slv_arb_cs_sel         <= 'd0;
           slv_mem_cont_rd_req <= 'd0;
           slv_mem_cont_wr_req <= 'd0;
        end 
      endcase
   end
end


assign slv_araddr_sig = ( slv_arsize == 3'd0 ) ? slv_araddr :
                        ( slv_arsize == 3'd1 ) ? {slv_araddr[31:1],1'b0} :
                        ( slv_arsize == 3'd2 ) ? {slv_araddr[31:2],2'b0} : 
                        ( slv_arsize == 3'd3 ) ? {slv_araddr[31:3],3'b0} : {slv_araddr[31:4],4'b0} ; 

always @ ( posedge mem_clk or negedge mem_rst_n )
begin
   if ( ~mem_rst_n )
   begin
      read_nxt_addr   <= 'd0; 
      prev_ar_btype <= 'd0;
   end
   else
   begin
      if ( slv_arvalid & slv_arb_arready )
      begin 
         read_nxt_addr <= end_addr(hyperflash_en,slv_araddr_sig,slv_arlen,slv_arsize,slv_arburst); 
         prev_ar_btype <= slv_arburst;
      end
      else
      begin
         read_nxt_addr <= read_nxt_addr; 
         prev_ar_btype <= prev_ar_btype;
      end
   end
end

assign read_nxt_addr_sig = ( read_nxt_addr[0] ) ? read_nxt_addr + 1 : read_nxt_addr;

always @ ( posedge mem_clk or negedge mem_rst_n )
begin
   if ( ~mem_rst_n )
   begin
      write_nxt_addr  <= 'd0; 
      slv_awaddr_reg <= 'd0;
      axi4_wrap_size_reg <= 'd0;
      prev_aw_btype <= 'd0;
   end
   else
   begin
      if ( slv_awvalid & slv_arb_awready )
      begin
         write_nxt_addr <= end_addr(hyperflash_en,slv_awaddr,slv_awlen,slv_awsize,slv_awburst); 
         slv_awaddr_reg <= slv_awaddr;
         axi4_wrap_size_reg <= axi4_wrap_size;
         prev_aw_btype <= slv_awburst;
      end
      else
      begin
         write_nxt_addr     <= write_nxt_addr    ;
         slv_awaddr_reg     <= slv_awaddr_reg    ;
         axi4_wrap_size_reg <= axi4_wrap_size_reg;
         prev_aw_btype         <= prev_aw_btype        ;
      end
   end
end

assign axi4_wrap_size =  slv_awburst[1] ? //hyperflash_en ? burst_length(slv_awlen,slv_awsize)>>7'd1 : 
							 burst_length(slv_awlen,slv_awsize)    : 7'd0;
//Continuous Transfer for WRAP followed by WRAP writes
always @ *
begin
case(axi4_wrap_size)	//Wrap
7'd8:  write_nxt_addr_sig = {write_nxt_addr[XSPI_MEM_ADDR_WIDTH-1:3],(write_nxt_addr[2:0] | slv_awaddr[2:0])};
7'd16: write_nxt_addr_sig = {write_nxt_addr[XSPI_MEM_ADDR_WIDTH-1:4],(write_nxt_addr[3:0] | slv_awaddr[3:0])};
7'd32: write_nxt_addr_sig = {write_nxt_addr[XSPI_MEM_ADDR_WIDTH-1:5],(write_nxt_addr[4:0] | slv_awaddr[4:0])};
7'd64: write_nxt_addr_sig = {write_nxt_addr[XSPI_MEM_ADDR_WIDTH-1:6],(write_nxt_addr[5:0] | slv_awaddr[5:0])};
default: write_nxt_addr_sig = ( write_nxt_addr[0] ) ? write_nxt_addr + 1'b1 : write_nxt_addr; //Increment
endcase
end

//assign write_nxt_addr_sig = ( write_nxt_addr[0] ) ? write_nxt_addr : write_nxt_addr + 1'b1; 

assign cont_slv_wr_req = slv_awvalid & ((slv_awaddr_reg >> mem_page_size) == (slv_awaddr >> mem_page_size)) & (write_nxt_addr_sig[XSPI_MEM_ADDR_WIDTH-1:1] == slv_awaddr[XSPI_MEM_ADDR_WIDTH-1:1]) & ( (prev_aw_btype[1] & slv_awburst[1] & axi4_wrap_size == axi4_wrap_size_reg) | (slv_awburst[0]) );                   // for odd number of bytes and octal DDR mode this condition will not work

//cont read not applicable for NAND Flash
assign cont_slv_rd_req = slv_arvalid & (read_nxt_addr_sig[XSPI_MEM_ADDR_WIDTH-1:1] == slv_araddr[XSPI_MEM_ADDR_WIDTH-1:1]) & ( (prev_ar_btype[1] & slv_arburst[0] & hybrid_wrap_cmd_en) || (prev_ar_btype[0] & slv_arburst[0]) );

assign slv_arb_arready = slv_arb_cur_state[Read]  & slv_arb_ready ; 
assign slv_arb_awready = slv_arb_cur_state[Write] & slv_arb_ready ; 


assign slv_arb_wr_start_en    = slv_arb_cur_state[Write] & slv_arb_ready ; 


//////////////////////////////////////////////////////////////////////////////
// Functions to check continuous transfers
// Possible continuous transfers are:
// Writes: Incr-Incr, Wrap-Incr, Wrap-Wrap
// Reads: Incr-Incr, Wrap-Incr 
//////////////////////////////////////////////////////////////////////////////

parameter LEN_WIDTH       = 8;
parameter BURST_LEN_WIDTH = LEN_WIDTH + 4 ;
parameter ADDR_LFTOVR     = 32 - BURST_LEN_WIDTH;

function [BURST_LEN_WIDTH-1:0] burst_length;
input [LEN_WIDTH - 1:0] length;
input [2:0] size;

begin
   burst_length = 'h0;

   case ( size )

      3'b000   : burst_length	 = length + 1;	             // BYTE	
      3'b001   : burst_length	 = (length << 1) + 2;      // HALF WORD
      3'b010   : burst_length	 = (length << 2) + 4;      // WORD
      3'b011   : burst_length	 = (length << 3) + 8;      // DWORD
      default  : burst_length	 = (length << 4) + 16;     // QWORD

   endcase // case( size )
end
endfunction // burst_length

function [31:0] end_addr;
input hyperflash_en;
input [31:0] start_addr;
input [LEN_WIDTH-1:0] length;
input [2:0] size;
input [1:0] burst;
reg   [31:0] add_addr;
      
begin
   add_addr =  //hyperflash_en ? { {ADDR_LFTOVR{1'b0}}, burst_length( length, size ) }>>1 :
				{ {ADDR_LFTOVR{1'b0}}, burst_length( length, size ) }	;

	 
   case ( burst )

      // INCR followed by INCR
      `B_INCR :           
      begin
         case ( size )
         3'b000   :end_addr = start_addr + add_addr;
         3'b001   :end_addr = start_addr + add_addr - slv_awaddr[0];
         3'b010   :end_addr = start_addr + add_addr - slv_awaddr[1:0];
         3'b011   :end_addr = start_addr + add_addr - slv_awaddr[2:0] ;
         default  :end_addr = start_addr + add_addr - slv_awaddr[3:0];
         endcase // case( size )

      end
	   
      // WRAP followed by INCR/WRAP
      // New INCR address will start from new wrap window
      // New WRAP address will be within new WRAP window (Only for writes)
      `B_WRAP :
      begin
	case(add_addr[6:0])	//Wrap Requesting size	

		       
	7'd8 : end_addr = {start_addr[XSPI_MEM_ADDR_WIDTH-1:3]+1'b1, 3'd0} ; //Next wrap window
	7'd16: end_addr = {start_addr[XSPI_MEM_ADDR_WIDTH-1:4]+1'b1, 4'd0} ;


		       
	7'd32: end_addr = {start_addr[XSPI_MEM_ADDR_WIDTH-1:5]+1'b1, 5'd0} ;
		       
		  
		       
	7'd64: end_addr = {start_addr[XSPI_MEM_ADDR_WIDTH-1:6]+1'b1, 6'd0} ;
                  default : end_addr = start_addr;
		       
		  

		       

            		       
		       
		  
		  
	endcase
      end

      default :
      begin
         end_addr = start_addr;
      end
   endcase // case( burst )
end
endfunction // end_addr



endmodule // slv_rdwr_arb 
