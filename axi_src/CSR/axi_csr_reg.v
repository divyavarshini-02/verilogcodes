

`timescale 1ps/1ps
`include "csr_defines.vh"


module axi_csr_reg (
//GLOBAL SYSTEM SIGNALS
   sys_clk_i,
   sys_reset_n_i,

//AXI WRITE ADDRESS CHANNEL
   csr_aw_valid_i,
   csr_aw_id_i,
   csr_aw_addr_i,
   csr_aw_len_i,
   csr_aw_size_i,
   csr_aw_burst_i,
   csr_aw_ready_o,

//AXI WRITE  DATA CHANNEL
   csr_w_data_i,
   csr_w_valid_i,
   csr_w_last_i,
   csr_w_ready_o,

//AXI WRITE RESPONSE CHANNEL
   csr_b_id_o,
   csr_b_valid_o,
   csr_b_resp_o,
   csr_b_ready_i,

//AXI READ ADDRESS CHANNEL
   csr_ar_valid_i,
   csr_ar_id_i,
   csr_ar_addr_i,
   csr_ar_len_i,
   csr_ar_size_i,
   csr_ar_burst_i,
   csr_ar_ready_o,

//AXI READ DATA CHANNEL
   csr_r_id_o,
   csr_r_data_o,
   csr_r_valid_o,
   csr_r_resp_o,
   csr_r_last_o,
   csr_r_ready_i,

// sequence RAM Write Ports
   seq_ram_wen,
   seq_ram_wr_data,
   seq_ram_addr,

// sequence RAM read ports

// TO MAIN CONTROLLER
   rd_seq_sel,
   wr_seq_sel,
   rd_seq_id,
   wr_seq_id,
   def_seq1_dword1,
   def_seq1_dword2,
   def_seq1_dword3,
   def_seq1_dword4,
   def_seq2_dword1,
   def_seq2_dword2,
   def_seq2_dword3,
   def_seq2_dword4,

   hybrid_wrap_cmd_en,
   page_incr_en,
   hyperflash_en,
   mem_page_size,

   wr_rd_data_1,
   wr_rd_data_2,

   cmd_no_of_opcode,
   cmd_xfer_data_rate,
   cmd_no_of_pins,
   cmd_opcode,
   wr_data_en       ,
   wdata_no_of_pins ,
   wdata_xfer_data_rate,
   csr_cmd_xfer_valid,
   no_of_wr_data_bytes,

   read_cmd_opcode,
   read_no_of_pins,
   read_xfer_data_rate,
   read_cmd_data_rate,
   read_no_of_opcode,
   csr_rd_xfer_valid,
   no_of_csr_rd_data_bytes,
   no_of_csr_rd_addr_bytes,
   rd_monitor_bit,
   rd_monitor_value,
   rd_monitor_en,   
   subseq_rd_xfer_time,

   status_cmd_opcode,
   status_no_of_pins,
   status_xfer_data_rate,
   status_cmd_data_rate,
   status_no_of_opcode,
   status_monitor_bit,
   status_monitor_value,
   status_monitor_en,
   no_of_auto_status_rd_data_bytes,
   subseq_status_rd_xfer_time,
   auto_status_rd_addr_bytes,
   auto_initiate_status_read_seq,
   status_reg_rd_xfer_time,
   auto_initiate_status_addr,

   auto_initiate_write_en_seq,
   auto_initiate_write_en_seq_2,
   auto_initiate_post_wren_seq,
   post_wren_seq_data,
   auto_initiate_write_dis_seq,

   mem_upper_bound_addr_0,
   mem_lower_bound_addr_0,
   write_en_seq_reg_1,
   write_en_seq_reg_2,
   write_dis_seq_reg_1,
   write_dis_seq_reg_2,

   mem_xfer_pending,
   status_reg_en, // specific to hyperflash
   cont_read_auto_status_en,

// TO MEMORY XFER SM
   ddr_delay_tap,
   dqs_mode,
   dlp_pattern_cyc_cnt,
   jhr_en,
   predrive_en,
   dual_seq_mode,
   dummy_cycle_config,           
   dummy_cycle_HiZ,           
   dummy_cycle_drive,
   dqs_non_tgle_to ,
   cs_hold,
   cs_setup,
   cs_high,
   mem_rd_data_ack,

// FROM MAIN CONTROLLER
 
   csr_cmd_xfer_ack,
   csr_cmd_xfer_success, // pulse
   mem_xfer_auto_status_rd_done, // pulse
   csr_rd_xfer_ack,
   monitoring_xfer,

// FROM MEMORY XFER SM
   mem_illegal_instrn_err, //level from mem_xfer_sm
   mem_dqs_non_toggle_err,    // level from mem_xfer_sm
   illegal_strobe_err, //level from mem_xfer_sm
   csr_dqs_non_toggle_err,    // level from mem_xfer_sm
   calib_tap_out,      //data is made stable until the next dlp transfer is initiated
   calib_tap_valid,    //pulse from mem_xfer, converted to level using pulse_level_stretcher
   mem_rd_data,//data is maintained until next transaction
   mem_rd_valid,//level
   slv_mem_err,

// TO CPU
   xspi_csr_xfer_status_intr,
   xspi_mem_xfer_status_intr
   ); 
parameter IDLE                 = 1'b0;
parameter WRITE_SEQ_RAM        = 1'b1;
//parameter READ_SEQ_RAM         = 2'b10;

parameter DOUBLE_DWORD       = 32;
parameter CSR_ADDR_INT_WIDTH = 12;

localparam CSR_AXI_ID_WIDTH     = 4 ;
localparam CSR_AXI_ADDR_WIDTH   = 32;
localparam CSR_AXI_DATA_WIDTH   = 32;
localparam CSR_AXI_LEN_WIDTH    = 8;
localparam CSR_AXI_BURST_WIDTH  = 2 ;
localparam CSR_AXI_RESP_WIDTH   = 2 ;
localparam CSR_AXI_STROBE_WIDTH = 4 ; //GLOBAL SYSTEM SIGNALS
      
input                              sys_clk_i;
input                              sys_reset_n_i;

//AXI WRITE ADDRESS CHANNEL
input                              csr_aw_valid_i;
input  [CSR_AXI_ID_WIDTH-1:0]      csr_aw_id_i;
input  [CSR_AXI_ADDR_WIDTH-1:0]    csr_aw_addr_i;
input  [CSR_AXI_LEN_WIDTH-1:0]     csr_aw_len_i;
input  [2:0]                       csr_aw_size_i;
input  [CSR_AXI_BURST_WIDTH-1:0]   csr_aw_burst_i;
output                             csr_aw_ready_o;

//AXI WRITE  DATA CHANNEL

input  [CSR_AXI_DATA_WIDTH-1:0]    csr_w_data_i;
input                              csr_w_valid_i;
input                              csr_w_last_i;
output                             csr_w_ready_o;

//AXI WRITE RESPONSE CHANNEL

input                              csr_b_ready_i;
output [CSR_AXI_ID_WIDTH-1:0]      csr_b_id_o;
output                             csr_b_valid_o;
output [CSR_AXI_RESP_WIDTH-1:0]    csr_b_resp_o;
                
//AXI READ ADDRESS CHANNEL
input                              csr_ar_valid_i;
input [CSR_AXI_ID_WIDTH-1:0]       csr_ar_id_i;
input [CSR_AXI_ADDR_WIDTH-1:0]     csr_ar_addr_i;
input [CSR_AXI_LEN_WIDTH-1:0]      csr_ar_len_i;
input [2:0]                        csr_ar_size_i;
input [CSR_AXI_BURST_WIDTH-1:0]    csr_ar_burst_i;
output                             csr_ar_ready_o;

// sequence RAM Write Ports
output                             seq_ram_wen;
output [CSR_AXI_DATA_WIDTH-1:0]    seq_ram_wr_data;
output [9:0]                       seq_ram_addr;

// sequence RAM Write Ports

//AXI READ DATA CHANNEL

input                              csr_r_ready_i;
output [CSR_AXI_ID_WIDTH-1:0]      csr_r_id_o;
output [CSR_AXI_DATA_WIDTH-1:0]    csr_r_data_o;
output                             csr_r_valid_o;
output [CSR_AXI_RESP_WIDTH-1:0]    csr_r_resp_o;
output                             csr_r_last_o;

// TO MAIN CONTROLLER

output                             rd_seq_sel;
output                             wr_seq_sel;
output [10:0]                      rd_seq_id;
output [10:0]                      wr_seq_id;
output [DOUBLE_DWORD-1:0]          def_seq1_dword1;
output [DOUBLE_DWORD-1:0]          def_seq1_dword2;
output [DOUBLE_DWORD-1:0]          def_seq1_dword3;
output [DOUBLE_DWORD-1:0]          def_seq1_dword4;
output [DOUBLE_DWORD-1:0]          def_seq2_dword1;
output [DOUBLE_DWORD-1:0]          def_seq2_dword2;
output [DOUBLE_DWORD-1:0]          def_seq2_dword3;
output [DOUBLE_DWORD-1:0]          def_seq2_dword4;
output [31:0]                      mem_upper_bound_addr_0;
output [31:0]                      mem_lower_bound_addr_0;
output [31:0]                      write_en_seq_reg_1;
output [31:0]                      write_en_seq_reg_2;
output [31:0]                      write_dis_seq_reg_1;
output [31:0]                      write_dis_seq_reg_2;

input 				   mem_xfer_pending;
output                             status_reg_en;

output                             hybrid_wrap_cmd_en;
output                             page_incr_en;
output [31:0]                      wr_rd_data_1;
output [31:0]                      wr_rd_data_2;

output                             wdata_xfer_data_rate;
output [1:0]                       wdata_no_of_pins  ;
output				   hyperflash_en;
output [3:0]                       mem_page_size;
output [5:0]                       no_of_wr_data_bytes;
output                             wr_data_en        ;
output                             cmd_no_of_opcode;
output                             cmd_xfer_data_rate;
output [1:0]                       cmd_no_of_pins;
output [15:0]                      cmd_opcode;
output                             csr_cmd_xfer_valid   ;
output [2:0]                       auto_status_rd_addr_bytes;
output [30:0]                      status_reg_rd_xfer_time;
output [31:0]                      auto_initiate_status_addr;
output [17:0]                      subseq_status_rd_xfer_time;
output [2:0]                       no_of_auto_status_rd_data_bytes;
output [6:0]                       no_of_csr_rd_data_bytes;
output                             status_monitor_en ;
output                             status_monitor_value ;
output [2:0]                       status_monitor_bit ;
output                             status_no_of_opcode;
output                             status_xfer_data_rate;
output                             status_cmd_data_rate;
output [1:0]                       status_no_of_pins;
output [15:0]                      status_cmd_opcode;
output [2:0]                       no_of_csr_rd_addr_bytes;
output                             read_no_of_opcode;
output                             read_xfer_data_rate;
output                             read_cmd_data_rate;
output [1:0]                       read_no_of_pins;
output [15:0]                      read_cmd_opcode;
output                             csr_rd_xfer_valid;

output     [17:0] subseq_rd_xfer_time; 
output  rd_monitor_en;   
output	rd_monitor_value;
output	[2:0] rd_monitor_bit;     
output                             auto_initiate_post_wren_seq;
output [15:0]                      post_wren_seq_data;
output                             auto_initiate_write_en_seq;
output                             auto_initiate_write_en_seq_2;
output                             auto_initiate_status_read_seq;
output                             auto_initiate_write_dis_seq;
output                             cont_read_auto_status_en;



// TO MEMORY XFER SM
output [7:0]                       ddr_delay_tap;
output                             dqs_mode;
output [2:0]                       dlp_pattern_cyc_cnt;
output [4:0]                       dummy_cycle_config;           
output [7:0]                       dummy_cycle_HiZ;           
output [7:0]                       dummy_cycle_drive;
output [4:0]                       dqs_non_tgle_to ;
output [1:0]                       cs_hold;
output [1:0]                       cs_setup;
output [4:0]                       cs_high;
output                             jhr_en;
output                             predrive_en;
output                             dual_seq_mode;
output                             mem_rd_data_ack ;

