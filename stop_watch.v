module stop_watch(input clk,
                  input rst,start,
					
						output [6:0]sec_seg_1,
						output [6:0]sec_seg_2,
						output [7:0]min_seg_1,
						output [6:0]min_seg_2);
reg [4:0] sec_count_1;
reg [4:0] sec_count_2;
reg [4:0] min_count_1;
reg [4:0] min_count_2;
wire clk_1hz;
always @(posedge clk_1hz or negedge rst)
begin
  if(!rst)
    begin

        sec_count_1<=4'd0;
        sec_count_2<=4'd0;
        min_count_1<=4'd0;
        min_count_2<=4'd0;
    end
	 

	else if(start)
		   begin
			  if(sec_count_1==4'd9)
			     begin
				     sec_count_1<=4'd0;
					    if(sec_count_2==4'd5)
			             begin
				             sec_count_2<=4'd0;
					          if(min_count_1==4'd9)
			                    begin
				                   min_count_1<=4'd0;
					              if(min_count_2==4'd5)
			                       begin
				                       min_count_2<=4'd0;
											  end
									  else
									       
									        min_count_2<=min_count_2+4'd1;
											end
											
								 else
								       min_count_1<=min_count_1+4'd1;
									 end
						 else
						       sec_count_2<=sec_count_2+4'd1;
							 end
			  else
			         sec_count_1<=sec_count_1+4'd1;
					end
			 end
   bcd_7seg m1(.in(sec_count_1),.out(sec_seg_1));
	bcd_7seg m2(.in(sec_count_2),.out(sec_seg_2));
	bcd_7seg1 m3(.in(min_count_1),.out(min_seg_1));
	bcd_7seg m4(.in(min_count_2),.out(min_seg_2));
	clk_1 m5(.clk_50(clk),.rst(rst),.clk_1hz(clk_1hz));
endmodule 
					