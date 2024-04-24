module black_read ();

reg [7:0]mem[4799:0];
//integer fd;

// initial
//    fd = $fopen("black.bin" ,"r");

//integer i;

initial
begin
$readmemb("black.bin",mem);
end
endmodule