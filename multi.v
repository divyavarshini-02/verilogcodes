module multi();
parameter width=720,
	height=580;
integer		var,fd;
integer		var_yellow,var_white,var_black,var_green,var_blue;
parameter pixel = 72; /////720*580 =417600 each time writes 5760...so 417600/5760
reg  [7:0]	black=8'd0;
reg  [7:0]	yellow=8'd252;
reg  [7:0]	white=8'd255;
reg  [7:0]	green=8'd8;
reg  [7:0]	blue=8'd1;
initial
fd = $fopen("multiclr.bin" ,"w");
	
	
initial
begin
	
       for(var=0;var<pixel;var=var+1)
       begin
	       for(var_white=0;var_white<144;var_white=var_white+1)
       		begin
			$fdisplayb(fd,white);
		end
		for(var_black=0;var_black<144;var_black=var_black+1)
		begin
			$fdisplayb(fd,black);
		end
		for(var_green=0;var_green<144;var_green=var_green+1)
		begin
			$fdisplayb(fd,green);
		end
		for(var_blue=0;var_blue<144;var_blue=var_blue+1)
		begin
			$fdisplayb(fd,blue);
		end
		for(var_yellow=0;var_yellow<144;var_yellow=var_yellow+1)
		begin
			$fdisplayb(fd,yellow);
		end

	end

	$fclose(fd);
	
end
endmodule





























	/*for(var=0;var<pixel;var=var+1)
	begin
		$fwrite(fd,yellow,yellow,yellow,yellow,yellow,yellow);
		$fwrite(fd,white,white,white,white,white,white);
		$fwrite(fd,green,green,green,green,green,green);
		$fwrite(fd,black,black,black,black,black,black);
		$fwrite(fd,blue,blue,blue,blue,blue,blue);
	end*/



