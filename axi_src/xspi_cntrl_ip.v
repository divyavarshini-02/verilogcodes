

`timescale 1ps/1ps


`define CSR_DPRAM_ADDR_WIDTH     10

`define ARM_UD_MODEL
module xspi_cntrl_ip
	(
            axi_clk,
            axi_rst_n,

            mem_clk,
            mem_rst_n,
// AXI CSR INTF

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

// AXI MEM INTF

//AXI WRITE ADDRESS CHANNEL
            mem_aw_valid_i,
            mem_aw_id_i,
            mem_aw_addr_i,
            mem_aw_len_i,
            mem_aw_size_i,
            mem_aw_burst_i,
            mem_aw_ready_o,

//AXI READ ADDRESS CHANNEL
            mem_ar_valid_i,
            mem_ar_id_i,
            mem_ar_addr_i,
            mem_ar_len_i,
            mem_ar_size_i,
            mem_ar_burst_i,
            mem_ar_ready_o,

//AXI WRITE  DATA CHANNEL

            mem_w_data_i,
            mem_w_strb_i,
            mem_w_valid_i,
            mem_w_last_i,
            
            mem_w_ready_o,

//AXI WRITE RESPONSE CHANNEL

            mem_b_id_o,
            mem_b_valid_o,
            mem_b_resp_o,
            
            mem_b_ready_i,

//AXI READ DATA CHANNEL
            mem_r_id_o,
            mem_r_data_o,
            mem_r_valid_o,
            mem_r_resp_o,
            mem_r_last_o,

            mem_r_ready_i,

// TO main controller
            def_seq_sel,

// TO CPU

	    xspi_csr_xfer_status_intr,
	    xspi_mem_xfer_status_intr,

// To wrapper 
            cs_n_ip, 
            sclk_en,
            dq_out_16,
            dq_oe, 

            ddr_delay_tap,
            dqs_mode,

// From wrapper
            dq_in_ip,
            dqs_ip  
	);

parameter MEM_AXI_ID_WIDTH          = 4;
parameter MEM_AXI_ADDR_WIDTH	    = 32;
parameter MEM_AXI_DATA_WIDTH        = 32;
parameter MEM_DQ_BUS_WIDTH              = 8;

localparam RCV_DQ_FIFO_ADDR_WIDTH   = 4;// depth 16

localparam MEM_AXI_LEN_WIDTH	    = 8;
localparam MEM_AXI_RESP_WIDTH       = 2;
localparam MEM_AXI_BURST_TYPE_WIDTH = 2;
localparam MEM_AXI_SIZE_WIDTH       = 3;
localparam XFER_LEN_WIDTH = (MEM_AXI_DATA_WIDTH==32) ? 11 : (MEM_AXI_DATA_WIDTH==64) ? 12 : 13 ;

localparam CSR_AXI_ID_WIDTH         = 4 ;
localparam CSR_AXI_ADDR_WIDTH       = 32;
localparam CSR_AXI_DATA_WIDTH       = 32;
localparam CSR_AXI_LEN_WIDTH        = 8;
localparam CSR_AXI_BURST_WIDTH      = 2 ;
localparam CSR_AXI_SIZE_WIDTH       = 3 ;
localparam CSR_AXI_RESP_WIDTH       = 2 ;
localparam CSR_AXI_STROBE_WIDTH     = 4 ;

//GLOBAL SYSTEM SIGNALS
		
input                             axi_clk;
input                             mem_clk;

input                             axi_rst_n;
input                             mem_rst_n;

// AXI CSR INTERFACE

//AXI WRITE ADDRESS CHANNEL
input                            csr_aw_valid_i;
input  [CSR_AXI_ID_WIDTH-1:0]    csr_aw_id_i;
input  [CSR_AXI_ADDR_WIDTH-1:0]  csr_aw_addr_i;
input  [CSR_AXI_LEN_WIDTH-1:0]   csr_aw_len_i;
input  [CSR_AXI_SIZE_WIDTH-1:0]  csr_aw_size_i;
input  [CSR_AXI_BURST_WIDTH-1:0] csr_aw_burst_i;
               
output                           csr_aw_ready_o;

//AXI WRITE  DATA CHANNEL

input [CSR_AXI_DATA_WIDTH-1:0]   csr_w_data_i;
input                            csr_w_valid_i;
input                            csr_w_last_i;
                 
output                           csr_w_ready_o;

//AXI WRITE RESPONSE CHANNEL

input                            csr_b_ready_i;

output [CSR_AXI_ID_WIDTH-1:0]    csr_b_id_o;
output                           csr_b_valid_o;
output [CSR_AXI_RESP_WIDTH-1:0]  csr_b_resp_o;

//AXI READ ADDRESS CHANNEL
input                            csr_ar_valid_i;
input [CSR_AXI_ID_WIDTH-1:0]     csr_ar_id_i;
input [CSR_AXI_ADDR_WIDTH-1:0]   csr_ar_addr_i;
input [CSR_AXI_LEN_WIDTH-1:0]    csr_ar_len_i;
input [2:0]                      csr_ar_size_i;
input [CSR_AXI_BURST_WIDTH-1:0]  csr_ar_burst_i;
                
output                           csr_ar_ready_o;

//AXI READ DATA CHANNEL
input                            csr_r_ready_i;

output [CSR_AXI_ID_WIDTH-1:0]    csr_r_id_o;
output [CSR_AXI_DATA_WIDTH-1:0]  csr_r_data_o;
output                           csr_r_valid_o;
output [CSR_AXI_RESP_WIDTH-1:0]  csr_r_resp_o;
output                           csr_r_last_o;

// AXI MEM INTERFACE

//AXI WRITE ADDRESS CHANNEL
input                                 mem_aw_valid_i;
input  [MEM_AXI_ID_WIDTH-1:0]         mem_aw_id_i;
input  [MEM_AXI_ADDR_WIDTH-1:0]       mem_aw_addr_i;
input  [MEM_AXI_LEN_WIDTH-1:0]        mem_aw_len_i;
input  [MEM_AXI_SIZE_WIDTH-1:0]       mem_aw_size_i;
input  [MEM_AXI_BURST_TYPE_WIDTH-1:0] mem_aw_burst_i;
               
output                                mem_aw_ready_o;

//AXI READ ADDRESS CHANNEL
input                                mem_ar_valid_i;
input [MEM_AXI_ID_WIDTH-1:0]         mem_ar_id_i;
input [MEM_AXI_ADDR_WIDTH-1:0]       mem_ar_addr_i;
input [MEM_AXI_LEN_WIDTH-1:0]        mem_ar_len_i;
input [MEM_AXI_SIZE_WIDTH-1:0]       mem_ar_size_i;
input [MEM_AXI_BURST_TYPE_WIDTH-1:0] mem_ar_burst_i;
             
output                               mem_ar_ready_o;

//AXI WRITE  DATA CHANNEL
input [MEM_AXI_DATA_WIDTH-1:0]       mem_w_data_i;
input [(MEM_AXI_DATA_WIDTH/8)-1:0]   mem_w_strb_i;
input                                mem_w_valid_i;
input                                mem_w_last_i;
                 
output                               mem_w_ready_o;

//AXI WRITE RESPONSE CHANNEL
input                                mem_b_ready_i;

output [MEM_AXI_ID_WIDTH-1:0]        mem_b_id_o;
output                               mem_b_valid_o;
output [MEM_AXI_RESP_WIDTH-1:0]      mem_b_resp_o;

//AXI READ DATA CHANNEL

input                                mem_r_ready_i;

output [MEM_AXI_ID_WIDTH-1:0]        mem_r_id_o;
output [MEM_AXI_DATA_WIDTH-1:0]      mem_r_data_o;
output                               mem_r_valid_o;
output [MEM_AXI_RESP_WIDTH-1:0]      mem_r_resp_o;
output                               mem_r_last_o;

// TO main controller
input              def_seq_sel;

// TO CPU
output             xspi_csr_xfer_status_intr;
output             xspi_mem_xfer_status_intr;

// To wrapper
output             cs_n_ip; 
output             sclk_en; 
output [15:0]      dq_out_16;
output [15:0]      dq_oe; 

output [7:0]       ddr_delay_tap;
output             dqs_mode;

//FROM wrapper
input[7:0]         dq_in_ip;
input              dqs_ip ;

//-------------------------------------------WIRE DECLARATION------------------------------------



wire [`CSR_DPRAM_ADDR_WIDTH -1:0] seq_ram_rd_addr;
wire seq_ram_rd_en;
wire [CSR_AXI_DATA_WIDTH-1:0] seq_ram_rd_data;         

