module boolean_circuit (a,b,clk,rst,qx,qy,o);
	input a,b,clk,rst; //a & b are the inputs
	output reg qx,qy;
	output o; // two outputs of the two flops and o is the actual output
	wire dx,dy;
	wire c;
	assign dx=a;
	assign dy=c; 
		always@(posedge clk)
			begin
				if (rst)
					begin
						qx<=1'b0;
						qy<=1'b0;	
					end
				else
					begin
						qx<=dx;
						qy<=dy;
					end
			end
	assign o=a^qy;
	assign c=~(qx||b);
endmodule 

module tbboolean_circuit();
	reg a,b,clk,rst; //a & b are the inputs
	wire qx,qy;
	wire o;
	always #5 clk=~clk;
	initial 
		begin
			clk=1'b0;a=1'b0; b=1'b0; rst=1'b1;
			#10 rst=1'b0;
			#10 a=1'b1; b=1'b0;
			#10 a=1'b0; b=1'b1;
			#10 a=1'b1; b=1'b1;
			#1000 $stop;
		end
	boolean_circuit b1(
		.a		(a),
		.b		(b),
		.clk	(clk),
		.rst	(rst),
		.qx		(qx),
		.qy		(qy),
		.o		(o));
endmodule 