// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------

// Generate a binary representation of a gray coded
// number.  Module is purely combinational
//
// Required parameters:
//   WIDTH -- sets bit width of gray/binary number

module gen_gray2binary(
  // inputs
  din, 
  // outputs
  dout
);

parameter WIDTH=2;

input	[WIDTH-1:0]	din;
output	[WIDTH-1:0]	dout;
reg	[WIDTH-1:0]	dout;

reg [WIDTH-1:0]		i;
//integer		i;

always @(din) begin
	for(i=0; i<=WIDTH-1; i=i+1) begin
		dout[i] = ^(din>>i);
	end
end

endmodule
