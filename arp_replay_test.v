module eth_rec_ee(clk,dataout_rx,rx_clk,rx_er,rx_dv,rx_crs,rx_col,temp);
  input clk;
  input rx_clk;
  input rx_er;
  input rx_dv;
  input rx_crs;
  input rx_col; 
  input [3:0]dataout_rx;
  output [511:0]temp;
  
  
  //reg

  wire [3:0]rx_data_1;
  wire [3:0]rx_data_2;
   
   reg [15:0]rx_frame_type;
   reg [15:0]rx_hard_type;
   reg [15:0]rx_protocol_type;
   reg [7:0] rx_hard_len;
   reg [7:0] rx_ip_len;
   reg [15:0]replay;
   reg [143:0] rx_padding_reg;
   reg [4:0]st=5'b00001;
   reg [19:0] cnt=0;
   reg [47:0]bmac1;
   reg [47:0]smac1;
   reg [47:0]smac2;
   reg [47:0]desm;
   reg [31:0]sip1;
   reg [31:0]mip2;
   reg [31:0]crc_rx;
  wire [7:0] crt_data;
  wire repclk;
  
  parameter  rpre=5'b00001,rdes_add=5'b00010,rsrc_add=5'b00011,rfrm_ty=5'b00100,rht=5'b00101,rpt=5'b00110,
  rhl=5'b00111,ripl=5'b01000, rreq=5'b01001,rsmac =5'b01010,rsip=5'b01011,rdmac=5'b01100,rdip=5'b01101,rpadding=5'b01110,
  rcrc_type=5'b01111;
  assign temp[511:0]={bmac1[47:0],smac1[47:0],rx_frame_type[15:0],rx_hard_type[15:0],rx_protocol_type[15:0],rx_hard_len[7:0],rx_ip_len[7:0],replay[15:0],smac2[47:0],sip1[31:0],desm[47:0],mip2[31:0],rx_padding_reg[143:0],crc_rx[31:0]};
  assign crt_data={rx_data_2,rx_data_1}; 
  /*dd_rec xy(
	dataout_rx,
        repclk,
	rx_data_1,
	rx_data_2);
	
	rx_rep_clk zx(
	clk,
	repclk);*/

	
	  always @(posedge clk) 
     begin 
          if(rx_dv^rx_er==1'b0)
				      begin
				     cnt<=1'b0;				       
				      end
			    else if(rx_dv^rx_er==1'b1)
				     begin
            cnt<=cnt+1'b1;
             case (st)       
              rpre:begin
		                if(cnt>=20'd0 && cnt<20'd7)
                      begin
                         if(crt_data== 8'h55)
                           begin
                           st<=rpre;
                           end
                         else //if (crt_data!= 8'h55)
                           begin 
                           cnt<=20'd0;
                           st<=rpre;
                           end
                      end 
                      else if(cnt==20'd7)
                        begin
                         if(crt_data== 8'hd5)
                           begin
                           cnt<=20'd0;
                           st<=rdes_add;
                           end
                         else //if (crt_data!= 8'hd5)
                           begin
                           cnt<=20'd0;
                           st<=rpre;
                           end
                      end 
                 end
             
              rdes_add : begin
                 if(cnt==20'd0) 
                 begin  
                    bmac1[47:40]<=crt_data;
                 end
                 else if(cnt==20'd1)
                  begin                   
                   bmac1[39:32]<=crt_data;
                  end
                 else if(cnt==20'd2)
                  begin                                   
                   bmac1[31:24]<=crt_data;                                 
                  end                                                      
                 else if(cnt==20'd3)                                    
                  begin                                             
                   bmac1[23:16]<=crt_data; 
                  end                                                      
                 else if(cnt==20'd4)                                       
                  begin                  
                   bmac1[15:8]<= crt_data; 
                  end
                 else if(cnt==20'd5)
                  begin
                   bmac1[7:0]<=crt_data; 
                   cnt<=20'd0;
                   st<= rsrc_add;
                  end
                
                end
            rsrc_add :begin
                if(cnt==20'd0)
                  begin
                    smac1[47:40]<=crt_data; 
                  end
                else if(cnt==20'd1)
                  begin
                    smac1[39:32]<=crt_data; 
                  end
                else if(cnt==20'd2)
                  begin
                    smac1[31:24]<=crt_data; 
                  end
                else if(cnt==20'd3)
                  begin                    
                    smac1[23:16]<=crt_data; 
                 end
                else if(cnt==20'd4)
                  begin
                    smac1[15:8]<=crt_data; 
                  end
                else if(cnt==20'd5)
                  begin
                    smac1[7:0]<=crt_data; 
                    cnt<=20'd0;
                    st<=rfrm_ty;
                  end 
                    
                end
             rfrm_ty : begin
                if(cnt==20'd0)
                  begin
                  rx_frame_type[15:8]<=crt_data;                                       
                  end
                else if(cnt==20'd1)
                  begin                  
                    rx_frame_type[7:0]<=crt_data;                                                         
                    cnt<=20'd0;
                    st<=rht;  
                  end
               end
                rht:begin
                  if(cnt==20'd0)
                  begin                     
                     rx_hard_type[15:8]<=crt_data; 
                  end
                else if(cnt==20'd1)
                  begin                     
                     rx_hard_type[7:0]<=crt_data; 
                     cnt<=20'd0;
                     st<=rpt;
                  end
               end
               rpt:begin
                  if(cnt==20'd0)
                  begin                     
                     rx_protocol_type[15:8]<=crt_data; 
                  end
                 else if(cnt==20'd1)
                   begin                     
                     rx_protocol_type[7:0]<=crt_data; 
                     cnt<=20'd0;
                     st<=rhl;
                   end
                   end
                rhl: begin
                   if(cnt==20'd0)
                   begin                     
                      rx_hard_len[7:0]<=crt_data; 
                      cnt<=20'd0;
                      st<=ripl;
                    end
                    end
                ripl :begin
                   if(cnt==20'd0)
                  begin                     
                      rx_ip_len[7:0]<=crt_data; 
                      cnt<=20'd0;
                      st<=rreq;
                  end
                  end
                rreq : begin
                if(cnt==20'd0)
                   begin                    
                     replay[15:8]<=crt_data; 
                   end
                 else if(cnt==20'd1)
                   begin                    
                     replay[7:0]<=crt_data; 
                     cnt<=20'd0;
                     st<=rsmac;                               
                  end
                  end
               rsmac :begin
                if(cnt==20'd0)
                  begin                   
                    smac2[47:40]<= crt_data; 
                  end
                else if(cnt==20'd1)
                  begin                   
                    smac2[39:32]<= crt_data; 
                  end
                else if(cnt==20'd2)
                  begin                   
                    smac2[31:24]<=crt_data; 
                  end
                else if(cnt==20'd3)
                  begin                    
                    smac2[23:16]<= crt_data; 
                 end
                else if(cnt==20'd4)
                  begin                    
                    smac2[15:8]<= crt_data;                
                  end
                else if(cnt==20'd5)
                  begin                    
                    smac2[7:0]<= crt_data; 
                    cnt<=20'd0;
                    st<=rsip;
                  end
                end
                rsip :begin
                if(cnt==20'd0)
                  begin
                    sip1[31:24]<=crt_data; 
                  end
                else if(cnt==20'd1)
                  begin
                    sip1[23:16]<=crt_data; 
                  end
                else if(cnt==20'd2)
                  begin                   
                    sip1[15:8]<=crt_data; 
                  end
                  else if(cnt==20'd3)
                  begin                    
                    sip1[7:0]<=crt_data; 
                    cnt<=20'd0;
                    st<=rdmac;
                  end
                  end
             rdmac :begin
               if(cnt==20'd0)
                  begin                    
                    desm[47:40]<=crt_data; 
                  end 
               else if(cnt==20'd1)
                  begin                    
                    desm[39:32]<=crt_data; 
                  end 
               else if(cnt==20'd2)
                  begin                                                  
                    desm[31:24]<=crt_data;                                 
                  end                                                      
                else if(cnt==20'd3)                                    
                  begin                                                
                    desm[23:16]<=crt_data; 
                  end                                                     
                else if(cnt==20'd4)                                       
                  begin                    
                    desm[15:8]<=crt_data; 
                  end
                else if(cnt==20'd5)
                  begin
                  cnt<=20'd0;                   
                  desm[7:0]<=crt_data; 
                  st<=rdip ;   
                   end
                end
              rdip : begin

                if(cnt==20'd0)
                  begin                   
                    mip2[31:24]<=crt_data; 
                  end
                else if(cnt==20'd1)
                  begin                   
                    mip2[23:16]<=crt_data; 
                  end
                else if(cnt==20'd2)
                   begin 
                    mip2[15:8]<=crt_data; 
                  end
                else if(cnt==20'd3)
                   begin
                    mip2[7:0]<=crt_data;
                    cnt<=20'd0;
                    st<=rpadding; 
                  end
                  end 
              rpadding:begin
                  
               if(cnt==20'd0)
                  begin                 
                    rx_padding_reg[143:136]<=crt_data; 
                 end  
                else if(cnt==20'd1)
                  begin                 
                    rx_padding_reg[135:128]<=crt_data; 
                 end  
                  else if(cnt==20'd2)
                  begin                 
                    rx_padding_reg[127:120]<=crt_data; 
                  end  
                 else if(cnt==20'd3)
                  begin                 
                    rx_padding_reg[119:112]<=crt_data; 
                 end  
                 else if(cnt==20'd4)
                  begin                 
                    rx_padding_reg[111:104]<=crt_data; 
                 end  
                 else if(cnt==20'd5)
                  begin                 
                    rx_padding_reg[103:96]<=crt_data; 
                 end  
                 else if(cnt==20'd6)
                  begin                 
                    rx_padding_reg[95:88]<=crt_data; 
                 end  
                 else if(cnt==20'd7)
                  begin                 
                    rx_padding_reg[87:80]<=crt_data; 
                  end  
                 else if(cnt==20'd8)
                  begin                 
                    rx_padding_reg[79:72]<=crt_data; 
                 end  
                 else if(cnt==20'd9)
                  begin                 
                    rx_padding_reg[71:64]<=crt_data; 
                 end  
                 else if(cnt==20'd10)
                  begin                 
                    rx_padding_reg[63:56]<=crt_data; 
                 end  
                 else if(cnt==20'd11)
                  begin                 
                    rx_padding_reg[55:48]<=crt_data; 
                 end  
                 else if(cnt==20'd12)
                  begin                 
                    rx_padding_reg[47:40]<=crt_data; 
                  end  
                 else if(cnt==20'd13)
                  begin                 
                    rx_padding_reg[39:32]<=crt_data; 
                 end 
                 else if(cnt==20'd14)
                  begin                 
                    rx_padding_reg[31:24]<=crt_data; 
                 end  
                 else if(cnt==20'd015)
                  begin                 
                    rx_padding_reg[23:16]<=crt_data; 
                 end  
                 else if(cnt==20'd16)
                  begin                 
                    rx_padding_reg[15:8]<=crt_data; 
                 end                   
                 else if(cnt==20'd17)
                 begin
                    st<= rcrc_type; 
                    rx_padding_reg[7:0]<=crt_data;                   
                    cnt<=20'd0;
                  end
                  end 
              rcrc_type : begin
                if(cnt==20'd0)
                  begin                   
                   crc_rx[31:24]<=crt_data; 
                  end
                else if(cnt==20'd1)
                  begin                   
                   crc_rx[23:16]<=crt_data; 
                  end
                else  if(cnt==20'd2)
                  begin                   
                   crc_rx[15:8]<=crt_data; 
                   end
                  else  if(cnt==20'd3)
                  begin                   
                   crc_rx[7:0]<=crt_data; 
                   cnt<=20'd0;
                   st<=rpre;
                  end
                  end    
                    
endcase
end
end
endmodule
               
