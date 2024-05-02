module stop_watch_sub(hour,min,secs,clk,rst,stop);
  
  output [3:0]min,secs;
  output [3:0]hour;
  input clk,rst,stop;
  reg [3:0]count,count1,count2;
  reg a,b; //flag signals
  wire sec_clk;
  
fifty_mhz_to_seconds l3(.one_sec(sec_clk),.clk(clk),.rst(rst));
  
always@(posedge sec_clk)
begin
  if(rst)
    begin
      count = 0;
      a = 0;
    end
  else if(count == 4'd9)  //else if(count == 6'd60)
    begin
      count = 0;
      a = ~a;
    end
  else if(stop)
    begin
      count = count;
    end
  else
    begin
      count = count+1'b1;
    end
end
    
always@(a)
begin
  if(rst)
    begin
      count1 = 0;
      b = 0;
    end
  else if(count1 == 4'd9)  //else if(count1 == 6'd60)
    begin
      count1 = 0;
      b = ~b;
    end
  else if(stop)
    begin
      count1 = count1;
    end
  else
    begin
      count1 = count1+1'b1;
    end
end

always@(b)
begin
  if(rst)
    begin
      count2 = 0;
    end
  else if(count2 == 4'd9)  //else if(count2 == 4'd12)
    begin
      count2 = 0;
    end
  else if(stop)
    begin
      count2 = count2;
    end
  else
    begin
      count2 = count2+1'b1;
    end
end
    
assign hour = count2;
assign min = count1;
assign secs = count;

endmodule
