module  uart(
                            output reg    TX_OUT,   	//  transmitter serial output
                            input         CLK,      	//  clock signal
                            input         RST_n      	//  reset signal
                            
                            );
 
                            parameter     s1  =   2'b00,
                                          s2  =   2'b01,
                                          s3  =   2'b10; // FSM OPERATION 

														
														
														
														
														
wire  BAUD_CLK_OUT;                
               

 reg   [7:0]	  mem_tx = 8'b00001111;	  	  // MEMORY TO STORE THE DATA

		

                            

 reg   [1:0]   state=2'b00;    			// STATES FOR FSM OPERATION
 reg   [3:0]   cnt=4'b0000;    			// counter opertion



//----------------------- ALWAYS BLOCK-----------------//                          
                            
        always@(posedge BAUD_CLK_OUT)
        begin

//--RESET OPERATION TO MAKE INITIAL VALUE FOR STATE, COUNTER.          
          
              if(RST_n)
                        begin
                              state     <=  s1;
                              TX_OUT    <=  1'b1;
                      
                              cnt       <=  4'b0000;
                        end
              else
              begin
                
                
//---------------------FSM OPERTION-------------------//

                  case(state)
                    
//---------------------START BIT CONDITION------------// 
                   
                  s1:	 begin
  	                       TX_OUT     <= 1'b0;
			                 cnt        <= 4'b0000;
        	                 state      <= s2;
       	                 end
       	                
//--SERIAL DATA TRANSMISSION FROM UART TRANSMITTER-----// 

       	                
                  s2: begin
                    
                      if(cnt<4'd7)
                        begin
                              
			                     TX_OUT    <= mem_tx[cnt];
                              cnt       <= cnt+1'b1;
                              state     <= s2;
                        end
                        
                        else

                              state     <= s3;
                      end
                        
//-------------------- STOP BIT CONDITION--------------// 
 
                    s3: begin

                             TX_OUT    	 <= 1'b1;                             
                             cnt           <= 4'b0;
                             state         <= s1;
				
                        end
                        
                  default:state<=s1; 
                      
                  endcase
        end
        end
		  
		  
		  
		  BAUD_RATE    u3 ( 	 
                               .CLK           (CLK),
                               .RST_n         (RST_n),
                               .BAUD_CLK_OUT  (BAUD_CLK_OUT)
                                    	 
                          );
      
endmodule

