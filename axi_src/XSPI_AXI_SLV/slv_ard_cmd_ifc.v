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


module slv_ard_cmd_ifc  (

     axi_clk, 
     axi_rst_n,
     si_araddr,
     si_arvalid,
     si_arsize,
     si_arlen,
     si_arburst,
     si_arid,
     si_arready,
     si_rvalid,
     si_rlast,
     si_rready,
     spl_instr_req,
     spl_instr_stall,

     mem_lower_bound_addr_0, 
     mem_upper_bound_addr_0,
     
     mem_clk, 
     mem_rst_n,
     slv_araddr,
     slv_arvalid,
     slv_arsize,
     slv_arlen,
     slv_arburst,
     slv_arid,
     slv_ar_err,
     slv_ar_cs_sel,
     slv_arready,
     rd_pending

);

parameter SLV_AXI_ADDR_WIDTH  = 32;
parameter MEM_ADDR_WIDTH      = 32;
parameter XSPI_MEM_ADDR_WIDTH = 32;
parameter SLV_AXI_ID_WIDTH   = 4;
parameter SLV_AXI_LEN_WIDTH  = 8;
parameter SLV_RD_ACCEPT      = 8;
parameter CS_SEL= 1;

localparam INCR  = 2'b01;
localparam WRAP  = 2'b10;
localparam CS_SEL_BITS = 1;
//localparam CS_SEL_BITS = SLV_AXI_ADDR_WIDTH-MEM_ADDR_WIDTH;


//*********************************INPUTS & OUTPUTS************************************

input                                  axi_clk;
input                                  axi_rst_n;
input [SLV_AXI_ADDR_WIDTH-1:0 ]        si_araddr;
input                                  si_arvalid;
input [2:0 ]                           si_arsize;
input [SLV_AXI_LEN_WIDTH-1 :0 ]        si_arlen;
input [1:0 ]                           si_arburst;
input [SLV_AXI_ID_WIDTH-1:0 ]          si_arid;
output                                 si_arready;
input                                  si_rvalid;
input                                  si_rlast;
input                                  si_rready;
input                                  spl_instr_req;
input                                  spl_instr_stall;

input [CS_SEL*MEM_ADDR_WIDTH-1 : 0 ]          mem_lower_bound_addr_0; 
input [CS_SEL*MEM_ADDR_WIDTH-1 : 0 ]          mem_upper_bound_addr_0;

 
input                                  mem_clk;
input                                  mem_rst_n;
output [31:0 ]       slv_araddr;
output                                 slv_arvalid;
output [2:0 ]                          slv_arsize;
output [SLV_AXI_LEN_WIDTH-1 :0 ]       slv_arlen;
output [1:0 ]                          slv_arburst;
output [SLV_AXI_ID_WIDTH-1:0 ]         slv_arid;
output [1:0]                           slv_ar_err;
output [ CS_SEL_BITS-1 : 0 ]           slv_ar_cs_sel;
input                                  slv_arready;

output                                 rd_pending;

//===================================================================================
reg   [SLV_AXI_ADDR_WIDTH-1:0 ]        si_araddr_reg;
//reg                                    si_arvalid_reg;
//reg   [2:0 ]                           si_arsize_reg;
//reg   [SLV_AXI_LEN_WIDTH-1 :0 ]        si_arlen_reg;
//reg   [1:0 ]                           si_arburst_reg;
//reg   [SLV_AXI_ID_WIDTH-1:0 ]          si_arid_reg;
reg [ CS_SEL_BITS-1 : 0 ]              slv_ar_cs_sel;

reg    [31:0 ]       slv_araddr;
reg                                    slv_arvalid;
reg    [2:0 ]                          slv_arsize;
reg    [SLV_AXI_LEN_WIDTH-1:0 ]        slv_arlen;
reg    [1:0 ]                          slv_arburst;
reg    [SLV_AXI_ID_WIDTH-1:0 ]         slv_arid;
reg    [1:0]                      slv_ar_err;

wire                                   slv_ard_ff_rden; 

wire                                   si_arready;

reg  [3:0]                             rd_accept_cnt;

wire                                   rd_accept_full;
wire                                   ard_ff_empty;
wire                                   ard_ff_full;

reg  [1:0]                             si_ar_err;


//wire [6:0]                             axi4_wrap_size;
//wire  [2:0]                             axi_shift_len;
wire                                   rd_pending;

reg si_arready_int, next_si_arready_int;
reg si_ard_ff_wren, next_si_ard_ff_wren;
reg [XSPI_MEM_ADDR_WIDTH + SLV_AXI_ID_WIDTH + SLV_AXI_LEN_WIDTH+CS_SEL_BITS+7 :0] si_ard_ff_wdata, next_si_ard_ff_wdata;

