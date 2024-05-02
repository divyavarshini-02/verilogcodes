module file(); // writing random values to a file

integer			var;
reg	[23:0]	num;
reg	[7:0]	address;
initial 
begin
	var=$fopen("memhex.txt");//file descriptor
	/*	repeat(190)
		begin
			num=$random;
			address=address+1;
			$fdisplayb (var, address  ,num);// file display //writing into the file
		end*/
		num=0;
		$fdisplay(var,"DEPTH = 190;");
		$fdisplay(var, "WIDTH=24;");
		$fdisplay(var,"ADDRESS_RADIX= HEX;");
		$fdisplay(var,"DATA_RADIX =HEX;");
		$fdisplay(var,"CONTENT");
		$fdisplay(var,"BEGIN");
	       for(address=0;address<8'd190;address=address+1)
	       begin
		     			
		       	
		    	$fdisplayh(var,address," : ",num);
			num=num+1;
		
		end     	
		$fdisplay(var,"END;");
		$fclose(var);
	end
	endmodule