wire [10:0] wr_seq_id;               
wire [10:0] rd_seq_id;               
wire wr_seq_sel;          
wire rd_seq_sel;   
wire wr_seq_sel_sync;          
wire rd_seq_sel_sync;       
                        
wire [31:0] def_seq1_dword1;        
wire [31:0] def_seq1_dword2;        
wire [31:0] def_seq1_dword3;        
wire [31:0] def_seq1_dword4;        
wire [31:0] def_seq2_dword1;        
wire [31:0] def_seq2_dword2;        
wire [31:0] def_seq2_dword3;        
wire [31:0] def_seq2_dword4;        
wire [31:0] write_en_seq_reg_1;     
wire [31:0] write_en_seq_reg_2; 
wire [31:0] write_dis_seq_reg_1;    
wire [31:0] write_dis_seq_reg_2;  
                        
wire [31:0] mem_upper_bound_addr_0; 
wire [31:0] mem_lower_bound_addr_0; 
                        
wire       page_incr_en;     
wire hybrid_wrap_cmd_en;      
wire mem_xfer_pending;  
wire mem_xfer_pending_sync;

wire [31:0] wr_rd_data_1;
wire [31:0] wr_rd_data_2;


//To csr

wire [1:0]  wdata_no_of_pins    ;
wire hyperflash_en;

wire [3:0]  mem_page_size;
wire dual_seq_mode;
wire cont_read_auto_status_en;
wire [5:0]  no_of_wr_data_bytes;
wire cmd_no_of_opcode         ;     
wire cmd_xfer_data_rate       ; 
wire [1:0]  cmd_no_of_pins    ;    
wire [15:0] cmd_opcode        ;    

wire status_xfer_data_rate    ;
wire status_cmd_data_rate    ;
wire [1:0] status_no_of_pins  ;   
wire status_no_of_opcode  ;   
wire [15:0] status_cmd_opcode  ;
wire [2:0] no_of_no_of_csr_rd_addr_bytes;
wire read_xfer_data_rate    ;
wire read_cmd_data_rate    ;
wire [1:0] read_no_of_pins  ;   
wire read_no_of_opcode  ;   
wire [15:0] read_cmd_opcode  ;
wire status_reg_en;
wire status_monitor_en; 
wire [2:0] monitor_bit; 
wire [2:0]  rd_addr_bytes;
wire [30:0] status_reg_rd_xfer_time;
wire [17:0] subseq_status_rd_xfer_time;
wire [6:0]  no_of_csr_rd_data_bytes;
wire [2:0]                       no_of_csr_rd_addr_bytes;
wire [2:0] rd_monitor_bit;
wire [17:0]  subseq_rd_xfer_time;
wire [2:0] no_of_auto_status_rd_data_bytes;
wire [2:0] auto_status_rd_addr_bytes;
wire [31:0] auto_initiate_status_addr;
wire [5:0]  no_of_data_bytes;
wire [1:0]  no_of_xfer;

