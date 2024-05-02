module read_pattern();
reg[39:0]data[15:0];

initial
begin
	$readmemb("name.bin",data);
end
endmodule
