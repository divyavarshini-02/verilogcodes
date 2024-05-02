/*------------------------------------------------------------------------------------------------------------
Design Name : Debouncer circuit for car parking with respective to car tyre
File Name : Debouncer_n
--------------------------------------------------------------------------------------------------------------*/

module debouncer_n (
    in      , //input signal for the debouncer
    rst_n   , // Active low, synchronous reset
    clk     , //clock
    db_out    //output which says whether it belongs to vehicle or not
    ) ;
//--------------------------------- INPUT PORTS ------------------------------------------------------------------//

input in, rst_n, clk ;

//--------------------------------- OUTPUT PORT -----------------------------------------------------------------//

output db_out ;

//--------------------------------- INPUT DATA TYPES ------------------------------------------------------------//

wire in, rst_n, clk ;

//--------------------------------- OUTPUT DATA TYPES -----------------------------------------------------------//

reg db_out ;

//--------------------------------- INTERNAL CONSTANTS ----------------------------------------------------------//

parameter size = 2 ;
parameter ff_time_cnt = 4 ;

//--------------------------------- INTERNAL VARIABLES ----------------------------------------------------------//

reg [size-1 : 0] dff ;
reg [ff_time_cnt-1 : 0] q_timing ;
reg [ff_time_cnt-1 : 0] counter = 0 ;
wire q_reset, q_add ;

//--------------------------------- CONTINOUS ASSIGNMENT OUTPUTS ------------------------------------------------//

assign q_reset = dff[0]^dff[size-1] ;
assign q_add = ~ ( q_timing[ff_time_cnt-1] ) ;

//----------------------------------- CODE STARTS HERE ----------------------------------------------------------//

always@(posedge clk)
    begin
		if(rst_n)
			begin
		    	dff[0] <= 1'b0;
				dff[1] <= 1'b0;
				counter <= 4'd2;
			end
		else
			begin
				dff[0] <= in;
				dff[1] <= dff[0];
				counter <= counter + 1;
					if ({counter < 4'd2,counter > 4'd10}) // the range is from 2 to 10 from cycle tyre range to car tyre range 
						counter <= 4'd2;
					else
						counter <= counter + 1;
			end
	end


    
endmodule