
// Generate a binary representation of a gray coded
// number.  Module is purely combinational
//
// Required parameters:
//   WIDTH -- sets bit width of gray/binary number

module gen_gray2binary(
  // inputs
  din, 
  // outputs
  dout
);

parameter WIDTH=2;

input	[WIDTH-1:0]	din;
output	[WIDTH-1:0]	dout;
reg	[WIDTH-1:0]	dout;

reg [WIDTH-1:0]		i;
//integer		i;

always @(din) begin
	for(i=0; i<=WIDTH-1; i=i+1) begin
		dout[i] = ^(din>>i);
	end
end

endmodule
