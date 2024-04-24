module tbass1_2();
	reg p,clk,rst;
	wire  qa,qb,qab,qbb; 
	always #5 clk=~clk;
	initial 
		fork
			clk=1'b0;rst=1'b1;p=1'b1;
			#10 rst=1'b0; 
			#100 $stop;
		join
	ass1_2 a1	 (
				.p(p),
				.clk(clk),
				.rst(rst),
				.qa(qa),
				.qb(qb),
				.qab(qab),
				.qbb(qbb)	
				);
endmodule