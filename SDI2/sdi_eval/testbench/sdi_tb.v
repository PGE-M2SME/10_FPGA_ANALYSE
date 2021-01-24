// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2000-2013 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised by
// a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement from
// Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation        TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                      408-826-6000 (other locations)
// Hillsboro, OR 97124                      web  : http://www.latticesemi.com/
// U.S.A                                    email: techsupport@latticesemi.com
// =============================================================================
//                FILE DETAILS
// Project          : Tri-Rate SDI PHY IP
// File             : sdi_tb.v
// Title            : Testbench for the Tri-Rate SDI PHY IP.
// Dependencies     : 1. sdi_config.mem
// Description      : 
// =============================================================================
//                REVISION HISTORY
// Version          : 1.0
// Author(s)        : 
// Mod. Date        : March 14, 2009
// Changes Made     : Initial Creation
// -----------------------------------------------------------------------------
// Version          : 0.2
// Changes Made     : Level-B/VPID modifications
// Author(s)        : BM
// Mod. Date        : July 28, 2009
// =============================================================================

`timescale 1ns / 10fs

// =============================================================================
// defines used in the top level testbench
// =============================================================================
`define  NOLOCK_TIMEOUT    40
`define  WAIT_FOR_RST_INACTIVE (`HALF_PERIOD1*100)
`define  WAIT_FOR_RST_INACTIVE_PCS (`HALF_PERIOD1*30)
`define  BYPASS_RX_4911

`ifdef RTL_SIM
   `define SDF_INP_DELAY                0
`endif
`ifdef SYNNET_SIM
   `define SDF_INP_DELAY                0
`endif
`ifdef PARNET_SIM
   `define SDF_INP_DELAY                0
`endif
`ifdef TIMING_SIM
   `define SDF_INP_DELAY                0
`endif

module sdi_tb ; 

// =============================================================================
// parameter definitions 
// =============================================================================
   localparam ldatawidth       = 20;
   localparam llinenumbits     = 11;

// =============================================================================
// internal signals  declarations 
// =============================================================================
   reg                                         rstn;
   reg                                         rstn1;
   reg                                         sr;
   reg                                         ce;
   reg                                         tst_end_pulse;
   reg                                         clk1;
   reg                                         clk2;
   reg                                         tx_x1;
   reg                                         rx_x1;
   reg   [31:0]                                waitcnt_afterlock;
   reg   [2:0]                                 rx_rate;
   reg                                         rx_cref_clk;
   wire                                        ref_clkp;
   wire                                        ref_clkn;

   reg                                         sd8b_mode;
   reg                                         threeg_hdn_in;
   reg                                         threeg_hdn_int;
   reg                                         hdrate_tx;

   wire [ldatawidth-1:0]                       pd_out;                   
   wire                                        trs_out;
   wire                                        sdi_outp;
   wire                                        sdi_outn;
   reg                                         crci_en;
   reg                                         lni_en;

   wire                                        rx_3g_hdn;
   wire                                        rx_hd_sdn;
   wire                                        rx_lb_lan;
   wire                                        pdo_clk;
   wire                                        field;
   wire                                        vblank;
   wire                                        hblank;
   wire                                        crc_error;
   wire [llinenumbits-1:0]                     ln_out;                   
   wire                                        sdi_inp;
   wire                                        sdi_inn;
   wire                                        lock;
   reg                                         lock_p1;
   reg                                         lock_p2;
   reg                                         lock_p3;
   reg                                         lock_p4;
   reg  [31:0]                                 num_err_data;                   
   reg  [31:0]                                 num_err_sav;                   
   reg  [31:0]                                 num_err_eav;                   
   reg  [31:0]                                 num_err_crc;                   

   wire                                        vidactive;
   wire                                        hd_rate_out;
   wire                                        trs_in;

   reg                                         pattern_group_sel_in;
   reg                                         cbtype_smpte_in;
   reg                                         cbtype_75_in;
   reg                                         pll_test_only_in;
   reg                                         equ_test_only_in;
   reg                                         lb_lan_int;
   reg                                         lb_lan_in;
   reg                                         hd_sdn_in;
   reg [4:0]                                   std_number;
   reg [4:0]                                   std_number_int;
   
   reg [31:0]                                  mem_sdi_config[0:1000];
   reg [31:0]                                  num_runs;
   reg [31:0]                                  num_lines;
   reg [31:0]                                  loop_index;
   reg   [4:0]                                 offset;
   wire                                        test_error;
   wire [llinenumbits-1:0]                     line_number;                   
   reg                                         init_sdiin;

   integer                                     i;
   reg                                         temp_var;                   
   reg   [4:0]                                 pg_std_num; 
   reg   [4:0]                                 format_sel_3g; 
   wire  [1:0]                                 vid_format; 
   wire  [2:0]                                 frame_format; 
   reg   [1:0]                                 vid_format_p1; 
   reg   [2:0]                                 frame_format_p1; 
   reg   [1:0]                                 cb_patho_type;
   wire                                        ldr_en;
   reg                                         rx_lb_lan_p1;
   reg                                         vidactive_p1;
   wire                                        clk_pat_gen;
   reg   [7:0]                                 nolock_cnt;
   wire  [31:0]                                vpid1_in;
   wire  [31:0]                                vpid1_out;
   wire  [31:0]                                vpid2_out;
   reg   [31:0]                                vpid1_out_p1;
   reg   [31:0]                                vpid2_out_p1;
   wire  [10:0]                                ifln;

   reg                                         lb_lan_in_p1;
   reg                                         threeg_hdn_in_p1;
   reg                                         hd_sdn_in_p1;
   reg   [4:0]                                 pg_std_num_p1;
   reg                                         dis_test_err;
   reg                                         tghdn_p1;
   wire                                        tghdn;
   reg                                         trs_saved;

// ========================= Start of code ============================
   `ifdef SD_LDR
      assign ldr_en = ~hd_sdn_in;
   `else
      assign ldr_en = 1'b0;
   `endif
   
   assign lock            = vidactive;
   assign trs_in          = u1_sdi_sample.trs_in_pat;
   assign clk_pat_gen     = u1_sdi_sample.clk_pat_gen;
   assign vpid1_in        = u1_sdi_sample.vpid1_in;
   assign vpid1_out       = u1_sdi_sample.vpid1_out;
   assign vpid2_out       = u1_sdi_sample.vpid2_out;
