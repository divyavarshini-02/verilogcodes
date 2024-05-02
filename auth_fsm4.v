
`timescale 1ns / 1ps

module auth_fsm4 (async_fifo_empty_i, async_fifo_full_i, async_fifo_rd_en_o, async_fifo_wr_en_o, au_spi_sel, clk, cre_lmmi_clk, cre_lmmi_offset, cre_lmmi_rdata, cre_lmmi_rdata_valid, cre_lmmi_ready, cre_lmmi_request, cre_lmmi_wdata, cre_lmmi_wr_rdn, cs, in_process, m_fsm_read_add, m_fsm_read_clk, m_fsm_read_data, oe_au_out, rst, sclk, sio0_in, sio0_o, sio1_in, sio1_o, sio2_in, sio2_o, sio3_in, sio3_o, spi_read_add, spi_read_clk, spi_read_data, start_process, status);

/*
parameter
	DATA_SRC	 = 18'h2003C,
	DPA_CON	 = 18'h20030,
	ML_app_add_for_auth	 = 24'h300040,
	NX_app_add_for_auth	 = 24'h100040,
	PUB_KEY	 = 18'h1F800,
	RI_CTRL1	 = 18'h2000C,
	RI_CTRL3	 = 18'h20014,
	RO_GP0	 = 18'h20020,
	RS_sign	 = 18'h1F840,
	R_RECAL_SIGN	 = 18'h1F880,
	SHA_INIT	 = 18'h23070,
	SHA_MSG2	 = 18'h1F880,
	SHA_MSG	 = 18'h2304C,
	SHA_OUT	 = 18'h23050;
*/

input      	async_fifo_empty_i;
input      	async_fifo_full_i;
input      	clk;
input      	[31:0] cre_lmmi_rdata;
input      	cre_lmmi_rdata_valid;
input      	cre_lmmi_ready;
input      	[7:0] m_fsm_read_data;
input      	rst;
input      	sio0_in;
input      	sio1_in;
input      	sio2_in;
input      	sio3_in;
input      	[7:0] spi_read_data;
input      	start_process;
output     	async_fifo_rd_en_o;
output     	async_fifo_wr_en_o;
output     	au_spi_sel;
output     	cre_lmmi_clk;
output     	[17:0] cre_lmmi_offset;
output     	cre_lmmi_request;
output     	[31:0] cre_lmmi_wdata;
output     	cre_lmmi_wr_rdn;
output     	cs;
output     	in_process;
output     	[7:0] m_fsm_read_add;
output     	m_fsm_read_clk;
output     	[3:0] oe_au_out;
output     	sclk;
output     	sio0_o;
output     	sio1_o;
output     	sio2_o;
output     	sio3_o;
output     	[8:0] spi_read_add;
output     	spi_read_clk;
output     	[7:0] status;

wire        async_fifo_empty_i;
wire        async_fifo_full_i;
reg         async_fifo_rd_en_o, next_async_fifo_rd_en_o;
reg         async_fifo_wr_en_o, next_async_fifo_wr_en_o;
reg         au_spi_sel, next_au_spi_sel;
wire        clk;
reg         cre_lmmi_clk, next_cre_lmmi_clk;
reg         [17:0] cre_lmmi_offset, next_cre_lmmi_offset;
wire        [31:0] cre_lmmi_rdata;
wire        cre_lmmi_rdata_valid;
wire        cre_lmmi_ready;
reg         cre_lmmi_request, next_cre_lmmi_request;
reg         [31:0] cre_lmmi_wdata, next_cre_lmmi_wdata;
reg         cre_lmmi_wr_rdn, next_cre_lmmi_wr_rdn;
reg         cs, next_cs;
reg         in_process, next_in_process;
reg         [7:0] m_fsm_read_add, next_m_fsm_read_add;
reg         m_fsm_read_clk, next_m_fsm_read_clk;
wire        [7:0] m_fsm_read_data;
reg         [3:0] oe_au_out, next_oe_au_out;
wire        rst;
reg         sclk, next_sclk;
wire        sio0_in;
reg         sio0_o, next_sio0_o;
wire        sio1_in;
reg         sio1_o, next_sio1_o;
wire        sio2_in;
reg         sio2_o, next_sio2_o;
wire        sio3_in;
reg         sio3_o, next_sio3_o;
reg         [8:0] spi_read_add, next_spi_read_add;
reg         spi_read_clk, next_spi_read_clk;
wire        [7:0] spi_read_data;
wire        start_process;
reg         [7:0] status, next_status;

// BINARY ENCODED state machine: Sreg0
// State codes definitions:
`define set_RO_GP01 7'b0000000
`define set_RO_GP0_0 7'b0000001
`define set_RO_GP00 7'b0000010
`define lmmi_clk11_1 7'b0000011
`define chk_data_len 7'b0000100
`define lmmi_clk11_0 7'b0000101
`define chk_B00 7'b0000110
`define PK_dpm_rd_clk0 7'b0000111
`define PK_set_add 7'b0001000
`define RS_next_add 7'b0001001
`define set_PUB_KEY 7'b0001010
`define set_RS_sign 7'b0001011
`define PK_next_add 7'b0001100
`define RS_set_add 7'b0001101
`define lmmi_clk12_1 7'b0001110
`define lmmi_clk12_0 7'b0001111
`define PK_dpm_rd_clk1 7'b0010000
`define lmmi_clk13_0 7'b0010001
`define lmmi_clk13_1 7'b0010010
`define set_RO_GP0 7'b0010011
`define lmmi_clk0_0 7'b0010100
`define lmmi_clk0_1 7'b0010101
`define chk_B0 7'b0010110
`define lmmi_clk1_0 7'b0010111
`define lmmi_clk1_1 7'b0011000
`define lmmi_clk2_0 7'b0011001
`define set_DATA_SRC 7'b0011010
`define lmmi_clk2_1 7'b0011011
`define set_SHA_INIT_stp1 7'b0011100
`define lmmi_clk3_0 7'b0011101
`define lmmi_clk3_1 7'b0011110
`define set_SHA_INIT_stp2 7'b0011111
`define lmmi_clk4_0 7'b0100000
`define lmmi_clk4_1 7'b0100001
`define set_RI_CTRL1 7'b0100010
`define next_bitfile 7'b0100011
`define SHA_MSG2_next_add 7'b0100100
`define auth_done 7'b0100101
`define loop_read 7'b0100110
`define set_SHA_MSG2 7'b0100111
`define set_SHA_MSG2_add 7'b0101000
`define lmmi_clk14_1 7'b0101001
`define chk_ML_app 7'b0101010
`define lmmi_clk14_0 7'b0101011
`define lmmi_clk5_0 7'b0101100
`define chk_NX_app 7'b0101101
`define lmmi_clk5_1 7'b0101110
`define set_RI_CTRL11 7'b0101111
`define lmmi_clk15_0 7'b0110000
`define lmmi_clk15_1 7'b0110001
`define lmmi_clk16_0 7'b0110010
`define chk_B2 7'b0110011
`define lmmi_clk9_1 7'b0110100
`define set_RI_CTRL12 7'b0110101
`define S164 7'b0110110
`define lmmi_clk19_0 7'b0110111
`define lmmi_clk19_1 7'b0111000
`define lmmi_clk8_1 7'b0111001
`define lmmi_clk8_0 7'b0111010
`define set_R_RECAL_SIGN 7'b0111011
`define set_R_RECAL_SIGN_add 7'b0111100
`define lmmi_clk18_1 7'b0111101
`define lmmi_clk18_0 7'b0111110
`define R_RECAL_SIGN_next_add 7'b0111111
`define lmmi_clk17_1 7'b1000000
`define lmmi_clk17_0 7'b1000001
`define chk_bitfile12 7'b1000010
`define lmmi_clk16_1 7'b1000011
`define ideal_auth 7'b1000100
`define S168 7'b1000101
`define S158 7'b1000110
`define lmmi_clk10_1 7'b1000111
`define lmmi_clk10_0 7'b1001000
`define select_bitfile_add 7'b1001001
`define flash_add_bitout 7'b1001010
`define flash_sclk10 7'b1001011
`define set_wdata_SHA_MSG 7'b1001100
`define flash_sclk01 7'b1001101
`define flash_sclk00 7'b1001110
`define set_SHA_MSG_1 7'b1001111
`define flash_sclk11 7'b1010000
`define flash_set_add_cmd 7'b1010001
`define flash_data_bit_in 7'b1010010
`define dpm_rd_clk0 7'b1010011
`define dpm_rd_clk1 7'b1010100
`define set_dpm_add 7'b1010101
`define lmmi_clk6_0 7'b1010110
`define lmmi_clk6_1 7'b1010111
`define select_dpm_add 7'b1011000
`define reset_auth 7'b1011001
`define start_auth 7'b1011010
`define S169 7'b1011100
`define lmmi_clk9_0 7'b1011011

