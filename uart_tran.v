module brcal (clkout,clk);
  input clk;
  output reg clkout = 0;
  reg [3:0] count =0;
  always @ (posedge clk)
  begin
    if 
    (count == 2603)
   begin 
      clkout = ~clkout;
      count =0;
    end
    else
      count = count+1;
    end
endmodule

module trans (trout,in,clk);
  input clk;
  input [7:0] in;
  output reg trout;
  reg [3:0]cnt =0;
  reg  start;
  reg stop;
  reg [1:0]pstate;
  wire clkout;
  parameter ideal=2'b00,active=2'b01,trans=2'b10;
  brcal q1 (.clkout(clkout),.clk(clk));
  always @ (posedge clkout)
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
module rec (rcout,in,clk);
  input clk;
  input in;
  output  [7:0] rcout;
  reg [3:0]cnt =0;
  reg start;
  reg stop;
  reg [1:0]pstate;
  reg [8:0]rcoutx;
  assign rcout=rcoutx[8:1];
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
           cnt = cnt+1;
           end
           else
             begin
             cnt = 0;
             stop = 1;
             pstate = ideal;
        end
        default:pstate = ideal;
         endcase  
end
endmodule

        
        
            
  

      
    
