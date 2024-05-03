/*-------------------------------------------------------------------------------------------------------------------------------------------
Design Name : Traffic Lights intrepertation in FSM or sequence detector
File name   : traffic_lights.v
Description : 

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                      TRAFFIC LIGHT SYSTEM                                                               //
//                              *THINGS TO REMEMBER FOR DESIGNING VGA IN UART SPEC WHICH DE0 BOARD*                                        //
//                     1# THE DESIGN WORKS IN 25 MHZ.                                                                                      //
//                     2# THE COLOUR RED STANDS FOR 10 COUNTS.                                                                             //
//                     3# THE COLOUR ORANGE STANDS FOR 5 COUNTS.                                                                           //
//                     4# THE COLOUR GREEN STANDS FOR 30 COUNTS.                                                                           //
//                     5# THERE ARE THREE STATES WHICH DETERMINES THE LIGHT OF THE DEVICE.                                                 //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-------------------------------------------------------------------------------------------------------------------------------------------*/

module traffic_lights(
        clk_i,              // INPUT CLK FOR 25mhz
        rst_n_i,            // INPUT ACTIVE LOW RESET 
        turn_off_in_i,      // INPUT ENABLE SIGNAL TO DETERMINE THE TRAFFIC LIGHTS IS ON OR OFF
        red_o,              // OUTPUT RED SIGNAL
        orange_o,           // OUTPUT ORANGE SIGNAL
        green_o             // OUTPUT GREEN SIGNAL
                    );

//----------------------------------------- INPUT PORTS ------------------------------------------------------------//

input clk_i, rst_n_i, turn_off_in_i;

//----------------------------------------- OUTPUT PORTS -----------------------------------------------------------//

output red_o, orange_o, green_o;

//----------------------------------------- INTERNAL CONSTANTS -----------------------------------------------------//

parameter size = 2;
parameter cnt_size = 5;

parameter red       =    2'h0,
          orange    =    2'h1,
          green     =    2'h2;

//----------------------------------------- INTERNAL VARIABLES -----------------------------------------------------//

reg [size-1:0]pstate;               //combinational logic
reg [size-1:0]nstate;               //sequential logic

reg [cnt_size-1:0] count_r;         //red_counter
reg [cnt_size-1:0] count_o;         //orange counter 
reg [cnt_size-1:0] count_g;         //green counter

//----------------------------------------- COMBINATIONAL AND OUTPUT LOGIC -------------------------------------------//

always@(*) 
    begin
        if(!rst_n_i)
            begin
                nstate  =  2'h0;
                count_r =  5'h00;
                count_o =  5'h00;
                count_g =  5'h00;
            end
        else
            begin
                nstate = 2'h0;
                if (turn_off_in_i == 1'b1)
                    begin
                        case(pstate)
                        red:    begin 
                                    if(count_r <= 5'h0A )
                                    begin
                                        red_o  = 1'b1;
                                        nstate = orange;
                                    end 
                                    else
                                    begin
                                        if(count_r == 5'h0A)
                                            begin
                                                count_r = 5'h00;
                                            end
                                        else
                                            begin
                                                count_r = count_r + 5'b1;
                                            end
                                        nstate = red;
                                    end 
                                end
                        orange:    begin 
                                    if(count_o <= 5'h05 )
                                    begin
                                        orange_o  = 1'b1;
                                        nstate = green;
                                    end 
                                    else
                                    begin
                                        if(count_o == 5'h05)
                                            begin
                                                count_o = 5'h00;
                                            end
                                        else
                                            begin
                                                count_o = count_o + 5'b1;
                                            end
                                        nstate = orange;
                                    end 
                                end
                        green:    begin 
                                    if(count_g <= 5'h1E )
                                    begin
                                        green_o  = 1'b1;
                                        nstate = red;
                                    end 
                                    else
                                    begin
                                        if(count_g == 5'h1E)
                                            begin
                                                count_g = 5'h00;
                                            end
                                        else
                                            begin
                                                count_g = count_g + 5'b1;
                                            end
                                        nstate = green;
                                    end 
                                end
                        endcase
                    end
                else
                    begin
                        orange_o = ~orange_o;
                        orange_o = ~orange_o;
                    end 
            end
    end

//----------------------------------------- SEQUENTIAL LOGIC -------------------------------------------------------//

always@(posedge clk_i ) 
    begin
        if(!rst_n_i)
            begin
                pstate <= 2'h0;
            end
        else
            begin
                pstate <= nstate;
            end
    end

endmodule