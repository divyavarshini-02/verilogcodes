module bcd_adder(a,b,cin,s1,s,c);
    input [3:0] a,b;
    input cin;
    wire cin=1'b0;
    output [3:0]s;
    output c;
    wire cout1,cout,x,y;
    input [3:0]s1;
    wire [3:0]a1,b1;
    rpa r1(a,b,cin,s1,cout);
    assign x=s1[1]&&s1[3];
    assign y=s1[2]&&s1[3];
    assign c=x||y||cout;
    assign b1[1]=c;
    assign b1[2]=c;
    assign b1[0]=1'b0;
    assign b1[3]=1'b0;    
    assign a1=s1;   
    rpa r2(a1,b1,cin,s,cout1);
endmodule

module rpa(a,b,c,s,co);
    input [3:0]a,b;
    input c;
    output[3:0]s;
    output co;
    wire [2:0]cc;
    fa f0(a[0],b[0],c,s[0],cc[0]);
    fa f1(a[1],b[1],cc[0],s[1],cc[1]);
    fa f2(a[2],b[2],cc[1],s[2],cc[2]);
    fa f3(a[3],b[3],cc[2],s[3],co);
endmodule 

module fa(p,q,r,s,c1);
    input p,q,r;
    output s,c1;
    assign s=p^q^r;
    assign c1=(p&&q)||(q&&r)||(r&&p);
endmodule


module tbbcd();
    reg [3:0] a,b;
    reg cin=1'b0;
    wire [3:0]s;
    wire c;
    initial
        begin
            a=4'b0010;b=4'd14;cin=1'b0;
            #200 a=4'b0011; b=4'b0001;
            #1000 $stop;
        end
    bcd_adder bcd1(
        .a  (a),
        .b  (b),
        .cin  (cin),
        .s  (s),
        .c (c));
endmodule