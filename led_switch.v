/*module led_switch(clk,reset,switch,led);
	//parameter idle=5'b00000, led_1=5'b10000,	led_2=5'b01000,	led_3=5'b00100, led_4=5'b00010, led_5=5'b00001;
	input clk,reset;
  input [4:0] switch;
  output reg [4:0] led;
  reg [2:0] nxt_state = 3'b000;
  reg s1_1, s2_2, s3_3, s4_4, s5_5; // signals for validity check


	always@(posedge clk)
  	begin
      if(reset)
	      begin
          led<=5'd0;
          s1_1<=1'b1;
  	      s2_2<=1'b1;
          s3_3<=1'b1;
          s4_4<=1'b1;
          s5_5<=1'b1;
        end
      else
        begin
          case(nxt_state)
               	3'd0:	begin                 //ideal
                       	led<=5'd0;
                       	s1_1<=1'b1;
                       	s2_2<=1'b1;
                       	s3_3<=1'b1;
                       	s4_4<=1'b1;
                       	s5_5<=1'b1;
												nxt_state<=3'd1;
                    	end
                3'd1: begin
												if(switch[4]==1'b0)
													begin
                        		nxt_state <= 3'd2;
													end
                  			else if (switch[4]==1'b1)
                       		begin
                          	led[4] <= 1'b0;
                          	s1_1   <= 1'b0;
														nxt_state <= 3'd2;
                        	end
												else
													begin
                    				case({s1_1,s2_2,s3_3,s4_4,s5_5})
                        						5'b01111:nxt_state<=3'd2;
                        						5'b00111:nxt_state<=3'd3;
                        						5'b00011:nxt_state<=3'd4;
                        						5'b00001:nxt_state<=3'd5;
                        						5'b00000:nxt_state<=3'd0;
                        						default:nxt_state<=3'd2;
                    				endcase
													end
                   		end
								3'd2: begin 
												if(switch[3]==1'b0)
													begin 
														nxt_state<=	3'd3;
													end
												else if(switch[3]==1'b1)
													begin
														led[3] <= 1'b0;
														s2_2    <= 1'b0;
														nxt_state <= 3'd3;
													end
												else
													begin
														case({s1_1,s2_2,s3_3,s4_4,s5_5})
																		5'b10111:nxt_state<=3'd3;
																		5'b10011:nxt_state<=3'd4;
																		5'b10001:nxt_state<=3'd5;
																		5'b10000:nxt_state<=3'd1;
																		5'b00000:nxt_state<=3'd0;
																		default:nxt_state<=3'd3;
														endcase
													end
											end
								3'd3: begin 
												if(switch[2]==1'b0)
														begin
															nxt_state<=3'd4;
														end
												else if(switch[2]==1'b1)
														begin
															led[2] <= 1'b0;
															s3_3    <= 1'b0;
															nxt_state<=3'd4;
													end
												else
														begin  
															case({s1_1,s2_2,s3_3,s4_4,s5_5})
																			5'b11011:nxt_state<=3'd4;
																			5'b11001:nxt_state<=3'd5;
																			5'b11000:nxt_state<=3'd1;
																			5'b01000:nxt_state<=3'd2;
																			5'b00000:nxt_state<=3'd0;
																			default:nxt_state<=3'd4;
															endcase
														end
											end
								3'd4: begin 
												if(switch[1]==1'b0)
														begin
															nxt_state<=3'd5;
														end
												else if(switch[1]==1'b1)
														begin
															led[1] <= 1'b0;
															s4_4    <= 1'b0;
															nxt_state<=3'd5;
														end
												else
													begin
														case({s1_1,s2_2,s3_3,s4_4,s5_5})
																		5'b11101:nxt_state<=3'd5;
																		5'b11100:nxt_state<=3'd1;
																		5'b01100:nxt_state<=3'd2;
																		5'b00100:nxt_state<=3'd3;
																		5'b00000:nxt_state<=3'd0;
																		default:nxt_state<=3'd5;
														endcase
													end 
											end
								3'd5: begin
												if(switch[0]==1'b0)
														begin 
															nxt_state<=3'd1;
														end
											else if(switch[0]==1'b1)
													begin
														led[0] <= 1'b0;
														s5_5    <= 1'b0;
														nxt_state<=3'd1;
													end
											else 
												begin
														case({s1_1,s2_2,s3_3,s4_4,s5_5})
																		5'b11110:nxt_state<=3'd1;
																		5'b01110:nxt_state<=3'd2;
																		5'b00110:nxt_state<=3'd3;
																		5'b00010:nxt_state<=3'd4;
																		5'b00000:nxt_state<=3'd0;
															default:nxt_state<=3'd1;
														endcase
												end
											end
							endcase
						end
				end
endmodule*/
module led_switch(clk,reset,switch,led);
    //parameter idle=5'b00000, led_1=5'b10000,    led_2=5'b01000,    led_3=5'b00100, led_4=5'b00010, led_5=5'b00001;
  input clk,reset;
  input [4:0] switch;
  output reg [4:0] led;
  reg [2:0] next_state ;
  reg s1_1, s2_2, s3_3, s4_4, s5_5; // signals for validity check
  reg [2:0]clk_sel; 
  wire clk_out1,clk_out2,clk_out3,clk_out4;
  reg clk1;
  reg clk_sgl=1'd1;

