module rom(single_in,single_out,mem_addr,clk1,clk2,reset);

   output reg[1:0]single_out;
    input [1:0]single_in;
    input clk1,clk2,reset;

    input wire[1:0]mem_addr;
    reg [1:0]rom[3:0];

       always@(posedge clk1)

          begin
             if(reset)
                begin
                    single_out<=2'd0;
                 end
             else
                begin
                  case(single_in)
                     2'b00: rom[0]<=2'b00;
                      2'b01: rom[1]<=2'b01;
                      2'b10: rom[2]<=2'b10;
                      2'b11: rom[3]<=2'b11;
                     endcase
                  end
             end


            always@(posedge clk2)

          begin
            
                  single_out<=rom[mem_addr];
        
            end
endmodule
