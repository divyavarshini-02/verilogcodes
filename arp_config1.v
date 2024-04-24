module arp_tran(clk,tx_clk,data,tx_en);
  input clk;
  output tx_clk;
  output reg [3:0]data;
  output tx_en;
  //memory
  reg [7:0] board_mac_add [0:5];
  reg [7:0] src_mac_add [0:5];
  reg [7:0] des_mac_add [0:5];
  reg [7:0] src_ip_add[0:3];
  reg [7:0] des_ip_add[0:3];
  reg [7:0] crc[0:3];
  //reg
  reg [7:0] bmreg;
  reg [7:0] pre_reg =8'b 1010_1010;
  reg [7:0] sfd_reg =8'b 1010_1011;
  reg [15:0] frame_type=16'h0806;
  reg [15:0] hard_type=16'h0001;
  reg [15:0] protocol_type=16'h0800;
  reg [7:0] hard_len=8'h06;
  reg [7:0] ip_len=8'h04;
  reg [15:0] request=16'h0001;
  reg [7:0] padding_reg=8'b0;
  reg sender_en;
  reg [3:0]state;
  reg cnt=0;
  reg [4:0] cnt_add=0;
  
  parameter pre=4'b0000,sfd=4'b0001,des_add=4'b0010,src_add=4'b0011,frm_ty=4'b0100,
  ht=4'b0101,pt=4'b0110,hl=4'b0111,ipl=4'b1000, req=4'b1001,smac =4'b1010,sip=4'b1011,dmac=4'b1100,dip=4'b1101,padding=4'b1110,crc_type=4'b1111;
  
  assign tx_clk=clk;
  assign tx_en=sender_en;
  
  always @ (posedge clk)
  begin
    cnt<=0;
    board_mac_add[0]<=8'hff;
    board_mac_add[1]<=8'hff;
    board_mac_add[2]<=8'hff;
    board_mac_add[3]<=8'hff;
    board_mac_add[4]<=8'hff;
    board_mac_add[5]<=8'hff;
    
    src_mac_add[0]<=8'hac;
    src_mac_add[1]<=8'h16;
    src_mac_add[2]<=8'h2d;
    src_mac_add[3]<=8'h0b;
    src_mac_add[4]<=8'h5a;
    src_mac_add[5]<=8'ha2;
    
    des_mac_add[0]<=8'h00;
    des_mac_add[1]<=8'h00;
    des_mac_add[2]<=8'h00;
    des_mac_add[3]<=8'h00;
    des_mac_add[4]<=8'h00;
    des_mac_add[5]<=8'h00;
    
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
  
  always @(negedge clk)
  begin
    cnt<=1;
  end
  
  always @(posedge clk or negedge clk)
  begin
    sender_en<=1'b1;
    case(state)
      pre : begin
        if(cnt_add<7)
          begin
        if(cnt==0)
          begin
           data<=pre_reg[7:4];
          // cnt_add <= cnt_add +1;
          end
        else if(cnt==1)
          begin
          data<=pre_reg[3:0];
           cnt_add <= cnt_add +1;
          end
          end
        else if(cnt_add==7)
          begin
            cnt_add<=0;
            if(cnt==0)
          begin
           data<=pre_reg[7:4];
          end
        else if(cnt==1)
          begin
          data<=pre_reg[3:0];
          end
            state<=sfd;
          end
          
         end
      sfd : begin
        if(cnt_add == 0)
          begin
          if(cnt==0)
          begin
           data<=sfd_reg[7:4];
          end
        else if(cnt==1)
          begin
          data<=sfd_reg[3:0];
          bmreg<=board_mac_add[cnt_add]; 
          cnt_add <= cnt_add +1;
        end
         end
           if(cnt_add == 1)
          begin
          if(cnt==0)
          begin
           data<=bmreg[7:4];
          // cnt_add <= cnt_add +1;
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
           cnt_add <= cnt_add +1;
          end
          state<=des_add;
          end
          end
    des_add : begin
           bmreg<=board_mac_add[cnt_add]; 
        if(cnt_add<6)
          begin 
          //bmreg<=board_mac_add[cnt_add]; 
        if(cnt==0)
          begin
           data<=bmreg[7:4];
           //cnt_add <= cnt_add +1;
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
           cnt_add <= cnt_add +1;
          end
          end
        else if(cnt_add==6)
          begin
            cnt_add<=0;
            if(cnt==0)
          begin
           data<=bmreg[7:4];
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
          end
            state<=src_add;
          end
          end
      src_add : begin
         bmreg<=src_mac_add[cnt_add];
        if(cnt_add<6)
          begin
            // bmreg<=src_mac_add[cnt_add];
        if(cnt==0)
          begin
           data<=bmreg[7:4];
           //cnt_add <= cnt_add +1;
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
           cnt_add <= cnt_add +1;
          end
          end
        else if(cnt_add==6)
          begin
            cnt_add<=0;
            if(cnt==0)
          begin
           data<=bmreg[7:4];
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
          end
            bmreg<=frame_type[15:8];
            state<=frm_ty;
          end
          end
      frm_ty : begin
        if(cnt_add<2)
          begin
        if(cnt==0)
          begin
           data<=bmreg[7:4];
           //cnt_add <= cnt_add +1;
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
           cnt_add <=  cnt_add+1;
           bmreg<=frame_type[7:0];
          end
          end
        else if(cnt_add==2)
          begin
            cnt_add<=0;
            if(cnt==0)
          begin
           data<=bmreg[7:4];
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
          end
            bmreg<=hard_type[15:8];
            state<=ht;
          end
          end
       ht:begin
        if(cnt_add<2)
          begin
        if(cnt==0)
          begin
           data<=bmreg[7:4];
           //cnt_add <= cnt_add +1;
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
           cnt_add <= cnt_add +1;
           bmreg<=hard_type[7:0];
          end
          end
        else if(cnt_add==2)
          begin
            cnt_add<=0;
            if(cnt==0)
          begin
           data<=bmreg[7:4];
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
          end
            bmreg<=protocol_type[15:8];
            state<=pt;
          end
          end
        pt:begin
        if(cnt_add<2)
          begin
        if(cnt==0)
          begin
           data<=bmreg[7:4];
           //cnt_add <= cnt_add +1;
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
          cnt_add <= cnt_add +1;
           bmreg<=protocol_type[7:0];
          end
          end
        else if(cnt_add==2)
          begin
            cnt_add<=0;
            if(cnt==0)
          begin
           data<=bmreg[7:4];
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
          end
            state<=hl;
          end
          end
        hl: begin
          if(cnt==0)
          begin
           data<=hard_len[7:4];
          end
        else if(cnt==1)
          begin
          data<=hard_len[3:0];
          state<=ipl;
          end
          end
        ipl :begin
          if(cnt==0)
          begin
           data<=ip_len[7:4];
          end
        else if(cnt==1)
          begin
          data<=ip_len[3:0];
          bmreg<=request[15:8];
          state<=req;
          end
          end
        req : begin
        if(cnt_add<2)
          begin
        if(cnt==0)
          begin
           data<=bmreg[7:4];
           //cnt_add <= cnt_add +1;
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
           cnt_add = cnt_add +1;
           bmreg<=request[7:0];
          end
          end
        else if(cnt_add==2)
          begin
            cnt_add<=0;
            if(cnt==0)
          begin
           data<=bmreg[7:4];
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
          end
            state<=smac;
          end
          end
        smac : begin
          bmreg<=src_mac_add[cnt_add];
        if(cnt_add<6)
          begin
            // bmreg<=src_mac_add[cnt_add];
        if(cnt==0)
          begin
           data<=bmreg[7:4];
           //cnt_add <= cnt_add +1;
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
          cnt_add <= cnt_add +1;
          end
          end
        else if(cnt_add==6)
          begin
            cnt_add<=0;
            if(cnt==0)
          begin
           data<=bmreg[7:4];
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
          end
            state<=sip;
          end
          end
        sip :begin
          bmreg<=src_ip_add[cnt_add];
        if(cnt_add<3)
          begin
             //bmreg<=src_ip_add[cnt_add];
        if(cnt==0)
          begin
           data<=bmreg[7:4];
           //cnt_add <= cnt_add +1;
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
           cnt_add <= cnt_add +1;
          end
          end
        else if(cnt_add==3)
          begin
            cnt_add<=0;
            if(cnt==0)
          begin
           data<=bmreg[7:4];
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
          end
            state<=dmac;
          end
          end
       dmac: begin
         bmreg<= des_mac_add[cnt_add];
        if(cnt_add<6)
          begin
            // bmreg<= des_mac_add[cnt_add];
        if(cnt==0)
          begin
           data<=bmreg[7:4];
           //cnt_add <= cnt_add +1;
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
           cnt_add <= cnt_add +1;
          end
          end
        else if(cnt_add==6)
          begin
            cnt_add<=0;
            if(cnt==0)
          begin
           data<=bmreg[7:4];
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
          end
            state<=dip;
          end
          end
        dip :begin
           bmreg<= des_ip_add[cnt_add];
        if(cnt_add<4)
          begin
             //bmreg<= des_ip_add[cnt_add];
        if(cnt==0)
          begin
           data<=bmreg[7:4];
           //cnt_add <= cnt_add +1;
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
          cnt_add <= cnt_add +1;
          end
          end
        else if(cnt_add==4)
          begin
            cnt_add<=0;
            if(cnt==0)
          begin
           data<=bmreg[7:4];
          end
         else if(cnt==1)
          begin
          data<=bmreg[3:0];
          end
            state<=padding;
          end
          end
        padding : begin
        if(cnt_add<19)
          begin
        if(cnt==0)
          begin
           data<=padding_reg[7:4];
           //cnt_add <= cnt_add +1;
          end
        else if(cnt==1)
          begin
          data<=padding_reg[3:0];
         cnt_add <= cnt_add +1;
          end
          end
        else if(cnt_add==19)
          begin
            cnt_add<=0;
            if(cnt==0)
          begin
           data<=padding_reg[7:4];
          end
        else if(cnt==1)
          begin
          data<=padding_reg[3:0];
          end
            state<=crc_type;
          end
          end
        crc_type : begin
          bmreg<= crc[cnt_add];
        if(cnt_add<7)
          begin
        if(cnt==0)
          begin
           data<=bmreg[7:4];
           //cnt_add <= cnt_add +1;
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
          cnt_add <= cnt_add +1;
          end
          end
        else if(cnt_add==7)
          begin
            cnt_add<=0;
            if(cnt==0)
          begin
           data<=bmreg[7:4];
          end
        else if(cnt==1)
          begin
          data<=bmreg[3:0];
          end
            sender_en<=1'b0;
          end
          end
      default :begin
             if(cnt==0)
             begin
           data<=pre_reg[7:4];
           //cnt_add <= cnt_add +1;
              end
            else if(cnt==1)
             begin
           data<=pre_reg[3:0];
           cnt_add <= cnt_add +1;
              end
              //cnt_add <= cnt_add +1;
              state<=pre;
              end
endcase
end
endmodule
              
                  
           
    
  
  
  
  
  
  
  