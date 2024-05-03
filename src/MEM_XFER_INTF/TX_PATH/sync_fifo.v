`include "tx_defines.vh"

module sync_fifo(
 clk,
 rstn,
 pop,
 push,
 empty,
 full,
 din,
 dout
    );

parameter PTR_WIDTH = 4; 
parameter DATA_WIDTH = 32;
parameter DEPTH = 15; 

input clk;
input rstn;
input pop;
input push;
input [DATA_WIDTH-1:0]din;

output [DATA_WIDTH-1:0]dout;
output empty;
output full;

reg [PTR_WIDTH-1:0]rdptr, next_rdptr;
reg [PTR_WIDTH-1:0]wrptr, next_wrptr;
reg empty, next_empty;
reg full, next_full;

wire fullchk;
wire emptychk;

assign fullchk = push && !(|(wrptr^(rdptr-1'b1)));
assign emptychk = pop && !(|(rdptr^(wrptr-1'b1)));

always @ (posedge clk or negedge rstn) //Sequential block
begin
  if(!rstn)
  begin
    empty   <= 1'b1;
    full    <= 1'b0;
    rdptr   <= 1'b0;
    wrptr   <= 1'b0;
  end
  else
  begin
    empty   <= next_empty;
    full    <= next_full; 
    rdptr   <= next_rdptr;
    wrptr   <= next_wrptr;
  end
end

always @ (*) //Combinational Block
begin
  next_empty   = emptychk ? 1'b1 : push ? 1'b0 : empty;
  next_full    = fullchk ? 1'b1 : pop ? 1'b0 : full;
  next_rdptr   = rdptr;
  next_wrptr   = wrptr;
 
  if(push)  //write
  begin
  next_wrptr  = wrptr+1;
  end
  else if(pop)  //read
  begin
  next_rdptr   = rdptr+1;
  end
  else
  begin
  next_rdptr = rdptr;
  next_wrptr = wrptr;
  end 
end
`ifdef FPGA_OR_SIMULATION
mem_1w1r_fpga_or_sim # ( PTR_WIDTH, DATA_WIDTH , DEPTH  ) WRAP_MEM (
    .wclk                ( clk ),
    .waddr               ( wrptr ),
    .wen                 ( push ),
    .wdata               ( din ),
    .rclk                ( clk ),
    .raddr               ( rdptr ),
    .ren                 ( pop ),
    .rdata               ( dout )
);
`endif
`ifdef ASIC_SYNTH
mem_1w1r_asic8 # ( PTR_WIDTH, DATA_WIDTH , DEPTH  ) WRAP_MEM (
    .wclk                ( clk ),
    .wrst_n		 ( rstn ),    
    .waddr               ( wrptr ),
    .wen                 ( push ),
    .wdata               ( din ),
    .rclk                ( clk ),
    .rrst_n		 ( rstn ),    
    .raddr               ( rdptr ),
    .ren                 ( pop ),
    .rdata               ( dout )
);
`endif
endmodule
