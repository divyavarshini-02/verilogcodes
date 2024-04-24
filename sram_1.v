module sram(cs,oe,we,ub,lb,addr,data);
  output reg cs,oe,we,ub,lb;
  output reg [17:0]addr;
  inout [15:0]data;
  reg [17:0]addrin=18'b1;
   reg  [15:0]datain;
  reg cs_s=0;reg oe_s=0;reg we_s=0;reg ub_s=0;reg lb_s=0;
  assign data=datain;
  always @(*)
  begin
  addr<=addrin;
   cs<=cs_s;
   oe<=oe_s;
   we<=we_s;
   ub<=ub_s;
    lb<=lb_s;
  end
  always @(*)

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
              datain[7:0]<=data[7:0];
              datain[15:8]<=data[15:8];
            end
            
         end   
          
          else if(we==0)
          begin
            
            if((lb && ub)==0)
              begin
              datain[7:0]<=8'b10101010;
              datain[15:8]<=8'b11110000;
              end
          
          end
        
        end  
   end  
   
 end
 
 endmodule     
                
           
           
               
              
        
       
        
        
  
  
    
        
        
