module bcd_7segment (out,in,en);
input [3:0] in;
input en;
output reg [6:0] out;
always @ (in,en) 
begin
  if (en)
    out = 7'b 0000000;
  else if (in == 4'b0000)
    out = 7'b 1111110;
  else if (in == 4'b0001)
    out = 7'b 0110000;
  else if (in == 4'b0010)
    out = 7'b 1101101;
  else if (in == 4'b0011)
    out = 7'b 1111001;
  else if (in == 4'b0100)
    out = 7'b 0110011;
  else if (in == 4'b0101)
    out = 7'b 1011011;
  else if (in == 4'b0110)
    out = 7'b 1011111;
  else if (in == 4'b0111)
    out = 7'b 1110000;
  else if (in == 4'b1000)
    out = 7'b 1111111;
  else if (in == 4'b1001)
    out = 7'b 1110011;
  else
    out = 7'bx;
end
endmodule    
  
  
  
  