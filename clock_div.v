module clock_div (out,clk);
  input clk;
  output reg out=0;
  always @ (posedge clk)
  begin
    out = ~out;
  end
endmodule
module clock_div_4clk (out,clk);
  input clk;
  output reg out=0;
 reg [1:0]count=0;
  always @ (posedge clk)
  begin
     if(count == 2'b11)
        begin
        out = ~out;
      count =0;   
  end  
  else
    begin
     count = count+1;
  end
 end
endmodule
