module sram_array(cs,oe,we,ub,lb,addr,data);
  output reg cs,oe,we,ub,lb;
  output reg [17:0]addr;
  inout [15:0]data;
  reg [17:0]addrin;
   reg  [15:0]datain;
  reg cs_s=0;reg oe_s=0;reg we_s=0;reg ub_s=0;reg lb_s=0;
  reg cnt;
  assign data=datain;
  always @(cnt)
  begin
  case (cnt)
    0:begin
      addrin=18'hffff;
      end
    
    1:begin
      addrin=18'hf0f0;
      end
    
  endcase
  end   
  always @(*)
  begin
    
     addr<=addrin;
      cs<=cs_s;
      oe<=oe_s;
      we<=we_s;
      ub<=ub_s;
      lb<=lb_s; 
  end
  always @(cs or we or oe or lb or ub or cnt)

  begin
  
   if(cs==1)
      begin
      datain[7:0]<=8'bz;
      datain[15:8]<=8'bz;
      end

    else if(cs==0) 
  begin
  
     if((we & oe)|(lb & ub) ==1)
        begin
        datain[7:0]<=8'bz;
        datain[15:8]<=8'bz; 
        end
  
      else
        begin
  
      if(we==1)
        begin
         
          if((oe && lb && ub)==0)
                  begin
              datain[15:0]<=16'hzzzz;
                   end
         end   
          
          else if(we==0)
          begin
            
            if((lb && ub)==0)
              begin 
                if(cnt ==1)
                  begin
              datain[7:0]<=8'b11001100;
              datain[15:8]<=8'b00110000;
                   end
                 else
                   begin
              datain[7:0]<=8'b11111111;
              datain[15:8]<=8'b00000000;
                   end 
              end
          
          end
        end  
   end  
   
 end
 
 endmodule    
