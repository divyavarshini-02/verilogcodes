/*module uarttxrx(clk,clk_o,tx);
  input clk;
  //input [7:0]d;
  reg [7:0]d=8'b10110001;
  output clk_o;
  output tx;
  reg tx=1'b1;
  reg[1:0] ns=2'b00;
  reg [3:0]count1=0;
  parameter ideal=2'b00,start=2'b01,data=2'b10,stop=2'b11;
  clkdiv1 c1 (clk,clk_o);
  always @(posedge clk_o)
    begin      
  case(ns)
      ideal:begin
      tx<=1'b1;
      ns<=start;
     
      end
     
      start:begin
       tx<=1'b0;
        ns<=data;
         count1<=4'b0;
      end
     
      data:begin        
        tx<=d[count1];
        count1<=count1+1;
          if(count1>=7)
            ns<=stop;            
        end
               
        stop:begin
         tx<=1'b1;
          ns<=ideal;
        end          
        endcase        
        end
      endmodule*/   
     
     
   
   
  module keeri_clkdiv1(clk,clk_0);
  input clk;
  output reg clk_0=1;
  reg [2:0]count=1;
  parameter n=3'd6;
 
  always @(negedge clk)
 
    if(count==(n/2))
      begin
        clk_0<=~clk_0;
        count<=1;
      end
      else
        count<=count+1;
  endmodule
