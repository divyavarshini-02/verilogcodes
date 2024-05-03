`timescale 1ns/1ps


module memory_interface_controller
(
  //Global inputs
  mem_clk,     
  reset_n,
              
  //Input from Main controller
  axi_start_mem_xfer,
  addr_mem_xfer,
  rw_len_mem_xfer, //9/10/11 bits according to axi data bus32bit/64bit/126 
  xfer_mem_error,
  xfer_wr_rd,
  xfer_axi_len,            
  xfer_btype,
  xfer_bsize,
  cont_rd_req,
  cont_wr_req,
  auto_initiate_seq,

  csr_start_mem_xfer,
  no_of_data_bytes,
  no_of_xfer,

  wait_subseq_pg_wr,

  seq_reg_0,
  seq_reg_1,
  seq_reg_2,
  seq_reg_3,
  sequence_change,
  dual_seq_mode_reg,
  //Ouptut to Main Controller
  axi_start_mem_xfer_ack,
  csr_start_mem_xfer_ack,
  csr_mem_xfer_bsy,
  subseq_pg_wr,
  deassert_cs,
  rd_done,
  dual_seq_mode_ack,
  //Input from CSR
  dummy_cycle_config,
  dummy_cyc_HiZ,
  dummy_cyc_drive,
  csr_dlp_cyc_cnt,
  cs_hold,
  cs_setup,
  cs_high,
  jhr_en,   
  predrive_en,   
  dqs_non_tgl_to,
  page_incr_en,
  mem_page_size,
  hyperflash_en,
  wr_rd_data_1,			
  wr_rd_data_2,			

  mem_rd_data_ack,

  //Output to CSR
  enter_jump_on_cs,
  calib_tap_out,
  calib_tap_valid,
  mem_rd_data,
  mem_rd_valid,
  mem_illegal_instrn,
  illegal_strobe,
  axi_dqs_non_toggle_err,
  csr_dqs_non_toggle_err,

  //Input from AXI4_SLV_CNTRL write interface
  slv_mem_wdata_valid,
  slv_mem_wstrb,
  slv_mem_wlast,
  slv_mem_wdata,                      
  //Output to AXI4_SLV_CNTRL write interface
  slv_mem_wdata_ack,
  slv_mem_wdata_err,

  //Input from AXI4_SLV_CNTRL read interface
  slv_mem_rdata_ack,
  //Output to AXI4_SLV_CNTRL read interface
  slv_mem_rdata_valid,
  slv_mem_rdata,
  slv_mem_rlast,
  slv_mem_rresp,

  //Input from Memory
  dqs,
  dq_in,
  //Output to Memory
  cs_n,
  dq_out,
  dq_oe,
 
  //Output to wrapper
  sclk_en

);

//////////////////////////////////////////////////////////
//Parameter declaration
//////////////////////////////////////////////////////////
parameter MEM_AXI_DATA_WIDTH     = 32;
parameter MEM_AXI_ADDR_WIDTH     = 32;
parameter RCV_DQ_FIFO_ADDR_WIDTH = 4; 
localparam XFER_LEN_WIDTH        = MEM_AXI_DATA_WIDTH == 64 ? 10 :
                                   MEM_AXI_DATA_WIDTH == 128 ? 11 : 9;

//////////////////////////////////////////////////////////
//Port Declaration
//////////////////////////////////////////////////////////
//Global input
input                             mem_clk;
input                             reset_n;

//Input from Main controller
input                             axi_start_mem_xfer;
input [MEM_AXI_ADDR_WIDTH -1:0]   addr_mem_xfer;
input [4:0]       rw_len_mem_xfer; //used only during wrap writes
input                             xfer_mem_error;
input                             xfer_wr_rd;
input  [7:0]                      xfer_axi_len;            
input  [1:0]                      xfer_btype;
input  [2:0]                      xfer_bsize;
input                             csr_start_mem_xfer;
input [31:0]                      seq_reg_0;
input [31:0]                      seq_reg_1;
input [31:0]                      seq_reg_2;
input [31:0]                      seq_reg_3;
input                             cont_rd_req;
input                             cont_wr_req;
input                             sequence_change;
input                             dual_seq_mode_reg;
input                             auto_initiate_seq;
//Ouptut to Main Controller
output                            axi_start_mem_xfer_ack; // from ack resolver
output                            csr_start_mem_xfer_ack;
output                            csr_mem_xfer_bsy;
output                            enter_jump_on_cs;
output				  rd_done;
output				  dual_seq_mode_ack;
output				  subseq_pg_wr;
output deassert_cs;
 //Input from CSR
input [4:0]                       dummy_cycle_config;
input [7:0]                       dummy_cyc_HiZ;
input [7:0]                       dummy_cyc_drive;
input [2:0]                       csr_dlp_cyc_cnt;
input [1:0]                       cs_hold;
input [1:0]                       cs_setup;
input [4:0]                       cs_high;
input                             jhr_en;
input                             predrive_en;
input [4:0]                       dqs_non_tgl_to;
input  				  page_incr_en;
  input [3:0] mem_page_size;
input				  hyperflash_en;
input [31:0] 			  wr_rd_data_1;			
input [31:0] 			  wr_rd_data_2;			
input [5:0] 			  no_of_data_bytes;
input [1:0] 			  no_of_xfer;
input				  mem_rd_data_ack;

input  wait_subseq_pg_wr;

//Output to CSR
output [7:0]                      calib_tap_out;
output                            calib_tap_valid;
output [31:0]                     mem_rd_data;
output                            mem_rd_valid;
output                            mem_illegal_instrn;
output                            illegal_strobe;
output                            csr_dqs_non_toggle_err;
output                            axi_dqs_non_toggle_err;

//Input from AXI4_SLV_CNTRL write interface
input                             slv_mem_wdata_valid;
input [3:0]                       slv_mem_wstrb;
input                             slv_mem_wlast;
input [31:0]                      slv_mem_wdata;
//Output to AXI4_SLV_CNTRL write interface
output                            slv_mem_wdata_ack;
output [1:0]                      slv_mem_wdata_err;

//Input from AXI4_SLV_CNTRL read interface
input                             slv_mem_rdata_ack;
//Output to AXI4_SLV_CNTRL read interface
output                            slv_mem_rdata_valid;
output [MEM_AXI_DATA_WIDTH-1:0]       slv_mem_rdata;
output                            slv_mem_rlast;
output [1:0]                      slv_mem_rresp;

//Input from Memory
input                             dqs;
input [7:0]                       dq_in;
//Output to Memory
output                            cs_n;
output [15:0]                     dq_out;
output [15:0]                     dq_oe;    

//Output to wrapper
output                            sclk_en;

/////////////////////////////////////////////////////////////////////////////////////////////////
//Internal wire declaration
/////////////////////////////////////////////////////////////////////////////////////////////////
wire          cs_n;
wire          data_ack;
wire [1:0]    no_of_pins;
wire [6:0]    valid_operand_bits;
wire [47:0]   operand; 
wire          write_enable;
wire          start_read;
wire [1:0]    bits_enabled;
wire [7:0]    instrn_dlp_pattern;
wire          rd_progress;
wire          dlp_read_stop;
wire          ddr_en;
wire          txfr_en;
wire          dummy_end;
wire          onecyc_en_out;   
wire          twocyc_en_out;   
wire          multicyc_en_out; 
wire          stop_instrn;
wire          rd_done;
wire          dual_seq_mode_ack;
wire          csr_trigger;
wire          axi_trigger;
wire	      csr_read_end;
wire 	      rcv_dq_fifo_flush_done;
wire 	      rd_clk_stretch;

/////////////////////////////////////////////////////////////////////////////////////////////////
//Module instances
/////////////////////////////////////////////////////////////////////////////////////////////////

//INSTRUCTION HANDLER - handles the instruction programmed in sequence
//register and direct it to write or read engine according to the instructions
instrn_handler 
#(
 .MEM_AXI_DATA_WIDTH (MEM_AXI_DATA_WIDTH),
 .MEM_AXI_ADDR_WIDTH (MEM_AXI_ADDR_WIDTH)
 )
INSTRN_HANDLER (
//Global inputs
  .mem_clk                       (mem_clk),
  .reset_n                       (reset_n),

//From CSR
  .sequence_change               (sequence_change),
  .dual_seq_mode_reg             (dual_seq_mode_reg),
  .dummy_cyc_HiZ                 (dummy_cyc_HiZ),
  .dummy_cyc_drive               (dummy_cyc_drive),
  .req_to_cs_dly                 (cs_high),
  .page_incr_en			 (page_incr_en),
  .mem_page_size (mem_page_size),
  .hyperflash_en		 (hyperflash_en),
  .wr_rd_data_1			 (wr_rd_data_1),			
  .wr_rd_data_2			 (wr_rd_data_2),
  .no_of_data_bytes	         (no_of_data_bytes),
  .no_of_xfer     	         (no_of_xfer),
//To CSR
  .enter_jump_on_cs              (enter_jump_on_cs),
  .illegal_strobe                (illegal_strobe),
  .mem_illegal_instrn            (mem_illegal_instrn),

//From Main Controller
  .axi_start_mem_xfer            (axi_start_mem_xfer),
  .csr_start_mem_xfer            (csr_start_mem_xfer),
  .addr_mem_xfer                 (addr_mem_xfer),
  .rw_len_mem_xfer               (rw_len_mem_xfer),
  .xfer_mem_error                (xfer_mem_error),
  .seq_reg_0_in                  (seq_reg_0),
  .seq_reg_1_in                  (seq_reg_1),
  .seq_reg_2_in                  (seq_reg_2),
  .seq_reg_3_in                  (seq_reg_3),
  . xfer_btype                   (xfer_btype),
  . xfer_bsize                   (xfer_bsize),
  . auto_initiate                (auto_initiate_seq),
  . xfer_wr_rd                   (xfer_wr_rd),
  . cont_wr_req         (cont_wr_req),


  .wait_subseq_pg_wr (wait_subseq_pg_wr),
//To Main Controller
  .csr_start_mem_xfer_ack        (csr_start_mem_xfer_ack),
  .csr_mem_xfer_bsy              (csr_mem_xfer_bsy),
  .subseq_pg_wr  		 (subseq_pg_wr),
      .deassert_cs (deassert_cs),

//From AXI4 SLV write interface
  .slv_mem_wdata_valid           (slv_mem_wdata_valid),
  .slv_mem_wstrb                 (slv_mem_wstrb),
  .slv_mem_wlast                 (slv_mem_wlast),
  .slv_mem_wdata                 (slv_mem_wdata),
//To AXI4 SLV write interface
  .slv_mem_wdata_ack             (slv_mem_wdata_ack),
  .slv_mem_wdata_err             (slv_mem_wdata_err),

//From Rx Path
  .dlp_read_stop                 (dlp_read_stop),
  .rcv_dq_fifo_flush_done        (rcv_dq_fifo_flush_done),
  .rd_done                       (rd_done),
  .dual_seq_mode_ack             (dual_seq_mode_ack),
  .csr_read_end                      (csr_read_end),
//To RxPath
  .axi_start_mem_xfer_ack        (axi_start_mem_xfer_ack_internal),
  .rcv_dq_fifo_flush_en          (rcv_dq_fifo_flush_en),
  .csr_trigger                   (csr_trigger),
  .axi_trigger                   (axi_trigger),
  .start_read                    (start_read),
  .read_pins                     (bits_enabled),
  .instrn_dlp_en                 (instrn_dlp_en),
  .instrn_dlp_pattern            (instrn_dlp_pattern),

//From Write Engine
  .dummy_end                     (dummy_end),
  .data_ack                      (data_ack),
  .chip_sel                      (cs_n),
//To Write Engine
  .write_enable                  (write_enable),
  .no_of_pins                    (no_of_pins),
  .valid_operand_bits            (valid_operand_bits),
  .operand_out                   (operand),
  .onecyc_en_out                 (onecyc_en_out),
  .twocyc_en_out                 (twocyc_en_out),
  .multicyc_en_out               (multicyc_en_out),
  .stop_instrn_out               (stop_instrn),
  .ddr_instrn_en                 (ddr_en),
  .stall_wr_out                      (stall_wr)

);

/////////////////////////////////////////////////////////////////////////////////////////////////

//WRITE_ENGINE - This module interfaces with the memory using the control
//signals from instruction handler.it generates the signals used to
//communicate with the memory during write and command transfer
write_engine WRITE_ENGINE (
//Global Input
  .mem_clk                (mem_clk),
  .reset_n                (reset_n),
//From CSR
  .CSS                    (cs_setup),
  .CSH                    (cs_hold),
  .dummy_cyc_HiZ          (dummy_cyc_HiZ),
  .jhr_en                 (jhr_en),

//From AXI slave
  .slv_mem_wdata_valid    (slv_mem_wdata_valid),

//From Instruction Handler
  .write_enable           (write_enable),
  .no_of_pins             (no_of_pins),
  .valid_operand_bits     (valid_operand_bits),
  .operand                (operand),
  .in_onecyc_en           (onecyc_en_out),
  .in_twocyc_en           (twocyc_en_out),
  .in_multicyc_en         (multicyc_en_out),
  .stop_instrn            (stop_instrn),
  .ddr_en                 (ddr_en),
  .rd_progress            (start_read),
  .stall_wr               (stall_wr),
  .csr_trigger            (csr_trigger),
//To Instruction Handler
  .data_ack               (data_ack),
  .dummy_end              (dummy_end),
//From Rx Path
  .rd_clk_stretch         (rd_clk_stretch),
  .rd_done                (rd_done),
  .csr_read_end               (csr_read_end),
//To wrapper
  .sclk_en                (sclk_en),
//To Memory
  .dq_out                 (dq_out),
  .dq_oe                  (dq_oe),
  .chip_sel               (cs_n)
);

/////////////////////////////////////////////////////////////////////////////////////////////////
//RX_PATH - This module interfaces with memory during read from memory
//It has many instances to receive and process the dq data read from memory
rx_path 
#(
   .MEM_AXI_DATA_WIDTH (MEM_AXI_DATA_WIDTH),
   .RCV_DQ_FIFO_ADDR_WIDTH (RCV_DQ_FIFO_ADDR_WIDTH)
)

RX_PATH
   (
//Global inputs
  . mem_clk                (mem_clk),
  . reset_n                (reset_n),
    
  //From Main controller
  . mem_mr_xfer_valid      (axi_start_mem_xfer),
  . mem_mr_error           (xfer_mem_error),
  . mem_mr_xfer_addr_lsb   (addr_mem_xfer[3:0]),
  . mem_mr_xfer_wr_rd      (xfer_wr_rd),
  . mem_mr_axi_len         (xfer_axi_len),
  . mem_mr_xfer_btype      (xfer_btype),
  . cont_rd_req         (cont_rd_req),
  . mem_mr_xfer_bsize      (xfer_bsize),                         
  //To Main controller  ---- final ack from ack resolver 
  . mem_mr_xfer_ack        (axi_start_mem_xfer_ack),
                         
  //From AXI4_SLV_CNTRL rd interface 
  . mem_mr_rdata_ack       (slv_mem_rdata_ack),
  //TO AXI4_SLV_CNTRL rd interface
  . mem_mr_rdata_valid     (slv_mem_rdata_valid),
  . mem_mr_rdata           (slv_mem_rdata),
  . mem_mr_rlast           (slv_mem_rlast),
  . mem_mr_rresp           (slv_mem_rresp),
                        
  //From write engine  
  . sclk_en (sclk_en),
  . dq_oe_ip               (dq_oe[0]),
  . ce_n_ip                (cs_n),
//From MEM_XFER_INTF
   .mem_illegal_instrn_err (mem_illegal_instrn), // level - mem_clk
  //To write engine      
  . rd_done                (rd_done),
  . rd_clk_stretch         (rd_clk_stretch),
  
  //From instruction handler
  . xmittr_ack             (axi_start_mem_xfer_ack_internal),
  . rcv_dq_fifo_flush_en   (rcv_dq_fifo_flush_en),
  . start_read             (start_read),
  . bits_enabled           (bits_enabled),
  . instrn_dlp_en          (instrn_dlp_en),
  . instrn_dlp_pattern     (instrn_dlp_pattern),
  . ddr_en                 (ddr_en),
  . csr_trigger            (csr_trigger),
  . axi_trigger            (axi_trigger),
  // To instruction handler
  . rcv_dq_fifo_flush_done (rcv_dq_fifo_flush_done),
  . dlp_read_stop          (dlp_read_stop),
  . csr_read_end               (csr_read_end),
  
  //From CSR            
  . dqs_non_tgl_to         (dqs_non_tgl_to),
  . csr_dlp_cyc_cnt        (csr_dlp_cyc_cnt),
  .no_of_data_bytes	   (no_of_data_bytes),
  .mem_rd_data_ack (mem_rd_data_ack ),
  .predrive_en             (predrive_en),
  .dummy_cycle_config      (dummy_cycle_config),
  //To CSR  
  .calib_tap_out           (calib_tap_out),
  .calib_tap_valid         (calib_tap_valid),
  .mem_rd_valid (mem_rd_valid),
  .mem_rd_data  (mem_rd_data),
  .csr_dqs_non_toggle_err  (csr_dqs_non_toggle_err),
  .axi_dqs_non_toggle_err  (axi_dqs_non_toggle_err),
                          
  //From memory           
  . dqs_ip                 (dqs),
  . dq_in_ip               (dq_in)
  );
/////////////////////////////////////////////////////////////////////////////////////////////////
endmodule
