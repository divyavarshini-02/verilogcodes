module decusingdec (out,x,a);
  input a;
  input [2:0] x;
  output [15:0]out;
  subdec s1 (out[7:0],x,(~a)); 
  subdec s2 (out[15:8],x,a);
endmodule
    
 
  module subdec (ot,u,b);
  input [2:0] u;
  input b;
  output [7:0] ot;
  assign ot=(!b)? 8'b 00000000:( u == 3'b 000)? 8'b 00000001 :( u == 3'b 001)? 8'b 00000010:
( u == 3'b 010)? 8'b 00000100:( u == 3'b 011)? 8'b 00001000:( u == 3'b 100)? 8'b 00010000:
( u == 3'b 101)? 8'b 00100000:( u == 3'b 110)? 8'b 01000000:( u == 3'b 111)? 8'b 10000000:8'bx;

  endmodule