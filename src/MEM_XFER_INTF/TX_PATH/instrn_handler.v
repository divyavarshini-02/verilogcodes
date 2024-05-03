//instruction Encoding
//6'd1 -  Command       - 6'h00_0001
//6'd2 -  Address       - 6'h00_0010
//6'd3 -  Dummy         - 6'h00_0011
//6'd4 -  Mode          - 6'h00_0100
//6'd15 - Read          - 6'h00_1111
//6'd16 - Write         - 6'h01_0000
//6'd30 - Jump_on_CS    - 6'h01_1110
//6'd31 - Address DDR   - 6'h01_1111
//6'd32 - Mode DDR      - 6'h10_0000
//6'd56 - Read DDR      - 6'h11_1000
//6'd60 - Write DDR     - 6'h11_1100
//6'd61 - CA            - 6'h11_1101
//6'd62 - Data learn    - 6'h11_1110
//6'd63 - CMD16_DDR     - 6'h11_1111
//6'd00 - Stop          - 6'h00_0000

`timescale 1ns/1ps


module instrn_handler
(
//INPUT PORTS 
//-----------------------------------------------------------------------
//Global signals
//-----------------------------------------------------------------------
mem_clk,                        //Memory clock of frequency 200MHz
reset_n,                        //Active low asynchronous reset
//-----------------------------------------------------------------------
//From Main controller
//-----------------------------------------------------------------------
ahb_start_mem_xfer,             //Request for AXI memory access transfer
addr_mem_xfer,                  //Address for AXI memory access
rw_len_mem_xfer,                //Indicates the number of wdata_valid from AXI4_SLV_CNTRL
csr_start_mem_xfer,             //Request for CSR triggered memory access transfer
xfer_mem_error,                 //Indicates if the incoming transfer has decode error 
seq_reg_0_in,                   //Sequence register0 which holds instruction to access memory
seq_reg_1_in,                   //Sequence register1 which holds instruction to access memory
seq_reg_2_in,                   //Sequence register2 which holds instruction to access memory
seq_reg_3_in,                   //Sequence register3 which holds instruction to access memory
xfer_btype,
xfer_bsize,
no_of_xfer,
auto_initiate,
cont_wr_req,
//-----------------------------------------------------------------------
//From AHB_SLV_CNTRL
//-----------------------------------------------------------------------
slv_mem_wdata_valid,
slv_mem_wstrb,
slv_mem_wdata,                     
slv_mem_wlast,
//-----------------------------------------------------------------------
//From CSR
//-----------------------------------------------------------------------
sequence_change,                //While in XIP mode, instruction handler will be executing same set of programmed sequence
                                //until it sees the sequence_change input.
req_to_cs_dly,                  //Chip select high time
dummy_cyc_HiZ,                  //Lines to be driven with HiZ value are denoted with 1
dummy_cyc_drive,                //Logical value to be driven for the 8 bit dq lines
hyperflash_en,
wr_rd_data_1,			
wr_rd_data_2,
no_of_data_bytes,
xfer_wr_rd,
page_incr_en,                     // if disabled, controller continue the remainging data beyond the page in the same transfer; it does not split and perform the write to subsequent page
mem_page_size,
//-----------------------------------------------------------------------
//From Read Engine      
//-----------------------------------------------------------------------
dlp_read_stop,                  //dlp end detected one clock earlier than usual ending of dlp
rcv_dq_fifo_flush_done,         //End of flush used to move the state from READ to IDLE
rd_done,                        //End of read data transfer from memory
dual_seq_mode_reg,                        //End of read data transfer from memory
dual_seq_mode_ack,                        //End of read data transfer from memory
csr_read_end,                       //End of read status register and also dlp data
//-----------------------------------------------------------------------
//From Write Engine
//-----------------------------------------------------------------------
data_ack,                       //Ack to indicate the current write enable is served and next write enable can be placed
chip_sel,                       //Chip select signal is high - 1'b1
dummy_end,                      //End of dummy instruction driven to the memory
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//OUTPUT PORTS
//-----------------------------------------------------------------------
//To CSR
//-----------------------------------------------------------------------
illegal_strobe,             	//Indicates strobe error in AXI initiated transfers
mem_illegal_instrn,             //Indicates illegal instruction error in AXI initiated transfers
//-----------------------------------------------------------------------
//To Main Controller
//-----------------------------------------------------------------------
ahb_start_mem_xfer_ack,        //Ack to inform AXI request info is registered 
csr_start_mem_xfer_ack,        //Ack to inform CSR request info is registered 
csr_mem_xfer_bsy,              //Indicates memory is processing AXI/CSR initiated transfers
enter_jump_on_cs,              //Jump on CS instruction is being processed
subseq_pg_wr,
deassert_cs,
//From Main controller
wait_subseq_pg_wr,
//-----------------------------------------------------------------------
//To Read Engine
//-----------------------------------------------------------------------
csr_trigger,                   //Memory status register read is triggered by CSR. So the read data has to be sent to CSR rather than data packer
axi_trigger,                   //Memory status register read is triggered by AXI. So the read data has to be sent to AXI
start_read,                    //Trigger when read instruction is about to be executed
read_pins,                     //Pin count used for memory read instruction; 0 -1pin; 1 -2pin; 2 -4pin; 4 - 8pin
instrn_dlp_en,                 //DLP read enabled through instruction
instrn_dlp_pattern,            //DLP pattern for the DLP instruction
rcv_dq_fifo_flush_en,          //Enable to flush dqfifo after every read; Pulse signal
//-----------------------------------------------------------------------
//To Write Engine
//-----------------------------------------------------------------------
write_enable,                  //Write request to write engine; level signal
no_of_pins,                    //Write request control signal - number of pins for the request
valid_operand_bits,            //Write request control signal - number of bits valid for the request
operand_out,                    //Write request control signal - operand value to be sent on the dq line 
onecyc_en_out,                  //Indicates the instruction given to write engine will consume only one
                                // sclk cycle to get transferred to memory 
twocyc_en_out,                  //Indicates the instruction given to write engine will consume 
                                //two sclk cycles to get transfered to memory
multicyc_en_out,                //Indicates the instruction given to write engine will consume 
                                //more than two sclk cycles to get transfered to memory
stop_instrn_out,                    //Indicates stop instruction is given to write engine
ddr_instrn_en,                  //Read Engine also use this input
                                //Indicates ddr_instruction is being exectued
stall_wr_out,                       //To stop sclk inbetween write to memory
//-----------------------------------------------------------------------
//To AHB_SLV_CNTRL
//-----------------------------------------------------------------------
slv_mem_wdata_ack,             //ack to indicate wdata from AXI is read and new data is expected
slv_mem_wdata_err             //Error in the write data transfer
);

/////////////////////////////////////////////////////////////////////////
//PARAMETER DECLARATION FOR FSM
/////////////////////////////////////////////////////////////////////////
parameter IDLE = 2'b00;
parameter READ = 2'b01;
parameter WRITE = 2'b10;

//parameter definition for signal width
parameter AHB_DATA_WIDTH     = 32;
parameter AHB_ADDR_WIDTH     = 32;
parameter WRAP_LEN_WIDTH         = 5; 
                                   

/////////////////////////////////////////////////////////////////////////
//Port declaration
/////////////////////////////////////////////////////////////////////////
//Input Declaration
//Global signals
   input             mem_clk;
   input             reset_n;
//From Main controller
   input                            ahb_start_mem_xfer;
   input [AHB_ADDR_WIDTH -1:0]  addr_mem_xfer;
   input [4:0]      rw_len_mem_xfer; //9/10/11 bits according to axi data bus32bit/64bit/128 
   input                            csr_start_mem_xfer;
   input [31:0]                     seq_reg_0_in;
   input [31:0]                     seq_reg_1_in;
   input [31:0]                     seq_reg_2_in;
   input [31:0]                     seq_reg_3_in;
   input                            xfer_mem_error;
   input  [1:0]                     xfer_btype;
   input  [2:0]                     xfer_bsize;
   input                            auto_initiate;
  input                             cont_wr_req;
//From AHB_SLV_CNTRL
  input                             slv_mem_wdata_valid;
  input [3:0]                       slv_mem_wstrb;
  input [31:0]                      slv_mem_wdata;
  input                             slv_mem_wlast;
//From CSR
  input [7:0]                       dummy_cyc_HiZ;
  input [7:0]                       dummy_cyc_drive;
  input                             sequence_change;
  input [4:0]                       req_to_cs_dly;
  input                             page_incr_en;
  input [3:0] mem_page_size;

  input				    hyperflash_en;
  input [31:0]                      wr_rd_data_1; 			
  input [31:0]                      wr_rd_data_2;

  input	[5:0]			    no_of_data_bytes;
  input	[1:0]			    no_of_xfer;
  input				    xfer_wr_rd;
//From Read Engine
   input                            dlp_read_stop;
   input                            rcv_dq_fifo_flush_done;
   input                            rd_done;
   input                            csr_read_end;
//From Write Engine
   input                            data_ack;
   input                            chip_sel;
   input                            dummy_end;
//Output Declaration
//To CSR
   output                           illegal_strobe;
   output                           mem_illegal_instrn;
//To Main Controller
   output                           csr_start_mem_xfer_ack;
   output                           csr_mem_xfer_bsy;
   output                           enter_jump_on_cs;
   output			    subseq_pg_wr;
   output			    dual_seq_mode_ack;
   output                           deassert_cs;
//From Main controller
   input 			    wait_subseq_pg_wr;
   input 			    dual_seq_mode_reg;
//To Read Engine
   output                           ahb_start_mem_xfer_ack;
   output                           csr_trigger;
   output                           axi_trigger;
   output                           start_read;
   output [1:0]                     read_pins;
   output                           instrn_dlp_en;
   output [7:0]                     instrn_dlp_pattern;
   output                           rcv_dq_fifo_flush_en;
//To Write Engine
   output                           onecyc_en_out;   
   output                           twocyc_en_out;   
   output                           multicyc_en_out; 
   output                           ddr_instrn_en;
   output                           stop_instrn_out;
   output                           write_enable;
   output [1:0]                     no_of_pins;
   output [6:0]                     valid_operand_bits;//bit 6   - says if the instruction is dummy or other instruction
                                                       //bit 5:0 - To represent max of 32 bit data; Also max no.of dummy cycle count - 'h3f
   output [47:0]                    operand_out;
   output                           stall_wr_out;
//To AXI4_SLV_CNTRL
   output                          slv_mem_wdata_ack;
   output [1:0]                    slv_mem_wdata_err;

/////////////////////////////////////////////////////////////////////////////////////////////////
//Internal wire declaration
/////////////////////////////////////////////////////////////////////////////////////////////////
wire         axi_txfr_lat_fedge;
wire         csr_txfr_lat_fedge;
wire         fsm_trig_redge;
wire [5:0]   axi_addr_valid_operand_bits;
wire         seq_fetch;
wire         onecyc_en_int,twocyc_en_int,multicyc_en_int;
wire          dummy_onecyc_en, dummy_twocyc_en, dummy_multicyc_en;

wire         ddr_instrn;
//wire [5:0]   exp_ddr_data_bits;
wire         mode_instrn;
wire         write_instrn;
wire         read_instrn;
wire         enter_jump_on_cs;
wire         last_wr;
wire         deassert_cs;
wire         axi_txfr_req;
wire         csr_txfr_req;
wire         txfr_req;
wire         seq_cntr_ld_en;
wire [2:0]   seq_cntr_ld_value;
wire [47:0]  operand_out;
wire         fsm_trigger;
wire         stop_instrn;
wire         sdr_read_instrn;
wire         ddr_read_instrn;
wire         cmd_instrn;
wire         ca_instrn;
wire         sdr_addr_instrn;
wire         addr_instrn;
wire         sdr_write_instrn; 
wire         ddr_write_instrn;
wire         sdr_mode8_instrn; 
wire         cmd_ddr_instrn; 
wire         dummy_instrn;
wire         dlp_instrn;
wire         addr_ddr_instrn; 
wire         jump_on_cs_instrn;
wire [7:0]   addr_shift_value;
wire [31:0]  addr_operand;
wire seq_cntr_clr;
wire         legal_instrn;
wire [3:0]   wdata_strobe;
wire [4:0]   axi32_shift_val;
reg [31:0]  axi_first_operand;
wire [31:0]  axi_valid_data;
wire         expect_write_instrn;
wire         write_instrn_in_lsb_seq;
wire         write_instrn_in_msb_seq;
wire         expect_rd_instrn;
wire         rd_in_lsb_seq;
wire         rd_in_msb_seq;
wire [31:0]  axi_rd_addr_to_send;
wire         xip_mode;
wire         xip_drive_bit;
wire         start_mem_xfer_ack;
wire         txfr_wr_trigger;
wire         strobe_all_ones;
wire [5:0]   no_of_wr_clks;
wire         unalign_data_chk_ddr;
wire [2:0]   wr_pins_chk;

reg [5:0]    valid_csr_bits;
wire [5:0]   csr_wr_valid_operand_bits;		
wire [5:0]   csr_wr_up_cntr;	
wire [5:0]   csr_wr_dword_cnt_max;
wire	     csr_trig_redge;
reg [31:0]  valid_csr_data;

wire [47:0] valid_ca_operand;
wire [39:0] csr_hyperaddr;
wire [39:0] valid_csr_hyperaddr;
wire [1:0] pins_chk;

wire wrap_has_split;
wire wrap_push;
wire wrap_push_fedge;
wire wrap_pop;
wire wrap_data_ready;
wire wrap_empty;
wire [31:0] slv_mem_wdata_wrap;
wire cont_wr_ack;	//Continuous write transfer ack
wire dual_seq_mode_ack;
wire [47:0] page_addr;
wire page_addr_enable;

/////////////////////////////////////////////////////////////////////////////////////////////////
//Internal register declaration
/////////////////////////////////////////////////////////////////////////////////////////////////
reg [WRAP_LEN_WIDTH -1 :0]      nxt_axi_rw_len,   axi_rw_len;
reg [AHB_ADDR_WIDTH-1:0]  nxt_axi_addr,     axi_addr;
reg [5 :0]     nxt_csr_or_wrap_wr_nosplit_dword_cntr, csr_or_wrap_wr_nosplit_dword_cntr;  //holds max value of 256/512/1024 based on bus width 32/64/128
reg [WRAP_LEN_WIDTH -1 :0]     nxt_initial_wrap_data_cntr, initial_wrap_data_cntr;  
reg [31:0]  nxt_csr_addr,                        csr_addr;
reg [2:0]   nxt_seq_cntr,                        seq_cntr;
reg [5:0]   nxt_decoded_instrn,                  decoded_instrn;
reg [1:0]   nxt_decoded_pins,                    decoded_pins;
reg [7:0]   nxt_decoded_operand,                 decoded_operand;
reg [47:0]  nxt_ca_operand,                      ca_operand;
reg [15:0]  nxt_decoded_cmd16_operand,           decoded_cmd16_operand;
reg         nxt_write_enable,                    write_enable;
reg nxt_first_data_ack , first_data_ack;
reg         onecyc_en_out,twocyc_en_out,multicyc_en_out; 
reg         nxt_onecyc_en_out,nxt_twocyc_en_out,nxt_multicyc_en_out; 
reg [47:0]  nxt_operand,                         operand;
reg [6:0]   nxt_valid_operand_bits,              valid_operand_bits;
reg [1:0]   nxt_no_of_pins,                      no_of_pins;
reg         nxt_ddr_instrn_en,                   ddr_instrn_en;
reg         nxt_start_read,                      start_read;
reg [1:0]   nxt_read_pins,                       read_pins;
reg         nxt_instrn_dlp_en,                   instrn_dlp_en;
reg [7:0]   nxt_instrn_dlp_pattern,              instrn_dlp_pattern;
reg         nxt_wdata_progress,                  wdata_progress;
reg [1:0]   nxt_state,                           state;
reg         nxt_rcv_dq_fifo_flush_en,            rcv_dq_fifo_flush_en;
reg [4:0]   nxt_rcv_dq_fifo_flush_chk,           rcv_dq_fifo_flush_chk;
reg         nxt_stall_wr,                        stall_wr;
reg         nxt_mem_xfer_start,                  mem_xfer_start;
reg [1:0]   nxt_axi_burst_type,                  axi_burst_type;
reg [2:0]   nxt_axi_burst_size,                  axi_burst_size;
reg         nxt_mem_illegal_instrn,              mem_illegal_instrn;
//reg         nxt_csr_illegal_instrn,              csr_illegal_instrn;
reg [31:0]  nxt_seq_reg_0,                       seq_reg_0;
reg [31:0]  nxt_seq_reg_1,                       seq_reg_1;
reg [31:0]  nxt_seq_reg_2,                       seq_reg_2;
reg [31:0]  nxt_seq_reg_3,                       seq_reg_3;
reg         nxt_write_instrn_exist,              write_instrn_exist;
reg         nxt_rd_instrn_exist,                 rd_instrn_exist;
reg         nxt_axi_trigger,                     axi_trigger;
reg         nxt_csr_trigger,                     csr_trigger;
reg         nxt_ahb_start_mem_xfer_ack,          ahb_start_mem_xfer_ack;
reg         axi_start_mem_xfer_ack_d;
reg         nxt_csr_start_mem_xfer_ack,          csr_start_mem_xfer_ack;
reg         nxt_stop_in_progress,                stop_in_progress;
reg         nxt_axi_txfr_lat,                    axi_txfr_lat;
reg         nxt_csr_txfr_lat,                    csr_txfr_lat, csr_txfr_lat_d;
reg [4:0]   nxt_req_to_cs_dly_cnt,               req_to_cs_dly_cnt;
reg [2:0]   nxt_jump_to_instrn,                  jump_to_instrn;
reg         nxt_jump_on_cs_high,                 jump_on_cs_high;
reg         nxt_axi_mem_xfer_bsy,                axi_mem_xfer_bsy;
reg         nxt_csr_mem_xfer_bsy,                csr_mem_xfer_bsy;
reg         nxt_addr_instrn_d,                   addr_instrn_d;
reg [31:0]  nxt_valid_addr_value,                valid_addr_value;
reg         nxt_illegal_strobe,                  illegal_strobe;
reg         nxt_first_wvalid,                    first_wvalid;
reg	    nxt_slv_mem_wlast_stall,		 slv_mem_wlast_stall;
reg	    nxt_wrap_data_wait,			 wrap_data_wait;


reg [15:0]                   following_seq;
reg [15:0]                   cmd16_operand;
reg [5:0]                    valid_data_bits;
reg [31:0]                   axi_wr_addr_to_send;
reg [31:0]                   axi_first_operand_calc;

reg [WRAP_LEN_WIDTH -1:0]    rw_txfr_length;
reg                          axi_txfr_lat_d;
reg                          slv_mem_wdata_valid_d;
reg                          jump_on_cs_instrn_d;
reg                          dlp_rd_stp_d;
reg                          fsm_trig_d;
reg [5:0]		     nxt_csr_data_bytes,   csr_data_bytes;	
reg			     csr_trig_d;
reg			     nxt_ca_reg, ca_reg;
reg [31:0]                    nxt_addr_incr, addr_incr;
reg		    	     nxt_subseq_pg_wr_reg, subseq_pg_wr_reg;
reg			     wrap_push_d;
//reg [3:0]		     nxt_cont_wr_strobe, cont_wr_strobe;
reg [1:0]		     nxt_wrap_no_of_xfer, wrap_no_of_xfer;
reg [1:0]		     nxt_write_pins , write_pins;
reg			     page_incr_en_reg;
reg cont_wr_reg, nxt_cont_wr_reg;
reg dual_seq_mode_reg_int, nxt_dual_seq_mode_reg_int;
/////////////////////////////////////////////////////////////////////////////////////
//Functional description starts
/////////////////////////////////////////////////////////////////////////////////////
assign stall_wr_out = stall_wr;
//assign stall_wr_out = stall_wr || (write_enable && (!slv_mem_wdata_valid) && (state==WRITE));
//operand value during write
//Sending operand to the write engine with LSbyte first 
assign operand_out = {operand[7:0],
                      operand[15:8],
                      operand[23:16],
                      operand[31:24],
		      operand[39:32],
		      operand[47:40]};


//INSTRUCTION DECODING
assign cmd_instrn                 = (~|decoded_instrn[5:1] && decoded_instrn[0]); //6'd1;
assign sdr_addr_instrn            = (~|decoded_instrn[5:2] && decoded_instrn[1] && ~decoded_instrn[0]); //6'd2 address
assign dummy_instrn               = (~|decoded_instrn[5:2] && (&decoded_instrn[1:0]) );//6'd3
assign sdr_mode8_instrn           = (~|decoded_instrn[5:3] && decoded_instrn[2] && ~|decoded_instrn[1:0]);//6'd4
assign sdr_read_instrn            = (~|decoded_instrn[5:4] && &decoded_instrn[3:0]); //6'd15 
assign sdr_write_instrn           = (~decoded_instrn[5] && decoded_instrn[4]&& ~|decoded_instrn[3:0]); //6'd16
assign jump_on_cs_instrn          = (~decoded_instrn[5] && (&decoded_instrn[4:1]) && ~decoded_instrn[0]);//6'd30
assign addr_ddr_instrn            = (~decoded_instrn[5] && (&decoded_instrn[4:0])) ;//6'd31
assign cmd_ddr_instrn             = (decoded_instrn[5] && ~|decoded_instrn[4:0]);//6'd32
assign ddr_read_instrn            = (&decoded_instrn[5:3] && ~|decoded_instrn[2:0]); //6'd56
assign ddr_write_instrn           = (&decoded_instrn[5:2] && ~|decoded_instrn[1:0]);//6'd60
assign ca_instrn                  = (&decoded_instrn[5:2] && ~decoded_instrn[1] && decoded_instrn[0]);//6'd61
assign dlp_instrn                 = (&decoded_instrn[5:1] && ~decoded_instrn[0]);//6'd62
assign cmd16_instrn               = &decoded_instrn || (~|decoded_instrn[5:4] && decoded_instrn[3] && ~|decoded_instrn[2:0]);//6'd63 for DDR and 6'd8 for SDR
assign stop_instrn                = ~|decoded_instrn; 

//Derivation from instruction
assign mode_instrn     = sdr_mode8_instrn | cmd_ddr_instrn;
assign write_instrn    = sdr_write_instrn | ddr_write_instrn;
assign read_instrn     = sdr_read_instrn | ddr_read_instrn | dlp_instrn; 
assign addr_instrn     = sdr_addr_instrn || addr_ddr_instrn;
assign legal_instrn    = cmd_instrn | addr_instrn | write_instrn | read_instrn | dummy_instrn | jump_on_cs_instrn | ca_instrn | mode_instrn | dlp_instrn | cmd16_instrn | stop_instrn ;
assign ddr_instrn      = addr_ddr_instrn | cmd_ddr_instrn | ddr_write_instrn | ddr_read_instrn | dlp_instrn | ca_instrn | (cmd16_instrn & decoded_operand[0]) | (cmd_instrn & hyperflash_en);

assign stop_instrn_out =  stop_in_progress || (rd_done & jump_on_cs_instrn);

//This logic denotes the current transfer to write engine consumes one mem_clk
//or 2 mem_clk or more than 2 mem_clk cycles
assign onecyc_en_int    = (nxt_ddr_instrn_en ? 
                          (nxt_valid_operand_bits == (3'd2<< decoded_pins))  : (nxt_valid_operand_bits == (3'd1<< decoded_pins)) ); 
                      //pins == 0, valid_operand_bits ==1; pins ==1, valid_operand_bits ==2; 
                      //pins == 2, valid_operand_bits ==4; pins ==3, valid_operand_bits ==8;
                      
assign twocyc_en_int    = nxt_ddr_instrn_en ? (nxt_valid_operand_bits == (3'd4<< decoded_pins)) :(nxt_valid_operand_bits == (3'd2<< decoded_pins)); 
                      //pins == 0, valid_operand_bits ==2; pins ==1, valid_operand_bits ==4;
                      //pins == 2, valid_operand_bits ==8; pins ==3, valid_operand_bits ==16;

assign multicyc_en_int  = nxt_ddr_instrn_en ? (nxt_valid_operand_bits > (3'd4<< decoded_pins)) : (nxt_valid_operand_bits > (3'd2<< decoded_pins)) ;
                      //pins == 0 && valid_operand_bits >2;pins == 1 && valid_operand_bits >4
                      //pins == 2 && valid_operand_bits >8);pins==3 && valid_operand_bits >16

assign dummy_onecyc_en       = dummy_end ? 1'b0 : dummy_instrn ? (decoded_operand[0] && ~|decoded_operand[5:1]) :  1'b0;
assign dummy_twocyc_en       = dummy_end ? 1'b0 : dummy_instrn ? (decoded_operand[1] && ~|decoded_operand[5:2] && ~decoded_operand[0]) : 1'b0;
assign dummy_multicyc_en     = dummy_end ? 1'b0 : dummy_instrn ? (decoded_operand[5:0] > 6'h2) : 1'b0;

assign axi_txfr_lat_fedge =(!axi_txfr_lat) && axi_txfr_lat_d;
assign csr_txfr_lat_fedge =(!csr_txfr_lat) && csr_txfr_lat_d;

//Handling operand value for address instruction
//For write, address from Main controller is modified w.r.t strobe for aligned address transfer
//else address sent to memory as received from Main Controller.
//For read, if address is unaligned, it is made as aligned to 2bytes and sent to memory always.

always@* 
begin
  axi_wr_addr_to_send = 32'h0;
  if(( ( (axi_addr[1:0]==2'd0 && wdata_strobe[1:0]==2'b00 && (!cont_wr_reg)) || (axi_addr[1]) ) /*&& (!ca_reg)*/ ) & (axi_burst_type!=2'b10) )
  //if( ( (axi_addr[1:0]==2'd0 && (axi_burst_size==3'd0 || axi_burst_size==3'd1) && (wdata_strobe[1:0]==2'b00) && (!cont_wr_reg)) || (axi_addr[1]) ) && (!ca_reg) )
  begin
        axi_wr_addr_to_send =  {axi_addr[31:2],2'd2};
  end
  else //for SDR and DDR, unaligned AXI address is converted to previous 2 byte even address to the memory
  begin
      axi_wr_addr_to_send = {axi_addr[31:1], 1'b0};
  end
end

assign addr_shift_value     = 8'd32 - decoded_operand;//operand shows valid address bits; input from seq engine
assign axi_rd_addr_to_send          = {axi_addr[31:1],1'b0};
//addr instrn is used to transfer memory wr/rd address for AXI4_MEM initiated mem transfers
//addr instrn is used to transfer 32bit data for AXI4_CSR initiated mem transfers
//since max operand width using any instruction is only 8 bit and we require
//32 bit operand to be sent for some memory access, we opt to use address
//command to transfer the operand and not the address. This is purely for CSR
//initated transfers
assign addr_operand         = csr_trigger ? csr_addr << addr_shift_value :
                              write_instrn_exist ? axi_wr_addr_to_send<<addr_shift_value :
                              rd_instrn_exist    ? axi_rd_addr_to_send<<addr_shift_value : axi_addr<< addr_shift_value;

///////////////////////////////////////////////////////////////////////////////////////////////////
////Sequence Fetching Logic
///////////////////////////////////////////////////////////////////////////////////////////////////
//To fetch instructions from sequence registers
assign seq_fetch        = (start_mem_xfer_ack & !(|state)) | fsm_trig_redge |  (data_ack && !wdata_progress);

////Enable to clear the counter value
assign seq_cntr_clr = (jump_on_cs_instrn && sequence_change && ~|state && !seq_fetch);
//
////Enable and load value to the sequence counter - used only during JUMP_ON_CS instruction 
assign seq_cntr_ld_en    = (jump_on_cs_instrn & !seq_fetch); // || (jump_on_cs_high && rd_done && !sequence_change));
assign seq_cntr_ld_value = jump_to_instrn;


//Check to detect if read instruction is present in the current sequence programmed in sequence engine
assign expect_rd_instrn                = (!xfer_wr_rd & ahb_start_mem_xfer_ack & !auto_initiate); //rd_in_lsb_seq || rd_in_msb_seq;




//////////////////////////////////////////////////////////////////
//Request generation, from AXI/CSR request input, for triggering the FSM
//////////////////////////////////////////////////////////////////
//It is expected that start_mem_xfer will go high other than initial assertion
//for continuous read purpose
//AXI transfers should not be responded back while csr is in progress. So
//*_bsy signal is checked wherever required to stop the trigger of either transfer while other is in progress
assign axi_txfr_req       = ahb_start_mem_xfer && (~xfer_mem_error) && !axi_mem_xfer_bsy && !csr_mem_xfer_bsy;
assign csr_txfr_req       = csr_start_mem_xfer && !csr_mem_xfer_bsy && !axi_mem_xfer_bsy;
assign txfr_req           = axi_txfr_req || csr_txfr_req;
assign fsm_trigger        = axi_trigger || csr_trigger;
assign fsm_trig_redge     = fsm_trigger && !fsm_trig_d;
assign xip_mode           = dummy_instrn && |decoded_operand[7:6];
assign xip_drive_bit      = decoded_operand[7] ? 1'b0 : decoded_operand[6] ? 1'b1 : 1'b0 ;
assign enter_jump_on_cs   = jump_on_cs_high;
assign start_mem_xfer_ack = ahb_start_mem_xfer_ack  | csr_start_mem_xfer_ack;
assign csr_trig_redge     = csr_trigger && !csr_trig_d;
assign page_addr          = xfer_wr_rd ? {32'd0,axi_wr_addr_to_send[23:16],axi_wr_addr_to_send[31:24]} :
                            {32'd0,axi_rd_addr_to_send[23:16],axi_rd_addr_to_send[31:24]};  
assign page_addr_enable   = addr_instrn & decoded_operand[7];

//////////////////////////////////////////////
////Memory write related signals             
//////////////////////////////////////////////
assign slv_mem_wdata_valid_redge = slv_mem_wdata_valid && !slv_mem_wdata_valid_d;

assign slv_mem_wdata_ack     = slv_mem_wdata_valid ? ((mem_illegal_instrn | illegal_strobe | xfer_mem_error)? 1'b1  
                                                                         :((write_instrn |wdata_progress) && data_ack && !slv_mem_wlast_stall) | wrap_push)
                                                   : 1'b0;
assign slv_mem_wdata_err     = xfer_mem_error ? 2'b11 : (mem_illegal_instrn | illegal_strobe) ? 2'b10 : 2'b00;


reg subseq_pg_wr, nxt_subseq_pg_wr;

always @ *
begin
case(mem_page_size)
4'd6:
  nxt_subseq_pg_wr  = wait_subseq_pg_wr & page_incr_en_reg  & (!chip_sel) & ((&addr_incr[5:2]) | ((&addr_incr[5:3]) & (&addr_incr[1:0]) )) &   !xfer_mem_error; 		//subseq_pg_wr asserted anywhere from address  3B to 3F ; addr_incr[3:0] will hold 3, 7, B, F
4'd7:
  nxt_subseq_pg_wr  = wait_subseq_pg_wr & page_incr_en_reg  & (!chip_sel) & ((&addr_incr[6:2]) | ((&addr_incr[6:3]) & (&addr_incr[1:0]) )) &   !xfer_mem_error; 		//subseq_pg_wr asserted anywhere from address  7B to 7F ; addr_incr[3:0] will hold 3, 7, B, F
4'd8:
 //nxt_subseq_pg_wr  = page_incr_en_reg & (!chip_sel) & (((&addr_incr[7:3]) & (&addr_incr[1:0]) )) &   !xfer_mem_error; //subseq_pg_wr asserted anywhere from address  FB to FF ; addr_incr[3:0] will hold 3, 7, B, F		
 nxt_subseq_pg_wr  = wait_subseq_pg_wr & page_incr_en_reg & (!chip_sel) & ((&addr_incr[7:2]) | ((&addr_incr[7:3]) & (&addr_incr[1:0]) )) &   !xfer_mem_error; //subseq_pg_wr asserted anywhere from address  FB to FF ; addr_incr[3:0] will hold 3, 7, B, F		
 //nxt_subseq_pg_wr  = page_incr_en_reg & ((&addr_incr[7:2] & slv_mem_wdata_ack) | ((&addr_incr[7:3]) & (&addr_incr[1:0]) & slv_mem_wdata_ack & !slv_mem_wlast )) & !subseq_pg_wr_reg &  !xfer_mem_error; //subseq_pg_wr asserted anywhere from address  FB to FF ; addr_incr[3:0] will hold 3, 7, B, F		
4'd9:
  nxt_subseq_pg_wr  = wait_subseq_pg_wr & page_incr_en_reg  & (!chip_sel) & ((&addr_incr[8:2] ) | ((&addr_incr[8:3]) & (&addr_incr[1:0]) )) &  !xfer_mem_error; 	
4'd10:
  nxt_subseq_pg_wr  = wait_subseq_pg_wr & page_incr_en_reg  & (!chip_sel) & ((&addr_incr[9:2] ) | ((&addr_incr[9:3]) & (&addr_incr[1:0]) )) &  !xfer_mem_error; 	
4'd11:
  nxt_subseq_pg_wr  = wait_subseq_pg_wr & page_incr_en_reg & (!chip_sel)  & ((&addr_incr[10:2] ) | ((&addr_incr[10:3]) & (&addr_incr[1:0]) ))  & !xfer_mem_error; 	
4'd12:
  nxt_subseq_pg_wr  = wait_subseq_pg_wr & page_incr_en_reg  & (!chip_sel) & ((&addr_incr[11:2] ) | ((&addr_incr[11:3]) & (&addr_incr[1:0]) ))  & !xfer_mem_error; 	
default : nxt_subseq_pg_wr = subseq_pg_wr;
endcase
end
//Valid operand bits during write instruction
//possible valid data bits for 1st and last transfer are as follows
//For 1st transfer : 32,24,16 and 8 based on axi addr 0, 1, 2, 3 respectively
//                 : 32, 24,16,and 8 based on axi_aligned address and strobe value F; 7,E; 3,6,C; 2,4,8
//For last transfer : 32,24,16 and 8 based on strobe value - 1, 3, 7, and F                 
//Among the 4 value, 24 and 8 face data misalignment w.r.t dual clock edge.

//In DDR, for example if data is 8 bit and no of pins to be used is 8 pin,
//then for the 1st edge we have 8 bit data but for the second edge we don't
//have a valid data. So place FF for the second edge ; Also make valid data
//bits as 16 instead of 8
//Also if the valid bits is 24 and no.of pins to be used is 8 pins, then for
//the 2nd clock, we don't have data for one edge. So place FF for the 2nd
//clock 2nd edge; Also we have to make the valid data bits as 32 instead 24

//For SDR data count aligned with clock edge always

//assign axi_wr_valid_operand_bits = (unalign_data_chk_ddr && valid_data_bits == 6'd8) ? 6'd16 : (unalign_data_chk_ddr && valid_data_bits == 6'd24) ? 6'd32 : valid_data_bits ;
//
assign csr_wr_valid_operand_bits = (unalign_data_chk_ddr && valid_csr_bits == 6'd8) ? 6'd16 : (unalign_data_chk_ddr && valid_csr_bits == 6'd24) ? 6'd32 : valid_csr_bits ;

assign axi_addr_valid_operand_bits = (unalign_data_chk_ddr && decoded_operand[5:0] == 6'd8) ? 6'd16 : (unalign_data_chk_ddr && decoded_operand[5:0] == 6'd24) ? 6'd32 : decoded_operand[5:0] ; 
 
assign unalign_data_chk_ddr      = ((ddr_instrn | ddr_instrn_en) && (&write_pins)) ? 1'b1 : 1'b0; //octal DDR check

//assign strobe_all_ones  = &wdata_strobe;


//// To de-assert the chip select ; cont_wr_req will not be asserted if it beyond the current page

assign last_wr = axi_burst_type == 2'b01 ? ( (slv_mem_wlast && slv_mem_wdata_valid && slv_mem_wdata_ack) ||
                                            (subseq_pg_wr & stall_wr & slv_mem_wdata_valid & slv_mem_wdata_ack) || (subseq_pg_wr & (!stall_wr)) )   :
                 axi_burst_type == 2'b10 ? wrap_has_split ? (wrap_empty && slv_mem_wlast_stall && data_ack) : 
                       (~|csr_or_wrap_wr_nosplit_dword_cntr) &&  slv_mem_wdata_valid && slv_mem_wdata_ack : 1'b0;

//assign last_wr = axi_burst_type == 2'b01 ? ((slv_mem_wlast && slv_mem_wdata_valid && slv_mem_wdata_ack) | ((subseq_pg_wr || subseq_pg_wr_reg) & slv_mem_wdata_ack))   :
//                 axi_burst_type == 2'b10 ? wrap_has_split ? (wrap_empty && slv_mem_wlast_stall && data_ack) : 
//                       (~|csr_or_wrap_wr_nosplit_dword_cntr) &&  slv_mem_wdata_valid && slv_mem_wdata_ack : 1'b0;
//
assign cont_wr_ack = last_wr & ahb_start_mem_xfer & cont_wr_req; 
assign deassert_cs = ahb_start_mem_xfer & cont_wr_req ? 1'b0 : last_wr;


//Check to detect if write instruction is present in the current sequence programmed in sequence engine
assign expect_write_instrn      = (xfer_wr_rd & ahb_start_mem_xfer_ack & !auto_initiate);
assign txfr_wr_trigger          = expect_write_instrn ||  write_instrn_exist;
assign wdata_strobe         = slv_mem_wstrb ;

assign axi_valid_data       = (slv_mem_wlast_stall & data_ack) ? slv_mem_wdata_wrap : axi_first_operand;
//assign axi_valid_data       = (slv_mem_wlast_stall & data_ack) ? slv_mem_wdata_wrap : first_wvalid  ? axi_first_operand : slv_mem_wdata;



assign csr_wr_dword_cnt_max = csr_data_bytes >>2;	
assign csr_wr_up_cntr = csr_wr_dword_cnt_max - csr_or_wrap_wr_nosplit_dword_cntr[5:0];

assign valid_ca_operand = {ca_operand[7:0],ca_operand[15:8],ca_operand[23:16],
			   ca_operand[31:24],ca_operand[39:32],ca_operand[47:40]};
assign csr_hyperaddr = {2'd0,wr_rd_data_1[24:3],13'd0,wr_rd_data_1[2:0]};
assign valid_csr_hyperaddr = {csr_hyperaddr[7:0],csr_hyperaddr[15:8],csr_hyperaddr[23:16],
			   csr_hyperaddr[31:24],csr_hyperaddr[39:32]};

assign dual_seq_mode_ack = seq_fetch & stop_instrn & dual_seq_mode_reg_int & !auto_initiate;
////////////////////////////////////////////////////////
///////////sequence fetch/////////////////////////////
////////////////////////////////////////////////////////
//This logic registers the next instruction to be executed from sequence
//engine instructions.
always@*
begin
case(seq_cntr)
  3'b000 : begin
           following_seq     = seq_reg_0[15:0];
           cmd16_operand     = &seq_reg_0[15:10] ? seq_reg_0[31:16] : 16'h0; // CMD16 check
           end
  3'b001 : begin 
           following_seq     = &seq_reg_0[15:10] ? seq_reg_1[15:0]  : seq_reg_0[31:16]; // if [15:0] CMD16 opcoded placed, [31:16] is command operand, Hence don;t consider it as valid sequence instruction. Instead take the subsequent set of 16 bits for decoding instruction
           cmd16_operand     = &seq_reg_0[31:26] && ~&seq_reg_0[15:10] ? seq_reg_1[15:0]  :
                               &seq_reg_1[15:10] && ~&seq_reg_0[31:26] ? seq_reg_1[31:16] : 16'h0; 
           end
  3'b010 : begin 
           following_seq     = &seq_reg_0[31:26] && ~&seq_reg_0[15:10] ? seq_reg_1[31:16] : seq_reg_1[15:0];
           cmd16_operand     = &seq_reg_1[15:10] && ~&seq_reg_0[31:26] ? seq_reg_1[31:16] :
                               &seq_reg_1[31:26] && ~&seq_reg_1[15:10] ? seq_reg_2[15:0]  : 16'h0;
           end
  3'b011 : begin 
           following_seq     = &seq_reg_1[15:10] && ~&seq_reg_0[31:26] ? seq_reg_2[15:0]  : seq_reg_1[31:16];
           cmd16_operand     = &seq_reg_2[15:10] && ~&seq_reg_1[31:26] ? seq_reg_2[31:16] : 
                               &seq_reg_1[31:26] && ~&seq_reg_1[15:10] ? seq_reg_2[15:0]  : 16'h0;
           end
  3'b100 : begin 
           following_seq     = &seq_reg_1[31:26] && ~&seq_reg_1[15:10] ? seq_reg_2[31:16] : seq_reg_2[15:0]; 
           cmd16_operand     = &seq_reg_2[31:26] && ~&seq_reg_2[15:10] ? seq_reg_3[15:0]  : 
                               &seq_reg_2[15:10] && ~&seq_reg_1[31:26] ? seq_reg_2[31:16] : 16'h0;
           end
  3'b101 : begin 
           following_seq     = &seq_reg_2[15:10] && ~&seq_reg_1[31:26] ? seq_reg_3[15:0]  : seq_reg_2[31:16];
           cmd16_operand     = &seq_reg_3[15:10] && ~&seq_reg_2[31:26] ? seq_reg_3[31:16] : 
                               &seq_reg_2[31:26] && ~&seq_reg_2[15:10] ? seq_reg_3[15:0]  : 16'h0;
           end
  3'b110 : begin 
           following_seq     = &seq_reg_2[31:26] && ~&seq_reg_2[15:10] ? seq_reg_3[31:16] : seq_reg_3[15:0]; 
           cmd16_operand     = 16'h0;
           end
  3'b111 : begin 
           following_seq     = seq_reg_3[31:16];
           cmd16_operand     = 16'h0;
           end
endcase
end

//--------------------------------------------------------------------------------------------------------------

//To calculate the valid data bits sent to write engine in a clock during memory write    
always @*
begin
  nxt_ca_reg = ca_instrn ? 1'b1 : stop_instrn & fsm_trigger ? 1'b0 : ca_reg;
  valid_data_bits = 6'h0;
  if(first_wvalid) begin
  //if(fsm_trig_redge | first_wvalid) begin
    //if( (axi_addr[1])  && (!ca_reg) ) // unaligned address
  if( ( (axi_addr[1:0]==2'd0 && wdata_strobe[1:0]==2'b00 && (!cont_wr_reg)) || (axi_addr[1]) ) /*&& (!ca_reg)*/ )
    //if( ((axi_addr[1:0]==2'd0 && (axi_burst_size==3'd0 || axi_burst_size==3'd1) && (wdata_strobe[1:0]==2'b00) && (!cont_wr_reg)) || (axi_addr[1]) ) && (!ca_reg) )
//aligned addr and 1B/xfer or 2B/xfer and LSB 2 byte strobe is masked or unlaigned address 2 or 3
    begin
               valid_data_bits = 6'h10;
               case(wdata_strobe[3:2])
               2'd1: axi_first_operand = {16'd0,8'hFF,slv_mem_wdata[23:16]};
               2'd2: axi_first_operand = {16'd0,slv_mem_wdata[31:24],8'hFF};
               2'd3: axi_first_operand = {16'd0,slv_mem_wdata[31:16]};
               2'd0: axi_first_operand = {32'h 00_00_FF_FF};
               endcase
    end
    else 
    begin
        if((deassert_cs || last_wr) && (axi_burst_size==3'd0 || axi_burst_size==3'd1) && (wdata_strobe[3:2]==2'b00) ) //1B/xfer and 2B/xfer and MSB 2 bytes is masked
        begin
           valid_data_bits = 6'h10;
           case(wdata_strobe[1:0])
           2'd1: axi_first_operand = {16'd0,8'hFF,slv_mem_wdata[7:0]};
           2'd2: axi_first_operand = {16'd0,slv_mem_wdata[15:8],8'hFF};
           2'd3: axi_first_operand = {16'd0,slv_mem_wdata[15:0]};
           2'd0: axi_first_operand = {32'h 00_00_FF_FF};
           endcase
        end
        else
        begin
        valid_data_bits    = 6'h20;
        axi_first_operand[31:24] = wdata_strobe[3] ? slv_mem_wdata [31:24] : 8'hFF;
        axi_first_operand[23:16] = wdata_strobe[2] ? slv_mem_wdata [23:16] : 8'hFF; 
        axi_first_operand[15:8]  = wdata_strobe[1] ? slv_mem_wdata [15:8]  : 8'hFF; 
        axi_first_operand[7:0]   = wdata_strobe[0] ? slv_mem_wdata [7:0]   : 8'hFF; 
        end
    end
  end //first write ends
  else if((last_wr || deassert_cs) && (axi_burst_size==3'd0 || axi_burst_size==3'd1) && (wdata_strobe[3:2]==2'b00) && (!slv_mem_wlast_stall) ) //1B/xfer and 2B/xfer and MSB 2 bytes is masked
  begin   
      valid_data_bits = 6'h10;
      case(wdata_strobe[1:0])
      2'd1: axi_first_operand = {16'd0,8'hFF,slv_mem_wdata[7:0]};
      2'd2: axi_first_operand = {16'd0,slv_mem_wdata[15:8],8'hFF};
      2'd3: axi_first_operand = {16'd0,slv_mem_wdata[15:0]};
      2'd0: axi_first_operand = {32'h 00_00_FF_FF};
      endcase
  end
  /*else if((deassert_cs || last_wr) && (axi_burst_size==3'd0 || axi_burst_size==3'd1) && (wdata_strobe[3:2]==2'b01) ) //1B/xfer and 2B/xfer and MSB 2 bytes is masked
        begin
           valid_data_bits = 6'h18;
           case(wdata_strobe[1:0])
           2'd1: axi_first_operand = {8'd0,8'hFF,slv_mem_wdata[15:0]};
           2'd2: axi_first_operand = {8'd0,slv_mem_wdata[15:0],8'hFF};
           2'd3: axi_first_operand = {8'd0,slv_mem_wdata[23:0]};
           2'd0: axi_first_operand = {32'h 00_00_FF_FF};
           endcase
        end*/
  else // 4'h4, 4'h5, 4'h6, 4'h7, 4'h8, 4'h9, 4'hA, 4'hB, 4'hD, 4'hE, 4'hF
  begin
      valid_data_bits = 6'h20;
      axi_first_operand[31:24] = wdata_strobe[3] ? slv_mem_wdata [31:24] : 8'hFF;
      axi_first_operand[23:16] = wdata_strobe[2] ? slv_mem_wdata [23:16] : 8'hFF; 
      axi_first_operand[15:8]  = wdata_strobe[1] ? slv_mem_wdata [15:8]  : 8'hFF; 
      axi_first_operand[7:0]   = wdata_strobe[0] ? slv_mem_wdata [7:0]   : 8'hFF; 
  end
end

//always @*
//begin
//  if((axi_burst_size == 3'b000 ||  axi_burst_size== 3'b001) &&
//      axi_burst_type == 2'b01 && ~|axi_addr[1:0])
//    rw_txfr_length = axi_rw_len + 5'd1;
//    //rw_txfr_length = strobe_all_ones ? axi_rw_len : axi_rw_len + 9'd1;
//  else
//    rw_txfr_length = axi_rw_len;
//end

//Logic for CSR based write transfer 
always @*
begin
  
  case(csr_wr_up_cntr[3:0] )
  4'b0000: valid_csr_data = wr_rd_data_1;
  4'b0001: valid_csr_data = wr_rd_data_2;
   default : valid_csr_data = 32'd0;

  endcase

  case(|csr_or_wrap_wr_nosplit_dword_cntr )
  1'b1:
	valid_csr_bits = 6'd32;
	//csr_wr_valid_operand_bits = 6'd32;	//any other cnt
  1'b0:
  if(~|csr_data_bytes[1:0])
	valid_csr_bits = 6'd8;
  else if(~csr_data_bytes[1] && csr_data_bytes[0])
	valid_csr_bits = 6'd16; 
  else if(csr_data_bytes[1] && ~csr_data_bytes[0])
	valid_csr_bits = 6'd24; 
  else 
	valid_csr_bits = 6'd32; 	
  endcase
end
//--------------------------------------------------------------------------------------------------------------


////////////////////////////////////////////////////////
//FSM
////////////////////////////////////////////////////////
always @*
begin       //always begin
nxt_operand                 = operand            ;
nxt_valid_operand_bits      = valid_operand_bits ;
nxt_no_of_pins              = no_of_pins         ;
nxt_ddr_instrn_en           = /*chip_sel ? 1'b0 : */ddr_instrn_en      ;
nxt_read_pins               = read_pins          ;
nxt_instrn_dlp_en           = instrn_dlp_en      ;
nxt_instrn_dlp_pattern      = instrn_dlp_pattern ;
nxt_wdata_progress          = wdata_progress     ;
nxt_state                   = state              ;
nxt_rcv_dq_fifo_flush_en    = rcv_dq_fifo_flush_en;
nxt_rcv_dq_fifo_flush_chk   = rcv_dq_fifo_flush_chk;
nxt_stall_wr                = stall_wr;
nxt_illegal_strobe          = illegal_strobe;
nxt_csr_or_wrap_wr_nosplit_dword_cntr            = csr_or_wrap_wr_nosplit_dword_cntr;
nxt_initial_wrap_data_cntr         = initial_wrap_data_cntr;
nxt_first_wvalid            = first_wvalid;

  nxt_axi_txfr_lat 	        = (ahb_start_mem_xfer_ack & xfer_wr_rd & dual_seq_mode_reg_int) ? 1'b0 : (ahb_start_mem_xfer && ~axi_mem_xfer_bsy && ~csr_mem_xfer_bsy && ~xfer_mem_error) ? 1'b1 :
                                   (txfr_wr_trigger & wrap_has_split) ? ((wrap_data_ready && (~|req_to_cs_dly_cnt)) ? 1'b0 : axi_txfr_lat) : /*wait for all wrap data to be ready*/
                                   txfr_wr_trigger ? ((slv_mem_wdata_valid && (~|req_to_cs_dly_cnt)) ? 1'b0 : axi_txfr_lat) : /*wait for 1st strobe*/
                                   (axi_txfr_lat && (~|req_to_cs_dly_cnt)) ? 1'b0 : axi_txfr_lat;
  nxt_csr_txfr_lat              = (csr_start_mem_xfer && !csr_mem_xfer_bsy && ~axi_mem_xfer_bsy) ? 1'b1 :
                                  (csr_txfr_lat && (~|req_to_cs_dly_cnt)) ? 1'b0 : csr_txfr_lat;
  nxt_axi_mem_xfer_bsy          = ahb_start_mem_xfer_ack & ahb_start_mem_xfer ? 1'b1 : ((state==READ && rcv_dq_fifo_flush_done)  || (state!=READ && mem_xfer_start && chip_sel)) ? 1'b0 : axi_mem_xfer_bsy ;	
  nxt_csr_mem_xfer_bsy	        = csr_start_mem_xfer_ack & csr_start_mem_xfer ? 1'b1 : ((state==READ && rcv_dq_fifo_flush_done)  || (state!=READ && mem_xfer_start && chip_sel)) ? 1'b0 : csr_mem_xfer_bsy ;
  nxt_ahb_start_mem_xfer_ack    = ahb_start_mem_xfer && !axi_mem_xfer_bsy && !csr_mem_xfer_bsy && !start_read
                                   && !ahb_start_mem_xfer_ack ;
  //nxt_axi_start_mem_xfer_ack    = axi_start_mem_xfer && !axi_mem_xfer_bsy && !csr_mem_xfer_bsy && !start_read
  //                                 && !axi_start_mem_xfer_ack && (!slv_mem_wlast | (subseq_pg_wr_reg & slv_mem_wlast));	// check

  nxt_csr_start_mem_xfer_ack    = csr_start_mem_xfer && !csr_mem_xfer_bsy && !axi_mem_xfer_bsy && !start_read 
                                   && !csr_start_mem_xfer_ack;	

  nxt_axi_trigger	        = (axi_txfr_lat_fedge) ? 1'b1 : 
                                   (axi_trigger && (stop_in_progress || (jump_on_cs_instrn & rd_done) || ~legal_instrn)) ? 1'b0 : axi_trigger ;

  nxt_csr_trigger	        = (csr_txfr_lat_fedge) ? 1'b1:
                                   (csr_trigger && (stop_in_progress || jump_on_cs_instrn || ~legal_instrn)) ? 1'b0 : csr_trigger ;

  nxt_req_to_cs_dly_cnt         = (|req_to_cs_dly_cnt) ? req_to_cs_dly_cnt -5'h1 :
                                  ((ahb_start_mem_xfer && ahb_start_mem_xfer_ack ) | (csr_start_mem_xfer && csr_start_mem_xfer_ack) )
                                  ? req_to_cs_dly  : req_to_cs_dly_cnt ;

  nxt_mem_xfer_start             = (mem_xfer_start && chip_sel) ? 1'b0 : !chip_sel ? 1'b1 : mem_xfer_start;

  //nxt_write_enable        = fsm_trig_redge | data_ack  ?  
  //                          (sdr_read_instrn || ddr_read_instrn || dlp_instrn || stop_instrn || stop_in_progress)  ? 1'b0 : 1'b1 : 
  //                          write_enable;



////////////////////////////////////////////////////////
//INITIAL STEPS ONCE A REQUEST(AXI/CSR) IS RECEIVED
////////////////////////////////////////////////////////
  nxt_seq_reg_0                 = txfr_req & dual_seq_mode_reg_int & !auto_initiate ? seq_reg_2_in : txfr_req ? seq_reg_0_in : seq_reg_0;
  nxt_seq_reg_1                 = txfr_req & dual_seq_mode_reg_int & !auto_initiate ? seq_reg_3_in : txfr_req ? seq_reg_1_in : seq_reg_1;
  nxt_seq_reg_2                 = txfr_req & dual_seq_mode_reg_int & !auto_initiate & !xfer_wr_rd? 32'h0 : txfr_req ? seq_reg_2_in : seq_reg_2;
  nxt_seq_reg_3                 = txfr_req ? seq_reg_3_in : seq_reg_3;
  //Latching length, address informations using the rising edge of the leveled axi request signal    
  nxt_axi_rw_len                =  axi_txfr_req ? rw_len_mem_xfer : axi_rw_len ;
  nxt_axi_addr 	                =  axi_txfr_req ? addr_mem_xfer : axi_addr ;
  nxt_axi_burst_type            =  axi_txfr_req ? xfer_btype :axi_burst_type ;
  nxt_axi_burst_size            =  axi_txfr_req ? xfer_bsize :axi_burst_size ;
  nxt_wrap_no_of_xfer           =  axi_txfr_req ? no_of_xfer :wrap_no_of_xfer ;
  nxt_cont_wr_reg = cont_wr_reg;
                                   
  //Latching length, address informations using the rising edge of the leveled CSR request signal    
  nxt_csr_addr 	                = csr_txfr_req              ? addr_mem_xfer : csr_addr ;
  nxt_csr_data_bytes  	        = csr_txfr_req              ? no_of_data_bytes : csr_data_bytes ;		

nxt_start_read              = start_read;
nxt_write_pins   	    = stop_instrn ? write_pins : decoded_pins;

nxt_addr_incr               = chip_sel ? 32'd0:
                              addr_instrn ? addr_operand>>addr_shift_value : 
	                      (write_instrn & data_ack) ? (addr_incr + (valid_data_bits>>3)) - 1'b1 : 
			      slv_mem_wdata_ack ? addr_incr + (valid_data_bits>>3) : addr_incr; //indicates addr programmed upto this location

//nxt_addr_incr               = subseq_pg_wr ? 32'd0:
//                              addr_instrn ? addr_operand : 
//	                      (write_instrn & data_ack) ? (addr_incr + (valid_data_bits>>3)) - 1'b1 : 
//			      slv_mem_wdata_ack ? addr_incr + (valid_data_bits>>3) : addr_incr; //indicates addr programmed upto this location

nxt_subseq_pg_wr_reg		    = subseq_pg_wr ? 1'b1 : chip_sel ? 1'b0 : subseq_pg_wr_reg;

////Sequence Counter - Points to the current instruction out of 8 instructions from the sequence engine
nxt_seq_cntr = ((seq_fetch && ((~|following_seq[15:10]) | ~legal_instrn | (stop_instrn && fsm_trigger))) |seq_cntr_clr|xfer_mem_error  ) & (!dual_seq_mode_reg_int || (!xfer_wr_rd & dual_seq_mode_reg_int)) ? 3'b000 :
               seq_cntr_ld_en ? seq_cntr_ld_value:
               (seq_fetch && &following_seq[15:10]) ? seq_cntr + 3'b010 :    //increment it twice if cmd16 is the current instruction
               (seq_fetch && !wdata_progress && !start_read) ? seq_cntr + 3'b001 : seq_cntr; //increment once for all other commands except during write data

//seq decoding
nxt_decoded_instrn        = seq_fetch ? following_seq[15:10] : decoded_instrn;
nxt_decoded_pins          = (seq_fetch & |nxt_decoded_instrn) ? following_seq[9:8]   : decoded_pins;
nxt_decoded_operand       = seq_fetch ? following_seq[7:0]   : decoded_operand;
nxt_ca_operand            = seq_fetch ? {!xfer_wr_rd,1'b0,!axi_burst_type[1],5'h1F, 2'd0, addr_mem_xfer[25:4], 13'd0, addr_mem_xfer[3:1]} : ca_operand; //Byte address converted to word address
nxt_decoded_cmd16_operand = seq_fetch ? cmd16_operand    : decoded_cmd16_operand;



 //Indicates that new AXI request received is AXI write and hence controller
 //should expect the WRITE instrcution in its sequence of instructions
 //axi_last_wr is checked if only 1 write transfer is to be sent to memory
 nxt_write_instrn_exist        = (wdata_progress | deassert_cs | stop_instrn && data_ack) ? 1'b0 : expect_write_instrn ? 1'b1 : write_instrn_exist ;
 //Indicates that new AXI request received is AXI read and hence controller
 //should expect the READ instrcution in its sequence of instructions
 nxt_rd_instrn_exist 	        = start_read ? 1'b0 : expect_rd_instrn ? 1'b1 : rd_instrn_exist ;

 nxt_addr_instrn_d             = fsm_trigger ? addr_instrn : 1'b0 ;
 nxt_valid_addr_value 	       = (addr_instrn && !addr_instrn_d) ? {addr_operand[7:0],   //To avoid muxt in operand_out
                                                                     addr_operand[15:8],
                                                                     addr_operand[23:16],
                                                                     addr_operand[31:24]
                                                                    }
                                                                  : valid_addr_value ; //address to be sent to memory
   
 nxt_mem_illegal_instrn        = (mem_illegal_instrn && chip_sel) ? 1'b0 : 
                                  (~legal_instrn && axi_trigger)  ? 1'b1 : mem_illegal_instrn ;

//stop in progress get deasserted at the next input request from AXI/CSR
 nxt_stop_in_progress 	        = txfr_req ? 1'b0: (stop_instrn && fsm_trigger &&
                                  ((data_ack && !wdata_progress) | rd_done | csr_read_end)) ? 1'b1 
                                  : stop_in_progress ;
//Jump on CS instruction and Stop instruction handling
 nxt_jump_to_instrn            =  jump_on_cs_instrn ? (decoded_operand[2:0] - 1'b1) : jump_to_instrn	; // -1  is because seq_cntr takes values 0 to 7 for 8 different instructions
 nxt_jump_on_cs_high 	        =  (sequence_change && ~|state) ? 1'b0 :
			           (jump_on_cs_instrn && |state) ? 1'b1 : jump_on_cs_high ;

nxt_initial_wrap_data_cntr     = axi_start_mem_xfer_ack_d & wrap_has_split ? axi_rw_len : 
			      wrap_push ? (initial_wrap_data_cntr - ({{(WRAP_LEN_WIDTH-1){1'b0}},1'b1})) : initial_wrap_data_cntr;  
nxt_wrap_data_wait	    = (axi_start_mem_xfer_ack_d & wrap_has_split) ? 1'b1 : wrap_data_ready ? 1'b0 : wrap_data_wait; 
//nxt_initial_wrap_data_cntr     = cont_wr_ack_d & wrap_has_split ? axi_rw_len : 
//			      wrap_push ? (initial_wrap_data_cntr - ({{(WRAP_LEN_WIDTH-1){1'b0}},1'b1})) : initial_wrap_data_cntr;  
//nxt_wrap_data_wait	    = (cont_wr_ack_d & wrap_has_split) ? 1'b1 : wrap_data_ready ? 1'b0 : wrap_data_wait; 

nxt_slv_mem_wlast_stall     = (slv_mem_wlast & wrap_has_split & (write_instrn | stop_instrn) & data_ack) ? 1'b1 : (wrap_empty & data_ack ) || deassert_cs ? 1'b0 : slv_mem_wlast_stall;

  nxt_first_data_ack      = first_data_ack;
  nxt_write_enable       = write_enable;
  nxt_onecyc_en_out       = onecyc_en_out ;
  nxt_twocyc_en_out       = twocyc_en_out ;
  nxt_multicyc_en_out     = multicyc_en_out;
  nxt_dual_seq_mode_reg_int = (seq_fetch & stop_instrn & dual_seq_mode_reg_int & !auto_initiate) ? 1'b0 : (dual_seq_mode_reg & ahb_start_mem_xfer_ack & !auto_initiate) ? 1'b1 : dual_seq_mode_reg_int;

case (state)
IDLE : //IDLE		
begin

if(fsm_trig_redge | data_ack)
begin
   //Write engine input generation
  nxt_write_enable        = (sdr_read_instrn || ddr_read_instrn || dlp_instrn || stop_instrn || stop_in_progress)  ? 1'b0 : 1'b1 ; 

  nxt_onecyc_en_out       = ((sdr_read_instrn || ddr_read_instrn || dlp_instrn || stop_instrn || stop_in_progress) ? 1'b0 : 
                             (dummy_onecyc_en   | onecyc_en_int));
  nxt_twocyc_en_out       = ((sdr_read_instrn || ddr_read_instrn || dlp_instrn || stop_instrn || stop_in_progress) ? 1'b0 : 
                            (dummy_twocyc_en   | twocyc_en_int));
  nxt_multicyc_en_out     = ((sdr_read_instrn || ddr_read_instrn || dlp_instrn || stop_instrn || stop_in_progress) ? 1'b0 : 
                            (dummy_multicyc_en | multicyc_en_int));

  nxt_operand             = (cmd_instrn || cmd_ddr_instrn)         ? hyperflash_en ? {32'd0,valid_csr_hyperaddr[7:0],decoded_operand} : {32'd0,decoded_operand,decoded_operand}                       :                 //cmd
			    ca_instrn                              ? {valid_ca_operand} :     //ca instrn 
                            cmd16_instrn                           ? {32'd0,decoded_cmd16_operand[7:0],decoded_cmd16_operand[15:8]} ://cmd16
                            addr_instrn                            ? hyperflash_en ? {16'd0,valid_csr_hyperaddr[39:8]} : 
                                                                     page_addr_enable ? page_addr : {16'd0,valid_addr_value} :
                            (sdr_mode8_instrn )  ? {16'd0,valid_csr_hyperaddr[39:8]}  : 
//dummy instruction sends the HiZ value or the logic value
                            dummy_instrn                           ? (xip_mode ? ({39'd0,1'b1,dummy_cyc_drive[7:1],xip_drive_bit})  : ({40'd0,dummy_cyc_drive}) ) : //dummy
                            write_instrn                           ? ( (csr_trigger & hyperflash_en) ? {16'd0,valid_csr_hyperaddr[39:8]} : 
                                                                      csr_trigger ? ( (unalign_data_chk_ddr && valid_csr_bits == 6'h18) ? 
                                                                     {16'd0,8'hFF,valid_csr_data[23:0]} : 
                                                                     (unalign_data_chk_ddr && valid_csr_bits == 6'h08) ? 
                                                                     {16'd0,24'hFF,valid_csr_data[7:0]} : {16'd0,valid_csr_data}) : 
                                                                     {16'd0,axi_valid_data} ) :      //write
                            (stop_instrn | sdr_read_instrn | ddr_read_instrn | dlp_instrn) ? 48'd0 : operand;

//upper one bit is reserved for dummy instruction alone; by setting this one,
//it indicates the write engine that dummy instruction is in progress
  nxt_valid_operand_bits  = cmd_instrn                            ? hyperflash_en ? 7'h10 : 7'h08 : //for hyperflash requires 6 bytes(48 bits); 2 bytes through command and 4 bytes through MODE insturction; Mode instruction shall have maximum 6 bytes of data (removed from sequence enigne; it is internal to the FSM controller)
			    ca_instrn                             ? 7'h30 :          //valid ca bits ; 48 bites - specific to hyperflash
                            cmd_ddr_instrn                        ? &decoded_pins ? 7'h10 : 7'h08 :                                                        cmd16_instrn                          ? 7'h10 :                                        //cmd16
                            addr_instrn                           ? hyperflash_en ? 7'h20 : {1'b0, axi_addr_valid_operand_bits} : //valid addr bits can be max of 32
                            dummy_instrn                          ? {1'b1, decoded_operand[5:0]} : //dummy instrn;holds the number of dummy cycles
                            write_instrn                          ? (csr_trigger & hyperflash_en) ? 7'h20 : csr_trigger? {1'b0,csr_wr_valid_operand_bits} : {1'b0,valid_data_bits} :             //write
                            (stop_instrn | sdr_read_instrn | ddr_read_instrn | dlp_instrn) ? 7'b0 : valid_operand_bits; 

  nxt_no_of_pins          = stop_instrn ? 2'b00 : decoded_pins;   

  //ddr enable
  nxt_ddr_instrn_en       = (ddr_instrn_en && !ddr_instrn) ? 1'b0 : 
                            (ddr_instrn)  ? 1'b1 : ddr_instrn_en ;

 //signal asserted for all other instructions except for data access(wr/rd) instructions

  //read conditions
  nxt_start_read          =  stop_instrn ? 1'b0 : (sdr_read_instrn || ddr_read_instrn || dlp_instrn) ? 1'b1 : start_read;
  nxt_read_pins           = (sdr_read_instrn || ddr_read_instrn || dlp_instrn) ? decoded_pins : read_pins;
  nxt_instrn_dlp_en       = stop_instrn ? 1'b0 : dlp_instrn ? 1'b1 : instrn_dlp_en;
  nxt_instrn_dlp_pattern  = stop_instrn ? 8'h0 : decoded_operand;

  //write conditions
  //last_wr is possible when there is only one write is going to memory
  nxt_wdata_progress      = ((csr_trigger && ~|csr_wr_dword_cnt_max) | deassert_cs| stop_instrn) ? 1'b0 : write_instrn ? 1'b1 : 1'b0; // will be asserted only after the 1st slv_mem_wdata_valid is consumed
  nxt_stall_wr            = ((stall_wr && slv_mem_wdata_valid_redge) | slv_mem_wlast_stall) ? 1'b0 :(wdata_progress && !csr_trigger && !slv_mem_wdata_valid) ? 1'b1 : stall_wr;

//This counter is both for CSR writes and for AXI wrap write transfers - and counts for the expected number of data to be received from AXI
//AXI increment write transfers are independent of length calculation and depends only on wlast
					
 nxt_csr_or_wrap_wr_nosplit_dword_cntr               = (csr_trig_redge) ? {{(WRAP_LEN_WIDTH-1){1'b0}},csr_wr_dword_cnt_max} :  
                                  (csr_trigger && (|csr_or_wrap_wr_nosplit_dword_cntr)) ? (csr_or_wrap_wr_nosplit_dword_cntr - {{(WRAP_LEN_WIDTH-1){1'b0}},1'b1}) :  
                                   cont_wr_ack ?   (rw_len_mem_xfer - ({{(WRAP_LEN_WIDTH-1){1'b0}},1'b1}))   :
                                  (axi_burst_type == 2'b10 && fsm_trig_redge) ? (axi_rw_len - ({{(WRAP_LEN_WIDTH-1){1'b0}},1'b1})) :
                                  (axi_burst_type == 2'b10 && slv_mem_wdata_valid && slv_mem_wdata_ack && (|csr_or_wrap_wr_nosplit_dword_cntr)) ?  
                                  (csr_or_wrap_wr_nosplit_dword_cntr - ({{(WRAP_LEN_WIDTH-1){1'b0}},1'b1})) :
                                    csr_or_wrap_wr_nosplit_dword_cntr;

 nxt_first_wvalid               = (stop_instrn | (first_wvalid && slv_mem_wdata_ack)) ? 1'b0 :(fsm_trig_redge && slv_mem_wdata_valid) ? 1'b1 : first_wvalid;

  //state switching
  nxt_state               = (sdr_read_instrn || ddr_read_instrn || dlp_instrn) ? READ : 
		            (stop_instrn | deassert_cs || (csr_trigger && ~|csr_wr_dword_cnt_max)) ? IDLE : 
                             write_instrn  ? WRITE : state;

  nxt_axi_rw_len 	    = cont_wr_ack ? rw_len_mem_xfer : axi_rw_len;
  nxt_wrap_no_of_xfer       = cont_wr_ack ? no_of_xfer : wrap_no_of_xfer;
  nxt_axi_addr 	            = cont_wr_ack ? addr_mem_xfer : axi_addr ;
  nxt_axi_burst_type        = cont_wr_ack ? xfer_btype :axi_burst_type ;
  nxt_axi_burst_size        = cont_wr_ack ? xfer_bsize :axi_burst_size ;
  nxt_ahb_start_mem_xfer_ack= cont_wr_ack ? 1'b1 : 1'b0;
  nxt_cont_wr_reg           = deassert_cs ? 1'b0 : cont_wr_ack ? 1'b1 : cont_wr_reg;
end//conditional check ends
else 
begin

  nxt_write_enable               = write_enable;
  nxt_operand                    = operand;
  nxt_valid_operand_bits         = valid_operand_bits;
  
end
end//Idle state ends
READ  :
begin
  nxt_write_enable             = 1'b0;
  nxt_onecyc_en_out       = 1'b0 ; 
  nxt_twocyc_en_out       = 1'b0 ; 
  nxt_multicyc_en_out     = 1'b0 ; 
  nxt_start_read               =  (rd_done | csr_read_end) ? 1'b0 : start_read;
  nxt_instrn_dlp_en            = dlp_rd_stp_d ? 1'b0 : instrn_dlp_en;
  //waiting for 5 clocks after chip sel deassertion; then to assert rcv_dq_fifo_flush_en
  nxt_rcv_dq_fifo_flush_chk    = rcv_dq_fifo_flush_done? 5'b0 : {chip_sel,rcv_dq_fifo_flush_chk[4:1]};
  nxt_rcv_dq_fifo_flush_en     = rcv_dq_fifo_flush_done ? 1'b0 : rcv_dq_fifo_flush_chk[0] ? 1'b1 : rcv_dq_fifo_flush_en ; 
  //State to remain in read till fifo flush is done after every read transfer
  nxt_state                    = rcv_dq_fifo_flush_done ? IDLE : state;
  //ddr enable
  nxt_ddr_instrn_en       = (ddr_instrn_en && rcv_dq_fifo_flush_done ) ? 1'b0 : ddr_instrn_en ;
end
WRITE : 					
begin

if((data_ack && !mem_illegal_instrn) || (stall_wr & slv_mem_wdata_valid))
  begin
    nxt_first_data_ack      = deassert_cs ? 1'b0 : (!csr_trigger) ? 1'b1 : first_data_ack;
    nxt_write_enable        = ((csr_trigger && ~|csr_or_wrap_wr_nosplit_dword_cntr) | deassert_cs) ? 1'b0 :  write_enable;
    nxt_onecyc_en_out       = deassert_cs ||(wdata_progress && !csr_trigger && !slv_mem_wdata_valid && (!slv_mem_wlast_stall)) ? 1'b0 : (dummy_onecyc_en   | onecyc_en_int);
    nxt_twocyc_en_out       = deassert_cs ||(wdata_progress && !csr_trigger && !slv_mem_wdata_valid && (!slv_mem_wlast_stall)) ? 1'b0 : (dummy_twocyc_en   | twocyc_en_int);
    nxt_multicyc_en_out     = deassert_cs ||(wdata_progress && !csr_trigger && !slv_mem_wdata_valid && (!slv_mem_wlast_stall)) ? 1'b0 : (dummy_multicyc_en   | multicyc_en_int);
    nxt_axi_rw_len 	    = cont_wr_ack ? rw_len_mem_xfer : axi_rw_len;
    nxt_wrap_no_of_xfer     = cont_wr_ack ? no_of_xfer : wrap_no_of_xfer;
    nxt_axi_addr 	    = cont_wr_ack ? addr_mem_xfer : axi_addr ;
    nxt_axi_burst_type      = cont_wr_ack ? xfer_btype :axi_burst_type ;
    nxt_axi_burst_size      = cont_wr_ack ? xfer_bsize :axi_burst_size ;
    nxt_ahb_start_mem_xfer_ack = cont_wr_ack ? 1'b1 : 1'b0;
    nxt_first_wvalid        = first_wvalid && slv_mem_wdata_ack && (!cont_wr_ack) ? 1'b0 :(cont_wr_ack && slv_mem_wdata_valid) ? 1'b1 : first_wvalid;
    nxt_cont_wr_reg         = deassert_cs ? 1'b0 : cont_wr_ack ? 1'b1 : cont_wr_reg;
    nxt_stall_wr            = deassert_cs || ((stall_wr && slv_mem_wdata_valid & (!wrap_data_wait)) | slv_mem_wlast_stall) ? 1'b0 :(wdata_progress && !csr_trigger && !slv_mem_wdata_valid /*& (!first_data_ack)*/ ) || wrap_data_wait || ahb_start_mem_xfer_ack ? 1'b1 : stall_wr;
    nxt_no_of_pins          = no_of_pins ;
    nxt_operand             = csr_trigger ? 
                            ((unalign_data_chk_ddr && valid_csr_bits == 6'h18) ? {16'd0,8'hFF,valid_csr_data[23:0]} : 
                            ((unalign_data_chk_ddr && valid_csr_bits == 6'h08 )? {16'd0,24'hFF,valid_csr_data[7:0]} : {16'd0,valid_csr_data})) : 
                             stall_wr ?  (slv_mem_wdata_valid ? {16'd0,axi_valid_data} : operand ): {16'd0,axi_valid_data} ;
    nxt_valid_operand_bits  = csr_trigger? {1'b0,csr_wr_valid_operand_bits} :
                              stall_wr ? (slv_mem_wdata_valid ? {1'b0,valid_data_bits} : valid_operand_bits): 
                              {1'b0,valid_data_bits};	
    nxt_wdata_progress      = ((csr_trigger && ~|csr_or_wrap_wr_nosplit_dword_cntr) | deassert_cs) ? 1'b0 : wdata_progress;
    nxt_state               = ((csr_trigger && ~|csr_or_wrap_wr_nosplit_dword_cntr) | deassert_cs) ? IDLE : state; 

    nxt_stop_in_progress    = stop_instrn && axi_trigger && (/*(csr_trigger && ~|csr_or_wrap_wr_nosplit_dword_cntr) |*/ deassert_cs) ? 1'b1  : 
                              stop_in_progress ;

   //Counter is decremented as the data is received from AXI for AXI wrap write
    nxt_csr_or_wrap_wr_nosplit_dword_cntr        =  cont_wr_ack ? (rw_len_mem_xfer - ({{(WRAP_LEN_WIDTH-1){1'b0}},1'b1})) : (csr_trigger || (axi_burst_type == 2'b10 && slv_mem_wdata_valid && slv_mem_wdata_ack)) && (|csr_or_wrap_wr_nosplit_dword_cntr) ? 
                                (csr_or_wrap_wr_nosplit_dword_cntr - {{(WRAP_LEN_WIDTH-1){1'b0}},1'b1}) : csr_or_wrap_wr_nosplit_dword_cntr;
    //if the wstrobe is not FFFF for transfers other than first and last data
    //nxt_illegal_strobe      = last_wr ? 1'b0 : (slv_mem_wdata_valid && !strobe_all_ones && !last_wr) ? 1'b1 : illegal_strobe;  // strobe check for the 2nd Dword and thereafter Dwords ; since 1st DWORD is already processed in IDLE state
  end
else 
  begin
    nxt_stall_wr            = (first_data_ack & (!slv_mem_wdata_valid) & (!slv_mem_wlast_stall)) ? 1'b1 : stall_wr;
    nxt_write_enable        = write_enable;
    nxt_no_of_pins          = no_of_pins ;
    nxt_operand             = operand ;
    nxt_valid_operand_bits  = valid_operand_bits;                                      
    nxt_wdata_progress      = wdata_progress;
    nxt_state               = state; 
    //nxt_csr_or_wrap_wr_nosplit_dword_cntr        = (cont_wr_ack_d) ? {axi_rw_len - 5'd1} : csr_or_wrap_wr_nosplit_dword_cntr;
    nxt_wrap_no_of_xfer     = wrap_no_of_xfer;
    nxt_axi_rw_len 	    = axi_rw_len;
  end
end
default :
begin
  nxt_write_enable       = write_enable;
  nxt_operand            = operand;
  nxt_valid_operand_bits = valid_operand_bits;
end
endcase
end //always ends

///////////////////////////////////////////////////////////////////////
//Sequential block
///////////////////////////////////////////////////////////////////////
always @(posedge mem_clk or negedge reset_n)
begin
  if(!reset_n)
    begin
    subseq_pg_wr                <= 1'b0;
    fsm_trig_d 			 <= 1'b0;
    mem_illegal_instrn 		 <= 1'b0;
    //csr_illegal_instrn	 <= 1'b0;
    seq_reg_0		         <= 32'h0;    
    seq_reg_1		         <= 32'h0;
    seq_reg_2		         <= 32'h0;
    seq_reg_3		         <= 32'h0;
    axi_rw_len 	                 <= {WRAP_LEN_WIDTH{1'b0}};
    axi_addr 	                 <= {AHB_ADDR_WIDTH{1'b0}};
    csr_addr 	                 <= 32'h0;
    write_instrn_exist 	         <= 1'b0;
    rd_instrn_exist 		 <= 1'b0;
    operand                      <= 32'b0;
    valid_operand_bits           <= 7'b0;
    write_enable                 <= 1'b0;
    first_data_ack               <= 1'b0;
    onecyc_en_out                <= 1'b0;
    twocyc_en_out                <= 1'b0;
    multicyc_en_out              <= 1'b0;
    state                        <= 2'b0;
    axi_trigger		         <= 1'b0; 
    csr_trigger			 <= 1'b0;
    jump_on_cs_instrn_d          <= 1'b0;
    ahb_start_mem_xfer_ack       <= 1'b0;
    axi_start_mem_xfer_ack_d       <= 1'b0;
    csr_start_mem_xfer_ack       <= 1'b0;
    stop_in_progress 		 <= 1'b0;
    seq_cntr			 <= 3'b0;
    axi_txfr_lat 		 <= 1'b0;
    csr_txfr_lat 		 <= 1'b0;
    csr_txfr_lat_d 		 <= 1'b0;
    req_to_cs_dly_cnt 		 <= 5'h0;
    decoded_instrn               <= 6'b0;
    decoded_pins                 <= 2'b0; 
    decoded_operand              <= 8'b0;
    ca_operand                   <= 48'd0;
    decoded_cmd16_operand        <= 16'b0;
    wdata_progress               <= 1'b0; 
    csr_or_wrap_wr_nosplit_dword_cntr                 <= {6{1'b0}};
    initial_wrap_data_cntr              <= {WRAP_LEN_WIDTH{1'b0}};
    jump_to_instrn 		 <= 3'b0;
    jump_on_cs_high 		 <= 1'b0;
    axi_mem_xfer_bsy		 <= 1'b0;
    csr_mem_xfer_bsy		 <= 1'b0;
    addr_instrn_d		 <= 1'b0;
    valid_addr_value 		 <= 32'h0;
    //bits_tx_progress 		 <= 1'b0;
    //bits_tx_sclk_dis 		 <= 1'b0;
    rcv_dq_fifo_flush_en         <= 1'b0;
    rcv_dq_fifo_flush_chk        <= 5'b0;
    dlp_rd_stp_d                 <= 1'b0;
    axi_txfr_lat_d               <= 1'b0;
    slv_mem_wdata_valid_d        <= 1'b0;
    start_read                   <= 1'b0;
    ddr_instrn_en                <= 1'b0;
    instrn_dlp_en                <= 1'b0;
    instrn_dlp_pattern           <= 8'b0;
    no_of_pins                   <= 2'b0;
    read_pins                    <= 2'b0; 
    stall_wr                     <= 1'b0;
    mem_xfer_start               <= 1'b0;
    axi_burst_type               <= 2'b0;
    axi_burst_size               <= 3'b0;
    illegal_strobe               <= 1'b0;
    first_wvalid                 <= 1'b0;
    csr_trig_d			 <= 1'b0;	
    csr_data_bytes		 <= 1'b0;
    addr_incr			 <= 32'd0;
    subseq_pg_wr_reg 		 <= 1'b0;
    ca_reg			 <= 1'b0;
    wrap_push_d			 <= 1'b0;
    slv_mem_wlast_stall		 <= 1'b0;
    wrap_data_wait		 <= 1'b0;
    //cont_wr_strobe 		 <= 4'd0;
    wrap_no_of_xfer 		 <= 2'd0;
    write_pins	 		 <= 2'd0;
    page_incr_en_reg 		 <= 1'd0;
    cont_wr_reg <= 1'b0;
    dual_seq_mode_reg_int        <= 1'b0;
 end
else
  begin
    subseq_pg_wr                <= nxt_subseq_pg_wr;
    seq_reg_0		         <= nxt_seq_reg_0;        
    seq_reg_1		         <= nxt_seq_reg_1;        
    seq_reg_2		         <= nxt_seq_reg_2;        
    seq_reg_3		         <= nxt_seq_reg_3;        
    axi_rw_len 	                 <= nxt_axi_rw_len;
    axi_addr 	                 <= nxt_axi_addr;        
    csr_addr 	                 <= nxt_csr_addr;        
    write_instrn_exist 	         <= nxt_write_instrn_exist;        
    rd_instrn_exist 		 <= nxt_rd_instrn_exist;	
    operand                      <= nxt_operand;
    valid_operand_bits           <= nxt_valid_operand_bits;
    write_enable                 <= nxt_write_enable;
    first_data_ack               <= nxt_first_data_ack;
    onecyc_en_out                <= nxt_onecyc_en_out;
    twocyc_en_out                <= nxt_twocyc_en_out;
    multicyc_en_out              <= nxt_multicyc_en_out;
    state                        <= nxt_state;
    axi_trigger		         <= nxt_axi_trigger;        
    csr_trigger			 <= nxt_csr_trigger;	
    ahb_start_mem_xfer_ack       <= nxt_ahb_start_mem_xfer_ack;	
    axi_start_mem_xfer_ack_d     <= ahb_start_mem_xfer_ack;
    csr_start_mem_xfer_ack       <= nxt_csr_start_mem_xfer_ack;	
    stop_in_progress 		 <= nxt_stop_in_progress;	
    decoded_instrn               <= nxt_decoded_instrn;
    decoded_pins                 <= nxt_decoded_pins; 
    decoded_operand              <= nxt_decoded_operand;
    ca_operand                   <= nxt_ca_operand;
    decoded_cmd16_operand        <= nxt_decoded_cmd16_operand;
    wdata_progress               <= nxt_wdata_progress; 
    csr_or_wrap_wr_nosplit_dword_cntr                 <= nxt_csr_or_wrap_wr_nosplit_dword_cntr;
    initial_wrap_data_cntr       <= nxt_initial_wrap_data_cntr;
    seq_cntr			 <= nxt_seq_cntr;	
    axi_txfr_lat 		 <= nxt_axi_txfr_lat;	
    csr_txfr_lat 		 <= nxt_csr_txfr_lat;	
    csr_txfr_lat_d 		 <= csr_txfr_lat;
    req_to_cs_dly_cnt 		 <= nxt_req_to_cs_dly_cnt;	
    jump_to_instrn 		 <= nxt_jump_to_instrn;	
    jump_on_cs_high 		 <= nxt_jump_on_cs_high;	
    axi_mem_xfer_bsy		 <= nxt_axi_mem_xfer_bsy;	
    csr_mem_xfer_bsy		 <= nxt_csr_mem_xfer_bsy;	
    addr_instrn_d		 <= nxt_addr_instrn_d;	
    valid_addr_value 		 <= nxt_valid_addr_value;	
    //bits_tx_progress 		 <= nxt_bits_tx_progress;     
    //bits_tx_sclk_dis 		 <= nxt_bits_tx_sclk_dis;     
    mem_illegal_instrn 		 <= nxt_mem_illegal_instrn;	
    //csr_illegal_instrn	 <= nxt_csr_illegal_instrn;	
    rcv_dq_fifo_flush_en         <= nxt_rcv_dq_fifo_flush_en;
    rcv_dq_fifo_flush_chk        <= nxt_rcv_dq_fifo_flush_chk;
    start_read                   <= nxt_start_read;
    ddr_instrn_en                <= nxt_ddr_instrn_en;
    instrn_dlp_en                <= nxt_instrn_dlp_en;
    instrn_dlp_pattern           <= nxt_instrn_dlp_pattern;
    no_of_pins                   <= nxt_no_of_pins;
    read_pins                    <= nxt_read_pins;
    stall_wr                     <= nxt_stall_wr;
    mem_xfer_start               <= nxt_mem_xfer_start;
    illegal_strobe               <= nxt_illegal_strobe;
    first_wvalid                 <= nxt_first_wvalid;
//Delayed signals 
    fsm_trig_d 			 <= fsm_trigger;	
    jump_on_cs_instrn_d          <= jump_on_cs_instrn;        
    dlp_rd_stp_d                 <= dlp_read_stop;     
    axi_txfr_lat_d               <= axi_txfr_lat;
    slv_mem_wdata_valid_d        <= slv_mem_wdata_valid;
    axi_burst_type               <= nxt_axi_burst_type;
    axi_burst_size               <= nxt_axi_burst_size;
//    axi_size                     <= nxt_axi_size;
    csr_trig_d			 <= csr_trigger;	
    csr_data_bytes		 <= nxt_csr_data_bytes;
    addr_incr			 <= nxt_addr_incr;
    subseq_pg_wr_reg	 	 <= nxt_subseq_pg_wr_reg;
    //cont_wr_strobe		 <= nxt_cont_wr_strobe;
    ca_reg			 <= nxt_ca_reg;
    wrap_push_d			 <= wrap_push;
    slv_mem_wlast_stall		 <= nxt_slv_mem_wlast_stall;
    wrap_data_wait		 <= nxt_wrap_data_wait;
    wrap_no_of_xfer		 <= nxt_wrap_no_of_xfer;
    write_pins			 <= nxt_write_pins;
    page_incr_en_reg		 <= page_incr_en;
    cont_wr_reg                  <= nxt_cont_wr_reg;
    dual_seq_mode_reg_int        <= nxt_dual_seq_mode_reg_int;
  end 
end

assign wrap_has_split = axi_burst_type[1] & wrap_no_of_xfer[1];
assign wrap_pop = wrap_data_ready | (!wrap_empty & slv_mem_wlast_stall & data_ack);
assign wrap_push_fedge = !wrap_push & wrap_push_d;
assign wrap_data_ready = wrap_push_fedge & (!(|initial_wrap_data_cntr)); // since initial_wrap_data_cntr will be zero in the starting and hence checked for zero after the last push into the FIFO
assign wrap_push = slv_mem_wdata_valid & |initial_wrap_data_cntr;

sync_fifo 
#(
 .DATA_WIDTH (AHB_DATA_WIDTH)
 )
WRAP_FIFO( // depth = 16
 .clk (mem_clk),
 .rstn (reset_n),
 .pop (wrap_pop),
 .push (wrap_push),
 .empty (wrap_empty),
 .full (),
 .din (slv_mem_wdata),
 .dout (slv_mem_wdata_wrap)
    );


endmodule
