module dualedgedetector(d,clk,rst,q);
		input d,clk,rst;
		output  q;
		wire w1,w2;
		assign q=w1||w2;
		posedgedetector p1 (.d(d),.clk(clk),.rst(rst),.q(w1));
		negedgedetector n1 (.d(d),.clk(clk),.rst(rst),.q(w2));
endmodule