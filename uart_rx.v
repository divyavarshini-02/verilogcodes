module uart_rx (clk_50, rst_n, uart_rx, data_out);
		
		input clk_50, rst_n, uart_rx;
		
		output reg [7:0] data_out;

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


/////////////////////////////UART_RX_FSM////////////////////////




reg [1:0] state_rx = 2'd0;
reg [1:0] bit_index_rx = 2'd0;


always@(posedge clk_50)
	begin
		if( rst_n )
			begin
				bit_index_rx <= 2'd0;
				data_out <= 8'd0;
			end
		else
			begin
				case(state_rx)
					2'd0:
						begin
							if (uart_rx == 1'b0)
								begin
									state_rx <= 2'd1;
								end
							else
								begin
									state_rx <= 2'd0;
								end
							
						end
					2'd1:
						begin
							data_out[bit_index_rx] <= uart_rx;
								if(bit_index_rx == 2'd3)
									begin
										bit_index_rx <= 2'd0;
										state_rx <= 2'd2;
									end
								else
									begin
										bit_index_rx <= bit_index_rx + 1'b1;
										state_rx <= 2'd1;
									end
						end
					2'd2:
						begin
				            if(uart_rx == 1'b1)
								begin
                					state_rx <= 2'd0;
								end
              				else
								begin
                					state_rx <= 2'd2;
								end
            			end
					default :
            			state_rx <= 2'd0;	
				endcase		
			end
	end

endmodule
