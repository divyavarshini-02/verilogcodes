module tcp_tx(clk,er,tx_en,dataout,shift_90,ar,sr,ack_reg,sw,CRC_32_op,tx_temp,a,b,cnt);
  //tx input-output
  input clk;
  input sr,sw;
  input [31:0] ack_reg;
  output shift_90;
  output er; 
  //reg [3:0]data_1,data_2;
  output reg tx_en;
  output [3:0]dataout;
  output reg ar=1'b0;
  output [31:0] CRC_32_op;
  output reg [591:0]tx_temp;
  
  //tx-reg
  reg er_out=0;
  output reg [19:0]cnt=20'b0;
  reg [1:0] st=2'b00;
  reg [55:0]pre=56'h55555555555555;
  reg [7:0] sfd=8'hd5;
  reg [47:0]d_mac=48'ha0b1c2d3e4f5;
  reg [47:0]s_mac=48'h24be051e72e9;
  reg [15:0]lt=16'h0800;
  reg [3:0] ver=4'b0100;
  reg [3:0]ihl=4'b0101;
  reg [7:0]tos=8'b00000000;
  reg [15:0]tl=16'd48;
  reg [15:0]id=16'b0000000000000000;
  reg [15:0]fragment=16'h4000;
  reg [7:0]ttl=8'd64;
  reg [7:0]pro=8'd6;
  reg [15:0]checksum=16'h3ac9;
  reg [31:0]s_ip=32'hc010fe01;
  reg [31:0]d_ip=32'hc0a20d2d;
  reg [15:0] s_tcp=16'd20;
  reg [15:0] d_tcp=16'd80;
  reg [31:0] seq_num=32'd10000;
  reg [31:0] ack_num=32'd00000;
  reg [3:0] data_offset=4'd7;
  reg [5:0] revd=6'd0;
  reg [5:0] bit_sa=6'b000010;
  reg [15:0] window=16'd 0;
  reg [15:0] checksum_tcp=16'd0;
  reg [15:0] ugp=16'd0;
  reg [63:0] pad_tcp=64'b0;
  reg [31:0] fcs=32'habcdef12;
  output reg [3:0] a,b;
  wire init;
  wire valid;
  wire [7:0]inp_data;
  //assign
  assign  er=er_out;
  assign inp_data = {b,a};
  
  
  //parameter
  parameter s0=2'b00,s1=2'b01,s2=2'b10;
  assign init = (cnt>=0 && cnt<=10)?1'b1:1'b0;
  assign valid=(cnt>=11 && cnt<=72)?1'b1:1'b0;
  
 CRC_32_gen sd(clk,init,valid,inp_data,CRC_32_op);
  
  always @(posedge clk)
   begin
     if(sw == 1'b1)
       begin
     case(st)
    s0:begin
     if(cnt<1)
       begin
         tx_en<=1'b0;
          tx_temp[591:0]<={fcs[7:0],fcs[15:8],fcs[23:16],fcs[31:24],pad_tcp,ugp[7:0],ugp[15:8],checksum_tcp[7:0],checksum_tcp[15:8],window[7:0],window[15:8],revd[1:0],bit_sa[5:4],bit_sa[3:0],data_offset,revd[5:2],
                          ack_num[7:0],ack_num[15:8],ack_num[23:16],ack_num[31:24],seq_num[7:0],seq_num[15:8],seq_num[23:16],seq_num[31:24],d_tcp[7:0],d_tcp[15:8],s_tcp[7:0],s_tcp[15:8],d_ip[7:0],d_ip[15:8],
                          d_ip[23:16],d_ip[31:24],s_ip[7:0],s_ip[15:8],s_ip[23:16],s_ip[31:24],checksum[7:0],checksum[15:8],pro,ttl,fragment[7:0],fragment[15:8],id[7:0],id[15:8],tl[7:0],tl[15:8],
                          tos,ver,ihl,lt[7:0],lt[15:8],s_mac[7:0],s_mac[15:8],s_mac[23:16],s_mac[31:24],s_mac[39:32],s_mac[47:40],d_mac[7:0],d_mac[15:8],d_mac[23:16],d_mac[31:24],d_mac[39:32],d_mac[47:40],sfd,pre};    
         cnt<=cnt+1;
       end
     else
       begin
         tx_en<=1'b0;
         cnt<=cnt+1;
         st<=s1;
       end
    end   
       
    s1:begin
     if(cnt>=2 && cnt<=75)
       begin
          tx_en<=1'b1;
          a <= tx_temp[3:0];
          b <= tx_temp[7:4];
          tx_temp<=tx_temp>>8;
          cnt<= cnt+1;
       end
    else
      begin
        tx_en<=1'b0;
        cnt<=0;
        st<=s2;
        ar<=1'b1;
       end
       end
    s2:begin
        if(cnt<=20'd124998)
         begin
          tx_en<=1'b0;
          cnt<=cnt+1;
          end
        else
          begin
          tx_en<=1'b0;
          if(sr==1'b1)
            begin
              st<=s0;
               ar<=1'b0;
              bit_sa<=6'b010000;
              ack_num<=ack_reg+1'b1;
              cnt<=7'b0;
            end 
          end
        end    
endcase
end
else
  begin
  tx_en<=1'b0;
  end
end
endmodule  

     
module tcp_rx(clk,ar,sr,ack_reg,dataout_rx,rx_clk,rx_er,rx_dv,rx_crs,rx_col,mem,temp,rx_data_2,rx_data_1);                           
input ar;
output reg sr;
input clk,rx_clk,rx_er,rx_dv,rx_crs,rx_col;
input [3:0]dataout_rx;
wire repclk;
output  [3:0]rx_data_2,rx_data_1;
output reg [63:0]temp;
output reg [527:0]mem;
reg [6:0]cnt;
output reg [31:0] ack_reg;
 	
always @(posedge clk)
begin
if(ar==1'b1)
begin

 if((rx_dv^rx_er)==0)
   begin
  cnt<=0;
 if ((mem[380] && mem[377])==1)
  begin
    sr<=1'b1;
    ack_reg<=mem[335:304];
  end
   end


else 
begin
if(cnt<=7)
  begin
temp<={rx_data_2,rx_data_1,temp[63:8]};
cnt<=cnt+1;
sr<=1'b0;

  end

else if((cnt>7 && cnt<=73)&&(temp== 64'h5D55555555555555))
  begin
mem<={rx_data_2,rx_data_1,mem[527:8]};
cnt<=cnt+1;
sr<=1'b0;
  end

else
  begin 
cnt<=0;
  end
  

end
end
end
endmodule    


module tcp_phychip(clk,mdc,mdio);
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
   






































     
  
      
         
         
         
         
     
     
              
              

