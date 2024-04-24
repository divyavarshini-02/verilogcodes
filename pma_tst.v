module pma_tst(pma_clk,op,pma_out,clk1);
//input [15:0]pma_in;
input pma_clk;
output reg pma_out;
input clk1;
reg [3:0]cn =4'd15;

wire [1:0] syn;
wire [63:0] data;
input [15:0] op;


gearbox ss(clk1,data,op,syn);
//assign pma_in = op;


always @ (posedge pma_clk)
begin
  if(cn<4'd15)
    begin
  pma_out<=op[cn];
   cn<=cn+1'd1;
   end
   else           
  begin        
   cn<=3'b0;   
  end 
end
endmodule    