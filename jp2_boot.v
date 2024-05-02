

// ---------- Design Unit Header ---------- //
`timescale 1ps / 1ps

module jp2_boot (TP10,ai_scl_io,ai_sda_io,cam_rst_n_o,cam_sda_io,ir_mclk_o,mcu_mosi,mcu_rgb_i2c_scl,mcu_spi_clk_i,mcu_spi_cs_n_i,
reset_n_i,rx0_clk_p_i,rx0_d0_n_i,rx0_d0_p_i,rx0_d1_p_i,TP19,ai_int_n_o,cam_mclk_o,cam_scl_io,flash_spi_clk_o,
flash_spi_cs_n_o,ir_i2c_sda,mcu_miso,nx_ir_rst_n_o,reconfig_n_o,rx0_clk_n_i,rx0_d1_n_i,rx1_clk_n_i,rx1_clk_p_i,rx1_d0_n_i,
rx1_d0_p_i,sda_zero,flash_spi_d2,flash_spi_d3,flash_spi_miso,flash_spi_mosi,mcu_rgb_i2c_sda) ;

// ------------ Port declarations --------- //
input TP10;
wire TP10;
input ai_scl_io;
wire ai_scl_io;
input ai_sda_io;
wire ai_sda_io;
input cam_rst_n_o;
wire cam_rst_n_o;
input cam_sda_io;
wire cam_sda_io;
input ir_mclk_o;
wire ir_mclk_o;
input mcu_mosi;
wire mcu_mosi;
input mcu_rgb_i2c_scl;
wire mcu_rgb_i2c_scl;
input mcu_spi_clk_i;
wire mcu_spi_clk_i;
input mcu_spi_cs_n_i;
wire mcu_spi_cs_n_i;
input reset_n_i;
wire reset_n_i;
input rx0_clk_p_i;
wire rx0_clk_p_i;
input rx0_d0_n_i;
wire rx0_d0_n_i;
input rx0_d0_p_i;
wire rx0_d0_p_i;
input rx0_d1_p_i;
wire rx0_d1_p_i;
output TP19;
wire TP19;
output ai_int_n_o;
wire ai_int_n_o;
output cam_mclk_o;
wire cam_mclk_o;
output cam_scl_io;
wire cam_scl_io;
output flash_spi_clk_o;
wire flash_spi_clk_o;
output flash_spi_cs_n_o;
wire flash_spi_cs_n_o;
output ir_i2c_sda;
wire ir_i2c_sda;
output mcu_miso;
wire mcu_miso;
output nx_ir_rst_n_o;
wire nx_ir_rst_n_o;
output reconfig_n_o;
wire reconfig_n_o;
output rx0_clk_n_i;
wire rx0_clk_n_i;
output rx0_d1_n_i;
wire rx0_d1_n_i;
output rx1_clk_n_i;
wire rx1_clk_n_i;
output rx1_clk_p_i;
wire rx1_clk_p_i;
output rx1_d0_n_i;
wire rx1_d0_n_i;
output rx1_d0_p_i;
wire rx1_d0_p_i;
output sda_zero;
wire sda_zero;
inout flash_spi_d2;
wire flash_spi_d2;
inout flash_spi_d3;
wire flash_spi_d3;
inout flash_spi_miso;
wire flash_spi_miso;
inout flash_spi_mosi;
wire flash_spi_mosi;
inout mcu_rgb_i2c_sda;
wire mcu_rgb_i2c_sda;

// ----------------- Constants ------------ //
parameter DANGLING_INPUT_CONSTANT = 1'bZ;

// ----------- Signal declarations -------- //
wire async_fifo_empty;
wire async_fifo_full;
wire async_fifo_rd_en;
wire async_fifo_wr_en;
wire auth_cntr_clk;
wire auth_cntr_rst;
wire auth_in_process;
wire auth_start_process;
wire auth_we;
wire auth_write_clk;
wire au_spi_mcu_sel;
wire au_spi_sel;
wire cnfg_lmmi_rdata_valid;
wire cnfg_lmmi_ready;
wire cnfg_lmmi_request;
wire cnfg_lmmi_wr_rdn;
wire config_done;
wire config_ptr_rst;
wire config_read_clk;
wire config_start;
wire core_rst;
wire cre_lmmi_clk;
wire cre_lmmi_rdata_valid;
wire cre_lmmi_ready;
wire cre_lmmi_request;
wire cre_lmmi_wr_rdn;
wire cs_aui;
wire cs_fi;
wire dpm_we;
wire dpm_write_clk;
wire i2c_slave_clk;
wire i2c_slave_rst;
wire lf_clk;
wire loop_test_rst;
wire main_fsm_clk;
wire main_fsm_rst;
wire m_fsm_read_clk;
wire port_clk;
wire s0_aui;
wire s0_auo;
wire s0_fi;
wire s0_fo;
wire s1_aui;
wire s1_auo;
wire s1_fi;
wire s1_fo;
wire s2_aui;
wire s2_auo;
wire s2_fi;
wire s2_fo;
wire s3_aui;
wire s3_auo;
wire s3_fi;
wire s3_fo;
wire sclk_aui;
wire sclk_fi;
wire spi_cntr_clk;
wire spi_cntr_rst;
wire spi_dpm_read_clk;
wire spi_f_cntr_in_process;
wire spi_f_cntr_start;
wire sys_clk;
wire [7:0] auth_status;
wire [7:0] auth_wdata;
wire [7:0] auth_write_addr;
wire [7:0] cmd;
wire [7:0] cnfg_lmmi_offset;
wire [7:0] cnfg_lmmi_rdata;
wire [7:0] cnfg_lmmi_wdata;
wire [3:0] config_func;
wire [7:0] config_rdara;
wire [7:0] config_r_addr;
wire [7:0] config_status;
wire [17:0] cre_lmmi_offset;
wire [31:0] cre_lmmi_rdata;
wire [31:0] cre_lmmi_wdata;
wire [7:0] dev_id0;
wire [7:0] dev_id1;
wire [7:0] dev_id2;
wire [7:0] dev_id3;
wire [7:0] dev_id4;
wire [7:0] dev_id5;
wire [7:0] dev_id6;
wire [8:0] dpm_wadd;
wire [7:0] dpm_wdata;
wire [7:0] m_fsm_read_add;
wire [7:0] m_fsm_read_data;
wire [3:0] oe_au_out;
wire [3:0] oe_fsm_o;
wire [3:0] oe_mc_out;
wire [31:0] reboot_add;
wire [8:0] spi_dpm_read_add;
wire [7:0] spi_dpm_read_data;
wire [7:0] spi_flash_cntr_func;
wire [7:0] spi_f_cntr_status;
wire [7:0] status;

// ---- Declaration for Dangling inputs ----//
wire Dangling_Input_Signal = DANGLING_INPUT_CONSTANT;

// -------- Component instantiations -------//

// synthesis translate_off
// `library("Auth_cntr","auth_fsm4")
// synthesis translate_on
auth_fsm4 Auth_cntr
(
	.async_fifo_empty_i(async_fifo_empty),
	.async_fifo_full_i(async_fifo_full),
	.async_fifo_rd_en_o(async_fifo_rd_en),
	.async_fifo_wr_en_o(async_fifo_wr_en),
	.au_spi_sel(au_spi_sel),
	.clk(auth_cntr_clk),
	.cre_lmmi_clk(cre_lmmi_clk),
	.cre_lmmi_offset(cre_lmmi_offset),
	.cre_lmmi_rdata(cre_lmmi_rdata),
	.cre_lmmi_rdata_valid(cre_lmmi_rdata_valid),
	.cre_lmmi_ready(cre_lmmi_ready),
	.cre_lmmi_request(cre_lmmi_request),
	.cre_lmmi_wdata(cre_lmmi_wdata),
	.cre_lmmi_wr_rdn(cre_lmmi_wr_rdn),
	.cs(cs_aui),
	.in_process(auth_in_process),
	.m_fsm_read_add(m_fsm_read_add),
	.m_fsm_read_clk(m_fsm_read_clk),
	.m_fsm_read_data(m_fsm_read_data),
	.oe_au_out(oe_au_out),
	.rst(auth_cntr_rst),
	.sclk(sclk_aui),
	.sio0_in(s0_auo),
	.sio0_o(s0_aui),
	.sio1_in(s1_auo),
	.sio1_o(s1_aui),
	.sio2_in(s2_auo),
	.sio2_o(s2_aui),
	.sio3_in(s3_auo),
	.sio3_o(s3_aui),
	.spi_read_add(spi_dpm_read_add),
	.spi_read_clk(spi_dpm_read_clk),
	.spi_read_data(spi_dpm_read_data),
	.start_process(auth_start_process),
	.status(auth_status)
);



