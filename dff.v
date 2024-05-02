//------------------------------------------ RTL DESIGN CODE ----------------------------------------// 
module dff (q, d, clk, rst);
input d, clk, rst;
output q;

always@(posedge clk) 
begin
   if(rst) 
        q <= 1'd0; 
    else
        q <= d;
end
endmodule

//------------------------------------------ VERILOG DESIGN CODE ------------------------------------//

module tb_dff ();  
    reg clk, d, rst;  
    reg [2:0] delay;  
  
    dff  dff0 ( .d(d),  
                .rst (rst),  
                .clk (clk),  
                .q (q));  
  
    // Generate clock  
    always #10 clk = ~clk;  
  
    // Testcase  
    initial begin  
        clk <= 0;  
        d <= 0;  
        rst <= 0;  
  
        #15 d <= 1;  
        #10 rst <= 1;  
        for (int i = 0; i < 5; i=i+1) begin  
            delay = $random;  
            #(delay) d <= i;  
        end  
    end  
endmodule  





check whatsapp
000 - 000000
001 - 000001
010 - 000100
011 - 001001
100 - 010000
101 - 011001
110 - 110110
111 - 110001


gimme 2 mins


