

`define CSR_DPRAM_ADDR_WIDTH     10


module main_controller_wrapper
   (
   ahb_clk,
   ahb_rst_n,

   mem_clk,
   mem_rst_n,

//FROM AHB SLV CNTRL - mem_clk
   
   slv_mem_cmd_valid,
   slv_mem_addr,
   slv_arb_bytes_len, // wont be useful since it is calculated assuming memory is in OCTAL DDR mode always
   slv_mem_err,
   slv_mem_write,
   slv_mem_ahb_len,
   slv_mem_burst,
   slv_mem_size,
   slv_mem_cont_rd_req,
   slv_mem_cont_wr_req,
   slv_mem_wlast, // slv_mem_wvalid to be added to latch this information//RSR

//TO AHB SLV CNTRL
   mem_slv_cmd_ready, 
   current_xfer,

//TO AHB SLV CNTRL -ahb_clk
   spl_instrn_req,
   spl_instrn_stall,

//FROM AHB SLV CNTRL  
    spl_instrn_ack,  

//From CSR - apb_clk

    wr_seq_sel,
    rd_seq_sel,
    wr_seq_id,
    rd_seq_id,

    def_seq_sel,
   //DEF SEQ 1
    def_seq1_dword1,     
    def_seq1_dword2,     
    def_seq1_dword3,     
    def_seq1_dword4,     
   //DEF SEQ 1
    def_seq2_dword1,     
    def_seq2_dword2,     
    def_seq2_dword3,     
    def_seq2_dword4,     

    page_incr_en,
    hyperflash_en,
    mem_page_size,
    dual_seq_mode,
    cont_read_auto_status_en,

    cmd_no_of_opcode,
    cmd_xfer_data_rate,
    cmd_no_of_pins,
    cmd_opcode,
    wr_data_en,
    wdata_no_of_pins    ,
    wdata_xfer_data_rate,
    no_of_wr_data_bytes,
    csr_cmd_xfer_valid,
    wr_rd_data_1,
    wr_rd_data_2,

    read_cmd_opcode,
    read_no_of_pins,
    read_xfer_data_rate,
    read_cmd_data_rate,
    read_no_of_opcode,
    csr_rd_xfer_valid,
    no_of_csr_rd_addr_bytes,
    no_of_csr_rd_data_bytes,
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

//post write enable and write enable 2 and write enable data are specific to
//hyperflash
   auto_initiate_write_en_seq,
   auto_initiate_write_en_seq_2, 
   auto_initiate_post_wren_seq,
   post_wren_seq_data,
   auto_initiate_write_dis_seq,

    write_en_seq_reg_1,
    write_en_seq_reg_2,
    write_dis_seq_reg_1,
    write_dis_seq_reg_2,

    status_reg_en, // specific to hyperflash

//TO/From CSR - mem_clk
   seq_ram_rd_addr,
   seq_ram_rd_en,
   seq_ram_rd_data,

//To CSR
    csr_cmd_xfer_ack,
    csr_cmd_xfer_success,
    mem_xfer_auto_status_rd_done,
    csr_rd_xfer_ack,
    monitoring_xfer,

//To Memory xfer interface -mem_clk
   ahb_start_mem_xfer_valid,
   addr_mem_xfer,
   rw_len_mem_xfer,  // read - not used; write - denotes number of mem_xfer_wvalid
   xfer_mem_error,
   xfer_wr_rd,
   xfer_ahb_len,            
   xfer_btype,
   xfer_bsize,
   cont_rd_req,
   cont_wr_req,

   csr_start_mem_xfer_valid,
   no_of_data_bytes,
   no_of_xfer,

   wait_subseq_pg_wr,
   dual_seq_mode_reg,

// common for both ahb_start_mem_xfer_valid and csr_start_mem_xfer_valid
   seq_reg_0,
   seq_reg_1,
   seq_reg_2,
   seq_reg_3,
   auto_initiate,

   seq_change,

//From Memory xfer interface
   mem_rd_valid,
   mem_rd_data, 
   csr_dqs_non_toggle_err,
   enter_jump_on_cs,
   ahb_start_mem_xfer_ack,
   csr_start_mem_xfer_ack,
   csr_mem_xfer_bsy,
   subseq_pg_wr,
   deassert_cs,
   dual_seq_mode_ack,
   rd_done
   );

parameter AHB_ADDR_WIDTH = 32;
parameter AHB_DATA_WIDTH = 32;

localparam XFER_LEN_WIDTH = (AHB_DATA_WIDTH==32) ? 11 : (AHB_DATA_WIDTH==64) ? 12 : 13 ;

input   ahb_clk;
input   ahb_rst_n;

input   mem_clk;
input   mem_rst_n;

//FROM AHB SLV CNTRL
   
input                           slv_mem_cmd_valid;
input  [AHB_ADDR_WIDTH-1:0] slv_mem_addr;
input  [XFER_LEN_WIDTH-1:0]     slv_arb_bytes_len;
input                           slv_mem_err;
input                           slv_mem_write;
input  [7:0]                    slv_mem_ahb_len;
input  [1:0]                    slv_mem_burst;
input  [2:0]                    slv_mem_size;
input                           slv_mem_cont_rd_req;
input                           slv_mem_cont_wr_req;
input				slv_mem_wlast;

//TO AHB SLV CNTRL
output   mem_slv_cmd_ready; 
output   current_xfer; 

//TO AHB SLV CNTRL
output   spl_instrn_req;
output   spl_instrn_stall;

//FROM AHB SLV CNTRL
input    spl_instrn_ack;  

//Top level Strap input
input        def_seq_sel;

input [10:0] wr_seq_id;
input [10:0] rd_seq_id;
input        wr_seq_sel;
input        rd_seq_sel;
   //DEF SEQ 1
input [31:0] def_seq1_dword1;     
input [31:0] def_seq1_dword2;     
input [31:0] def_seq1_dword3;     
input [31:0] def_seq1_dword4;     
   //DEF SEQ 1
input [31:0] def_seq2_dword1;     
input [31:0] def_seq2_dword2;     
input [31:0] def_seq2_dword3;     
input [31:0] def_seq2_dword4;    

input        page_incr_en;
input        hyperflash_en;
input [3:0]  mem_page_size;
input        dual_seq_mode;
input        cont_read_auto_status_en;

//From CSR
input        cmd_no_of_opcode;
input        cmd_xfer_data_rate;
input [1:0]  cmd_no_of_pins;
input [15:0] cmd_opcode;
input        wr_data_en;
input [1:0]  wdata_no_of_pins    ;
input        wdata_xfer_data_rate;
input [5:0]  no_of_wr_data_bytes;
input        csr_cmd_xfer_valid;
input [31:0]                      wr_rd_data_1;
input [31:0]                      wr_rd_data_2;

input [15:0] read_cmd_opcode;
input [1:0]  read_no_of_pins;
input        read_xfer_data_rate;
input        read_cmd_data_rate;
input        read_no_of_opcode;
input        csr_rd_xfer_valid;
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
 
input        auto_initiate_write_en_seq;
input        auto_initiate_write_en_seq_2;
input        auto_initiate_post_wren_seq;
input [15:0] post_wren_seq_data;
input        auto_initiate_write_dis_seq;

input [31:0] write_en_seq_reg_1;
input [31:0] write_en_seq_reg_2;
input [31:0] write_dis_seq_reg_1;
input [31:0] write_dis_seq_reg_2;

input        status_reg_en;


//TO CSR
output [`CSR_DPRAM_ADDR_WIDTH -1:0]  seq_ram_rd_addr;
output                               seq_ram_rd_en;
input[31:0]                          seq_ram_rd_data;

