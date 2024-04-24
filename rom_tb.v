module rom_tb();
  reg clk1,clk2,reset;
  reg [1:0]single_in;
	reg [1:0]mem_addr;

  wire [1:0]single_out;

	always#5 clk1=~clk1;
	always#5 clk2=~clk2;

  initial
  begin
    reset=1'b1;
    clk1=1'b0;
    clk2=1'b0;
    single_in=2'b00;
		mem_addr=2'b00;
 

#100;
reset=1'b0;
clk1=1'b1;
clk2=1'b1;
single_in=2'b00;
mem_addr=2'b00;
 
#100;
single_in=2'b01;
mem_addr=2'b01;
   
#100;
single_in=2'b10;
mem_addr=2'b10;

#100;
single_in=2'b11;
mem_addr=2'b11;

#100;
$stop;
  end
   rom dut(
   .clk1(clk1),
   .clk2(clk2),
   .reset(reset),
	 .mem_addr(mem_addr),
   .single_in(single_in),
   .single_out(single_out)
   );
 endmodule
