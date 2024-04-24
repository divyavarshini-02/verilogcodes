module forever_ex (); 
 
  reg r_Clock = 1'b0;
  reg s_clock =1'b1;
   
  initial
    begin
      forever
      begin
        #10 r_Clock <= !r_Clock;
        #20 s_clock <= !s_clock;
    end
  end
  
endmodule

module re_op(a,b,c,d,e);//reduction operator
input [4:0]a;
output b,c,d,e;

assign b = &a;
assign c = ~&a;
assign d = ^a;
assign e = ~^a;

endmodule 

module repeat_example (); 
 
  reg r_Clock;
  reg [3:0]a =4'd15; 
  initial
    begin
     r_Clock =1'b0;
      repeat (a)
        #5 r_Clock = !r_Clock;
    end
endmodule

module repetition(a,b,c,d);
  reg [2:0]cs=3'd6;
  reg sd=1'b1;
  output [5:0]a,b,c;
  output [7:0]d;
  parameter cn=4'd2;
  
  assign a ={cn{cs}};
  assign b ={2{cs}};
  assign c ={cn{3'd6}};
  assign d ={4'd2{3'b110,sd}};
  
endmodule

module shift_operator (); 
 
  reg        [3:0] r_Shift1 = 4'b1001;
  reg signed [3:0] r_Shift2 = 4'b1001;
   
  initial
    begin
      // Left Shift
      $display("%b", r_Shift1 <<  1);
      $display("%b", $unsigned(r_Shift1) <<< 1); // Cast as signed
      $display("%b", $signed(r_Shift1) <<< 1);
      $display("%b", r_Shift2 <<< 1);          // Declared as signed type
       
      // Right Shift
      $display("%b", r_Shift1 >>  2);
      $display("%b", $unsigned(r_Shift1) >>> 2);
      $display("%b", $signed(r_Shift1) >>> 2); // Cast as signed
      $display("%b", r_Shift2 >>> 2) ;         // Declared as signed type
    end
endmodule

  
  