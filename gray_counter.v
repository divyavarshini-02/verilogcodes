module gray_counter (q,clk,reset);
  input clk,reset;
  output reg [3:0]q;
  reg [3:0]temp;
  always @ (posedge clk)
  begin
    if(reset)
      begin
        q = 0;
        temp = 0;
      end   
     else
      begin
        temp =temp +1;
        q[3] <= temp[3];
        q[2] <= (temp[3] ^ temp[2]);
        q[1] <= (temp[2] ^ temp[1]);
        q[0] <= (temp[1] ^ temp[0]);
      end
   end
endmodule

  
