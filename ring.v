module john_ring (q,clk,rst);
input clk,rst;
output reg [3:0] q;
always @ (posedge clk)
 begin
 if(rst)
 q = 0;
 else
 begin 
 q[3] <= ~q[0];
 q[2] <= q[3];
 q[1] <= q[2];
 q[0] <= q[1];
 end
 end 
endmodule
 