assign clk=(clk_sgl==1)?clk1:1'b0;
//assign clk=clk2;
always@(posedge clk, posedge reset)
  begin                                          //  clk1<=clk;
		if(reset)
				begin
					led<=5'd0;
					s1_1<=1'b1;
					s2_2<=1'b1;
					s3_3<=1'b1;
					s4_4<=1'b1;
					s5_5<=1'b1;
					next_state<=3'b000;
					clk_sel<=3'b000;
				end
		else
			begin
				clk_sel <= s1_1 + s2_2 + s3_3 + s4_4 + s5_5;
					begin
						case(clk_sel)
								3'b000:clk1<=clk;
								3'b001:clk1<=clk;
								3'b010:clk1<=clk_out1;
								3'b011:clk1<=clk_out2;
								3'b100:clk1<=clk_out3;
								3'b101:clk1<=clk_out4;
						endcase
					end
			end	
	end	

always@(posedge clk1, posedge reset)
  begin                                          //  clk1<=clk;
		if(reset)
				begin
					led<=5'd0;
					s1_1<=1'b1;
					s2_2<=1'b1;
					s3_3<=1'b1;
					s4_4<=1'b1;
					s5_5<=1'b1;
					next_state<=3'b000;
					clk_sel<=3'b000;
				end
		else
			begin
				case(next_state)
					3'd0:   	begin                 //ideal
											led<=5'd0;
											s1_1<=1'b1;
											s2_2<=1'b1;
											s3_3<=1'b1;
											s4_4<=1'b1;
											s5_5<=1'b1;
											next_state<=3'd1;
										end
					3'd1: begin                      //led 1 on state
											if(switch[4]==1'b0)
														begin
															next_state <= 3'd2;
														end
												else 
														begin
															led[4] <= 1'b0;
															s1_1   <= 1'b0;
															next_state <= 3'd2;
														end
												if (s2_2==1'b1)
														begin
															next_state<= 3'd2;
														end
												else
														if(s3_3==1'b1)
															begin
															next_state<= 3'd3;
															end
														else
															if(s4_4==1'b1)
																	begin
																		next_state<= 3'd4;
																	end
															else
																	if(s5_5==1'b1)
																		begin
																			next_state<= 3'd5;
																		end
																	else
																		if(s1_1==1'b1)
																				begin
																					next_state<= 3'd1;
																				end
																		else
																				begin
																					next_state<= 3'd0;
																				end
							end
					3'd2: begin         //led 2 on state
												if(switch[3]==1'b0)
														begin 
																next_state<= 3'd3;
														end
												else 
														begin
																led[3] <= 1'b0;
																s2_2    <= 1'b0;
																next_state <= 3'd3;
														end
												if (s3_3==1'b1)
														begin
															next_state<= 3'd3;
														end
												else
														if(s4_4==1'b1)
															begin
															next_state<= 3'd4;
															end
														else
															if(s5_5==1'b1)
																	begin
																		next_state<= 3'd5;
																	end
															else
																	if(s1_1==1'b1)
																		begin
																			next_state<= 3'd1;
																		end
																	else
																		if(s2_2==1'b1)
																				begin
																					next_state<= 3'd2;
																				end
																		else
																				begin
																					next_state<= 3'd0;
																				end
										end
					3'd3: begin          //led 3 on state
												if(switch[2]==1'b0)
																begin
																		next_state<=3'd4;
																end
												else
																begin
																		led[2] <= 1'b0;
																		s3_3    <= 1'b0;
																		next_state<=3'd4;
														end
												if (s4_4==1'b1)
														begin
															next_state<= 3'd4;
														end
												else
														if(s5_5==1'b1)
															begin
															next_state<= 3'd5;
															end
														else
															if(s1_1==1'b1)
																	begin
																		next_state<= 3'd1;
																	end
															else
																	if(s2_2==1'b1)
																		begin
																			next_state<= 3'd2;
																		end
																	else
																		if(s3_3==1'b1)
																				begin
																					next_state<= 3'd3;
																				end
																		else
																				begin
																					next_state<= 3'd0;
																				end
										end
					3'd4: begin          //led 4 on state
												if(switch[1]==1'b0)
																begin
																		next_state<=3'd5;
																end
												else 
																begin
																		led[1] <= 1'b0;
																		s4_4    <= 1'b0;
																		next_state<=3'd5;
																end
												if (s5_5==1'b1)
														begin
															next_state<= 3'd5;
														end
												else
														if(s1_1==1'b1)
															begin
															next_state<= 3'd1;
															end
														else
															if(s2_2==1'b1)
																	begin
																		next_state<= 3'd2;
																	end
															else
																	if(s3_3==1'b1)
																		begin
																			next_state<= 3'd3;
																		end
																	else
																		if(s4_4==1'b1)
																				begin
																					next_state<= 3'd4;
																				end
																		else
																				begin
																					next_state<= 3'd0;
																				end
										end
					3'd5: begin            // led 5 on state
												if(switch[0]==1'b0)
																begin 
																		next_state<=3'd1;
																end
												else 
														begin
																led[0] <= 1'b0;
																s5_5    <= 1'b0;
																next_state<=3'd1;
														end
												if (s1_1==1'b1)
														begin
															next_state<= 3'd1;
														end
												else
														if(s2_2==1'b1)
															begin
															next_state<= 3'd2;
															end
														else
															if(s3_3==1'b1)
																	begin
																		next_state<= 3'd3;
																	end
															else
																	if(s4_4==1'b1)
																		begin
																			next_state<= 3'd4;
																		end
																	else
																		if(s5_5==1'b1)
																				begin
																					next_state<= 3'd5;
																				end
																		else
																				begin
																					next_state<= 3'd0;
																				end
										end
													endcase

											end
							end

clk_divide_2  f1(.clk(clk),.reset(reset),.clk_out(clk_out1));//clock divide by 2
clk_divider_for_sec f2(.clk(clk),.reset(reset),.clk_out(clk_out2));//clock divide by 4
clk_divide_6  f3(.clk(clk),.reset(reset),.clk_out(clk_out3));//clock divide by 6
clk_divide_4 f4 (.clk(clk),.reset(reset),.clk_out(clk_out4));//clock divide by 8
endmodule


																			//clk divider by 6
																			module clk_divide_6(clk,reset,clk_out);
																			input clk,reset;
																			output reg clk_out;
																			reg [1:0]count;

																			always@(posedge clk, negedge reset)
																			begin
																			if (reset)
																					begin
																						clk_out=1'b0;
																						count=3'b0;
																					end
																			else
																				begin
																				count=count+1'd1;
																				if(count < 2'b11 )
																						clk_out=clk_out;
																				else
																						begin
																						clk_out=~clk_out;
																						count=2'b0;
																						end
																				end
																			end
																			endmodule


																			//clk divider by 2
																			module clk_divide_2(clk,reset,clk_out);
																			input clk,reset;
																			output reg clk_out;
																			reg count;

																			always@(posedge clk,negedge reset)
																			begin
																			if (reset)
																					begin
																						clk_out=1'b0;
																						count=1'b0;
																					end
																			else
																				begin
																				count=count+1'd1;
																				if(count < 1'b1 )
																						clk_out=clk_out;
																				else
																						begin
																						clk_out=~clk_out;
																						count=1'b0;
																						end
																				end
																			end
																			endmodule


																			//clk divider by 8
																			module clk_divide_4(clk,reset,clk_out);
																			input clk,reset;
																			output reg clk_out;
																			reg [2:0]count;

																			always@(posedge clk,negedge reset)
																			begin
																			if (reset)
																					begin
																						clk_out=1'b0;
																						count=3'b0;
																					end
																			else
																				begin
																				count=count+1'd1;
																				if(count < 3'b100 )
																						clk_out=clk_out;
																				else
																						begin
																						clk_out=~clk_out;
																						count=3'b0;
																						end
																				end
																			end
																			endmodule



																			//clk divider  by 4
																			module clk_divider_for_sec(clk,reset,clk_out);
																			input clk,reset;
																			output reg clk_out;
																			reg [1:0]count=2'b0;

																			always@(posedge clk,negedge reset)
																			begin
																			if (reset)
																					begin
																						clk_out<=1'b0;
																						count<=2'b0;
																					end
																			else
																				begin
																				count<=count+1'd1;
																				if(count < 2'b01 )
																						clk_out=clk_out;
																				else
																						begin
																						clk_out<=~clk_out;
																						count<=2'b0;
																						end
																				end
																			end
																			endmodule