reg [6:0] CurrState_Sreg0;
reg [6:0] NextState_Sreg0;

// Diagram actions (continuous assignments allowed only: assign ...)

// Diagram ACTION

//--------------------------------------------------------------------
// Machine: Sreg0
//--------------------------------------------------------------------
// machine variables declarations
reg  [17:0]OFFSET_PTR, next_OFFSET_PTR;
reg  [23:0]address, next_address;
reg  [31:0]cmdadd, next_cmdadd;
reg  [7:0]cnt1, next_cnt1;
reg  [7:0]cnt, next_cnt;
reg  [23:0]data_len, next_data_len;
reg  [8:0]loop, next_loop;
reg  [7:0]pt_bit, next_pt_bit;
reg  [8:0]spi_cnt, next_spi_cnt;
reg  [575:0]temp0, next_temp0;
reg  [575:0]temp1, next_temp1;
reg  [575:0]temp2, next_temp2;
reg  [575:0]temp3, next_temp3;
reg  [7:0]temp, next_temp;
reg  [7:0]ver_loc, next_ver_loc;

//----------------------------------
// Next State Logic (combinatorial)
//----------------------------------
always @ (OFFSET_PTR or address or async_fifo_empty_i or async_fifo_full_i or async_fifo_rd_en_o or async_fifo_wr_en_o or au_spi_sel or cmdadd or cnt or cnt1 or cre_lmmi_clk or cre_lmmi_offset or cre_lmmi_rdata or cre_lmmi_rdata_valid or cre_lmmi_ready or cre_lmmi_request or cre_lmmi_wdata or cre_lmmi_wr_rdn or cs or data_len or in_process or loop or m_fsm_read_add or m_fsm_read_clk or m_fsm_read_data or oe_au_out or pt_bit or sclk or sio0_o or sio1_in or sio1_o or sio2_o or sio3_o or spi_cnt or spi_read_add or spi_read_clk or spi_read_data or start_process or status or temp or temp0 or temp1 or temp2 or temp3 or ver_loc or CurrState_Sreg0)
begin : Sreg0_NextState
	NextState_Sreg0 <= CurrState_Sreg0;
	// Set default values for outputs and signals
	next_cre_lmmi_offset <= cre_lmmi_offset;
	next_cre_lmmi_request <= cre_lmmi_request;
	next_cre_lmmi_wr_rdn <= cre_lmmi_wr_rdn;
	next_cs <= cs;
	next_au_spi_sel <= au_spi_sel;
	next_async_fifo_wr_en_o <= async_fifo_wr_en_o;
	next_cre_lmmi_clk <= cre_lmmi_clk;
	next_data_len <= data_len;
	next_pt_bit <= pt_bit;
	next_temp <= temp;
	next_m_fsm_read_clk <= m_fsm_read_clk;
	next_cnt1 <= cnt1;
	next_m_fsm_read_add <= m_fsm_read_add;
	next_cnt <= cnt;
	next_OFFSET_PTR <= OFFSET_PTR;
	next_cre_lmmi_wdata <= cre_lmmi_wdata;
	next_loop <= loop;
	next_status <= status;
	next_ver_loc <= ver_loc;
	next_spi_cnt <= spi_cnt;
	next_spi_read_add <= spi_read_add;
	next_spi_read_clk <= spi_read_clk;
	next_in_process <= in_process;
	next_sclk <= sclk;
	next_cmdadd <= cmdadd;
	next_sio0_o <= sio0_o;
	next_sio1_o <= sio1_o;
	next_oe_au_out <= oe_au_out;
	next_sio2_o <= sio2_o;
	next_sio3_o <= sio3_o;
	next_temp0 <= temp0;
	next_temp1 <= temp1;
	next_temp2 <= temp2;
	next_temp3 <= temp3;
	next_address <= address;
	next_async_fifo_rd_en_o <= async_fifo_rd_en_o;
	case (CurrState_Sreg0) // synopsys parallel_case full_case
		`set_RO_GP01:
		begin
			next_cre_lmmi_offset <= RO_GP0;
			next_cre_lmmi_request <= 1'b1;
			next_cre_lmmi_wr_rdn <= 1'b1;
			//Poll transaction done  [RO_GP0 == 0xB2]
			NextState_Sreg0 <= `lmmi_clk16_1;
		end
		`set_RO_GP0_0:
		begin
			next_cs <= 1'b1;
			next_au_spi_sel <= 1'b0;
			next_async_fifo_wr_en_o <= 1'b0;
			NextState_Sreg0 <= `S168;
		end
		`set_RO_GP00:
		begin
			// ECDSA algo start from here
			next_cre_lmmi_offset <= RO_GP0;
			next_cre_lmmi_request <= 1'b1;
			next_cre_lmmi_wr_rdn <= 1'b0;
			//Poll if IP is Ready. [RO_GP0 == 0xB0]
			NextState_Sreg0 <= `lmmi_clk11_1;
		end
		`lmmi_clk11_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk11_0;
		end
		`chk_data_len:
		begin
			next_data_len <= data_len - 24'd1;
			next_pt_bit <= 8'd7;
			if (data_len==24'h0)	
				NextState_Sreg0 <= `set_RO_GP0_0;
			else
				NextState_Sreg0 <= `flash_sclk11;
		end
		`lmmi_clk11_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			next_cre_lmmi_request <= 1'b0;
			next_temp <= cre_lmmi_rdata[7:0];
			if (cre_lmmi_ready==1'b1)	
				NextState_Sreg0 <= `chk_B00;
			else
				NextState_Sreg0 <= `lmmi_clk11_1;
		end
		`chk_B00:
		begin
			next_temp <= cre_lmmi_rdata[7:0];
			if (temp==8'hB0)	
				NextState_Sreg0 <= `set_PUB_KEY;
			else
				NextState_Sreg0 <= `set_RO_GP00;
		end
		`PK_dpm_rd_clk0:
		begin
			next_m_fsm_read_clk <= 1'b0;
			next_cre_lmmi_request <= 1'b1;
			next_cre_lmmi_wdata[8*temp +: 8] <= m_fsm_read_data;
			next_cnt1 <= cnt1 + 8'd1;
			next_temp <= temp + 8'd1;
			if (temp==8'h03)	
				NextState_Sreg0 <= `lmmi_clk12_1;
			else
				NextState_Sreg0 <= `PK_set_add;
		end
		`PK_set_add:
		begin
			next_m_fsm_read_add <= cnt1;
			next_cre_lmmi_offset <= OFFSET_PTR;
			NextState_Sreg0 <= `PK_dpm_rd_clk1;
		end
		`RS_next_add:
		begin
			next_cnt <= cnt + 8'h1;
			next_OFFSET_PTR <= OFFSET_PTR + 18'h4;
			if (cnt==8'd15)	
				NextState_Sreg0 <= `set_SHA_MSG2;
			else
				NextState_Sreg0 <= `RS_set_add;
		end
		`set_PUB_KEY:
		begin
			next_OFFSET_PTR <= PUB_KEY;
			next_cre_lmmi_request <= 1'b1;
			next_cre_lmmi_wr_rdn <= 1'b1;
			next_temp <= 8'h0;
			next_cnt1 <= 8'h0;
			// PUB Key
			NextState_Sreg0 <= `PK_set_add;
		end
		`set_RS_sign:
		begin
			next_OFFSET_PTR <= RS_sign;
			next_cre_lmmi_request <= 1'b1;
			next_cre_lmmi_wr_rdn <= 1'b1;
			next_temp <= 8'h0;
			next_cnt1 <= 8'h0;
			// RS sign
			NextState_Sreg0 <= `RS_set_add;
		end
		`PK_next_add:
		begin
			next_OFFSET_PTR <= OFFSET_PTR + 18'h4;
			next_temp <= 8'h00;
			if (cnt==8'd63)	
				NextState_Sreg0 <= `set_RS_sign;
			else
				NextState_Sreg0 <= `PK_set_add;
		end
		`RS_set_add:
		begin
			next_cre_lmmi_offset <= OFFSET_PTR;
			next_cre_lmmi_request <= 1'b1;
			case (loop)
			8'h00 : next_cre_lmmi_wdata <= temp0[32*cnt1 +: 32];
			8'h01 : next_cre_lmmi_wdata <= temp2[32*cnt1 +: 32];
			endcase
			NextState_Sreg0 <= `lmmi_clk13_1;
		end
		`lmmi_clk12_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			next_temp <= 8'h00;
			NextState_Sreg0 <= `lmmi_clk12_0;
		end
		`lmmi_clk12_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			next_cre_lmmi_request <= 1'b0;
			if (cre_lmmi_ready==1'b1)	
				NextState_Sreg0 <= `PK_next_add;
			else
				NextState_Sreg0 <= `lmmi_clk12_1;
		end
		`PK_dpm_rd_clk1:
		begin
			next_m_fsm_read_clk <= 1'b1;
			NextState_Sreg0 <= `PK_dpm_rd_clk0;
		end
		`lmmi_clk13_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			next_cre_lmmi_request <= 1'b0;
			if (cre_lmmi_ready==1'b1)	
				NextState_Sreg0 <= `RS_next_add;
			else
				NextState_Sreg0 <= `lmmi_clk13_1;
		end
		`lmmi_clk13_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk13_0;
		end
		`set_RO_GP0:
		begin
			next_cre_lmmi_offset <= RO_GP0;
			next_cre_lmmi_request <= 1'b1;
			next_cre_lmmi_wr_rdn <= 1'b0;
			//Poll if IP is Ready. [RO_GP0 == 0xB0]
			NextState_Sreg0 <= `lmmi_clk1_1;
		end
		`lmmi_clk0_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			if (cre_lmmi_ready==1'b1)	
				NextState_Sreg0 <= `set_RO_GP0;
			else
				NextState_Sreg0 <= `lmmi_clk0_1;
		end
		`lmmi_clk0_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk0_0;
		end
		`chk_B0:
		begin
			next_temp <= cre_lmmi_rdata[7:0];
			if (temp==8'hB0)	
				NextState_Sreg0 <= `set_DATA_SRC;
			else
				NextState_Sreg0 <= `lmmi_clk0_1;
		end
		`lmmi_clk1_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			next_cre_lmmi_request <= 1'b0;
			next_temp <= cre_lmmi_rdata[7:0];
			if (cre_lmmi_ready==1'b1)	
				NextState_Sreg0 <= `chk_B0;
			else
				NextState_Sreg0 <= `lmmi_clk1_1;
		end
		`lmmi_clk1_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk1_0;
		end
		`lmmi_clk2_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			next_cre_lmmi_request <= 1'b0;
			if (cre_lmmi_ready==1'b1)	
				NextState_Sreg0 <= `set_SHA_INIT_stp1;
			else
				NextState_Sreg0 <= `lmmi_clk2_1;
		end
		`set_DATA_SRC:
		begin
			next_cre_lmmi_offset <= DATA_SRC;
			next_cre_lmmi_wdata <= 32'h00000003;
			// 2 for lmmi 3 for fifo
			next_cre_lmmi_request <= 1'b1;
			next_cre_lmmi_wr_rdn <= 1'b1;
			// [DATA_SRC © 0x02] Sets the SHA
			//data source from the LMMI / AHB-L / APB bus
			NextState_Sreg0 <= `lmmi_clk2_1;
		end
		`lmmi_clk2_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk2_0;
		end
		`set_SHA_INIT_stp1:
		begin
			next_cre_lmmi_offset <= SHA_INIT;
			next_cre_lmmi_wdata <= 32'h00000001;
			next_cre_lmmi_request <= 1'b1;
			next_cre_lmmi_wr_rdn <= 1'b1;
			// SHA_INIT step 1
			NextState_Sreg0 <= `lmmi_clk3_1;
		end
		`lmmi_clk3_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			next_cre_lmmi_request <= 1'b0;
			if (cre_lmmi_ready==1'b1)	
				NextState_Sreg0 <= `set_SHA_INIT_stp2;
			else
				NextState_Sreg0 <= `lmmi_clk3_1;
		end
		`lmmi_clk3_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk3_0;
		end
		`set_SHA_INIT_stp2:
		begin
			next_cre_lmmi_offset <= SHA_INIT;
			next_cre_lmmi_wdata <= 32'h00000000;
			next_cre_lmmi_request <= 1'b1;
			next_cre_lmmi_wr_rdn <= 1'b1;
			// SHA_INIT step 2
			NextState_Sreg0 <= `lmmi_clk4_1;
		end
		`lmmi_clk4_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			next_cre_lmmi_request <= 1'b0;
			if (cre_lmmi_ready==1'b1)	
				NextState_Sreg0 <= `set_RI_CTRL1;
			else
				NextState_Sreg0 <= `lmmi_clk4_1;
		end
		`lmmi_clk4_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk4_0;
		end
		`set_RI_CTRL1:
		begin
			next_cre_lmmi_offset <= RI_CTRL1;
			next_cre_lmmi_wdata <= 32'h00000005;
			next_cre_lmmi_request <= 1'b1;
			next_cre_lmmi_wr_rdn <= 1'b1;
			// RI_CTRL1	 Starts the SHA Engine
			NextState_Sreg0 <= `lmmi_clk5_1;
		end
		`next_bitfile:
		begin
			next_loop <= loop + 8'h01;
			if (loop == 8'h02)	
				NextState_Sreg0 <= `auth_done;
			else
				NextState_Sreg0 <= `lmmi_clk0_1;
		end
		`SHA_MSG2_next_add:
		begin
			next_cnt <= cnt + 8'h1;
			next_OFFSET_PTR <= OFFSET_PTR + 18'h4;
			if (cnt==8'd8)	
				NextState_Sreg0 <= `set_RI_CTRL11;
			else
				NextState_Sreg0 <= `set_SHA_MSG2_add;
		end
		`auth_done:
		begin
			next_status[6] <= 1'b1;
			NextState_Sreg0 <= `ideal_auth;
		end
		`loop_read:
		begin
			next_ver_loc <= ver_loc + 8'd1;
			if (ver_loc==8'h03)	
				NextState_Sreg0 <= `lmmi_clk0_1;
			else
				NextState_Sreg0 <= `select_dpm_add;
		end
		`set_SHA_MSG2:
		begin
			next_OFFSET_PTR <= SHA_MSG2;
			next_cre_lmmi_request <= 1'b1;
			next_cre_lmmi_wr_rdn <= 1'b1;
			next_temp <= 8'h0;
			next_cnt1 <= 8'h0;
			// SHA MSG input to 2nd stage
			NextState_Sreg0 <= `set_SHA_MSG2_add;
		end
		`set_SHA_MSG2_add:
		begin
			next_cre_lmmi_offset <= OFFSET_PTR;
			next_cre_lmmi_request <= 1'b1;
			next_cre_lmmi_wdata <= temp1[32*cnt1 +: 32];
			NextState_Sreg0 <= `lmmi_clk14_1;
		end
		`lmmi_clk14_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk14_0;
		end
		`chk_ML_app:
		begin
			if (temp2[255:0] == temp1[255:0]) begin
			  next_status[1] <= 1'b1;
			end	else begin
			  next_status[1] <= 1'b0;
			end
			NextState_Sreg0 <= `next_bitfile;
		end
		`lmmi_clk14_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			next_cre_lmmi_request <= 1'b0;
			if (cre_lmmi_ready==1'b1)	
				NextState_Sreg0 <= `SHA_MSG2_next_add;
			else
				NextState_Sreg0 <= `lmmi_clk14_1;
		end
		`lmmi_clk5_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			next_cre_lmmi_request <= 1'b0;
			case (loop)
			8'h00 : next_data_len <= temp0[567:544];
			8'h01 : next_data_len <= temp2[567:544];
			endcase
			// 575 74 73 72 71 70 69 68
			next_au_spi_sel <= 1'b1;
			if (cre_lmmi_ready==1'b1)	
				NextState_Sreg0 <= `select_bitfile_add;
			else
				NextState_Sreg0 <= `lmmi_clk5_1;
		end
		`chk_NX_app:
		begin
			if (temp0[255:0] == temp1[255:0]) begin
			  next_status[0] <= 1'b1;
			end	else begin
			  next_status[0] <= 1'b0;
			end
			NextState_Sreg0 <= `next_bitfile;
		end
		`lmmi_clk5_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk5_0;
		end
		`set_RI_CTRL11:
		begin
			next_cre_lmmi_offset <= RI_CTRL1;
			next_cre_lmmi_wdata <= 32'h0000000D;
			next_cre_lmmi_request <= 1'b1;
			next_cre_lmmi_wr_rdn <= 1'b1;
			//Starts the signature verification process.
			NextState_Sreg0 <= `lmmi_clk15_1;
		end
		`lmmi_clk15_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			next_cre_lmmi_request <= 1'b0;
			if (cre_lmmi_ready==1'b1)	
				NextState_Sreg0 <= `set_RO_GP01;
			else
				NextState_Sreg0 <= `lmmi_clk15_1;
		end
		`lmmi_clk15_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk15_0;
		end
		`lmmi_clk16_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			next_cre_lmmi_request <= 1'b0;
			next_temp <= cre_lmmi_rdata[7:0];
			if (cre_lmmi_ready==1'b1)	
				NextState_Sreg0 <= `chk_B2;
			else
				NextState_Sreg0 <= `lmmi_clk16_1;
		end
		`chk_B2:
		begin
			next_temp <= cre_lmmi_rdata[7:0];
			if (temp==8'hB2)	
				NextState_Sreg0 <= `set_R_RECAL_SIGN;
			else
				NextState_Sreg0 <= `lmmi_clk15_1;
		end
		`lmmi_clk9_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk9_0;
		end
		`set_RI_CTRL12:
		begin
			next_cre_lmmi_offset <= RI_CTRL1;
			next_cre_lmmi_wdata <= 32'h00000000;
			next_cre_lmmi_request <= 1'b1;
			next_cre_lmmi_wr_rdn <= 1'b1;
			//Clears the previous transaction,
			//and sets the IP ready for the next.
			NextState_Sreg0 <= `lmmi_clk19_1;
		end
		`S164:
		begin
			next_cnt <= cnt + 8'h1;
			if (cnt==8'h8)	
				NextState_Sreg0 <= `S169;
			else
				NextState_Sreg0 <= `lmmi_clk9_1;
		end
		`lmmi_clk19_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			next_cre_lmmi_request <= 1'b0;
			if (cre_lmmi_ready==1'b1)	
				NextState_Sreg0 <= `chk_bitfile12;
			else
				NextState_Sreg0 <= `lmmi_clk19_1;
		end
		`lmmi_clk19_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk19_0;
		end
		`lmmi_clk8_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk8_0;
		end
		`lmmi_clk8_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			if (async_fifo_empty_i==1'b0)	
				NextState_Sreg0 <= `lmmi_clk9_1;
			else
				NextState_Sreg0 <= `lmmi_clk8_1;
		end
		`set_R_RECAL_SIGN:
		begin
			next_OFFSET_PTR <= R_RECAL_SIGN;
			next_cnt <= 8'h0;
			// R_RECAL_SIGN OUTPUT
			NextState_Sreg0 <= `lmmi_clk17_1;
		end
		`set_R_RECAL_SIGN_add:
		begin
			next_cre_lmmi_offset <= OFFSET_PTR;
			next_cre_lmmi_request <= 1'b1;
			next_cre_lmmi_wr_rdn <= 1'b0;
			NextState_Sreg0 <= `lmmi_clk18_1;
		end
		`lmmi_clk18_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk18_0;
		end
		`lmmi_clk18_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			next_cre_lmmi_request <= 1'b0;
			if ((cre_lmmi_rdata_valid && cre_lmmi_ready)==1'b1)	
				NextState_Sreg0 <= `R_RECAL_SIGN_next_add;
			else
				NextState_Sreg0 <= `lmmi_clk18_1;
		end
		`R_RECAL_SIGN_next_add:
		begin
			next_temp1[cnt*32 +: 32] <= cre_lmmi_rdata;
			next_OFFSET_PTR <= OFFSET_PTR + 18'h4;
			next_cnt <= cnt + 8'h1;
			if (cnt==8'h8)	
				NextState_Sreg0 <= `set_RI_CTRL12;
			else
				NextState_Sreg0 <= `lmmi_clk17_1;
		end
		`lmmi_clk17_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk17_0;
		end
		`lmmi_clk17_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			if (cre_lmmi_ready==1'b1)	
				NextState_Sreg0 <= `set_R_RECAL_SIGN_add;
			else
				NextState_Sreg0 <= `lmmi_clk17_1;
		end
		`chk_bitfile12:
		begin
			next_status[7] <= 1'b1;
			if (loop==8'h01)	
				NextState_Sreg0 <= `chk_ML_app;
			else if (loop==8'h00)	
				NextState_Sreg0 <= `chk_NX_app;
		end
		`lmmi_clk16_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk16_0;
		end
		`ideal_auth:
		begin
			next_cre_lmmi_clk <= 1'b0;
			next_cre_lmmi_request <= 1'b0;
			next_cre_lmmi_wr_rdn <= 1'b0;
			next_cre_lmmi_offset <= 18'h00000;
			next_cre_lmmi_wdata <= 32'h00000000;
			next_spi_cnt <= 9'h0;
			next_spi_read_add <= 9'h0;
			next_spi_read_clk <= 1'b0;
			next_OFFSET_PTR <= 18'h0;
			next_m_fsm_read_add <= 8'h00;
			next_m_fsm_read_clk <= 1'b0;
			next_in_process <= 1'b0;
			next_loop <= 8'h00;
			next_cnt <= 8'h0;
			next_cnt1 <= 8'h0A;
			next_temp <= 8'h00;
			next_ver_loc <= 8'h00;
			next_cs <= 1'b1;
			next_sclk <= 1'b0;
			next_pt_bit <= 8'h00;
			next_cmdadd <= 32'h0;
			next_sio0_o <= 1'b0;
			next_sio1_o <= 1'b0;
			next_oe_au_out <= 4'b1011;   // change this to the req for tri mux
			next_sio2_o <= 1'b0;
			next_sio3_o <= 1'b1;
			next_au_spi_sel <= 1'b0;
			next_temp0 <= 576'h0;
			next_temp1 <= 576'h0;
			next_temp2 <= 576'h0;
			next_temp3 <= 576'h0;
			next_address <= 24'h0;
			next_data_len <= 24'h0;
			next_async_fifo_wr_en_o <= 1'b0;
			 	next_async_fifo_rd_en_o <= 1'b0;
			if (start_process==1'b1)	
				NextState_Sreg0 <= `start_auth;
			else
				NextState_Sreg0 <= `ideal_auth;
		end
		`S168:
		begin
			//OFFSET_PTR <= SHA_OUT;
			next_async_fifo_rd_en_o <= 1'b1;
			next_cnt <= 8'h0;
			// SHA MSG OUTPUT
			NextState_Sreg0 <= `lmmi_clk8_1;
		end
		`S158:
		begin
			next_cre_lmmi_offset <= RI_CTRL1;
			next_cre_lmmi_wdata <= 32'h00000000;
			next_cre_lmmi_request <= 1'b1;
			next_cre_lmmi_wr_rdn <= 1'b1;
			//
			NextState_Sreg0 <= `lmmi_clk10_1;
		end
		`lmmi_clk10_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk10_0;
		end
		`lmmi_clk10_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			next_cre_lmmi_request <= 1'b0;
			if (cre_lmmi_ready==1'b1)	
				NextState_Sreg0 <= `set_RO_GP00;
			else
				NextState_Sreg0 <= `lmmi_clk10_1;
		end
		`select_bitfile_add:
		begin
			next_ver_loc <= 8'd0;
			next_cnt <= 8'd0;
			case (loop)
			8'h00 : next_address <= NX_app_add_for_auth;
			// + data_len ;
			8'h01 : next_address <= ML_app_add_for_auth;
			// + data_len ;
			endcase
			  //temp0[575:544];
			NextState_Sreg0 <= `flash_set_add_cmd;
		end
		`flash_add_bitout:
		begin
			next_sio0_o <= cmdadd[pt_bit];
			NextState_Sreg0 <= `flash_sclk01;
		end
		`flash_sclk10:
		begin
			next_sclk <= 1'b0;
			next_pt_bit <= pt_bit - 8'd1;
			if (pt_bit==8'h00)	
				NextState_Sreg0 <= `set_wdata_SHA_MSG;
			else
				NextState_Sreg0 <= `flash_sclk11;
		end
		`set_wdata_SHA_MSG:
		begin
			if (data_len==24'h0)
			next_cre_lmmi_wdata <= {1'b1,23'h0,temp};
			else
			next_cre_lmmi_wdata <= {24'h0,temp};
			// cre_lmmi_request <=1'b1; // not req for fifo
			next_async_fifo_wr_en_o <= 1'b1;
			//cs <= 1'b1;
			if (async_fifo_full_i==1'b0)	
				NextState_Sreg0 <= `lmmi_clk6_1;
			else
				NextState_Sreg0 <= `set_wdata_SHA_MSG;
		end
		`flash_sclk01:
		begin
			next_sclk <= 1'b1;
			NextState_Sreg0 <= `flash_sclk00;
		end
		`flash_sclk00:
		begin
			next_sclk <= 1'b0;

			next_pt_bit <= pt_bit - 8'd1;
			if (pt_bit==8'h00)	
				NextState_Sreg0 <= `set_SHA_MSG_1;
			else
				NextState_Sreg0 <= `flash_add_bitout;
		end
		`set_SHA_MSG_1:
		begin
			next_pt_bit <= 8'd7;
			// cre_lmmi_wr_rdn <=1'b1; // for fifo it is not in use
			next_cre_lmmi_offset <= SHA_MSG;
			NextState_Sreg0 <= `flash_sclk11;
		end
		`flash_sclk11:
		begin
			next_sclk <= 1'b1;
			NextState_Sreg0 <= `flash_data_bit_in;
		end
		`flash_set_add_cmd:
		begin
			// 	read data from flash
			next_cmdadd <= {8'h03,address};
			next_pt_bit <= 8'd31;
			next_sclk <= 1'b0;
			next_cs <= 1'b0;
			next_cnt <= 8'd0;
			next_temp <= 8'h0;
			NextState_Sreg0 <= `flash_add_bitout;
		end
		`flash_data_bit_in:
		begin
			next_temp[pt_bit] <= sio1_in;
			NextState_Sreg0 <= `flash_sclk10;
		end
		`dpm_rd_clk0:
		begin
			next_spi_read_clk <= 1'b0;
			case (ver_loc)
			    8'h00: next_temp0[8*temp +: 8] <= spi_read_data;
			    8'h01: next_temp1[8*temp +: 8] <= spi_read_data;
			    8'h02: next_temp2[8*temp +: 8] <= spi_read_data;
			    8'h03: next_temp3[8*temp +: 8] <= spi_read_data;
			      // default: temp0[8*temp +: 8] <= spi_read_data;
			endcase
			next_spi_cnt <= spi_cnt + 9'd1;
			next_temp <= temp + 8'd1;
			if (temp==8'd72)	
				NextState_Sreg0 <= `loop_read;
			else
				NextState_Sreg0 <= `set_dpm_add;
		end
		`dpm_rd_clk1:
		begin
			next_spi_read_clk <= 1'b1;
			NextState_Sreg0 <= `dpm_rd_clk0;
		end
		`set_dpm_add:
		begin
			next_spi_read_add <= spi_cnt;
			NextState_Sreg0 <= `dpm_rd_clk1;
		end
		`lmmi_clk6_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			//cre_lmmi_request <=1'b0;
			//// for fifo it not req
			NextState_Sreg0 <= `chk_data_len;
		end
		`lmmi_clk6_1:
		begin
			next_cre_lmmi_clk <= 1'b1;
			NextState_Sreg0 <= `lmmi_clk6_0;
		end
		`select_dpm_add:
		begin
			// fetch the sign+ver+data len
			// from dpm for bitfiles
			case (ver_loc)
			    8'h00:  next_spi_cnt <= 9'h0;
			    8'h01:  next_spi_cnt <= 9'd72;
			    8'h02:  next_spi_cnt <= 9'd145;
			    8'h03:  next_spi_cnt <= 9'd218;
			      // default:
			endcase
			next_temp <= 8'h0;
			NextState_Sreg0 <= `set_dpm_add;
		end
		`reset_auth:
		begin
			next_cre_lmmi_clk <= 1'b0;
			next_cre_lmmi_request <= 1'b0;
			next_cre_lmmi_wr_rdn <= 1'b0;
			next_cre_lmmi_offset <= 18'h00000;
			next_cre_lmmi_wdata <= 32'h00000000;
			next_spi_cnt <= 9'h0;
			next_spi_read_add <= 9'h0;
			next_spi_read_clk <= 1'b0;
			next_OFFSET_PTR <= 18'h0;
			next_m_fsm_read_add <= 8'h00;
			next_m_fsm_read_clk <= 1'b0;
			next_in_process <= 1'b0;
			next_status <= 8'h00;
			next_loop <= 8'h00;
			next_cnt <= 8'h0;
			next_cnt1 <= 8'h0A;
			next_temp <= 8'h00;
			next_ver_loc <= 8'h00;
			next_cs <= 1'b1;
			next_sclk <= 1'b0;
			next_pt_bit <= 8'h00;
			next_cmdadd <= 32'h0;
			next_sio0_o <= 1'b0;
			next_sio1_o <= 1'b0;
			next_oe_au_out <= 4'b1011;   // change this to the req for tri mux
			next_sio2_o <= 1'b0;
			next_sio3_o <= 1'b1;
			next_au_spi_sel <= 1'b0;
			next_temp0 <= 576'h0;
			next_temp1 <= 576'h0;
			next_temp2 <= 576'h0;
			next_temp3 <= 576'h0;
			next_address <= 24'h0;
			next_data_len <= 24'h0;
			next_async_fifo_wr_en_o <= 1'b0;
			 	next_async_fifo_rd_en_o <= 1'b0;
			NextState_Sreg0 <= `ideal_auth;
		end
		`start_auth:
		begin
			next_in_process <= 1'b1;
			next_status <= 8'h00;
			// au_spi_sel <= 1'b1;
			NextState_Sreg0 <= `select_dpm_add;
		end
		`S169:
		begin
			//OFFSET_PTR <= SHA_OUT;
			next_async_fifo_rd_en_o <= 1'b0;
			next_cnt <= 8'h0;
			// SHA MSG OUTPUT
			NextState_Sreg0 <= `S158;
		end
		`lmmi_clk9_0:
		begin
			next_cre_lmmi_clk <= 1'b0;
			next_temp1[cnt*32 +: 32] <= cre_lmmi_rdata;
			// async_fifo_empty_i==1'b0
			// not use for check
			NextState_Sreg0 <= `S164;
		end
	endcase
end

//----------------------------------
// Current State Logic (sequential)
//----------------------------------
always @ (posedge clk or negedge rst)
begin : Sreg0_CurrentState
	if (rst==1'b0)	
		CurrState_Sreg0 <= `reset_auth;
	else
		CurrState_Sreg0 <= NextState_Sreg0;
end

//----------------------------------
// Registered outputs logic
//----------------------------------
always @ (posedge clk or negedge rst)
begin : Sreg0_RegOutput
	if (rst==1'b0)	
	begin
		spi_cnt <= 9'h0;
		OFFSET_PTR <= 18'h0;
		loop <= 8'h00;
		cnt <= 8'h0;
		cnt1 <= 8'h0A;
		temp <= 8'h00;
		ver_loc <= 8'h00;
		pt_bit <= 8'h00;
		cmdadd <= 32'h0;
		temp0 <= 576'h0;
		temp1 <= 576'h0;
		temp2 <= 576'h0;
		temp3 <= 576'h0;
		address <= 24'h0;
		data_len <= 24'h0;
		cre_lmmi_clk <= 1'b0;
		cre_lmmi_request <= 1'b0;
		cre_lmmi_wr_rdn <= 1'b0;
		cre_lmmi_offset <= 18'h00000;
		cs <= 1'b1;
		au_spi_sel <= 1'b0;
		async_fifo_wr_en_o <= 1'b0;
		m_fsm_read_clk <= 1'b0;
		cre_lmmi_wdata <= 32'h00000000;
		m_fsm_read_add <= 8'h00;
		status <= 8'h00;
		spi_read_add <= 9'h0;
		spi_read_clk <= 1'b0;
		in_process <= 1'b0;
		sclk <= 1'b0;
		sio0_o <= 1'b0;
		sio1_o <= 1'b0;
		oe_au_out <= 4'b1011;    // change this to the req for tri mux
		sio2_o <= 1'b0;
		sio3_o <= 1'b1;
		async_fifo_rd_en_o <= 1'b0;
	end
	else 
	begin
		spi_cnt <= next_spi_cnt;
		OFFSET_PTR <= next_OFFSET_PTR;
		loop <= next_loop;
		cnt <= next_cnt;
		cnt1 <= next_cnt1;
		temp <= next_temp;
		ver_loc <= next_ver_loc;
		pt_bit <= next_pt_bit;
		cmdadd <= next_cmdadd;
		temp0 <= next_temp0;
		temp1 <= next_temp1;
		temp2 <= next_temp2;
		temp3 <= next_temp3;
		address <= next_address;
		data_len <= next_data_len;
		cre_lmmi_clk <= next_cre_lmmi_clk;
		cre_lmmi_request <= next_cre_lmmi_request;
		cre_lmmi_wr_rdn <= next_cre_lmmi_wr_rdn;
		cre_lmmi_offset <= next_cre_lmmi_offset;
		cs <= next_cs;
		au_spi_sel <= next_au_spi_sel;
		async_fifo_wr_en_o <= next_async_fifo_wr_en_o;
		m_fsm_read_clk <= next_m_fsm_read_clk;
		cre_lmmi_wdata <= next_cre_lmmi_wdata;
		m_fsm_read_add <= next_m_fsm_read_add;
		status <= next_status;
		spi_read_add <= next_spi_read_add;
		spi_read_clk <= next_spi_read_clk;
		in_process <= next_in_process;
		sclk <= next_sclk;
		sio0_o <= next_sio0_o;
		sio1_o <= next_sio1_o;
		oe_au_out <= next_oe_au_out;
		sio2_o <= next_sio2_o;
		sio3_o <= next_sio3_o;
		async_fifo_rd_en_o <= next_async_fifo_rd_en_o;
	end
end

endmodule