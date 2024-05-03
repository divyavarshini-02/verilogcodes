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
// AXI Write address clock crossing interface,
//====================================================================================



// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------

`include "xspi_axi_slv.vh"


module slv_awr_cmd_ifc  (

     axi_clk, 
     axi_rst_n,
     si_awaddr,
     si_awvalid,
     si_awsize,
     si_awlen,
     si_awburst,
     si_awid,
     si_awready,
     si_bvalid,
     si_bready,
     spl_instr_req,
     spl_instr_stall,

     mem_lower_bound_addr_0, 
     mem_upper_bound_addr_0,
     
     mem_clk, 
     mem_rst_n,

     slv_awaddr,
     slv_awvalid,
     slv_awsize,
     slv_awlen,
     slv_awburst,
     slv_awid,
     slv_aw_err,
     slv_aw_cs_sel,
     slv_awready,
     wr_pending
);

parameter SLV_AXI_ADDR_WIDTH = 32;
parameter MEM_ADDR_WIDTH     = 32;
parameter XSPI_MEM_ADDR_WIDTH = 32;
parameter SLV_AXI_ID_WIDTH   = 4;
parameter SLV_AXI_LEN_WIDTH  = 8;
parameter SLV_WR_ACCEPT      = 8;

parameter CS_SEL = 1;
localparam INCR  = 2'b01;
localparam WRAP  = 2'b10;
localparam CS_SEL_BITS = 1;
//localparam CS_SEL_BITS = SLV_AXI_ADDR_WIDTH-MEM_ADDR_WIDTH;


//*********************************INPUTS & OUTPUTS************************************

input                                  axi_clk;
input                                  axi_rst_n;
input [SLV_AXI_ADDR_WIDTH-1:0 ]        si_awaddr;
input                                  si_awvalid;
input [2:0 ]                           si_awsize;
input [SLV_AXI_LEN_WIDTH-1 :0 ]        si_awlen;
input [1:0 ]                           si_awburst;
input [SLV_AXI_ID_WIDTH-1:0 ]          si_awid;
output                                 si_awready;
input                                  si_bvalid;
input                                  si_bready;
input                                  spl_instr_req;
input                                  spl_instr_stall;

input [CS_SEL*MEM_ADDR_WIDTH-1 : 0 ]   mem_lower_bound_addr_0; 
input [CS_SEL*MEM_ADDR_WIDTH-1 : 0 ]   mem_upper_bound_addr_0;
 
input                                  mem_clk;
input                                  mem_rst_n;
output [XSPI_MEM_ADDR_WIDTH-1:0 ]      slv_awaddr;
output                                 slv_awvalid;
output [2:0 ]                          slv_awsize;
output [SLV_AXI_LEN_WIDTH-1 :0 ]       slv_awlen;
output [1:0 ]                          slv_awburst;
output [SLV_AXI_ID_WIDTH-1:0 ]         slv_awid;
output [ 1 : 0 ]                       slv_aw_err;
output [ CS_SEL_BITS-1 : 0 ]           slv_aw_cs_sel;
input                                  slv_awready;
output				       wr_pending;

//===================================================================================
reg    [XSPI_MEM_ADDR_WIDTH-1:0 ]       slv_awaddr;
reg                                    slv_awvalid;
reg    [2:0 ]                          slv_awsize;
reg    [SLV_AXI_LEN_WIDTH-1:0 ]        slv_awlen;
reg    [1:0 ]                          slv_awburst;
reg    [SLV_AXI_ID_WIDTH-1:0 ]         slv_awid;
reg    [ 1 : 0 ]                       slv_aw_err;
reg [ CS_SEL_BITS-1 : 0 ]              slv_aw_cs_sel;

wire                                   slv_awr_ff_rden; 


reg  [3:0]                             wr_accept_cnt;

wire                                   wr_accept_full;

reg   [SLV_AXI_ADDR_WIDTH-1:0 ]        si_awaddr_reg;
reg                                    si_awvalid_reg;
reg   [2:0 ]                           si_awsize_reg;
reg   [SLV_AXI_LEN_WIDTH-1 :0 ]        si_awlen_reg;
reg   [1:0 ]                           si_awburst_reg;
reg   [SLV_AXI_ID_WIDTH-1:0 ]          si_awid_reg;

reg   [1:0]                            si_aw_err;

wire                                   awr_ff_empty;
wire                                   awr_ff_full;

//wire [6:0]                             axi4_wrap_size;
//wire  [2:0]                             axi_shift_len;

wire                                   wr_pending;
reg si_awready_int, next_si_awready_int;
reg si_awr_ff_wren, next_si_awr_ff_wren;
reg [XSPI_MEM_ADDR_WIDTH + SLV_AXI_ID_WIDTH + SLV_AXI_LEN_WIDTH+CS_SEL_BITS+7 :0] si_awr_ff_wdata, next_si_awr_ff_wdata;

assign si_awready = si_awready_int & (~awr_ff_full) & (~wr_accept_full);
assign wr_pending = (|wr_accept_cnt) ? 1'b1 : 1'b0;

//===================================================================================

wire [CS_SEL_BITS-1:0] cs_sel;
assign cs_sel = 1'b0;
//assign cs_sel = si_awaddr[SLV_AXI_ADDR_WIDTH-1:MEM_ADDR_WIDTH];

reg [MEM_ADDR_WIDTH-1 : 0 ]          mem_lower_bound_addr_0_final; 
reg [MEM_ADDR_WIDTH-1 : 0 ]          mem_upper_bound_addr_0_final;

generate 

if(CS_SEL==1)
begin
always @ *
begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0;
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0;
end
end

else if(CS_SEL==2)
begin

always @ *
begin
  case(cs_sel)
  4'd0:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[0*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[0*32+:32];
  end
  4'd1:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[1*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[1*32+:32];
  end
  default:
  begin
      mem_lower_bound_addr_0_final = { MEM_ADDR_WIDTH{1'b0}};
      mem_upper_bound_addr_0_final  = { MEM_ADDR_WIDTH{1'b0}};
  end
  endcase 
end

end

else if(CS_SEL==3)
begin

always @ *
begin
  case(cs_sel)
  4'd0:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[0*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[0*32+:32];
  end
  4'd1:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[1*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[1*32+:32];
  end
  4'd2:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[2*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[2*32+:32];
  end
  default:
  begin
      mem_lower_bound_addr_0_final = { MEM_ADDR_WIDTH{1'b0}};
      mem_upper_bound_addr_0_final  = { MEM_ADDR_WIDTH{1'b0}};
  end
  endcase 
end

end

else if(CS_SEL==4)
begin

always @ *
begin
  case(cs_sel)
  4'd0:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[0*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[0*32+:32];
  end
  4'd1:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[1*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[1*32+:32];
  end
  4'd2:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[2*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[2*32+:32];
  end
  4'd3:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[3*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[3*32+:32];
  end
  default:
  begin
      mem_lower_bound_addr_0_final = { MEM_ADDR_WIDTH{1'b0}};
      mem_upper_bound_addr_0_final  = { MEM_ADDR_WIDTH{1'b0}};
  end
  endcase 
end

end

else if(CS_SEL==5)
begin

always @ *
begin
  case(cs_sel)
  4'd0:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[0*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[0*32+:32];
  end
  4'd1:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[1*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[1*32+:32];
  end
  4'd2:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[2*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[2*32+:32];
  end
  4'd3:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[3*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[3*32+:32];
  end
  4'd4:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[4*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[4*32+:32];
  end
  default:
  begin
      mem_lower_bound_addr_0_final = { MEM_ADDR_WIDTH{1'b0}};
      mem_upper_bound_addr_0_final  = { MEM_ADDR_WIDTH{1'b0}};
  end
  endcase 
end

end

else if(CS_SEL==6)
begin

always @ *
begin
  case(cs_sel)
  4'd0:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[0*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[0*32+:32];
  end
  4'd1:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[1*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[1*32+:32];
  end
  4'd2:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[2*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[2*32+:32];
  end
  4'd3:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[3*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[3*32+:32];
  end
  4'd4:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[4*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[4*32+:32];
  end
  4'd5:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[5*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[5*32+:32];
  end
  default:
  begin
      mem_lower_bound_addr_0_final = { MEM_ADDR_WIDTH{1'b0}};
      mem_upper_bound_addr_0_final  = { MEM_ADDR_WIDTH{1'b0}};
  end
  endcase 
end

end

else if(CS_SEL==7)
begin

always @ *
begin
  case(cs_sel)
  4'd0:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[0*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[0*32+:32];
  end
  4'd1:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[1*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[1*32+:32];
  end
  4'd2:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[2*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[2*32+:32];
  end
  4'd3:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[3*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[3*32+:32];
  end
  4'd4:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[4*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[4*32+:32];
  end
  4'd5:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[5*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[5*32+:32];
  end
  4'd6:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[6*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[6*32+:32];
  end
  default:
  begin
      mem_lower_bound_addr_0_final = { MEM_ADDR_WIDTH{1'b0}};
      mem_upper_bound_addr_0_final  = { MEM_ADDR_WIDTH{1'b0}};
  end
  endcase 
end
end

else if(CS_SEL==8)
begin

always @ *
begin
  case(cs_sel)
  4'd0:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[0*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[0*32+:32];
  end
  4'd1:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[1*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[1*32+:32];
  end
  4'd2:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[2*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[2*32+:32];
  end
  4'd3:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[3*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[3*32+:32];
  end
  4'd4:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[4*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[4*32+:32];
  end
  4'd5:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[5*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[5*32+:32];
  end
  4'd6:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[6*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[6*32+:32];
  end
  4'd7:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[7*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[7*32+:32];
  end
  default:
  begin
      mem_lower_bound_addr_0_final = { MEM_ADDR_WIDTH{1'b0}};
      mem_upper_bound_addr_0_final  = { MEM_ADDR_WIDTH{1'b0}};
  end
  endcase 
end
end

else if(CS_SEL==9)
begin

always @ *
begin
  case(cs_sel)
  4'd0:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[0*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[0*32+:32];
  end
  4'd1:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[1*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[1*32+:32];
  end
  4'd2:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[2*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[2*32+:32];
  end
  4'd3:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[3*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[3*32+:32];
  end
  4'd4:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[4*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[4*32+:32];
  end
  4'd5:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[5*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[5*32+:32];
  end
  4'd6:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[6*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[6*32+:32];
  end
  4'd7:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[7*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[7*32+:32];
  end
  4'd8:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[8*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[8*32+:32];
  end
  default:
  begin
      mem_lower_bound_addr_0_final = { MEM_ADDR_WIDTH{1'b0}};
      mem_upper_bound_addr_0_final  = { MEM_ADDR_WIDTH{1'b0}};
  end
  endcase 
end
end

else if(CS_SEL==10)
begin

always @ *
begin
  case(cs_sel)
  4'd0:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[0*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[0*32+:32];
  end
  4'd1:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[1*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[1*32+:32];
  end
  4'd2:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[2*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[2*32+:32];
  end
  4'd3:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[3*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[3*32+:32];
  end
  4'd4:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[4*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[4*32+:32];
  end
  4'd5:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[5*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[5*32+:32];
  end
  4'd6:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[6*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[6*32+:32];
  end
  4'd7:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[7*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[7*32+:32];
  end
  4'd8:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[8*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[8*32+:32];
  end
  4'd9:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[9*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[9*32+:32];
  end
  default:
  begin
      mem_lower_bound_addr_0_final = { MEM_ADDR_WIDTH{1'b0}};
      mem_upper_bound_addr_0_final  = { MEM_ADDR_WIDTH{1'b0}};
  end
  endcase 
end
end

else if(CS_SEL==11)
begin

always @ *
begin
  case(cs_sel)
  4'd0:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[0*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[0*32+:32];
  end
  4'd1:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[1*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[1*32+:32];
  end
  4'd2:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[2*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[2*32+:32];
  end
  4'd3:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[3*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[3*32+:32];
  end
  4'd4:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[4*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[4*32+:32];
  end
  4'd5:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[5*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[5*32+:32];
  end
  4'd6:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[6*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[6*32+:32];
  end
  4'd7:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[7*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[7*32+:32];
  end
  4'd8:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[8*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[8*32+:32];
  end
  4'd9:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[9*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[9*32+:32];
  end
  4'd10:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[10*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[10*32+:32];
  end
  default:
  begin
      mem_lower_bound_addr_0_final = { MEM_ADDR_WIDTH{1'b0}};
      mem_upper_bound_addr_0_final  = { MEM_ADDR_WIDTH{1'b0}};
  end
  endcase 
end
end

else if(CS_SEL==12)
begin

always @ *
begin
  case(cs_sel)
  4'd0:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[0*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[0*32+:32];
  end
  4'd1:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[1*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[1*32+:32];
  end
  4'd2:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[2*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[2*32+:32];
  end
  4'd3:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[3*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[3*32+:32];
  end
  4'd4:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[4*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[4*32+:32];
  end
  4'd5:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[5*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[5*32+:32];
  end
  4'd6:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[6*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[6*32+:32];
  end
  4'd7:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[7*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[7*32+:32];
  end
  4'd8:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[8*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[8*32+:32];
  end
  4'd9:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[9*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[9*32+:32];
  end
  4'd10:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[10*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[10*32+:32];
  end
  4'd11:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[11*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[11*32+:32];
  end
  default:
  begin
      mem_lower_bound_addr_0_final = { MEM_ADDR_WIDTH{1'b0}};
      mem_upper_bound_addr_0_final  = { MEM_ADDR_WIDTH{1'b0}};
  end
  endcase 
end
end

else if(CS_SEL==13)
begin

always @ *
begin
  case(cs_sel)
  4'd0:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[0*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[0*32+:32];
  end
  4'd1:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[1*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[1*32+:32];
  end
  4'd2:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[2*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[2*32+:32];
  end
  4'd3:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[3*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[3*32+:32];
  end
  4'd4:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[4*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[4*32+:32];
  end
  4'd5:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[5*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[5*32+:32];
  end
  4'd6:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[6*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[6*32+:32];
  end
  4'd7:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[7*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[7*32+:32];
  end
  4'd8:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[8*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[8*32+:32];
  end
  4'd9:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[9*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[9*32+:32];
  end
  4'd10:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[10*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[10*32+:32];
  end
  4'd11:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[11*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[11*32+:32];
  end
  4'd12:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[12*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[12*32+:32];
  end
  default:
  begin
      mem_lower_bound_addr_0_final = { MEM_ADDR_WIDTH{1'b0}};
      mem_upper_bound_addr_0_final  = { MEM_ADDR_WIDTH{1'b0}};
  end
  endcase 
end
end

else if(CS_SEL==14)
begin

always @ *
begin
  case(cs_sel)
  4'd0:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[0*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[0*32+:32];
  end
  4'd1:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[1*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[1*32+:32];
  end
  4'd2:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[2*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[2*32+:32];
  end
  4'd3:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[3*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[3*32+:32];
  end
  4'd4:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[4*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[4*32+:32];
  end
  4'd5:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[5*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[5*32+:32];
  end
  4'd6:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[6*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[6*32+:32];
  end
  4'd7:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[7*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[7*32+:32];
  end
  4'd8:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[8*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[8*32+:32];
  end
  4'd9:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[9*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[9*32+:32];
  end
  4'd10:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[10*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[10*32+:32];
  end
  4'd11:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[11*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[11*32+:32];
  end
  4'd12:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[12*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[12*32+:32];
  end
  4'd13:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[13*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[13*32+:32];
  end
  default:
  begin
      mem_lower_bound_addr_0_final = { MEM_ADDR_WIDTH{1'b0}};
      mem_upper_bound_addr_0_final  = { MEM_ADDR_WIDTH{1'b0}};
  end
  endcase 
end
end

else if(CS_SEL==15)
begin

always @ *
begin
  case(cs_sel)
  4'd0:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[0*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[0*32+:32];
  end
  4'd1:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[1*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[1*32+:32];
  end
  4'd2:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[2*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[2*32+:32];
  end
  4'd3:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[3*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[3*32+:32];
  end
  4'd4:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[4*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[4*32+:32];
  end
  4'd5:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[5*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[5*32+:32];
  end
  4'd6:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[6*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[6*32+:32];
  end
  4'd7:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[7*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[7*32+:32];
  end
  4'd8:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[8*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[8*32+:32];
  end
  4'd9:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[9*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[9*32+:32];
  end
  4'd10:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[10*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[10*32+:32];
  end
  4'd11:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[11*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[11*32+:32];
  end
  4'd12:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[12*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[12*32+:32];
  end
  4'd13:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[13*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[13*32+:32];
  end
  4'd14:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[14*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[14*32+:32];
  end
  default:
  begin
      mem_lower_bound_addr_0_final = { MEM_ADDR_WIDTH{1'b0}};
      mem_upper_bound_addr_0_final  = { MEM_ADDR_WIDTH{1'b0}};
  end
  endcase 
end
end

else
begin

always @ *
begin
  case(cs_sel)
  4'd0:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[0*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[0*32+:32];
  end
  4'd1:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[1*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[1*32+:32];
  end
  4'd2:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[2*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[2*32+:32];
  end
  4'd3:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[3*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[3*32+:32];
  end
  4'd4:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[4*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[4*32+:32];
  end
  4'd5:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[5*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[5*32+:32];
  end
  4'd6:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[6*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[6*32+:32];
  end
  4'd7:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[7*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[7*32+:32];
  end
  4'd8:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[8*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[8*32+:32];
  end
  4'd9:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[9*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[9*32+:32];
  end
  4'd10:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[10*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[10*32+:32];
  end
  4'd11:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[11*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[11*32+:32];
  end
  4'd12:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[12*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[12*32+:32];
  end
  4'd13:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[13*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[13*32+:32];
  end
  4'd14:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[14*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[14*32+:32];
  end
  4'd15:
  begin
      mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[15*32+:32];
      mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[15*32+:32];
  end
  default:
  begin
      mem_lower_bound_addr_0_final = { MEM_ADDR_WIDTH{1'b0}};
      mem_upper_bound_addr_0_final  = { MEM_ADDR_WIDTH{1'b0}};
  end
  endcase 
end
end


endgenerate

//integer unsigned i;
//always @ *
//begin
//for(i=0; i<CS_SEL; i=i+1)
//begin
//if(cs_sel==i)
//begin
//mem_lower_bound_addr_0_final = mem_lower_bound_addr_0[i*MEM_ADDR_WIDTH+:MEM_ADDR_WIDTH];
//mem_upper_bound_addr_0_final = mem_upper_bound_addr_0[i*MEM_ADDR_WIDTH+:MEM_ADDR_WIDTH];
//end
//else;
//begin
//mem_lower_bound_addr_0_final = {MEM_ADDR_WIDTH{1'b0}};
//mem_upper_bound_addr_0_final  = {MEM_ADDR_WIDTH{1'b0}};
//end
//end
//end

assign invalid_wr_addr = (si_awaddr[MEM_ADDR_WIDTH-1:0] < mem_lower_bound_addr_0_final) || (si_awaddr[MEM_ADDR_WIDTH-1:0] > mem_upper_bound_addr_0_final);

/*assign axi_shift_len   = (si_awlen == 8'h1 ) ? 3'd1 : 
                         (si_awlen == 8'h3 ) ? 3'd2 :
                         (si_awlen == 8'h7 ) ? 3'd3 :
                         (si_awlen == 8'hf ) ? 3'd4 : 3'd1 ;*/

//assign axi4_wrap_size  = (1<< si_awsize ) <<  axi_shift_len ;


//assign valid_axi_wrap_len = ( si_awlen == 8'h1 ) | ( si_awlen == 8'h3) | ( si_awlen == 8'h7) | ( si_awlen == 8'hf ) ;


always @ ( * )
begin
        if ( spl_instr_req || spl_instr_stall)
        begin
            next_si_awready_int = 1'b0;
            next_si_awr_ff_wren = 1'b0;
            next_si_awr_ff_wdata = si_awr_ff_wdata;
            si_aw_err       = 'd0;
        end
        else if(si_awvalid & si_awready & ~awr_ff_full & ~wr_accept_full)
        begin
            next_si_awready_int = 1'b1;
            next_si_awr_ff_wren = 1'b1;
            if (invalid_wr_addr ) // Memory array access - addr range check
            begin
               si_aw_err  = 2'd3; //Addr decode error
            end
           /* else if (si_awburst == WRAP) // Memory array access - WRAP transfer
            begin
               if (valid_axi_wrap_len)
               begin
                  si_aw_err  = axi4_wrap_size ==8 || axi4_wrap_size ==16 || axi4_wrap_size ==32 || axi4_wrap_size ==64 ? 2'd0 : 2'd2; // controller automatically initiates write to the register in the memory  during mismatch WRAP settings
               end
               else
               begin
                  si_aw_err  = 2'd2; // SLVERR
               end
            end
            else if(si_awburst == INCR)
            begin
               si_aw_err     = 2'd0;
            end*/
            else
            begin
               si_aw_err = 2'd0; // No error
            end
           next_si_awr_ff_wdata = {cs_sel,si_aw_err,si_awid,si_awburst,si_awlen,si_awsize,{{XSPI_MEM_ADDR_WIDTH-MEM_ADDR_WIDTH{1'b0}},si_awaddr[XSPI_MEM_ADDR_WIDTH-1:0]},si_awvalid};
        end
     else
     begin
            next_si_awready_int = ~awr_ff_full & ~wr_accept_full ? 1'b1 : 1'b0;
            next_si_awr_ff_wren = 1'b0;
            next_si_awr_ff_wdata = si_awr_ff_wdata; 
            si_aw_err = 2'd0;
     end
end


always @ ( posedge axi_clk or negedge axi_rst_n )
begin
   if ( ~axi_rst_n )
   begin
      si_awready_int    <= 1'b1;
      si_awr_ff_wren    <= 1'b0;
      si_awr_ff_wdata   <= {(XSPI_MEM_ADDR_WIDTH + SLV_AXI_ID_WIDTH + SLV_AXI_LEN_WIDTH+CS_SEL_BITS+8){1'b0}};
   end
   else
   begin
      si_awready_int    <= next_si_awready_int;
      si_awr_ff_wren    <= next_si_awr_ff_wren;
      si_awr_ff_wdata   <= next_si_awr_ff_wdata;
   end
end


wire [XSPI_MEM_ADDR_WIDTH + SLV_AXI_ID_WIDTH + SLV_AXI_LEN_WIDTH+ CS_SEL_BITS + 7 :0] si_awr_ff_rdata;
reg  [XSPI_MEM_ADDR_WIDTH + SLV_AXI_ID_WIDTH + SLV_AXI_LEN_WIDTH+ CS_SEL_BITS + 7 :0] si_awr_ff_rdata_reg;
wire rdata_valid;

parameter	PTR_WIDTH = 3;
parameter	DEPTH  = 7;
parameter	DATA_WIDTH = XSPI_MEM_ADDR_WIDTH + SLV_AXI_ID_WIDTH + SLV_AXI_LEN_WIDTH+ CS_SEL_BITS + 8 ;

wire [PTR_WIDTH-1:0] ram_write_addr;
wire [PTR_WIDTH-1:0] ram_read_addr; 


gen_fifo_async_ctl # ( PTR_WIDTH ) u_slv_awr_ff (
   // Outputs
   .wdepth               ( ), 
   .rdepth               ( ), 
   .ram_write_strobe     ( ram_write_strobe ), 
   .ram_write_addr       ( ram_write_addr ), 
   .ram_read_strobe      ( ram_read_strobe ), 
   .ram_read_addr        ( ram_read_addr ), 
   .full                 ( awr_ff_full ), 
   .empty                ( awr_ff_empty ), 
   .dout_v               ( rdata_valid ), 
   // Inputs
   .wusable              ( 1'b1), 
   .wreset               ( ~axi_rst_n ), 
   .wclk                 ( axi_clk ), 
   .rusable              ( 1'b1), 
   .rreset               ( ~mem_rst_n ), 
   .rclk                 ( mem_clk ), 
   .push                 ( si_awr_ff_wren ), 
   .pop                  ( slv_awr_ff_rden )
);

`ifdef FPGA_OR_SIMULATION

