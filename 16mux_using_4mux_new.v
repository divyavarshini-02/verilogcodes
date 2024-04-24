module submux (out,in,sel);
  input [3:0] in;
  input [1:0] sel;
  output out;
  always @ (in or sel)
  begin 
    
  