wire [31:0] seq_ram_rd_dat;
wire [2:0] status_monitor_bit;


 

// TO MEMORY XFER SM         
wire [7:0] ddr_delay_tap        ;
wire dqs_mode        ;
wire [2:0] dlp_pattern_cyc_cnt  ;
wire [7:0] dlp_pattern          ;
wire [4:0] dummy_cycle_config ;
wire [7:0] dummy_cycle_HiZ      ;
wire [7:0] dummy_cycle_drive    ;
wire [1:0] cs_hold              ;
wire [1:0] cs_setup             ;
wire [4:0] cs_high              ;
wire mem_rd_data_ack ;
wire mem_rd_data_ack_sync ;
wire [4:0] dqs_non_tgl_to;
wire auto_initiate_post_wren_seq;
wire [15:0] post_wren_seq_data;
wire auto_initiate_write_en_seq;
wire auto_initiate_write_en_seq_2;
wire auto_initiate_status_read_seq;
wire auto_initiate_write_dis_seq;
//wire [`CSR_DPRAM_ADDR_WIDTH -1:0] seq_ram_wr_rd_addr;
                            
// FROM MEMORY XFER SM                          
wire [7:0] calib_tap_out;           
wire calib_tap_valid;         
wire [31:0] mem_rd_data;  
wire mem_rd_valid; 


wire [MEM_AXI_ADDR_WIDTH -1 :0] addr_mem_xfer;
wire [4:0]       rw_len_mem_xfer;  // read - not used; write - denotes number of mem_xfer_wvalid
wire   [7:0]                    xfer_axi_len;            
wire   [1:0]                    xfer_btype;
wire   [2:0]                    xfer_bsize;

wire [31:0] seq_reg_0;
wire [31:0] seq_reg_1;
wire [31:0] seq_reg_2;
wire [31:0] seq_reg_3;

wire [3:0]  slv_mem_wstrb;
wire [31:0] slv_mem_wdata;           

wire  [MEM_AXI_DATA_WIDTH-1 : 0 ]     mem_slv_rdata;
wire [1:0]                            mem_slv_rdata_resp;

wire [MEM_AXI_ADDR_WIDTH-1:0] slv_mem_addr     ;
wire [XFER_LEN_WIDTH-1:0]     slv_arb_bytes_len      ;
wire [7:0] slv_mem_axi_len  ;
wire [1:0] slv_mem_burst    ;
wire [2:0] slv_mem_size     ;
wire [1:0] mem_slv_wdata_err;
                                                          
