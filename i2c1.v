module i2c1(sda,en,rst,clk,read,sclk);
input rst,en;
input clk;
input read;// the name for read or write is "read" signal
inout sda;
output reg sclk;
reg ack=1'hz; //if write signal is on, then ack is 'z' but if read signal is on, go for mux.
reg sda_out;
reg ack_reg;
reg [7:0]memoryaddress=8'b10100100;//in
reg [7:0]master_s=8'b11111100;//in;
reg [6:0]master_u=7'b1001000;//in
reg [2:0]count=3'b000;
reg [3:0]state=4'b0010;
reg [0:7]y;
reg x=1;
reg m;
reg sda1;
parameter s1=4'b0000,s2=4'b0001,s3=4'b0010,s4=4'b0011,s5=4'b0100,s6=4'b0101,s7=4'b0110,s8=4'b0111,s9=4'b1001,s10=4'b1010;

assign sda=en?sda1:sda_out;

always@(posedge clk, negedge clk)
begin
if(en)
begin
sda1=1'b1;
sda_out=1'b0;
sclk=1'b1;
end
else if(en==0&&x==1)
begin
sda1<=1'b1;
sda_out<=1'b0;
sclk<=1'b1;
end
else
sclk=clk;
end



always@(negedge sclk)
begin
case(state)
s3: begin//slave add


sda_out<=master_u[count];
if(count==3'd6)

begin
count<=0;
state<=s4;
end
else
begin
count<=count+1;
state<=s3;
end
end

s4: begin//rd/wr

sda_out<=read;  
state<=s5;
end
s5: begin
m<=1;
sda_out=1'bz;
       
state<=s6;
end
s6: begin//memory add
sda_out<=memoryaddress[count];
if(count==3'd7)
begin
count<=0;
state<=s7;
end
else
begin
count<=count+1;
state<=s6;
end
    end
s7: begin//memory ack
m<=1;
sda_out=1'bz;

state<=s8;
end
s8: begin//data

if(read==1)//read 1 means sent.....
begin

sda_out<=master_s[count];
if(count<3'd7)
begin
count<=count+1;
state<=s8;
end
else
begin

count<=3'b000;
state<=s9;
end
end
else
begin
m<=0;
end
end
s9: begin//ack

if(read==1)
begin
sda_out=1'b0;
m<=1;
state<=s10;
end
else
begin

sda_out<=ack_reg;
state<=s10;
end
end
s10: begin//stop

x<=1;
sda_out<=1;
state<=s1;
end
endcase
end
always@(posedge sclk)
begin
if(m==1)
begin
ack_reg<=sda;
end
else if(m==0)
begin

y<={y[0:6],sda};
if(count<=3'b111)
begin
count<=count+1;
state<=s8;
end
else
begin
state<=s9;
count<=3'b000;
end

end

end
endmodule