// synthesis translate_off
// `library("CLK_RST_UNIT1","clk_rst_unit_la1")
// synthesis translate_on
clk_rst_unit_la1 CLK_RST_UNIT1
(
	.auth_clk_o(auth_cntr_clk),
	.auth_rst_o(auth_cntr_rst),
	.clk_i(sys_clk),
	.i2c_clk_o(i2c_slave_clk),
	.i2c_rst_o(i2c_slave_rst),
	.main_fsm_clk_o(main_fsm_clk),
	.main_fsm_rst_o(main_fsm_rst),
	.port_clk_o(port_clk),
	.rst_i(core_rst),
	.spi_cntr_clk_o(spi_cntr_clk),
	.spi_cntr_rst_o(spi_cntr_rst)
);



// synthesis translate_off
// `library("COMBO_CRE_MB_CONFIG","cre_mb_config1")
// synthesis translate_on
cre_mb_config1 COMBO_CRE_MB_CONFIG
(
	.MSPIMADDR(reboot_add),
	.TP10(TP10),
	.async_fifo_empty_o(async_fifo_empty),
	.async_fifo_full_o(async_fifo_full),
	.async_fifo_rd_en_i(async_fifo_rd_en),
	.async_fifo_wr_en_i(async_fifo_wr_en),
	.boot_rst(core_rst),
	.cnfg_lmmi_offset_i(cnfg_lmmi_offset),
	.cnfg_lmmi_rdata_o(cnfg_lmmi_rdata),
	.cnfg_lmmi_rdata_valid_o(cnfg_lmmi_rdata_valid),
	.cnfg_lmmi_ready_o(cnfg_lmmi_ready),
	.cnfg_lmmi_request_i(cnfg_lmmi_request),
	.cnfg_lmmi_wdata_i(cnfg_lmmi_wdata),
	.cnfg_lmmi_wr_rdn_i(cnfg_lmmi_wr_rdn),
	.cre_lmmi_clk_i(cre_lmmi_clk),
	.cre_lmmi_offset_i(cre_lmmi_offset),
	.cre_lmmi_rdata_o(cre_lmmi_rdata),
	.cre_lmmi_rdata_valid_o(cre_lmmi_rdata_valid),
	.cre_lmmi_ready_o(cre_lmmi_ready),
	.cre_lmmi_request_i(cre_lmmi_request),
	.cre_lmmi_wdata_i(cre_lmmi_wdata),
	.cre_lmmi_wr_rdn_i(cre_lmmi_wr_rdn),
	.lf_clk_o(lf_clk),
	.loop_test_rst_n(loop_test_rst),
	.reset_n_i(reset_n_i),
	.sys_clk_o(sys_clk)
);



