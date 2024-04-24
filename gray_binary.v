module graytobin (q,a);
  input [0:3]a;
  output [0:3] q;
  assign q[0]= a[0];
  assign q[1]= (a[0] ^ a[1]);
  assign q[2]= (a[1] ^ a[2]);
  assign q[3]= (a[2] ^ a[3]);
endmodule
  
  