output       csr_cmd_xfer_ack;
output       csr_cmd_xfer_success;
output       mem_xfer_auto_status_rd_done;
output       csr_rd_xfer_ack;
output       monitoring_xfer;

//To Memory xfer interface
output                            ahb_start_mem_xfer_valid;
output [AHB_ADDR_WIDTH -1 :0] addr_mem_xfer;
output [4:0]       rw_len_mem_xfer;  // read - not used; write - denotes number of mem_xfer_wvalid
output                            xfer_mem_error;
output                            xfer_wr_rd;
output   [7:0]                    xfer_ahb_len;            
output   [1:0]                    xfer_btype;
output   [2:0]                    xfer_bsize;
output                            cont_rd_req;
output                            cont_wr_req;
output                            csr_start_mem_xfer_valid;
output [5:0]                      no_of_data_bytes;
output [1:0]                      no_of_xfer;
output                            dual_seq_mode_reg;

   output wait_subseq_pg_wr;

   // common for both ahb_start_mem_xfer_valid and csr_start_mem_xfer_valid
output [31:0] seq_reg_0;
output [31:0] seq_reg_1;
output [31:0] seq_reg_2;
output [31:0] seq_reg_3;
output        auto_initiate;

output        seq_change;

//From Memory xfer interface
input   mem_rd_valid;
input[31:0]   mem_rd_data;
input   csr_dqs_non_toggle_err;
input   enter_jump_on_cs;
input   ahb_start_mem_xfer_ack;
input   csr_start_mem_xfer_ack;
input   csr_mem_xfer_bsy;
input   subseq_pg_wr;
input deassert_cs;
input   rd_done;
input   dual_seq_mode_ack;

