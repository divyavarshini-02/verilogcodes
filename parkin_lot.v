/*-------------------------------------------------------------------------------------------------------------
 Design Name : Parking lot using Finite State Machine       
 File Name: parkin_lot.v
----------------------------------------------------------------------------------------------------------------*/
module parkin_lot (
    rst_n     , //Active low, syn reset
    clk       , //clock
    in_sig    , //input signal
    out_sig   , // output signal
    veh_sgl   , // vehicle incoming and exiting signal 
    entering  , // output signal which says the vehicle is entered
    exiting     // output signal which says the vehicle is exited 
    );
    
    //---------------------------------------- INPUT PORTS --------------------------------------------------------//

    input rst_n, clk, in_sig, out_sig, veh_sgl;

    //---------------------------------------- OUTPUT PORTS -------------------------------------------------------//

    output entering, exiting;

    //----------------------------------------- INPUT DATA TYPES --------------------------------------------------//

    wire clk, rst_n, in_sig, out_sig, veh_sgl; 

    //----------------------------------------- OUTPUT DATA TYPES -------------------------------------------------//

    reg entering, exiting;

    //----------------------------------------- INTERNAL CONSTANTS ------------------------------------------------//

    parameter size = 3;

    parameter idle          =           3'd0,
              car_enter     =           3'd1,
              half_enter    =           3'd3,
              almost_enter  =           3'd2,
              car_exit      =           3'd6,
              half_exit     =           3'd7,
              almost_exit   =           3'd5,
              invalid       =           3'd4;
    
    //----------------------------------------- INTERNAL VARIABLES -------------------------------------------------//

    reg     [size-1:0]     state;  // sequential part of the FSM
    reg     [size-1:0]     next_state; //Combinational part of the FSM

    //----------------------------------------- COMBINATIONAL LOGIC ------------------------------------------------//

    always@ (state or in_sig or out_sig)
        begin
            next_state <= 3'd0;
                case (state)
                    idle:	        begin
                                        if(veh_sgl == 1'd1)
                                            begin
                                                if (in_sig == 1'd1 && out_sig == 1'd0)
                                                    begin
                                                        next_state <= car_enter;
                                                    end
                                                else if (in_sig == 1'd0 && out_sig == 1'd1)
                                                    begin
                                                        next_state <= car_exit;
                                                    end
                                                else if (in_sig == 1'd0 && out_sig == 1'd0)
                                                    begin
                                                        next_state <= idle;
                                                    end
                                                else
                                                    begin
                                                        next_state <=invalid ;
                                                    end
                                            end
                                        else
                                            begin
                                                next_state<=idle;
                                            end
                                    end
        
                    car_enter:		begin
                                        if (in_sig == 1'd1 && out_sig == 1'd1)
                                            begin
                                                next_state <= half_enter;
                                            end
                                        else
                                            begin
                                                next_state <= idle;
                                            end
                                    end

                    half_enter:		begin
                                        if (in_sig == 1'd0 && out_sig == 1'd1)
                                            begin
                                                next_state <= almost_enter;
                                            end
                                        else
                                            begin
                                                next_state <= car_enter;
                                            end
                                    end

                    almost_enter:	begin // output comes entering as one in here
                                        if (in_sig == 1'd0 && out_sig == 1'd0)
                                            begin
                                                next_state = idle;
                                            end
                                        else
                                            begin
                                                next_state <= half_enter;
                                            end
                                    end

                    car_exit:		begin
                                        if (in_sig == 1'd1 && out_sig == 1'd1)
                                            begin
                                                next_state <= half_exit;
                                            end
                                        else
                                            begin
                                                next_state <= idle;
                                            end
                                    end

                    half_exit:		begin
                                        if (in_sig == 1'd1 && out_sig == 1'd0)
                                            begin
                                                next_state <= almost_exit;
                                            end
                                        else
                                            begin
                                                next_state <= idle;
                                            end
                                    end

                    almost_exit:	begin // output comes exiting as one in here
                                        if (in_sig == 1'd0 && out_sig == 1'd0)
                                            begin
                                                next_state = idle;
                                            end
                                        else
                                            begin
                                                next_state <= half_exit;
                                            end
                                    end
                endcase
        end

    //------------------------------------ SEQUENTIAL LOGIC -------------------------------------------------------//

    always @( posedge clk )
        begin
            if(rst_n)
                begin
                    state <= idle;
                end
            else
                begin
                    state <= next_state;
                end
        end
    
    //------------------------------------------- OUTPUT LOGIC -----------------------------------------------------//
    
    always @(posedge clk) 
    begin
        if (rst_n)
            begin
                entering <= 1'd0;
                exiting <= 1'd0;
            end 
        else 
            begin
                case (state)
                    idle:	        begin
                                        entering <= 1'd0;
                                        exiting <= 1'd0; 
                                    end
        
                    car_enter:		begin
                                        entering <= 1'd0;
                                        exiting <= 1'd0; 
                                    end

                    half_enter:		begin
                                        entering <= 1'd0;
                                        exiting <= 1'd0;  
                                    end

                    almost_enter:	begin // output comes entering as one in here
                                        entering <= 1'd1;
                                        exiting <= 1'd0;                                                                                                    
                                    end

                    car_exit:		begin
                                        entering <= 1'd0;
                                        exiting <= 1'd0;  
                                    end

                    half_exit:		begin
                                        entering <= 1'd0;
                                        exiting <= 1'd0;                                                                                
                                    end

                    almost_exit:	begin // output comes exiting as one in here
                                        entering <= 1'd0;
                                        exiting <= 1'd1;  
                                    end
                endcase 
            end
    end    

endmodule