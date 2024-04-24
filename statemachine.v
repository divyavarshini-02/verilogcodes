module statemachine(out,clk,in,reset);
	output reg out;
	input clk,in,reset;
	reg [1:0]ns,ps; //nextstate=ns; presentstate=ps;
	parameter a=2'b00, b=2'b01, c=2'b10, d=2'b11;
		always@(posedge clk)
			begin
				case(ps)
    				a:	if(in==1'b1)
							begin
								ns<=b;
        						out<=1'b0;
    						end
    					else
    						begin
    							ns<=ps;
    							out<=1'b0;
    						end
				    b:	if(in==1'b0)
    						begin
        						ns<=c;
        						out<=1'b0;
      						end
    					else
							begin
        						ns<=ps;
        						out<=1'b0;
      						end
    				c:	if(in==1'b1)
      						begin
        						ns<=d;
        						out<=1'b0;
      						end
    					else
      						begin
        						ns<=a;
        						out<=1'b0;
      						end
				    d:	if(in==1'b1)
      						begin
        						ns<=b;
        						out<=1'b1;
      						end
    					else
      						begin
        						ns<=c;
        						out<=1'b0;
      						end
      			endcase
			end

      	always@(negedge clk)
      		begin
        		if(reset)
          			ps<=a;
          		else
            		ps<=ns;
      		end
endmodule 


module tbstatemachine();
	wire out;
	reg clk,in,reset;
	statemachine st(out,clk,in,reset);
	always #5 clk=~clk;
	initial
		begin
			clk=1'b0;
			reset=1'b1;
			#10 
			reset=1'b0;
			in=1'b1;
			#10
			in=1'b0;
			#10
			in=1'b1;
			#10
			in=1'b1;
			#1000 $stop;
		end
endmodule