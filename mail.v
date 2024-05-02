module i2cc(sda,rst,clk,read,sclk);
input rst;
input clk;
input read;// the name for read or write is "read" signal
inout sda;
output sclk;
reg ack=1'hz; //if write signal is on, then ack is 'z' but if read signal is on, go for mux.
reg sda_out;
reg ack_reg;
reg [7:0]memoryaddress=8'b10100100;//in
reg [7:0]master_s=8'b11111100;//in;
reg [6:0]master_u=7'b1001000;//in
reg [2:0]count=3'b000;
reg [3:0]state=0;
reg [0:7]y;
reg x=1;
reg l;
reg m;
reg q;
parameter s1=4'b0000,s2=4'b0001,s3=4'b0010,s4=4'b0011,s5=4'b0100,s6=4'b0101,s7=4'b0110,s8=4'b0111,s9=4'b1001,s10=4'b1010;
assign sda=(EN==1)?sda_out:1'bz;
assign sclk=EN?sclk1:sclk2;
always@(posedge clk)
begin
if(EN)
begin
sclk1<=1;
sda_out1<=1;
end
else if(EN && x)
begin
sda_out1<=0;
sclk2<=1;
end
else
sclk<=clk;

end


always@(negedge sclk)
begin
if(rst)
	begin
		l<=0;
       		sda_out<=1;
	end
else
begin
case(state)
s1:	begin//ideal
	x<=1;
	l<=0;
        sda_out<=1;
	state<=s2;
end
s2://start
begin
	x<=1;
	l<=0;
	sda_out<=0; 
	state<=s3;
end

s3:	begin//slave add
	x<=1;
	l<=1;
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

s4:	begin//rd/wr
	x<=1;
 	l<=1;
	sda_out<=read;   
	state<=s5;
	end
s5:	begin
	m<=1;
	x<=0;
        l<=1;
	state<=s6;
	end
s6:	begin//memory add
		x<=1;
       		l<=1;
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
s7:	begin//memory ack
	m<=1;
	x<=0;
	l<=1;
	state<=s8;
	end