axi_csr_reg_wrapper AXI_CSR_INST (

//GLOBAL SYSTEM SIGNALS
		.axi_clk          (axi_clk  ),   
		.mem_clk          (mem_clk  ),

		.axi_rst_n        (axi_rst_n),
		//.mem_rst_n        (mem_rst_n),

//AXI WRITE ADDRESS CHANNEL
                .csr_aw_valid_i   (csr_aw_valid_i    ),
                .csr_aw_id_i      (csr_aw_id_i       ),
                .csr_aw_addr_i    (csr_aw_addr_i     ),
                .csr_aw_len_i     (csr_aw_len_i      ),
                .csr_aw_size_i    (csr_aw_size_i     ),
                .csr_aw_burst_i   (csr_aw_burst_i    ),
                                
                .csr_aw_ready_o   (csr_aw_ready_o    ),

//AXI WRITE  DATA CHANNEL
                .csr_w_data_i     (csr_w_data_i      ),
                .csr_w_valid_i    (csr_w_valid_i     ),
                .csr_w_last_i     (csr_w_last_i      ),
                                                    
                .csr_w_ready_o    (csr_w_ready_o     ),
                                                     
//AXI WRITE RESPONSE CHANNEL
                .csr_b_id_o       (csr_b_id_o        ),
                .csr_b_valid_o    (csr_b_valid_o     ),
                .csr_b_resp_o     (csr_b_resp_o      ),
                                                    
                .csr_b_ready_i    (csr_b_ready_i     ),

//AXI READ ADDRESS CHANNEL
                .csr_ar_valid_i    (csr_ar_valid_i   ),
                .csr_ar_id_i       (csr_ar_id_i      ),
                .csr_ar_addr_i     (csr_ar_addr_i    ),
                .csr_ar_len_i      (csr_ar_len_i     ),
                .csr_ar_size_i     (csr_ar_size_i    ),
                .csr_ar_burst_i    (csr_ar_burst_i   ),

                .csr_ar_ready_o    (csr_ar_ready_o   ),

//AXI READ DATA CHANNEL
                .csr_r_id_o        (csr_r_id_o       ),
                .csr_r_data_o      (csr_r_data_o     ),
                .csr_r_valid_o     (csr_r_valid_o    ),
                .csr_r_resp_o      (csr_r_resp_o     ),
                .csr_r_last_o      (csr_r_last_o     ),
                .csr_r_ready_i     (csr_r_ready_i    ),
   	        .slv_mem_err       (slv_mem_err_sync ),

                .mem_xfer_pending		  (mem_xfer_pending_sync          ),

// TO MAIN CONTROLLER                           
                .wr_seq_sel                    (wr_seq_sel                 ),
                .rd_seq_sel                    (rd_seq_sel                 ),
                .wr_seq_id                        (wr_seq_id                     ),
                .rd_seq_id                        (rd_seq_id                     ),

                .def_seq1_dword1                  (def_seq1_dword1               ),
                .def_seq1_dword2                  (def_seq1_dword2               ),
                .def_seq1_dword3                  (def_seq1_dword3               ),
                .def_seq1_dword4                  (def_seq1_dword4               ),
                .def_seq2_dword1                  (def_seq2_dword1               ),
                .def_seq2_dword2                  (def_seq2_dword2               ),
                .def_seq2_dword3                  (def_seq2_dword3               ),
                .def_seq2_dword4                  (def_seq2_dword4               ),

                .hybrid_wrap_cmd_en               (hybrid_wrap_cmd_en            ),
   		.page_incr_en	                  (page_incr_en	                 ),
                .hyperflash_en		      (hyperflash_en		     ),
                .mem_page_size (mem_page_size),
                .dual_seq_mode (dual_seq_mode),
                .cont_read_auto_status_en (cont_read_auto_status_en),

     .wr_rd_data_1                  (wr_rd_data_1), 
     .wr_rd_data_2                  (wr_rd_data_2), 


//To Main controller - axi_clk 
    .csr_cmd_xfer_valid               (csr_cmd_xfer_valid            ),
    .cmd_no_of_opcode                 (cmd_no_of_opcode              ),
    .cmd_xfer_data_rate               (cmd_xfer_data_rate            ),
    .cmd_no_of_pins                   (cmd_no_of_pins                ),
    .cmd_opcode                       (cmd_opcode                    ),
    .wr_data_en                       (wr_data_en                    ),
    .wdata_no_of_pins                 (wdata_no_of_pins              ),
    .wdata_xfer_data_rate             (wdata_xfer_data_rate          ),
    .no_of_wr_data_bytes              (no_of_wr_data_bytes           ),

    .csr_rd_xfer_valid                (csr_rd_xfer_valid         ),
    .read_cmd_opcode	 	      (read_cmd_opcode	                 ),      				
    .read_no_of_pins                  (read_no_of_pins       		),     					
    .read_xfer_data_rate	      (read_xfer_data_rate	 	), 
    .read_cmd_data_rate	              (read_cmd_data_rate	 	), 
    .read_no_of_opcode  	      (read_no_of_opcode     	        ),     					
    .no_of_csr_rd_data_bytes       	(no_of_csr_rd_data_bytes      		),
    .no_of_csr_rd_addr_bytes       	(no_of_csr_rd_addr_bytes      		),
    .rd_monitor_value          	      (rd_monitor_value          		), 
    .rd_monitor_bit           	      (rd_monitor_bit            		), 
    .rd_monitor_en           	      (rd_monitor_en            		), 
    .subseq_rd_xfer_time       (subseq_rd_xfer_time),

    .status_cmd_opcode                (status_cmd_opcode                ),
    .status_no_of_pins                (status_no_of_pins             ),
    .status_xfer_data_rate            (status_xfer_data_rate         ),
    .status_cmd_data_rate             (status_cmd_data_rate         ),
    .status_no_of_opcode              (status_no_of_opcode             ),
    .status_monitor_bit           	      (status_monitor_bit            		), 
    .status_monitor_value          	      (status_monitor_value          		), 
    .status_monitor_en            (status_monitor_en      	),
    .no_of_auto_status_rd_data_bytes (no_of_auto_status_rd_data_bytes),
    .subseq_status_rd_xfer_time       (subseq_status_rd_xfer_time),
    .auto_status_rd_addr_bytes                    (auto_status_rd_addr_bytes                 ),
    .auto_initiate_status_read_seq (auto_initiate_status_read_seq),
    .status_reg_rd_xfer_time          (status_reg_rd_xfer_time           ),
    .auto_initiate_status_addr (auto_initiate_status_addr),
    .status_reg_en                    (status_reg_en                	 ),

  .auto_initiate_write_en_seq    (auto_initiate_write_en_seq),
  .auto_initiate_write_en_seq_2  (auto_initiate_write_en_seq_2),
  .auto_initiate_post_wren_seq   (auto_initiate_post_wren_seq),
  .post_wren_seq_data            (post_wren_seq_data),
  .auto_initiate_write_dis_seq    (auto_initiate_write_dis_seq),


   .mem_upper_bound_addr_0  (mem_upper_bound_addr_0),
   .mem_lower_bound_addr_0  (mem_lower_bound_addr_0),

   .write_en_seq_reg_1      (write_en_seq_reg_1     ),    
   .write_en_seq_reg_2      (write_en_seq_reg_2     ),
   .write_dis_seq_reg_1     (write_dis_seq_reg_1    ),    
   .write_dis_seq_reg_2     (write_dis_seq_reg_2    ),

    
// TO MEMORY XFER SM         
    .ddr_delay_tap                    (ddr_delay_tap                 ),
    .dqs_mode                         (dqs_mode                 ),
    .dlp_pattern_cyc_cnt              (dlp_pattern_cyc_cnt           ),

    .jhr_en                           (jhr_en                        ),
    .predrive_en                      (predrive_en                   ),

    .dummy_cycle_config               (dummy_cycle_config ),     
    .dummy_cycle_HiZ                  (dummy_cycle_HiZ               ),
    .dummy_cycle_drive                (dummy_cycle_drive             ),

    .dqs_non_tgle_to                   (dqs_non_tgl_to                ),
    .cs_hold                          (cs_hold                       ),
    .cs_setup                         (cs_setup                      ),
    .cs_high                          (cs_high                       ),

    .mem_rd_data_ack       (mem_rd_data_ack ),

// FROM MAIN CONTROLLER   - axi_clk  
    .csr_cmd_xfer_ack                 (csr_cmd_xfer_ack              ),
    .csr_cmd_xfer_success             (csr_cmd_xfer_success          ),
    .mem_xfer_auto_status_rd_done          (mem_xfer_auto_status_rd_done          ),
    .csr_rd_xfer_ack              (csr_rd_xfer_ack           ),
    .monitoring_xfer              (monitoring_xfer           ),

// sequence RAM Ports - To/From MAIN CONTROLLER
   .seq_ram_rd_data_B    (seq_ram_rd_data),
   .seq_ram_rd_addr      (seq_ram_rd_addr  ),
   .seq_ram_rd_en        (seq_ram_rd_en    ),
//   .seq_ram_wr_rd_addr (seq_ram_wr_rd_addr),
                            
// FROM MEMORY XFER SM                          
    .mem_illegal_instrn_err           (mem_illegal_instrn_sync       ),
    .mem_dqs_non_toggle_err           (mem_dqs_non_toggle_err_sync   ),
    .illegal_strobe_err               (illegal_strobe_sync           ),
    .csr_dqs_non_toggle_err           (csr_dqs_non_toggle_err_sync   ),
    .calib_tap_out                    (calib_tap_out                 ),
    .calib_tap_valid                  (calib_tap_valid_sync          ),
    .mem_rd_data           (mem_rd_data        ),
    .mem_rd_valid          (mem_rd_valid_sync  ),
                                               
// TO CPU                                     
    .xspi_csr_xfer_status_intr        (xspi_csr_xfer_status_intr     ),
    .xspi_mem_xfer_status_intr        (xspi_mem_xfer_status_intr     )
);

