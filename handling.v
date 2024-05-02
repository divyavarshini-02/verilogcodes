module handling();

integer 			fd,r;
integer			var;
reg[39:0]data[80:0][159:0];


reg	[3799:0]	data_1;

//initial
//	fd=$fopen("clr.bin","r");



initial
begin
/*		for(var=0;var<100;var=var+1)
		begin
			$fgets(data[var],fd);
		
		end*/
       $readmemb("name.bin",data);	 
      //r=$fread(data,fd);
	/*	while(!$feof(fd))
		begin
			r=$fscanf(fd,"%h",data);
		end*/


end

/*
integer				fd,var;
reg[37999:0] black_data;

initial
	fd=$fopen("black.bin","r");

initial
begin
	$fscanf(fd,"%b",black_data);
	
end
*/



endmodule
