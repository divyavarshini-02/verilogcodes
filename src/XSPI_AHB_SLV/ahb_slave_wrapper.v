

/*************************************************************************************


*************************************************************************************/

module ahb_slave_wrapper ( 

// INPUTS AND OUTPUTS OF AHB INTERFACE
	HRDATA,
	hreadyout,
	HRESP,
	HADDR,
	HBURST,
	HREADY,
	HSELx,
	HSIZE,
	HTRANS,
	HWDATA,
	HWRITE,
	ahb_clk,
	ahb_rst_n,

   	mem_clk,
   	mem_rst_n,	
	ahb_cmd_valid,
	//ahb_mr_access,
   	ahb_addr,
   	ahb_write,
   	ahb_burst,
   	ahb_len,
        xfer_ahb_len,
   	ahb_size,
   	cont_wr_rd_req,
   	ahb_cmd_ready, 

   	ahb_rdata_valid,
   	ahb_rdata,
   	ahb_rdata_last,
   	ahb_rdata_resp,
   	ahb_rdata_ready,


     	ahb_wdata_ready_in, 
     	ahb_wdata, 
     	ahb_wvalid, 
     	ahb_wstrb, 
     	ahb_wlast_o,
	rd_fifo_flush_start_mem_clk_sync,
	dq_rdata_flush_done,
	
//        ahb_wr_burst_complete,
	
        //ap_mem_wrap_size,
        //rd_prefetch_en,

//	mr8_btype,
        mem_base_addr,
        mem_top_addr ,
        //mr_access    ,
        //mr8_bsize    ,
        ce_n_ip,
        //mr8_wr_success   , 
   	spl_instr_req,
   	spl_instr_ack,
   	spl_instr_stall
);

///////////////////////
// Parameters
///////////////////////

parameter AHB_DATA_WIDTH	= 32;				// DATA WIDTH OF AHB//
parameter AHB_ADDR_WIDTH	= 32;
parameter LEN_WIDTH       	= 10;
parameter PTR_WIDTH_CMD_FF  	= 3; 				// READ AND WRITE POINTERS WIDTH //
parameter DEPTH_CMD_FF  	= 7; 				// FIFO DEPTH //
parameter DATA_WIDTH_CMD_FF 	= 40;				// FIFO DATA WIDTH // 
parameter PTR_WIDTH_WR_FF  	= 5; 				// READ AND WRITE POINTERS WIDTH //
parameter DEPTH_WR_FF  		= 31; 	
parameter PTR_WIDTH_RD_FF  	= 5; 				// READ AND WRITE POINTERS WIDTH //
parameter DEPTH_RD_FF  		= 31; 	

localparam DQS_CNT_WIDTH 	= 10;

//*********************************INPUTS & OUTPUTS************************************
//


input	[AHB_ADDR_WIDTH-1:0]	HADDR;			// READ OR WRITE ADDRESS FROM MASTER TO SLAVE//
input			[2:0]	HBURST;			// BUSRT LENGTH AND TYPE FROM MASTER//
input				HREADY;			// HREADY INPUT//
input				HSELx;			// SLAVE SELECT FROM MASTER//
input			[2:0]	HSIZE;			// DATA SIZE RECEIVE FROM MASTER//
input			[1:0]	HTRANS;			// TRANSFER MODE OF MASTER// 
input	[AHB_DATA_WIDTH-1:0]	HWDATA;			// WRITE DATA FROM MASTER TO SLAVE// 
input				HWRITE;			// WRITE OR READ SIGNAL//
input				ahb_clk;			// AHB MASTER CLK FROM MASTER //
input				ahb_rst_n;		// AHB MASTER RESET FROM MASTER//
input   			mem_clk;
input   			mem_rst_n;
input   			ahb_cmd_ready; 
input   			ahb_rdata_valid;
input   	       [AHB_DATA_WIDTH-1:0]	ahb_rdata;
input   			ahb_rdata_last;
input   	[1:0]		ahb_rdata_resp;
input   			spl_instr_req;
input   			spl_instr_stall;
input                           ahb_wdata_ready_in;
input				dq_rdata_flush_done;


