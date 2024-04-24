// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// //											*SDRAM- Synchronous Dynamic Random Access Memory *																	            																	  				//
// //        #1  IN DE2 BOARD THE CLOCK FREQ FOR THE SDRAM DIFFERS FROM 133,143,166 TO 200.																																						//
// //        #2  ROW = 4096 BITS																																																																				//
// //				#3  COLUMN = 256 BITS																																																																			//
// //				#4  FOR EACH MATRIX IT IS = 16 BITS           																																																						//
// //				#5  NO. OF BANKS = 4																																																																			//
// //				#6  OVERALL MEMORY = 4096*256*16*4 = 67108864 BITS = 67108864/8 = 8.388608MBYTES (8MB APPROX)																															//
// //				#7  HERE, THE CLOCK FREQ IS 133MHZ. 																																																											//
// //				#8  STATE = INIHIBIT, NO_OPERATION, ACTIVE, READ, WRITE, REFRESH, PRECHARGE.																																							//
// //				#9  FOR EVERY 64ms THE 4096 TIMES THE AUTO PRECHARGE AND THE AUTO REFRESH MODE WORKS.																																			//
// //				#10	THE REFRESH COUNTER VALUE FOR THE REFRESH STATE IS 4096 WHICH IS EQUAL TO THE NUMBER OF ROWS FOR THE GIVEN 1MB.																				//
// //				#11 THE PRECHARGE COUNTER VALUE FOR THE PRECHARGE STATE IS 64ms CALCULATED BY 133 X 10^6 X 64 X 10 ^ (-3) =	8152 																					//														

// //				#12 VALUABLE INFORMATION REGARDING SDRAM- 																																																								//
// //																1) TRCD - ACTIVE COMMAND TO R/W COMMAND no_operation TIME 																																								//	
// //																2) TCK - CLOCK CYCLE TIME 																																																				//
// //																3) TRC - ROW CYCLE TIME = MINIMUM ROW ACTIVE TIME (TRAS) + ROW PRECHARGE TIME (TRP) 																							//
// // 																4) TREF - REFRESH CYCLE TIME 																																																			//
// //																5) REFRESH RATE COUNTER FORMULA = CLOCK FREQ * (TREF (in ms)/ TOTAL NO OF ROWS)																										//
// //																																= 133 X 10^6 * (64 X 10^(-3)/4096) 																																//
// //																																= 133 X 10^6 * 15.6µS 																																						//
// //																																= 2074.8 (2075 APPROX) IS THE COUNTER VALUE																												//
// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// 																							// PIN DESCRIPTION \\

// // sd_rc_a = sdram_row_column_address, sd_ba = bank_address, sd_io = sdram_inout, sd_ce_n = sdram_clock_enable, sd_cs_n	= sdram_chip_select, 
// //sd_ras_n = sdram_row_address_strobe, sd_cas_n = sdram_column_address_strobe, sd_we_n = write_enable, sd_dqm_n = data_inout_mask (signal like LB UB)																														
																																																																												 

// ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// module sdram_uart_de2	(
// 												clk_50, reset_n, enable, write_port, read_port, dual_port_out,	//input side of the simple dual port ram\\
// 												sd_rc_a, sd_ba, sd_io, sd_ce_n, sd_cs_n, sd_ras_n, sd_cas_n, sd_we_n, sd_dqm_n // input side of the sdram and output for the sdram controller, sd_io is inout pin\\
// 											);
															
// 							input [4:0] write_port,read_port;
// 							input [7:0] dual_port_out;
// 							input clk_50;
// 							input reset_n;
// 							input enable;
// 							output reg [0:11] sd_rc_a;
// 							output reg [0:1] sd_ba;
// 							inout reg [0:15] sd_io;
// 							output reg sd_ce_n;
// 							output reg sd_cs_n;
// 							output reg sd_ras_n;
// 							output reg sd_cas_n;
// 							output reg sd_we_n;
// 							output reg sd_dqm_n;

