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




module gen_fifo_async(
   // Outputs

   full, 
   fifo_pre_full,
   fifo_almost_full,
   empty, 
   dout_v, 
   rdata,
   // Inputs
   wusable, 
   wreset, 
   wclk, 
   rusable, 
   rreset, 
   rclk, 
   push, 
   pop,
   wdata,
  flush
);



parameter	PTR_WIDTH  = 3; 		// READ AND WRITE POINTERS WIDTH //
parameter 	DATA_WIDTH = 39;			// FIFO DATA WIDTH // 
parameter	DEPTH  = 7; 			// FIFO DEPTH //


input				pop;			// Read data out of fifo
input				push;			// Write data into fifo
input				rclk;			// Read clock
input				rreset;			// Read side reset
input				rusable;		// Read side usable
input				wclk;			// Write clock
input				wreset;			// Write side reset
input				wusable;		// Write side usable
input 	[DATA_WIDTH -1 : 0]	wdata;			// fifo write data
input                           flush;

output				dout_v;			// Read data valid (read side)
output				empty;			// Fifo empty (read side)
output				full;			// Fifo full (write side)
output                          fifo_pre_full;
output                          fifo_almost_full;
//output 	[PTR_WIDTH:0] 		rdepth;			// Depth (as seen on read side)
//output 	[PTR_WIDTH:0] 		wdepth;			// Depth (as seen on write side)
output 	[DATA_WIDTH -1 : 0]	rdata;			// fifo read data


wire	[DATA_WIDTH -1 : 0]	rdata;			// fifo read data
wire 	[DATA_WIDTH -1 : 0]	wdata;			// fifo write data 
wire	[PTR_WIDTH-1:0]		read_addr;		// Read address
wire				read_strobe;	// Read strobe
wire	[PTR_WIDTH-1:0] 	write_addr;		// Write address
wire				write_strobe;	// Write  strobe



gen_fifo_async_ctl # ( PTR_WIDTH ) U_GEN_FIFO_ASYNC_CTR_INST (
   // Outputs
   .wdepth               ( ), 
   .rdepth               ( ), 
   .ram_write_strobe     ( write_strobe ), 
   .ram_write_addr       ( write_addr ), 
   .ram_read_strobe      ( read_strobe ), 
   .ram_read_addr        ( read_addr ), 
   .full                 ( full ), 
   .fifo_pre_full        ( fifo_pre_full ), 
   .fifo_almost_full        ( fifo_almost_full ), 
   .empty                ( empty ), 
   .dout_v               ( dout_v ), 
   // Inputs
   .wusable              ( 1'b1), 
   .wreset               ( !wreset ), 
   .wclk                 ( wclk ), 
   .rusable              ( 1'b1), 
   .rreset               ( !rreset ), 
   .rclk                 ( rclk ), 
   .push                 ( push ), 
   .pop                  ( pop ),
   .flush (flush)
);

`ifdef FPGA_OR_SIMULATION

mem_1w1r_fpga_or_sim # ( PTR_WIDTH, DATA_WIDTH , DEPTH  ) U_MEM_1W1R_INST (
    .wclk                ( wclk ),
    .waddr               ( write_addr ),
    .wen                 ( write_strobe ),
    .wdata               ( wdata),

    .rclk                ( rclk ),
    .raddr               ( read_addr ),
    .ren                 ( read_strobe),
    .rdata               ( rdata)
);

`endif 

`ifdef ASIC_SYNTH

mem_1w1r_asic # ( PTR_WIDTH, DATA_WIDTH , DEPTH  ) U_MEM_1W1R_INST (
    .wclk                ( wclk ),
    .wrst_n              ( wreset ), // wreset is active low
    .waddr               ( write_addr ),
    .wen                 ( write_strobe ),
    .wdata               ( wdata),

    .rclk                ( rclk ),
    .rrst_n              ( rreset ), //rreset is active low
    .raddr               ( read_addr ),
    .ren                 ( read_strobe),
    .rdata               ( rdata)
);

`endif 

endmodule
