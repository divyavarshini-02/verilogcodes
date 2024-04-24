module multiplication(a,b,out);
	input [3:0]a,b; // a is multiplicant && b is multiplier 
	input [7:0]out;
	reg [4:0]accumulator;
	wire [3:0]reg_multiplier;
	reg [8:0]total_reg;
	assign reg_multiplier=b;
	always@(a or b)
		begin
			if(reg_multiplier[0]==1'b0)
				total_reg<=({accumulator,reg_multiplier}>>1);
			else
				begin
					accumulator[3:0]<=b[3:0];
					
				end	
		end