// FROM MAIN CONTROLLER

input                              csr_cmd_xfer_ack     ;
input                              csr_cmd_xfer_success ;
input                              mem_xfer_auto_status_rd_done ;
input                              csr_rd_xfer_ack ;
input                              monitoring_xfer ;

// FROM MEMORY XFER SM
input                              mem_dqs_non_toggle_err;
input                              csr_dqs_non_toggle_err;
input                              mem_illegal_instrn_err; 
input                              illegal_strobe_err; 
input [7:0]                        calib_tap_out;
input                              calib_tap_valid;
input [31:0]                        mem_rd_data  ;
input                              mem_rd_valid ;
input			      	   slv_mem_err;

// TO CPU
output                             xspi_csr_xfer_status_intr;
output                             xspi_mem_xfer_status_intr;


reg                                pres_state,next_state;
reg                                data_wait     , next_data_wait;
reg                                csr_aw_ready_o,  next_csr_aw_ready_o;
reg                                csr_w_ready_o,   next_csr_w_ready_o;          
reg   [CSR_AXI_ID_WIDTH-1:0]       csr_b_id_o,      next_csr_b_id_o;          
reg                                csr_b_valid_o,   next_csr_b_valid_o;     
reg   [CSR_AXI_RESP_WIDTH-1:0]     csr_b_resp_o,    next_csr_b_resp_o;     
reg                                csr_ar_ready_o,  next_csr_ar_ready_o;      
reg   [CSR_AXI_ID_WIDTH-1:0]       csr_r_id_o,      next_csr_r_id_o;            
reg   [CSR_AXI_DATA_WIDTH-1:0]     csr_r_data_o,    next_csr_r_data_o;       
reg                                csr_r_valid_o,   next_csr_r_valid_o;       
reg   [CSR_AXI_RESP_WIDTH-1:0]     csr_r_resp_o,    next_csr_r_resp_o;       
reg                                csr_r_last_o,    next_csr_r_last_o; 
      
reg   [CSR_AXI_ADDR_WIDTH-1:0]     csr_aw_addr_reg,next_csr_aw_addr_reg;
reg   [CSR_AXI_ID_WIDTH-1:0]       csr_aw_id_reg,next_csr_aw_id_reg;
 
reg   [CSR_ADDR_INT_WIDTH-1:0]     axi_addr_reg,     next_axi_addr_reg;
reg   [CSR_AXI_LEN_WIDTH:0]        axi_len_reg,      next_axi_len_reg;
reg   [CSR_AXI_BURST_WIDTH-1:0]    axi_burst_reg,    next_axi_burst_reg;
reg  [CSR_AXI_DATA_WIDTH-1:0]      rdata_reg_1,       next_rdata_reg_1;
reg  [CSR_AXI_DATA_WIDTH-1:0]      rdata_reg_2,       next_rdata_reg_2;
reg                                data_avail_2, next_data_avail_2;
reg                                auto_initiate_write_en_seq, next_auto_initiate_write_en_seq;
reg                                auto_initiate_write_en_seq_2, next_auto_initiate_write_en_seq_2;
reg                                auto_initiate_post_wren_seq, next_auto_initiate_post_wren_seq;
reg [15:0]                         post_wren_seq_data, next_post_wren_seq_data;
reg                                auto_initiate_status_read_seq,next_auto_initiate_status_read_seq;
reg                                auto_initiate_write_dis_seq, next_auto_initiate_write_dis_seq;

reg				   mem_xfer_pending_d;
wire 				   mem_xfer_pending_fedge;
reg 				   mem_all_xfer_done, next_mem_all_xfer_done;



wire                               mem_dqs_non_toggle_err_redge;
wire                               csr_dqs_non_toggle_err_redge;
wire                               mem_illegal_instrn_err_redge ;
wire                               mem_illegal_strobe_err_redge ;
wire                               mem_illegal_addr_err_redge ;
reg                                csr_dqs_non_toggle_err_d1;
reg                                mem_dqs_non_toggle_err_d1;
reg                                illegal_strobe_err_d1    ;
reg				   slv_mem_err_d1;
reg                                mem_illegal_instrn_err_d1    ;
reg                                mem_illegal_strobe_err_d1    ;
reg                                calib_tap_valid_d1;
wire                               calib_tap_valid_redge;
wire [CSR_AXI_ID_WIDTH-1 :0]       csr_aw_id_final      ;
wire [CSR_AXI_ADDR_WIDTH-1 :0]     csr_aw_addr_final      ;

assign calib_tap_valid_redge            = calib_tap_valid && (!calib_tap_valid_d1);
assign mem_dqs_non_toggle_err_redge     = mem_dqs_non_toggle_err && (!mem_dqs_non_toggle_err_d1);
assign mem_illegal_instrn_err_redge     = mem_illegal_instrn_err && (!mem_illegal_instrn_err_d1);
assign csr_dqs_non_toggle_err_redge     = csr_dqs_non_toggle_err && (!csr_dqs_non_toggle_err_d1);
assign mem_illegal_strobe_err_redge     = illegal_strobe_err && (!illegal_strobe_err_d1);
assign mem_illegal_addr_err_redge       = slv_mem_err && (!slv_mem_err_d1);
assign csr_aw_id_final                  = data_wait ? csr_aw_id_reg : csr_aw_id_i;
assign csr_aw_addr_final                = data_wait ? csr_aw_addr_reg : csr_aw_addr_i;
assign mem_xfer_pending_fedge	 	= !mem_xfer_pending & mem_xfer_pending_d;

reg                                seq_ram_wen      , next_seq_ram_wen;
reg   [CSR_AXI_DATA_WIDTH-1:0]     seq_ram_wr_data    , next_seq_ram_wr_data;
reg   [9:0]                        seq_ram_addr       , next_seq_ram_addr;


// CSR Registers 
reg [DOUBLE_DWORD-1:0]             seq_ram_key         , next_seq_ram_key              ;    
reg                                seq_ram_key_valid   , next_seq_ram_key_valid        ;    
reg                                seq_ram_lock        , next_seq_ram_lock             ;
reg                                seq_ram_unlock      , next_seq_ram_unlock           ;

reg                                rd_seq_sel,next_rd_seq_sel;
reg                                wr_seq_sel,next_wr_seq_sel;
reg [10:0]                         rd_seq_id     , next_rd_seq_id      ;
reg [10:0]                         wr_seq_id     , next_wr_seq_id      ;

reg [DOUBLE_DWORD-1:0]             def_seq1_dword1 ;
reg [DOUBLE_DWORD-1:0]             def_seq1_dword2 ;
reg [DOUBLE_DWORD-1:0]             def_seq1_dword3 ;
reg [DOUBLE_DWORD-1:0]             def_seq1_dword4 ;
reg [DOUBLE_DWORD-1:0]             def_seq2_dword1 ;
reg [DOUBLE_DWORD-1:0]             def_seq2_dword2 ;
reg [DOUBLE_DWORD-1:0]             def_seq2_dword3 ;
reg [DOUBLE_DWORD-1:0]             def_seq2_dword4 ;


reg [7:0]                          ddr_delay_tap      , next_ddr_delay_tap            ; 
reg                                dqs_mode           , next_dqs_mode                 ; 
reg [2:0]                          dlp_pattern_cyc_cnt, next_dlp_pattern_cyc_cnt      ;
reg [7:0]                          auto_dummy_cycle_config , next_auto_dummy_cycle_config          ;
reg [7:0]                          read_dummy_cycle_config , next_read_dummy_cycle_config          ;
reg [7:0]                          dummy_cycle_HiZ    , next_dummy_cycle_HiZ          ;
reg [7:0]                          dummy_cycle_drive  , next_dummy_cycle_drive        ;
reg [4:0]                          dqs_non_tgle_to    , next_dqs_non_tgle_to          ;
reg [1:0]                          cs_hold            , next_cs_hold                  ;
reg [1:0]                          cs_setup           , next_cs_setup                 ;
reg [4:0]                          cs_high            , next_cs_high                  ;
reg                               cmd_no_of_opcode     , next_cmd_no_of_opcode        ;
reg                               cmd_xfer_data_rate   , next_cmd_xfer_data_rate      ;
reg [1:0]                         cmd_no_of_pins       , next_cmd_no_of_pins          ;
reg [15:0]                        cmd_opcode           , next_cmd_opcode              ;
reg [2:0]			  auto_status_rd_addr_bytes     , next_auto_status_rd_addr_bytes        ;
reg [30:0]                        status_reg_rd_xfer_time , next_status_reg_rd_xfer_time ;
reg [17:0]                        subseq_status_rd_xfer_time , next_subseq_status_rd_xfer_time ;
reg [2:0]                         no_of_auto_status_rd_data_bytes , next_no_of_auto_status_rd_data_bytes      ;
reg [6:0]                         no_of_csr_rd_data_bytes , next_no_of_csr_rd_data_bytes      ;
reg                               status_reg_en        ,  next_status_reg_en     ;
reg                               status_monitor_en   , next_status_monitor_en      ;                            
reg                               status_monitor_value        , next_status_monitor_value           ;
reg [2:0]                         status_monitor_bit          , next_status_monitor_bit             ;
reg                               status_no_of_opcode    , next_status_no_of_opcode       ;
reg                               status_xfer_data_rate, next_status_xfer_data_rate   ;
reg                               status_cmd_data_rate, next_status_cmd_data_rate   ;
reg [1:0]                         status_no_of_pins    , next_status_no_of_pins       ;
reg [15:0]                         status_cmd_opcode    , next_status_cmd_opcode       ;

reg [2:0]			  no_of_csr_rd_addr_bytes     , next_no_of_csr_rd_addr_bytes  ;
reg [2:0]                         read_dummy_cycles    , next_read_dummy_cycles   ;
reg                               read_no_of_opcode    , next_read_no_of_opcode   ;
reg                               read_xfer_data_rate, next_read_xfer_data_rate   ;
reg                               read_cmd_data_rate, next_read_cmd_data_rate   ;
reg [1:0]                         read_no_of_pins    , next_read_no_of_pins       ;
reg [15:0]                        read_cmd_opcode    , next_read_cmd_opcode       ;
reg [31:0] next_auto_initiate_status_addr, auto_initiate_status_addr;

reg     [17:0] next_subseq_rd_xfer_time,  subseq_rd_xfer_time; 
reg	next_rd_monitor_en ,     rd_monitor_en;   
reg	next_rd_monitor_value    ,  rd_monitor_value;
reg	[2:0] next_rd_monitor_bit ,  rd_monitor_bit;     

reg                               mem_illegal_strobe_err_ie,  next_mem_illegal_strobe_err_ie ;
reg                               mem_illegal_addr_err_ie,    next_mem_illegal_addr_err_ie ;
reg                               csr_dqs_non_toggle_err_ie,  next_csr_dqs_non_toggle_err_ie  ;
reg                               csr_rd_xfer_intr_en , next_csr_rd_xfer_intr_en ;
reg                               cmd_xfer_intr_en           , next_cmd_xfer_intr_en         ;
reg                               mem_all_xfer_intr_en           , next_mem_all_xfer_intr_en         ;
reg                               csr_rd_xfer_done, next_csr_rd_xfer_done        ;
reg                               cmd_xfer_done , next_cmd_xfer_done ;
reg                               mem_xfer_auto_status_rd_done_reg , next_mem_xfer_auto_status_rd_done_reg ;
reg                                jhr_en              , next_jhr_en                  ;
reg                                predrive_en         , next_predrive_en             ;
reg                                dual_seq_mode       , next_dual_seq_mode             ;
reg                                cont_read_auto_status_en , next_cont_read_auto_status_en             ;

