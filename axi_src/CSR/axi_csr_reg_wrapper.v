
`timescale 1ps/1ps

`include "csr_defines.vh"

module axi_csr_reg_wrapper (

//GLOBAL SYSTEM SIGNALS
		axi_clk,
		axi_rst_n,
		mem_clk,

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

// From AXI slave

 		mem_xfer_pending,  


// TO MAIN CONTROLLER
                rd_seq_sel,
                wr_seq_sel,
                rd_seq_id ,           
                wr_seq_id,           
                def_seq1_dword1,     
                def_seq1_dword2,     
                def_seq1_dword3,     
                def_seq1_dword4,     
                def_seq2_dword1,     
                def_seq2_dword2,     
                def_seq2_dword3,     
                def_seq2_dword4,

                hybrid_wrap_cmd_en, //To AXI slave
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

                status_reg_en, // specific to hyperflash

// TO MEMORY XFER SM
                ddr_delay_tap       ,
                dqs_mode            ,
                dlp_pattern_cyc_cnt ,

                jhr_en              ,
                predrive_en         ,
                dual_seq_mode       ,
                cont_read_auto_status_en       ,

   		dummy_cycle_config,           
                dummy_cycle_HiZ     ,
                dummy_cycle_drive   ,

                dqs_non_tgle_to     ,
                cs_hold             ,
                cs_setup            ,
                cs_high             ,

                mem_rd_data_ack,

// FROM MAIN CONTROLLER                                   

                csr_cmd_xfer_ack,
                csr_cmd_xfer_success,
                mem_xfer_auto_status_rd_done,
                csr_rd_xfer_ack,
                monitoring_xfer,

// sequence RAM Ports - To/From MAIN CONTROLLER
                seq_ram_rd_data_B,
                seq_ram_rd_addr,
                seq_ram_rd_en,
//                seq_ram_wr_rd_addr,

// FROM MEMORY XFER SM
                mem_illegal_instrn_err,
                mem_dqs_non_toggle_err, 
                illegal_strobe_err,
                csr_dqs_non_toggle_err, 
                calib_tap_out,
                calib_tap_valid,
                mem_rd_data,
                mem_rd_valid,
		slv_mem_err,

                                     
// TO CPU
               xspi_csr_xfer_status_intr,
               xspi_mem_xfer_status_intr
);
  
    parameter PTR_WIDTH = 8; 
    parameter DATA_WIDTH = 32;
    parameter DEPTH = 255;
 
    parameter DOUBLE_DWORD    = 32;
    localparam CSR_AXI_ID_WIDTH     = 4 ;
    localparam CSR_AXI_ADDR_WIDTH   = 32;
    localparam CSR_AXI_DATA_WIDTH   = 32;
    localparam CSR_AXI_LEN_WIDTH    = 8;
    localparam CSR_AXI_BURST_WIDTH  = 2 ;
    localparam CSR_AXI_RESP_WIDTH   = 2 ;
    localparam CSR_AXI_STROBE_WIDTH = 4 ; //GLOBAL SYSTEM SIGNALS

//GLOBAL SYSTEM SIGNALS
		
input                               axi_clk;
input                               mem_clk;

input                               axi_rst_n;

//AXI WRITE ADDRESS CHANNEL
input                               csr_aw_valid_i;
input  [CSR_AXI_ID_WIDTH-1:0]       csr_aw_id_i;
input  [CSR_AXI_ADDR_WIDTH-1:0]     csr_aw_addr_i;
input  [CSR_AXI_LEN_WIDTH-1:0]      csr_aw_len_i;
input  [2:0]                        csr_aw_size_i;
input  [CSR_AXI_BURST_WIDTH-1:0]    csr_aw_burst_i;
               
output                              csr_aw_ready_o;

//AXI WRITE  DATA CHANNEL

input [CSR_AXI_DATA_WIDTH-1:0]      csr_w_data_i;
input                               csr_w_valid_i;
input                               csr_w_last_i;
                 
output                              csr_w_ready_o;

//AXI WRITE RESPONSE CHANNEL

input                              csr_b_ready_i;

output [CSR_AXI_ID_WIDTH-1:0]      csr_b_id_o;
output                             csr_b_valid_o;
output [CSR_AXI_RESP_WIDTH-1:0]    csr_b_resp_o;

