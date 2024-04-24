module decoder (out,en,in);
  input en;
  input [2:0] in;
  output reg [5:0] out;
  always @ (en or in)
  begin
    if(en)
      out=6'b 000000;
    else
      begin
      case (in)
        3'b000 : out=6'b000001;
        3'b001 : out=6'b000010;
        3'b010 : out=6'b000100;
        3'b011 : out=6'b001000;
        3'b100 : out=6'b010000;
        3'b101 : out=6'b100000;
        default : out=6'bx;
      endcase
       end
    end
endmodule   
