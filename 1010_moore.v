module moore_state (out,in,clk,rst);
  parameter s0=3'b000,s1=3'b001,s2=3'b010,s3=3'b011,s4=3'b100;
  input in,clk,rst;
  output reg out;
  reg [2:0]state;
  always @(posedge clk)
  begin
    if (rst)
      begin
      state = s0;
      out = 0;
    end
    else 
      begin
      case(state)
        s0:begin
         if(in)
           state = s1;
         else
           state =s0;
         end
        s1:begin
           out = 0;
           if(in)
           state = s1;
         else
           state = s2;
         end
         s2:begin
           out = 0;
           if(in)
           state = s3;
         else
           state = s0;
         end
         s3:begin
           out = 0;
           if(in)
           state = s1;
         else
           state = s4;
         end
         s4:begin
           out = 1;
           if(in)
           state = s3;
         else
           state = s0;
         end
       endcase
     end
   end
     endmodule
           
           
           
                  
    
