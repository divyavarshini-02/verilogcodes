/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                  *SRAM - SYNCHRONOUS RANDOM ACCESS MEMORY*                                              //
//                               THE PIN DESCRIPTION OF THE SRAM IN CYCLONE V BOARD ARE AS FOLLOW:                                         //
//	                                         			 #1 18 BIT ADDRESSS INPUTS (A) 																													 //
//                                                 #2 16 BIT INOUT DATA (I/O)																					   									 //
//                                                 #3 CE CHIP ENABLE (I/P)		 																					      						 //
//                                                 #4 OE OUTPUT ENABLE (I/P)                                                               //
//                                                 #5 WE WRITE ENABLE (I/P)                                                                //
//                                                 #6 LB LOWER-BYTE CONTROL (0-7 I/O)                                                      //
//                                                 #7 UB UPPER-BYTE CONTROL (8-15 I/O)                                                     //
// ----------------------------------------------------------------------------------------------------------------------------------------//
//                                                      *VGA-VIDEO GRAPHIC ARRAY*                                                          //
//                              *THINGS TO REMEMBER FOR DESIGNING VGA IN UART SPEC WHICH DE0 BOARD*                                        //
//                     1# THE DE0 BOARD WORKS IN 25 MHZ.                                                                                   //
//                     2# THE REFRESH RATE OR THE DATA WITH WHICH THE DISPLAY DEPENDS IS 60Hz, WHICH MEANS 60 FRAMES PER SECOND.           //
//                     3# THE TOTAL NUMBER OF PIXELS IS 800X525 BUT THE ACTIVE REGION IS 640X480.                                          //
//                     4# THE VSYNC SIGNAL IS CALLED FRAME AND THE HSYNC SIGNAL IS CALLED ROW OF DATA.                                     //
//                     5# THE TOTAL NUMBER OF PIXELS IS 800 X 525 = 420000 PIXELS.                                                         //
//                     6# IF WE TAKE ONE PIXEL PER CLOCK CYCLE, THEN IT WOULD TAKE 420000/25000000 = 0.0168 SECONDS (i.e) 16.8ms           //
//                                                                                                                                         //
// ----------------------------------------------------------------------------------------------------------------------------------------//
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


module vga_sram_de2 (vga_hsync,
							vga_vsync, 
							vga_sync, 
							vga_blank, 
							vga_clk, 
							fpga_clk, 
							fpga_rst_n, 
							vga_rgb, 
							sram_address, 
							data_in_out, 
							sram_ce, 
							sram_oe, 
							sram_we, 
							sram_lb, 
							sram_ub);

						input fpga_clk, fpga_rst_n;

						output reg [29:0]vga_rgb;
						
						output  vga_hsync, vga_vsync;
						
						output  vga_sync, vga_blank; 

						output reg sram_ce, sram_oe, sram_we, sram_lb, sram_ub;
				
						output [17:0] sram_address;

						output reg vga_clk = 1'b0;
				
						inout	[15:0] data_in_out;
						
