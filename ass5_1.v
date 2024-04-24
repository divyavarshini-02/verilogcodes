module ass5_1(clk,rst,preset,d,q);
	input clk,rst,preset,d;
	output reg q;
	always@(posedge clk or negedge rst or negedge preset)
		begin
			if(!preset)
			
				q<=1'b1;
			else if(!rst)
				q<=1'b0;
			else
				q<=d;
		end
endmodule