output 				ahb_rdata_ready;
output [31 :0]    ahb_wdata;
output                          ahb_wvalid;
output [3:0]			ahb_wstrb;
output                          ahb_wlast_o;
output	[AHB_DATA_WIDTH-1:0]	HRDATA;			// READ DATA TO MASTER//
output				hreadyout;		// HREADY TO MASTER
output				HRESP;  		// ERROR RESPONSE OF SLAVE TO MASTER//
output				ahb_cmd_valid;
//output				ahb_mr_access;
output   		[31:0]	ahb_addr;
output   			ahb_write;
output   		[1:0]	ahb_burst;
output   		[LEN_WIDTH-1:0]	ahb_len;
output   [DQS_CNT_WIDTH-1:0]	xfer_ahb_len;
output   		[2:0]	ahb_size;
output   			cont_wr_rd_req;
//input [6:0]                     ap_mem_wrap_size;
//input rd_prefetch_en;
output   			spl_instr_ack;
//input	 			mr8_btype;
output				rd_fifo_flush_start_mem_clk_sync;
//output				ahb_wr_burst_complete;

input [24:0]                    mem_base_addr;
input [24:0]                    mem_top_addr ;
//input                           mr_access    ;
//input [1:0]                     mr8_bsize    ;
input ce_n_ip;
//input       mr8_wr_success;


wire			[39:0]	ahb_cmd_ff_data;
wire				ahb_cmd_ff_empty;
wire				ahb_rd_ff_wren;
wire				ahb_cmd_ff_rden;
wire	[AHB_DATA_WIDTH :0]	ahb_rd_ff_data;
wire				ahb_rd_ff_full;	
wire                            ahb_wdata_ready_in;
wire 				wdata_ff_empty;
wire 	[AHB_DATA_WIDTH :0]	wdata_ff_data;
wire				rd_ff_empty;		// READ FIFO EMPTY FROM READ DATA FIFO//
wire	[AHB_DATA_WIDTH:0]	rdata;			// READ DATA FROM READ DATA FIFO//
wire				wr_almost_full;		// WRITE DATA FULL FROM WRITE DATA FIFO// 
wire				cmd_full;		// CMD DATA FULL FROM CMD FIFO//	
wire				rdffen;			// READ ENABLE TO READ DATA FIFO//
wire	[AHB_DATA_WIDTH:0]	wdata;			// WRITE DATA FROM MASTER TO WRITE DATA FIFO//
wire				wrffen;			// WRITE ENABLE TO WRITE DATA FIFO//
wire			[39:0] 	cmd_ff_data;		// COMMAND DATA TO WRITE CMD FIFO// HWRITE,HSIZE,HBURST,HADDR//
wire				cmd_wr;			// CMD WRITE ENABLE//
wire	[AHB_ADDR_WIDTH-1:0]	ahb_addr;
wire			[2:0]	ahb_size;
wire				ahb_rdata_ready;
wire				wr_start_en;
wire				cmd_empty_sync;
wire				wdata_empty_sync;

ahb_lite_slave_cntrl  # (.AHB_ADDR_WIDTH  (AHB_ADDR_WIDTH),
                     	 .AHB_DATA_WIDTH (AHB_DATA_WIDTH)
                     )

       u_ahb_lite_slave_cntrl ( 

	.HRDATA		(HRDATA),	
	.hreadyout	(hreadyout),        
	.HRESP		(HRESP),             
	.HADDR		(HADDR),             
	.HBURST		(HBURST),            
	.HREADY		(HREADY),            
	.HSELx		(HSELx),            
	.HSIZE		(HSIZE),            
	.HTRANS		(HTRANS),            
	.HWDATA		(HWDATA),            
	.HWRITE		(HWRITE),            
	.HCLK		(ahb_clk),              
	.HRESET_n	(ahb_rst_n),         
	.rdffen		(rdffen), 
	.rd_ff_empty	(rd_ff_empty),
	.rdata		(rdata),               
	.wdata		(wdata),  
	.wrffen		(wrffen),	
	.wr_almost_full	(wr_almost_full),    
	.cmd_ff_data	(cmd_ff_data),   
	.cmd_wr		(cmd_wr),	
	.cmd_full	(cmd_full),
	.rd_fifo_flush_ack (rd_fifo_flush_ack_pulse_sync),
        .rd_fifo_flush_start 	(rd_fifo_flush_start),

        //.mr_access (mr_access),
        .mem_base_addr (mem_base_addr),
        .mem_top_addr(mem_top_addr),
       // .mr8_bsize (mr8_bsize), //unused signal
	.spl_instr_req (spl_instr_req),
	.spl_instr_ack(spl_instr_ack),
  	.spl_instr_stall(spl_instr_stall),
	.wdata_empty_sync (wdata_empty_sync),
	.cmd_empty_sync	(cmd_empty_sync)
 
);


