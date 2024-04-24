module top_parking_lot(in,reset,clk,in_sig,out_sig,db_out,entering,exiting);
				input in,reset,clk,in_sig,out_sig;
				output db_out,entering,exiting;
				wire p_in, p_out;

				debouncer entry1(.in(in), .reset(reset), .clk(clk), .db_out(p_in) );
				debouncer exit1(.in(p_out), .reset(reset), .clk(clk), .db_out(db_out) );
				parking_lot_fsm_single p1 (.rst(reset),.clk(clk),.start(p_in),.in_sig(in_sig),.out_sig(out_sig),.entering(entering),.exiting(p_out));
endmodule	