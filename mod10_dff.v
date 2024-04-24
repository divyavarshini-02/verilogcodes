module mod_ten (q,clk,clr);
  input clk,clr;
  output [3:0] q;
  parameter j=1,k=1;
  wire rst=q[0]&q[3];
  //and_gate s5 (q,clk);
  jkff s1 (q[0],j,k,clk,clr);
  jkff s2 (q[1],j,k,q[0],clr);
  jkff s3 (q[2],j,k,q[1],clr);
  jkff s4 (q[3],j,k,q[2],clr);
endmodule
  
module jkff(q,j,k,clk,clr);
  input j,k,clk,clr;
  output reg q;
  always @(negedge clk)
  begin
    if(clr)
      q = 0;
     else if(j == 1 && k == 1) 
        q = ~q;
  end     
endmodule   
/*module and_gate (temp,clk,cr);
  input clk;
output reg [3:0]temp;  
   always @ (negedge clk)
  begin
  /*if(clr)
    temp = 4'b0000;
  else
    begin*/
    //if((temp[3] && temp[0])== 1)
      //temp = 4'b0000;
    //else  
    //temp = temp;
  //end
 // end
//endmodule*/
  