// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------
// write controller for asynchronous FIFOs.

`define GEN_AFIFO_DEPTH_FULL		{1'b1, {PTR_WIDTH{1'b0}}}

module gen_fifo_async_wrctl (
   // Outputs
   faw_depth, faw_full, faw_write_addr_gray, faw_ram_write_addr, 
   faw_ram_write_strobe, 
   // Inputs
   wclk, wreset, wusable, push, far_read_addr_gray
   );

parameter	PTR_WIDTH	= 1;

// external interface
input			wclk;			// write clock.
input			wreset;			// write reset.
input			wusable;		// signal from read clock is 
						// usable in wclk.
input			push;			// write to FIFO.
output [PTR_WIDTH:0]	faw_depth;		// current FIFO depth as viewed 
						// in the write clock domain.
output			faw_full;		// FIFO full as viewed in the 
						// write clock domain.

// fifo_async_rdctl interface
input [PTR_WIDTH:0]	far_read_addr_gray;	// gray-coded read address from 
						// read clock domain.
output [PTR_WIDTH:0]	faw_write_addr_gray;	// gray-coded write address from
						// write clock domain.

// RAM interface
output [PTR_WIDTH-1:0]	faw_ram_write_addr;	// binary-coded RAM write 
						// add pointer.
output			faw_ram_write_strobe;	// RAM write strobe.

wire [PTR_WIDTH:0]		read_addr_gray_d2;	// stage 2 sync of gray
							// coded read address.
wire [PTR_WIDTH:0]		read_addr_binary_d2;	// stage 2 binary-coded 
							// read address.
//reg  [PTR_WIDTH:0]		Read_addr_binary_d3;	// stage 3 binary-coded 
							// read address.
reg  [PTR_WIDTH:0]		Fifo_depth;		// current FIFO depth.
reg				Fifo_full;		// current FIFO full.
reg  [PTR_WIDTH:0]		Write_addr_binary;	// current binary-coded 
							// write address.
wire [PTR_WIDTH:0]		fifo_depth_next;	// FIFO depth next cycle
wire				fifo_full_next;		// FIFO full next cycle.
wire [PTR_WIDTH:0]		write_addr_binary_next;	// binary-coded write 
							// address next cycle.
wire [PTR_WIDTH:0]		wr_rd_addr_gap;		// gap between write 
							// address and read addr
wire [PTR_WIDTH:0]		wr_rd_addr_gap_plus_1;	// incremented gap 								// between write 
							// address and read
							// address.
wire [PTR_WIDTH:0] 		write_addr_binary_plus_1;// incremented current 
							// binary-coded write 
							// address.
wire [PTR_WIDTH:0]		write_addr_gray;	// current gray-coded 
							// write address.
wire 				push_final;

//=============================
// Code starts here...
//=============================

assign push_final = push; // RSR
//assign push_final = push & ~Fifo_full;

// synchronize far_read_addr_gray

double_flop_sync 
   #(
   .DATA_WIDTH (PTR_WIDTH+1)
    )
   SS_RDADDR_GRAY
   (
   . clk   (wclk),
   . rst_n (~wreset),
   . async_in (far_read_addr_gray),
   . sync_out (read_addr_gray_d2)
   );

//RSR - Not required since both synchronizers reset are asynchronous. 
//always @ (posedge wclk ) begin
//      // register the binary-coded read address just converted from gray-code.
//      // We only use read_addr_binary_d2 when it is usable as indicated by 
//      // wusable.
//
//      Read_addr_binary_d3	<= (wusable ? read_addr_binary_d2 
//					: {PTR_WIDTH+1{1'b0}});
//end

always @ (posedge wclk or posedge wreset ) begin
      // register the binary-coded read address just converted from gray-code.
      // We only use read_addr_binary_d2 when it is usable as indicated by 
      // wusable.
      if ( wreset )
      begin
         Fifo_full	    <= 1'b0; 
         Fifo_depth         <= {PTR_WIDTH+1{1'b0}}; 
	 Write_addr_binary  <= {PTR_WIDTH+1{1'b0}}; 
         
      end
      else
      begin
         Fifo_full	    <= fifo_full_next;
         Fifo_depth	    <= fifo_depth_next;
         Write_addr_binary  <= write_addr_binary_next;
      end
end


// convert gray-coded read address into binary-coded read address.
gen_gray2binary #(PTR_WIDTH+1) raconv(
	.dout (read_addr_binary_d2),
	.din (read_addr_gray_d2)
);

// generate FIFO depth in the next cycle.
assign wr_rd_addr_gap = (Write_addr_binary - read_addr_binary_d2);
//assign wr_rd_addr_gap = (Write_addr_binary - Read_addr_binary_d3);
assign wr_rd_addr_gap_plus_1 = wr_rd_addr_gap + 1'b1;

gen_mux2 #(PTR_WIDTH+1) depthmux (
	.sel (push_final),
	.z   (fifo_depth_next),
	.d0  (wr_rd_addr_gap),
	.d1  (wr_rd_addr_gap_plus_1)
);

// generate FIFO full in the next cycle.
assign fifo_full_next = (fifo_depth_next == (`GEN_AFIFO_DEPTH_FULL - 1));

// generate binary write address in the next cycle.
assign write_addr_binary_plus_1	= Write_addr_binary + 1'b1;

gen_mux2 #(PTR_WIDTH+1) wamux(
	.sel(push_final),
	.z(write_addr_binary_next),
	.d0(Write_addr_binary),
	.d1(write_addr_binary_plus_1)
);

// generate gray write address in the current cycle.
gen_gray_counter #(PTR_WIDTH+1) wagc (
	.count(write_addr_gray),
	.clk(wclk),
	.reset(wreset),
	.enable(push_final)
);

//---------------------
// other outputs
//---------------------
assign faw_depth		= Fifo_depth;
assign faw_full			= Fifo_full;
assign faw_write_addr_gray	= write_addr_gray;
assign faw_ram_write_strobe	= push_final;
assign faw_ram_write_addr	= Write_addr_binary[PTR_WIDTH-1:0];

endmodule
