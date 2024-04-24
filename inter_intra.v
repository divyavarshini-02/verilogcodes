module test;
  reg[3:0] x,y,a,b;
  initial 
  begin
    $monitor ($time,"x=%b,y=%b",x,y);
    x=0;y=1;
    #10;
    x=2;
    a=x;
    b=y;
    #10 y=13;
        a=11;
        a=3;
    x=#20 a+b;
    y=#10 a-b;
    #10 x=5;
    #5 y=3;
    $display($time,x,y);
  end
endmodule
module testy;
  reg clk;
  reg [1:0]a,b;
  always @ (posedge clk)
  begin
    a<=1;
    b<=@(negedge clk)a+1;
  end
  endmodule
    
    
    
    
