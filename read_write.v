module read_write(); // writing random values to a file
  integer i,j;

  initial 
	begin
      i=$fopen("read_bin.txt");//file descriptor
      j=$fopen("read_bin1.txt");
	  $fwrite(j,i);
	  $fclose(i);
	  $fclose(j);
	end
endmodule
//while(!$feof(var))
//begin

    

//end




/*module read_write(); // writing random values to a file
  integer i,j;

  initial 
	begin
      i = $fopen("read_bin.txt","w"); //file descriptor
        repeat(7)
          begin
            j=$random;
            $fdisplay (i, " number is ", j); // file display //writing into the file
          end
          $fclose(i);
    end
endmodule*/



/*module read_write (); // read and store 
  reg [3:0] mem [15:0];
  integer i;
  
  initial
    begin
    
        $readmemb("read_bin.txt",mem);
      
        for(i=0; i<16; i=i+1)
          begin
            $display("%d:%b",i, mem[i]);
          end
	//   	#300
	// $stop;
    end

endmodule*/

/*Things to remember:
1. save the txt file with the code in the same location.
2. don't mention the path totally
3. don't give delays*/