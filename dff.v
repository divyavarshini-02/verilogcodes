
module DFF (q,q0,d,clk);
output reg q,q0;
input d,clk;
always@(posedge clk)
    begin
        if (d==0)
            begin 
                q<=0;
                q0<=1;
            end 
        else
            begin
                q<=1;
                q0<=0;
            end
    end
endmodule

module tb__1();
reg d,clk;
wire y,y0;
always #5 clk=~clk;
initial
    begin
        clk=1'b0; d=1'b0;
        #20
        d=1'b1;
        #121313535 $stop;
    end

    DFF d1(
        .clk    (clk),
        .d      (d),
        .q      (y),
        .q0     (y0)
        );
endmodule