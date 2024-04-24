module eth_mac_ss(clk,int_N,rst,er,tx_en,dataout,shift_90);
  input clk;
  input int_N;
  output shift_90;
  output reg  rst=1;
  output reg er=0; 
  reg [3:0]data_1,data_2;
  output tx_en;
  output [3:0]dataout;
 
  //memory
  reg [3:0] board_mac_add =4'hf;
  reg [7:0] src_mac_add [0:5];
  reg [3:0] des_mac_add =4'h0;
  reg [7:0] src_ip_add[0:3];
  reg [7:0] des_ip_add[0:3];
  reg [7:0] crc[0:3];
  //reg
  reg [7:0] bmreg;
  reg [3:0] pre_reg =4'b 0101;
  reg [7:0] sfd_reg =8'b 1101_0101;
  reg [15:0] frame_type=16'h0806;
  reg [15:0] hard_type=16'h0001;
  reg [15:0] protocol_type=16'h0800;
  reg [7:0] hard_len=8'h06;
  reg [7:0] ip_len=8'h04;
  reg [15:0] request=16'h0001;
  reg [3:0] padding_reg=4'b0;
  reg sender_en;
  reg [4:0]state=5'b0;
  reg [19:0] cnt_add=0;
  wire tx_clk;
  wire areset;
  wire locked;
  
  parameter en_clk=5'b 00000,pre=5'b00001,sfd=5'b00010,des_add=5'b00011,src_add=5'b00100,frm_ty=5'b00101,ht=5'b00110,pt=5'b00111,
  hl=5'b01000,ipl=5'b01001, req=5'b01010,smac =5'b01011,sip=5'b01100,dmac=5'b01101,dip=5'b01110,padding=5'b01111,
  crc_type=5'b10000,en_cnt=5'b10001;
  
  assign tx_en=sender_en;
 assign tx_clk = clk;
  
 
