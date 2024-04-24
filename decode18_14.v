module decode18_14(in,s,out);
input in;
input [2:0]s;
output reg [7:0]out;
always@(*)
    begin
        if (s[2]==0)
                begin
                    if(s[0]==0&&s[1]==0)
                           out[0]<=in;
                    else if(s[0]==0&&s[1]==1)
                           out[1]<=in;
                    else if(s[0]==1&&s[1]==0)
                           out[2]<=in;
                    else 
                           out[3]<=in;
                end
        else
                begin
                    if(s[0]==0&&s[1]==0)
                           out[4]<=in;
                    else if(s[0]==0&&s[1]==1)
                           out[5]<=in;
                    else if(s[0]==1&&s[1]==0)
                           out[6]<=in;
                    else 
                           out[7]<=in;
                end        
    end
endmodule

module de();
reg i;
reg [2:0]s1;
wire [7:0]q;
initial 
    begin
       s1[0]=4'b0000; s1[1]=4'b1111; i=1'b0;
      #10 s1[0]=4'b0110; s1[1]=4'b1110; i=1'b1;
      #10 s1[0]=4'b0111; s1[1]=4'b1100; 
       #1000 $stop;
    end
    decode18_14 detb(
        .in      (i),
        .s       (s1),
        .out     (q)       
    );
endmodule 