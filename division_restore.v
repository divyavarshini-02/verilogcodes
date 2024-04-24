module division_restore(dividend,divisor,quotient,clk);
		parameter s1=3'd0, s2=3'd1, s3=3'd3, s4=3'd4, s5=3'd5;
		input [7:0] dividend;
		input [8:0] divisor;
		reg [8:0] divisor_new;
		input clk;
		output [15:0] quotient;
		reg [4:0]counter=8'd0;
		reg [8:0] accumulator,accumulator1;
		reg	[3:0]state=0;
		reg [8:0]q;
		reg [9:0]accu_q;

		assign quotient=accu_q;
		always@(posedge clk)
			begin
				case(state)
					s1:	begin
							accumulator <= 9'd0;
							accumulator1 <= 9'd0;
							q <= dividend;
							counter <= counter + 1;
							state <= s2;
						end
					s2:	begin
							accu_q <= ( {accumulator1,q} << 1 );
							accumulator <= accumulator1;
							counter <= counter + 1;
							state <= s3;
						end
					s3:	begin
							divisor_new <= (~divisor) + 1;
							accumulator <= accumulator + divisor_new;
							accu_q[9:5] <= accumulator;
							counter <= counter + 1;
							state <= s4;
						end
					s4:	begin
							if(accu_q[9] == 1)
								begin
									accumulator <= accumulator1;
									accu_q[9:5] <= accumulator;
									q[0] <= 1'b0;
									accu_q <= ( {accumulator1,q} );
									counter <= counter + 1;
										begin
											if( counter >= 4'd8)
												counter <= 4'd0;
											else
												counter <= counter + 1;
										end
									state <= s2;
								end
							else
								begin
									state <= s5;
									counter <= counter + 1;
								end
						end
					s5:	begin
							if(accu_q[9] == 0)
								begin
									q[0] <= 1'b1;
									counter <= counter + 1;
										begin
											if( counter >= 4'd8)
												counter <= 4'd0;
											else
												counter <= counter + 1;
										end
									state <= s2;
								end
							else
								begin
									state <= s4;
									counter <= counter + 1;
								end
						end
				endcase
			end

endmodule