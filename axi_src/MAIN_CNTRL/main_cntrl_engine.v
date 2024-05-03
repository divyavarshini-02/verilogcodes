

module  main_cntrl_engine
     (
  //Global inputs
    mem_clk,                      
    mem_rst_n,                    
  
  //From AXI4_SLV_CNTRL - mem_clk
    slv_mem_cmd_input,            
    slv_mem_addr,                 
    slv_arb_bytes_len,                  
    slv_mem_err,                  
    slv_mem_write,                
    slv_mem_axi_len,              
    slv_mem_burst,                
    slv_mem_size,                 
    slv_mem_cont_rd_req,
    slv_mem_cont_wr_req,
    slv_mem_wlast,          
                                   
  //TO AXI4 SLV CNTRL              
    mem_slv_cmd_ready,   // only after aserting ready, the write data packer places wvalid         
    current_xfer,       
  
//TO Instruction handler
wait_subseq_pg_wr,
//From csr instruction handler - mem_clk - pulse
    csr_cmd_xfer_valid_final,     
    csr_rd_xfer_valid_final,  
    spl_instrn_stall, 
  
  
//From CSR - axi_clk

    page_incr_en,
    hyperflash_en,
    mem_page_size,
    dual_seq_mode,
    cont_read_auto_status_en,

    cmd_no_of_opcode,             
    cmd_xfer_data_rate,           
    cmd_no_of_pins,               
    cmd_opcode,                   
    wr_data_en         ,
    wdata_no_of_pins,
    wdata_xfer_data_rate,
    no_of_wr_data_bytes,
    wr_rd_data_1,
    wr_rd_data_2,

    read_cmd_opcode,
    read_no_of_pins,
    read_xfer_data_rate,
    read_cmd_data_rate,
    read_no_of_opcode,
    no_of_csr_rd_data_bytes,
    no_of_csr_rd_addr_bytes,
    rd_monitor_bit,
    rd_monitor_value,
    rd_monitor_en,   
    subseq_rd_xfer_time,

    status_cmd_opcode,    
    status_no_of_pins,    
    status_xfer_data_rate,
    status_cmd_data_rate,
    status_no_of_opcode,
    status_monitor_bit,
    status_monitor_value,
    status_monitor_en,
    no_of_auto_status_rd_data_bytes,
    subseq_status_rd_xfer_time,
    auto_status_rd_addr_bytes,
    auto_initiate_status_read_seq,
    status_reg_rd_xfer_time,
    auto_initiate_status_addr,

    write_en_seq_reg_1,           
    write_en_seq_reg_2,     
    write_dis_seq_reg_1,          
    write_dis_seq_reg_2,   

    status_reg_en, // specific to hyperflash

//To csr
   csr_cmd_xfer_ack_pulse, //pulse - asserted when the write transfer busy FEDGE is detected
   csr_cmd_xfer_success_pulse, //pulse - asserted when the write trasnfer busy FEDGE is detected (if auto inistated status reg read is disabled);asserted when the auto status register read has succesfully monitored the required value (if auto inistated status reg read is enabled);
   mem_xfer_auto_status_rd_done_pulse, //asserted after automated status read for AXI write transfers
   csr_rd_xfer_ack_pulse,//pulse 
   csr_rd_xfer_success_pulse,//pulse - asserted after csr_bsy_fedge for the status register read
   monitoring_xfer,
  
//From SEQ_RAM_READER - mem_clk
    wr_seq_valid,      // level           
    wr_seq_0,                     
    wr_seq_1,                     
    wr_seq_2,                     
    wr_seq_3,                     
    rd_seq_valid,     // level 
    rd_seq_0,                     
    rd_seq_1,                     
    rd_seq_2,                     
    rd_seq_3,                     
  
//To Memory xfer interface - mem_clk
    axi_start_mem_xfer_valid,           
    addr_mem_xfer,       // in case of address instruction the data will be sent from addr_mem_xfer         
    rw_len_mem_xfer,  // useful only during wrap write            
    xfer_mem_error,               
    xfer_wr_rd,                   
    xfer_axi_len,                 
    xfer_btype,                   
    xfer_bsize,                   
    cont_rd_req,                                                   
    cont_wr_req,                                                   
    csr_start_mem_xfer_valid,           
    no_of_data_bytes,
    no_of_xfer,
    seq_reg_0,                    
    seq_reg_1,                    
    seq_reg_2,                    
    seq_reg_3,                    
    dual_seq_mode_reg,                    
    auto_initiate, //the MEM_XFER_INTF expects ack for rd_data_valid assertion since CSR and MC both consumes the valid, the MC uses the ack based on auto_initiate if it is 1 ack from MC , else ack from CSR               
   auto_initiate_write_en_seq,
   auto_initiate_write_en_seq_2, // if set indicates it is hyperflash
   auto_initiate_post_wren_seq,
   post_wren_seq_data,
   auto_initiate_write_dis_seq,
//level signal to MEM_XFER_INTF - deassert when enter_jump_on_cs is deasserted; assertion condition- rd->wr; wrap rd-> incr rd; incr rd->wrap rd; rd_seq_id change
    seq_change, 
  
//From Memory xfer interface - mem_clk
    mem_rd_valid,
    mem_rd_data,
    csr_dqs_non_toggle_err,
    enter_jump_on_cs,
    axi_start_mem_xfer_ack,       
    csr_start_mem_xfer_ack,       
    csr_mem_xfer_bsy,             
    subseq_pg_wr, 
    deassert_cs,
    dual_seq_mode_ack,
    rd_done            
     );

parameter MEM_AXI_ADDR_WIDTH = 32;
parameter MEM_AXI_DATA_WIDTH = 32;

localparam WRAP = 2'b10;
localparam INCR = 2'b01;

localparam NO_OF_SEQ = 10;
localparam XFER_LEN_WIDTH    = MEM_AXI_DATA_WIDTH==32 ? 11 : MEM_AXI_DATA_WIDTH==64 ? 12 : 13 ; // reduntant;; 

// FSM states
localparam IDLE                = 4'h0;
localparam INCR_WR             = 4'h1;
localparam INCR_RD             = 4'h2;
localparam WRAP_WR_1           = 4'h3; // reduced to single wrap write transfer; start address given is aligened to wrap boundary start address
//localparam WRAP_WR_2           = 4'h4;
localparam WRAP_RD             = 4'h5;
localparam WRITE_EN            = 4'h6;
localparam WRITE_DIS           = 4'h7;
//localparam REG_WRAP_CONFIG_WR  = 4'h8;
//localparam ERROR               = 4'h9;
localparam WAIT_AUTO_STATUS_XFER_SUCCESS   = 4'hA;
localparam WRITE_EN_2          = 4'hB;
localparam INCR_RD_MONITOR     = 4'hC;

//sequence engine instructions

localparam CMD      = 6'd1;
localparam ADDR     = 6'd2; 
localparam DUMMY    = 6'd3; 
localparam READ     = 6'd15;
localparam WRITE    = 6'd16;
localparam MODE     = 6'd4;
localparam ADDR_DDR = 6'd31;
localparam CMD_DDR  = 6'd32;
localparam READ_DDR = 6'd56;
localparam WRITE_DDR = 6'd60;
localparam CA        = 6'd61;
localparam CMD16_DDR = 6'd63;

//Global inputs

input   mem_clk;
input   mem_rst_n;

//FROM AXI4 SLV CNTRL
   
input                           slv_mem_cmd_input;
input  [MEM_AXI_ADDR_WIDTH-1:0] slv_mem_addr;
input  [XFER_LEN_WIDTH-1:0]     slv_arb_bytes_len;
input                           slv_mem_err;
input                           slv_mem_write;
input  [7:0]                    slv_mem_axi_len;
input  [1:0]                    slv_mem_burst;
input  [2:0]                    slv_mem_size;
input                           slv_mem_cont_rd_req;
input                           slv_mem_cont_wr_req;
input				slv_mem_wlast;

//TO AXI4 SLV CNTRL
output       mem_slv_cmd_ready; 
output       current_xfer; 

//TO Instruction handler
output wait_subseq_pg_wr;
//From csr instruction handler - mem_clk - pulse
input        csr_cmd_xfer_valid_final;
input        csr_rd_xfer_valid_final;  
input        spl_instrn_stall;

//From CSR - axi_clk

input        page_incr_en;
input	     hyperflash_en;
input [3:0]  mem_page_size;
input        dual_seq_mode;
input        cont_read_auto_status_en;

input        cmd_no_of_opcode;
input        cmd_xfer_data_rate;
input [1:0]  cmd_no_of_pins;
input [15:0] cmd_opcode;
input        wr_data_en;
input [1:0]  wdata_no_of_pins    ;
input        wdata_xfer_data_rate;
input [5:0]  no_of_wr_data_bytes;
input [31:0]                      wr_rd_data_1;
input [31:0]                      wr_rd_data_2;

input [15:0] read_cmd_opcode;
input [1:0]  read_no_of_pins;
input        read_xfer_data_rate;
input        read_cmd_data_rate;
input        read_no_of_opcode;
input [2:0]  no_of_csr_rd_addr_bytes;
input [6:0]  no_of_csr_rd_data_bytes;
input [2:0]  rd_monitor_bit ;
input        rd_monitor_value ;
input        rd_monitor_en;
input [17:0] subseq_rd_xfer_time;

input [15:0] status_cmd_opcode;
input [1:0]  status_no_of_pins;
input        status_xfer_data_rate;
input        status_cmd_data_rate;
input        status_no_of_opcode;
input [2:0]  status_monitor_bit ;
input        status_monitor_value ;
input        status_monitor_en;
input [2:0]  no_of_auto_status_rd_data_bytes;
input [17:0] subseq_status_rd_xfer_time;
input [2:0]  auto_status_rd_addr_bytes;
input        auto_initiate_status_read_seq;
input [30:0] status_reg_rd_xfer_time;
input [31:0] auto_initiate_status_addr;

input auto_initiate_write_en_seq;
input        auto_initiate_write_en_seq_2;
input        auto_initiate_post_wren_seq;
input [15:0] post_wren_seq_data;
input auto_initiate_write_dis_seq;
input [31:0] write_en_seq_reg_1;
input [31:0] write_en_seq_reg_2;
input [31:0] write_dis_seq_reg_1;
input [31:0] write_dis_seq_reg_2;

input status_reg_en;


//To csr
output   csr_cmd_xfer_ack_pulse; //pulse
output   csr_cmd_xfer_success_pulse; //pulse
output   mem_xfer_auto_status_rd_done_pulse; //pulse
output   csr_rd_xfer_ack_pulse;//pulse
output   csr_rd_xfer_success_pulse;//pulse
output   monitoring_xfer; 

//From SEQ_RAM_READER - mem_clk
input          wr_seq_valid;                 
input [31:0]   wr_seq_0;                     
input [31:0]   wr_seq_1;                     
input [31:0]   wr_seq_2;                     
input [31:0]   wr_seq_3;                     
input          rd_seq_valid; 
input [31:0]   rd_seq_0;                     
input [31:0]   rd_seq_1;                     
input [31:0]   rd_seq_2;                     
input [31:0]   rd_seq_3;                     
  
//To Memory xfer interface - mem_clk
output                            axi_start_mem_xfer_valid;           
output   [MEM_AXI_ADDR_WIDTH-1:0] addr_mem_xfer;                
output   [4:0]rw_len_mem_xfer;              
output                       xfer_mem_error;               
output                       xfer_wr_rd;                   
output   [7:0]               xfer_axi_len;                 
output   [1:0]               xfer_btype;                   
output   [2:0]               xfer_bsize;                   
output                       cont_rd_req;                  
output                       cont_wr_req;                  
                                         
output                       csr_start_mem_xfer_valid;           
output [5:0]                 no_of_data_bytes;
output [1:0]	             no_of_xfer;
  
output [31:0]    seq_reg_0;                    
output [31:0]    seq_reg_1;                    
output [31:0]    seq_reg_2;                    
output [31:0]    seq_reg_3;                    

output           auto_initiate;                

output           seq_change;
output           dual_seq_mode_reg;
  
//From Memory xfer interface - mem_clk
input    mem_rd_valid;
input [31:0]    mem_rd_data;
input   csr_dqs_non_toggle_err;
input    enter_jump_on_cs;
input    axi_start_mem_xfer_ack;
input    csr_start_mem_xfer_ack;       
input    csr_mem_xfer_bsy;             
input    subseq_pg_wr;   
input    deassert_cs;
input    dual_seq_mode_ack;
input    rd_done;        

//-------------------------------------REG declaration-------------------------------------------------

reg [5:0] no_of_data_bytes, nxt_no_of_data_bytes;
reg nxt_wrap_addr_valid  , wrap_addr_valid;
reg [1:0]  nxt_no_of_xfer       , no_of_xfer;      
reg [MEM_AXI_ADDR_WIDTH-1:0] nxt_wrap_xfer_addr_1 , wrap_xfer_addr_1;
reg [4:0]  nxt_wrap_xfer_len_1  , wrap_xfer_len_1; 
reg [MEM_AXI_ADDR_WIDTH-1:0] nxt_wrap_xfer_addr_2 , wrap_xfer_addr_2;
reg [4:0]  nxt_wrap_xfer_len_2  , wrap_xfer_len_2; 
reg axi_xfer,axi_xfer_reg, nxt_axi_xfer_reg;
reg csr_xfer,csr_xfer_reg, nxt_csr_xfer_reg;
reg start_xfer;
reg [(NO_OF_SEQ*4)-1:0] seq_path;

