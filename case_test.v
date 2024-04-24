module case_tt(s,in,in1,o);
  input in,in1,s;
  output reg o;
  always @(in,in1,s)
  begin
    case(s)
      0:o<=in1;
     // 1:o<=in;
    endcase
  end
endmodule
