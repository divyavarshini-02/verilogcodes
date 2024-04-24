module johnson_counter(q,clk);
	parameter n = 4;
	output reg [n-1:0] q;
	input clk;
	reg [n-1:0] x;
	initial x = 4'b0001;
	always @ (posedge clk)
		begin 
			case (x)
				1 : q = 4'b0000;
				2 : q = 4'b1000;
				3 : q = 4'b1100;
				4 : q = 4'b1110;
				5 : q = 4'b1111;
				6 : q = 4'b0111;
				7 : q = 4'b0011;
				8 : q = 4'b0001;
				default : q = 4'b0000;
			endcase
		end

	always@(negedge clk)
		begin
			if (x > 4'b1111)
				x <= 4'b0000;
			else
				x = x + 1;
		end 
endmodule 


