module comp (aeb,agb,alb,a,b);
  input [3:0]a,b;
  output  reg aeb,agb,alb;
  always @ (a,b)
  begin
    aeb = 0;agb = 0;alb = 0;
    if (a == b)
      aeb = 1;
    else if (a > b)
      agb = 1;
    else if (a < b)
      alb = 1;
    end
  endmodule
      
      
  
