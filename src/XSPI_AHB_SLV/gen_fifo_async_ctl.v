// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------

// Generic asynchronous FIFO controller.
// This module does not include the actual data storage
// element (register bank or SRAM).  The datapath is outside
// this control module.
//
// Required parameters:
//      PTR_WIDTH -- Sets the depth of the FIFO.
//
// rusable and wusable signals:
//  These signals can be confusing to use.  There are two possible cases:
//  1) the reset pulse in both clock domains is overlapping and big enough
//     to clear out synchronizers.  This is the simple and preferred case.
//     Here you can simply tie wusable=~wreset; rusable=~rreset;
//  2) one clock is a master and exits reset first, potentially before the 
//     second clock is in reset.  Say the master clock is rclk.  You would
//     tie wusable to 1 and rusable to a rclk domain signal which says that 
//     the wclk has been reset.  If the master clock is wclk you tie rusable
//     to 1 and wusable to a wclk domain signal which says that the rclk 
//     has been reset.


module gen_fifo_async_ctl(
   // Outputs
   wdepth, 
   rdepth, 
   ram_write_strobe, 
   ram_write_addr, 
   ram_read_strobe, 
   ram_read_addr, 
   full, 
   fifo_pre_full,
   fifo_almost_full,
   empty, 
   dout_v, 
   // Inputs
   wusable, 
   wreset, 
   wclk, 
   rusable, 
   rreset, 
   rclk, 
   push, 
   pop,
   flush
);

parameter	PTR_WIDTH = 3;

input                   flush;
input			pop;			// Read data out of fifo
input			push;			// Write data into fifo
input			rclk;			// Read clock
input			rreset;			// Read side reset
input			rusable;		// Read side usable
input			wclk;			// Write clock
input			wreset;			// Write side reset
input			wusable;		// Write side usable

output			dout_v;			// Read data valid (read side)
output			empty;			// Fifo empty (read side)
output			full;			// Fifo full (write side)
output                  fifo_pre_full;
output                  fifo_almost_full;
output [PTR_WIDTH-1:0]	ram_read_addr;		// Read address
output			ram_read_strobe;	// Read strobe
output [PTR_WIDTH-1:0] 	ram_write_addr;		// Write address
output			ram_write_strobe;	// Write  strobe
output [PTR_WIDTH:0] 	rdepth;			// Depth (as seen on read side)
output [PTR_WIDTH:0] 	wdepth;			// Depth (as seen on write side)

wire [PTR_WIDTH:0]	far_read_addr_gray;	// Gray coded read pointer
wire [PTR_WIDTH:0]	faw_write_addr_gray;	// Gray coded write pointer
    
//==========================
// Code starts here...
//==========================

gen_fifo_async_rdctl #(PTR_WIDTH) far(
	// Outputs
	.far_dout_v(dout_v), 
	.far_depth(rdepth[PTR_WIDTH:0]), 
	.far_empty(empty), 
	.far_read_addr_gray(far_read_addr_gray[PTR_WIDTH:0]),
	.far_ram_read_addr(ram_read_addr[PTR_WIDTH-1:0]), 
	.far_ram_read_strobe(ram_read_strobe),
	// Inputs
	.rclk(rclk),
	.rreset(rreset),
	.rusable(rusable),
	.pop(pop),
	.faw_write_addr_gray(faw_write_addr_gray[PTR_WIDTH:0]),
        .flush(flush)
);

gen_fifo_async_wrctl #(PTR_WIDTH) faw(
	// Outputs
	.faw_depth(wdepth[PTR_WIDTH:0]),
	.faw_full(full), 
	.fifo_pre_full(fifo_pre_full), 
	.fifo_almost_full(fifo_almost_full), 
	.faw_write_addr_gray(faw_write_addr_gray[PTR_WIDTH:0]),
	.faw_ram_write_addr(ram_write_addr[PTR_WIDTH-1:0]),
	.faw_ram_write_strobe(ram_write_strobe), 
	// Inputs
	.wclk(wclk),
	.wreset(wreset),
	.wusable(wusable),
	.push(push),
	.far_read_addr_gray(far_read_addr_gray[PTR_WIDTH:0])
);






// synopsys translate_off
// print out the maximum fifo depth
reg [PTR_WIDTH:0] max_wdepth;
reg [PTR_WIDTH:0] max_rdepth;
initial max_wdepth = 0;
initial max_rdepth = 0;
initial $timeformat(-9, 3, "ns", 1);
always @(wdepth or wreset or rreset) if(wreset | rreset) begin
	max_wdepth = 0;
end else if(wdepth > max_wdepth) begin
//	$display("INFO: %t: GEN_FIFO_ASYNC_CTL wdepth=%0d max=%0d -- %m", $realtime, wdepth, 1<<PTR_WIDTH);
	max_wdepth = wdepth;
end
always @(rdepth or wreset or rreset) if(wreset | rreset) begin
	max_rdepth = 0;
end else if(rdepth > max_rdepth) begin
//	$display("INFO: %t: GEN_FIFO_ASYNC_CTL rdepth=%0d max=%0d -- %m", $realtime, rdepth, 1<<PTR_WIDTH);
	max_rdepth = rdepth;
end
// synopsys translate_on

endmodule 