//ABC
xspi_axi_slv 

# (.SLV_AXI_ADDR_WIDTH (MEM_AXI_ADDR_WIDTH),  
   .SLV_AXI_DATA_WIDTH (MEM_AXI_DATA_WIDTH),
   .SLV_AXI_ID_WIDTH   (MEM_AXI_ID_WIDTH),
   .SLV_MEM_DATA_WIDTH (MEM_AXI_DATA_WIDTH))

XSPI_AXI4_SLV_CNTRL (

   .axi_clk                 (axi_clk  ),
   .axi_rst_n               (axi_rst_n),
   .mem_clk                 (mem_clk  ),
   .mem_rst_n               (mem_rst_n),
                           
//AXI4-MEM Master interface
   .S_AWADDR                (mem_aw_addr_i),
   .S_AWVALID               (mem_aw_valid_i),
   .S_AWSIZE                (mem_aw_size_i),
   .S_AWLEN                 (mem_aw_len_i),
   .S_AWBURST               (mem_aw_burst_i),
   .S_AWID                  (mem_aw_id_i),
   .S_AWREADY               (mem_aw_ready_o),
         
   .S_WDATA                 (mem_w_data_i),
   .S_WVALID                (mem_w_valid_i),
   .S_WSTRB                 (mem_w_strb_i),
   .S_WLAST                 (mem_w_last_i),
   .S_WREADY                (mem_w_ready_o),
        
   .S_ARADDR                (mem_ar_addr_i),
   .S_ARVALID               (mem_ar_valid_i),
   .S_ARSIZE                (mem_ar_size_i),
   .S_ARLEN                 (mem_ar_len_i),
   .S_ARBURST               (mem_ar_burst_i),
   .S_ARID                  (mem_ar_id_i),
   .S_ARREADY               (mem_ar_ready_o),
       
   .S_BREADY                (mem_b_ready_i),
   .S_BVALID                (mem_b_valid_o),
   .S_BRESP                 (mem_b_resp_o),
   .S_BID                   (mem_b_id_o),
                          
   .S_RREADY                (mem_r_ready_i),
   .S_RDATA                 (mem_r_data_o),
   .S_RVALID                (mem_r_valid_o),
   .S_RID                   (mem_r_id_o),
   .S_RLAST                 (mem_r_last_o),
   .S_RRESP                 (mem_r_resp_o),
                           
//From CSR                 
   .mem_upper_bound_addr_0  (mem_upper_bound_addr_0),
   .mem_lower_bound_addr_0  (mem_lower_bound_addr_0),
   .hybrid_wrap_cmd_en      (hybrid_wrap_cmd_en    ),
   .mem_xfer_pending         (mem_xfer_pending       ),
   .hyperflash_en	    (hyperflash_en     ),
                .mem_page_size (mem_page_size),
                                                   
//To Main controller      - mem_clk 
   .slv_mem_cmd_valid       (slv_mem_cmd_valid     ),
   .slv_mem_addr            (slv_mem_addr          ),
   .slv_arb_bytes_len             (slv_arb_bytes_len           ),
   .slv_mem_err             (slv_mem_err           ),
   .slv_mem_write           (slv_mem_write         ),
   .slv_mem_axi_len         (slv_mem_axi_len       ),
   .slv_mem_burst           (slv_mem_burst         ),
   .slv_mem_size            (slv_mem_size          ),
   .slv_mem_cont_rd_req     (slv_mem_cont_rd_req   ),
   .slv_mem_cont_wr_req     (slv_mem_cont_wr_req   ),
                                                  
//From Main controller    
   .mem_slv_cmd_ready       (mem_slv_cmd_ready     ),
   .current_xfer            (current_xfer          ),
                                                   
//To Mem transfer Interface -mem_clk  
   .slv_mem_wvalid          (slv_mem_wvalid        ),
   .slv_mem_wstrb           (slv_mem_wstrb         ),
   .slv_mem_wlast           (slv_mem_wlast         ),
   .slv_mem_wdata           (slv_mem_wdata         ),
//From Mem transfer Interface
   .mem_slv_wdata_err       (mem_slv_wdata_err     ),
   .mem_slv_wdata_ready     (mem_slv_wdata_ready   ),
                                                   
//From Mem transfer Interface - mem_clk
   .mem_slv_rdata_valid     (mem_slv_rdata_valid   ),
   .mem_slv_rdata           (mem_slv_rdata         ),
   .mem_slv_rdata_last      (mem_slv_rdata_last    ),
   .mem_slv_rdata_resp      (mem_slv_rdata_resp    ),
//To Mem transfer Interface 
   .slv_mem_rdata_ready     (slv_mem_rdata_ready   ),
                                                   
//From Main controller  - axi_clk 
   .spl_instr_req           (spl_instr_req         ),
   .spl_instr_stall         (spl_instr_stall       ),
                                                   
//To Main controller      
   .spl_instr_ack           (spl_instr_ack         )

             );

