`timescale 1ns/1ps


module uspif_rxdata_blk (

//INPUT PORTS 
//Global signals
mem_clk,
reset_n,
//From instruction handler
ddr_en,
bits_enabled,
start_read,
csr_trigger,                //Memory status register read is triggered by CSR. So the read data has to be sent to CSR rather than data packer
axi_trigger,                //Memory status register read is triggered by AXI. So the read data has to be sent to AXI
instrn_dlp_en,
no_of_data_bytes,        //It shows the number of read in CSR
//From rcvr_fsm
rxdata_blk_en,
calib_tap_valid,                 //Valid for the dlp data
//From rcvif
rcv_dqfifo_empty,
rcv_dqfifo_almost_empty, 
rcv_dqfifo_almost_full,  
rcv_dqfifo_dout,
//From Rxdata packer
mem_16bit_rdata_ack,
dqs_timeout,
//From Rcv cntrl  
rd_done,          
rcv_dq_fifo_flush_done,
                  
//OUTPUT PORTS    
//To instruction handler
csr_read_end,
//To rcvif
rcv_dqfifo_rd_en_final,
//To read data packer
mem_16bit_rdata,
mem_16bit_rdata_valid,
//To CSR
csr_dqs_non_toggle_err,         //During CSR initiated memory read, after sending dummy cycles, wait for 6 more clocks;
                                //If there is no dqs till this time,error flag asserted //Pulse
axi_dqs_non_toggle_err,         //During AXI initiated memory read, after sending dummy cycles, wait for 6 more clocks;
                                //If there is no dqs till this time,error flag asserted //Pulse
mem_rd_valid,
mem_rd_data_ack,
mem_rd_data, 
//To write engine
rd_clk_stretch

  );

input         mem_clk;
input         reset_n;

input         rxdata_blk_en;
input [1:0]   bits_enabled;
input         start_read;
input         csr_trigger;
input         axi_trigger;
input         instrn_dlp_en;
input [5:0]   no_of_data_bytes;      
input         rcv_dqfifo_empty;
input [15:0]  rcv_dqfifo_dout;
input         rcv_dqfifo_almost_empty;
input         rcv_dqfifo_almost_full;

input         ddr_en;
input         mem_16bit_rdata_ack;
input         rd_done;
input         dqs_timeout;
input         calib_tap_valid;
input         rcv_dq_fifo_flush_done;
input	      mem_rd_data_ack;
output        rcv_dqfifo_rd_en_final;
output        mem_16bit_rdata_valid;
output [15:0] mem_16bit_rdata;
output        csr_dqs_non_toggle_err;
output        axi_dqs_non_toggle_err;
output        mem_rd_valid;
output [31:0] mem_rd_data;     //32bit to CSR 
output        rd_clk_stretch;
output        csr_read_end;

//Internal reg declaration
reg [7:0]   valid_data;
reg         rcv_dqfifo_rd_en_final_d;
reg         start_read_d;
reg         start_read_redge;
reg         ddr_reg;
reg         calib_tap_valid_d;
reg         rxdata_valid;
reg         rxdata_valid_d;
reg [15:0]  mem_rxdata;
reg [15:0]   csr_rd_data;
reg [4:0]   dqfifo_rd_cntr, next_dqfifo_rd_cntr;                //It shows the no of bytes loading to the mem_rd_data(0-63) 
reg         nxt_rcv_dqfifo_rd_en       , rcv_dqfifo_rd_en;
reg [6:0]   csr_byte_cntr, next_csr_byte_cntr;
reg         nxt_cntr_en                , cntr_en;
reg [15:0]  nxt_data_reg0               , data_reg0;
reg         nxt_reg1_rd                , reg1_rd;
reg [1:0]   nxt_data_cnt, data_cnt;
reg         nxt_mem_16bit_rdata_valid            , mem_16bit_rdata_valid;
reg         nxt_csr_pkd_rd_valid           , csr_pkd_rd_valid;             
reg [31:0]  nxt_mem_rd_data , mem_rd_data;  
reg [31:0]  nxt_csr_pkd_rd_data        , csr_pkd_rd_data;  
reg         nxt_csr_hold_valid         , csr_hold_valid;  
reg [31:0]  nxt_csr_hold_data          , csr_hold_data;  
reg         nxt_mem_rd_valid, mem_rd_valid;
//reg         mem_rd_valid_d;
reg         nxt_csr_dqs_non_toggle_err , csr_dqs_non_toggle_err;
reg         nxt_axi_dqs_non_toggle_err , axi_dqs_non_toggle_err;
reg         nxt_csr_read_end               , csr_read_end;          
reg         nxt_rd_from_dqfifo_stp     , rd_from_dqfifo_stp;
reg [15:0]  nxt_mem_16bit_rdata_int           , mem_16bit_rdata_int;
reg         nxt_rxvld_hold             , rxvld_hold;
reg [15:0]  nxt_rxdata_hold            , rxdata_hold;
reg         rd_clk_stretch;

//Internal wire declaration
wire [4:0]  mem_rd_cntr_max;
wire        dqs_err;
wire [15:0] mem_16bit_rdata;
wire        csr_oct_ddr;
wire        csr_reqd_rd_cmplt;
wire [6:0]       csr_rem_bytes;  

assign rcv_dqfifo_rd_en_final = rcv_dqfifo_rd_en & (!rcv_dqfifo_empty);

//Data read from memory for an AXI read request
assign mem_16bit_rdata                 = {mem_16bit_rdata_int[7:0],mem_16bit_rdata_int[15:8]};

//Read data from dq fifo
//assign dqfifo_rdata = rcv_dqfifo_rd_en_d ? rcv_dqfifo_dout[7:0] : 8'h00;

//Indicates max no. of clocks required to collect 16 bit data (AXI triggered) and 8  bit data(CSR triggered) during different pin mode at SDR
//For 1 pin , it will be 16 clocks SDR;(8 for DDR)
//For 2 pin , it will be 8 clocks SDR;(4 for DDR)
//For 4 pins, it will be 4 clocks SDR;(2 for DDR)
//For 8 pins, it will be 2 clocks SDR;(1 for DDR)
//Reading status register of Flash memory is done through CSR to read a single
//byte. So 1st option is required
assign mem_rd_cntr_max = csr_oct_ddr ? 5'h8>> bits_enabled : 5'h10 >> bits_enabled;
//assign mem_rd_cntr_max = csr_trigger ? 5'h8>> bits_enabled : 5'h10 >> bits_enabled; // RSR

assign csr_reqd_rd_cmplt = csr_trigger && (csr_byte_cntr >= (no_of_data_bytes + 6'd1) );  
//assign csr_reqd_rd_cmplt = csr_trigger && mem_rd_valid && ~(|(csr_byte_cntr-1 ^ no_of_data_bytes));  
assign csr_rem_bytes = (no_of_data_bytes + 6'd1) - csr_byte_cntr;  

//assign csr_rd_done = (csr_trigger) ?((csr_read_end && !csr_read_end_d) ? 1'd0 :(rxdata_valid &&  ~(|(csr_byte_cntr ^ no_of_data_bytes))): csr_rd_done; //CHANGE

//assign rxdata_valid_redge = rxdata_valid && !rxdata_valid_d; 
assign axi_oct_ddr = axi_trigger && (&bits_enabled) && ddr_reg;
assign oct_ddr = csr_oct_ddr | axi_oct_ddr;

assign csr_oct_ddr = csr_trigger && (&bits_enabled) && ddr_reg;
//assign mem_rd_valid_redge = mem_rd_valid & !mem_rd_valid_d; 

always @ (posedge mem_clk or negedge reset_n)
if (!reset_n)
begin
dqfifo_rd_cntr            <= 5'h0;
rcv_dqfifo_rd_en         <= 1'h0;
rcv_dqfifo_rd_en_final_d       <= 1'h0;
start_read_d             <= 1'h0;
rxdata_valid_d           <= 1'h0;         
start_read_redge         <= 1'h0;
csr_pkd_rd_valid             <= 1'h0;
mem_rd_data   <= 32'h0;
csr_pkd_rd_data          <= 32'h0;
csr_hold_valid        <= 1'b0;
csr_hold_data         <= 32'b0;
mem_rd_valid  <= 1'b0;
//mem_rd_valid_d<= 1'b0;
csr_dqs_non_toggle_err 	 <= 1'h0;
axi_dqs_non_toggle_err	 <= 1'h0;
calib_tap_valid_d        <= 1'h0;
csr_read_end                 <= 1'h0;
cntr_en                  <= 1'h0;
data_reg0                 <= 16'h0;
reg1_rd                  <= 1'h0;
data_cnt                 <= 2'd0;
mem_16bit_rdata_valid              <= 1'h0;
rd_from_dqfifo_stp       <= 1'h0;
mem_16bit_rdata_int             <= 16'h0;
rd_clk_stretch           <= 1'b0;
rxvld_hold               <= 1'b0;
rxdata_hold              <= 16'b0;
csr_byte_cntr    <= 7'h0;
end
else
begin
dqfifo_rd_cntr            <= next_dqfifo_rd_cntr;
rcv_dqfifo_rd_en_final_d       <= rcv_dqfifo_rd_en_final;
start_read_d             <= start_read;
rxdata_valid_d           <= rxdata_valid;
start_read_redge         <= (start_read && !start_read_d);
calib_tap_valid_d        <= calib_tap_valid;
rcv_dqfifo_rd_en         <= nxt_rcv_dqfifo_rd_en ;
csr_pkd_rd_valid             <= nxt_csr_pkd_rd_valid;
csr_pkd_rd_data          <= nxt_csr_pkd_rd_data;
csr_hold_valid           <= nxt_csr_hold_valid;
csr_hold_data            <= nxt_csr_hold_data;
mem_rd_data   <= nxt_mem_rd_data;   //change
mem_rd_valid  <= nxt_mem_rd_valid;
csr_dqs_non_toggle_err 	 <= nxt_csr_dqs_non_toggle_err;	
axi_dqs_non_toggle_err	 <= nxt_axi_dqs_non_toggle_err;
csr_read_end                 <= nxt_csr_read_end;
cntr_en                  <= nxt_cntr_en;
data_reg0                 <= nxt_data_reg0;
reg1_rd                  <= nxt_reg1_rd;
data_cnt                 <= nxt_data_cnt;
mem_16bit_rdata_valid              <= nxt_mem_16bit_rdata_valid;
rd_from_dqfifo_stp       <= nxt_rd_from_dqfifo_stp;
mem_16bit_rdata_int             <= nxt_mem_16bit_rdata_int;
rd_clk_stretch           <= (rd_done | rcv_dqfifo_empty | rcv_dqfifo_almost_empty) ? 1'b0 : rcv_dqfifo_almost_full ? 1'b1 : rd_clk_stretch;
rxvld_hold               <= nxt_rxvld_hold;
rxdata_hold              <= nxt_rxdata_hold;
csr_byte_cntr    <=  next_csr_byte_cntr;
end


// rxdata_valid is asserted when dq_fifo_rd_cntr is exhausted;
// 1 bytes for CSR; 2 bytes for AXI
//
always@(posedge mem_clk or negedge reset_n)
if(!reset_n)
begin
  rxdata_valid     <= 1'b0;
  mem_rxdata       <= 16'h0;
  csr_rd_data      <= 16'h0;
  ddr_reg          <= 1'b0;
end
else if(rxdata_blk_en && (!rd_done))    //CHECK
begin
  //rxdata_valid     <= oct_ddr ? (~|dqfifo_rd_cntr) : rcv_dqfifo_rd_en_final_d ? (~|dqfifo_rd_cntr) : rxdata_valid; //new
  rxdata_valid     <= csr_trigger && (csr_byte_cntr >= (no_of_data_bytes + 6'd1 )) ? 1'b0 : 
                      (oct_ddr ? (~|dqfifo_rd_cntr) & rcv_dqfifo_rd_en_final : 
                       rcv_dqfifo_rd_en_final_d & (~|dqfifo_rd_cntr));

//mem_rxdata is used only when 1-byte of data is not available in 1clk so has to be packed
  if(ddr_en || ddr_reg) //DDR data receive - simple, dual - takes more than 1 clock to receive 1 byte of data
  begin
    mem_rxdata <=    (rcv_dqfifo_rd_en_final_d & axi_trigger) ? (
                     (bits_enabled ==2'd2) ? {mem_rxdata[7:0],valid_data[7:0]} :
                     (bits_enabled ==2'd1) ? {mem_rxdata[11:0],valid_data[3:0]} :
                     (bits_enabled ==2'd0) ? {mem_rxdata[13:0],valid_data[1:0]} : mem_rxdata) : mem_rxdata;

  csr_rd_data <=      (csr_trigger & rcv_dqfifo_rd_en_final_d) ? 
                      ((bits_enabled ==2'd3) ? {rcv_dqfifo_dout[15:8] ,rcv_dqfifo_dout[7:0]}:
                      (bits_enabled ==2'd2 ) ? {csr_rd_data[7:0],valid_data[7:0]}:
                      (bits_enabled ==2'd1 ) ? {csr_rd_data[11:0],valid_data [3:0]} :
                      (bits_enabled ==2'd0 ) ? {csr_rd_data[13:0],valid_data[1:0]} : csr_rd_data ) : csr_rd_data;
  end//ddr ends
  else
  begin //SDR data receive - simple, dual, quad - takes more than 1 clock to receive 1 byte of data
    mem_rxdata <=    (rcv_dqfifo_rd_en_final_d & axi_trigger) ? (
                     (bits_enabled ==2'd3) ? {mem_rxdata[7:0],rcv_dqfifo_dout[15:8]} :
                     (bits_enabled ==2'd2) ? {mem_rxdata[11:0],rcv_dqfifo_dout[11:8]} :
                     (bits_enabled ==2'd1) ? {mem_rxdata[13:0],rcv_dqfifo_dout[9:8]} :
                     (bits_enabled ==2'd0) ? {mem_rxdata[14:0],rcv_dqfifo_dout[9]} : mem_rxdata) : mem_rxdata;

  csr_rd_data <=      (csr_trigger && rcv_dqfifo_rd_en_final_d) ? 
                      ((bits_enabled ==2'd3) ? {csr_rd_data[7:0],rcv_dqfifo_dout[15:8]} :
                      (bits_enabled ==2'd2) ? {csr_rd_data[11:0],rcv_dqfifo_dout[11:8]} :
                      (bits_enabled ==2'd1) ? {csr_rd_data[13:0],rcv_dqfifo_dout[9:8]} :{csr_rd_data[14:0],rcv_dqfifo_dout[9]}) : csr_rd_data;
  end//SDR ends
  ddr_reg      <=   ddr_reg;
end//rxdatablk ends
else
begin
  rxdata_valid <=  1'b0;
  mem_rxdata   <=  mem_rxdata;
  ddr_reg      <=  rd_done || csr_read_end ? 1'b0 : ddr_en ? 1'b1 : ddr_reg;
  csr_rd_data  <= csr_rd_data;
end


always @ *
begin
if (rcv_dqfifo_rd_en_final_d)
begin
  case (bits_enabled)
    2'b00://1 bit data line
         valid_data ={6'h0,rcv_dqfifo_dout[9],rcv_dqfifo_dout[1]}; //RSR
         //valid_data ={6'h0,rcv_dqfifo_dout[8],rcv_dqfifo_dout[0]};
    2'b01://2 bit data line
         valid_data ={4'h0,rcv_dqfifo_dout[9:8],rcv_dqfifo_dout[1:0]};
    2'b10://4 bit data line
         valid_data ={rcv_dqfifo_dout[11:8],rcv_dqfifo_dout[3:0]};
    //2'b11://8 bit data line
  default:valid_data = 8'h0;
  endcase
end
else 
valid_data = 8'h00;
end


always @*
begin


//This has to be reloaded for every 2 bytes of read data
//star_read given only during normal read operation; two types of read data
//They are normal read and DLP read.
//rxdata_blk_en is asserted only during normal read
if (rd_done | csr_read_end) // rd_done asserted during AXI trigger ; csr_read_end asserted during CSR trigger
  next_dqfifo_rd_cntr = 5'h0;
else if(( (~|dqfifo_rd_cntr) && rcv_dqfifo_rd_en_final_d) | start_read_redge) // ~|dqfifo_rd_cntr is used to reload after every 2 bytes of read data
  next_dqfifo_rd_cntr = (ddr_en || ddr_reg) ? ((mem_rd_cntr_max == 5'h1) ? 5'h0 : ((mem_rd_cntr_max >> 1) - 5'h1))
                         :(mem_rd_cntr_max-5'h1); // octal DDR -> mem_rd_cntr_max will be 1
else if(rxdata_blk_en)
//else if(rxdata_blk_en && (rcv_dqfifo_rd_en_final_d | (rd_from_dqfifo_stp && mem_16bit_rdata_ack)))
  next_dqfifo_rd_cntr = (rcv_dqfifo_rd_en_final_d && (|dqfifo_rd_cntr)) ? dqfifo_rd_cntr-5'h1 : dqfifo_rd_cntr;
else
  next_dqfifo_rd_cntr = dqfifo_rd_cntr;


//DQS non toggle error
  nxt_csr_dqs_non_toggle_err  =  csr_dqs_non_toggle_err ? 1'b0 : (csr_trigger && dqs_timeout);
  nxt_axi_dqs_non_toggle_err  =  axi_dqs_non_toggle_err ? 1'b0 : (axi_trigger && dqs_timeout);

  nxt_csr_read_end                = ((instrn_dlp_en && calib_tap_valid && ~calib_tap_valid_d) || 
                                   csr_reqd_rd_cmplt || csr_dqs_non_toggle_err || axi_dqs_non_toggle_err) ? 1'b1 :1'b0;   

nxt_mem_16bit_rdata_valid = mem_16bit_rdata_valid;
nxt_mem_16bit_rdata_int = mem_16bit_rdata_int;
nxt_rd_from_dqfifo_stp = rd_from_dqfifo_stp;
nxt_rcv_dqfifo_rd_en = rcv_dqfifo_rd_en;
nxt_cntr_en = cntr_en;
nxt_data_reg0        = data_reg0;
nxt_reg1_rd = reg1_rd;

nxt_data_cnt = data_cnt;

nxt_rxdata_hold  = rxdata_hold;
nxt_rxvld_hold   = rxvld_hold;

if (csr_trigger)
begin

next_csr_byte_cntr = rd_done || csr_read_end ? 7'd0 : 
                     (rxdata_valid_d && rxdata_blk_en) ? 
                      ( csr_oct_ddr ? csr_byte_cntr + 7'h2 :  csr_byte_cntr + 7'h1 ): csr_byte_cntr ;

if(csr_oct_ddr)
begin
   nxt_csr_pkd_rd_data = rxdata_valid_d ? ( csr_byte_cntr[1:0]==2'd0 ? {csr_pkd_rd_data[31:16],csr_rd_data[7:0],csr_rd_data[15:8]} : {csr_rd_data[7:0],csr_rd_data[15:8],csr_pkd_rd_data[15:0]} ) : csr_pkd_rd_data;
   nxt_csr_pkd_rd_valid = rcv_dq_fifo_flush_done ||  csr_reqd_rd_cmplt ? 1'b0 : 
                      (csr_trigger && rxdata_valid_d && ( (csr_rem_bytes==2'd1) || (csr_rem_bytes==2'd2)|| (csr_byte_cntr[1:0]==2'd2) )) ? 1'b1 : 1'b0;   //rxdata_valid validates 16 bit of read data always
next_csr_byte_cntr = rd_done || csr_read_end ? 7'd0 : 
                     ((rxdata_valid_d && rxdata_blk_en) ? 
                      csr_byte_cntr + 7'h2 : csr_byte_cntr ) ;
end
else
begin
   nxt_csr_pkd_rd_data = rxdata_valid ? ( csr_byte_cntr[1:0]==2'd0 ? {csr_pkd_rd_data[31:16],csr_rd_data[7:0],csr_rd_data[15:8]} : {csr_rd_data[7:0],csr_rd_data[15:8],csr_pkd_rd_data[15:0]} ) : csr_pkd_rd_data;
   nxt_csr_pkd_rd_valid = rcv_dq_fifo_flush_done ||  csr_reqd_rd_cmplt ? 1'b0 : 
                      (csr_trigger && rxdata_valid && ( (csr_rem_bytes==2'd1) || (csr_rem_bytes==2'd2)|| (csr_byte_cntr[1:0]==2'd2) )) ? 1'b1 : 1'b0;   //rxdata_valid validates 16 bit of read data always
   next_csr_byte_cntr = rd_done || csr_read_end ? 7'd0 : 
                     ((rxdata_valid && rxdata_blk_en) ? 
                      csr_byte_cntr + 7'h2 : csr_byte_cntr) ;
end
end

else
begin
   nxt_csr_pkd_rd_valid = csr_pkd_rd_valid;
   nxt_csr_pkd_rd_data = csr_pkd_rd_data;
   next_csr_byte_cntr = csr_byte_cntr;
end

nxt_csr_hold_valid = (mem_rd_valid && (!mem_rd_data_ack) && csr_pkd_rd_valid) ? 1'b1 : 
      		      (mem_rd_valid && mem_rd_data_ack) ? 1'b0 : csr_hold_valid;

nxt_csr_hold_data = (csr_pkd_rd_valid) ? csr_pkd_rd_data : csr_hold_data; 
//nxt_csr_hold_data = (csr_pkd_rd_valid_d) ? csr_pkd_rd_data : csr_hold_data; 

nxt_mem_rd_valid = (mem_rd_valid & mem_rd_data_ack) ? ((csr_pkd_rd_valid || csr_hold_valid) ? mem_rd_valid : 1'b0) : 
      	           (csr_pkd_rd_valid || csr_hold_valid) ? 1'b1 : mem_rd_valid;

nxt_mem_rd_data =       (csr_pkd_rd_valid & !mem_rd_valid) ? csr_pkd_rd_data :
      		        (csr_hold_valid & mem_rd_valid & mem_rd_data_ack) ? csr_hold_data : mem_rd_data;

//nxt_mem_rd_data =    (monitor_status_reg_rd & )? ((rxdata_valid_d & !csr_pkd_rd_valid_d) ? {mem_rd_data[23:0],csr_rd_data} : mem_rd_data) :
//      			(csr_pkd_rd_valid & !mem_rd_valid) ? csr_pkd_rd_data :
//      		        (csr_hold_valid & !mem_rd_valid) ? csr_hold_data;
//
if(mem_rd_cntr_max == 5'h2 && ddr_reg && ~csr_trigger) //1 clock to collect 16bit data - Octal DDR AXI transfer
begin

   nxt_mem_16bit_rdata_valid  =  (rd_done) ? 1'b0 : 
                                  rxdata_valid  || (|data_cnt) ? 1'b1 : 
                                  (mem_16bit_rdata_valid & mem_16bit_rdata_ack) ? 1'b0 : mem_16bit_rdata_valid;
   
   nxt_mem_16bit_rdata_int            = ((mem_16bit_rdata_valid && mem_16bit_rdata_ack) || (!mem_16bit_rdata_valid)) ?
                                  ( |data_cnt ? {data_reg0[15:8],data_reg0[7:0]} 
                                   : (rxdata_valid ? {rcv_dqfifo_dout[15:8],rcv_dqfifo_dout[7:0]} : mem_16bit_rdata_int)) : mem_16bit_rdata_int ;
   
   nxt_rcv_dqfifo_rd_en        = ((mem_16bit_rdata_valid && (!mem_16bit_rdata_ack))  | rcv_dqfifo_empty | rd_done) ? 1'b0 :
                                 (rxdata_blk_en && (!rcv_dqfifo_empty));
   nxt_data_reg0                = (data_cnt==2'd0 && rxdata_valid && mem_16bit_rdata_valid && (!mem_16bit_rdata_ack)) || 
                                  (data_cnt==2'd1 && rxdata_valid && mem_16bit_rdata_valid && mem_16bit_rdata_ack) || 
                                  (data_cnt==2'd2 && (!rxdata_valid) && mem_16bit_rdata_valid && mem_16bit_rdata_ack) ? 
                                 {rcv_dqfifo_dout[15:8],rcv_dqfifo_dout[7:0]} : data_reg0;
  nxt_data_cnt                 =  rd_done ? 2'd0: (rxdata_valid && mem_16bit_rdata_valid && (!mem_16bit_rdata_ack))?
                                  data_cnt + 2'd1  : ((!rxdata_valid) && mem_16bit_rdata_valid && mem_16bit_rdata_ack && (|data_cnt)) ? data_cnt-2'd1 : data_cnt;
end

else  //
//DDR - quad, dual and simple mode
//SDR - octal, quad, dual and simple
begin
   nxt_mem_16bit_rdata_valid     = rd_done ? 1'b0 : (!csr_trigger && (rxdata_valid | rxvld_hold)) ? 1'b1 :
                                   (mem_16bit_rdata_valid & mem_16bit_rdata_ack)  ? 1'b0 : 
                                    mem_16bit_rdata_valid;

   nxt_mem_16bit_rdata_int       = axi_trigger ? 
                                   ( (rxvld_hold && mem_16bit_rdata_valid && mem_16bit_rdata_ack) ? rxdata_hold : 
                                   ( (rxdata_valid && ((mem_16bit_rdata_valid && mem_16bit_rdata_ack) || (!mem_16bit_rdata_valid)) )  ? mem_rxdata : 
                                   mem_16bit_rdata_int)) : mem_16bit_rdata_int ;

   nxt_rcv_dqfifo_rd_en          = rd_done || rcv_dqfifo_empty || (rcv_dqfifo_rd_en_final && csr_oct_ddr) || 
                                    (rcv_dqfifo_rd_en_final && (mem_16bit_rdata_valid && (!mem_16bit_rdata_ack) && (~|(dqfifo_rd_cntr-5'h1)))) ? 1'b0 :
                                   ((rxdata_blk_en && !rcv_dqfifo_empty && ((mem_16bit_rdata_valid && mem_16bit_rdata_ack) || (!mem_16bit_rdata_valid)) ) ? 1'b1 :rcv_dqfifo_rd_en) ;

   nxt_rxvld_hold                = rd_done ? 1'b0 : (rxdata_valid && mem_16bit_rdata_valid && !mem_16bit_rdata_ack ) ? 1'b1 :
                                   (rxvld_hold && mem_16bit_rdata_ack ) ? 1'b0 : rxvld_hold;
   nxt_rxdata_hold               = (rxdata_valid && mem_16bit_rdata_valid && !mem_16bit_rdata_ack) ? mem_rxdata :
                                   rxdata_hold;
end


end //always ends




endmodule