//AXI READ ADDRESS CHANNEL
input                               csr_ar_valid_i;
input [CSR_AXI_ID_WIDTH-1:0]        csr_ar_id_i;
input [CSR_AXI_ADDR_WIDTH-1:0]      csr_ar_addr_i;
input [CSR_AXI_LEN_WIDTH-1:0]       csr_ar_len_i;
input [2:0]                         csr_ar_size_i;
input [CSR_AXI_BURST_WIDTH-1:0]     csr_ar_burst_i;
                
output                              csr_ar_ready_o;

//AXI READ DATA CHANNEL
input                               csr_r_ready_i;

output [CSR_AXI_ID_WIDTH-1:0]       csr_r_id_o;
output [CSR_AXI_DATA_WIDTH-1:0]     csr_r_data_o;
output                              csr_r_valid_o;
output [CSR_AXI_RESP_WIDTH-1:0]     csr_r_resp_o;
output                              csr_r_last_o;
 

// sequence RAM Ports
//input                               seq_ram_rd_en;
output [CSR_AXI_DATA_WIDTH-1:0]     seq_ram_rd_data_B;
input [`CSR_DPRAM_ADDR_WIDTH-1:0]   seq_ram_rd_addr;
input 				    seq_ram_rd_en;

// TO MAIN CONTROLLER

output                             rd_seq_sel;
output                             wr_seq_sel;
output [10:0]                       rd_seq_id;
output [10:0]                       wr_seq_id;
output [DOUBLE_DWORD-1:0]           def_seq1_dword1;
output [DOUBLE_DWORD-1:0]           def_seq1_dword2;
output [DOUBLE_DWORD-1:0]           def_seq1_dword3;
output [DOUBLE_DWORD-1:0]           def_seq1_dword4;
output [DOUBLE_DWORD-1:0]           def_seq2_dword1;
output [DOUBLE_DWORD-1:0]           def_seq2_dword2;
output [DOUBLE_DWORD-1:0]           def_seq2_dword3;
output [DOUBLE_DWORD-1:0]           def_seq2_dword4;

output [31:0]                      mem_upper_bound_addr_0;
output [31:0]                      mem_lower_bound_addr_0;
output [31:0]                      write_en_seq_reg_1;
output [31:0]                      write_en_seq_reg_2;
output [31:0]                      write_dis_seq_reg_1;
output [31:0]                      write_dis_seq_reg_2;

input 				   mem_xfer_pending;
output                             status_reg_en;

output                             hybrid_wrap_cmd_en;
output				   page_incr_en;
output				   hyperflash_en;
output [3:0]                       mem_page_size;

output [31:0]                      wr_rd_data_1;
output [31:0]                      wr_rd_data_2;

output                             cmd_no_of_opcode;
output                             cmd_xfer_data_rate;
output [1:0]                       cmd_no_of_pins;
output [15:0]                      cmd_opcode;
output                             wr_data_en        ;
output [1:0]                       wdata_no_of_pins  ;
output                             wdata_xfer_data_rate;
output                             csr_cmd_xfer_valid   ;
output [5:0]                       no_of_wr_data_bytes;

output [15:0]                      read_cmd_opcode;
output [1:0]                       read_no_of_pins;
output                             read_xfer_data_rate;
output                             read_cmd_data_rate;
output                             read_no_of_opcode;
output                             csr_rd_xfer_valid;
output [6:0]                       no_of_csr_rd_data_bytes;
output [2:0]                       no_of_csr_rd_addr_bytes;
output [2:0]                       rd_monitor_bit;
output                             rd_monitor_value;
output                             rd_monitor_en;
output [17:0]                      subseq_rd_xfer_time;

output [15:0]                      status_cmd_opcode;
output [1:0]                       status_no_of_pins;
output                             status_xfer_data_rate;
output                             status_cmd_data_rate;
output                             status_no_of_opcode;
output [2:0]                             status_monitor_bit;
output                             status_monitor_value;
output                             status_monitor_en;

output [2:0]                       no_of_auto_status_rd_data_bytes;
output [17:0]                      subseq_status_rd_xfer_time;
output [2:0]                       auto_status_rd_addr_bytes;
output                             auto_initiate_status_read_seq;
output [30:0]                      status_reg_rd_xfer_time;
output [31:0]                      auto_initiate_status_addr;


output                             auto_initiate_write_en_seq;
output                             auto_initiate_write_en_seq_2;
output                             auto_initiate_post_wren_seq;
output [15:0]                      post_wren_seq_data;
output                             auto_initiate_write_dis_seq;

//output [`CSR_DPRAM_ADDR_WIDTH-1:0] seq_ram_wr_rd_addr;

