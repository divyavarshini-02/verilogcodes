module brcal (clkout,clk);
  input clk;
  output reg clkout = 0;
  reg [11:0] count =0;
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
module uart_trans(tout,clk);
  input clk;
  output reg tout;
  reg [7:0]trout;
  reg  start;
  reg stop;
  reg [1:0]pstate;
  reg [3:0]cnt = 0;
  reg [3:0]addr=0;
  reg [7:0]mem[0:9];
  parameter ideal=2'b00,active=2'b01,trans=2'b10;
  always @ (posedge clk)
  begin
    case (pstate)
     ideal : 
          begin
            start = 1;
            tout = start;
            pstate = active ;
          end
    active : 
           begin
            start = 0;
            tout = start;
            mem[0] = 8'b00000001;
            mem[1] = 8'b00000011;
            mem[2] = 8'b00000111;
            mem[3] = 8'b00001111;
            mem[4] = 8'b00011111;
            mem[5] = 8'b00111111;
            mem[6] = 8'b01111111;
            mem[7] = 8'b11111111;
            mem[8] = 8'b10000000;
            mem[9] = 8'b11000000;
            pstate = trans;
          end
      trans:
           if (addr <=9)
           begin
           trout = mem[addr];
           if(cnt <=8)
             begin
           tout = trout[cnt];
           cnt = cnt +1;
             end
           else
             begin
             cnt=0;
            stop =1;
           tout = stop;
           addr = addr+1;
           pstate = ideal;
             end
           end
           else
             begin
             addr = 0;
             pstate = ideal;
        end
        default:pstate = ideal;
         endcase
end
endmodule 
module uart_memory_rec (rcout,in,clk);
  input clk;
  input in;
  output  reg [7:0]rcout;
  reg [3:0]cnt =0;
  reg start;
  reg stop;
  reg [1:0]pstate;
  reg [8:0]rcoutx;
  reg [3:0]addr=0;
  reg [7:0]mem[0:9];
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
            stop = 0;
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
             if(addr <=9)
               begin
               mem[addr]=rcout;
               addr=addr+1;
               pstate=ideal;
                end
            else
              begin
               addr =0;
             pstate = ideal;
              end
        end
        default:pstate = ideal;
         endcase  
end
endmodule
module uart_tranrec_mem(out,clk);
  input clk;
  output [7:0]out;
  wire wr,clk1;
  brcal ss1(.clkout(clk1),.clk(clk));
  uart_trans ss2(.tout(wr),.clk(clk1));
  uart_memory_rec ss3 (.rcout(out),.in(wr),.clk(clk1));
 endmodule 
  
  
