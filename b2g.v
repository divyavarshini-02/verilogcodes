module b2g(binary_input, grey_output);
	input [3:0]binary_input;
	output [3:0]grey_output;
		function [3:0]binary2grey;
		  input [3:0]answer;
		  integer i;
			begin
				binary2grey[3]=answer[3];
					for (i = 3 ;i>0 ;i=i-1 ) 
						begin
							binary2grey[i-1]=answer[i]^answer[i-1];
						end
			end
		endfunction
	assign grey_output=binary2grey(binary_input);
endmodule

module tbb2g();
	reg [3:0]binary_input;
	wire [3:0]grey_output;
	initial
		begin
			binary_input=4'b0011;
			#30 binary_input=4'b0001;
			#1000 $stop;
		end
	b2g b1(
		.binary_input	(binary_input),
		.grey_output	(grey_output));
endmodule
