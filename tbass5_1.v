module tbass5_1();
	reg clk,rst,preset,d;
	wire q;
	always #10 clk=~clk;
	initial
		begin
			clk=1'b0; rst=1'b1; preset=1'b0;d=1'b0;
			#5 preset=1'b1;
			#10 d=1'b1;
			#5 d=1'b1;
			#15 rst=1'b0;
			#2 rst=1'b1;
			#3 d=1'b0;
			#5 d=1'b1;
			#8 rst=1'b0;
			#2 rst=1'b1;
			$display ("podu thakida thakida");
			#1000 $stop;
		end
		
	ass5_1 a1(
			.clk(clk),.rst(rst),.preset(preset),.d(d),.q(q));
endmodule