 module mux_8 (out,inp,se);
  input [7:0] inp;
  input [2:0] se;
  output out;
  wire m1,m2,m3,m4,m5,m6;
  mux_2 s1 (.ot(m1),.in(inp[1:0]),.s(se[0]));
  mux_2 s2 (.ot(m2),.in(inp[3:2]),.s(se[0]));
  mux_2 s3 (.ot(m3),.in(inp[5:4]),.s(se[0]));
  mux_2 s4 (.ot(m4),.in(inp[7:6]),.s(se[0]));
  mux_2 s5 (.ot(m5),.in({m2,m1}),.s(se[1]));
  mux_2 s6 (.ot(m6),.in({m4,m3}),.s(se[1]));
  mux_2 s7 (.ot(out),.in({m6,m5}),.s(se[2]));
endmodule

module mux_2 (ot,in,s);
input [1:0] in;
input s;
output reg ot;
always @ (in or s)
begin
  if (!s)
    ot = in[0];
  else
    ot = in[1];
end 
endmodule  
    
 