//ABC
main_controller_wrapper 
   #(
   .MEM_AXI_ADDR_WIDTH  (MEM_AXI_ADDR_WIDTH),
   .MEM_AXI_DATA_WIDTH  (MEM_AXI_DATA_WIDTH)
    )

MAIN_CNTRLR_INST (

// Global Signals
       .axi_clk    (axi_clk), 
       .axi_rst_n  (axi_rst_n), 

       .mem_clk    (mem_clk), 
       .mem_rst_n  (mem_rst_n), 

//FROM AXI4 SLV CNTRL - mem_clk
   
      .slv_mem_cmd_valid         (slv_mem_cmd_valid  ), 
      .slv_mem_addr              (slv_mem_addr       ), 
      .slv_arb_bytes_len               (slv_arb_bytes_len        ), 
      .slv_mem_err               (slv_mem_err        ), 
      .slv_mem_write             (slv_mem_write      ),
      .slv_mem_axi_len           (slv_mem_axi_len    ),
      .slv_mem_burst             (slv_mem_burst      ),
      .slv_mem_size              (slv_mem_size       ),
      .slv_mem_cont_rd_req       (slv_mem_cont_rd_req),
      .slv_mem_cont_wr_req       (slv_mem_cont_wr_req),
      .slv_mem_wlast             (slv_mem_wlast      ),
                               
//TO AXI4 SLV CNTRL            
      .mem_slv_cmd_ready         (mem_slv_cmd_ready        ),
      .current_xfer              (current_xfer             ),
                                                         
//TO AXI4 SLV CNTRL -axi_clk      
      .spl_instrn_req             (spl_instr_req            ),
      .spl_instrn_stall           (spl_instr_stall          ),
                                                        
//FROM AXI4 SLV CNTRL            
      .spl_instrn_ack             (spl_instr_ack            ),
                                                       
                                                           
      .wr_seq_sel             (wr_seq_sel_sync       ),
      .rd_seq_sel             (rd_seq_sel_sync       ),
      .wr_seq_id                 (wr_seq_id                ),
      .rd_seq_id                 (rd_seq_id                ),
                                                           
      .def_seq_sel               (def_seq_sel              ),
   //DEF SEQ 1                 
      .def_seq1_dword1           (def_seq1_dword1          ),
      .def_seq1_dword2           (def_seq1_dword2          ),
      .def_seq1_dword3           (def_seq1_dword3          ),
      .def_seq1_dword4           (def_seq1_dword4          ),
                                                           
   //DEF SEQ 1                
      .def_seq2_dword1           (def_seq2_dword1          ),
      .def_seq2_dword2           (def_seq2_dword2          ),
      .def_seq2_dword3           (def_seq2_dword3          ),
      .def_seq2_dword4           (def_seq2_dword4          ),

   .page_incr_en           (page_incr_en),
    .hyperflash_en	(hyperflash_en ),
    .mem_page_size (mem_page_size),
    .dual_seq_mode (dual_seq_mode),
    .cont_read_auto_status_en (cont_read_auto_status_en),

//From CSR - axi_clk            
      .cmd_no_of_opcode          (cmd_no_of_opcode         ),
      .cmd_xfer_data_rate        (cmd_xfer_data_rate       ),
      .cmd_no_of_pins            (cmd_no_of_pins           ),
      .cmd_opcode                (cmd_opcode               ),
      .wr_data_en                    (wr_data_en         ),
      .wdata_no_of_pins              (wdata_no_of_pins    ),
      .wdata_xfer_data_rate          (wdata_xfer_data_rate),
      .no_of_wr_data_bytes           (no_of_wr_data_bytes),
      .csr_cmd_xfer_valid        (csr_cmd_xfer_valid       ),
  .wr_rd_data_1   (wr_rd_data_1),  
  .wr_rd_data_2   (wr_rd_data_2),

      .read_cmd_opcode	 	 (read_cmd_opcode	    ),      				
      .read_no_of_pins           (read_no_of_pins       ),     					
      .read_xfer_data_rate	 (read_xfer_data_rate	), 
      .read_cmd_data_rate	 (read_cmd_data_rate	), 
      .read_no_of_opcode  	 (read_no_of_opcode         ),     					
      .csr_rd_xfer_valid     (csr_rd_xfer_valid    ),
      .no_of_csr_rd_addr_bytes       	  (no_of_csr_rd_addr_bytes    ),
      .no_of_csr_rd_data_bytes       	      (no_of_csr_rd_data_bytes      		),
      .rd_monitor_bit               (rd_monitor_bit            ), 
      .rd_monitor_value             (rd_monitor_value          ), 
      .rd_monitor_en             (rd_monitor_en          ), 
      .subseq_rd_xfer_time   (subseq_rd_xfer_time),

      .status_cmd_opcode         (status_cmd_opcode        ),
      .status_no_of_pins         (status_no_of_pins        ),
      .status_xfer_data_rate     (status_xfer_data_rate    ),
      .status_cmd_data_rate      (status_cmd_data_rate    ),
      .status_no_of_opcode         (status_no_of_opcode        ),
      .status_monitor_bit        (status_monitor_bit            ), 
      .status_monitor_value      (status_monitor_value          ), 
      .status_monitor_en         (status_monitor_en            ), 
      .no_of_auto_status_rd_data_bytes   (no_of_auto_status_rd_data_bytes),
      .subseq_status_rd_xfer_time        (subseq_status_rd_xfer_time     ),
      .auto_status_rd_addr_bytes         (auto_status_rd_addr_bytes      ),
      .auto_initiate_status_read_seq     (auto_initiate_status_read_seq  ),
      .status_reg_rd_xfer_time           (status_reg_rd_xfer_time        ),
      .auto_initiate_status_addr         (auto_initiate_status_addr      ),
      .status_reg_en             (status_reg_en           ),

      .auto_initiate_write_en_seq    (auto_initiate_write_en_seq),
      .auto_initiate_write_en_seq_2  (auto_initiate_write_en_seq_2),
      .auto_initiate_post_wren_seq   (auto_initiate_post_wren_seq),
      .post_wren_seq_data            (post_wren_seq_data),
      .auto_initiate_write_dis_seq    (auto_initiate_write_dis_seq),
                             
   //WRITE EN SEQ            
      .write_en_seq_reg_1        (write_en_seq_reg_1       ),
      .write_en_seq_reg_2        (write_en_seq_reg_2       ),
                                                          
   //WRITE DIS SEQ          
      .write_dis_seq_reg_1       (write_dis_seq_reg_1      ),
      .write_dis_seq_reg_2       (write_dis_seq_reg_2      ),


//TO CSR - mem_clk        
      .seq_ram_rd_addr           (seq_ram_rd_addr          ),
      .seq_ram_rd_en             (seq_ram_rd_en            ),
      .seq_ram_rd_data           (seq_ram_rd_data          ),
                                                     
//TO CSR - axi_clk        
      .csr_cmd_xfer_ack          (csr_cmd_xfer_ack         ),
      .csr_cmd_xfer_success      (csr_cmd_xfer_success     ),
      .mem_xfer_auto_status_rd_done   (mem_xfer_auto_status_rd_done     ),
      .csr_rd_xfer_ack       (csr_rd_xfer_ack      ),
      .monitoring_xfer       (monitoring_xfer      ),

//To Memory xfer interface -mem_clk
      .axi_start_mem_xfer_valid  (axi_start_mem_xfer_valid ),
      .addr_mem_xfer             (addr_mem_xfer            ),
      .rw_len_mem_xfer           (rw_len_mem_xfer          ), // readnot used; during wrap write ony used
      .xfer_mem_error            (xfer_mem_error           ),
      .xfer_wr_rd                (xfer_wr_rd               ),
      .xfer_axi_len              (xfer_axi_len             ),
      .xfer_btype                (xfer_btype               ),
      .xfer_bsize                (xfer_bsize               ),
      .cont_rd_req               (cont_rd_req              ),
      .cont_wr_req               (cont_wr_req              ),
                                                          
      .csr_start_mem_xfer_valid  (csr_start_mem_xfer_valid ),
      .no_of_data_bytes          (no_of_data_bytes),
      .no_of_xfer	         (no_of_xfer),

      .wait_subseq_pg_wr (wait_subseq_pg_wr),

// common for both axi_start_memfer_valid and csr_start_mem_xfer_valid
      .seq_reg_0                 (seq_reg_0                ),
      .seq_reg_1                 (seq_reg_1                ),
      .seq_reg_2                 (seq_reg_2                ),
      .seq_reg_3                 (seq_reg_3                ),
      .auto_initiate             (auto_initiate            ),

      .seq_change                (seq_change               ),
                                                          
//From Memory xfer interface     
      .mem_rd_valid (mem_rd_valid),
      .mem_rd_data  (mem_rd_data ),
   .enter_jump_on_cs       (enter_jump_on_cs), //level
      .csr_dqs_non_toggle_err    (csr_dqs_non_toggle_err),// level
      .dual_seq_mode_reg (dual_seq_mode_reg),
                                                          
//From Memory xfer interface     
      .axi_start_mem_xfer_ack    (axi_start_mem_xfer_ack   ),
      .csr_start_mem_xfer_ack    (csr_start_mem_xfer_ack   ),
      .csr_mem_xfer_bsy          (csr_mem_xfer_bsy         ),
      .subseq_pg_wr (subseq_pg_wr),
      .deassert_cs (deassert_cs),
      .dual_seq_mode_ack (dual_seq_mode_ack),
      .rd_done                   (rd_done                  )
);

