module mealy_1011(x,clk,y,reset);
	parameter s0=2'b00, s1=2'b01, s2=2'b10, s3=2'b11;
	input x,clk,reset;
	output reg y;
	reg [1:0]present,next;
		always@(posedge clk)
			begin
				if (reset)
					present<=s0;
				else
					present<=next;
			end
		always@(posedge clk)
			begin
				case(present)
					s0:	if(x==1)
							begin
								next=s1;
								y=1'b0;
							end
						else
							begin
								next=s0;
								y=1'b0;
							end
					s1:	if(x==0)
							begin
								next=s2;
								y=1'b0;
							end
						else
							begin
								next=s1;
								y=1'b0;
							end
					s2:	if(x==1)
							begin
								next=s3;
								y=1'b0;
							end
						else
							begin
								next=s0;
								y=1'b0;
							end
					s3:	if(x==1)
							begin
								next=s2;
								y=1'b1;
							end
						else
							begin
								next=s2;
								y=1'b0;
							end
				endcase
			end
endmodule 




module tbmealy_1011();
	reg x,clk,reset;
	wire y;
	always #5 clk=~clk;
	initial 
		begin
			$monitor(" displaying x: %b",x);
			clk=1'b0;x=1'b1; reset=1'b1;
			#20 reset=1'b0;
			#20 x=1'b0;
			#20 x=1'b1;
			#50 x=1'b0;
			#20 x=1'b1;
			#100 $display ("rakita rakita rakita ooooo!");			
			#1000 $stop;
		end
	mealy_1011 m1(
			.x		(x),
			.clk	(clk),
			.reset	(reset),
			.y		(y));
endmodule
