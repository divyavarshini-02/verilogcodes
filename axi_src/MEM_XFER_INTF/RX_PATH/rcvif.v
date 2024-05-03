`timescale 1ns/1ps
module rcvif (
//Global input
mem_clk,
reset_n,
//From instruction handler
start_read,
rcv_dq_fifo_flush_en,
//From memory
dq_in,
dqs,
//From rxdata_blk
rcv_dqfifo_rd_en,
predrive_en,
dummy_cycle_config,
csr_trigger,
//To DQS non-toggle checker
rcv_dqfifo_empty, 
dqs_pulse,

rcv_dqfifo_almost_empty, 
rcv_dqfifo_almost_full_sync,
rcv_dq_fifo_flush_done,
rcv_dqfifo_dout
);

parameter RCV_DQ_FIFO_ADDR_WIDTH = 4;

input        mem_clk;
input        reset_n;
input        start_read;

input [7:0]   dq_in;
input         dqs;
input         rcv_dqfifo_rd_en;
input         predrive_en;
input [4:0]   dummy_cycle_config;
input         csr_trigger;
input         rcv_dq_fifo_flush_en;
output        rcv_dqfifo_empty;
output        dqs_pulse;
output        rcv_dqfifo_almost_empty;
output        rcv_dqfifo_almost_full_sync;
output        rcv_dq_fifo_flush_done;
output [15:0] rcv_dqfifo_dout;       


reg rcv_dq_fifo_flush_en_reg, rcv_dq_fifo_flush_done;

reg        next_test_in_progress,test_in_progress ;
reg        start_read_d;
reg        wait_wr_en;
wire       rcv_dqfifo_wr_en;
wire       start_read_redge;
reg [1:0]  dqs_cntr;
reg [4:0]  dummy_cycle_cntr;

//assign rcv_dqfifo_wr_en   = start_train ||(test_in_progress && !rcv_dqfifo_empty);
assign rcv_dqfifo_wr_en   = ((csr_trigger & !(|dummy_cycle_cntr)) | (!csr_trigger)) ? (predrive_en ? (start_read & !wait_wr_en) : start_read_d) : 1'b0;
assign start_read_redge = start_read & !start_read_d;

always @ (posedge dqs or negedge reset_n)
begin
if(~reset_n) dqs_cntr <= 2'b0;
else dqs_cntr <= wait_wr_en ? dqs_cntr + 1'b1 : 1'b0;
end

always @ (posedge mem_clk or negedge reset_n)
begin
if(~reset_n)
begin
   rcv_dq_fifo_flush_done  <= 1'b0;
   rcv_dq_fifo_flush_en_reg <= 1'b0;
   wait_wr_en <= 1'b0;
   start_read_d <= 1'b0;
   dummy_cycle_cntr <= 5'd0;
end
else
begin
  rcv_dq_fifo_flush_done   <= rcv_dq_fifo_flush_done ? 1'b0 : rcv_dq_fifo_flush_en_reg ? (rcv_dqfifo_empty ? 1'b1 : 1'b0) : 1'b0; 
  rcv_dq_fifo_flush_en_reg <= rcv_dq_fifo_flush_done ? 1'b0 : rcv_dq_fifo_flush_en ? 1'b1 : rcv_dq_fifo_flush_en_reg;
  wait_wr_en <= dqs_cntr[1] ? 1'b0 : start_read_redge ? 1'b1 : wait_wr_en;
   start_read_d <= start_read;
   dummy_cycle_cntr <= (start_read_redge & |dummy_cycle_config) ? dummy_cycle_config : (|dummy_cycle_cntr) ? dummy_cycle_cntr-1'b1 : dummy_cycle_cntr;
end
end

read_dq_input_capture
   # (
      .FIFO_ADDR_WIDTH (RCV_DQ_FIFO_ADDR_WIDTH),
      .FIFO_DATA_WIDTH (16)     
     )
read_dq_input_capture
  (
   // Outputs
   .dout                (rcv_dqfifo_dout), 
   .fifo_empty          (rcv_dqfifo_empty),
   .fifo_full           (),     
   .fifo_almost_full    (rcv_dqfifo_almost_full),
   .fifo_almost_full_early (),
   .fifo_almost_empty   (rcv_dqfifo_almost_empty),
   .fifo_non_empty      (), 
   .rd_en_final         (),
   .rcv_dq_fifo_data_avail (),
   .dqs_pulse           (dqs_pulse),
                         
   // Inputs             
   .rst_n               (reset_n), 
   .mem_clk             (mem_clk),
   .rd_en               (rcv_dqfifo_rd_en),
   .flush               (rcv_dq_fifo_flush_en),
   .dqs                 (dqs),
 //  .wr_en               (1'b1), // since rcv_dqfifo_wr_en is not aligned to DQS_INV clock but aligned to mem_clk
   .wr_en               (rcv_dqfifo_wr_en),
   .dq_in               (dq_in)
   );


double_flop_sync 
   #(
   .DATA_WIDTH (1)
    )
   RCV_DQ_FIFO_ALMOST_FULL_SYNCHRONIZER
   (
   . clk   (mem_clk),
   . rst_n (reset_n),
   . async_in (rcv_dqfifo_almost_full),
   . sync_out (rcv_dqfifo_almost_full_sync)
   );

endmodule
