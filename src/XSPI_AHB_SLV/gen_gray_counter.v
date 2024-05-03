// Gray code counter with enable and synchronous reset.
// Required parameters:
//   WIDTH -- Sets the bit width of counter

module gen_gray_counter (
    count,
    clk,
    reset,
    flush,
    wr_addr_bin,
    enable
);

parameter		WIDTH = 2;		// counter width.

input			enable;			// counter enable.
input			reset;			
input                   flush;
input   [WIDTH-1:0]     wr_addr_bin;
input			clk;
output	[WIDTH-1:0]	count;			// counter value.

reg 	[WIDTH-1:0]	count;		 	// gray counter current value.
reg 	[WIDTH-1:0]     i;			// loop index
//integer			i;			// loop index
reg 	[WIDTH-1:0]	gnext;
reg 	[WIDTH-1:0]	bnext;
reg 	[WIDTH-1:0]	bin;

//==========================
// Code starts here...
//==========================
always @ (posedge clk or posedge reset ) begin
	if (reset) count <= {WIDTH{1'b0}};
	else count <= gnext;
end

// calculate next value for bit
always @ (*) begin
//always @ (count or enable) begin
	for (i = 0; i <= WIDTH-1; i=i+1)
		bin[i] = ^(count>>i);
	bnext = flush ? wr_addr_bin : (bin + {{WIDTH-1{1'b0}},enable});
	gnext = (bnext>>1) ^ bnext;
end	
    
endmodule
