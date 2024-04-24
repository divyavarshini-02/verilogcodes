module gearbox(clk,data,op,syn);
  input clk;
  input [1:0] syn;
  input [63:0] data;
  output reg [15:0]op;  
  //reg
  reg [2:0]cnt=3'b0;
  reg [7:0]n=8'd15;
  
  always @ (posedge clk)
  begin
    if(cnt<1)
      begin
        op<={data[13:0],syn[1],syn[0]};
        n<=n+8'd16;
        cnt<=cnt+1;
      end
  else if(cnt>=1 && cnt<4)
      begin
        op<=data[n-:18];
        n<=n+8'd16;
        cnt<=cnt+1;
      end
    else if(cnt==4)
      begin
        op<={14'b0,data[63],data[62]};
        n<=8'd30;
        cnt<=3'b0;
      end     
   end   
   
endmodule 

// data = 101011111010111011011011011010111110101010111110101111011011011011
        
      
               


        
         
    
  
