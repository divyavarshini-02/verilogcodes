module synchronizer_top
	(
	ahb_clk,
	ahb_rst_n,
	apb_clk,
	apb_rst_n,
	mem_clk,
	mem_rst_n,
	mem_illegal_instrn,
	mem_illegal_instrn_sync,
	mem_dqs_non_toggle_err,
	mem_dqs_non_toggle_err_sync,
	csr_dqs_non_toggle_err,
	csr_dqs_non_toggle_err_sync,
	illegal_strobe,
	illegal_strobe_sync,
	calib_tap_valid,
	calib_tap_valid_sync,
	mem_rd_valid,
	mem_rd_valid_sync,
	mem_xfer_pending,
	mem_xfer_pending_sync,
	slv_mem_err,
	slv_mem_err_sync,
	rd_seq_sel,	
	rd_seq_sel_sync,	
	wr_seq_sel,	
	wr_seq_sel_sync,	
	jhr_en,
	jhr_en_sync,
	mem_rd_data_ack,
	mem_rd_data_ack_sync              
	);

input ahb_clk;                     	
input ahb_rst_n; 
input apb_clk;
input apb_rst_n;                  	
input mem_clk;
input mem_rst_n;

input mem_illegal_instrn;
output mem_illegal_instrn_sync;
input mem_dqs_non_toggle_err;
output mem_dqs_non_toggle_err_sync;
input csr_dqs_non_toggle_err;
output csr_dqs_non_toggle_err_sync;
input illegal_strobe;
output illegal_strobe_sync;
input calib_tap_valid;
output calib_tap_valid_sync;
input mem_rd_valid;
output mem_rd_valid_sync;
input mem_xfer_pending;
output mem_xfer_pending_sync;
input slv_mem_err;
output slv_mem_err_sync;
input rd_seq_sel;	
output rd_seq_sel_sync;	
input wr_seq_sel;	
output wr_seq_sel_sync;	
input jhr_en;
output jhr_en_sync;
input mem_rd_data_ack;
output mem_rd_data_ack_sync;

double_flop_sync #(
          1
          ) 
 MEM_ILLEGAL_INSTRN_SYNC(
          .clk        (ahb_clk),	
          .rst_n      (ahb_rst_n),
          .async_in   (mem_illegal_instrn),	
          .sync_out   (mem_illegal_instrn_sync)
);



double_flop_sync #(
          1
          ) 
MEM_DQS_NON_TOGGLE_ERR_SYNC (
          .clk        (ahb_clk),	
          .rst_n      (ahb_rst_n),
          .async_in   (mem_dqs_non_toggle_err),	
          .sync_out   (mem_dqs_non_toggle_err_sync)
);
double_flop_sync #(
          1
          ) 
 ILLEGAL_STROBE_SYNC(
          .clk        (ahb_clk),	
          .rst_n      (ahb_rst_n),
          .async_in   (illegal_strobe),	
          .sync_out   (illegal_strobe_sync)
);



double_flop_sync #(
          1
          ) 
CSR_DQS_NON_TOGGLE_ERR_SYNC (
          .clk        (apb_clk),	
          .rst_n      (apb_rst_n),
          .async_in   (csr_dqs_non_toggle_err),	
          .sync_out   (csr_dqs_non_toggle_err_sync)
);

double_flop_sync #(
          1
          ) 
 CALIB_TAP_VALID_SYNC(
          .clk        (ahb_clk),	
          .rst_n      (ahb_rst_n),
          .async_in   (calib_tap_valid),	
          .sync_out   (calib_tap_valid_sync)
);

double_flop_sync #(
          1
          ) 
 MEM_STATUS_REG_RD_VALID_SYNC(
          .clk        (ahb_clk),	
          .rst_n      (ahb_rst_n),
          .async_in   (mem_rd_valid),	
          .sync_out   (mem_rd_valid_sync)
);
double_flop_sync #(
          1
          ) 
 MEM_OUTSTANDING_SYNC(
          .clk        (ahb_clk),	
          .rst_n      (ahb_rst_n),
          .async_in   (mem_xfer_pending),	
          .sync_out   (mem_xfer_pending_sync)
);
double_flop_sync #(
          1
          ) 
 SLV_MEM_ERR_SYNC(
          .clk        (ahb_clk),	
          .rst_n      (ahb_rst_n),
          .async_in   (slv_mem_err),	
          .sync_out   (slv_mem_err_sync)
);

fb_sync READ_SEQ_CHANGE_SYNC (
                               .clkA   (ahb_clk),
                               .clkB   (mem_clk), 
                               .resetA (ahb_rst_n),
                               .resetB (mem_rst_n),
                               .inA    (rd_seq_sel),
                               .inB    (),
                               .inB_pulse(rd_seq_sel_sync)
                                 );
fb_sync WR_SEQ_CHANGE_SYNC (
                               .clkA   (ahb_clk),
                               .clkB   (mem_clk), 
                               .resetA (ahb_rst_n),
                               .resetB (mem_rst_n),
                               .inA    (wr_seq_sel),
                               .inB    (),
                               .inB_pulse(wr_seq_sel_sync)
                                 );
fb_sync JHR_EN_SYNC (
                               .clkA   (ahb_clk),
                               .clkB   (mem_clk), 
                               .resetA (ahb_rst_n),
                               .resetB (mem_rst_n),
                               .inA    (jhr_en),
                               .inB    (),
                               .inB_pulse(jhr_en_sync)
                                 );
fb_sync MEM_STATUS_REG_RD_DATA_ACK_SYNC (
                               .clkA   (ahb_clk),
                               .clkB   (mem_clk), 
                               .resetA (ahb_rst_n),
                               .resetB (mem_rst_n),
                               .inA    (mem_rd_data_ack),
                               .inB    (),
                               .inB_pulse(mem_rd_data_ack_sync)
                                 );
endmodule                  
