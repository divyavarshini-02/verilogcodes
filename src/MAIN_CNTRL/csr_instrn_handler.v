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
module csr_instrn_handler
(
  //Global inputs
  apb_clk,
  apb_rst_n,

  mem_clk,
  mem_rst_n,

//From CSR  - apb_clk                   
  csr_cmd_xfer_valid,
  csr_rd_xfer_valid,      

//From Main control - pulse synced to ahb_clk
  csr_cmd_xfer_success   ,
  csr_rd_xfer_success,

//To AHB_SLV_CNTRL -ahb_clk
  spl_instrn_req,           
  spl_instrn_stall,         
                           
//From AHB_SLV_CNTRL      
  spl_instrn_ack,           
  
//To Main controller engine - mem_clk -pulse
  csr_cmd_xfer_valid_final,    
  csr_rd_xfer_valid_final 
);

//IO declarations
input      apb_clk;
input      apb_rst_n;

input      mem_clk;
input      mem_rst_n;

//From CSR  - apb_clk                   
input  csr_cmd_xfer_valid;
input  csr_rd_xfer_valid;      

//From Main control - pulse synced to ahb_clk
input  csr_cmd_xfer_success   ;
input  csr_rd_xfer_success;
                                
//To AHB_SLV_CNTRL -ahb_clk
output  spl_instrn_req;           
output  spl_instrn_stall;         
                           
//From AHB_SLV_CNTRL      
input  spl_instrn_ack;           
  
//To Main controller engine - mem_clk -pulse
output  csr_cmd_xfer_valid_final;    
output  csr_rd_xfer_valid_final; 
  
  
//Internal reg and wire declarations
reg csr_cmd_xfer_valid_d1;
reg csr_rd_xfer_valid_d1;
reg spl_instrn_req, next_spl_instrn_req;
reg spl_instrn_stall, next_spl_instrn_stall;
reg csr_cmd_xfer_valid_sync_d;
reg csr_rd_xfer_valid_sync_d;


//---------------------------------------wire declaration--------------------------------
wire csr_cmd_xfer_valid_sync;
wire csr_rd_xfer_valid_sync;
wire csr_cmd_xfer_valid_redge;
wire csr_rd_xfer_valid_redge;


//Sequential block in AXI clock
always@(posedge apb_clk or negedge apb_rst_n)
begin
  if(!apb_rst_n)
  begin
    csr_cmd_xfer_valid_d1         <= 1'b0;
    csr_rd_xfer_valid_d1      <= 1'b0; 
    spl_instrn_req                <= 1'b0;
    spl_instrn_stall              <= 1'b0;
  end
  else
  begin
    csr_cmd_xfer_valid_d1         <= csr_cmd_xfer_valid;
    csr_rd_xfer_valid_d1      <= csr_rd_xfer_valid;  
    spl_instrn_req                <= next_spl_instrn_req;
    spl_instrn_stall              <= next_spl_instrn_stall;
  end
end


//Sequential block in MEM clock
always@(posedge mem_clk or negedge mem_rst_n)
begin
  if(!mem_rst_n)
  begin
    csr_cmd_xfer_valid_sync_d     <= 1'b0;
    csr_rd_xfer_valid_sync_d  <= 1'b0;
  end
  else
  begin
    csr_cmd_xfer_valid_sync_d     <= csr_cmd_xfer_valid_sync;
    csr_rd_xfer_valid_sync_d  <= csr_rd_xfer_valid_sync;
  end
end


//Special instruction request to AXI indicates that there is a special
//instruction input request from CSR. When AXI finished the ongoing memory
//request, it will accept the request and provide Special instrucion ack.
always @*
begin

next_spl_instrn_req   = spl_instrn_req; 
next_spl_instrn_stall = spl_instrn_stall;

if(csr_cmd_xfer_valid_redge | csr_rd_xfer_valid_redge)
begin
  next_spl_instrn_req = 1'b1;
  next_spl_instrn_stall = spl_instrn_stall;
end
else if(spl_instrn_ack)
begin
  next_spl_instrn_req = 1'b0;
  next_spl_instrn_stall =1'b1;
end
else if(csr_cmd_xfer_success || csr_rd_xfer_success) 
begin
  next_spl_instrn_req = spl_instrn_req;
  next_spl_instrn_stall = 1'b0;
end
else
begin
  next_spl_instrn_req = spl_instrn_req;
  next_spl_instrn_stall = spl_instrn_stall;
end
end 

assign csr_cmd_xfer_valid_redge      = csr_cmd_xfer_valid  && (!csr_cmd_xfer_valid_d1);
assign csr_rd_xfer_valid_redge   = csr_rd_xfer_valid && (!csr_rd_xfer_valid_d1);


assign csr_cmd_xfer_valid_sync_in    = csr_cmd_xfer_valid && spl_instrn_ack;
assign csr_rd_xfer_valid_sync_in = csr_rd_xfer_valid &&  spl_instrn_ack;

assign csr_cmd_xfer_valid_final      = csr_cmd_xfer_valid_sync && (!csr_cmd_xfer_valid_sync_d) ;
assign csr_rd_xfer_valid_final   = csr_rd_xfer_valid_sync && (!csr_rd_xfer_valid_sync_d);

//assign spl_instrn_done               = csr_cmd_xfer_success || csr_rd_xfer_success ? 1'b1 : 1'b0;


//Feedback Pulse synchronizer - pulse to level
fb_sync FB_SYNC_CSR_CMD_XFER_INST (
       .clkA    (apb_clk),
       .clkB    (mem_clk), 
       .resetA  (apb_rst_n),
       .resetB  (mem_rst_n),
       .inA     (csr_cmd_xfer_valid_sync_in),
       .inB     (csr_cmd_xfer_valid_sync),
       .inB_pulse     ()
);

fb_sync FB_SYNC_CSR_STATUS_XFER_INST (
       .clkA    (apb_clk),
       .clkB    (mem_clk), 
       .resetA  (apb_rst_n),
       .resetB  (mem_rst_n),
       .inA     (csr_rd_xfer_valid_sync_in),
       .inB     (csr_rd_xfer_valid_sync),
       .inB_pulse     ()
);

endmodule
