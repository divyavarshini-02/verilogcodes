module  BAUD_RATE   (
                      output  reg    BAUD_CLK_OUT=1'b1,   //OUTPUT OF BAUD RATE GENERATOR
                      input          CLK,
		                input          RST_n    // INPUT CLOCK AND RESET SIGNAL
                    );
  
  
                              reg   [11:0]    cnt;      // COUNTER 
                                
//--------------------ALWAYS BLOCK----------------------//    
                               
        always@(posedge CLK)
        begin
          
//----------- RST OPERATION TO MAKE COUNTER TO "0" -----//
              if(RST_n)
              begin
                     cnt     	    <= 12'b0;

		     BAUD_CLK_OUT   <= 1'b1;
              end

              else

          
//COUNTER OPERATION TO GENERATE THE BAUD RATE CLK SIGNAL//
	     
             if(cnt==12'd2604)

             begin
                    BAUD_CLK_OUT   <= ~BAUD_CLK_OUT;

                    cnt            <= 12'b0;
             end

             else
                    cnt		   <= cnt+1'b1;

	        
end
endmodule
