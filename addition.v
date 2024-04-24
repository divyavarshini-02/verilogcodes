module addition (a,b,cin,s,c);
 	input [3:0]a,b;
 	input cin;
 	output[3:0]s;
 	output c;
 	wire c1,c2,c3;
 	fa f1(s[0],c1,a[0],b[0],cin);
 	fa f2(s[1],c2,a[1],b[1],c1);
 	fa f3(s[2],c3,a[2],b[2],c2);
 	fa f4(s[3],c,a[3],b[3],c3);
endmodule

module fa (s,ca,a,b,c);
 	input a,b,c;
 	output s,ca;
 	assign s=a^b^c;
 	assign ca=(a&b)|(b&c)|(c&a);
endmodule
