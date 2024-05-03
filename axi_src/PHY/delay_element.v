// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------
//Delay element netlist from TSMC28nm process
//Delay timing is annotated from the SDF file
//To change the delay for a single tap, increase/decrease buffers here and regenerate SDF
//Currently, single tap delay=0.668ns for ASIC and 0.356ns for FPGA 
`timescale 1ps/1ps
`ifdef ASIC_PHY
module delay_element ( out, in );
  input in;
  output out;
  wire   out_snps_wire, eco_net, eco_net_1, eco_net_2, eco_net_3, eco_net_4,
         eco_net_5, eco_net_6, eco_net_7, eco_net_8, eco_net_9, eco_net_10,
         eco_net_11, eco_net_12, eco_net_13, eco_net_14, eco_net_15,
         eco_net_16, eco_net_17, eco_net_18, eco_net_19, eco_net_20,
         eco_net_21, eco_net_22, eco_net_23, eco_net_24, eco_net_25,
         eco_net_26, eco_net_27, eco_net_28, eco_net_29, eco_net_30,
         eco_net_31;
  assign out_snps_wire = in;
  assign out = eco_net;
   initial
        $sdf_annotate("../../src/PHY/delay_asic.sdf");
  BUF_X2P5B_A12TS_C31 eco_cell ( .A(eco_net_1), .Y(eco_net) );
  BUF_X2P5B_A12TS_C31 eco_cell_1 ( .A(eco_net_2), .Y(eco_net_1) );
  BUF_X2P5B_A12TS_C31 eco_cell_2 ( .A(eco_net_3), .Y(eco_net_2) );
  BUF_X2P5B_A12TS_C31 eco_cell_3 ( .A(eco_net_4), .Y(eco_net_3) );
  BUF_X2P5B_A12TS_C31 eco_cell_4 ( .A(eco_net_5), .Y(eco_net_4) );
  BUF_X2P5B_A12TS_C31 eco_cell_5 ( .A(eco_net_6), .Y(eco_net_5) );
  BUF_X2P5B_A12TS_C31 eco_cell_6 ( .A(eco_net_7), .Y(eco_net_6) );
  BUF_X2P5B_A12TS_C31 eco_cell_7 ( .A(eco_net_8), .Y(eco_net_7) );
  BUF_X2P5B_A12TS_C31 eco_cell_8 ( .A(eco_net_9), .Y(eco_net_8) );
  BUF_X2P5B_A12TS_C31 eco_cell_9 ( .A(eco_net_10), .Y(eco_net_9) );
  BUF_X2P5B_A12TS_C31 eco_cell_10 ( .A(eco_net_11), .Y(eco_net_10) );
  BUF_X2P5B_A12TS_C31 eco_cell_11 ( .A(eco_net_12), .Y(eco_net_11) );
  BUF_X2P5B_A12TS_C31 eco_cell_12 ( .A(eco_net_13), .Y(eco_net_12) );
  BUF_X2P5B_A12TS_C31 eco_cell_13 ( .A(eco_net_14), .Y(eco_net_13) );
  BUF_X2P5B_A12TS_C31 eco_cell_14 ( .A(eco_net_15), .Y(eco_net_14) );
  BUF_X2P5B_A12TS_C31 eco_cell_15 ( .A(eco_net_16), .Y(eco_net_15) );
  BUF_X2P5B_A12TS_C31 eco_cell_16 ( .A(eco_net_17), .Y(eco_net_16) );
  BUF_X2P5B_A12TS_C31 eco_cell_17 ( .A(eco_net_18), .Y(eco_net_17) );
  BUF_X2P5B_A12TS_C31 eco_cell_18 ( .A(eco_net_19), .Y(eco_net_18) );
  BUF_X2P5B_A12TS_C31 eco_cell_19 ( .A(eco_net_20), .Y(eco_net_19) );
  BUF_X2P5B_A12TS_C31 eco_cell_20 ( .A(eco_net_21), .Y(eco_net_20) );
  BUF_X2P5B_A12TS_C31 eco_cell_21 ( .A(eco_net_22), .Y(eco_net_21) );
  BUF_X2P5B_A12TS_C31 eco_cell_22 ( .A(eco_net_23), .Y(eco_net_22) );
  BUF_X2P5B_A12TS_C31 eco_cell_23 ( .A(eco_net_24), .Y(eco_net_23) );
  BUF_X2P5B_A12TS_C31 eco_cell_24 ( .A(eco_net_25), .Y(eco_net_24) );
  BUF_X2P5B_A12TS_C31 eco_cell_25 ( .A(eco_net_26), .Y(eco_net_25) );
  BUF_X2P5B_A12TS_C31 eco_cell_26 ( .A(eco_net_27), .Y(eco_net_26) );
  BUF_X2P5B_A12TS_C31 eco_cell_27 ( .A(eco_net_28), .Y(eco_net_27) );
  BUF_X2P5B_A12TS_C31 eco_cell_28 ( .A(eco_net_29), .Y(eco_net_28) );
  BUF_X2P5B_A12TS_C31 eco_cell_29 ( .A(eco_net_30), .Y(eco_net_29) );
  BUF_X2P5B_A12TS_C31 eco_cell_30 ( .A(eco_net_31), .Y(eco_net_30) );
  BUF_X2P5B_A12TS_C31 eco_cell_31 ( .A(out_snps_wire), .Y(eco_net_31) );
endmodule
`elsif FPGA_PHY
`define XIL_TIMING
module delay_element
   (out,
    in);
  output out;
  input in;
  wire wire1;
   initial
        $sdf_annotate("../../src/PHY/delay_fpga.sdf");
  LUT1 #(.INIT(2'b10)) LUT1_inst (.I0(in), .O(wire1));
  LUT1 #(.INIT(2'b10)) LUT2_inst (.I0(wire1), .O(out));
endmodule
`else 

module delay_element(/*AUTOARG*/
   // Outputs
   out,
   // Inputs
   in
   );
   parameter DELAY_VAL = 700;
   
   input in;
   output reg out;
always @ in
 out <= #(DELAY_VAL)  in;
endmodule //delay_module 

`endif
