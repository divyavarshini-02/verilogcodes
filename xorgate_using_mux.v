module gateusmux (out,a,b);
  input a,b;
  output reg out;
  always @(a or b)
  begin
    case (a)
      1'b 0 : out = b;
      1'b 1 : out = (~b);
    endcase
  end
endmodule
  
      
      
      
