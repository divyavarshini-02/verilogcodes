module tb_top_parking_lot();
	reg in,reset,clk,in_sig,out_sig;
	wire db_out,entering,exiting;

	always #5 clk=~clk;

		initial
			begin
				reset=1'b1; clk=1'b0; //entry
				#10@(posedge clk); reset=1'b0;
				#10 in=1'b1;
				#70 in_sig=1'b1;out_sig=1'b0;
				#10 in_sig=1'b1;out_sig=1'b1;
				#10 in_sig=1'b0;out_sig=1'b1;
				#10 in_sig=1'b0;out_sig=1'b0;
//exit
				#10 in_sig=1'b0; out_sig=1'b1;
				#10 in_sig=1'b1; out_sig=1'b1;
				#10 in_sig=1'b1; out_sig=1'b0;
				#10 in_sig=1'b0; out_sig=1'b0;
				#10 in_sig=1'b1; out_sig=1'b1;
				#1000 $stop;
			end
	top_parking_lot t1 (.in(in),.reset(reset),.clk(clk),.in_sig(in_sig),.out_sig(out_sig),
						.db_out(db_out),.entering(entering),.exiting(exiting));

endmodule