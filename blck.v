 
module blck();
parameter width=240,
	height=160;
integer		var;
parameter pixel = 4800; /////240*160 =38400  divide by 8 because eachtime writes 8bits
integer		fd;
reg  [7:0]	bi=8'd0;

initial
fd = $fopen("black.bin" ,"w");
	
	
initial
begin

	for(var=0;var<pixel;var=var+1)
	begin
		$fdisplayb(fd,bi);
	end
	$fclose(fd);
end
	
endmodule



