// 	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// 						parameter inhibit = 3'd0;
// 						parameter auto_refresh = 3'd1;						
// 						parameter load_mode_reg = 3'd2;						
// 						parameter no_operation = 3'd3;						
// 						parameter idle = 3'd4;						
// 						parameter active = 3'd5;						
// 						parameter rw = 3'd6;						
// 						parameter precharge = 3'd7;

// 	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// 	//localparam sdram_row = 12, sdram_column = 8, bank_width = 4;
// 	//localparam sdram_address = (sdram_row > sdram_column) ? sdram_row : sdram_column;

// 	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 		reg [3:0] state,next;
// 		reg [1:0] no_operation_cnt;
	
// 		reg [11:0]mode_reg;
// 		reg [2:0] burst_length = 2'b001;
// 		reg sequential = 1'b0;
// 		reg [2:0] cas_latency = 3'd2; // here it is 2
// 		reg [1:0] operating_mode = 2'd0;
// 		reg burst_mode = 1'd0;
// 		wire sdram_clk;
// 		reg [15:0]sd_io_reg;
		
// 		assign sd_io_reg = sd_io;
	
// 		clk_143 c1(.areset(reset_n), .inclk0(clk_50), .c0(sdram_clk));
// 		 dual_port_ram (.clock(sdram_clk), .data(dual_port_out), .rdaddress(read_port), .wraddress(write_port), .wren(enable), .q(sd_io_reg));
	

		
// 		always@(posedge sdram_clk)
// 			begin
// 				if(reset_n)
// 					begin
// 						sd_ce_n <= 1'd1;
// 						sd_cs_n <= 1'd1;
// 						sd_ras_n <= 1'd1;
// 						sd_cas_n <= 1'd1;
// 						sd_we_n <= 1'd1;
// 						sd_dqm_n <= 1'd1;	
// 					end
// 				else
// 					begin
// 						casex(state)
						
// 							inhibit :						begin
// 																	sd_cs_n <= 1'd1;
// 																	sd_ras_n <= 1'dx;
// 																	sd_cas_n <= 1'dx;
// 																	sd_we_n <= 1'dx;
// 																	sd_dqm_n <= 1'd1;
// 																	sd_rc_a <= 12'dx;
// 																	sd_io_reg <= 16'dx;
// 																	state <= auto_refresh;
// 																	//next <= auto_refresh;
// 																end
							
// 							auto_refresh : 				begin
// 																	sd_cs_n <= 1'd0;
// 																	sd_ras_n <= 1'dx;
// 																	sd_cas_n <= 1'dx;
// 																	sd_we_n <= 1'dx;
// 																	sd_dqm_n <= 1'dx;
// 																	sd_rc_a <= 12'dx;
// 																	sd_ba <= 2'dx;
// 																	sd_io_reg <= 16'dx;
// 																	state <= no_operation;
// 																	next <= load_mode_reg;
// 																end
													
// 							load_mode_reg:					begin
// 																	sd_cs_n <= 1'd0;
// 																	sd_ras_n <= 1'd0;
// 																	sd_cas_n <= 1'd0;
// 																	sd_we_n <= 1'd0;
// 																	sd_dqm_n <= 1'dx;
// 																	mode_reg <= { sd_rc_a[11], sd_rc_a[10], burst_mode, operating_mode[1:0], cas_latency[2:0], sequential, burst_length[2:0] };
// 																	state <= no_operation;
// 																	next <= idle;
// 																end

// 							no_operation: 				//	begin
// 																	// if((state == inhibit)&&(state == auto_refresh))
// 																	// 	begin
// 																	// 		state <= next; 
// 																	// 	end
// 																	// else
// 																		begin
// 																		no_operation_cnt <= no_operation_cnt + 2'd1;
// 																			if (no_operation_cnt == 2'd3)
// 																				begin
// 																					no_operation_cnt <= 2'd0;
// 																					state <= next;
// 																				end
// 																			else
// 																				begin
// 																					no_operation_cnt <= no_operation_cnt + 2'd1;
// 																					state <= no_operation;
// 																				end																			
// 																		end
// 																//end	

