module ring_counter(count,pst,clr,load,clk,rst);
  output [3:0]count;
  input pst,clr,load;  //preset and clear should always high., logic 1. 
  input clk,rst;
  wire q1,q2,q3,q4,qb1,qb2,qb3,qb4;
  
preset_clear v1(.q(q1),.q_bar(qb1),.pst(load),.clr(clr),.clk(clk),.rst(rst),.k(q4),.j(~q4));  //used j and k flip flop 
preset_clear v2(.q(q2),.q_bar(qb2),.pst(pst),.clr(load),.clk(clk),.rst(rst),.k(q1),.j(qb1));
preset_clear v3(.q(q3),.q_bar(qb3),.pst(pst),.clr(load),.clk(clk),.rst(rst),.k(q2),.j(qb2));
preset_clear v4(.q(q4),.q_bar(qb4),.pst(pst),.clr(load),.clk(clk),.rst(rst),.k(q3),.j(qb3));

assign count = {q4,q3,q2,q1};

endmodule

