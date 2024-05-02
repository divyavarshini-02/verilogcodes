
`define MB_PLUS_AUTH
`define LSCC_CRE

module  cre_mb_config1 (
        cre_lmmi_clk_i, 
        cre_lmmi_request_i, 
        cre_lmmi_wr_rdn_i, 
        cre_lmmi_offset_i, 
        cre_lmmi_wdata_i, 
        cre_lmmi_rdata_o, 
        cre_lmmi_rdata_valid_o, 
        cre_lmmi_ready_o,
        async_fifo_wr_en_i, 
        async_fifo_rd_en_i, 
        async_fifo_full_o, 
        async_fifo_empty_o,
		MSPIMADDR, 
		cnfg_lmmi_request_i,
		cnfg_lmmi_wr_rdn_i,
		cnfg_lmmi_offset_i,
		cnfg_lmmi_wdata_i,
		cnfg_lmmi_rdata_o,
		cnfg_lmmi_ready_o,
		cnfg_lmmi_rdata_valid_o,  
		TP10,
		lf_clk_o, 	 
		loop_test_rst_n,
		boot_rst,
		sys_clk_o,
		reset_n_i		) ;
    input 			cre_lmmi_clk_i ; 
    input 			cre_lmmi_request_i ; 
    input 			cre_lmmi_wr_rdn_i ; 
    input [17:0] 	cre_lmmi_offset_i ; 
    input [31:0] 	cre_lmmi_wdata_i ; 
    output [31:0] 	cre_lmmi_rdata_o ; 
    output 			cre_lmmi_rdata_valid_o ; 
    output 			cre_lmmi_ready_o ; 

    input 			async_fifo_wr_en_i; 
    input 			async_fifo_rd_en_i; 
    output 			async_fifo_full_o; 
    output 			async_fifo_empty_o;
		
	input [31:0]	MSPIMADDR; 
	input			cnfg_lmmi_request_i;
	input			cnfg_lmmi_wr_rdn_i;
	input	[7:0]	cnfg_lmmi_offset_i;
	input	[7:0] 	cnfg_lmmi_wdata_i;
	output	[7:0] 	cnfg_lmmi_rdata_o;
	output			cnfg_lmmi_ready_o;
	output			cnfg_lmmi_rdata_valid_o	; 
	input			TP10; 
	output			lf_clk_o; 
	output			loop_test_rst_n;
	output			boot_rst ;	 
	output			sys_clk_o ;	
	input			reset_n_i;
	
	
wire cfg_clk;
wire cfg_clk_w;
wire LMMI_CLK_O;
wire LMMI_RST;
wire sed_sec_out_w;
wire cre_clk;
wire sedc_rst_o;



wire resetn;		
wire orgate_rst; 
wire boot_rst_n;
wire lf_clk;
wire sys_clk;
reg [7:0] r_rst_cnt;