//-----------------------------------------------------WIRE DECLARATION----------------------------------------------------
wire [31:0] wr_seq_0;
wire [31:0] wr_seq_1;
wire [31:0] wr_seq_2;
wire [31:0] wr_seq_3;

wire [31:0] rd_seq_0;
wire [31:0] rd_seq_1;
wire [31:0] rd_seq_2;
wire [31:0] rd_seq_3;

wire monitoring_xfer_unsync;
wire monitoring_xfer;

seq_ram_reader SEQ_RAM_RD
   (    
   . mem_clk            (mem_clk), 
   . reset_n_i          (mem_rst_n),

//From CSR - apb_clk  - requires apb_clk to mem_clk sync                     
   . wr_seq_sel      (wr_seq_sel),
   . rd_seq_sel      (rd_seq_sel),
   . wr_seq_id          (wr_seq_id),
   . rd_seq_id          (rd_seq_id),

   . def_seq_sel        (def_seq_sel),
    //DEF SEQ 1         
   . def_seq1_dword1    (def_seq1_dword1),
   . def_seq1_dword2    (def_seq1_dword2),
   . def_seq1_dword3    (def_seq1_dword3),
   . def_seq1_dword4    (def_seq1_dword4),
    //DEF SEQ 1         
   . def_seq2_dword1    (def_seq2_dword1),
   . def_seq2_dword2    (def_seq2_dword2),
   . def_seq2_dword3    (def_seq2_dword3),
   . def_seq2_dword4    (def_seq2_dword4),

//To CSR - mem_clk
   . seq_ram_rd_addr    (seq_ram_rd_addr),
   . seq_ram_rd_en      (seq_ram_rd_en),
   . seq_ram_rd_data    (seq_ram_rd_data),

//To main controller engine - mem_clk
   . wr_seq_valid       (wr_seq_valid),
   . wr_seq_0           (wr_seq_0),
   . wr_seq_1           (wr_seq_1),
   . wr_seq_2           (wr_seq_2),
   . wr_seq_3           (wr_seq_3),
   . rd_seq_valid       (rd_seq_valid),
   . rd_seq_0           (rd_seq_0),
   . rd_seq_1           (rd_seq_1),
   . rd_seq_2           (rd_seq_2),
   . rd_seq_3           (rd_seq_3)
   );

