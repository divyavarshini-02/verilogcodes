module counter (q,rst,clk);
  input clk,rst;
  output reg [3:0] q;
  always @ (posedge clk)
  begin
    if(rst)
      q<=4'b0001;
    else
      case(q)
        4'b0001 : q = 4'b0011;
        4'b0011 : q = 4'b0111;
        4'b0111 : q = 4'b1001;
        4'b1001 : q = 4'b1101;
        4'b1101 : q = 4'b0000;
        4'b0000 : q = 4'b0001;
      endcase
    end  
endmodule
