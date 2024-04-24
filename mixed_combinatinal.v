module mixed_combinational(q,clk);
output reg [3:0]q;
reg [3:0]x;
//input [3:0] d;
input clk;
initial x=4'b0001;
always@(posedge clk)
    begin 
        case(x)
            1:q=4'b0000;
            2:q=4'b0001;
            3:q=4'b0011;
            4:q=4'b0111;   
            5:q=4'b1001;
            6:q=4'b1101;
            7:q=4'b0000;
        endcase
    end

always@(negedge clk)
    begin
        if(x==4'b1000)
            x<=4'b0000;
        else
            x=x+1;
    end 
endmodule


module uut();
reg clk;
wire [3:0]q;
always #5 clk=~clk;
initial 
begin
    clk=1'b0;
    #100100    $stop;
end


mixed_combinational d1(
                    .clk    (clk),
                    .q      (q)
                    );
endmodule
