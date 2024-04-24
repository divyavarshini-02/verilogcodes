module tbparking_lot_fsm_single ();
		reg rst,clk,in_sig,out_sig;
		wire entering,exiting;


		always #5 clk=~clk;

		initial
			begin
				rst=1'b1; clk=1'b0; 
				#10 rst=1'b0;
				#10 in_sig=0; out_sig=0;
				#10 in_sig=1; out_sig=0;
				#10 in_sig=1; out_sig=1;
				#10 in_sig=0; out_sig=1;
				#10 in_sig=0; out_sig=0;
				#10 in_sig=0; out_sig=0;
				#10 in_sig=0; out_sig=1;
				#10 in_sig=1; out_sig=1;
				#10 in_sig=1; out_sig=0;
				#10 in_sig=0; out_sig=0;
				#10 in_sig=1; out_sig=1;
				#1000 $stop;
			end
		
		parking_lot_fsm_single p1 (.rst(rst),.clk(clk),.in_sig(in_sig),.out_sig(out_sig),.entering(entering),.exiting(exiting));
endmodule