assign si_arready = si_arready_int & (~ard_ff_full) & (~rd_accept_full);
assign rd_pending = (|rd_accept_cnt) ? 1'b1 : 1'b0;

//********************************CODE START HERE************************************

reg [MEM_ADDR_WIDTH-1 : 0 ]          mem_lower_bound_addr_0_final; 
reg [MEM_ADDR_WIDTH-1 : 0 ]          mem_upper_bound_addr_0_final;
wire [CS_SEL_BITS-1:0] cs_sel;
assign cs_sel = 1'b0;  //===================================================================================
//assign cs_sel = si_araddr[SLV_AXI_ADDR_WIDTH-1:MEM_ADDR_WIDTH];  //===================================================================================

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
////begin
////mem_lower_bound_addr_0_final = {MEM_ADDR_WIDTH {1'b0}};
////mem_upper_bound_addr_0_final  = {MEM_ADDR_WIDTH {1'b0}};
////end
//end
//end

assign invalid_rd_addr = (si_araddr[MEM_ADDR_WIDTH-1:0] < mem_lower_bound_addr_0_final) || (si_araddr[MEM_ADDR_WIDTH-1:0] > mem_upper_bound_addr_0_final);

/*assign axi_shift_len   = (si_arlen == 8'h1 ) ? 3'd1 : 
                         (si_arlen == 8'h3 ) ? 3'd2 :
                         (si_arlen == 8'h7 ) ? 3'd3 :
                         (si_arlen == 8'hf ) ? 3'd4 : 3'd1 ;*/
                   
//assign axi4_wrap_size  = (1<< si_arsize ) <<  axi_shift_len ;


//assign valid_axi_wrap_len = ( si_arlen == 8'h1 ) | ( si_arlen == 8'h3) | ( si_arlen == 8'h7) | ( si_arlen == 8'hf ) ;

