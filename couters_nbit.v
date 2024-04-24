module nbit_john (q,clk,rst);
parameter n= 4;
input clk,rst;
output reg [n-1:0] q;
always @ (posedge clk)
 begin
   if(rst)
   q = 0;
 else
   q <= {~q[0],q[n-1:1]};
 end
endmodule

module nbit_ring (q,clk,rst);
parameter n= 4;
input clk,rst;
output reg [n-1:0] q;
always @ (posedge clk)
 begin
   if(rst)
     begin
   q = 0;
   q = q+1;
     end
 else
   q <= {q[0],q[n-1:1]};
 end
endmodule
module nbit_gray (q,clk,load);
  parameter n =4;
  input clk,load;
  output reg [n-1:0]q;
  reg [n-1:0]temp;
  always @ (posedge clk)
  begin
    if(load)
      begin
      q = 0;
      temp = 0;
      temp = temp+1;
     end   
     else
      begin 
     q =((temp >> 1) ^ temp);
     temp =temp +1;
      end
   end
   endmodule
module nbit_ring_shift (q,clk,rst);
parameter n= 4;
input clk,rst;
output reg [n-1:0] q;
always @ (posedge clk)
 begin
   if(rst)
     begin
   q = 0;
   q = q+1;
     end
 else
   begin
   q[n-1] <= q[0];
   q[n-2:0] <= q[n-1:1];
   end
 end
endmodule



   
 
