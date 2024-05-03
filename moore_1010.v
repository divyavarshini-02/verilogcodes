module Moore_1010_ol (
    clk,            // Input CLK
    rst_n,          // Active low reset
    in,             // 1 bit input 
    out             // 1 bit output
    );
    //----------------------------------------- INPUT PORTS ------------------------------------------------------------//

 input clk,rst_n,in;

  //----------------------------------------- OUTPUT PORTS -----------------------------------------------------------//

 output reg out;

  //----------------------------------------- INTERNAL CONSTANTS -----------------------------------------------------//
 
 parameter s0 = 3'h0,
           s1 = 3'h1,
           s2 = 3'h2,
           s3 = 3'h3,
           s4 = 3'h4;

 //----------------------------------------- INTERNAL VARIABLES -----------------------------------------------------//

 reg [1:0]pstate;        //combinational logic
 reg [1:0]nstate;        //sequential logic

  //----------------------------------------- COMBINATIONAL LOGIC ----------------------------------------------------//

 always@(*)
    begin
        nstate = 3'h0;
        case(pstate)
        s0: begin
                if (in==1)
                    nstate = s1;
                else
                    nstate = s0;
            end
        s1: begin
                if (in==0)
                    nstate = s2;
                else
                    nstate = s1;
            end
        s2: begin
                if (in==1)
                    nstate = s3;
                else
                    nstate = s0;
            end
        s3: begin
                if (in==0)
                    nstate = s4;
                else
                    nstate = s1;
            end
        s4: begin
                if (in==1)
                    nstate = s0;
                else
                    nstate = s3;
            end
        default : nstate = s0;
        endcase
    end

     //----------------------------------------- SEQUENTIAL LOGIC -------------------------------------------------------//

    always@(posedge clk)
        begin
            if(!rst_n)
                pstate <= 3'h0;
            else 
                pstate <= nstate;
        end

    //----------------------------------------- OUTPUT LOGIC -----------------------------------------------------------//

    always @(posedge clk ) 
        begin
            if(!rst_n)
                out <=  1'd0;
            else
                begin
                    case(pstate)
                        s0:out <= 1'd0;
                        s1:out <= 1'd0;
                        s2:out <= 1'd0;
                        s3:out <= 1'd0;
                        s4:out <= 1'd1;
                        default : out <= 1'b0;
                    endcase
                end
        end