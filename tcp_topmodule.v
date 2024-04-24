module tcp_top(clk,mdc,mdio,int_N,rst,er,tx_en,dataout,shift_90,sw,dataout_rx,rx_clk,rx_er,rx_dv,rx_crs,rx_col,mem);
  
  //tcp_phy
  input clk;
  inout mdio;
  output mdc;
  
  //common tx_rx
  input int_N;
  output reg rst=1;
  
  //tcp_tx
  input sw;
  output er;
  output tx_en;
  output [3:0]dataout;
  output shift_90;
  wire [591:0]tx_temp;
  wire [3:0] a,b;
  wire [31:0]CRC_32_op;
  wire [19:0]cnt;
  
  
  //common tx_rx
  wire ar;
  wire sr;
  wire[31:0] ack_reg;
  
  //tcp_rx
 input [3:0]dataout_rx;
 input rx_clk,rx_er,rx_dv,rx_crs,rx_col; 
 output [527:0]mem;
 wire [63:0]temp;
 wire [3:0]rx_data_2,rx_data_1;

//tcp_phychip qp0(clk,mdc,mdio);
tcp_tx qp1(clk,er,tx_en,dataout,shift_90,ar,sr,ack_reg,sw,CRC_32_op,tx_temp,a,b,cnt);
tcp_rx qp2(clk,ar,sr,ack_reg,dataout_rx,rx_clk,rx_er,rx_dv,rx_crs,rx_col,mem,temp,rx_data_2,rx_data_1);

endmodule 