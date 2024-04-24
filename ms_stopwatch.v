module ms_stopwatch(ms_output,sec_output,min_output,clk,rst);
		input clk,rst;
		output reg [5:0]ms_output,sec_output,min_output;
		reg [5:0]counter=6'd0;
		reg [5:0]sec_counter=6'd0;
		reg [5:0]min_counter=6'd0;
		reg [6:0] seg_ms1,seg_ms2;
		reg [6:0] seg_sec1,seg_sec2;
		reg [6:0] seg_min1,seg_min2;


///////////////////////////////////////////////////////////////////////////////
		
		
		always@(posedge clk)
			begin
				if(rst)
					begin
						ms_output<=6'd0;
					end
				else
					begin
						counter<=counter+1;
							begin
								if(counter>=6'd59)
									begin
										counter<=6'd0;
									end
								else 
									begin
										counter<=counter+1;
									end
							end
					end
				assign ms_output=counter;
			end




///////////////////////////////////////////////////////////////////////////////	
		
		
		always@(posedge counter)
			begin
				if(rst)
					begin
						sec_output<=6'd0;
					end
				else
					begin
						sec_counter<=sec_counter+1;
							begin
								if(sec_counter>=6'd59)
									begin
										sec_counter<=6'd0;
									end
								else 
									begin
										sec_counter<=sec_counter+1;
									end
							end
					end
				assign sec_output=sec_counter;
			end


///////////////////////////////////////////////////////////////////////////////


		always@(posedge sec_counter)
					begin
						if(rst)
							begin
								min_output<=6'd0;
							end
						else
							begin
								min_counter<=min_counter+1;
									begin
										if(min_counter>=6'd59)
											begin
												min_counter<=6'd0;
											end
										else 
											begin
												min_counter<=min_counter+1;
											end
									end
							end
						assign min_output=min_counter;
					end


endmodule
///////////////////////////////////////////////////////////////////////////////


// always@(sec_counter)

// 			begin
// 				case (sec_counter)
// 					6'd0:seg_sec1=7'b1111110;
// 					6'd1:seg_sec1=7'b0110000;
// 					6'd2:seg_sec1=7'b1101101;
// 					6'd3:seg_sec1=7'b1111001;
// 					6'd4:seg_sec1=7'b0110011;
// 					6'd5:seg_sec1=7'b1011011;
// 					6'd6:seg_sec1=7'b1011111;
// 					6'd7:seg_sec1=7'b1110000;
// 					6'd8:seg_sec1=7'b1111111;
// 					6'd9:seg_sec1=7'b1111011;
// 					6'd10:	begin
// 							seg_sec1=7'b0110000;
// 							seg_sec2=7'b1111110;
// 							end 
// 					6'd11:	begin
// 							seg_sec1=7'b0110000;
// 							seg_sec2=7'b0110000;
// 							end 
// 					6'd12:begin
// 							seg_sec1=7'b0110000;
// 							seg_sec2=7'b1101101;
// 							end 
// 					6'd13:begin
// 							seg_sec1=7'b0110000;
// 							seg_sec2=7'b1111001;
// 							end 
// 					6'd14:begin
// 							seg_sec1=7'b0110000;
// 							seg_sec2=7'b0110011;
// 							end 
// 					6'd15:begin
// 							seg_sec1=7'b0110000;
// 							seg_sec2=7'b1011011;
// 							end 
// 					6'd16:begin
// 							seg_sec1=7'b0110000;
// 							seg_sec2=7'b1011111;
// 							end
// 					6'd17:begin
// 							seg_sec1=7'b0110000;
// 							seg_sec2=7'b1110000;
// 							end
// 					6'd18:begin
// 							seg_sec1=7'b0110000;
// 							seg_sec2=7'b1111111;
// 							end 
// 					6'd19:begin
// 							seg_sec1=7'b0110000;
// 							seg_sec2=7'b1111011;
// 							end 
// 					6'd20:begin
// 							seg_sec1=7'b1101101;
// 							seg_sec2=7'b1111110;
// 							end
// 					6'd21:begin
// 							seg_sec1=7'b1101101;
// 							seg_sec2=7'b0110000;
// 							end
// 					6'd22:begin
// 							seg_sec1=7'b1101101;
// 							seg_sec2=7'b1101101;
// 							end 
// 					6'd23:begin
// 							seg_sec1=7'b1101101;
// 							seg_sec2=7'b1111001;
// 							end
// 					6'd24:begin
// 							seg_sec1=7'b1101101;
// 							seg_sec2=7'b0110011;
// 							end
// 					6'd25:begin
// 							seg_sec1=7'b1101101;
// 							seg_sec2=7'b1011011;
// 							end 
// 					6'd26:begin
// 							seg_sec1=7'b1101101;
// 							seg_sec2=7'b1011111;
// 							end 
// 					6'd27:begin
// 							seg_sec1=7'b1101101;
// 							seg_sec2=7'b1110000;
// 							end 
// 					6'd28:begin
// 							seg_sec1=7'b1101101;
// 							seg_sec2=7'b1111111;
// 							end 
// 					6'd29:begin
// 							seg_sec1=7'b1101101;
// 							seg_sec2=7'b1111011;
// 							end
// 					6'd30:begin
// 							seg_sec1=7'b1111001;
// 							seg_sec2=7'b1111110;
// 							end
// 					6'd31:begin
// 							seg_sec1=7'b1111001;
// 							seg_sec2=7'b0110000;
// 							end 
// 					6'd32:begin
// 							seg_sec1=7'b1111001;
// 							seg_sec2=7'b1101101;
// 							end 
// 					6'd33:begin
// 							seg_sec1=7'b1111001;
// 							seg_sec2=7'b1111001;
// 							end 
// 					6'd34:begin
// 							seg_sec1=7'b1111001;
// 							seg_sec2=7'b0110011;
// 							end
// 					6'd35:begin
// 							seg_sec1=7'b1111001;
// 							seg_sec2=7'b1011011;
// 							end
// 					6'd36:begin
// 							seg_sec1=7'b1111001;
// 							seg_sec2=7'b1011111;
// 							end
// 					6'd37:begin
// 							seg_sec1=7'b1111001;
// 							seg_sec2=7'b1110000;
// 							end 
// 					6'd38:begin
// 							seg_sec1=7'b1111001;
// 							seg_sec2=7'b1111111;
// 							end
// 					6'd39:begin
// 							seg_sec1=7'b1111001;
// 							seg_sec2=7'b1111011;
// 							end 
// 					6'd40:begin
// 							seg_sec1=7'b0110011;
// 							seg_sec2=7'b1111110;
// 							end
// 					6'd41:begin
// 							seg_sec1=7'b0110011;
// 							seg_sec2=7'b0110000;
// 							end 
// 					6'd42:begin
// 							seg_sec1=7'b0110011;
// 							seg_sec2=7'b1101101;
// 							end 
// 					6'd43:begin
// 							seg_sec1=7'b0110011;
// 							seg_sec2=7'b1111001;
// 							end
// 					6'd44:begin
// 							seg_sec1=7'b0110011;
// 							seg_sec2=7'b0110011;
// 							end
// 					6'd45:begin
// 							seg_sec1=7'b0110011;
// 							seg_sec2=7'b1011011;
// 							end
// 					6'd46:begin
// 							seg_sec1=7'b0110011;
// 							seg_sec2=7'b1011111;
// 							end
// 					6'd47:begin
// 							seg_sec1=7'b0110011;
// 							seg_sec2=7'b1110000;
// 							end 
// 					6'd48:begin
// 							seg_sec1=7'b0110011;
// 							seg_sec2=7'b1111111;
// 							end
// 					6'd49:begin
// 							seg_sec1=7'b0110011;
// 							seg_sec2=7'b1111011;
// 							end 
// 					6'd50:begin
// 							seg_sec1=7'b1011011;
// 							seg_sec2=7'b1111110;
// 							end 
// 					6'd51:begin
// 							seg_sec1=7'b1011011;
// 							seg_sec2=7'b0110000;
// 							end 
// 					6'd52:begin
// 							seg_sec1=7'b1011011;
// 							seg_sec2=7'b1101101;
// 							end 
// 					6'd53:begin
// 							seg_sec1=7'b1011011;
// 							seg_sec2=7'b1111001;
// 							end 
// 					6'd54:begin
// 							seg_sec1=7'b1011011;
// 							seg_sec2=7'b0110011;
// 							end 
// 					6'd55:begin
// 							seg_sec1=7'b1011011;
// 							seg_sec2=7'b1011011;
// 							end 
// 					6'd56:begin
// 							seg_sec1=7'b1011011;
// 							seg_sec2=7'b1011111;
// 							end 
// 					6'd57:begin
// 							seg_sec1=7'b1011011;
// 							seg_sec2=7'b1110000;
// 							end 
// 					6'd58:begin
// 							seg_sec1=7'b1011011;
// 							seg_sec2=7'b1111111;
// 							end 
// 					6'd59:begin
// 							seg_sec1=7'b1011011;
// 							seg_sec2=7'b1111011;
// 							end
// 				endcase
// 			end


/////////////////////////////////////////////////////////////////////////////////


		// always@(min_counter)

		// 			begin
		// 				case (min_counter)
		// 					6'd0:seg_min1=7'b1111110;
		// 					6'd1:seg_min1=7'b0110000;
		// 					6'd2:seg_min1=7'b1101101;
		// 					6'd3:seg_min1=7'b1111001;
		// 					6'd4:seg_min1=7'b0110011;
		// 					6'd5:seg_min1=7'b1011011;
		// 					6'd6:seg_min1=7'b1011111;
		// 					6'd7:seg_min1=7'b1110000;
		// 					6'd8:seg_min1=7'b1111111;
		// 					6'd9:seg_min1=7'b1111011;
		// 					6'd10:	begin
		// 							seg_min1=7'b0110000;
		// 							seg_min2=7'b1111110;
		// 							end 
		// 					6'd11:	begin
		// 							seg_min1=7'b0110000;
		// 							seg_min2=7'b0110000;
		// 							end 
		// 					6'd12:begin
		// 							seg_min1=7'b0110000;
		// 							seg_min2=7'b1101101;
		// 							end 
		// 					6'd13:begin
		// 							seg_min1=7'b0110000;
		// 							seg_min2=7'b1111001;
		// 							end 
		// 					6'd14:begin
		// 							seg_min1=7'b0110000;
		// 							seg_min2=7'b0110011;
		// 							end 
		// 					6'd15:begin
		// 							seg_min1=7'b0110000;
		// 							seg_min2=7'b1011011;
		// 							end 
		// 					6'd16:begin
		// 							seg_min1=7'b0110000;
		// 							seg_min2=7'b1011111;
		// 							end
		// 					6'd17:begin
		// 							seg_min1=7'b0110000;
		// 							seg_min2=7'b1110000;
		// 							end
		// 					6'd18:begin
		// 							seg_min1=7'b0110000;
		// 							seg_min2=7'b1111111;
		// 							end 
		// 					6'd19:begin
		// 							seg_min1=7'b0110000;
		// 							seg_min2=7'b1111011;
		// 							end 
		// 					6'd20:begin
		// 							seg_min1=7'b1101101;
		// 							seg_min2=7'b1111110;
		// 							end
		// 					6'd21:begin
		// 							seg_min1=7'b1101101;
		// 							seg_min2=7'b0110000;
		// 							end
		// 					6'd22:begin
		// 							seg_min1=7'b1101101;
		// 							seg_min2=7'b1101101;
		// 							end 
		// 					6'd23:begin
		// 							seg_min1=7'b1101101;
		// 							seg_min2=7'b1111001;
		// 							end
		// 					6'd24:begin
		// 							seg_min1=7'b1101101;
		// 							seg_min2=7'b0110011;
		// 							end
		// 					6'd25:begin
		// 							seg_min1=7'b1101101;
		// 							seg_min2=7'b1011011;
		// 							end 
		// 					6'd26:begin
		// 							seg_min1=7'b1101101;
		// 							seg_min2=7'b1011111;
		// 							end 
		// 					6'd27:begin
		// 							seg_min1=7'b1101101;
		// 							seg_min2=7'b1110000;
		// 							end 
		// 					6'd28:begin
		// 							seg_min1=7'b1101101;
		// 							seg_min2=7'b1111111;
		// 							end 
		// 					6'd29:begin
		// 							seg_min1=7'b1101101;
		// 							seg_min2=7'b1111011;
		// 							end
		// 					6'd30:begin
		// 							seg_min1=7'b1111001;
		// 							seg_min2=7'b1111110;
		// 							end
		// 					6'd31:begin
		// 							seg_min1=7'b1111001;
		// 							seg_min2=7'b0110000;
		// 							end 
		// 					6'd32:begin
		// 							seg_min1=7'b1111001;
		// 							seg_min2=7'b1101101;
		// 							end 
		// 					6'd33:begin
		// 							seg_min1=7'b1111001;
		// 							seg_min2=7'b1111001;
		// 							end 
		// 					6'd34:begin
		// 							seg_min1=7'b1111001;
		// 							seg_min2=7'b0110011;
		// 							end
		// 					6'd35:begin
		// 							seg_min1=7'b1111001;
		// 							seg_min2=7'b1011011;
		// 							end
		// 					6'd36:begin
		// 							seg_min1=7'b1111001;
		// 							seg_min2=7'b1011111;
		// 							end
		// 					6'd37:begin
		// 							seg_min1=7'b1111001;
		// 							seg_min2=7'b1110000;
		// 							end 
		// 					6'd38:begin
		// 							seg_min1=7'b1111001;
		// 							seg_min2=7'b1111111;
		// 							end
		// 					6'd39:begin
		// 							seg_min1=7'b1111001;
		// 							seg_min2=7'b1111011;
		// 							end 
		// 					6'd40:begin
		// 							seg_min1=7'b0110011;
		// 							seg_min2=7'b1111110;
		// 							end
		// 					6'd41:begin
		// 							seg_min1=7'b0110011;
		// 							seg_min2=7'b0110000;
		// 							end 
		// 					6'd42:begin
		// 							seg_min1=7'b0110011;
		// 							seg_min2=7'b1101101;
		// 							end 
		// 					6'd43:begin
		// 							seg_min1=7'b0110011;
		// 							seg_min2=7'b1111001;
		// 							end
		// 					6'd44:begin
		// 							seg_min1=7'b0110011;
		// 							seg_min2=7'b0110011;
		// 							end
		// 					6'd45:begin
		// 							seg_min1=7'b0110011;
		// 							seg_min2=7'b1011011;
		// 							end
		// 					6'd46:begin
		// 							seg_min1=7'b0110011;
		// 							seg_min2=7'b1011111;
		// 							end
		// 					6'd47:begin
		// 							seg_min1=7'b0110011;
		// 							seg_min2=7'b1110000;
		// 							end 
		// 					6'd48:begin
		// 							seg_min1=7'b0110011;
		// 							seg_min2=7'b1111111;
		// 							end
		// 					6'd49:begin
		// 							seg_min1=7'b0110011;
		// 							seg_min2=7'b1111011;
		// 							end 
		// 					6'd50:begin
		// 							seg_min1=7'b1011011;
		// 							seg_min2=7'b1111110;
		// 							end 
		// 					6'd51:begin
		// 							seg_min1=7'b1011011;
		// 							seg_min2=7'b0110000;
		// 							end 
		// 					6'd52:begin
		// 							seg_min1=7'b1011011;
		// 							seg_min2=7'b1101101;
		// 							end 
		// 					6'd53:begin
		// 							seg_min1=7'b1011011;
		// 							seg_min2=7'b1111001;
		// 							end 
		// 					6'd54:begin
		// 							seg_min1=7'b1011011;
		// 							seg_min2=7'b0110011;
		// 							end 
		// 					6'd55:begin
		// 							seg_min1=7'b1011011;
		// 							seg_min2=7'b1011011;
		// 							end 
		// 					6'd56:begin
		// 							seg_min1=7'b1011011;
		// 							seg_min2=7'b1011111;
		// 							end 
		// 					6'd57:begin
		// 							seg_min1=7'b1011011;
		// 							seg_min2=7'b1110000;
		// 							end 
		// 					6'd58:begin
		// 							seg_min1=7'b1011011;
		// 							seg_min2=7'b1111111;
		// 							end 
		// 					6'd59:begin
		// 							seg_min1=7'b1011011;
		// 							seg_min2=7'b1111011;
		// 							end
		// 				endcase
		// 			end


		///////////////////////////////////////////////////////////////////////////////		
		
		
		/*always@(counter)
			begin
				case (counter)
					6'd0:seg_ms1=7'b1111110;
					6'd1:seg_ms1=7'b0110000;
					6'd2:seg_ms1=7'b1101101;
					6'd3:seg_ms1=7'b1111001;
					6'd4:seg_ms1=7'b0110011;
					6'd5:seg_ms1=7'b1011011;
					6'd6:seg_ms1=7'b1011111;
					6'd7:seg_ms1=7'b1110000;
					6'd8:seg_ms1=7'b1111111;
					6'd9:seg_ms1=7'b1111011;
					6'd10:	begin
							seg_ms1=7'b0110000;
							seg_ms2=7'b1111110;
							end 
					6'd11:	begin
							seg_ms1=7'b0110000;
							seg_ms2=7'b0110000;
							end 
					6'd12:begin
							seg_ms1=7'b0110000;
							seg_ms2=7'b1101101;
							end 
					6'd13:begin
							seg_ms1=7'b0110000;
							seg_ms2=7'b1111001;
							end 
					6'd14:begin
							seg_ms1=7'b0110000;
							seg_ms2=7'b0110011;
							end 
					6'd15:begin
							seg_ms1=7'b0110000;
							seg_ms2=7'b1011011;
							end 
					6'd16:begin
							seg_ms1=7'b0110000;
							seg_ms2=7'b1011111;
							end
					6'd17:begin
							seg_ms1=7'b0110000;
							seg_ms2=7'b1110000;
							end
					6'd18:begin
							seg_ms1=7'b0110000;
							seg_ms2=7'b1111111;
							end 
					6'd19:begin
							seg_ms1=7'b0110000;
							seg_ms2=7'b1111011;
							end 
					6'd20:begin
							seg_ms1=7'b1101101;
							seg_ms2=7'b1111110;
							end
					6'd21:begin
							seg_ms1=7'b1101101;
							seg_ms2=7'b0110000;
							end
					6'd22:begin
							seg_ms1=7'b1101101;
							seg_ms2=7'b1101101;
							end 
					6'd23:begin
							seg_ms1=7'b1101101;
							seg_ms2=7'b1111001;
							end
					6'd24:begin
							seg_ms1=7'b1101101;
							seg_ms2=7'b0110011;
							end
					6'd25:begin
							seg_ms1=7'b1101101;
							seg_ms2=7'b1011011;
							end 
					6'd26:begin
							seg_ms1=7'b1101101;
							seg_ms2=7'b1011111;
							end 
					6'd27:begin
							seg_ms1=7'b1101101;
							seg_ms2=7'b1110000;
							end 
					6'd28:begin
							seg_ms1=7'b1101101;
							seg_ms2=7'b1111111;
							end 
					6'd29:begin
							seg_ms1=7'b1101101;
							seg_ms2=7'b1111011;
							end
					6'd30:begin
							seg_ms1=7'b1111001;
							seg_ms2=7'b1111110;
							end
					6'd31:begin
							seg_ms1=7'b1111001;
							seg_ms2=7'b0110000;
							end 
					6'd32:begin
							seg_ms1=7'b1111001;
							seg_ms2=7'b1101101;
							end 
					6'd33:begin
							seg_ms1=7'b1111001;
							seg_ms2=7'b1111001;
							end 
					6'd34:begin
							seg_ms1=7'b1111001;
							seg_ms2=7'b0110011;
							end
					6'd35:begin
							seg_ms1=7'b1111001;
							seg_ms2=7'b1011011;
							end
					6'd36:begin
							seg_ms1=7'b1111001;
							seg_ms2=7'b1011111;
							end
					6'd37:begin
							seg_ms1=7'b1111001;
							seg_ms2=7'b1110000;
							end 
					6'd38:begin
							seg_ms1=7'b1111001;
							seg_ms2=7'b1111111;
							end
					6'd39:begin
							seg_ms1=7'b1111001;
							seg_ms2=7'b1111011;
							end 
					6'd40:begin
							seg_ms1=7'b0110011;
							seg_ms2=7'b1111110;
							end
					6'd41:begin
							seg_ms1=7'b0110011;
							seg_ms2=7'b0110000;
							end 
					6'd42:begin
							seg_ms1=7'b0110011;
							seg_ms2=7'b1101101;
							end 
					6'd43:begin
							seg_ms1=7'b0110011;
							seg_ms2=7'b1111001;
							end
					6'd44:begin
							seg_ms1=7'b0110011;
							seg_ms2=7'b0110011;
							end
					6'd45:begin
							seg_ms1=7'b0110011;
							seg_ms2=7'b1011011;
							end
					6'd46:begin
							seg_ms1=7'b0110011;
							seg_ms2=7'b1011111;
							end
					6'd47:begin
							seg_ms1=7'b0110011;
							seg_ms2=7'b1110000;
							end 
					6'd48:begin
							seg_ms1=7'b0110011;
							seg_ms2=7'b1111111;
							end
					6'd49:begin
							seg_ms1=7'b0110011;
							seg_ms2=7'b1111011;
							end 
					6'd50:begin
							seg_ms1=7'b1011011;
							seg_ms2=7'b1111110;
							end 
					6'd51:begin
							seg_ms1=7'b1011011;
							seg_ms2=7'b0110000;
							end 
					6'd52:begin
							seg_ms1=7'b1011011;
							seg_ms2=7'b1101101;
							end 
					6'd53:begin
							seg_ms1=7'b1011011;
							seg_ms2=7'b1111001;
							end 
					6'd54:begin
							seg_ms1=7'b1011011;
							seg_ms2=7'b0110011;
							end 
					6'd55:begin
							seg_ms1=7'b1011011;
							seg_ms2=7'b1011011;
							end 
					6'd56:begin
							seg_ms1=7'b1011011;
							seg_ms2=7'b1011111;
							end 
					6'd57:begin
							seg_ms1=7'b1011011;
							seg_ms2=7'b1110000;
							end 
					6'd58:begin
							seg_ms1=7'b1011011;
							seg_ms2=7'b1111111;
							end 
					6'd59:begin
							seg_ms1=7'b1011011;
							seg_ms2=7'b1111011;
							end
				endcase
			end*/
