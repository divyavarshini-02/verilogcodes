module xgaxi#(parameter IDLE=0,C1=1,C2=2,C3=3,C4=4,C5=5,C6=6,C7=7,DELAY=8)(clk,data,tready,tlast,tuser,tvalid,tkeep,tdata);
input tready,clk;
input [63:0]data;
output reg[63:0]tdata;
output reg tlast,tuser;
output reg tvalid;
output reg [7:0] tkeep;
reg [3:0] state=0;
reg [5:0]n=1;
reg delay=0;
reg [5:0]count=6'b000000;
reg [47:0]d_mac=48'ha0b1c2d3e4f5;
reg [47:0]s_mac=48'h24be051e72e9;
reg [15:0]lt=16'h0800;
reg [3:0] ver=4'b0100;
reg[3:0]ihl=4'b0101;
reg[7:0]tos=8'b00000000;
reg[15:0]tl=16'd284;
reg[15:0]id=16'b0000000000000000;
reg[15:0]fragment=16'h4000;
reg[7:0]ttl=8'd64;
reg[7:0]pro=8'd17;
reg [15:0]checksum=16'hadef;
reg [31:0]s_ip=32'hc010fe01;
reg [31:0]d_ip=32'hc0a20d2d;
reg[15:0] s_udp=16'd20;
reg[15:0] d_udp=16'd80;
reg[15:0] l_udp=16'd264;
reg[15:0] checksum_udp=16'd0;
reg[31:0] fcs=32'habcdef12;
reg [63:0]mem[32:1];


always@(posedge clk)
 begin
if(count<=6'd32)
begin
mem[count]<=data;
count<=count+1'b1;
end
end


always@(posedge clk)
begin
if(tready==1)
begin
case(state)
IDLE:
begin
tvalid<=0;
tkeep<=8'h00;
tuser<=0;
tlast<=0;
state<=C1;
end


C1:
begin
tdata<={s_mac[39:32],s_mac[47:40],d_mac[7:0],d_mac[15:8],d_mac[23:16],d_mac[31:24],d_mac[39:32],d_mac[47:40]};
tlast<=0;
tuser<=0;
tvalid<=1'b1;
tkeep<=8'hff;
state<=C2;
end
C2:
begin
tdata<={tos,ver,ihl,lt[7:0],lt[15:8],s_mac[7:0],s_mac[15:8],s_mac[23:16],s_mac[31:24]};
tlast<=0;
tuser<=0;
tvalid<=1'b1;
//tvalid<=1;
tkeep<=8'hff;
state<=C3;
end

C3:
begin
tdata<={pro,ttl,fragment[7:0],fragment[15:8],id[7:0],id[15:8],tl[7:0],tl[15:8]};
tlast<=0;
tuser<=0;
tvalid<=1'b1;
tkeep<=8'hff;
state<=C4;
end

C4:
begin
tdata<={d_ip[23:16],d_ip[31:24],s_ip[7:0],s_ip[15:8],s_ip[23:16],s_ip[31:24],checksum[7:0],checksum[15:8]};
tlast<=0;
tuser<=0;
tvalid<=1'b1;
tvalid<=1'b1;
tkeep<=8'hff;
state<=C5;
end

C5:
begin
tdata<={l_udp[7:0],l_udp[15:8],d_udp[7:0],d_udp[15:8],s_udp[7:0],s_udp[15:8],d_ip[7:0],d_ip[15:8]};
tlast<=0;
tuser<=0;
tvalid<=1'b1;
tkeep<=8'hff;
state<=C6;
end

C6:
begin
tdata<={mem[1][47:40],mem[1][39:32],mem[1][31:24],mem[1][23:16],mem[1][15:8],mem[1][7:0],checksum_udp[7:0],checksum_udp[15:8]};
tlast<=0;
tvalid<=1'b1;
tuser<=0;
tkeep<=8'hff;
state<=C7;
end

C7:
begin
if(n<=31)
begin
tdata<={mem[n+1][47:40],mem[n+1][39:32],mem[n+1][31:24],mem[n+1][23:16],mem[n+1][15:8],mem[n+1][7:0],mem[n][63:56],mem[n][55:48]};
n<=n+1;
tvalid<=1'b1;
tlast<=0;
tuser<=0;
tkeep<=8'hff;
if(n==26)
begin
count<=1;
end
end
else
begin
tdata<={fcs[7:0],fcs[15:8],fcs[23:16],fcs[31:24],mem[n][63:56],mem[n][55:48]};
n<=1;
tlast<=1;
tvalid<=1'b1;
tuser<=0;
tkeep<=8'h3f;
state<=DELAY;
end
end
DELAY:
begin
if(delay==0)
begin
tvalid<=0;
tkeep<=8'h00;
delay<=delay+1;
tuser<=0;
tlast<=0;
//state<=IDLE;
end
else
begin
tvalid<=0;
tkeep<=8'h00;
tuser<=0;
tlast<=0;
state<=IDLE;
end
end

endcase
end
else
begin
tvalid<=0;
tkeep<=8'h00;
tuser<=0;
tlast<=0;
end

end
endmodule 




