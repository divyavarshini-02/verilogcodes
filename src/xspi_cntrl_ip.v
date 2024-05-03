

`timescale 1ns/1ps

`define CSR_DPRAM_ADDR_WIDTH     10

`define ARM_UD_MODEL

module xspi_cntrl_ip
   (

   ahb_clk,
   ahb_rst_n,             

   apb_clk,
   apb_rst_n,             

   mem_clk,
   mem_rst_n,             

//AHB Interface
   HADDR ,   
   HBURST ,  
   HREADY, 
   HSELx,    
   HSIZE,    
   HTRANS,   
   HWDATA,   
   HWRITE,   

   HRDATA,   
   hreadyout,
   HRESP,    

//CSR - APB bus
   apb_sel,
   apb_en,
   apb_write,
   apb_addr,
   apb_wdata,
   apb_rdata,
   apb_ready,

/// TO main controller
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

parameter AHB_ADDR_WIDTH = 32;
parameter AHB_DATA_WIDTH = 32; //32,64
parameter APB_ADDR_WIDTH = 12;
parameter APB_DATA_WIDTH = 32;
localparam RCV_DQ_FIFO_ADDR_WIDTH   = 4;// depth 16

/*localparam MEM_AHB_LEN_WIDTH	    = 8;
localparam MEM_AHB_RESP_WIDTH       = 2;
localparam MEM_AHB_BURST_TYPE_WIDTH = 2;
localparam MEM_AHB_SIZE_WIDTH       = 3;*/
localparam XFER_LEN_WIDTH = (AHB_DATA_WIDTH==32) ? 11 : (AHB_DATA_WIDTH==64) ? 12 : 13 ;


//localparam DQS_CNT_WIDTH = 10; // maximum is 1024 bytes in both 32 bit and 64 bit interface due to max 1KB boundary cross
//localparam DQS_CNT_WIDTH = (AHB_DATA_WIDTH==32) ? 10: 11;

input   ahb_clk;
input   ahb_rst_n;
input   apb_clk;
input   apb_rst_n;
input   mem_clk;
input   mem_rst_n;

//AHB Interface
input	[AHB_ADDR_WIDTH-1:0]	HADDR;			// READ OR WRITE ADDRESS FROM MASTER TO SLAVE//
input			[2:0]	HBURST;			// BUSRT LENGTH AND TYPE FROM MASTER//
input				HREADY;			// HREADY INPUT//
input				HSELx;			// SLAVE SELECT FROM MASTER//
input			[2:0]	HSIZE;			// DATA SIZE RECEIVE FROM MASTER//
input			[1:0]	HTRANS;			// TRANSFER MODE OF MASTER// 
input	[AHB_DATA_WIDTH-1:0]	HWDATA;			// WRITE DATA FROM MASTER TO SLAVE// 
input				HWRITE;			// WRITE OR READ SIGNAL//

output	[AHB_DATA_WIDTH-1:0]	HRDATA;			// READ DATA TO MASTER//
output				hreadyout;		// HREADY TO MASTER
output				HRESP;			// ERROR RESPONSE OF SLAVE TO MASTER//

//CSR - APB bus
//
input   apb_sel;
input   apb_en;
input   apb_write;
input [APB_ADDR_WIDTH-1:0]  apb_addr;
input [APB_DATA_WIDTH-1:0]  apb_wdata;
output[APB_DATA_WIDTH-1:0]  apb_rdata;
output  apb_ready;

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
wire [AHB_DATA_WIDTH -1:0] seq_ram_rd_data;         

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
wire [2:0]  no_of_csr_rd_addr_bytes;
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


wire [AHB_ADDR_WIDTH-1 :0] addr_mem_xfer;
wire [4:0]       rw_len_mem_xfer;  // read - not used; write - denotes number of mem_xfer_wvalid
wire   [7:0]                    xfer_ahb_len;            
wire   [1:0]                    xfer_btype;
wire   [2:0]                    xfer_bsize;

wire [31:0] seq_reg_0;
wire [31:0] seq_reg_1;
wire [31:0] seq_reg_2;
wire [31:0] seq_reg_3;

wire [3:0]  slv_mem_wstrb;
wire [31:0] slv_mem_wdata;           

wire  [AHB_DATA_WIDTH-1 : 0 ]     mem_slv_rdata;
wire [1:0]                            mem_slv_rdata_resp;

wire [AHB_ADDR_WIDTH-1:0] slv_mem_addr     ;
wire [XFER_LEN_WIDTH-1:0]     slv_arb_bytes_len      ;
wire [7:0] slv_mem_ahb_len  ;
wire [1:0] slv_mem_burst    ;
wire [2:0] slv_mem_size     ;
wire [1:0] mem_slv_wdata_err;

xspi_csr_reg_wrapper CSR
   (
//APB BUS
    . apb_clk                             (apb_clk),
    . mem_clk                             (mem_clk  ),
    . apb_rst_n                           (apb_rst_n),
                                         
    . apb_sel                             (apb_sel  ),
    . apb_en                              (apb_en   ),
    . apb_write                           (apb_write),
    . apb_addr                            (apb_addr ),
    . apb_wdata                           (apb_wdata),
    . apb_rdata                           (apb_rdata),
    . apb_ready                           (apb_ready),
                                        
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


//To Main controller - ahb_clk 
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

// FROM MAIN CONTROLLER   - ahb_clk  
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

ahb_slave_wrapper
   #(
   . AHB_ADDR_WIDTH (AHB_ADDR_WIDTH),
   . AHB_DATA_WIDTH (AHB_DATA_WIDTH)
    )
AHB_SLV_CTRL( 

   . ahb_clk                         (ahb_clk),
   . ahb_rst_n                       (ahb_rst_n),
   . mem_clk                         (mem_clk),
   . mem_rst_n                       (mem_rst_n),

//AHB Interface
   . HADDR                       (HADDR     ),
   . HBURST                      (HBURST    ),
   . HREADY                      (HREADY    ),
   . HSELx                       (HSELx     ),
   . HSIZE                       (HSIZE     ),
   . HTRANS                      (HTRANS    ),
   . HWDATA                      (HWDATA    ),
   . HWRITE                      (HWRITE    ),

   . HRDATA                      (HRDATA), 
   . hreadyout                   (hreadyout ),
   . HRESP                       (HRESP ),

   /* .ap_mem_wrap_size  (ap_mem_wrap_size),
    .rd_prefetch_en    (rd_prefetch_en),
        .mr_access         (mr_access_int ),
    .mr8_bsize         (mr8_bsize ),
       
   .mr8_wr_success                    (mr8_wr_success),*/
   
  // .mr8_btype                    (mr8_btype ),
   .mem_base_addr    		 (mem_lower_bound_addr_0),
   .mem_top_addr      		 (mem_upper_bound_addr_0),
   .ce_n_ip                      (cs_n_ip),           
   . ahb_cmd_valid               (slv_mem_cmd_valid),
   . ahb_addr                    (slv_mem_addr ),
   . ahb_write                   (slv_mem_write),
   . ahb_burst                   (slv_mem_burst),
   . ahb_len                     (slv_mem_ahb_len ),
  // . ahb_mr_access               (ahb_mr_access),
   . xfer_ahb_len                (xfer_ahb_len ), 
   . ahb_size                    (ahb_size),
//   . ahb_err                     (mem_mr_error),
   . cont_wr_rd_req              (slv_mem_cont_rd_req), // continuous read alone to use during prefetch


//   outstanding feature in AHB
   . ahb_cmd_ready               (mem_slv_cmd_ready ),
                                
   . ahb_wvalid                  (slv_mem_wvalid),
   . ahb_wstrb                   (slv_mem_wstrb),
   . ahb_wlast_o                 (slv_mem_wlast),
   . ahb_wdata                   (slv_mem_wdata),
//   . ahb_wdata_err               (mem_mr_wdata_err), 
   . ahb_wdata_ready_in          (slv_mem_wdata_ack),
                               
   . ahb_rdata_valid             (slv_mem_rdata_valid),
   . ahb_rdata                   (slv_mem_rdata ),
   . ahb_rdata_last              (slv_mem_rlast),
   . ahb_rdata_resp              (slv_mem_rresp),
   . ahb_rdata_ready             (slv_mem_rdata_ack),
   . rd_fifo_flush_start_mem_clk_sync            (rd_fifo_flush_start_mem_clk_sync),
   . dq_rdata_flush_done	(dq_fifo_flush_done),
                              
   . spl_instr_req                   (spl_instrn_req),
   . spl_instr_ack                   (spl_instrn_ack),
   . spl_instr_stall                 (spl_instrn_stall)
);
 
main_controller_wrapper 
   #(
   .AHB_ADDR_WIDTH  (AHB_ADDR_WIDTH),
   .AHB_DATA_WIDTH  (AHB_DATA_WIDTH)
    )

MAIN_CNTRLR_INST (

// Global Signals
       .ahb_clk    (ahb_clk), 
       .ahb_rst_n  (ahb_rst_n), 

       .mem_clk    (mem_clk), 
       .mem_rst_n  (mem_rst_n), 

//FROM AHB SLV CNTRL - mem_clk
   
      .slv_mem_cmd_valid         (slv_mem_cmd_valid   ), 
      .slv_mem_addr              (slv_mem_addr ), 
      .slv_arb_bytes_len         (slv_arb_bytes_len), 
      .slv_mem_err               (2'b00        ), 
      .slv_mem_write             (slv_mem_write      ),
      .slv_mem_ahb_len           (slv_mem_ahb_len    ),
      .slv_mem_burst             (slv_mem_burst      ),
      .slv_mem_size              (slv_mem_size       ),
      .slv_mem_cont_rd_req       (slv_mem_cont_rd_req),
      .slv_mem_cont_wr_req       (),
      .slv_mem_wlast             (slv_mem_wlast      ),
                               
//TO AHB SLV CNTRL            
      .mem_slv_cmd_ready         (mem_slv_cmd_ready         ),
      .current_xfer              (current_xfer             ),
                                                         
//TO AHB SLV CNTRL -ahb_clk      
      .spl_instrn_req             (spl_instr_req            ),
      .spl_instrn_stall           (spl_instr_stall          ),
                                                        
//FROM AHB SLV CNTRL            
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

//From CSR - ahb_clk            
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
                                                     
//TO CSR - apb_clk        
      .csr_cmd_xfer_ack          (csr_cmd_xfer_ack         ),
      .csr_cmd_xfer_success      (csr_cmd_xfer_success     ),
      .mem_xfer_auto_status_rd_done   (mem_xfer_auto_status_rd_done     ),
      .csr_rd_xfer_ack       (csr_rd_xfer_ack      ),
      .monitoring_xfer       (monitoring_xfer      ),

//To Memory xfer interface -mem_clk
      .ahb_start_mem_xfer_valid  (ahb_start_mem_xfer_valid ),
      .addr_mem_xfer             (addr_mem_xfer            ),
      .rw_len_mem_xfer           (rw_len_mem_xfer          ), // readnot used; during wrap write ony used
      .xfer_mem_error            (xfer_mem_error           ),
      .xfer_wr_rd                (xfer_wr_rd               ),
      .xfer_ahb_len              (xfer_ahb_len             ),
      .xfer_btype                (xfer_btype               ),
      .xfer_bsize                (xfer_bsize               ),
      .cont_rd_req               (cont_rd_req              ),
      .cont_wr_req               (cont_wr_req              ),
                                                          
      .csr_start_mem_xfer_valid  (csr_start_mem_xfer_valid ),
      .no_of_data_bytes          (no_of_data_bytes),
      .no_of_xfer	         (no_of_xfer),

      .wait_subseq_pg_wr (wait_subseq_pg_wr),

// common for both ahb_start_memfer_valid and csr_start_mem_xfer_valid
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
      .ahb_start_mem_xfer_ack    (ahb_start_mem_xfer_ack   ),
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
   .AHB_DATA_WIDTH (AHB_DATA_WIDTH),
   .AHB_ADDR_WIDTH (AHB_ADDR_WIDTH),
   .RCV_DQ_FIFO_ADDR_WIDTH (RCV_DQ_FIFO_ADDR_WIDTH)
  )

MEMORY_INTF_CNTRLR_INST (
   .mem_clk              (mem_clk),     
   .reset_n              (mem_rst_n), 
   
   //Input from Main controller -mem_clk
   .ahb_start_mem_xfer   (ahb_start_mem_xfer_valid),                       
   .addr_mem_xfer        (addr_mem_xfer),            
   .rw_len_mem_xfer      (rw_len_mem_xfer),              
   .xfer_mem_error       (xfer_mem_error),
   .xfer_wr_rd           ( xfer_wr_rd   ),
   .xfer_ahb_len         ( xfer_ahb_len ),
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
   .ahb_start_mem_xfer_ack (ahb_start_mem_xfer_ack),
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

//From AHB_SLV_CNTRL - mem_clk
   .slv_mem_wdata_valid     (slv_mem_wvalid),
   .slv_mem_wstrb           (slv_mem_wstrb      ),
   .slv_mem_wlast           (slv_mem_wlast      ),
   .slv_mem_wdata           (slv_mem_wdata      ),           
                           
//To AHB_SLV_CNTRL        
   .slv_mem_wdata_ack       (slv_mem_wdata_ack),
   .slv_mem_wdata_err       (mem_slv_wdata_err  ),
                          
//From AHB_SLV_CNTRL  - mem_clk  
   .slv_mem_rdata_ack       (slv_mem_rdata_ack  ),
                         
//To AHB_SLV_CNTRL      
   .slv_mem_rdata_valid     (slv_mem_rdata_valid ),
   .slv_mem_rdata           (slv_mem_rdata       ),
   .slv_mem_rlast           (slv_mem_rlast  ),
   .slv_mem_rresp           (slv_mem_rresp  ),

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
	.ahb_clk    			(ahb_clk),
	.ahb_rst_n  			(ahb_rst_n), 
	.apb_clk			(apb_clk),
	.apb_rst_n			(apb_rst_n),
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

