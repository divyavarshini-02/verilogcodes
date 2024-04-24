module posedgedetector(d,clk,rst,q);
		input d,clk,rst;
		output q;
		wire inv_q;
		reg q1;
		assign inv_q=~q1;
		assign q=inv_q&&d;
		always@(posedge clk)
			begin
				if(rst)
					begin
						q1<=1'b0;
					end
				else
					begin
						q1<=d;
					end
			end
endmodule