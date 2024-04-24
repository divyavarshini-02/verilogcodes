module i2c_new(sda,clk);
  inout sda;
  input clk;
  reg clkout=1;
  reg clt;
  reg sda1;
  assign sda=sda1;
  always @ (posedge clk or negedge clk)
  begin
    if(clt)
      clkout<=clkout;
    else 
      clkout<=~clkout;
  end
endmodule