csr_instrn_handler CSR_INSTRN_HANDLER
(
  //Global inputs
  . apb_clk                      (apb_clk  ),
  . apb_rst_n                    (apb_rst_n),
                                           
  . mem_clk                      (mem_clk  ),
  . mem_rst_n                    (mem_rst_n),
                               
//From CSR  - apb_clk                   
  .csr_cmd_xfer_valid            (csr_cmd_xfer_valid   ),
  .csr_rd_xfer_valid             (csr_rd_xfer_valid),

//From Main control - pulse synced to ahb_clk
  .csr_cmd_xfer_success          (csr_cmd_xfer_success),
  .csr_rd_xfer_success           (csr_rd_xfer_success),

//To AHB_SLV_CNTRL -ahb_clk
  .spl_instrn_req                (spl_instrn_req  ),
  .spl_instrn_stall              (spl_instrn_stall),
                               
//From AHB_SLV_CNTRL          
  .spl_instrn_ack                (spl_instrn_ack),
  
//To Main controller engine - mem_clk -pulse
  .csr_cmd_xfer_valid_final      (csr_cmd_xfer_valid_final   ),
  .csr_rd_xfer_valid_final   (csr_rd_xfer_valid_final)
  
  
);


main_cntrl_engine  
#(
 .AHB_ADDR_WIDTH (AHB_ADDR_WIDTH),
 .AHB_DATA_WIDTH (AHB_DATA_WIDTH)
 )

