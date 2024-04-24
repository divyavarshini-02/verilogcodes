module debouncer ( in, reset, clk, db_out );
		input in, reset, clk;
		output reg db_out;

///////////////////////////////////////////////////////////////////////////


		reg [1:0] dff;
		wire q_reset, q_add;
		reg [3:0]q_timing=0;
		reg [3:0]counter=0; // timing flipflops 


//////////////////////////////////////////////////////////////////////////


		assign q_reset = dff[0]^dff[1];
		assign q_add = ~(q_timing[3]);


//////////////////////////////////////////////////////////////////////////


		always@(posedge clk)
		begin
			begin
				if(reset)
					begin
						dff[0] <= 1'b0;
						dff[1] <= 1'b0;
						counter <= 4'd2;
					end
				else
					begin
						dff[0] <= in;
						dff[1] <= dff[0];
						counter <= counter + 1;
							if ({counter < 4'd2,counter > 4'd10}) // the range is from 2 to 10 from cycle tyre range to car tyre range 
								counter <= 4'd2;
							else
								counter <= counter + 1;
					end
			end
		end	


//////////////////////////////////////////////////////////////////////////


	always @ ( posedge clk )
		begin
			if(counter[3] == 1'b1)
					db_out <= dff[1];
			else
					db_out <= db_out;
		end


//////////////////////////////////////////////////////////////////////////
endmodule