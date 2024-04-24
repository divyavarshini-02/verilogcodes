module fulladd (sum,carry,a,b,c);
  input a,b,c;
  output sum,carry;
  wire ot1,ot2,ot3;
  halfadd s1 (.sums(ot1),.carrys(ot2),.a1(a),.b1(b));
  halfadd s2 (.sums(sum),.carrys(ot3),.a1(ot1),.b1(c));
  assign carry =(ot2 | ot3);
endmodule
  
  module halfadd (sums,carrys,a1,b1);
  input a1,b1;
  output sums,carrys;
  assign sums = (a1 ^ b1);
  assign carrys = (a1 & b1);
endmodule
  
