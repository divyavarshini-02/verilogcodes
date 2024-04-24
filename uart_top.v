module uart_top(clk_50, rst_n, data_tx_out, data_rx_out);
				input  clk_50, rst_n;
                output data_tx_out;
                output [7:0] data_rx_out;
                
wire data_rx_in;     

assign data_rx_in = data_tx_out;           
                
uart_tx d1(	
			.clk_50 	(clk_50),
        	.rst_n		(rst_n),
        	.tx_uart	(data_tx_out)
          );

uart_rx d2(
			.clk_50   (clk_50),
        	.rst_n    (rst_n),
        	.uart_rx  (data_rx_in),
        	.data_out (data_rx_out)
          );

endmodule