// synthesis translate_off
// `library("DPM_MAIN_TO_AUTH","dual_port_ram1")
// synthesis translate_on
dual_port_ram1 DPM_MAIN_TO_AUTH
(
	.rdata_o(m_fsm_read_data),
	.read_addr_i(m_fsm_read_add),
	.read_clk_i(m_fsm_read_clk),
	.wdata_i(auth_wdata),
	.we_i(auth_we),
	.write_addr_i(auth_write_addr),
	.write_clk_i(auth_write_clk)
);



// synthesis translate_off
// `library("DPM_SPI_CNTR_AUTH","dual_port_ram2")
// synthesis translate_on
dual_port_ram2 DPM_SPI_CNTR_AUTH
(
	.rdata_o(spi_dpm_read_data),
	.read_addr_i(spi_dpm_read_add),
	.read_clk_i(spi_dpm_read_clk),
	.wdata_i(dpm_wdata),
	.we_i(dpm_we),
	.write_addr_i(dpm_wadd),
	.write_clk_i(dpm_write_clk)
);



// synthesis translate_off
// `library("I2C_SLAVE_1","i2c_slave_la1")
// synthesis translate_on
i2c_slave_la1 I2C_SLAVE_1
(
	.cmd_o(cmd),
	.device_id0_i(dev_id0),
	.device_id1_i(dev_id1),
	.device_id2_i(dev_id2),
	.device_id3_i(dev_id3),
	.device_id4_i(dev_id4),
	.device_id5_i(dev_id5),
	.device_id6_i(dev_id6),
	.reg_addr(),
	.reg_re(),
	.reg_wdata(),
	.reg_we(),
	.rst(i2c_slave_rst),
	.scl_in(mcu_rgb_i2c_scl),
	.sda_in(mcu_rgb_i2c_sda),
	.sda_zero(sda_zero),
	.status_i(status),
	.sys_clk(i2c_slave_clk),
	.ver1_i({8{Dangling_Input_Signal}}),
	.ver2_i({8{Dangling_Input_Signal}})
);



