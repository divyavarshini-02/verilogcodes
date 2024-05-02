module clk_1( rst,clk_50,clk_1hz);

input rst;
input clk_50;
output reg clk_1hz;

reg [24:0] count=25'd0;
					
always @(posedge clk_50 or negedge rst)
begin
if(!rst)
begin
count<=25'd0;
clk_1hz<=1'b0;
end
else 
  if(count<25'd24999999)
 begin
  count<=count+1'b1;
  clk_1hz<=clk_1hz;
  end
  else 
  begin
   clk_1hz<=~clk_1hz;
	count<=25'd0;
	end
	end
	endmodule