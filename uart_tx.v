/*-------------------------------------------------------------------------------------------------------------------
Design Name : UART - Universal Asynchronous Reciever Transmitter
File name : uart_tx.v
Designer Name: VK. Divyavarshini & S.Santhosh
Design Description :
        1) It's a simple duplex communication protocol.
        2) The clock is replaces by Baud Rate (No clock)
        3)  
-------------------------------------------------------------------------------------------------------------------*/



module uart_tx ();

//----------------------------------------- INTERNAL CONSTANTS -----------------------------------------------------//

parameter               DATAWIDTH = 8       ;
parameter               SIZE = 2            ;
parameter               COUNT = 8           ;

parameter               idle = 2'h00        ,
                        start = 2'h01       ,
                        transfer = 2'h10    ,
                        stop = 2'h11        ;

//----------------------------------------- INPUT PORTS ------------------------------------------------------------//

input [DATAWIDTH-1:0]   data_in             ;               //transmitter input
input                   baud_clk            ;               //baud clock 
input                   reset_n             ;               //active high reset

//----------------------------------------- OUTPUT PORTS -----------------------------------------------------------//

output                  data_out            ;               //output in transmitter
output                  tx_signal           ;               //signal of transmitter

//----------------------------------------- INPUT DATA TYPES -------------------------------------------------------//

wire [DATAWIDTH-1:0]    data_in             ;
wire                    baud_clk            ;
wire                    reset_n             ;

//----------------------------------------- OUTPUT DATA TYPES ------------------------------------------------------//

reg                     data_out            ;
reg                     tx_signal           ;

//----------------------------------------- INTERNAL VARIABLES -----------------------------------------------------//

reg [SIZE-1:0]          p_state             ;
reg [SIZE-1:0]          n_state             ;
reg                     srt                 ;                //start signal
reg                     stp                 ;                //stop signal
reg [COUNT-1:0]         counter             ;

//----------------------------------------- SEQUENTIAL LOGIC -------------------------------------------------------//

always@( posedge clk ) 
    begin
        if(reset_n)
            begin
                p_state     <=      3'd0;
                counter     <=      8'd0;
                srt         <=      1'd1;
                stp         <=      1'd0;
                data_out    <=      1'd1;
                tx_signal   <=      1'd1;
            end
        else                                                                                                       
            begin
                p_state <=  n_state;    
            end
    end

//----------------------------------------- COMBINATIONAL LOGIC ----------------------------------------------------//

always@( * )
    begin
        n_state = 2'h00;
        case(p_state)

            idle:       begin
                            srt         =       1'd0;
                            data_out    =       1'd1;
                            tx_signal   =       1'd1;
                            n_state     =       start;
                        end     

            start:      begin
                            if(srt = 1'd0)
                                begin
                                    n_state     =   transfer;  
                                end
                            else 
                                begin
                                    n_state     =   idle; 
                                end
                            
                        end 

            transfer:   begin
                            n_state     =       stop;
                        end
                        
            stop:       begin
                            n_state     =       .
                            
                            
                            idle;
                        end 
    end
//----------------------------------------- OUTPUT LOGIC -----------------------------------------------------------//

input 
output
endmodule