module spi_master(out,mst,in,clk);
  input in,clk;
  output  out;
  output reg [0:3]mst=4'b1101;
  assign out = mst[3]; 
  always @ (posedge clk)
        begin
        mst <= mst>>1;
        mst[0] <= in;  
        end
 endmodule 
module spi_slave(out,slv,in,clk);
  input in,clk;
  output out;
  output reg [3:0]slv=4'b0001;
   assign out=slv[3];
  always @ (posedge clk)
  begin
        slv <= slv<<1;
        slv[0] <= in;
          end
endmodule 
module spi_m_s(mout,sout,slv,mst,clk);
  input clk;
  output mout,sout;
  output [3:0]slv,mst;
  wire si,mi;
  assign mi = sout;
  assign si = mout;
 spi_master m1(.out(mout),.mst(mst),.in(mi),.clk(clk));
 spi_slave s1(.out(sout),.slv(slv),.in(si),.clk(clk));
 endmodule
  
        
        
