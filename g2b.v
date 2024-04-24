module g2b(clk,rst,en,binary_output);
	input clk,rst,en;
	output reg [3:0]binary_output;
	reg [3:0]grey_counter;
	always@(posedge clk)
		begin
			if(rst)
				begin
					grey_counter<={4{1'b0}}+1;
					binary_output<={4{1'b0}};
				end
			else if(en)
				begin
					grey_counter<=grey_counter+1;
					binary_output<={grey_counter[3],grey_counter[2:0]^grey_counter[3:1]};
				end
			else
				begin
					grey_counter<={4{1'b0}};
					binary_output<={4{1'b0}};
				end
		end
endmodule 

module tbg2b();
	reg clk,rst,en;
	wire [3:0]binary_output;
	always #5 clk=~clk;
	initial
		begin
			rst=1'b1; en=1'b0; clk=1'b0;
			#30 rst=1'b0; en=1'b1;
			#30 en=1'b0;
			#1000 $stop;
		end
	g2b g1(
		.clk			(clk),
		.rst			(rst),
		.en				(en),
		.binary_output	(binary_output)	);
endmodule