
`timescale 1ns/1ps
module  read_engine(

//INPUT PORTS 
//-----------------------------------------------------------------------
//Global signals
//-----------------------------------------------------------------------
mem_clk,                        //Memory clock of frequency 200MHz
reset_n,                        //Active low asynchronous reset
//-----------------------------------------------------------------------
//From Memory
//-----------------------------------------------------------------------
dqs,                           //Memory Data strobe
dq_in,                         //Memory Data bus
//-----------------------------------------------------------------------
//From CSR 
//-----------------------------------------------------------------------
csr_dlp_cyc_cnt,              //DLP cycle count for the CSR initiated DLP read 
no_of_data_bytes,
predrive_en,
dummy_cycle_config,
mem_rd_data_ack,
//-----------------------------------------------------------------------
//From write engine 
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//From Instruction Handler 
//-----------------------------------------------------------------------
ddr_en,                     //Indicates the read instruction is SDR/DDR
bits_enabled,               //Indicates the number of pins to be used for read transfer
start_read,                 //Trigger for the read; asserted when read instruction is executed from instruction handler
csr_trigger,                //Memory status register read is triggered by CSR. So the read data has to be sent to CSR rather than data packer
axi_trigger,                //Memory status register read is triggered by AXI. So the read data has to be sent to AXI
instrn_dlp_en,              //DLP read enabled through instruction
instrn_dlp_pattern,         //DLP pattern for the DLP instruction
rcv_dq_fifo_flush_en,       //Flush dqfifo afer every read
//-----------------------------------------------------------------------
// FROM RCVR_CNTRL
//-----------------------------------------------------------------------
rd_done,
//-----------------------------------------------------------------------
//From RX DATA PACKER
//-----------------------------------------------------------------------
mem_16bit_rdata_ack,
dqs_timeout,
/////////////////////////////////////////////////////////////////////////
//OUTPUT PORTS
/////////////////////////////////////////////////////////////////////////
//-----------------------------------------------------------------------
//To Instruction Handler 
//-----------------------------------------------------------------------
dlp_read_stop,                  //dlp end detected one clock earlier than usual ending of dlp
rcv_dq_fifo_flush_done,
rcv_dqfifo_empty,
dqs_pulse,
csr_read_end,                      //Indicates dqs non toggle err condition
//-----------------------------------------------------------------------
//To CSR 
//-----------------------------------------------------------------------
calib_tap_out,                  //DLP data after passing through dlp check
calib_tap_valid,                 //Valid for the dlp data
mem_rd_valid,
mem_rd_data, 
csr_dqs_non_toggle_err,
axi_dqs_non_toggle_err,
//-----------------------------------------------------------------------
//To write engine
//-----------------------------------------------------------------------
rd_clk_stretch,
//-----------------------------------------------------------------------
//To wrapper 
//-----------------------------------------------------------------------
mem_16bit_rdata,                         //16bit data grouped from dqfifo
mem_16bit_rdata_valid                   //valid for the grouped 16bit data


);

parameter RCV_DQ_FIFO_ADDR_WIDTH = 4;

/////////////////////////////////////////////////////////////////////////
//Port Declartation
/////////////////////////////////////////////////////////////////////////
//Input Declaration
//Global inputs
input          mem_clk;
input          reset_n;
//From wrapper
input          dqs;
input [7:0]    dq_in;
//From CSR
input [2:0]    csr_dlp_cyc_cnt;
input [5:0]    no_of_data_bytes;
input          predrive_en;
input [4:0]    dummy_cycle_config;
input	       mem_rd_data_ack;
//From write engine
//From Instruction Handler
input          ddr_en;
input [1:0]    bits_enabled;
input          start_read;
input          csr_trigger;
input          axi_trigger;
input          instrn_dlp_en;
input [7:0]    instrn_dlp_pattern;
input          rcv_dq_fifo_flush_en;
// FROM RCVR_CNTRL
input          rd_done;
//From RXdata packer
input          mem_16bit_rdata_ack;
input          dqs_timeout;

//Output Declaration
//To Instruction Handler
output        dlp_read_stop;
output        csr_read_end;
output        rcv_dq_fifo_flush_done;
//To CSR
output [7:0]  calib_tap_out;
output        calib_tap_valid;
output        mem_rd_valid;
output [31:0]  mem_rd_data; 
output        csr_dqs_non_toggle_err;
output        axi_dqs_non_toggle_err;
//To Read data packer
output [15:0] mem_16bit_rdata;
output        mem_16bit_rdata_valid;
output        rcv_dqfifo_empty;
output dqs_pulse;
//To write engine
output        rd_clk_stretch;


//Wire Declaration
wire            rcv_dqfifo_rd_en;
wire            rxdata_blk_en;
wire            training_blk_en;
wire            rxblk_rd_en;
wire            training_rd_en;
wire [15:0]     rcv_dqfifo_dout;
wire 		rcv_dqfifo_almost_empty;
wire	        rcv_dqfifo_almost_full;


assign rcv_dqfifo_rd_en = training_blk_en? training_rd_en :rxdata_blk_en ? rxblk_rd_en: 1'b0;
//assign dlp_pattern      = csr_dlp_en ? csr_dlp_pattern : instrn_dlp_en? {8'h0,instrn_dlp_pattern} : 16'h0000;
assign rxblk_ddr_en     = start_read && ddr_en;


rcvif  #(.RCV_DQ_FIFO_ADDR_WIDTH (RCV_DQ_FIFO_ADDR_WIDTH))

rcvif_inst(

//I/Ps'
.mem_clk                     (mem_clk),
.reset_n                     (reset_n),
.start_read                  (start_read),
.dqs                         (dqs),
.dq_in                       (dq_in),
.rcv_dqfifo_rd_en            (rcv_dqfifo_rd_en), 
.rcv_dq_fifo_flush_en        (rcv_dq_fifo_flush_en),
.predrive_en                 (predrive_en),
.dummy_cycle_config         (dummy_cycle_config),
.csr_trigger                  (csr_trigger),
//O/Ps'
.rcv_dqfifo_empty            (rcv_dqfifo_empty), 
.dqs_pulse (dqs_pulse),
.rcv_dqfifo_almost_empty     (rcv_dqfifo_almost_empty), 
.rcv_dqfifo_almost_full_sync (rcv_dqfifo_almost_full),
.rcv_dq_fifo_flush_done      (rcv_dq_fifo_flush_done),
.rcv_dqfifo_dout             (rcv_dqfifo_dout)
);

uspif_training_monitor training_mon_inst(

//I/Ps'
.mem_clk          (mem_clk),
.reset_n          (reset_n),
.start_read       (start_read),
.training_blk_en  (training_blk_en),
.bits_enabled     (bits_enabled),
.instrn_dlp_en    (instrn_dlp_en),
.dlp_pattern      (instrn_dlp_pattern),
.dlp_cyc_cnt      (csr_dlp_cyc_cnt),
.rcv_dqfifo_empty (rcv_dqfifo_empty), 
.rcv_dqfifo_dout  (rcv_dqfifo_dout),
//O/Ps'
.rcv_dqfifo_rd_en (training_rd_en), 
.calib_tap_out    (calib_tap_out),
.calib_tap_valid  (calib_tap_valid),
.dlp_read_stop    (dlp_read_stop)
);


uspif_rxdata_blk  uspif_rxdata_blk_inst
(
.mem_clk                      (mem_clk),
.reset_n                      (reset_n),
.rxdata_blk_en                (rxdata_blk_en),
.ddr_en                       (rxblk_ddr_en),
.bits_enabled                 (bits_enabled),
.start_read                   (start_read),
.csr_trigger                  (csr_trigger),
.axi_trigger                  (axi_trigger),
.rcv_dqfifo_empty             (rcv_dqfifo_empty), 
.rcv_dqfifo_almost_empty      (rcv_dqfifo_almost_empty), 
.rcv_dqfifo_almost_full       (rcv_dqfifo_almost_full), 
.rcv_dqfifo_dout              (rcv_dqfifo_dout),
.rd_done                      (rd_done),
.mem_16bit_rdata_ack                   (mem_16bit_rdata_ack),
.dqs_timeout                  (dqs_timeout),
.instrn_dlp_en                (instrn_dlp_en),
.calib_tap_valid              (calib_tap_valid),
.rcv_dq_fifo_flush_done       (rcv_dq_fifo_flush_done),
.no_of_data_bytes	      (no_of_data_bytes),
//O/Ps'
.rd_clk_stretch               (rd_clk_stretch),
.mem_rd_valid      (mem_rd_valid),
.mem_rd_data       (mem_rd_data),
.mem_rd_data_ack (mem_rd_data_ack ),
.csr_dqs_non_toggle_err       (csr_dqs_non_toggle_err),
.axi_dqs_non_toggle_err       (axi_dqs_non_toggle_err),
.rcv_dqfifo_rd_en_final             (rxblk_rd_en),
.csr_read_end                     (csr_read_end),
.mem_16bit_rdata                   (mem_16bit_rdata),
.mem_16bit_rdata_valid                  (mem_16bit_rdata_valid)
);


rcvr_fsm  rcvr_fsm_inst(

.mem_clk           (mem_clk),
.reset_n           (reset_n),
.ddr_en            (rxblk_ddr_en),
.instrn_dlp_en     (instrn_dlp_en),
.read_instrn       (start_read), 
.dlp_read_stop     (dlp_read_stop),
.rd_done           (rd_done),
.csr_read_end          (csr_read_end),

.rxdata_blk_en     (rxdata_blk_en),
.training_blk_en   (training_blk_en)

);


endmodule
