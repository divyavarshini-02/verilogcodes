// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------
`timescale 1ps/1ps
module del_n_mux

( 
sig_in,
chain_in,
sel_in,
del_mux_out

);


input sig_in, chain_in, sel_in;
output del_mux_out;


wire mux_out;
wire del_mux_out;

delay_element
delay_inst
(
.in(mux_out),
.out(del_mux_out)
 );

assign mux_out = sel_in? chain_in: sig_in;

endmodule