mem_1w1r_fpga_or_sim # ( PTR_WIDTH, DATA_WIDTH , DEPTH  ) u_slv_awr_ff_mem (
    .wclk                ( axi_clk ),
    .waddr               ( ram_write_addr ),
    .wen                 ( ram_write_strobe ),
    .wdata               ( si_awr_ff_wdata),

    .rclk                ( mem_clk ),
    .raddr               ( ram_read_addr ),
    .ren                 ( ram_read_strobe),
    .rdata               ( si_awr_ff_rdata)
);

`endif

`ifdef ASIC_SYNTH

mem_1w1r_asic1 # ( PTR_WIDTH, DATA_WIDTH , DEPTH  ) u_slv_awr_ff_mem (
    .wclk                ( axi_clk ),
    .wrst_n                ( axi_rst_n ),
    .waddr               ( ram_write_addr ),
    .wen                 ( ram_write_strobe ),
    .wdata               ( si_awr_ff_wdata),

    .rclk                ( mem_clk ),
    .rrst_n                ( mem_rst_n ),
    .raddr               ( ram_read_addr ),
    .ren                 ( ram_read_strobe),
    .rdata               ( si_awr_ff_rdata)
);

`endif


//===================================================================================
// SLV  Interface based on mem_clk 
//===================================================================================

parameter S_AW_IDLE = 2'b00;
parameter S_AW_RD   = 2'b01;
parameter S_AW_RD_V = 2'b10;

reg [1:0] cur_slv_aw_state;
reg [1:0] nxt_slv_aw_state;

always @ ( * )
begin
   case ( cur_slv_aw_state )
     S_AW_IDLE :
     begin
        if ( ~awr_ff_empty )
           nxt_slv_aw_state  = S_AW_RD;
        else 
           nxt_slv_aw_state  = S_AW_IDLE;
     end 
     S_AW_RD :
     begin
        if ( slv_awready & ~awr_ff_empty )
           nxt_slv_aw_state  = S_AW_RD_V;
        else if ( slv_awready & awr_ff_empty )
           nxt_slv_aw_state  = S_AW_IDLE;
        else
           nxt_slv_aw_state  = S_AW_RD;
     end 
     S_AW_RD_V :
     begin
        if ( slv_awready & ~awr_ff_empty )
           nxt_slv_aw_state  = S_AW_RD;
        else if ( slv_awready & awr_ff_empty )
           nxt_slv_aw_state  = S_AW_IDLE;
        else
           nxt_slv_aw_state  = S_AW_RD_V;
     end 
     default :
     begin
        nxt_slv_aw_state  = S_AW_IDLE;
     end 
   endcase
end

always @ ( posedge mem_clk or negedge mem_rst_n )
begin
   if ( ~mem_rst_n )
   begin
      cur_slv_aw_state <= S_AW_IDLE;
      si_awr_ff_rdata_reg <= 'd0;
   end
   else
   begin
      cur_slv_aw_state <= nxt_slv_aw_state;
      if ( rdata_valid )
         si_awr_ff_rdata_reg  <= si_awr_ff_rdata;
      else
         si_awr_ff_rdata_reg  <= si_awr_ff_rdata_reg;
   end
end

assign slv_awr_ff_rden = (~awr_ff_empty & (( cur_slv_aw_state == S_AW_IDLE) | 
                                           ((cur_slv_aw_state == S_AW_RD_V) & slv_awready) | 
                                           ((cur_slv_aw_state == S_AW_RD) & slv_awready) )); 
                                           
always @ ( * )
begin
   if ( (cur_slv_aw_state == S_AW_RD_V ) || (cur_slv_aw_state == S_AW_RD) )
   begin 
      slv_awvalid     =  ( rdata_valid) ? si_awr_ff_rdata[0]     : si_awr_ff_rdata_reg[0] ;
      slv_awaddr      =  ( rdata_valid) ? si_awr_ff_rdata[XSPI_MEM_ADDR_WIDTH:1]  : si_awr_ff_rdata_reg[XSPI_MEM_ADDR_WIDTH:1]  ;
      slv_awsize      =  ( rdata_valid) ? si_awr_ff_rdata[XSPI_MEM_ADDR_WIDTH+3 :XSPI_MEM_ADDR_WIDTH+1] : 
                                          si_awr_ff_rdata_reg[XSPI_MEM_ADDR_WIDTH+3 :XSPI_MEM_ADDR_WIDTH+1]  ;
      slv_awlen       =  ( rdata_valid) ? si_awr_ff_rdata[XSPI_MEM_ADDR_WIDTH+SLV_AXI_LEN_WIDTH+3 :XSPI_MEM_ADDR_WIDTH+4] : 
                                          si_awr_ff_rdata_reg[XSPI_MEM_ADDR_WIDTH+SLV_AXI_LEN_WIDTH+3 :XSPI_MEM_ADDR_WIDTH+4] ;
      slv_awburst     =  ( rdata_valid) ? si_awr_ff_rdata[XSPI_MEM_ADDR_WIDTH+SLV_AXI_LEN_WIDTH+5 :XSPI_MEM_ADDR_WIDTH+SLV_AXI_LEN_WIDTH+4] :
                                          si_awr_ff_rdata_reg[XSPI_MEM_ADDR_WIDTH+SLV_AXI_LEN_WIDTH+5 :XSPI_MEM_ADDR_WIDTH+SLV_AXI_LEN_WIDTH+4] ; 
      slv_awid        =  ( rdata_valid) ? si_awr_ff_rdata[XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+5 :
                                                         XSPI_MEM_ADDR_WIDTH+SLV_AXI_LEN_WIDTH+6] : 
                                          si_awr_ff_rdata_reg[XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+5 : 
                                                              XSPI_MEM_ADDR_WIDTH+SLV_AXI_LEN_WIDTH+6]   ;
      slv_aw_err      =  ( rdata_valid) ? si_awr_ff_rdata[XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+7 : 
                                                          XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+6] : 
                                          si_awr_ff_rdata_reg[XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+7 :
                                                              XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+6 ] ;
      slv_aw_cs_sel   =  ( rdata_valid) ? si_awr_ff_rdata[XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+CS_SEL_BITS-1+8:
                                                          XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+8] : 
                                          si_awr_ff_rdata_reg[XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+CS_SEL_BITS-1+8:
                                                             XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+8 ] ;
   end
   else
   begin
      slv_awvalid     =  'd0; 
      slv_awaddr      =  'd0; 
      slv_awsize      =  'd0; 
      slv_awlen       =  'd0; 
      slv_awburst     =  'd0; 
      slv_awid        =  'd0; 
      slv_aw_err      =  'd0;
      slv_aw_cs_sel   =  'd0; 
   end
end

//===================================================================================
// Write acceptance Capability of the Slave
//===================================================================================

always @ ( posedge axi_clk  or negedge axi_rst_n )
begin
   if (~axi_rst_n )
     wr_accept_cnt <= 'd0;
   else
   begin
      if ( ( si_awvalid & si_awready & ~wr_accept_full ) & (si_bvalid & si_bready ))
         wr_accept_cnt <= wr_accept_cnt;
      else if ( si_awvalid & si_awready & ~wr_accept_full )
         wr_accept_cnt <= wr_accept_cnt + 1;
      else if ( si_bvalid & si_bready )
         wr_accept_cnt <= wr_accept_cnt - 1;
   end
end

assign wr_accept_full = ( wr_accept_cnt == SLV_WR_ACCEPT);




endmodule // slv_awr_cmd_ifc 
