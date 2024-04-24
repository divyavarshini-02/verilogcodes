module tb_debouncer ();
		reg in, reset, clk;
		wire db_out;
		always #5 clk=~clk;
		initial
			begin
				clk=1'b0; reset=1'b1; in=1'b1;
				#10 reset=1'b0; 
				#1000 $stop; 
			end
		debouncer d1(.in(in), .reset(reset), .clk(clk), .db_out(db_out) );
endmodule