module trans_seq (trout,in,clk);
  input clk;
  input [7:0] in;
  output reg trout;
  reg [3:0]cnt =0;
  reg  start;
  reg stop;
  reg [1:0]pstate;
  parameter ideal=2'b00,active=2'b01,trans=2'b10;
  always @ (posedge clk)
  begin
    case (pstate)
     ideal : 
          begin
            start = 1;
            trout = start;
            pstate = active ;
          end
    active : 
           begin
            start = 0;
            trout = start; 
            pstate = trans;
          end
      trans: if (cnt <=7)
           begin
           trout = in[cnt];
           cnt = cnt+1;
           end
           else
             begin
             cnt = 0;
             stop = 1;
             trout = stop;
             pstate = ideal;
        end
        default:pstate = ideal;
         endcase
end
endmodule
module rec_seq(rcout,in,clk);
  input clk;
  input [7:0]in;
  output reg rcout;
  reg [3:0]cnt =0;
  reg  start,trout;
  reg stop;
  reg [1:0]pstate;
  parameter ideal=2'b00,active=2'b01,trans=2'b10,receive=2'b11;
  always @ (posedge clk)
  begin
    case (pstate)
     ideal : 
          begin
            start = 1;
            trout = start;
            rcout = 1'bz;
            pstate = active ;
          end
    active : 
           begin
            start = 0; 
            trout = start;
            rcout = 1'bz;
            pstate = trans;
          end
      trans: if(cnt==0)
           begin
           trout = in[cnt];
           cnt = cnt+1;
         end
       else
           pstate = receive;
       receive:if(cnt <=8)
           begin
           rcout = trout;
           trout = in[cnt];
           cnt = cnt +1;
           pstate = receive;  
         end  
           else
             begin
             cnt = 0;
             stop = 1;
             trout = stop;
             rcout = 1'bz;
             pstate = ideal;
        end
        default:pstate = ideal;
         endcase
end
endmodule