//ABC
memory_interface_controller 

# (
   .MEM_AXI_DATA_WIDTH (MEM_AXI_DATA_WIDTH),
   .MEM_AXI_ADDR_WIDTH (MEM_AXI_ADDR_WIDTH),
   .RCV_DQ_FIFO_ADDR_WIDTH (RCV_DQ_FIFO_ADDR_WIDTH)
  )

MEMORY_INTF_CNTRLR_INST (
   .mem_clk              (mem_clk),     
   .reset_n              (mem_rst_n), 
   
   //Input from Main controller -mem_clk
   .axi_start_mem_xfer   (axi_start_mem_xfer_valid),                       
   .addr_mem_xfer        (addr_mem_xfer),            
   .rw_len_mem_xfer      (rw_len_mem_xfer),              
   .xfer_mem_error       (xfer_mem_error),
   .xfer_wr_rd           ( xfer_wr_rd   ),
   .xfer_axi_len         ( xfer_axi_len ),
   .xfer_btype           ( xfer_btype   ),
   .xfer_bsize           ( xfer_bsize   ),
   .cont_rd_req          (cont_rd_req      ),
      .cont_wr_req               (cont_wr_req              ),
   .auto_initiate_seq    (auto_initiate),

   .csr_start_mem_xfer   (csr_start_mem_xfer_valid),                 
   .no_of_data_bytes     (no_of_data_bytes),
   .no_of_xfer           (no_of_xfer),

      .wait_subseq_pg_wr (wait_subseq_pg_wr),
   .seq_reg_0            (seq_reg_0  ), 
   .seq_reg_1            (seq_reg_1  ),   
   .seq_reg_2            (seq_reg_2  ),     
   .seq_reg_3            (seq_reg_3  ),   
   .sequence_change      (seq_change), // level 
  .dual_seq_mode_reg (dual_seq_mode_reg),

  //Ouptut to Main Controller
   .axi_start_mem_xfer_ack (axi_start_mem_xfer_ack),
   .csr_start_mem_xfer_ack (csr_start_mem_xfer_ack),
   .csr_mem_xfer_bsy       (csr_mem_xfer_bsy      ), //level
      .subseq_pg_wr (subseq_pg_wr),
      .deassert_cs (deassert_cs),
   .rd_done                (rd_done               ),
  .dual_seq_mode_ack (dual_seq_mode_ack),
  
   //Input from CSR
   .dummy_cycle_config  (dummy_cycle_config ),     
   .dummy_cyc_HiZ       (dummy_cycle_HiZ  ),                      
   .dummy_cyc_drive     (dummy_cycle_drive),                        
   .csr_dlp_cyc_cnt     (dlp_pattern_cyc_cnt ),                        
   .cs_hold             (cs_hold ),         
   .cs_setup            (cs_setup), 
   .cs_high             (cs_high ) ,
   .jhr_en              (jhr_en_sync),
   .predrive_en         (predrive_en),
   .dqs_non_tgl_to      (dqs_non_tgl_to),
   .page_incr_en           (page_incr_en),
  .mem_page_size (mem_page_size),

    .hyperflash_en	(hyperflash_en ),
  .wr_rd_data_1                  (wr_rd_data_1), 
  .wr_rd_data_2                  (wr_rd_data_2), 

  .mem_rd_data_ack (mem_rd_data_ack_sync ),

   .enter_jump_on_cs       (enter_jump_on_cs), //level

//Output to CSR - mem_clk
   .calib_tap_out             (calib_tap_out),                          
   .calib_tap_valid           (calib_tap_valid), //level                             
   .mem_rd_data    (mem_rd_data ),
   .mem_rd_valid   (mem_rd_valid), // level
   .mem_illegal_instrn        (mem_illegal_instrn     ),// level  
   .illegal_strobe            (illegal_strobe         ),// level  
   .axi_dqs_non_toggle_err    (mem_dqs_non_toggle_err),// level  
   .csr_dqs_non_toggle_err    (csr_dqs_non_toggle_err),// level

//From AXI4_SLV_CNTRL - mem_clk
   .slv_mem_wdata_valid     (slv_mem_wvalid),
   .slv_mem_wstrb           (slv_mem_wstrb      ),
   .slv_mem_wlast           (slv_mem_wlast      ),
   .slv_mem_wdata           (slv_mem_wdata      ),           
                           
//To AXI4_SLV_CNTRL        
   .slv_mem_wdata_ack       (mem_slv_wdata_ready),
   .slv_mem_wdata_err       (mem_slv_wdata_err  ),
                          
//From AXI4_SLV_CNTRL  - mem_clk  
   .slv_mem_rdata_ack       (slv_mem_rdata_ready  ),
                         
//To AXI4_SLV_CNTRL      
   .slv_mem_rdata_valid     (mem_slv_rdata_valid ),
   .slv_mem_rdata           (mem_slv_rdata       ),
   .slv_mem_rlast           (mem_slv_rdata_last  ),
   .slv_mem_rresp           (mem_slv_rdata_resp  ),

//Input from Memory
    .dqs                 (dqs_ip   ),            
    .dq_in               (dq_in_ip),              

//Output to Memory wrapper
    .cs_n            (cs_n_ip   ),                                              
    .dq_out          (dq_out_16),             
    .dq_oe           (dq_oe ),            
    .sclk_en         (sclk_en   )           

);


