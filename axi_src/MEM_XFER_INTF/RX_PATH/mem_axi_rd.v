//====================================================================================
// 
// 
// 
// 
//====================================================================================

`timescale 1ns/1ps
module mem_axi_rd (

     mem_clk, 
     reset_n,


     mem_axi_rd_start,
     mem_axi_btype,
     mem_axi_rd_addr_lsb,
     mem_slv_axi_len,
     mem_axi_size,
     mem_axi_rd_err,

     mem_dqs_time_out, 
     mem_illegal_instrn_err,

     mem_16bit_rdata_valid,
     mem_16bit_rdata_in,
     mem_16bit_rdata_ack,

     mem_slv_rdata_valid, 
     mem_slv_rdata, 
     mem_slv_rdata_last, 
     mem_slv_rdata_resp,
     slv_mem_rdata_ack
    

);

parameter SLV_AXI_DATA_WIDTH  = 32;
parameter MEM_FIFO_DATA_WIDTH = 16;
                         


//*********************************INPUTS & OUTPUTS************************************
 
input                                  mem_clk;
input                                  reset_n;


input                                  mem_axi_rd_start;
input  [ 1 : 0 ]                       mem_axi_btype;
input  [ 3 : 0 ]                       mem_axi_rd_addr_lsb;
input  [ 7 : 0 ]                       mem_slv_axi_len;
input  [ 2 : 0 ]                       mem_axi_size;
input                         mem_axi_rd_err; 
input                                  mem_dqs_time_out;
input                                  mem_illegal_instrn_err;

input            mem_16bit_rdata_valid;
input    [15:0]  mem_16bit_rdata_in;
output           mem_16bit_rdata_ack;

output                                 mem_slv_rdata_valid;
output [SLV_AXI_DATA_WIDTH-1 : 0 ]     mem_slv_rdata;
output                                 mem_slv_rdata_last;
output [ 1 : 0 ]                       mem_slv_rdata_resp;
input                                  slv_mem_rdata_ack;


//===================================================================================

reg    [ 1 : 0 ]                       mem_slv_rdata_resp;
reg    [ 8 : 0 ]                       rd_len_cnt;
reg                                    mem_axi_rd_start_reg;
reg                          mem_axi_rd_err_reg;
reg                                    mem_axi_rd_err_en;
reg                                    wrap_frst_rdata_valid;
reg    [ 2 : 0 ]                       mem_axi_size_reg;
reg    [ 3 : 0 ]                       mem_axi_rd_addr_lsb_reg;
//reg    [ 7 : 0 ]                       mem_slv_axi_len_reg;

reg    [ 1 : 0 ]                       mem_axi_btype_reg;

reg                                    mem_dqs_timeout_en;
reg                                    mem_err_en;
reg mem_illegal_instrn_err_redge_reg, nxt_mem_illegal_instrn_err_redge_reg, mem_illegal_instrn_err_d1;

wire                                   rd_len_cnt_over;
//wire                                   rd_len_cnt_lt_eq_2;

wire mem_16bit_rdata_ack; 
wire mem_illegal_instrn_err_redge;
assign mem_illegal_instrn_err_redge = mem_illegal_instrn_err & (!mem_illegal_instrn_err_d1);

//********************************CODE STARTHERE*************************************




//===================================================================================
// 32-bit AXI DATA WIDTH 
//===================================================================================

generate 


if ( SLV_AXI_DATA_WIDTH == 32 ) // SLV DATA WIDTH 32 BEGIN
begin

reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  byte_rdata_reg;
reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  word_hw_1_rdata_reg;



always @ ( posedge mem_clk or negedge reset_n )
begin
   if ( ~reset_n )
   begin
      rd_len_cnt               <= 'd0;
      mem_axi_rd_start_reg     <= 1'b0; 
      mem_axi_rd_err_reg       <= 1'b0;
      mem_axi_rd_err_en        <= 1'b0;
      mem_err_en               <= 1'b0;
      mem_axi_size_reg         <= 'd0;
      mem_axi_rd_addr_lsb_reg  <= 'd0;
      mem_axi_btype_reg        <= 'd0;
      mem_illegal_instrn_err_d1 <= 1'b0;
      mem_illegal_instrn_err_redge_reg <= 1'b0;
      mem_dqs_timeout_en       <= 1'b0;
   end
   else
   begin
      mem_illegal_instrn_err_d1 <= mem_illegal_instrn_err;
      mem_illegal_instrn_err_redge_reg <= nxt_mem_illegal_instrn_err_redge_reg;
      if ( mem_axi_rd_start  )
         rd_len_cnt   <=  mem_slv_axi_len + 1 ; 
      else if ( mem_slv_rdata_valid & slv_mem_rdata_ack ) 
         rd_len_cnt   <= rd_len_cnt - 1; 

      if ( mem_axi_rd_start & (mem_axi_rd_err == 1'b0 ))
         mem_axi_rd_start_reg  <= 1'b1;
      else if ( mem_16bit_rdata_valid | mem_dqs_time_out | mem_dqs_timeout_en | mem_illegal_instrn_err_redge_reg)
         mem_axi_rd_start_reg  <= 1'b0;
      else
         mem_axi_rd_start_reg  <= mem_axi_rd_start_reg;

      if ( mem_axi_rd_start )
         mem_axi_rd_err_reg  <= mem_axi_rd_err;
      else if ( rd_len_cnt_over )
         mem_axi_rd_err_reg  <= 1'b0;
      else
         mem_axi_rd_err_reg  <= mem_axi_rd_err_reg;


      if ( (mem_axi_rd_start &  mem_axi_rd_err) | (mem_axi_rd_start_reg & (mem_dqs_time_out || mem_dqs_timeout_en)) |  
           (mem_axi_rd_start_reg & mem_illegal_instrn_err_redge_reg) )
         mem_axi_rd_err_en   <= 1'b1;
      else if ( rd_len_cnt_over  )
         mem_axi_rd_err_en   <= 1'b0;

      if ( ( mem_axi_rd_start_reg & (mem_dqs_time_out || mem_dqs_timeout_en) ) | (mem_axi_rd_start_reg & mem_illegal_instrn_err_redge_reg))
         mem_err_en   <= 1'b1;
      else if ( rd_len_cnt_over  )
         mem_err_en   <= 1'b0;
	 
      if (mem_dqs_time_out )
         mem_dqs_timeout_en   <= 1'b1;
      else
         mem_dqs_timeout_en   <= mem_dqs_timeout_en;

      if ( mem_axi_rd_start )
      begin
         mem_axi_size_reg  <= mem_axi_size;
         mem_axi_rd_addr_lsb_reg <= mem_axi_rd_addr_lsb; 
         mem_axi_btype_reg   <= mem_axi_btype;
      end
      else
      begin
         mem_axi_size_reg  <= mem_axi_size_reg;
         mem_axi_rd_addr_lsb_reg <= mem_axi_rd_addr_lsb_reg; 
         mem_axi_btype_reg   <= mem_axi_btype_reg;
      end
   end
end




assign rd_len_cnt_over    = ( rd_len_cnt <= 1 );
//assign rd_len_cnt_lt_eq_2 = ( rd_len_cnt <= 2 );

//===================================================================================
// 32-bit AXI READ DATA INTERFACE 
//===================================================================================

reg  [3:0] mem_axird_cur_state;
reg  [3:0] mem_axird_nxt_state;

localparam [3:0]  MEM_AXIRD_IDLE           = 0;
localparam [3:0]  MEM_BYTE_DATA_1          = 1;
localparam [3:0]  MEM_BYTE_DATA_2          = 2;
localparam [3:0]  MEM_BYTE_DATA_1_WAIT     = 3;
localparam [3:0]  MEM_HWORD_DATA           = 4;
localparam [3:0]  MEM_HWORD_DATA_WAIT      = 5;
localparam [3:0]  MEM_WORD_HW_DATA_1       = 6;
localparam [3:0]  MEM_WORD_HW_DATA_2       = 7;
localparam [3:0]  MEM_WORD_HW_DATA_1_WAIT  = 8;
localparam [3:0]  MEM_WORD_HW_DATA_2_WAIT  = 9;
localparam [3:0]  MEM_ERROR_DATA           = 10;
//===================================================================================


always @ (*)
begin
      nxt_mem_illegal_instrn_err_redge_reg = mem_illegal_instrn_err_redge ? 1'b1 : rd_len_cnt_over ? 1'b0 : mem_illegal_instrn_err_redge_reg;
   case (mem_axird_cur_state )
      MEM_AXIRD_IDLE :
      begin
         if ( mem_axi_rd_err_en )
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_axi_rd_start_reg & (mem_axi_size_reg == 3'd0 ) & mem_16bit_rdata_valid )
         begin
            if ( mem_axi_rd_addr_lsb_reg[0] ) 
               mem_axird_nxt_state = MEM_BYTE_DATA_2;
            else
               mem_axird_nxt_state = MEM_BYTE_DATA_1;
         end
         else if ( mem_axi_rd_start_reg & (mem_axi_size_reg == 3'd1 ) & mem_16bit_rdata_valid)
            mem_axird_nxt_state = MEM_HWORD_DATA;
         else if ( mem_axi_rd_start_reg & (mem_axi_size_reg == 3'd2 ) & mem_16bit_rdata_valid)
         begin
            if ( mem_axi_rd_addr_lsb_reg[1] ) 
               mem_axird_nxt_state = MEM_WORD_HW_DATA_2;
            else
               mem_axird_nxt_state = MEM_WORD_HW_DATA_1;
         end
         else
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
      end
      // BYTE 1
      MEM_BYTE_DATA_1 :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if ( slv_mem_rdata_ack )
            mem_axird_nxt_state = MEM_BYTE_DATA_2; 
         else 
            mem_axird_nxt_state = MEM_BYTE_DATA_1; 
      end 
      // BYTE 2 
      MEM_BYTE_DATA_2 :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if ( slv_mem_rdata_ack)
            mem_axird_nxt_state = MEM_BYTE_DATA_1_WAIT; 
         else 
            mem_axird_nxt_state = MEM_BYTE_DATA_2; 
      end 

      MEM_BYTE_DATA_1_WAIT : 
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_BYTE_DATA_1; 
         else    
            mem_axird_nxt_state = MEM_BYTE_DATA_1_WAIT; 
      end

      //  HALF WORD  
      MEM_HWORD_DATA : 
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if ( slv_mem_rdata_ack )
            mem_axird_nxt_state = MEM_HWORD_DATA_WAIT; 
         else    
            mem_axird_nxt_state = MEM_HWORD_DATA; 
      end

      MEM_HWORD_DATA_WAIT : 
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_HWORD_DATA; 
         else    
            mem_axird_nxt_state = MEM_HWORD_DATA_WAIT; 
      end

      // WORD HALFWORD 1 
      MEM_WORD_HW_DATA_1 :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else    
            mem_axird_nxt_state = MEM_WORD_HW_DATA_2_WAIT; 
      end

      // WORD HALFWORD 2 
      MEM_WORD_HW_DATA_2 :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if (slv_mem_rdata_ack )
            mem_axird_nxt_state = MEM_WORD_HW_DATA_1_WAIT ; 
         else 
            mem_axird_nxt_state = MEM_WORD_HW_DATA_2; 
      end
      
      // WORD HALFWORD 2 WAIT 
      MEM_WORD_HW_DATA_2_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_WORD_HW_DATA_2; 
         else    
            mem_axird_nxt_state = MEM_WORD_HW_DATA_2_WAIT; 
      end

    // WORD HALFWORD 1 WAIT 
      MEM_WORD_HW_DATA_1_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_WORD_HW_DATA_1; 
         else    
            mem_axird_nxt_state = MEM_WORD_HW_DATA_1_WAIT; 
      end


      // ERROR DATA 
      MEM_ERROR_DATA :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else 
            mem_axird_nxt_state = MEM_ERROR_DATA; 
      end 

      default :
      begin
         mem_axird_nxt_state = MEM_AXIRD_IDLE;
      end
   endcase
end



always @ ( posedge mem_clk or negedge reset_n )
begin
   if ( ~reset_n )
   begin
      mem_axird_cur_state    <= MEM_AXIRD_IDLE; 
      byte_rdata_reg         <= 'd0;
      word_hw_1_rdata_reg    <= 'd0;
   end
   else
   begin
      mem_axird_cur_state    <= mem_axird_nxt_state; 
      if ( mem_16bit_rdata_valid & (( mem_axird_cur_state == MEM_AXIRD_IDLE ) & (mem_axird_nxt_state == MEM_BYTE_DATA_2)) & 
                               (mem_axi_btype_reg == 2'b10 )   ) 
         byte_rdata_reg      <= mem_16bit_rdata_in; 
      if ( mem_axird_cur_state == MEM_WORD_HW_DATA_1 )
         word_hw_1_rdata_reg <= mem_16bit_rdata_in;
   end
end

//assign mem_16bit_rdata_ack  = ((( mem_axird_cur_state == MEM_AXIRD_IDLE ) & mem_axi_rd_start_reg) |
//                             ((mem_axird_cur_state == MEM_BYTE_DATA_2 ) & slv_mem_rdata_ack & ( (~rd_len_cnt_over & (mem_axi_btype_reg != 2'b10) ) | 
//                                                                                                (~rd_len_cnt_lt_eq_2 & (mem_axi_btype_reg == 2'b10 )))) |  
//                             ( mem_axird_cur_state == MEM_BYTE_DATA_1_WAIT  ) | 
//                             ((mem_axird_cur_state == MEM_HWORD_DATA  ) & slv_mem_rdata_ack & ~rd_len_cnt_over ) | 
//                             ( mem_axird_cur_state == MEM_HWORD_DATA_WAIT  ) | 
//                             ( mem_axird_cur_state == MEM_WORD_HW_DATA_1  ) | 
//                             ( mem_axird_cur_state == MEM_WORD_HW_DATA_1_WAIT ) | 
//                             ((mem_axird_cur_state == MEM_WORD_HW_DATA_2  ) & slv_mem_rdata_ack & ~rd_len_cnt_over ) 
//                             ) & mem_16bit_rdata_valid  ; 

assign mem_16bit_rdata_ack  = (((mem_axird_cur_state == MEM_BYTE_DATA_1  ) & slv_mem_rdata_ack & rd_len_cnt_over & (mem_axi_btype_reg != 2'b10)) | 
                             ((mem_axird_cur_state == MEM_BYTE_DATA_2 ) & slv_mem_rdata_ack ) |  
                             ((mem_axird_cur_state == MEM_HWORD_DATA  ) & slv_mem_rdata_ack ) | 
                             ( mem_axird_cur_state == MEM_WORD_HW_DATA_1  ) | 
                             ((mem_axird_cur_state == MEM_WORD_HW_DATA_2  ) & slv_mem_rdata_ack) 
                             ) & mem_16bit_rdata_valid  ; 


assign mem_slv_rdata_valid = ( ( mem_axird_cur_state == MEM_BYTE_DATA_1 ) |
                               ( mem_axird_cur_state == MEM_BYTE_DATA_2 ) | 
                               ( mem_axird_cur_state == MEM_HWORD_DATA  ) | 
                               ( mem_axird_cur_state == MEM_WORD_HW_DATA_2 ) |
                               ( mem_axird_cur_state == MEM_ERROR_DATA ) ) ;


assign mem_slv_rdata       = (( mem_axird_cur_state == MEM_BYTE_DATA_1) & ~rd_len_cnt_over )  ? {2{mem_16bit_rdata_in}} : 
                             ( mem_axird_cur_state == MEM_BYTE_DATA_2 )    ? {2{mem_16bit_rdata_in}}  : 
                             ((mem_axird_cur_state == MEM_BYTE_DATA_1 ) & rd_len_cnt_over & (mem_axi_btype_reg != 2'b10) )  ? {2{mem_16bit_rdata_in}}  : 
                             ((mem_axird_cur_state == MEM_BYTE_DATA_1 ) & rd_len_cnt_over & (mem_axi_btype_reg == 2'b10) )  ? {2{byte_rdata_reg}}  : 
                             ( mem_axird_cur_state == MEM_HWORD_DATA  )    ? {2{mem_16bit_rdata_in}}      : 
                             ( mem_axird_cur_state == MEM_WORD_HW_DATA_2 ) ? {mem_16bit_rdata_in,word_hw_1_rdata_reg} : 'd0;  

assign mem_slv_rdata_last  = ( ( mem_axird_cur_state == MEM_BYTE_DATA_1 )    | 
                               ( mem_axird_cur_state == MEM_BYTE_DATA_2 )    | 
                               ( mem_axird_cur_state == MEM_HWORD_DATA  )    |
                               ( mem_axird_cur_state == MEM_WORD_HW_DATA_2 ) | 
                               ( mem_axird_cur_state == MEM_ERROR_DATA ) ) & rd_len_cnt_over ; 

always @ ( posedge mem_clk or negedge reset_n )
begin
   if ( ~reset_n )
   begin
      mem_slv_rdata_resp <= 'd0; 
   end
   else
   begin
      if ( mem_err_en || mem_dqs_timeout_en) 
          mem_slv_rdata_resp <= 'd2;  // SLV ERROR
      else 
          mem_slv_rdata_resp <= ( mem_axi_rd_err_reg ) ? 2'd3: 'd0; 
   end
end

end // SLV DATA WIDTH 32 END 

else if ( SLV_AXI_DATA_WIDTH == 64 ) // SLV DATA WIDTH 64 BEGIN
begin

reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  byte_rdata_reg;
reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  word_hw_1_rdata_reg;
reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  dword_hw_1_rdata_reg;
reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  dword_hw_2_rdata_reg;
reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  dword_hw_3_rdata_reg;


always @ ( posedge mem_clk or negedge reset_n )
begin
   if ( ~reset_n )
   begin
      rd_len_cnt     <= 'd0;
      mem_axi_rd_start_reg <= 1'b0;
      mem_axi_rd_err_reg       <= 1'b0;
      mem_axi_rd_err_en        <= 1'b0;
      mem_axi_size_reg         <= 'd0;
      mem_axi_rd_addr_lsb_reg  <= 'd0;
      mem_err_en   <= 1'b0;
      mem_dqs_timeout_en       <= 1'b0;
   end
   else
   begin
      if ( mem_axi_rd_start  )
         rd_len_cnt   <=  mem_slv_axi_len + 1 ; 
      else if ( mem_slv_rdata_valid & slv_mem_rdata_ack ) 
         rd_len_cnt   <= rd_len_cnt - 1; 

      if ( mem_axi_rd_start & (mem_axi_rd_err == 1'b0 ))
         mem_axi_rd_start_reg  <= 1'b1;
      else if ( mem_16bit_rdata_valid | mem_dqs_time_out | mem_dqs_timeout_en | mem_illegal_instrn_err_redge_reg)
         mem_axi_rd_start_reg  <= 1'b0;

      if ( mem_axi_rd_start )
         mem_axi_rd_err_reg  <= mem_axi_rd_err;
      else if ( rd_len_cnt_over )
         mem_axi_rd_err_reg  <= 2'b0;


      if ( (mem_axi_rd_start &  mem_axi_rd_err) | (mem_axi_rd_start_reg & (mem_dqs_time_out | mem_dqs_timeout_en) ) |  
           (mem_axi_rd_start_reg & mem_illegal_instrn_err_redge_reg) )
         mem_axi_rd_err_en   <= 1'b1;
      else if ( rd_len_cnt_over  )
         mem_axi_rd_err_en   <= 1'b0;

      if ( ( mem_axi_rd_start_reg & (mem_dqs_time_out | mem_dqs_timeout_en) ) | (mem_axi_rd_start_reg & mem_illegal_instrn_err_redge_reg))
         mem_err_en   <= 1'b1;
      else if ( rd_len_cnt_over  )
         mem_err_en   <= 1'b0;

      if (mem_dqs_time_out )
      //if ( mem_axi_rd_start_reg & mem_dqs_time_out )
         mem_dqs_timeout_en   <= 1'b1;
      //else if ( rd_len_cnt_over  )
      //   mem_dqs_timeout_en   <= 1'b0;

      if ( mem_axi_rd_start )
      begin
         mem_axi_size_reg  <= mem_axi_size;
         mem_axi_rd_addr_lsb_reg <= mem_axi_rd_addr_lsb; 
         mem_axi_btype_reg   <= mem_axi_btype;
         //mem_slv_axi_len_reg <= mem_slv_axi_len;
      end
   end
end

assign rd_len_cnt_over    = ( rd_len_cnt <= 1 );

//assign rd_len_cnt_lt_eq_2 = ( rd_len_cnt <= 2 );

//===================================================================================
// 64-bit AXI READ DATA INTERFACE 
//===================================================================================

reg  [4:0] mem_axird_cur_state;
reg  [4:0] mem_axird_nxt_state;

localparam [4:0]  MEM_AXIRD_IDLE          = 0;
localparam [4:0]  MEM_BYTE_DATA_1         = 1;
localparam [4:0]  MEM_BYTE_DATA_2         = 2;
localparam [4:0]  MEM_BYTE_DATA_1_WAIT    = 3;
localparam [4:0]  MEM_HWORD_DATA          = 4;
localparam [4:0]  MEM_HWORD_DATA_WAIT     = 5;
localparam [4:0]  MEM_WORD_HW_DATA_1      = 6;
localparam [4:0]  MEM_WORD_HW_DATA_2      = 7;
localparam [4:0]  MEM_WORD_HW_DATA_1_WAIT = 8;
localparam [4:0]  MEM_WORD_HW_DATA_2_WAIT = 9;
localparam [4:0]  MEM_DWORD_HW_DATA_1     = 10;
localparam [4:0]  MEM_DWORD_HW_DATA_2     = 11;
localparam [4:0]  MEM_DWORD_HW_DATA_3     = 12;
localparam [4:0]  MEM_DWORD_HW_DATA_4     = 13;
localparam [4:0]  MEM_DWORD_HW_DATA_1_WAIT= 14;
localparam [4:0]  MEM_DWORD_HW_DATA_2_WAIT= 15;
localparam [4:0]  MEM_DWORD_HW_DATA_3_WAIT= 16;
localparam [4:0]  MEM_DWORD_HW_DATA_4_WAIT= 17;
localparam [4:0]  MEM_ERROR_DATA          = 18;
//===================================================================================


always @ (*)
begin
   case (mem_axird_cur_state )
      MEM_AXIRD_IDLE :
      begin
         if ( mem_axi_rd_err_en )
            mem_axird_nxt_state = MEM_ERROR_DATA;
         else if ( mem_axi_rd_start_reg & (mem_axi_size_reg == 3'd0 ) & mem_16bit_rdata_valid)
         begin
            if ( mem_axi_rd_addr_lsb_reg[0] ) 
               mem_axird_nxt_state = MEM_BYTE_DATA_2;
            else
               mem_axird_nxt_state = MEM_BYTE_DATA_1;
         end
         else if ( mem_axi_rd_start_reg & (mem_axi_size_reg == 3'd1 ) & mem_16bit_rdata_valid)
            mem_axird_nxt_state = MEM_HWORD_DATA;
         else if ( mem_axi_rd_start_reg & (mem_axi_size_reg == 3'd2 ) & mem_16bit_rdata_valid)
            if ( mem_axi_rd_addr_lsb_reg[1] ) 
               mem_axird_nxt_state = MEM_WORD_HW_DATA_2;
            else
               mem_axird_nxt_state = MEM_WORD_HW_DATA_1;
         else if ( mem_axi_rd_start_reg & (mem_axi_size_reg == 3'd3 ) & mem_16bit_rdata_valid)
         begin
            if ( mem_axi_rd_addr_lsb_reg[2:1] == 2'b00 ) 
               mem_axird_nxt_state = MEM_DWORD_HW_DATA_1;
            else if ( mem_axi_rd_addr_lsb_reg[2:1] == 2'b01 )
               mem_axird_nxt_state = MEM_DWORD_HW_DATA_2;
            else if ( mem_axi_rd_addr_lsb_reg[2:1] == 2'b10 )
               mem_axird_nxt_state = MEM_DWORD_HW_DATA_3;
            else 
               mem_axird_nxt_state = MEM_DWORD_HW_DATA_4;
         end
         else
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
      end
      // BYTE 1
      MEM_BYTE_DATA_1 :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if ( slv_mem_rdata_ack )
            mem_axird_nxt_state = MEM_BYTE_DATA_2; 
         else 
            mem_axird_nxt_state = MEM_BYTE_DATA_1; 
      end 
      // BYTE 2 
      MEM_BYTE_DATA_2 :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if ( slv_mem_rdata_ack)
            mem_axird_nxt_state = MEM_BYTE_DATA_1_WAIT; 
         else 
            mem_axird_nxt_state = MEM_BYTE_DATA_2; 
      end 

      MEM_BYTE_DATA_1_WAIT : 
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_BYTE_DATA_1; 
         else    
            mem_axird_nxt_state = MEM_BYTE_DATA_1_WAIT; 
      end

      //  HALFWORD  
      MEM_HWORD_DATA : 
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if ( slv_mem_rdata_ack )
            mem_axird_nxt_state = MEM_HWORD_DATA_WAIT; 
         else    
            mem_axird_nxt_state = MEM_HWORD_DATA; 
      end

      // HALFWORD WAIT
      MEM_HWORD_DATA_WAIT : 
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_HWORD_DATA; 
         else    
            mem_axird_nxt_state = MEM_HWORD_DATA_WAIT; 
      end

      //  WORD HALFWORD 1 
      MEM_WORD_HW_DATA_1 :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else    
            mem_axird_nxt_state = MEM_WORD_HW_DATA_2_WAIT; 
      end

      //  WORD HALFWORD 2 
      MEM_WORD_HW_DATA_2 :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if (slv_mem_rdata_ack )
            mem_axird_nxt_state = MEM_WORD_HW_DATA_1_WAIT ; 
         else 
            mem_axird_nxt_state = MEM_WORD_HW_DATA_2; 
      end

      // WORD HALFWORD 1 WAIT 
      MEM_WORD_HW_DATA_1_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_WORD_HW_DATA_1; 
         else    
            mem_axird_nxt_state = MEM_WORD_HW_DATA_1_WAIT; 
      end
     
     // WORD HALFWORD 2 WAIT 
      MEM_WORD_HW_DATA_2_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_WORD_HW_DATA_2; 
         else    
            mem_axird_nxt_state = MEM_WORD_HW_DATA_2_WAIT; 
      end

      //  DWORD HALFWORD 1 
      MEM_DWORD_HW_DATA_1 :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else    
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_2_WAIT; 
      end
      
      //  DWORD HALFWORD 2 
      MEM_DWORD_HW_DATA_2 :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else    
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_3_WAIT; 
      end
      
      //  DWORD HALFWORD 3 
      MEM_DWORD_HW_DATA_3 :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else    
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_4_WAIT; 
      end

      //  DWORD HALFWORD 4 
      MEM_DWORD_HW_DATA_4 :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if ( slv_mem_rdata_ack )
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_1_WAIT; 
         else    
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_4; 
      end

      // DWORD HWORD 1 WAIT 
      MEM_DWORD_HW_DATA_1_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_1; 
         else    
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_1_WAIT; 
      end

      // DWORD HWORD 1 WAIT 
      MEM_DWORD_HW_DATA_2_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_2; 
         else    
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_2_WAIT; 
      end

      // DWORD HWORD 1 WAIT 
      MEM_DWORD_HW_DATA_3_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_3; 
         else    
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_3_WAIT; 
      end

      // DWORD HWORD 1 WAIT 
      MEM_DWORD_HW_DATA_4_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_4; 
         else    
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_4_WAIT; 
      end


      // ERROR DATA 
      MEM_ERROR_DATA :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else 
            mem_axird_nxt_state = MEM_ERROR_DATA; 
      end 
 
      default :
      begin
         mem_axird_nxt_state = MEM_AXIRD_IDLE;
      end
   endcase
end



always @ ( posedge mem_clk or negedge reset_n )
begin
   if ( ~reset_n )
   begin
      mem_axird_cur_state <= MEM_AXIRD_IDLE; 
      byte_rdata_reg      <= 'd0;
      word_hw_1_rdata_reg <= 'd0;
      dword_hw_1_rdata_reg<= 'd0; 
      dword_hw_2_rdata_reg<= 'd0; 
      dword_hw_3_rdata_reg<= 'd0; 
      wrap_frst_rdata_valid  <= 1'b0;
   end
   else
   begin
      mem_axird_cur_state <= mem_axird_nxt_state; 

      if ( mem_16bit_rdata_valid & (( mem_axird_cur_state == MEM_AXIRD_IDLE ) & (mem_axird_nxt_state == MEM_BYTE_DATA_2)) & 
                               (mem_axi_btype_reg == 2'b10 )   ) 
         byte_rdata_reg      <= mem_16bit_rdata_in; 

      if ( mem_axird_cur_state == MEM_WORD_HW_DATA_1 )
         word_hw_1_rdata_reg    <= mem_16bit_rdata_in;
      else if ( mem_axird_cur_state == MEM_AXIRD_IDLE )
         word_hw_1_rdata_reg    <= 'd0;
      

      if ( mem_axird_cur_state == MEM_DWORD_HW_DATA_1 )
         dword_hw_1_rdata_reg   <= mem_16bit_rdata_in;
      else if ( mem_axird_cur_state == MEM_AXIRD_IDLE )
         word_hw_1_rdata_reg    <= 'd0;

      if ( mem_axird_cur_state == MEM_DWORD_HW_DATA_2 )
         dword_hw_2_rdata_reg   <= mem_16bit_rdata_in;
      else if ( mem_axird_cur_state == MEM_AXIRD_IDLE )
         word_hw_1_rdata_reg    <= 'd0;

      if ( mem_axird_cur_state == MEM_DWORD_HW_DATA_3 )
         dword_hw_3_rdata_reg   <= mem_16bit_rdata_in;
      else if ( mem_axird_cur_state == MEM_AXIRD_IDLE )
         word_hw_1_rdata_reg    <= 'd0;
   end
end

//assign mem_16bit_rdata_ack  = (((mem_axird_cur_state == MEM_AXIRD_IDLE ) & mem_axi_rd_start_reg ) |
//                             ((mem_axird_cur_state == MEM_BYTE_DATA_2 ) & slv_mem_rdata_ack & ( (~rd_len_cnt_over & (mem_axi_btype_reg != 2'b10) ) | 
//                                                                                                (~rd_len_cnt_lt_eq_2 & (mem_axi_btype_reg == 2'b10 )))) |  
//                             ( mem_axird_cur_state == MEM_BYTE_DATA_1_WAIT  ) | 
//                             ((mem_axird_cur_state == MEM_HWORD_DATA  ) & slv_mem_rdata_ack & ~rd_len_cnt_over) | 
//                             ( mem_axird_cur_state == MEM_HWORD_DATA_WAIT  ) | 
//                             ( mem_axird_cur_state == MEM_WORD_HW_DATA_1  ) | 
//                             ((mem_axird_cur_state == MEM_WORD_HW_DATA_2  ) & slv_mem_rdata_ack & ~rd_len_cnt_over) | 
//                             ( mem_axird_cur_state == MEM_WORD_HW_DATA_1_WAIT  ) | 
//                             ( mem_axird_cur_state == MEM_DWORD_HW_DATA_1  ) | 
//                             ( mem_axird_cur_state == MEM_DWORD_HW_DATA_2  ) | 
//                             ( mem_axird_cur_state == MEM_DWORD_HW_DATA_3  ) | 
//                             ((mem_axird_cur_state == MEM_DWORD_HW_DATA_4  ) & slv_mem_rdata_ack & ~rd_len_cnt_over ) |  
//                             ( mem_axird_cur_state == MEM_DWORD_HW_DATA_1_WAIT  )  
//                             ) & mem_16bit_rdata_valid ; 
//

assign mem_16bit_rdata_ack  = (((mem_axird_cur_state == MEM_BYTE_DATA_1  ) & slv_mem_rdata_ack & rd_len_cnt_over & (mem_axi_btype_reg != 2'b10)) | 
                             ((mem_axird_cur_state == MEM_BYTE_DATA_2 ) & slv_mem_rdata_ack ) |  
                             ((mem_axird_cur_state == MEM_HWORD_DATA  ) & slv_mem_rdata_ack ) | 
                             ( mem_axird_cur_state == MEM_WORD_HW_DATA_1  ) | 
                             ((mem_axird_cur_state == MEM_WORD_HW_DATA_2  ) & slv_mem_rdata_ack) | 
                             ( mem_axird_cur_state == MEM_DWORD_HW_DATA_1  ) | 
                             ( mem_axird_cur_state == MEM_DWORD_HW_DATA_2  ) | 
                             ( mem_axird_cur_state == MEM_DWORD_HW_DATA_3  ) | 
                             ((mem_axird_cur_state == MEM_DWORD_HW_DATA_4  ) & slv_mem_rdata_ack ) 
                             ) & mem_16bit_rdata_valid ; 


assign mem_slv_rdata_valid = ( ( mem_axird_cur_state == MEM_BYTE_DATA_1 ) | 
                               ( mem_axird_cur_state == MEM_BYTE_DATA_2 ) | 
                               ( mem_axird_cur_state == MEM_HWORD_DATA  ) | 
                               ( mem_axird_cur_state == MEM_WORD_HW_DATA_2 )  | 
                               ( mem_axird_cur_state == MEM_DWORD_HW_DATA_4 )  | 
                               ( mem_axird_cur_state == MEM_ERROR_DATA )  );


assign mem_slv_rdata       = ((mem_axird_cur_state == MEM_BYTE_DATA_1 ) & ~rd_len_cnt_over )   ? {4{mem_16bit_rdata_in}} : 
                             ( mem_axird_cur_state == MEM_BYTE_DATA_2 )    ? {4{mem_16bit_rdata_in}}  : 
                             ((mem_axird_cur_state == MEM_BYTE_DATA_1 ) & rd_len_cnt_over & (mem_axi_btype_reg != 2'b10) )  ? {4{mem_16bit_rdata_in}}  : 
                             ((mem_axird_cur_state == MEM_BYTE_DATA_1 ) & rd_len_cnt_over & (mem_axi_btype_reg == 2'b10) )  ? {4{byte_rdata_reg}}  : 
                             ( mem_axird_cur_state == MEM_HWORD_DATA  )    ? {4{mem_16bit_rdata_in}}      : 
                             ( mem_axird_cur_state == MEM_WORD_HW_DATA_2 ) ? {2{mem_16bit_rdata_in,word_hw_1_rdata_reg}} :   
                             ( mem_axird_cur_state == MEM_DWORD_HW_DATA_4 )? {mem_16bit_rdata_in,dword_hw_3_rdata_reg,
                                                                              dword_hw_2_rdata_reg,dword_hw_1_rdata_reg} : 'd0;  

assign mem_slv_rdata_last  = ( ( mem_axird_cur_state == MEM_BYTE_DATA_1 )    | 
                               ( mem_axird_cur_state == MEM_BYTE_DATA_2 )    | 
                               ( mem_axird_cur_state == MEM_HWORD_DATA  )    |
                               ( mem_axird_cur_state == MEM_WORD_HW_DATA_2 ) | 
                               ( mem_axird_cur_state == MEM_DWORD_HW_DATA_4 )  | 
                               ( mem_axird_cur_state == MEM_ERROR_DATA ) ) & rd_len_cnt_over ; 


always @ ( posedge mem_clk or negedge reset_n )
begin
   if ( ~reset_n )
   begin
      mem_slv_rdata_resp <= 'd0; 
   end
   else
   begin
      if ( mem_err_en | mem_dqs_timeout_en)
          mem_slv_rdata_resp <= 'd2; // SLV ERROR 
      else
          mem_slv_rdata_resp <= ( mem_axi_rd_err_reg ) ? 2'd2: 'd0; 
   end
end

end // SLV DATA WIDTH 64 END

else  // SLV DATA WIDTH 128 BEGIN 
begin

reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  byte_rdata_reg;
reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  word_hw_1_rdata_reg;
reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  dword_hw_1_rdata_reg;
reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  dword_hw_2_rdata_reg;
reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  dword_hw_3_rdata_reg;
reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  qword_hw_1_rdata_reg;
reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  qword_hw_2_rdata_reg;
reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  qword_hw_3_rdata_reg;
reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  qword_hw_4_rdata_reg;
reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  qword_hw_5_rdata_reg;
reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  qword_hw_6_rdata_reg;
reg    [ MEM_FIFO_DATA_WIDTH -1 : 0 ]  qword_hw_7_rdata_reg;



always @ ( posedge mem_clk or negedge reset_n )
begin
   if ( ~reset_n )
   begin
      rd_len_cnt               <= 'd0;
      mem_axi_rd_start_reg     <= 1'b0;
      mem_axi_rd_err_reg       <= 1'b0;
      mem_axi_rd_err_en        <= 1'b0;
      mem_axi_size_reg         <= 'd0;
      mem_axi_rd_addr_lsb_reg  <= 'd0;
      mem_dqs_timeout_en       <= 1'b0;
   end
   else
   begin
      if ( mem_axi_rd_start  )
         rd_len_cnt   <=  mem_slv_axi_len + 1 ; 
      else if ( mem_slv_rdata_valid & slv_mem_rdata_ack ) 
         rd_len_cnt   <= rd_len_cnt - 1; 

      if ( mem_axi_rd_start & (mem_axi_rd_err == 1'b0 ))
      //if ( mem_axi_rd_start )
         mem_axi_rd_start_reg  <= 1'b1;
      else if ( mem_16bit_rdata_valid | mem_dqs_time_out | mem_dqs_timeout_en | mem_illegal_instrn_err_redge_reg)
         mem_axi_rd_start_reg  <= 1'b0;

      if ( mem_axi_rd_start )
         mem_axi_rd_err_reg  <= mem_axi_rd_err;
      else if ( rd_len_cnt_over )
         mem_axi_rd_err_reg  <= 2'b0;


      if ( (mem_axi_rd_start &  mem_axi_rd_err) | (mem_axi_rd_start_reg & (mem_dqs_time_out | mem_dqs_timeout_en) ) |  
           (mem_axi_rd_start_reg & mem_illegal_instrn_err_redge_reg) )
         mem_axi_rd_err_en   <= 1'b1;
      else if ( rd_len_cnt_over  )
         mem_axi_rd_err_en   <= 1'b0;

      if ( ( mem_axi_rd_start_reg & (mem_dqs_time_out | mem_dqs_timeout_en) ) | (mem_axi_rd_start_reg & mem_illegal_instrn_err_redge_reg))
         mem_err_en   <= 1'b1;
      else if ( rd_len_cnt_over  )
         mem_err_en   <= 1'b0;
	 
       if (mem_dqs_time_out )
      //if ( mem_axi_rd_start_reg & mem_dqs_time_out )
         mem_dqs_timeout_en   <= 1'b1;
      //else if ( rd_len_cnt_over  )
      //   mem_dqs_timeout_en   <= 1'b0;

      if ( mem_axi_rd_start )
      begin
         mem_axi_size_reg  <= mem_axi_size;
         mem_axi_rd_addr_lsb_reg <= mem_axi_rd_addr_lsb; 
         mem_axi_btype_reg   <= mem_axi_btype;
         //mem_slv_axi_len_reg <= mem_slv_axi_len;
      end
   end
end

assign rd_len_cnt_over    = ( rd_len_cnt <= 1 );

//assign rd_len_cnt_lt_eq_2 = ( rd_len_cnt <= 2 );

//===================================================================================
// 128-bit AXI READ DATA INTERFACE 
//===================================================================================

reg  [5:0] mem_axird_cur_state;
reg  [5:0] mem_axird_nxt_state;

localparam [4:0]  MEM_AXIRD_IDLE          = 5'h00;
localparam [4:0]  MEM_BYTE_DATA_1         = 5'h01;
localparam [4:0]  MEM_BYTE_DATA_2         = 5'h02;
localparam [4:0]  MEM_BYTE_DATA_1_WAIT    = 5'h03;
localparam [4:0]  MEM_HWORD_DATA          = 5'h04;
localparam [4:0]  MEM_HWORD_DATA_WAIT     = 5'h05;
localparam [4:0]  MEM_WORD_HW_DATA_1      = 5'h06;
localparam [4:0]  MEM_WORD_HW_DATA_2      = 5'h07;
localparam [4:0]  MEM_WORD_HW_DATA_1_WAIT = 5'h08;
localparam [4:0]  MEM_WORD_HW_DATA_2_WAIT = 5'h09;
localparam [4:0]  MEM_DWORD_HW_DATA_1     = 5'h0A;
localparam [4:0]  MEM_DWORD_HW_DATA_2     = 5'h0B;
localparam [4:0]  MEM_DWORD_HW_DATA_3     = 5'h0C;
localparam [4:0]  MEM_DWORD_HW_DATA_4     = 5'h0D;
localparam [4:0]  MEM_DWORD_HW_DATA_1_WAIT= 5'h0E;
localparam [4:0]  MEM_DWORD_HW_DATA_2_WAIT= 5'h0F;
localparam [4:0]  MEM_DWORD_HW_DATA_3_WAIT= 5'h10;
localparam [4:0]  MEM_DWORD_HW_DATA_4_WAIT= 5'h11;

localparam [4:0]  MEM_QWORD_HW_DATA_1     = 5'h12;
localparam [4:0]  MEM_QWORD_HW_DATA_2     = 5'h13;
localparam [4:0]  MEM_QWORD_HW_DATA_3     = 5'h14;
localparam [4:0]  MEM_QWORD_HW_DATA_4     = 5'h15;
localparam [4:0]  MEM_QWORD_HW_DATA_5     = 5'h16;
localparam [4:0]  MEM_QWORD_HW_DATA_6     = 5'h17;
localparam [4:0]  MEM_QWORD_HW_DATA_7     = 5'h18;
localparam [4:0]  MEM_QWORD_HW_DATA_8     = 5'h19;
localparam [4:0]  MEM_QWORD_HW_DATA_1_WAIT= 5'h1A;
localparam [4:0]  MEM_QWORD_HW_DATA_2_WAIT= 5'h1B;
localparam [4:0]  MEM_QWORD_HW_DATA_3_WAIT= 5'h1C;
localparam [4:0]  MEM_QWORD_HW_DATA_4_WAIT= 5'h1D;
localparam [4:0]  MEM_QWORD_HW_DATA_5_WAIT= 5'h1E;
localparam [4:0]  MEM_QWORD_HW_DATA_6_WAIT= 5'h1F;
localparam [5:0]  MEM_QWORD_HW_DATA_7_WAIT= 6'h20;
localparam [5:0]  MEM_QWORD_HW_DATA_8_WAIT= 6'h21;
localparam [5:0]  MEM_ERROR_DATA          = 6'h22;
//
//===================================================================================


always @ (*)
begin
   case (mem_axird_cur_state )
      MEM_AXIRD_IDLE :
      begin
         if ( mem_axi_rd_err_en )
            mem_axird_nxt_state = MEM_ERROR_DATA;
         else if ( mem_axi_rd_start_reg & (mem_axi_size_reg == 3'd0 ) & mem_16bit_rdata_valid)
         begin
            if ( mem_axi_rd_addr_lsb_reg[0] ) 
               mem_axird_nxt_state = MEM_BYTE_DATA_2;
            else
               mem_axird_nxt_state = MEM_BYTE_DATA_1;
         end
         else if ( mem_axi_rd_start_reg & (mem_axi_size_reg == 3'd1 ) & mem_16bit_rdata_valid)
            mem_axird_nxt_state = MEM_HWORD_DATA;
         else if ( mem_axi_rd_start_reg & (mem_axi_size_reg == 3'd2 ) & mem_16bit_rdata_valid)
            if ( mem_axi_rd_addr_lsb_reg[1] ) 
               mem_axird_nxt_state = MEM_WORD_HW_DATA_2;
            else
               mem_axird_nxt_state = MEM_WORD_HW_DATA_1;
         else if ( mem_axi_rd_start_reg & (mem_axi_size_reg == 3'd3 ) & mem_16bit_rdata_valid)
         begin
            if ( mem_axi_rd_addr_lsb_reg[2:1] == 2'b00 ) 
               mem_axird_nxt_state = MEM_DWORD_HW_DATA_1;
            else if ( mem_axi_rd_addr_lsb_reg[2:1] == 2'b01 )
               mem_axird_nxt_state = MEM_DWORD_HW_DATA_2;
            else if ( mem_axi_rd_addr_lsb_reg[2:1] == 2'b10 )
               mem_axird_nxt_state = MEM_DWORD_HW_DATA_3;
            else 
               mem_axird_nxt_state = MEM_DWORD_HW_DATA_4;
         end
         else if ( mem_axi_rd_start_reg & (mem_axi_size_reg == 3'd4 ) & mem_16bit_rdata_valid)
         begin
            if ( mem_axi_rd_addr_lsb_reg[3:1] == 3'b000 ) 
               mem_axird_nxt_state = MEM_QWORD_HW_DATA_1;
            else if ( mem_axi_rd_addr_lsb_reg[3:1] == 3'b001 )
               mem_axird_nxt_state = MEM_QWORD_HW_DATA_2;
            else if ( mem_axi_rd_addr_lsb_reg[3:1] == 3'b010 )
               mem_axird_nxt_state = MEM_QWORD_HW_DATA_3;
            else if ( mem_axi_rd_addr_lsb_reg[3:1] == 3'b011 ) 
               mem_axird_nxt_state = MEM_QWORD_HW_DATA_4;
            else if ( mem_axi_rd_addr_lsb_reg[3:1] == 3'b100 ) 
               mem_axird_nxt_state = MEM_QWORD_HW_DATA_5;
            else if ( mem_axi_rd_addr_lsb_reg[3:1] == 3'b101 ) 
               mem_axird_nxt_state = MEM_QWORD_HW_DATA_6;
            else if ( mem_axi_rd_addr_lsb_reg[3:1] == 3'b110 ) 
               mem_axird_nxt_state = MEM_QWORD_HW_DATA_7;
            else
               mem_axird_nxt_state = MEM_QWORD_HW_DATA_8;
         end
         
         else
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
      end

      // BYTE 1
      MEM_BYTE_DATA_1 :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if ( slv_mem_rdata_ack )
            mem_axird_nxt_state = MEM_BYTE_DATA_2; 
         else 
            mem_axird_nxt_state = MEM_BYTE_DATA_1; 
      end 
      // BYTE 2 
      MEM_BYTE_DATA_2 :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if ( slv_mem_rdata_ack)
            mem_axird_nxt_state = MEM_BYTE_DATA_1_WAIT; 
         else 
            mem_axird_nxt_state = MEM_BYTE_DATA_2; 
      end 

      MEM_BYTE_DATA_1_WAIT : 
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_BYTE_DATA_1; 
         else    
            mem_axird_nxt_state = MEM_BYTE_DATA_1_WAIT; 
      end

      //  HALFWORD  
      MEM_HWORD_DATA : 
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if ( slv_mem_rdata_ack )
            mem_axird_nxt_state = MEM_HWORD_DATA_WAIT; 
         else    
            mem_axird_nxt_state = MEM_HWORD_DATA; 
      end

      // HALFWORD WAIT
      MEM_HWORD_DATA_WAIT : 
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_HWORD_DATA; 
         else    
            mem_axird_nxt_state = MEM_HWORD_DATA_WAIT; 
      end

      //  WORD HALFWORD 1 
      MEM_WORD_HW_DATA_1 :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else    
            mem_axird_nxt_state = MEM_WORD_HW_DATA_2_WAIT; 
      end

      //  WORD HALFWORD 2 
      MEM_WORD_HW_DATA_2 :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if (slv_mem_rdata_ack )
            mem_axird_nxt_state = MEM_WORD_HW_DATA_1_WAIT ; 
         else 
            mem_axird_nxt_state = MEM_WORD_HW_DATA_2; 
      end

      // WORD HALFWORD 1 WAIT 
      MEM_WORD_HW_DATA_1_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_WORD_HW_DATA_1; 
         else    
            mem_axird_nxt_state = MEM_WORD_HW_DATA_1_WAIT; 
      end
     
     // WORD HALFWORD 2 WAIT 
      MEM_WORD_HW_DATA_2_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_WORD_HW_DATA_2; 
         else    
            mem_axird_nxt_state = MEM_WORD_HW_DATA_2_WAIT; 
      end
      // BYTE 1
      MEM_BYTE_DATA_1 :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if ( slv_mem_rdata_ack )
            mem_axird_nxt_state = MEM_BYTE_DATA_2; 
         else 
            mem_axird_nxt_state = MEM_BYTE_DATA_1; 
      end 
      // BYTE 2 
      MEM_BYTE_DATA_2 :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if ( slv_mem_rdata_ack)
            mem_axird_nxt_state = MEM_BYTE_DATA_1_WAIT; 
         else 
            mem_axird_nxt_state = MEM_BYTE_DATA_2; 
      end 

      MEM_BYTE_DATA_1_WAIT : 
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_BYTE_DATA_1; 
         else    
            mem_axird_nxt_state = MEM_BYTE_DATA_1_WAIT; 
      end

      //  HALFWORD  
      MEM_HWORD_DATA : 
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if ( slv_mem_rdata_ack )
            mem_axird_nxt_state = MEM_HWORD_DATA_WAIT; 
         else    
            mem_axird_nxt_state = MEM_HWORD_DATA; 
      end

      // HALFWORD WAIT
      MEM_HWORD_DATA_WAIT : 
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_HWORD_DATA; 
         else    
            mem_axird_nxt_state = MEM_HWORD_DATA_WAIT; 
      end

      //  WORD HALFWORD 1 
      MEM_WORD_HW_DATA_1 :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else    
            mem_axird_nxt_state = MEM_WORD_HW_DATA_2_WAIT; 
      end

      //  WORD HALFWORD 2 
      MEM_WORD_HW_DATA_2 :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if (slv_mem_rdata_ack )
            mem_axird_nxt_state = MEM_WORD_HW_DATA_1_WAIT ; 
         else 
            mem_axird_nxt_state = MEM_WORD_HW_DATA_2; 
      end

      // WORD HALFWORD 1 WAIT 
      MEM_WORD_HW_DATA_1_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_WORD_HW_DATA_1; 
         else    
            mem_axird_nxt_state = MEM_WORD_HW_DATA_1_WAIT; 
      end
     
     // WORD HALFWORD 2 WAIT 
      MEM_WORD_HW_DATA_2_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_WORD_HW_DATA_2; 
         else    
            mem_axird_nxt_state = MEM_WORD_HW_DATA_2_WAIT; 
      end

     //  DWORD HALFWORD 1 
      MEM_DWORD_HW_DATA_1 :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else    
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_2_WAIT; 
      end
      
      //  DWORD HALFWORD 2 
      MEM_DWORD_HW_DATA_2 :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else    
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_3_WAIT; 
      end
      
      //  DWORD HALFWORD 3 
      MEM_DWORD_HW_DATA_3 :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else    
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_4_WAIT; 
      end

      //  DWORD HALFWORD 4 
      MEM_DWORD_HW_DATA_4 :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if ( slv_mem_rdata_ack )
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_1_WAIT; 
         else    
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_4; 
      end

      // DWORD HWORD 1 WAIT 
      MEM_DWORD_HW_DATA_1_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_1; 
         else    
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_1_WAIT; 
      end

      // DWORD HWORD 1 WAIT 
      MEM_DWORD_HW_DATA_2_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_2; 
         else    
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_2_WAIT; 
      end

      // DWORD HWORD 1 WAIT 
      MEM_DWORD_HW_DATA_3_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_3; 
         else    
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_3_WAIT; 
      end

      // DWORD HWORD 1 WAIT 
      MEM_DWORD_HW_DATA_4_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_4; 
         else    
            mem_axird_nxt_state = MEM_DWORD_HW_DATA_4_WAIT; 
      end

      //  QWORD HALFWORD 1 
      MEM_QWORD_HW_DATA_1 :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else    
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_2_WAIT; 
      end
      
      //  QWORD HALFWORD 2 
      MEM_QWORD_HW_DATA_2 :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else    
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_3_WAIT; 
      end
      
      //  QWORD HALFWORD 3 
      MEM_QWORD_HW_DATA_3 :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else    
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_4_WAIT; 
      end
      
      //  QWORD HALFWORD 4 
      MEM_QWORD_HW_DATA_4 :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else    
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_5_WAIT; 
      end
      
      //  QWORD HALFWORD 5 
      MEM_QWORD_HW_DATA_5 :
      begin 
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else    
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_6_WAIT; 
      end
      
      //  QWORD HALFWORD 6 
      MEM_QWORD_HW_DATA_6 :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else    
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_7_WAIT; 
      end
      
      //  QWORD HALFWORD 7 
      MEM_QWORD_HW_DATA_7 :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else    
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_8_WAIT; 
      end

      //  QWORD HALFWORD 8 
      MEM_QWORD_HW_DATA_8 :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else if (slv_mem_rdata_ack )
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_1_WAIT; 
         else    
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_8; 
      end

      // QWORD HWORD 1 WAIT 
      MEM_QWORD_HW_DATA_1_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_1; 
         else    
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_1_WAIT; 
      end

      // QWORD HWORD 1 WAIT 
      MEM_QWORD_HW_DATA_2_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_2; 
         else    
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_2_WAIT; 
      end

      // QWORD HWORD 1 WAIT 
      MEM_QWORD_HW_DATA_3_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_3; 
         else    
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_3_WAIT; 
      end

      // QWORD HWORD 1 WAIT 
      MEM_QWORD_HW_DATA_4_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_4; 
         else    
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_4_WAIT; 
      end

      // QWORD HWORD 1 WAIT 
      MEM_QWORD_HW_DATA_5_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_5; 
         else    
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_5_WAIT; 
      end

      // QWORD HWORD 1 WAIT 
      MEM_QWORD_HW_DATA_6_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_6; 
         else    
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_6_WAIT; 
      end

     // QWORD HWORD 1 WAIT 
      MEM_QWORD_HW_DATA_7_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_7; 
         else    
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_7_WAIT; 
      end

     // QWORD HWORD 1 WAIT 
      MEM_QWORD_HW_DATA_8_WAIT :
      begin
         if (mem_dqs_timeout_en)
            mem_axird_nxt_state = MEM_ERROR_DATA; 
         else if ( mem_16bit_rdata_valid )
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_8; 
         else    
            mem_axird_nxt_state = MEM_QWORD_HW_DATA_8_WAIT; 
      end



      // ERROR DATA 
      MEM_ERROR_DATA :
      begin
         if ( slv_mem_rdata_ack & rd_len_cnt_over )
            mem_axird_nxt_state = MEM_AXIRD_IDLE;
         else 
            mem_axird_nxt_state = MEM_ERROR_DATA; 
      end 
 
      default :
      begin
         mem_axird_nxt_state = MEM_AXIRD_IDLE;
      end
   endcase
end



always @ ( posedge mem_clk or negedge reset_n )
begin
   if ( ~reset_n )
   begin
      mem_axird_cur_state    <= MEM_AXIRD_IDLE; 
      byte_rdata_reg         <= 'd0;
      word_hw_1_rdata_reg    <= 'd0;
      dword_hw_1_rdata_reg   <= 'd0; 
      dword_hw_2_rdata_reg   <= 'd0; 
      dword_hw_3_rdata_reg   <= 'd0; 
   end
   else
   begin
      mem_axird_cur_state <= mem_axird_nxt_state; 

      if ( mem_16bit_rdata_valid & (( mem_axird_cur_state == MEM_AXIRD_IDLE ) & (mem_axird_nxt_state == MEM_BYTE_DATA_2)) & 
                               (mem_axi_btype_reg == 2'b10 )   ) 
         byte_rdata_reg      <= mem_16bit_rdata_in; 

      // WORD

      if ( mem_axird_cur_state == MEM_WORD_HW_DATA_1 )
         word_hw_1_rdata_reg    <= mem_16bit_rdata_in;
      else if ( mem_axird_cur_state == MEM_AXIRD_IDLE )
         word_hw_1_rdata_reg    <= 'd0;
      
      // DWORD

      if ( mem_axird_cur_state == MEM_DWORD_HW_DATA_1 )
         dword_hw_1_rdata_reg   <= mem_16bit_rdata_in;
      else if ( mem_axird_cur_state == MEM_AXIRD_IDLE )
         dword_hw_1_rdata_reg   <= 'd0;

      if ( mem_axird_cur_state == MEM_DWORD_HW_DATA_2 )
         dword_hw_2_rdata_reg   <= mem_16bit_rdata_in;
      else if ( mem_axird_cur_state == MEM_AXIRD_IDLE )
         dword_hw_2_rdata_reg   <= 'd0;

      if ( mem_axird_cur_state == MEM_DWORD_HW_DATA_3 )
         dword_hw_3_rdata_reg   <= mem_16bit_rdata_in;
      else if ( mem_axird_cur_state == MEM_AXIRD_IDLE )
         dword_hw_3_rdata_reg   <= 'd0;

      // QWORD

      if ( mem_axird_cur_state == MEM_QWORD_HW_DATA_1 )
         qword_hw_1_rdata_reg   <= mem_16bit_rdata_in;
      else if ( mem_axird_cur_state == MEM_AXIRD_IDLE )
         qword_hw_1_rdata_reg   <= 'd0;

      if ( mem_axird_cur_state == MEM_QWORD_HW_DATA_2 )
         qword_hw_2_rdata_reg   <= mem_16bit_rdata_in;
      else if ( mem_axird_cur_state == MEM_AXIRD_IDLE )
         qword_hw_2_rdata_reg   <= 'd0;

      if ( mem_axird_cur_state == MEM_QWORD_HW_DATA_3 )
         qword_hw_3_rdata_reg   <= mem_16bit_rdata_in;
      else if ( mem_axird_cur_state == MEM_AXIRD_IDLE )
         qword_hw_3_rdata_reg   <= 'd0;

      if ( mem_axird_cur_state == MEM_QWORD_HW_DATA_4 )
         qword_hw_4_rdata_reg   <= mem_16bit_rdata_in;
      else if ( mem_axird_cur_state == MEM_AXIRD_IDLE )
         qword_hw_4_rdata_reg   <= 'd0;

      if ( mem_axird_cur_state == MEM_QWORD_HW_DATA_5 )
         qword_hw_5_rdata_reg   <= mem_16bit_rdata_in;
      else if ( mem_axird_cur_state == MEM_AXIRD_IDLE )
         qword_hw_5_rdata_reg   <= 'd0;

      if ( mem_axird_cur_state == MEM_QWORD_HW_DATA_6 )
         qword_hw_6_rdata_reg   <= mem_16bit_rdata_in;
      else if ( mem_axird_cur_state == MEM_AXIRD_IDLE )
         qword_hw_6_rdata_reg   <= 'd0;

      if ( mem_axird_cur_state == MEM_QWORD_HW_DATA_7 )
         qword_hw_7_rdata_reg   <= mem_16bit_rdata_in;
      else if ( mem_axird_cur_state == MEM_AXIRD_IDLE )
         qword_hw_7_rdata_reg   <= 'd0;

   end
end

//assign mem_16bit_rdata_ack = (((mem_axird_cur_state == MEM_AXIRD_IDLE ) & mem_axi_rd_start_reg ) |
//                             ((mem_axird_cur_state == MEM_BYTE_DATA_2 ) & slv_mem_rdata_ack & ( (~rd_len_cnt_over & (mem_axi_btype_reg != 2'b10) ) | 
//                                                                                                (~rd_len_cnt_lt_eq_2 & (mem_axi_btype_reg == 2'b10 )))) |  
//                             ( mem_axird_cur_state == MEM_BYTE_DATA_1_WAIT  ) | 
//                             ((mem_axird_cur_state == MEM_HWORD_DATA  ) & slv_mem_rdata_ack & ~rd_len_cnt_over) | 
//                             ( mem_axird_cur_state == MEM_HWORD_DATA_WAIT  ) | 
//                             ( mem_axird_cur_state == MEM_WORD_HW_DATA_1  ) | 
//                             ((mem_axird_cur_state == MEM_WORD_HW_DATA_2  ) & slv_mem_rdata_ack & ~rd_len_cnt_over) | 
//                             ( mem_axird_cur_state == MEM_WORD_HW_DATA_1_WAIT  ) | 
//                             ( mem_axird_cur_state == MEM_DWORD_HW_DATA_1  ) | 
//                             ( mem_axird_cur_state == MEM_DWORD_HW_DATA_2  ) | 
//                             ( mem_axird_cur_state == MEM_DWORD_HW_DATA_3  ) | 
//                             ((mem_axird_cur_state == MEM_DWORD_HW_DATA_4  ) & slv_mem_rdata_ack & ~rd_len_cnt_over ) |  
//                             ( mem_axird_cur_state == MEM_QWORD_HW_DATA_1  ) | 
//                             ( mem_axird_cur_state == MEM_QWORD_HW_DATA_2  ) | 
//                             ( mem_axird_cur_state == MEM_QWORD_HW_DATA_3  ) | 
//                             ( mem_axird_cur_state == MEM_QWORD_HW_DATA_4  ) | 
//                             ( mem_axird_cur_state == MEM_QWORD_HW_DATA_5  ) | 
//                             ( mem_axird_cur_state == MEM_QWORD_HW_DATA_6  ) | 
//                             ( mem_axird_cur_state == MEM_QWORD_HW_DATA_7  ) | 
//                             ((mem_axird_cur_state == MEM_QWORD_HW_DATA_8  ) & slv_mem_rdata_ack & ~rd_len_cnt_over ) |  
//                             ( mem_axird_cur_state == MEM_DWORD_HW_DATA_1_WAIT  ) | 
//                             ( mem_axird_cur_state == MEM_QWORD_HW_DATA_1_WAIT  ) 
//                             ) & mem_16bit_rdata_valid ; 


assign mem_16bit_rdata_ack = (((mem_axird_cur_state == MEM_BYTE_DATA_1  ) & slv_mem_rdata_ack & rd_len_cnt_over & (mem_axi_btype_reg != 2'b10)) | 
                             ((mem_axird_cur_state == MEM_BYTE_DATA_2 ) & slv_mem_rdata_ack) |  
                             ((mem_axird_cur_state == MEM_HWORD_DATA  ) & slv_mem_rdata_ack) | 
                             ( mem_axird_cur_state == MEM_WORD_HW_DATA_1  ) | 
                             ((mem_axird_cur_state == MEM_WORD_HW_DATA_2  ) & slv_mem_rdata_ack) | 
                             ( mem_axird_cur_state == MEM_DWORD_HW_DATA_1  ) | 
                             ( mem_axird_cur_state == MEM_DWORD_HW_DATA_2  ) | 
                             ( mem_axird_cur_state == MEM_DWORD_HW_DATA_3  ) | 
                             ((mem_axird_cur_state == MEM_DWORD_HW_DATA_4  ) & slv_mem_rdata_ack) |  
                             ( mem_axird_cur_state == MEM_QWORD_HW_DATA_1  ) | 
                             ( mem_axird_cur_state == MEM_QWORD_HW_DATA_2  ) | 
                             ( mem_axird_cur_state == MEM_QWORD_HW_DATA_3  ) | 
                             ( mem_axird_cur_state == MEM_QWORD_HW_DATA_4  ) | 
                             ( mem_axird_cur_state == MEM_QWORD_HW_DATA_5  ) | 
                             ( mem_axird_cur_state == MEM_QWORD_HW_DATA_6  ) | 
                             ( mem_axird_cur_state == MEM_QWORD_HW_DATA_7  ) | 
                             ((mem_axird_cur_state == MEM_QWORD_HW_DATA_8  ) & slv_mem_rdata_ack)   
                             ) & mem_16bit_rdata_valid ; 

assign mem_slv_rdata_valid = ( ( mem_axird_cur_state == MEM_BYTE_DATA_1 ) | 
                               ( mem_axird_cur_state == MEM_BYTE_DATA_2 ) | 
                               ( mem_axird_cur_state == MEM_HWORD_DATA  ) | 
                               ( mem_axird_cur_state == MEM_WORD_HW_DATA_2 )  | 
                               ( mem_axird_cur_state == MEM_DWORD_HW_DATA_4 )  | 
                               ( mem_axird_cur_state == MEM_QWORD_HW_DATA_8 )  | 
                               ( mem_axird_cur_state == MEM_ERROR_DATA )  );


assign mem_slv_rdata       = ((mem_axird_cur_state == MEM_BYTE_DATA_1 ) & ~rd_len_cnt_over )   ? {8{mem_16bit_rdata_in}} : 
                             ( mem_axird_cur_state == MEM_BYTE_DATA_2 )    ? {8{mem_16bit_rdata_in}}  : 
                             ((mem_axird_cur_state == MEM_BYTE_DATA_1 ) & rd_len_cnt_over & (mem_axi_btype_reg != 2'b10) )  ? {8{mem_16bit_rdata_in}}  : 
                             ((mem_axird_cur_state == MEM_BYTE_DATA_1 ) & rd_len_cnt_over & (mem_axi_btype_reg == 2'b10) )  ? {8{byte_rdata_reg}}  : 
                             ( mem_axird_cur_state == MEM_HWORD_DATA  )    ? {8{mem_16bit_rdata_in}}      : 
                             ( mem_axird_cur_state == MEM_WORD_HW_DATA_2 ) ? {4{mem_16bit_rdata_in,word_hw_1_rdata_reg}} :   
                             ( mem_axird_cur_state == MEM_DWORD_HW_DATA_4 )? {2{mem_16bit_rdata_in,dword_hw_3_rdata_reg,
                                                                              dword_hw_2_rdata_reg,dword_hw_1_rdata_reg}} : 
                             ( mem_axird_cur_state == MEM_QWORD_HW_DATA_8 )? {mem_16bit_rdata_in,qword_hw_7_rdata_reg,
                                                                              qword_hw_6_rdata_reg,qword_hw_5_rdata_reg, 
                                                                              qword_hw_4_rdata_reg,qword_hw_3_rdata_reg, 
                                                                              qword_hw_2_rdata_reg,qword_hw_1_rdata_reg} : 'd0;  

assign mem_slv_rdata_last  = ( ( mem_axird_cur_state == MEM_BYTE_DATA_1 )    | 
                               ( mem_axird_cur_state == MEM_BYTE_DATA_2 )    | 
                               ( mem_axird_cur_state == MEM_HWORD_DATA  )    |
                               ( mem_axird_cur_state == MEM_WORD_HW_DATA_2 ) | 
                               ( mem_axird_cur_state == MEM_DWORD_HW_DATA_4 )  | 
                               ( mem_axird_cur_state == MEM_QWORD_HW_DATA_8 )  | 
                               ( mem_axird_cur_state == MEM_ERROR_DATA ) ) & rd_len_cnt_over ; 


always @ ( posedge mem_clk or negedge reset_n )
begin
   if ( ~reset_n )
   begin
      mem_slv_rdata_resp <= 'd0; 
   end
   else
   begin
      if ( mem_err_en | mem_dqs_timeout_en)
          mem_slv_rdata_resp <= 'd2; // SLV ERROR 
      else
          mem_slv_rdata_resp <= ( mem_axi_rd_err_reg ) ? 2'd2: 'd0; 
   end
end


end   // SLV DATA WIDTH 128 END 

endgenerate



endmodule // mem_axi_rd 
