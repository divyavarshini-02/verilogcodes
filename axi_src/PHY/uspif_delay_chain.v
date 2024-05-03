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
module uspif_delay_chain
(
tap_in,
dqs_in,
dqs_delayed
);


input [7:0] tap_in;
input       dqs_in;
output      dqs_delayed;

wire dqs_delayed_1, dqs_delayed_2, dqs_delayed_3, dqs_delayed_4, dqs_delayed_5, dqs_delayed_6, dqs_delayed_7 , dqs_delayed_8;
wire dqs_delayed;

del_n_mux
delay_1

( 
.sig_in(dqs_in),
.chain_in(dqs_delayed_8),
.sel_in(tap_in[0]),
.del_mux_out(dqs_delayed)

);

del_n_mux
delay_2

( 
.sig_in(dqs_in),
.chain_in(dqs_delayed_7),
.sel_in(tap_in[1]),
.del_mux_out(dqs_delayed_8)

);

del_n_mux
delay_3
( 
.sig_in(dqs_in),
.chain_in(dqs_delayed_6),
.sel_in(tap_in[2]),
.del_mux_out(dqs_delayed_7)

);

del_n_mux
delay_4
( 
.sig_in(dqs_in),
.chain_in(dqs_delayed_5),
.sel_in(tap_in[3]),
.del_mux_out(dqs_delayed_6)

);


del_n_mux
delay_5
( 
.sig_in(dqs_in),
.chain_in(dqs_delayed_4),
.sel_in(tap_in[4]),
.del_mux_out(dqs_delayed_5)

);


del_n_mux
delay_6
( 
.sig_in(dqs_in),
.chain_in(dqs_delayed_3),
.sel_in(tap_in[5]),
.del_mux_out(dqs_delayed_4)

);



del_n_mux
delay_7
( 
.sig_in(dqs_in),
.chain_in(dqs_delayed_2),
.sel_in(tap_in[6]),
.del_mux_out(dqs_delayed_3)

);

del_n_mux
delay_8
( 
.sig_in(dqs_in),
.chain_in(dqs_delayed_1),
.sel_in(tap_in[7]),
.del_mux_out(dqs_delayed_2)

);

del_n_mux
delay_init
(
.sig_in(dqs_in),
.chain_in(dqs_in),
.sel_in(1'b0),
.del_mux_out(dqs_delayed_1)

);

endmodule


