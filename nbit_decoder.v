 module shift_test (q,a);
 output [7:0]q;
 input [2:0]a;
 assign q = 1 << a;
 endmodule   

module nbit_dec (q,a,en);
  input en;
  parameter n = 4;
  input [n-1:0]a;
  output reg [(2**n -1):0]q;
  always @ (a or en)
  if (en)
    q = 0;
  else
    q = 1 << a;
  endmodule
  
