module tribuf (f,a,c);
  input a,c;
  output f;
  assign f = (c==0)? 1'bz : a;
endmodule

