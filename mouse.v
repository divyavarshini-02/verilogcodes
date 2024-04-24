module
halfadder(a,b,sum,carry);
input a,b;
output sum, carry;
wire sum, carry;
assign sum = a^b; // sum bit
assign carry = (a&b) ;
//carry bit
endmodule