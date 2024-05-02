module single_port(single_out, single_in, clk, wr, reset);
	
	output [7:0]single_out;
	
	input [7:0]single_in;
	
	input clk,wr,reset;

	//////////////////////////////////////////////////////////////////////////////////////////////////////	


	reg [7:0] mem_add=8'b10101010;
	reg [7:0]mem[255:0];

				always@(posedge clk)
				begin
					if(reset)
						begin
							single_out<=8'd0;
						end
					else
						begin
							if(wr==1'd0)//write
											begin
												mem[mem_add] <= single_in;
											end		  
							else
											begin
												single_out<=mem[mem_add];
											end
						end
				end


 /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
endmodule