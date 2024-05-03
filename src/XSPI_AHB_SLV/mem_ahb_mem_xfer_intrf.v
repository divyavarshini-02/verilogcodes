


/*************************************************************************************


*************************************************************************************/
module mem_ahb_mem_xfer_intrf( 

   	mem_clk,
   	mem_rst_n,


	ahb_cmd_ff_data,
	ahb_cmd_ff_empty,
	ahb_cmd_ff_rden,

	ahb_rd_ff_data,
	ahb_rd_ff_full,
	ahb_rd_ff_wren,
	
	ahb_cmd_valid,
        ahb_mr_access,
   	ahb_addr,
   	ahb_write,
   	ahb_burst,
   	ahb_len,
   	xfer_len,
   	ahb_size,
   	cont_wr_rd_req,
   	ahb_cmd_ready, 


   	ahb_rdata_valid,
   	ahb_rdata,
   	ahb_rdata_last,
   	ahb_rdata_resp,
   	ahb_rdata_ready,
	rd_fifo_flush_start,
	rd_fifo_flush_ack_out,
	dq_rdata_flush_done,
 	
	//mr8_btype,
        ce_n_ip,
        //mr8_wr_success,
        //rd_prefetch_en,
        //ap_mem_wrap_size,
	wr_start_en


 
);


///////////////////////
// Parameters
//////////////////////////////////////////////////////////////////////////////
// functions
//////////////////////////////////////////////////////////////////////////////

parameter LEN_WIDTH       = 10;
parameter AHB_ADDR_WIDTH = 32;
parameter AHB_DATA_WIDTH = 32;


//////////////////////////////////////////////////////////////////////////////
// STATE MACHINE
//////////////////////////////////////////////////////////////////////////////


localparam INIT 		= 2'b00;
//localparam WAIT_MR8_CMPLT       = 2'b01;
localparam CMD_DATA_STATE	= 2'b10;

localparam LEN4 	= 8'b00000011;
localparam LEN8   	= 8'b00000111;
localparam LEN16  	= 8'b00001111;


//*********************************INPUTS & OUTPUTS************************************


input   		mem_clk;
input   		mem_rst_n;
input		[39:0]	ahb_cmd_ff_data;
input			ahb_cmd_ff_empty;
output			ahb_cmd_ff_rden;
input   		ahb_cmd_ready;
input   		ahb_rdata_valid;
input   	[AHB_DATA_WIDTH-1:0]	ahb_rdata;
input   		ahb_rdata_last;
input    		ahb_rdata_resp;
//input 			mr8_btype;
input ce_n_ip;
//input mr8_wr_success; //pulse in mem_clk
//input rd_prefetch_en;
//input [6:0]        ap_mem_wrap_size;





output			        ahb_rd_ff_wren;
output		[AHB_DATA_WIDTH:0]		ahb_rd_ff_data;
input				ahb_rd_ff_full;	
output				ahb_cmd_valid;
output                          ahb_mr_access;
output	[AHB_ADDR_WIDTH-1:0]	ahb_addr;
output   			ahb_write;
output   	[1:0]		ahb_burst;
output   	[LEN_WIDTH-1:0]		ahb_len;
output   	[9:0]		xfer_len;
output   	[2:0]		ahb_size;
output   			cont_wr_rd_req;
output   			ahb_rdata_ready; 
output				wr_start_en;
input                   	rd_fifo_flush_start;
output				rd_fifo_flush_ack_out;
input				dq_rdata_flush_done;

wire				ahb_cmd_ff_rden;



