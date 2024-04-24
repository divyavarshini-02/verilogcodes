module clock_odd (out,clk);
  input clk;
  output out;
 reg [1:0] pcount=0,ncount=0;
  always @ (posedge clk)
    begin
     if(pcount == 2'b10)
         pcount =0;    
  else
     pcount = pcount+1;
 end
 always @ (negedge clk)
  begin
     if(ncount == 2'b10)
      ncount =0;     
  else
     ncount = ncount+1;
 end
 assign out = ((pcount > 2'b01)|(ncount > 2'b01));
endmodule