reg                          seq_change, nxt_seq_change;
reg nxt_csr_cmd_xfer_valid_final_reg , csr_cmd_xfer_valid_final_reg;
reg nxt_csr_rd_xfer_valid_final_reg , csr_rd_xfer_valid_final_reg;
reg                          cur_mem_mode_wr, nxt_mem_mode_wr;
reg                          final_xfer, nxt_final_xfer;
reg                          axi_start_mem_xfer_valid, nxt_axi_start_mem_xfer_valid;
reg                          csr_start_mem_xfer_valid, nxt_csr_start_mem_xfer_valid;
reg csr_cmd_xfer_ack_pulse       , nxt_csr_cmd_xfer_ack_pulse        ; 
reg csr_cmd_xfer_success_pulse   , nxt_csr_cmd_xfer_success_pulse    ; 
reg mem_xfer_auto_status_rd_done_pulse   , nxt_mem_xfer_auto_status_rd_done_pulse    ; 
reg csr_rd_xfer_ack_pulse    , nxt_csr_rd_xfer_ack_pulse     ;
reg csr_rd_xfer_success_pulse, nxt_csr_rd_xfer_success_pulse ;
reg [3:0]                    pres_state, nxt_state;
reg [(NO_OF_SEQ*4)-1:0]      seq_path_reg, nxt_seq_path_reg; 
reg [1:0]                    cont_wr_check_cnt, nxt_cont_wr_check_cnt;
reg [31:0]                   seq_reg_0, nxt_seq_reg_0;
reg [31:0]                   seq_reg_1, nxt_seq_reg_1;
reg [31:0]                   seq_reg_2, nxt_seq_reg_2;
reg [31:0]                   seq_reg_3, nxt_seq_reg_3;
reg                          auto_initiate, nxt_auto_initiate;
reg [MEM_AXI_ADDR_WIDTH-1:0] addr_mem_xfer  , nxt_addr_mem_xfer;
reg [MEM_AXI_ADDR_WIDTH-1:0] wr_addr_reg   , nxt_wr_addr_reg;
reg [4:0]     rw_len_mem_xfer, nxt_rw_len_mem_xfer;
reg                          xfer_mem_error, nxt_xfer_mem_error;
reg                          xfer_wr_rd, nxt_xfer_wr_rd;
reg [7:0]                    xfer_axi_len   , nxt_xfer_axi_len;
reg [1:0]                    xfer_btype     , nxt_xfer_btype;
reg [2:0]                    xfer_bsize     , nxt_xfer_bsize;
reg                          cont_rd_req    , nxt_cont_rd_req;
reg                          cont_wr_req    , nxt_cont_wr_req;
reg                          wait_for_xfer_cmplt, nxt_wait_for_xfer_cmplt;

reg [1:0]      nxt_subseq_btype_reg , subseq_btype_reg;
reg [2:0]      nxt_subseq_bsize_reg , subseq_bsize_reg;

reg [7:0] nxt_wrap_axi_len_reg   , wrap_axi_len_reg;
reg [2:0] nxt_wrap_axi_bsize_reg , wrap_axi_bsize_reg;

reg  csr_mem_xfer_bsy_d1;

reg [30:0] check_status_reg_xfer_cmplt, nxt_check_status_reg_xfer_cmplt;
reg first_check,nxt_first_check;

//reg nxt_mem_rd_ack , mem_rd_ack;
reg status_en_flag, nxt_status_en_flag;
reg [7:0] subseq_pg_wr_cnt, nxt_subseq_pg_wr_cnt;
          //nxt_subseq_pg_wr_cnt      = | subseq_pg_wr_cnt ? subseq_pg_wr_cnt - 'd1 : subseq_pg_wr_cnt;
reg nxt_wait_subseq_pg_wr , wait_subseq_pg_wr;
reg wait_for_ack, nxt_wait_for_ack;
reg post_wren_flag, nxt_post_wren_flag;
reg csr_cmd_xfer_ack_level, nxt_csr_cmd_xfer_ack_level;
reg deassert_cs_reg, nxt_deassert_cs_reg;
reg dual_seq_mode_reg, nxt_dual_seq_mode_reg;

//-------------------------------------WIRE declaration -----------------------------------------------

wire [MEM_AXI_ADDR_WIDTH-1:0] slv_mem_addr_final;
wire  [2:0]                             axi_shift_len;
wire [6:0] axi4_wrap_size_req;
wire csr_mem_xfer_bsy_fedge; 
wire current_xfer;
wire slv_mem_cmd_valid; 
wire status_monitor_true;
wire rd_monitor_true;

assign main_cntrl_idle_state = (pres_state ==IDLE);

