module updown_4bit (out,out1,clk,rst);
  parameter n = 4;
  input clk,rst;
  output reg [n-1:0] out,out1;
  always @ (posedge clk)
  begin
    if(rst) 
    begin
      out = 0;
      out1 = out-1;
    end
    else
      begin
      out = out+1;
      out1 = out1-1;
    end
    end
  endmodule

