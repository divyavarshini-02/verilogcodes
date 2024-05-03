/*-------------------------------------------------------------------------------------------------------------------
Design Name : Overlapping Mealy FSM for 101
File name : Mealy_101_OL
-------------------------------------------------------------------------------------------------------------------*/

module Mealy_101_OL (
    clk,            // Input CLK
    rst_n,          // Active low reset
    in,             // 1 bit input 
    out             // 1 bit output
    );

    //----------------------------------------- INPUT PORTS ------------------------------------------------------------//

 input clk,rst_n,in;

 //----------------------------------------- OUTPUT PORTS -----------------------------------------------------------//

 output out;

 //----------------------------------------- INTERNAL CONSTANTS -----------------------------------------------------//
 
 parameter s0 = 2'b00,
            s1 = 2'b01,
            s2 = 2'b10; 

 //----------------------------------------- INTERNAL VARIABLES -----------------------------------------------------//

 reg [1:0]pstate;        //combinational logic
 reg [1:0]nstate;        //sequential logic

 //----------------------------------------- COMBINATIONAL LOGIC ----------------------------------------------------//

 always@(*)
    begin
        nstate = 2'b00;
        case(pstate)
        s0: begin
                if (in==0)
                    nstate = s0;
                else
                    nstate = s1;
            end
        s1: begin
                if (in==0)
                    nstate = s2;
                else
                    nstate = s1;
            end
        s2: begin
                if (in==0)
                    nstate = s0;
                else
                    nstate = s1;
            end
    end
 //----------------------------------------- SEQUENTIAL LOGIC -------------------------------------------------------//

 always@(posedge clk)
    if(!rst_n)
        pstate <= 2'b00;
    else 
        pstate <= nstate;

 //----------------------------------------- OUTPUT LOGIC -----------------------------------------------------------//

    always @(posedge clk ) 
    begin
        if(!rst_n)
            out <=  1'd0;
        else
            begin
                case(pstate)
                s0:out<=1'd0;
                s1:out<=1'd0;
                s2: begin
                    if (in==0)
                        out <= 1'b0;
                    else
                        out <= 1'b1;
                end
                endcase
            end
    end

endmodule