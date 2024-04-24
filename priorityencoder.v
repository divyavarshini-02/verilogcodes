module pencoder (out,in,valid);
  input [3:0] in;
  output valid;
  output reg [1:0] out;
  assign valid = (in == 4'b0000)? 0:1;
  always @ (in)
  begin
       casex (in)
        4'b 0000, 4'b 0001 : out = 2'b00;
        4'b 001x : out = 2'b01;
        4'b 01xx : out = 2'b10;
        4'b 1xxx : out = 2'b11;
      endcase
  end
endmodule
  
