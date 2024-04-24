module receives (rcout,r,in,clk);
  input clk;
  input in;
  output reg r;
  output  reg [7:0]rcout;
  reg [3:0]cnt =0;
  reg [1:0]pstate;
  parameter ideal = 2'b00,active=2'b01,receive=2'b10;
  always @ (posedge clk)
  begin
    case (pstate)
       ideal : 
          begin
            r<=1;
            pstate <= active ;
          end
       active : 
           begin 
             r<=0;
            pstate <= receive;
          end
      receive:
      begin
       if (cnt <=8)
           begin
              cnt <= cnt+1;
           r <=in;
           rcout[cnt-1]<=r;
          
           end
           else
             begin
             cnt<= 0;
             rcout<=8'b0;
             r<=1;
             pstate<= active;
        end
      end
        default:pstate <= ideal;
         endcase  
end
endmodule

