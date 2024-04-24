module tbposedgedetector();
	reg d,clk,rst;
	wire q;
	always #5 clk=~clk;
	initial
		fork
			d=1'b0;clk=1'b0;rst=1'b1;
			#30 rst=1'b0;
			#50 d=1'b1;
			#100 d=1'b0;
			#150 d=1'b1;
			#1000 $stop;
		join
	posedgedetector p1 (.d(d),.clk(clk),.rst(rst),.q(q));
endmodule