// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------
// Simple, parameterized, 2-input MUX.
// Suitable for helping force Synopsys to obey your critical paths.

module gen_mux2 (
    // Outputs
    z, 
    // Inputs
    d0, 
    d1, 
    sel
);


parameter WIDTH = 1;

input	[WIDTH-1:0]	d0;    // data input used when sel is 0
input	[WIDTH-1:0]	d1;    // data input used when sel is 1
input			sel;   // MUX select signal
output	[WIDTH-1:0]	z;     // output

assign z = (sel ? d1 : d0);

endmodule