MAIN_CNTRL_ENGINE
   (
//Global inputs
  . mem_clk                      (mem_clk  ),
  . mem_rst_n                    (mem_rst_n),

//From AHB_SLV_CNTRL - mem_clk
  . slv_mem_cmd_input            (slv_mem_cmd_valid  ),
  . slv_mem_addr                 (slv_mem_addr       ),
  . slv_arb_bytes_len                  (slv_arb_bytes_len        ),
  . slv_mem_err                  (slv_mem_err        ),
  . slv_mem_write                (slv_mem_write      ),
  . slv_mem_ahb_len              (slv_mem_ahb_len    ),
  . slv_mem_burst                (slv_mem_burst      ),
  . slv_mem_size                 (slv_mem_size       ),
  . slv_mem_cont_rd_req          (slv_mem_cont_rd_req),
  . slv_mem_cont_wr_req          (slv_mem_cont_wr_req),
  . slv_mem_wlast                (slv_mem_wlast      ),
                                 
//TO AHB SLV CNTRL              
  . mem_slv_cmd_ready            (mem_slv_cmd_ready),
  . current_xfer                 (current_xfer),

//From csr instruction handler - mem_clk - pulse
  .csr_cmd_xfer_valid_final      (csr_cmd_xfer_valid_final   ),
  .csr_rd_xfer_valid_final   (csr_rd_xfer_valid_final),
  .spl_instrn_stall              (spl_instrn_stall_sync),

//From CSR - apb_clk

    .page_incr_en                (page_incr_en),
    .hyperflash_en		 (hyperflash_en     ),
    .mem_page_size               (mem_page_size),
    .dual_seq_mode               (dual_seq_mode),
    .cont_read_auto_status_en    (cont_read_auto_status_en),

  .cmd_no_of_opcode              (cmd_no_of_opcode     ),
  .cmd_xfer_data_rate            (cmd_xfer_data_rate   ),
  .cmd_no_of_pins                (cmd_no_of_pins       ),
  .cmd_opcode                    (cmd_opcode           ),
  .wr_data_en                    (wr_data_en         ),
  .wdata_no_of_pins              (wdata_no_of_pins    ),
  .wdata_xfer_data_rate          (wdata_xfer_data_rate),
  .no_of_wr_data_bytes           (no_of_wr_data_bytes),
  .wr_rd_data_1   (wr_rd_data_1),  
  .wr_rd_data_2   (wr_rd_data_2),
             
  .read_cmd_opcode	 	(read_cmd_opcode	 ),      				
  .read_no_of_pins         	(read_no_of_pins        ),     					
  .read_xfer_data_rate		 (read_xfer_data_rate	 ), 
  .read_cmd_data_rate		 (read_cmd_data_rate	 ), 
  .read_no_of_opcode      	 (read_no_of_opcode      ),     					
  .no_of_csr_rd_addr_bytes     	  (no_of_csr_rd_addr_bytes      ),
  .no_of_csr_rd_data_bytes     	  (no_of_csr_rd_data_bytes      ),
  .rd_monitor_bit               (rd_monitor_bit            ), 
  .rd_monitor_value             (rd_monitor_value          ), 
  .rd_monitor_en                (rd_monitor_en            ), 
  .subseq_rd_xfer_time (subseq_rd_xfer_time),

  .status_cmd_opcode             (status_cmd_opcode    ),
  .status_no_of_pins             (status_no_of_pins    ),
  .status_xfer_data_rate         (status_xfer_data_rate),
  .status_cmd_data_rate          (status_cmd_data_rate),
  .status_no_of_opcode              (status_no_of_opcode     ),
  .status_monitor_bit               (status_monitor_bit            ), 
  .status_monitor_value             (status_monitor_value          ), 
  .status_monitor_en                (status_monitor_en            ), 
  .no_of_auto_status_rd_data_bytes           (no_of_auto_status_rd_data_bytes),
  .subseq_status_rd_xfer_time        (subseq_status_rd_xfer_time     ),
  .auto_status_rd_addr_bytes         (auto_status_rd_addr_bytes      ),
  .auto_initiate_status_read_seq     (auto_initiate_status_read_seq  ),
  .status_reg_rd_xfer_time           (status_reg_rd_xfer_time        ),
  .auto_initiate_status_addr         (auto_initiate_status_addr      ),

  .write_en_seq_reg_1            (write_en_seq_reg_1 ),
  .write_en_seq_reg_2            (write_en_seq_reg_2 ),
  .write_dis_seq_reg_1           (write_dis_seq_reg_1),
  .write_dis_seq_reg_2           (write_dis_seq_reg_2),
                                                     
  .status_reg_en                 (status_reg_en), //specific to hyperflash

//To csr
   .csr_cmd_xfer_ack_pulse        (csr_cmd_xfer_ack_pulse    ),
   .csr_cmd_xfer_success_pulse    (csr_cmd_xfer_success_pulse),
   .mem_xfer_auto_status_rd_done_pulse (mem_xfer_auto_status_rd_done_pulse),
   .csr_rd_xfer_ack_pulse     (csr_rd_xfer_ack_pulse ),
   .csr_rd_xfer_success_pulse (csr_rd_xfer_success_pulse ), // TO csr instruction handler
   .monitoring_xfer (monitoring_xfer_unsync ), // To csr

//From SEQ_RAM_READER - mem_clk

  .wr_seq_valid                  (wr_seq_valid),
  .wr_seq_0                      (wr_seq_0), // addr_ddr, cmd (page program)
  .wr_seq_1                      (wr_seq_1), //stop, write_ddr
  .wr_seq_2                      (wr_seq_2),
  .wr_seq_3                      (wr_seq_3),
  .rd_seq_valid                  (rd_seq_valid),
  .rd_seq_0                      (rd_seq_0), // addr_ddr, cmd
  .rd_seq_1                      (rd_seq_1), // read_ddr, dummy(8 cycels for 66 MHz)
  .rd_seq_2                      (rd_seq_2), //stop
  .rd_seq_3                      (rd_seq_3),

//To Memory xfer interface - mem_clk
   .ahb_start_mem_xfer_valid     (ahb_start_mem_xfer_valid),
   .addr_mem_xfer                (addr_mem_xfer     ),
   .rw_len_mem_xfer              (rw_len_mem_xfer   ),
   .xfer_mem_error               (xfer_mem_error    ),
   .xfer_wr_rd                   (xfer_wr_rd        ),
   .xfer_ahb_len                 (xfer_ahb_len      ),
   .xfer_btype                   (xfer_btype        ),
   .xfer_bsize                   (xfer_bsize        ),
   .cont_rd_req                  (cont_rd_req       ),
   .cont_wr_req                  (cont_wr_req       ),
                                                    
   .csr_start_mem_xfer_valid     (csr_start_mem_xfer_valid),
   .no_of_data_bytes             (no_of_data_bytes),
   .no_of_xfer		         (no_of_xfer),

      .wait_subseq_pg_wr (wait_subseq_pg_wr),
      .dual_seq_mode_reg (dual_seq_mode_reg),

// common for both axi_start_mem_xfer_valid and csr_start_mem_xfer_valid
   .seq_reg_0                    (seq_reg_0    ),
   .seq_reg_1                    (seq_reg_1    ),
   .seq_reg_2                    (seq_reg_2    ),
   .seq_reg_3                    (seq_reg_3    ),
   .auto_initiate                (auto_initiate),

//post write enable and write enable 2 and write enable data are specific to
//hyperflash
  .auto_initiate_write_en_seq   (auto_initiate_write_en_seq),
  .auto_initiate_write_en_seq_2 (auto_initiate_write_en_seq_2),
  .auto_initiate_post_wren_seq  (auto_initiate_post_wren_seq),
  .post_wren_seq_data           (post_wren_seq_data),
  .auto_initiate_write_dis_seq   (auto_initiate_write_dis_seq),

   .seq_change                  (seq_change),

//From Memory xfer interface - mem_clk
   .mem_rd_valid      (mem_rd_valid),
   .mem_rd_data       (mem_rd_data), 
   .csr_dqs_non_toggle_err       (csr_dqs_non_toggle_err),
   .enter_jump_on_cs             (enter_jump_on_cs),
   .ahb_start_mem_xfer_ack       (ahb_start_mem_xfer_ack),
   .csr_start_mem_xfer_ack       (csr_start_mem_xfer_ack),
   .csr_mem_xfer_bsy             (csr_mem_xfer_bsy      ),
   .subseq_pg_wr			 (subseq_pg_wr               ),
   .deassert_cs (deassert_cs),
   .dual_seq_mode_ack (dual_seq_mode_ack),
   .rd_done                      (rd_done		)
   );


