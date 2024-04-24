module fadec(d,s,c);
input [7:0]d;
output s,c;
assign s=d[1]||d[2]||d[4]||d[7];
assign c=d[3]||d[5]||d[6]||d[7];
endmodule
