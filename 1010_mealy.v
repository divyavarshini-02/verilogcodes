module melay_wlap(out,in,clk,rst,wl);
  input rst,clk,in,wl;
  parameter s0=2'b00,s1=2'b01,s2=2'b10,s3=2'b11;
  output reg out;
  reg [1:0]state,nstate;
  always @ (posedge clk)
  begin
    if(rst)
      state = s0;
    else
      state = nstate;
  end 
  always @ (state or in or wl)
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
           nstate = s3;
            out = 0;
              end
           else
              begin
           nstate =s0;
            out = 0;
              end 
        s3 : if(wl)
            begin
            if(in)
              begin
           nstate = s1;
            out = 0;
              end
           else
              begin
           nstate =s2;
            out = 1;
              end 
            end
          else
             begin
            if(in)
              begin
           nstate = s1;
            out = 0;
              end
           else
              begin
           nstate =s0;
            out = 1;
              end 
             end
            endcase    
   end
endmodule     
