module mux16_4(y,a,s);
output y;
input [15:0]a;
input [3:0]s;
wire [4:1]y;
mux x1(y[1],a[3:0],s[1:0]);
mux x2(y[2],a[7:4],s[1:0]);
mux x3(y[3],a[11:8],s[1:0]);
mux x4(y[4],a[15:12],s[1:0]);
mux x5(y,y[4:1],s[3:2]);
endmodule

module mux(y,i,sel);
output y;
input [3:0]i;
input [1:0]sel;
wire [3:0]i;
wire [1:0]sel;
assign y = sel[1] ? (sel[0] ? i[3] : i[2]) : (sel[0] ? i[1] : i[0]);
endmodule




module up();
reg [15:0]a;
reg [3:0]s;
wire y;

initial
begin
    
    s=4'b1011;   a=16'b1010101010101100;
    #10    s=4'b1000;
    #10     s=4'b0011;
    #10     s=4'b0111;
    #10     s=4'b1111;
    #10000 $stop;
end

mux16_4 ap(
    .a   (a),
    .s   (s),
    .y   (y)
);
endmodule