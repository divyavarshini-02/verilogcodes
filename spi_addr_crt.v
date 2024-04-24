module ms_spi(out,in,rw,sclk,addr,saddr,temp,ss);
  input in;
  input sclk,rw,ss;
  input [7:0]addr;
  input [7:0]saddr;
  output reg out;
  reg [7:0]tradr=8'b00000001;
  reg [7:0]mem[0:4];
  reg [7:0]smem[0:4];
  output reg [7:0]temp;
  reg [3:0] cnt=0;
  reg [1:0]state;
  parameter ideal=3'b000,clt=3'b001,trans=3'b010,receive=3'b011;
  always @(posedge sclk)
  begin
    mem[0]<=8'b10101010;
    mem[1]<=8'b10111011;
    mem[2]<=8'b10001000;
    mem[3]<=8'b10011001;
    mem[4]<=8'b11101110;
  end
  always @(posedge sclk)
  begin
    case(state)
      ideal:begin
        if(ss==0)
            begin
               temp<=tradr;
               state<=trans;
              end
        else
           state<=ideal;
            end  
      clt:begin
            if(rw==1)
              begin
             temp<=mem[addr];
              state<=trans;
              end
             else
             state<=receive;
              end 
      trans:begin
            if(cnt<=8)
            begin
              out<=temp[cnt];
              cnt<=cnt+1;
             end
            else if(cnt>8)
            begin
              cnt<=0;
              temp<=0;
              state<=clt;
            end
            end    
      receive:begin
              if(cnt<=8)
              begin
                 cnt<=cnt+1;
                temp[cnt-1]<=in;
              end
              else if(cnt>8)
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
 module sl_spi(out,in,rw,sclk,raddr,rtemp,ss);
  input in;
  input sclk,rw,ss;
  reg [7:0]raddr;
  output reg out;
  reg [7:0]rmem[0:4];
  output reg [7:0]rtemp;
  reg [3:0]cnt=0;
  reg [1:0]state;
  parameter ideal=2'b000,clt=3'b001,trans=2'b010,receive=2'b011;
  always @(posedge sclk)
  begin
    rmem[0]<=8'b00000000;
    rmem[1]<=8'b00010001;
    rmem[2]<=8'b00100010;
    rmem[3]<=8'b00110011;
    rmem[4]<=8'b01000011;
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
        clt:begin
            if(rw==1)
              begin
             state<=receive;
              end
             else
             state<=trans;
              end 
             
    receive:begin
              if(cnt<=8)
              begin
                cnt<=cnt+1;
                rtemp[cnt-1]<=in;
              end
              else if(cnt>8)
              begin
                cnt<=0;
                rmem[raddr]<=rtemp;
                state<=clt;
              end
              end
      
      trans:begin
            if(cnt<=8)
            begin
              out<=rtemp[cnt];
              cnt<=cnt+1;
             end
            else if(cnt>8)
            begin
              cnt<=0;
              state<=ideal;
            end
            end

      default:state<=ideal;
    endcase
    end
  endmodule
  module ms_sl_spi(addr,saddr,rw,sclk,ss);
  input rw,sclk,ss;
  input [2:0]addr,saddr;
  wire [7:0]temp,rtemp;
  wire mout,sout,min,sin;
  assign min=sout;
  assign sin=mout;
  spi_ms_rw q1 (.out(mout),.in(min),.rw(rw),.sclk(sclk),.addr(addr),.saddr(saddr),.temp(temp),.ss(ss));
  spi_rs_rw q2 (.out(sout),.in(sin),.rw(rw),.sclk(sclk),.raddr(raddr),.rtemp(rtemp),.ss(ss));
endmodule