// 							idle : 							begin
// 																	sd_ba <= 2'dx;
// 																	state <= no_operation;
// 																	next <= active;
// 																end	
															
// 							active: 							begin
// 																	sd_cs_n = 1'd0;
// 																	sd_ras_n = 1'd0;
// 																	sd_cas_n = 1'd1;
// 																	sd_we_n = 1'd1;
// 																	sd_dqm_n = 1'dx;
// 																	sd_rc_a = mode_reg;
// 																	sd_ba = 2'd2;
// 																	sd_io_reg = 16'dx;
// 																	state = no_operation;
// 																	next = rw;
// 																end	

// 							rw:								begin
// 																	sd_cs_n <= 1'd0;
// 																	sd_ras_n <= 1'd1;
// 																	sd_cas_n <= 1'd0;
// 																	sd_we_n <= 1'd0;
// 																	sd_dqm_n <= 1'd1;
// 																	sd_io_reg <= dual_port_out;
// 																	sd_rc_a <= {4'dx, mode_reg};
// 																	sd_ba <= 2'd2;
// 																	state <= no_operation;
// 																	next <= rw;
// 																end	
							
// 							precharge:						begin
// 																	sd_cs_n <= 1'd0;
// 																	sd_ras_n <= 1'd0;
// 																	sd_cas_n <= 1'd1;
// 																	sd_we_n <= 1'd0;
// 																	sd_dqm_n <= 1'dx;
// 																	sd_io_reg <= 16'dx;
// 																	sd_rc_a <= 12'dx;
// 																	sd_ba <= 2'dx;
// 																	state <= no_operation;
// 																	next <= inhibit;
// 																end
// 						endcase										
// 					end
// 			end
// endmodule















//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//											*SDRAM- Synchronous Dynamic Random Access Memory *																	            																	  				//
//        #1  IN DE2 BOARD THE CLOCK FREQ FOR THE SDRAM DIFFERS FROM 133,143,166 TO 200.																																						//
//        #2  ROW = 4096 BITS																																																																				//
//				#3  COLUMN = 256 BITS																																																																			//
//				#4  FOR EACH MATRIX IT IS = 16 BITS           																																																						//
//				#5  NO. OF BANKS = 4																																																																			//
//				#6  OVERALL MEMORY = 4096*256*16*4 = 67108864 BITS = 67108864/8 = 8.388608MBYTES (8MB APPROX)																															//
//				#7  HERE, THE CLOCK FREQ IS 133MHZ. 																																																											//
//				#8  STATE = INIHIBIT, NO_OPERATION, ACTIVE, READ, WRITE, REFRESH, PRECHARGE.																																							//
//				#9  FOR EVERY 64ms THE 4096 TIMES THE AUTO PRECHARGE AND THE AUTO REFRESH MODE WORKS.																																			//
//				#10	THE REFRESH COUNTER VALUE FOR THE REFRESH STATE IS 4096 WHICH IS EQUAL TO THE NUMBER OF ROWS FOR THE GIVEN 1MB.																				//
//				#11 THE PRECHARGE COUNTER VALUE FOR THE PRECHARGE STATE IS 64ms CALCULATED BY 133 X 10^6 X 64 X 10 ^ (-3) =	8152 																					//														

//				#12 VALUABLE INFORMATION REGARDING SDRAM- 																																																								//
//																1) TRCD - ACTIVE COMMAND TO R/W COMMAND no_operation TIME 																																								//	
//																2) TCK - CLOCK CYCLE TIME 																																																				//
//																3) TRC - ROW CYCLE TIME = MINIMUM ROW ACTIVE TIME (TRAS) + ROW PRECHARGE TIME (TRP) 																							//
// 																4) TREF - REFRESH CYCLE TIME 																																																			//
//																5) REFRESH RATE COUNTER FORMULA = CLOCK FREQ * (TREF (in ms)/ TOTAL NO OF ROWS)																										//
//																																= 133 X 10^6 * (64 X 10^(-3)/4096) 																																//
//																																= 133 X 10^6 * 15.6µS 																																						//
//																																= 2074.8 (2075 APPROX) IS THE COUNTER VALUE																												//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


																							// PIN DESCRIPTION \\

