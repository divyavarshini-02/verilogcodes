module squareof3bit (s,a);
  input [2:0] a;
  output [5:0] s;
  assign s[0]=a[0];
  assign s[1]=0;
  assign s[2]=(a[1] &(~a[0]));
  assign s[3]=((~a[2]) & a[1] & a[0])|(a[2] & (~a[1]) & a[0]);
  assign s[4]=(a[2] &(~a[1]))|(a[2] & a[0]);  
  assign s[5]=(a[2] & a[1]);
endmodule