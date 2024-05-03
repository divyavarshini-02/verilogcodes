// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------
// Gray code counter with enable and synchronous reset.
// Required parameters:
//   WIDTH -- Sets the bit width of counter

module gen_gray_counter (
    count,
    clk,
    reset,
    enable
);

parameter		WIDTH = 2;		// counter width.

input			enable;			// counter enable.
input			reset;			
input			clk;
output	[WIDTH-1:0]	count;			// counter value.

reg 	[WIDTH-1:0]	count;		 	// gray counter current value.
reg 	[WIDTH-1:0]     i;			// loop index
//integer			i;			// loop index
reg 	[WIDTH-1:0]	gnext;
reg 	[WIDTH-1:0]	bnext;
reg 	[WIDTH-1:0]	bin;

//==========================
// Code starts here...
//==========================
always @ (posedge clk or posedge reset ) begin
	if (reset) count <= {WIDTH{1'b0}};
	else count <= gnext;
end

// calculate next value for bit
always @ (count or enable) begin
	for (i = 0; i <= WIDTH-1; i=i+1)
		bin[i] = ^(count>>i);
	bnext = bin + {{WIDTH-1{1'b0}},enable};
	gnext = (bnext>>1) ^ bnext;
end	
    
endmodule
