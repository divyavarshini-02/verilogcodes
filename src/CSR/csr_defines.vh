


// sequence RAM
`define CSR_DPRAM_ADDR_WIDTH     10

// CSR - WRITE AND READ FIFO
//CSR_REGISTERS
`define SEQ_RAM_KEY                      10'h000  // 12'h800
`define SEQ_RAM_ACCESS                   10'h004  // 12'h804
`define SEQ_ID_SEL_REG                   10'h008  // 12'h808                                                     
`define DEF_SEQ1_DWORD1                  10'h00C  // 12'h80C
`define DEF_SEQ1_DWORD2                  10'h010  // 12'h810
`define DEF_SEQ1_DWORD3                  10'h014  // 12'h814
`define DEF_SEQ1_DWORD4                  10'h018  // 12'h818
`define DEF_SEQ2_DWORD1                  10'h01C  // 12'h81C
`define DEF_SEQ2_DWORD2                  10'h020  // 12'h820
`define DEF_SEQ2_DWORD3                  10'h024  // 12'h824
`define DEF_SEQ2_DWORD4                  10'h028  // 12'h828
`define DATA_LEARNING_PATTERN_CONFIG     10'h02C  // 12'h82C
`define DUMMY_CYC_CONFIG                 10'h030  // 12'h830
`define TIMING_CONFIG_REG                10'h034  // 12'h834
`define FLASH_MODE_XFER_SEL              10'h038  // 12'h838
`define WR_RD_DATA_REG_1                 10'h03C  // 12'h83C
`define WR_RD_DATA_REG_2                 10'h040  // 12'h840
`define CMD_DATA_XFER_REG                10'h044  // 12'h844
`define CSR_RD_CONFIG_REG_1              10'h048  // 12'h848
`define CSR_RD_CONFIG_REG_2              10'h04C  // 12'h848
`define AUTO_STATUS_REG_RD_CONFIG_1      10'h050  // 12'h84C     
`define AUTO_STATUS_REG_RD_CONFIG_2      10'h054  // 12'h850     
`define AUTO_STATUS_REG_RD_CONFIG_3      10'h058  // 12'h850     
`define AUTO_STATUS_REG_RD_CONFIG_4      10'h05C  // 12'h850     
`define XSPI_AUTO_INITIATE_WRITE_EN_REG  10'h060  // 12'h854
`define XSPI_AUTO_INITIATE_WRITE_DIS_REG 10'h064  // 12'h85C
`define XSPI_CSR_INTR_EN_REG             10'h068  // 12'h860 
`define XSPI_CSR_STATUS_REG              10'h06C  // 12'h864 
`define XSPI_MEM_INTR_EN_REG             10'h070  // 12'h868
`define XSPI_MEM_STATUS_REG              10'h074  // 12'h86C
`define XSPI_MEM_UPPER_BOUND_ADDR_0      10'h078  // 12'h870
`define XSPI_MEM_LOWER_BOUND_ADDR_0      10'h07C  // 12'h874
`define XSPI_WRITE_EN_SEQ_REG_1          10'h080  // 12'h878 
`define XSPI_WRITE_EN_SEQ_REG_2          10'h084  // 12'h87C     
`define XSPI_WRITE_DIS_SEQ_REG_1         10'h088  // 12'h880     
`define XSPI_WRITE_DIS_SEQ_REG_2         10'h08C  // 12'h884 
 
//DEFAULT sequence RAM KEY VALUE
`define SEQ_RAM_KEY_VALUE            32'hAABBCCDD

`define MEM_AXI_DATA_WIDTH  32
`define FPGA_OR_SIMULATION 
//`define ASIC_SYNTH 