synchronizer_top SYNC_TOP_INST (
	.axi_clk    			(axi_clk),
	.axi_rst_n  			(axi_rst_n), 
	.mem_clk    			(mem_clk),
	.mem_rst_n  			(mem_rst_n),
	.mem_illegal_instrn          (mem_illegal_instrn),
	.mem_illegal_instrn_sync     (mem_illegal_instrn_sync),



	.mem_dqs_non_toggle_err	     (mem_dqs_non_toggle_err),	
	.mem_dqs_non_toggle_err_sync (mem_dqs_non_toggle_err_sync),



	.csr_dqs_non_toggle_err      (csr_dqs_non_toggle_err),
	.csr_dqs_non_toggle_err_sync (csr_dqs_non_toggle_err_sync),

	.illegal_strobe  	     (illegal_strobe), 
	.illegal_strobe_sync	     (illegal_strobe_sync),
	.calib_tap_valid 	     (calib_tap_valid),
	.calib_tap_valid_sync	     (calib_tap_valid_sync),

	.mem_rd_valid     (mem_rd_valid),
	.mem_rd_valid_sync(mem_rd_valid_sync),
	.mem_xfer_pending            (mem_xfer_pending),
	.mem_xfer_pending_sync       (mem_xfer_pending_sync),
	.slv_mem_err		     (slv_mem_err),
	.slv_mem_err_sync	     (slv_mem_err_sync),
	.rd_seq_sel		     (rd_seq_sel),	
	.rd_seq_sel_sync	     (rd_seq_sel_sync),	
	.wr_seq_sel		     (wr_seq_sel),	
	.wr_seq_sel_sync	     (wr_seq_sel_sync),	
	.jhr_en			     (jhr_en),
	.jhr_en_sync		     (jhr_en_sync),
	.mem_rd_data_ack  (mem_rd_data_ack),
	.mem_rd_data_ack_sync  (mem_rd_data_ack_sync)
                                 );
endmodule
