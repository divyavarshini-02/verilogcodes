module sdram_uart_de2	(
								clk_50, reset_n,// w_en, r_en, dual_port_out,	//input side of the simple dual port ram\\
								sd_rc_a, sd_ba, sd_clock, sd_io, sd_ce_n, sd_cs_n, sd_ras_n, sd_cas_n, sd_we_n, sd_dqm_n, // input side of the sdram and output for the sdram controller, sd_io is inout pin\\
								tx_wire, uart_tx_out //uart 
								);
															
							//input [7:0] dual_port_out;
							input clk_50;
							input reset_n;
							//input w_en, r_en;ii
							output sd_clock;
							output reg [11:0] sd_rc_a;
							output reg [1:0] sd_ba;
							inout  [15:0] sd_io;
							output reg sd_ce_n;
							output reg sd_cs_n;
							output reg sd_ras_n;
							output reg sd_cas_n;
							output reg sd_we_n;
							output reg sd_dqm_n;
							output tx_wire;
							output [7:0]uart_tx_out;
							//output empty, full;

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
		

			
		// clk_143 ca1(.areset(reset_n), .inclk0(clk_50), .c0(sdram_clk), .c1(sdram_200_clk));
			
		// //dual_port_ram  aa1(.clock(sdram_clk), .data(dual_port_out), .enable(reset_n), .rdaddress(read_port), .rden(r_en), .wraddress (write_port), .wren(w_en),.q(sd_io_wire));
		
		//  ROM aa1 (.address(write_port), .clock(clk_50), .q(sd_io_wire));
		
		
 ////////////////////////////////////////////DUAL PORT RAM INCREMENT AND DECREMENT///////////////////////////////////////////////////////////////////	
		//reg [1:0] ram_state;
		reg [7:0] write_port=8'd0;
		wire sdram_clk;
		wire sdram_200_clk;
		
//		
//		
//		always@(posedge sdram_clk)		
//			begin		
//				casex(ram_state)
//				
//					2'b00:begin				 
//								if(w_en && ~r_en)
//									begin
//										ram_state = 2'b01;
//									end
//								else if (~w_en && r_en)
//									begin
//										ram_state = 2'b10;
//									end
//								else
//									begin
//										ram_state = 2'dx;
//									end
//							end     
//
//					2'b01:begin
//								write_port    = write_port+7'd1;
//								ram_state     = 2'b00;
//							end
//				 
//					2'b10:begin
//								read_port   = read_port + 7'd1;
//								ram_state   = 2'b00;
//							end  
//							
//					default:ram_state = 2'b00;	
//					
//				endcase			
//			end

