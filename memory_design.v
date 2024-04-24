module memory_design (dataout,datain,datain1,datain2,datain3,add,rw,en,clk);
  input [3:0] datain,datain1,datain2,datain3;
  input rw,en,clk;
output reg [3:0] dataout;
  
parameter s0=2'b00,s1=2'b01,s2=2'b10;
   
input [0:1]add;
   
reg [1:0]state;
   
reg [3:0] mem[0:3];
  always @ (posedge clk)
  begin
    case(state)
      s0:if(en)
          state = s1;
        else
          state = s0;
       s1:if(rw)
       begin
        mem [0] = datain;
        mem [1] = datain1;
        mem [2] = datain2;
        mem [3] = datain3;
       end
     else
       begin
       state = s2;
     end
     s2:if(!rw)
       dataout =mem[add];
     else
       state = s0;
     default:state = s0;
   endcase
   end 
 endmodule
 module mem_des (datain,en,rw,addr,dataout);
   input [3:0]datain;
   input en,rw;
   input [0:3]addr;
   output reg [3:0]dataout;
   reg [3:0]mem[0:8];
   always @ (*)
   begin
     if(en)
       begin
         if(rw)
           mem[addr]=datain;
         else
           dataout=mem[addr];
         end
       else
         dataout=4'bz;
  end
endmodule
   
     
       
       
         
         
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          
      
    

              

           
  
