/*module check_sum(clk,ip_cs,out);
  input clk;
  output reg [79:0]ip_cs;
  output  reg [16:0]out=16'd 0;
  reg [3:0] ver=4'b1100;
  reg [3:0]ihl=4'b0101;
  reg [7:0]tos=8'hff;
  reg [15:0]tl=16'd88;
  reg [15:0]id=16'hffff;
  reg [15:0]fragment=16'h90d0;
  reg [7:0]ttl=8'd64;
  reg [7:0]pro=8'd6;
  reg [15:0]checksum=16'h1000;
  reg [2:0] count =3'b0;
  reg [15:0]y=16'd0;
  reg s=1'b0;
  wire c;
  assign c=out[16];
  
  parameter load=1'b0, cs=1'b1;
  
  always @ (posedge clk)
  begin
    ip_cs[79:0]<={pro,ttl,fragment[7:0],fragment[15:8],id[7:0],id[15:8],tl[7:0],tl[15:8],tos,ver,ihl};
    
    case(s)
      
      load:begin
           s<=cs;
           end
           
      cs:  begin
           if(count<=3'd5)
              begin
                y<=ip_cs[15:0];
                out<=(out[15:0]+y+out[16]);
                count<=count+3'd1;
                ip_cs<=ip_cs>>16;
              end
            else
              begin
                count<=3'b0;
                out<=17'd0;
                s<=load;
              end
  
             end
             endcase
          end
endmodule */  

/*module ip_check(clk,Main_data,In_data);
input        		clk;
input      [79:0] In_data;
output reg [15:0] Main_data=16'b0;
		 reg [7:0]  a_1=8'b0;
		 reg [7:0]  b_1=8'b0;
		 reg [7:0]  c_1=8'b0;
		 reg [7:0]  d_1=8'b0;
       reg [15:0] temp_data=16'b0;
always@(posedge clk)
begin
	
	a_1 				  = d_1[7:4]+ In_data[67:64]+ In_data[51:48]+ In_data[35:32]+ In_data[19:16]+ In_data[3:0];
	b_1 				  = a_1[7:4]+ In_data[71:68]+ In_data[55:52]+ In_data[39:36]+ In_data[23:20]+ In_data[7:4];
	c_1 				  = b_1[7:4]+ In_data[75:72]+ In_data[59:56]+ In_data[43:40]+ In_data[27:24]+ In_data[11:8];
	d_1 				  = c_1[7:4]+ In_data[79:76]+ In_data[63:60]+ In_data[47:44]+ In_data[31:28]+ In_data[15:12];
			temp_data[15:0] = {d_1[3:0],c_1[3:0],b_1[3:0],a_1[3:0]};
			Main_data[15:0] = ~(temp_data[15:0]);
end
endmodule  
*/
   //45000030000040004006
    
module tcp_check(clk,Main_data,In_data);
input      clk;
input      [319:0] In_data;
output reg [15:0] Main_data=16'b0;
		 reg [7:0]  a_1=8'b0;
		 reg [7:0]  b_1=8'b0;
		 reg [7:0]  c_1=8'b0;
		 reg [7:0]  d_1=8'b0;
     reg [15:0] temp_data=16'b0;
always@(posedge clk)
begin
	a_1 				  = d_1[7:4]+In_data[307:304]+In_data[291:288]+In_data[275:272]+In_data[259:256]+In_data[243:240]+In_data[227:224]+ In_data[211:208]+ In_data[195:192]+ In_data[179:176]+ In_data[163:160]+ In_data[147:144]+ In_data[131:128]+ In_data[115:112]+ In_data[99:96]+ In_data[83:80]+ In_data[67:64]+ In_data[51:48]+ In_data[35:32]+ In_data[19:16]+ In_data[3:0];
	b_1 				  = a_1[7:4]+In_data[311:308]+In_data[295:292]+In_data[279:276]+In_data[263:260]+In_data[247:244]+In_data[231:228]+ In_data[215:212]+ In_data[199:196]+ In_data[183:180]+ In_data[167:164]+ In_data[151:148]+ In_data[135:132]+ In_data[119:116]+ In_data[103:100]+ In_data[87:84]+ In_data[71:68]+ In_data[55:52]+ In_data[39:36]+ In_data[23:20]+ In_data[7:4];
	c_1 				  = b_1[7:4]+In_data[315:312]+In_data[299:296]+In_data[283:280]+In_data[267:264]+In_data[251:248]+In_data[235:232]+ In_data[219:216]+ In_data[203:200]+ In_data[187:184]+ In_data[171:168]+ In_data[155:152]+ In_data[139:136]+ In_data[123:120]+ In_data[107:104]+ In_data[91:88]+ In_data[75:72]+ In_data[59:56]+ In_data[43:40]+ In_data[27:24]+ In_data[11:8];
	d_1 				  = c_1[7:4]+In_data[319:316]+In_data[303:300]+In_data[287:284]+In_data[271:268]+In_data[255:252]+In_data[239:236]+ In_data[223:220]+ In_data[207:204]+ In_data[191:188]+ In_data[175:172]+ In_data[159:156]+ In_data[143:140]+ In_data[127:124]+ In_data[111:108]+ In_data[95:92]+ In_data[79:76]+ In_data[63:60]+ In_data[47:44]+ In_data[31:28]+ In_data[15:12];
		
	
			temp_data[15:0] = {d_1[3:0],c_1[3:0],b_1[3:0],a_1[3:0]};
			Main_data[15:0] = ~(temp_data[15:0]);
end
endmodule 
    
    
//c010fe01c0a20d2d0006001c00140050000027100000000070020000000000000000000000000000