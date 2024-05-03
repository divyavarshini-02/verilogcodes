//WRITE DATA PACKER... READING WRITE DATA FROM THE WRITE DATA FIFO 
//AND PACKED IT INTO 32 BIT ACCORDING TO SIZE AND STARTING ADDRESS.  


module ahb_slave_wrdata  (

    
     	mem_clk, 
     	mem_rst_n,

     	wr_start_en,
     	wdata_ready_in,
     	hsize, 
	addr,
    
     	wdata, 
     	wvalid, 
     	wstrb, 
     	wlast_o,
	wdata_ff_empty,
	wdata_ff_rd_en,
     	wdata_ff_data

);

parameter AHB_ADDR_WIDTH = 32;
parameter AHB_DATA_WIDTH = 32;
 




//*********************************INPUTS & OUTPUTS************************************


 
input                                  	mem_clk;
input                                  	mem_rst_n;
input                                  	wr_start_en;
input  [2:0]                           	hsize;
input                                  	wdata_ready_in;
input 					wdata_ff_empty;
input [AHB_DATA_WIDTH :0]		wdata_ff_data;
input  [AHB_ADDR_WIDTH-1:0]             addr;


output [31 :0]        	                wdata;
output                                 	wvalid;
output [3:0]    			wstrb;
output                                 	wlast_o;
output 					wdata_ff_rd_en;


//===================================================================================


wire   [2:0]                           	hsize_sig;
wire   [AHB_ADDR_WIDTH-1:0] 	        addr_sig;
wire  					wr_start_en_sig;
wire 					wdata_ff_empty;
wire 					wdata_ff_rd_en;


 

reg	[31:0]	        wdata,next_wdata;
reg	[3:0]				wstrb,next_wstrb; 
reg                                     rdata_valid;
reg			         	wr_start_en_reg ,next_wr_start_en_reg;
reg	[2:0]		         	hsize_reg,next_hsize_reg;
reg	[AHB_ADDR_WIDTH-1:0]	        addr_reg,next_addr_reg;
reg 					wvalid,next_wvalid;
reg					wlast_o,next_wlast_o;
reg	[1:0]				rd_data_cnt,next_rd_data_cnt;
reg	[AHB_DATA_WIDTH:0]		rdata_reg, next_rdata_reg;			

//===================================================================================

assign hsize_sig        = ( wr_start_en ) ? hsize        : hsize_reg;
assign addr_sig        	= ( wr_start_en ) ? addr : addr_reg ;
assign wr_start_en_sig  = ( wr_start_en | wr_start_en_reg );






//===================================================================================
// AXI DATA WIDTH 32 bits
//===================================================================================

generate 

if ( AHB_DATA_WIDTH == 32 ) // AHB DATA WIDTH == 32
begin


reg  [3:0] 				wdata_state,next_wdata_state;
reg					wr_hword0_flag,next_wr_hword0_flag; 
reg					wr_byte0_flag,next_wr_byte0_flag;
reg					wr_hword1_flag,next_wr_hword1_flag; 
reg					wr_byte1_flag,next_wr_byte1_flag;
reg					wr_byte2_flag, next_wr_byte2_flag;
reg					wr_byte3_flag,next_wr_byte3_flag;  

localparam [3:0]  WR_IDLE        = 4'b0000;
localparam [3:0]  WR_BYTE_0      = 4'b0001;
localparam [3:0]  WR_BYTE_1      = 4'b0010;
localparam [3:0]  WR_BYTE_2      = 4'b0011;
localparam [3:0]  WR_BYTE_3      = 4'b0100;
localparam [3:0]  WR_HWORD_0     = 4'b0101;
localparam [3:0]  WR_HWORD_1     = 4'b0110;
localparam [3:0]  WR_WORD        = 4'b0111;


assign wlast = wdata_ff_data[32];
assign wdata_ff_rd_en = ((!wdata_ff_empty) && ( (( wdata_state == WR_IDLE  ) &&  wr_start_en_sig ) ||
                                              (( wdata_state == WR_BYTE_0)) || 
                                              (( wdata_state == WR_BYTE_1)) ||
                                              (( wdata_state == WR_BYTE_2)) ||
                                              (( wdata_state == WR_BYTE_3)) ||
                                              (( wdata_state == WR_HWORD_0)) || 
                                              (( wdata_state == WR_HWORD_1)) ||
                                              (( wdata_state == WR_WORD))) && (!(next_rd_data_cnt>=1))
                                              ); // ensuring that rd_data_cnt possible values are 0,1 and 2


always @ (posedge mem_clk or negedge mem_rst_n)