// synthesis translate_off
// `library("MAIN_FSM","main_fsm2")
// synthesis translate_on
main_fsm2 MAIN_FSM
(
	.MSPIMADDR(reboot_add),
	.auth_in_process(auth_in_process),
	.auth_start_process(auth_start_process),
	.auth_status(auth_status),
	.auth_wdata(auth_wdata),
	.auth_we(auth_we),
	.auth_write_addr(auth_write_addr),
	.auth_write_clk(auth_write_clk),
	.clk(main_fsm_clk),
	.cmd(cmd),
	.config_done(config_done),
	.config_func(config_func),
	.config_ptr_rst(config_ptr_rst),
	.config_rdata(config_rdara),
	.config_read_addr(config_r_addr),
	.config_read_clk(config_read_clk),
	.config_start(config_start),
	.config_status(config_status),
	.dev_id0(dev_id0),
	.dev_id1(dev_id1),
	.dev_id2(dev_id2),
	.dev_id3(dev_id3),
	.dev_id4(dev_id4),
	.dev_id5(dev_id5),
	.dev_id6(dev_id6),
	.dev_id7(),
	.mux_sel_o(au_spi_mcu_sel),
	.oe_mc_o(oe_mc_out),
	.rst(main_fsm_rst),
	.spi_f_in_process(spi_f_cntr_in_process),
	.spi_f_start_process(spi_f_cntr_start),
	.spi_f_status(spi_f_cntr_status),
	.spi_flash_cntr_func(spi_flash_cntr_func),
	.status(status)
);



// synthesis translate_off
// `library("SELF_TEST_UNIT","self_test_bb1")
// synthesis translate_on
self_test_bb1 SELF_TEST_UNIT
(
	.TP10(TP10),
	.TP19(TP19),
	.ai_int_n_o(ai_int_n_o),
	.ai_scl_io(ai_scl_io),
	.ai_sda_io(ai_sda_io),
	.cam_mclk_o(cam_mclk_o),
	.cam_rst_n_o(cam_rst_n_o),
	.cam_scl_io(cam_scl_io),
	.cam_sda_io(cam_sda_io),
	.ir_i2c_sda(ir_i2c_sda),
	.ir_mclk_o(ir_mclk_o),
	.lf_clk(lf_clk),
	.loop_test_rst_n(loop_test_rst),
	.nx_ir_rst_n_o(nx_ir_rst_n_o),
	.reconfig_n_o(reconfig_n_o),
	.rx0_clk_n_i(rx0_clk_n_i),
	.rx0_clk_p_i(rx0_clk_p_i),
	.rx0_d0_n_i(rx0_d0_n_i),
	.rx0_d0_p_i(rx0_d0_p_i),
	.rx0_d1_n_i(rx0_d1_n_i),
	.rx0_d1_p_i(rx0_d1_p_i),
	.rx1_clk_n_i(rx1_clk_n_i),
	.rx1_clk_p_i(rx1_clk_p_i),
	.rx1_d0_n_i(rx1_d0_n_i),
	.rx1_d0_p_i(rx1_d0_p_i)
);



