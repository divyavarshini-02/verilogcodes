module bcd_7seg1(input [4:0] in,
                output reg[7:0]out
					 );
always @(in)
begin
case (in)
                          4'd0:out<=8'b00000001;
                          4'd1:out<=8'b01001111;
                          4'd2:out<=8'b00010010;
                          4'd3:out<=8'b00000110;
                          4'd4:out<=8'b01001100;
                          4'd5:out<=8'b00100100;
                          4'd6:out<=8'b00100000;
                          4'd7:out<=8'b00001111;
                          4'd8:out<=8'b00000000;
                          4'd9:out<=8'b00000100;
                    
                          default: out <= 8'b01111111;
								  endcase
								  end
								  endmodule