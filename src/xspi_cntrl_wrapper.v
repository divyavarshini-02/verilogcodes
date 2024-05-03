
`timescale 1ps/1ps
module xspi_cntrl_wrapper
	(
                mem_clk_0,
                mem_clk_90,
                mem_clk_180,
                mem_rst_n,

                ahb_clk,
                ahb_rst_n,
	  	apb_clk,
	  	apb_rst_n,

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


parameter AHB_ADDR_WIDTH	= 32;
parameter AHB_DATA_WIDTH        = 32;
parameter MEM_DQ_BUS_WIDTH      = 8;
parameter APB_ADDR_WIDTH        = 12;
parameter APB_DATA_WIDTH        = 32;

/*localparam MEM_AXI_LEN_WIDTH	    = 8;
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
localparam CSR_AXI_STROBE_WIDTH     = 4 ;*/

input           mem_clk_0;
input           mem_clk_90;
input           mem_clk_180;
input           mem_rst_n;

input           ahb_clk;
input           ahb_rst_n;
input   	apb_clk;
input  		apb_rst_n;

// AHB CSR INTERFACE

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
      
   .AHB_ADDR_WIDTH (AHB_ADDR_WIDTH),
   .AHB_DATA_WIDTH (AHB_DATA_WIDTH),
   .APB_DATA_WIDTH (APB_DATA_WIDTH),
   .APB_ADDR_WIDTH (APB_ADDR_WIDTH)
   //.MEM_DQ_BUS_WIDTH(MEM_DQ_BUS_WIDTH)
 )


XSPI_CNTRL_IP_INST
	(
                .ahb_clk          (ahb_clk),
                .ahb_rst_n        (ahb_rst_n),
	  	.apb_clk 	  (apb_clk),
		.apb_rst_n 	  (apb_rst_n),
                .mem_clk          (mem_clk_0),
                .mem_rst_n        (mem_rst_n),

//AHB Interface
   		.HADDR 		(HADDR),   
   		.HBURST 	(HBURST),  
   		.HREADY		(HREADY), 
   		.HSELx		(HSELx),    
   		.HSIZE		(HSIZE),    
   		.HTRANS		(HTRANS),   
   		.HWDATA		(HWDATA),   
   		.HWRITE		(HWRITE),   

   		.HRDATA		(HRDATA),   
   		.hreadyout	(hreadyout),
   		.HRESP		(HRESP),    

//CSR - APB bus
   		.apb_sel	(apb_sel),
   		.apb_en		(apb_en),
   		.apb_write	(apb_write),
   		.apb_addr	(apb_addr),
   		.apb_wdata	(apb_wdata),
   		.apb_rdata	(apb_rdata),
   		.apb_ready	(apb_ready),

//To Controller
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