mem_ahb_mem_xfer_intrf #(.LEN_WIDTH     (LEN_WIDTH),
   .AHB_DATA_WIDTH (AHB_DATA_WIDTH)
		)
 u_mem_ahb_mem_xfer_intrf (

   	.mem_clk		(mem_clk),
   	.mem_rst_n		(mem_rst_n),

	.ahb_cmd_ff_data	(ahb_cmd_ff_data),
	.ahb_cmd_ff_empty	(ahb_cmd_ff_empty),
	.ahb_cmd_ff_rden	(ahb_cmd_ff_rden),

	.ahb_rd_ff_data		(ahb_rd_ff_data),
	.ahb_rd_ff_full		(ahb_rd_ff_full),
	.ahb_rd_ff_wren		(ahb_rd_ff_wren),
	
	.ahb_cmd_valid		(ahb_cmd_valid),
   	//.ahb_mr_access		(ahb_mr_access),
   	.ahb_addr		(ahb_addr),
   	.ahb_write		(ahb_write),
   	.ahb_burst		(ahb_burst),
   	.ahb_len		(ahb_len),
   	.xfer_len		(xfer_ahb_len),
   	.ahb_size		(ahb_size),
   	.cont_wr_rd_req		(cont_wr_rd_req),
   	.ahb_cmd_ready		(ahb_cmd_ready), 

   	.ahb_rdata_valid	(ahb_rdata_valid),
   	.ahb_rdata		(ahb_rdata),
   	.ahb_rdata_last		(ahb_rdata_last),
   	.ahb_rdata_resp		(ahb_rdata_resp[1]),
   	.ahb_rdata_ready	(ahb_rdata_ready),
	.wr_start_en		(wr_start_en),
        .rd_fifo_flush_start 	(rd_fifo_flush_start_mem_clk_sync),
	.rd_fifo_flush_ack_out	(rd_fifo_flush_ack),
	.dq_rdata_flush_done	(dq_rdata_flush_done),	
        //.ap_mem_wrap_size       (ap_mem_wrap_size),
        //.rd_prefetch_en (rd_prefetch_en),
	//.mr8_btype		(mr8_btype), 
        .ce_n_ip (ce_n_ip)
        // .mr8_wr_success                    (mr8_wr_success)
        // Unused inputs - tie it to zero
        // Unused outputs - keep it unconnected
);




ahb_slave_wrdata #  (.AHB_ADDR_WIDTH  (AHB_ADDR_WIDTH),
                     	 .AHB_DATA_WIDTH (AHB_DATA_WIDTH)
			)

u_ahb_wrdata_packer (

    
     	.mem_clk		(mem_clk), 
     	.mem_rst_n		(mem_rst_n),
     	.wr_start_en		(wr_start_en),
     	.wdata_ready_in		(ahb_wdata_ready_in),
     	.hsize			(ahb_size), 
	.addr			(ahb_addr),    
     	.wdata			(ahb_wdata),
     	.wvalid			(ahb_wvalid), 
     	.wstrb			(ahb_wstrb), 
     	.wlast_o		(ahb_wlast_o),
 	.wdata_ff_empty		(wdata_ff_empty),
	.wdata_ff_rd_en		(wdata_ff_rd_en),
     	.wdata_ff_data		(wdata_ff_data)

);

gen_fifo_async  # (.PTR_WIDTH (PTR_WIDTH_CMD_FF),
		   .DATA_WIDTH(DATA_WIDTH_CMD_FF),
		   .DEPTH(DEPTH_CMD_FF))

