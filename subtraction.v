module subtraction(a,b,cin,d,bo);
	input [3:0]a,b;
	input cin;
	output [3:0]d;
	output bo;
	wire b1,b2,b3;
	fs s1(d[0],b1,a[0],b[0],cin);
	fs s2(d[1],b2,a[1],b[1],b1);
	fs s3(d[2],b3,a[2],b[2],b2);
	fs s4(d[3],bo,a[3],b[3],b3);
endmodule

module fs(d,bo,a,b,c);
	input a,b,c;
	output d,bo;
	assign d=a^b^c;
	assign bo=((~a)&(b^c))|(b&c);
endmodule
