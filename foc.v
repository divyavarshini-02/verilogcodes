/*module foc(); // writing random values to a file

integer			var,num;
initial 
begin
	var=$fopen("file.txt");//file descriptor
		repeat(7)
		begin
			num=$random;
			$fdisplayb (var, "number is ",num);// file display //writing into the file
		end
		$fclose(var);
	end
	endmodule

	
/*
integer			desc,desc1;
integer 		var;


initial
begin

	desc=$fopen("file.txt");
	
	//avar=$fgetc(desc);
	while(!$feof(desc))
	begin
		desc1=$fopen("file2.txt");
	end
	$fdisplay(desc1,var);

	$fclose(desc);
	$fclose(desc1);
end
endmodule*/

/*
module foc(); // writing random values to a file

integer			var,var1;




initial 
begin
	var=$fopen("file.txt");//file descriptor
	var1=$fopen("file1.txt");

	//while(!$feof(var))
	//begin

		$fwrite(var1,var);

	//end

	$fclose(var);
	$fclose(var1);

end
	endmodule


*/


module foc();
integer fdd;

reg[7:0]mem[4799:0];


initial
	$readmemb("black.bin",mem);
endmodule

/*module handling();///reading a file and storing the contents in a memory register and displaying

integer		var;

reg[7:0]mem[0:6];

initial
	$readmemb("file.txt",mem);

initial
begin
	#10;
	$display("contents of mem after reading the file");
	for(var=0;var<6;var=var+1)$display("%d:%b",var,mem[var]);

end
endmodule
*/

////		writing to a file 	/////
  /*
module handling();  
    reg[8*45:0] store ;  //360
    integer     fd,fdd ;  
    wire [8*45:0] send;
  
    initial begin  
      fd = $fopen("file.bin", "r");  
     fdd = $fopen("file1.txt","w");	

       while (! $feof(fd))
   	 begin  
  
               $fgets(store, fd);  
      
               $display("%0s", store);  
		$fdisplay(fdd,"%0s", store);
		assign send=store;   

      	end  
    $fclose(fd); 
     $fclose(fdd);
   end  
endmodule 
 */
	


///////////////// name /////////////////////
/*
module handling();
parameter width=240,
	height=160;
integer		var,var2;
parameter pixel = width*height; /////240*160 pixel 
integer		fd;
reg  [7:0]	white=8'd255;

initial
fd = $fopen("displayname.bin" ,"w");
	
	
initial
begin

	for(var=0;var<pixel;var=var+1)
	begin
		$fwrite(fd,bi);
	end
	
end

endmodule
*/














