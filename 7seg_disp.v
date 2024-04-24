module clk_div(clkin,clkout);
  input clkin;
  output reg clkout=1;
  reg [25:0]cnt=1;
  parameter n=50000000;
  always @(posedge clkin)
  begin
    if(cnt == n/2)
      begin
      clkout <= ~clkout;
      cnt<=1;
      end
  else
      cnt<=cnt+1;
  end
endmodule

module seg_disp(clk,a,b);
  input clk; 
  output  reg [6:0]a,b;
  reg [3:0]count1=0;
  reg [3:0]count2=0;
  wire clkout; 
  clk_div ss1(.clkin(clk),.clkout(clkout));
  always @ (posedge clkout)
  begin
    
    if(count2<=9)
     
      begin
        
      case(count2)
    
     4'b0000:b<=7'b0111111;
     4'b0001:b<=7'b0000110;
     4'b0010:b<=7'b1011011;
     4'b0011:b<=7'b1001111;
     4'b0100:b<=7'b1100110;
     4'b0101:b<=7'b1101101;
     4'b0110:b<=7'b1111101;
     4'b0111:b<=7'b0000111;
     4'b1000:b<=7'b1111111;
     4'b1001:b<=7'b1101111;
     
   endcase 
   
       if(count1<=9)
      
      begin
   
   case(count1)
     
     4'b0000:a<=7'b0111111;
     4'b0001:a<=7'b0000110;
     4'b0010:a<=7'b1011011;
     4'b0011:a<=7'b1001111;
     4'b0100:a<=7'b1100110;
     4'b0101:a<=7'b1101101;
     4'b0110:a<=7'b1111101;
     4'b0111:a<=7'b0000111;
     4'b1000:a<=7'b1111111;
     4'b1001:a<=7'b1101111;
     
   endcase
   
   count1<=count1+1;
   
      end
      
   else
     
     begin
     count1<=0;
   count2<=count2+1;
     end
   end
   
   else
      count2<=0;
    end
  endmodule
     
     
      
      
      
      
      
      
    
      
      
  
  


  
  
  
