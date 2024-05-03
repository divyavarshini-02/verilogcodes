// Simple, parameterized, 2-input MUX.
// Suitable for helping force Synopsys to obey your critical paths.

module gen_mux2 (
    // Outputs
    z, 
    // Inputs
    d0, 
    d1, 
    sel
);


parameter WIDTH = 1;

input	[WIDTH-1:0]	d0;    // data input used when sel is 0
input	[WIDTH-1:0]	d1;    // data input used when sel is 1
input			sel;   // MUX select signal
output	[WIDTH-1:0]	z;     // output

assign z = (sel ? d1 : d0);

endmodule
