module freq_7 (clk_in, rst_n, mod_out, d_out, or_out);

	input clk_in, rst_n;

	output reg [2:0] mod_out, d_out;
	
	output or_out;

	////////////////////////////////////////////////////////////////MOD 7 COUNTER////////////////////////////////////////////////////////////////////////////////////////////


	always@(posedge clk_in)
		begin
			if(rst_n)
				begin
					mod_out <= 3'd0;
				end
			else
				begin
					mod_out<= mod_out+1'b1;
						if(mod_out==3'd6)
							begin
								mod_out <= 3'd0;
							end
						else
							begin
								mod_out <= mod_out+1'b1;
							end
				end
		end


  /////////////////////////////////////////////////////NEGEDGE DFF OF MOD COUNTER OUTPUT////////////////////////////////////////////////////////////////////////////////////


	always@(negedge mod_out)
		begin
			if(rst_n)
				begin
					d_out <= 3'd0;
				end
			else
				begin
					d_out <= d_out+1'b1;
						if(d_out == 3'd6)
							begin
								d_out <= 3'd0;
							end
						else
							begin
								d_out <= d_out + 1'b1;
							end
				end
		end

	
  ///////////////////////////////////////////////////////////OR OPERATION///////////////////////////////////////////////////////////////////////////

	assign or_out = mod_out[3] || d_out;

endmodule