// TO MEMORY XFER SM
output [7:0]                        ddr_delay_tap;
output                              dqs_mode;
output [2:0]                        dlp_pattern_cyc_cnt;

output                              jhr_en;
output                              predrive_en;
output                              dual_seq_mode;
output                              cont_read_auto_status_en;

output [4:0]                       dummy_cycle_config;           
output [7:0]                        dummy_cycle_HiZ;           
output [7:0]                        dummy_cycle_drive;
output [4:0]                        dqs_non_tgle_to ;
output [1:0]                        cs_hold;
output [1:0]                        cs_setup;
output [4:0]                        cs_high;

output                             mem_rd_data_ack;

// FROM MAIN CONTROLLER

input                               csr_cmd_xfer_ack     ; //pulse
input                               csr_cmd_xfer_success ; //pulse
input                               mem_xfer_auto_status_rd_done ; //pulse
input                               csr_rd_xfer_ack  ; //pulse
input                               monitoring_xfer  ; //level

// FROM MEMORY XFER SM
input                               mem_illegal_instrn_err;//level
input                               mem_dqs_non_toggle_err;//level 
input                               illegal_strobe_err;//level
input                               csr_dqs_non_toggle_err;//level 
input [7:0]                         calib_tap_out;
input                               calib_tap_valid;//level but pulse from mem_xfer_sm
input [31:0]                         mem_rd_data;   //data is maintained stable until next rd_data is available
input                               mem_rd_valid ; //pulse //need to clarify
input				    slv_mem_err;

// TO CPU
output                             xspi_csr_xfer_status_intr;
output                             xspi_mem_xfer_status_intr;

//WIRES

