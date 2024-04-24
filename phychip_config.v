module phychip_config(clk,mdc,mdio);
  input clk;
  inout mdio;
  output mdc;
//reg
  reg en=0;
  reg [2:0] state;
  reg [1:0] st=2'b10;
  reg [1:0] op_wr=2'b10;
  reg [4:0] phy_ad=5'b10000;
  reg [4:0] reg_ad;
  reg [1:0] wr_tr=2'b01;
  reg [15:0] data;
  reg mdin_out;
  //count
  reg [4:0]cnt=0;
  reg [2:0]cnt_reg=3'b000;
  //assign
  assign mdio = mdin_out;
  assign mdc = clk;
  
parameter preideal =3'b000,start=3'b001,op_write=3'b010,phy_addr=3'b011,reg_addr=3'b100,wr_turn_around=3'b101,data_wr=3'b110,ideal=3'b111;
 always @ (cnt_reg)
  begin
   if(cnt_reg ==3'd0)
    begin
    reg_ad <=5'd16;
    data   <=16'h0060;
    end
  else if (cnt_reg ==3'd1)
    begin
    reg_ad <=5'd0;
    data   <=16'h8140;
    end 
  else if (cnt_reg ==3'd2)
    begin
    reg_ad <=5'd20;
    data   <=16'h0070;
    end 
  else if (cnt_reg ==3'd3)
    begin
    reg_ad <=5'd0;
    data   <=16'h8140;
    end 
   else if (cnt_reg ==3'd4)
    begin
    reg_ad <=5'd29;
    data   <=16'h0012;
    end 
   else if (cnt_reg ==3'd5)
    begin
    reg_ad <=5'd30;
    data   <=16'h8240;
    end 
   else if (cnt_reg ==3'd6)
    begin
    reg_ad <=5'd0;
    data   <=16'h8140;
    end 
   else if (cnt_reg ==3'd7)
    begin
    reg_ad <=5'bzzzzz;
    data   <=16'hzzzz;
    end 
    
  end

always @ (posedge mdc)
  begin
  
    case(state)
             
       preideal : begin
              if(cnt<5'd31)
              begin
                mdin_out<=1'b1;
                cnt<=cnt+1;
              end
              else if(cnt==5'd31)
              begin
                mdin_out<=1'b1;
                cnt<=5'd0;
                state<=start;     
              end
              end
              
              
              
              
              
        start : begin
              if(cnt<5'd1)
              begin
                mdin_out<=st[cnt];
                cnt<=cnt+1;
              end
              else if(cnt == 5'd1)
              begin
                  mdin_out<=st[cnt];
                  cnt<=5'd0;
                  state<=op_write;
 
              end
              end
              
              
              
              
              
      op_write:begin
              if(cnt<5'd1)
              begin
                mdin_out<=op_wr[cnt];
                cnt<=cnt+1;
              end
              else if(cnt==5'd1)
              begin
                mdin_out<=op_wr[cnt];
                cnt<=5'b00100;
                state<=phy_addr;     
              end
            end
            
            
            
            
            
            
       phy_addr:begin
              if(cnt >5'd0 && cnt<=5'd4)
              begin
                mdin_out<=phy_ad[cnt];
                cnt<=cnt-1;
              end
              else if(cnt==5'd0)
              begin
                mdin_out<=phy_ad[cnt];
                cnt<=5'b00100;
                state<=reg_addr;     
              end
              end
              
              
              
              
              
              
               
        reg_addr:
            begin
              if(cnt > 5'd0 && cnt<=5'd4)
              begin
                mdin_out<=reg_ad[cnt];
                cnt<=cnt-1;
              end
              else if(cnt==5'd0)
              begin
                mdin_out<=reg_ad[cnt];
                cnt<=5'd0;
                state<=wr_turn_around;  
              end
              end 
              
              
              
              
              
              
     wr_turn_around: begin
                   if(cnt<5'd1)
                    begin
                    mdin_out<=wr_tr[cnt];
                    cnt<=cnt+1;
                    end
                    else if(cnt==5'd1)
                    begin
                    mdin_out<=wr_tr[cnt];
                    cnt<=5'b10000;
                    state<=data_wr;     
              end
              end
              
              
              
              
              
               
       data_wr: begin
              if(cnt > 5'd0 & cnt<=5'd16)
              begin
                mdin_out<=data[cnt-1];
                cnt<=cnt-1;
              end
              else if(cnt==5'd0)
              begin
                mdin_out<=data[cnt];
                cnt<=cnt+1;
                cnt_reg <= cnt_reg +1;
                if(cnt_reg<3'd6)
                  begin
                    en<=1'b0;
                    mdin_out<=1'b1;
                    state<=preideal;
                  end
                else if(cnt_reg==3'd6)
                  begin
                    en<=1'b1;
                    state<=ideal;
                    mdin_out<=1'bz;
                  end  
                     
              end
              end
              
              
               ideal :
                begin
               mdin_out<=1'bz;
               state<=ideal;
               end 
               
      //default :begin
//                mdin_out<=1'b1;
//                cnt<=cnt+1;
//                state<=preideal;
//                end
                   
     endcase
   end 
 endmodule
   

