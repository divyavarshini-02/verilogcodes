module bcd_7seg(input [4:0] in,
                output reg[6:0]out
					 );
always @(in)
begin
case (in)
                          4'd0:out<=7'b0000001;
                          4'd1:out<=7'b1001111;
                          4'd2:out<=7'b0010010;
                          4'd3:out<=7'b0000110;
                          4'd4:out<=7'b1001100;
                          4'd5:out<=7'b0100100;
                          4'd6:out<=7'b0100000;
                          4'd7:out<=7'b0001111;
                          4'd8:out<=7'b0000000;
                          4'd9:out<=7'b0000100;
                    
                          default: out <= 7'b1111111;
								  endcase
								  end
								  endmodule