u_cmd_gen_fifo_async(
   // Outputs

   	.full			(), 
   	.fifo_pre_full		(), 
   	.fifo_almost_full	(cmd_full), 
   	.empty			(ahb_cmd_ff_empty), 
   	.dout_v			(), 
   	.rdata			(ahb_cmd_ff_data),
   // Inputs
   	.wusable		(1'b1), 
   	.wreset			(ahb_rst_n), 
   	.wclk			(ahb_clk), 
   	.rusable 		(1'b1), 
   	.rreset			(mem_rst_n), 
   	.rclk			(mem_clk), 
   	.push			(cmd_wr), 
   	.pop			(ahb_cmd_ff_rden),
   	.wdata			(cmd_ff_data),
        .flush                  (1'b0)
);

gen_fifo_async  # (.PTR_WIDTH (PTR_WIDTH_WR_FF),
		   .DATA_WIDTH(AHB_DATA_WIDTH+1),
		   .DEPTH(DEPTH_WR_FF))

u_wdata_gen_fifo_async(
   // Outputs
   	.full			(), 
   	.fifo_pre_full		(), 
   	.fifo_almost_full	(wr_almost_full), 
   	.empty			(wdata_ff_empty), 
   	.dout_v			(), 
   	.rdata			(wdata_ff_data),
   // Inputs
   	.wusable		(1'b1), 
   	.wreset			(ahb_rst_n), 
   	.wclk			(ahb_clk), 
   	.rusable 		(1'b1), 
   	.rreset			(mem_rst_n), 
   	.rclk			(mem_clk), 
   	.push			(wrffen), 
  	.pop			(wdata_ff_rd_en),
   	.wdata			(wdata),
        .flush                  (1'b0)

);

gen_fifo_async  # (.PTR_WIDTH (PTR_WIDTH_RD_FF),
		   .DATA_WIDTH(AHB_DATA_WIDTH+1),
		   .DEPTH(DEPTH_RD_FF))

u_rdata_gen_fifo_async(
   // Outputs
   	.full			(), 
   	.fifo_pre_full		(), 
   	.fifo_almost_full	(ahb_rd_ff_full), 
   	.empty			(rd_ff_empty), 
   	.dout_v			(), 
   	.rdata			(rdata),
   // Inputs
   	.wusable		(1'b1), 
   	.wreset			(mem_rst_n), 
   	.wclk			(mem_clk), 
   	.rusable 		(1'b1), 
   	.rreset			(ahb_rst_n), 
   	.rclk			(ahb_clk), 
   	.push			(ahb_rd_ff_wren), 
   	.pop			(rdffen),
   	.wdata			(ahb_rd_ff_data),
        .flush                  (rd_fifo_flush_ack_pulse_sync)

);

double_flop_sync 
   #(
   .DATA_WIDTH (1)
    )
   RD_FIFO_FLUSH_START_SYNC
   (
   . clk   (mem_clk),
   . rst_n (mem_rst_n),
   . async_in (rd_fifo_flush_start),
   . sync_out (rd_fifo_flush_start_mem_clk_sync)
   );

double_flop_sync 
   #(
   .DATA_WIDTH (1)
    )
   CMD_FIFO_EMPTY_SYNC
   (
   . clk   (ahb_clk),
   . rst_n (ahb_rst_n),
   . async_in (ahb_cmd_ff_empty),
   . sync_out (cmd_empty_sync)
   );

double_flop_sync 
   #(
   .DATA_WIDTH (1)
    )
   WDATA_FIFO_EMPTY_SYNC
   (
   . clk   (ahb_clk),
   . rst_n (ahb_rst_n),
   . async_in (wdata_ff_empty),
   . sync_out (wdata_empty_sync)
   );

fb_sync FB_SYNC_RD_FIFO_FLUSH (
       .clkA    (mem_clk),
       .clkB    (ahb_clk), 
       .resetA  (mem_rst_n),
       .resetB  (ahb_rst_n),
       .inA     (rd_fifo_flush_ack),
       .inB     (),
       .inB_pulse     (rd_fifo_flush_ack_pulse_sync)
);



endmodule








