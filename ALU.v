module ALU (inp1,inp2,select,out,cout);
	input [3:0]inp1,inp2;
	reg cin=1'b0;
	input [1:0]select;
	output reg [7:0]out;
	output cout;
	wire[3:0]sum,sub;
	always@(select)
		begin
			if(select==2'b00)
				begin
					out<=sum;
				end
			else
				begin
					out<=sub;
				end
		end
	addition a1 (
						.a	(inp1),
						.b	(inp2),
						.cin	(cin),
						.s	(sum),
						.c	(cout));
	
	subtraction a2(
						.a	(inp1),
						.b	(inp2),
						.cin	(cin),
						.d	(sub),
						.bo	(cout));
endmodule 