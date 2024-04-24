module n_bit_counter (out,clk,rst,s); // nbit_up_down_counter
  parameter n = 4;
  input clk,rst,s;
  output reg [n-1:0] out;
  always @ (posedge clk)
  begin
    if(rst)
      out <= 0;
    else
      out <= (s)?out+1:out-1;
    end
  endmodule
