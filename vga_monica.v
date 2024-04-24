 vga    (
                        input                CLK_50Mhz,

                        input            rst,
                        output    reg[3:0]    Red,
                        output    reg[3:0]    Green,
                        output    reg[3:0]    Blue,
                        output            Hsync,
                        output            Vsync
                        );
                        

                    reg        [11:0]    Hsync_cnt=12'd0;        
                    reg        [11:0]    Vsync_cnt=12'd0;        
                    
                    parameter        total_column    = 800;
                    parameter        total_row    = 525;
                    parameter        active_column    = 640;
                    parameter        active_row    = 470;
                    
                    assign            Hsync                = (Hsync_cnt >= 656 && Hsync_cnt < 752)?1'b1:1'b0;                
                    assign            Vsync                = (Vsync_cnt>= 490 && Vsync_cnt< 492)?1'b1:1'b0;




                                            reg  PIXEL_CLK_25Mhz;
//CLK_25MHZ   xy( .clk( CLK_50Mhz) ,
//           .rst(rst),
//           .out_clk(PIXEL_CLK_25Mhz));

//-------------ALWAYS BLOCK TO GENERATE THE 25MHZ CLOCK FREQUENCY------------------------------------//

                              always @(posedge CLK_50Mhz)
                              begin
                              if (rst)
                                                     PIXEL_CLK_25Mhz <= 1'b0;
                              else
                                                     PIXEL_CLK_25Mhz <= ~PIXEL_CLK_25Mhz;    
                              end
//-------------ALWAYS BLOCK TO GENERATE THE Hsync_cnt AND Vsync_cnt COUNTER------------------------------------//
                        

   always@(posedge PIXEL_CLK_25Mhz)
   begin
          if(rst)
          begin
                             Hsync_cnt <= 12'b0;
                             Vsync_cnt <= 12'b0;
          end
          else
          begin

          if(Hsync_cnt ==12'd 799)
             begin
                                Hsync_cnt <= 12'b0;
          if(Vsync_cnt == 12'd524)
                                Vsync_cnt <= 0;
          else 
                                Vsync_cnt <= Vsync_cnt+1'b1;
             end
          else
                                Hsync_cnt <= Hsync_cnt+1'b1;

          end
   end

//-------------ALWAYS BLOCK TO DISPLAY THE RGB VALUE------------------------------------------------------//

   always @ (posedge PIXEL_CLK_25Mhz)
   begin
                  if (rst)
                      begin
                           Red    <= 4'b0000;
                           Green  <= 4'b0000;
                           Blue   <= 4'b0000; 
                           
                      end

                 else
                 begin
                 if ( Hsync_cnt < 12'd 80 && Vsync_cnt < 12'd 480 )

                      begin
                          Red    <= 4'b1111;
                          Green  <= 4'b1111;
                          Blue   <= 4'b1111; 
                      end

                 else 
                  if ( Hsync_cnt < 12'd 160 && Vsync_cnt < 12'd 480 )
 
                      begin
                          Red    <= 4'b1111;
                          Green  <= 4'b1111;
                          Blue   <= 4'b0000;       
                       end

                 else 
                 if ( Hsync_cnt < 12'd 240 && Vsync_cnt < 12'd 480 )

                     begin
                          Red    <= 4'b0000;
                          Green  <= 4'b1111;
                          Blue   <= 4'b1111;      
                     end

                else 
                if ( Hsync_cnt < 12'd 320 && Vsync_cnt < 12'd 480 )

                      begin
                           Red   <= 4'b0000;
                           Green <= 4'b1111;
                           Blue  <= 4'b0000; 
                       end

               else 
                if ( Hsync_cnt < 12'd 400 && Vsync_cnt < 12'd 480 )

                      begin
                          Red   <= 4'b1111;
                          Green <= 4'b0000;
                          Blue  <= 4'b1111;
                      end

               else 
               if ( Hsync_cnt < 12'd 480 && Vsync_cnt < 12'd 480 )

                     begin
                          Red   <= 4'b1111;
                          Green <= 4'b0000;
                          Blue  <= 4'b0000;
                     end

               else
               if ( Hsync_cnt < 12'd 560 && Vsync_cnt < 12'd 480 )

                     begin
                          Red   <= 4'b0000;
                          Green <= 4'b0000;
                          Blue  <= 4'b1111;
                     end

               else 
              if ( Hsync_cnt < 12'd 640 && Vsync_cnt < 12'd 480 )

                     begin
                          Red   <= 4'b1111;
                          Green <= 4'b0000;
                          Blue  <= 4'b0000; 
                     end
                else 

                     begin
                          Red   <= 4'b0000;
                          Green <= 4'b0000;
                          Blue  <= 4'b0000;
                     end
              end 
end 
endmodule