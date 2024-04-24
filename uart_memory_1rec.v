module uart_transs(ack,tout,clk,clt);
  input clk,clt;
  output reg tout;
  output reg ack=0;
  reg [7:0]trout;
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
          if(clt==0)
            begin
            tout=1;
            pstate =  ideal;
            end
       else if(clt==1)
          begin
            tout =1;
            pstate = active ;
            end
          end
    active : 
           begin
            tout = 0;
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
            if(addr<4)
             begin
             tout=1;
            addr=addr+1;
            pstate=ideal;
              end
         else if (addr>=4 && addr <=9)
           begin
           trout = mem[addr];
           if(cnt <=7)
             begin
           tout = trout[cnt];
           cnt = cnt +1;
             end
           else if(cnt>7)
             begin
             cnt=0;
           tout = 1;
           addr = addr+1;
           pstate = ideal;
             end
           end
           else if(addr>9)
             begin
             addr = 0;
             ack=1;
             pstate = ideal;
             end
        default:pstate = ideal;
         endcase
end
endmodule
module uart_memory_recs(addr,temp,rcout,wr,clk);
  input clk;
  input wr;
  output  reg rcout;
  reg [3:0]cnt =0;
  output reg  [7:0]temp;
  reg [1:0]pstate;
  output reg [3:0]addr=0;
  reg [7:0]mem[0:9];
  parameter ideal = 2'b00,receive=2'b01;
  always @ (posedge clk)
  begin
    case(pstate)
      ideal:begin
            if(wr==0)
              pstate = receive;
            else
              pstate = ideal;
            end
     receive:begin
             if(cnt<=7)
               begin
             rcout = wr;
            temp[cnt]=rcout;
             cnt=cnt+1;
                end
              else
            begin
               cnt=0;
             if(wr==1)
              begin
               rcout=1'b1;
                 if(addr<=9)
                     begin
                     mem[addr]=temp;
                     addr=addr+1;
                     pstate=ideal;
                     end
                 else
                     begin
                     addr=0;
                     pstate=ideal;
                     end
                end
              end
            end
            default:pstate=ideal;
          endcase
        end
      endmodule
  
  module uart_1bittr_mem(ack,mem,addr,out,clk,clt);
  input clk,clt;
  output ack,out;
  output [7:0]mem;
  output [3:0]addr;
  wire wr1;
  uart_transs ss2(.ack(ack),.tout(wr1),.clk(clk),.clt(clt));
  uart_memory_recs ss3 (.addr(addr),.temp(mem),.rcout(out),.wr(wr1),.clk(clk));
 endmodule  
                   
                   
                   
               
            
              
              
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
             
      