module top_uart(clk,reset,y,d,err,clr);
			
				input   clk,reset;
			
				output  y;
			
				output	[9:0]d;
			
				output	err,clr;
			
				wire  tx;


				uart_tx u1	(
							.clk		(clk),
							.reset      (reset),
							.y			(y),
							.tx         (tx)
							);


				uart_rx u2	(
							.d		(d),
							.rst	(reset),
							.err	(err),
							.clr	(clr),
							.clk	(clk),
							.rx		(tx)
							);

endmodule