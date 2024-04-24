module uart_en_tran(ack,tout,clk,clt);
  input clk,clt;
  output reg ack=0;
  output reg tout;
  reg [7:0]trout;
  reg [1:0]pstate;
  reg [3:0]cnt = 0;
  reg [3:0]addr=0;
  reg [7:0]mem[0:9];
  parameter ideal=2'b00,active=2'b01,trans=2'b10;
  always @ (posedge clk)
  begin
            mem[0] <= 8'b00000001;
            mem[1] <= 8'b00000011;
            mem[2] <= 8'b00000111;
            mem[3] <= 8'b00001111;
            mem[4] <= 8'b00011111;
            mem[5] <= 8'b00111111;
            mem[6] <= 8'b01111111;
            mem[7] <= 8'b11111111;
            mem[8] <= 8'b10000000;
            mem[9] <= 8'b11000000;
          end
    
  always @ (posedge clk)
  begin
    case (pstate)
     ideal : 
     begin
       if(clt==0)
         tout<=1;
       else if(clt==1)
          begin
            tout <=1;
            pstate <= active ;
            end
          end
    active : 
           begin
            if (addr>=4 && addr <=9)
              begin
              tout <= 0;
           trout <= mem[addr];
            pstate <= trans;
          end
          
          else if(addr>9)
             begin
             addr <= 0;
             ack <=1;
             pstate <= ideal;
            end
            
        else if(addr<4)
          begin
            addr<=addr+1;
            pstate<=ideal;
          end
          end
          
      trans:
       begin 
           
           if(cnt <=7)
             begin
           tout <= trout[cnt];
           cnt <= cnt +1;
             end
           
           else if(cnt>7)
             begin
             cnt<=0;
           tout <= 1;
           addr <= addr+1;
           pstate <= active;
             end
            
          end
          
        default:pstate <= ideal;
         endcase
end
endmodule
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
  
  module uart_memory (rcout,ack,out,clk,clt); //uart_4to9tr_mem
  input clk,clt;
  output out,ack;
  output [7:0]rcout;
  wire wr1;
  uart_en_tran ss2(.ack(ack),.tout(wr1),.clk(clk),.clt(clt));
  receives ss3 (.rcout(rcout),.r(out),.in(wr1),.clk(clk));
 endmodule
  
