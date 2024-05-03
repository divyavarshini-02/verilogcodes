`timescale 1ns/1ps
module write_engine
(
//INPUT PORTS 
//-----------------------------------------------------------------------
//Global signals
//-----------------------------------------------------------------------
mem_clk,
reset_n,
//-----------------------------------------------------------------------
//From Instruction Handler
//-----------------------------------------------------------------------
write_enable                    ,//Write request to write engine; Level signal
no_of_pins                      ,//validated by write_enable signal; Write request control signal - number of pins for the request; 
valid_operand_bits              ,//validated by write_enable signal; Write request control signal - number of bits valid for the request      [5:0] - operand bits; [6] - dummy phase or other phase
operand                         ,//validated by write_enable signal; Write request control signal - operand value to be sent on the dq line ; data is placed from MSB to LSB
in_onecyc_en                    ,//validated by write_enable signal; One cycle enable; Level signal // one cycle is required to send data placed on "operand" bus
in_twocyc_en                    ,//validated by write_enable signal; Two cycle enable; Level signal // two cycle is required to send data placed on "operand" bus
in_multicyc_en                  ,//validated by write_enable signal; Multi cycle enable; Level signal // multi cycle is required to send data placed on "operand" bus
ddr_en                          ,//validated by write_enable signal; Indicates ddr_instruction is given as input to write engine; Level signal
stop_instrn                     ,//Stop instruction detected; Level signal
rd_progress                     ,//Indicates read instruction starts and is in progress; Level signal                    
stall_wr                        ,//Indicates there is no data available from AXI4 slv interface
csr_trigger			,
//-----------------------------------------------------------------------
//From Read engine
//-----------------------------------------------------------------------
rd_clk_stretch,
rd_done,
csr_read_end,
//-----------------------------------------------------------------------
//From CSR
//-----------------------------------------------------------------------
jhr_en                          ,//JEDEC-HW reset enable
CSS                             ,//Chip select setup time count
CSH                             ,//Chip select hold time count
dummy_cyc_HiZ                   ,//Indicates which output dq data lines are to be driven with HiZ value during dummy instruction execution

//From AXI slave
slv_mem_wdata_valid,
/////////////////////////////////////////////////////////////////////////
//OUTPUT PORTS
/////////////////////////////////////////////////////////////////////////
//To Instruction Handler
data_ack,                       //Ack to indicate the current write enable is served and next write enable can be placed; Pulse signal
dummy_end,                      //End of dummy instruction driven to the memory; Pulse signal
//To read engine
//To wrapper
sclk_en,                        //Enable to gated clock generation of sclk, going to memory; Level signal
dq_out,                         //Data lines carrying data for both edges of dq lines; [7:0] -posedge data ; [15:8] -negedge data
dq_oe,                          //Enable for the data lines
chip_sel                       //Chip select signal going to the memory; Level signal
);

parameter IDLE        = 2'b00; 
parameter MULTI_CYCLE = 2'b01;
parameter TWO_CYCLE   = 2'b10;
parameter ONE_CYCLE   = 2'b11;




//Port Declarations
//Global inputs
input mem_clk;
input reset_n;
//From Instruction Handler
input           write_enable;
input [1:0]     no_of_pins;
input [6:0]     valid_operand_bits; 
input [47:0]    operand; 
input           in_onecyc_en;//One cycle enable
input           in_twocyc_en;//Two cycle enable 
input           in_multicyc_en;//Multi cycle enable
input           stop_instrn;
input           ddr_en;
input           rd_progress;
input           stall_wr;
input           csr_trigger;
//From Read engine
input           rd_clk_stretch;
input           rd_done;
input           csr_read_end;
//From CSR
input           jhr_en;
input [1:0]     CSS;
input [1:0]     CSH;
input [7:0]     dummy_cyc_HiZ;

//From AXI slave
input slv_mem_wdata_valid;

//To Instruction Handler
output          data_ack;
output          dummy_end;
//To wrapper
output          sclk_en;
output [15:0]   dq_out;
output [15:0]   dq_oe;
output          chip_sel;

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//Wire declaration
///////////////////////////////////////////////////////////////////////////////////////////////////////////
wire stop_instrn_int;
wire [5:0] cycle_cntr_max;
wire [5:0] cycle_cntr_calc;
wire [3:0] shiftval_calc;
wire [4:0] shiftval;
wire [5:0] data_cycle_cntr;
wire       data_ack;
wire       combo_data_ack;
wire       write_enable_redge;
wire       txfr_en_redge;
wire [5:0] valid_op_bits;
wire       rd_clk_stretch_redge;
wire       rd_clk_stretch_fedge;
wire       stall_wr_redge;
wire       stall_wr_fedge;
wire       stop_cs_redge;
wire       jhr_cs_toggle;
///////////////////////////////////////////////////////////////////////////////////////////////////////////
//Register declaration
///////////////////////////////////////////////////////////////////////////////////////////////////////////
reg        nxt_data_loaded         , data_loaded; 
reg [47:0] nxt_shift_data          , shift_data;
reg        nxt_dummy_end           , dummy_end;
reg        nxt_trigger_txfr        , trigger_txfr;
reg        nxt_txfr_en             , txfr_en;
reg [7:0]  nxt_cycle_cntr          , cycle_cntr;
reg        nxt_chip_sel            , chip_sel;
reg        nxt_stop_cs             , stop_cs;
reg        nxt_sclk_en             , sclk_en;
reg [1:0]  nxt_cs_setup_hold_cnt       , cs_setup_hold_cnt;
reg        nxt_stall_wr_in_progress, stall_wr_in_progress;
reg        nxt_jhr_en_reg          , jhr_en_reg;
reg        nxt_bits_tx_flag        , bits_tx_flag;
reg [6:0]  nxt_jhr_cs_wait         , jhr_cs_wait;
reg [2:0]  jhr_cntr;
reg        write_enable_d;
reg        txfr_en_d;
reg        rd_clk_stretch_d;
reg        stall_wr_d;
reg        rd_progress_d;
reg        stop_cs_d;
reg [15:0] dq_out;
reg [15:0] dq_oe;
reg [15:0] data_dq_oe;
reg [15:0] dummy_dq_oe;

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//Sequential block
///////////////////////////////////////////////////////////////////////////////////////////////////////////
always @ (posedge mem_clk or negedge reset_n)
begin
 if (!reset_n)
 begin
   data_loaded           <= 1'b0;
   shift_data            <= 48'h0;
   dummy_end             <= 1'b0;
   trigger_txfr          <= 1'b0;
   txfr_en               <= 1'b0;
   write_enable_d        <= 1'b0;
   txfr_en_d             <= 1'b0;
   cycle_cntr            <= 8'h0;
   chip_sel              <= 1'b1;
   stop_cs               <= 1'b0;
   stop_cs_d             <= 1'b0;
   sclk_en               <= 1'b0;
   cs_setup_hold_cnt         <= 2'h0;
   rd_clk_stretch_d      <= 1'b0;
   stall_wr_d            <= 1'b0;
   rd_progress_d         <= 1'b0;
   stall_wr_in_progress  <= 1'b0;
   jhr_en_reg		 <= 1'b0;
   bits_tx_flag		 <= 1'b0;
   jhr_cs_wait		 <= 7'd0;
 end
 else
 begin
   data_loaded            <= nxt_data_loaded;
   shift_data             <= nxt_shift_data;
   dummy_end              <= nxt_dummy_end;
   trigger_txfr           <= nxt_trigger_txfr;
   txfr_en                <= nxt_txfr_en;
   cycle_cntr             <= nxt_cycle_cntr;
   chip_sel               <= nxt_chip_sel;
   stop_cs                <= nxt_stop_cs;
   stop_cs_d              <= stop_cs;
   sclk_en                <= nxt_sclk_en;
   cs_setup_hold_cnt          <= nxt_cs_setup_hold_cnt;
   stall_wr_in_progress   <= nxt_stall_wr_in_progress;
   jhr_en_reg             <= nxt_jhr_en_reg;
   bits_tx_flag           <= nxt_bits_tx_flag;
   jhr_cs_wait            <= nxt_jhr_cs_wait;
   //delayed signals
   write_enable_d         <= write_enable;
   txfr_en_d              <= txfr_en;
   rd_clk_stretch_d       <= rd_clk_stretch;
   stall_wr_d             <= stall_wr;
   rd_progress_d          <= rd_progress;
 end
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//Continuous assignments
///////////////////////////////////////////////////////////////////////////////////////////////////////////
//assign data_ack           = txfr_en ? ( (in_onecyc_en & (~|cycle_cntr)) ||
//                            (in_twocyc_en || in_multicyc_en & (~|(cycle_cntr-8'h1)))) : 1'b0;
assign data_ack           = txfr_en ? ( (in_onecyc_en & (~|cycle_cntr)) ||
                            ((in_twocyc_en || in_multicyc_en) & (cycle_cntr==8'h1)) || (stall_wr & (~|cycle_cntr) & slv_mem_wdata_valid)) : 1'b0;

//lower 6 bits shows the number of valid bits in a particular transfer
//MSB 7th bit shows if the instruction is dummy or not
assign valid_op_bits      = valid_operand_bits[5:0]; 
//Rising edge detection of level signals
assign write_enable_redge   = (write_enable && !write_enable_d);
assign txfr_en_redge        = (txfr_en && !txfr_en_d);
assign rd_clk_stretch_redge = (rd_clk_stretch && !rd_clk_stretch_d);
assign rd_clk_stretch_fedge = (!rd_clk_stretch && rd_clk_stretch_d);
assign stall_wr_redge       = stall_wr && !stall_wr_d;
assign stall_wr_fedge       = !stall_wr && stall_wr_d;
assign stop_cs_redge        = stop_cs & (!stop_cs_d);
//Number of clocks required as per the number of pins and the number of bits to be sent to memory
assign cycle_cntr_calc    = (txfr_en ) ?((~|no_of_pins) ? (valid_op_bits -6'h1):
                                         (~no_of_pins[1] & no_of_pins[0]) ? (valid_op_bits >>1)-6'h1:
                                         (no_of_pins[1] & ~no_of_pins[0]) ? (valid_op_bits>>2) -6'h1:
                                         (&no_of_pins) ? (valid_op_bits>>3) -6'h1 : 6'h00) : 6'h00 ;
//Holds the cycle counter calculation for SDR and DDR
assign data_cycle_cntr          = ddr_en ? cycle_cntr_calc>>1 : cycle_cntr_calc;
//cycle counter calculation grouped for SDR/DDR write and Dummy instruction
assign cycle_cntr_max           = valid_operand_bits[6] ? valid_operand_bits[5:0]-1: data_cycle_cntr ;
//According to the number of pins, data from the input data bus(operand) will be shifted before transferring it to memory
assign shiftval_calc            =  4'd1<< no_of_pins;
assign shiftval                 = ddr_en ? shiftval_calc<<1 : {1'b0,shiftval_calc};
//Indicates Chip sel is low 
assign jhr_cs_toggle           = jhr_cs_wait[6] & jhr_cs_wait[2]; //eheck for 'd68 value


assign stop_instrn_int = ((!csr_trigger) & |valid_operand_bits) ? (stop_instrn & ( (sclk_en & (!(|cycle_cntr)) & (!data_loaded)) || (rd_progress_d))) : stop_instrn;
// 133MHz freq is standard for JedecHardware reset;minimum 500ns as per JESD252 speci. i.e 500ns/(clock period of 133MHz) = 67.5 ~ 68
///////////////////////////////////////////////////////////////////////////////////////////////////////////
//FSM to control cmd/address/data transfer to memory
//Receives input from instruction handler
//According to the number of pins of the current input moves to the corresponding state.
///////////////////////////////////////////////////////////////////////////////////////////////////////////
always@*
begin
nxt_cs_setup_hold_cnt =  write_enable_redge ? CSS  : stop_cs_redge ? CSH :  ~|cs_setup_hold_cnt ? 2'h0 :
                         (write_enable || stop_cs) ? cs_setup_hold_cnt -2'h1 : cs_setup_hold_cnt ;
//nxt_shift_data          = data_loaded ? operand << shiftval : shift_data << shiftval;
nxt_shift_data          = (!stall_wr) &&  data_loaded ? operand << shiftval : shift_data << shiftval;
nxt_trigger_txfr        = write_enable_redge ? 1'b1 :  (~|cs_setup_hold_cnt && (~chip_sel)) ? 1'b0 : trigger_txfr;
//Normal condition ---> cycle cntr 1 - dummy instrn - End detected 
//If next is 1 cycle dummy ---> assert dummy end here itself
nxt_dummy_end          = (~|(cycle_cntr-8'h1) | (in_onecyc_en)) ? valid_operand_bits[6] : 1'b0;
nxt_data_loaded         = (stop_instrn_int | rd_progress) && (~|cycle_cntr)  ? 1'b0 :
                           data_ack || (stall_wr && (~|cycle_cntr)) || (trigger_txfr && ~|cs_setup_hold_cnt && (~chip_sel)) ? 
                          1'b1 : 1'b0;
//nxt_data_loaded         = data_ack || stall_wr || stall_wr_fedge || (trigger_txfr && ~|cs_setup_hold_cnt && (~chip_sel)) ? 
//                          1'b1 : 1'b0;

nxt_txfr_en            = ((stop_instrn_int | rd_progress) && (~|cycle_cntr))? 1'b0 :
                          (trigger_txfr && ~|cs_setup_hold_cnt && (~chip_sel)) ? 1'h1: txfr_en ;

nxt_cycle_cntr         = (stop_instrn_int | rd_progress |  (stall_wr && (~|cycle_cntr))) ? 8'b0 :
                         (~|cycle_cntr) ? {2'b0,cycle_cntr_max} :  
                          txfr_en && (|cycle_cntr)? (cycle_cntr -8'h1) : cycle_cntr; 

nxt_stop_cs            = (stop_cs_d && ~|cs_setup_hold_cnt) ? 1'b0 :
                         ((!chip_sel) & stop_instrn_int & (~|cycle_cntr)) ? 1'b1 : stop_cs;

nxt_chip_sel           = (jhr_en_reg & !bits_tx_flag) ? 1'b0 :   
                         (bits_tx_flag & jhr_cs_toggle) ? ~chip_sel :
			 (bits_tx_flag) ? chip_sel :         
			  write_enable_redge ? 1'b0 : 
                         (stop_cs_d && ~|cs_setup_hold_cnt) ? 1'b1 : chip_sel;
nxt_stall_wr_in_progress = stall_wr_fedge ? 1'b0 : ( (~|cycle_cntr) ? (stall_wr_redge ? 1'b1 : stall_wr_in_progress) : stall_wr_in_progress);
nxt_sclk_en             = ((~|cycle_cntr)  && (stall_wr | stop_instrn_int | jhr_en_reg | rd_clk_stretch_redge| rd_done | csr_read_end)) ? 1'b0 :
                          (txfr_en_redge | stall_wr_fedge | rd_clk_stretch_fedge) && (!chip_sel) && (!stop_cs)? 1'b1 : sclk_en;

//nxt_sclk_en             = ((~|cycle_cntr)  && (stall_wr_redge | stop_instrn_int | jhr_en_reg | rd_clk_stretch_redge| rd_done | csr_read_end)) ? 1'b0 :
//                          (txfr_en_redge | (stall_wr_fedge_d) | rd_clk_stretch_fedge) ? 1'b1 : sclk_en;

nxt_jhr_en_reg		= jhr_en ? 1'b1 : jhr_cntr[2] ? 1'b0 : jhr_en_reg; // four times CHIP sel has to be asserted and deasserted
nxt_bits_tx_flag	= (jhr_en_reg & !bits_tx_flag) ? 1'b1 : jhr_cntr[2] ? 1'b0 : bits_tx_flag;
nxt_jhr_cs_wait        = (jhr_cs_toggle)? 7'd0 : (bits_tx_flag & !jhr_cntr[2]) ? jhr_cs_wait + 7'd1 : jhr_cs_wait; //both low and high time counter
//nxt_data_loaded         = data_ack ||  (trigger_txfr && ~|cs_setup_hold_cnt && (~chip_sel)) ? 
//                          1'b1 : txfr_en || stall_wr_end ? 1'b0 :  data_loaded;

//nxt_cycle_cntr         = (stop_instrn_int | rd_progress |  stall_wr_in_progress) ? 8'b0 :
//                         (txfr_en_redge || (~|cycle_cntr) ) ? {2'b0,cycle_cntr_max} :  
//                          txfr_en ? (cycle_cntr -8'h1) : cycle_cntr; 

//nxt_stop_cs            = (stop_cs_d && ~|cs_setup_hold_cnt) ? 1'b0 :
//                         (stop_instrn_int && (txfr_en | rd_progress_d)) ? 1'b1 : stop_cs;


end


always@(posedge mem_clk or negedge reset_n)
begin
 if(!reset_n)
 begin
 dq_out <= 16'h0;
 jhr_cntr <= 3'd0;
 end

 else if(!bits_tx_flag && jhr_en_reg) 
 begin
   dq_out <= 16'd0;
   jhr_cntr <= 3'd0;
 end

 else if(bits_tx_flag) 
 begin
   dq_out[0] <= (chip_sel & jhr_cs_toggle) ? !dq_out[0] : dq_out[0];
   dq_out[8] <= (chip_sel & jhr_cs_toggle) ? !dq_out[8] : dq_out[8];
   jhr_cntr  <= (chip_sel & jhr_cs_toggle) ? jhr_cntr + 1'b1 : jhr_cntr;
 end
 else if (stop_instrn_int | rd_progress | (stall_wr && (~|cycle_cntr)))
   dq_out  <= dq_out;
 else if(valid_operand_bits[6]) // specific to dummy
 begin 
   dq_out[7:0]  <= operand[47:40];
   dq_out[15:8] <= operand[47:40];
   jhr_cntr 	<= 3'd0;
 end
 else 
 begin
 jhr_cntr <= 3'd0;
 if(no_of_pins ==2'h0)
 begin
   if(ddr_en)
     begin dq_out[0] <= data_loaded ? operand[47] : shift_data[47];
           dq_out[8] <= data_loaded ? operand[46] : shift_data[46];
     end             
   else
     begin dq_out[0]   <= data_loaded ? operand[47] : shift_data[47];
           dq_out[8]   <= data_loaded ? operand[47] : shift_data[47];
     end
 end//1pin mode ends
 else if(no_of_pins ==2'h1) 
 begin
   if(ddr_en)
     begin dq_out[1:0] <= data_loaded ? operand[47:46] : shift_data[47:46];
           dq_out[9:8] <= data_loaded ? operand[45:44] : shift_data[45:44]; 
     end
   else
     begin dq_out[1:0] <= data_loaded ? operand[47:46] : shift_data[47:46];
           dq_out[9:8] <= data_loaded ? operand[47:46] : shift_data[47:46];
     end 
 end//2pin ends
 else if(no_of_pins ==2'h2)  
 begin
   if(ddr_en)
     begin dq_out[3:0]  <= data_loaded ? operand[47:44] : shift_data[47:44];
           dq_out[11:8] <= data_loaded ? operand[43:40] : shift_data[43:40]; 
     end
   else
     begin dq_out[3:0]   <= data_loaded ? operand[47:44] : shift_data[47:44];
           dq_out[11:8]  <= data_loaded ? operand[47:44] : shift_data[47:44];
     end
 end//4pin ends
 else // if(no_of_pins ==2'h3)  
 begin
   if(ddr_en)  
     begin dq_out[7:0]  <= data_loaded ? operand[47:40] : shift_data[47:40];
           dq_out[15:8] <= data_loaded ? operand[39:32] : shift_data[39:32];
     end
   else
     begin dq_out[7:0]   <= data_loaded ? operand[47:40] : shift_data[47:40];
           dq_out[15:8]  <= data_loaded ? operand[47:40] : shift_data[47:40];
     end
 end//8pin ends
end//else condition ends
end//always ends


always@(posedge mem_clk or negedge reset_n)
begin
  if(!reset_n)
    dq_oe <= 16'b0;
  else if(jhr_en_reg) //bits tx instruction //RSR
  begin
    dq_oe[0] <= 1'b1;
    dq_oe[8] <= 1'b1;
  end
  else if (stop_instrn_int | rd_progress)
    dq_oe <= 16'b0;
  else if (valid_operand_bits[6])
  begin
    dq_oe[7:0]   <= operand[32] ? {~dummy_cyc_HiZ[7:1],1'b1} : ~dummy_cyc_HiZ[7:0]; //XIP mode intimation
    dq_oe[15:8]   <= operand[32] ? {~dummy_cyc_HiZ[7:1],1'b1} : ~dummy_cyc_HiZ[7:0]; 
  end //Dummy ends 

  else if(txfr_en) //normal data
  begin
    if(no_of_pins == 2'h0) 
    begin
      dq_oe[0]   <= txfr_en; 
      dq_oe[8]   <= txfr_en;  
    end
    else if(no_of_pins == 2'h1) 
    begin
      dq_oe[1:0]   <= {2{txfr_en}};
      dq_oe[9:8]   <= {2{txfr_en}};
    end
    else if(no_of_pins == 2'h2) 
    begin
      dq_oe[3:0]   <= {4{txfr_en}};
      dq_oe[11:8]   <= {4{txfr_en}};
    end
    else //if(no_of_pins == 2'h3) 
    begin
      dq_oe[7:0]   <={8{txfr_en}};
      dq_oe[15:8]   <={8{txfr_en}}; 
    end
   end//normal data ends
  else
    dq_oe <=16'b0;
end

endmodule
