module ass1_2 (p,clk,rst,qa,qb,qab,qbb);
	input p,clk,rst;
//	input [1:0] j,k;
	output reg qa,qb,qab,qbb; //qa=ff a o/p; qb=ff b o/p; qab= ~qa; qbb=~qb;
	wire w1,w2,w3,w4;
	assign w1=!p;
	assign w2=(w1)&&(qb);
	assign w3=(p)&&(qb);
	assign w4=(p)&&(qa);
	always@(posedge clk)
		begin
			if(rst)
				begin
					qa<=1'b0;
					qb<=1'b0;
					qab<=1'b1;
					qbb<=1'b1;
				end
			else
				begin
					qa<=w2;
					qab<=w3;
					qb<=p;
					qbb<=w4;
				end
		end
endmodule