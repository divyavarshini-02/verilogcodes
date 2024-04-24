module top_univ_shift(mux_input,ff_output,clk,rst);
	input [15:0]mux_input;
	input clk,rst;
	output reg [3:0]ff_output;
	wire [1:0]s;
	reg [3:0]shift_reg=4'b0000;
	wire [3:0]d;
	reg [3:0]d1;
	//assign d1=d;
	mux m0(.i({mux_input[3:0]}),.s(s),.d(d[0]));
	mux m1(.i({mux_input[7:4]}),.s(s),.d(d[1]));
	mux m2(.i({mux_input[11:8]}),.s(s),.d(d[2]));
	mux m3(.i({mux_input[15:12]}),.s(s),.d(d[3]));
	always@(posedge clk)
		begin
			if(rst)
				begin
					ff_output[0]<=4'b0000;
					d1<=d;
				end
			else if(s==2'b00)
				begin
					shift_reg<=shift_reg<<1;
					shift_reg[0]<=d[0];
					d1[1]<=shift_reg[0];
					shift_reg[1]<=d1[1];
					d1[2]<=shift_reg[1];
					shift_reg[2]<=d1[2];
					d1[3]<=shift_reg[2];
					shift_reg[3]<=d1[3];
					ff_output[3]<=shift_reg[3];
				end
			else if(s==2'b01)
				begin
					ff_output<=d>>1;				
				end
			else if(s==2'b10)
				begin
					ff_output<=d<<1;
				end
			else
				begin
					ff_output<=d;
				end
		end
endmodule