reg [31:0]                         mem_upper_bound_addr_0, next_mem_upper_bound_addr_0;
reg [31:0]                         mem_lower_bound_addr_0, next_mem_lower_bound_addr_0;
reg                                page_incr_en             ,  next_page_incr_en            ;        
reg                                hybrid_wrap_cmd_en    ,  next_hybrid_wrap_cmd_en   ; 
reg [31:0]                         wr_rd_data_1,next_wr_rd_data_1;
reg [31:0]                         wr_rd_data_2,next_wr_rd_data_2;
reg                                   next_csr_cmd_xfer_reg, csr_cmd_xfer_reg;
reg [31:0]                        write_en_seq_reg_1 , next_write_en_seq_reg_1     ;
reg [31:0]                        write_en_seq_reg_2 , next_write_en_seq_reg_2     ;

reg [31:0]                        write_dis_seq_reg_1 , next_write_dis_seq_reg_1     ;
reg [31:0]                        write_dis_seq_reg_2 , next_write_dis_seq_reg_2     ;


reg                               mem_auto_status_rd_intr_en , next_mem_auto_status_rd_intr_en ;
reg                                mem_dlp_failure_ie          , next_mem_dlp_failure_ie           ;
reg                                mem_illegal_instrn_err_ie , next_mem_illegal_instrn_err_ie  ;  
reg                                mem_dqs_non_toggle_err_ie, next_mem_dqs_non_toggle_err_ie;



reg                                wdata_xfer_data_rate,next_wdata_xfer_data_rate;
reg [1:0]                          wdata_no_of_pins,next_wdata_no_of_pins;
reg				   hyperflash_en, next_hyperflash_en;
reg [3:0]		           mem_page_size, next_mem_page_size;
reg [5:0]                          no_of_wr_data_bytes, next_no_of_wr_data_bytes;
reg                                wr_data_en , next_wr_data_en;

reg                                mem_dlp_failure_reg , next_mem_dlp_failure_reg ;
reg                                mem_illegal_instrn_err_redge_reg  , next_mem_illegal_instrn_err_redge_reg ;
reg                                mem_illegal_addr_err_redge_reg  , next_mem_illegal_addr_err_redge_reg ;
reg                                mem_dqs_non_toggle_err_redge_reg, next_mem_dqs_non_toggle_err_redge_reg;
reg                                mem_illegal_strobe_err_redge_reg  , next_mem_illegal_strobe_err_redge_reg ;
reg                                csr_dqs_non_toggle_err_redge_reg, next_csr_dqs_non_toggle_err_redge_reg;
reg                                dlp_failure, next_dlp_failure;

reg                                next_xspi_csr_xfer_status_intr, xspi_csr_xfer_status_intr;
reg                                next_xspi_mem_xfer_status_intr, xspi_mem_xfer_status_intr;
reg                                csr_cmd_xfer_valid , next_csr_cmd_xfer_valid ;
reg                                csr_rd_xfer_valid , next_csr_rd_xfer_valid ;
reg [1:0]                          valid_cntr_out , next_status_valid_cntr, status_valid_cntr ;
reg                                mem_rd_valid_d ;
reg                                mem_rd_data_ack ;
reg                                csr_rd_xfer_progress, next_csr_rd_xfer_progress;
//Write Wires
wire [CSR_AXI_LEN_WIDTH:0]         axi_len_reg_minus1;
wire                               axi_len_reg_eq0;
wire                               axi_len_reg_eq1;

//Read Wires
//wire                               rd_addr_eq_seq_ram;

wire                               wr_addr_eq_seq_ram;
wire                               csr_wr_addr_space;
wire                               csr_rd_addr_space;

//Length Assignment
assign axi_len_reg_minus1 = axi_len_reg - 1;
assign axi_len_reg_eq0    = !(|axi_len_reg);
assign axi_len_reg_eq1    = (!(|axi_len_reg[CSR_AXI_LEN_WIDTH:1])) && (axi_len_reg[0]);

//write assignment

//Read Assignment
//assign rd_addr_eq_seq_ram = !(|csr_ar_addr_i[11:10]);

assign wr_addr_eq_seq_ram = !(|csr_aw_addr_final[31:10]);
assign csr_wr_addr_space     = !(|csr_aw_addr_final[31:12]) && ( (csr_aw_addr_final[11:10]==2'd2) || ( csr_aw_addr_final[11:10]==2'd3) );
assign csr_rd_addr_space     = !(|csr_ar_addr_i[31:12]) && ( (csr_ar_addr_i[11:10]==2'd2) || ( csr_ar_addr_i[11:10]==2'd3) );

wire [4:0] dummy_cycle_config;
assign dummy_cycle_config = dqs_mode ? (csr_rd_xfer_progress ? read_dummy_cycle_config : auto_dummy_cycle_config) : 5'd0;

