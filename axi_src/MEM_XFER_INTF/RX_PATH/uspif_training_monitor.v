`timescale 1ns/1ps
module uspif_training_monitor (

//I/Ps'
mem_clk,
reset_n,
start_read,//fsm control to trigger training blk
training_blk_en,
bits_enabled,
dlp_pattern,
dlp_cyc_cnt,
rcv_dqfifo_empty, 
rcv_dqfifo_dout,
instrn_dlp_en,

//O/Ps'
rcv_dqfifo_rd_en, 
calib_tap_out,
calib_tap_valid,
dlp_read_stop // //to avoid gap between switching of training to normal rxdata_blk enable
);


input         mem_clk;
input         reset_n;
input         start_read;
input         training_blk_en;
input [1:0]   bits_enabled;
input         instrn_dlp_en;
input [7:0]   dlp_pattern;
input [2:0]   dlp_cyc_cnt; // restrict to 4 cycles
input         rcv_dqfifo_empty;
input [15:0]  rcv_dqfifo_dout;

output        rcv_dqfifo_rd_en;
output        calib_tap_valid;
output [7:0]  calib_tap_out;
output        dlp_read_stop;

reg        next_rcv_dqfifo_rd_en,rcv_dqfifo_rd_en ;
reg        rcv_dqfifo_rd_en_d;
reg [1:0]  read_count, next_read_count;
reg [7:0]  pass_check_negedge;
reg [7:0]  pass_check_posedge;
reg [7:0]  pass_check;
reg        next_calib_tap_valid,calib_tap_valid;
//reg        dlp_end;
reg        dlp_end_d;
reg [7:0]  next_pass_chk;
reg        start_read_d;

wire [2:0] pass_check_bit_sel;
wire [1:0] dlp_bit_select;
wire [7:0] rcv_dqfifo_dout_lsb, rcv_dqfifo_dout_msb;
//wire       rd_end;
wire       dlp_end;
wire start_read_redge;

//read_count : requires 4 clocks of read data . i,e, 8 edges of data
//1st clock set : dlp_pattern [0], dlp_pattern[1] ; 
//2nd clock set : dlp_pattern [2], dlp_pattern[3] ; 
//3rd clock set : dlp_pattern [4], dlp_pattern[5] ; 
//4th clock set : dlp_pattern [6], dlp_pattern[7] ; 
assign dlp_bit_select      = {dlp_pattern[pass_check_bit_sel],dlp_pattern[pass_check_bit_sel+1]}; //{posedge byte data, nedgedge byte data} 
assign rcv_dqfifo_dout_lsb = rcv_dqfifo_dout[7:0];
assign rcv_dqfifo_dout_msb = rcv_dqfifo_dout[15:8];
assign pass_check_bit_sel  = ({1'b0,read_count} << 1); // shall take 2,4,6,8 values; denotes number of edges
assign calib_tap_out       =  pass_check;
assign dlp_read_stop       = (read_count == dlp_cyc_cnt -3'h2 );
assign dlp_end         = (read_count ==  (dlp_cyc_cnt -3'h1));
assign start_read_redge = start_read && ~start_read_d ; 

always @ (posedge mem_clk or negedge reset_n)
begin
if (!reset_n)
begin
rcv_dqfifo_rd_en      <= 1'b0;
read_count            <= 2'b0;
rcv_dqfifo_rd_en_d    <= 1'b0;
pass_check            <= 8'd0;
calib_tap_valid       <= 1'b0;
dlp_end_d             <= 1'b0;
start_read_d          <= 1'b0;
end
else
begin
rcv_dqfifo_rd_en      <= next_rcv_dqfifo_rd_en ;
read_count            <= next_read_count;
rcv_dqfifo_rd_en_d    <= rcv_dqfifo_rd_en;
pass_check            <= next_pass_chk;
calib_tap_valid       <= next_calib_tap_valid;
dlp_end_d             <= dlp_end;
start_read_d          <= start_read;
end
end


always @ *
begin
  if(instrn_dlp_en && rcv_dqfifo_rd_en_d) 
  begin
  next_pass_chk = pass_check;
  next_pass_chk[pass_check_bit_sel] = pass_check_negedge[pass_check_bit_sel];
  next_pass_chk[pass_check_bit_sel+3'd1] = pass_check_posedge[pass_check_bit_sel+3'd1];
  end
  else if(start_read_redge)
  begin
  next_pass_chk = 8'h00;
  end
  else next_pass_chk = pass_check;
end


always @ *
begin

next_calib_tap_valid = (dlp_end && ~dlp_end_d) ? 1'b1 : start_read_redge ? 1'b0 :  calib_tap_valid;
next_rcv_dqfifo_rd_en = 1'b0;
next_read_count       = 2'd0;
if (rcv_dqfifo_empty )
begin
next_rcv_dqfifo_rd_en = 1'b0;
next_read_count       = read_count;
end
else if (dlp_end)
begin
next_rcv_dqfifo_rd_en = 1'b0;
next_read_count       = 2'd0;
end
else if (!rcv_dqfifo_empty && training_blk_en)
begin
next_rcv_dqfifo_rd_en = 1'b1;
next_read_count       = rcv_dqfifo_rd_en_d ? (read_count + 2'd1) : read_count;
end
end


// Negedge data bytes validation
always @ * begin

pass_check_negedge = {4'b0,pass_check[6],pass_check[4],pass_check[2],pass_check[0]};
if(rcv_dqfifo_empty) 
begin
   pass_check_negedge = 8'h00;
end
else if (rcv_dqfifo_rd_en_d)
begin
case (bits_enabled)

2'b00: //1 bit data line
if ({1{dlp_bit_select[0]}} == rcv_dqfifo_dout_msb[1]) 
pass_check_negedge[pass_check_bit_sel] = 1'b1;
else
pass_check_negedge[pass_check_bit_sel] = 1'b0;

2'b01://2 bit data line
if ({2{dlp_bit_select[0]}} == rcv_dqfifo_dout_msb[1:0]) 
pass_check_negedge[pass_check_bit_sel] = 1'b1;
else
pass_check_negedge[pass_check_bit_sel] = 1'b0;

2'b10: //4 bit data line
if ({4{dlp_bit_select[0]}} == rcv_dqfifo_dout_msb[3:0]) 
pass_check_negedge[pass_check_bit_sel] = 1'b1;
else
pass_check_negedge[pass_check_bit_sel] = 1'b0;

2'b11: //8 bit data line

if ({8{dlp_bit_select[0]}} == rcv_dqfifo_dout_msb[7:0]) 
pass_check_negedge[pass_check_bit_sel] = 1'b1;
else
pass_check_negedge[pass_check_bit_sel] = 1'b0;

endcase
end
else
begin
pass_check_negedge[pass_check_bit_sel] = pass_check[pass_check_bit_sel];
end

end

// Posedge data bytes validation
always @ * begin
pass_check_posedge = {4'b0,pass_check[7],pass_check[5],pass_check[3],pass_check[1]};

if(rcv_dqfifo_empty) 
begin
   pass_check_posedge = 8'h00;
end
else if (rcv_dqfifo_rd_en_d)
begin
case (bits_enabled)
2'b00: //1 bit data line
if ({1{dlp_bit_select[1]}} == rcv_dqfifo_dout_lsb[1]) 
pass_check_posedge[pass_check_bit_sel+3'd1] = 1'b1;
else
pass_check_posedge[pass_check_bit_sel+3'd1] = 1'b0;

2'b01://2 bit data line
if ({2{dlp_bit_select[1]}} == rcv_dqfifo_dout_lsb[1:0]) 
pass_check_posedge[pass_check_bit_sel+3'd1] = 1'b1;
else
pass_check_posedge[pass_check_bit_sel+3'd1] = 1'b0;

2'b10: //4 bit data line
if ({4{dlp_bit_select[1]}} == rcv_dqfifo_dout_lsb[3:0]) 
pass_check_posedge[pass_check_bit_sel+3'd1] = 1'b1;
else
pass_check_posedge[pass_check_bit_sel+3'd1] = 1'b0;

2'b11: //8 bit data line
if ({8{dlp_bit_select[1]}} == rcv_dqfifo_dout_lsb[7:0]) 
pass_check_posedge[pass_check_bit_sel+3'd1] = 1'b1;
else
pass_check_posedge[pass_check_bit_sel+3'd1] = 1'b0;

endcase
end
else
begin
pass_check_posedge[pass_check_bit_sel+3'd1] = pass_check[pass_check_bit_sel+3'd1];
end

end

endmodule