// synthesis translate_off
// `library("SPI_FLASH_CNTR","mb_spi_flash_cntr3")
// synthesis translate_on
mb_spi_flash_cntr3 SPI_FLASH_CNTR
(
	.clk(spi_cntr_clk),
	.cs(cs_fi),
	.done(spi_f_cntr_in_process),
	.func(spi_flash_cntr_func),
	.oe_fsm_o(oe_fsm_o),
	.rst(spi_cntr_rst),
	.sclk(sclk_fi),
	.sio0(s0_fi),
	.sio0_in(s0_fo),
	.sio1(s1_fi),
	.sio1_in(s1_fo),
	.sio2(s2_fi),
	.sio2_in(s2_fo),
	.sio3(s3_fi),
	.sio3_in(s3_fo),
	.start(spi_f_cntr_start),
	.status(spi_f_cntr_status),
	.wadd(dpm_wadd),
	.wdata(dpm_wdata),
	.we(dpm_we),
	.write_clk(dpm_write_clk)
);



// synthesis translate_off
// `library("TRI_MUX_INST","tri_mux")
// synthesis translate_on
tri_mux TRI_MUX_INST
(
	.Si0_au_in(s0_aui),
	.Si0_fsm_in(s0_fi),
	.Si0_mc_in(mcu_mosi),
	.Si1_au_in(s1_aui),
	.Si1_fsm_in(s1_fi),
	.Si2_au_in(s2_aui),
	.Si2_fsm_in(s2_fi),
	.Si3_au_in(s3_aui),
	.Si3_fsm_in(s3_fi),
	.So0_au_out(s0_auo),
	.So0_fsm_out(s0_fo),
	.So0_mc_out(mcu_miso),
	.So1_au_out(s1_auo),
	.So1_fsm_out(s1_fo),
	.So2_au_out(s2_auo),
	.So2_fsm_out(s2_fo),
	.So3_au_out(s3_auo),
	.So3_fsm_out(s3_fo),
	.au_spi_sel_in(au_spi_sel),
	.cs_au_in(cs_aui),
	.cs_fsm_in(cs_fi),
	.cs_mc_in(mcu_spi_cs_n_i),
	.flash_spi_clk_o(flash_spi_clk_o),
	.flash_spi_cs_n_o(flash_spi_cs_n_o),
	.flash_spi_d2(flash_spi_d2),
	.flash_spi_d3(flash_spi_d3),
	.flash_spi_miso(flash_spi_miso),
	.flash_spi_mosi(flash_spi_mosi),
	.oe_au_in(oe_au_out),
	.oe_fsm_in(oe_fsm_o),
	.oe_mc_in(oe_mc_out),
	.sclk_au_in(sclk_aui),
	.sclk_fsm_in(sclk_fi),
	.sclk_mc_in(mcu_spi_clk_i),
	.sel_mcu_in(au_spi_mcu_sel)
);



// synthesis translate_off
// `library("dev_config_fsm","dev_config_fsm1")
// synthesis translate_on
dev_config_fsm1 dev_config_fsm
(
	.clk(sys_clk),
	.done(config_done),
	.func(config_func),
	.lmmi_offset_o(cnfg_lmmi_offset),
	.lmmi_rdata_valid_i(cnfg_lmmi_rdata_valid),
	.lmmi_ready_i(cnfg_lmmi_ready),
	.lmmi_request_o(cnfg_lmmi_request),
	.lmmi_wdata_o(cnfg_lmmi_wdata),
	.lmmi_wr_rdn_o(cnfg_lmmi_wr_rdn),
	.rst(core_rst),
	.start(config_start),
	.status(config_status)
);



// synthesis translate_off
// `library("dpm_config_main","dual_port_ram_auto1")
// synthesis translate_on
dual_port_ram_auto1 dpm_config_main
(
	.rdata_o(config_rdara),
	.read_addr_i(config_r_addr),
	.read_clk_i(config_read_clk),
	.rst_i(config_ptr_rst),
	.wdata_i(cnfg_lmmi_rdata),
	.we_i(cnfg_lmmi_rdata_valid),
	.write_clk_i(sys_clk)
);



endmodule 
