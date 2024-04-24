module fulsubmux ( br,df,a);
  input [2:0] a;
  output br,df;
  brmux s1 (.obr(br),.abr(a[2]),.sbr(a[1:0]));
  dfmux s2 (.odf(df),.adf(a[2]),.sdf(a[1:0]));
endmodule
  module brmux (obr,abr,sbr);
    input abr;
    input [1:0] sbr;
    output reg obr;
    always @ (sbr or abr)
begin
  case (sbr)
    2'b00 : obr = 0;
    2'b01 : obr = ~abr; 
    2'b10 : obr = ~abr;
    2'b11 : obr = 1;
  endcase
end
endmodule
module dfmux (odf,adf,sdf);
    input adf;
    input [1:0] sdf;
    output  reg odf;
    always @ (sdf or adf)
begin
  case (sdf)
    2'b00 : odf = adf;
    2'b01 : odf = ~adf; 
    2'b10 : odf = ~adf;
    2'b11 : odf = adf;
  endcase
end
endmodule