///////////////////////////////////////////////////ASSIGNING THE VALUE FOR HSYNC AND VSYNC//////////////////////////////////////////////////
	
	reg [11:0] vga_hsync_counter = 12'd0;
	reg [11:0] vga_vsync_counter = 12'd0;

	assign vga_hsync = (vga_hsync_counter<=95)? 1'd0: 1'd1;
	assign vga_vsync = (vga_vsync_counter<=1)? 1'd0: 1'd1;
				
 /////////////////////////////////////////////////////CHANGING THE MAIN CLOCK TO 25 Mhz///////////////////////////////////////////////////////////

	always@(posedge fpga_clk)
		begin
			if(fpga_rst_n)
				begin
					vga_clk <= 1'd0;
				end
			else
				begin
					vga_clk <= ~vga_clk;
				end
		end

 //////////////////////////////////////////////////////CHANGING THE VGA CLOCK TO 12.5 Mhz////////////////////////////////////////////////////////

	reg vga_clk_2 = 1'd0;

	always@(posedge vga_clk)
		begin
			if(fpga_rst_n)
				begin
					vga_clk_2 <= 1'd0;
				end
			else
				begin
					vga_clk_2 <= ~vga_clk_2;
				end
		end
 ////////////////////////////////////////////////////HSYNC AND VSYNC COUNTER/////////////////////////////////////////////////////////////////

 always@(posedge vga_clk)
	begin
		if(fpga_rst_n)
			begin
				vga_hsync_counter <= 12'd0;
				vga_vsync_counter <= 12'd0;
			end
		else
			begin
					if (vga_hsync_counter == 12'd800)
						begin
							vga_hsync_counter <= 12'd0;
								if(vga_vsync_counter == 12'd525)
									begin
										vga_vsync_counter <= 12'd0;
									end
								else
									begin
										vga_vsync_counter <= vga_vsync_counter + 1'b1;
									end
						end
					else
						begin
							vga_hsync_counter <= vga_hsync_counter + 1'b1;
						end
			end
	end


 ///////////////////////////////////////////////////// ASSIGNING VALUE FOR CONSTANT ////////////////////////////////////////////
		
		reg [17:0] sram_address_reg;
		
		assign vga_blank = vga_hsync & vga_vsync;

		assign vga_sync = 1'b0;

		//assign sram_ce = 1'b0, sram_oe = 1'b0,  sram_lb = 1'b0, sram_ub = 1'b0, sram_we = 1'b1;
		
		assign sram_address = sram_address_reg;

 //////////////////////////////////////////////////////// GRAYSCALE DISPLAY ///////////////////////////////////////////////////////////////////////

	reg count = 1'd0;
	reg addr_en;
	reg [1:0] state = 2'd0;
	
		always@(posedge vga_clk_2)
			begin
				if(fpga_rst_n)
					begin
						sram_address_reg <= 18'd0;
						vga_rgb <= 30'd0;
						state <= 2'd0;
					end
				else
					begin
						case(state)
							2'd0: begin
										if(vga_vsync_counter>=12'd35 && vga_vsync_counter<=12'd515)
											begin
												state <= 2'd1;
											end
										else
											begin
												vga_rgb <= 30'd0;
												state <= 2'd0;
											end
									end
							2'd1: begin
										if(vga_hsync_counter>=12'd144 && vga_hsync_counter<=12'd784)
											begin
												addr_en <= 1'd1;
												state <= 2'd2;
											end
										else
											begin
												vga_rgb <= 30'd0;
												state <= 2'd1;
											end
									end
							2'd2: begin
										if(addr_en == 1'd1)
											begin
												sram_ce <= 1'b0;
												sram_oe <= 1'b0;
												sram_lb <= 1'b0;
												sram_ub <= 1'b0;
												sram_we <= 1'b1;
												sram_address_reg <= sram_address_reg + 18'd1;
												state <= 2'd3;
											end
										else
											begin
												sram_ce <= 1'b0;
												sram_oe <= 1'b0;
												sram_lb <= 1'b0;
												sram_ub <= 1'b0;
												sram_we <= 1'b0;
												state <= 2'd2;
											end
									end
							2'd3: begin
											if(sram_we == 1'd1)
												begin
													if(sram_address_reg <= 18'd153599)
														begin
															case(count)
																1'd0: vga_rgb <= {{data_in_out[15:8],2'b00},{data_in_out[15:8],2'b00},{data_in_out[15:8],2'b00}};
																1'd1: vga_rgb <= {{data_in_out[7:0],2'b00},{data_in_out[7:0],2'b00},{data_in_out[7:0],2'b00}};
															endcase
															sram_address_reg <= sram_address_reg + 18'd1;
															state <= 2'd3;
														end
													else
														begin
															sram_address_reg <= 18'd0;
															state <= 2'd2;
														end
												end
											else
												begin
													vga_rgb <= 30'd0;
													sram_address_reg <= 18'd0;
													state <= 2'd0;
												end
										end
							default : state <= 2'd0;
						endcase
					end
			end


endmodule