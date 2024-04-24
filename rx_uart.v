module rx_uart(rcout,wr,clk);
  input clk;
  input wr;
  output  reg rcout;
  reg [3:0]cnt =0;
  reg  [7:0]temp;
  reg [1:0]pstate;
 reg [3:0]addr=0;
  reg [7:0]mem[0:4];
  parameter ideal = 2'b00,receive=2'b01;
  always @ (posedge clk)
  begin
    case(pstate)
      ideal:begin
            if(wr==0)
              pstate <= receive;
            else
              pstate <= ideal;
            end
     receive:begin
             if(cnt<=8)
               begin
            cnt<=cnt+1;
             rcout <= wr;
            temp[cnt-1]<=rcout;
            
                end
              else
            begin
               cnt=0;
             if(wr==1)
              begin
               rcout<=1'b1;
                 if(addr<=9)
                     begin
                     mem[addr]<=temp;
                     addr<=addr+1;
                     pstate<=ideal;
                     end
                 else
                     begin
                     addr<=0;
                     pstate<=ideal;
                     end
                end
              end
            end
            default:pstate=ideal;
          endcase
        end
      endmodule

