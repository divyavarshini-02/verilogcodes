module ass3_12(clk,rst,q);
	input clk,rst;
	output [1:0]q;
	wire p;//=1'b0;
	wire d1,d2;
	wire r;//=1'b0;
	assign r=~q[0];
	assign d1=r;
	assign p=~(q[1]);
	assign d2=(p^(q[0]));
	dff f1(clk,rst,d1,q[0]);
	dff f2(clk,rst,d2,q[1]);
endmodule

module dff(clk,rst,d,q);
	input clk,d,rst;
	output reg [1:0] q;
	always@(posedge clk)
		begin
			if(rst)
			begin
				q[0]<=0;
				q[1]<=0;
			end
			else
			begin
				q[0]<=d;
				q[1]<=d;
			end
		end
endmodule
	// always@(posedge clk)
	// 	begin
	// 		if(rst)
	// 			begin
	// 				q[0]<=1'b0;
	// 				q[1]<=1'b0;
	// 			end
	// 		else
	// 			begin
	// 				q[0]<=d1;
	// 				q[1]<=d2;
	// 			end
	// 	end
// // endmodule
// module tbass3_12();
//  	reg clk,rst;
//  	wire [1:0]q;
//  	always #5 clk=~clk;
// 	initial 
//  		begin
//  			clk=1'b0; rst=1'b1;
//  			#10 rst=1'b0;
//  			#1000 $stop;
//  		end
//  	ass3_12 a1(
//  		.clk	(clk),
//  		.rst	(rst),
//  		.q		(q));
// endmodule

// module tbass3__12();
// 	reg clk;
// 	reg d1,d2;
// 	wire [1:0]q;
// 	always #5 clk=~clk;

// 	initial 
// 		begin
// 			d1=1'b0; d2=1'b1;clk=1'b0;
// 			#10 d1=1'b0; d2=1'b0;
// 			#10 d1=1'b1; d2=1'b0;
// 			#10 d1=1'b1; d2=1'b1;
// 			#1000 $stop;
// 		end	
// 	ass3_12 a1(
// 		.clk	(clk),
// 		.d1		(d1),
// 		.d2		(d2),
// 		.q		(q));
// endmodule 