module fifty_mhz_to_seconds(one_sec,clk,rst);
  output one_sec;
  input clk,rst;
  reg [25:0]count;
  
always@(posedge clk)
begin

if(rst)
  begin
    count = 26'd0;
  end
else if(count < 26'd50000000)
  begin
    count = count+1'b1;
  end
else
  count = 26'd0;
  
end

assign one_sec = (count < 26'd25000000) ? 1'b1 : 1'b0;

endmodule
