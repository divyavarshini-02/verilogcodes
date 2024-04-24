module multi(a,b,exception,overflow,underflow,out_product);
input [7:0]a,b;
output exception,overflow,underflow;
output [15:0]out_product;

reg sign_reg;
