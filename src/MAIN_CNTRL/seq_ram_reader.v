`define CSR_DPRAM_ADDR_WIDTH     10

module seq_ram_reader (
                      mem_clk,
                      reset_n_i,

                      wr_seq_sel,
                      rd_seq_sel,
                      wr_seq_id,
                      rd_seq_id,
                      seq_ram_rd_addr,
                      seq_ram_rd_en,
                      seq_ram_rd_data,

                      wr_seq_valid,
                      wr_seq_0,
                      wr_seq_1,
                      wr_seq_2,
                      wr_seq_3,

                      rd_seq_valid,
                      rd_seq_0,
                      rd_seq_1,
                      rd_seq_2,
                      rd_seq_3,

                      def_seq_sel,
                      def_seq1_dword1,
                      def_seq1_dword2,
                      def_seq1_dword3,
                      def_seq1_dword4,
                      def_seq2_dword1,
                      def_seq2_dword2,
                      def_seq2_dword3,
                      def_seq2_dword4
                     );

parameter SEQ_RAM_DATA_WIDTH = 32;
parameter SEQ_RAM_ADDR_WIDTH = 10;
parameter IDLE               = 2'b00;
parameter WRITE_SEQ          = 2'b01;
parameter READ_SEQ           = 2'b10;


input                                  mem_clk;
input                                  reset_n_i;

input                                  wr_seq_sel; //pulse 
input                                  rd_seq_sel; //pulse 
input [SEQ_RAM_ADDR_WIDTH:0]           wr_seq_id;
input [SEQ_RAM_ADDR_WIDTH:0]           rd_seq_id;

input                                  def_seq_sel; // strap input
input [31:0]                           def_seq1_dword1;
input [31:0]                           def_seq1_dword2;
input [31:0]                           def_seq1_dword3;
input [31:0]                           def_seq1_dword4;
input [31:0]                           def_seq2_dword1;
input [31:0]                           def_seq2_dword2;
input [31:0]                           def_seq2_dword3;
input [31:0]                           def_seq2_dword4;

output [SEQ_RAM_ADDR_WIDTH-1:0]        seq_ram_rd_addr;
output 		                       seq_ram_rd_en;
input [SEQ_RAM_DATA_WIDTH-1:0]         seq_ram_rd_data;

output				       wr_seq_valid;//level
output [SEQ_RAM_DATA_WIDTH-1:0]        wr_seq_0;
output [SEQ_RAM_DATA_WIDTH-1:0]        wr_seq_1;
output [SEQ_RAM_DATA_WIDTH-1:0]        wr_seq_2;
output [SEQ_RAM_DATA_WIDTH-1:0]        wr_seq_3;

output				       rd_seq_valid;//level
output [SEQ_RAM_DATA_WIDTH-1:0]        rd_seq_0;
output [SEQ_RAM_DATA_WIDTH-1:0]        rd_seq_1;
output [SEQ_RAM_DATA_WIDTH-1:0]        rd_seq_2;
output [SEQ_RAM_DATA_WIDTH-1:0]        rd_seq_3;

reg [SEQ_RAM_ADDR_WIDTH-1:0]        nxt_seq_ram_rd_addr,seq_ram_rd_addr;
reg 	                            nxt_seq_ram_rd_en, seq_ram_rd_en;
reg				    nxt_wr_seq_valid ,  wr_seq_valid   ;
reg				    nxt_wr_seq_sel_reg ,  wr_seq_sel_reg   ;
reg				    nxt_rd_seq_sel_reg ,  rd_seq_sel_reg   ;
reg [SEQ_RAM_DATA_WIDTH-1:0]        nxt_wr_seq_0     ,  wr_seq_0       ;
reg [SEQ_RAM_DATA_WIDTH-1:0]        nxt_wr_seq_1     ,  wr_seq_1       ;
reg [SEQ_RAM_DATA_WIDTH-1:0]        nxt_wr_seq_2     ,  wr_seq_2       ;
reg [SEQ_RAM_DATA_WIDTH-1:0]        nxt_wr_seq_3     ,  wr_seq_3       ;
reg				    nxt_rd_seq_valid ,  rd_seq_valid   ;
reg [SEQ_RAM_DATA_WIDTH-1:0]        nxt_rd_seq_0     ,  rd_seq_0       ;
reg [SEQ_RAM_DATA_WIDTH-1:0]        nxt_rd_seq_1     ,  rd_seq_1       ;
reg [SEQ_RAM_DATA_WIDTH-1:0]        nxt_rd_seq_2     ,  rd_seq_2       ;
reg [SEQ_RAM_DATA_WIDTH-1:0]        nxt_rd_seq_3     ,  rd_seq_3       ;
reg [1:0]                           nxt_state        ,  cur_state      ;
reg [2:0]                           nxt_data_cntr    ,  data_cntr      ;   
reg                                 nxt_entry_flag   ,  entry_flag     ;

always @ (posedge mem_clk or negedge reset_n_i)
begin
 if (!reset_n_i)
  begin
    wr_seq_valid       <=  1'b0 ;
    wr_seq_0           <=  32'd0;
    wr_seq_1           <=  32'd0;        
    wr_seq_2           <=  32'd0;
    wr_seq_3           <=  32'd0;
    rd_seq_valid       <=  1'b0 ;
    rd_seq_0           <=  32'd0;
    rd_seq_1           <=  32'd0;        
    rd_seq_2           <=  32'd0;
    rd_seq_3           <=  32'd0;
    cur_state          <=  IDLE ;
    data_cntr          <=  3'd0 ;
    seq_ram_rd_addr    <=  11'd0;
    seq_ram_rd_en      <=  1'b0;
    entry_flag         <=  1'b0 ;
    rd_seq_sel_reg  <= 1'b0  ;
    wr_seq_sel_reg  <= 1'b0  ;
 end
 else
   begin
    wr_seq_valid       <=  nxt_wr_seq_valid  ;   
    wr_seq_0           <=  nxt_wr_seq_0      ;
    wr_seq_1           <=  nxt_wr_seq_1      ;
    wr_seq_2           <=  nxt_wr_seq_2      ;
    wr_seq_3           <=  nxt_wr_seq_3      ;
    rd_seq_valid       <=  nxt_rd_seq_valid  ;
    rd_seq_0           <=  nxt_rd_seq_0      ;
    rd_seq_1           <=  nxt_rd_seq_1      ;
    rd_seq_2           <=  nxt_rd_seq_2      ;
    rd_seq_3           <=  nxt_rd_seq_3      ;
    cur_state          <=  nxt_state         ;
    data_cntr          <=  nxt_data_cntr     ;
    seq_ram_rd_addr    <=  nxt_seq_ram_rd_addr ; 
    seq_ram_rd_en      <=  nxt_seq_ram_rd_en ; 
    entry_flag         <=  nxt_entry_flag    ;
    rd_seq_sel_reg  <=  nxt_rd_seq_sel_reg;
    wr_seq_sel_reg  <=  nxt_wr_seq_sel_reg;
  end 
end

always @ *
begin
   //nxt_both_seq_change = (wr_seq_sel & rd_seq_sel) ? 1'b1 : (wr_seq_sel ^ rd_seq_sel) ? 1'b0 : both_seq_change;
   //nxt_rd_seq_sel_reg =  ((rd_seq_sel & !wr_seq_sel) || load_rd_seq_pulse) ? 1'b1 : rd_seq_sel_reg;
   //nxt_wr_seq_sel_reg =  ((wr_seq_sel & !rd_seq_sel) || load_wr_seq_pulse) ? 1'b1 : wr_seq_sel_reg;
   //nxt_wr_seq_valid     =   (wr_seq_sel || rd_seq_sel || load_rd_seq_pulse || load_wr_seq_pulse) ? 1'b0 : wr_seq_valid;
   nxt_rd_seq_sel_reg     =  rd_seq_sel ? 1'b1 : rd_seq_sel_reg;
   nxt_wr_seq_sel_reg     =  wr_seq_sel ? 1'b1 : wr_seq_sel_reg;
   nxt_wr_seq_valid     =   wr_seq_sel ? 1'b0 : wr_seq_valid;
   nxt_wr_seq_0         =   wr_seq_0;
   nxt_wr_seq_1         =   wr_seq_1;
   nxt_wr_seq_2         =   wr_seq_2;
   nxt_wr_seq_3         =   wr_seq_3;
   //nxt_rd_seq_valid     =   (wr_seq_sel || rd_seq_sel || load_rd_seq_pulse || load_wr_seq_pulse) ? 1'b0 : rd_seq_valid;
   nxt_rd_seq_valid     =   rd_seq_sel ? 1'b0 : rd_seq_valid;
   nxt_rd_seq_0         =   rd_seq_0;
   nxt_rd_seq_1         =   rd_seq_1;
   nxt_rd_seq_2         =   rd_seq_2;
   nxt_rd_seq_3         =   rd_seq_3;
   nxt_state            =   cur_state;
   nxt_data_cntr        =   data_cntr;
   nxt_seq_ram_rd_addr  =   seq_ram_rd_addr ;
   nxt_seq_ram_rd_en    =   1'b0 ;
   nxt_entry_flag       =   entry_flag      ; 
case (cur_state)
  IDLE :
    begin
      if(rd_seq_id[10] & !entry_flag)
       begin
          nxt_rd_seq_0          = def_seq_sel ? def_seq2_dword1 : def_seq1_dword1 ;
          nxt_rd_seq_1          = def_seq_sel ? def_seq2_dword2 : def_seq1_dword2 ;
          nxt_rd_seq_2          = def_seq_sel ? def_seq2_dword3 : def_seq1_dword3 ;
          nxt_rd_seq_3          = def_seq_sel ? def_seq2_dword4 : def_seq1_dword4 ;
          nxt_rd_seq_valid      = 1'b1 ;
          nxt_entry_flag        = 1'b1 ;
          nxt_state             = cur_state  ;
       end
       else if (rd_seq_sel_reg)
         begin
            if(rd_seq_id[10])
              begin
                nxt_rd_seq_0          = def_seq_sel ? def_seq2_dword1 : def_seq1_dword1 ;
                nxt_rd_seq_1          = def_seq_sel ? def_seq2_dword2 : def_seq1_dword2 ;
                nxt_rd_seq_2          = def_seq_sel ? def_seq2_dword3 : def_seq1_dword3 ;
                nxt_rd_seq_3          = def_seq_sel ? def_seq2_dword4 : def_seq1_dword4 ;
                nxt_rd_seq_valid      = 1'b1 ;
                nxt_rd_seq_sel_reg = 1'b0 ;
                nxt_state             = cur_state  ;
              end
            else
              begin
                nxt_state           = READ_SEQ  ;
                nxt_seq_ram_rd_addr = rd_seq_id[9:0] ;
                nxt_seq_ram_rd_en   = 1'b1 ;
                nxt_rd_seq_valid    = 1'b0 ;
              end
         end

      else if (wr_seq_sel_reg & (!wr_seq_id[10]))
         begin  
          nxt_state           = WRITE_SEQ ;
          nxt_seq_ram_rd_addr = wr_seq_id[9:0] ;
          nxt_seq_ram_rd_en = 1'b1;
         end
      else if (wr_seq_sel_reg & (wr_seq_id[10]))
         begin  
          nxt_wr_seq_sel_reg  = 1'b0;
          nxt_state           = cur_state   ;
          nxt_seq_ram_rd_addr = seq_ram_rd_addr ;
         end
         else
         begin
          nxt_state           = cur_state   ;
          nxt_seq_ram_rd_addr = seq_ram_rd_addr ;
         end
     end

  WRITE_SEQ :
    begin
      nxt_data_cntr         = (data_cntr == 4) ? 3'd0 : data_cntr +1 ;
      nxt_seq_ram_rd_addr   = seq_ram_rd_addr + 4 ; //wr_seq_id[9:0]+4;
      nxt_seq_ram_rd_en     = 1'b1;
      //nxt_seq_ram_rd_addr   = (|(seq_ram_rd_addr ^ seq_ram_wr_rd_addr)) ? seq_ram_rd_addr + 4 : seq_ram_rd_addr; //To avoid X read out from the sequence RAM if out of 4 locations only 3 are programmed and for the remaining 1 unprogrammed location data will be X.
      //nxt_seq_ram_rd_en     = (|(seq_ram_rd_addr ^ seq_ram_wr_rd_addr)) ? 1'b1 : 1'b0;
      nxt_wr_seq_0          = (data_cntr == 1) ? seq_ram_rd_data : wr_seq_0 ;
      nxt_wr_seq_1          = (data_cntr == 2) ? seq_ram_rd_data : wr_seq_1;
      nxt_wr_seq_2          = (data_cntr == 3) ? seq_ram_rd_data : wr_seq_2;
      nxt_wr_seq_3          = (data_cntr == 4) ? seq_ram_rd_data : wr_seq_3;
      nxt_wr_seq_valid      = (data_cntr == 4) ? 1'b1 : wr_seq_valid ;
      nxt_wr_seq_sel_reg = (data_cntr == 4) ? 1'b0 : wr_seq_sel_reg ;
      nxt_state             = (data_cntr == 4) ? IDLE : cur_state   ;
    end

 READ_SEQ :
       begin
      nxt_data_cntr         = (data_cntr == 4) ? 3'd0 : data_cntr +1 ;
      nxt_seq_ram_rd_addr   = seq_ram_rd_addr + 4 ; //wr_seq_id[9:0]+4;
      nxt_seq_ram_rd_en     = 1'b1;
      //nxt_seq_ram_rd_addr   = (|(seq_ram_rd_addr ^ seq_ram_wr_rd_addr)) ? seq_ram_rd_addr + 4 : seq_ram_rd_addr; //rd_seq_id[9:0]+4;
      //nxt_seq_ram_rd_en     = (|(seq_ram_rd_addr ^ seq_ram_wr_rd_addr)) ? 1'b1 : 1'b0;
      nxt_rd_seq_0          = (data_cntr == 1) ? seq_ram_rd_data : rd_seq_0 ;
      nxt_rd_seq_1          = (data_cntr == 2) ? seq_ram_rd_data : rd_seq_1;
      nxt_rd_seq_2          = (data_cntr == 3) ? seq_ram_rd_data : rd_seq_2;
      nxt_rd_seq_3          = (data_cntr == 4) ? seq_ram_rd_data : rd_seq_3;
      nxt_rd_seq_valid      = (data_cntr == 4) ? 1'b1 : rd_seq_valid ;
      nxt_rd_seq_sel_reg      = (data_cntr == 4) ? 1'b0 : rd_seq_sel_reg ;
      nxt_state             = (data_cntr == 4) ? IDLE : cur_state   ;
       end
default :
   begin
        nxt_wr_seq_valid     =   wr_seq_valid;
        nxt_wr_seq_0         =   wr_seq_0;
        nxt_wr_seq_1         =   wr_seq_1;
        nxt_wr_seq_2         =   wr_seq_2;
        nxt_wr_seq_3         =   wr_seq_3;
        nxt_rd_seq_valid     =   rd_seq_valid;
        nxt_rd_seq_0         =   rd_seq_0;
        nxt_rd_seq_1         =   rd_seq_1;
        nxt_rd_seq_2         =   rd_seq_2;
        nxt_rd_seq_3         =   rd_seq_3;
        nxt_state            =   cur_state;
        nxt_data_cntr        =   data_cntr;
        nxt_seq_ram_rd_addr  =   seq_ram_rd_addr ;
        nxt_seq_ram_rd_en    =   seq_ram_rd_en ;
        nxt_rd_seq_sel_reg = rd_seq_sel_reg;
        nxt_wr_seq_sel_reg = wr_seq_sel_reg;

   end
endcase
end
endmodule