s8:	begin//data
	l<=1;
		if(read==1)//read 1 means sent.....
			begin
				x<=1;
				sda_out<=master_s[count];
						if(count<3'd7)
								begin
									count<=count+1;
									state<=s8;	
								end 
						else
								begin
									l<=1;
									count<=3'b000;
									state<=s9;
								end
			end
		else 
			begin
				m<=0;
			end
	end
s9:	begin//ack
	l<=1;
		if(read==1)
			begin
				x<=0;
				m<=1;
				state<=s10;
			end
		else
			begin
				x<=1;
				sda_out<=ack_reg;	
				state<=s10;
			end
	end
s10:	begin//stop
	l<=0;
	x<=1;
	sda_out<=1;
	state<=s1;
	end
endcase
end
end
always@(posedge sclk)
	begin
		if(m==1)
			begin
				ack_reg<=sda;
			end
		else if(m==0)
			begin
				x<=0;
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





















module i2cms(
		sda,
		sclk,
		);
input
 sclk;// the name for read or write is "read" signal
inout sda;
reg ack_reg;//ack stroage
reg sda_out;//if write signal is on, then ack is 'z' but if read signal is on, go for mux.
reg [7:0]master_s;
reg [3:0]count=4'b0000;
reg [3:0]state=0;
reg [0:6]ys;
reg [0:7]m;
reg [0:7]d;
reg sm;
reg x;
reg u;
reg k;
parameter s1=4'b0000,s2=4'b0001,s3=4'b0010,s4=4'b0011,s5=4'b0100,s6=4'b0101,s7=4'b0110,s8=4'b0111,s9=4'b1001,s10=4'b1010;
 
assign sda=(x==1)?sda_out:1'hz;
always@(posedge sclk)
begin

case(state)
s1:
begin
x<=0;
	if(sclk==1 &&sda==1)									//8,27
	state<=s2;
else
state<=s1;

end
s2:
//start
	
begin
	x<=0;
	if(sclk==1 &&sda==0)
	state<=s3;
else
state<=s2;
end

s3:begin//slave add recv
	x<=0;
	ys<={sda,ys[0:5]};//y is slave add storeage reg
	if(count==4'd6)
	begin
	state<=s4;
	end
	else
	begin
	count<=count+1;
	state<=s3;	
	end
       end 

s4://rd/wr
begin
x<=0;
sm<=sda;
state<=s5;
end

s5:begin//slaveadd check and check
if(ys==7'b1001000)
begin
	x<=0;
	u<=1;//ack=0
	count<=6'b0;
	//ys<=7'd0;
	state<=s6;
end

else
begin
	x<=0;
	u<=0;//nack=1
	//count<=0;
	state<=s1;
end
end


s6:begin//memory add
	x<=0;
	m<={sda,m[0:6]};
	if(count==3'd7)
begin
	state<=s7;
end
	else
begin
	count<=count+1;
	state<=s6;	
end
end 


s7:begin//memory check and ack

if(m==8'b10100100)
begin
	x<=0;
	u<=0;
	count<=7'b0;
	state<=s8;
end
else
begin
	x<=0;
	u<=1;
	count<=0;
	state<=s1;
end
end


s8:begin//data
	if(sm==0)
	begin
		x<=0;
		k<=1;
	end
	
	else
		begin
			x<=0;
			d<={d[0:6],sda};
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

s9:
begin//ack
if(sm==0)
begin

		x<=0;
		ack_reg<=sda;
			if(ack_reg==1)
		begin
			state<=s10;
		end
			else 		
		begin
			state<=s8;
		end
end
else
begin
		x<=0;
		u<=1;
	        state<=10;


end
end
s10:begin//stop
	x<=0;
	if(sda_out==1&&sclk==1)
		begin
				state<=s1;
		end
       else
		begin	
				state<=s8;
      		 end
	end
		endcase
		
end



always@(negedge sclk)
begin
		if(u==1)
			begin
				x=1;
				sda_out<=0;
			end
			else 
			begin
					x=1;
                        	 sda_out<=1;
			end
		if(k==1)
		begin
x<=1;
				if(count<=4'b0110)
				begin
				
				sda_out<=master_s[count];
				count<=count+1;
                                state<=s8;
				end
				
			else	
				state<=s9;
		end
		 
end
endmodule













module i2ctop(rst,clk,read,sda,sclk);
input rst,clk;
input read;
inout sda;
output sclk;
i2cc u1(sda,rst,clk,read,sclk);//(sda,rst,clk,read,sclk)
i2cms u2(sda,sclk);
endmodule















module i2cc(sda,rst,clk,read,sclk);
input rst;
input clk;
input read;// the name for read or write is "read" signal
inout sda;
output sclk;
reg ack=1'hz; //if write signal is on, then ack is 'z' but if read signal is on, go for mux.
reg sda_out;
reg ack_reg;
reg [7:0]memoryaddress=8'b10100100;//in
reg [7:0]master_s=8'b11111100;//in;
reg [6:0]master_u=7'b1001000;//in
reg [2:0]count=3'b000;
reg [3:0]state=0;
reg [0:7]y;
reg x=1;
reg l;
reg sclk1;
reg sclk2;
reg m;
reg q;
reg EN;
parameter s1=4'b0000,s2=4'b0001,s3=4'b0010,s4=4'b0011,s5=4'b0100,s6=4'b0101,s7=4'b0110,s8=4'b0111,s9=4'b1001,s10=4'b1010;
assign sda=(x==1)?sda_out:1'bz;
assign sclk=(EN==1)?sclk1:sclk2;
always@(posedge clk)
begin
if(EN==1 && x==1)
begin
sclk1<=1;
sda_out<=1;
end
else if(EN==0 && x==1)
begin
sda_out<=0;
sclk2<=1;
end
else
sclk<=clk;
end


always@(negedge sclk)
begin
if(rst)
	begin
		
       		sda_out<=1;
	end
else
begin
case(state)
s1:	begin//ideal
	x<=1;
	EN<=1;
        sda_out<=1;
	state<=s2;
end
s2://start
begin
	x<=1;
	EN<=0;
	sda_out<=0; 
	state<=s3;
end

s3:	begin//slave add
	x<=1;

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

s4:	begin//rd/wr
	x<=1;
 	
	sda_out<=read;   
	state<=s5;
	end
s5:	begin
	m<=1;
	x<=0;
        
	state<=s6;
	end
s6:	begin//memory add
		x<=1;
       		
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
s7:	begin//memory ack
	m<=1;
	x<=0;
	
	state<=s8;
	end
s8:	begin//data

		if(read==1)//read 1 means sent.....
			begin
				x<=1;
				sda_out<=master_s[count];
						if(count<3'd7)
								begin
									count<=count+1;
									state<=s8;	
								end 
						else
								begin
									l<=1;
									count<=3'b000;
									state<=s9;
								end
			end
		else 
			begin
				m<=0;
			end
	end
s9:	begin//ack

		if(read==1)
			begin
				x<=0;
				m<=1;
				state<=s10;
			end
		else
			begin
				x<=1;
				sda_out<=ack_reg;	
				state<=s10;
			end
	end
s10:	begin//stop
	EN<=1;
	x<=1;
	sda_out<=1;
	state<=s1;
	end
endcase
end
end
always@(posedge sclk)
	begin
		if(m==1)
			begin
				ack_reg<=sda;
			end
		else if(m==0)
			begin
				x<=0;
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


/*
module i2cc1(sda,en,rst,clk,read,sclk);
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
reg l;
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
else 
sclk=clk;
end 



always@(negedge sclk)
begin
case(state)
s3:	begin//slave add
x<=1;
l<=1;
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

s4:	begin//rd/wr
x<=1;
 	l<=1;
sda_out<=read;   
state<=s5;
end
s5:	begin
m<=1;
sda_out=1'bz;
        l<=1;
state<=s6;
end
s6:	begin//memory add
x<=1;
       	l<=1;
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
s7:	begin//memory ack
m<=1;
sda_out=1'bz;
l<=1;
state<=s8;
end
s8:	begin//data
l<=1;
if(read==1)//read 1 means sent.....
begin
x<=1;
sda_out<=master_s[count];
if(count<3'd7)
begin
count<=count+1;
state<=s8;	
end 
else
begin
l<=1;
count<=3'b000;
state<=s9;
end
end
else 
begin
m<=0;
end
end
s9:	begin//ack
l<=1;
if(read==1)
begin
sda_out=1'b0;
m<=1;
state<=s10;
end
else
begin
x<=1;
sda_out<=ack_reg;	
state<=s10;
end
end
s10:	begin//stop
l<=0;
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
x<=0;
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




module i2cc(sda,en,rst,clk,read,sclk);
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
parameter s3=4'b0010,s4=4'b0011,s5=4'b0100,s6=4'b0101,s7=4'b0110,s8=4'b0111,s9=4'b1001,s10=4'b1010;

assign sda=en?sda1:sda_out;

always@(posedge clk, negedge clk)
begin 
	if(en)
begin 
	sda1=1'b1;
	sda_out=1'b0;
	sclk=1'b1;
end 
	else if(en &&x==1)
begin
	sda1=1'b1;
	sclk=1'b0;
end
else 
	sclk=clk;

end


always@(negedge sclk)
begin
case(state)
s3:	begin//slave add


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

s4:	begin//rd/wr

 	
sda_out<=read;   
state<=s5;
end


s5:	begin
m<=1;
sda_out=1'bz;
        
state<=s6;
end


s6:	begin//memory add
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


s7:	begin//memory ack
m<=1;
sda_out=1'bz;

state<=s8;
end
s8:	begin//data

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
s9:	begin//ack

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


s10:	begin//stop
x<=1;
state<=s3;
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
x<=0;
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


























































