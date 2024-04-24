module decoder3to8 (out,in,en);
  input [2:0] in;
  input en;
  output reg [7:0] out;
  always @(in or en)
  begin
    if (en)
      out = 8'b0;
    else
      case (in)
        3'b000 : out = 8'b 00000001;
        3'b001 : out = 8'b 00000010;
        3'b010 : out = 8'b 00000100;
        3'b011 : out = 8'b 00001000;
        3'b100 : out = 8'b 00010000;
        3'b101 : out = 8'b 00100000;
        3'b110 : out = 8'b 01000000;
        3'b111 : out = 8'b 10000000;
    endcase
  end  
endmodule