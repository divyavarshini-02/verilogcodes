module vibgyor();

parameter [9:0] width = 10'd720;
parameter [9:0] height = 10'd580;

integer fd;
integer i;
integer j = width * height;

reg [7:0] violet_pixel = 8'd227 ;           //101
reg [7:0] blue_pixel = 8'd3;               //001
reg [7:0] green_pixel = 8'd28;            //010
reg [7:0] yellow_pixel = 8'd252;         //110
reg [7:0] white_pixel = 8'd255;         //111
reg [7:0] red_pixel = 8'd224;          //100

initial
begin
	fd = $fopen("vibgyor.bin" ,"w");
end

initial
  begin
  for(i=0; i<73; i=i+1)
	 	begin
			 for(j=0; j<120; j=j+1)
			 	$fdisplayb (fd,violet_pixel); 
		 end
	end

initial
	begin
		for(j=0; j<120; j=j+1)
			 	$fdisplayb (fd,blue_pixel); 
	end		 

initial
	begin
		for(j=0; j<120; j=j+1)
			 	$fdisplayb (fd,green_pixel); 
	end	

initial
	begin
		for(j=0; j<120; j=j+1)
			 	$fdisplayb (fd,yellow_pixel); 
	end	

initial
	begin
		for(j=0; j<120; j=j+1)
			 	$fdisplayb (fd,white_pixel); 
	end	

initial
	begin
		for(j=0; j<120; j=j+1)
			 	$fdisplayb (fd,red_pixel); 
	end	

initial	$finish ;

endmodule









