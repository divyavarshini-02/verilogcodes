module mod_10 (q,clk,rst);
  input clk,rst;
  output reg [3:0]q;
  always @ (posedge clk)
  begin
   if(rst)
   q = 4'b0000;
   else 
     begin
    if ((q[3] && q[0]) == 1)
      q = 4'b0000;
    else
      q = q+1;
    end
   end
 endmodule
  
      
   
  
  
  
 