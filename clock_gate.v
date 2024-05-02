module clock_gate
  (
  clkA,
  clkB,
  clksel,
  clkout
  );

input  clkA;
input  clkB;
input  clksel;
output clkout;

assign clkout = clksel ? clkA : clkB;

endmodule
