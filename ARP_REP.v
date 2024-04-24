module arp_r(rx_clk,int_N,rx_er,rx_dv,rx_crs,rx_col,rst,rx_en,dataout,bmac1,smac2,desm,sip1,mip2,crc_rx);
  input rx_clk;
  input int_N;
  input rx_er;
  input rx_dv;
  input rx_crs;
  input rx_col; 
  output rst;
  input rx_en;
  input [3:0]dataout;
  output [47:0]bmac1;
  output [47:0]smac2;
  output [47:0]desm;
  output [31:0]sip1;
  output [31:0]mip2;
  output [31:0]crc_rx;
  //memory
  reg [7:0] board_mac_add[0:5];
  reg [7:0] src_mac_add [0:5];
  reg [7:0] des_mac_add [0:5];
  reg [7:0] src_ip_add[0:3];
  reg [7:0] des_ip_add[0:3];
  reg [7:0] crc[0:3];
  //reg
  reg [7:0] bmreg;
  reg rst_out=1;
  reg [3:0]data_1,data_2;
  reg [3:0] pre_reg;
  reg [7:0] sfd_reg;
  reg [15:0] frame_type;
  reg [15:0] hard_type;
  reg [15:0] protocol_type;
  reg [7:0] hard_len;
  reg [7:0] ip_len;
  reg [15:0] replay;
  reg [3:0] padding_reg;
  reg sender_en;
  reg [4:0]state=5'b00000;
  reg [19:0] cnt_add=0;
   
 
  
  parameter pre=5'b00000,sfd=5'b00001,des_add=5'b00010,src_add=5'b00011,frm_ty=5'b00100,ht=5'b00101,pt=5'b00110,
  hl=5'b00111,ipl=5'b01000, req=5'b01001,smac =5'b01010,sip=5'b01011,dmac=5'b01100,dip=5'b01101,padding=5'b01110,
  crc_type=5'b01111;
  
  assign  rst=rst_out;
  assign bmac1[47:40] =board_mac_add[0];
  assign bmac1[39:32] =board_mac_add[1];
  assign bmac1[31:24] =board_mac_add[2];
  assign bmac1[23:16] =board_mac_add[3];
  assign bmac1[15:8]  =board_mac_add[4];
  assign bmac1[7:0]   =board_mac_add[5];
  
  assign smac2[47:40] =src_mac_add[0];
  assign smac2[39:32] =src_mac_add[1];
  assign smac2[31:24] =src_mac_add[2];
  assign smac2[23:16] =src_mac_add[3];
  assign smac2[15:8]  =src_mac_add[4];
  assign smac2[7:0]   =src_mac_add[5];
  
  assign desm[47:40]=des_mac_add[0];
  assign desm[39:32] =des_mac_add[1];
  assign desm[31:24] =des_mac_add[2];
  assign desm[23:16] =des_mac_add[3];
  assign desm[15:8]  =des_mac_add[4];
  assign desm[7:0]   =des_mac_add[5];
  
  assign sip1[31:24] =src_ip_add[0];
  assign sip1[23:16] =src_ip_add[1];
  assign sip1[15:8]  =src_ip_add[2];
  assign sip1[7:0]   =src_ip_add[3];
  
  assign mip2[31:24] =des_ip_add[0];
  assign mip2[23:16] =des_ip_add[1];
  assign mip2[15:8]  =des_ip_add[2];
  assign mip2[7:0]   =des_ip_add[3];
  
  assign crc_rx[31:24] =crc[0];
  assign crc_rx[23:16] =crc[1];
  assign crc_rx[15:8]  =crc[2];
  assign crc_rx[7:0]   =crc[3];
  
  