//SYNCHRONOUS BLOCK
always @ (posedge sys_clk_i or negedge sys_reset_n_i)
begin
   if (!sys_reset_n_i)
   begin
      pres_state                                       <= IDLE                              ;
      data_wait                                        <= #1 1'b0                           ;
      csr_aw_ready_o                                   <= #1 1'b0                           ;      
      csr_w_ready_o                                    <= #1 1'b0                           ;      
      csr_b_id_o                                       <= #1 {CSR_AXI_ID_WIDTH{1'b0}}       ;          
      csr_b_valid_o                                    <= #1 1'b0                           ;       
      csr_b_resp_o                                     <= #1 2'b00                          ;        
      csr_ar_ready_o                                   <= #1 1'b0                           ;      
      csr_r_id_o                                       <= #1 {CSR_AXI_ID_WIDTH{1'b0}}       ;          
      csr_r_data_o                                     <= #1 {CSR_AXI_DATA_WIDTH{1'b0}}     ;        
      csr_r_valid_o                                    <= #1 1'b0                           ;       
      csr_r_resp_o                                     <= #1 2'b00                          ;        
      csr_r_last_o                                     <= #1 1'b0                           ;
      csr_aw_addr_reg                                  <= #1 {CSR_AXI_ADDR_WIDTH{1'b0}}     ;        
      csr_aw_id_reg                                    <= #1 {CSR_AXI_ID_WIDTH{1'b0}}       ;        
      axi_addr_reg                                     <= #1 {CSR_ADDR_INT_WIDTH{1'b0}}     ;     
      axi_burst_reg                                    <= #1 {CSR_AXI_BURST_WIDTH{1'b0}}    ;     
      axi_len_reg                                      <= #1 {CSR_AXI_LEN_WIDTH+1{1'b0}}    ;     
      seq_ram_wen                                    <= #1 1'b0                           ;
      seq_ram_wr_data                                  <= #1 {CSR_AXI_DATA_WIDTH{1'b0}}     ;
      seq_ram_addr                                     <= #1 10'd0                          ;
      rdata_reg_1                                      <= #1 {CSR_AXI_DATA_WIDTH{1'b0}}     ;
      rdata_reg_2                                      <= #1 {CSR_AXI_DATA_WIDTH{1'b0}}     ;
      data_avail_2                                     <= #1 1'b0 			    ;
      seq_ram_key                                      <= #1 32'd0                          ;   // value to be decided
      seq_ram_key_valid                                <= #1 1'b0                           ; 
      seq_ram_lock                                     <= #1 1'b0                           ;   
      seq_ram_unlock                                   <= #1 1'b1                           ;   // By default, sequence RAM is in unlock state after POR.
      rd_seq_sel                 		       <= #1 1'b0                           ;
      wr_seq_sel                 		       <= #1 1'b0                           ;
      rd_seq_id                                        <= #1 11'h400                        ;
      wr_seq_id                                        <= #1 11'h400                        ;
      def_seq1_dword1                                  <= #1 32'h 3C00_0C0E                 ;
      def_seq1_dword2                                  <= #1 32'h 0000_0000		    ;
      def_seq1_dword3                                  <= #1 32'h 0000_0000		    ;
      def_seq1_dword4                                  <= #1 32'h 0000_0000		    ;
      def_seq2_dword1                                  <= #1 32'h 0C8E_0820                 ;
      def_seq2_dword2                                  <= #1 32'h 0000_3C00                 ;
      def_seq2_dword3                                  <= #1 32'h 0                         ;
      def_seq2_dword4                                  <= #1 32'h 0                         ;
      ddr_delay_tap                                    <= #1 8'h0			    ;  
      dqs_mode                                         <= #1 1'h0			    ;  
      dlp_pattern_cyc_cnt                              <= #1 3'h0			    ;
      auto_dummy_cycle_config                          <= #1 5'd0			    ; 
      read_dummy_cycle_config                          <= #1 5'd0			    ; 
      dummy_cycle_HiZ                                  <= #1 8'hFF			    ; 
      dummy_cycle_drive                                <= #1 8'hFF		       	    ;
      dqs_non_tgle_to                                  <= #1 5'd0                           ;
      cs_hold                                          <= #1 2'h0                           ; 
      cs_setup                                         <= #1 2'h0                           ;
      cs_high                                          <= #1 5'h0                           ;
      jhr_en		                               <= #1 1'b0                           ;          
      predrive_en	                               <= #1 1'b0                           ;          
      dual_seq_mode	               		       <= #1 1'b0                           ;		    
      cont_read_auto_status_en        		       <= #1 1'b0                           ;		    
      cmd_no_of_opcode                                 <= #1 1'd0                           ;    
      cmd_xfer_data_rate                               <= #1 1'd0                           ;   
      cmd_no_of_pins                                   <= #1 2'd0                           ;          
      cmd_opcode                                       <= #1 16'd0                          ; 
      auto_status_rd_addr_bytes                                    <= #1 3'd0                           ;
      status_reg_rd_xfer_time                          <= #1 31'd0                          ; 
      subseq_status_rd_xfer_time                       <= #1 18'd0                          ; 
      no_of_auto_status_rd_data_bytes                              <= #1 3'd0                           ;
      no_of_csr_rd_data_bytes                              <= #1 7'd0                           ;
      status_reg_en                                    <= #1 1'd0                           ; 
      status_monitor_en                            <= #1 1'd0			    ;                 
      status_monitor_value                                    <= #1 1'd0			    ;       
      status_monitor_bit                                      <= #1 3'd0			    ;            
      status_no_of_opcode                              <= #1 1'd0			    ;                
      status_xfer_data_rate                            <= #1 1'd0			    ;            
      status_cmd_data_rate                            <= #1 1'd0			    ;            
      status_no_of_pins                                <= #1 2'd0			    ;                
      status_cmd_opcode                                <= #1 8'h05                          ;
      no_of_csr_rd_addr_bytes                                <= #1 3'd0                           ;
      read_dummy_cycles                                <= #1 3'd0                           ;          
      read_no_of_opcode                                <= #1 1'd0			    ;                
      read_xfer_data_rate                              <= #1 1'd0			    ;            
      read_cmd_data_rate                              <= #1 1'd0			    ;            
      read_no_of_pins                                  <= #1 2'd0			    ;                
      read_cmd_opcode                                  <= #1 8'h00                          ;
	subseq_rd_xfer_time 				<= 18'd0;
	rd_monitor_en       				<= 1'b0;
	rd_monitor_value    				<= 1'b0;
	rd_monitor_bit      				<= 3'd0;
	auto_initiate_status_addr 			<= 32'd0;
      mem_illegal_strobe_err_ie                        <= #1 1'b0                           ;
      mem_illegal_addr_err_ie                          <= #1 1'b0                           ;
      csr_dqs_non_toggle_err_ie                        <= #1 1'b0                           ;
      csr_rd_xfer_intr_en                        <= #1 1'd0			    ;
      cmd_xfer_intr_en                                 <= #1 1'd0			    ;
      mem_all_xfer_intr_en                             <= #1 1'd0			    ;
      csr_rd_xfer_done                           <= #1 1'd0			    ;
      cmd_xfer_done                                    <= #1 1'd0			    ;
      mem_xfer_auto_status_rd_done_reg                         <= #1 1'd0			    ;
      mem_upper_bound_addr_0                           <= #1 32'hFFFF_FFFF                  ; 
      mem_lower_bound_addr_0                           <= #1 32'h0                          ;
      hybrid_wrap_cmd_en                               <= #1 1'd0		            ;
      page_incr_en					       <= #1 1'd0            		    ;
      wr_rd_data_1                                     <= #1 32'd0                          ;
      wr_rd_data_2                                     <= #1 32'd0                          ;
      csr_cmd_xfer_reg                                 <= #1 1'b0;
      write_en_seq_reg_1                               <= #1 32'h7F20_870C 		    ; 
      write_en_seq_reg_2                               <= #1 32'h7F20_870C 		    ;
      write_dis_seq_reg_1                              <= #1 32'h7F20_870C 		    ; 
      write_dis_seq_reg_2                              <= #1 32'h7F20_870C 		    ;
      mem_auto_status_rd_intr_en                       <= #1 1'd0			    ;
      mem_dlp_failure_ie                               <= #1 1'b0                           ;
      mem_dlp_failure_reg                              <= #1 1'b0                           ;
      mem_illegal_instrn_err_redge_reg                 <= #1 1'b0                           ; 
      mem_dqs_non_toggle_err_redge_reg                 <= #1 1'b0                           ; 
      mem_illegal_strobe_err_redge_reg                 <= #1 1'b0                           ; 
      mem_illegal_addr_err_redge_reg                   <= #1 1'b0                           ; 
      csr_dqs_non_toggle_err_redge_reg                 <= #1 1'b0                           ;     
      mem_illegal_instrn_err_ie         	       <= #1 1'b0			    ;
      mem_dqs_non_toggle_err_ie           	       <= #1 1'b0			    ;

      wdata_xfer_data_rate                             <= #1 1'b0                           ;
      wdata_no_of_pins                                 <= #1 2'd0                           ;
      hyperflash_en	                               <= #1 1'd0                           ;
      mem_page_size                                    <= #1 4'd8;
      no_of_wr_data_bytes                              <= #1 6'd0                           ;
      wr_data_en                                       <= #1 1'b0                           ;
      dlp_failure                                      <= #1 1'b0			    ;
      calib_tap_valid_d1                               <= #1 1'b0			    ;
      mem_dqs_non_toggle_err_d1                        <= #1 1'b0			    ;
      csr_dqs_non_toggle_err_d1                        <= #1 1'b0			    ;
      mem_illegal_instrn_err_d1                        <= #1 1'b0			    ;
      illegal_strobe_err_d1                            <= #1 1'b0			    ;
      slv_mem_err_d1    	                       <= #1 1'b0			    ;
      xspi_csr_xfer_status_intr                        <= #1 1'b0                           ;  
      xspi_mem_xfer_status_intr                        <= #1 1'b0                           ;
      csr_cmd_xfer_valid                               <= #1 1'b0                           ;
      csr_rd_xfer_valid                            <= #1 1'b0                           ;
      status_valid_cntr                                <= #1 5'd0                           ;
      mem_rd_valid_d                        <= #1 1'd0                           ;
      auto_initiate_write_en_seq                       <= #1 1'd1                           ;
      auto_initiate_write_en_seq_2                     <= #1 1'd1                           ;
      auto_initiate_post_wren_seq                      <= #1 1'd0                           ;
      post_wren_seq_data                               <= #1 16'd0                          ;
      auto_initiate_status_read_seq                    <= #1 1'd0                           ;
      auto_initiate_write_dis_seq                      <= #1 1'd0                           ;
      mem_xfer_pending_d	                       <= #1 1'd0                           ;
      mem_all_xfer_done                                <= #1 1'd0			    ;
      csr_rd_xfer_progress                             <= #1 1'b0                           ;
   end 
   else
   begin 
      pres_state                                       <= #1 next_state                           ; 
      data_wait                                        <= #1 next_data_wait                       ;
      csr_aw_ready_o                                   <= #1 next_csr_aw_ready_o                  ; 
      csr_w_ready_o                                    <= #1 next_csr_w_ready_o                   ; 
      csr_b_id_o                                       <= #1 next_csr_b_id_o                      ; 
      csr_b_valid_o                                    <= #1 next_csr_b_valid_o                   ; 
      csr_b_resp_o                                     <= #1 next_csr_b_resp_o                    ; 
      csr_ar_ready_o                                   <= #1 next_csr_ar_ready_o                  ; 
      csr_r_id_o                                       <= #1 next_csr_r_id_o                      ; 
      csr_r_data_o                                     <= #1 next_csr_r_data_o                    ; 
      csr_r_valid_o                                    <= #1 next_csr_r_valid_o                   ; 
      csr_r_resp_o                                     <= #1 next_csr_r_resp_o                    ; 
      csr_r_last_o                                     <= #1 next_csr_r_last_o                    ; 
      csr_aw_addr_reg                                  <= #1 next_csr_aw_addr_reg                 ;  
      csr_aw_id_reg                                    <= #1 next_csr_aw_id_reg                   ;
      axi_addr_reg                                     <= #1 next_axi_addr_reg                    ; 
      axi_burst_reg                                    <= #1 next_axi_burst_reg                   ; 
      axi_len_reg                                      <= #1 next_axi_len_reg                     ; 
      seq_ram_wen                                    <= #1 next_seq_ram_wen                	  ; 
      seq_ram_wr_data                                  <= #1 next_seq_ram_wr_data                 ; 
      seq_ram_addr                                     <= #1 next_seq_ram_addr                    ; 
      rdata_reg_1                                      <= #1 next_rdata_reg_1 			  ;
      rdata_reg_2                                      <= #1 next_rdata_reg_2			  ;
      data_avail_2                                     <= #1 next_data_avail_2			  ;
      seq_ram_key                                      <= #1 next_seq_ram_key                     ; 
      seq_ram_key_valid                                <= #1 next_seq_ram_key_valid               ; 
      seq_ram_lock                                     <= #1 next_seq_ram_lock                    ; 
      seq_ram_unlock                                   <= #1 next_seq_ram_unlock                  ; 
      rd_seq_sel                                    <= #1 next_rd_seq_sel                   ; 
      wr_seq_sel                                    <= #1 next_wr_seq_sel                   ; 
      rd_seq_id                                        <= #1 next_rd_seq_id                       ; 
      wr_seq_id                                        <= #1 next_wr_seq_id                       ; 
      def_seq1_dword1                                  <= #1 32'h 3C00_0C0E                 ;
      def_seq1_dword2                                  <= #1 32'h 0000_0000		    ;
      def_seq1_dword3                                  <= #1 32'h 0000_0000		    ;
      def_seq1_dword4                                  <= #1 32'h 0000_0000		    ;
      def_seq2_dword1                                  <= #1 32'h 0C8E_0820                 ;
      def_seq2_dword2                                  <= #1 32'h 0000_3C00                 ;
      def_seq2_dword3                                  <= #1 32'h 0                         ;
      def_seq2_dword4                                  <= #1 32'h 0                         ;
      ddr_delay_tap                                    <= #1 next_ddr_delay_tap                   ; 
      dqs_mode                                         <= #1 next_dqs_mode                        ; 
      dlp_pattern_cyc_cnt                              <= #1 next_dlp_pattern_cyc_cnt             ;
      auto_dummy_cycle_config                          <= #1 next_auto_dummy_cycle_config         ; 
      read_dummy_cycle_config                          <= #1 next_read_dummy_cycle_config         ; 
      dummy_cycle_HiZ                                  <= #1 next_dummy_cycle_HiZ                 ; 
      dummy_cycle_drive                                <= #1 next_dummy_cycle_drive               ; 
      dqs_non_tgle_to                                  <= #1 next_dqs_non_tgle_to                 ;
      cs_hold                                          <= #1 next_cs_hold                         ; 
      cs_setup                                         <= #1 next_cs_setup                        ; 
      cs_high                                          <= #1 next_cs_high                         ; 
      jhr_en		               		       <= #1 next_jhr_en                          ;		    
      predrive_en	               		       <= #1 next_predrive_en                     ;		    
      dual_seq_mode	               		       <= #1 next_dual_seq_mode                   ;		    
      cont_read_auto_status_en         		       <= #1 next_cont_read_auto_status_en        ;		    
      cmd_no_of_opcode                 		       <= #1 next_cmd_no_of_opcode                ;    
      cmd_xfer_data_rate               		       <= #1 next_cmd_xfer_data_rate              ;      
      cmd_no_of_pins                   		       <= #1 next_cmd_no_of_pins                  ;           
      cmd_opcode                       		       <= #1 next_cmd_opcode                      ;
      auto_status_rd_addr_bytes				       <= #1 next_auto_status_rd_addr_bytes		          ;
      status_reg_rd_xfer_time                          <= #1 next_status_reg_rd_xfer_time         ;
      subseq_status_rd_xfer_time                       <= #1 next_subseq_status_rd_xfer_time      ;
      no_of_auto_status_rd_data_bytes                              <= #1 next_no_of_auto_status_rd_data_bytes                           ;
      no_of_csr_rd_data_bytes                              <= #1 next_no_of_csr_rd_data_bytes             ;
      status_reg_en                                    <= #1 next_status_reg_en                   ;  
      status_monitor_en               	       <= #1 next_status_monitor_en           ;             
      status_monitor_value                    		       <= #1 next_status_monitor_value                   ;    
      status_monitor_bit                      		       <= #1 next_status_monitor_bit                     ;           
      status_no_of_opcode                	       <= #1 next_status_no_of_opcode             ;           
      status_xfer_data_rate            		       <= #1 next_status_xfer_data_rate           ;                  
      status_cmd_data_rate            		       <= #1 next_status_cmd_data_rate           ;                  
      status_no_of_pins                		       <= #1 next_status_no_of_pins               ;           
      status_cmd_opcode                		       <= #1 next_status_cmd_opcode               ; 
      no_of_csr_rd_addr_bytes				       <= #1 next_no_of_csr_rd_addr_bytes               ;
      read_dummy_cycles                                <= #1 next_read_dummy_cycles               ;          
      read_no_of_opcode                	       	       <= #1 next_read_no_of_opcode               ;           
      read_xfer_data_rate            		       <= #1 next_read_xfer_data_rate             ;                  
      read_cmd_data_rate            		       <= #1 next_read_cmd_data_rate             ;                  
      read_no_of_pins                		       <= #1 next_read_no_of_pins                 ;           
      read_cmd_opcode                		       <= #1 next_read_cmd_opcode                 ; 
