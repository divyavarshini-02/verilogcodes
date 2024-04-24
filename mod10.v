module mod10(q,clk);
	output reg [3:0]q;
	input clk;
	reg [3:0]x;
	initial x=4'b0001;
	always @(posedge clk)
		begin
			case(x)
				1:q<=4'b0000;
				2:q<=4'b0001;
				3:q<=4'b0010;
				4:q<=4'b0011;
				5:q<=4'b0100;
				6:q<=4'b0101;
				7:q<=4'b0110;
				8:q<=4'b0111;
				9:q<=4'b1000;
				10:q<=4'b1001;
				11:q<=4'b1010;
				default:q<=4'b0000;
			endcase
		end
	always@(posedge clk)
		begin
			if(x>=4'b1011)
				x<=4'b0000;
			else
				x=x+1;
		end
endmodule 
