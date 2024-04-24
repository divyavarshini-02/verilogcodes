module freq3(clk,rst,q,out,or_out,xor_out,d_out);
	input clk,rst;
	output reg  [1:0]q;
	output reg out;
	output or_out,xor_out;
	output reg d_out;
	always@(posedge clk)
		begin
			if(rst)
				q<=2'b00;
			else if( q==2'b10)
				q<=2'b00;
			else
				q<=q+1;
		end
	always@(negedge clk)
		begin
			if(rst)
				out<=1'b0;
			else 
				out<=q[0];
		end
	assign or_out=q[0]||out;
	always@(negedge clk)
		begin 
			if(rst)
				d_out<=1'b0;
			else 
				d_out<=or_out;
		end
	assign xor_out=or_out^d_out;
endmodule