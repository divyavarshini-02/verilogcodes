
`timescale 1ps/1ps
module xspi_cntrl_wrapper
	(
                mem_clk_0,
                mem_clk_90,
                mem_clk_180,
                mem_rst_n,

                axi_clk,
                axi_rst_n,

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

// To memory
                 CS_N,  
                 SCLK,

//To and From memory
                 DQ,

// From memory
                 DQS
	);

parameter MEM_AXI_ID_WIDTH          = 4;
parameter MEM_AXI_ADDR_WIDTH	    = 32;
parameter MEM_AXI_DATA_WIDTH        = 32;
parameter MEM_DQ_BUS_WIDTH              = 8;

localparam MEM_AXI_LEN_WIDTH	    = 8;
localparam MEM_AXI_RESP_WIDTH       = 2;
localparam MEM_AXI_BURST_TYPE_WIDTH = 2;
localparam MEM_AXI_SIZE_WIDTH       = 3;

localparam CSR_AXI_ID_WIDTH         = 4 ;
localparam CSR_AXI_ADDR_WIDTH       = 32;
localparam CSR_AXI_DATA_WIDTH       = 32;
localparam CSR_AXI_LEN_WIDTH        = 8;
localparam CSR_AXI_BURST_WIDTH      = 2 ;
localparam CSR_AXI_SIZE_WIDTH       = 3 ;
localparam CSR_AXI_RESP_WIDTH       = 2 ;
localparam CSR_AXI_STROBE_WIDTH     = 4 ;

input           mem_clk_0;
input           mem_clk_90;
input           mem_clk_180;
input           mem_rst_n;

input           axi_clk;
input           axi_rst_n;

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

// To memory
output            CS_N;
output            SCLK;

//To and From memory
inout  [MEM_DQ_BUS_WIDTH-1:0] DQ;

// From memory
input             DQS; 


//----------------------------------------WIRE declarations--------------------------------

wire [15:0]                 dq_out_ip;
wire [15:0]                 dq_oe_ip; 
wire [7:0]                  ddr_delay_tap;
wire                        dqs_mode;
wire [7:0]                  dq_in_ip;

xspi_cntrl_ip 
#( 
   .MEM_AXI_ID_WIDTH   (MEM_AXI_ID_WIDTH  ),   
   .MEM_AXI_ADDR_WIDTH (MEM_AXI_ADDR_WIDTH),
   .MEM_AXI_DATA_WIDTH (MEM_AXI_DATA_WIDTH),
   .MEM_DQ_BUS_WIDTH(MEM_DQ_BUS_WIDTH)
 )


XSPI_CNTRL_IP_INST
	(
                .axi_clk          (axi_clk),
                .axi_rst_n        (axi_rst_n),

                .mem_clk          (mem_clk_0),
                .mem_rst_n        (mem_rst_n),

// AXI CSR INTF

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

// AXI MEM INTF

//AXI WRITE ADDRESS CHANNEL
                .mem_aw_valid_i (mem_aw_valid_i ),
                .mem_aw_id_i    (mem_aw_id_i    ),
                .mem_aw_addr_i  (mem_aw_addr_i  ),
                .mem_aw_len_i   (mem_aw_len_i   ),
                .mem_aw_size_i  (mem_aw_size_i  ),
                .mem_aw_burst_i (mem_aw_burst_i ),
                .mem_aw_ready_o (mem_aw_ready_o ),

//AXI READ ADDRESS CHANNEL
                .mem_ar_valid_i (mem_ar_valid_i ),
                .mem_ar_id_i    (mem_ar_id_i    ),
                .mem_ar_addr_i  (mem_ar_addr_i  ),
                .mem_ar_len_i   (mem_ar_len_i   ),
                .mem_ar_size_i  (mem_ar_size_i  ),
                .mem_ar_burst_i (mem_ar_burst_i ),
                .mem_ar_ready_o (mem_ar_ready_o ),

//AXI WRITE  DATA CHANNEL

                .mem_w_data_i   (mem_w_data_i   ),
                .mem_w_strb_i   (mem_w_strb_i   ),
                .mem_w_valid_i  (mem_w_valid_i  ),
                .mem_w_last_i   (mem_w_last_i   ),
                .mem_w_ready_o  (mem_w_ready_o  ),

//AXI WRITE RESPONSE CHANNEL

                .mem_b_id_o      (mem_b_id_o    ),
                .mem_b_valid_o   (mem_b_valid_o ),
                .mem_b_resp_o    (mem_b_resp_o  ),
                .mem_b_ready_i   (mem_b_ready_i ),

//AXI READ DATA CHANNEL
                .mem_r_id_o    (mem_r_id_o    ),
                .mem_r_data_o  (mem_r_data_o  ),
                .mem_r_valid_o (mem_r_valid_o ),
                .mem_r_resp_o  (mem_r_resp_o  ),
                .mem_r_last_o  (mem_r_last_o  ),
                .mem_r_ready_i (mem_r_ready_i ),
                

                .def_seq_sel   (def_seq_sel),
// TO CPU
                .xspi_csr_xfer_status_intr (xspi_csr_xfer_status_intr ),
                .xspi_mem_xfer_status_intr (xspi_mem_xfer_status_intr ),

// To wrapper
                .cs_n_ip   (ce_n_ip),  
                .sclk_en   (sclk_en   ),
                .dq_out_16 (dq_out_ip),
                .dq_oe     (dq_oe_ip),                 

                .ddr_delay_tap(ddr_delay_tap),
                .dqs_mode(dqs_mode),
// From wrapper
                .dq_in_ip    (dq_in_ip ),
                .dqs_ip   (dqs_ip)
	);


xspi_phy 

#(
   .MEM_DQ_BUS_WIDTH(MEM_DQ_BUS_WIDTH)
 )

XSPI_PHY

   (

//Inputs
   . mem_clk_0        (mem_clk_0  ),
   . mem_clk_90       (mem_clk_90 ),
   . mem_clk_180      (mem_clk_180),
   . rst_n            (mem_rst_n),

   . sclk_en          (sclk_en    ),
   . ce_n_ip          (ce_n_ip    ),
   . dq_out_ip        (dq_out_ip  ),
   . dq_oe_ip         (dq_oe_ip),

//From CSR
   .ddr_delay_tap       (ddr_delay_tap),
   .dqs_mode            (dqs_mode),

//To CNTRL           
   . dq_in_ip         (dq_in_ip),
   . dqs_ip           (dqs_ip),
                     
//To memory         
   . ce_n             (CS_N),
   . sclk             (SCLK),
   . dq               (DQ),
   . dqs              (DQS)
   );

endmodule