always @ ( * )
begin
    if ( spl_instr_req || spl_instr_stall)
    begin
        next_si_arready_int = 1'b0;
        next_si_ard_ff_wren = 1'b0;
        next_si_ard_ff_wdata = si_ard_ff_wdata;
        si_ar_err       = 'd0;
    end
    else if(si_arvalid & si_arready & ~ard_ff_full & ~rd_accept_full)
    begin
        next_si_arready_int = 1'b1;
        next_si_ard_ff_wren = 1'b1;
        //next_si_ard_ff_wdata = 1;
        if (invalid_rd_addr ) // Memory array access - addr range check
        begin
           si_ar_err  = 2'd3; //Addr decode error
        end
        /*else if (si_arburst == WRAP) // Memory array access - WRAP transfer
        begin
           if (valid_axi_wrap_len)
           begin
              si_ar_err  = axi4_wrap_size ==8 || axi4_wrap_size ==16 || axi4_wrap_size ==32 || axi4_wrap_size ==64 ? 2'd0 : 2'd2; // controller automatically initiates MR8 write during mismatch WRAP settings
           end
           else
           begin
              si_ar_err  = 2'd2; // SLVERR
           end
        end
        else if( si_arburst == INCR)
        begin
           si_ar_err     = 2'd0;
        end*/
        else
        begin
           si_ar_err = 2'd0; // No error
        end
           next_si_ard_ff_wdata = {cs_sel,si_ar_err,si_arid,si_arburst,si_arlen,si_arsize,{{(XSPI_MEM_ADDR_WIDTH-MEM_ADDR_WIDTH){1'b0}},si_araddr[MEM_ADDR_WIDTH-1:0]},si_arvalid};
     end
     else
     begin
            next_si_arready_int = ~ard_ff_full & ~rd_accept_full ? 1'b1 : 1'b0;
            next_si_ard_ff_wren = 1'b0;
            next_si_ard_ff_wdata = si_ard_ff_wdata; 
            si_ar_err = 2'd0;
     end
end


always @ ( posedge axi_clk or negedge axi_rst_n )
begin
   if ( ~axi_rst_n )
   begin
      si_arready_int    <= 1'b1;
      si_ard_ff_wren    <= 1'b0;
      si_ard_ff_wdata   <= {(XSPI_MEM_ADDR_WIDTH + SLV_AXI_ID_WIDTH + SLV_AXI_LEN_WIDTH+CS_SEL_BITS+8){1'b0}};
   end
   else
   begin
      si_arready_int    <= next_si_arready_int;
      si_ard_ff_wren    <= next_si_ard_ff_wren;
      si_ard_ff_wdata   <= next_si_ard_ff_wdata;
   end
end


wire [XSPI_MEM_ADDR_WIDTH + SLV_AXI_ID_WIDTH + SLV_AXI_LEN_WIDTH+ CS_SEL_BITS + 7 :0] si_ard_ff_rdata;
reg  [XSPI_MEM_ADDR_WIDTH + SLV_AXI_ID_WIDTH + SLV_AXI_LEN_WIDTH+ CS_SEL_BITS + 7 :0] si_ard_ff_rdata_reg;
wire rdata_valid;


parameter	PTR_WIDTH = 3;
parameter	DEPTH  = 7;
parameter	DATA_WIDTH = XSPI_MEM_ADDR_WIDTH + SLV_AXI_ID_WIDTH + SLV_AXI_LEN_WIDTH+ CS_SEL_BITS + 8 ;

wire [PTR_WIDTH-1:0] ram_write_addr;
wire [PTR_WIDTH-1:0] ram_read_addr; 


gen_fifo_async_ctl # ( PTR_WIDTH ) u_slv_ard_ff (
   // Outputs
   .wdepth               ( ), 
   .rdepth               ( ), 
   .ram_write_strobe     ( ram_write_strobe ), 
   .ram_write_addr       ( ram_write_addr ), 
   .ram_read_strobe      ( ram_read_strobe ), 
   .ram_read_addr        ( ram_read_addr ), 
   .full                 ( ard_ff_full ), 
   .empty                ( ard_ff_empty ), 
   .dout_v               ( rdata_valid ), 
   // Inputs
   .wusable              ( 1'b1), 
   .wreset               ( ~axi_rst_n ), 
   .wclk                 ( axi_clk ), 
   .rusable              ( 1'b1), 
   .rreset               ( ~mem_rst_n ), 
   .rclk                 ( mem_clk ), 
   .push                 ( si_ard_ff_wren ), 
   .pop                  ( slv_ard_ff_rden )
);

`ifdef FPGA_OR_SIMULATION

mem_1w1r_fpga_or_sim # ( PTR_WIDTH, DATA_WIDTH , DEPTH  ) u_slv_ard_ff_mem (
    .wclk                ( axi_clk ),
    .waddr               ( ram_write_addr ),
    .wen                 ( ram_write_strobe ),
    .wdata               ( si_ard_ff_wdata),

    .rclk                ( mem_clk ),
    .raddr               ( ram_read_addr ),
    .ren                 ( ram_read_strobe),
    .rdata               ( si_ard_ff_rdata)
);

`endif

`ifdef ASIC_SYNTH

mem_1w1r_asic2 # ( PTR_WIDTH, DATA_WIDTH , DEPTH  ) u_slv_ard_ff_mem (
    .wclk                ( axi_clk ),
    .wrst_n                ( axi_rst_n ),
    .waddr               ( ram_write_addr ),
    .wen                 ( ram_write_strobe ),
    .wdata               ( si_ard_ff_wdata),

    .rclk                ( mem_clk ),
    .rrst_n                ( mem_rst_n ),
    .raddr               ( ram_read_addr ),
    .ren                 ( ram_read_strobe),
    .rdata               ( si_ard_ff_rdata)
);

`endif

//===================================================================================
// SLAVE READ ADDRESS INTERFACE based on mem_clk 
//===================================================================================

parameter S_AR_IDLE = 2'b00;
parameter S_AR_RD   = 2'b01;
parameter S_AR_RD_V = 2'b10;

reg [1:0] cur_slv_ar_state;
reg [1:0] nxt_slv_ar_state;

always @ ( * )
begin
   case ( cur_slv_ar_state )
     S_AR_IDLE :
     begin
        if ( ~ard_ff_empty )
           nxt_slv_ar_state  = S_AR_RD;
        else 
           nxt_slv_ar_state  = S_AR_IDLE;
     end 
     S_AR_RD :
     begin
        if ( slv_arready & ~ard_ff_empty )
           nxt_slv_ar_state  = S_AR_RD_V;
        else if ( slv_arready & ard_ff_empty )
           nxt_slv_ar_state  = S_AR_IDLE;
        else
           nxt_slv_ar_state  = S_AR_RD;
     end 
     S_AR_RD_V :
     begin
        if ( slv_arready & ~ard_ff_empty )
           nxt_slv_ar_state  = S_AR_RD;
        else if ( slv_arready & ard_ff_empty )
           nxt_slv_ar_state  = S_AR_IDLE;
        else
           nxt_slv_ar_state  = S_AR_RD_V;
     end 
     default :
     begin
        nxt_slv_ar_state  = S_AR_IDLE;
     end 
   endcase
end

always @ ( posedge mem_clk or negedge mem_rst_n )
begin
   if ( ~mem_rst_n )
   begin
      cur_slv_ar_state <= S_AR_IDLE;
      si_ard_ff_rdata_reg <= 'd0;
   end
   else
   begin
      cur_slv_ar_state <= nxt_slv_ar_state;
      if ( rdata_valid )
         si_ard_ff_rdata_reg  <= si_ard_ff_rdata;
   end
end

assign slv_ard_ff_rden = (~ard_ff_empty & ((cur_slv_ar_state == S_AR_IDLE) | 
                                           ((cur_slv_ar_state == S_AR_RD_V) & slv_arready) | 
                                           ((cur_slv_ar_state == S_AR_RD) & slv_arready) )); 
                                           
always @ ( * )
begin
   if ( (cur_slv_ar_state == S_AR_RD_V ) || (cur_slv_ar_state == S_AR_RD) )
   begin 
      slv_arvalid     =  ( rdata_valid) ? si_ard_ff_rdata[0]     : si_ard_ff_rdata_reg[0] ;
      slv_araddr      =  ( rdata_valid) ? si_ard_ff_rdata[XSPI_MEM_ADDR_WIDTH:1]  : si_ard_ff_rdata_reg[XSPI_MEM_ADDR_WIDTH:1]  ;
      slv_arsize      =  ( rdata_valid) ? si_ard_ff_rdata[XSPI_MEM_ADDR_WIDTH+3 :XSPI_MEM_ADDR_WIDTH+1] : 
                                          si_ard_ff_rdata_reg[XSPI_MEM_ADDR_WIDTH+3 :XSPI_MEM_ADDR_WIDTH+1]  ;
      slv_arlen       =  ( rdata_valid) ? si_ard_ff_rdata[XSPI_MEM_ADDR_WIDTH+SLV_AXI_LEN_WIDTH+3 :XSPI_MEM_ADDR_WIDTH+4] : 
                                          si_ard_ff_rdata_reg[XSPI_MEM_ADDR_WIDTH+SLV_AXI_LEN_WIDTH+3 :XSPI_MEM_ADDR_WIDTH+4] ;
      slv_arburst     =  ( rdata_valid) ? si_ard_ff_rdata[XSPI_MEM_ADDR_WIDTH+SLV_AXI_LEN_WIDTH+5 :XSPI_MEM_ADDR_WIDTH+SLV_AXI_LEN_WIDTH+4] :
                                          si_ard_ff_rdata_reg[XSPI_MEM_ADDR_WIDTH+SLV_AXI_LEN_WIDTH+5 :XSPI_MEM_ADDR_WIDTH+SLV_AXI_LEN_WIDTH+4] ; 
      slv_arid        =  ( rdata_valid) ? si_ard_ff_rdata[XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+5 :
                                                          XSPI_MEM_ADDR_WIDTH+SLV_AXI_LEN_WIDTH+6] : 
                                          si_ard_ff_rdata_reg[XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+5 : 
                                                              XSPI_MEM_ADDR_WIDTH+SLV_AXI_LEN_WIDTH+6]   ;
      slv_ar_err      =  ( rdata_valid) ? si_ard_ff_rdata[XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+7 : 
                                                          XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+6] : 
                                          si_ard_ff_rdata_reg[XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+7 :
                                                              XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+6 ] ;
      slv_ar_cs_sel   =  ( rdata_valid) ? si_ard_ff_rdata[XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+CS_SEL_BITS-1+8 :
                                                          XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+8] : 
                                          si_ard_ff_rdata_reg[XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+CS_SEL_BITS-1+8 :
                                                          XSPI_MEM_ADDR_WIDTH+SLV_AXI_ID_WIDTH+SLV_AXI_LEN_WIDTH+8] ;
   end
   else
   begin
      slv_arvalid     =  'd0; 
      slv_araddr      =  'd0; 
      slv_arsize      =  'd0; 
      slv_arlen       =  'd0; 
      slv_arburst     =  'd0; 
      slv_arid        =  'd0; 
      slv_ar_err      =  'd0;
      slv_ar_cs_sel   =  'd0; 
   end
end

//===================================================================================
// SLAVE READ ACCEPTANCE CAPABILITY
//===================================================================================

always @ ( posedge axi_clk  or negedge axi_rst_n )
begin
   if (~axi_rst_n )
     rd_accept_cnt <= 'd0;
   else
   begin
      if ( ( si_arvalid & si_arready & ~rd_accept_full) & (si_rvalid & si_rlast & si_rready ))
         rd_accept_cnt <= rd_accept_cnt ;
      else if ( si_arvalid & si_arready & ~rd_accept_full)
         rd_accept_cnt <= rd_accept_cnt + 1;
      else if ( si_rvalid & si_rlast & si_rready )
         rd_accept_cnt <= rd_accept_cnt - 1;
   end
end

assign rd_accept_full = ( rd_accept_cnt == SLV_RD_ACCEPT);



//===================================================================================



endmodule // slv_ard_cmd_ifc 
