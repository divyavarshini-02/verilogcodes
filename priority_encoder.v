module priority_encoder(y,m);
  output reg[2:0]y;
  input [7:0]m;
 always@(m)
   begin
	  casex(m)
	  //  8'b00000000 : y <= 3'bxxx;
	    8'b00000001 : y = 3'b000;
		 8'b0000001X : y = 3'b001;
		 8'b000001XX : y = 3'b010;
		 8'b00001XXX : y = 3'b011;
		 8'b0001XXXX : y = 3'b100;
		 8'b001XXXXX : y = 3'b101;
		 8'b01XXXXXX : y = 3'b110;
		 8'b1XXXXXXX : y = 3'b111;
	  endcase
  end
endmodule