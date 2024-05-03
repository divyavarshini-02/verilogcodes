


// STATE MACHINE FOR AHB LITE INTERFACE//
// READ AND WRITE OPERATION IS DONE DEPENDING UPON THE INPUT HWRITE FROM MASTER//
// MASTER MODE OF OF OPERATION IS DECIDED BY THE INPUT HTRANS FROM MASTER//
// BURST TYPE AND LENGTH INFORMATION IS GIVEN BY HBURST FROM MASTER//
// SIZE OF THE DATA BEAT IS GIVEN BY HSIZE FROM MASTER//
// WAITED STATE OF SLAVE IS INTIMATED TO MASTER BY AN OUTPUT HREADYOUT//
// COMMAND ADDRESS AND WRITE DATA ARE WRITING INTO THE CMD AND WR_DATA FIFO
// READ DATA ARE READING FROM THE READ DATA FIFO
// HSIZE,HWRITE,HBURST AND HADDR ARE CONCATINATED AND WRITING INTO CMD FIFO
 

module ahb_lite_slave_cntrl ( 

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
	HCLK,
	HRESET_n,

// INTERFACE SIGNALS OF READ DATA FIFO
	rdffen,
	rd_ff_empty,
	rdata,

// INTERFACE SIGNALS OF WRITE DATA FIFO
	wdata,
	wrffen,	
	wr_almost_full, 
	wdata_empty_sync,  

//INTERFACE SIGNALS OF WRITE COMMAND FIFO	
	cmd_ff_data,
	cmd_wr,
	cmd_full,
	cmd_empty_sync,	

// INPUTS AND OUTPUTS OF AHB_MEM_INTERFACE BLOCK
	rd_fifo_flush_ack,
	rd_fifo_flush_start,

//From CSR
       //mr_access,
       mem_base_addr,
       mem_top_addr,
      // mr8_bsize,
       spl_instr_req,
       spl_instr_ack,
       spl_instr_stall
);



parameter AHB_DATA_WIDTH= 32;				// DATA WIDTH OF AHB//
parameter AHB_ADDR_WIDTH= 32;				// ADDRESS WIDTH OF AHB//



localparam MSTR_IDLE  	= 2'b00;			// HTRANS = IDLE STATE//
localparam BUSY  	= 2'b01;			// HTRANS = BUSY STATE//
localparam NSEQ  	= 2'b10;			// HTRANS = NON SEQUENCE//
localparam SEQ   	= 2'b11;			// HTRANS = SEQUENCE//

localparam SINGLE 	= 3'b000;
localparam INCR_UNDEF 	= 3'b001;
localparam WRAP4	= 3'b010;
localparam WRAP8	= 3'b100;
localparam WRAP16	= 3'b110;




// STATES DECLARATION FOR THE AHB STATE MACHINE

localparam R_W_IDLE 	= 4'b0000;			// IDLE STATE AHB//
localparam READ 	= 4'b0001;			// SINGLE BEAT READ//
localparam WRITE 	= 4'b0010;			// DEFINED READ WRAP OR INCREMENT AHB//
localparam WAIT_STATE	= 4'b0011;			// WAIT STATE AHB//
localparam RD_FIFO_FLUSH= 4'b0100;			// READ DATA FLUSH FROM READ FIFO WHEN MASTER IS IN IDLE//
localparam ERROR	= 4'b0101;			// ERROR STATE


input	[AHB_ADDR_WIDTH-1:0]	HADDR;			// READ OR WRITE ADDRESS FROM MASTER TO SLAVE//
input			[2:0]	HBURST;			// BUSRT LENGTH AND TYPE FROM MASTER//
input				HREADY;			// HREADY INPUT//
input				HSELx;			// SLAVE SELECT FROM MASTER//
input			[2:0]	HSIZE;			// DATA SIZE RECEIVE FROM MASTER//
input			[1:0]	HTRANS;			// TRANSFER MODE OF MASTER// 
input	[AHB_DATA_WIDTH-1:0]	HWDATA;			// WRITE DATA FROM MASTER TO SLAVE// 
input				HWRITE;			// WRITE OR READ SIGNAL//
input				HCLK;			// AHB MASTER CLK FROM MASTER //
input				HRESET_n;		// AHB MASTER RESET FROM MASTER//
input				rd_ff_empty;		// READ FIFO EMPTY FROM READ DATA FIFO//
input	[AHB_DATA_WIDTH:0]	rdata;			// READ DATA FROM READ DATA FIFO//
input				wr_almost_full;		// WRITE DATA FULL FROM WRITE DATA FIFO// 
input				cmd_full;		// CMD DATA FULL FROM CMD FIFO//
input 				rd_fifo_flush_ack; //pulse
input	[24:0]			mem_top_addr;
input   [24:0]			mem_base_addr;
//From CSR
//input       			mr_access;
//input [1:0]			mr8_bsize;
input				cmd_empty_sync;
input				wdata_empty_sync;
input			        spl_instr_req;
input			        spl_instr_stall;


	
output	[AHB_DATA_WIDTH-1:0]	HRDATA;			// READ DATA TO MASTER//
output				hreadyout;		// HREADY TO MASTER
output				HRESP;			// ERROR RESPONSE OF SLAVE TO MASTER//
output				rdffen;			// READ ENABLE TO READ DATA FIFO//
output	[AHB_DATA_WIDTH:0]	wdata;			// WRITE DATA FROM MASTER TO WRITE DATA FIFO//
output				wrffen;			// WRITE ENABLE TO WRITE DATA FIFO//
output				[39:0] 	cmd_ff_data;	// COMMAND DATA TO WRITE CMD FIFO// HWRITE,HSIZE,HBURST,HADDR//
output				cmd_wr;			// CMD WRITE ENABLE//
output				rd_fifo_flush_start;
output			        spl_instr_ack;




wire 				cmd_data_hwrite;
wire	 		[2:0]	cmd_data_hsize;
wire			[2:0]	cmd_data_hburst;
wire	[AHB_ADDR_WIDTH-1:0]	cmd_data_haddr;

wire 				hwrite_final ; 
wire 			[2:0]	hsize_final  ; 
wire 			[2:0] 	hburst_final ; 
wire 	[AHB_ADDR_WIDTH-1:0] 	haddr_final  ; 


wire 				cmd_ff_data_hwrite;
wire 			[2:0]	cmd_ff_data_hsize;
wire 			[2:0]	cmd_ff_data_hburst;
wire 	[AHB_ADDR_WIDTH-1:0]	cmd_ff_data_haddr;
wire				rdffen;							// READ ENABLE TO READ DATA FIFO//
//wire 			[2:0] 	ahb_shift_len;
//wire 			[6:0] 	ahb_wrap_size;
//wire 			[6:0] 	ap_mem_wrap_size;


reg 				ahb_error;
reg	[AHB_DATA_WIDTH-1:0]	HRDATA,next_HRDATA;					// READ DATA TO MASTER//
reg				hreadyout_int,next_hreadyout_int;				// READY TO MASTER//
reg				HRESP,next_HRESP;					// ERROR/OKAY RESPONSE OF SLAVE TO MASTER//
reg			[3:0]	AHB_state,next_AHB_state;				// PRESENT STATE,NEXT STATE //
reg			[39:0]	cmd_ff_data,next_cmd_ff_data;				// COMMAND DATA TO WRITE CMD FIFO// HWRITE,HSIZE,HBURST,HADDR//
reg				cmd_wr,next_cmd_wr;					// CMD WRITE ENABLE//			
reg	[AHB_DATA_WIDTH:0]	wdata,next_wdata;					// WRITE DATA FROM MASTER TO WRITE DATA FIFO//WLAST BIT IN MSB BIT//
reg				wrffen,next_wrffen;					// WRITE ENABLE TO WRITE DATA FIFO//

reg				write_flag,next_write_flag;
reg				read_flag,next_read_flag;
reg				rd_fifo_flush_start,next_rd_fifo_flush_start;
reg				outstanding_rd_en,next_outstanding_rd_en;
reg				rdata_valid;
reg				rd_fifo_flush_ack_reg,next_rd_fifo_flush_ack_reg;
reg				cmd_non_seq,next_cmd_non_seq;
reg				cmplt_read_fifo_flush,next_cmplt_read_fifo_flush;

reg error_resp_cmplt,next_error_resp_cmplt;


			
reg [1:0] prev_trans_type , next_prev_trans_type;
reg [2:0] prev_burst_type , next_prev_burst_type;
reg [1:0] rd_data_cnt , next_rd_data_cnt;
reg [AHB_DATA_WIDTH : 0] rdata_reg, next_rdata_reg;
reg rd_data_plcd, next_rd_data_plcd;
reg wr_data_cmplt, next_wr_data_cmplt;
reg spl_instr_ack,next_spl_instr_ack;
reg pending_ahb_xfer, next_pending_ahb_xfer;
reg [1:0] wait_cntr, next_wait_cntr;
reg addr_ack, next_addr_ack;

//wire wrap_xfer;
//assign wrap_xfer = hburst_final==WRAP4 | hburst_final==WRAP8 | hburst_final==WRAP16;

assign cmd_data_hwrite=HWRITE;
assign cmd_data_hsize = HSIZE;
assign cmd_data_hburst = HBURST;
assign cmd_data_haddr = HADDR;

assign hwrite_final = cmd_non_seq ? cmd_ff_data_hwrite : HWRITE; 
assign hsize_final  = cmd_non_seq ? cmd_ff_data_hsize  : HSIZE; 
assign hburst_final = cmd_non_seq ? cmd_ff_data_hburst : HBURST; 
assign haddr_final  = cmd_non_seq ? cmd_ff_data_haddr : HADDR; 



//assign ahb_shift_len   = (hburst_final == WRAP4 ) ? 3'd2 : 
//                         (hburst_final == WRAP8 ) ? 3'd3 :
//                         (hburst_final == WRAP16) ? 3'd4 :3'd0; 
                   
//assign ahb_wrap_size  = (1<< hsize_final ) <<  ahb_shift_len ;
//assign ap_mem_wrap_size= ('b10000) << mr8_bsize;


assign cmd_ff_data_hwrite = cmd_ff_data[38];
assign cmd_ff_data_hsize  = cmd_ff_data[37:35];
assign cmd_ff_data_hburst = cmd_ff_data[34:32];
assign cmd_ff_data_haddr  = cmd_ff_data[31:0];

assign rdffen= (!rd_ff_empty) && ((AHB_state == READ) || ((AHB_state == WAIT_STATE) && read_flag) || ((AHB_state==RD_FIFO_FLUSH) && (!rd_fifo_flush_ack_reg))) && (!(next_rd_data_cnt>=1));
//assign rdffen= (!rd_ff_empty) && ((AHB_state == READ) || ((AHB_state == WAIT_STATE) && read_flag) || (AHB_state==RD_FIFO_FLUSH)) && (!(next_rd_data_cnt>=1));

