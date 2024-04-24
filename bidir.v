module bidir(a,b,en);
  inout a,b;
  input en;
  wire n;
  assign a=en?n:1'bz;
  assign b=(!en)?n:1'bz;
endmodule 
        
    