subseq_rd_xfer_time <= next_subseq_rd_xfer_time;
rd_monitor_en       <= next_rd_monitor_en      ;
rd_monitor_value    <= next_rd_monitor_value   ;
rd_monitor_bit      <= next_rd_monitor_bit     ;
auto_initiate_status_addr <= next_auto_initiate_status_addr;
      mem_illegal_strobe_err_ie                        <= #1 next_mem_illegal_strobe_err_ie       ;
      mem_illegal_addr_err_ie                          <= #1 next_mem_illegal_addr_err_ie         ;
      csr_dqs_non_toggle_err_ie                        <= #1 next_csr_dqs_non_toggle_err_ie       ;
      csr_rd_xfer_intr_en       		       <= #1 next_csr_rd_xfer_intr_en       ; 
      cmd_xfer_intr_en                		       <= #1 next_cmd_xfer_intr_en                ;
      mem_all_xfer_intr_en            		       <= #1 next_mem_all_xfer_intr_en                ;
      csr_rd_xfer_done          		       <= #1 next_csr_rd_xfer_done          ;
      cmd_xfer_done                   		       <= #1 next_cmd_xfer_done                   ;
      mem_xfer_auto_status_rd_done_reg          		       <= #1 next_mem_xfer_auto_status_rd_done_reg          ;
      mem_upper_bound_addr_0          		       <= #1 next_mem_upper_bound_addr_0          ;
      mem_lower_bound_addr_0          		       <= #1 next_mem_lower_bound_addr_0          ;
      hybrid_wrap_cmd_en              		       <= #1 next_hybrid_wrap_cmd_en              ;
      page_incr_en		               		       <= #1 next_page_incr_en                       ; 

      wr_rd_data_1                                     <= #1 next_wr_rd_data_1                    ;
      wr_rd_data_2                                     <= #1 next_wr_rd_data_2                    ;
      csr_cmd_xfer_reg                                 <= #1 next_csr_cmd_xfer_reg;

      write_en_seq_reg_1              		       <= #1 next_write_en_seq_reg_1              ;
      write_en_seq_reg_2              		       <= #1 next_write_en_seq_reg_2              ;
      write_dis_seq_reg_1             		       <= #1 next_write_dis_seq_reg_1             ;   
      write_dis_seq_reg_2             		       <= #1 next_write_dis_seq_reg_2             ;
      mem_auto_status_rd_intr_en       		       <= #1 next_mem_auto_status_rd_intr_en         ;
      mem_dlp_failure_ie                               <= #1 next_mem_dlp_failure_ie              ;
      mem_dlp_failure_reg                              <= #1 next_mem_dlp_failure_reg             ;
      mem_illegal_instrn_err_redge_reg                 <= #1 next_mem_illegal_instrn_err_redge_reg ;
      mem_dqs_non_toggle_err_redge_reg                 <= #1 next_mem_dqs_non_toggle_err_redge_reg ;
      mem_illegal_strobe_err_redge_reg                 <= #1 next_mem_illegal_strobe_err_redge_reg ;
      mem_illegal_addr_err_redge_reg                   <= #1 next_mem_illegal_addr_err_redge_reg ;
      csr_dqs_non_toggle_err_redge_reg                 <= #1 next_csr_dqs_non_toggle_err_redge_reg ;
      mem_illegal_instrn_err_ie                        <= #1 next_mem_illegal_instrn_err_ie       ; 
      mem_dqs_non_toggle_err_ie                        <= #1 next_mem_dqs_non_toggle_err_ie       ;

      wdata_xfer_data_rate                             <= #1 next_wdata_xfer_data_rate            ;
      wdata_no_of_pins                                 <= #1 next_wdata_no_of_pins                ;
      hyperflash_en				       <= #1 next_hyperflash_en			  ;
      mem_page_size                                    <= #1 next_mem_page_size;
      no_of_wr_data_bytes                              <= #1 next_no_of_wr_data_bytes             ;
      wr_data_en                                       <= #1 next_wr_data_en                      ;
      dlp_failure                                      <= #1 next_dlp_failure                     ;
      calib_tap_valid_d1                               <= #1 calib_tap_valid                      ;
      mem_dqs_non_toggle_err_d1                        <= #1 mem_dqs_non_toggle_err               ;
      csr_dqs_non_toggle_err_d1                        <= #1 csr_dqs_non_toggle_err               ;
      mem_illegal_instrn_err_d1                        <= #1 mem_illegal_instrn_err	          ;
      illegal_strobe_err_d1                            <= #1 illegal_strobe_err                   ;
      slv_mem_err_d1                                   <= #1 slv_mem_err	                  ;
      xspi_csr_xfer_status_intr                        <= #1 next_xspi_csr_xfer_status_intr       ;
      xspi_mem_xfer_status_intr                        <= #1 next_xspi_mem_xfer_status_intr       ;
      csr_cmd_xfer_valid                               <= #1 next_csr_cmd_xfer_valid              ;
      csr_rd_xfer_valid                            <= #1 next_csr_rd_xfer_valid           ;
      status_valid_cntr                                <= #1 next_status_valid_cntr               ;
      mem_rd_valid_d                        <= #1 mem_rd_valid              ;
      auto_initiate_write_en_seq                       <= #1 next_auto_initiate_write_en_seq       ;
      auto_initiate_write_en_seq_2                     <= #1 next_auto_initiate_write_en_seq_2     ;
      auto_initiate_post_wren_seq                      <= #1 next_auto_initiate_post_wren_seq     ;
      post_wren_seq_data                               <= #1 next_post_wren_seq_data              ;
      auto_initiate_status_read_seq                    <= #1 next_auto_initiate_status_read_seq    ;
      auto_initiate_write_dis_seq                       <= #1 next_auto_initiate_write_dis_seq     ;
      mem_xfer_pending_d	                       <= #1 mem_xfer_pending                      ;
      mem_all_xfer_done                                <= #1 next_mem_all_xfer_done                    ;
      csr_rd_xfer_progress                             <= #1 next_csr_rd_xfer_progress                    ;
      end
end

always @ *
begin

mem_rd_data_ack = /*(csr_status_xfer_trigger) ?*/ !mem_rd_valid_d && mem_rd_valid/*: 1'b0*/ ;

case (no_of_csr_rd_data_bytes)
7'd0, 7'd1, 7'd2, 7'd3 : valid_cntr_out = 2'd1 ;
7'd4, 7'd5, 7'd6, 7'd7 : valid_cntr_out = 2'd2 ;
default : valid_cntr_out = 2'd0;
endcase
end


always @ *
begin 
        next_auto_initiate_write_en_seq =  auto_initiate_write_en_seq ;
        next_auto_initiate_write_en_seq_2 =  auto_initiate_write_en_seq & hyperflash_en ;
        next_auto_initiate_post_wren_seq =  auto_initiate_post_wren_seq ;
        next_post_wren_seq_data		 =  post_wren_seq_data ;
        next_auto_initiate_status_read_seq = auto_initiate_status_read_seq;
        next_auto_initiate_write_dis_seq =  auto_initiate_write_dis_seq ;
        next_state                     = pres_state                ;
        next_data_wait                 = data_wait                 ;
        next_csr_aw_ready_o            = 1'b0;
        next_csr_w_ready_o             = 1'b0;             
        next_csr_b_id_o                = csr_b_id_o                ;
        next_csr_b_valid_o             = csr_b_valid_o             ;
        next_csr_b_resp_o              = csr_b_resp_o              ;
        next_csr_aw_id_reg             = csr_aw_id_reg             ;
        next_csr_aw_addr_reg           = csr_aw_addr_reg           ;
        next_axi_addr_reg              = axi_addr_reg              ; 
        next_axi_burst_reg             = axi_burst_reg             ;
        next_axi_len_reg               = axi_len_reg               ; 
        next_seq_ram_wen             = 1'b0                      ;
        next_seq_ram_wr_data           = seq_ram_wr_data           ;
        next_seq_ram_addr              = seq_ram_addr              ;
        next_seq_ram_key               = seq_ram_key               ;
        next_seq_ram_key_valid         = seq_ram_key_valid         ;
        next_seq_ram_lock              = seq_ram_lock              ;       
        next_seq_ram_unlock            = seq_ram_unlock            ;       
        next_rd_seq_sel                = rd_seq_sel                   ; 
        next_wr_seq_sel                = wr_seq_sel                   ; 
        next_rd_seq_id                 = rd_seq_id                 ;           
        next_wr_seq_id                 = wr_seq_id                 ;           
        next_ddr_delay_tap             = ddr_delay_tap             ; 
        next_dqs_mode                  = dqs_mode                  ; 
        next_dlp_pattern_cyc_cnt       = dlp_pattern_cyc_cnt       ;
        next_auto_dummy_cycle_config   = auto_dummy_cycle_config   ; 
        next_read_dummy_cycle_config   = read_dummy_cycle_config   ; 
        next_dummy_cycle_HiZ           = dummy_cycle_HiZ           ; 
        next_dummy_cycle_drive         = dummy_cycle_drive         ; 
        next_dqs_non_tgle_to           = dqs_non_tgle_to           ;
        next_cs_hold                   = cs_hold                   ; 
        next_cs_setup                  = cs_setup                  ; 
        next_cs_high                   = cs_high                   ; 
        next_jhr_en		       = (jhr_en) ? 1'b0 : jhr_en  ;		    
        next_predrive_en	       = predrive_en               ;		    
        next_dual_seq_mode	       = dual_seq_mode               ;		    
        next_cont_read_auto_status_en  = cont_read_auto_status_en  ;		    
        next_cmd_no_of_opcode          = cmd_no_of_opcode          ;
        next_cmd_xfer_data_rate        = cmd_xfer_data_rate        ;
        next_cmd_no_of_pins            = cmd_no_of_pins            ;
        next_cmd_opcode                = cmd_opcode                ;
        next_auto_status_rd_addr_bytes             = auto_status_rd_addr_bytes  ;
        next_status_reg_rd_xfer_time   = status_reg_rd_xfer_time   ;
        next_subseq_status_rd_xfer_time = subseq_status_rd_xfer_time   ;
        next_no_of_auto_status_rd_data_bytes       = no_of_auto_status_rd_data_bytes ;
        next_no_of_csr_rd_data_bytes       = no_of_csr_rd_data_bytes ;
        next_status_reg_en             = auto_initiate_status_read_seq & hyperflash_en;
        next_status_monitor_en     = status_monitor_en    ;
        next_status_monitor_value             = status_monitor_value         ;
        next_status_monitor_bit               = status_monitor_bit        ;
        next_status_no_of_opcode       = status_no_of_opcode   ;
        next_status_xfer_data_rate     = status_xfer_data_rate  ;
        next_status_cmd_data_rate      = status_cmd_data_rate  ;
        next_status_no_of_pins         = status_no_of_pins   ;
        next_status_cmd_opcode         = status_cmd_opcode   ;
        next_no_of_csr_rd_addr_bytes         = no_of_csr_rd_addr_bytes  ;
        next_read_dummy_cycles         = read_dummy_cycles       ;
        next_read_no_of_opcode         = read_no_of_opcode   ;
        next_read_xfer_data_rate       = read_xfer_data_rate  ;
        next_read_cmd_data_rate        = read_cmd_data_rate  ;
        next_read_no_of_pins           = read_no_of_pins   ;
        next_read_cmd_opcode           = read_cmd_opcode   ;
