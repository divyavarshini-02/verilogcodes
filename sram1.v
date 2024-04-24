module sram1(we, //write enable
            ce, //chip enable
            oe, //output enable
            lb, //lower bit
            ub, //upper bit
            clk,
            rst,
            data_in, //this acts as input data when u want write the data in the cache memory
            data_out); //this acts as output data when u want to read the data in the cache memory 

    input we, ce, lb, ub, oe;
    input clk, rst;
    reg [15:0]data = 16'hffff;  // the actual data which is to be tken from the main memory
    input [15:0]data_in;
    output reg [15:0]data_out;
    reg [7:0] address=8'haaaa;
    reg [7:0] counter;
    reg [17:0]sram[262143:0];
    wire [15:0] data_1;
    assign data_1= we?(data_out):(16'hz);
    assign data_1=data;
    always@(posedge clk)
    begin
        if(rst)
            begin
                sram[address]<=16'h0;
                data_out<=16'h0;
                counter<=address;
            end
        else if (we==1'bx && ce==1 && oe==1'bx && lb==1'bx && ub==1'bx)
            begin 
                data<= 16'hz;
                data_out <= 16'hz;
            end
        else if (we==1 && ce==0 && oe==1 && lb==1'bx && ub==1'bx)
            begin 
                data<= 16'hz;
                data_out <= 16'hz;
            end
        else if (we==1'bx && ce==0 && oe==1'bx && lb==1 && ub==1)
            begin 
                data<= 16'hz;
                data_out <= 16'hz;
            end
        else if (we==1 && ce==0 && oe==0 && lb==0 && ub==1)
            begin 
                data<= 16'hz;
                data_out <= 16'hz;
            end
        else if (we==1 && ce==0 && oe==0 && lb==1 && ub==0)
            begin 
                data<= 16'hz;
                data_out <= 16'hz;
            end
        else if (we==1 && ce==0 && oe==0 && lb==0 && ub==0)
            begin 
                data_out<=sram[counter];
                counter<=counter+1;
            end
        else if (we==0 && ce==0 && oe==1'bx && lb==0 && ub==1)
            begin 
                sram[address]<={data_in[7:0],8'hz};
            end
        else if (we==0 && ce==0 && oe==1'bx && lb==0 && ub==1)
            begin 
                sram[address]<={8'hz,data_in[15:8]};
            end
        else
            begin
                sram[counter]<=data;
                counter<=counter+1;
            end
    end
endmodule



