module parking_lot_fsm_single (rst,clk,in_sig,out_sig,entering,exiting);
		parameter idle=3'b000, car_enter=3'b001, half_enter=3'b010, almost_enter=3'b011, car_exit=3'b100, half_exit=3'b101, almost_exit=3'b110, invalid=3'b111;
		input rst,clk,in_sig,out_sig;
		output reg entering,exiting;
		reg [2:0]state;


		always@(posedge clk)
			begin
				if(rst)
					begin
						state<=3'b000;
					end
				else
					begin
						case(state)
							idle:			begin
												if (in_sig == 1 && out_sig == 0)
													state <= car_enter;
												else if (in_sig == 0 && out_sig == 1)
													state <= car_exit;
												else if (in_sig == 0 && out_sig == 0)
													state <= idle;
												else
													state <= invalid;
											end
							car_enter:		begin
												if (in_sig == 1 && out_sig == 1)
													state <= half_enter;
												else if (in_sig == 0 && out_sig == 0)
													state <= idle;
												else if (in_sig == 1 && out_sig == 0)
													state <= car_enter;
												else
													state <= invalid;
											end
							half_enter:		begin
												if (in_sig == 0 && out_sig == 1)
													state <= almost_enter;
												else if (in_sig == 1 && out_sig == 0)
													state <= car_enter;
												else if (in_sig == 1 && out_sig == 0)
													state <= half_enter;
												else
													state <= invalid;
											end
							almost_enter:	begin
												if(in_sig == 0 && out_sig == 0)
													begin
														entering <= 1'b1;
														state <= idle;
													end
												else if (in_sig == 1 && out_sig == 0)
													state <= half_enter;
												else if (in_sig == 1 && out_sig == 0)
													state <= almost_enter;
												else
													state <= invalid;
											end
							car_exit:		begin
												if (in_sig == 1 && out_sig == 1)
													state <= half_exit;
												else if (in_sig == 0 && out_sig == 0)
													state <= idle;
												else if (in_sig == 0 && out_sig == 1)
													state <= car_exit;
												else
													state <= invalid;
											end
							half_exit:		begin
												if (in_sig == 1 && out_sig == 0)
													state <= almost_exit;
												else if (in_sig == 0 && out_sig == 1)
													state <= car_exit;
												else if (in_sig == 1 && out_sig == 1)
													state <= half_exit;
												else
													state <= invalid;
											end
							almost_exit:	begin
												if(in_sig == 0 && out_sig == 0)
													begin
														exiting <= 1'b1;
														state <= idle;
													end
												else if (in_sig == 1 && out_sig == 0)
													state <= half_exit;
												else if (in_sig == 1 && out_sig == 0)
													state <= almost_exit;
												else
													state <= invalid;
											end
							invalid:		begin
												state<=idle;
											end	
						endcase	
															
					end
			end
endmodule