//////////////////////////////////////////////////////// SDRAM CONTROLLER ////////////////////////////////////////////////////////////////////
		
		reg [3:0] state = 4'd0;
		reg [1:0] no_operation_cnt = 2'd0;
		reg [11:0] mode_reg = 12'd0;
		reg [2:0] burst_length = 2'b001;
		reg [2:0] cas_latency = 3'd2; // here it is 2
		reg [1:0] operating_mode = 2'd0;
		reg sequential = 1'd0, burst_mode = 1'd0;
		reg [7:0] rd_cnt = 8'd0;
		reg [7:0] uart_txn = 8'd1;
		//wire [7:0] uart_txn_wire;
		//wire enable;
		wire [7:0] sd_io_wire = 8'd45;
		reg [7:0] sd_io_reg;
		reg en_uart;
		
		assign sd_io = {8'd0,sd_io_reg};
		
		assign sd_clock = sdram_clk;
				
		always@(posedge sd_clock or posedge reset_n)
			begin
				if(reset_n)
					begin
						sd_ce_n = 1'd1;
						sd_cs_n = 1'd1;
						sd_ras_n = 1'd1;
						sd_cas_n = 1'd1;
						sd_we_n = 1'd1;
						sd_dqm_n = 1'd1;
						no_operation_cnt = 2'd0;
						state = inhibit;
						sd_rc_a = 12'd0;
						uart_txn = 8'd1;
						mode_reg = 12'd0;
						en_uart = 1'b0;
					end
				else
					begin
						
						//en_uart = 1'b0;
						
							case(state)
							
								inhibit :						begin
																		sd_cs_n = 1'd1;
																		sd_ras_n = 1'dx;
																		sd_cas_n = 1'dx;
																		sd_we_n = 1'dx;
																		sd_dqm_n = 1'd1;
																		sd_rc_a = 12'dx;
																		sd_io_reg = 8'dx;
																		state = auto_refresh;
																	end
								
								auto_refresh : 				begin
																		sd_cs_n = 1'd0;
																		sd_ras_n = 1'dx;
																		sd_cas_n = 1'dx;
																		sd_we_n = 1'dx;
																		sd_dqm_n = 1'dx;
																		sd_rc_a = 12'dx;
																		sd_ba = 2'dx;
																		sd_io_reg = 8'dx;
																		state = no_operation_1;
																	end
								
								no_operation_1: 				begin
																		sd_cs_n = 1'd0;
																		sd_ras_n = 1'd1;
																		sd_cas_n = 1'd1;
																		sd_we_n = 1'd1;
																		if (no_operation_cnt == 2'd3)
																			begin
																				no_operation_cnt = 2'd0;
																				state = load_mode_reg;
																			end
																		else
																			begin
																				no_operation_cnt = no_operation_cnt + 2'd1;
																				state = no_operation_1;
																			end																			
																	end	
														
								load_mode_reg:					begin
																		sd_cs_n = 1'd0;
																		sd_ras_n = 1'd0;
																		sd_cas_n = 1'd0;
																		sd_we_n = 1'd0;
																		sd_dqm_n = 1'dx;
																		mode_reg = { sd_rc_a[11], sd_rc_a[10], burst_mode, operating_mode[1:0], cas_latency[2:0], sequential, burst_length[2:0] };
																		state = no_operation_2;
																	end

								no_operation_2: 				begin
																		sd_cs_n = 1'd0;
																		sd_ras_n = 1'd1;
																		sd_cas_n = 1'd1;
																		sd_we_n = 1'd1;
																		if (no_operation_cnt == 2'd3)
																			begin
																				no_operation_cnt = 2'd0;
																				state = idle;
																			end
																		else
																			begin
																				no_operation_cnt = no_operation_cnt + 2'd1;
																				state = no_operation_2;
																			end																			
																	end

								idle : 							begin
																		sd_cs_n = 1'd0;
																		sd_ras_n = 1'd0;
																		sd_cas_n = 1'd0;
																		sd_we_n = 1'd0;
																		sd_ba = 2'dx;
																		sd_io_reg = mode_reg[7:0];
																		state = no_operation_3;
																	end
																
								no_operation_3: 				begin
																		sd_cs_n = 1'd0;
																		sd_ras_n = 1'd1;
																		sd_cas_n = 1'd1;
																		sd_we_n = 1'd1;
																		if (no_operation_cnt == 2'd3)
																			begin
																				no_operation_cnt = 2'd0;
																				state = active;
																			end
																		else
																			begin
																				no_operation_cnt = no_operation_cnt + 2'd1;
																				state = no_operation_3;
																			end																			
																	end	
																
								active: 							begin
																		sd_cs_n = 1'd0;
																		sd_ras_n = 1'd0;
																		sd_cas_n = 1'd1;
																		sd_we_n = 1'd1;
																		sd_dqm_n = 1'dx;
																		sd_rc_a = 12'd2763;
																		sd_ba = 2'd2;
																		sd_io_reg = 8'dx;
																		state = no_operation_4;
																	end	
																	
								no_operation_4: 				begin
																		sd_cs_n = 1'd0;
																		sd_ras_n = 1'd1;
																		sd_cas_n = 1'd1;
																		sd_we_n = 1'd1;
																		if (no_operation_cnt == 2'd3)
																			begin
																				no_operation_cnt = 2'd0;
																				state = write;
																			end
																		else
																			begin
																				no_operation_cnt = no_operation_cnt + 2'd1;
																				state = no_operation_4;
																			end																			
																	end	

								write:								begin
																		sd_cs_n = 1'd0;
																		sd_ras_n = 1'd1;
																		sd_cas_n = 1'd0;
																		sd_we_n = 1'd0;
																		sd_dqm_n = 1'd1;
																		sd_rc_a = {4'dx, 8'd0};
																		sd_ba = 2'd2;
																			if(write_port == 8'd255)
																				begin
																					write_port = 8'd0;
																					sd_io_reg = sd_io_wire;
																					state = no_operation_5;																					
																				end
																			else
																				begin
																					write_port = write_port + 8'd1;
																					sd_io_reg = sd_io_wire;//[write_port];
																					state = write;
																				end
																	end	
														
								no_operation_5: 				begin
																		sd_cs_n = 1'd0;
																		sd_ras_n = 1'd1;
																		sd_cas_n = 1'd1;
																		sd_we_n = 1'd1;
																		if (no_operation_cnt == 2'd3)
																			begin
																				no_operation_cnt = 2'd0;
																				state = precharge;
																			end
																		else
																			begin
																				no_operation_cnt = no_operation_cnt + 2'd1;
																				state = no_operation_5;
																			end																			
																	end
								
								precharge:						begin
																		sd_cs_n = 1'd0;
																		sd_ras_n = 1'd0;
																		sd_cas_n = 1'd1;
																		sd_we_n = 1'd0;
																		sd_dqm_n = 1'dx;
																		sd_io_reg = 8'dx;
																		sd_rc_a = 12'dx;
																		sd_ba = 2'dx;
																		state = no_operation_6;
																	end
																	
								no_operation_6: 				begin
																		sd_cs_n = 1'd0;
																		sd_ras_n = 1'd1;
																		sd_cas_n = 1'd1;
																		sd_we_n = 1'd1;
																		if (no_operation_cnt == 2'd3)
																			begin
																				no_operation_cnt = 2'd0;
																				rd_cnt = 8'd0;
																				state = read;
																			end
																		else
																			begin
																				no_operation_cnt = no_operation_cnt + 2'd1;
																				state = no_operation_6;
																			end																			
																	end
																	
								read:								begin
																		sd_cs_n = 1'd0;
																		sd_ras_n = 1'd1;
																		sd_cas_n = 1'd0;
																		sd_we_n = 1'd0;
																		sd_dqm_n = 1'd1;
																		sd_rc_a = {4'dx, 8'd0};
																		sd_ba = 2'd2;
																		sd_io_reg = sd_io_wire;
																			if(rd_cnt == 8'd255)
																				begin
																					rd_cnt = 8'd0;
																					uart_txn = 8'd1;
																					en_uart = 1'b1;
																					state = read;
																					
																				end
																			else
																				begin
																					rd_cnt = rd_cnt + 8'd1;
																					en_uart = 1'b1;
																					uart_txn = sd_io_reg;//[rd_cnt];
																					state = no_operation_7;
																				end
																	end
																
								no_operation_7: 				begin
																		sd_cs_n = 1'd0;
																		sd_ras_n = 1'd1;
																		sd_cas_n = 1'd1;
																		sd_we_n = 1'd1;
																		if (no_operation_cnt == 2'd3)
																			begin
																				no_operation_cnt = 2'd0;
																				state = read;
																			end
																		else
																			begin
																				no_operation_cnt = no_operation_cnt + 2'd1;
																				state = no_operation_7;
																			end																			
																	end
								default: 						begin 
																		state = inhibit;
																	end
							endcase										
					end
			end



 uart_tx d1(
         .tx_clk(clk_50),
         .tx_reset(reset_n),
			.tx_in(uart_txn),
        .mem_r_en(en_uart),
        .tx_out(tx_wire)
			);

sipo s1(.y	(uart_tx_out),
		  .clk	(clk_50),
		  .enable(reset_n),
		  .m(tx_wire));	

endmodule





		  
//uart_rx d2(
//			.clk_50   (sdram_clk),
//        	.rst_n    (reset_n),
//        	.uart_rx  (tx_wire),
//        	.data_out (uart_txn_wire)
//          );
			
//uart_top(.clk_50(sdram_clk), .rst_n(reset_n), .data_tx_out(), .data_rx_out());

//sdram_2_uart aa3(.data(uart_txn),
//	rdclk(clk_50),
//	rdreq(r_en),
//	wrclk(sd_clock),
//	wrreq(w_en),
//	q(tx_wire),
//	rdempty(empty),
//	wrfull(full));




























