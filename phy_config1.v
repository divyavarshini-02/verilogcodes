module mac_phy(sw,clk,mdc,mdio);
  input sw;
  input clk;
  inout mdio;
  output mdc;
//reg
  reg [3:0] state;
  reg [31:0]id=32'b1111_1111_1111_1111_1111_1111_1111_1111;
  reg [1:0] st=2'b10;
  reg [1:0] op_wr=2'b10;
  reg [1:0] op_rd=2'b01;
  reg [4:0] phy_ad=5'b10000;
  reg [4:0] reg_ad=5'b00000;
  reg [1:0] wr_tr=2'b01;
  reg [1:0] rd_tr=2'b0z;
  reg [15:0] data=16'b0001_0011_0000_0001;
  reg mdin_out;
  //count
  reg [4:0]cnt;
  //assign
  assign mdio = mdin_out;
  assign mdc = clk;
  
  parameter ideal =4'b0000,start=4'b0001,op_write=4'b0010,op_read=4'b0011,phy_addr=4'b0100,reg_addr=4'b0101,wr_turn_around=4'b0110,rd_turn_around=4'b0111,data_wr=4'b1000,data_rd=4'b1001;
  
  always @ (posedge mdc)
  begin
  
    case(state)
        ideal:begin
              if(cnt>=1 & cnt<31)
              begin
                mdin_out<=id[cnt];
                cnt<=cnt+1;
              end
              else if(cnt==31)
              begin
                mdin_out<=id[cnt];
                cnt<=0;
                state<=start;     
              end
              end
        start:begin
              if(cnt<1)
              begin
                mdin_out<=st[cnt];
                cnt<=cnt+1;
              end
              else if(cnt == 1)
              begin
                  mdin_out<=st[cnt];
                  cnt<=0;
                  if(sw==0)
                    begin
                  state<=op_write;
                    end
                  else if(sw==1)
                    begin
                  state<=op_read;
                    end
              end
              end
      op_write:begin
              if(cnt<1)
              begin
                mdin_out<=op_wr[cnt];
                cnt<=cnt+1;
              end
              else if(cnt==1)
              begin
                mdin_out<=op_wr[cnt];
                cnt<=5'b00100;
                state<=phy_addr;     
              end
              end
       op_read :begin
              if(cnt<1)
              begin
                mdin_out<=op_rd[cnt];
                cnt<=cnt+1;
              end
              else if(cnt==1)
              begin
                mdin_out<=op_rd[cnt];
                cnt<=5'b00100;
                state<=phy_addr;     
              end
              end
       phy_addr:begin
              if(cnt > 0 && cnt<=4)
              begin
                mdin_out<=phy_ad[cnt];
                cnt<=cnt-1;
              end
              else if(cnt==0)
              begin
                mdin_out<=phy_ad[cnt];
                cnt<=5'b00100;
                state<=reg_addr;     
              end
              end 
        reg_addr:begin
              if(cnt > 0 && cnt<=4)
              begin
                mdin_out<=reg_ad[cnt];
                cnt<=cnt-1;
              end
              else if(cnt==0)
              begin
                mdin_out<=reg_ad[cnt];
                cnt<=0;
                if(sw==0)
                    begin
                  state<=wr_turn_around;
                    end
                  else if(sw==1)
                    begin
                  state<=rd_turn_around;
                    end    
              end
              end 
     wr_turn_around: begin
                   if(cnt<1)
                    begin
                    mdin_out<=wr_tr[cnt];
                    cnt<=cnt+1;
                    end
                    else if(cnt==1)
                    begin
                    mdin_out<=wr_tr[cnt];
                    cnt<=5'b10000;
                    state<=data_wr;     
              end
              end 
      rd_turn_around: begin
                   if(cnt<1)
                    begin
                    mdin_out<=rd_tr[cnt];
                    cnt<=cnt+1;
                    end
                    else if(cnt==1)
                    begin
                    mdin_out<=rd_tr[cnt];
                    cnt<=5'b10000;
                    state<=data_rd;     
              end
              end  
       data_wr: begin
              if(cnt > 0 & cnt<=16)
              begin
                mdin_out<=data[cnt-1];
                cnt<=cnt-1;
              end
              else if(cnt==0)
              begin
                mdin_out<=data[cnt];
                cnt<=0;
                mdin_out<=id[cnt];
                cnt<=cnt+1;
                state<=ideal;     
              end
              end 
      data_rd :begin
              if(cnt > 0 & cnt<=16)
              begin
                mdin_out<=1'bz;
                cnt<=cnt-1;
              end
              else if(cnt==0)
              begin
                mdin_out<=1'bz;
                cnt<=0;
                mdin_out<=id[cnt];
                cnt<=cnt+1;
                state<=ideal;     
              end
              end  
        default :begin
                cnt=4'b0;
                mdin_out<=id[cnt];
                cnt<=cnt+1;
                state<=ideal;
              end
                   
     endcase
   end 
 endmodule   
 
  
        
            
              
              
    
    
    
  
