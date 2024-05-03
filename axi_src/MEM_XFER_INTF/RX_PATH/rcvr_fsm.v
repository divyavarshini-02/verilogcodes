`timescale 1ns/1ps
module rcvr_fsm(
//Global input
mem_clk,
reset_n,
//From Instruction handler
ddr_en,
instrn_dlp_en, // DLP only read transfer this bit has to be set 
read_instrn,
//From rcvr cntrl block
rd_done,
csr_read_end,
//From training monitor
dlp_read_stop,

//To rxdata block
rxdata_blk_en,
//To training monitor block
training_blk_en
);


input   mem_clk;
input   reset_n;

input   ddr_en;
input   instrn_dlp_en;
input   read_instrn;


input   dlp_read_stop;
input   rd_done;
input   csr_read_end;

output  rxdata_blk_en; 
output  training_blk_en;

reg [1:0] state;
reg       rxdata_blk_en;
reg       training_blk_en;
reg       dlp_rd_stp_d;

parameter IDLE = 2'b00;
parameter DLP =  2'b01;
parameter RD_DATA = 2'b10;

always @ (posedge mem_clk or negedge reset_n)
if (!reset_n)
begin 
  rxdata_blk_en   <= 1'b0;
  training_blk_en <= 1'b0;
  state           <= 2'b00;
  dlp_rd_stp_d    <= 1'b0;
end 
else
begin
  dlp_rd_stp_d    <= dlp_read_stop;
  case(state)
  IDLE://IDLE state
        if(ddr_en && instrn_dlp_en) //read data from memory preceeded by DLP
        begin
          state           <= DLP; //DLP state
          rxdata_blk_en   <= 1'b0;  // added- to avoid latch
          training_blk_en <= 1'b1;
        end
        //else if (read_instrn && !csr_dlp_en) //read data from memory not preceeded by DLP
        else if (read_instrn) //read data from memory not preceeded by DLP
        begin
          state           <= RD_DATA;
          rxdata_blk_en   <= 1'b1;
          training_blk_en <= 1'b0;
        end
        else
        begin
          state           <= state;
          rxdata_blk_en   <= 1'b0;
          training_blk_en <= 1'b0;               
        end
  DLP:
        if(dlp_rd_stp_d && instrn_dlp_en)
        begin
          state           <= IDLE;
          rxdata_blk_en   <= rxdata_blk_en;
          training_blk_en <= 1'b0;
        end         
        else if(dlp_read_stop)
        begin //to avoid gap between switching of training and rxblk
//if there is csr dlp enable, it indirectly means there exists a data block transfer following the training; so rxdatablk is enabled here
          state           <= RD_DATA;
          rxdata_blk_en   <= 1'b1;
          training_blk_en <= 1'b0;
        end
        else
        begin
          state           <= state;
          rxdata_blk_en   <= rxdata_blk_en  ;
          training_blk_en <= training_blk_en;
        end 
  RD_DATA: 
          begin
          state           <= rd_done | csr_read_end ? IDLE : state;
          rxdata_blk_en   <= rd_done | csr_read_end ? 1'b0 : rxdata_blk_en ;
          training_blk_en <= training_blk_en;
          end
  default:
          begin
            state           <= IDLE;
            rxdata_blk_en   <= 1'b0;
            training_blk_en <= 1'b0;
          end
   endcase
end

endmodule
