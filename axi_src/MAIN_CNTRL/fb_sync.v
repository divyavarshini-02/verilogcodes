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

module fb_sync (
clkA,
clkB, 
resetA,
resetB,
inA,
inB,
inB_pulse
);

input  clkA;
input  clkB;
input  resetA;
input  resetB;
input  inA;
output inB;
output inB_pulse;

reg inB_level_d1;
reg    inA_level,next_inA_level     ;
wire inB_pulse;

assign inB_pulse = inB & (!inB_level_d1);

always @ (posedge clkB or negedge resetB)
begin
if(~resetB)
inB_level_d1 <= 1'b0;
else
inB_level_d1 <= inB;
end

wire   inB;
wire   ack2;

double_flop_sync #(
          1
          ) 
INPUT_DFF (
          .clk          (clkB),	
          .rst_n      (resetB),
          .async_in     (inA_level),	
          .sync_out     (inB)
);

double_flop_sync #(
          1
          ) 

OUTPUT_DFF (
          .clk          (clkA),	
          .rst_n      (resetA),
          .async_in     (inB),	
          .sync_out     (ack2)
);

always @(posedge clkA or negedge resetA)
begin
    if (!resetA)
    begin
         inA_level <=  1'b0;
    end
    else
    begin
        inA_level <=  next_inA_level;
    end
end

always @ (*)          /// clkA
begin
       if (inA)
       begin
           next_inA_level = 1'b1 ;
       end
       else 
       if (ack2)
       begin
           next_inA_level = 1'b0 ;
       end
       else 
       begin
           next_inA_level = inA_level;
       end
end

endmodule


