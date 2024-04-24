module nand2_4(i,y);
input [7:0]i;
wire [5:0]w;
output y;
assign w[0]=~(i[0]&&i[1]);
assign w[1]=~(i[2]&&i[3]);
assign w[2]=~(i[4]&&i[5]);
assign w[3]=~(i[6]&&i[7]);
assign w[4]=~(w[0]&&w[1]);
assign w[5]=~(w[2]&&w[3]);
assign y=~(w[4]&&w[5]);
endmodule