assign slv_mem_addr_final = |slv_mem_addr[1:0] ?  {slv_mem_addr[MEM_AXI_ADDR_WIDTH-1:2],2'b11} :slv_mem_addr; // move the address to the boundary of 4 byte aligned address

wire [MEM_AXI_ADDR_WIDTH-1:0] slv_mem_addr_end;
reg [7:0] no_of_csr_rd_addr_bits;
reg [7:0] no_of_auto_status_rd_addr_bits;
assign slv_mem_addr_end  = slv_mem_addr + slv_arb_bytes_len;

assign axi_shift_len   = (slv_mem_axi_len == 8'h1 ) ? 3'd1 : 
                         (slv_mem_axi_len == 8'h3 ) ? 3'd2 :
                         (slv_mem_axi_len == 8'h7 ) ? 3'd3 :
                         (slv_mem_axi_len == 8'hf ) ? 3'd4 : 3'd1 ;
assign axi4_wrap_size_req  = (7'd1<< slv_mem_size) <<  axi_shift_len ;
assign csr_mem_xfer_bsy_fedge = (!csr_mem_xfer_bsy) & csr_mem_xfer_bsy_d1;
assign current_xfer = |pres_state;
assign slv_mem_cmd_valid = slv_mem_cmd_input & !spl_instrn_stall;
wire [4:0] status_monitor_bit_final;
assign status_monitor_bit_final = status_monitor_bit + (no_of_auto_status_rd_data_bytes<<3);
assign status_monitor_true = status_monitor_en & !(mem_rd_data[status_monitor_bit_final] ^ status_monitor_value); 
assign rd_monitor_true = rd_monitor_en & !(mem_rd_data[rd_monitor_bit] ^ rd_monitor_value);

wire monitoring_xfer;
assign monitoring_xfer = (pres_state==WAIT_AUTO_STATUS_XFER_SUCCESS & status_monitor_en) || (pres_state==INCR_RD_MONITOR);

//mem_wrap_size - 8,16,32,64
always @*
begin

 case (no_of_csr_rd_addr_bytes)
 3'd1: no_of_csr_rd_addr_bits = 8'd8;
 3'd2: no_of_csr_rd_addr_bits = 8'd16;
 3'd3: no_of_csr_rd_addr_bits = 8'd24;
 3'd4: no_of_csr_rd_addr_bits = 8'd32;
 default:
 no_of_csr_rd_addr_bits = 8'd0;
 endcase

 case (auto_status_rd_addr_bytes)
 3'd1: no_of_auto_status_rd_addr_bits = 8'd8;
 3'd2: no_of_auto_status_rd_addr_bits = 8'd16;
 3'd3: no_of_auto_status_rd_addr_bits = 8'd24;
 3'd4: no_of_auto_status_rd_addr_bits = 8'd32;
 default:
 no_of_auto_status_rd_addr_bits = 8'd0;
 endcase











end
always @ (posedge mem_clk or negedge mem_rst_n)
begin

if(~mem_rst_n)
begin
   no_of_data_bytes <= 6'd0;
   wrap_addr_valid  <= 1'b0; 
   no_of_xfer       <= 2'd0;
   wrap_xfer_addr_1 <= {MEM_AXI_ADDR_WIDTH{1'b0}};
   wrap_xfer_len_1  <= 5'd0;
   wrap_xfer_addr_2 <= {MEM_AXI_ADDR_WIDTH{1'b0}};
   wrap_xfer_len_2  <= 5'd0;
   seq_change       <= 1'b0;
   csr_cmd_xfer_valid_final_reg <= 1'b0;
   csr_rd_xfer_valid_final_reg  <= 1'b0;
   cur_mem_mode_wr            <= 1'b0; //default read
   final_xfer                 <= 1'b0;
   axi_start_mem_xfer_valid   <= 1'b0;
   csr_start_mem_xfer_valid   <= 1'b0;
   csr_cmd_xfer_ack_pulse        <= 1'b0; 
   csr_cmd_xfer_success_pulse    <= 1'b0; 
   mem_xfer_auto_status_rd_done_pulse    <= 1'b0; 
   csr_rd_xfer_ack_pulse     <= 1'b0;
   csr_rd_xfer_success_pulse <= 1'b0;
   pres_state                 <= IDLE;
   seq_path_reg               <= {(NO_OF_SEQ*4){1'b0}};
   cont_wr_check_cnt          <= 2'd0;
   seq_reg_0                  <= 32'd0; 
   seq_reg_1                  <= 32'd0; 
   seq_reg_2                  <= 32'd0; 
   seq_reg_3                  <= 32'd0; 
   auto_initiate              <= 1'b0; 
   addr_mem_xfer              <= {MEM_AXI_ADDR_WIDTH{1'b0}}; 
   wr_addr_reg              <= {MEM_AXI_ADDR_WIDTH{1'b0}}; 
   rw_len_mem_xfer            <= {5{1'b0}}; 
   xfer_mem_error             <= 1'b0; 
   xfer_wr_rd                 <= 1'b0;
   xfer_axi_len               <= 8'd0; 
   xfer_btype                 <= 2'd0;
   xfer_bsize                 <= 3'd0;
   subseq_btype_reg           <= 2'd0;
   subseq_bsize_reg           <= 3'd0;
   cont_rd_req                <= 1'b0;
   cont_wr_req                <= 1'b0;
   wait_for_xfer_cmplt        <= 1'b0;
wrap_axi_len_reg   <= 8'd0;
wrap_axi_bsize_reg <= 3'd0;
   csr_mem_xfer_bsy_d1        <= 1'b0;
   check_status_reg_xfer_cmplt <= 31'd0;
   first_check <= 1'b0;
   axi_xfer_reg               <= 1'b0; 
   csr_xfer_reg               <= 1'b0; 
   //mem_rd_ack      <= 1'b0;
   status_en_flag             <= 1'b0;
   subseq_pg_wr_cnt		      <= 8'd0;
   wait_subseq_pg_wr          <= 1'b0;
   wait_for_ack		      <= 1'b0;
   post_wren_flag	      <= 1'b0;
   csr_cmd_xfer_ack_level <= 1'b0;
   deassert_cs_reg	      <= 1'b0;
   dual_seq_mode_reg	      <= 1'b0;
   
end
else
begin
   no_of_data_bytes <= nxt_no_of_data_bytes;
   wrap_addr_valid  <= nxt_wrap_addr_valid;
   no_of_xfer       <= nxt_no_of_xfer;      
   wrap_xfer_addr_1 <= nxt_wrap_xfer_addr_1;
   wrap_xfer_len_1  <= nxt_wrap_xfer_len_1; 
   wrap_xfer_addr_2 <= nxt_wrap_xfer_addr_2;
   wrap_xfer_len_2  <= nxt_wrap_xfer_len_2; 
   seq_change       <= nxt_seq_change;
   csr_cmd_xfer_valid_final_reg <= nxt_csr_cmd_xfer_valid_final_reg;
   csr_rd_xfer_valid_final_reg  <= nxt_csr_rd_xfer_valid_final_reg ;
   cur_mem_mode_wr            <= nxt_mem_mode_wr;
   final_xfer                 <= nxt_final_xfer;
   axi_start_mem_xfer_valid   <= nxt_axi_start_mem_xfer_valid;
   csr_start_mem_xfer_valid   <= nxt_csr_start_mem_xfer_valid;
   csr_cmd_xfer_ack_pulse        <=  nxt_csr_cmd_xfer_ack_pulse       ;
   csr_cmd_xfer_success_pulse    <=  nxt_csr_cmd_xfer_success_pulse   ;
   mem_xfer_auto_status_rd_done_pulse    <=  nxt_mem_xfer_auto_status_rd_done_pulse   ;
   csr_rd_xfer_ack_pulse     <=  nxt_csr_rd_xfer_ack_pulse    ;
   csr_rd_xfer_success_pulse <=  nxt_csr_rd_xfer_success_pulse;
   pres_state                 <= nxt_state;
   seq_path_reg               <= nxt_seq_path_reg; 
   cont_wr_check_cnt          <= nxt_cont_wr_check_cnt;
   seq_reg_0                  <= nxt_seq_reg_0;
   seq_reg_1                  <= nxt_seq_reg_1;
   seq_reg_2                  <= nxt_seq_reg_2;
   seq_reg_3                  <= nxt_seq_reg_3;
   auto_initiate              <= nxt_auto_initiate;
   addr_mem_xfer              <= nxt_addr_mem_xfer;
   wr_addr_reg              <= nxt_wr_addr_reg;
   rw_len_mem_xfer            <= nxt_rw_len_mem_xfer;
   xfer_mem_error             <= nxt_xfer_mem_error;
   xfer_wr_rd                 <= nxt_xfer_wr_rd;   
   xfer_axi_len               <= nxt_xfer_axi_len;
   xfer_btype                 <= nxt_xfer_btype;
   xfer_bsize                 <= nxt_xfer_bsize;
   subseq_btype_reg           <= nxt_subseq_btype_reg ;
   subseq_bsize_reg           <= nxt_subseq_bsize_reg ;
   cont_rd_req                <= nxt_cont_rd_req;
   cont_wr_req                <= nxt_cont_wr_req;
   wait_for_xfer_cmplt        <= nxt_wait_for_xfer_cmplt;
wrap_axi_len_reg   <= nxt_wrap_axi_len_reg  ;
wrap_axi_bsize_reg <= nxt_wrap_axi_bsize_reg;
   csr_mem_xfer_bsy_d1        <= csr_mem_xfer_bsy;
   check_status_reg_xfer_cmplt <= nxt_check_status_reg_xfer_cmplt;
   first_check <= nxt_first_check;
   axi_xfer_reg               <= nxt_axi_xfer_reg; 
   csr_xfer_reg               <= nxt_csr_xfer_reg;
  // mem_rd_ack      <= nxt_mem_rd_ack;
   status_en_flag             <= nxt_status_en_flag;
   subseq_pg_wr_cnt		      <= nxt_subseq_pg_wr_cnt;
   wait_subseq_pg_wr          <= nxt_wait_subseq_pg_wr;
   wait_for_ack		      <= nxt_wait_for_ack;
   post_wren_flag	      <= nxt_post_wren_flag;
   csr_cmd_xfer_ack_level <= nxt_csr_cmd_xfer_ack_level;
   deassert_cs_reg	      <= nxt_deassert_cs_reg;
   dual_seq_mode_reg	      <= nxt_dual_seq_mode_reg;
end
end


//wrap write - number of split transfers calculation; Their address and length calulation
always @ *
begin

nxt_wrap_addr_valid  = wrap_addr_valid;
nxt_no_of_xfer       = no_of_xfer;      
nxt_wrap_xfer_addr_1 = wrap_xfer_addr_1;
nxt_wrap_xfer_len_1  = wrap_xfer_len_1; 
nxt_wrap_xfer_addr_2 = wrap_xfer_addr_2;
nxt_wrap_xfer_len_2  = wrap_xfer_len_2; 

if(slv_mem_cmd_valid & (slv_mem_burst==WRAP) & slv_mem_write & (!mem_slv_cmd_ready) & (!wrap_addr_valid)) // WRAP write
begin
   nxt_wrap_addr_valid  = 1'b1;
   case(axi4_wrap_size_req) // input AXI wrap size
   7'd8:   
   begin
      if((&slv_mem_addr_final[2:0]) ||  (!(|slv_mem_addr_final[2:0])) )// addr = 3'h7
      begin
         nxt_no_of_xfer       = 2'd1;
         nxt_wrap_xfer_addr_1 = {slv_mem_addr_final[MEM_AXI_ADDR_WIDTH-1:3],3'd0};
         nxt_wrap_xfer_len_1  = 5'd2;
         nxt_wrap_xfer_addr_2 = {MEM_AXI_ADDR_WIDTH{1'd0}};
         nxt_wrap_xfer_len_2  = 5'd0;
      end
      else
      begin
         nxt_no_of_xfer       = 2'd2;
         nxt_wrap_xfer_addr_1 = &slv_mem_addr_final[1:0] ? slv_mem_addr_final + 1 : slv_mem_addr_final;
         nxt_wrap_xfer_len_1  = 5'd1;
         nxt_wrap_xfer_addr_2 = {slv_mem_addr_final[MEM_AXI_ADDR_WIDTH-1:3],3'd0};
         nxt_wrap_xfer_len_2  = 5'd1;
      end
   end
   7'd16:   
   begin
      if((&slv_mem_addr_final[3:0]) ||  (!(|slv_mem_addr_final[3:0])) )// addr = 4'hF
      begin
         nxt_no_of_xfer       = 2'd1;
         nxt_wrap_xfer_addr_1 = {slv_mem_addr_final[MEM_AXI_ADDR_WIDTH-1:4],4'd0};
         nxt_wrap_xfer_len_1  = 5'd4;
         nxt_wrap_xfer_addr_2 = {MEM_AXI_ADDR_WIDTH{1'd0}};
         nxt_wrap_xfer_len_2  = 5'd0;
      end
      else
      begin
         nxt_no_of_xfer       = 2'd2;
         nxt_wrap_xfer_addr_1 = &slv_mem_addr_final[1:0] ? slv_mem_addr_final + 1 : slv_mem_addr_final;
         nxt_wrap_xfer_addr_2 = {slv_mem_addr_final[MEM_AXI_ADDR_WIDTH-1:4],4'd0};
         case(slv_mem_addr_final[3:0])
         4'h3, 4'h4 :
         begin
         nxt_wrap_xfer_len_1  = 5'd3;
         nxt_wrap_xfer_len_2  = 5'd1;
         end
         4'h7, 4'h8 :
         begin
         nxt_wrap_xfer_len_1  = 5'd2;
         nxt_wrap_xfer_len_2  = 5'd2;
         end
         4'hB, 4'hC :
         begin
         nxt_wrap_xfer_len_1  = 5'd1;
         nxt_wrap_xfer_len_2  = 5'd3;
         end
         default:
         begin
         nxt_wrap_xfer_len_1  = 5'd0;
         nxt_wrap_xfer_len_2  = 5'd0;
         end
         endcase
      end
   end
   7'd32:   
   begin
      if((&slv_mem_addr_final[4:0]) ||  (!(|slv_mem_addr_final[4:0])) )// addr = 5'h1F
      begin
         nxt_no_of_xfer       = 2'd1;
         nxt_wrap_xfer_addr_1 = {slv_mem_addr_final[MEM_AXI_ADDR_WIDTH-1:5],5'd0};
         nxt_wrap_xfer_len_1  = 5'd8;
         nxt_wrap_xfer_addr_2 = {MEM_AXI_ADDR_WIDTH{1'd0}};
         nxt_wrap_xfer_len_2  = 5'd0;
      end
      else
      begin
         nxt_no_of_xfer       = 2'd2;
         nxt_wrap_xfer_addr_1 = &slv_mem_addr_final[1:0] ? slv_mem_addr_final + 1 : slv_mem_addr_final;
         nxt_wrap_xfer_addr_2 = {slv_mem_addr_final[MEM_AXI_ADDR_WIDTH-1:5],5'd0};
         case(slv_mem_addr_final[4:0])
         5'h3, 5'h4 :
         begin
         nxt_wrap_xfer_len_1  = 5'd7;
         nxt_wrap_xfer_len_2  = 5'd1;
         end
         5'h7, 5'h8 :
         begin
         nxt_wrap_xfer_len_1  = 5'd6;
         nxt_wrap_xfer_len_2  = 5'd2;
         end
         5'hB, 5'hC :
         begin
         nxt_wrap_xfer_len_1  = 5'd5;
         nxt_wrap_xfer_len_2  = 5'd3;
         end
         5'hF, 5'h10 :
         begin
         nxt_wrap_xfer_len_1  = 5'd4;
         nxt_wrap_xfer_len_2  = 5'd4;
         end
         5'h13, 5'h14 :
         begin
         nxt_wrap_xfer_len_1  = 5'd3;
         nxt_wrap_xfer_len_2  = 5'd5;
         end
         5'h17, 5'h18 :
         begin
         nxt_wrap_xfer_len_1  = 5'd2;
         nxt_wrap_xfer_len_2  = 5'd6;
         end
         5'h1B, 5'h1C :
         begin
         nxt_wrap_xfer_len_1  = 5'd1;
         nxt_wrap_xfer_len_2  = 5'd7;
         end
         default:
         begin
         nxt_wrap_xfer_len_1  = 5'd0;
         nxt_wrap_xfer_len_2  = 5'd0;
         end
         endcase
      end
   end
   7'd64:   
   begin
      if((&slv_mem_addr_final[5:0]) ||  (!(|slv_mem_addr_final[5:0])) )// addr = 6'h3F
      begin
         nxt_no_of_xfer       = 2'd1;
         nxt_wrap_xfer_addr_1 = {slv_mem_addr_final[MEM_AXI_ADDR_WIDTH-1:6],6'd0};
         nxt_wrap_xfer_len_1  = 5'd16;
         nxt_wrap_xfer_addr_2 = {MEM_AXI_ADDR_WIDTH{1'd0}};
         nxt_wrap_xfer_len_2  = 5'd0;
      end
      else
      begin
         nxt_no_of_xfer       = 2'd2;
         nxt_wrap_xfer_addr_1 = &slv_mem_addr_final[1:0] ? slv_mem_addr_final + 1 : slv_mem_addr_final;
         nxt_wrap_xfer_addr_2 = {slv_mem_addr_final[MEM_AXI_ADDR_WIDTH-1:6],6'd0};
         case(slv_mem_addr_final[5:0])
         6'h3, 6'h4 :
         begin
         nxt_wrap_xfer_len_1  = 5'd15;
         nxt_wrap_xfer_len_2  = 5'd1;
         end
         6'h7, 6'h8 :
         begin
         nxt_wrap_xfer_len_1  = 5'd14;
         nxt_wrap_xfer_len_2  = 5'd2;
         end
         6'hB, 6'hC :
         begin
         nxt_wrap_xfer_len_1  = 5'd13;
         nxt_wrap_xfer_len_2  = 5'd3;
         end
         6'hF, 6'h10 :
         begin
         nxt_wrap_xfer_len_1  = 5'd12;
         nxt_wrap_xfer_len_2  = 5'd4;
         end
         6'h13, 6'h14 :
         begin
         nxt_wrap_xfer_len_1  = 5'd11;
         nxt_wrap_xfer_len_2  = 5'd5;
         end
         6'h17, 6'h18 :
         begin
         nxt_wrap_xfer_len_1  = 5'd10;
         nxt_wrap_xfer_len_2  = 5'd6;
         end
         6'h1B, 6'h1C :
         begin
         nxt_wrap_xfer_len_1  = 5'd9;
         nxt_wrap_xfer_len_2  = 5'd7;
         end
         6'h1F, 6'h20 :
         begin
         nxt_wrap_xfer_len_1  = 5'd8;
         nxt_wrap_xfer_len_2  = 5'd8;
         end
         6'h23, 6'h24 :
         begin
         nxt_wrap_xfer_len_1  = 5'd7;
         nxt_wrap_xfer_len_2  = 5'd9;
         end
         6'h27, 6'h28 :
         begin
         nxt_wrap_xfer_len_1  = 5'd6;
         nxt_wrap_xfer_len_2  = 5'd10;
         end
         6'h2B, 6'h2C :
         begin
         nxt_wrap_xfer_len_1  = 5'd5;
         nxt_wrap_xfer_len_2  = 5'd11;
         end
         6'h2F, 6'h30 :
         begin
         nxt_wrap_xfer_len_1  = 5'd4;
         nxt_wrap_xfer_len_2  = 5'd12;
         end
         6'h33, 6'h34 :
         begin
         nxt_wrap_xfer_len_1  = 5'd3;
         nxt_wrap_xfer_len_2  = 5'd13;
         end
         6'h37, 6'h38 :
         begin
         nxt_wrap_xfer_len_1  = 5'd2;
         nxt_wrap_xfer_len_2  = 5'd14;
         end
         6'h3B, 6'h3C :
         begin
         nxt_wrap_xfer_len_1  = 5'd1;
         nxt_wrap_xfer_len_2  = 5'd15;
         end
         default:
         begin
         nxt_wrap_xfer_len_1  = 5'd0;
         nxt_wrap_xfer_len_2  = 5'd0;
         end
         endcase
      end
   end
   endcase
end
else if (slv_mem_cmd_valid & mem_slv_cmd_ready)
begin
   nxt_wrap_addr_valid  = 1'b0;
   nxt_no_of_xfer       = 2'd0;
   nxt_wrap_xfer_addr_1 = {MEM_AXI_ADDR_WIDTH{1'd0}};
   nxt_wrap_xfer_addr_2 = {MEM_AXI_ADDR_WIDTH{1'd0}};
   nxt_wrap_xfer_len_1  = 5'd0;
   nxt_wrap_xfer_len_2  = 5'd0;
end
else 
begin
   nxt_wrap_addr_valid  = wrap_addr_valid ; 
   nxt_no_of_xfer       = no_of_xfer      ;
   nxt_wrap_xfer_addr_1 = wrap_xfer_addr_1;
   nxt_wrap_xfer_addr_2 = wrap_xfer_addr_2;
   nxt_wrap_xfer_len_1  = wrap_xfer_len_1 ;
   nxt_wrap_xfer_len_2  = wrap_xfer_len_2 ;
end
end

// sequence path calculation 
always @ *
begin

nxt_seq_change = enter_jump_on_cs ?  ( (wr_seq_valid||rd_seq_valid) ? seq_change : 1'b1  ) : 1'b0;
nxt_csr_cmd_xfer_valid_final_reg = main_cntrl_idle_state ? 1'b0 : csr_cmd_xfer_valid_final ? 1'b1 : csr_cmd_xfer_valid_final_reg;
nxt_csr_rd_xfer_valid_final_reg = main_cntrl_idle_state ? 1'b0 : csr_rd_xfer_valid_final ? 1'b1 : csr_rd_xfer_valid_final_reg;
seq_path = {NO_OF_SEQ*4{1'b0}};
csr_xfer   = 1'b0;
axi_xfer   = 1'b0;
start_xfer = 1'b0;

if((csr_cmd_xfer_valid_final || csr_cmd_xfer_valid_final_reg)  & main_cntrl_idle_state) // CSR INITIATED COMMAND ONLY XFER -pulse
begin
   nxt_csr_cmd_xfer_valid_final_reg = 1'b0;
   start_xfer = 1'b1;
       axi_xfer   = 1'b0;
   csr_xfer   = 1'b1;
   //nxt_seq_change = enter_jump_on_cs ?  1'b1 : seq_change;
   
   seq_path       = auto_initiate_write_en_seq_2 && auto_initiate_status_read_seq  ? 
   (auto_initiate_write_dis_seq ? {WRITE_EN,WRITE_EN_2,INCR_WR,WRITE_DIS,WAIT_AUTO_STATUS_XFER_SUCCESS, IDLE,{((NO_OF_SEQ*4)-(6*4)){1'b0}}} : 
                                  {WRITE_EN,WRITE_EN_2,INCR_WR,WAIT_AUTO_STATUS_XFER_SUCCESS, IDLE,{((NO_OF_SEQ*4)-(5*4)){1'b0}}} ) :
   auto_initiate_write_en_seq && auto_initiate_status_read_seq  ? 
     (auto_initiate_write_dis_seq ? {WRITE_EN,INCR_WR,WRITE_DIS,WAIT_AUTO_STATUS_XFER_SUCCESS, IDLE,{((NO_OF_SEQ*4)-(5*4)){1'b0}}} :
                                   {WRITE_EN,INCR_WR,WAIT_AUTO_STATUS_XFER_SUCCESS, IDLE,{((NO_OF_SEQ*4)-(4*4)){1'b0}}} ) :
   (!auto_initiate_write_en_seq) && auto_initiate_status_read_seq ? 
      (auto_initiate_write_dis_seq ? {INCR_WR,WRITE_DIS,WAIT_AUTO_STATUS_XFER_SUCCESS, IDLE,{((NO_OF_SEQ*4)-(4*4)){1'b0}}} : 
                                    {INCR_WR,WAIT_AUTO_STATUS_XFER_SUCCESS, IDLE,{((NO_OF_SEQ*4)-(3*4)){1'b0}}} )         :
   auto_initiate_write_en_seq_2 && !auto_initiate_status_read_seq  ? {WRITE_EN,WRITE_EN_2,INCR_WR, IDLE,{((NO_OF_SEQ*4)-(4*4)){1'b0}}} :
   auto_initiate_write_en_seq && !auto_initiate_status_read_seq  ? {WRITE_EN,INCR_WR, IDLE,{((NO_OF_SEQ*4)-(3*4)){1'b0}}} : 
   {INCR_WR, IDLE,{((NO_OF_SEQ*4)-(2*4)){1'b0}}} ;
end 
else if((csr_rd_xfer_valid_final || csr_rd_xfer_valid_final_reg ) & main_cntrl_idle_state) // CSR INITIATED READ REGISTER READ TRANSFER - pulse
begin
   nxt_csr_rd_xfer_valid_final_reg = 1'b0;
   axi_xfer   = 1'b0;
   start_xfer = 1'b1;
   csr_xfer   = 1'b1;
   //nxt_seq_change = enter_jump_on_cs ?  1'b1 : seq_change;
   seq_path   = rd_monitor_en ?  
                (auto_initiate_write_dis_seq ? {WRITE_DIS,WAIT_AUTO_STATUS_XFER_SUCCESS,IDLE,{((NO_OF_SEQ*4)-(3*4)){1'b0}}} : {INCR_RD_MONITOR,IDLE,{((NO_OF_SEQ*4)-(2*4)){1'b0}}}) :
                (auto_initiate_write_dis_seq ? {WRITE_DIS,INCR_RD,IDLE,{((NO_OF_SEQ*4)-(3*4)){1'b0}}} : {INCR_RD,IDLE,{((NO_OF_SEQ*4)-(2*4)){1'b0}}});
end
else if(slv_mem_cmd_valid & (!mem_slv_cmd_ready))
begin
     if(slv_mem_burst==INCR & slv_mem_write) //INCR write
     begin
       start_xfer = 1'b1;
       axi_xfer   = 1'b1;
       csr_xfer   = 1'b0;
       seq_path       = auto_initiate_write_en_seq_2 && auto_initiate_status_read_seq  ? 
       (auto_initiate_write_dis_seq ? {WRITE_EN,WRITE_EN_2,INCR_WR,WRITE_DIS,WAIT_AUTO_STATUS_XFER_SUCCESS, IDLE,{((NO_OF_SEQ*4)-(6*4)){1'b0}}} : 
                                      {WRITE_EN,WRITE_EN_2,INCR_WR,WAIT_AUTO_STATUS_XFER_SUCCESS, IDLE,{((NO_OF_SEQ*4)-(5*4)){1'b0}}} ) :
       auto_initiate_write_en_seq && auto_initiate_status_read_seq  ? 
         (auto_initiate_write_dis_seq ? {WRITE_EN,INCR_WR,WRITE_DIS,WAIT_AUTO_STATUS_XFER_SUCCESS, IDLE,{((NO_OF_SEQ*4)-(5*4)){1'b0}}} :       
                                       {WRITE_EN,INCR_WR,WAIT_AUTO_STATUS_XFER_SUCCESS, IDLE,{((NO_OF_SEQ*4)-(4*4)){1'b0}}} ) :
       (!auto_initiate_write_en_seq) && auto_initiate_status_read_seq ? 
         ( auto_initiate_write_dis_seq ? {INCR_WR,WRITE_DIS,WAIT_AUTO_STATUS_XFER_SUCCESS, IDLE,{((NO_OF_SEQ*4)-(4*4)){1'b0}}} :
                                        {INCR_WR,WAIT_AUTO_STATUS_XFER_SUCCESS, IDLE,{((NO_OF_SEQ*4)-(3*4)){1'b0}}} )         :
       auto_initiate_write_en_seq_2 && !auto_initiate_status_read_seq  ? {WRITE_EN,WRITE_EN_2,INCR_WR, IDLE,{((NO_OF_SEQ*4)-(4*4)){1'b0}}} :
       auto_initiate_write_en_seq && !auto_initiate_status_read_seq  ? {WRITE_EN,INCR_WR, IDLE,{((NO_OF_SEQ*4)-(3*4)){1'b0}}} : 
       {INCR_WR, IDLE,{((NO_OF_SEQ*4)-(2*4)){1'b0}}} ;
       //nxt_seq_change = enter_jump_on_cs ?  1'b1 : seq_change;
     end
     else if(slv_mem_burst==WRAP & slv_mem_write) //WRAP write
     begin
       //nxt_seq_change = enter_jump_on_cs ?  1'b1 : seq_change;
       if(wrap_addr_valid)
       begin
          seq_path = auto_initiate_write_en_seq_2 && auto_initiate_status_read_seq ? 
         (auto_initiate_write_dis_seq ?   {WRITE_EN,WRITE_EN_2,WRAP_WR_1,WRITE_DIS,WAIT_AUTO_STATUS_XFER_SUCCESS,IDLE,{((NO_OF_SEQ*4)-(6*4)){1'b0}}} : 
                                          {WRITE_EN,WRITE_EN_2,WRAP_WR_1,WAIT_AUTO_STATUS_XFER_SUCCESS,IDLE,{((NO_OF_SEQ*4)-(5*4)){1'b0}}} ) :
         auto_initiate_write_en_seq && auto_initiate_status_read_seq ? 
         (auto_initiate_write_dis_seq ?  {WRITE_EN,WRAP_WR_1,WRITE_DIS,WAIT_AUTO_STATUS_XFER_SUCCESS,IDLE,{((NO_OF_SEQ*4)-(5*4)){1'b0}}} :
                                            {WRITE_EN,WRAP_WR_1,WAIT_AUTO_STATUS_XFER_SUCCESS,IDLE,{((NO_OF_SEQ*4)-(4*4)){1'b0}}} ) :
         (!auto_initiate_write_en_seq) && auto_initiate_status_read_seq ? 
         (auto_initiate_write_dis_seq ?  {WRAP_WR_1,WRITE_DIS,WAIT_AUTO_STATUS_XFER_SUCCESS,IDLE,{((NO_OF_SEQ*4)-(4*4)){1'b0}}} : 
                                          {WRAP_WR_1,WAIT_AUTO_STATUS_XFER_SUCCESS,IDLE,{((NO_OF_SEQ*4)-(3*4)){1'b0}}}  ) :
         auto_initiate_write_en_seq_2 && !auto_initiate_status_read_seq ? {WRITE_EN,WRITE_EN_2,WRAP_WR_1,IDLE,{((NO_OF_SEQ*4)-(4*4)){1'b0}}} :
         auto_initiate_write_en_seq && !auto_initiate_status_read_seq ? {WRITE_EN,WRAP_WR_1,IDLE,{((NO_OF_SEQ*4)-(3*4)){1'b0}}} : 
          {WRAP_WR_1,IDLE,{((NO_OF_SEQ*4)-(2*4)){1'b0}}} ;
          start_xfer = 1'b1;
          axi_xfer   = 1'b1;
       csr_xfer   = 1'b0;
       end
       else
       begin
          seq_path   = {NO_OF_SEQ*4{1'b0}}; 
          start_xfer = 1'b0;
          axi_xfer   = 1'b0;
       csr_xfer   = 1'b0;

       end
     end 
     else if(slv_mem_burst==WRAP & (!slv_mem_write)) //WRAP read
     begin
       start_xfer = 1'b1;
       axi_xfer   = 1'b1;
       csr_xfer   = 1'b0;
       seq_path   = auto_initiate_write_dis_seq ? {WRITE_DIS,WRAP_RD,IDLE,{((NO_OF_SEQ*4)-(2*4)){1'b0}}}  : {WRAP_RD,IDLE,{((NO_OF_SEQ*4)-(2*4)){1'b0}}};
       //nxt_seq_change = enter_jump_on_cs ?  1'b1 : seq_change;
       //end
     end
     else //if(slv_mem_burst==INCR & (!slv_mem_write)) //INCR read
     begin
       start_xfer = 1'b1;
       axi_xfer   = 1'b1;
       csr_xfer   = 1'b0;
       //nxt_seq_change = enter_jump_on_cs ?  1'b1 : seq_change;
       seq_path   = auto_initiate_write_dis_seq ? {WRITE_DIS,INCR_RD,IDLE,{((NO_OF_SEQ*4)-(3*4)){1'b0}}} : {INCR_RD,IDLE,{((NO_OF_SEQ*4)-(2*4)){1'b0}}};

   end

end
else // if (slv_mem_cmd_valid & mem_slv_cmd_ready) or for CSR initiated transfers
begin
   start_xfer = 1'b0;
   csr_xfer   = 1'b0;
   axi_xfer   = 1'b0;
end
end

//-----------------------------------------MAIN FSM ----------------------------------

assign mem_slv_cmd_ready =  axi_start_mem_xfer_ack & final_xfer & (!wait_subseq_pg_wr);
//assign mem_slv_cmd_ready =  axi_start_mem_xfer_ack & final_xfer & (!wait_subseq_pg_wr);

always @ *
begin

nxt_csr_cmd_xfer_ack_pulse          = 1'b0; 
nxt_csr_cmd_xfer_success_pulse      = 1'b0; 
nxt_mem_xfer_auto_status_rd_done_pulse         = 1'b0; 
nxt_csr_rd_xfer_ack_pulse       = 1'b0;
nxt_csr_rd_xfer_success_pulse   = 1'b0;
nxt_wait_for_xfer_cmplt             = wait_for_xfer_cmplt;
nxt_check_status_reg_xfer_cmplt = check_status_reg_xfer_cmplt;
nxt_first_check = first_check;
nxt_axi_xfer_reg  = axi_xfer_reg;
nxt_csr_xfer_reg  = csr_xfer_reg;

nxt_mem_mode_wr              = cur_mem_mode_wr;
nxt_cont_rd_req              = cont_rd_req             ; 
nxt_cont_wr_req              = cont_wr_req             ; 
nxt_xfer_bsize               = xfer_bsize              ; 
nxt_xfer_btype               = xfer_btype              ; 
nxt_xfer_axi_len             = xfer_axi_len            ; 
nxt_rw_len_mem_xfer          = rw_len_mem_xfer         ; 
nxt_addr_mem_xfer            = addr_mem_xfer           ; 
nxt_subseq_btype_reg = subseq_btype_reg;
nxt_subseq_bsize_reg = subseq_bsize_reg;
nxt_wr_addr_reg              = wr_addr_reg;
nxt_final_xfer               = final_xfer              ; 
nxt_auto_initiate            = auto_initiate           ; 
//nxt_auto_initiate            = (mem_rd_valid && mem_rd_ack ) ? 1'b0 : auto_initiate           ; 
nxt_seq_reg_3                = seq_reg_3               ; 
nxt_seq_reg_2                = seq_reg_2               ; 
nxt_seq_reg_1                = seq_reg_1               ; 
nxt_seq_reg_0                = seq_reg_0               ; 
nxt_xfer_wr_rd               = xfer_wr_rd              ; 
nxt_csr_start_mem_xfer_valid = csr_start_mem_xfer_valid; 
nxt_axi_start_mem_xfer_valid = axi_start_mem_xfer_valid; 
nxt_state                    = pres_state              ; 
nxt_seq_path_reg = seq_path_reg;
nxt_cont_wr_check_cnt = cont_wr_check_cnt;

nxt_wrap_axi_len_reg         = wrap_axi_len_reg;
nxt_wrap_axi_bsize_reg       = wrap_axi_bsize_reg;
   
nxt_no_of_data_bytes = no_of_data_bytes;
//nxt_mem_rd_ack = 1'b0;
nxt_status_en_flag = status_en_flag;
nxt_subseq_pg_wr_cnt = subseq_pg_wr_cnt;
nxt_wait_subseq_pg_wr = wait_subseq_pg_wr;
nxt_wait_for_ack = wait_for_ack;
nxt_post_wren_flag = post_wren_flag;
nxt_csr_cmd_xfer_ack_level = csr_cmd_xfer_ack_level;
nxt_deassert_cs_reg = deassert_cs_reg;
nxt_dual_seq_mode_reg = dual_seq_mode_reg;
//Decode error case
nxt_xfer_mem_error = (slv_mem_wlast|rd_done) ? 1'b0 : axi_start_mem_xfer_valid & slv_mem_err ? 1'b1 : xfer_mem_error; // RSR

case(pres_state)
IDLE:
begin
   if(start_xfer)
   begin
      nxt_seq_path_reg = seq_path<<4;
      nxt_state        = seq_path[(NO_OF_SEQ*4)-4 +:4];
      nxt_axi_xfer_reg = axi_xfer;
      nxt_csr_xfer_reg = csr_xfer;
      nxt_dual_seq_mode_reg = (axi_xfer & dual_seq_mode) ? 1'b1 : dual_seq_mode_reg;
   end
   else
   begin
      nxt_seq_path_reg = seq_path_reg;
      nxt_state        = pres_state;
      nxt_axi_xfer_reg = 1'b0;
      nxt_csr_xfer_reg = 1'b0;
   end
end
WRITE_EN:
begin
   if( (~axi_start_mem_xfer_valid & axi_xfer_reg) || (~csr_start_mem_xfer_valid & csr_xfer_reg) )
   begin
       nxt_mem_mode_wr              = 1'b1;
       nxt_state                    = pres_state;
       nxt_addr_mem_xfer	    = auto_initiate_write_en_seq_2 ? {7'd0,25'hAAA} : addr_mem_xfer;
       nxt_axi_start_mem_xfer_valid = axi_xfer_reg;
       nxt_csr_start_mem_xfer_valid = csr_xfer_reg;
       //nxt_xfer_mem_error           = 1'b0;  
       nxt_xfer_wr_rd               = 1'b1;
       nxt_xfer_axi_len             = 8'd0; 
       nxt_xfer_btype               = 2'd0;
       nxt_xfer_bsize               = 3'd0;
       nxt_seq_reg_0                = auto_initiate_write_en_seq_2 ? {CMD16_DDR,2'b11,8'd1,CA,2'b11,8'h3F} : write_en_seq_reg_1;
       nxt_seq_reg_1                = auto_initiate_write_en_seq_2 ? {16'd0,16'hAA} : write_en_seq_reg_2;
       nxt_seq_reg_2                = 32'd0;
       nxt_seq_reg_3                = 32'd0;
       nxt_auto_initiate            = 1'b1;
   end
   else if ( (axi_start_mem_xfer_valid & axi_start_mem_xfer_ack) || (csr_start_mem_xfer_valid & csr_start_mem_xfer_ack) )
   begin
       nxt_axi_start_mem_xfer_valid = 1'b0; // no need to wait for the busy signal
       nxt_csr_start_mem_xfer_valid = 1'b0; 
       //nxt_xfer_mem_error           = 1'b0;  
       nxt_xfer_wr_rd               = 1'b0;
       nxt_auto_initiate            = 1'b0;
       nxt_state                    = seq_path_reg[(NO_OF_SEQ*4)-4 +:4];
       nxt_seq_path_reg             = seq_path_reg<<4;
   end
   else
   begin
       nxt_state                    = pres_state;
  end
end

WRITE_EN_2:
begin
   if( (~axi_start_mem_xfer_valid & axi_xfer_reg) || (~csr_start_mem_xfer_valid & csr_xfer_reg) )
   begin
       nxt_mem_mode_wr              = 1'b1;
       nxt_state                    = pres_state;
       nxt_post_wren_flag 	    = post_wren_flag ? 1'b0 : auto_initiate_post_wren_seq ? 1'b1 : post_wren_flag;
       nxt_addr_mem_xfer            = post_wren_flag ? {7'd0,25'hAAA} : {7'd0,25'h554};
       nxt_axi_start_mem_xfer_valid = axi_xfer_reg;
       nxt_csr_start_mem_xfer_valid = csr_xfer_reg;
       //nxt_xfer_mem_error           = 1'b0;  
       nxt_xfer_wr_rd               = 1'b1;
       nxt_xfer_axi_len             = 8'd0; 
       nxt_xfer_btype               = 2'd0;
       nxt_xfer_bsize               = 3'd0;
       nxt_seq_reg_0                = {CMD16_DDR,2'b11,8'd1,CA,2'b11,8'h3F}; //write_en_2_seq_reg_1;
       nxt_seq_reg_1                = post_wren_flag ? {16'd0,post_wren_seq_data} : {16'd0,16'h55}; //write_en_2_seq_reg_2;
       nxt_seq_reg_2                = 32'd0;
       nxt_seq_reg_3                = 32'd0;
       nxt_auto_initiate            = 1'b1;
   end
   else if ( (axi_start_mem_xfer_valid & axi_start_mem_xfer_ack) || (csr_start_mem_xfer_valid & csr_start_mem_xfer_ack) )
   begin
       nxt_axi_start_mem_xfer_valid = 1'b0; // no need to wait for the busy signal
       nxt_csr_start_mem_xfer_valid = 1'b0; 
       //nxt_xfer_mem_error           = 1'b0;  
       nxt_xfer_wr_rd               = 1'b0;
       nxt_auto_initiate            = 1'b0;
       nxt_state                    = (!post_wren_flag) ? seq_path_reg[(NO_OF_SEQ*4)-4 +:4] : pres_state;
       nxt_seq_path_reg             = (!post_wren_flag) ? seq_path_reg<<4 : seq_path_reg;
   end
   else
   begin
       nxt_state                    = pres_state;
  end
end


WRITE_DIS:
begin
   if( (~axi_start_mem_xfer_valid & axi_xfer_reg) || (~csr_start_mem_xfer_valid & csr_xfer_reg) )
   begin
       nxt_mem_mode_wr              = 1'b0;
       nxt_state                    = pres_state;
       nxt_axi_start_mem_xfer_valid = axi_xfer_reg;
       nxt_csr_start_mem_xfer_valid = csr_xfer_reg;
       //nxt_xfer_mem_error           = 1'b0;  
       nxt_xfer_wr_rd               = 1'b1;
       nxt_xfer_axi_len             = 8'd0; 
       nxt_xfer_btype               = 2'd0;
       nxt_xfer_bsize               = 3'd0;
       nxt_seq_reg_0                = write_dis_seq_reg_1;
       nxt_seq_reg_1                = write_dis_seq_reg_2;
       nxt_seq_reg_2                = 32'h0; 
       nxt_seq_reg_3                = 32'h0; 
       nxt_auto_initiate            = 1'b1;
   end
   else if ( (axi_start_mem_xfer_valid & axi_start_mem_xfer_ack) || (csr_start_mem_xfer_valid & csr_start_mem_xfer_ack) )
   begin
       nxt_axi_start_mem_xfer_valid = 1'b0; // no need to wait for the busy signal
       nxt_csr_start_mem_xfer_valid = 1'b0; 
       //nxt_xfer_mem_error           = 1'b0;  
       nxt_xfer_wr_rd               = 1'b0;
       nxt_auto_initiate            = 1'b0;
       nxt_state                    = seq_path_reg[(NO_OF_SEQ*4)-4 +:4];
       nxt_seq_path_reg             = seq_path_reg<<4;
   end
   else
   begin
       nxt_state                    = pres_state;
  end
end

INCR_WR: 
//wait for cont_wr_check_cnt=2 for cont_req to be reasserted
begin
   if (  (~axi_start_mem_xfer_valid & axi_xfer_reg & wr_seq_valid & (!final_xfer) & (!(|cont_wr_check_cnt)) )  ||
          ( cont_wr_check_cnt==2'd2 & (!deassert_cs) & wr_seq_valid & slv_mem_cmd_valid & slv_mem_write & slv_mem_cont_wr_req & (slv_mem_burst==2'd1)) )
   begin
       nxt_cont_wr_check_cnt        = 2'd0;
       nxt_final_xfer               = 1'b1;
       nxt_state                    = pres_state;
       nxt_axi_start_mem_xfer_valid = axi_xfer_reg;
       nxt_rw_len_mem_xfer          = rw_len_mem_xfer; // used only during wrap writes
       nxt_xfer_wr_rd               = 1'b1;
       nxt_xfer_axi_len             = wait_subseq_pg_wr ? xfer_axi_len : slv_mem_axi_len; // used only during read operation
       nxt_xfer_btype               = wait_subseq_pg_wr ? subseq_btype_reg : slv_mem_burst;
       nxt_xfer_bsize               = wait_subseq_pg_wr ? subseq_bsize_reg : slv_mem_size; 
       nxt_cont_wr_req              = wait_subseq_pg_wr ? 1'b0 : slv_mem_cont_wr_req  ;
       nxt_subseq_btype_reg         = wait_subseq_pg_wr ? subseq_btype_reg : slv_mem_burst;
       nxt_subseq_bsize_reg         = wait_subseq_pg_wr ? subseq_bsize_reg : slv_mem_size ;
       nxt_cont_rd_req              = cont_rd_req;
       nxt_seq_reg_0                = wr_seq_0; 
       nxt_seq_reg_1                = wr_seq_1; 
       nxt_seq_reg_2                = wr_seq_2; 
       nxt_seq_reg_3                = wr_seq_3; 
       nxt_auto_initiate            = 1'b0;
       if(wait_subseq_pg_wr) //One time - update subseq_pg_wr_cnt
       begin
       case(mem_page_size)
       4'd6:  
       begin
          nxt_addr_mem_xfer         = {wr_addr_reg[31:6]+1'b1,6'd0}; 
          nxt_wr_addr_reg            = {wr_addr_reg[31:6]+1'b1,6'd0}; 
                                     
       end
       4'd7:  
       begin
          nxt_addr_mem_xfer         = {wr_addr_reg[31:7]+1'b1,7'd0}; 
          nxt_wr_addr_reg         = {wr_addr_reg[31:7]+1'b1,7'd0}; 

       end
       4'd8:  
       begin
          nxt_addr_mem_xfer         = {wr_addr_reg[31:8]+1'b1,8'd0}; 
          nxt_wr_addr_reg         = {wr_addr_reg[31:8]+1'b1,8'd0}; 

       end
       4'd9:  
       begin
          nxt_addr_mem_xfer         = {wr_addr_reg[31:9]+1'b1,9'd0}; 
          nxt_wr_addr_reg         = {wr_addr_reg[31:9]+1'b1,9'd0}; 

       end
       4'd10:  
       begin
          nxt_addr_mem_xfer         = {wr_addr_reg[31:10]+1'b1,10'd0}; 
          nxt_wr_addr_reg         = {wr_addr_reg[31:10]+1'b1,10'd0}; 

       end
       4'd11:  
       begin
          nxt_addr_mem_xfer         = {wr_addr_reg[31:11]+1'b1,11'd0}; 
          nxt_wr_addr_reg         = {wr_addr_reg[31:11]+1'b1,11'd0}; 

       end
       4'd12:  
       begin
          nxt_addr_mem_xfer         = {wr_addr_reg[31:12]+1'b1,12'd0}; 
          nxt_wr_addr_reg         = {wr_addr_reg[31:12]+1'b1,12'd0}; 
       end
        endcase
          nxt_subseq_pg_wr_cnt      = | subseq_pg_wr_cnt ? subseq_pg_wr_cnt - 'd1 : subseq_pg_wr_cnt;
          //nxt_wait_subseq_pg_wr     = subseq_pg_wr_cnt == 'd1 ? 1'b0 : wait_subseq_pg_wr;
       end
       else
       begin
       nxt_addr_mem_xfer            = slv_mem_addr;
       nxt_wr_addr_reg              =  slv_mem_addr;
          if(page_incr_en)
          begin
          case(mem_page_size)
          4'd6:  
           begin
              nxt_subseq_pg_wr_cnt     = slv_mem_addr_end[31:6] - slv_mem_addr[31:6]; // 64 bytes page
              //nxt_wait_subseq_pg_wr    = |(slv_mem_addr[31:6]^slv_mem_addr_end[31:6]);
           end
          4'd7:  
           begin
              nxt_subseq_pg_wr_cnt     = slv_mem_addr_end[31:7]- slv_mem_addr[31:7]; // 128 bytes page
             // nxt_wait_subseq_pg_wr    = |(slv_mem_addr[31:7]^slv_mem_addr_end[31:7]);
           end
          4'd8:  
           begin
              nxt_subseq_pg_wr_cnt     = slv_mem_addr_end[31:8]- slv_mem_addr[31:8]; // 256 bytes page
            //  nxt_wait_subseq_pg_wr    = |(slv_mem_addr[31:8]^slv_mem_addr_end[31:8]);
           end
          4'd9:  
           begin
              nxt_subseq_pg_wr_cnt     = slv_mem_addr_end[31:9]- slv_mem_addr[31:9]; // 512 bytes page
            //  nxt_wait_subseq_pg_wr    = |(slv_mem_addr[31:9]^slv_mem_addr_end[31:9]);
           end
          4'd10: 
           begin
              nxt_subseq_pg_wr_cnt     = slv_mem_addr_end[31:10]- slv_mem_addr[31:10]; // 1024 bytes page
            //  nxt_wait_subseq_pg_wr    = |(slv_mem_addr[31:10]^slv_mem_addr_end[31:10]);
           end
          4'd11: 
           begin
              nxt_subseq_pg_wr_cnt     = slv_mem_addr_end[31:11]- slv_mem_addr[31:11]; // 2048 bytes page
            //  nxt_wait_subseq_pg_wr    = |(slv_mem_addr[31:11]^slv_mem_addr_end[31:11]);
           end
          4'd12: 
           begin
              nxt_subseq_pg_wr_cnt     = slv_mem_addr_end[31:12]- slv_mem_addr[31:12]; // 4096 bytes page
            //  nxt_wait_subseq_pg_wr    = |(slv_mem_addr[31:12]^slv_mem_addr_end[31:12]);
           end
          4'd13: 
           begin
              nxt_subseq_pg_wr_cnt     = slv_mem_addr_end[31:13]- slv_mem_addr[31:13]; // 8192 bytes page
            //  nxt_wait_subseq_pg_wr    = |(slv_mem_addr[31:13]^slv_mem_addr_end[31:13]);
           end
           default:
           begin
              nxt_subseq_pg_wr_cnt     = subseq_pg_wr_cnt ;
              nxt_wait_subseq_pg_wr    = wait_subseq_pg_wr;
           end
          endcase
          end
          else
          begin
              nxt_subseq_pg_wr_cnt     = subseq_pg_wr_cnt ;
              nxt_wait_subseq_pg_wr    = 1'b0;
          end
       end
   end
   else if ((|subseq_pg_wr_cnt) || wait_subseq_pg_wr) //update wait_subseq_pg_wr
   //else if (axi_start_mem_xfer_valid & wait_subseq_pg_wr) 
   begin
       nxt_wait_subseq_pg_wr        = axi_start_mem_xfer_ack ? subseq_pg_wr_cnt == 'd0 ? 1'b0 : 1'b1 : wait_subseq_pg_wr;
       nxt_axi_start_mem_xfer_valid = axi_start_mem_xfer_ack ? 1'b0 : axi_start_mem_xfer_valid ; 
          //nxt_subseq_pg_wr_cnt      = | subseq_pg_wr_cnt ? subseq_pg_wr_cnt - 'd1 : subseq_pg_wr_cnt;
          //nxt_wait_subseq_pg_wr     = subseq_pg_wr_cnt == 'd1 ? 1'b0 : wait_subseq_pg_wr;
       if(subseq_pg_wr || (axi_start_mem_xfer_ack && subseq_pg_wr_cnt == 'd0 ))
       begin
       nxt_final_xfer               = 1'b0;
       nxt_state                    = WAIT_AUTO_STATUS_XFER_SUCCESS;
       nxt_seq_path_reg             = axi_start_mem_xfer_ack && subseq_pg_wr_cnt == 'd0 ? seq_path_reg<<4: 
                                      {WRITE_EN, INCR_WR, WAIT_AUTO_STATUS_XFER_SUCCESS, {((NO_OF_SEQ*4)-(3*4)){1'b0}}}; 
       end
       else
       begin
       nxt_final_xfer               = final_xfer              ;
       nxt_state                    = pres_state                   ;
       nxt_seq_path_reg             = seq_path_reg            ;
       end
   end

   else if (axi_start_mem_xfer_valid & axi_start_mem_xfer_ack)
   begin
        nxt_axi_start_mem_xfer_valid = dual_seq_mode_reg ? axi_start_mem_xfer_valid : 1'b0; 
        nxt_cont_wr_req              = 1'b0;
        nxt_final_xfer               = 1'b0;
        nxt_state                    = pres_state;
        nxt_seq_path_reg             = seq_path_reg;
        nxt_cont_wr_check_cnt        = cont_wr_check_cnt + 2'd1;
   end
   else if(|cont_wr_check_cnt)
   begin
      if(deassert_cs)
      begin
          nxt_cont_wr_check_cnt        = 2'd0;
          nxt_state                    = seq_path_reg[(NO_OF_SEQ*4)-4 +:4];
          nxt_seq_path_reg             = seq_path_reg<<4;
      end
      else if(cont_wr_check_cnt==2'd2)
      begin
          if (slv_mem_cmd_valid & slv_mem_write & slv_mem_cont_wr_req & slv_mem_burst==2'd2)
          begin
             nxt_cont_wr_check_cnt         = 2'd0;
             nxt_state                    = WRAP_WR_1;
          end
          else
          begin
             nxt_cont_wr_check_cnt        = 2'd0;
             nxt_state                    = seq_path_reg[(NO_OF_SEQ*4)-4 +:4];
             nxt_seq_path_reg             = seq_path_reg<<4;
          end
      end
      else
      begin
       nxt_state                    = pres_state;
       nxt_cont_wr_check_cnt        = cont_wr_check_cnt + 2'd1;
      end
   end
   else if(~csr_start_mem_xfer_valid & csr_xfer_reg & (!final_xfer))
   begin
       nxt_final_xfer               = 1'b1;
       nxt_state                    = pres_state;
       nxt_csr_start_mem_xfer_valid = csr_xfer_reg;
       //nxt_xfer_mem_error           = 1'b0;  
       nxt_xfer_wr_rd               = 1'b1;
       nxt_xfer_axi_len             = 8'd0; 
       nxt_xfer_btype               = 2'd0;
       nxt_xfer_bsize               = 3'd0;
       nxt_no_of_data_bytes         = no_of_wr_data_bytes;
       if(wdata_xfer_data_rate) // DDR
       begin
          if(wr_data_en)
          begin
             nxt_seq_reg_0    = cmd_no_of_opcode ? {cmd_opcode[15:0],CMD16_DDR,cmd_no_of_pins,7'h0,cmd_xfer_data_rate}:
                                (cmd_xfer_data_rate ? {WRITE_DDR,wdata_no_of_pins,8'h0, CMD_DDR,cmd_no_of_pins,cmd_opcode[7:0]} : 
                                {WRITE_DDR,wdata_no_of_pins,8'h0, CMD,cmd_no_of_pins,cmd_opcode[7:0]} ) ; 

             nxt_seq_reg_1    = cmd_no_of_opcode ? (
                                {16'h0, WRITE_DDR,wdata_no_of_pins,8'h0}) : 32'h0; 
                                // STOP is placed here when two command opcodes are sent
             nxt_seq_reg_2    = 32'h0;
             nxt_seq_reg_3    = 32'h0;
          end
          else
          begin
             nxt_seq_reg_0    = cmd_no_of_opcode ? {cmd_opcode[15:0],CMD16_DDR,cmd_no_of_pins,7'h0,cmd_xfer_data_rate}:
                                cmd_xfer_data_rate ? {16'h0 ,CMD_DDR,cmd_no_of_pins,cmd_opcode[7:0]} : 
                                {16'h0 ,CMD,cmd_no_of_pins,cmd_opcode[7:0]}; 
             nxt_seq_reg_1    = 32'h0; // STOP is placed here when two command opcodes are sent
             nxt_seq_reg_2    = 32'h0;
             nxt_seq_reg_3    = 32'h0;
          end
       end
       else // SDR
       begin
          if(wr_data_en)
          begin
             nxt_seq_reg_0    =  cmd_no_of_opcode ? {cmd_opcode[15:0],CMD16_DDR,cmd_no_of_pins,7'h0,cmd_xfer_data_rate}:  //8'h0 for CMD16 SDR
                                 (cmd_xfer_data_rate ? {WRITE,wdata_no_of_pins,8'h0,CMD_DDR,cmd_no_of_pins,cmd_opcode[7:0]} : 
                                 {WRITE,wdata_no_of_pins,8'h0,CMD,cmd_no_of_pins,cmd_opcode[7:0]}); 
             nxt_seq_reg_1    =  cmd_no_of_opcode ? (
                                 {16'h0,WRITE,wdata_no_of_pins,8'h0}) : 32'h0; 
                                 // STOP is placed here when two command opcodes are sent
             nxt_seq_reg_2    =  32'h0;
             nxt_seq_reg_3    =  32'h0;
          end
          else
          begin
             nxt_seq_reg_0    =  cmd_no_of_opcode ? {cmd_opcode[15:0],CMD16_DDR,cmd_no_of_pins,7'h0,cmd_xfer_data_rate}:  //8'h0 for CMD16 SDR
                                 cmd_xfer_data_rate ? {16'h0 ,CMD_DDR,cmd_no_of_pins,cmd_opcode[7:0]} : 
                                {16'h0 ,CMD,cmd_no_of_pins,cmd_opcode[7:0]}; 
             nxt_seq_reg_1    =  32'h0; // STOP is placed here when two command opcodes are sent
             nxt_seq_reg_2    =  32'h0;
             nxt_seq_reg_3    =  32'h0;
          end
       end                            
   end
   else if (csr_start_mem_xfer_valid & csr_start_mem_xfer_ack || (wait_for_xfer_cmplt))
   begin
       nxt_csr_start_mem_xfer_valid   = 1'b0; // no need to wait for the busy signal
       if(csr_mem_xfer_bsy_fedge)
       begin
       nxt_state                      = seq_path_reg[(NO_OF_SEQ*4)-4 +:4];
       nxt_seq_path_reg               = seq_path_reg<<4;
       //nxt_csr_cmd_xfer_success_pulse = 1'b0; //RSR ; two times repeated
       nxt_csr_cmd_xfer_success_pulse = !auto_initiate_status_read_seq ? 1'b1 : 1'b0;
       nxt_final_xfer                 = 1'b0;
       nxt_wait_for_xfer_cmplt        = 1'b0;
       nxt_csr_cmd_xfer_ack_pulse     = 1'b1;
       end
       else
       begin
       nxt_state                      = pres_state;
       nxt_csr_cmd_xfer_success_pulse = csr_cmd_xfer_success_pulse;
       nxt_final_xfer                 = final_xfer;
       nxt_wait_for_xfer_cmplt        = 1'b1;
       end
   end
   else
   begin
       nxt_state                    = pres_state;
   end

end

INCR_RD: 
begin
   if(~axi_start_mem_xfer_valid & axi_xfer_reg & rd_seq_valid & (!final_xfer))
   begin
       nxt_final_xfer               = dual_seq_mode_reg ? 1'b0 : 1'b1;
       nxt_state                    = pres_state;
       nxt_axi_start_mem_xfer_valid = axi_xfer_reg;
       nxt_addr_mem_xfer            = slv_mem_addr;  
       nxt_rw_len_mem_xfer          = rw_len_mem_xfer; 
       //nxt_xfer_mem_error           = 1'b0;  
       nxt_xfer_wr_rd               = slv_mem_write;
       nxt_xfer_axi_len             = slv_mem_axi_len;
       nxt_xfer_btype               = slv_mem_burst;
       nxt_xfer_bsize               = slv_mem_size; 
       nxt_cont_rd_req              = slv_mem_cont_rd_req;
       nxt_cont_wr_req              = cont_wr_req;
       nxt_seq_reg_0                = rd_seq_0; 
       nxt_seq_reg_1                = rd_seq_1; 
       nxt_seq_reg_2                = rd_seq_2; 
       nxt_seq_reg_3                = rd_seq_3; 
       nxt_auto_initiate            = 1'b0;
   end
   else if (axi_start_mem_xfer_valid & axi_start_mem_xfer_ack)
   begin
       nxt_axi_start_mem_xfer_valid = /*dual_seq_mode_reg ? axi_start_mem_xfer_valid : */1'b0; 
       //nxt_axi_start_mem_xfer_valid = 1'b0; // no need to wait for the busy signal
       nxt_final_xfer               = 1'b0;
       nxt_state                    = dual_seq_mode_reg ? WAIT_AUTO_STATUS_XFER_SUCCESS : seq_path_reg[(NO_OF_SEQ*4)-4 +:4];
       nxt_seq_path_reg             = dual_seq_mode_reg ? cont_read_auto_status_en ? {INCR_RD, WAIT_AUTO_STATUS_XFER_SUCCESS, IDLE, {((NO_OF_SEQ*4)-(3*4)){1'b0}}} : {INCR_RD, IDLE, {((NO_OF_SEQ*4)-(2*4)){1'b0}}} : seq_path_reg<<4;
       nxt_dual_seq_mode_reg        = 1'b0;
   end
   else if(~csr_start_mem_xfer_valid & csr_xfer_reg & (!final_xfer))
   begin
       nxt_final_xfer               = 1'b1;
       nxt_state                    = pres_state;
       nxt_csr_start_mem_xfer_valid = csr_xfer_reg;
       //nxt_xfer_mem_error           = 1'b0;  
       nxt_xfer_wr_rd               = 1'b0;
       nxt_xfer_axi_len             = 8'd0; 
       nxt_xfer_btype               = 2'd0;
       nxt_xfer_bsize               = 3'd0;
       nxt_no_of_data_bytes         = no_of_csr_rd_data_bytes;
       nxt_addr_mem_xfer            = wr_rd_data_1; //Holds the address during CSR initated read operations 
       if(read_xfer_data_rate) // DDR
       begin
          if(read_no_of_opcode)
          begin
             nxt_seq_reg_0   = {read_cmd_opcode[15:0],CMD16_DDR,read_no_of_pins,7'd0,read_cmd_data_rate};

             nxt_seq_reg_1   = |no_of_csr_rd_addr_bytes ? {READ_DDR,read_no_of_pins,8'h0,ADDR_DDR,read_no_of_pins,no_of_csr_rd_addr_bits} :
                                {16'h0,READ_DDR,read_no_of_pins,8'h0};
             nxt_seq_reg_2   = 32'h0;
             nxt_seq_reg_3   = 32'h0;
          end
          else
          begin
             nxt_seq_reg_0   = |no_of_csr_rd_addr_bytes ? 
                                (read_cmd_data_rate ?  
                                {ADDR_DDR,read_no_of_pins,no_of_csr_rd_addr_bits, CMD_DDR,read_no_of_pins,read_cmd_opcode[7:0]} :
                                {ADDR_DDR,read_no_of_pins,no_of_csr_rd_addr_bits, CMD,read_no_of_pins,read_cmd_opcode[7:0]}) : // Data for mode instruction is placed on hte wr_rd_data_reg_* signals from CSR
                                (read_cmd_data_rate ?  
                                {READ_DDR,read_no_of_pins,8'h0, CMD_DDR,read_no_of_pins,read_cmd_opcode[7:0]} :
                                {READ_DDR,read_no_of_pins,8'h0, CMD,read_no_of_pins,read_cmd_opcode[7:0]}) ;

             nxt_seq_reg_1   = |no_of_csr_rd_addr_bytes ?  {16'h0, READ_DDR,read_no_of_pins,8'h0} : 32'h0;
             nxt_seq_reg_2   = 32'h0;
             nxt_seq_reg_3   = 32'h0;
          end
       end
       else // SDR
       begin
          if(read_no_of_opcode)
          begin
             nxt_seq_reg_0          = {read_cmd_opcode[15:0],CMD16_DDR,read_no_of_pins,7'd0,read_cmd_data_rate}; //8'h0 for CMD16 SDR
             nxt_seq_reg_1          = |no_of_csr_rd_addr_bytes ? {READ,read_no_of_pins,8'h0,ADDR,read_no_of_pins,no_of_csr_rd_addr_bits} :
                                       {16'h0,READ,read_no_of_pins,8'h0};
             nxt_seq_reg_2          = 32'h0;
             nxt_seq_reg_3          = 32'h0;
          end
          else
          begin
             nxt_seq_reg_0  =|no_of_csr_rd_addr_bytes ? {ADDR,read_no_of_pins,no_of_csr_rd_addr_bits,CMD,read_no_of_pins,read_cmd_opcode[7:0]} :
                              {READ,read_no_of_pins,8'h0,CMD,read_no_of_pins,read_cmd_opcode[7:0]};
             nxt_seq_reg_1  =|no_of_csr_rd_addr_bytes ? {16'h0,READ,read_no_of_pins,8'h0} :32'h0;
             nxt_seq_reg_2  = 32'h0;
             nxt_seq_reg_3  = 32'h0;
          end
       end                             
   end
   else if (csr_start_mem_xfer_valid & csr_start_mem_xfer_ack || (wait_for_xfer_cmplt))
   begin
       nxt_csr_start_mem_xfer_valid   = 1'b0; // no need to wait for the busy signal
       nxt_csr_rd_xfer_ack_pulse  = 1'b1;
       if(csr_mem_xfer_bsy_fedge)
       begin
       nxt_state                      = seq_path_reg[(NO_OF_SEQ*4)-4 +:4];
       nxt_seq_path_reg               = seq_path_reg<<4;
       nxt_final_xfer                 = 1'b0;
       nxt_wait_for_xfer_cmplt        = 1'b0;
       nxt_csr_rd_xfer_success_pulse    = 1'b1;
       end
       else
       begin
       nxt_state                      = pres_state;
       nxt_final_xfer                 = final_xfer;
       nxt_wait_for_xfer_cmplt        = 1'b1;
       nxt_csr_rd_xfer_success_pulse    = 1'b0;
       end
   end
   else
   begin
       nxt_state                    = pres_state;
   end
end

WRAP_RD: 
begin
   if(~axi_start_mem_xfer_valid & axi_xfer_reg & rd_seq_valid & (!final_xfer))
   begin
       nxt_final_xfer               = 1'b1;
       nxt_state                    = pres_state;
       nxt_axi_start_mem_xfer_valid = axi_xfer_reg;
       nxt_addr_mem_xfer            = slv_mem_addr;  
       nxt_rw_len_mem_xfer          = rw_len_mem_xfer; 
       //nxt_xfer_mem_error           = 1'b0;  
       nxt_xfer_wr_rd               = slv_mem_write;
       nxt_xfer_axi_len             = slv_mem_axi_len;
       nxt_xfer_btype               = slv_mem_burst;
       nxt_xfer_bsize               = slv_mem_size; 
       nxt_cont_rd_req              = slv_mem_cont_rd_req;
       nxt_cont_wr_req              = cont_wr_req;
       nxt_seq_reg_0                = rd_seq_0; 
       nxt_seq_reg_1                = rd_seq_1; 
       nxt_seq_reg_2                = rd_seq_2; 
       nxt_seq_reg_3                = rd_seq_3; 
       nxt_auto_initiate            = 1'b0;
   end
   else if (axi_start_mem_xfer_valid & axi_start_mem_xfer_ack)
   begin
       nxt_axi_start_mem_xfer_valid = 1'b0; // no need to wait for the busy signal
       nxt_final_xfer               = 1'b0;
       nxt_state                    = seq_path_reg[(NO_OF_SEQ*4)-4 +:4];
       nxt_seq_path_reg             = seq_path_reg<<4;
   end
   else
   begin
       nxt_state                    = pres_state;
   end
end

WRAP_WR_1: 
begin
   //if(~axi_start_mem_xfer_valid & axi_xfer_reg & wr_seq_valid & wrap_addr_valid & (!final_xfer))
   if (  (~axi_start_mem_xfer_valid & axi_xfer_reg & wr_seq_valid & wrap_addr_valid & (!final_xfer) & (!(|cont_wr_check_cnt)) )  ||
          ( cont_wr_check_cnt==2'd2 & (!deassert_cs)  & wr_seq_valid & slv_mem_cmd_valid & slv_mem_write & slv_mem_cont_wr_req & (slv_mem_burst==2'd2 && wrap_addr_valid)) )
   begin
       nxt_cont_wr_check_cnt        = 2'd0;
       nxt_final_xfer               = 1'b1;
       nxt_state                    = pres_state;
       nxt_axi_start_mem_xfer_valid = axi_xfer_reg;
       nxt_addr_mem_xfer            = no_of_xfer[1] ? (wrap_xfer_addr_2):  // since hyperflash is word addressable ; if number of transfer is 2, wrap_xfer_addr_2 is aligned to start of the wrapp boundary; wrap_xfer_addr_1 is middle of wrap size 
						      (wrap_xfer_addr_1); // wrap_xfer_addr_1 is already aligned to wrap boundary if number of transfer is 1 
       nxt_rw_len_mem_xfer          = wrap_xfer_len_1; //wrap_xfer_len_2 not required by mem_xfer_intf. wrap_xfer_len_1 is used to find out for how many write data memo_xfer_intrf has to wait and put it tempory write data FIFO
       //nxt_xfer_mem_error           = 1'b0;  
       nxt_xfer_wr_rd               = slv_mem_write;
       nxt_xfer_axi_len             = slv_mem_axi_len;
       nxt_xfer_btype               = slv_mem_burst;
       nxt_xfer_bsize               = slv_mem_size; 
       nxt_cont_rd_req              = cont_rd_req;
       nxt_cont_wr_req              = slv_mem_cont_wr_req;
       nxt_seq_reg_0                = wr_seq_0; 
       nxt_seq_reg_1                = wr_seq_1; 
       nxt_seq_reg_2                = wr_seq_2; 
       nxt_seq_reg_3                = wr_seq_3; 
       nxt_auto_initiate            = 1'b0;
   end
   //else if (axi_start_mem_xfer_valid & slv_mem_wlast & ( slv_mem_cmd_input & (!slv_mem_cont_wr_req) ))//axi_start_mem_xfer_ack)
   else if (axi_start_mem_xfer_valid & axi_start_mem_xfer_ack)
   begin
       nxt_axi_start_mem_xfer_valid = 1'b0; // no need to wait for the busy signal
       nxt_cont_wr_req              = 1'b0;
       nxt_final_xfer               = 1'b0;
       nxt_state                    = pres_state;
       nxt_seq_path_reg             = seq_path_reg;
       nxt_cont_wr_check_cnt        = cont_wr_check_cnt + 2'd1;
   end
   else if(|cont_wr_check_cnt)
   begin
      if(deassert_cs)
      begin
          nxt_cont_wr_check_cnt        = 2'd0;
          nxt_state                    = seq_path_reg[(NO_OF_SEQ*4)-4 +:4];
          nxt_seq_path_reg             = seq_path_reg<<4;
      end
      else if(cont_wr_check_cnt==2'd2)
      begin
          if( slv_mem_cmd_valid & slv_mem_write & slv_mem_cont_wr_req & (slv_mem_burst==2'd1))
          begin
             nxt_cont_wr_check_cnt         = 2'd0;
             nxt_state                    = INCR_WR;
          end
          else if (slv_mem_cmd_valid & slv_mem_write & slv_mem_cont_wr_req & slv_mem_burst==2'd2)
          begin
             nxt_state                    = pres_state;
          end
          else 
          begin
             nxt_cont_wr_check_cnt        = 2'd0;
             nxt_state                    = seq_path_reg[(NO_OF_SEQ*4)-4 +:4];
             nxt_seq_path_reg             = seq_path_reg<<4;
          end
       end
       else
       begin
        nxt_state                    = pres_state;
        nxt_cont_wr_check_cnt        = cont_wr_check_cnt + 2'd1;
       end
   end

   else
   begin
       nxt_rw_len_mem_xfer          = wrap_xfer_len_1; 
       nxt_xfer_wr_rd               = slv_mem_write;
       nxt_xfer_axi_len             = slv_mem_axi_len;
       nxt_xfer_btype               = slv_mem_burst;
       nxt_xfer_bsize               = slv_mem_size; 
       nxt_cont_wr_req              = slv_mem_cont_wr_req;
       nxt_state                    = pres_state;
   end
end

WAIT_AUTO_STATUS_XFER_SUCCESS:

if(status_reg_en & !status_en_flag)  //status register enable sequence sepcific to hyperflash; Need to program this register before auto initiated status regisger read.
//the write to status register does not require write enable in hyperflash
begin
   nxt_csr_cmd_xfer_ack_level = csr_cmd_xfer_ack_pulse ? 1'b1 : csr_cmd_xfer_ack_level;
   nxt_deassert_cs_reg = deassert_cs ? 1'b1 : deassert_cs_reg;
   if( (~axi_start_mem_xfer_valid & axi_xfer_reg) || (~csr_start_mem_xfer_valid & csr_xfer_reg) )
   begin
       nxt_state                    = pres_state;
       nxt_addr_mem_xfer	    = {7'd0,25'hAAA}; //RSR
       nxt_axi_start_mem_xfer_valid = axi_xfer_reg;
       nxt_csr_start_mem_xfer_valid = csr_xfer_reg;
       //nxt_xfer_mem_error           = 1'b0;  
       nxt_xfer_wr_rd               = 1'b1;
       nxt_xfer_axi_len             = 8'd0; 
       nxt_xfer_btype               = 2'd0;
       nxt_xfer_bsize               = 3'd0;
       nxt_seq_reg_0                = {CMD16_DDR,2'b11,8'd1,CA,2'b11,8'h3F}; //status_en_seq_reg_1;
       nxt_seq_reg_1                = {16'd0,16'h70}; //status_en_seq_reg_2;
       nxt_seq_reg_2                = 32'd0;
       nxt_seq_reg_3                = 32'd0;
       nxt_auto_initiate            = 1'b1;
   end
   else if ( (axi_start_mem_xfer_valid & axi_start_mem_xfer_ack) || (csr_start_mem_xfer_valid & csr_start_mem_xfer_ack) )
   begin
       nxt_axi_start_mem_xfer_valid = 1'b0; // no need to wait for the busy signal
       nxt_csr_start_mem_xfer_valid = 1'b0; 
       //nxt_xfer_mem_error           = 1'b0;  
       nxt_xfer_wr_rd               = 1'b0;
       nxt_auto_initiate            = 1'b0;
       nxt_status_en_flag           = 1'b1;
       nxt_state                    = pres_state;
   end
end


else    //actual status register read
begin
   nxt_dual_seq_mode_reg = dual_seq_mode_ack ? 1'b0 : dual_seq_mode_reg;
   nxt_axi_start_mem_xfer_valid = dual_seq_mode_ack ? 1'b0 : axi_start_mem_xfer_valid; 
   if(((check_status_reg_xfer_cmplt[17:0] == subseq_status_rd_xfer_time) & first_check & auto_initiate_status_read_seq) || (check_status_reg_xfer_cmplt == status_reg_rd_xfer_time & (!first_check)))


   begin
   
   if(~csr_start_mem_xfer_valid & (!wait_for_xfer_cmplt) & !dual_seq_mode_reg) // auto initiated after every write transfer - triggered always using CSR
   begin
       nxt_final_xfer               = 1'b0;
       nxt_state                    = pres_state;
       nxt_csr_start_mem_xfer_valid = 1'b1;
       //nxt_xfer_mem_error           = 1'b0;  
       nxt_xfer_wr_rd               = 1'b0; //read
       nxt_xfer_axi_len             = 8'd0; 
       nxt_xfer_btype               = 2'd0;
       nxt_xfer_bsize               = 3'd0;
       nxt_no_of_data_bytes         = {3'd0, no_of_auto_status_rd_data_bytes}; // read 1 byte of data
       nxt_auto_initiate            = 1'b1;
       nxt_addr_mem_xfer            = auto_initiate_status_addr;
       nxt_csr_cmd_xfer_ack_level = 1'b0;
       nxt_deassert_cs_reg          = 1'b0; 
       if(status_xfer_data_rate) // DDR
       begin
          if(status_no_of_opcode)
          begin
             nxt_seq_reg_0   = {status_cmd_opcode[15:0],CMD16_DDR,status_no_of_pins,7'd0,status_cmd_data_rate};
             nxt_seq_reg_1   = |auto_status_rd_addr_bytes ? {READ_DDR,status_no_of_pins,8'h0,ADDR_DDR,status_no_of_pins,no_of_auto_status_rd_addr_bits} :
                                {16'h0,READ_DDR,status_no_of_pins,8'h0};
             nxt_seq_reg_2   = 32'h0;
             nxt_seq_reg_3   = 32'h0;
          end
          else
          begin
          //MODE_DDR possible only for 1 bytes of CMD - not available in any memory
             nxt_seq_reg_0   = |auto_status_rd_addr_bytes ? 
                                (status_cmd_data_rate ? 
                                {ADDR_DDR,status_no_of_pins,no_of_auto_status_rd_addr_bits, CMD_DDR,status_no_of_pins,status_cmd_opcode[7:0]} :
                                {ADDR_DDR,status_no_of_pins,no_of_auto_status_rd_addr_bits, CMD,status_no_of_pins,status_cmd_opcode[7:0]}) :
                                (status_cmd_data_rate ? 
                                {READ_DDR,status_no_of_pins,8'h0, CMD_DDR,status_no_of_pins,status_cmd_opcode[7:0]} :
                                {READ_DDR,status_no_of_pins,8'h0, CMD,status_no_of_pins,status_cmd_opcode[7:0]}) ;
             nxt_seq_reg_1   = |auto_status_rd_addr_bytes ?  {16'h0, READ_DDR,status_no_of_pins,8'h0} : 32'h0;
             nxt_seq_reg_2   = 32'h0;
             nxt_seq_reg_3   = 32'h0;
          end
       end
       else // SDR
       begin
          if(status_no_of_opcode)
          begin
             nxt_seq_reg_0          = {status_cmd_opcode[15:0],CMD16_DDR,status_no_of_pins,7'd0,status_cmd_data_rate}; //8'h0 for CMD16 SDR
             nxt_seq_reg_1          = |auto_status_rd_addr_bytes ? {READ,status_no_of_pins,8'h0,ADDR,status_no_of_pins,no_of_auto_status_rd_addr_bits} :
                                       {16'h0,READ,status_no_of_pins,8'h0};
             nxt_seq_reg_2          = 32'h0;
             nxt_seq_reg_3          = 32'h0;
          end
          else
          begin
             nxt_seq_reg_0  =|auto_status_rd_addr_bytes ? {ADDR,status_no_of_pins,no_of_auto_status_rd_addr_bits,CMD,status_no_of_pins,status_cmd_opcode[7:0]} :
                              {READ,status_no_of_pins,8'h0,CMD,status_no_of_pins,status_cmd_opcode[7:0]};
             nxt_seq_reg_1  =|auto_status_rd_addr_bytes ? {16'h0,READ,status_no_of_pins,8'h0} :32'h0;
             nxt_seq_reg_2  = 32'h0;
             nxt_seq_reg_3  = 32'h0;
          end
       end                             
   end
   else if (csr_start_mem_xfer_valid & csr_start_mem_xfer_ack || (wait_for_xfer_cmplt))
   begin
       nxt_csr_start_mem_xfer_valid = 1'b0; // no need to wait for the busy signal
       if(csr_dqs_non_toggle_err)
       begin
       nxt_state               =  pres_state; 
       nxt_seq_path_reg        =  seq_path_reg;
       nxt_wait_for_xfer_cmplt = 1'b0;
       nxt_check_status_reg_xfer_cmplt =  check_status_reg_xfer_cmplt;
       nxt_first_check         = 1'b1;
       nxt_csr_cmd_xfer_success_pulse = 1'b0;
       end
       else if(mem_rd_valid)
       begin
       //nxt_mem_rd_ack = 1'b1;
       nxt_state               = (status_monitor_true || !status_monitor_en) ? seq_path_reg[(NO_OF_SEQ*4)-4 +:4] : pres_state;
       nxt_seq_path_reg        = status_monitor_true ? seq_path_reg<<4 : seq_path_reg;
       nxt_wait_for_xfer_cmplt = 1'b0;
       nxt_check_status_reg_xfer_cmplt = 31'd0;
       nxt_first_check         = status_monitor_true ? 1'b0 : 1'b1;
       nxt_csr_cmd_xfer_success_pulse = csr_xfer_reg & (status_monitor_true || !status_monitor_en) ;
       nxt_mem_xfer_auto_status_rd_done_pulse = axi_xfer_reg & (status_monitor_true || !status_monitor_en) ;
       nxt_status_en_flag      = 1'b0; 
       end
       else
       begin
       nxt_auto_initiate            = 1'b0;
       nxt_state                    = pres_state;
       nxt_wait_for_xfer_cmplt      = 1'b1;
       end
   end
   else
   begin
       nxt_state                    = pres_state;
   end
   end
 
   else
   begin
	if(auto_initiate_status_read_seq)
//When status bit monitoring is in progress, the auto-status reads can be force stopped by lowering this bit./
	begin
	nxt_csr_cmd_xfer_ack_level = csr_cmd_xfer_ack_pulse ? 1'b1 : csr_cmd_xfer_ack_level;
	nxt_deassert_cs_reg = deassert_cs ? 1'b1 : deassert_cs_reg;
      nxt_check_status_reg_xfer_cmplt = (deassert_cs_reg || csr_cmd_xfer_ack_level) || first_check ? check_status_reg_xfer_cmplt + 31'd1 : check_status_reg_xfer_cmplt;
	nxt_state = pres_state;
        nxt_seq_path_reg        = seq_path_reg;
        nxt_wait_for_xfer_cmplt = wait_for_xfer_cmplt;
        nxt_status_en_flag      = status_en_flag; 
        nxt_first_check         = first_check;
	end
	else
	begin
	nxt_csr_cmd_xfer_ack_level = csr_cmd_xfer_ack_level;
	nxt_deassert_cs_reg = deassert_cs_reg;
	nxt_check_status_reg_xfer_cmplt = 31'd0;
	nxt_state = seq_path_reg[(NO_OF_SEQ*4)-4 +:4];
        nxt_seq_path_reg        = seq_path_reg<<4;
        nxt_wait_for_xfer_cmplt = 1'b0;
        nxt_status_en_flag      = 1'b0; 
        nxt_first_check         = 1'b0;
	end
   end

end

INCR_RD_MONITOR:

   if(((check_status_reg_xfer_cmplt[17:0] == subseq_rd_xfer_time) & first_check) || (!first_check))
   begin
   
   if(~csr_start_mem_xfer_valid & (!wait_for_xfer_cmplt)) // auto initiated after every write transfer - triggered always using CSR
   begin
       nxt_final_xfer               = 1'b0;
       nxt_state                    = pres_state;
       nxt_csr_start_mem_xfer_valid = 1'b1;
       nxt_xfer_wr_rd               = 1'b0; //read
       nxt_xfer_axi_len             = 8'd0; 
       nxt_xfer_btype               = 2'd0;
       nxt_xfer_bsize               = 3'd0;
       nxt_no_of_data_bytes         = no_of_csr_rd_data_bytes; // read 1 byte of data
       nxt_auto_initiate            = 1'b1;
       nxt_addr_mem_xfer            = wr_rd_data_1; 
       if(read_xfer_data_rate) // DDR
       begin
          if(read_no_of_opcode)
          begin
             nxt_seq_reg_0   = {read_cmd_opcode[15:0],CMD16_DDR,read_no_of_pins,7'd0,read_cmd_data_rate};
             nxt_seq_reg_1   = |no_of_csr_rd_addr_bytes ? {READ_DDR,read_no_of_pins,8'h0,ADDR_DDR,read_no_of_pins,no_of_csr_rd_addr_bits} :
                                {16'h0,READ_DDR,read_no_of_pins,8'h0};
             nxt_seq_reg_2   = 32'h0;
             nxt_seq_reg_3   = 32'h0;
          end
          else
          begin
          //MODE_DDR possible only for 1 bytes of CMD - not available in any memory
             nxt_seq_reg_0   = |no_of_csr_rd_addr_bytes ? 
                                (read_cmd_data_rate ?  
                                {ADDR_DDR,read_no_of_pins,no_of_csr_rd_addr_bits, CMD_DDR,read_no_of_pins,read_cmd_opcode[7:0]} :
                                {ADDR_DDR,read_no_of_pins,no_of_csr_rd_addr_bits, CMD,read_no_of_pins,read_cmd_opcode[7:0]}) :
                                (read_cmd_data_rate ?  
                                {READ_DDR,read_no_of_pins,8'h0, CMD_DDR,read_no_of_pins,read_cmd_opcode[7:0]} :
                                {READ_DDR,read_no_of_pins,8'h0, CMD,read_no_of_pins,read_cmd_opcode[7:0]}) ;
             nxt_seq_reg_1   = |no_of_csr_rd_addr_bytes ?  {16'h0, READ_DDR,read_no_of_pins,8'h0} : 32'h0;
             nxt_seq_reg_2   = 32'h0;
             nxt_seq_reg_3   = 32'h0;
          end
       end
       else // SDR
       begin
          if(read_no_of_opcode)
          begin
             nxt_seq_reg_0          = {read_cmd_opcode[15:0],CMD16_DDR,read_no_of_pins,7'd0,read_cmd_data_rate}; //8'h0 for CMD16 SDR
             nxt_seq_reg_1          = |no_of_csr_rd_addr_bytes ? {READ,read_no_of_pins,8'h0,ADDR,read_no_of_pins,no_of_csr_rd_addr_bits} :
                                       {16'h0,READ,read_no_of_pins,8'h0};
             nxt_seq_reg_2          = 32'h0;
             nxt_seq_reg_3          = 32'h0;
          end
          else
          begin
             nxt_seq_reg_0  = |no_of_csr_rd_addr_bytes ? {ADDR,read_no_of_pins,no_of_csr_rd_addr_bits,CMD,read_no_of_pins,read_cmd_opcode[7:0]} :
                              {READ,read_no_of_pins,8'h0,CMD,read_no_of_pins,read_cmd_opcode[7:0]};
             nxt_seq_reg_1  = |no_of_csr_rd_addr_bytes ? {16'h0,READ,read_no_of_pins,8'h0} : 32'h0;
             nxt_seq_reg_2  = 32'h0;
             nxt_seq_reg_3  = 32'h0;
          end
       end                             
   end
   else if (csr_start_mem_xfer_valid & csr_start_mem_xfer_ack || (wait_for_xfer_cmplt))
   begin
       nxt_csr_start_mem_xfer_valid = 1'b0; // no need to wait for the busy signal
       nxt_csr_rd_xfer_ack_pulse  = 1'b1;
       if(csr_dqs_non_toggle_err)
       begin
       nxt_state                      =  pres_state; 
       nxt_seq_path_reg               =  seq_path_reg;
       nxt_wait_for_xfer_cmplt        = 1'b0;
       nxt_check_status_reg_xfer_cmplt=  check_status_reg_xfer_cmplt;
       nxt_first_check                = 1'b1;
       nxt_csr_rd_xfer_success_pulse    = 1'b0;
       end
       else if(mem_rd_valid)
       begin
       //nxt_mem_rd_ack          = 1'b1;
       nxt_state               = (rd_monitor_true || !rd_monitor_en) ? seq_path_reg[(NO_OF_SEQ*4)-4 +:4] : pres_state;
       nxt_seq_path_reg        = rd_monitor_true ? seq_path_reg<<4 : seq_path_reg;
       nxt_wait_for_xfer_cmplt = 1'b0;
       nxt_check_status_reg_xfer_cmplt = 31'd0;
       nxt_first_check         = rd_monitor_true ? 1'b0 : 1'b1;
       nxt_csr_rd_xfer_success_pulse    = (rd_monitor_true || !rd_monitor_en);
       end
       else
       begin
       nxt_state                    = pres_state;
       nxt_wait_for_xfer_cmplt      = 1'b1;
       end
   end
   else
   begin
       nxt_state                    = pres_state;
   end
   end
 
   else
   begin
      nxt_check_status_reg_xfer_cmplt = first_check ? check_status_reg_xfer_cmplt + 31'd1 : check_status_reg_xfer_cmplt;
	nxt_state = pres_state;
   end

endcase
end
endmodule
