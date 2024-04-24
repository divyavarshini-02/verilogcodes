module muxusingmux(out,in,s1,s2);
  input [15:0] in;
  input [1:0] s1;
  input [1:0] s2;
  output reg out;
  reg  [3:0] n;
  always @ (in or s1)
begin
  if(s1 == 2'b00)
    begin
   n[0] = in[0];n[1]=in[4];n[2]=in[8];n[3]=in[12];
 end
  else if (s1 == 2'b01) 
   begin
   n[0] = in[1];n[1]=in[5];n[2]=in[9];n[3]=in[13];
 end
  else if (s1 == 2'b10) 
   begin
   n[0] = in[2];n[1]=in[6];n[2]=in[10];n[3]=in[14];
 end
  else if (s1 == 2'b11)  
    begin
   n[0] = in[3];n[1]=in[7];n[2]=in[11];n[3]=in[15];
end
end
always @ (n or s2)
begin
  case (s2)
    2'b00 : out = n[0];
    2'b01 : out = n[1];
    2'b10 : out = n[2];
    2'b11 : out = n[3];
  endcase
end
endmodule