// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------
`define	LEN1	4'b0000
`define	LEN2	4'b0001
`define	LEN3	4'b0010
`define	LEN4	4'b0011
`define	LEN5	4'b0100
`define	LEN6	4'b0101
`define	LEN7	4'b0110
`define	LEN8	4'b0111
`define	LEN9	4'b1000
`define	LEN10	4'b1001
`define	LEN11	4'b1010
`define	LEN12	4'b1011
`define	LEN13	4'b1100
`define	LEN14	4'b1101
`define	LEN15	4'b1110
`define	LEN16	4'b1111

// SIZE transfer type signal encoding
`define S_BYTE  3'b000
`define S_HALF  3'b001
`define S_WORD  3'b010
`define S_DWORD 3'b011
`define S_QWORD 3'b100

// BURST transfer type signal encoding
`define B_FIXED     2'b00
`define B_INCR      2'b01
`define B_WRAP      2'b10
`define B_RESERVED  2'b11

`define AXI_ADDR_WIDTH 36
`define AXI_DATA_WIDTH 32
`define AXI_ID_WIDTH    4
`define AXI_LEN_WIDTH   8
`define MEM_DATA_WIDTH 32
`define AXI_WR_ACCEPT   8
`define AXI_RD_ACCEPT   8

`define PSMEM_ADDR_WIDTH  32

`define FPGA_OR_SIMULATION
//`define ASIC_SYNTH
