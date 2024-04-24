module seqencedet (out,clk,rst,in);
  input clk,rst,in;
  output reg out;
  parameter s0=2'b00,s1=2'b01,s2=2'b10,s3=2'b11;
  reg [1:0] state,nstate;
  always @ (posedge clk)
  begin
    if (rst)
      state = s0;
    else
      state = nstate;
 end
 always @ (state or nstate or in)
    begin
      case (state)
        s0: if(in)
        begin
            nstate = s1;
            out = 1'b0;
       end
        else
          begin
            nstate = s0;
            out = 1'b0;
          end
          s1: if(in)
        begin
            nstate = s1;
            out = 1'b0;
       end
        else
          begin
            nstate = s2;
            out = 1'b0;
          end
           s2: if(in)
        begin
            nstate = s3;
            out = 1'b0;
       end
        else
          begin
            nstate = s0;
            out = 1'b0;
          end
           s3: if(in)
        begin
            nstate = s1;
            out = 1'b1;
       end
        else
          begin
            nstate = s0;
            out = 1'b1;
          end
    endcase 
  end
  endmodule
       
        
