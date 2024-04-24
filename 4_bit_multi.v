module multi_4bit (out,a,b);
  input [3:0]a,b;
  output [7:0]out;
  wire k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z;
  wire c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,s1,s2,s3,s4,s5,s6;
  assign k = (a[0]& b[0]);
  assign l = (a[1]& b[0]);
  assign m = (a[0]& b[1]);
  assign n = (a[2]& b[0]);
  assign o = (a[1]& b[1]);
  assign p = (a[0]& b[2]);
  assign q = (a[3]& b[0]);
  assign r = (a[2]& b[1]);
  assign s = (a[1]& b[2]);
  assign t = (a[0]& b[3]);
  assign u = (a[3]& b[1]);
  assign v = (a[2]& b[2]);
  assign w = (a[1]& b[3]);
  assign x = (a[3]& b[2]);
  assign y = (a[2]& b[3]);
  assign z = (a[3]& b[3]);
  assign out[0] = k;
  halfadd o1 (.sums(out[1]),.carrys(c1),.a1(l),.b1(m));
  halfadd o2 (.sums(s1),.carrys(c2),.a1(n),.b1(o));
  fulladd o3 (.sum(out[2]),.carry(c3),.a(p),.b(s1),.c(c1));
  halfadd o4 (.sums(s2),.carrys(c4),.a1(q),.b1(r));
  fulladd o5 (.sum(s3),.carry(c5),.a(s),.b(s2),.c(c2));
  fulladd o6 (.sum(out[3]),.carry(c6),.a(t),.b(s3),.c(c3));
  fulladd o7 (.sum(s4),.carry(c7),.a(u),.b(v),.c(c4));
  fulladd o8 (.sum(s5),.carry(c8),.a(w),.b(s4),.c(c5));
  halfadd o9 (.sums(out[4]),.carrys(c9),.a1(s5),.b1(c6));
  fulladd o10 (.sum(s6),.carry(c10),.a(x),.b(y),.c(c7));
  fulladd o11 (.sum(out[5]),.carry(c11),.a(s6),.b(c8),.c(c9));
  fulladd o12 (.sum(out[6]),.carry(out[7]),.a(z),.b(c10),.c(c11));
endmodule  
 module halfadd (sums,carrys,a1,b1);
  input a1,b1;
  output sums,carrys;
  assign sums = (a1 ^ b1);
  assign carrys = (a1 & b1);
endmodule
module fulladd (sum,carry,a,b,c);
  input a,b,c;
  output sum,carry;
  wire ot1,ot2,ot3;
  halfadd s1 (.sums(ot1),.carrys(ot2),.a1(a),.b1(b));
  halfadd s2 (.sums(sum),.carrys(ot3),.a1(ot1),.b1(c));
  assign carry =(ot2 | ot3);
endmodule

  