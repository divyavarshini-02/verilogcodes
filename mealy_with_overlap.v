module seq_overlap (out,in,rst,clk);
  input rst,clk,in;
  parameter s0=2'b00,s1=2'b01,s2=2'b10;
  output reg out;
  reg [1:0]state,nstate;
  always @ (posedge clk)
  begin
    if(rst)
      state = s0;
    else
      state = nstate;
  end 
  always @ (state or in)
  begin
    case (state)
      s0 : if(in)
              begin
           nstate = s1;
            out = 0;
              end
           else
              begin
           nstate =s0;
            out = 0;
              end      
      s1 : if(in)
              begin
           nstate = s1;
            out = 0;
              end
           else
              begin
           nstate =s2;
            out = 0;
              end      
       s2 : if(in)
              begin
           nstate = s1;
            out = 0;
              end
           else
              begin
           nstate =s0;
            out = 1;
              end 
            endcase
   end
endmodule     
  