next_subseq_rd_xfer_time = subseq_rd_xfer_time;
next_rd_monitor_en       = rd_monitor_en      ;
next_rd_monitor_value    = rd_monitor_value   ;
next_rd_monitor_bit      = rd_monitor_bit     ;
next_auto_initiate_status_addr = auto_initiate_status_addr;
        next_mem_illegal_strobe_err_ie = mem_illegal_strobe_err_ie ;
        next_mem_illegal_addr_err_ie   = mem_illegal_addr_err_ie ;
        next_csr_dqs_non_toggle_err_ie = csr_dqs_non_toggle_err_ie ;
        next_csr_rd_xfer_intr_en = csr_rd_xfer_intr_en ;
        next_cmd_xfer_intr_en          = cmd_xfer_intr_en          ;
        next_mem_all_xfer_intr_en      = mem_all_xfer_intr_en          ;
        next_mem_upper_bound_addr_0    = mem_upper_bound_addr_0    ;
        next_mem_lower_bound_addr_0    = mem_lower_bound_addr_0    ;
        next_hybrid_wrap_cmd_en        = hybrid_wrap_cmd_en        ;
        next_page_incr_en		       = page_incr_en                 ;  
        next_wr_rd_data_1                        = wr_rd_data_1 ;                              
        next_wr_rd_data_2                        = wr_rd_data_2 ;                              
        next_csr_cmd_xfer_reg                    = csr_cmd_xfer_reg;


        next_write_en_seq_reg_1        =   write_en_seq_reg_1      ;
        next_write_en_seq_reg_2        =   write_en_seq_reg_2      ;

                                                    
        next_write_dis_seq_reg_1       =   write_dis_seq_reg_1     ;   
        next_write_dis_seq_reg_2       =   write_dis_seq_reg_2     ;

        next_mem_auto_status_rd_intr_en = mem_auto_status_rd_intr_en;
        next_mem_dlp_failure_ie           = mem_dlp_failure_ie          ;
        next_mem_illegal_instrn_err_ie    = mem_illegal_instrn_err_ie ; 
        next_mem_dqs_non_toggle_err_ie    = mem_dqs_non_toggle_err_ie   ;
        next_cmd_xfer_done               = csr_cmd_xfer_success ? 1'b1 : cmd_xfer_done;
        next_csr_rd_xfer_done            = mem_rd_data_ack & (status_valid_cntr == 5'd1) & csr_rd_xfer_progress ? 1'b1 : csr_rd_xfer_done;
        next_mem_all_xfer_done               = mem_xfer_pending_fedge ? 1'b1 : mem_all_xfer_done;
        next_mem_xfer_auto_status_rd_done_reg      = mem_xfer_auto_status_rd_done ? 1'b1 : mem_xfer_auto_status_rd_done_reg;
        next_xspi_mem_xfer_status_intr   = mem_auto_status_rd_intr_en  && mem_xfer_auto_status_rd_done_reg ? 1'b1 :
					   mem_all_xfer_intr_en && mem_all_xfer_done ? 1'b1 :
					   mem_dqs_non_toggle_err_ie && mem_dqs_non_toggle_err_redge_reg  ? 1'b1 :
                                           mem_illegal_instrn_err_ie && mem_illegal_instrn_err_redge_reg ? 1'b1:
                                           mem_dlp_failure_ie  && mem_dlp_failure_reg ? 1'b1 : 
                                           mem_illegal_strobe_err_ie && mem_illegal_strobe_err_redge_reg ? 1'b1:
                                           mem_illegal_addr_err_ie && mem_illegal_addr_err_redge_reg ? 1'b1: 1'b0 ;
 
        next_xspi_csr_xfer_status_intr =    cmd_xfer_intr_en && cmd_xfer_done ? 1'b1 :
                                            csr_rd_xfer_intr_en && csr_rd_xfer_done ? 1'b1 :
                                            csr_dqs_non_toggle_err_ie && csr_dqs_non_toggle_err_redge_reg  ? 1'b1: 1'b0; 
        next_mem_dlp_failure_reg                 = dlp_failure ? 1'b1 : mem_dlp_failure_reg ;
        next_mem_dqs_non_toggle_err_redge_reg    = mem_dqs_non_toggle_err_redge ? 1'b1 : mem_dqs_non_toggle_err_redge_reg;
        next_mem_illegal_instrn_err_redge_reg    = mem_illegal_instrn_err_redge ? 1'b1 : mem_illegal_instrn_err_redge_reg;
        next_csr_dqs_non_toggle_err_redge_reg    = csr_dqs_non_toggle_err_redge ? 1'b1 : csr_dqs_non_toggle_err_redge_reg;
        next_mem_illegal_strobe_err_redge_reg    = mem_illegal_strobe_err_redge ? 1'b1 : mem_illegal_strobe_err_redge_reg;
        next_mem_illegal_addr_err_redge_reg      = mem_illegal_addr_err_redge ? 1'b1 : mem_illegal_addr_err_redge_reg;

        next_wdata_xfer_data_rate                = wdata_xfer_data_rate ;
        next_wdata_no_of_pins                    = wdata_no_of_pins     ;
        next_hyperflash_en			 = hyperflash_en        ;
        next_mem_page_size                       = mem_page_size;
        next_no_of_wr_data_bytes                 = no_of_wr_data_bytes  ;
        next_wr_data_en                          = wr_data_en ;
        next_csr_ar_ready_o                       =  1'b0;
        next_csr_r_id_o                           = csr_r_id_o        ;
        next_csr_r_data_o                         = csr_r_data_o      ;
        next_csr_r_valid_o                        = csr_r_valid_o     ;
        next_csr_r_resp_o                         = csr_r_resp_o      ;
        next_csr_r_last_o                         = csr_r_last_o      ;
        next_rdata_reg_1                          = rdata_reg_1 ;
        next_rdata_reg_2                          = rdata_reg_2 ;
        next_data_avail_2                         = data_avail_2;
        next_wr_seq_sel                        = 1'b0;
        next_rd_seq_sel                        = 1'b0;
        next_csr_cmd_xfer_valid                   = csr_cmd_xfer_valid & csr_cmd_xfer_ack ? 1'b0 : csr_cmd_xfer_valid;
        next_csr_rd_xfer_valid                = csr_rd_xfer_valid & csr_rd_xfer_ack ? 1'b0 : csr_rd_xfer_valid ;
        next_csr_rd_xfer_progress             = csr_rd_xfer_valid ? 1'b1 : csr_rd_xfer_done ? 1'b0 : csr_rd_xfer_progress;


       if (mem_rd_data_ack)
       begin
        next_status_valid_cntr  = csr_cmd_xfer_reg ? status_valid_cntr :  status_valid_cntr  - 2'd1;
        if (monitoring_xfer)  //monitoring transfers
        begin
          case(no_of_auto_status_rd_data_bytes)
            3'd0: next_wr_rd_data_2    = mem_rd_data[7:0];
            3'd1: next_wr_rd_data_2    = mem_rd_data[15:0];
            3'd2: next_wr_rd_data_2    = mem_rd_data[23:0];
            default: next_wr_rd_data_2 = mem_rd_data;
          endcase
	end
        else
	begin
          case(status_valid_cntr)
          2'd1: 
          next_wr_rd_data_1    = mem_rd_data;
          2'd2: 
          next_wr_rd_data_2    = mem_rd_data;
          endcase
	end
       end  
       else
       begin
        next_status_valid_cntr  =  csr_cmd_xfer_reg ?  2'd2 : csr_rd_xfer_valid ? valid_cntr_out : status_valid_cntr;
        next_csr_cmd_xfer_reg  =  csr_cmd_xfer_success ? 1'b0 : csr_cmd_xfer_valid ? 1'b1 : csr_cmd_xfer_reg;
       end                             

	if(calib_tap_valid_redge)
	begin
	   case(dlp_pattern_cyc_cnt)
	      3'd1: next_dlp_failure = (!(& calib_tap_out[1:0]));
	      3'd2: next_dlp_failure = (!(& calib_tap_out[3:0]));
	      3'd3: next_dlp_failure = (!(& calib_tap_out[5:0]));
	      3'd4: next_dlp_failure = (!(& calib_tap_out[7:0]));
	      default : next_dlp_failure = dlp_failure;
	   endcase
	end
	else
	begin
	      next_dlp_failure = 1'b0;
	end
//FSM starts here
case (pres_state)
 IDLE:  
    if (csr_r_valid_o)
    begin
      next_csr_r_valid_o          = (csr_r_ready_i) ? 1'b0 : csr_r_valid_o;
      next_csr_r_last_o           = (csr_r_ready_i) ? 1'b0 : csr_r_last_o ;
        next_csr_aw_ready_o         = 1'b0;
        next_csr_ar_ready_o         = 1'b0;
        next_csr_w_ready_o          = 1'b0;
        next_state                  = pres_state;
   end
  else if (csr_b_valid_o)
    begin
      next_csr_b_valid_o          = (csr_b_ready_i) ? 1'b0 : csr_b_valid_o; 
        next_csr_aw_ready_o         = 1'b0;
        next_csr_ar_ready_o         = 1'b0;
        next_csr_w_ready_o          = 1'b0;
        next_state                  = pres_state;
   end

else if (csr_aw_valid_i || data_wait )
 begin
  if (csr_aw_valid_i & wr_addr_eq_seq_ram)
  begin
             next_csr_aw_ready_o  =  1'b1;
             next_csr_ar_ready_o  =  1'b0;
             next_axi_addr_reg    = csr_aw_addr_i[11:0];
             next_axi_burst_reg   = csr_aw_burst_i; 
             next_axi_len_reg     = csr_aw_len_i +1;          //1
	     next_csr_b_id_o      = csr_aw_id_i;
             next_csr_w_ready_o   =  1'b1 ;
             next_state           = WRITE_SEQ_RAM ;
            // next_data_wait       = (!csr_w_valid_i) ? 1'b1 : 1'b0; 

  end
  else if (csr_w_valid_i)
  begin
        next_csr_b_valid_o          = 1'b1; 
        next_csr_b_id_o             = csr_aw_id_final;
        next_csr_aw_ready_o         = data_wait ? 1'b0 : 1'b1;
        next_csr_ar_ready_o         = 1'b0;
        next_csr_w_ready_o          = data_wait ? 1'b0 : 1'b1;   
        next_state                  = pres_state;
        next_data_wait              = 1'b0;
   
    if(csr_wr_addr_space)
    begin
        next_csr_b_resp_o           = 2'd0;   
    case (csr_aw_addr_final[9:0])
           `SEQ_RAM_KEY:
                   begin
                      next_seq_ram_key             = csr_w_data_i;
                      next_seq_ram_key_valid       = !(|(`SEQ_RAM_KEY_VALUE ^ csr_w_data_i));
                      next_csr_b_resp_o           = !(|(`SEQ_RAM_KEY_VALUE ^ csr_w_data_i)) ? 2'd0 : 2'd2;   
                   end
            `SEQ_RAM_ACCESS:
                   begin
                      next_seq_ram_unlock            = seq_ram_key_valid ? csr_w_data_i[1] : seq_ram_unlock;
                      next_seq_ram_lock              = seq_ram_key_valid ? csr_w_data_i[0] : seq_ram_lock;
                      next_seq_ram_key_valid         = 1'b0;
                   end
            `SEQ_ID_SEL_REG:
                  begin
                     next_rd_seq_sel              = csr_w_data_i[23];
                     next_wr_seq_sel              = csr_w_data_i[22];
                     next_rd_seq_id                  = csr_w_data_i[21:11];
                     next_wr_seq_id                  = csr_w_data_i[10:0];
                  end

            `DATA_LEARNING_PATTERN_CONFIG:
                   begin
                      next_ddr_delay_tap             = csr_w_data_i[10:3];
                      next_dlp_pattern_cyc_cnt       = csr_w_data_i[2:0];
                   end
            `DUMMY_CYC_CONFIG:
                   begin
                      next_dummy_cycle_HiZ           = csr_w_data_i[15:8];
                      next_dummy_cycle_drive         = csr_w_data_i[7:0];
                   end
             `TIMING_CONFIG_REG:
                   begin
                      next_dqs_non_tgle_to           = csr_w_data_i[13:9];
                      next_cs_high                   = csr_w_data_i[8:4];
                      next_cs_hold                   = csr_w_data_i[3:2];
                      next_cs_setup                  = csr_w_data_i[1:0];
                   end
             `FLASH_MODE_XFER_SEL:
                   begin
                      next_cont_read_auto_status_en  = csr_w_data_i[11];
                      next_dual_seq_mode	     = csr_w_data_i[10];
                      next_predrive_en		     = csr_w_data_i[9];
                      next_mem_page_size             = csr_w_data_i[8:5];
		      next_hyperflash_en	     = csr_w_data_i[4];
		      next_page_incr_en		     = csr_w_data_i[3]; 
                      next_hybrid_wrap_cmd_en        = csr_w_data_i[2];
                      next_dqs_mode                  = csr_w_data_i[1];
                      next_jhr_en		     = csr_w_data_i[0];
                   end

             `WR_RD_DATA_REG_1:
                  begin
                     next_wr_rd_data_1                  = csr_w_data_i[31:0];
                  end
             `WR_RD_DATA_REG_2:
                  begin
                     next_wr_rd_data_2                  = csr_w_data_i[31:0];
                  end

             `CMD_DATA_XFER_REG:
                    begin
		     next_no_of_wr_data_bytes	     = csr_w_data_i[30:25];
                     next_csr_cmd_xfer_valid         = csr_w_data_i[24] ? 1'b1 : csr_cmd_xfer_valid  ;
                     next_wdata_xfer_data_rate       = csr_w_data_i[23];
                     next_wdata_no_of_pins           = csr_w_data_i[22:21];
                     next_wr_data_en                 = csr_w_data_i[20];
		     next_cmd_no_of_opcode	     = csr_w_data_i[19];
		     next_cmd_xfer_data_rate         = csr_w_data_i[18];
		     next_cmd_no_of_pins             = csr_w_data_i[17:16];
		     next_cmd_opcode		     = csr_w_data_i[15:0];
                    end

               `CSR_RD_CONFIG_REG_1:
                    begin
		     next_read_cmd_data_rate        = csr_w_data_i[31];
		     next_no_of_csr_rd_addr_bytes          = csr_w_data_i[30:28];
                    next_no_of_csr_rd_data_bytes         = csr_w_data_i[27:21];
                     next_csr_rd_xfer_valid          = csr_w_data_i[20] ? 1'b1 : csr_rd_xfer_valid ;
                     next_read_no_of_opcode          = csr_w_data_i [19];
		     next_read_xfer_data_rate        = csr_w_data_i[18];
		     next_read_no_of_pins            = csr_w_data_i[17:16];
		     next_read_cmd_opcode	     = csr_w_data_i[15:0];
                    end

              `CSR_RD_CONFIG_REG_2:
                    begin
                     next_read_dummy_cycle_config   = csr_w_data_i[27:23];
                     next_subseq_rd_xfer_time        = csr_w_data_i [22:5];
		     next_rd_monitor_en             = csr_w_data_i[4];
		     next_rd_monitor_value           = csr_w_data_i[3];
		     next_rd_monitor_bit	     = csr_w_data_i[2:0];
                    end

               `AUTO_STATUS_REG_RD_CONFIG_1:
                    begin
		     next_status_cmd_data_rate       = csr_w_data_i[25];
		     next_status_monitor_en          = csr_w_data_i[24];
		     next_status_monitor_value       = csr_w_data_i[23];
		     next_status_monitor_bit	     = csr_w_data_i[22:20];
                     next_status_no_of_opcode        = csr_w_data_i [19];
		     next_status_xfer_data_rate      = csr_w_data_i[18];
		     next_status_no_of_pins          = csr_w_data_i[17:16];
		     next_status_cmd_opcode	     = csr_w_data_i[15:0];
                    end

               `AUTO_STATUS_REG_RD_CONFIG_2:
                   begin
                    next_auto_dummy_cycle_config         = csr_w_data_i[28:24];
		    next_auto_status_rd_addr_bytes       = csr_w_data_i[23:21];
                    next_subseq_status_rd_xfer_time      = csr_w_data_i[20:3];
                    next_no_of_auto_status_rd_data_bytes = csr_w_data_i[2:0];
                   end

               `AUTO_STATUS_REG_RD_CONFIG_3:
                  begin
                     next_status_reg_rd_xfer_time       =  csr_w_data_i[31:1];
                     next_auto_initiate_status_read_seq =  csr_w_data_i[0];
                  end

               `AUTO_STATUS_REG_RD_CONFIG_4:
                  begin
                     next_auto_initiate_status_addr =  csr_w_data_i[31:0];
                  end

            `XSPI_AUTO_INITIATE_WRITE_EN_REG:
                  begin
                     next_post_wren_seq_data           =  csr_w_data_i[31:16];
                     next_auto_initiate_post_wren_seq  =  csr_w_data_i[1]; // specific to hyperflash; requires 3 write enable sequence;
//First two write enables are hardcoded in main controller; 3rd write enable
//addres is hardcoded and write data is taken from post_wren_seq_data
                     next_auto_initiate_write_en_seq   =  csr_w_data_i[0];
                  end
             `XSPI_AUTO_INITIATE_WRITE_DIS_REG:
                  begin
                     next_auto_initiate_write_dis_seq   =  csr_w_data_i[0];
                  end 

  
              `XSPI_CSR_INTR_EN_REG:
                   begin
                      next_csr_dqs_non_toggle_err_ie    = csr_w_data_i[2];
                      next_csr_rd_xfer_intr_en          = csr_w_data_i[1];
                      next_cmd_xfer_intr_en             = csr_w_data_i[0];
                   end

              `XSPI_MEM_INTR_EN_REG:
                  begin
		      next_mem_auto_status_rd_intr_en   = csr_w_data_i[6];
                      next_mem_all_xfer_intr_en         = csr_w_data_i[5];
		      next_mem_illegal_addr_err_ie      = csr_w_data_i[4];
		      next_mem_illegal_strobe_err_ie    = csr_w_data_i[3];
                      next_mem_dlp_failure_ie           = csr_w_data_i[2];
                      next_mem_illegal_instrn_err_ie    = csr_w_data_i[1];    
		      next_mem_dqs_non_toggle_err_ie    = csr_w_data_i[0];
                  end

	      `XSPI_MEM_UPPER_BOUND_ADDR_0:
		    begin
		       next_mem_upper_bound_addr_0    =  csr_w_data_i[31:0];
	            end

	      `XSPI_MEM_LOWER_BOUND_ADDR_0:
		    begin
		       next_mem_lower_bound_addr_0    =  csr_w_data_i[31:0];
                    end


               `XSPI_WRITE_EN_SEQ_REG_1:
                    begin
                     next_write_en_seq_reg_1         = csr_w_data_i[31:0];
                    end

               `XSPI_WRITE_EN_SEQ_REG_2:
                    begin
                     next_write_en_seq_reg_2         = csr_w_data_i[31:0];
                    end

               `XSPI_WRITE_DIS_SEQ_REG_1:
                    begin
                     next_write_dis_seq_reg_1         = csr_w_data_i[31:0];
                    end

               `XSPI_WRITE_DIS_SEQ_REG_2:
                    begin
                     next_write_dis_seq_reg_2         = csr_w_data_i[31:0];
                    end

               `DEF_SEQ1_DWORD1,              
               `DEF_SEQ1_DWORD2,              
               `DEF_SEQ1_DWORD3,              
               `DEF_SEQ1_DWORD4,              
               `DEF_SEQ2_DWORD1,              
               `DEF_SEQ2_DWORD2,              
               `DEF_SEQ2_DWORD3,              
               `DEF_SEQ2_DWORD4,             
               `XSPI_CSR_STATUS_REG,
               `XSPI_MEM_STATUS_REG:
                begin
                      next_csr_b_resp_o              = 2'b10                     ;
                end 
                 default :                
                   begin 
                      next_csr_b_resp_o              = 2'b11                     ;
                      next_seq_ram_key               = seq_ram_key               ; 
                      next_seq_ram_unlock            = seq_ram_unlock            ; 
                      next_seq_ram_lock              = seq_ram_lock              ; 
                      next_rd_seq_sel                = rd_seq_sel                   ; 
                      next_wr_seq_sel                = wr_seq_sel                   ; 
                      next_rd_seq_id                 = rd_seq_id                 ; 
                      next_wr_seq_id                 = wr_seq_id                 ; 
                      next_ddr_delay_tap             = ddr_delay_tap             ; 
                      next_dqs_mode                  = dqs_mode                  ; 
                      next_dlp_pattern_cyc_cnt       = dlp_pattern_cyc_cnt       ;
                      next_auto_dummy_cycle_config   = auto_dummy_cycle_config   ; 
                      next_read_dummy_cycle_config   = read_dummy_cycle_config   ; 
                      next_dummy_cycle_HiZ           = dummy_cycle_HiZ           ; 
                      next_dummy_cycle_drive         = dummy_cycle_drive         ;
                      next_dqs_non_tgle_to           = dqs_non_tgle_to           ;  
                      next_cs_hold                   = cs_hold                   ; 
                      next_cs_setup                  = cs_setup                  ; 
                      next_cs_high                   = cs_high                   ; 
                      next_jhr_en		     = jhr_en                    ;
                      next_predrive_en		     = predrive_en               ;
                      next_dual_seq_mode	     = dual_seq_mode             ;
                      next_cont_read_auto_status_en  = cont_read_auto_status_en  ;
                      next_wdata_xfer_data_rate      = wdata_xfer_data_rate      ;
                      next_wdata_no_of_pins          = wdata_no_of_pins          ;
		      next_hyperflash_en	     = hyperflash_en		 ;
                      next_no_of_wr_data_bytes       = no_of_wr_data_bytes       ;
                      next_wr_data_en                = wr_data_en                ;
                      next_cmd_no_of_opcode          = cmd_no_of_opcode          ;
                      next_cmd_xfer_data_rate        = cmd_xfer_data_rate        ;
                      next_cmd_no_of_pins            = cmd_no_of_pins            ;
                      next_cmd_opcode                = cmd_opcode                ;
                      next_auto_status_rd_addr_bytes             = auto_status_rd_addr_bytes             ;
                      next_status_reg_rd_xfer_time   = status_reg_rd_xfer_time   ;
                      next_subseq_status_rd_xfer_time = subseq_status_rd_xfer_time;
                      next_no_of_csr_rd_data_bytes       = no_of_csr_rd_data_bytes       ;
                      next_status_reg_en             = status_reg_en             ;
                      next_status_monitor_en     = status_monitor_en     ;
                      next_status_monitor_value             = status_monitor_value             ;
                      next_status_monitor_bit               = status_monitor_bit               ;
                      next_status_no_of_opcode       = status_no_of_opcode       ;
                      next_status_xfer_data_rate     = status_xfer_data_rate     ;
                      next_status_cmd_data_rate      = status_cmd_data_rate      ;
                      next_status_no_of_pins         = status_no_of_pins         ;
                      next_status_cmd_opcode         = status_cmd_opcode         ;
                      next_no_of_csr_rd_addr_bytes         = no_of_csr_rd_addr_bytes         ;
                      next_read_dummy_cycles         = read_dummy_cycles         ;
                      next_read_no_of_opcode         = read_no_of_opcode         ;
                      next_read_xfer_data_rate       = read_xfer_data_rate       ;
                      next_read_cmd_data_rate        = read_cmd_data_rate       ;
                      next_read_no_of_pins           = read_no_of_pins           ;
                      next_read_cmd_opcode           = read_cmd_opcode           ;
                      next_mem_illegal_strobe_err_ie = mem_illegal_strobe_err_ie ;
                      next_mem_illegal_addr_err_ie   = mem_illegal_addr_err_ie   ;
                      next_csr_dqs_non_toggle_err_ie = csr_dqs_non_toggle_err_ie ;
                      next_csr_rd_xfer_intr_en = csr_rd_xfer_intr_en ;
                      next_cmd_xfer_intr_en          = cmd_xfer_intr_en          ;
                      next_mem_all_xfer_intr_en      = mem_all_xfer_intr_en          ;
                      next_mem_upper_bound_addr_0    = mem_upper_bound_addr_0    ;
                      next_mem_lower_bound_addr_0    = mem_lower_bound_addr_0    ;
                      next_hybrid_wrap_cmd_en        = hybrid_wrap_cmd_en        ;
        	      next_page_incr_en		     = page_incr_en                 ;  

                      next_wr_rd_data_1              = wr_rd_data_1              ;                              
                      next_wr_rd_data_2              = wr_rd_data_2              ;                              

                      next_write_en_seq_reg_1        = write_en_seq_reg_1        ;
                      next_write_en_seq_reg_2        = write_en_seq_reg_2        ;
                      next_write_dis_seq_reg_1       = write_dis_seq_reg_1       ;   
                      next_write_dis_seq_reg_2       = write_dis_seq_reg_2       ;
                    end         
                   endcase
          end
          else
          begin
                      next_csr_b_resp_o              = 2'b11                     ;
          end
   end
 else
  begin
        next_csr_b_valid_o          = 1'b0; 
        next_csr_b_resp_o           = 2'd0;   
        next_csr_aw_ready_o         = data_wait ? 1'b0 : 1'b1;
        next_csr_ar_ready_o         = 1'b0;
        next_csr_w_ready_o          = 1'b1;
        next_csr_aw_id_reg          = csr_aw_id_i;
        next_csr_aw_addr_reg        = csr_aw_addr_i;
        next_data_wait              = 1'b1; 
        next_state                  = pres_state;
  end
            
  end
  else if (csr_ar_valid_i  )
   begin
     next_csr_r_valid_o          = 1'b1; 
     next_csr_r_last_o           = 1'b1;
     next_csr_r_id_o             = csr_ar_id_i;
     next_csr_aw_ready_o         = 1'b0;
     next_csr_ar_ready_o         = 1'b1;
     next_csr_w_ready_o          = 1'b0;
     next_state                  = pres_state;

    if(csr_rd_addr_space)
    begin
     next_csr_r_resp_o           = 2'd0;   
     case (csr_ar_addr_i[9:0])
               `SEQ_RAM_KEY:                  next_csr_r_data_o       = seq_ram_key;
               `SEQ_RAM_ACCESS:               next_csr_r_data_o       = {30'd0,seq_ram_unlock,seq_ram_lock};
               `SEQ_ID_SEL_REG:               next_csr_r_data_o       = {8'd0,rd_seq_sel,wr_seq_sel,rd_seq_id, wr_seq_id};
               `DEF_SEQ1_DWORD1:              next_csr_r_data_o       = def_seq1_dword1;
               `DEF_SEQ1_DWORD2:              next_csr_r_data_o       = def_seq1_dword2;
               `DEF_SEQ1_DWORD3:              next_csr_r_data_o       = def_seq1_dword3;
               `DEF_SEQ1_DWORD4:              next_csr_r_data_o       = def_seq1_dword4;
               `DEF_SEQ2_DWORD1:              next_csr_r_data_o       = def_seq2_dword1;
               `DEF_SEQ2_DWORD2:              next_csr_r_data_o       = def_seq2_dword2;
               `DEF_SEQ2_DWORD3:              next_csr_r_data_o       = def_seq2_dword3;
               `DEF_SEQ2_DWORD4:              next_csr_r_data_o       = def_seq2_dword4;
               `DATA_LEARNING_PATTERN_CONFIG: next_csr_r_data_o       = {21'd0,ddr_delay_tap,dlp_pattern_cyc_cnt}; 
               `DUMMY_CYC_CONFIG:             next_csr_r_data_o       = {16'd0, dummy_cycle_HiZ, dummy_cycle_drive};
               `TIMING_CONFIG_REG:            next_csr_r_data_o       = {18'd0,dqs_non_tgle_to,cs_high,cs_hold,cs_setup};
               `FLASH_MODE_XFER_SEL:          next_csr_r_data_o       = {19'd0,cont_read_auto_status_en,dual_seq_mode,predrive_en,mem_page_size,hyperflash_en,page_incr_en,hybrid_wrap_cmd_en,dqs_mode,jhr_en};
             `WR_RD_DATA_REG_1:  next_csr_r_data_o = wr_rd_data_1;
             `WR_RD_DATA_REG_2:  next_csr_r_data_o = wr_rd_data_2;
 
              `CMD_DATA_XFER_REG :   next_csr_r_data_o      = {1'd0,no_of_wr_data_bytes,1'd0,wdata_xfer_data_rate,wdata_no_of_pins,wr_data_en,cmd_no_of_opcode,cmd_xfer_data_rate,cmd_no_of_pins,cmd_opcode};
               `CSR_RD_CONFIG_REG_1 :            next_csr_r_data_o      = {read_cmd_data_rate,no_of_csr_rd_addr_bytes,no_of_csr_rd_data_bytes,1'b0,read_no_of_opcode,read_xfer_data_rate,read_no_of_pins,read_cmd_opcode};
               `CSR_RD_CONFIG_REG_2 :            next_csr_r_data_o      = {4'd0,read_dummy_cycle_config,subseq_rd_xfer_time,rd_monitor_en,rd_monitor_value,rd_monitor_bit};
               `AUTO_STATUS_REG_RD_CONFIG_1 :            next_csr_r_data_o      = {6'd0,status_cmd_data_rate,status_monitor_en,status_monitor_value,status_monitor_bit,status_no_of_opcode,status_xfer_data_rate,status_no_of_pins,status_cmd_opcode};
               `AUTO_STATUS_REG_RD_CONFIG_2 :            next_csr_r_data_o      = {3'd0,auto_dummy_cycle_config,auto_status_rd_addr_bytes ,subseq_status_rd_xfer_time,no_of_auto_status_rd_data_bytes}   ;
               `AUTO_STATUS_REG_RD_CONFIG_3 :            next_csr_r_data_o      = {status_reg_rd_xfer_time ,auto_initiate_status_read_seq}   ;
               `AUTO_STATUS_REG_RD_CONFIG_4 :            next_csr_r_data_o      = auto_initiate_status_addr  ;

             `XSPI_AUTO_INITIATE_WRITE_EN_REG:
                  begin
                     next_csr_r_data_o                               = {14'd0,post_wren_seq_data,auto_initiate_post_wren_seq,auto_initiate_write_en_seq};
                  end
             `XSPI_AUTO_INITIATE_WRITE_DIS_REG:
                  begin
                     next_csr_r_data_o                               = {31'd0,auto_initiate_write_dis_seq};
                  end

               `XSPI_CSR_INTR_EN_REG   :          next_csr_r_data_o  = {29'd0,csr_dqs_non_toggle_err_ie,csr_rd_xfer_intr_en,cmd_xfer_intr_en}; 
               `XSPI_CSR_STATUS_REG: 
                 begin
                    next_csr_r_data_o                              = {29'd0,csr_dqs_non_toggle_err_redge_reg,csr_rd_xfer_done,cmd_xfer_done};

                    next_csr_dqs_non_toggle_err_redge_reg          = csr_dqs_non_toggle_err_redge ? 1'b1 : 1'b0 ;
                    next_cmd_xfer_done                             = csr_cmd_xfer_success ? 1'b1 : 1'b0;
                    next_csr_rd_xfer_done = mem_rd_data_ack & (status_valid_cntr == 5'd1) ? 1'b1 : 1'b0;     
                 end
              `XSPI_MEM_INTR_EN_REG:   
                                      next_csr_r_data_o              = {25'd0,mem_auto_status_rd_intr_en,mem_all_xfer_intr_en,mem_illegal_addr_err_ie,mem_illegal_strobe_err_ie,mem_dlp_failure_ie, mem_illegal_instrn_err_ie,mem_dqs_non_toggle_err_ie};

              `XSPI_MEM_STATUS_REG: 
		begin
			    next_csr_r_data_o                        = {25'd0,mem_xfer_auto_status_rd_done_reg,mem_all_xfer_done,mem_illegal_addr_err_redge_reg,mem_illegal_strobe_err_redge_reg,mem_dlp_failure_reg,mem_illegal_instrn_err_redge_reg ,mem_dqs_non_toggle_err_redge_reg}; 
                            next_mem_illegal_addr_err_redge_reg      = mem_illegal_addr_err_redge ? 1'b1 : 1'b0 ;
                            next_mem_illegal_strobe_err_redge_reg    = mem_illegal_strobe_err_redge ? 1'b1 : 1'b0 ;
                            next_mem_dlp_failure_reg                 = dlp_failure ? 1'b1 : 1'b0 ;
                            next_mem_dqs_non_toggle_err_redge_reg    = mem_dqs_non_toggle_err_redge ? 1'b1 : 1'b0 ;
                            next_mem_illegal_instrn_err_redge_reg    = mem_illegal_instrn_err_redge ? 1'b1 : 1'b0 ;
			    next_mem_all_xfer_done		     = mem_xfer_pending_fedge ? 1'b1 : 1'b0;
        	            next_mem_xfer_auto_status_rd_done_reg      	     = mem_xfer_auto_status_rd_done ? 1'b1 : 1'b0;
		end

              `XSPI_MEM_UPPER_BOUND_ADDR_0:
	       begin
	          next_csr_r_data_o                                = mem_upper_bound_addr_0 ;
	       end
	      `XSPI_MEM_LOWER_BOUND_ADDR_0:
	       begin
	          next_csr_r_data_o                                = mem_lower_bound_addr_0 ;
	       end
              `XSPI_WRITE_EN_SEQ_REG_1 :
               begin
                  next_csr_r_data_o                                = {write_en_seq_reg_1}   ;
               end
              `XSPI_WRITE_EN_SEQ_REG_2 :
               begin
                  next_csr_r_data_o                                = {write_en_seq_reg_2}   ;
               end
              `XSPI_WRITE_DIS_SEQ_REG_1 :
               begin 
                  next_csr_r_data_o                                = {write_dis_seq_reg_1}  ;
               end
              `XSPI_WRITE_DIS_SEQ_REG_2 :
               begin
                  next_csr_r_data_o                                = {write_dis_seq_reg_2}  ;
               end

               default:
	       begin
			next_csr_r_data_o = csr_r_data_o;
                        next_csr_r_resp_o = 2'b11;
                        next_state        = pres_state;
               end                               
            endcase 
         end
         else
         begin
                        next_csr_r_resp_o = 2'b11;
         end
               
     end   
          //}

WRITE_SEQ_RAM:
   begin
         next_csr_aw_ready_o =1'b0;
           if (csr_w_valid_i && csr_w_ready_o) // sequence RAM address space  (first 2k) - of which only first 1K is alloted to sequence RAM
          begin
             if(seq_ram_lock || (!seq_ram_unlock))
             begin
                next_seq_ram_wen       = 1'b0;
                next_seq_ram_wr_data     = seq_ram_wr_data;
                next_seq_ram_addr        = seq_ram_addr;
                next_axi_addr_reg        = (axi_burst_reg == 'd0)?axi_addr_reg:axi_addr_reg + (csr_aw_size_i <<16'b1);
                if(csr_w_last_i)
                begin
                next_state               = IDLE;
                next_csr_w_ready_o       = 1'b0;
                next_csr_b_valid_o       = 1'b1;
                next_csr_b_resp_o        = 2'b10;
                end
                else
                begin
                next_state               = pres_state;
                next_csr_w_ready_o       = csr_w_ready_o;
                next_csr_b_valid_o       = 1'b0;
                next_csr_b_resp_o        = csr_b_resp_o;
                end
             end
             else
             begin
                next_seq_ram_wen      = 1'b1;
                next_seq_ram_wr_data    = csr_w_data_i;
                next_seq_ram_addr       = axi_addr_reg[9:0]; 
                next_axi_addr_reg       = (axi_burst_reg == 'd0)?axi_addr_reg:axi_addr_reg + (csr_aw_size_i <<16'b1);
                next_axi_len_reg        = (axi_len_reg_eq0)?axi_len_reg : (axi_len_reg_minus1);
                if(csr_w_last_i)
                begin
                next_state              = IDLE;
                next_csr_w_ready_o      = 1'b0;
                next_csr_b_valid_o      = 1'b1;
                next_csr_b_resp_o       =(axi_len_reg_eq1) ? 2'b00 : 2'b10;
                end
                else
                begin
                next_state             = pres_state;
                next_csr_w_ready_o     = csr_w_ready_o;
                next_csr_b_valid_o     = 1'b0;
                next_csr_b_resp_o      = csr_b_resp_o;
                end 
             end
          end
        else
         begin
          next_state                  = pres_state;
          next_csr_w_ready_o          = csr_w_ready_o;

         end
  end

   default : 
   begin 
      next_csr_r_valid_o     = csr_r_valid_o;
      next_csr_r_data_o      = csr_r_data_o;
      next_csr_r_last_o      = csr_r_last_o;
      next_axi_len_reg       = axi_len_reg;
      next_state             = pres_state;
      next_csr_b_valid_o     = csr_b_valid_o;
      next_csr_aw_ready_o    = csr_aw_ready_o;
      next_csr_ar_ready_o    = csr_ar_ready_o;
      next_csr_w_ready_o     = csr_w_ready_o;
   end

     endcase
end   //}


endmodule


