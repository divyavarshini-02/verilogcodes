module i2c(sda, sclk, reset, en, clk);
inout sda;
output reg sclk;
input reset, clk, en;
reg [2:0]count=3'b000;
always@(posedge clk)
begin 
  if(reset)
    sclk<=1'b0;
  else if(count==3'b011)
    begin
        sclk<=~sclk;
        count <= count + 1; end
  else if ( count == 3'b111)begin
       sclk<=~sclk;
       count<=0;end
  else
     count <= count + 1;
     
end
endmodule
      