assign 	lf_clk_o = lf_clk ;
assign resetn = (r_rst_cnt == 8'hFF);
always @(posedge lf_clk) begin
	if(!resetn) begin
		r_rst_cnt <= r_rst_cnt + 8'h1;
	end
end	

or(orgate_rst, resetn,reset_n_i);

assign   loop_test_rst_n = orgate_rst &   TP10;
assign	 boot_rst_n      = orgate_rst & (~TP10);	  
assign	 boot_rst        = orgate_rst & (~TP10);
assign   sys_clk_o       = sys_clk ;


	OSCA #(
		.HF_CLK_DIV		("9"),	   // 9-50Mhz  56-8Mhz
		.HF_SED_SEC_DIV	("1"),
		.HF_OSC_EN		("ENABLED"),
		.LF_OUTPUT_EN	("ENABLED")
	)	u_OSC (           
		.HFOUTEN	(1'b1), 
		.HFSDSCEN	(boot_rst_n), 	 // resetn
		.HFCLKOUT	(sys_clk), 
		.LFCLKOUT	(lf_clk), 
		.HFCLKCFG	(cfg_clk_w), 
		.HFSDCOUT	(sed_sec_out_w)
	);
	
	CONFIG_CLKRST_CORE u_cfg_clkrst_core (
		.JTAG_LRST_N	(boot_rst_n),	// OK? 
		.LMMI_CLK		(sys_clk), 
		.LMMI_LRST_N	(resetn), 
		.OSCCLK			(cfg_clk_w), 
		.SEDC_CLK		(sed_sec_out_w), 
		.SEDC_LRST_N	(boot_rst_n), 
		.WDT_LRST_N		(boot_rst_n),	// OK? 
		.HSE_CLK		(cre_clk), 
		.LMMI_CLK_O		(LMMI_CLK_O), 
		.LMMI_RST		(LMMI_RST), 
		.SEDC_RST		(sedc_rst_o), 
		.CFG_CLK		(cfg_clk), 
		.SMCLK_RST		(), 		 // SMCLK_RST
		.WDT_CLK		(), 
		.WDT_RST		(),
		.MBISTCLK(sys_clk)
	);

// note cre ip need to create in radiant with name cre_cmp 
 cre_cmp u_cre0 (.cfg_clk_i(cfg_clk),  
				.cre_clk_i(cre_clk), 
				.cre_rstn_i(boot_rst_n), 
				.lmmi_clk_i(cre_lmmi_clk_i), 
				.lmmi_resetn_i(boot_rst_n), 
				.lmmi_request_i(cre_lmmi_request_i), 
				.lmmi_wr_rdn_i(cre_lmmi_wr_rdn_i), 
				.lmmi_offset_i(cre_lmmi_offset_i), 
				.lmmi_wdata_i(cre_lmmi_wdata_i), 
				.lmmi_rdata_o(cre_lmmi_rdata_o), 
				.lmmi_rdata_valid_o(cre_lmmi_rdata_valid_o) , 
				.lmmi_ready_o(cre_lmmi_ready_o),
				.async_fifo_clk_i(cre_lmmi_clk_i), 
        		.async_fifo_rst_i(boot_rst_n), 
        		.async_fifo_wr_en_i(async_fifo_wr_en_i), 
        		.async_fifo_rd_en_i(async_fifo_rd_en_i), 
        		.async_fifo_full_o(async_fifo_full_o), 
        		.async_fifo_empty_o(async_fifo_empty_o)) ; /* synthesis syn_noprune=1 */ 
		
//	  defparam u_cre0.GSR = "ENABLED" ; 
//    defparam u_cre0.CRE_DISABLE = "ENABLED" ; 
//    defparam u_cre0.OTP_EN = "DISABLED" ;    



		CONFIG_LMMI #(
			.LMMI_EN ("EN")
		) config_lmmi (
			.LMMICLK		(LMMI_CLK_O),
			.LMMIREQUEST	(cnfg_lmmi_request_i),
			.LMMIWRRD_N		(cnfg_lmmi_wr_rdn_i),
			.LMMIOFFSET		(cnfg_lmmi_offset_i),
			.LMMIWDATA		(cnfg_lmmi_wdata_i),
			.LMMIRDATA		(cnfg_lmmi_rdata_o),
			.LMMIREADY		(cnfg_lmmi_ready_o),
			.LMMIRDATAVALID	(cnfg_lmmi_rdata_valid_o),
			.LMMIRESETN		(LMMI_RST),
			.RSTSMCLK		(),	// not necessary	  SMCLK_RST
			.SMCLK			()	// not necessary	  cfg_clk
		);		
		

MULTIBOOT #(
	.SOURCESEL ("EN")
) multi_boot_i (
	.AUTOREBOOT (1'b0),  // no need to set this!!!!!
	.MSPIMADDR  (MSPIMADDR)   // addr will be come from main fsm 
);



							   
	endmodule
