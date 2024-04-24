/*module avalon_st(clk,data,ready,tx_data0,tx_data1,tx_data2,tx_data3,
                 tx_empty0,tx_empty1,tx_empty2,tx_empty3,
                 sof0,sof1,sof2,sof3,eof0,eof1,eof2,eof3,
                 valid0,valid1,valid2,valid3,er0,er1,er2,er3);
                 
  //input & output               
                             
  input clk;
  input [511:0]data;
  input ready;
  output reg[127:0]tx_data0,tx_data1,tx_data2,tx_data3;
  output reg[3:0]tx_empty0,tx_empty1,tx_empty2,tx_empty3;
  output reg sof0,sof1,sof2,sof3;
  output reg eof0,eof1,eof2,eof3;
  output reg valid0,valid1,valid2,valid3;
  output reg er0,er1,er2,er3;
  
  //reg
  
  reg [2:0]cnt=3'b000;
  reg [511:0]mem[0:3];
  reg [2:0] st=3'b000;
  reg [47:0]d_mac=48'ha0b1c2d3e4f5;
  reg [47:0]s_mac=48'h24be051e72e9;
  reg [15:0]lt=16'h0800;
  reg [3:0] ver=4'b0100;
  reg [3:0]ihl=4'b0101;
  reg [7:0]tos=8'b00000000;
  reg [15:0]tl=16'd284;
  reg [15:0]id=16'b0000000000000000;
  reg [15:0]fragment=16'h4000;
  reg [7:0]ttl=8'd64;
  reg [7:0]pro=8'd17;
  reg [15:0]checksum=16'hadef;
  reg [31:0]s_ip=32'hc010fe01;
  reg [31:0]d_ip=32'hc0a20d2d;
  reg [15:0] s_udp=16'd20;
  reg [15:0] d_udp=16'd80;
  reg [15:0] l_udp=16'd264;
  reg [15:0] checksum_udp=16'd0;
  reg [31:0] fcs=32'habcdef12;
  
  
  //parameter
   parameter idle=3'd0,s0=3'd1,s1=3'd2,s2=3'd3,s3=3'd4,s4=3'd5;
   
  always @(posedge clk)
  begin
    if(cnt<=3'd3)
      begin
        mem[cnt]<=data;
        cnt<=cnt+1'b1;
      end
  end
  always @(posedge clk)
  begin
    if(ready==1'b1)
      begin
        case(st)
          idle:begin
              tx_empty0<=4'h0;tx_empty1<=4'h0;tx_empty2<=4'h0;tx_empty3<=4'h0;
              sof0<=1'b0;sof1<=1'b0;sof2<=1'b0;sof3<=1'b0;
              eof0<=1'b0;eof1<=1'b0;eof2<=1'b0;eof3<=1'b0;
              valid0<=1'b0;valid1<=1'b0;valid2<=1'b0;valid3<=1'b0;
              er0<=1'b0;er1<=1'b0;er2<=1'b0;er3<=1'b0;
              st<=s0;
              end
           s0:begin
              tx_empty0<=4'hf;tx_empty1<=4'hf;tx_empty2<=4'hf;tx_empty3<=4'hf;
              sof0<=1'b1;sof1<=1'b0;sof2<=1'b0;sof3<=1'b0;
              eof0<=1'b0;eof1<=1'b0;eof2<=1'b0;eof3<=1'b0;
              valid0<=1'b1;valid1<=1'b1;valid2<=1'b1;valid3<=1'b1;
              er0<=1'b0;er1<=1'b0;er2<=1'b0;er3<=1'b0;
              tx_data0<={tos,ver,ihl,lt[7:0],lt[15:8],s_mac[7:0],s_mac[15:8],s_mac[23:16],s_mac[31:24],s_mac[39:32],s_mac[47:40],d_mac[7:0],d_mac[15:8],d_mac[23:16],d_mac[31:24],d_mac[39:32],d_mac[47:40]};
              tx_data1<={d_ip[23:16],d_ip[31:24],s_ip[7:0],s_ip[15:8],s_ip[23:16],s_ip[31:24],checksum[7:0],checksum[15:8],pro,ttl,fragment[7:0],fragment[15:8],id[7:0],id[15:8],tl[7:0],tl[15:8]};
              tx_data2<={mem[0][47:40],mem[0][39:32],mem[0][31:24],mem[0][23:16],mem[0][15:8],mem[0][7:0],checksum_udp[7:0],checksum_udp[15:8],l_udp[7:0],l_udp[15:8],d_udp[7:0],d_udp[15:8],s_udp[7:0],s_udp[15:8],d_ip[7:0],d_ip[15:8]};
              tx_data3<={mem[0][175:168],mem[0][167:160],mem[0][159:152],mem[0][151:144],mem[0][143:136],mem[0][135:128],mem[0][127:120],mem[0][119:112],mem[0][111:104],mem[0][103:96],mem[0][95:88],mem[0][87:80],mem[0][79:72],mem[0][71:64],mem[0][63:56],mem[0][55:48]};
              st<=s1;
              end
           s1:begin
              tx_empty0<=4'hf;tx_empty1<=4'hf;tx_empty2<=4'hf;tx_empty3<=4'hf;
              sof0<=1'b0;sof1<=1'b0;sof2<=1'b0;sof3<=1'b0;
              eof0<=1'b0;eof1<=1'b0;eof2<=1'b0;eof3<=1'b0;
              valid0<=1'b1;valid1<=1'b1;valid2<=1'b1;valid3<=1'b1;
              er0<=1'b0;er1<=1'b0;er2<=1'b0;er3<=1'b0;
              tx_data0<=mem[0][303:176];
              tx_data1<=mem[0][431:304];
              tx_data2<={mem[1][47:0],mem[0][511:432]};
              tx_data3<=mem[1][175:48];
              st<=s2;
              end
            s2:begin
              tx_empty0<=4'hf;tx_empty1<=4'hf;tx_empty2<=4'hf;tx_empty3<=4'hf;
              sof0<=1'b0;sof1<=1'b0;sof2<=1'b0;sof3<=1'b0;
              eof0<=1'b0;eof1<=1'b0;eof2<=1'b0;eof3<=1'b0;
              valid0<=1'b1;valid1<=1'b1;valid2<=1'b1;valid3<=1'b1;
              er0<=1'b0;er1<=1'b0;er2<=1'b0;er3<=1'b0;
              tx_data0<=mem[1][303:176];
              tx_data1<=mem[1][431:304];
              tx_data2<={mem[2][47:0],mem[1][511:432]};
              tx_data3<=mem[2][175:48];
              st<=s3;
              end
            s3:begin
              tx_empty0<=4'hf;tx_empty1<=4'hf;tx_empty2<=4'hf;tx_empty3<=4'hf;
              sof0<=1'b0;sof1<=1'b0;sof2<=1'b0;sof3<=1'b0;
              eof0<=1'b0;eof1<=1'b0;eof2<=1'b0;eof3<=1'b0;
              valid0<=1'b1;valid1<=1'b1;valid2<=1'b1;valid3<=1'b1;
              er0<=1'b0;er1<=1'b0;er2<=1'b0;er3<=1'b0;
              tx_data0<=mem[2][303:176];
              tx_data1<=mem[2][431:304];
              tx_data2<={mem[3][47:0],mem[2][511:432]};
              tx_data3<=mem[3][175:48];
              st<=s4;
              end
            s4:begin
              tx_empty0<=4'hf;tx_empty1<=4'hf;tx_empty2<=4'd2;tx_empty3<=4'h0;
              sof0<=1'b0;sof1<=1'b0;sof2<=1'b0;sof3<=1'b0;
              eof0<=1'b0;eof1<=1'b0;eof2<=1'b1;eof3<=1'b0;
              valid0<=1'b1;valid1<=1'b1;valid2<=1'b1;valid3<=1'b0;
              er0<=1'b0;er1<=1'b0;er2<=1'b0;er3<=1'b0;
              tx_data0<=mem[3][303:176];
              tx_data1<=mem[3][431:304];
              tx_data2<={fcs[7:0],fcs[15:8],fcs[23:16],fcs[31:24],mem[3][511:432]};
              st<=idle;
              end
        endcase
       end         
          
  else
    begin
      tx_empty0<=4'h0;tx_empty1<=4'h0;tx_empty2<=4'h0;tx_empty3<=4'h0;
      sof0<=1'b0;sof1<=1'b0;sof2<=1'b0;sof3<=1'b0;
      eof0<=1'b0;eof1<=1'b0;eof2<=1'b0;eof3<=1'b0;
      valid0<=1'b0;valid1<=1'b0;valid2<=1'b0;valid3<=1'b0;
      er0<=1'b0;er1<=1'b0;er2<=1'b0;er3<=1'b0;
     end
 end
 endmodule*/
      //511:0 512'h0123456789abcdef0123456789abcdef11111111111111110123456789abcdef0123456789abcdef00000000000000000123456789abcdef0123456789abcdef
        
  module avalon_st_test(clk,data,ready,tx_data0,tx_data1,tx_data2,tx_data3,
                 tx_empty0,tx_empty1,tx_empty2,tx_empty3,
                 sof0,sof1,sof2,sof3,eof0,eof1,eof2,eof3,
                 valid0,valid1,valid2,valid3,er0,er1,er2,er3);
                 
  //input & output               
                          
  input clk;
  input [511:0]data;
  input ready;
  output reg[127:0]tx_data0,tx_data1,tx_data2,tx_data3;
  output reg[3:0]tx_empty0,tx_empty1,tx_empty2,tx_empty3;
  output reg sof0,sof1,sof2,sof3;
  output reg eof0,eof1,eof2,eof3;
  output reg valid0,valid1,valid2,valid3;
  output reg er0,er1,er2,er3;
  
  //reg
  
  reg [2:0]cnt=3'b000;
  reg [511:0]mem[0:3];
  reg [2:0] st=3'b000;
  reg [47:0]d_mac=48'ha0b1c2d3e4f5;
  reg [47:0]s_mac=48'h24be051e72e9;
  reg [15:0]lt=16'h0800;
  reg [3:0] ver=4'b0100;
  reg [3:0]ihl=4'b0101;
  reg [7:0]tos=8'b00000000;
  reg [15:0]tl=16'd284;
  reg [15:0]id=16'b0000000000000000;
  reg [15:0]fragment=16'h4000;
  reg [7:0]ttl=8'd64;
  reg [7:0]pro=8'd17;
  reg [15:0]checksum=16'hadef;
  reg [31:0]s_ip=32'hc010fe01;
  reg [31:0]d_ip=32'hc0a20d2d;
  reg [15:0] s_udp=16'd20;
  reg [15:0] d_udp=16'd80;
  reg [15:0] l_udp=16'd264;
  reg [15:0] checksum_udp=16'd0;
  reg [31:0] fcs=32'habcdef12;
  reg [1:0]n=2'b0;
  
  
  //parameter
   parameter idle=3'd0,s0=3'd1,s1=3'd2;
   
  always @(posedge clk)
  begin
    if(cnt<=3'd3)
      begin
        mem[cnt]<=data;
        cnt<=cnt+1'b1;
      end
  end
  always @(posedge clk)
  begin
    if(ready==1'b1)
      begin
        case(st)
          idle:begin
              tx_empty0<=4'hf;tx_empty1<=4'hf;tx_empty2<=4'hf;tx_empty3<=4'hf;
              sof0<=1'b0;sof1<=1'b0;sof2<=1'b0;sof3<=1'b0;
              eof0<=1'b0;eof1<=1'b0;eof2<=1'b0;eof3<=1'b0;
              valid0<=1'b0;valid1<=1'b0;valid2<=1'b0;valid3<=1'b0;
              er0<=1'b0;er1<=1'b0;er2<=1'b0;er3<=1'b0;
              st<=s0;
              end
           s0:begin
              tx_empty0<=4'h0;tx_empty1<=4'h0;tx_empty2<=4'h0;tx_empty3<=4'h0;
              sof0<=1'b1;sof1<=1'b0;sof2<=1'b0;sof3<=1'b0;
              eof0<=1'b0;eof1<=1'b0;eof2<=1'b0;eof3<=1'b0;
              valid0<=1'b1;valid1<=1'b1;valid2<=1'b1;valid3<=1'b1;
              er0<=1'b0;er1<=1'b0;er2<=1'b0;er3<=1'b0;
              tx_data0<={tos,ver,ihl,lt[7:0],lt[15:8],s_mac[7:0],s_mac[15:8],s_mac[23:16],s_mac[31:24],s_mac[39:32],s_mac[47:40],d_mac[7:0],d_mac[15:8],d_mac[23:16],d_mac[31:24],d_mac[39:32],d_mac[47:40]};
              tx_data1<={d_ip[23:16],d_ip[31:24],s_ip[7:0],s_ip[15:8],s_ip[23:16],s_ip[31:24],checksum[7:0],checksum[15:8],pro,ttl,fragment[7:0],fragment[15:8],id[7:0],id[15:8],tl[7:0],tl[15:8]};
              tx_data2<={mem[n][47:40],mem[n][39:32],mem[n][31:24],mem[n][23:16],mem[n][15:8],mem[n][7:0],checksum_udp[7:0],checksum_udp[15:8],l_udp[7:0],l_udp[15:8],d_udp[7:0],d_udp[15:8],s_udp[7:0],s_udp[15:8],d_ip[7:0],d_ip[15:8]};
              tx_data3<=mem[n][175:48];
              st<=s1;
              end
           s1:begin
              if(n<=2)
                begin
              n<=n+1;
              tx_empty0<=4'h0;tx_empty1<=4'h0;tx_empty2<=4'h0;tx_empty3<=4'h0;
              sof0<=1'b0;sof1<=1'b0;sof2<=1'b0;sof3<=1'b0;
              eof0<=1'b0;eof1<=1'b0;eof2<=1'b0;eof3<=1'b0;
              valid0<=1'b1;valid1<=1'b1;valid2<=1'b1;valid3<=1'b1;
              er0<=1'b0;er1<=1'b0;er2<=1'b0;er3<=1'b0;
              tx_data0<=mem[n][303:176];
              tx_data1<=mem[n][431:304];
              tx_data2<={mem[n+1][47:0],mem[n][511:432]};
              tx_data3<=mem[n+1][175:48];
              if(n==2)
                begin
                  cnt<=3'b0;
                end
                end 
              else
                begin
              n<=3'b0;
              tx_empty0<=4'h0;tx_empty1<=4'h0;tx_empty2<=4'd2;tx_empty3<=4'hf;
              sof0<=1'b0;sof1<=1'b0;sof2<=1'b0;sof3<=1'b0;
              eof0<=1'b0;eof1<=1'b0;eof2<=1'b1;eof3<=1'b0;
              valid0<=1'b1;valid1<=1'b1;valid2<=1'b1;valid3<=1'b0;
              er0<=1'b0;er1<=1'b0;er2<=1'b0;er3<=1'b0;
              tx_data0<=mem[n][303:176];
              tx_data1<=mem[n][431:304];
              tx_data2<={fcs[7:0],fcs[15:8],fcs[23:16],fcs[31:24],mem[n][511:432]};
              st<=idle;
                end 
              end
          
            
        endcase
       end         
         
  else
    begin
      tx_empty0<=4'hf;tx_empty1<=4'hf;tx_empty2<=4'hf;tx_empty3<=4'hf;
      sof0<=1'b0;sof1<=1'b0;sof2<=1'b0;sof3<=1'b0;
      eof0<=1'b0;eof1<=1'b0;eof2<=1'b0;eof3<=1'b0;
      valid0<=1'b0;valid1<=1'b0;valid2<=1'b0;valid3<=1'b0;
      er0<=1'b0;er1<=1'b0;er2<=1'b0;er3<=1'b0;
     end
 end
 endmodule
      //511:0 512'h0123456789abcdef0123456789abcdef11111111111111110123456789abcdef0123456789abcdef00000000000000000123456789abcdef0123456789abcdef
      