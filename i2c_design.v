module i2c_design_mst(sda,scl);
  inout sda;
  input scl;
  reg [2:0]state;
  reg clkout=1;
  reg st;
  reg [6:0]adfr=7'b0001001;
  reg rw=1;
  reg [7:0]cn;
  reg [3:0]cnt=7;
  reg sda1;
  reg ak=1;
  reg [7:0]dt=10111011;
  reg dr;
  reg [7:0]rtemp;
assign cn ={rw,adfr};
assign sda=sda1;
  parameter ideal=3'b000,af=3'b001,ack=3'b010,tdata=3'b011,ack1=3'b100,rdata=3'b101,stop=3'b110;
  always @ (posedge clk,negedge clk)
  begin
    if(clt)
      sda1<=clkout;
    else 
      sda1<=~clkout;
  end
  always @ (negedge sda1)
  begin
    case(state)
      ideal:begin
          if(st==0)
             state<=af;
          else
             state<=ideal;
          end
       af:begin
          if(cnt>=0)
            begin
            sda1<=cn[cnt];
            cnt=cnt-1;
            end
          else if(cnt>8)
            begin
            cnt<=0;
            state<=ack;
            end
          end
       ack:begin
          if(sda1==1 & cnt==0)
            begin
              sda1<=ak;
              state<=data;
            end
          else if(sda1==0 & cnt==0)
            begin
              sda1<=ak;
              state<=rdata;
            end
          else
            begin
              sda1<=~ak;
              state<=ideal;
            end  
          end
        tdata:begin
          if(cnt<=7)
            begin
              sd1<=dt[cnt];
              cnt=cnt+1;
            end
          else if(cnt>7)
            begin
              cnt<=0;
              state<=ack1;
            end
          end
          ack1:begin
            if(cnt==0)
               begin
              sda1<=ak;
              state<=stop;
               end
            else
               begin
              sda1<=~ak;
              state<=ideal;
               end
               end
          rdata:begin
            if(cnt<=7)
            begin
              sd1<=dr;
              temp[cnt]<=sd1
              cnt=cnt+1;
            end
          else if(cnt>7)
            begin
              cnt<=0;
              state<=ack1;
            end
          end
          stop:
            
            
              
          
            
         
    
  
