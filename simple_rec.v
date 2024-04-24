module eth_rec_tst(clk,dataout_rx,rx_clk,rx_er,rx_dv,rx_crs,rx_col,mem);                           

input clk,rx_clk,rx_er,rx_dv,rx_crs,rx_col;
input [3:0]dataout_rx;
wire repclk;
wire [3:0]rx_data_2,rx_data_1;
reg [63:0]temp;
output reg [511:0]mem;
reg [6:0]cnt;
 	
/*	rx_rep_clk zx(
	clk,
	repclk);
	
dd_rec xy(
	dataout_rx,
   repclk,
	rx_data_1,
	rx_data_2);*/
always @(posedge clk)
begin

if((rx_dv^rx_er)==0)
begin
cnt<=0;
end


else 
begin
if(cnt<=7)
begin
temp<={rx_data_2,rx_data_1,temp[63:8]};
cnt<=cnt+1;
end

else if((cnt>7 && cnt<=71)&&(temp== 64'h5D55555555555555))
begin
mem<={rx_data_2,rx_data_1,mem[511:8]};
cnt<=cnt+1;
end

else
cnt<=0;
end

end

endmodule
