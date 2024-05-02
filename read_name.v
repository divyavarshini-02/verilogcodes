module read_name();

reg[795:0]data[92:0];


integer		fd,var;

initial
begin
	$readmemb("name_display.bin",data);
end

initial
begin
	fd=$fopen("read_name.bin","w");

	for(var=0;var<93;var=var+2)
	begin
		$fdisplayb(fd,data[var]);
	end
	$fclose(fd);
end
endmodule