begin
	if (!mem_rst_n)
	begin
		wdata_state		<= WR_IDLE;
		wdata			<= 32'b0;
		wr_hword0_flag 		<= 1'b0; 
		wr_hword1_flag 		<= 1'b0;
		wr_byte0_flag		<= 1'b0;
		wr_byte1_flag		<= 1'b0;
		wr_byte2_flag		<= 1'b0; 
		wr_byte3_flag		<= 1'b0; 
		wstrb  			<= 4'b0; 
                rdata_valid             <= 1'b0;
         	wr_start_en_reg  	<= 1'b0;
         	hsize_reg   		<= 3'b0;
         	addr_reg 		<= 32'b0;
		wvalid			<= 1'b0;
		wlast_o			<= 1'b0;
		rdata_reg		<= {AHB_DATA_WIDTH+1{1'b0}};
		rd_data_cnt		<= 2'b0;




	end 
	
	else
	begin
		wdata_state		<= next_wdata_state;
		wdata			<= next_wdata;
		wr_hword0_flag 		<= next_wr_hword0_flag;
		wr_hword1_flag 		<= next_wr_hword1_flag;
		wr_byte0_flag		<= next_wr_byte0_flag;
		wr_byte1_flag		<= next_wr_byte1_flag;
		wr_byte2_flag		<= next_wr_byte2_flag;
		wr_byte3_flag		<= next_wr_byte3_flag;
		wstrb  			<= next_wstrb; 
         	wr_start_en_reg  	<= next_wr_start_en_reg;
         	hsize_reg   		<= next_hsize_reg;
         	addr_reg 		<= next_addr_reg;
                rdata_valid             <= wdata_ff_rd_en;
		wvalid			<= next_wvalid;
		wlast_o			<= next_wlast_o;
		rdata_reg		<= next_rdata_reg;
		rd_data_cnt		<= next_rd_data_cnt;

	end
end




//===================================================================================


always @ (*)
begin


		next_wdata_state	= wdata_state;
		next_wdata		= wdata;
		next_wr_hword0_flag 	= wr_hword0_flag;
		next_wr_hword1_flag 	= wr_hword1_flag;
		next_wr_byte0_flag	= wr_byte0_flag;
		next_wr_byte1_flag	= wr_byte1_flag;
		next_wr_byte2_flag	= wr_byte2_flag;
		next_wr_byte3_flag	= wr_byte3_flag;
		next_wstrb  		= wstrb;
		next_wlast_o		= wlast_o;
		next_wvalid		= wvalid;
                next_rd_data_cnt        = rdata_valid ? rd_data_cnt + 1 : rd_data_cnt;
                next_rdata_reg          = rd_data_cnt==0 && rdata_valid ? wdata_ff_data : rdata_reg;
         	next_wr_start_en_reg  	= wlast ? 1'b0 : wr_start_en ? 1'b1 : wr_start_en_reg;
         	next_hsize_reg   	= wr_start_en ?  hsize : hsize_reg;
         	next_addr_reg 		= wr_start_en ? addr : addr_reg;


   case (wdata_state )   

      WR_IDLE :
      begin

                if (wr_start_en_sig)  // BYTE ACCESS
		begin
			if (hsize_sig == 3'd0)  
         		begin
            			if ( addr_sig[1:0] == 2'b00 ) 
				begin
               				next_wdata_state = WR_BYTE_0;
					next_wr_byte0_flag = 1'b1;
				end
            			else if ( addr_sig[1:0] == 2'b01 )
				begin
					next_wr_byte1_flag = 1'b1;
               				next_wdata_state = WR_BYTE_1;
				end
            			else if ( addr_sig[1:0] == 2'b10 )
				begin
					next_wr_byte2_flag = 1'b1;
               				next_wdata_state = WR_BYTE_2;
				end
            			else 
				begin
					next_wr_byte3_flag = 1'b1;
               				next_wdata_state = WR_BYTE_3;
         			end
			end
         
         		else if  (hsize_sig == 3'd1) // HALF WORD ACCESS  - possible only 2'b00, 2'b10
         		begin
            			if (addr_sig[1:0] == 2'b00) 
            			//if ( (addr_sig[1:0] == 2'b00) | (addr_sig[1:0] == 2'b01 ) )
				begin
               				next_wdata_state = WR_HWORD_0;
					next_wr_hword0_flag = 1'b1;
				end
            			else 
				begin
					next_wr_hword1_flag = 1'b1;
               				next_wdata_state = WR_HWORD_1;
				end
         		end 

         		else if (hsize_sig == 3'd2)           // WORD ACCESS
			begin
            			next_wdata_state  = WR_WORD ;
					
			end
		end

         	else
		begin

            	next_wdata_state = WR_IDLE ;
		end
      	end                   
      

	// BYTE 0      

      WR_BYTE_0 :
      begin

	  if ( (wr_byte0_flag && (!wvalid)) || (wvalid && wdata_ready_in && (!wlast_o)) || (!wvalid))
          begin
	    next_wstrb  		= 4'b0001;
            case(rd_data_cnt)
            2'd0:
            begin
                 next_rd_data_cnt       = 2'd0;  
	         next_wr_byte0_flag	= wr_byte0_flag ? !(rdata_valid) : wr_byte0_flag;
	         next_wdata		= {wdata[31:8],wdata_ff_data[7:0]};
	         next_wvalid		= rdata_valid && wlast ? 1'b1 : 1'b0;
	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_BYTE_1)  : wdata_state ;
            end
            2'd1:
            begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
	         next_wr_byte0_flag	= 1'b0; 
	         next_wdata		= {wdata[31:8],rdata_reg[7:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_1;
            end
            2'd2:
            begin
                 next_rd_data_cnt       = 2'd1;  //no need to check rdata_valid since we already ensured that the RDATA FIFO is not read again once "rd_data_cnt" count is >=2
                 next_rdata_reg         = wdata_ff_data;
	         next_wr_byte0_flag	= 1'b0; 
	         next_wdata		= {wdata[31:8],rdata_reg[7:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_1;
            end
            endcase
	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
	  begin
	     next_wr_byte0_flag	= 1'b0;
	     next_wvalid	= 1'b0;
	     next_wlast_o	= 1'b0;
	     next_wdata_state 	= WR_IDLE ;
	  end
          else
	  begin
          	next_wdata_state 	= wdata_state;
	  end

      end

      // BYTE 1 
           WR_BYTE_1 :
           begin
     
     	  if ( (wr_byte1_flag && (!wvalid)) || (!wvalid)) //  only "(!wvalid)" this condition is enough
               begin
     	         next_wstrb  		= wr_byte1_flag ? 4'b0010 : {3'b001,wstrb[0]};
                 case(rd_data_cnt)
                 2'd0:
                 begin
                 next_rd_data_cnt       = 2'd0;  
     	         next_wr_byte1_flag	= wr_byte1_flag ? !(rdata_valid) : wr_byte1_flag;
	         next_wdata		= {wdata[31:16],wdata_ff_data[15:8],wdata[7:0]};
     	         next_wvalid		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_BYTE_2)  : wdata_state ;
                 end
                 2'd1:
                 begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
     	         next_wr_byte1_flag	= 1'b0; 
	         next_wdata		= {wdata[31:16],rdata_reg[15:8],wdata[7:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_2;
                 end
                 2'd2:
                 begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
     	         next_wr_byte1_flag	= 1'b0; 
	         next_wdata		= {wdata[31:16],rdata_reg[15:8],wdata[7:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_2;
                 end
                 endcase
     	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
     	  begin
     	     next_wr_byte1_flag	= 1'b0;
     	     next_wvalid	= 1'b0;
     	     next_wlast_o	= 1'b0;
     	     next_wdata_state 	= WR_IDLE ;
     	  end
          else
     	  begin
               	next_wdata_state 	= wdata_state;
     	  end
     
           end

           WR_BYTE_2 :
           begin
     
     	  if ( (wr_byte2_flag && (!wvalid)) || (!wvalid))
               begin
     	         next_wstrb  		= wr_byte2_flag ? 4'b0100 : {2'b01,wstrb[1:0]};
                 case(rd_data_cnt)
                 2'd0:
                 begin
                 next_rd_data_cnt       = 2'd0;  
     	         next_wr_byte2_flag	= wr_byte2_flag ? !(rdata_valid) : wr_byte2_flag;
	         next_wdata		= {wdata[31:24],wdata_ff_data[23:16],wdata[15:0]};
     	         next_wvalid		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_BYTE_3)  : wdata_state ;
                 end
                 2'd1:
                 begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
     	         next_wr_byte2_flag	= 1'b0; 
	         next_wdata		= {wdata[31:24],rdata_reg[23:16],wdata[15:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_3;
                 end
                 2'd2:
                 begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
     	         next_wr_byte2_flag	= 1'b0; 
	         next_wdata		= {wdata[31:24],rdata_reg[23:16],wdata[15:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_3;
                 end
                 endcase
     	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
     	  begin
     	     next_wr_byte2_flag	= 1'b0;
     	     next_wvalid	= 1'b0;
     	     next_wlast_o	= 1'b0;
     	     next_wdata_state 	= WR_IDLE ;
     	  end
          else
     	  begin
               	next_wdata_state 	= wdata_state;
     	  end
     
           end

           WR_BYTE_3 :
           begin
     
     	  if ( (wr_byte3_flag && (!wvalid)) || (!wvalid))
               begin
     	         next_wstrb  		= wr_byte3_flag ? 4'b1000 : {1'b1,wstrb[2:0]};
                 case(rd_data_cnt)
                 2'd0:
                 begin
                 next_rd_data_cnt       = 2'd0;  
     	         next_wr_byte3_flag	= wr_byte3_flag ? !(rdata_valid) : wr_byte3_flag;
	         next_wdata		= {wdata_ff_data[31:24],wdata[23:0]};
     	         next_wvalid		= rdata_valid ? 1'b1 : 1'b0;
     	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_BYTE_0)  : wdata_state ;
                 end
                 2'd1:
                 begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
     	         next_wr_byte3_flag	= 1'b0; 
	         next_wdata		= {rdata_reg[31:24],wdata[23:0]};
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_0;
                 end
                 2'd2:
                 begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
     	         next_wr_byte3_flag	= 1'b0; 
	         next_wdata		= {rdata_reg[31:24],wdata[23:0]};
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_0;
                 end
                 endcase
     	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
     	  begin
     	     next_wr_byte3_flag	= 1'b0;
     	     next_wvalid	= 1'b0;
     	     next_wlast_o	= 1'b0;
     	     next_wdata_state 	= WR_IDLE ;
     	  end
          else
     	  begin
               	next_wdata_state 	= wdata_state;
     	  end
     
           end

      // HALF WORD 0
      

   WR_HWORD_0:
      begin

	  if ((wr_hword0_flag && (!wvalid)) || (wvalid && wdata_ready_in && (!wlast_o)) || (!wvalid))
          begin
	    next_wstrb  		= 4'b0011;
            case(rd_data_cnt)
            2'd0:
            begin
                 next_rd_data_cnt       = 2'd0;  
	         next_wr_hword0_flag	= wr_hword0_flag ? !(rdata_valid) : wr_hword0_flag;
	         next_wdata		= {wdata[31:16],wdata_ff_data[15:0]};
	         next_wvalid		= rdata_valid && wlast ? 1'b1 : 1'b0;
	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_HWORD_1)  : wdata_state ;
            end
            2'd1:
            begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
	         next_wr_hword0_flag	= 1'b0; 
	         next_wdata		= {wdata[31:16],rdata_reg[15:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_HWORD_1;
            end
            2'd2:
            begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
	         next_wr_hword0_flag	= 1'b0; 
	         next_wdata		= {wdata[31:16],rdata_reg[15:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_HWORD_1;
            end
            endcase
	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
	  begin
	     next_wr_hword0_flag	= 1'b0;
	     next_wvalid	= 1'b0;
	     next_wlast_o	= 1'b0;
	     next_wdata_state 	= WR_IDLE ;
	  end
          else
	  begin
          	next_wdata_state 	= wdata_state;
	  end

      end

       WR_HWORD_1 :
           begin
     
     	  if ((wr_hword1_flag && (!wvalid)) || (!wvalid))
               begin
     	         next_wstrb  		= wr_hword1_flag ? 4'b1100 : {2'b11,wstrb[1:0]};
                 case(rd_data_cnt)
                 2'd0:
                 begin
                 next_rd_data_cnt       = 2'd0;  
     	         next_wr_hword1_flag	= wr_hword1_flag ? !(rdata_valid) : wr_hword1_flag;
	         next_wdata		= {wdata_ff_data[31:16],wdata[15:0]};
     	         next_wvalid		= rdata_valid ? 1'b1 : 1'b0;
     	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_HWORD_0)  : wdata_state ;
                 end
                 2'd1:
                 begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
     	         next_wr_hword1_flag	= 1'b0; 
	         next_wdata		= {rdata_reg[31:16],wdata[15:0]};
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_HWORD_0;
                 end
                 2'd2:
                 begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
     	         next_wr_hword1_flag	= 1'b0; 
	         next_wdata		= {rdata_reg[31:16],wdata[15:0]};
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_HWORD_0;
                 end
                 endcase
     	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
     	  begin
     	     next_wr_hword1_flag	= 1'b0;
     	     next_wvalid	= 1'b0;
     	     next_wlast_o	= 1'b0;
     	     next_wdata_state 	= WR_IDLE ;
     	  end
          else
     	  begin
               	next_wdata_state 	= wdata_state;
     	  end
     
           end



      // WORD 
      WR_WORD  :
	begin
     	  if ((!wvalid) || (wvalid && wdata_ready_in && (!wlast_o)) )
               begin
     	         next_wstrb  		= 4'b1111;
                 case(rd_data_cnt)
                 2'd0:
                 begin
                 next_rd_data_cnt       = 2'd0;  
     	         next_wdata		= wdata_ff_data[31:0];
     	         next_wvalid		= rdata_valid ? 1'b1 : 1'b0;
     	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= wdata_state;
                 end
                 2'd1:
                 begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
	         next_wdata		= rdata_reg[31:0];
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
     	         next_wdata_state 	= wdata_state;
                 end
                 2'd2:
                 begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
	         next_wdata		= rdata_reg[31:0];
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
     	         next_wdata_state 	= wdata_state;
                 end
                 endcase
     	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
     	  begin
     	     next_wvalid	= 1'b0;
     	     next_wlast_o	= 1'b0;
     	     next_wdata_state 	= WR_IDLE ;
     	  end
          else
     	  begin
               	next_wdata_state 	= wdata_state;
     	  end
     
        end


     default:
	begin
	end
endcase
end
end



else // AHB DATA WIDTH == 64
begin


reg  [4:0] 				wdata_state,next_wdata_state;
reg					wr_hword0_flag,next_wr_hword0_flag; 
reg					wr_hword1_flag,next_wr_hword1_flag; 
reg					wr_hword2_flag,next_wr_hword2_flag; 
reg					wr_hword3_flag,next_wr_hword3_flag; 
reg					wr_word0_flag,next_wr_word0_flag; 
reg					wr_word1_flag,next_wr_word1_flag; 
reg					wr_byte0_flag,next_wr_byte0_flag;
reg					wr_byte1_flag,next_wr_byte1_flag;
reg					wr_byte2_flag, next_wr_byte2_flag;
reg					wr_byte3_flag,next_wr_byte3_flag;  
reg					wr_byte4_flag,next_wr_byte4_flag;
reg					wr_byte5_flag,next_wr_byte5_flag;
reg					wr_byte6_flag, next_wr_byte6_flag;
reg					wr_byte7_flag,next_wr_byte7_flag;  


localparam [4:0]  WR_IDLE        = 5'b00000;
localparam [4:0]  WR_BYTE_0      = 5'b00001;
localparam [4:0]  WR_BYTE_1      = 5'b00010;
localparam [4:0]  WR_BYTE_2      = 5'b00011;
localparam [4:0]  WR_BYTE_3      = 5'b00100;
localparam [4:0]  WR_BYTE_4      = 5'b00101;
localparam [4:0]  WR_BYTE_5      = 5'b00110;
localparam [4:0]  WR_BYTE_6      = 5'b00111;
localparam [4:0]  WR_BYTE_7      = 5'b01000;

localparam [4:0]  WR_HWORD_0     = 5'b01001;
localparam [4:0]  WR_HWORD_1     = 5'b01010;
localparam [4:0]  WR_HWORD_2     = 5'b01011;
localparam [4:0]  WR_HWORD_3     = 5'b01100;

localparam [4:0]  WR_WORD_0        = 5'b01101;
localparam [4:0]  WR_WORD_1        = 5'b01110;

localparam [4:0]  WR_QWORD_LSB        = 5'b01111;
localparam [4:0]  WR_QWORD_MSB        = 5'b10000;





assign wlast = wdata_ff_data[64];
assign wdata_ff_rd_en = ((!wdata_ff_empty) && ( (( wdata_state == WR_IDLE  ) &&  wr_start_en_sig ) ||
                                              (( wdata_state == WR_BYTE_0)) || 
                                              (( wdata_state == WR_BYTE_1)) ||
                                              (( wdata_state == WR_BYTE_2)) ||
                                              (( wdata_state == WR_BYTE_3)) ||
					      (( wdata_state == WR_BYTE_4)) || 
                                              (( wdata_state == WR_BYTE_5)) ||
                                              (( wdata_state == WR_BYTE_6)) ||
                                              (( wdata_state == WR_BYTE_7)) ||
                                              (( wdata_state == WR_HWORD_0)) || 
                                              (( wdata_state == WR_HWORD_1)) ||
                                              (( wdata_state == WR_HWORD_2)) || 
                                              (( wdata_state == WR_HWORD_3)) ||
					      (( wdata_state == WR_WORD_0)) ||
                                              (( wdata_state == WR_WORD_1)) ||
					      (( wdata_state == WR_QWORD_LSB))) && (!(next_rd_data_cnt>=1))
                                              ); 


always @ (posedge mem_clk or negedge mem_rst_n)


begin
	if (!mem_rst_n)
	begin
		wdata_state		<= WR_IDLE;
		wdata			<= 32'b0;
		wr_hword0_flag 		<= 1'b0; 
		wr_hword1_flag 		<= 1'b0;
		wr_hword2_flag 		<= 1'b0; 
		wr_hword3_flag 		<= 1'b0;
		wr_word0_flag 		<= 1'b0; 
		wr_word1_flag 		<= 1'b0;
		wr_byte0_flag		<= 1'b0;
		wr_byte1_flag		<= 1'b0;
		wr_byte2_flag		<= 1'b0; 
		wr_byte3_flag		<= 1'b0; 
		wr_byte4_flag		<= 1'b0;
		wr_byte5_flag		<= 1'b0;
		wr_byte6_flag		<= 1'b0; 
		wr_byte7_flag		<= 1'b0; 
		wstrb  			<= 4'b0; 
                rdata_valid             <= 1'b0;
         	wr_start_en_reg  	<= 1'b0;
         	hsize_reg   		<= 3'b0;
         	addr_reg 		<= 32'b0;
		wvalid			<= 1'b0;
		wlast_o			<= 1'b0;
		rdata_reg		<= {AHB_DATA_WIDTH+1{1'b0}};
		rd_data_cnt		<= 2'b0;




	end 
	
	else
	begin
		wdata_state		<= next_wdata_state;
		wdata			<= next_wdata;
		wr_hword0_flag 		<= next_wr_hword0_flag;
		wr_hword1_flag 		<= next_wr_hword1_flag;
		wr_hword2_flag 		<= next_wr_hword2_flag;
		wr_hword3_flag 		<= next_wr_hword3_flag;
		wr_byte0_flag		<= next_wr_byte0_flag;
		wr_byte1_flag		<= next_wr_byte1_flag;
		wr_byte2_flag		<= next_wr_byte2_flag;
		wr_byte3_flag		<= next_wr_byte3_flag;
		wr_byte4_flag		<= next_wr_byte4_flag;
		wr_byte5_flag		<= next_wr_byte5_flag;
		wr_byte6_flag		<= next_wr_byte6_flag;
		wr_byte7_flag		<= next_wr_byte7_flag;
		wr_word0_flag 		<= next_wr_word0_flag;
		wr_word1_flag 		<= next_wr_word1_flag;
		wstrb  			<= next_wstrb; 
         	wr_start_en_reg  	<= next_wr_start_en_reg;
         	hsize_reg   		<= next_hsize_reg;
         	addr_reg 		<= next_addr_reg;
                rdata_valid             <= wdata_ff_rd_en;
		wvalid			<= next_wvalid;
		wlast_o			<= next_wlast_o;
		rdata_reg		<= next_rdata_reg;
		rd_data_cnt		<= next_rd_data_cnt;

	end
end




//===================================================================================


always @ (*)
begin


		next_wdata_state	= wdata_state;
		next_wdata		= wdata;
		next_wr_hword0_flag 	= wr_hword0_flag;
		next_wr_hword1_flag 	= wr_hword1_flag;
		next_wr_hword2_flag 	= wr_hword2_flag;
		next_wr_hword3_flag 	= wr_hword3_flag;
		next_wr_byte0_flag	= wr_byte0_flag;
		next_wr_byte1_flag	= wr_byte1_flag;
		next_wr_byte2_flag	= wr_byte2_flag;
		next_wr_byte3_flag	= wr_byte3_flag;
		next_wr_byte4_flag	= wr_byte4_flag;
		next_wr_byte5_flag	= wr_byte5_flag;
		next_wr_byte6_flag	= wr_byte6_flag;
		next_wr_byte7_flag	= wr_byte7_flag;
		next_wr_word0_flag 	= wr_word0_flag;
		next_wr_word1_flag 	= wr_word1_flag;
		next_wstrb  		= wstrb;
		next_wlast_o		= wlast_o;
		next_wvalid		= wvalid;
                next_rd_data_cnt        = rdata_valid ? rd_data_cnt + 1 : rd_data_cnt;
                next_rdata_reg          = rd_data_cnt==0 && rdata_valid ? wdata_ff_data : rdata_reg;
         	next_wr_start_en_reg  	= wlast ? 1'b0 : wr_start_en ? 1'b1 : wr_start_en_reg;
         	next_hsize_reg   	= wr_start_en ?  hsize : hsize_reg;
         	next_addr_reg 		= wr_start_en ? addr : addr_reg;


   case (wdata_state )   

      WR_IDLE :
      begin

                if (wr_start_en_sig)  // BYTE ACCESS
		begin
			if (hsize_sig == 3'd0)  
         		begin
            			if ( addr_sig[2:0] == 3'b000 ) 
				begin
               				next_wdata_state = WR_BYTE_0;
					next_wr_byte0_flag = 1'b1;
				end
            			else if ( addr_sig[2:0] == 3'b001 )
				begin
					next_wr_byte1_flag = 1'b1;
               				next_wdata_state = WR_BYTE_1;
				end
            			else if ( addr_sig[2:0] == 3'b010 )
				begin
					next_wr_byte2_flag = 1'b1;
               				next_wdata_state = WR_BYTE_2;
				end
            			else if ( addr_sig[2:0] == 3'b011 )
				begin
					next_wr_byte3_flag = 1'b1;
               				next_wdata_state = WR_BYTE_3;
        			end

            			else if ( addr_sig[2:0] == 3'b100 ) 
				begin
					next_wr_byte4_flag = 1'b1;
               				next_wdata_state = WR_BYTE_4;
				end
            			else if ( addr_sig[2:0] == 3'b101 )
				begin
					next_wr_byte5_flag = 1'b1;
               				next_wdata_state = WR_BYTE_5;
				end
            			else if ( addr_sig[2:0] == 3'b110 )
				begin
					next_wr_byte6_flag = 1'b1;
               				next_wdata_state = WR_BYTE_6;
				end
            			else 
				begin
					next_wr_byte7_flag = 1'b1;
               				next_wdata_state = WR_BYTE_7;
				end
			end
         
         		else if  (hsize_sig == 3'd1) // HALF WORD ACCESS  
         		begin
            			if (addr_sig[2:0] == 3'b000) 
				begin
					next_wr_hword0_flag = 1'b1;
               				next_wdata_state = WR_HWORD_0;
				end
            			else if (addr_sig[2:0] == 3'b010) 
				begin
					next_wr_hword1_flag = 1'b1;
               				next_wdata_state = WR_HWORD_1;
				end
            			else if (addr_sig[2:0] == 3'b100) 
				begin
					next_wr_hword2_flag = 1'b1;
               				next_wdata_state = WR_HWORD_2;
				end
            			else  
				begin
					next_wr_hword3_flag = 1'b1;
               				next_wdata_state = WR_HWORD_3;
				end
         		end 

         		else if (hsize_sig == 3'd2)           // WORD ACCESS
			begin
            			if (addr_sig[2:0] == 3'b000) 
				begin
					next_wr_word0_flag = 1'b1;
               				next_wdata_state = WR_WORD_0;
				end
            			else if (addr_sig[2:0] == 3'b100) 
				begin
					next_wr_word1_flag = 1'b1;
               				next_wdata_state = WR_WORD_1;
				end
                                else  // not expected from AHB master
                                begin
               				next_wdata_state = wdata_state;
                                end
                        end
			else if (hsize_sig == 3'd3)           // QWORD ACCESS
			begin
				next_wdata_state = WR_QWORD_LSB;
					
			end
                        else  // not expected from AHB master
                        begin
               			next_wdata_state = wdata_state;
                        end
		end

         	else
		begin
            	    next_wdata_state = wdata_state ;
		end
      	end                   
      

	// BYTE 0      

      WR_BYTE_0:
      begin

	  if ( (wr_byte0_flag && (!wvalid)) || (wvalid && wdata_ready_in && (!wlast_o)) || (!wvalid))
          begin
	    next_wstrb  		= 4'b0001;
            case(rd_data_cnt)
            2'd0:
            begin
                 next_rd_data_cnt       = 2'd0;  
	         next_wr_byte0_flag	= wr_byte0_flag ? !(rdata_valid) : wr_byte0_flag;
	         next_wdata		= {wdata[31:8],wdata_ff_data[7:0]};
	         next_wvalid		= rdata_valid && wlast ? 1'b1 : 1'b0;
	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_BYTE_1)  : wdata_state ;
            end
            2'd1:
            begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
	         next_wr_byte0_flag	= 1'b0; 
	         next_wdata		= {wdata[31:8],rdata_reg[7:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_1;
            end
            2'd2:
            begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
	         next_wr_byte0_flag	= 1'b0; 
	         next_wdata		= {wdata[31:8],rdata_reg[7:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_1;
            end
            endcase
	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
	  begin
	     next_wr_byte0_flag	= 1'b0;
	     next_wvalid	= 1'b0;
	     next_wlast_o	= 1'b0;
	     next_wdata_state 	= WR_IDLE ;
	  end
          else
	  begin
          	next_wdata_state 	= wdata_state;
	  end

      end

      // BYTE 1 
           WR_BYTE_1 :
           begin
     
     	  if ( (wr_byte1_flag && (!wvalid)) || (!wvalid))
               begin
     	         next_wstrb  		= wr_byte1_flag ? 4'b0010 : {3'b001,wstrb[0]};
                 case(rd_data_cnt)
                 2'd0:
                 begin
                 next_rd_data_cnt       = 2'd0;  
     	         next_wr_byte1_flag	= wr_byte1_flag ? !(rdata_valid) : wr_byte1_flag;
	         next_wdata		= {wdata[31:16],wdata_ff_data[15:8],wdata[7:0]};
     	         next_wvalid		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_BYTE_2)  : wdata_state ;
                 end
                 2'd1:
                 begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
     	         next_wr_byte1_flag	= 1'b0; 
	         next_wdata		= {wdata[31:16],rdata_reg[15:8],wdata[7:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_2;
                 end
                 2'd2:
                 begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
     	         next_wr_byte1_flag	= 1'b0; 
	         next_wdata		= {wdata[31:16],rdata_reg[15:8],wdata[7:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_2;
                 end
                 endcase
     	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
     	  begin
     	     next_wr_byte1_flag	= 1'b0;
     	     next_wvalid	= 1'b0;
     	     next_wlast_o	= 1'b0;
     	     next_wdata_state 	= WR_IDLE ;
     	  end
          else
     	  begin
               	next_wdata_state 	= wdata_state;
     	  end
     
           end

           WR_BYTE_2 :
           begin
     
     	  if ( (wr_byte2_flag && (!wvalid)) || (!wvalid))
               begin
     	         next_wstrb  		= wr_byte2_flag ? 4'b0100 : {2'b01,wstrb[1:0]};
                 case(rd_data_cnt)
                 2'd0:
                 begin
                 next_rd_data_cnt       = 2'd0;  
     	         next_wr_byte2_flag	= wr_byte2_flag ? !(rdata_valid) : wr_byte2_flag;
	         next_wdata		= {wdata[31:24],wdata_ff_data[23:16],wdata[15:0]};
     	         next_wvalid		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_BYTE_3)  : wdata_state ;
                 end
                 2'd1:
                 begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
     	         next_wr_byte2_flag	= 1'b0; 
	         next_wdata		= {wdata[31:24],rdata_reg[23:16],wdata[15:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_3;
                 end
                 2'd2:
                 begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
     	         next_wr_byte2_flag	= 1'b0; 
	         next_wdata		= {wdata[31:24],rdata_reg[23:16],wdata[15:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_3;
                 end
                 endcase
     	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
     	  begin
     	     next_wr_byte2_flag	= 1'b0;
     	     next_wvalid	= 1'b0;
     	     next_wlast_o	= 1'b0;
     	     next_wdata_state 	= WR_IDLE ;
     	  end
          else
     	  begin
               	next_wdata_state 	= wdata_state;
     	  end
     
           end

           WR_BYTE_3 :
           begin
     
     	  if ( (wr_byte3_flag && (!wvalid)) || (!wvalid))
               begin
     	         next_wstrb  		= wr_byte3_flag ? 4'b1000 : {1'b1,wstrb[2:0]};
                 case(rd_data_cnt)
                 2'd0:
                 begin
                 next_rd_data_cnt       = 2'd0;  
     	         next_wr_byte3_flag	= wr_byte3_flag ? !(rdata_valid) : wr_byte3_flag;
	         next_wdata		= {wdata_ff_data[31:24],wdata[23:0]};
     	         next_wvalid		= rdata_valid ? 1'b1 : 1'b0;
     	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_BYTE_4)  : wdata_state ;
                 end
                 2'd1:
                 begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
     	         next_wr_byte3_flag	= 1'b0; 
	         next_wdata		= {rdata_reg[31:24],wdata[23:0]};
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_4;
                 end
                 2'd2:
                 begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
     	         next_wr_byte3_flag	= 1'b0; 
	         next_wdata		= {rdata_reg[31:24],wdata[23:0]};
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_4;
                 end
                 endcase
     	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
     	  begin
     	     next_wr_byte3_flag	= 1'b0;
     	     next_wvalid	= 1'b0;
     	     next_wlast_o	= 1'b0;
     	     next_wdata_state 	= WR_IDLE ;
     	  end
          else
     	  begin
               	next_wdata_state 	= wdata_state;
     	  end
     
           end


      WR_BYTE_4 :
      begin

	  if ( (wr_byte4_flag && (!wvalid)) || (wvalid && wdata_ready_in && (!wlast_o)) || (!wvalid))
          begin
	    next_wstrb  		= 4'b0001;
            case(rd_data_cnt)
            2'd0:
            begin
                 next_rd_data_cnt       = 2'd0;  
	         next_wr_byte4_flag	= wr_byte4_flag ? !(rdata_valid) : wr_byte4_flag;
	         next_wdata		= {wdata[31:8],wdata_ff_data[39:32]};
	         next_wvalid		= rdata_valid && wlast ? 1'b1 : 1'b0;
	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_BYTE_5)  : wdata_state ;
            end
            2'd1:
            begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
	         next_wr_byte4_flag	= 1'b0; 
	         next_wdata		= {wdata[31:8],rdata_reg[39:32]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_5;
            end
            2'd2:
            begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
	         next_wr_byte4_flag	= 1'b0; 
	         next_wdata		= {wdata[31:8],rdata_reg[39:32]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_5;
            end
            endcase
	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
	  begin
	     next_wr_byte4_flag	= 1'b0;
	     next_wvalid	= 1'b0;
	     next_wlast_o	= 1'b0;
	     next_wdata_state 	= WR_IDLE ;
	  end
          else
	  begin
          	next_wdata_state 	= wdata_state;
	  end

      end

      // BYTE 5 
           WR_BYTE_5 :
           begin
     
     	  if ( (wr_byte5_flag && (!wvalid)) || (!wvalid))
               begin
     	         next_wstrb  		= wr_byte5_flag ? 4'b0010 : {3'b001,wstrb[0]};
                 case(rd_data_cnt)
                 2'd0:
                 begin
                 next_rd_data_cnt       = 2'd0;  
     	         next_wr_byte5_flag	= wr_byte5_flag ? !(rdata_valid) : wr_byte5_flag;
	         next_wdata		= {wdata[31:16],wdata_ff_data[47:40],wdata[7:0]};
     	         next_wvalid		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_BYTE_6)  : wdata_state ;
                 end
                 2'd1:
                 begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
     	         next_wr_byte5_flag	= 1'b0; 
	         next_wdata		= {wdata[31:16],rdata_reg[47:40],wdata[7:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_6;
                 end
                 2'd2:
                 begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
     	         next_wr_byte5_flag	= 1'b0; 
	         next_wdata		= {wdata[31:16],rdata_reg[47:40],wdata[7:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_6;
                 end
                 endcase
     	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
     	  begin
     	     next_wr_byte5_flag	= 1'b0;
     	     next_wvalid	= 1'b0;
     	     next_wlast_o	= 1'b0;
     	     next_wdata_state 	= WR_IDLE ;
     	  end
          else
     	  begin
               	next_wdata_state 	= wdata_state;
     	  end
     
           end

           WR_BYTE_6 :
           begin
     
     	  if ( (wr_byte6_flag && (!wvalid)) || (!wvalid))
               begin
     	         next_wstrb  		= wr_byte6_flag ? 4'b0100 : {2'b01,wstrb[1:0]};
                 case(rd_data_cnt)
                 2'd0:
                 begin
                 next_rd_data_cnt       = 2'd0;  
     	         next_wr_byte6_flag	= wr_byte6_flag ? !(rdata_valid) : wr_byte6_flag;
	         next_wdata		= {wdata[31:24],wdata_ff_data[55:48],wdata[15:0]};
     	         next_wvalid		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_BYTE_7)  : wdata_state ;
                 end
                 2'd1:
                 begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
     	         next_wr_byte6_flag	= 1'b0; 
	         next_wdata		= {wdata[31:24],rdata_reg[55:48],wdata[15:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_7;
                 end
                 2'd2:
                 begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
     	         next_wr_byte6_flag	= 1'b0; 
	         next_wdata		= {wdata[31:24],rdata_reg[55:48],wdata[15:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_7;
                 end
                 endcase
     	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
     	  begin
     	     next_wr_byte6_flag	= 1'b0;
     	     next_wvalid	= 1'b0;
     	     next_wlast_o	= 1'b0;
     	     next_wdata_state 	= WR_IDLE ;
     	  end
          else
     	  begin
               	next_wdata_state 	= wdata_state;
     	  end
     
           end

           WR_BYTE_7 :
           begin
     
     	  if ( (wr_byte7_flag && (!wvalid)) || (!wvalid))
               begin
     	         next_wstrb  		= wr_byte7_flag ? 4'b1000 : {1'b1,wstrb[2:0]};
                 case(rd_data_cnt)
                 2'd0:
                 begin
                 next_rd_data_cnt       = 2'd0;  
     	         next_wr_byte7_flag	= wr_byte7_flag ? !(rdata_valid) : wr_byte7_flag;
	         next_wdata		= {wdata_ff_data[63:56],wdata[23:0]};
     	         next_wvalid		= rdata_valid ? 1'b1 : 1'b0;
     	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_BYTE_0)  : wdata_state ;
                 end
                 2'd1:
                 begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
     	         next_wr_byte7_flag	= 1'b0; 
	         next_wdata		= {rdata_reg[63:56],wdata[23:0]};
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_0;
                 end
                 2'd2:
                 begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
     	         next_wr_byte7_flag	= 1'b0; 
	         next_wdata		= {rdata_reg[63:56],wdata[23:0]};
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_BYTE_0;
                 end
                 endcase
     	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
     	  begin
     	     next_wr_byte7_flag	= 1'b0;
     	     next_wvalid	= 1'b0;
     	     next_wlast_o	= 1'b0;
     	     next_wdata_state 	= WR_IDLE ;
     	  end
          else
     	  begin
               	next_wdata_state 	= wdata_state;
     	  end
     
           end

      // HALF WORD 0
      

   WR_HWORD_0:
      begin

	  if ((wr_hword0_flag && (!wvalid)) || (wvalid && wdata_ready_in && (!wlast_o)) || (!wvalid))
          begin
	    next_wstrb  		= 4'b0011;
            case(rd_data_cnt)
            2'd0:
            begin
                 next_rd_data_cnt       = 2'd0;  
	         next_wr_hword0_flag	= wr_hword0_flag ? !(rdata_valid) : wr_hword0_flag;
	         next_wdata		= {wdata[31:16],wdata_ff_data[15:0]};
	         next_wvalid		= rdata_valid && wlast ? 1'b1 : 1'b0;
	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_HWORD_1)  : wdata_state ;
            end
            2'd1:
            begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
	         next_wr_hword0_flag	= 1'b0; 
	         next_wdata		= {wdata[31:16],rdata_reg[15:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_HWORD_1;
            end
            2'd2:
            begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
	         next_wr_hword0_flag	= 1'b0; 
	         next_wdata		= {wdata[31:16],rdata_reg[15:0]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_HWORD_1;
            end
            endcase
	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
	  begin
	     next_wr_hword0_flag	= 1'b0;
	     next_wvalid	= 1'b0;
	     next_wlast_o	= 1'b0;
	     next_wdata_state 	= WR_IDLE ;
	  end
          else
	  begin
          	next_wdata_state 	= wdata_state;
	  end

      end

       WR_HWORD_1 :
           begin
     
     	  if ((wr_hword1_flag && (!wvalid)) || (!wvalid))
               begin
     	         next_wstrb  		= wr_hword1_flag ? 4'b1100 : {2'b11,wstrb[1:0]};
                 case(rd_data_cnt)
                 2'd0:
                 begin
                 next_rd_data_cnt       = 2'd0;  
     	         next_wr_hword1_flag	= wr_hword1_flag ? !(rdata_valid) : wr_hword1_flag;
	         next_wdata		= {wdata_ff_data[31:16],wdata[15:0]};
     	         next_wvalid		= rdata_valid ? 1'b1 : 1'b0;
     	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_HWORD_2)  : wdata_state ;
                 end
                 2'd1:
                 begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
     	         next_wr_hword1_flag	= 1'b0; 
	         next_wdata		= {rdata_reg[31:16],wdata[15:0]};
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_HWORD_2;
                 end
                 2'd2:
                 begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
     	         next_wr_hword1_flag	= 1'b0; 
	         next_wdata		= {rdata_reg[31:16],wdata[15:0]};
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_HWORD_2;
                 end
                 endcase
     	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
     	  begin
     	     next_wr_hword1_flag	= 1'b0;
     	     next_wvalid	= 1'b0;
     	     next_wlast_o	= 1'b0;
     	     next_wdata_state 	= WR_IDLE ;
     	  end
          else
     	  begin
               	next_wdata_state 	= wdata_state;
     	  end
     
           end

   WR_HWORD_2:
      begin

	  if ((wr_hword2_flag && (!wvalid)) || (wvalid && wdata_ready_in && (!wlast_o)) || (!wvalid))
          begin
	    next_wstrb  		= 4'b0011;
            case(rd_data_cnt)
            2'd0:
            begin
                 next_rd_data_cnt       = 2'd0;  
	         next_wr_hword2_flag	= wr_hword2_flag ? !(rdata_valid) : wr_hword2_flag;
	         next_wdata		= {wdata[31:16],wdata_ff_data[47:32]};
	         next_wvalid		= rdata_valid && wlast ? 1'b1 : 1'b0;
	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_HWORD_3)  : wdata_state ;
            end
            2'd1:
            begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
	         next_wr_hword2_flag	= 1'b0; 
	         next_wdata		= {wdata[31:16],rdata_reg[47:32]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_HWORD_3;
            end
            2'd2:
            begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
	         next_wr_hword2_flag	= 1'b0; 
	         next_wdata		= {wdata[31:16],rdata_reg[47:32]};
	         next_wvalid		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0; 
	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_HWORD_3;
            end
            endcase
	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
	  begin
	     next_wr_hword2_flag	= 1'b0;
	     next_wvalid	= 1'b0;
	     next_wlast_o	= 1'b0;
	     next_wdata_state 	= WR_IDLE ;
	  end
          else
	  begin
          	next_wdata_state 	= wdata_state;
	  end

      end

       WR_HWORD_3 :
           begin
     
     	  if ((wr_hword3_flag && (!wvalid)) || (!wvalid))
               begin
     	         next_wstrb  		= wr_hword3_flag ? 4'b1100 : {2'b11,wstrb[1:0]};
                 case(rd_data_cnt)
                 2'd0:
                 begin
                 next_rd_data_cnt       = 2'd0;  
     	         next_wr_hword3_flag	= wr_hword3_flag ? !(rdata_valid) : wr_hword3_flag;
	         next_wdata		= {wdata_ff_data[63:48],wdata[15:0]};
     	         next_wvalid		= rdata_valid ? 1'b1 : 1'b0;
     	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_HWORD_0)  : wdata_state ;
                 end
                 2'd1:
                 begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
     	         next_wr_hword3_flag	= 1'b0; 
	         next_wdata		= {rdata_reg[63:48],wdata[15:0]};
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_HWORD_0;
                 end
                 2'd2:
                 begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
     	         next_wr_hword3_flag	= 1'b0; 
	         next_wdata		= {rdata_reg[63:48],wdata[15:0]};
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_HWORD_0;
                 end
                 endcase
     	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
     	  begin
     	     next_wr_hword3_flag	= 1'b0;
     	     next_wvalid	= 1'b0;
     	     next_wlast_o	= 1'b0;
     	     next_wdata_state 	= WR_IDLE ;
     	  end
          else
     	  begin
               	next_wdata_state 	= wdata_state;
     	  end
     
           end

      // WORD_0 
      WR_WORD_0  :
	begin

	    if ((wr_word0_flag && (!wvalid)) || (!wvalid) || (wvalid && wdata_ready_in && (!wlast_o)))
            begin
     	         next_wstrb  		= 4'b1111;
                 case(rd_data_cnt)
                 2'd0:
                 begin
                 next_rd_data_cnt       = 2'd0; 
    	         next_wr_word0_flag	= wr_word0_flag ? !(rdata_valid) : wr_word0_flag; 
     	         next_wdata		= wdata_ff_data[31:0];
     	         next_wvalid		= rdata_valid ? 1'b1 : 1'b0;
     	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_WORD_1)  : wdata_state ;
                 end
                 2'd1:
                 begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
	         next_wdata		= rdata_reg[31:0];
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_WORD_1;
                 end
                 2'd2:
                 begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
	         next_wdata		= rdata_reg[31:0];
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_WORD_1;
                 end
                 endcase
     	  end			
          else if (wvalid && wdata_ready_in && wlast_o)
     	  begin
	     next_wr_word0_flag = 1'b0;
     	     next_wvalid	= 1'b0;
     	     next_wlast_o	= 1'b0;
     	     next_wdata_state 	= WR_IDLE ;
     	  end
          else
     	  begin
               	next_wdata_state 	= wdata_state;
     	  end
     
        end


      // WORD 
      WR_WORD_1  :
	begin
	    if ((wr_word1_flag && (!wvalid)) || (!wvalid) || (wvalid && wdata_ready_in && (!wlast_o)))
               begin
     	         next_wstrb  		= 4'b1111;
                 case(rd_data_cnt)
                 2'd0:
                 begin
                 next_rd_data_cnt       = 2'd0; 
    	         next_wr_word1_flag	= wr_word1_flag ? !(rdata_valid) : wr_word1_flag; 
     	         next_wdata		= wdata_ff_data[63:32];
     	         next_wvalid		= rdata_valid ? 1'b1 : 1'b0;
     	         next_wlast_o		= rdata_valid && wlast ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_valid ? (wlast ? wdata_state : WR_WORD_0)  : wdata_state ;
                 end
                 2'd1:
                 begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
	         next_wdata		= rdata_reg[63:32];
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_WORD_0;
                 end
                 2'd2:
                 begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
	         next_wdata		= rdata_reg[63:32];
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_WORD_0;
                 end
                 endcase
     	     end			
             else if (wvalid && wdata_ready_in && wlast_o)
     	     begin
		next_wr_word1_flag 	= 1'b0;
     	        next_wvalid		= 1'b0;
     	        next_wlast_o		= 1'b0;
     	        next_wdata_state 	= WR_IDLE ;
     	  end
          else
     	  begin
               	next_wdata_state 	= wdata_state;
     	  end
     
        end

     // QWORD_LSB 
      WR_QWORD_LSB  :
	begin

	    if ((!wvalid) || (wvalid && wdata_ready_in && (!wlast_o))) // qword_lsb and qword_msb flag not required since always we keep 4'hF strobe
            begin
     	         next_wstrb  		= 4'b1111;
                 case(rd_data_cnt)
                 2'd0:
                 begin
                 //next_rd_data_cnt       = 2'd0; 
    	         next_wdata		= wdata_ff_data[31:0];
     	         next_wvalid		= rdata_valid ? 1'b1 : 1'b0;
     	         next_wlast_o		= 1'b0;
     	         next_wdata_state 	= rdata_valid ?  WR_QWORD_MSB : wdata_state ;
                 end
                 2'd1:
                 begin
                 //next_rd_data_cnt       = rd_data_cnt -1;  
	         next_wdata		= rdata_reg[31:0];
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= 1'b0;
	         next_wdata_state 	= WR_QWORD_MSB;
                 end
                 2'd2:
                 begin
                 //next_rd_data_cnt       = 2'd0; 
	         next_wdata		= rdata_reg[31:0];
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= 1'b0;
     	         next_wdata_state 	= WR_QWORD_MSB;
                 end
                 endcase
     	  end			
          else
     	  begin
               	next_wdata_state 	= wdata_state;
     	  end
     
        end


      // QWORD_MSB 
      WR_QWORD_MSB  :
	begin
	    if ((!wvalid) || (wvalid && wdata_ready_in && (!wlast_o)))
               begin
     	         next_wstrb  		= 4'b1111;
                 case(rd_data_cnt)
                 //2'd0: 
                 /* not possible since FSM switches from WR_QWORD_LSB
                 to WR_QWORD_MSB only when rdata_valid is asserted for
                 rd_data_cnt=0; Hence it is incremented to rd_data_cnt
                 1 when it comes to this state.*/
                 //begin
                 //next_rd_data_cnt       = 2'd0; 
    	         //next_wdata		= wdata_ff_data[63:32];
     	         //next_wvalid		= 1'b1;
     	         //next_wlast_o		= wlast ? 1'b1 : 1'b0;
     	         //next_wdata_state 	= (wlast ? wdata_state : WR_QWORD_LSB);
                 //end
                 2'd1:
                 begin
                 next_rd_data_cnt       = rdata_valid ? rd_data_cnt : rd_data_cnt -1;  
                 next_rdata_reg         = rdata_valid ? wdata_ff_data : rdata_reg;
	         next_wdata		= rdata_reg[63:32];
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_QWORD_LSB;
                 end
                 2'd2:
                 begin
                 next_rd_data_cnt       = 2'd1; 
                 next_rdata_reg         = wdata_ff_data;
	         next_wdata		= rdata_reg[63:32];
     	         next_wvalid		= 1'b1; 
     	         next_wlast_o		= rdata_reg[AHB_DATA_WIDTH] ? 1'b1 : 1'b0;
     	         next_wdata_state 	= rdata_reg[AHB_DATA_WIDTH] ? wdata_state : WR_QWORD_LSB;
                 end
                 endcase
     	     end			
             else if (wvalid && wdata_ready_in && wlast_o)
     	     begin
		next_wr_word1_flag 	= 1'b0;
     	        next_wvalid		= 1'b0;
     	        next_wlast_o		= 1'b0;
     	        next_wdata_state 	= WR_IDLE ;
     	  end
          else
     	  begin
               	next_wdata_state 	= wdata_state;
     	  end
     
        end

     default:
	begin
	end
endcase
end
end
endgenerate



endmodule