reg 	[1:0]			mem_ahb_state,next_mem_ahb_state;
reg                             next_ahb_mr_access, ahb_mr_access;
reg	[31:0]			ahb_addr,next_ahb_addr;
reg	[LEN_WIDTH-1:0]			ahb_len,next_ahb_len;
reg 	[1:0]			ahb_burst,next_ahb_burst;
reg	[2:0]			ahb_size,next_ahb_size;
reg				ahb_write,next_ahb_write;
reg	[9:0]  			xfer_len,next_xfer_len;	
reg	[AHB_ADDR_WIDTH-1:0]	nxt_addr,next_nxt_addr;
reg				prev_rd_wr,next_prev_rd_wr;
reg	[1:0]			prev_btype,next_prev_btype;
reg   	[9:0]		        prev_xfer_len , next_prev_xfer_len;
reg	[LEN_WIDTH:0]			prev_xfer_size,next_prev_xfer_size;
reg				rdata_valid_reg,next_rdata_valid_reg;
reg				rdata_valid;
reg                             cont_wr_rd_req, next_cont_wr_rd_req;
reg				ahb_cmd_valid,next_ahb_cmd_valid;
reg				ahb_rdata_ready,next_ahb_rdata_ready;
reg				ahb_rd_ff_wren,next_ahb_rd_ff_wren;
reg		[AHB_DATA_WIDTH:0]		ahb_rd_ff_data, next_ahb_rd_ff_data;
reg				rd_fifo_flush_ack,next_rd_fifo_flush_ack;
reg                             rd_fifo_flush_ack_d1;
reg                             rd_fifo_flush_ack_d2;
reg				rd_fifo_flush_ack_out;
reg				check_rd_flush_cmplt,next_check_rd_flush_cmplt;
reg                             rd_fifo_flush_done_reg, next_rd_fifo_flush_done_reg; 



//reg				wr_start_en,next_wr_start_en;






assign wr_start_en = (ahb_cmd_valid && ahb_cmd_ready) && (ahb_write);  // Trigger to start the write data packer
  


assign ahb_cmd_ff_rden = ((!ahb_cmd_ff_empty) && (mem_ahb_state == INIT))? 1'b1 : 1'b0;

wire cont_wr_rd_req_wire;



reg upcoming_wrap_cont_possbl, next_upcoming_wrap_cont_possbl;
wire [LEN_WIDTH:0] cur_xfer_size;
wire [LEN_WIDTH:0] new_wrap_size;
wire [LEN_WIDTH-1:0] new_wrap_len;
wire [AHB_ADDR_WIDTH-1:0] nxt_addr_final;
reg nxt_addr_subseq_wrap_bndry_middle;

assign cur_xfer_size = burst_length(ahb_len,ahb_size); 
assign new_wrap_len  = ahb_cmd_ff_data[34:32]==3'd2 ? 'd3 : ahb_cmd_ff_data[34:32]==3'd4 ? 'd7 : ahb_cmd_ff_data[34:32]==3'd6 ? 'd15 : 'd0;
assign cur_wrap      = ahb_cmd_ff_data[34:32]==3'd2 || ahb_cmd_ff_data[34:32]==3'd4 || ahb_cmd_ff_data[34:32]==3'd6; 
assign new_wrap_size = burst_length (new_wrap_len,ahb_cmd_ff_data[37:35]);
assign cur_incr      = ahb_cmd_ff_data[34:32]==3'd0 || ahb_cmd_ff_data[34:32]==3'd1 || ahb_cmd_ff_data[34:32]==3'd3 || ahb_cmd_ff_data[34:32]==3'd5 || ahb_cmd_ff_data[34:32]==3'd7; 
assign nxt_addr_final = (nxt_addr + new_wrap_size);

always @ *
begin
   case (new_wrap_size)
   'd15:
       nxt_addr_subseq_wrap_bndry_middle =  |nxt_addr[3:0];
   'd31:
       nxt_addr_subseq_wrap_bndry_middle =  |nxt_addr[4:0];
   'd63:
       nxt_addr_subseq_wrap_bndry_middle =  |nxt_addr[5:0];
    default:
       nxt_addr_subseq_wrap_bndry_middle = 1'b1;
    endcase
end

// NO CONT- write, INCR->WRAP
// CONT - read

