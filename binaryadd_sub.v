module add_sub (s,cout,a,b,m);
  input [3:0] a,b;
  input m;
  output [3:0]s;
  output cout;
  wire c1,c2,c3;
  assign e1 = (b[0] ^ m );
  assign e2 = (b[1] ^ m );
  assign e3 = (b[2] ^ m ); 
  assign e4 = (b[3] ^ m );
  fulladd f1 (.sum(s[0]),.carry(c1),.c(a[0]),.d(e1),.e(m));
  fulladd f2 (.sum(s[1]),.carry(c2),.c(a[1]),.d(e2),.e(c1));
  fulladd f3 (.sum(s[2]),.carry(c3),.c(a[2]),.d(e3),.e(c2));
  fulladd f4 (.sum(s[3]),.carry(cout),.c(a[3]),.d(e4),.e(c3));
endmodule
  module fulladd (sum,carry,c,d,e);
  input c,d,e;
  output sum,carry;
  assign sum = (c^d^e);
  assign carry = (c&d)|(d&e)|(e&c);
endmodule