//assign hreadyout =  ((mr8_wr_data_cmplt) || ((AHB_state==R_W_IDLE) && (spl_instr_req || spl_instr_stall))) ? 1'b0 :(AHB_state==ERROR)? hreadyout_int : 
//			(hreadyout_int && (!wr_almost_full));
assign hreadyout = hreadyout_int;
//assign hreadyout =  check_wdata ? 1'b0 :hreadyout_int;


assign rd_err_xfer = rdata[AHB_DATA_WIDTH];
assign rd_err_reg_xfer = rdata_reg[AHB_DATA_WIDTH];


always @ (posedge HCLK or negedge HRESET_n)


begin
	if (!HRESET_n)
	begin
		AHB_state		<= R_W_IDLE;
		cmd_wr 			<= 1'b0;
		cmd_ff_data 		<= 40'b0;
		hreadyout_int 		<= 1'b1;
		wrffen			<= 1'b0;
		wdata			<= {AHB_DATA_WIDTH+1{1'b0}};
		HRDATA			<= {AHB_DATA_WIDTH{1'b0}};
		write_flag		<= 1'b0;
		read_flag		<= 1'b0;
		rd_fifo_flush_ack_reg	<= 1'b0;
		rd_fifo_flush_start	<= 1'b0;
		outstanding_rd_en	<= 1'b0;
		rdata_valid		<= 1'b0;
		cmd_non_seq		<= 1'b0;
                prev_trans_type         <= 2'd0;
                prev_burst_type         <= 3'd0;
                rd_data_cnt             <= 2'd0;
                rdata_reg               <= {AHB_DATA_WIDTH+1{1'b0}};
                rd_data_plcd          	<= 1'b0;
                wr_data_cmplt         	<= 1'b0;
		HRESP			<= 1'b0;
		cmplt_read_fifo_flush	<= 1'b0;
		spl_instr_ack		<= 1'b0;
                pending_ahb_xfer        <= 1'b0;
                wait_cntr               <= 2'd0;
                addr_ack                <= 1'b0;
		error_resp_cmplt	<= 1'b0;
		
	end 
	
	else
	begin
		AHB_state		<= next_AHB_state;
		cmd_wr 			<= next_cmd_wr;
		cmd_ff_data 		<= next_cmd_ff_data;
		hreadyout_int 		<= next_hreadyout_int;
		wrffen			<= next_wrffen;
		wdata			<= next_wdata;
		HRDATA			<= next_HRDATA;
		write_flag		<= next_write_flag;
		read_flag		<= next_read_flag;
		rd_fifo_flush_ack_reg	<= next_rd_fifo_flush_ack_reg;
		rd_fifo_flush_start	<= next_rd_fifo_flush_start;
		outstanding_rd_en	<= next_outstanding_rd_en;
		rdata_valid		<= rdffen;
		cmd_non_seq		<= next_cmd_non_seq;
                prev_trans_type         <= next_prev_trans_type;
                prev_burst_type         <= next_prev_burst_type;
                rd_data_cnt            <= next_rd_data_cnt;
                rdata_reg              <= next_rdata_reg;
                rd_data_plcd          <= next_rd_data_plcd;
                wr_data_cmplt          <= next_wr_data_cmplt;
		HRESP			<=  next_HRESP;
		cmplt_read_fifo_flush	<= next_cmplt_read_fifo_flush;
		spl_instr_ack	 	<= next_spl_instr_ack;
                pending_ahb_xfer        <= next_pending_ahb_xfer;
                wait_cntr               <= next_wait_cntr;
                addr_ack                <= next_addr_ack;
		error_resp_cmplt	<= next_error_resp_cmplt;
		
		
	end
end

always @*
begin

ahb_error = 1'b0;

   if(hwrite_final /*&& mr_access*/) // mode register write transfer
   begin
      if(((hburst_final!=SINGLE) && (hburst_final!=INCR_UNDEF) )|| (hsize_final!=0)) // non single burst or size !=0
      //if((hburst_final!=SINGLE) || (hsize_final!=0)) // non single burst or size !=0
      begin
         ahb_error = 1'b1;
      end
      else
      begin
         case (haddr_final)
         'd0,'d4,'d8 :
         begin
            ahb_error = 1'b0;
         end
         default :
         begin
            ahb_error = 1'b1;
         end
         endcase
      end
   end
   else if((!hwrite_final) /*&& mr_access*/) // mode register read transfer
   begin
      if(((hburst_final!=SINGLE) && (hburst_final!=INCR_UNDEF)) ||  (|hsize_final[2:1])) // non single burst or size !=0 or 1
      //if((hburst_final!=SINGLE) || (|hsize_final[2:1])) // non single burst or size !=0 or 1
      begin
         ahb_error = 1'b1;
      end
      else
      begin
         case (haddr_final)
         'd0,'d1,'d2,'d3:
         begin
            ahb_error = 1'b0;
         end
         'd4,'d8:
         begin
            ahb_error = hsize_final[0] ? 1'b1 : 1'b0;
         end
         default :
         begin
            ahb_error = 1'b1;
         end
         endcase
      end
   end
   else // if(!mr_access) // memory array transfer
   begin
         ahb_error = (hburst_final==WRAP4 && hsize_final!=2 && hsize_final!=3) || (hburst_final==WRAP8 && hsize_final==0) || 
                     (hburst_final==WRAP16 && hsize_final==3) ? 1'b1 : 
                          (haddr_final < mem_base_addr) || (haddr_final > mem_top_addr);

         //ahb_error = (hburst_final==WRAP4 && hsize_final!=2) || (hburst_final==WRAP8 && hsize_final==0) ? 1'b1 : 
         //                 (haddr_final < mem_base_addr) || (haddr_final > mem_top_addr);
         //ahb_error = (hburst_final==WRAP4 && hsize_final!=2) || (hburst_final==WRAP8 && hsize_final==0) ? 1'b1 : 
         //                 (wrap_xfer && (|(ahb_wrap_size^ap_mem_wrap_size)) && (!check_wdata)) ? 1'b1 :
         //                 (haddr_final < mem_base_addr) || (haddr_final > mem_top_addr);
   end
end

always @ (*)

begin

next_AHB_state		= AHB_state;
next_cmd_wr 		= 1'b0;
next_cmd_ff_data 	= cmd_ff_data;
next_hreadyout_int		= hreadyout_int;
next_wrffen		= 1'b0;
next_wdata		= wdata;
next_HRDATA		= HRDATA;
next_write_flag		= write_flag;
next_read_flag		= read_flag;
next_rd_fifo_flush_ack_reg = rd_fifo_flush_ack_reg;
next_rd_fifo_flush_start = rd_fifo_flush_start;
next_outstanding_rd_en	 = outstanding_rd_en;
next_cmd_non_seq	= cmd_non_seq;
next_prev_trans_type   = prev_trans_type;
next_prev_burst_type    = prev_burst_type;

next_rd_data_cnt        = rdata_valid ? rd_data_cnt + 1 : rd_data_cnt;
next_rdata_reg          = rd_data_cnt==0 && rdata_valid ? rdata : rdata_reg;
next_rd_data_plcd       = rd_data_plcd;
next_wr_data_cmplt      = wr_data_cmplt;
next_cmplt_read_fifo_flush	= cmplt_read_fifo_flush;
next_HRESP       		= HRESP;

next_spl_instr_ack	= 1'b0;
next_pending_ahb_xfer   = pending_ahb_xfer;
next_wait_cntr = wait_cntr;
next_error_resp_cmplt	= error_resp_cmplt;
next_addr_ack           = addr_ack;


	case ( AHB_state )
	
	R_W_IDLE :
	begin
               next_rd_fifo_flush_ack_reg = 1'b0;

		if  (spl_instr_req || spl_instr_stall)
		begin
			next_hreadyout_int	= (HSELx && (hreadyout && HREADY) && (HTRANS==NSEQ)) || cmd_non_seq || pending_ahb_xfer ? 1'b0 : 1'b1;
                        next_wait_cntr          = spl_instr_ack ? 2'd0 : (&wait_cntr ? wait_cntr :  spl_instr_req ? wait_cntr + 1 : wait_cntr);
			next_spl_instr_ack      = spl_instr_ack ? 1'b0 : (&wait_cntr ? ((wdata_empty_sync && cmd_empty_sync && rd_ff_empty) ? 1'b1 : 1'b0) :
                                                  spl_instr_ack );

                        next_addr_ack           = (HSELx && (hreadyout && HREADY)) && (HTRANS==NSEQ) && (!ahb_error) ? 1'b1 :  addr_ack;    
			next_cmd_ff_data 	= cmd_non_seq ? cmd_ff_data : {/*mr_access*/ cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
			next_cmd_non_seq	= (HSELx && (hreadyout && HREADY)) && (HTRANS==NSEQ) && (!ahb_error) ? 1'b1 : cmd_non_seq;
			next_pending_ahb_xfer	= (HSELx && (hreadyout && HREADY)) && (HTRANS==NSEQ) && (ahb_error) ? 1'b1 : pending_ahb_xfer;
			next_AHB_state		= AHB_state;
		end
	
		else if ( ((HSELx && (hreadyout == HREADY)) && (HTRANS==NSEQ) && (ahb_error))  || pending_ahb_xfer)  // SLAVE SELECT AND NONSEQ
		begin
                   if(hreadyout || pending_ahb_xfer)
                   begin
                        next_pending_ahb_xfer   = 1'b0;
			next_hreadyout_int 	= 1'b0;
			next_HRESP 		= 1'b1; // no need to check for check_wdata since it will not be set once it comes to IDLE state
			//next_HRESP 		= check_wdata ? 1'b0 : 1'b1;
			next_AHB_state		= ERROR;
                   end
                   else
                   begin
			next_hreadyout_int 	= 1'b1; //removed the concept of check_wdata //RSR
			//next_hreadyout_int 	= check_wdata ? 1'b0 : 1'b1;
			next_HRESP 		= HRESP;
			next_AHB_state		= AHB_state;
                   end
		end



		else if (((HSELx && (hreadyout == HREADY)) && (HTRANS==NSEQ)) || (cmd_non_seq))  // SLAVE SELECT AND NONSEQ
		begin
                        //next_prev_trans_type    = HTRANS;
                        next_prev_trans_type    = NSEQ;
		    if (!cmd_full) 
		    begin
                        if(hreadyout || addr_ack)
                        begin
                           next_addr_ack        = 1'b0;    
                           //next_prev_burst_type = HBURST;
                           next_prev_burst_type     = cmd_non_seq ? cmd_ff_data_hburst : cmd_data_hburst;
			   next_cmd_non_seq	= 1'b0;
			   next_cmd_ff_data 	= (cmd_non_seq) ? cmd_ff_data : {/*mr_access*/ cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
			   next_cmd_wr 		= 1'b1;  
			   next_AHB_state	= cmd_non_seq ? (cmd_ff_data_hwrite ? WRITE : READ) : ( HWRITE ? WRITE : READ);
			   next_hreadyout_int 	= (wr_almost_full || ((!cmd_data_hwrite) && (!cmd_non_seq) ) || 
                                                  ((!cmd_ff_data_hwrite) && cmd_non_seq ))  ? 1'b0 : 1'b1; 
		           next_write_flag      = cmd_non_seq ? (cmd_ff_data_hwrite ? 1 : 0) : ( HWRITE ? 1 : 0);
		           next_read_flag	= cmd_non_seq ? (cmd_ff_data_hwrite ? 0: 1) : ( HWRITE ? 0 : 1);
                        end
                        else
                        begin
			   next_hreadyout_int 		= 1'b1;
			   next_AHB_state		= AHB_state;
                        end
		    end
		    else
		    begin
                        next_addr_ack           = hreadyout ? 1'b1 :  addr_ack;    
			next_hreadyout_int 	= 1'b0;
			next_cmd_ff_data 	= cmd_non_seq ? cmd_ff_data : {/*mr_access*/ cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
			next_cmd_non_seq	= 1'b1;
			next_cmd_wr 		= 1'b0;
			next_wdata	        = cmd_non_seq ? {1'b0, HWDATA}	: wdata;
			next_AHB_state		= AHB_state;
		    end
		end
                
		else 
		begin	
			next_hreadyout_int 	= 1'b1;
			//next_hreadyout_int 	= cmd_full ? 1'b0 :1'b1;
			next_AHB_state		= AHB_state;
		end
	end

/////////////////////////////////////////////////////////// READ OPERATION /////////////////////////////////////////////////



	READ :
	begin
		next_write_flag = 1'b0;
		next_read_flag	= 1'b1;

               if (outstanding_rd_en)  // stop transfer and no new transfer
               begin
                   next_prev_trans_type  = HTRANS;
                   case(rd_data_cnt)
                   2'd0:
                   begin
                        next_hreadyout_int      = rdata_valid ? !rd_err_xfer : 1'b0;
		        next_HRDATA             = rdata_valid ? rdata[AHB_DATA_WIDTH-1:0] : HRDATA;
			next_HRESP 		= rdata_valid ? rd_err_xfer : HRESP;
			next_AHB_state		= rdata_valid ? (rd_err_xfer ? ERROR : AHB_state) : AHB_state;
                        next_rd_data_cnt        = 2'd0;  
                        next_outstanding_rd_en  = !(rdata_valid);
                        next_cmplt_read_fifo_flush = rdata_valid & rd_err_xfer;
                        //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ? rdata_valid & rd_err_xfer : 1'b0;
                   end
                   2'd1:
                   begin
                        next_hreadyout_int      = !rd_err_reg_xfer;
                        next_HRDATA             = rdata_reg[AHB_DATA_WIDTH-1:0];  
			next_HRESP 		= rd_err_reg_xfer;
			next_AHB_state		= rd_err_reg_xfer ? ERROR : AHB_state;
                        next_rd_data_cnt        = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                        next_rdata_reg          = rdata_valid ? rdata  : rdata_reg;
                        next_outstanding_rd_en  = 1'b0;
                        next_cmplt_read_fifo_flush = rd_err_reg_xfer;
                        //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ? rd_err_reg_xfer  : 1'b0;
                   end
                   2'd2:
                   begin
                        next_hreadyout_int      = !rd_err_reg_xfer;
                        next_HRDATA             = rdata_reg[AHB_DATA_WIDTH-1:0];
			next_HRESP 		= rd_err_reg_xfer;
			next_AHB_state		= rd_err_reg_xfer ? ERROR : AHB_state;
                        next_rd_data_cnt        = 2'd1; 
                        next_rdata_reg          = rdata;
                        next_outstanding_rd_en  = 1'b0;
                        next_cmplt_read_fifo_flush = rd_err_reg_xfer;
                        //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ? rd_err_reg_xfer  : 1'b0;
                   end
                   endcase
               end

		else if ((HSELx && (hreadyout == HREADY)) && (HTRANS==NSEQ) && (ahb_error))   // SLAVE SELECT AND NONSEQ
		begin
                   if(hreadyout)
                   begin
			next_hreadyout_int 	= 1'b0;
			next_HRESP 		= 1'b1;
			//next_HRESP 		= check_wdata ? 1'b0 : 1'b1;
			next_AHB_state		= ERROR;
                        next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ? 1'b1 : 1'b0;
                        next_prev_burst_type     = cmd_data_hburst;
		        next_write_flag          = 1'b0;
		        next_read_flag	         = 1'b0;
                   end
                   else
                   begin
			next_cmd_ff_data 	= {/*mr_access*/cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
                        case(rd_data_cnt)
                         2'd0:
                         begin
                              next_rd_data_cnt    = 2'd0;  
                              next_hreadyout_int  = rdata_valid ? !rd_err_xfer : 1'b0;
		              next_HRDATA         = rdata_valid ? rdata[AHB_DATA_WIDTH-1:0]  : HRDATA;
			      next_HRESP 	  = rdata_valid ? rd_err_xfer : HRESP;
			      next_AHB_state	  = rdata_valid ? (rd_err_xfer ? ERROR : AHB_state) : AHB_state;
                             //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ?  rdata_valid & rd_err_xfer : 1'b0;
                              next_cmplt_read_fifo_flush = rdata_valid & rd_err_xfer;
                         end

                         2'd1:
                         begin
                              next_hreadyout_int  = !rd_err_reg_xfer;
                              next_HRDATA         = rdata_reg[AHB_DATA_WIDTH-1:0];  
			      next_HRESP 	  = rd_err_reg_xfer;
                       	      next_rd_data_cnt        = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                              next_rdata_reg          = rdata_valid ? rdata  : rdata_reg;
			      next_AHB_state	  = rd_err_reg_xfer ? ERROR : AHB_state;
                             //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ?  rd_err_reg_xfer : 1'b0;
                             next_cmplt_read_fifo_flush = rd_err_reg_xfer;

                         end
                         2'd2:
                         begin

                              next_hreadyout_int  = !rd_err_reg_xfer;
                              next_HRDATA         = rdata_reg[AHB_DATA_WIDTH-1:0];  
			      next_HRESP 	  = rd_err_reg_xfer;
                              next_rd_data_cnt    = 2'd0;  
			      next_AHB_state	  = rd_err_reg_xfer ? ERROR : AHB_state;
                             //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ?  rd_err_reg_xfer : 1'b0;
                             next_cmplt_read_fifo_flush = rd_err_reg_xfer;
                           end
                         endcase
                   end
		end
		else if ((HSELx && hreadyout == HREADY &&  HTRANS == NSEQ)  || (cmd_non_seq))  // stop on-going transfer and a new transfer
		begin

                        next_prev_trans_type    = NSEQ;
                        //next_prev_trans_type    = HTRANS;
		    if (!cmd_full && (hreadyout || rd_data_plcd))  
		    begin 
                        next_rd_data_plcd       = 1'b0;
			next_cmd_non_seq	= 1'b0;
			next_cmd_ff_data 	= (cmd_non_seq) ? cmd_ff_data :{/*mr_access*/cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
                        next_rd_fifo_flush_start = prev_burst_type == 3'd1 ? 1'b1 : 1'b0;
                        next_prev_burst_type     = cmd_non_seq ? cmd_ff_data_hburst : cmd_data_hburst;
			next_cmd_wr 		 = prev_burst_type == 3'd1 ? 1'b0 : 1'b1;
			if (!cmd_non_seq)
			begin
				if (HWRITE)
				begin
				    next_write_flag 	= 1'b1;
				    next_read_flag	= 1'b0;
			            next_hreadyout_int  = prev_burst_type == 3'd1 ? 1'b0 : 1'b1;
				    next_AHB_state	= prev_burst_type == 3'd1 ? RD_FIFO_FLUSH : WRITE;
				end
				else
				begin
				    next_write_flag 	= 1'b0;
				    next_read_flag	= 1'b1;
			            next_hreadyout_int  = 1'b0;
				    next_AHB_state	= prev_burst_type == 3'd1 ? RD_FIFO_FLUSH : READ;
				end
			end
			else
			begin
				if (cmd_ff_data_hwrite)
				begin
				    next_write_flag 	= 1'b1;
				    next_read_flag	= 1'b0;
			            next_hreadyout_int  = prev_burst_type == 3'd1 ? 1'b0 : 1'b1;
				    next_AHB_state	= prev_burst_type == 3'd1 ? RD_FIFO_FLUSH : WRITE;
				end
				else
				begin
				    next_write_flag     = 1'b0;
				    next_read_flag	= 1'b1;
			            next_hreadyout_int  = 1'b0;
				    next_AHB_state	= prev_burst_type == 3'd1 ? RD_FIFO_FLUSH : READ;
				end
	     		end
		    end
		    else if (cmd_full && rd_data_plcd)
                    begin
			next_AHB_state		= AHB_state;
			next_hreadyout_int 		= cmd_full ? 1'b0 : 1'b1;
                    end
                    else if (hreadyout) // cmd_full and previous sequential read data is already placed
                    begin
			next_hreadyout_int 		= 1'b0;
			next_cmd_non_seq	= 1'b1;
			next_cmd_ff_data 	= cmd_non_seq ? cmd_ff_data : {/*mr_access*/cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
			next_cmd_wr 		= 1'b0;
			next_AHB_state		= AHB_state;
                        next_rd_data_plcd      = 1'b1;
                    end
		    else // previous sequential read data not available
		    begin
			next_cmd_non_seq	= 1'b1;
			next_cmd_ff_data 	= cmd_non_seq ? cmd_ff_data : {/*mr_access*/cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
			next_cmd_wr 		= 1'b0;

                        case(rd_data_cnt)
                         2'd0:
                         begin
                              next_rd_data_cnt    = 2'd0;  
                              next_outstanding_rd_en  = rdata_valid ? 1'b0 : 1'b1;
                              next_hreadyout_int  = rdata_valid ? !rd_err_xfer : 1'b0;
		              next_HRDATA         = rdata_valid ? rdata[AHB_DATA_WIDTH-1:0]  : HRDATA;
			      next_HRESP 	  = rdata_valid ? rd_err_xfer : HRESP;
			      next_AHB_state	  = rdata_valid ? (rd_err_xfer ? ERROR : AHB_state) : AHB_state;
                             // next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ? rdata_valid & rd_err_xfer  : 1'b0;
                              next_cmplt_read_fifo_flush = rdata_valid & rd_err_xfer;
                         end

                         2'd1:
                         begin
                              next_hreadyout_int  = !rd_err_reg_xfer;
                              next_HRDATA         = rdata_reg[AHB_DATA_WIDTH-1:0];  
			      next_HRESP 	  = rd_err_reg_xfer;
                       	      next_rd_data_cnt        = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                              next_rdata_reg          = rdata_valid ? rdata  : rdata_reg;
    			      next_outstanding_rd_en  = 1'b0; 
			      next_AHB_state	  = rd_err_reg_xfer ? ERROR : AHB_state;
                             //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ?  rd_err_reg_xfer : 1'b0;
                             next_cmplt_read_fifo_flush = rd_err_reg_xfer;

                         end
                         2'd2:
                         begin

                              next_hreadyout_int  = !rd_err_reg_xfer;
                              next_HRDATA         = rdata_reg[AHB_DATA_WIDTH-1:0];  
			      next_HRESP 	  = rd_err_reg_xfer;
                              next_rd_data_cnt    = 2'd0; 
			      next_outstanding_rd_en  = 1'b0; 
			      next_AHB_state	  = rd_err_reg_xfer ? ERROR : AHB_state;
                             //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ?  rd_err_reg_xfer : 1'b0;
                             next_cmplt_read_fifo_flush = rd_err_reg_xfer;
                           end
                         endcase
		end
		end	
		else if (HSELx && HTRANS == BUSY)  //break in on-going transfer MASTER IN BUSY STATE / READ DATA FIFO EMPTY
		begin
		        next_prev_trans_type    = HTRANS;
		
			if (hreadyout) 
			begin
                           next_outstanding_rd_en  = 1'b0;
			   next_hreadyout_int	   = 1'b1;
			   //next_hreadyout_int	   = 1'b0;
			   next_HRDATA		   = HRDATA;
                           next_rd_data_plcd       = 1'b1;
			   next_AHB_state          = WAIT_STATE;
			end
			else
			begin

                        case(rd_data_cnt)
                         2'd0:
                         begin
                              next_rd_data_cnt    = 2'd0;  
                              next_outstanding_rd_en  = rdata_valid ? 1'b0 : 1'b1;
                              next_hreadyout_int  = rdata_valid ? !rd_err_xfer : 1'b0;
		              next_HRDATA         = rdata_valid ? rdata[AHB_DATA_WIDTH-1:0]  : HRDATA;
			      next_HRESP 	  = rdata_valid ? rd_err_xfer : HRESP;
			      next_AHB_state	  = rdata_valid ? (rd_err_xfer ? ERROR : WAIT_STATE) : WAIT_STATE;
                             //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ? rdata_valid &  rd_err_xfer : 1'b0;
                              next_cmplt_read_fifo_flush = rdata_valid & rd_err_xfer;
                         end

                         2'd1:
                         begin
                              next_hreadyout_int  = !rd_err_reg_xfer;
                              next_HRDATA         = rdata_reg[AHB_DATA_WIDTH-1:0];  
			      next_HRESP 	  = rd_err_reg_xfer;
                       	      next_rd_data_cnt        = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                              next_rdata_reg          = rdata_valid ? rdata  : rdata_reg; 
    			      next_outstanding_rd_en  = 1'b0; 
			      next_AHB_state	  = rd_err_reg_xfer ? ERROR : WAIT_STATE;
                             //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ?  rd_err_reg_xfer : 1'b0;
                             next_cmplt_read_fifo_flush = rd_err_reg_xfer;

                         end
                         2'd2:
                         begin

                              next_hreadyout_int  = !rd_err_reg_xfer;
                              next_HRDATA         = rdata_reg[AHB_DATA_WIDTH-1:0];  
			      next_HRESP 	  = rd_err_reg_xfer; 
                       	      next_rd_data_cnt        = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                              next_rdata_reg          = rdata_valid ? rdata  : rdata_reg;
			      next_outstanding_rd_en  = 1'b0; 
			      next_AHB_state	  = rd_err_reg_xfer ? ERROR : WAIT_STATE;
                             //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ?  rd_err_reg_xfer : 1'b0;
                             next_cmplt_read_fifo_flush = rd_err_reg_xfer;
                           end
                         endcase

			end
		end
	       else if (HSELx && HTRANS == SEQ)  // continue the on-going transfer
		begin
			next_prev_trans_type    = HTRANS;

                       case(rd_data_cnt)
                         2'd0:
                         begin
                              next_rd_data_cnt    = 2'd0;  
                              next_hreadyout_int  = rdata_valid ? !rd_err_xfer : 1'b0;
		              next_HRDATA         = rdata_valid ? rdata[AHB_DATA_WIDTH-1:0]  : HRDATA;
			      next_HRESP 	  = rdata_valid ? rd_err_xfer : HRESP;
			      next_AHB_state	  = rdata_valid ? (rd_err_xfer ? ERROR : AHB_state) : AHB_state;
                              //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ?  rdata_valid & rd_err_xfer: 1'b0;
                              next_cmplt_read_fifo_flush = rdata_valid & rd_err_xfer;
                         end

                         2'd1:
                         begin
                              next_hreadyout_int  = !rd_err_reg_xfer;
                              next_HRDATA         = rdata_reg[AHB_DATA_WIDTH-1:0];  
			      next_HRESP 	  = rd_err_reg_xfer;
                              next_rd_data_cnt        = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                              next_rdata_reg          = rdata_valid ? rdata : rdata_reg;
			      next_AHB_state	  = rd_err_reg_xfer ? ERROR : AHB_state;
                             //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ?  rd_err_reg_xfer : 1'b0;
                             next_cmplt_read_fifo_flush = rd_err_reg_xfer;

                         end
                         2'd2:
                         begin

                              next_hreadyout_int  = !rd_err_reg_xfer;
                              next_HRDATA         = rdata_reg[AHB_DATA_WIDTH-1:0];  
			      next_HRESP 	  = rd_err_reg_xfer;
                              next_rd_data_cnt    = 2'd0;  
			      next_AHB_state	  = rd_err_reg_xfer ? ERROR : AHB_state;
                             //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ?  rd_err_reg_xfer : 1'b0;
                             next_cmplt_read_fifo_flush = rd_err_reg_xfer;
                           end
                         endcase

		end
               else if (HTRANS == MSTR_IDLE || (!HSELx))  // stop transfer and no new transfer
               begin
                   next_prev_trans_type  = HTRANS;
               	   next_write_flag 	 = 1'b0;
               	   next_read_flag	 = 1'b0;
                       if(hreadyout) // required data is already available
                       begin
                          next_outstanding_rd_en   = 1'b0;
               	          next_hreadyout_int	   = 1'b1;
               	          //next_hreadyout_int	   = prev_burst_type == 3'd1 ? 1'b0 : (cmd_full ? 1'b0 : 1'b1);
                          next_rd_fifo_flush_start = prev_burst_type == 3'd1 ? 1'b1 : 1'b0;
               	          next_AHB_state	   = prev_burst_type == 3'd1 ? RD_FIFO_FLUSH : R_W_IDLE ; //before going to flush state, make write_flag=0 and read_flag=0
                       end
                       else //complete the read data required for the SEQ/NSEQ placed before this. (NSEQ->IDLE or NSEQ->SEQ->IDLE)
                       begin

                        case(rd_data_cnt)
                         2'd0:
                         begin
                              next_rd_data_cnt    = 2'd0;  
                              next_outstanding_rd_en  = rdata_valid ? 1'b0 : 1'b1;
			      next_AHB_state	  = rdata_valid ? (rd_err_xfer ? ERROR : (prev_burst_type == 3'd1 ? RD_FIFO_FLUSH : R_W_IDLE)) : AHB_state;
                              next_hreadyout_int  = rdata_valid ? (rd_err_xfer ? 1'b0 : 1'b1) :1'b0;
                              //next_hreadyout_int  = rdata_valid ? ((rd_err_xfer || (prev_burst_type == 3'd1)) ? 1'b0 : 1'b1) :1'b0;
 			      next_rd_fifo_flush_start = rdata_valid & (!rd_err_xfer) ? (prev_burst_type == 3'd1 ? 1'b1 : 1'b0) : 1'b0;
                              //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ? rdata_valid & rd_err_xfer  : 1'b0;
                              next_cmplt_read_fifo_flush = rdata_valid & rd_err_xfer;
		              next_HRDATA         = rdata_valid ? rdata[AHB_DATA_WIDTH-1:0]  : HRDATA;
			      next_HRESP 	  = rdata_valid ? rd_err_xfer : HRESP;
                         end

                         2'd1:
                         begin
                              next_hreadyout_int  =  rd_err_reg_xfer  ? 1'b0 : 1'b1;
                              //next_hreadyout_int  =  ((rd_err_reg_xfer || (prev_burst_type == 3'd1)) ? 1'b0 : 1'b1);
                              next_HRDATA         = rdata_reg[AHB_DATA_WIDTH-1:0];  
			      next_HRESP 	  = rd_err_reg_xfer;
                       	      next_rd_data_cnt        = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                              next_rdata_reg          = rdata_valid ? rdata : rdata_reg;
    			      next_outstanding_rd_en  = 1'b0; 
			      next_AHB_state	  = (rd_err_reg_xfer ? ERROR : (prev_burst_type == 3'd1 ? RD_FIFO_FLUSH : R_W_IDLE));
 			      next_rd_fifo_flush_start = rd_err_reg_xfer ? 1'b0 : (prev_burst_type == 3'd1 ? 1'b1 : 1'b0);
                             //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1  ? rd_err_reg_xfer  : 1'b0;
                             next_cmplt_read_fifo_flush = rd_err_reg_xfer;


                         end
                         2'd2:
                         begin
                              next_hreadyout_int  =  rd_err_reg_xfer ? 1'b0 : 1'b1;
                              //next_hreadyout_int  =  ((rd_err_reg_xfer || (prev_burst_type == 3'd1)) ? 1'b0 : 1'b1);
                              //next_hreadyout_int  = !rd_err_reg_xfer;
                              next_HRDATA         = rdata_reg[AHB_DATA_WIDTH-1:0];  
			      next_HRESP 	  = rd_err_reg_xfer;
                              next_rd_data_cnt    = 2'd0; 
			      next_outstanding_rd_en  = 1'b0; 
			     // next_AHB_state	  = rd_err_reg_xfer ? ERROR : R_W_IDLE;
			      next_AHB_state	  = (rd_err_reg_xfer ? ERROR : (prev_burst_type == 3'd1 ? RD_FIFO_FLUSH : R_W_IDLE));
 			      next_rd_fifo_flush_start = rd_err_reg_xfer ? 1'b0 : (prev_burst_type == 3'd1 ? 1'b1 : 1'b0);
                             //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1  ? rd_err_reg_xfer  : 1'b0;
                             next_cmplt_read_fifo_flush = rd_err_reg_xfer;

                           end
                         endcase

                       end
               end
	       else // HSELx=0 
	       begin
		next_outstanding_rd_en  = hreadyout ? 1'b0 : 1'b1 ; 
	       	next_hreadyout_int	= hreadyout ? 1'b1 :1'b0;
	       	//next_hreadyout_int	= hreadyout ? (cmd_full ? 1'b0 : 1'b1) :1'b0;
	       	next_AHB_state		= hreadyout ? R_W_IDLE : AHB_state;
	       end
	end


	WRITE: 
	begin
		next_write_flag = 1'b1;
		next_read_flag	= 1'b0;

		if (wr_almost_full && (!(cmd_non_seq || pending_ahb_xfer)))
		begin
			//next_hreadyout_int	= (((HTRANS == MSTR_IDLE || HTRANS==BUSY )&& hreadyout) && !(cmd_non_seq || pending_ahb_xfer))? 1'b1 :1'b0;

			//next_wrffen		= HSELx ? ((prev_trans_type == NSEQ || prev_trans_type==SEQ ) && (HTRANS!=BUSY ) && hreadyout ? 1'b1 : 1'b0 ) :
			//			 ((prev_trans_type == NSEQ || prev_trans_type==SEQ )? 1'b1 : 1'b0 );
			//next_wdata		= HSELx ? (prev_trans_type == NSEQ || prev_trans_type==SEQ  && hreadyout ? 
                        //                          ((HTRANS==NSEQ || HTRANS == MSTR_IDLE)?{1'b1,HWDATA} : {1'b0,HWDATA}) : wdata) : 							                       ((prev_trans_type == NSEQ || prev_trans_type==SEQ ) ? {1'b1,HWDATA} : wdata);	
                        //next_AHB_state		= HTRANS==BUSY ? WAIT_STATE : 
                        //                          (((HTRANS == MSTR_IDLE && hreadyout) && !(cmd_non_seq || pending_ahb_xfer))? R_W_IDLE :AHB_state) ;
			//next_wr_data_cmplt      = HSELx ? ((prev_trans_type == NSEQ || prev_trans_type==SEQ)  && hreadyout && HTRANS==NSEQ) : wr_data_cmplt;
                        //next_addr_ack           = (HSELx && (hreadyout && HREADY)) && (HTRANS==NSEQ) && (!ahb_error) ? 1'b1 :  addr_ack;    
			//next_cmd_ff_data 	= cmd_non_seq ? cmd_ff_data : {mr_access, cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
			//next_cmd_non_seq	= (HSELx && (hreadyout && HREADY)) && (HTRANS==NSEQ) && (!ahb_error) ? 1'b1 : cmd_non_seq;
			//next_pending_ahb_xfer	= (HSELx && (hreadyout && HREADY)) && (HTRANS==NSEQ) && (ahb_error) ? 1'b1 : pending_ahb_xfer;
                        //next_prev_trans_type    = HSELx  && hreadyout ? HTRANS : prev_trans_type;

                        if(HSELx && (hreadyout && HREADY) && (HTRANS==NSEQ) && (ahb_error))                        
                        begin
			   next_pending_ahb_xfer = 1'b1;
			   next_cmd_non_seq	 = cmd_non_seq;
			   next_cmd_ff_data 	 = cmd_ff_data;
                           next_addr_ack         = addr_ack;    
			   next_wrffen		 = 1'b1;
			   next_wdata		 = {1'b1, HWDATA}	;
			   next_wr_data_cmplt    = 1'b1;
			   next_hreadyout_int	 = 1'b0;
			   next_AHB_state	 = AHB_state;
                           next_prev_trans_type  = HTRANS;
                        end
			else if ((HSELx && (hreadyout && HREADY)) && (HTRANS==NSEQ) && (!ahb_error))
                        begin
			   next_pending_ahb_xfer = pending_ahb_xfer;
			   next_cmd_non_seq	 = 1'b1;
			   next_cmd_ff_data 	 = {/*mr_access*/ cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
                           next_addr_ack         = 1'b1;    
			   next_wrffen		 = 1'b1;
			   next_wdata		 = {1'b1, HWDATA};	
			   next_wr_data_cmplt    = 1'b1;
			   next_hreadyout_int	 = 1'b0;
			   next_AHB_state	 = AHB_state;
                           next_prev_trans_type  = HTRANS;
                        end
                        else if (HTRANS==MSTR_IDLE || (HSELx && HTRANS==BUSY) || (!HSELx))
                        begin
			   next_pending_ahb_xfer = pending_ahb_xfer;
			   next_cmd_non_seq	 = cmd_non_seq	;
			   next_cmd_ff_data 	 = cmd_ff_data;
                           next_addr_ack         = addr_ack;    
			   next_wrffen		 = HSELx && HTRANS==BUSY ? 1'b0 : hreadyout && (!wr_data_cmplt)? 1'b1 : 1'b0;//RSR
			   next_wdata		 = HSELx && HTRANS==BUSY ? {1'b0,HWDATA}: hreadyout ? {1'b1, HWDATA} : wdata;	//RSR
			   next_AHB_state	 = HSELx && HTRANS==BUSY  ? WAIT_STATE : hreadyout ? R_W_IDLE : AHB_state; //RSR
			   //next_wrffen		 = HTRANS==BUSY ? 1'b0 : 1'b1;
			   //next_wdata		 = HTRANS==BUSY ? {1'b0,HWDATA}: {1'b1, HWDATA};	
			   next_wr_data_cmplt    = 1'b0; 
			   next_hreadyout_int	 = hreadyout && (!(cmd_non_seq || pending_ahb_xfer))? 1'b1 : 1'b0;
			   //next_AHB_state	 = HTRANS==BUSY  ? WAIT_STATE : R_W_IDLE;
                           next_prev_trans_type  = hreadyout ? HTRANS : prev_trans_type;
                        end
                        else // SEQ
                        begin
                           if(cmd_non_seq || pending_ahb_xfer) // 1stNew burst SEQ or 2nd new burst
                           begin
			      next_pending_ahb_xfer = pending_ahb_xfer;
			      next_cmd_non_seq	    = cmd_non_seq;
			      next_cmd_ff_data 	    = cmd_ff_data;
                              next_addr_ack         = addr_ack;
			      next_wrffen           = 1'b0;
			      next_wdata	    = {1'b0,HWDATA};	
			      next_wr_data_cmplt    = wr_data_cmplt; 
			      next_hreadyout_int    = 1'b0;
			      next_AHB_state	    = AHB_state;
                              next_prev_trans_type  = HTRANS;
                           end
                           else // previous old burst SEQ
                           begin
			      next_pending_ahb_xfer = pending_ahb_xfer;
			      next_cmd_non_seq	    = cmd_non_seq;
			      next_cmd_ff_data 	    = cmd_ff_data;
                              next_addr_ack         = addr_ack;
			      next_wrffen           = hreadyout ? 1'b1 : 1'b0;
			      next_wdata	    = hreadyout ? {1'b0,HWDATA} : {1'b0,wdata[AHB_DATA_WIDTH-1:0]};	
			      //next_wdata	    = hreadyout ? {1'b0,HWDATA} : {1'b0,wdata};	 // RSR
			      next_wr_data_cmplt    = 1'b0; 
			      next_hreadyout_int    = 1'b0;
			      next_AHB_state	    = AHB_state;
                              next_prev_trans_type  = HTRANS;
                           end
                        end
		end

		else if ((HSELx && (hreadyout == HREADY) && (HTRANS==NSEQ) && ahb_error) || pending_ahb_xfer )   // SLAVE SELECT AND NONSEQ
		begin
                   if(hreadyout || pending_ahb_xfer) // if pending_ahb_xfer=1 , then wr_data_cmplt is also 1 
                   begin
                        next_pending_ahb_xfer   = 1'b0;
                        next_wr_data_cmplt      = 1'b0; 
			next_hreadyout_int 	= 1'b0;
			next_HRESP 		= 1'b1;
			//next_HRESP 		= check_wdata ? 1'b0 : 1'b1;
			//next_wrffen		= 1'b1;
			//next_wdata		= {1'b1,HWDATA};
                        next_wrffen		= wr_data_cmplt ? 1'b0 : 1'b1;
                        next_wdata		= wr_data_cmplt ? wdata : {1'b1,HWDATA};
			next_AHB_state		= ERROR;
                   end
                   else
                   begin
			next_hreadyout_int 	= 1'b1;
			next_HRESP 		= 1'b0;
			next_wrffen		= 1'b0;
			next_wdata		= wdata;
			next_AHB_state		= AHB_state;
                   end
		end

	       else if ((HSELx && hreadyout == HREADY && HTRANS == NSEQ) || (cmd_non_seq))  // stop on-going transfer and a new transfer
		begin

			next_wrffen		= cmd_non_seq && (wr_data_cmplt)? 1'b0 :  (hreadyout ? 1'b1 : 1'b0);
			next_wdata		= cmd_non_seq && (wr_data_cmplt)? wdata : (hreadyout ? {1'b1,HWDATA} : wdata);
                        
                        //next_prev_trans_type    = HTRANS;
                        next_prev_trans_type    = NSEQ;
			
		    if (!cmd_full && (hreadyout || wr_data_cmplt || addr_ack))   
		    begin

                        next_addr_ack           = 1'b0;    
                        next_wr_data_cmplt      = 1'b0;
			//next_hreadyout_int      = (((!cmd_non_seq) && HWRITE) || (cmd_non_seq && cmd_ff_data_hwrite));
			next_hreadyout_int      = 1'b0;
			next_cmd_non_seq	= 1'b0;
			next_cmd_ff_data 	= (cmd_non_seq) ? cmd_ff_data : {/*mr_access*/cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
			next_cmd_wr 		= 1'b1;
                        next_prev_burst_type    = cmd_non_seq ? cmd_ff_data_hburst : cmd_data_hburst;
			//next_cmd_wr 		= hreadyout ? 1'b1 : 1'b0;
		
			if (!cmd_non_seq)
			begin
				if (HWRITE)
				begin
				    next_AHB_state	= AHB_state;
				    next_write_flag 	= 1'b1;
				    next_read_flag	= 1'b0;
				end
				else
				begin
				    next_AHB_state	= READ;
				    next_write_flag 	= 1'b0;
				    next_read_flag	= 1'b1;
				end
			end
			else
			begin
				if (cmd_ff_data_hwrite)
				begin
				    next_AHB_state	= AHB_state;
				    next_write_flag 	= 1'b1;
				    next_read_flag	= 1'b0;
				end
				else
				begin
				    next_AHB_state	= READ;
				    next_write_flag 	= 1'b0;
				    next_read_flag	= 1'b1;
				end
			end
		    end
		    else
		    begin
		        //next_hreadyout_int      = 1'b1;
			next_hreadyout_int      = cmd_full ? 1'b0 : 1'b1;
                        next_wr_data_cmplt      = hreadyout ? 1'b1 : wr_data_cmplt;
			next_cmd_non_seq	= 1'b1;
			next_cmd_ff_data 	= cmd_non_seq ? cmd_ff_data : {/*mr_access*/cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
			next_cmd_wr 		= 1'b0;
			next_AHB_state		= AHB_state;

		    end
		end	
		else if ((HTRANS == MSTR_IDLE) || (!HSELx))  // stop transfer and no new transfer
		begin
                        next_prev_trans_type    = HTRANS;
			next_wrffen		= 1'b1;
			next_wdata	        = {1'b1,HWDATA};	
			next_hreadyout_int	= 1'b1;
			next_AHB_state		= R_W_IDLE;
			//next_wrffen		= hreadyout ? 1'b1 : 1'b0;
			//next_wdata	        = hreadyout ? {1'b1,HWDATA} : wdata;	
			//next_hreadyout_int	= cmd_full ? 1'b0 : 1'b1;
			//next_AHB_state		= hreadyout ? R_W_IDLE : AHB_state;
		end

		else if (HSELx && (HTRANS == BUSY))  //break in on-going transfer MASTER IN BUSY STATE / READ DATA FIFO EMPTY
		begin
                        next_prev_trans_type    = HTRANS;
			next_wrffen		= 1'b0;
			next_wdata		= {1'b0,HWDATA}; // hreadyout is not checked here. This will be asserted in IDLE (if next request is IDLE) or in WAIT state if next transfer is Non-SEQ or SEQ
			next_hreadyout_int	= 1'b1;
			//next_hreadyout_int	= 1'b0;
			next_AHB_state		= WAIT_STATE;
		end

	       else if (HSELx && (HTRANS == SEQ))  // continue the on-going transfer
		begin
			
                        next_prev_trans_type    = HTRANS;
			next_hreadyout_int		= 1'b1;
			next_wrffen		= (prev_trans_type == NSEQ || prev_trans_type==SEQ ) &&  hreadyout ? 1'b1 : 1'b0;
			next_wdata	        = (prev_trans_type == NSEQ || prev_trans_type==SEQ ) &&  hreadyout ? {1'b0,HWDATA} : wdata ;	
			next_AHB_state		= AHB_state;
		end

		else // HSELx=0 
		begin
			//next_hreadyout_int	= cmd_full ? 1'b0 : 1'b1;
			next_hreadyout_int	= 1'b1; // assert 1 for the current write data phase during HSELx=0
			next_wrffen		= (prev_trans_type == NSEQ || prev_trans_type==SEQ ) ? 1'b1 : 1'b0;
			next_wdata		= (prev_trans_type == NSEQ || prev_trans_type==SEQ ) ? {1'b1,HWDATA} : wdata;	
			next_AHB_state		= R_W_IDLE;
                        next_prev_trans_type    = prev_trans_type; // no need to update
		end
	end

	WAIT_STATE: // WAIT STATE FOR BUSY
	begin
		if ((wr_almost_full) && (write_flag) && (!(cmd_non_seq || pending_ahb_xfer)) ) 
		begin
			//next_hreadyout_int	= HTRANS==MSTR_IDLE || HTRANS==BUSY || (!HSELx) && (!(cmd_non_seq || pending_ahb_xfer)) ?  1'b1 : 1'b0;
			//next_wrffen		= (HTRANS!=BUSY|| (!HSELx)) && (!wr_data_cmplt) ? 1'b1 : 1'b0;
			//next_wdata		= HTRANS==MSTR_IDLE || HTRANS==NSEQ || (!HSELx) ? {1'b1, wdata[AHB_DATA_WIDTH-1:0]}: wdata;	
			//next_AHB_state		= HTRANS==MSTR_IDLE || (!HSELx) ?  R_W_IDLE : AHB_state;
                        //next_prev_trans_type    = HSELx ? HTRANS : prev_trans_type;

			//next_wr_data_cmplt      =  HTRANS!=BUSY && (HSELx) ? 1'b1 : wr_data_cmplt;
                        //next_addr_ack           = (HSELx && (hreadyout && HREADY)) && (HTRANS==NSEQ) && (!ahb_error) ? 1'b1 :  addr_ack;    
			//next_cmd_ff_data 	= cmd_non_seq ? cmd_ff_data : {mr_access, cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
			//next_cmd_non_seq	= (HSELx && (hreadyout && HREADY)) && (HTRANS==NSEQ) && (!ahb_error) ? 1'b1 : cmd_non_seq;
			//next_pending_ahb_xfer	= (HSELx && (hreadyout && HREADY)) && (HTRANS==NSEQ) && (ahb_error) ? 1'b1 : pending_ahb_xfer;

                        if(HSELx && (hreadyout && HREADY) && (HTRANS==NSEQ) && (ahb_error))                        
                        begin
			   next_pending_ahb_xfer = 1'b1;
			   next_cmd_non_seq	 = cmd_non_seq;
			   next_cmd_ff_data 	 = cmd_ff_data;
                           next_addr_ack         = addr_ack;    
			   next_wrffen		 = 1'b1;
			   next_wdata		 = {1'b1, wdata[AHB_DATA_WIDTH-1:0]}	;
			   next_wr_data_cmplt    = 1'b1;
			   next_hreadyout_int	 = 1'b0;
			   next_AHB_state	 = AHB_state;
                           next_prev_trans_type  = HTRANS;
                        end
			else if ((HSELx && (hreadyout && HREADY)) && (HTRANS==NSEQ) && (!ahb_error))
                        begin
			   next_pending_ahb_xfer = pending_ahb_xfer;
			   next_cmd_non_seq	 = 1'b1;
			   next_cmd_ff_data 	 = {/*mr_access*/ cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
                           next_addr_ack         = 1'b1;    
			   next_wrffen		 = 1'b1;
			   next_wdata		 = {1'b1, wdata[AHB_DATA_WIDTH-1:0]};	
			   next_wr_data_cmplt    = 1'b1;
			   next_hreadyout_int	 = 1'b0;
			   next_AHB_state	 = AHB_state;
                           next_prev_trans_type  = HTRANS;
                        end
                        else if (HTRANS==MSTR_IDLE || (HSELx && HTRANS==BUSY) || (!HSELx))
                        begin
			   next_pending_ahb_xfer = pending_ahb_xfer;
			   next_cmd_non_seq	 = cmd_non_seq	;
			   next_cmd_ff_data 	 = cmd_ff_data;
                           next_addr_ack         = addr_ack;    
			   next_wrffen		 = HSELx && HTRANS==BUSY ? 1'b0 : hreadyout && (!wr_data_cmplt)? 1'b1 : 1'b0;//RSR
			   //next_wdata		 = HSELx && HTRANS==BUSY ? (hreadyout && (wr_data_cmplt || prev_trans_type==BUSY)  ? wdata : {1'b0,HWDATA}) : hreadyout ? {1'b1, wdata[AHB_DATA_WIDTH-1:0]} : wdata;	//RSR
			   next_wdata		 = HSELx && HTRANS==BUSY ? (hreadyout && (wr_data_cmplt || prev_trans_type==BUSY)  ? wdata : {1'b0,HWDATA}) : hreadyout ? {1'b1, wdata[AHB_DATA_WIDTH-1:0]} : {1'b0,HWDATA};	//RSR
			   next_AHB_state	 = HSELx && HTRANS==BUSY  ? AHB_state : hreadyout ?  R_W_IDLE : AHB_state; //RSR
			   //next_wrffen		 = HTRANS==BUSY ? 1'b0 : 1'b1;
			   //next_wdata		 = HTRANS==BUSY ? wdata : {1'b1, wdata[AHB_DATA_WIDTH-1:0]};	
			   //next_AHB_state	 = HTRANS==BUSY  ? AHB_state : R_W_IDLE;
			   next_wr_data_cmplt    = 1'b0; 
			   next_hreadyout_int	 = hreadyout && (!(cmd_non_seq || pending_ahb_xfer))? 1'b1 : 1'b0;
			   //next_hreadyout_int	 = 1'b1;
                           next_prev_trans_type  = hreadyout ? HTRANS : prev_trans_type;
                           //next_prev_trans_type  = prev_trans_type;
                        end
                        else // SEQ
                        begin
                           if(cmd_non_seq || pending_ahb_xfer) // 1stNew burst SEQ or 2nd new burst
                           begin
			      next_pending_ahb_xfer = pending_ahb_xfer;
			      next_cmd_non_seq	    = cmd_non_seq;
			      next_cmd_ff_data 	    = cmd_ff_data;
                              next_addr_ack         = addr_ack;
			      next_wrffen           = 1'b0;
			      next_wdata	    = {1'b0,HWDATA};	
			      next_wr_data_cmplt    = wr_data_cmplt; 
			      next_hreadyout_int    = 1'b0;
			      next_AHB_state	    = AHB_state;
                              next_prev_trans_type  = HTRANS;
                           end
                           else // previous old burst SEQ
                           begin
			      next_pending_ahb_xfer = pending_ahb_xfer;
			      next_cmd_non_seq	    = cmd_non_seq;
			      next_cmd_ff_data 	    = cmd_ff_data;
                              next_addr_ack         = addr_ack;
			      next_wrffen           = hreadyout ? 1'b1 : 1'b0;
			      next_wdata	    = {1'b0,wdata[AHB_DATA_WIDTH-1:0]};	
			      next_wr_data_cmplt    = 1'b0; 
			      next_hreadyout_int    = 1'b0;
			      next_AHB_state	    = AHB_state;
                              next_prev_trans_type  = HTRANS;
                           end
                        end
		end
                else if (read_flag && outstanding_rd_en) // it is ensured that the read data for the SEQ/NSEQ given in read state is 
                //placed in(read_flag && outstanding_rd_en)  condition
                begin
                        case(rd_data_cnt)
                         2'd0:
                         begin
                              next_rd_data_cnt    = 2'd0;  
			      next_AHB_state	  = rdata_valid ? (rd_err_xfer ? ERROR : AHB_state) : AHB_state;
                              next_hreadyout_int  = rdata_valid ? !rd_err_xfer : 1'b0;
		              next_HRDATA         = rdata_valid ? rdata[AHB_DATA_WIDTH-1:0]  : HRDATA;
			      next_HRESP 	  = rdata_valid ? rd_err_xfer : HRESP;
                              next_outstanding_rd_en   = rdata_valid ? 1'b0 : outstanding_rd_en;
                              //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1  ? rdata_valid & rd_err_xfer  : 1'b0;
                              next_cmplt_read_fifo_flush = rdata_valid & rd_err_xfer;
                         end

                         2'd1:
                         begin
                              next_hreadyout_int  = !rd_err_reg_xfer;
                              next_HRDATA         = rdata_reg[AHB_DATA_WIDTH-1:0];  
			      next_HRESP 	  = rd_err_reg_xfer;
                       	      next_rd_data_cnt        = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                              next_rdata_reg          = rdata_valid ? rdata : rdata_reg;
    			      next_AHB_state	  = rd_err_reg_xfer ? ERROR : AHB_state;
                              next_outstanding_rd_en   = 1'b0;
                             //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1  ?  rd_err_reg_xfer   : 1'b0;
                             next_cmplt_read_fifo_flush = rd_err_reg_xfer;

                         end
                         2'd2:
                         begin

                              next_hreadyout_int  = !rd_err_reg_xfer;
                              next_HRDATA         = rdata_reg[AHB_DATA_WIDTH-1:0];  
			      next_HRESP 	  = rd_err_reg_xfer;
                              next_rd_data_cnt    = 2'd0; 
			      next_AHB_state	  = rd_err_reg_xfer ? ERROR : AHB_state;
                              next_outstanding_rd_en   = 1'b0;
                             //next_cmplt_read_fifo_flush = prev_burst_type == 3'd1  ?  rd_err_reg_xfer   : 1'b0;
                             next_cmplt_read_fifo_flush = rd_err_reg_xfer;
                           end
                         endcase

                       //end
                end
 		else if ((HSELx && (hreadyout == HREADY) && (HTRANS==NSEQ) && (ahb_error)) || pending_ahb_xfer)   // SLAVE SELECT AND NONSEQ
		begin
                   if(write_flag)
                   begin
                      if(hreadyout || wr_data_cmplt)
                      begin
                           next_pending_ahb_xfer = 1'b0;
                           next_wr_data_cmplt    = 1'b0; 
                           next_hreadyout_int 	= 1'b0;
			   next_HRESP 		= 1'b1;
			   //next_HRESP 		= check_wdata ? 1'b0 : 1'b1;
                           next_wrffen		= wr_data_cmplt ? 1'b0 : 1'b1;
                           next_wdata		= wr_data_cmplt ? wdata : {1'b1,wdata[AHB_DATA_WIDTH-1:0]};
                           next_AHB_state	= ERROR;
                      end
                      else
                      begin
                           next_hreadyout_int 	= 1'b1;
                           next_HRESP 		= 1'b0;
                           next_wrffen		= 1'b0;
                           next_wdata		= wdata;
                           next_AHB_state	= AHB_state;
                      end
                   end
                   else
                   begin
                      // if(hreadyout || rd_data_plcd)  
                      // From busy state ,if outstanding_rd_en=0, rd_data_plcd is 1
                      // From busy state ,if outstanding_rd_en=1, rd_data_plcd is 0, instead
                      // wait for hreadyout (asserted under (read_flag && outstanding_rd_en))
                      //begin
                           next_rd_data_plcd         = 1'b0;
		           next_hreadyout_int 	     = 1'b0;
		           next_HRESP 		     = 1'b1;
		           next_AHB_state	     = ERROR;
                           next_cmplt_read_fifo_flush = prev_burst_type == 3'd1 ? 1'b1 : 1'b0;
                           next_prev_burst_type       = cmd_data_hburst;
		           next_write_flag            = 1'b0;
		           next_read_flag	      = 1'b0;
                      //end
	          end
		end

		else if ((HSELx && (HTRANS == NSEQ) && (hreadyout == HREADY))|| (cmd_non_seq))  //-- undefined INCR transfer since busy --> IDLE transition
		begin
			next_wrffen		= (write_flag && (!cmd_non_seq) && (!wr_data_cmplt))  ? 1'b1 : 1'b0;
			next_wdata		= (cmd_non_seq) ? wdata : hreadyout ? {1'b1,wdata[AHB_DATA_WIDTH-1:0]} :
                                                  {1'b1,HWDATA[AHB_DATA_WIDTH-1:0]} ;

			//next_wrffen		= (write_flag && (!cmd_non_seq) && (!wr_data_cmplt)) || (cmd_non_seq && (!wr_data_cmplt)) ? 1'b1 : 1'b0;
// (cmd_non_seq && (!wr_data_cmplt) - New burst info is acknowledged,
// wr_data_cmplt for the new burst NSEQ data is incomplete (In write state
// under almost full, NSEQ->BUSY)
			//next_wdata		= (cmd_non_seq && wr_data_cmplt) || (cmd_non_seq && (!wr_data_cmplt))  ? wdata : {1'b1,wdata[AHB_DATA_WIDTH-1:0]} ;
// cmd_non_seq -> This will be set only if new NSEQ info is acknowledged and at the
// same time the previous burst data is already written into WDATA FIFO for sure.
// (cmd_non_seq && wr_data_cmplt) - New burst is ackowledged and the previous
// burst data is already written into WDATA FIFO
// (cmd_non_seq && !wr_data_cmplt) - New burst is ackowledged and the new
// burst data is yet to be written into WDATA FIFO

                        //next_prev_trans_type    = HTRANS;
                        next_prev_trans_type    = NSEQ;

		    if (!cmd_full && (hreadyout || rd_data_plcd || wr_data_cmplt))  
		    //if (!cmd_full && (hreadyout || rd_data_plcd))  
		    begin
                        next_addr_ack           = 1'b0;    
                        next_rd_data_plcd       = 1'b0;
                        next_wr_data_cmplt      = 1'b0;
			next_hreadyout_int	= write_flag ? (((!cmd_non_seq) && HWRITE) || (cmd_non_seq && cmd_ff_data_hwrite))  : 
                                                  1'b0; // during write NS(write)->BUSY0->NS(read) this check is required
			//next_hreadyout_int	= write_flag ? cmd_non_seq ? 1'b0 : (((!cmd_non_seq) && HWRITE) || (cmd_non_seq && cmd_ff_data_hwrite))  : 1'b0; // during write NS(write)->BUSY0->NS(read) this check is required
			//next_hreadyout_int		= write_flag ? 1'b1 : 1'b0;
			next_cmd_non_seq	= 1'b0;
			next_cmd_ff_data 	= (cmd_non_seq) ? cmd_ff_data :{/*mr_access*/cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
                        next_prev_burst_type    = cmd_non_seq ? cmd_ff_data_hburst : cmd_data_hburst;
                        next_rd_fifo_flush_start = write_flag ? 1'b0 : 1'b1;
			next_cmd_wr  	         = write_flag ? 1'b1 : 1'b0;
		
			if (!cmd_non_seq)
			begin
				if (HWRITE)
				begin
				    next_AHB_state	= write_flag ? WRITE : RD_FIFO_FLUSH;
				    next_write_flag 	= 1'b1;
				    next_read_flag	= 1'b0;
				end
				else
				begin
				    next_AHB_state	     = write_flag ? READ : RD_FIFO_FLUSH; // after flushing extra read data, write into the command FIFO to avoid flushing the new transfer's read data
				    next_write_flag 	     = 1'b0;
				    next_read_flag	     = 1'b1;
				end
			end
			else
			begin
				if (cmd_ff_data_hwrite)
				begin
				    next_AHB_state	= write_flag ? WRITE : RD_FIFO_FLUSH;
				    next_write_flag 	= 1'b1;
				    next_read_flag	= 1'b0;
				end
				else
				begin
				    next_AHB_state	     = write_flag ? READ : RD_FIFO_FLUSH; // after flushing extra read data, write into the command FIFO to avoid flushing the new transfer's read data
				    next_write_flag 	     = 1'b0;
				    next_read_flag	     = 1'b1;
				end
	     		end
		    end
                    else if (write_flag)
                    begin
			//next_hreadyout_int      = hreadyout_int;
			next_hreadyout_int 		= cmd_full ? 1'b0 : 1'b1;
                        //next_wr_data_cmplt      = 1'b1; //no need to check hreadyout since from this is wait state and hence no need to give hreadyout for busy given during write transfer.
                        next_wr_data_cmplt      = hreadyout ? 1'b1 : wr_data_cmplt;
			next_cmd_non_seq	= 1'b1;
			next_cmd_ff_data 	= cmd_non_seq ? cmd_ff_data : {/*mr_access*/cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
			next_cmd_wr 		= 1'b0;
			next_AHB_state		= AHB_state;
		    end
                    else // if (hreadyout && read_flag) // cmd_full and previous sequential read data is already placed
                    begin
			next_hreadyout_int 	= cmd_full ? 1'b0 : 1'b1;
			next_cmd_non_seq	= 1'b1;
			next_cmd_ff_data 	= cmd_non_seq ? cmd_ff_data : {/*mr_access*/cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
			next_cmd_wr 		= 1'b0;
			next_AHB_state		= AHB_state;
                        //next_rd_data_plcd      = 1'b1;
                    end
                end

                else if ((!HSELx) || (HTRANS == MSTR_IDLE)) // MASTER IN IDLE  -- undefined INCR transfer since busy --> IDLE transition
                begin
                	if (write_flag)
                	begin
                                next_prev_trans_type    = HTRANS;
                	        next_wrffen		= 1'b1;
                	        next_wdata		= hreadyout ? {1'b1,wdata[AHB_DATA_WIDTH-1:0]} : {1'b1,HWDATA[AHB_DATA_WIDTH-1:0]} ;
                	        next_AHB_state		= R_W_IDLE;
                	        next_hreadyout_int	= 1'b1;
                	        //next_hreadyout_int	= cmd_full ? 1'b0 : 1'b1;
                	end
                	else 
                	begin
                                next_rd_data_plcd        = 1'b0;
                                next_prev_trans_type     = HTRANS;
                                next_rd_fifo_flush_start = 1'b1;
                	        next_AHB_state		 = RD_FIFO_FLUSH;
                		next_write_flag          = 1'b0;
                		next_read_flag	         = 1'b0;
                                next_hreadyout_int	 = 1'b1;
                                //next_hreadyout_int	 = 1'b0;
                	end
                end

               else if (HSELx && (HTRANS == BUSY)) 
		begin
		   next_AHB_state	   = AHB_state;
                   next_prev_trans_type    = HTRANS;
		   next_hreadyout_int	   = 1'b1;
		   //next_hreadyout_int	   = hreadyout_int;  // From WRITE state, hready has to be zero; From read hready depends on data availablility
		   next_wrffen		 = 1'b0;//RSR ; addded newly
		   next_wdata		 = wr_data_cmplt ? wdata : (hreadyout ? wdata : {1'b0,HWDATA});	//RSR, added newly
                end

		else if (HSELx && (HTRANS == SEQ)) // MASTER IN BUSY MODE DURING DWWOI OR UWI STATES
		begin
                   next_prev_trans_type    = HTRANS;
		   if (write_flag) 
		   begin
                                next_hreadyout_int 	= 1'b1;
                                next_AHB_state	        = WRITE;
                           if(hreadyout)
                           begin
                                //next_hreadyout_int 	= 1'b0;
                                next_wrffen		= 1'b1;
                                //next_AHB_state	        = WRITE;
                           end
                           else
                           begin
                                //next_hreadyout_int 	= 1'b1;
                                next_wrffen		= 1'b0;
                                //next_AHB_state	= AHB_state;
                           end
                   end
                   else
                   begin
                        //if(hreadyout || rd_data_plcd) - no need to check
                        //this. this is already ensured
                        //begin
                           next_rd_data_plcd      = 1'b0;
			   next_AHB_state	  = READ; //added
                           next_hreadyout_int     = hreadyout ? 1'b0 : 1'b1; // acknowledge the SEQ address. The data for this will be placed in READ state.
			   // next_outstanding_rd_en flag is not required to
			   // be set.
		   end
                end
		else //if (HSELx && (HTRANS= BUSY )) ; HSELx=0 inside BUSY state is not possible. Since after busy master has to give some valid htrans type like NONSEQ, SEQ, IDLE . From there the FSM moves to write/idle state
		begin
		   next_AHB_state	   = WAIT_STATE;
                   next_prev_trans_type    = HTRANS;
		   next_hreadyout_int	   = hreadyout_int;  // From WRITE state, hready has to be zero; From read hready depends on data availablility
		end
	end
  
        RD_FIFO_FLUSH:
        begin
           next_rd_data_cnt             = 2'd0;
           next_rd_fifo_flush_start 	= rd_fifo_flush_ack ? 1'b0 : rd_fifo_flush_start;
           next_rd_fifo_flush_ack_reg 	= rd_fifo_flush_ack ? 1'b1 : (rd_fifo_flush_ack_reg ? (!rd_ff_empty) : rd_fifo_flush_ack_reg );
           //next_rd_fifo_flush_ack_reg 	= rd_fifo_flush_ack_reg ? (!rd_ff_empty) : (rd_fifo_flush_ack ? 1'b1 : rd_fifo_flush_ack_reg);

      if(write_flag || read_flag)
      begin
           next_cmd_wr 		= rd_fifo_flush_ack ? 1'b0 : (rd_fifo_flush_ack_reg ?  (rd_ff_empty ? 1'b1  : 1'b0) : 1'b0);
      	   next_hreadyout_int 	= hreadyout_int;
	   next_AHB_state      	= rd_fifo_flush_ack ? AHB_state : (rd_fifo_flush_ack_reg && rd_ff_empty ? (read_flag ? READ : (write_flag ? WRITE : R_W_IDLE)) : AHB_state);
      end
      else if ((HSELx && (hreadyout == HREADY)) && (HTRANS==NSEQ) && (ahb_error))   // SLAVE SELECT AND NONSEQ
      begin
      	   next_hreadyout_int 	= 1'b0;
           next_pending_ahb_xfer = 1'b1;
      	   next_HRESP 		= rd_fifo_flush_ack ? 1'b0 : (rd_fifo_flush_ack_reg && rd_ff_empty ? 1'b1 : 1'b0); // no need to check for check_wdata since it will not be set once it comes to IDLE state
	   next_AHB_state	= rd_fifo_flush_ack ? AHB_state : (rd_fifo_flush_ack_reg && rd_ff_empty ? ERROR : AHB_state);
      end
      else if ((HSELx && hreadyout == HREADY && HTRANS==NSEQ) || (cmd_non_seq))  // SLAVE SELECT AND NONSEQ
      begin
              next_prev_trans_type    = HSELx && (!cmd_non_seq)? HTRANS : prev_trans_type;
              next_prev_burst_type = HSELx && (!cmd_non_seq)? HBURST : prev_burst_type;
          if (!cmd_full) 
          begin
              if((hreadyout || addr_ack) && (!rd_fifo_flush_ack) && rd_fifo_flush_ack_reg && rd_ff_empty)
              begin
                 next_addr_ack        = 1'b0;    
      	         next_cmd_non_seq     = 1'b0;
      	         next_cmd_ff_data     = (cmd_non_seq) ? cmd_ff_data : {/*mr_access*/ cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
      	         next_cmd_wr 	      = 1'b1;  
      	         next_AHB_state	      = cmd_non_seq ? (cmd_ff_data_hwrite ? WRITE : READ) : ( HWRITE ? WRITE : READ);
      	         next_hreadyout_int   = (wr_almost_full || ((!cmd_data_hwrite) && (!cmd_non_seq) ) || 
                                        ((!cmd_ff_data_hwrite) && cmd_non_seq ))  ? 1'b0 : 1'b1; 
                 next_write_flag      = cmd_non_seq ? (cmd_ff_data_hwrite ? 1 : 0) : ( HWRITE ? 1 : 0);
                 next_read_flag	      = cmd_non_seq ? (cmd_ff_data_hwrite ? 0: 1) : ( HWRITE ? 0 : 1);
              end
              else //if (hreadyout || addr_ack)
              begin
                 next_addr_ack        = 1'b1;    
      	         next_cmd_non_seq     = 1'b1;
      	         next_cmd_ff_data     = (cmd_non_seq) ? cmd_ff_data : {/*mr_access*/ cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
                 next_AHB_state       = AHB_state;
      	         next_hreadyout_int   = 1'b0;
              end
          end
          else
          begin
              next_addr_ack           = hreadyout ? 1'b1 :  addr_ack;    
      	      next_hreadyout_int      = 1'b0;
      	      next_cmd_ff_data 	      = cmd_non_seq ? cmd_ff_data : {/*mr_access*/ cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
      	      next_cmd_non_seq	      = 1'b1;
      	      next_cmd_wr 	      = 1'b0;
          end
      end
      else
      begin
      	next_hreadyout_int 	= hreadyout_int;
        next_AHB_state		= rd_fifo_flush_ack ? AHB_state : (rd_fifo_flush_ack_reg && rd_ff_empty ? (pending_ahb_xfer ? ERROR : R_W_IDLE): AHB_state);
	//next_AHB_state      	= rd_fifo_flush_ack ? AHB_state : (rd_fifo_flush_ack_reg && rd_ff_empty ?  R_W_IDLE : AHB_state);
      	next_HRESP 		= rd_fifo_flush_ack ? 1'b0 : (rd_fifo_flush_ack_reg && rd_ff_empty ? (pending_ahb_xfer ? 1'b1 :1'b0) : 1'b0); // no need to check for check_wdata since it will not be set once it comes to IDLE state
      end

        end


	ERROR:
	begin
                next_outstanding_rd_en   = 1'b0;
                next_pending_ahb_xfer = 1'b0;

		if ((!hreadyout) && (HRESP))
		begin
			next_hreadyout_int 		= 1'b1;
			next_AHB_state			= AHB_state;
			next_HRESP 			= HRESP;
                        next_error_resp_cmplt           = 1'b1;
		end
                //else if ((!HRESP) && (mr8_wr_success)) // this block is not
                //required since HRESP is asserted to 1 before coming to this
                //state
                //begin
                //	next_HRESP 			= 1'b1;
                //	next_AHB_state			= AHB_state;
                //end
                else if (HSELx && (hreadyout == HREADY) && (HTRANS==NSEQ) && (ahb_error))   // SLAVE SELECT AND NONSEQ
                begin
                	next_hreadyout_int 	 = 1'b0;
                	next_HRESP 		 = 1'b1;
                	//next_HRESP 		 = check_wdata ? 1'b0 : 1'b1; // check_wdata check is not required. Since it is already checked before coming to ERROR state. Also update to MR8 is not possible in error followed by error xfer
                	next_AHB_state		 = AHB_state;
                        next_prev_burst_type     = cmd_data_hburst;
                        next_write_flag          = 1'b0;
                        next_read_flag	         = 1'b0;
                end
		else if (((HSELx && (hreadyout == HREADY) && HTRANS == NSEQ) || (cmd_non_seq))&& error_resp_cmplt)  
		begin
			next_HRESP 			= 1'b0;
                        next_prev_trans_type    = NSEQ;
		
		    if (!cmd_full && (hreadyout || rd_data_plcd || wr_data_cmplt))  
		    //if (!cmd_full && (hreadyout || rd_data_plcd))  
		    begin
                        next_error_resp_cmplt   = 1'b0;
                        next_rd_data_plcd       = 1'b0;
                        next_wr_data_cmplt      = 1'b0;
			next_hreadyout_int	= 1'b0;
			next_cmd_non_seq	= 1'b0;
			next_cmd_ff_data 	= (cmd_non_seq) ? cmd_ff_data :{/*mr_access*/cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
                        next_prev_burst_type    = cmd_non_seq ? cmd_ff_data_hburst : cmd_data_hburst;
                        next_rd_fifo_flush_start = cmplt_read_fifo_flush ? 1'b1 : 1'b0;
			next_cmd_wr 		 = cmplt_read_fifo_flush ? 1'b0 : 1'b1;
                        next_cmplt_read_fifo_flush = 1'b0;
		
			if (!cmd_non_seq)
			begin
				if (HWRITE)
				begin
				    next_AHB_state	= cmplt_read_fifo_flush ? RD_FIFO_FLUSH : WRITE;
				    next_write_flag 	= 1'b1;
				    next_read_flag	= 1'b0;
				end
			        else
				begin
				    next_AHB_state	= cmplt_read_fifo_flush ? RD_FIFO_FLUSH : READ;
				    next_write_flag 	= 1'b0;
				    next_read_flag	= 1'b1;
				end
			end
			else
			begin
				if (cmd_ff_data_hwrite)
				begin
				    next_AHB_state	= cmplt_read_fifo_flush ? RD_FIFO_FLUSH : WRITE;
				    next_write_flag 	= 1'b1;
				    next_read_flag	= 1'b0;
				end
				else
				begin
				    next_AHB_state	= cmplt_read_fifo_flush ? RD_FIFO_FLUSH : READ;
				    next_write_flag 	= 1'b0;
				    next_read_flag	= 1'b1;
				end
	     		end
		    end
                    else if (write_flag)
                    begin
			next_hreadyout_int 	= 1'b0;
                        next_wr_data_cmplt      = 1'b1;
                        //next_wr_data_cmplt    = hreadyout ? 1'b1 : wr_data_cmplt;
			next_cmd_non_seq	= 1'b1;
			next_cmd_ff_data 	= cmd_non_seq ? cmd_ff_data : {/*mr_access*/cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
			next_cmd_wr 		= 1'b0;
			next_AHB_state		= AHB_state;
		    end
                    else // if (cmd_full && hreadyout && read_flag) // cmd_full and previous sequential read data is already placed
                    begin
			next_hreadyout_int 	= 1'b0;
			next_cmd_non_seq	= 1'b1;
			next_cmd_ff_data 	= cmd_non_seq ? cmd_ff_data : {/*mr_access*/cmd_data_hwrite,cmd_data_hsize,cmd_data_hburst,cmd_data_haddr};
			next_cmd_wr 		= 1'b0;
			next_AHB_state		= AHB_state;
                        next_rd_data_plcd      = 1'b1;
                    end
		end

		else if (((HTRANS == MSTR_IDLE) || (!HSELx)) && error_resp_cmplt) // after error response Master can provide IDLE/NSEQ transfer
		begin
                        next_error_resp_cmplt           = 1'b0;
			next_hreadyout_int 		= 1'b1;
			//next_hreadyout_int 		= cmplt_read_fifo_flush ? 1'b0:1'b1;
			next_HRESP 			= 1'b0;
                        next_rd_fifo_flush_start        = cmplt_read_fifo_flush ? 1'b1 : 1'b0;
			next_AHB_state			= cmplt_read_fifo_flush ? RD_FIFO_FLUSH : R_W_IDLE;
                        next_cmplt_read_fifo_flush      = 1'b0;
                        next_write_flag          = 1'b0;
                        next_read_flag	         = 1'b0;
		end

		else if (HSELx && HTRANS == BUSY) // after error response Master can provide IDLE/NSEQ transfer
		begin
			next_hreadyout_int 		= 1'b1;
			next_HRESP 			= 1'b0;
			next_AHB_state			= AHB_state;
		end
                else
                begin
			next_hreadyout_int 		= 1'b0;
			next_HRESP 			= 1'b1;
			next_AHB_state			= AHB_state;
                end
	end	
	default : 
	begin
	end

	endcase

end

endmodule




































































































