assign	cont_wr_rd_req_wire = (!ahb_cmd_ff_data[38]) && (!ahb_cmd_ff_data[39]) && (!(prev_rd_wr || ahb_cmd_ff_data[38])) && (!(prev_btype == 2'b01 && prev_xfer_len[9])) && 
( ( (nxt_addr[AHB_ADDR_WIDTH-1:1] == ahb_cmd_ff_data[AHB_ADDR_WIDTH-1:1]) &&  
   ((/*mr8_btype &*/ prev_btype == 2'b10 && cur_incr) || (prev_btype == 2'b01 && cur_incr) ) ) ||
  ( (prev_xfer_size==new_wrap_size) && cur_wrap && upcoming_wrap_cont_possbl && (ahb_cmd_ff_data[AHB_ADDR_WIDTH-1:0]>=nxt_addr && ahb_cmd_ff_data[AHB_ADDR_WIDTH-1:0]<=nxt_addr_final) && (!nxt_addr_subseq_wrap_bndry_middle))
   ); 
//assign	cont_wr_rd_req_wire = (!ahb_cmd_ff_data[38]) && (!ahb_cmd_ff_data[39]) && (!(prev_rd_wr || ahb_cmd_ff_data[38])) && (!(prev_btype == 2'b01 && prev_xfer_len[9])) && 
//( ( (nxt_addr[AHB_ADDR_WIDTH-1:1] == ahb_cmd_ff_data[AHB_ADDR_WIDTH-1:1]) &&  
//   ((mr8_btype & prev_btype == 2'b10 && cur_incr) || (prev_btype == 2'b01 && cur_incr) ) ) ||
//  ( ((prev_xfer_size==new_wrap_size) &&  (prev_btype == 2'b10 && cur_wrap)) && (ahb_cmd_ff_data[AHB_ADDR_WIDTH-1:0]>=nxt_addr && ahb_cmd_ff_data[AHB_ADDR_WIDTH-1:0]<=nxt_addr_final))
//   ); 


// incr followed by wrap no continuous;  (!ahb_cmd_ff_data[38]) means continuous assertion only for read operation;      
// (!ahb_cmd_ff_data[39]) is to check No mr_access 
// prev_btype == 2'b01 && prev_xfer_len[9] - Previous is INCR undefined



wire [31:0] end_addr_final;
assign end_addr_final = end_addr(ahb_addr[31:0],ahb_len,ahb_size,ahb_burst);

wire prev_req_mr8_wr;
wire cur_req_not_mr_access;

assign prev_req_mr8_wr = ahb_mr_access && (ahb_addr=='d8) && ahb_write;
assign cur_req_not_mr_access = ! (ahb_cmd_ff_data[39] );

always @ (posedge mem_clk or negedge mem_rst_n)

begin
	if (!mem_rst_n)
	begin
		mem_ahb_state		<= 	INIT;
                ahb_mr_access           <=      1'b0;
		ahb_addr		<=	32'b0;
		ahb_len			<=	{LEN_WIDTH{1'b0}};
		ahb_burst		<=	2'b0;
		ahb_size		<=	3'b0;
		ahb_write		<=	1'b0;
		xfer_len		<=	10'b0;
		rdata_valid		<= 1'b0;	
		rdata_valid_reg		<= 1'b0;  	
                cont_wr_rd_req          <= 1'b0;
		ahb_cmd_valid		<= 	1'b0;
		//wr_start_en		<=  	1'b0;
		nxt_addr 		<=	32'b0;
		prev_btype	        <= 	2'b0;
                prev_xfer_len           <=      10'd0;
		prev_xfer_size          <=      {LEN_WIDTH{1'b0}};
		prev_rd_wr		<=	1'b0;
		ahb_rdata_ready 	<= 	1'b0;
		ahb_rd_ff_wren 		<= 	1'b0;
		ahb_rd_ff_data          <=      {(AHB_DATA_WIDTH+1){1'b0}};
		rd_fifo_flush_ack 	<= 	1'b0;
		rd_fifo_flush_ack_d1 	<= 	1'b0;
		rd_fifo_flush_ack_d2 	<= 	1'b0;
		rd_fifo_flush_ack_out	<= 	1'b0;
		check_rd_flush_cmplt	<= 	1'b0;
               rd_fifo_flush_done_reg  <= 1'b0;
                upcoming_wrap_cont_possbl <= 1'b0;
	end 
	


	else
	begin


		mem_ahb_state		<= 	next_mem_ahb_state;
                ahb_mr_access           <=      next_ahb_mr_access;
		ahb_addr		<=	next_ahb_addr;
		ahb_len			<=	next_ahb_len;
		ahb_burst		<=	next_ahb_burst;
		ahb_size		<=	next_ahb_size;
		ahb_write		<=	next_ahb_write;
		xfer_len		<=	next_xfer_len;
		rdata_valid		<=	ahb_cmd_ff_rden;
		rdata_valid_reg		<=  	next_rdata_valid_reg;
                cont_wr_rd_req          <= next_cont_wr_rd_req;
		ahb_cmd_valid		<=	next_ahb_cmd_valid;
		//wr_start_en		<=	next_wr_start_en;
         	nxt_addr 		<=	next_nxt_addr;
		prev_btype	        <= 	next_prev_btype;
                prev_xfer_len           <=      next_prev_xfer_len;
		prev_xfer_size          <=      next_prev_xfer_size;
		prev_rd_wr		<=	next_prev_rd_wr;
		ahb_rdata_ready 	<= 	next_ahb_rdata_ready;
		ahb_rd_ff_wren 		<= 	next_ahb_rd_ff_wren;
		ahb_rd_ff_data          <=      next_ahb_rd_ff_data;
		rd_fifo_flush_ack 	<= 	next_rd_fifo_flush_ack;
		rd_fifo_flush_ack_d1 	<= 	rd_fifo_flush_ack;
		rd_fifo_flush_ack_d2 	<= 	rd_fifo_flush_ack_d1;
		rd_fifo_flush_ack_out 	<= 	rd_fifo_flush_ack_d2; // delayed in order to update the status of AHB read data FIFO empty
		check_rd_flush_cmplt 	<= 	next_check_rd_flush_cmplt;
                rd_fifo_flush_done_reg  <= next_rd_fifo_flush_done_reg;
                upcoming_wrap_cont_possbl <= next_upcoming_wrap_cont_possbl;
		
	end
end

always @ (*)

begin


		next_mem_ahb_state	= 	mem_ahb_state;
                next_ahb_mr_access      =       ahb_mr_access;
		next_ahb_addr		=	ahb_addr;
		next_ahb_len		=	ahb_len;
		next_ahb_burst		=	ahb_burst;
		next_ahb_size		=	ahb_size;
		next_ahb_write		=	ahb_write;
		next_xfer_len	        =	xfer_len;
		next_rdata_valid_reg	=  	rdata_valid_reg;
		next_cont_wr_rd_req	=	cont_wr_rd_req;
		next_ahb_cmd_valid	=	ahb_cmd_valid;
		//next_wr_start_en	=	wr_start_en;
         	next_nxt_addr 		=	nxt_addr;
		next_prev_btype	        = 	prev_btype;
                next_prev_xfer_len  =       prev_xfer_len;
		next_prev_xfer_size     =       prev_xfer_size;
		next_prev_rd_wr		=	prev_rd_wr;
		next_ahb_rdata_ready 	= 	ahb_rdata_ready;
		next_ahb_rd_ff_wren 	= 	1'b0;
		next_ahb_rd_ff_data     =       ahb_rd_ff_data;
		next_rd_fifo_flush_ack 	= 	rd_fifo_flush_start && rd_fifo_flush_done_reg && (!rd_fifo_flush_ack) ? 1'b1 : 1'b0;
		next_rd_fifo_flush_done_reg 	= rd_fifo_flush_ack ? 1'b0 : dq_rdata_flush_done ? 1'b1 : rd_fifo_flush_done_reg;
		next_check_rd_flush_cmplt = 	dq_rdata_flush_done ? 1'b0 : check_rd_flush_cmplt;
                next_upcoming_wrap_cont_possbl = upcoming_wrap_cont_possbl;


		

                 //if(dq_rdata_flush_done)
		 //begin
		 //       	next_rd_fifo_flush_ack = rd_fifo_flush_start ? 1'b1 :rd_fifo_flush_ack ;
                 //               next_check_rd_flush_cmplt = 1'b0;
                 //               //next_rd_fifo_flush_done_reg = 1'b1; //added newly. Need to register since rd_fifo_flush_start for a read transfer might come after the dq_rdata_fifo is flushed. Hene register this to give rd_fifo_flush_ack when rd_fifo_flush_start is asserted
		 //end

		if ( ((!ahb_rd_ff_full) || (ahb_rd_ff_full && ahb_rdata_ready)) && ((!check_rd_flush_cmplt) || (check_rd_flush_cmplt && (!rd_fifo_flush_start))) )
		begin
			next_ahb_rdata_ready = ahb_rd_ff_full ? 1'b0 : 1'b1;

			if (ahb_rdata_valid && ahb_rdata_ready)
			begin
                                next_rd_fifo_flush_done_reg = 1'b0;
				next_ahb_rd_ff_wren = 1'b1;
		                next_ahb_rd_ff_data    = {ahb_rdata_resp,ahb_rdata}; // ahb_rdata_resp is DQS timeout here
                                next_check_rd_flush_cmplt = ahb_rdata_last ? 1'b1 : 1'b0;
			end
			else
			begin
				next_ahb_rd_ff_wren = 1'b0;
			end
		end
		else
		begin
			next_ahb_rdata_ready = 1'b0;
		end



	case (mem_ahb_state)

	INIT:
	begin
	
		if((rdata_valid) || (rdata_valid_reg))  
		begin

		
			next_rdata_valid_reg = 1'b0;

				case (ahb_cmd_ff_data[34:32])
	
					3'b000:
					begin		
						next_ahb_len	= 8'd0;  	// SINGLE BEAT
						next_ahb_burst	= 2'b01;  	// INCR
   			                        next_xfer_len   = (ahb_cmd_ff_data[37:35] == 3'b000 ) ? 'd1 :
                                     				  (ahb_cmd_ff_data[37:35] == 3'b001 ) ? 'd1 :
                                     				  (ahb_cmd_ff_data[37:35] == 3'b010 ) ? 'd 2 :  				
                                     				  (ahb_cmd_ff_data[37:35] == 3'b011 ) ? 'd 4 : 'd8 ; 				
					end
		
					3'b001:
					begin		
						next_ahb_len	= (AHB_DATA_WIDTH ==32) ?((ahb_cmd_ff_data[37:35] == 3'b000 ) ? 'd1023 :
                                     				  (ahb_cmd_ff_data[37:35] == 3'b001 ) ? 'd511 : 'd255) : 
								  (AHB_DATA_WIDTH ==64) ? ((ahb_cmd_ff_data[37:35] == 3'b000 ) ? 'd1023 :
                                     				  (ahb_cmd_ff_data[37:35] == 3'b001 ) ? 'd511 :
                                     				  (ahb_cmd_ff_data[37:35] == 3'b010 ) ? 'd255 : 'd127) :
								  (AHB_DATA_WIDTH ==128) ? ((ahb_cmd_ff_data[37:35] == 3'b000 ) ? 'd1023 :
                                     				  (ahb_cmd_ff_data[37:35] == 3'b001 ) ? 'd511 :
                                     				  (ahb_cmd_ff_data[37:35] == 3'b010 ) ? 'd255 :
                                     				  (ahb_cmd_ff_data[37:35] == 3'b011 ) ? 'd127 : 'd63) : 0; 	
//AHB_DATA_WIDTH ==32 ? 255 : AHB_DATA_WIDTH ==64 ? 127 :                          AHB_DATA_WIDTH ==128 ? 63 : 0; // keep max 
						next_ahb_burst	= 2'b01;  	// INCR
   			                        next_xfer_len   = 512; // keep max 
					end
					3'b010:
					begin	
						next_ahb_len 	= 8'd3;	// FOUR BEATS
						next_ahb_burst	= 2'b10;  	// WRAP
   			                        next_xfer_len   = (ahb_cmd_ff_data[37:35] == 3'b010 ) ? 'd 8 :		
   			                                          (ahb_cmd_ff_data[37:35] == 3'b011 ) ? 'd 16 : 'd32; 				
					end
		
					3'b011:
					begin	
						next_ahb_len 	= 8'd3;	// FOUR BEATS
						next_ahb_burst	= 2'b01;  	// INCR
   			                        next_xfer_len   = (ahb_cmd_ff_data[37:35] == 3'b000 ) ? ( ahb_cmd_ff_data[0] ? 'd3 : 'd2) :
                                     		 		  (ahb_cmd_ff_data[37:35] == 3'b001 ) ? 'd4 :
                                     				  (ahb_cmd_ff_data[37:35] == 3'b010 ) ? 'd 8 :			
                                     				  (ahb_cmd_ff_data[37:35] == 3'b011 ) ? 'd 16 : 'd32 ; 				

					end

					3'b100:
					begin
						next_ahb_len 	= 8'd7;	// EIGHT BEATS
						next_ahb_burst	= 2'b10;  	// WRAP
   			                        next_xfer_len   =  (ahb_cmd_ff_data[37:35] == 3'b001 ) ? 'd8 :
                                                                   (ahb_cmd_ff_data[37:35] == 3'b010 ) ? 'd 16 : 'd32 ; 				

					end
	
					3'b101:
					begin
						next_ahb_len 	= 8'd7;	// EIGHT BEATS
						next_ahb_burst	= 2'b01;  	// INCR
   			                        next_xfer_len   = (ahb_cmd_ff_data[37:35] == 3'b000 ) ? ( ahb_cmd_ff_data[0] ? 'd5 : 'd4) :
                                     				  (ahb_cmd_ff_data[37:35] == 3'b001 ) ? 'd8 :
                                     				  (ahb_cmd_ff_data[37:35] == 3'b010 ) ? 'd 16 :				
                                     				  (ahb_cmd_ff_data[37:35] == 3'b011 ) ? 'd 32 : 'd64 ; 				

					end

					3'b110:
					begin
						next_ahb_len 	= 8'd15;	// SIXTEEN BEATS
						next_ahb_burst	= 2'b10;  	// WRAP
   			                        next_xfer_len   =  (ahb_cmd_ff_data[37:35] == 3'b000 ) ? 'd8 :
                                                                   (ahb_cmd_ff_data[37:35] == 3'b001 ) ? 'd16 : 'd 32; 				

					end
	
					3'b111:
						begin
						next_ahb_len 	= 8'd15;	// SIXTEEN BEATS
						next_ahb_burst	= 2'b01;  	// INCR
   			                        next_xfer_len   = (ahb_cmd_ff_data[37:35] == 3'b000 ) ? ( ahb_cmd_ff_data[0] ? 'd9 : 'd8) :
                                     				  (ahb_cmd_ff_data[37:35] == 3'b001 ) ? 'd16 :
                                     				  (ahb_cmd_ff_data[37:35] == 3'b010 ) ? 'd32 :
                                     				  (ahb_cmd_ff_data[37:35] == 3'b011 ) ? 'd64 : 'd128 ; 				


					end

				endcase
				next_ahb_addr		= ahb_cmd_ff_data[31:0];
				next_ahb_size		= ahb_cmd_ff_data[37:35];
				next_ahb_write		= ahb_cmd_ff_data[38];
                                next_ahb_mr_access      = ahb_cmd_ff_data[39];
				next_cont_wr_rd_req  	= 1'b0 ?((prev_req_mr8_wr &&  (!ce_n_ip) && cur_req_not_mr_access) ? cont_wr_rd_req :cont_wr_rd_req_wire)
                                                           : 1'b0 ;
				next_ahb_cmd_valid  	= prev_req_mr8_wr && (!ce_n_ip) && cur_req_not_mr_access ? 1'b0 : 1'b1;
				next_mem_ahb_state 	= prev_req_mr8_wr && (!ce_n_ip) && cur_req_not_mr_access ? 1'b0 /*WAIT_MR8_CMPLT */: CMD_DATA_STATE;
			end
			else
			begin
			next_mem_ahb_state 	= INIT;
			end
	end
	
      /* WAIT_MR8_CMPLT:
       begin
		next_rdata_valid_reg 	=  (rdata_valid ? 1'b1 : rdata_valid_reg);
           if(mr8_wr_success)
           begin
		next_cont_wr_rd_req  	= rd_prefetch_en ? cont_wr_rd_req_wire : 1'b0;
		next_ahb_cmd_valid  	= 1'b1;
		next_mem_ahb_state 	= CMD_DATA_STATE;
           end
           else
           begin
		next_cont_wr_rd_req  	= cont_wr_rd_req;
		next_ahb_cmd_valid  	= ahb_cmd_valid;
		next_mem_ahb_state 	= mem_ahb_state;
           end
       end*/

	CMD_DATA_STATE:
	begin
		//next_wr_start_en	= 1'b0;

		next_rdata_valid_reg 	=  (rdata_valid ? 1'b1 : rdata_valid_reg);

		if ((ahb_cmd_ready) && (ahb_cmd_valid))
		begin
         		next_nxt_addr 		= end_addr_final[0] ?  end_addr_final+ 32'd 1 : end_addr_final + 32'd2;
			next_prev_btype	        = ahb_burst;
			next_prev_rd_wr		= ahb_write;
                        next_upcoming_wrap_cont_possbl = cont_wr_rd_req ? (cur_xfer_size == prev_xfer_size) && upcoming_wrap_cont_possbl :
                                                         (ahb_burst==2'b10 ? ((cur_xfer_size == (6'd0-7'd1)) ? 1'b0 : 1'b1/*since on wrap size mimatch controller auto-initiates MR8 write with hy*/) : 1'b1); 
                        next_prev_xfer_len      = xfer_len;
			next_prev_xfer_size     = cur_xfer_size;
			//next_prev_xfer_size     = ahb_burst==2'b10 ? cur_xfer_size : 7'd0;
			next_cont_wr_rd_req  	= 1'b0;
			next_ahb_cmd_valid  	= 1'b0;
			next_mem_ahb_state	= INIT;	
		end
		else
		begin
			next_mem_ahb_state	= mem_ahb_state;
		end
	end	

	default:
	begin
	end
	

endcase

end


//////////////////////////////////////////////////////////////////////////////
// functions
//////////////////////////////////////////////////////////////////////////////

function [LEN_WIDTH:0] burst_length;
input [LEN_WIDTH-1:0] ahb_len;
input [2:0] ahb_size;

begin
   burst_length = 'h0;

   case ( ahb_size )

      3'b000   : burst_length = ahb_len;	             // BYTE	
      3'b001   : burst_length = (ahb_len<< 1) + 1;      // HALF WORD
      3'b010   : burst_length = (ahb_len<< 2) + 3;      // WORD
      default  : 
	begin
	  	burst_length = (ahb_len << 3) + 7;      // DWORD
	end

   endcase // case( size )
end
endfunction // burst_length




function [31:0] end_addr;
input [31:0] start_addr;
input [LEN_WIDTH-1:0] ahb_len;
input [2:0] ahb_size;
input [1:0] ahb_burst;

reg   [31:0] add_bytes;
      
begin
   add_bytes =  burst_length(ahb_len,ahb_size);

   case ( ahb_burst )

      // INCR
      2'b01:
      begin
         end_addr = start_addr + add_bytes;
      end
      // WRAP
      2'b10:
      begin
         case ( ahb_size )
            3'b000 :
            begin
               case ( ahb_len)
                  LEN4   : end_addr = {start_addr[31:2], 2'd0} + add_bytes;
                  LEN8   : end_addr = {start_addr[31:3], 3'd0} + add_bytes;
                  LEN16  : end_addr = {start_addr[31:4], 4'd0} + add_bytes;
                  default : end_addr = start_addr;
               endcase // case( length )

            end // case: BYTE
            3'b001 :
            begin
               case ( ahb_len)
                  LEN4   : end_addr = {start_addr[31:3], 3'd0} + add_bytes;
                  LEN8   : end_addr = {start_addr[31:4], 4'd0} + add_bytes;
                  LEN16  : end_addr = {start_addr[31:5], 5'd0} + add_bytes;
                  default : end_addr = start_addr;
               endcase // case( ahb_len )
            end // HALF_WORD
            3'b010 :
            begin
               case (ahb_len)
                  LEN4   : end_addr = {start_addr[31:4], 4'd0} + add_bytes;
                  LEN8   : end_addr = {start_addr[31:5], 5'd0} + add_bytes;
                  LEN16  : end_addr = {start_addr[31:6], 6'd0} + add_bytes;
                  default : end_addr = start_addr;
               endcase // case( ahb_len)
            end // WORD
            3'b011 :
            begin
               case (ahb_len)
                  LEN4   : end_addr = {start_addr[31:5], 5'd0} + add_bytes;
                  LEN8   : end_addr = {start_addr[31:6], 6'd0} + add_bytes;
                  LEN16  : end_addr = {start_addr[31:7], 7'd0} + add_bytes;
                  default : end_addr = start_addr;
               endcase // case( ahb_len)
            end //DWORD
    	       
           default :
	    begin 
		end_addr = start_addr;
	    end
		  
         endcase // case( size )
      end
      default :
      begin
         end_addr = start_addr;
      end
   endcase // case( burst )
end
endfunction // end_addr


endmodule
