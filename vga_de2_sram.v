/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Module Name 		: 	vga.v																											   //
// Designer Name	: 	Divyavarshini. VK - (GET) RTL & ASIC DESIGN TEAM														           //
// Description 		:                                                                                                                      //
//                                                                                                                                         //
//                                                      VGA-VIDEO GRAPHIC ARRAY                                                            //
//                              *THINGS TO REMEMBER FOR DESIGNING VGA IN UART SPEC WHICH DE0 BOARD*                                        //
//                     1# THE DE0 BOARD WORKS IN 25 MHZ.                                                                                   //
//                     2# THE REFRESH RATE OR THE DATA WITH WHICH THE DISPLAY DEPENDS IS 60Hz, WHICH MEANS 60 FRAMES PER SECOND.           //
//                     3# THE TOTAL NUMBER OF PIXELS IS 800X525 BUT THE ACTIVE REGION IS 640X480.                                          //
//                     4# THE VSYNC SIGNAL IS CALLED FRAME AND THE HSYNC SIGNAL IS CALLED ROW OF DATA.                                     //
//                     5# THE TOTAL NUMBER OF PIXELS IS 800 X 525 = 420000 PIXELS.                                                         //
//                     6# IF WE TAKE ONE PIXEL PER CLOCK CYCLE, THEN IT WOULD TAKE 420000/25000000 = 0.0168 SECONDS (i.e) 16.8ms           //
//                                                                                                                                         //
//                                                                                                                                         //
//                                                                                                                                         //
//                     THE HORIZONTAL TIMING SPECIFICATION WORKS WITH FOLLOWING μs AS:                                                     //
//                                            #1 HSYNC - VGA CLK X HSYNC IN μs - 25MHz X 3.8μS = 95 (TAKEN 96)                             //
//                                            #2 BACKPORCH - VGA CLK X BACKPORCH IN μs - 25MHz X 1.9μS = 47.5 (48 Approx)                  //
//                                            #3 DISPLAY INTERVAL - VGA CLK X DISPLAY INTERVAL IN μs - 25MHz X 25.4μS = 635 (640 Approx)   //
//                                            #4 FRONTPORCH - VGA CLK X FRONTPORCH IN μs - 25MHz X 0.6μS = 15 (TAKEN 16)                   //
//                                            #5 SO TOTAL HORIZONTAL PIXELS ARE 96 + 48 + 640 + 16 = 800                                   //
//                                                                                                                                         //
//                     THE VERTICAL TIMING SPECIFICATION WORKS WITH FOLLOWING μs AS:                                                       //
//                                            #1 VSYNC - VGA CLK X VSYNC IN μs - 25MHz X 0.08μS = 2                                        //
//                                            #2 BACKPORCH - VGA CLK X BACKPORCH IN μs - 25MHz X 1.32μS = 33                               //
//                                            #3 DISPLAY INTERVAL - VGA CLK X DISPLAY INTERVAL IN μs - 25MHz X 19.2μS = 480                //
//                                            #4 FRONTPORCH - VGA CLK X FRONTPORCH IN μs - 25MHz X 0.4μS = 10                              //
//                                            #5 SO TOTAL HORIZONTAL PIXELS ARE 2 + 33 + 480 + 10 = 525                                    //    
//                                                                                                                                         //
//                                                                                                                                         // 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module vga (hsync, vsync, clk_50, rst, red, green, blue);

						parameter overall_column = 12'd800, overall_row = 12'd525; 

						input clk_50, rst;

						output reg [29:0]rgb;
						
						output hsync, vsync; 

						output				clk,rst;
				
						output			ce,oe,we,lb,ub;
				
						output	[17:0]			address;
				
						inout	[15:0]			data_in;
				
						input	[15:0]			data_out;

 ///////////////////////////////////////////////////ASSIGNING THE VALUE FOR HSYNC AND VSYNC//////////////////////////////////////////////////
	
	reg [11:0] hsync_counter = 12'd0;
	reg [11:0] vsync_counter = 12'd0;

	assign hsync = (hsync_counter<=95)? 1'd0: 1'd1;
	assign vsync = (vsync_counter<=1)? 1'd0: 1'd1;

 /////////////////////////////////////////////////////CHANGING THE CLOCK TO 25 Mhz///////////////////////////////////////////////////////////

	reg clk_out_25 = 1'd0;

	always@(posedge clk_50)
		begin
			if(rst)
				begin
					clk_out_25 <= 1'd0;
				end
			else
				begin
					clk_out_25 <= ~clk_out_25;
				end
		end