/*	dd_mac q1(
	data_1,
	data_2,
	tx_clk,
	dataout);
	
	clk_mac q2(
	areset,
	clk,
	shift_90,
	tx_clk,
	locked);*/

  
  always @ (posedge tx_clk)
  begin
    
    src_mac_add[0]<=8'hac;
    src_mac_add[1]<=8'h16;
    src_mac_add[2]<=8'h2d;
    src_mac_add[3]<=8'hbb;
    src_mac_add[4]<=8'h53;
    src_mac_add[5]<=8'ha1;
    
    src_ip_add[0]<=8'd192;
    src_ip_add[1]<=8'd168;
    src_ip_add[2]<=8'd0;
    src_ip_add[3]<=8'd11;
    
    des_ip_add[0]<=8'd192;
    des_ip_add[1]<=8'd168;
    des_ip_add[2]<=8'd13;
    des_ip_add[3]<=8'd69;
    
       crc[0]<=8'h93;
       crc[1]<=8'hFE;
       crc[2]<=8'h07;
       crc[3]<=8'h2A;
  end
  
        
         always @(posedge tx_clk)
         
         begin
               cnt_add<=cnt_add+1;
             case (state)
           en_clk : begin
			   if(cnt_add>=20'd0 && cnt_add<20'd1)
                  begin
                       sender_en<=0;
                       state<=en_clk;
                       end
				            else
				          begin
				                sender_en<=0;
                       cnt_add<=0;
                       state<=pre;
                       end
							  end
                  
             pre: begin 
                  sender_en<=1;
                if(cnt_add>=20'd0 && cnt_add<20'd6)
                  begin
                    data_1<=pre_reg[3:0];
                    data_2<=pre_reg[3:0]; 
                 end 
                else
                  begin
                    state<=sfd;
                    cnt_add<=0;
                end
                end 
             
             sfd: begin
               
               if(cnt_add==20'd0)
                 begin
                 data_1<=sfd_reg[3:0];
                 data_2<=sfd_reg[7:4];
                    cnt_add<=0;
                    state<=des_add;
                 end
                 end
          des_add : begin
               
               if(cnt_add>=20'd0 && cnt_add<20'd5)
                 begin
                 data_1<=board_mac_add[3:0];
                 data_2<=board_mac_add[3:0];
                 end
               else
                 begin
                   cnt_add<=20'd0;
                   bmreg<=src_mac_add[0];
                    state<= src_add;
                 end
              end
            src_add :begin
                if(cnt_add==20'd0)
                  begin
                     data_1<=bmreg[3:0];
                     data_2<=bmreg[7:4];
                   bmreg<=src_mac_add[cnt_add+1];
                  end
                else if(cnt_add==20'd1)
                  begin
                     data_1<=bmreg[3:0];
                     data_2<=bmreg[7:4];
                   bmreg<=src_mac_add[cnt_add+1];
                  end
                else if(cnt_add==20'd2)
                  begin
                     data_1<=bmreg[3:0];
                     data_2<=bmreg[7:4];
                  bmreg<=src_mac_add[cnt_add+1];
                  end
                else if(cnt_add==20'd3)
                  begin
                     data_1<=bmreg[3:0];
                     data_2=bmreg[7:4];
                  bmreg<=src_mac_add[cnt_add+1];
                  end
                else if(cnt_add==20'd4)
                  begin
                     data_1<=bmreg[3:0];
                     data_2=bmreg[7:4];
                  bmreg<=src_mac_add[cnt_add+1];
                  end
                else if(cnt_add==20'd5)
                  begin
                    data_1<=bmreg[3:0];
                    data_2<=bmreg[7:4];
                  bmreg<=frame_type[15:8];
                  cnt_add<=0;
                  state<=frm_ty;
                  end
                end
              frm_ty : begin
                if(cnt_add==20'd0)
                  begin
                    data_1<=bmreg[3:0];
                    data_2<=bmreg[7:4];
                   bmreg<=frame_type[7:0];
                  end
                else if(cnt_add==20'd1)
                  begin
                    data_1<=bmreg[3:0];
                    data_2<=bmreg[7:4];
                  cnt_add<=0;
                  bmreg<=hard_type[15:8];
                  state<=ht;
                  end
               end
                ht:begin
                  if(cnt_add==20'd0)
                  begin
                     data_1<=bmreg[3:0];
                     data_2<=bmreg[7:4];
                   bmreg<=hard_type[7:0];
                  end
                else if(cnt_add==20'd1)
                  begin
                     data_1<=bmreg[3:0];
                     data_2<=bmreg[7:4];
                  cnt_add<=0;
                  bmreg<=protocol_type[15:8];
                  state<=pt;
                  end
               end
               pt:begin
                 if(cnt_add==20'd0)
                   begin
                     data_1<=bmreg[3:0];
                     data_2<=bmreg[7:4];
                    bmreg<=protocol_type[7:0];
                   end
                else if(cnt_add==20'd1)
                  begin
                     data_1<=bmreg[3:0];
                     data_2<=bmreg[7:4];
                   cnt_add<=0;
                   state<=hl;
                  end
               end
                hl: begin
                   if(cnt_add==20'd0)
                   begin
                     data_1<=hard_len[3:0];
                     data_2<=hard_len[7:4];
                    cnt_add<=0;
                    state<=ipl;
                    end
                    end
                ipl :begin
                   if(cnt_add==20'd0)
                  begin
                     data_1<=ip_len[3:0];
                     data_2<=ip_len[7:4];
                    cnt_add<=0;
                    bmreg<=request[15:8];
                    state<=req;
                  end
                  end
                req : begin
                 if(cnt_add==20'd0)
                   begin
                     data_1<=bmreg[3:0];
                     data_2<=bmreg[7:4];
                   bmreg<=request[7:0];
                  end
                else if(cnt_add==20'd1)
                  begin
                     data_1<=bmreg[3:0];
                     data_2<=bmreg[7:4];
                  cnt_add<=0;
                  bmreg<=src_mac_add[0];
                  state<=smac;
                  end
                  end
               smac :begin
                if(cnt_add==20'd0)
                  begin
                     data_1<=bmreg[3:0];
                     data_2<=bmreg[7:4];
                   bmreg<=src_mac_add[cnt_add+1];
                  end
                else if(cnt_add==20'd1)
                  begin
                     data_1<=bmreg[3:0];
                     data_2<=bmreg[7:4];
                   bmreg<=src_mac_add[cnt_add+1];
                  end
                else if(cnt_add==20'd2)
                  begin
                     data_1<=bmreg[3:0];
                     data_2<=bmreg[7:4];
                   bmreg<=src_mac_add[cnt_add+1];
                  end
                else if(cnt_add==20'd3)
                  begin
                     data_1<=bmreg[3:0];
                     data_2<=bmreg[7:4];
                   bmreg<=src_mac_add[cnt_add+1];
                  end
                else if(cnt_add==20'd4)
                  begin
                     data_1<=bmreg[3:0];
                     data_2<=bmreg[7:4];
                   bmreg<=src_mac_add[cnt_add+1];
                  end
                else if(cnt_add==20'd5)
                  begin
                    data_1<=bmreg[3:0];
                    data_2<=bmreg[7:4];
                  bmreg<=src_ip_add[0];
                   cnt_add<=0;
                  state<=sip;
                  end
                end
                sip :begin
                if(cnt_add==20'd0)
                  begin
                    data_1<=bmreg[3:0];
                    data_2<=bmreg[7:4];
                   bmreg<=src_ip_add[cnt_add+1];
                  end
                else if(cnt_add==20'd1)
                  begin
                    data_1<=bmreg[3:0];
                    data_2<=bmreg[7:4];
                   bmreg<=src_ip_add[cnt_add+1];
                  end
                  else if(cnt_add==20'd2)
                  begin
                    data_1<=bmreg[3:0];
                    data_2<=bmreg[7:4];
                   bmreg<=src_ip_add[cnt_add+1];
                  end
                 else if(cnt_add==20'd3)
                 begin
                    data_1<=bmreg[3:0];
                    data_2<=bmreg[7:4];
                   cnt_add<=0;
                  state<=dmac;
                  end
                  end
             dmac :begin
               
                 if(cnt_add>=20'd0 && cnt_add<20'd5)
                  begin
                 data_1<=des_mac_add[3:0];
                 data_2<=des_mac_add[3:0];
                   end
                  else
                   begin
                   cnt_add<=0;
                   bmreg<=des_ip_add[0];
                  state<= dip ;
                 end
                 end
              dip : begin
                if(cnt_add==20'd0)
                  begin
                    data_1<=bmreg[3:0];
                    data_2<=bmreg[7:4];
                   bmreg<=des_ip_add[cnt_add+1];
                  end
                else if(cnt_add==20'd1)
                   begin
                    data_1<=bmreg[3:0];
		              data_2<=bmreg[7:4];
		             bmreg<=des_ip_add[cnt_add+1];
                  end
                else if(cnt_add==20'd2)
                   begin
                    data_1<=bmreg[3:0];
                    data_2<=bmreg[7:4];
                   bmreg<=des_ip_add[cnt_add+1];
                  end
                 else if(cnt_add==20'd3)
                  begin
                    data_1<=bmreg[3:0];
                    data_2<=bmreg[7:4];
                   cnt_add<=0;
                  state<=padding;
                  end
                  end 
              padding:begin
                if(cnt_add>=20'd0 && cnt_add<20'd17)
                  begin
                    data_1<=padding_reg[3:0];
                    data_2<=padding_reg[3:0];
                 end
                 
                 else
                 begin
                     state<= crc_type;
                       bmreg<= crc[0];
                     cnt_add<=0;
                  end
                  end 
              crc_type : begin
                if(cnt_add==20'd0)
                  begin
                    data_1<=bmreg[3:0];
                    data_2<=bmreg[7:4];
                   bmreg<=crc[cnt_add+1];
                  end
                else  if(cnt_add==20'd1)
                  begin
                    data_1<=bmreg[3:0];
                    data_2<=bmreg[7:4];
                   bmreg<=crc[cnt_add+1];
                  end
                  else  if(cnt_add==20'd2)
                  begin
                    data_1<=bmreg[3:0];
                    data_2<=bmreg[7:4];
                   bmreg<=crc[cnt_add+1];
                  end
                 else if(cnt_add==20'd3)
                  begin
                    data_1<=bmreg[3:0];
                    data_2<=bmreg[7:4];
                    cnt_add<=0;
                    state<=en_cnt;
                  end
                  end     
              en_cnt : begin
                     if(cnt_add <= 20'd124999)
                       begin
                          sender_en<=0;
                          state<=en_cnt;
                       end
                     else if (cnt_add >20'd125000)
                        begin
                           sender_en<=0;
                            cnt_add<=0;
                          state<=en_clk;
                       end                
                       end
               /*   default :
                  begin
                  cnt_add<=0;
                  sender_en<=0;
                  state<=en_clk;
                  end*/                
endcase
end
endmodule
