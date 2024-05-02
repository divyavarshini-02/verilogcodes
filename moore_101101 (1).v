/*-------------------------------------------------------------------------------------------------------------------
Design Name : Finite State Machine in a moore model for 101101 which is overlapping
File name : moore_101101.v
-------------------------------------------------------------------------------------------------------------------*/
module moore_101101 ( 
    clk     , //clock
    rst_n   , //syn active low reset
    in      , //input
    out     , //output
);

//----------------------------------------- INPUT PORTS ------------------------------------------------------------//

input clk, rst_n, in;

//----------------------------------------- OUTPUT PORTS -----------------------------------------------------------//

output out;

//----------------------------------------- INPUT DATA TYPES -------------------------------------------------------//

wire in;

//----------------------------------------- OUTPUT DATA TYPES ------------------------------------------------------//

reg out;

//----------------------------------------- INTERNAL CONSTANTS -----------------------------------------------------//

parameter size = 3;

parameter   s0 = 3'd0 ,
            s1 = 3'd1 ,
            s2 = 3'd2 ,
            s3 = 3'd3 ,
            s4 = 3'd4 ,
            s5 = 3'd5 ,
            s6 = 3'd6 ;

//----------------------------------------- INTERNAL VARIABLES -----------------------------------------------------//

reg     [size-1:0]     state;  // sequential part of the FSM
reg     [size-1:0]     next_state; //Combinational part of the FSM

//----------------------------------------- COMBINATIONAL LOGIC ----------------------------------------------------//

always @(state or in)
    begin
        next_state <= 3'd0;
            case(state)
                s0:     begin
                            if(in == 1'd1)
                                begin
                                    next_state = s1;
                                end
                            else
                                begin
                                    next_state = s0;
                                end
                        end

                s1:     begin
                            if(in == 1'd0)
                                begin
                                    next_state = s2;
                                end
                            else
                                begin
                                    next_state = s1;
                                end
                        end

                s2:     begin
                            if(in == 1'd1)
                                begin
                                    next_state = s3;
                                end
                            else
                                begin
                                    next_state = s0;
                                end
                        end

                s3:     begin
                            if(in == 1'd1)
                                begin
                                    next_state = s4;
                                end
                            else
                                begin
                                    next_state = s2;
                                end
                        end

                s4:     begin
                            if(in == 1'd0)
                                begin
                                    next_state = s5;
                                end
                            else
                                begin
                                    next_state = s1;
                                end
                        end

                s5:     begin
                            if(in == 1'd1)
                                begin
                                    next_state = s6;
                                end
                            else
                                begin
                                    next_state = s0;
                                end
                        end

                s6:     begin
					out = 1'd1;
                            if(in == 1'd1)
                                begin
                                    next_state = s1;
                                end
                            else
                                begin
                                    next_state = s2;
                                end
                        end                        
            endcase
    end

//----------------------------------------- SEQUENTIAL LOGIC -------------------------------------------------------//

    always @( posedge clk )
        begin
            if(rst_n)
                begin
			out<=1'd0;
                    state <= s0;
                end
            else
                begin
                    state <= next_state;
                end
        end

//----------------------------------------- OUTPUT LOGIC -----------------------------------------------------------//

   

endmodule