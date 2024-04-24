module demuxusdemux (out,em,a,s);
  input a,em;
  input [1:0] s;
  output [7:0] out;
  submux s1 (out[3:0],(~em),a,s);
  submux s2 (out[7:4],em,a,s);
endmodule
  
module submux (ot,en,b,p);
  input en,b;
  input [1:0] p;
  output reg [3:0] ot;
always @ (en or p or b)
begin
  if(en)
    ot = 4'b0000;
  else
    begin
  case (p)
    2'b00 : ot={3'b000,b};
    2'b01 : ot={2'b00,b,1'b0};
    2'b10 : ot={1'b0,b,2'b00};
    2'b11 : ot={b,3'b000};
  endcase
    end
end 
endmodule