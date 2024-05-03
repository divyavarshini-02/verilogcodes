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

module mem_mr_xfer_ack_resolver
   (
//From XMIT enigne
   xmittr_ack,

//From RCV_CNTRL
   cont_rd_ack,


//To AXI4 slave control
   mem_mr_xfer_ack
   );

input   xmittr_ack;
input   cont_rd_ack;
  
output  mem_mr_xfer_ack;

//assign mem_mr_xfer_ack = mem_mr_xfer_valid && ( ((!mem_mr_xfer_wr_rd) & (!cont_wr_rd_req)) || (mem_mr_xfer_wr_rd) )
//   			 ? xmittr_ack : cont_rd_ack;
assign mem_mr_xfer_ack = xmittr_ack || cont_rd_ack;

endmodule
