// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------
// read controller for asynchronous FIFOs.

`define GEN_AFIFO_DEPTH_EMPTY		{(PTR_WIDTH+1){1'b0}}

module gen_fifo_async_rdctl (
   // Outputs
   far_dout_v, far_depth, far_empty, far_read_addr_gray, 
   far_ram_read_addr, far_ram_read_strobe, 
   // Inputs
   rclk, pop, rreset, rusable, faw_write_addr_gray
   );

parameter	PTR_WIDTH	= 1;

// external interface
input			rclk;			// read clock.
input			rreset;			// read reset.
input			rusable;		// signal from write clock 
						// is usable in read clock.
input			pop;			// read from FIFO.
output			far_dout_v;		// data from RAM is valid.
output [PTR_WIDTH:0]	far_depth;		// current FIFO depth as viewed 
						// in the read clock domain.
output			far_empty;		// FIFO empty as viewed in the 
						// read clock domain.

// fifo_async_wrctl interface
input  [PTR_WIDTH:0]	faw_write_addr_gray;	// gray-coded write address 
						// from write clock domain.
output [PTR_WIDTH:0]	far_read_addr_gray;	// gray-coded read address 
						// from read clock domain.

// RAM interface
output [PTR_WIDTH-1:0]	far_ram_read_addr;	// binary-coded RAM read address
						// pointer.
output			far_ram_read_strobe;	// RAM read strobe.

wire [PTR_WIDTH:0]		write_addr_gray_d2;	// stage 2 sync of gray
							// coded write address.
wire [PTR_WIDTH:0]		write_addr_binary_d2;	// stage 2 binary-coded 
							// write address.
//reg  [PTR_WIDTH:0]		Write_addr_binary_d3;	// stage 3 binary-coded 
							// write address.
reg				Data_out_valid;		// data out is valid.
reg  [PTR_WIDTH:0]		Fifo_depth;		// current FIFO depth.
reg				Fifo_empty;		// current FIFO empty.
reg  [PTR_WIDTH:0]		Read_addr_binary;	// current binary-coded 
							// read address.
wire [PTR_WIDTH:0]		fifo_depth_next;	// FIFO depth next cycle
wire				fifo_empty_next;	// FIFO empty next cycle
wire [PTR_WIDTH:0]		read_addr_binary_next;	// binary-coded read 
							// address next cycle.
wire [PTR_WIDTH:0]		wr_rd_addr_gap;		// gap between write add
							// and read address.
wire [PTR_WIDTH:0]		wr_rd_addr_gap_minus_1;	// decremented gap 
							// between write address
							// and read address.
wire [PTR_WIDTH:0] 		read_addr_binary_plus_1;// incremented current 
							// binary-coded read 
							// address.
wire [PTR_WIDTH:0]		read_addr_gray;		// current gray-coded 
							// read address.
wire 				pop_final;

//=============================
// Code starts here...
//=============================

assign pop_final = pop & ~Fifo_empty;

// synchronize faw_write_addr_gray

double_flop_sync 
   #(
   .DATA_WIDTH (PTR_WIDTH+1)
    )
   SS_WRADDR_GRAY
   (
   . clk   (rclk),
   . rst_n (~rreset),
   . async_in (faw_write_addr_gray),
   . sync_out (write_addr_gray_d2)
   );

//RSR
//always @ (posedge rclk ) begin
//      // register the binary-coded write address just converted from gray-code.
//      // We only use write_addr_binary_d2 when it is usable as indicated 
//      // by rusable.
//
//      Write_addr_binary_d3 	<= (rusable ? write_addr_binary_d2 
//					: {PTR_WIDTH+1{1'b0}});
//end





always @ (posedge rclk or posedge rreset ) begin
      // register the binary-coded write address just converted from gray-code.
      // We only use write_addr_binary_d2 when it is usable as indicated 
      // by rusable.

      if ( rreset )
      begin
         Data_out_valid		<= 1'b0;
         Fifo_empty		<= 1'b1;
         Fifo_depth		<= {PTR_WIDTH+1{1'b0}}; 
         Read_addr_binary       <= {PTR_WIDTH+1{1'b0}}; 
      end
      else 
      begin
         Data_out_valid        <= pop_final;
         Fifo_empty	       <= fifo_empty_next;
         Fifo_depth	       <= fifo_depth_next;
         Read_addr_binary      <= read_addr_binary_next;
      end
end

// convert gray-coded write address into binary-coded write address.
gen_gray2binary #(PTR_WIDTH+1) waconv(
	.dout (write_addr_binary_d2),
	.din (write_addr_gray_d2));

// generate FIFO depth in the next cycle.
assign wr_rd_addr_gap = (write_addr_binary_d2 - Read_addr_binary); //RSR
//assign wr_rd_addr_gap = (Write_addr_binary_d3 - Read_addr_binary);
assign wr_rd_addr_gap_minus_1 = wr_rd_addr_gap - 1'b1;

gen_mux2 #(PTR_WIDTH+1) depthmux (
	.sel (pop_final),
	.z   (fifo_depth_next),
	.d0  (wr_rd_addr_gap),
	.d1  (wr_rd_addr_gap_minus_1)
);

// generate FIFO empty in the next cycle.
assign fifo_empty_next = (fifo_depth_next == `GEN_AFIFO_DEPTH_EMPTY);

// generate binary read address in the next cycle.
assign read_addr_binary_plus_1	= Read_addr_binary + 1'b1;
gen_mux2 #(PTR_WIDTH+1) ramux(.sel(pop_final),
	.z(read_addr_binary_next),
	.d0(Read_addr_binary),
	.d1(read_addr_binary_plus_1)
);

// generate gray read address in the current cycle.
gen_gray_counter #(PTR_WIDTH+1) ragc (
	.count		(read_addr_gray),
	.clk		(rclk),
	.reset		(rreset),
	.enable		(pop_final)
);

//---------------------
// other outputs
//---------------------
assign far_dout_v		= Data_out_valid;
assign far_depth		= Fifo_depth;
assign far_empty		= Fifo_empty;
assign far_read_addr_gray	= read_addr_gray;
assign far_ram_read_strobe	= pop_final;
assign far_ram_read_addr	= Read_addr_binary[PTR_WIDTH-1:0];
    
endmodule
