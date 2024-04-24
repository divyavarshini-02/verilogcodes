module swg(clk,rst,sq_wave);
	input clk,rst;
	output reg  sq_wave;
	parameter clock_freq=10000000; //10,000khz is the freq
	reg [7:0]counter=0;
	always@(posedge clk)
		begin
			if(rst)
				begin
					counter<=8'd0;
					sq_wave<=0;
				end
			else
				begin
					if(counter<8'd4)
						begin
							sq_wave<=((clock_freq/2)-1);
							sq_wave<=~sq_wave;
							counter<=counter+1; 
						end
					else
						begin
							counter<=8'd0;
						end
				end
		end
endmodule