/*	dd_mac q1(
	data_1,
	data_2,
	tx_clk,
	dataout);*/
	  always @(posedge rx_clk)
         
         begin
               cnt_add<=cnt_add+1;
             case (state)       
             pre: begin 
                if(cnt_add>=20'd0 && cnt_add<20'd6)
                  begin
                    pre_reg[3:0]<=4'b0101;
                    pre_reg[3:0]<=4'b0101; 
                 end 
                else
                  begin
                    state<=sfd;
                    pre_reg[3:0]<=4'b0101;
                    pre_reg[3:0]<=4'b0101; 
                    cnt_add<=20'd0;
                end
                end 
             
             sfd: begin
               
               if(cnt_add==20'd0)
                 begin
                 sfd_reg[3:0]<=4'b1101;
                 sfd_reg[7:4]<=4'b0101;
                    cnt_add<=20'd0;
                    state<=des_add;
                 end
                 end
          des_add : begin
              if(cnt_add==20'd0)
                  begin
                    bmreg[3:0]<= 4'b0000;
                    bmreg[7:4]<= 4'b0000;
                   board_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd1)
                  begin
                    bmreg[3:0]<= 4'b0000;
                    bmreg[7:4]<= 4'b0000;
                   board_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd2)
                  begin
                    bmreg[3:0]<= 4'b0000;
                    bmreg[7:4]<= 4'b0000;
                   board_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd3)
                  begin
                     bmreg[3:0]<=4'b0000;
                    bmreg[7:4]<= 4'b0000;
                   board_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd4)
                  begin
                    bmreg[3:0]<= 4'b0000;
                    bmreg[7:4]<= 4'b0000;
                   board_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd5)
                  begin
                   cnt_add<=20'd0;
                    bmreg[3:0]<= 4'b0001;
                    bmreg[7:4]<= 4'b0010;
                   board_mac_add[cnt_add+1]<=bmreg;
                   state<= src_add;
                 end
                end
           src_add :begin
                if(cnt_add==20'd0)
                  begin
                    bmreg[3:0]<= 4'b0011;
                    bmreg[7:4]<= 4'b0100;
                   src_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd1)
                  begin
                    bmreg[3:0]<= 4'b0101;
                    bmreg[7:4]<= 4'b0110;
                   src_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd2)
                  begin
                    bmreg[3:0]<= 4'b0111;
                    bmreg[7:4]<= 4'b1000;
                   src_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd3)
                  begin
                     bmreg[3:0]<= 4'b1001;
                    bmreg[7:4]<= 4'b1010;
                   src_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd4)
                  begin
                    bmreg[3:0]<= 4'b1011;
                    bmreg[7:4]<= 4'b1100;
                   src_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd5)
                  begin
                  bmreg[3:0]<= 4'b1101;
                  bmreg[7:4]<= 4'b1110;
                 src_mac_add[cnt_add+1]<=bmreg;
                  cnt_add<=20'd0;
                  state<=frm_ty;
                  end
                end
             frm_ty : begin
                if(cnt_add==20'd0)
                  begin
                   bmreg[3:0]<= 4'b0001;
                   bmreg[7:4]<= 4'b0010;
                   frame_type[15:8]<=bmreg;
                  end
                else if(cnt_add==20'd1)
                  begin
                   bmreg[3:0]<= 4'b0011;
                   bmreg[7:4]<= 4'b0100;
                   frame_type[7:0]<=bmreg;
                   cnt_add<=20'd0;
                   state<=ht;  
                  end
               end
               /* ht:begin
                  if(cnt_add==20'd0)
                  begin
                    bmreg[3:0]<= 4'b0101;
                    bmreg[7:4]<= 4'b0110;
                    hard_type[7:0]<=bmreg;
                  end
                else if(cnt_add==20'd1)
                  begin
                    bmreg[3:0]<= 4'b0111;
                    bmreg[7:4]<= 4'b1000;
                    cnt_add<=20'd0;
                    protocol_type[15:8]<=bmreg;
                    state<=pt;
                  end
               end
               pt:begin
                 if(cnt_add==20'd0)
                   begin
                    bmreg[3:0]<=4'b1001;
                    bmreg[7:4]<=4'b1010;
                    protocol_type[7:0]<=bmreg;
                    cnt_add<=20'd0;
                    state<=hl;
                   end
                   end
                hl: begin
                   if(cnt_add==20'd0)
                   begin
                     hard_len[3:0]<=4'b1011;
                     hard_len[7:4]<=4'b1100;
                     cnt_add<=20'd0;
                     state<=ipl;
                    end
                    end
                ipl :begin
                   if(cnt_add==20'd0)
                  begin
                     ip_len[3:0]<=4'b1101;
                     ip_len[7:4]<=4'b1110;
                   end
                 else if(cnt_add==20'd1)
                   begin
                    cnt_add<=20'd0;
                    bmreg[3:0]<=4'b1111;
                    bmreg[7:4]<=4'b0000;
                    replay[15:8]<=bmreg;
                    state<=req;
                  end
                  end
                req : begin
                 if(cnt_add==20'd0)
                   begin
                    bmreg[3:0]<=4'b0001;
                    bmreg[7:4]<=4'b0010;
                    replay[7:0]<=bmreg;
                  end
                else if(cnt_add==20'd1)
                  begin
                    bmreg[3:0]<=4'b0011;
                    bmreg[7:4]<=4'b0100;
                    cnt_add<=20'd0;
                    src_mac_add[0]<=bmreg;
                    state<=smac;
                  end
                  end
               smac :begin
                if(cnt_add==20'd0)
                  begin
                    bmreg[3:0]<=4'b0101;
                    bmreg[7:4]<=4'b0110;
                    src_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd1)
                  begin
                    bmreg[3:0]<=4'b0111;
                    bmreg[7:4]<=4'b1000;
                    src_mac_add[cnt_add+1]<=bmreg;
                  end                                                        
                else if(cnt_add==20'd2)
                  begin                                                      
                    bmreg[3:0]<=4'b1001;
                    bmreg[7:4]<=4'b1010;
                    src_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd3)
                  begin
                    bmreg[3:0]<=4'b1011;
                    bmreg[7:4]<=4'b1100;
                    src_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd4)
                  begin
                    bmreg[3:0]<=4'b1101;
                    bmreg[7:4]<=4'b1110;
                    src_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd5)
                  begin
                    bmreg[3:0]<=4'b1111;
                    bmreg[7:4]<=4'b0000;
                    src_ip_add[0]<=bmreg;
                    cnt_add<=20'd0;
                    state<=sip;
                  end
                end
                sip :begin
                if(cnt_add==20'd0)
                  begin
                    bmreg[3:0]<=4'b0000;
                    bmreg[7:4]<=4'b0000;
                    src_ip_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd1)
                  begin
                    bmreg[3:0]<=4'b0000;
                    bmreg[7:4]<=4'b0000;
                    src_ip_add[cnt_add+1]<=bmreg;
                  end
                  else if(cnt_add==20'd2)
                  begin
                    bmreg[3:0]<=4'b0000;
                    bmreg[7:4]<=4'b0000;
                    src_ip_add[cnt_add+1]<=bmreg;
                  end
                 else if(cnt_add==20'd3)
                 begin
                    bmreg[3:0]<=4'b0000;
                    bmreg[7:4]<=4'b0000;
                   des_mac_add[cnt_add+1]<=bmreg;
                    cnt_add<=20'd0;
                    state<=dmac;
                  end
                  end
             dmac :begin
               if(cnt_add==20'd0)
                  begin
                    bmreg[3:0]<= 4'b0001;
                    bmreg[7:4]<= 4'b0001;
                   des_mac_add[cnt_add+1]<=bmreg;
                  end 
               else if(cnt_add==20'd1)
                  begin
                    bmreg[3:0]<= 4'b0001;
                    bmreg[7:4]<=4'b0001;
                   des_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd2)
                  begin
                    bmreg[3:0]<= 4'b0001;
                    bmreg[7:4]<= 4'b0001;
                   des_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd3)
                  begin
                     bmreg[3:0]<=4'b0001;
                    bmreg[7:4]<= 4'b0001;
                   des_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd4)
                  begin
                    bmreg[3:0]<=4'b0001;
                    bmreg[7:4]<=4'b0001;
                   des_mac_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd5)
                  begin
                   cnt_add<=20'd0;
                    bmreg[3:0]<=4'b0001;
                    bmreg[7:4]<=4'b0001;
                   des_ip_add[0]<=bmreg;
                  state<= dip ;
                 end
                end
              dip : begin
                if(cnt_add==20'd0)
                  begin
                   bmreg[3:0]<= 4'b0011;
                   bmreg[7:4]<= 4'b0011;
                   des_ip_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd1)
                   begin
                    bmreg[3:0]<= 4'b0011;
                    bmreg[7:4]<= 4'b0011;
		                des_ip_add[cnt_add+1]<=bmreg;
                  end
                else if(cnt_add==20'd2)
                   begin
                    bmreg[3:0]<= 4'b0011;
                    bmreg[7:4]<= 4'b0011;
                    des_ip_add[cnt_add+1]<=bmreg;
                  end
                 else if(cnt_add==20'd3)
                  begin
                    padding_reg[3:0]<=4'b0011;
                    padding_reg[3:0]<=4'b0011;
                    cnt_add<=20'd0;
                    state<=padding;
                  end
                  end 
              padding:begin
                if(cnt_add>=20'd0 && cnt_add<20'd17)
                  begin
                    padding_reg[3:0]<=4'b0100;
                    padding_reg[3:0]<=4'b0100;
                 end
                 
                 else
                 begin
                     state<= crc_type;
                     bmreg[3:0]<= 4'b0101;
                     bmreg[7:4]<= 4'b0101;
                     crc[0]<=bmreg;
                     cnt_add<=20'd0;
                  end
                  end 
              crc_type : begin
                if(cnt_add==20'd0)
                  begin
                   bmreg[3:0]<= 4'b0101;
                   bmreg[7:4]<= 4'b0101;
                   crc[cnt_add+1]<=bmreg;
                  end
                else  if(cnt_add==20'd1)
                  begin
                   bmreg[3:0]<= 4'b0101;
                   bmreg[7:4]<= 4'b0101;
                   crc[cnt_add+1]<=bmreg;
                  end
                  else  if(cnt_add==20'd2)
                  begin
                   bmreg[3:0]<= 4'b0101;
                   bmreg[7:4]<= 4'b0101;
                   crc[cnt_add+1]<=bmreg;
                   cnt_add<=20'd0;
                   state<=pre;
                  end
                  end   */ 
                    
endcase
end
endmodule


