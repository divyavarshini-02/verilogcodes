
module add_sub_4bit(s,cout,a,b,k);
output [3:0]s;
output cout;
input [3:0]a,b;
input k;
wire [3:0]w;
wire [2:0]c;
xor x0(w[0],b[0],k);
xor x1(w[1],b[1],k);
xor x2(w[2],b[2],k);
xor x3(w[3],b[3],k);
fa f0(s[0],c[0],a[0],w[0],k);
fa f1(s[1],c[1],a[1],w[1],c[0]);
fa f2(s[2],c[2],a[2],w[2],c[1]);
fa f3(s[3],cout,a[3],w[3],c[2]);
endmodule 

module fa(s,c0,a,b,c);
output s,c0;
input a,b,c;
assign s= a^b^c;
assign c0= (a&&b)||(b&&c)||(c&&a);
endmodule 

module as4();
reg [3:0]p,q;
reg l;
wire [3:0]t;
wire cout;
initial
begin
    p=4'b1110; q=4'b1100; l=1'b1;
    #20 p=4'b1111; q=4'b0001; 
    #20 l=1'b0;
    #1230 $stop;
end
add_sub_4bit a1(
                .a  (p),
                .b  (q),
                .k  (l),
                .s  (t),
                .cout   (cout)
                );
endmodule
