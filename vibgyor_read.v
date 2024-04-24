module vibgyor_read ();

//integer i;

reg [7:0]mem[52199:0];

integer fd;

initial
  fd = $fopen("vibgyor.bin" ,"r");


initial
	begin
		////for(i=0; i<52199; i=i+1)
			$readmemb("vibgyor.bin",mem,0,52199);
	end		 

endmodule