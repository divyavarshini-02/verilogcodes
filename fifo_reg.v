/*module fifo_reg (dataout,datain,clk,emt);
  input datain,clk,emt;
  output reg dataout;
  reg rgst[0:3];
  reg [1:0]cnt=0;
always @(posedge clk)
begin
  if(emt)
    begin
    rgst[0]=1'bx;
    rgst[1]=1'bx;
    rgst[2]=1'bx;
    rgst[3]=1'bx;
  end
else
  begin
   rgst[0]=datain;
   if(cnt <=2)
     begin
       rgst[cnt+1]=rgst[cnt];
       cnt = cnt+1;
     end
   else
     begin
     dataout = rgst[cnt];
     cnt = 0;
   end
   end
 end
 endmodule*/
 module fifo_reg(dataout,datain,clk);
   input datain,clk;
   output  reg dataout;
   reg [7:0] mem = 8'bz;
   reg [3:0]cnt=0; 
   always @(posedge clk)
   begin
     if(cnt<=6)
       begin
     mem[0] = datain;
     mem = mem << 1;
     cnt = cnt+1;
   end
     else
       begin
     dataout = mem[7];
     cnt = 0;
      end
 end
 endmodule
 
     
     
     