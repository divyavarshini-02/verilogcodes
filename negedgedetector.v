module negedgedetector(d,clk,rst,q);
		input d,clk,rst;
		output  q;
		reg q1;
		assign q=~(q1||d);
		always@(negedge clk)
			begin
				if(rst)
					begin
						q1<=1'b0;
					end
				else
					begin
						q1<=~d;
					end
			end
endmodule