// sd_rc_a = sdram_row_column_address, sd_ba = bank_address, sd_io = sdram_inout, sd_ce_n = sdram_clock_enable, sd_cs_n	= sdram_chip_select, 
//sd_ras_n = sdram_row_address_strobe, sd_cas_n = sdram_column_address_strobe, sd_we_n = write_enable, sd_dqm_n = data_inout_mask (signal like LB UB)																														
																																																																												 

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module sdram_uart_de2	(
								clk_50, reset_n, w_en, r_en, dual_port_out,	//input side of the simple dual port ram\\
								sd_rc_a, sd_ba, sd_clock, sd_io, sd_ce_n, sd_cs_n, sd_ras_n, sd_cas_n, sd_we_n, sd_dqm_n, // input side of the sdram and output for the sdram controller, sd_io is inout pin\\
								tx_wire //uart 
								);
															
							input [7:0] dual_port_out;
							input clk_50;
							input reset_n;
							input w_en, r_en;
							output sd_clock;
							output reg [0:11] sd_rc_a;
							output reg [0:1] sd_ba;
							inout  reg [0:15] sd_io;
							output reg sd_ce_n;
							output reg sd_cs_n;
							output reg sd_ras_n;
							output reg sd_cas_n;
							output reg sd_we_n;
							output reg sd_dqm_n;
							output tx_wire;

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

						parameter inhibit = 4'd0;
						parameter auto_refresh = 4'd1;
						parameter no_operation_1 = 4'd2;
						parameter load_mode_reg = 4'd3;
						parameter no_operation_2 = 4'd4;
						parameter idle = 4'd5;						
						parameter no_operation_3 = 4'd6;
						parameter active = 4'd7;
						parameter no_operation_4 = 4'd8;						
						parameter write = 4'd9;
						parameter no_operation_5 = 4'd10;
						parameter precharge = 4'd11;
						parameter no_operation_6 = 4'd12;
						parameter read = 4'd13;
						parameter no_operation_7 = 4'd14;

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	//assign sd_io_wire = sd_io;
	//localparam sdram_row = 12, sdram_column = 8, bank_width = 4;
	//localparam sdram_address = (sdram_row > sdram_column) ? sdram_row : sdram_column;

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
		//assign sd_clock = sdram_clk;
			
		clk_143 c1(.areset(reset_n), .inclk0(clk_50), .c0(sd_clock));
	
		dual_port_ram  aa1(.clock(sd_clock), .data(dual_port_out), .enable(reset_n), .rdaddress(read_port), .rden(r_en), .wraddress (write_port), .wren(w_en),.q(sd_io_wire));
		
 ////////////////////////////////////////////DUAL PORT RAM INCREMENT AND DECREMENT///////////////////////////////////////////////////////////////////	
		reg [1:0] ram_state;
		reg [6:0] write_port = 7'd0,read_port = 7'd0;
		//wire sdram_clk;
		
		
		
		always@(posedge sd_clock)		
			begin		
				casex(ram_state)
				
					2'b00:begin				 
								if(w_en && ~r_en)
									begin
										ram_state <= 2'b01;
									end
								else if (~w_en && r_en)
									begin
										ram_state <= 2'b10;
									end
								else
									begin
										ram_state <= 2'dx;
									end
							end     

					2'b01:begin
								write_port    <= write_port+7'd1;
								ram_state     <= 2'b00;
							end
				 
					2'b10:begin
								read_port   <= read_port + 7'd1;
								ram_state   <= 2'b00;
							end  
							
					default:ram_state <= 2'b00;	
					
				endcase			
			end