/////////////////////////////////////////////////CHANGING THE CLOCK TO 12/5/////////////////////////////////////////////////////////////////
	reg clk_out_12 = 1'd0;

	always@(posedge clk_out_12)
		begin
			if(rst)
				begin
					clk_out_12 <= 1'd0;
				end
			else
				begin
					clk_out_12 <= ~clk_out_12;
				end
		end
 ////////////////////////////////////////////////////HSYNC AND VSYNC COUNTER/////////////////////////////////////////////////////////////////

 always@(posedge clk_out_25)
	begin
		if(rst)
			begin
				hsync_counter <= 12'd0;
				vsync_counter <= 12'd0;
			end
		else
			begin
					if (hsync_counter == 12'd800)
						begin
							hsync_counter <= 12'd0;
								if(vsync_counter == 12'd525)
									begin
										vsync_counter <= 12'd0;
									end
								else
									begin
										vsync_counter <= vsync_counter + 1'b1;
									end
						end
					else
						begin
							hsync_counter <= hsync_counter + 1'b1;
						end
			end
	end

 /////////////////////////////////////////////////////////RGB DISPLAY/////////////////////////////////////////////////////////////////////
	//reg addr_en=1'b0; 
  always@(posedge clk_out_12)
		begin
			if(rst)
				begin
					red <= 10'd0;
					green <= 10'd0;
					blue <= 10'd0;      
				end 
			else
				begin
					if((hsync_counter>=12'd144 && hsync_counter<=12'd784) || (vsync_counter>=12'd35 && vsync_counter<=12'd515)) //grey
							begin
									if(!ce && !oe && we)
										begin
											rgb= {2'b00,datain[7:0]};
											rgb= {2'b00,datain[15:8]};
											address=address+1;
											
										end
									else
										begin
											address <= address;
										end
							end
					else
						begin
							red <= 10'd0;
							green <= 10'd0;
							blue <= 10'd0;  							
						end
				end
		end

endmodule
////////////////////////////////////////////////////////////////SRAM CODE///////////////////////////////////////////////////////////////////////////////////////

module sram(clk,rst,ce,oe,we,lb,ub,address,data_in,data_out);
				input				clk,rst;
				input				ce,oe,we,lb,ub;
				input	[17:0]			address;
				inout	[15:0]			data_in;
				output	[15:0]			data_out;

//				reg[15:0]ram[255:0]
 ////////////////////////////////////////////////////////////WRITE IN SRAM///////////////////////////////////////////////////////////////////////////////////
		
		
		// always@(posedge clk)
		// 	begin
		// 		if(rst)
		// 			begin
		// 				data<=16'd0;	
		// 			end
		// 		else if(!ce && !oe && !we && lb && ub)
		// 		begin
		// 			sram[address]<=data_in;
		// 			address<=address+1;
		// 		end
		// 		else
		// 			begin
		// 				address <= address;
		// 			end
		// end

 ////////////////////////////////////////////////////////SRAM IN READ////////////////////////////////////////////////////////////////////////////////////
		
		
		always@(posedge clk)
			begin
				if(rst)
					begin
						data<=16'd0;	
					end
				else if(!ce && !oe)
					begin
						data_out<=sram[address]
						address<=address+1;
					end
				else
					begin
						address <= address;
					end
			end

endmodule