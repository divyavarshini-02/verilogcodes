// Copyright Mobiveil Inc 2012
// All Rights Reserved



module mem_1w1r_asic4 (
    wclk,
    wrst_n,
    waddr,
    wen,
    wdata,

    rclk,
    rrst_n,
    raddr,
    ren,
    rdata
);


parameter PTR_WIDTH = 3;
parameter DATA_WIDTH = 39;
parameter DEPTH      = 7;

    input wclk;
    input wrst_n;
    input [PTR_WIDTH -1:0] waddr;
    input wen;
    input [DATA_WIDTH-1:0] wdata;

    input rclk;
    input rrst_n;
    input [PTR_WIDTH-1:0]  raddr;
    input ren;
    output[DATA_WIDTH-1:0] rdata;



endmodule
