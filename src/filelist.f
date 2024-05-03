+define+FPGA_OR_SIMULATION
+incdir+../../src/CSR/
+incdir+../../src/XSPI_AXI_SLV/
+incdir+../../src/MEM_XFER_INTF/TX_PATH/

//./CSR/csr_defines.vh
//./XSPI_AHB_SLV/xspi_axi_slv.vh

../../src/xspi_cntrl_ip.v
../../src/xspi_cntrl_wrapper.v
../../src/synchronizer_top.v

../../src/CSR/xspi_csr.v
../../src/CSR/xspi_csr_reg_wrapper.v

../../src/XSPI_AHB_SLV/gen_fifo_async.v
../../src/XSPI_AHB_SLV/gen_fifo_async_ctl.v
../../src/XSPI_AHB_SLV/gen_fifo_async_rdctl.v
../../src/XSPI_AHB_SLV/gen_fifo_async_wrctl.v
../../src/XSPI_AHB_SLV/gen_gray2binary.v
../../src/XSPI_AHB_SLV/gen_gray_counter.v
../../src/XSPI_AHB_SLV/gen_mux2.v
../../src/XSPI_AHB_SLV/mem_1w1r_asic.v
../../src/XSPI_AHB_SLV/mem_1w1r_fpga_or_sim.v
../../src/XSPI_AHB_SLV/mem_ahb_mem_xfer_intrf.v
../../src/XSPI_AHB_SLV/ahb_slave_wrdata.v
../../src/XSPI_AHB_SLV/ahb_lite_slave_cntrl.v
../../src/XSPI_AHB_SLV/ahb_slave_wrapper.v

../../src/MAIN_CNTRL/csr_instrn_handler.v
../../src/MAIN_CNTRL/double_flop_sync.v
../../src/MAIN_CNTRL/fb_sync.v
../../src/MAIN_CNTRL/main_cntrl_engine.v
../../src/MAIN_CNTRL/main_controller_wrapper.v
../../src/MAIN_CNTRL/seq_ram_reader.v

../../src/MEM_XFER_INTF/memory_interface_controller.v
../../src/MEM_XFER_INTF/TX_PATH/instrn_handler.v
../../src/MEM_XFER_INTF/TX_PATH/sync_fifo.v
../../src/MEM_XFER_INTF/TX_PATH/mem_1w1r_asic8.v
../../src/MEM_XFER_INTF/TX_PATH/write_engine.v
../../src/MEM_XFER_INTF/RX_PATH/dqs_non_tgl_to_checker.v
../../src/MEM_XFER_INTF/RX_PATH/mem_axi_rd.v
../../src/MEM_XFER_INTF/RX_PATH/mem_mr_xfer_ack_resolver.v
../../src/MEM_XFER_INTF/RX_PATH/rcv_cntrl.v
../../src/MEM_XFER_INTF/RX_PATH/rcv_dqfifo_gcntr_rd.v
../../src/MEM_XFER_INTF/RX_PATH/rcv_dqfifo_gcntr_wr.v
../../src/MEM_XFER_INTF/RX_PATH/rcv_dq_fifo.v
../../src/MEM_XFER_INTF/RX_PATH/rcvif.v
../../src/MEM_XFER_INTF/RX_PATH/rcvr_fsm.v
../../src/MEM_XFER_INTF/RX_PATH/read_dq_input_capture.v
../../src/MEM_XFER_INTF/RX_PATH/read_engine.v
../../src/MEM_XFER_INTF/RX_PATH/rx_path.v
../../src/MEM_XFER_INTF/RX_PATH/uspif_rxdata_blk.v
../../src/MEM_XFER_INTF/RX_PATH/uspif_training_monitor.v

../../src/PHY/clk_gate.v
../../src/PHY/delay_element.v
../../src/PHY/del_n_mux.v
../../src/PHY/dq_out_mux.v
../../src/PHY/dqs_ip_gated.v
../../src/PHY/uspif_delay_chain.v
../../src/PHY/xspi_phy.v

//+define+ASIC_PHY
// /tools/syn_FE_libs/TSMC_CLN28HPM_SC12MC_BASE_SVT_C31_R3P0/arm/tsmc/cln28hpm/sc12mc_base_svt_c31/r3p0/verilog/sc12mc_cln28hpm_base_svt_c31.v
//+define+FPGA_PHY
// /tools/xilinx/2022.1/Vivado/2022.1/data/verilog/src/unisims/LUT1.v
// /tools/xilinx/2022.1/Vivado/2022.1/data/verilog/src/xeclib/BUFGMUX.v
