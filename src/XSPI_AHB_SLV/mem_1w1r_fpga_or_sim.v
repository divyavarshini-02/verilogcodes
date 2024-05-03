// Copyright Mobiveil Inc 2012
// All Rights Reserved



module mem_1w1r_fpga_or_sim (
    wclk,
    waddr,
    wen,
    wdata,

    rclk,
    raddr,
    ren,
    rdata
);


parameter PTR_WIDTH = 3;
parameter DATA_WIDTH = 39;
parameter DEPTH      = 7;

    input wclk;
    input [PTR_WIDTH -1:0] waddr;
    input wen;
    input [DATA_WIDTH-1:0] wdata;

    input rclk;
    input [PTR_WIDTH-1:0]  raddr;
    input ren;
    output[DATA_WIDTH-1:0] rdata;

    reg   [DATA_WIDTH-1:0] rdata; 
    reg   [DATA_WIDTH-1:0]   mem [DEPTH:0];

    always @ (posedge wclk)
    begin
        if (wen) mem[waddr] <= wdata;
    end

    always @ (posedge rclk)
    begin
        if (ren) rdata <= mem[raddr];
    end

endmodule
