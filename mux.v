module mux(i,s,d);
	input [3:0]i;
	input [1:0]s;
	output reg d;
	always@(i or s)
		begin
			if(s==2'b00)
				d<=i[0];
			else if(s==2'b01)
				d<=i[1];
			else if(s==2'b10)
				d<=i[2];
			else
				d<=i[3];
		end
endmodule