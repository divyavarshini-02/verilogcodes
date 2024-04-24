module enc(data,cntr,dd,clk,out,op,clk1,pma_clk,pma_out);
  input [63:0] data;
  input [7:0] cntr;
  input clk,clk1,pma_clk;
  reg [63:0] od;
  reg [1:0] sb;
  output  [65:0] dd;
  output [63:0]out;
  output [15:0]op;
  output pma_out;
  wire [63:0] sd;
  assign sd=od;
  assign dd={od,sb};
  scam ut(sd,out,clk);
  gearbox uus(clk1,sd,op,sb);
  pma_tst sfs(pma_clk,op,pma_out);
  always@(posedge clk)
case(cntr)

8'h00: // data
     begin 
       od<=data;
       sb<=2'b10;
     end 
     
8'hff: // ideal
      begin 
         if(data[7:0]==8'h07 && data[63:56]==8'h07)
         begin 
                     sb<=2'b01;
                     od[63:8]<={7{8'h00}};  
                     od[7:0]<=8'h1e;
                  end 
                              
       
      else 
        begin 
          if(data[7:0]==8'hfd)
             begin    
               sb<=2'b01;
                od[63:8]<={7{8'h00}};
                od[7:0]<=8'h87;
            end            
         else 
            begin 
               sb<=2'b00;
               od[63:0]<={8{8'h1e}};
            end  
       end 
   end 
 8'h01: //start
      begin 
         if(data[7:0]==8'hfb)
            begin    
                sb<=2'b01;
                od[63:8]<=data[63:8];  
                od[7:0]<=8'h78;
            end 
         else 
            begin 
              sb<=2'b00;
              od[63:0]<={8{8'h1e}};
            end         
     end   
     
 8'hfe: //T1
        begin 
           if(data[15:8]==8'hfd)
              begin    
               sb<=2'b01;
                 od[63:16]<={6{8'h00}};
                 od[15:8]<=data[7:0];
                 od[7:0]<=8'h99;
              end 
          else 
             begin 
                 sb<=2'b00;
                 od[63:0]<={8{8'h1e}};
             end         
       end 
   
 8'hfc: //T2
       begin 
          if(data[23:16]==8'hfd)
             begin    
                sb<=2'b01;
                od[63:24]<={5{8'h00}};
                od[23:8]<=data[15:0];
                od[7:0]<=8'haa;
            end 
         else 
            begin 
              sb<=2'b00;
              od[63:0]<={8{8'h1e}};
            end         
       end 
     
 8'hf8: //T3
        begin 
           if(data[31:24]==8'hfd)
              begin    
                 sb<=2'b01;
                 od[63:32]<={4{8'h00}};
                 od[31:8]<=data[23:0];
                 od[7:0]<=8'hb4;
             end 
          else 
             begin 
                sb<=2'b00;
               od[63:0]<={8{8'h1e}};
            end                     
        end 
 8'hf0: //T4
      begin 
         if(data[39:32]==8'hfd)
            begin    
              sb<=2'b01;
               od[63:40]<={3{8'h00}};
               od[39:8]<=data[31:0];
               od[7:0]<=8'hcc;
           end 
        else 
          begin 
             sb<=2'b00;
            od[63:0]<={8{8'h1e}};
         end         
     end 
 8'he0: //T5
       begin 
          if(data[47:40]==8'hfd)
            begin    
               sb<=2'b01;
               od[63:48]<={2{8'h00}};
               od[47:8]<=data[39:0];
               od[7:0]<=8'hd2;
           end
        else 
           begin 
             sb<=2'b00;
             od[63:0]<={8{8'h1e}};
          end                  
     end 
   
 8'hc0: //T6
        begin 
           if(data[55:48]==8'hfd)
              begin    
               sb<=2'b01;
                od[63:56]<={1{8'h00}};
                od[55:8]<=data[47:0];
                od[7:0]<=8'he1;
             end 
          else 
            begin 
              sb<=2'b00;
              od[63:0]<={8{8'h1e}};
           end         
     end 
     
 8'h80: //T7
        begin 
           if(data[63:56]==8'hfd)
         begin    
            sb<=2'b01;
            od[63:8]<=data[55:0];
            od[7:0]<=8'hff;
        end
      else 
        begin 
          sb<=2'b00;
          od[63:0]<={8{8'h1e}};
       end                 
     end 
endcase 
endmodule 


module scam (din,dout,ck);
  input ck;
  input [0:63]din;
  output reg[0:63]dout;
  reg [57:0]ns={58{1'b1}};
 // reg [1:0]i=0;
  always @(posedge ck)
  begin
  //  i <= i + 1;
   // if(i>=1)
      //begin
      //i<= 1;
   dout[0:38]<=ns[38:0]^ns[57:19]^din[0:38];
   dout[39:57]<=ns[18:0]^ns[38:20]^ns[57:39]^din[0:18]^din[39:57];
   dout[58:63]<=ns[19:14]^ns[57:52]^din[0:5]^din[19:24]^din[58:63];
    // end
  end
  always @ (dout)
  begin
   // if(i>=1)
    ns[57:0]<=dout[6:63];
  end
endmodule



// din=0000111111110000101011100101110000001111111100001010111001011100
    // 0001111000000000000000000000000000000000000000000000000000000000
    
/*module scam (din,dout,ck);
  input ck;
  input [0:63]din;
  output reg[0:63]dout;
  reg [57:0]ns={58{1'b1}};
  always @(posedge ck)
  begin
   dout[0:18]=ns[18:0]^ns[57:39]^din[0:18];
   dout[19:37]=ns[38:20]^ns[18:0]^ns[57:39]^din[0:18]^din[19:37];
   dout[38:56]=ns[19:1]^ns[18:0]^ns[57:39]^din[19:37]^din[38:56];
   dout[57]=ns[0]^ns[18]^ns[57]^din[38]^din[57];
   dout[58:63]=ns[17:12]^ns[57:52]^din[0:5]^din[39:44]^din[58:63];
 end
  always @ (dout)
  begin
    ns[57:0]<=dout[6:63];
  end
endmodule*/



