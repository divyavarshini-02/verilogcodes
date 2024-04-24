module   parking_lot (
            input    user_in,
            input    clk,
            input  rst,
            input    start,
            output    user_out,
            output    full,
            output    empty

);

reg        inc;
reg        dec;
reg    [2:0]    slot_inc;
reg    [2:0]    slot_dec;
reg    [2:0]    slot;
reg    [2:0] in;
reg    [2:0] out;
reg    [3:0]    ns=4'b0;

assign    full=(slot_inc==3'b111)?1'b1:1'b0;
assign    empty=(slot_dec==3'b111)?1'b1:1'b0;

always@(posedge clk)
begin
  if(rst)
  begin
    slot_inc<=0;
    slot_dec<=0;
  end
  else if(inc)
    slot_inc<=slot+1;
  else if(dec)
    slot_dec<=slot-1; 
end

always    @    (posedge    clk)
begin
case(ns)
4'd0:
    begin
            if(!full)
              begin
                    in<={user_in,in[1:0]};
                    dec<=0;
                    inc<=0;
                    ns<=4'd0;
              end
            else
            if(in[0]==user_in)
                      ns<=4'b1;
    end
4'd1:
    begin
                   slot[slot_inc]<=user_in;
                   dec=1'b1;
                     ns<=4'd2;

    end

endcase
end
endmodule