//pulse synchronizer

fb_sync  CSR_CMD_XFER_ACK_PULSE_SYNC(
   .clkA   (mem_clk),
   .clkB   (apb_clk),
   .resetA (mem_rst_n),
   .resetB (apb_rst_n),
   .inA    (csr_cmd_xfer_ack_pulse),
   .inB    (),
   .inB_pulse    (csr_cmd_xfer_ack)
);

fb_sync  CSR_CMD_XFER_SUCCESS_PULSE_SYNC(
   .clkA   (mem_clk),
   .clkB   (apb_clk),
   .resetA (mem_rst_n),
   .resetB (apb_rst_n),
   .inA    (csr_cmd_xfer_success_pulse),
   .inB    (),
   .inB_pulse    (csr_cmd_xfer_success)
);

fb_sync  CSR_STATUS_XFER_ACK_PULSE_SYNC(
   .clkA   (mem_clk),
   .clkB   (apb_clk),
   .resetA (mem_rst_n),
   .resetB (apb_rst_n),
   .inA    (csr_rd_xfer_ack_pulse),
   .inB    (),
   .inB_pulse    (csr_rd_xfer_ack)
);

fb_sync  CSR_STATUS_XFER_SUCCESS_PULSE_SYNC(
   .clkA   (mem_clk),
   .clkB   (apb_clk),
   .resetA (mem_rst_n),
   .resetB (apb_rst_n),
   .inA    (csr_rd_xfer_success_pulse),
   .inB    (),
   .inB_pulse    (csr_rd_xfer_success)
);

fb_sync  MEM_AUTO_STATUS_RD_DONE_PULSE_SYNC(
   .clkA   (mem_clk),
   .clkB   (ahb_clk),
   .resetA (mem_rst_n),
   .resetB (ahb_rst_n),
   .inA    (mem_xfer_auto_status_rd_done_pulse),
   .inB    (),
   .inB_pulse    (mem_xfer_auto_status_rd_done)
);

double_flop_sync #( 
          1
          )		 
 SPL_INSTRN_STALL_SYNC(
          .clk        (mem_clk),	
          .rst_n      (mem_rst_n),
          .async_in   (spl_instrn_stall),	
          .sync_out   (spl_instrn_stall_sync)
);

double_flop_sync #( 
          1
          )		 
 MONITORING_XFER_SYNC(
          .clk        (ahb_clk),	
          .rst_n      (ahb_rst_n),
          .async_in   (monitoring_xfer_unsync),	
          .sync_out   (monitoring_xfer)
);


endmodule
