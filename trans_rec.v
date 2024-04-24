module trans (trout,in,clk);
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
      trans: if (cnt <=8)
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

module rec (rcout,in,clk);
  input clk;
  input in;
  output reg [7:0] rcout;
  reg [3:0]cnt =0;
  reg start;
  reg stop;
  reg [1:0]pstate;
  reg [8:0]rcoutx;
  parameter ideal = 2'b00,active=2'b01,receive=2'b10;
  always @ (posedge clk)
  begin
    case (pstate)
       ideal : 
          begin
            start = 1;
            pstate = active ;
          end
       active : 
           begin
            start = 0; 
            pstate = receive;
          end
      receive: if (cnt <=8)
           begin
           rcoutx[cnt] =in;
           rcout=rcoutx[8:1];
           cnt = cnt+1;
           end
           else
             begin
             cnt = 0;
             stop = 1;
            rcoutx = 9'bx;
            rcout = rcoutx[8:1];
             pstate = ideal;
        end
        default: begin
        pstate = ideal;
      end
         endcase  
end
endmodule

 module trans_rec(out,in,clk);
   input clk;
   input [7:0] in;
   output [7:0] out;
   wire wr;
   trans ss1 (.trout(wr),.in(in),.clk(clk));
   rec ss2 (.rcout(out),.in(wr),.clk(clk));
 endmodule
   
   
