module fadecoder (sum,carry,a);
input [2:0] a;
output sum,carry;
wire na0,na1,na2;
wire [7:0] s;
assign na0=~a[0];
assign na1=~a[1];
assign na2=~a[2];
assign s[0]=(na2 & na1 & na0);
assign s[1]=(na2 & na1 & a[0]);
assign s[2]=(na2 & a[1] & na0);
assign s[3]=(na2 & a[1] & a[0]);
assign s[4]=(a[2] & na1 & na0);
assign s[5]=(a[2] & na1 & a[0]);
assign s[6]=(a[2] & a[1] & na0);
assign s[7]=(a[2] & a[1] & a[0]);
assign sum=(s[1] | s[2] | s[4] | s[7]);
assign carry=(s[3] | s[5] | s[6] | s[7]);
endmodule
