module uart_tx ( clk_50, rst_n, tx_uart );
	   
	   input clk_50, rst_n;
	   
	   output reg tx_uart;

////////////////////////////////BAUD_CLOCK_GENERATOR////////////////////////////////////////////////////////


reg [11:0] baud_count;     //baud in binary 1010 0010 1100 for 2604
reg baud_clock_out;

    always@(posedge clk_50)
        begin
			if( rst_n )
				begin
					baud_count <= 12'd0;
					baud_clock_out <= 1'd0;
				end
			else
				begin
				   if( baud_count == 2604 )
		    		    begin
    				        baud_clock_out <= ~baud_clock_out;
    				        baud_count <= 12'd0;
    	    		    end
        			else
						begin
							baud_count <= baud_count + 1'b1;		
						end

				end

        end



///////////////////////////////////////DATA_TO_MEM_TRANSFER/////////////////////////////

reg [7:0] mem;
reg [1:0]mem_addr = 2'd0;


always@(clk_50)
	begin
		case(mem_addr)
			2'd0: mem <= 8'h80;
			2'd1: mem <= 8'hC0;
			2'd2: mem <= 8'hE0;
			2'd3: mem <= 8'hF0;
		endcase

	end					


///////////////////////////////tx_uart_FSM///////////////////////////////////////////


reg [1:0] state_tx = 2'd0;
reg [1:0] bit_index = 2'd0;
reg [7:0] data = 8'd0;

always@(posedge baud_clock_out)
	begin
		if( rst_n )
			begin
				data <= 8'd0;
				mem_addr <= 2'd0;
				tx_uart <= 1'd0;
			end
		else
			begin
				case(state_tx)
					2'd0:
						begin
							tx_uart <= 1'd1;
							state_tx <= 2'd1; 
						end
					2'd1:
						begin
							tx_uart <= 1'd0;
							bit_index <= 2'd0;
							data <= mem;
							state_tx <= 2'd2; 
						end
					2'd2:
						begin
							tx_uart <= data[bit_index];
								if (bit_index == 2'd3)
									begin
										bit_index <= 2'd0;
										state_tx <= 2'd3;
									end
								else
									begin
										bit_index <= bit_index + 1'b1;
										state_tx <= 2'd2;
									end
						end
					2'd3:
						begin
							tx_uart <= 1'd1;
								if (mem_addr == 2'd3)
									begin
										mem_addr <= 2'd0;
										state_tx <= 2'd0;
									end
								else
									begin
										mem_addr <= mem_addr + 1'b1;
										state_tx <= 2'd1;
									end
						end
					default :
            			state_tx <= 2'd0;
				endcase		
			end
	end

endmodule