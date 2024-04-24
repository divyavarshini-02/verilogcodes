module spi_ms(out,in,ss,sclk,addr,saddr,temp);
  input in;
  input sclk,ss;
  input [2:0]addr;
  input [2:0]saddr;
  output reg out;
  reg [3:0]mem[0:4];
  reg [3:0]smem[0:4];
  output reg [3:0]temp;
  reg [2:0] cnt=0;
  reg [1:0]state;
  parameter ideal=2'b00,trans=2'b01,receive=2'b10;
  always @(posedge sclk)
  begin
    mem[0]<=4'b1010;
    mem[1]<=4'b1011;
    mem[2]<=4'b1000;
    mem[3]<=4'b1001;
    mem[4]<=4'b1110;
  end
  always @(posedge sclk)
  begin
    case(state)
      ideal:begin
            if(ss==0)
              begin
              temp<=mem[addr];
              state<=trans;
              end
            else
              state<=ideal;
            end
      
      trans:begin
            if(cnt<=4)
            begin
              out<=temp[cnt];
              cnt<=cnt+1;
             end
            else if(cnt>4)
            begin
              cnt<=0;
              temp<=0;
              state<=receive;
            end
            end
            
      receive:begin
              if(cnt<=4)
              begin
                 cnt<=cnt+1;
                temp[cnt-1]<=in;
              end
              else if(cnt>4)
              begin
                cnt<=0;
                smem[saddr]<=temp;
                state<=ideal;
              end
              end
      default:state<=ideal;
    endcase
    end
  endmodule
  module spi_rs(out,in,ss,sclk,raddr,rtemp);
  input in;
  input sclk,ss;
  input [2:0]raddr;
  output reg out;
  reg [3:0]rmem[0:4];
  output reg [3:0]rtemp;
  reg [2:0]cnt=0;
  reg [1:0]state;
  parameter ideal=2'b00,trans=2'b10,receive=2'b01;
  always @(posedge sclk)
  begin
    rmem[0]<=4'b0000;
    rmem[1]<=4'b0001;
    rmem[2]<=4'b0010;
    rmem[3]<=4'b0011;
    rmem[4]<=4'b0100;
  end
  always @(posedge sclk)
  begin
    case(state)
     ideal:begin
            if(ss==0)
              begin
              state<=receive;
              end
            else
              state<=ideal;
            end
            
    receive:begin
              if(cnt<=4)
              begin
                cnt<=cnt+1;
                rtemp[cnt-1]<=in;
              end
              else if(cnt>4)
              begin
                cnt<=0;
                rmem[raddr]<=rtemp;
                state<=trans;
              end
              end
      
      trans:begin
            if(cnt<=4)
            begin
              out<=rtemp[cnt];
              cnt<=cnt+1;
             end
            else if(cnt>4)
            begin
              cnt<=0;
              state<=ideal;
            end
            end

      default:state<=ideal;
    endcase
    end
  endmodule
  module spi_ms_rs(addr,saddr,raddr,ss,sclk);
  input ss,sclk;
  input [2:0]addr,saddr,raddr;
  wire [3:0]temp,rtemp;
  wire mout,sout,min,sin;
  assign min=sout;
  assign sin=mout;
  spi_ms q1 (.out(mout),.in(min),.ss(ss),.sclk(sclk),.addr(addr),.saddr(saddr),.temp(temp));
  spi_rs q2 (.out(sout),.in(sin),.ss(ss),.sclk(sclk),.raddr(raddr),.rtemp(rtemp));
endmodule              
                
      
            
    
        
            
         
    
