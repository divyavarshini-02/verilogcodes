module phy(clk,mdc,mdio);
  input clk;
  inout mdio;
  output mdc;
//reg
  reg en=1'b0;
  reg [3:0] state;
  reg id;
  reg [1:0] st=2'b10;
  reg [1:0] op_wr=2'b10;
  reg [1:0] op_rd=2'b01;
  reg [4:0] phy_ad=5'b10000;
  reg [4:0] reg_ad;
  reg [1:0] wr_tr=2'b01;
  reg [1:0] rd_tr=2'b0z;
  reg [15:0] data;
  reg [4:0] mem_reg[0:6];
  reg [15:0] mem_data[0:6];
  reg mdin_out;
  //count
  reg [4:0]cnt;
  reg [2:0]cnt_reg=3'b000;
  //assign
  assign mdio = mdin_out;
  
   
  
 
  parameter preideal =4'b0000,start=4'b0001,op_write=4'b0010,op_read=4'b0011,phy_addr=4'b0100,reg_addr=4'b0101,wr_turn_around=4'b0110,rd_turn_around=4'b0111,data_wr=4'b1000,data_rd=4'b1001,ideal=4'b1010;
  
 always @ (posedge clk)
  begin
    mem_data[0]<=16'h0060;
    mem_data[1]<=16'h8140;
    mem_data[2]<=16'h0070;  
    mem_data[3]<=16'h8140;
    mem_data[4]<=16'h0012;
    mem_data[5]<=16'h8240;
    mem_data[6]<=16'h8140;
    
    mem_reg[0]<=5'd16;
    mem_reg[1]<=5'd0;
    mem_reg[2]<=5'd20;
    mem_reg[3]<=5'd0;
    mem_reg[4]<=5'd29;
    mem_reg[5]<=5'd30;
    mem_reg[6]<=5'd0;
    
    
reg_ad <=mem_reg[cnt_reg];
data   <=mem_data[cnt_reg];
    
end    
  always @ (posedge clk)
  begin
  
    case(state)
         ideal :
                begin
               if(en == 0)
                 begin
                   cnt=4'b0;
                   mdin_out<=1'b1;
                   cnt<=cnt+1;
                   state<=preideal;
                end
              else if(cnt_reg >6 && en==1)
                begin
               mdin_out<=1'bz;
               state<=ideal;
               end
             end
             
             
             
       preideal : begin
              if(cnt>=1 & cnt<31)
              begin
                mdin_out<=1'b1;
                cnt<=cnt+1;
              end
              else if(cnt==31)
              begin
                mdin_out<=1'b1;
                cnt<=0;
                state<=start;     
              end
              end
              
              
              
              
              
        start : begin
              if(cnt<1)
              begin
                mdin_out<=st[cnt];
                cnt<=cnt+1;
              end
              else if(cnt == 1)
              begin
                  mdin_out<=st[cnt];
                  cnt<=0;
                  state<=op_write;
 
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
              
              
              
              
              
              
               
        reg_addr:
            begin
              if(cnt > 0 && cnt<=4)
              begin
                mdin_out<=reg_ad[cnt];
                cnt<=cnt-1;
              end
              else if(cnt==0)
              begin
                mdin_out<=reg_ad[cnt];
                cnt<=0;
                state<=wr_turn_around;  
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
                mdin_out<=1'b1;
                cnt<=cnt+1;
                cnt_reg <= cnt_reg +1;
                if(cnt_reg<6)
                  begin
                    en<=1'b0;
                    state<=preideal;
                  end
                else if(cnt_reg==6)
                  begin
                    en<=1'b1;
                    state<=ideal;
                    mdin_out<=1'bz;
                  end  
                     
              end
              end
              
              
              
               
      default :begin
                cnt=4'b0;
                mdin_out<=1'b1;
                cnt<=cnt+1;
                if(cnt_reg >6)
                  begin
                    state<=ideal;
                  end
                else if(cnt_reg<6)
                  begin
                    state<=preideal;
                  end
                  end
                   
     endcase
   end 
 endmodule  

