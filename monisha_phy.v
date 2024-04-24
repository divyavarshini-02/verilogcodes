module pp(mdc,mdio,clk);
input clk;
inout mdio;
output mdc;

parameter idle=3'd0;
parameter start=3'd1;
parameter write=3'd2;
parameter phy_add=3'd3;
parameter reg_add=3'd4;
parameter ta=3'd5;
parameter reg_data=3'd6;


reg [31:0]IDLE=32'hffffffff;
reg [1:0]START=2'b01;
reg [1:0]WRITE=2'b01;
reg [4:0]PHY_ADD=5'b10000;
reg [4:0]REG_ADD;
reg [1:0]TA=2'b10;
reg [15:0]REG_DATA;

reg [2:0]state=0;
reg [4:0]count0=5'd31;
reg count;
reg count1;
reg [2:0]count2;
reg [2:0]count3;
reg count4;
reg [3:0]count5;
reg [3:0]i=0;

reg out;

assign mdio=out;
assign mdc=clk;

/*phy_pll m1(
	clk,
	mdc);*/

always@(posedge mdc)

if(i==1)
begin
REG_ADD=5'b10000;
REG_DATA=16'h0060;
end

else if(i==2 || i==4 || i==7)
begin
REG_ADD=5'b00000;
REG_DATA=16'h8140;
end

else if(i==3)
begin
REG_ADD=5'b10100;
REG_DATA=16'h0070;
end

else if(i==5)
begin
REG_ADD=5'b11101;
REG_DATA=16'h0012;
end

else if(i==6)
begin
REG_ADD=5'b11110;
REG_DATA=16'h8240;
end


always@(posedge mdc)
case(state)

idle:begin

if(i==7)
begin
out<=1'bz;
state<=idle;
end
else
begin
out<=IDLE[count0];
if(!count0)
begin
count0<=5'd31;
i<=i+1'b1;
state<=start;
count<=1'b1;
end
else
begin
count0<=count0-1'b1;
state<=idle;
end
end


end

start:begin
out<=START[count];

if(!count)
begin
state<=write;
count1<=1'b1;
end
else
begin
count<=count-1'b1;
state<=start;
end

end

write:begin
out<=WRITE[count1];

if(!count1)
begin
state<=phy_add;
count2<=3'b100;
end
else
begin
count1<=count1-1'b1;
state<=write;
end

end

phy_add:begin
out<=PHY_ADD[count2];

if(!count2)
begin
state<=reg_add;
count3<=3'b100;
end
else
begin
count2<=count2-1'b1;
state<=phy_add;
end

end

reg_add:begin
out<=REG_ADD[count3];

if(!count3)
begin
state<=ta;
count4<=1'b1;
end
else
begin
count3<=count3-1'b1;
state<=reg_add;
end

end

ta:begin
out<=TA[count4];

if(!count4)
begin
state<=reg_data;
count5<=4'b1111;
end
else
begin
count4<=count4-1'b1;
state<=ta;
end

end

reg_data:begin
out<=REG_DATA[count5];

if(!count5)
begin
state<=idle;
end
else
begin
count5<=count5-1'b1;
state<=reg_data;
end

end

endcase

endmodule

