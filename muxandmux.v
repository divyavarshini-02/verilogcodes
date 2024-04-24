module mux_3 (out,s,a);
  input [2:0] a;
  input [1:0] s;
  output reg out;
  always @(a,s)
  begin
    if (s == 2'b00)
      out = a[0];
    else if (s == 2'b01)
      out = a[1];
    else if (s == 2'b10)
      out = a[2];
    else
      out = 1'bx;
  end 
 endmodule   
 module mux_7 (out,s,a);
  input [6:0] a;
  input [3:0] s;
  output reg out;
  always @(a,s)
  begin
    if (s == 3'b000)
      out = a[0];
    else if (s == 3'b001)
      out = a[1];
    else if (s == 3'b010)
      out = a[2];
    else if (s == 3'b011)
      out = a[3];
    else if (s == 3'b100)
      out = a[4];
    else if (s == 3'b101)
      out = a[5];
    else if (s == 3'b110)
      out = a[6];    
    else
      out = 1'bx;
  end 
 endmodule   
      
