// ----------------------------------------------------------------------------
//   Copyright December 2018, Mobiveil Inc. All rights reserved.
//   Use and distribution of this file is governed by the terms and conditions of a license agreement with
//   Mobiveil Inc.  Mobiveil Inc. makes no representations about the suitability of this file for any purpose.
//   It is provided as is without any express or implied warranty
//   No part of this information may be reproduced, stored in a
//   retrieval system, or transmitted, in any form or by any means
//   without the prior written permission of Mobiveil Inc.
// ----------------------------------------------------------------------------

// The TIMER_CHECKER block generates signals indicating the expiry of following timing
// parameters during a PSRAM transfer and after the completion of a PSRAM
// transfer:
// tRC  expiry
// tCPH expiry
// tRST expiry
// tXHS expiry
// tXDPD expiry
//

`timescale 1ns/1ps
module timer_checker
   (
   mem_clk,
   rst_n,

//From data_shifter
   ce_n_ip,
   spl_instrn_hs_exit_prgrs,
   spl_instrn_dpd_exit_prgrs,
   spl_instrn_glbl_rst_prgrs,

//From CSR           
   tcem_cnt,
   trc_cnt,
   tcph_cnt,
   trst_cnt,
   txhs_cnt,
   txdpd_cnt,

   tcem_time_ignore, 
   txhs_time_ignore, 
   txdpd_time_ignore, 
  
//To wr_tcem_pg_bndry_checker, rd_pg_bndry_checker , data_shifter                                       
   tcem_expired,

// To data shifter
   trc_expired,
   tcph_expired,
   trst_expired,
   txhs_expired,
   txdpd_expired
   );

//--------------I/Os Declaration------------------------

input         mem_clk;
input         rst_n;
input         ce_n_ip;
input         spl_instrn_hs_exit_prgrs;
input         spl_instrn_dpd_exit_prgrs;
input         spl_instrn_glbl_rst_prgrs;
input [11:0]  tcem_cnt;
input [3:0]   trc_cnt;
input [2:0]   tcph_cnt;
input [8:0]   trst_cnt;
input [15:0]  txdpd_cnt; //65536
input [14:0]  txhs_cnt;
input         tcem_time_ignore; 
input         txhs_time_ignore; 
input         txdpd_time_ignore; 
output        tcem_expired; 
output        trc_expired; 
output        tcph_expired; 
output        trst_expired; 
output        txhs_expired; 
output        txdpd_expired; 

//--------------REG Declaration------------------------
reg tcem_expired, next_tcem_expired;
reg trc_expired, next_trc_expired;
reg tcph_expired, next_tcph_expired;
reg trst_expired, next_trst_expired;
reg txhs_expired, next_txhs_expired;
reg txdpd_expired, next_txdpd_expired;

reg [15:0] ce_low_low_cntr, next_ce_low_low_cntr;
reg [8:0] ce_high_cntr, next_ce_high_cntr;

//---------------Synchronous block---------------------

always @ (posedge mem_clk or negedge rst_n)
begin
   if(!rst_n)
   begin
      tcem_expired <= 1'b0;
      trc_expired <= 1'b0;
      tcph_expired  <= 1'b0; 
      trst_expired  <= 1'b0; 
      txhs_expired <= 1'b0;
      txdpd_expired <= 1'b0;
      ce_low_low_cntr <= 16'd0;
      ce_high_cntr    <= 9'd0;
   end
   else
   begin
      tcem_expired  <= next_tcem_expired;
      trc_expired   <= next_trc_expired;
      tcph_expired  <= next_tcph_expired;
      trst_expired  <= next_trst_expired;
      txhs_expired  <= next_txhs_expired;
      txdpd_expired <= next_txdpd_expired;
      ce_low_low_cntr <= next_ce_low_low_cntr;
      ce_high_cntr    <= next_ce_high_cntr;
   end
end

// ---------------------combination block----------------

always @ *
   begin
      next_tcem_expired    = tcem_expired   ;
      next_trc_expired     = trc_expired    ;
      next_tcph_expired    = tcph_expired    ;
      next_trst_expired    = trst_expired    ;
      next_txhs_expired    = txhs_expired   ;
      next_txdpd_expired   = txdpd_expired  ;
      next_ce_low_low_cntr = ce_low_low_cntr;
      next_ce_high_cntr    = ce_high_cntr;

         if((trc_expired && tcph_expired) ||trst_expired || txhs_expired || txdpd_expired) //srare 1
            begin
               next_ce_low_low_cntr = 12'd0;
               next_ce_high_cntr    = 9'd0;
               next_tcem_expired    = 1'b0;
               next_trc_expired     = 1'b0;
               next_tcph_expired    = 1'b0;
               next_trst_expired    = 1'b0;
               next_txhs_expired    = 1'b0;
               next_txdpd_expired   = 1'b0;
            end
         else if (ce_n_ip && (|ce_low_low_cntr)) //state 2 
            begin

               if(spl_instrn_hs_exit_prgrs)
               begin
                  next_txhs_expired    = ce_low_low_cntr==txhs_cnt ? 1'b1  : txhs_expired;
                  next_ce_low_low_cntr = ce_low_low_cntr + 12'd1;
               end
               else if (spl_instrn_dpd_exit_prgrs)
               begin
                  next_txdpd_expired   = ce_low_low_cntr==txdpd_cnt ? 1'b1  : txdpd_expired;
                  next_ce_low_low_cntr = ce_low_low_cntr + 12'd1;
               end
               else
               begin
            // Memory array /Mode register transfer.Trigger the ce_high_cntr during the transfer by montioring the CE# HIGH de-assertion
               next_ce_low_low_cntr = spl_instrn_glbl_rst_prgrs ? ce_low_low_cntr : ce_low_low_cntr + 12'd1;
               next_ce_high_cntr    = tcph_expired || trst_expired ? ce_high_cntr : ce_high_cntr + 9'd1;
               next_tcem_expired    = 1'b0;
               next_trc_expired     = spl_instrn_glbl_rst_prgrs ? trc_expired : (ce_low_low_cntr==trc_cnt ? 1'b1  : trc_expired);
               next_tcph_expired   = spl_instrn_glbl_rst_prgrs ? tcph_expired : (ce_high_cntr==tcph_cnt ? 1'b1 : tcph_expired);
               next_trst_expired   = spl_instrn_glbl_rst_prgrs ? (ce_high_cntr==trst_cnt ? 1'b1 : trst_expired) : trst_expired;
               end
            end
         else if(!ce_n_ip && (!spl_instrn_hs_exit_prgrs) && (!spl_instrn_dpd_exit_prgrs)) //state3 
            // Memory array /Mode register transfer.Trigger the ce_low_low_cntr during the transfer by montioring the CE# low assertion
            begin
               next_ce_low_low_cntr = ce_low_low_cntr + 12'd1;
               next_tcem_expired    = tcem_time_ignore ? 1'b0 : ce_low_low_cntr==tcem_cnt;
               next_trc_expired     = ce_low_low_cntr==trc_cnt ? 1'b1  : trc_expired;
            end
         else if(!ce_n_ip && spl_instrn_hs_exit_prgrs) 
         begin
         // HS instructione exit transfer. Trigger the ce_low_low_cntr during the transfer by montioring the CE# low assertion
            next_ce_low_low_cntr = ce_low_low_cntr + 12'd1;
            next_txhs_expired    = ce_low_low_cntr==txhs_cnt || txhs_time_ignore ? 1'b1  : txhs_expired;
         end
         else if(!ce_n_ip && spl_instrn_dpd_exit_prgrs) 
         begin
         // DPD instructione exit transfer. Trigger the ce_low_low_cntr during the transfer by montioring the CE# low assertion
            next_ce_low_low_cntr = ce_low_low_cntr + 12'd1;
            next_txdpd_expired   = ce_low_low_cntr==txdpd_cnt || txdpd_time_ignore ? 1'b1  : txdpd_expired;
         end
         else
         begin
            next_ce_low_low_cntr = 12'd0;
            next_tcem_expired    = tcem_expired;
            next_trc_expired     = trc_expired;
         end
end

endmodule
