module arp_tran_tt(clk,tx_clk,data,tx_en);
  input clk;
  output tx_clk;
  output reg [3:0]data;
  output tx_en;
  //memory
  reg [3:0] board_mac_add =4'hf;
  reg [7:0] src_mac_add [0:5];
  reg [3:0] des_mac_add =4'h0;
  reg [7:0] src_ip_add[0:3];
  reg [7:0] des_ip_add[0:3];
  reg [7:0] crc[0:3];
  //reg
  reg [7:0] bmreg;
  reg [3:0] pre_reg =4'b 1010;
  reg [7:0] sfd_reg =8'b 1010_1011;
  reg [15:0] frame_type=16'h0806;
  reg [15:0] hard_type=16'h0001;
  reg [15:0] protocol_type=16'h0800;
  reg [7:0] hard_len=8'h06;
  reg [7:0] ip_len=8'h04;
  reg [15:0] request=16'h0001;
  reg [3:0] padding_reg=4'b0;
  reg sender_en=1;
  reg [3:0]state=4'b0;
  reg [4:0] cnt_add=0;
  
  parameter pre=4'b0000,sfd=4'b0001,des_add=4'b0010,src_add=4'b0011,frm_ty=4'b0100,
  ht=4'b0101,pt=4'b0110,hl=4'b0111,ipl=4'b1000, req=4'b1001,smac =4'b1010,sip=4'b1011,dmac=4'b1100,dip=4'b1101,padding=4'b1110,crc_type=4'b1111;
  
  assign tx_clk=clk;
  assign tx_en=sender_en;
  
  always @ (clk)
  begin
    
    src_mac_add[0]<=8'hac;
    src_mac_add[1]<=8'h16;
    src_mac_add[2]<=8'h2d;
    src_mac_add[3]<=8'h0b;
    src_mac_add[4]<=8'h5a;
    src_mac_add[5]<=8'ha2;
    
    src_ip_add[0]<=8'd192;
    src_ip_add[1]<=8'd168;
    src_ip_add[2]<=8'd0;
    src_ip_add[3]<=8'd144;
    
    des_ip_add[0]<=8'd192;
    des_ip_add[1]<=8'd168;
    des_ip_add[2]<=8'd0;
    des_ip_add[3]<=8'd166;
    
       crc[0]<=8'h62;
       crc[1]<=8'h86;
       crc[2]<=8'h4e;
       crc[3]<=8'he1;
  end
  
        
         always @(clk)
         
         begin
           
           if(sender_en)
             begin
               cnt_add<=cnt_add+1;
             case (state)
               
             pre: begin
               
               //cnt_add<=cnt_add+1;
               
                if(cnt_add>=0 && cnt_add<13)
                  begin
                    data<=pre_reg[3:0];
                 end
                 
               else
                 begin
               state<=sfd;
               cnt_add<=0;
             end
             end 
             
             sfd: begin
               
               if(cnt_add==0)
                 data<=sfd_reg[3:0];
               else
                 begin
                   data<=sfd_reg[7:4];
                   cnt_add<=0;
                    state<=des_add;
                 end
              end
          des_add : begin
               
               if(cnt_add>=0 && cnt_add<11)
                 data<=board_mac_add[3:0];
                 
               else
                 begin
                   cnt_add<=0;
                   bmreg<=src_mac_add[0];
                    state<= src_add;
                 end
              end
            src_add :begin
                if(cnt_add==0)
                     data<=bmreg[3:0];
                else if(cnt_add==1)
                  begin
                    data<=bmreg[7:4];
                   bmreg<=src_mac_add[cnt_add];
                  end
                else if(cnt_add==2)
                     data<=bmreg[3:0];
                else if(cnt_add==3)
                  begin
                    data<=bmreg[7:4];
                   bmreg<=src_mac_add[cnt_add-1];
                  end
                else if(cnt_add==4)
                     data<=bmreg[3:0];
                else if(cnt_add==5)
                  begin
                    data<=bmreg[7:4];
                  bmreg<=src_mac_add[cnt_add-2];
                  end
                   else if(cnt_add==6)
                     data<=bmreg[3:0];
                 else if(cnt_add==7)
                  begin
                    data<=bmreg[7:4];
                  bmreg<=src_mac_add[cnt_add-3];
                  end
                   else if(cnt_add==8)
                     data<=bmreg[3:0];
                 else if(cnt_add==9)
                  begin
                    data<=bmreg[7:4];
                  bmreg<=src_mac_add[cnt_add-4];
                  end
                   else if(cnt_add==10)
                     data<=bmreg[3:0];
                else if(cnt_add==11)
                  begin
                    data<=bmreg[7:4];
                  bmreg<=frame_type[15:8];
                   cnt_add<=0;
                  state<=frm_ty;
                  end
                end
              frm_ty : begin
                if(cnt_add==0)
                     data<=bmreg[3:0];
                else if(cnt_add==1)
                  begin
                    data<=bmreg[7:4];
                   bmreg<=frame_type[7:0];
                  end
                else if(cnt_add==2)
                     data<=bmreg[3:0];
                else if(cnt_add==3)
                  begin
                    data<=bmreg[7:4];
                  cnt_add<=0;
                  bmreg<=hard_type[15:8];
                  state<=ht;
                  end
               end
                ht:begin
                  if(cnt_add==0)
                     data<=bmreg[3:0];
                else if(cnt_add==1)
                  begin
                    data<=bmreg[7:4];
                   bmreg<=hard_type[7:0];
                  end
                else if(cnt_add==2)
                     data<=bmreg[3:0];
                else if(cnt_add==3)
                  begin
                    data<=bmreg[7:4];
                  cnt_add<=0;
                  bmreg<=protocol_type[15:8];
                  state<=pt;
                  end
               end
               pt:begin
                 if(cnt_add==0)
                     data<=bmreg[3:0];
                else if(cnt_add==1)
                  begin
                    data<=bmreg[7:4];
                   bmreg<=protocol_type[7:0];
                  end
                else if(cnt_add==2)
                     data<=bmreg[3:0];
                else if(cnt_add==3)
                  begin
                    data<=bmreg[7:4];
                  cnt_add<=0;
                  state<=hl;
                  end
               end
                hl: begin
                   if(cnt_add==0)
                   begin
                     data<=hard_len[3:0];
                    end
                    else if(cnt_add==1)
                    begin
                    data<=hard_len[7:4];
                    cnt_add<=0;
                    state<=ipl;
                    end
                    end
                ipl :begin
                   if(cnt_add==0)
                    begin
                   data<=ip_len[3:0];
                    end
                    else if(cnt_add==1)
                     begin
                    data<=ip_len[7:4];
                      cnt_add<=0;
                      bmreg<=request[15:8];
                     state<=req;
                  end
                  end
                req : begin
                 if(cnt_add==0)
                     data<=bmreg[3:0];
                else if(cnt_add==1)
                  begin
                    data<=bmreg[7:4];
                   bmreg<=request[7:0];
                  end
                else if(cnt_add==2)
                     data<=bmreg[3:0];
                else if(cnt_add==3)
                  begin
                    data<=bmreg[7:4];
                  cnt_add<=0;
                   bmreg<=src_mac_add[0];
                  state<=smac;
                  end
                  end
               smac :begin
                if(cnt_add==0)
                     data<=bmreg[3:0];
                else if(cnt_add==1)
                  begin
                    data<=bmreg[7:4];
                   bmreg<=src_mac_add[cnt_add];
                  end
                else if(cnt_add==2)
                     data<=bmreg[3:0];
                else if(cnt_add==3)
                  begin
                    data<=bmreg[7:4];
                   bmreg<=src_mac_add[cnt_add-1];
                  end
                else if(cnt_add==4)
                     data<=bmreg[3:0];
                else if(cnt_add==5)
                  begin
                    data<=bmreg[7:4];
                  bmreg<=src_mac_add[cnt_add-2];
                  end
                   else if(cnt_add==6)
                     data<=bmreg[3:0];
                 else if(cnt_add==7)
                  begin
                    data<=bmreg[7:4];
                  bmreg<=src_mac_add[cnt_add-3];
                  end
                   else if(cnt_add==8)
                     data<=bmreg[3:0];
                 else if(cnt_add==9)
                  begin
                    data<=bmreg[7:4];
                  bmreg<=src_mac_add[cnt_add-4];
                  end
                   else if(cnt_add==10)
                     data<=bmreg[3:0];
                else if(cnt_add==11)
                  begin
                    data<=bmreg[7:4];
                  bmreg<=src_ip_add[0];
                   cnt_add<=0;
                  state<=sip;
                  end
                end
                sip :begin
                if(cnt_add==0)
                     data<=bmreg[3:0];
                else if(cnt_add==1)
                  begin
                    data<=bmreg[7:4];
                   bmreg<=src_ip_add[cnt_add];
                  end
                else if(cnt_add==2)
                     data<=bmreg[3:0];
                else if(cnt_add==3)
                  begin
                    data<=bmreg[7:4];
                   bmreg<=src_ip_add[cnt_add-1];
                  end
                else if(cnt_add==4)
                     data<=bmreg[3:0];
                else if(cnt_add==5)
                  begin
                    data<=bmreg[7:4];
                  bmreg<=src_ip_add[cnt_add-2];
                  end
                   else if(cnt_add==6)
                     data<=bmreg[3:0];
                 else if(cnt_add==7)
                  begin
                    data<=bmreg[7:4];
                   cnt_add<=0;
                  state<=dmac;
                  end
                  end
             dmac :begin
               
                 if(cnt_add>=0 && cnt_add<11)
                 data<=des_mac_add[3:0];
                 
                  else
                   begin
                   cnt_add<=0;
                   bmreg<=des_ip_add[0];
                  state<= dip ;
                 end
                 end
              dip : begin
                if(cnt_add==0)
                     data<=bmreg[3:0];
                else if(cnt_add==1)
                  begin
                    data<=bmreg[7:4];
                   bmreg<=des_ip_add[cnt_add];
                  end
                else if(cnt_add==2)
                     data<=bmreg[3:0];
                else if(cnt_add==3)
                  begin
                    data<=bmreg[7:4];
                   bmreg<=des_ip_add[cnt_add-1];
                  end
                else if(cnt_add==4)
                     data<=bmreg[3:0];
                else if(cnt_add==5)
                  begin
                    data<=bmreg[7:4];
                  bmreg<=des_ip_add[cnt_add-2];
                  end
                   else if(cnt_add==6)
                     data<=bmreg[3:0];
                 else if(cnt_add==7)
                  begin
                    data<=bmreg[7:4];
                   cnt_add<=0;
                  state<=padding;
                  end
                  end 
              padding:begin
                if(cnt_add>=0 && cnt_add<19)
                  begin
                    data<=padding_reg[3:0];
                 end
                 
                 else
                 begin
                     state<= crc_type;
                       bmreg<= crc[0];
                     cnt_add<=0;
                  end
                  end 
              crc_type : begin
                if(cnt_add==0)
                     data<=bmreg[3:0];
                else if(cnt_add==1)
                  begin
                    data<=bmreg[7:4];
                   bmreg<=crc[cnt_add];
                  end
                else if(cnt_add==2)
                     data<=bmreg[3:0];
                else if(cnt_add==3)
                  begin
                    data<=bmreg[7:4];
                   bmreg<=crc[cnt_add-1];
                  end
                else if(cnt_add==4)
                     data<=bmreg[3:0];
                else if(cnt_add==5)
                  begin
                    data<=bmreg[7:4];
                  bmreg<=crc[cnt_add-2];
                  end
                   else if(cnt_add==6)
                     data<=bmreg[3:0];
                 else if(cnt_add==7)
                  begin
                    data<=bmreg[7:4];
                    sender_en<=0;
                   cnt_add<=0;
                  end
                  end 
                  default :
                  begin
                  cnt_add<=0;
                  state<=pre;
                  end                
endcase
end
end
endmodule