wire                                seq_ram_wen;
wire   [CSR_AXI_DATA_WIDTH-1:0]     seq_ram_wr_data;
wire   [`CSR_DPRAM_ADDR_WIDTH-1:0]  seq_ram_wr_rd_addr;


wire   [`CSR_DPRAM_ADDR_WIDTH-2-1:0]  seq_ram_wr_rd_addr_int;
wire   [`CSR_DPRAM_ADDR_WIDTH-2-1:0]  seq_ram_rd_addr_int;

assign seq_ram_wr_rd_addr_int = seq_ram_wr_rd_addr[9:2];
assign seq_ram_rd_addr_int = seq_ram_rd_addr[9:2];

axi_csr_reg axi_csr_reg_dut (
//GLOBAL SYSTEM SIGNALS
		.sys_clk_i               (axi_clk                ),
		.sys_reset_n_i           (axi_rst_n              ),

//AXI WRITE ADDRESS CHANNEL
                .csr_aw_valid_i          (csr_aw_valid_i         ),
                .csr_aw_id_i             (csr_aw_id_i            ),
                .csr_aw_addr_i           (csr_aw_addr_i          ),
                .csr_aw_len_i            (csr_aw_len_i           ),
                .csr_aw_size_i           (csr_aw_size_i          ),
                .csr_aw_burst_i          (csr_aw_burst_i         ),
                .csr_aw_ready_o          (csr_aw_ready_o         ),

//AXI WRITE  DATA CHANNEL
                .csr_w_data_i            (csr_w_data_i           ),
                .csr_w_valid_i           (csr_w_valid_i          ),
                .csr_w_last_i            (csr_w_last_i           ),
                .csr_w_ready_o           (csr_w_ready_o          ),

//AXI WRITE RESPONSE CHANNEL
                .csr_b_id_o              (csr_b_id_o             ),
                .csr_b_valid_o           (csr_b_valid_o          ),
                .csr_b_resp_o            (csr_b_resp_o           ),
                .csr_b_ready_i           (csr_b_ready_i          ),

//AXI READ ADDRESS CHANNEL
                .csr_ar_valid_i          (csr_ar_valid_i         ),
                .csr_ar_id_i             (csr_ar_id_i            ),
                .csr_ar_addr_i           (csr_ar_addr_i          ),
                .csr_ar_len_i            (csr_ar_len_i           ),
                .csr_ar_size_i           (csr_ar_size_i          ),
                .csr_ar_burst_i          (csr_ar_burst_i         ),
                .csr_ar_ready_o          (csr_ar_ready_o         ),

//AXI READ DATA CHANNEL
                .csr_r_id_o              (csr_r_id_o             ),
                .csr_r_data_o            (csr_r_data_o           ),
                .csr_r_valid_o           (csr_r_valid_o          ),
                .csr_r_resp_o            (csr_r_resp_o           ),
                .csr_r_last_o            (csr_r_last_o           ),
                .csr_r_ready_i           (csr_r_ready_i          ),

// sequence RAM Write Ports
                .seq_ram_wen           (seq_ram_wen          ),
                .seq_ram_wr_data         (seq_ram_wr_data        ),
                .seq_ram_addr            (seq_ram_wr_rd_addr     ),

// TO MAIN CONTROLLER

                .rd_seq_sel (rd_seq_sel),  
                .wr_seq_sel (wr_seq_sel),
                .rd_seq_id               (rd_seq_id              ),
                .wr_seq_id               (wr_seq_id              ),
                .def_seq1_dword1         (def_seq1_dword1        ),
                .def_seq1_dword2         (def_seq1_dword2        ),
                .def_seq1_dword3         (def_seq1_dword3        ),
                .def_seq1_dword4         (def_seq1_dword4        ),
                .def_seq2_dword1         (def_seq2_dword1        ),
                .def_seq2_dword2         (def_seq2_dword2        ),
                .def_seq2_dword3         (def_seq2_dword3        ),
                .def_seq2_dword4         (def_seq2_dword4        ),

                .hybrid_wrap_cmd_en      (hybrid_wrap_cmd_en     ),
                .page_incr_en	         (page_incr_en              ),
                .hyperflash_en           (hyperflash_en          ),
                .mem_page_size (mem_page_size),

                .wr_rd_data_1            (wr_rd_data_1           ), 
                .wr_rd_data_2            (wr_rd_data_2           ), 


                .cmd_no_of_opcode        (cmd_no_of_opcode       ),                                
                .cmd_xfer_data_rate      (cmd_xfer_data_rate     ),                                    
                .cmd_no_of_pins          (cmd_no_of_pins         ),                               
                .cmd_opcode              (cmd_opcode             ),                                
                .wr_data_en              (wr_data_en             ),   
                .wdata_no_of_pins        (wdata_no_of_pins       ),
                .wdata_xfer_data_rate    (wdata_xfer_data_rate   ),
                .csr_cmd_xfer_valid      (csr_cmd_xfer_valid     ),
                .no_of_wr_data_bytes     (no_of_wr_data_bytes    ),

                .read_cmd_opcode	 (read_cmd_opcode	 ),      				
                .read_no_of_pins         (read_no_of_pins        ),     				
                .read_xfer_data_rate	 (read_xfer_data_rate	 ), 
                .read_cmd_data_rate	 (read_cmd_data_rate	 ), 
                .read_no_of_opcode       (read_no_of_opcode      ),     					         .csr_rd_xfer_valid	  (csr_rd_xfer_valid	 ),      					          .no_of_csr_rd_data_bytes     (no_of_csr_rd_data_bytes    ),
                .no_of_csr_rd_addr_bytes           (no_of_csr_rd_addr_bytes       ),
                .rd_monitor_bit             (rd_monitor_bit            ), 
                .rd_monitor_value           (rd_monitor_value          ), 
                .rd_monitor_en              (rd_monitor_en),
                .subseq_rd_xfer_time (subseq_rd_xfer_time),


                .status_cmd_opcode	 (status_cmd_opcode	 ),      				
                .status_no_of_pins       (status_no_of_pins      ),     					         
                .status_xfer_data_rate	 (status_xfer_data_rate	 ), 
                .status_cmd_data_rate	 (status_cmd_data_rate	 ), 
                .status_no_of_opcode     (status_no_of_opcode    ),     				
                .status_monitor_bit                  (status_monitor_bit             ),
                .status_monitor_value                (status_monitor_value           ),
                .status_monitor_en                   (status_monitor_en              ),
                .no_of_auto_status_rd_data_bytes     (no_of_auto_status_rd_data_bytes),
                .subseq_status_rd_xfer_time (subseq_status_rd_xfer_time),
                .auto_status_rd_addr_bytes           (auto_status_rd_addr_bytes      ),
                .auto_initiate_status_read_seq       (auto_initiate_status_read_seq  ),
                .status_reg_rd_xfer_time             (status_reg_rd_xfer_time        ),
                .auto_initiate_status_addr           (auto_initiate_status_addr      ),

                .auto_initiate_write_en_seq   (auto_initiate_write_en_seq),
                .auto_initiate_write_en_seq_2 (auto_initiate_write_en_seq_2),
                .auto_initiate_post_wren_seq  (auto_initiate_post_wren_seq),
                .post_wren_seq_data           (post_wren_seq_data),
                .auto_initiate_write_dis_seq   (auto_initiate_write_dis_seq),

                .mem_upper_bound_addr_0  (mem_upper_bound_addr_0 ),
                .mem_lower_bound_addr_0  (mem_lower_bound_addr_0 ),
                .write_en_seq_reg_1      (write_en_seq_reg_1     ),    
                .write_en_seq_reg_2      (write_en_seq_reg_2     ),
                .write_dis_seq_reg_1     (write_dis_seq_reg_1    ),    
                .write_dis_seq_reg_2     (write_dis_seq_reg_2    ),

                .mem_xfer_pending         (mem_xfer_pending        ),
                .status_reg_en            (status_reg_en),

// TO MEMORY XFER SM

                .ddr_delay_tap           (ddr_delay_tap       ),
                .dqs_mode                (dqs_mode            ),
                .dlp_pattern_cyc_cnt     (dlp_pattern_cyc_cnt ),

                .jhr_en                  (jhr_en              ),
                .predrive_en             (predrive_en         ),
                .dual_seq_mode           (dual_seq_mode       ),
                .cont_read_auto_status_en (cont_read_auto_status_en),

                .dummy_cycle_config      (dummy_cycle_config ),     
                .dummy_cycle_HiZ         (dummy_cycle_HiZ     ),     
                .dummy_cycle_drive       (dummy_cycle_drive   ),

                .dqs_non_tgle_to         (dqs_non_tgle_to     ),
                .cs_hold                 (cs_hold             ),
                .cs_setup                (cs_setup            ),
                .cs_high                 (cs_high             ),

                .mem_rd_data_ack (mem_rd_data_ack),

                                                          
// FROM MAIN CONTROLLER                                   

                .csr_cmd_xfer_ack  	  (csr_cmd_xfer_ack    	    ),	 
                .csr_cmd_xfer_success	  (csr_cmd_xfer_success     ),   			
                .mem_xfer_auto_status_rd_done  (mem_xfer_auto_status_rd_done  ),   			
                .csr_rd_xfer_ack 	  (csr_rd_xfer_ack      ),   			
                .monitoring_xfer 	  (monitoring_xfer      ),   			

// FROM MEMORY XFER SM
                .mem_illegal_instrn_err   (mem_illegal_instrn_err    ),
                .mem_dqs_non_toggle_err   (mem_dqs_non_toggle_err    ), 
                .illegal_strobe_err       (illegal_strobe_err        ),
                .csr_dqs_non_toggle_err   (csr_dqs_non_toggle_err    ), 
                .calib_tap_out            (calib_tap_out             ),
                .calib_tap_valid          (calib_tap_valid           ),
                .mem_rd_data   (mem_rd_data    ),                             
                .mem_rd_valid  (mem_rd_valid   ),
                .slv_mem_err              (slv_mem_err		     ),

                                                             
// TO CPU
                .xspi_csr_xfer_status_intr   (xspi_csr_xfer_status_intr ),
                .xspi_mem_xfer_status_intr   (xspi_mem_xfer_status_intr )
);


`ifdef FPGA_OR_SIMULATION
mem_1w1r_fpga_or_sim # ( PTR_WIDTH, DATA_WIDTH , DEPTH  ) XSPI_SEQ_RAM (
    .wclk                ( axi_clk ),
    .waddr               ( seq_ram_wr_rd_addr_int ),
    .wen                 ( seq_ram_wen ),
    .wdata               ( seq_ram_wr_data ),
    .rclk                ( mem_clk ),
    .raddr               ( seq_ram_rd_addr_int ),
    .ren                 ( seq_ram_rd_en ),
    .rdata               ( seq_ram_rd_data_B )
);
`endif
`ifdef ASIC_SYNTH
mem_1w1r_asic7 # ( PTR_WIDTH, DATA_WIDTH , DEPTH  ) XSPI_SEQ_RAM (
    .wclk                ( axi_clk ),
    .waddr               ( seq_ram_wr_rd_addr_int ),
    .wen                 ( seq_ram_wen ),
    .wdata               ( seq_ram_wr_data ),
    .rclk                ( mem_clk ),
    .raddr               ( seq_ram_rd_addr_int ),
    .ren                 ( seq_ram_rd_en ),
    .rdata               ( seq_ram_rd_data_B )
);
`endif

endmodule