//////////////////////////////////////////////////////// SDRAM CONTROLLER ////////////////////////////////////////////////////////////////////
		
		reg [3:0] state = 4'd0;
		reg [1:0] no_operation_cnt;
		reg [11:0] mode_reg;
		reg [2:0] burst_length = 2'b001;
		reg [2:0] cas_latency = 3'd2; // here it is 2
		reg [1:0] operating_mode = 2'd0;
		reg sequential = 1'd0, burst_mode = 1'd0;
		reg [7:0]wr_cnt, rd_cnt;
		reg [7:0] uart_txn;
		wire [7:0] uart_txn_wire;
		wire enable;
		wire sd_io_wire;
		
//		always@(posedge sdram_clk)
//			begin
//				if(state_sgl)
//					state <= state;
//				else
//					state <= next;
//			end
//					
		always@(posedge sd_clock)
			begin
				if(reset_n)
					begin
						sd_ce_n <= 1'd1;
						sd_cs_n <= 1'd1;
						sd_ras_n <= 1'd1;
						sd_cas_n <= 1'd1;
						sd_we_n <= 1'd1;
						sd_dqm_n <= 1'd1;
						no_operation_cnt <= 2'd0;
						wr_cnt <= 8'd0;
						rd_cnt <= 8'd0;
						state <= 4'd0;
					end
				else
					begin
						sd_io <= sd_io_wire;
						
							casex (state)
							
								inhibit :						begin
																		sd_cs_n <= 1'd1;
																		sd_ras_n <= 1'dx;
																		sd_cas_n <= 1'dx;
																		sd_we_n <= 1'dx;
																		sd_dqm_n <= 1'd1;
																		sd_rc_a <= 12'dx;
																		sd_io <= 16'dx;
																		state <= auto_refresh;
																	end
								
								auto_refresh : 				begin
																		sd_cs_n <= 1'd0;
																		sd_ras_n <= 1'dx;
																		sd_cas_n <= 1'dx;
																		sd_we_n <= 1'dx;
																		sd_dqm_n <= 1'dx;
																		sd_rc_a <= 12'dx;
																		sd_ba <= 2'dx;
																		sd_io <= 16'dx;
																		state <= no_operation_1;
																	end
								
								no_operation_1: 				begin
																		if (no_operation_cnt == 2'd3)
																			begin
																				no_operation_cnt <= 2'd0;
																				state <= load_mode_reg;
																			end
																		else
																			begin
																				no_operation_cnt <= no_operation_cnt + 2'd1;
																				state <= no_operation_1;
																			end																			
																	end	
														
								load_mode_reg:					begin
																		sd_cs_n <= 1'd0;
																		sd_ras_n <= 1'd0;
																		sd_cas_n <= 1'd0;
																		sd_we_n <= 1'd0;
																		sd_dqm_n <= 1'dx;
																		mode_reg <= { sd_rc_a[11], sd_rc_a[10], burst_mode, operating_mode[1:0], cas_latency[2:0], sequential, burst_length[2:0] };
																		state <= no_operation_2;
																	end

								no_operation_2: 				begin
																		if (no_operation_cnt == 2'd3)
																			begin
																				no_operation_cnt <= 2'd0;
																				state <= idle;
																			end
																		else
																			begin
																				no_operation_cnt <= no_operation_cnt + 2'd1;
																				state <= no_operation_2;
																			end																			
																	end

								idle : 							begin
																		sd_cs_n <= 1'd0;
																		sd_ras_n <= 1'd0;
																		sd_cas_n <= 1'd0;
																		sd_we_n <= 1'd0;
																		sd_ba <= 2'dx;
																		state <= no_operation_3;
																	end
																
								no_operation_3: 				begin
																		if (no_operation_cnt == 2'd3)
																			begin
																				no_operation_cnt <= 2'd0;
																				state <= active;
																			end
																		else
																			begin
																				no_operation_cnt <= no_operation_cnt + 2'd1;
																				state <= no_operation_3;
																			end																			
																	end	
																
								active: 							begin
																		sd_cs_n <= 1'd0;
																		sd_ras_n <= 1'd0;
																		sd_cas_n <= 1'd1;
																		sd_we_n <= 1'd1;
																		sd_dqm_n <= 1'dx;
																		sd_rc_a <= 12'd2763;
																		sd_ba <= 2'd2;
																		sd_io <= 16'dx;
																		state <= no_operation_4;
																	end	
																	
								no_operation_4: 				begin
																		if (no_operation_cnt == 2'd3)
																			begin
																				no_operation_cnt <= 2'd0;
																				state <= write;
																			end
																		else
																			begin
																				no_operation_cnt <= no_operation_cnt + 2'd1;
																				state <= no_operation_4;
																			end																			
																	end	


								write:							begin
																		sd_cs_n <= 1'd0;
																		sd_ras_n <= 1'd1;
																		sd_cas_n <= 1'd0;
																		sd_we_n <= 1'd0;
																		sd_dqm_n <= 1'd1;
																		sd_io <= dual_port_out[wr_cnt];
																		sd_rc_a <= {4'dx, 8'd0};
																		sd_ba <= 2'd2;
																			if(wr_cnt <= 8'd255)
																				begin
																					wr_cnt <= wr_cnt + 8'd1;
																					state <= write;
																				end
																			else
																				begin
																					wr_cnt <= 8'd0;
																					state <= no_operation_5;
																				end
																	end	
													
								no_operation_5: 				begin
																		if (no_operation_cnt == 2'd3)
																			begin
																				no_operation_cnt <= 2'd0;
																				state <= precharge;
																			end
																		else
																			begin
																				no_operation_cnt <= no_operation_cnt + 2'd1;
																				state <= no_operation_5;
																			end																			
																	end
								
								precharge:						begin
																		sd_cs_n <= 1'd0;
																		sd_ras_n <= 1'd0;
																		sd_cas_n <= 1'd1;
																		sd_we_n <= 1'd0;
																		sd_dqm_n <= 1'dx;
																		sd_io <= 16'dx;
																		sd_rc_a <= 12'dx;
																		sd_ba <= 2'dx;
																		state <= no_operation_6;
																	end
								no_operation_6: 				begin
																		if (no_operation_cnt == 2'd3)
																			begin
																				no_operation_cnt <= 2'd0;
																				state <= read;
																			end
																		else
																			begin
																				no_operation_cnt <= no_operation_cnt + 2'd1;
																				state <= no_operation_7;
																			end																			
																	end
																	
								read:								begin
																		sd_cs_n <= 1'd0;
																		sd_ras_n <= 1'd1;
																		sd_cas_n <= 1'd0;
																		sd_we_n <= 1'd0;
																		sd_dqm_n <= 1'd1;
																		uart_txn <= sd_io[rd_cnt];
																		sd_rc_a <= {4'dx, 8'd0};
																		sd_ba <= 2'd2;
																			if(rd_cnt <= 8'd255)
																				begin
																					rd_cnt <= rd_cnt + 8'd1;
																					state <= no_operation_7;
																				end
																			else
																				begin
																					rd_cnt <= 8'd0;
																					state <= rd_cnt;
																				end
																	end
																	
								no_operation_7: 				begin
																		if (no_operation_cnt == 2'd3)
																			begin
																				no_operation_cnt <= 2'd0;
																				state <= inhibit;
																			end
																		else
																			begin
																				no_operation_cnt <= no_operation_cnt + 2'd1;
																				state <= no_operation_7;
																			end																			
																	end
								default: 						begin 
																		state <= inhibit;
																	end
							endcase										
					end
			end

			
//uart_top(.clk_50(sdram_clk), .rst_n(reset_n), .data_tx_out(), .data_rx_out());

uart_tx d1(	
			.clk_50 	(clk_50),
        	.rst_n		(reset_n),
			.tx_in (uart_txn),
        	.tx_uart	(tx_wire)
          );

			 
//uart_rx d2(
//			.clk_50   (sdram_clk),
//        	.rst_n    (reset_n),
//        	.uart_rx  (tx_wire),
//        	.data_out (uart_txn_wire)
//          );

endmodule
















































































