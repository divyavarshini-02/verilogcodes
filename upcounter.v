module up_4syn (out,in,clk,rst);
  input [3:0] in;
  input clk,rst;
  output reg [3:0] out;
  always @ (posedge clk)
  begin
    if(rst)
      out = in;
    else
      out = out + 1;
    end
  endmodule
  
module up_4asyn (out,in,clk,rst,load);
  input [3:0] in;
  input clk,rst,load;
  output reg [3:0] out;
  always @ (posedge clk or posedge rst)
  begin
    if(load)
      out = in;
    else
      out = out + 1;
    end
  endmodule
  
module down_4asyn (out,in,clk,rst,load);
  input [3:0] in;
  input clk,rst,load;
  output reg [3:0] out;
  always @ (posedge clk or posedge rst)
  begin
    if(load)
      out = in;
    else
      out = out - 1;
    end
  endmodule
  

  
