// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
//   Copyright December 2014, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty.
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------

`timescale 1ns/1ps

module double_flop_sync
                #(
                parameter DATA_WIDTH =1,
                parameter DEF_VAL =0
                 )
		(
		clk,	
		rst_n,
		async_in,	
		sync_out
		);

input			clk;
input			rst_n;
input [DATA_WIDTH-1:0]	async_in;
output [DATA_WIDTH-1:0]	sync_out;

reg [DATA_WIDTH-1:0]	sync_out,sync_f1;

 always @ (posedge clk or negedge rst_n)
 begin
 
 	if(!rst_n)
 	begin
 	sync_f1		<=  {DATA_WIDTH{DEF_VAL}};
 	sync_out	<=  {DATA_WIDTH{DEF_VAL}};
 	end
 	
 	else
 	begin
 	sync_f1		<=  async_in[DATA_WIDTH-1:0];
 	sync_out	<=  sync_f1[DATA_WIDTH-1:0];	
 	end
 end

endmodule