//   assign ifln            = u1_sdi_sample.u1_sdi_core.u1_multiratetx.ifln1;

// --------- disabling error checking during pg transitions of same rate
   assign tghdn = lb_lan_in|threeg_hdn_in;
   always @(posedge pdo_clk or negedge rstn) begin
      if (rstn == 1'b0) begin
         lb_lan_in_p1     <= 1'b0;
         threeg_hdn_in_p1 <= 1'b0;
         hd_sdn_in_p1     <= 1'b0;
         tghdn_p1         <= 1'b0;
         pg_std_num_p1    <= 'b0;
      end
      else if (ce) begin
         lb_lan_in_p1     <= lb_lan_in;
         threeg_hdn_in_p1 <= threeg_hdn_in;
         hd_sdn_in_p1     <= hd_sdn_in;
         tghdn_p1         <= tghdn;         
         pg_std_num_p1    <= pg_std_num;
      end
   end

   always @(posedge pdo_clk or negedge rstn) begin
      if (rstn==1'b0)
         trs_saved <= 1'b0;
      else if (ce) begin
         if(trs_out==1'b1) begin
            if(dis_test_err==1)
               trs_saved <= 1'b1;
            else
               trs_saved <= 1'b0;
         end
      end
   end

   always @(posedge pdo_clk or negedge rstn) begin
      if (rstn == 1'b0)
         dis_test_err <= 1'b0;
      else if (ce) begin
         if(((pg_std_num_p1!=pg_std_num)||(lb_lan_in_p1!=lb_lan_in)||(threeg_hdn_in_p1!=threeg_hdn_in))&&({tghdn_p1,hd_sdn_in_p1}=={tghdn,hd_sdn_in}))
            dis_test_err <= 1'b1;
         else if((trs_out==1'b1)&&(trs_saved==1'b1))
            dis_test_err <= 1'b0;
      end
   end
   
// =============================================================================
//          UUT Instantiation 
// =============================================================================
   sdi_sample  u1_sdi_sample (
         // Push buttons and switches
         .pb1                (rstn),       // Push button switch for Serdes and logic reset
         .pb2                (rstn1),      // Push button switch for Serdes Rx reset
         .sw1_3              (lb_lan_in),
      `ifdef SD_LDR
         .sw1_4              (ldr_en),     // LDR enable signal
      `endif
         .tg_hdn_in          (threeg_hdn_in),        // SW5-2
         .hd_sdn_in          (hd_sdn_in),  // SW6-1
         .patho_cbn          (pattern_group_sel_in), // SW5-1
         .cb_patho_type      (cb_patho_type), 
         .pg_std_num         (pg_std_num), // 3G or HD/SD format select

         `ifdef CLKEN
            .ce              (ce),         // clock enable
         `endif

         `ifdef SDWIDTH_DYN
            .sd8b_mode       (sd8b_mode),  // indicates if input is in 8bit SD format
         `endif 
         `ifdef CRCINSERT_DYN
            .crci_en         (crci_en),    // enable CRC insertion
         `endif 
         `ifdef LNINSERT_DYN
            .lni_en          (lni_en),     // enable line insertion
         `endif 

         .tx_ref_clkp        (ref_clkp),   // differential positive clock
         .tx_ref_clkn        (ref_clkn),   // differential negative clock
      `ifdef BYPASS_RX_4911
         .rx_x1              (rx_x1),      // 27 Mhz clock from the board for Rx
      `else
         .rx_4915_clkout_se_in (rx_cref_clk), // receiver reference clock
      `endif
         .tx_x1              (tx_x1),       // 27 Mhz clock from the board for Tx

         `ifdef ENABLERX
            .hdinp_ch0       (),            // channel 0 differential output positive data
            .hdinn_ch0       (),            // channel 0 differential output negative data
            .hdinp_ch1       (sdi_inp),     // channel 1 differential output positive data
            .hdinn_ch1       (sdi_inn),     // channel 1 differential output negative data
            .rx_rate         (rx_rate),
         `endif 

         //=====OUTPUTS
         `ifdef ENABLETX
            .hdoutp_ch0      (sdi_outp),     // channel 0 differential output positive data
            .hdoutn_ch0      (sdi_outn),     // channel 0 differential output negative data
            .hdoutp_ch1      (),             // channel 1 differential output positive data
            .hdoutn_ch1      (),             // channel 1 differential output negative data
         `endif
         `ifdef ENABLERX
            .pd_out          (pd_out),       // receiver parralel output data
            .pdo_clk_o       (pdo_clk),
            .vidactive       (vidactive),    // receiver detected valid video data 
            .trs_out         (trs_out),      // EAV/SAV TRS detect
            .rx_3g_hdn       (rx_3g_hdn),    // indicates if output is in 3G or HD format
            .rx_hd_sdn       (rx_hd_sdn),    // indicates if output is in HD or SD format
            .rx_lb_lan       (rx_lb_lan),    // indicates if output is 3G Level-B or not
            .ln1_out         (ln_out),
            .crc_error       (crc_error),
            .vid_format      (vid_format),   // Video format (0-SD, 1-1280x720, 2-1920x1035, 3-1920x1080)
            .frame_format    (frame_format), // Number of fields (0,1,,7 ---> res,24p,25p,30p,50i,60i,50p,60p)
         `endif 
         `ifdef ENABLETX
            .tx_line_number  (line_number),       
         `endif
         .test_error         (test_error),
         .field              (field),
         .vblank             (vblank),
         .hblank             (hblank)
         );

// =============================================================================
//         SERDES loopback connection
// =============================================================================
   assign    sdi_inp = sdi_outp;
   assign    sdi_inn = sdi_outn;

   PUR PUR_INST(.PUR(1'b1));

// =============================================================================
// initialization for the memories from external files
// =============================================================================
   initial begin
      $readmemb("sdi_config.mem",   mem_sdi_config);
   end

   initial begin
      init_sdiin  <=1'b0;
      #2000;
      init_sdiin  <=1'b1;
   end

   initial begin
      crci_en     <= 1'b1;
      lni_en      <= 1'b1;
   end 

   initial begin
      sd8b_mode   <=1'b0;
   end 

   initial begin
      rstn1                        <=1'b1;
      #5  rstn1                    <=1'b0;
      #1000;
      #`WAIT_FOR_RST_INACTIVE rstn1 <=1'b1;
      #1500  rstn1                  <=1'b1;
   end
   initial begin
      rstn                         <=1'b1;
      #5  rstn                     <=1'b0;
      #`WAIT_FOR_RST_INACTIVE rstn <=1'b1;
      #500  rstn                   <=1'b1;
   end
   
// ------------ Clocks   
   initial begin
      clk1                <=1'b1;  // Tx clock
      clk2                <=1'b1;  // Rx clock
      tx_x1               <=1'b1;  // 27 MHz Tx board clock
      rx_x1               <=1'b1;  // 27 MHz Rx board clock
   end

   always  #`HALF_PERIOD1    clk1 <= ~clk1;
   always  #`HALF_PERIOD2    clk2 <= ~clk2;
   always  #`HALF_PERIOD_SD  tx_x1 <= ~tx_x1;
   always  #`HALF_PERIOD_SD  rx_x1 <= ~rx_x1;

   assign ref_clkp        = clk1;
   assign ref_clkn        = ~clk1;

   always @(*) begin 
      rx_cref_clk = clk2;
   end

// =============================================================================
// initialization for the signals 
// =============================================================================
   initial begin
      ce               = 1'b1;
      sr               = 1'b0;
   end

// =============================================================================
// signal monitors                                             
// =============================================================================

   always @(negedge rstn) begin // indication of the reset assertion and de-assertion to output
      $display ("RESET ASSERTED                  time %dns",$time);
      wait ( rstn)
      $display ("RESET DE-ASSERTED               time %dns",$time);
      $display ("****************************************************************************");
      $display ("****************************************************************************");
      `ifdef CORE_SIM
         $display ("** SIMULATION LEVEL--------------------------->CORE                       **");
      `endif
      `ifdef TOP_SIM
         $display ("** SIMULATION LEVEL--------------------------->TOP                        **");
      `endif
      `ifdef RTL_SIM
         $display ("** SIMULATION TYPE---------------------------->RTL                        **");
      `endif
      `ifdef SYNNET_SIM
         $display ("** SIMULATION TYPE---------------------------->SYNTHESIS GATE LEVEL       **");
      `endif
      `ifdef PARNET_SIM
         $display ("** SIMULATION TYPE---------------------------->PNR GATE LEVEL WITHOUT SDF **");
      `endif
      `ifdef TIMING_SIM
         $display ("** SIMULATION TYPE---------------------------->PNR GATE LEVEL WITH SDF    **");
      `endif
      $display ("****************************************************************************");
      $display ("****************************************************************************");
   end 

// ------------ Tx Display
/*   always @(posedge trs_in) begin
      if(trs_in==1'b1) begin
         case({lb_lan_in,threeg_hdn_in,hd_sdn_in})
         3'b000: $display("---- Tx >>>> SD   :    std- %d : LN- %d : Ifln: %d : VPID [%2x %2x %2x %2x] : %d ns",std_number[0],line_number,ifln,vpid1_in[7:0],vpid1_in[15:8],vpid1_in[23:16],vpid1_in[31:24],$time);
         3'b001: $display("---- Tx >>>> HD   :    std- %d : LN- %d : Ifln: %d : VPID [%2x %2x %2x %2x] : %d ns",std_number[2:0],line_number,ifln,vpid1_in[7:0],vpid1_in[15:8],vpid1_in[23:16],vpid1_in[31:24],$time);
         3'b011: $display("---- Tx >>>> 3G-a : 3G std- %d : LN- %d : Ifln: %d : VPID [%2x %2x %2x %2x] : %d ns",std_number[4:0],line_number,ifln,vpid1_in[7:0],vpid1_in[15:8],vpid1_in[23:16],vpid1_in[31:24],$time);
         3'b101: $display("---- Tx >>>> 3G-b : DS std- %d : LN- %d : Ifln: %d : VPID [%2x %2x %2x %2x] : %d ns",std_number[2:0],line_number,ifln,vpid1_in[7:0],vpid1_in[15:8],vpid1_in[23:16],vpid1_in[31:24],$time);
         3'b111: $display("---- Tx >>>> 3G-b : DL std- %d : LN- %d : Ifln: %d : VPID [%2x %2x %2x %2x] : %d ns",std_number[4:0],line_number,ifln,vpid1_in[7:0],vpid1_in[15:8],vpid1_in[23:16],vpid1_in[31:24],$time);
         default: $display("---- Tx >>>> Invalid rate and format : %d ns",$time);
         endcase
      end
   end */

   always @(posedge trs_in) begin
      if(trs_in==1'b1) begin
         case({lb_lan_in,threeg_hdn_in,hd_sdn_in})
         3'b000: $display("---- Tx >>>> SD   :    std- %2d : LN- %d : VPID [%2x %2x %2x %2x] : %d ns",std_number[0],line_number,vpid1_in[7:0],vpid1_in[15:8],vpid1_in[23:16],vpid1_in[31:24],$time);
         3'b001: $display("---- Tx >>>> HD   :    std- %2d : LN- %d : VPID [%2x %2x %2x %2x] : %d ns",std_number[3:0],line_number,vpid1_in[7:0],vpid1_in[15:8],vpid1_in[23:16],vpid1_in[31:24],$time);
         3'b011: $display("---- Tx >>>> 3G-a : 3G std- %2d : LN- %d : VPID [%2x %2x %2x %2x] : %d ns",std_number[4:0],line_number,vpid1_in[7:0],vpid1_in[15:8],vpid1_in[23:16],vpid1_in[31:24],$time);
         3'b101: $display("---- Tx >>>> 3G-b : DS std- %2d : LN- %d : VPID [%2x %2x %2x %2x] : %d ns",std_number[3:0],line_number,vpid1_in[7:0],vpid1_in[15:8],vpid1_in[23:16],vpid1_in[31:24],$time);
         3'b111: $display("---- Tx >>>> 3G-b : DL std- %2d : LN- %d : VPID [%2x %2x %2x %2x] : %d ns",std_number[4:0],line_number,vpid1_in[7:0],vpid1_in[15:8],vpid1_in[23:16],vpid1_in[31:24],$time);
         default: $display("---- Tx >>>> Invalid rate and format : %d ns",$time);
         endcase
      end
   end

// ------------ Rx Display
   always @(posedge pdo_clk or negedge rstn) begin
      if ( rstn == 1'b0) begin
         vid_format_p1   <= 'b0;
         frame_format_p1 <= 'b0;
         rx_lb_lan_p1    <= 1'b0;
         vidactive_p1    <= 1'b0;
         vpid1_out_p1    <= 'b0;
         vpid1_out_p1    <= 'b0;
      end
      else if (ce) begin
         vid_format_p1   <= vid_format;
         frame_format_p1 <= frame_format;
         rx_lb_lan_p1    <= rx_lb_lan;
         vidactive_p1    <= vidactive;
         vpid1_out_p1    <= vpid1_out;
         vpid2_out_p1    <= vpid2_out;
      end
   end

   always @(*) begin
      if ((vidactive==1'b1)&&(vpid1_out!=vpid1_out_p1)) begin
//      if (vpid1_out!=vpid1_out_p1) begin
         $display ("-------------------------------------------------------------------");
         $display ("<<<< Rx ------------ Received VPID1 [1 2 3 4]: %2x %2x %2x %2x",vpid1_out[7:0],vpid1_out[15:8],vpid1_out[23:16],vpid1_out[31:24]);
         $display ("-------------------------------------------------------------------");
      end
   end
   always @(*) begin
      if ((vidactive==1'b1)&&(vpid2_out!=vpid2_out_p1)) begin
//      if (vpid2_out!=vpid2_out_p1) begin
         $display ("-------------------------------------------------------------------");
         $display ("<<<< Rx ------------ Received VPID2 [1 2 3 4]: %2x %2x %2x %2x",vpid2_out[7:0],vpid2_out[15:8],vpid2_out[23:16],vpid2_out[31:24]);
         $display ("-------------------------------------------------------------------");
      end
   end

   always @(*) begin
      if ((vidactive==1'b1)&&((vid_format!=vid_format_p1)||(frame_format!=frame_format_p1)||(rx_lb_lan!=rx_lb_lan_p1)||(vidactive!=vidactive_p1))) begin
         if(frame_format!=3'b000)
                             $display ("============================================================================");
         casex({rx_lb_lan,rx_3g_hdn,rx_hd_sdn,vid_format,frame_format})
            8'bx_x_x_xx_000: ;  // check this situation
            8'bx_0_0_00_100: $display ("<<<< Rx ============ Locked to SD,  625, 50i (PG- 1) =======================");
            8'bx_0_0_00_101: $display ("<<<< Rx ============ Locked to SD,  525, 60i (PG- 0) =======================");

            8'bx_0_1_01_001: $display ("<<<< Rx ============ Locked to HD,  720, 24p (PG- x) =======================");
            8'bx_0_1_01_010: $display ("<<<< Rx ============ Locked to HD,  720, 25p (PG- x) =======================");
            8'bx_0_1_01_011: $display ("<<<< Rx ============ Locked to HD,  720, 30p (PG- x) =======================");
            8'bx_0_1_01_110: $display ("<<<< Rx ============ Locked to HD,  720, 50p (PG- x) =======================");
            8'bx_0_1_01_111: $display ("<<<< Rx ============ Locked to HD,  720, 60p (PG- 7) =======================");
            8'bx_0_1_10_101: $display ("<<<< Rx ============ Locked to HD, 1035, 60i (PG- 0) =======================");
            8'bx_0_1_10_011: $display ("<<<< Rx ============ Locked to HD, 1035, 30p (must be 60i,PG-1) ============");
            8'bx_0_1_11_001: $display ("<<<< Rx ============ Locked to HD, 1080, 24p (PG- 6) =======================");
            8'bx_0_1_11_010: $display ("<<<< Rx ============ Locked to HD, 1080, 25p (PG- 4) =======================");
            8'bx_0_1_11_011: $display ("<<<< Rx ============ Locked to HD, 1080, 30p (PG- 2) =======================");
            8'bx_0_1_11_100: $display ("<<<< Rx ============ Locked to HD, 1080, 50i (PG- 1 or 5) ==================");
            8'bx_0_1_11_101: $display ("<<<< Rx ============ Locked to HD, 1080, 60i (PG- 3) =======================");

            8'b0_1_1_01_001: $display ("<<<< Rx ============ Locked to 3G-a,  720, 24p (PG- 9) =====================");
            8'b0_1_1_01_010: $display ("<<<< Rx ============ Locked to 3G-a,  720, 25p (PG- 7) =====================");
            8'b0_1_1_01_011: $display ("<<<< Rx ============ Locked to 3G-a,  720, 30p (PG- 5) =====================");
            8'b0_1_1_01_110: $display ("<<<< Rx ============ Locked to 3G-a,  720, 50p (PG- 3) =====================");
            8'b0_1_1_01_111: $display ("<<<< Rx ============ Locked to 3G-a,  720, 60p (PG- 2) =====================");
            8'b0_1_1_11_001: $display ("<<<< Rx ============ Locked to 3G-a, 1080, 24p (PG- 8/ 14/ 19) =============");
            8'b0_1_1_11_010: $display ("<<<< Rx ============ Locked to 3G-a, 1080, 25p (PG- 6/ 13/ 18) =============");
            8'b0_1_1_11_011: $display ("<<<< Rx ============ Locked to 3G-a, 1080, 30p (PG- 4/ 12/ 17) =============");
            8'b0_1_1_11_100: $display ("<<<< Rx ============ Locked to 3G-a, 1080, 50i (PG- 11/ 16/ 21) ============");
            8'b0_1_1_11_101: $display ("<<<< Rx ============ Locked to 3G-a, 1080, 60i (PG- 10/ 15/ 20) ============");
            8'b0_1_1_11_110: $display ("<<<< Rx ============ Locked to 3G-a, 1080, 50p (PG- 1) =====================");
            8'b0_1_1_11_111: $display ("<<<< Rx ============ Locked to 3G-a, 1080, 60p (PG- 0) =====================");
            
            8'b1_1_1_01_001: $display ("<<<< Rx ============ Locked to 3G-b,  720, 24p (PG- x) =====================");
            8'b1_1_1_01_010: $display ("<<<< Rx ============ Locked to 3G-b,  720, 25p (PG- x) =====================");
            8'b1_1_1_01_011: $display ("<<<< Rx ============ Locked to 3G-b,  720, 30p (PG- x) =====================");
            8'b1_1_1_01_110: $display ("<<<< Rx ============ Locked to 3G-b,  720, 50p (PG- x) =====================");
            8'b1_1_1_01_111: $display ("<<<< Rx ============ Locked to 3G-b,  720, 60p (DS- 7) =====================");
            8'b1_1_1_10_101: $display ("<<<< Rx ============ Locked to 3G-b, 1035, 60i (DS- 0) =====================");
            8'b1_1_1_11_001: $display ("<<<< Rx ============ Locked to 3G-b, 1080, 24p (DS- 6 or DL- 8/ 14/ 19) ====");
            8'b1_1_1_11_010: $display ("<<<< Rx ============ Locked to 3G-b, 1080, 25p (DS- 4 or DL- 6/ 13/ 18) ====");
            8'b1_1_1_11_011: $display ("<<<< Rx ============ Locked to 3G-b, 1080, 30p (DS- 2 or DL- 4/ 12/ 17) ====");
            8'b1_1_1_11_100: $display ("<<<< Rx ============ Locked to 3G-b, 1080, 50i (DS- 1/5 or DL- 11/ 16/ 21) =");
            8'b1_1_1_11_101: $display ("<<<< Rx ============ Locked to 3G-b, 1080, 60i (DS- 3 or DL- 10/ 15/ 20) ===");
            8'b1_1_1_11_110: $display ("<<<< Rx ============ Locked to 3G-b, 1080, 50p (DL- 1) =====================");
            8'b1_1_1_11_111: $display ("<<<< Rx ============ Locked to 3G-b, 1080, 60p (DL- 0) =====================");
            
            default:         $display ("<<<< Rx ============ Locked to Custom or Unknown Standard  =================");
         endcase
         if(frame_format!=3'b000)
                             $display ("============================================================================");
//         $display ("Transmitted VPID [4 3 2 1]: %2x %2x %2x %2x", vpid1_in[31:24],vpid1_in[23:16],vpid1_in[15:8],vpid1_in[7:0]);
//         $display ("Received    VPID [1 2 3 4]: %2x %2x %2x %2x",vpid1_out[7:0],vpid1_out[15:8],vpid1_out[23:16],vpid1_out[31:24]);
      end
   end 

// --------- Delaying vidactive signal
   always @( posedge pdo_clk or  negedge rstn ) begin
      if ( rstn == 1'b0) begin
         lock_p1 <= 1'b0;
         lock_p2 <= 1'b0;
         lock_p3 <= 1'b0;
         lock_p4 <= 1'b0;
      end
      else if (ce) begin
         lock_p1 <= lock;
         lock_p2 <= lock_p1;
         lock_p3 <= lock_p2;
         lock_p4 <= lock_p3;
      end
   end

   always @(negedge lock_p4) begin
      if((vidactive | lock_p1 | lock_p2 | lock_p3)==1'b0)
      $display ("<<<< Rx ============ UNLOCKED ======== %dns",$time);
   end 

// =============================================================================
// dump file generation 
// =============================================================================
`ifdef VCD
   initial begin
        $recordfile("sdi_tb.trn");
        $recordvars;
        #100;
   end
`endif

// --------- Final test result messages
   always @( posedge pdo_clk or  negedge rstn ) begin
      if ( rstn == 1'b0) begin
         num_err_crc  <= 'b0;
      end
      else if (ce) begin
         if (lock) begin
            if (crc_error) begin
               num_err_crc <= num_err_crc + 1'b1;
               $display ("$$$$$$$$ CRC TEST ERROR at time %d $$$$$$$$$$ ", $time);
            end
         end
      end
   end

   always  @(posedge tst_end_pulse  )begin
      $display ("Test End Pulse Goes High at %d",$time);
      if ( num_err_crc == 0 ) begin
         $display ("**************************************************************");
         $display ("******************* CRC TEST PASSED **************************");
         $display ("**************************************************************");
      end
      else begin
         $display ("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ ");
         $display ("$$$$$$$$$$$$$$$$$$$  CRC TEST FAILED  $$$$$$$$$$$$$$$$$$$$$$$$ ");
         $display ("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ ");
         $display ("At simulation time %d   NUM_ERRORS FOR CRC are  %d",$time,num_err_crc);
      end

      if ( num_err_data == 0 ) begin
         $display ("**************************************************************");
         $display ("****************  TX to RX DATA TEST PASSED  *****************");
         $display ("**************************************************************");
      end
      else begin
         $display ("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ ");
         $display ("$$$$$$$$$$$$$$$$$  TX to RX DATA TEST FAILED  $$$$$$$$$$$$$$$$ ");
         $display ("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ ");
         $display ("At simulation time %d   NUM_ERRORS FOR TX to RX are  %d",$time,num_err_data);
      end

      #100;
      $finish;
   end

// --------- logic to wait for the specified number of lines after lock 
   always @( posedge pdo_clk or  negedge rstn ) begin
      if ( rstn == 1'b0) begin
         waitcnt_afterlock <= 'b0;
      end
      else if (ce) begin
         if (((lock)&&(!lock_p1))||(!lock)||(waitcnt_afterlock==(num_lines<<1)))
            waitcnt_afterlock <= 'b0;
         else if ((lock)&&(trs_out))
            waitcnt_afterlock <= waitcnt_afterlock + 1'b1 ;
      end
   end

// --------- logic to wait for the specified number of lines after lock 
   always @( posedge pdo_clk or  negedge rstn ) begin
      if ( rstn == 1'b0) begin
         num_err_data <= 'b0;
      end
      else if (ce) begin
//         if (test_error) begin
         if (test_error && ~dis_test_err) begin
            num_err_data <= num_err_data + 1'b1;
            $display ("$$$$$$$$ TX to RX  TEST ERROR at time %d $$$$$$$$$$ ", $time);
         end
      end
   end

// --------- Test Loop
   initial begin
      rx_rate = 3'b111;
      format_sel_3g = 5'd0;
      pg_std_num = 5'd0;
      inputs_init;
      loop_index = 1;
      #1;
      num_runs = mem_sdi_config[0];
      #10;
   
      for (i=0;i<num_runs;i=i+1) begin
         test_case;
         loop_index = loop_index + 3;
      end 

      test_end;
      $finish;
   end

// --------- Task for one run
   task test_case;
      begin
         {lb_lan_int,threeg_hdn_in,hd_sdn_in} = mem_sdi_config[loop_index+0];
      `ifdef ENABLE_LEVELB
         lb_lan_in = lb_lan_int;
      `else
         lb_lan_in = 1'b0;
      `endif
         std_number_int  = mem_sdi_config[loop_index+1];
         if(lb_lan_in&threeg_hdn_in&hd_sdn_in) begin
            if(std_number_int==2)
               std_number   = 0;
            else if(std_number_int==3)
               std_number   = 1;
            else if(std_number_int==5)
               std_number   = 4;
            else if(std_number_int==7)
               std_number   = 6;
            else if(std_number_int==9)
               std_number   = 8;
            else
               std_number   = std_number_int;
         end
         else
            std_number   = std_number_int;
         num_lines     = mem_sdi_config[loop_index+2];
         wait (waitcnt_afterlock==(num_lines<<1)) ;
         #100;
      end
   endtask

// --------- standard number mapping from TB to SD Patgen conventions
/*
   always @(*) begin
   casex ({lb_lan_in,threeg_hdn_in,hd_sdn_in,std_number})
      8'b000_xxxx0 : pg_std_num = 5'b00000;   // 525  60i     125M
      8'b000_xxxx1 : pg_std_num = 5'b00001;   // 625  50i     125M
      8'b001_xx000 : pg_std_num = 5'b01000;   // 1035 59.94i  260M
      8'b001_xx001 : pg_std_num = 5'b01001;   // 1080 50i     295M
      8'b001_xx010 : pg_std_num = 5'b01010;   // 1080 30p     274M
      8'b001_xx011 : pg_std_num = 5'b01011;   // 1080 60i     274M
      8'b001_xx100 : pg_std_num = 5'b01100;   // 1080 25p     274M
      8'b001_xx101 : pg_std_num = 5'b01101;   // 1080 50i     274M
      8'b001_xx110 : pg_std_num = 5'b01110;   // 1080 24p     274M
      8'b001_xx111 : pg_std_num = 5'b01111;   // 720  60p     296M
      default : pg_std_num = std_number; // For 3G standards, pg number is same as tb number
   endcase
   end
*/
   always @(*) begin
   casex ({lb_lan_in,threeg_hdn_in,hd_sdn_in})
      3'b000  : pg_std_num = {4'b0000,std_number[0]}; // SD
      3'b001  : pg_std_num = {1'b0,std_number[3:0]};  // HD
      default : pg_std_num = std_number;              // 3G (pg number is same as tb number)
   endcase
   end

// --------- input initialize task
   task inputs_init;
      begin
         pattern_group_sel_in = 1'b0;
         std_number           = 5'd0;
         std_number_int       = 5'd0;
         lb_lan_int           = 1'b0;
         hd_sdn_in            = 1'b0;
         cbtype_smpte_in      = 1'b1;
         cbtype_75_in         = 1'b0;
         pll_test_only_in     = 1'b0;
         equ_test_only_in     = 1'b0;
         cb_patho_type        = 2'b10;
      `ifdef ENABLE_LEVELB
         lb_lan_in            = lb_lan_int;
      `else
         lb_lan_in            = 1'b0;
      `endif
      end
   endtask

   always @(*) begin
      if(pattern_group_sel_in==0)
         cb_patho_type={cbtype_smpte_in,cbtype_75_in};
      else
         cb_patho_type={pll_test_only_in,equ_test_only_in};
   end

// --------- test end task
   task test_end;
      begin
         @(posedge pdo_clk) begin
            tst_end_pulse <= 1'b0; 
         end
         @(posedge pdo_clk) begin
            tst_end_pulse <= 1'b1; 
         end
         @(posedge pdo_clk) begin
            tst_end_pulse <= 1'b0; 
         end
      end
   endtask

// ------------ time-out exit in case of indefinite loops
   always @(posedge clk_pat_gen or  negedge rstn) begin
      if (rstn == 1'b0) begin
         nolock_cnt <= 'b0;
      end
      else if (ce) begin
         if(lock==1'b1)
            nolock_cnt <= 'b0;
         else if (trs_in==1'b1)
            nolock_cnt <= nolock_cnt +1;
         if(nolock_cnt>`NOLOCK_TIMEOUT) begin
            $display ("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ ");
            $display ("$$$$$$$$$$$$$$  No-Lock Time-out, exiting... $$$$$$$$$$$$$$$$$ ");
            $display ("$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ ");
            $finish;
         end
      end
   end

endmodule