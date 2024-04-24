module black();

  parameter width=240, height=160;
  parameter black_pixel = (width * height)/8; /////240*160 pixel 

  integer		i;
  integer		fd;       //file descriptor
  reg       [7:0]           	bi=8'd0;     // bit_index with which the data is written

  initial
    fd = $fopen("black.bin" ,"w");
	
	
  initial
    begin
      for(i=0; i<black_pixel; i=i+1)
	    begin
		  $fdisplayb(fd,bi);
	    end
    end

endmodule


