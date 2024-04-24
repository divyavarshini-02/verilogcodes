module nand_gate ( s,a,b,c,d);
  input a,b,c,d;
  output s;
  wire x,y,u,v;
  assign x=~(a & b);
  assign y=~(c & d);
  assign u=~(x & x);
  assign v=~(y & y);
  assign s=~(u & v);
endmodule
