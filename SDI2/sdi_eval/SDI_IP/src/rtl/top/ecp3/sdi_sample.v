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
// Lattice Semiconductor Corporation       TEL  : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                            408-826-6000 (other locations)
// Hillsboro, OR 97124                     web  : http://www.latticesemi.com/
// U.S.A                                   email: techsupport@latticesemi.com
// =============================================================================
//                         FILE DETAILS         
// Project               : Tri-Rate SDI PHY IP
// File                  : sdi_sample.v
// Title                 : Top-level wrapper for Tri-Rate SDI PHY IP
// Dependencies          : 1.
//                       : 2.
// Description           : The top level file intantiate the SDI IP along with 
//                         Serdes/PCS and test logic. This is example top level
//                         for the full chip level to be used for Video Demo. 
//                         This file is used as top for ispLEVER as well as in
//                         the testbench for top level simulations.
// =============================================================================
//                        REVISION HISTORY
// Version               : 0.1
// Changes Made          : Initial Creation
// Author(s)             : BM
// Mod. Date             : March 14, 2009
// =============================================================================
// Version               : 0.2
// Changes Made          : Level-B/VPID modifications
// Author(s)             : BM
// Mod. Date             : July 28, 2009
// =============================================================================

`timescale 1ns/1ns

// ======================= Loopback and Passthrough ============================
// Loopback: FPGA Pat gen -> IP Tx -> SERDES Tx -> BNC output (Tx#0)
//           BNC input (Rx#1) -> SERDES Rx -> IP Rx -> LCD/LED status display
//
// Passthru: Tek Patgen -> BNC input (Rx#1) -> SERDES Rx -> IP Rx -> FIFO ->
//           IP Tx -> SERDES Tx -> BNC output (Tx#0) -> Tek monitor
//
// This top-level wrapper supports both loopback and passthrough modes
// For passthru, the line `define PASSTHRU_ENABLE must be present.
// For loopback, the line `define PASSTHRU_ENABLE must be removed or commented
// Similarly, a couple of lines need to be commented or uncommented in 
//    MachXO3.v file and the JEDEC file regenerated.
// =============================================================================

`ifndef RUN_SIMULATE
   `define RUN_SYN 
`endif

`ifdef RUN_SYN
   `include "passthru.v"
   `include "sdi_params.v"
   `define SCHEME1          // for LDR clocking
`endif 

`ifdef RUN_SIMULATE
   `define DPRAM_SELFCHK_TST
`endif

// Comment/uncomment the following depending on jitter performance on the board
//    Bypassing Rx 4911 and using Tx 4911 results in best jitter on the test setup

`define  BYPASS_RX_4911
`define  BYPASS_TX_4911

module sdi_sample (
   //=====INPUTS

   `ifdef RUN_SYN
      pb3,                 // Push button to reset display errors
      pb4,                 // Push button to change display screen
   `endif
   // Switch controls
   `ifndef PASSTHRU_ENABLE
      `ifdef SD_LDR
         sw1_4,            // LDR enable signal (0- from SERDES, 1-from soft logic)
      `endif
      sw1_3,               // Level B or non-level-B (1- Level-B, 0- Not level-B)
      tg_hdn_in,           // {tg_hdn_in, hd_sdn_in}:
      hd_sdn_in,           //    00 - SD, 01 - HD, 10 - 3G-B, 11 - 3G-A
      patho_cbn,           // Pathological or color bar (pattern_group_sel_in)
      cb_patho_type,       // type of color bar or patho pattern
      pg_std_num,          // Pattern number for HD/SD or 3G patterns
   `endif
   `ifdef CLKEN
      ce,                  // clock enable
   `endif

   //===== transmitter input signals
   `ifdef SDWIDTH_DYN
      sd8b_mode,           // if the data is in 8 bit SD video format
   `endif
   `ifdef CRCINSERT_DYN
      crci_en,             // enable CRC insertion
   `endif
   `ifdef LNINSERT_DYN
      lni_en,              // enable line insertion
   `endif

   //===== reference clock  
      tx_ref_clkp,         // transmitter differential positive clock
      tx_ref_clkn,         // transmitter differential negative clock
   `ifdef BYPASS_RX_4911
      rx_x1,               // 27 Mhz clock from the board for Rx
   `else
      rx_4915_clkout_se_in,// FPGA reference clock from Rx 4911/4915
   `endif
      tx_x1,               // 27 Mhz clock from the board for Tx

   // SerDes I/Os
   `ifdef ENABLERX
      hdinp_ch0,           // High-speed serial input- (positive) channel 0
      hdinn_ch0,           // High-speed serial input- (begative) channel 0
      hdinp_ch1,           // High-speed serial input- (positive) channel 1
      hdinn_ch1,           // High-speed serial input- (negative) channel 1
   `endif 

   //=====OUTPUTS
   // SerDes I/Os
   `ifdef ENABLETX
      hdoutp_ch0,          // High-speed serial output- (positive) channel 0
      hdoutn_ch0,          // High-speed serial output- (negative) channel 0
      hdoutp_ch1,          // High-speed serial output- (positive) channel 1
      hdoutn_ch1,          // High-speed serial output- (negative) channel 1
   `endif 

   // Timing signal outputs
   `ifdef ENABLERX
      `ifdef RUN_SIMULATE
         field,            // "field" timing signal for the received video
         vblank,           // Vertical blanking signal for the received video
         hblank,           // Horizontal blanking signal for the received video
      `endif
   `endif 
    // video output status
   `ifdef ENABLERX
      vid_format,          // Video format (0-SD, 1-1280x720, 2-1920x1035, 3-1920x1080)
      frame_format,        // Number of fields (0,1,,7 ---> res,24p,25p,30p,50i,60i,50p,60p)
      vidactive,           // receiver not able to detect valid video data
   `endif 

   `ifdef RUN_SIMULATE 
   //===== receiver input signals
      `ifdef ENABLERX
         rx_rate,          // Controls scanningo f different rates
      `endif
   //===== receiver output signals
      `ifdef ENABLERX
         pd_out,           // receiver parralel output data
         pdo_clk_o,        // output data clock
         trs_out,          // EAV/SAV TRS detect
         rx_3g_hdn,        // indicates if output is in 3G or HD format
         rx_hd_sdn,        // indicates if output is in HD or SD format
         rx_lb_lan,        // indicates if output is 3G Level-B or not
         ln1_out,          // output line number
         crc_error,        // if CRC error is detected
      `endif
      `ifdef ENABLETX
         tx_line_number,   // Transmitted line number         
      `endif
   `endif 

   `ifdef RUN_SYN
      rx_3g_hdn_o,         // indicates if output is in 3G or HD format
      rx_hd_sdn_o,         // indicates if output is in HD or SD format
      crc_error_o,         // if CRC error is detected
      tx_pll_lol,          // SERDES transmit PLL loss of lock signal
      rx_cdr_lol,          // SERDES Rx CDR loss of lock signal
      rxhalfclk_o,         // Recovered or PLL clock sent out to 4915 for cleaning
      rx_los,              // SERDES Rx loss of signal indicator
      RX_GS4911_RESETn,    // Reset output for Rx 4911
      TX_GS4911_RESETn,    // Reset output for Tx 4911
      clk_100,             // 100 MHz general purpose clock
      lcd0,                // LCD0 output - lcd_r/w
      lcd1,                // LCD1 output - lcd_db0
      lcd2,                // LCD2 output - lcd_db2
      lcd3,                // LCD3 output - lcd_db4
      lcd4,                // LCD4 output - lcd_db6
      lcd5,                // LCD5 output - lcd_rs
      lcd6,                // LCD6 output - lcd_e
      lcd7,                // LCD7 output - lcd_db1
      lcd8,                // LCD8 output - lcd_db3
      lcd9,                // LCD9 output - lcd_db5
      lcd10,               // LCD10 output- lcd_db7
   `endif
   // Status outputs
   `ifdef RUN_SIMULATE
      `ifdef ENABLERX
         test_error,       // Will be high when there is a pattern checking error
      `endif 
   `endif

   // switches used for reset
      pb1,                 // Push button switch for Serdes quad and logic reset
      pb2                  // Push button switch for Serdes Rx only reset
   );


   parameter pfrac_intn     = 0;       // 0- integer ref clock, 1- fractional ref clock

`ifdef DEVICE_ECP3
   parameter pdevice_family = "ECP3";  // ECP3 Device Technology
`endif

`ifdef DEVICE_ECP2M
   parameter pdevice_family = "ECP2M"; // ECP2M Device Technology
`endif

`ifdef CLKEN
   parameter pcepresent     = 1;
`else
   parameter pcepresent     = 0;
`endif

`ifdef ENABLETX
   parameter penabletx      = 1;       // enable Tx    
`else
   parameter penabletx      = 0; 
`endif

`ifdef ENABLERX
   parameter penablerx      = 1;       // enable Rx    
`else
   parameter penablerx      = 0;
`endif

`ifdef LNINSERT_DYN
   parameter plninsert_en   = 2;
`elsif LNINSERT_EN
   parameter plninsert_en   = 1;      // enable/disable line insert in HD video    
`else
   parameter plninsert_en   = 0;
`endif

`ifdef CRCINSERT_DYN
   parameter pcrcinsert_en  = 2;
`elsif CRCINSERT_EN
   parameter pcrcinsert_en  = 1;      // enable/disable crc insert in HD video    
`else
   parameter pcrcinsert_en  = 0;
`endif

`ifdef SDWIDTH_DYN
   parameter psd8b_mode     = 2;
`elsif SDWIDTH_EN
   parameter psd8b_mode     = 1;
`else
   parameter psd8b_mode     = 0;
`endif

`ifdef SD_TX_10BITS
   parameter psd_tx_10bits  = 1;      // Whether 10-bits SD mode is enabled for Tx
`else
   parameter psd_tx_10bits  = 0;
`endif

`ifdef SD_RX_10BITS
   parameter psd_rx_10bits  = 1;      // Whether 10-bits SD mode is enabled for Tx
`else
   parameter psd_rx_10bits  = 0;
`endif

`ifdef SD_LDR
   parameter psd_ldr        = 1;      // enable SD transmission using LDR feature 
`else
   parameter psd_ldr        = 0;
`endif

`ifdef PDINSD_PORT
   parameter ppdinsd_port   = 1;      // Offer a separate 10-bits input port for SD
`else
   parameter ppdinsd_port   = 0;
`endif

`ifdef SDPLL_EXCLUDE
   parameter psdpll_exclude = 1;
`else
   parameter psdpll_exclude = 0;
`endif

`ifdef ENABLE_LEVELB
   parameter penable_levelb = 1;     // Whether 3G- level-B support is enabled
`else
   parameter penable_levelb = 0;     // Whether 3G- level-B support is enabled
`endif

`ifdef ENABLE_VPID_TX
   parameter penable_vpid_tx = 1;     // Whether VPID insertion is enabled for Tx
`else
   parameter penable_vpid_tx = 0;     // 0 = disabled, 1= enabled
`endif

`ifdef ENABLE_VPID_RX
   parameter penable_vpid_rx = 1;     // Whether VPID extraction is enabled for Rx
`else
   parameter penable_vpid_rx = 0;     // 0 = disabled, 1= enabled
`endif

`ifdef USE_DCS
   parameter puse_dcs       = 1;
`else
   parameter puse_dcs       = 0;
`endif

// ------------ Module parameters- tunable
`ifdef TG_PGMTIME
   parameter ptg_pgmtime    = `TG_PGMTIME;     // Programming wait time for 3G
`else
   parameter ptg_pgmtime    = 2;     // Programming wait time for 3G
`endif
`ifdef HD_PGMTIME
   parameter phd_pgmtime    = `HD_PGMTIME;     // Programming wait time for HD
`else
   parameter phd_pgmtime    = 2;     // Programming wait time for HD
`endif
`ifdef SD_PGMTIME
   parameter psd_pgmtime    = `SD_PGMTIME;     // Programming wait time for SD
`else
   parameter psd_pgmtime    = 2;     // Programming wait time for SD
`endif
`ifdef LOCK_THRESH
   parameter plock_thresh   = `LOCK_THRESH;
`else
   parameter plock_thresh   = 3;
`endif
`ifdef UNLOCK_THRESH
   parameter punlock_thresh = `UNLOCK_THRESH;
`else
   parameter punlock_thresh = 3;
`endif

`ifdef CUST_HD
   parameter pcust_hd       = 1;     // custom format, 0- no support, 1- support
`else   
   parameter pcust_hd       = 0;     // custom format, 0- no support, 1- support
`endif
`ifdef CUST_HD_RANGE
   parameter pvalorrange_hd = 1;     // 0- value, 1- range
`else
   parameter pvalorrange_hd = 0;     // 0- value, 1- range
`endif
`ifdef E2S_VAL_HD
   parameter pe2s_val_hd    = `E2S_VAL_HD;   // 2200- format D
`else
   parameter pe2s_val_hd    = 275;   // 2200- format D
`endif
`ifdef S2E_VAL_HD
   parameter ps2e_val_hd    = `S2E_VAL_HD;  // 1920- format D
`else
   parameter ps2e_val_hd    = 1923;  // 1920- format D
`endif
`ifdef E2S_MIN_HD
   parameter pe2s_min_hd    = `E2S_MIN_HD; 
`else
   parameter pe2s_min_hd    = 275;   // encompasses all HD formats
`endif
`ifdef E2S_MAX_HD
   parameter pe2s_max_hd    = `E2S_MAX_HD; 
`else
   parameter pe2s_max_hd    = 2840;  // encompasses all HD formats
`endif
`ifdef S2E_MIN_HD
   parameter ps2e_min_hd    = `S2E_MIN_HD; 
`else
   parameter ps2e_min_hd    = 1283;  // encompasses all HD formats
`endif
`ifdef S2E_MAX_HD
   parameter ps2e_max_hd    = `S2E_MAX_HD; 
`else
   parameter ps2e_max_hd    = 1923;  // encompasses all HD formats
`endif

`ifdef CUST_TG
   parameter pcust_tg       = 1;     // custom format, 0- no support, 1- support
`else   
   parameter pcust_tg       = 0;     // custom format, 0- no support, 1- support
`endif
`ifdef CUST_TG_RANGE
   parameter pvalorrange_tg = 1;     // 0- value, 1- range
`else
   parameter pvalorrange_tg = 0;     // 0- value, 1- range
`endif
`ifdef E2S_VAL_TG
   parameter pe2s_val_tg    = `E2S_VAL_TG;   // 2200- format D
`else
   parameter pe2s_val_tg    = 275;   // 2200- format D
`endif
`ifdef S2E_VAL_TG
   parameter ps2e_val_tg    = `S2E_VAL_TG;  // 1920- format D
`else
   parameter ps2e_val_tg    = 1923;  // 1920- format D
`endif
`ifdef E2S_MIN_TG
   parameter pe2s_min_tg    = `E2S_MIN_TG; 
`else
   parameter pe2s_min_tg    = 275;   // encompasses all 3G formats
`endif
`ifdef E2S_MAX_TG
   parameter pe2s_max_tg    = `E2S_MAX_TG;
`else
   parameter pe2s_max_tg    = 5685;  // encompasses all 3G formats
`endif
`ifdef S2E_MIN_TG
   parameter ps2e_min_tg    = `S2E_MIN_TG;
`else
   parameter ps2e_min_tg    = 1923;  // encompasses all 3G formats
`endif
`ifdef S2E_MAX_TG
   parameter ps2e_max_tg    = `S2E_MAX_TG; 
`else
   parameter ps2e_max_tg    = 3843;  // encompasses all 3G formats
`endif

// ------------ Local parameters
   localparam  ldatawidth        = 20 ;
   localparam  llinenumbits      = 11 ;
   localparam  lcntwidth         = 3 ;
   localparam  ldatawidthby2     = ldatawidth >> 1 ;
   localparam  lramaddr_width    = 8 ;
   localparam  laddr_hd_width    = 4 ;
   localparam  lramaddr_width_pt = 13 ;
   localparam  lrd_ptr_initd     = 2**(lramaddr_width_pt-1);  // read pointer offset for data
   localparam  lrd_ptr_initln    = lrd_ptr_initd+10;         // read pointer offset for LN
   localparam  ldatawidth_p1     = ldatawidth+1;
   localparam  lpor_cnt_width    = 10;
   localparam  ltrig_cnt_width   = 16;
   localparam  lwait_cnt_width   = 20;

   localparam  los_cnt_width     = 12;
   localparam  rst_cnt_width     = 7;
   localparam  hold_cnt_width    = 8;
   localparam  los_cnt_width_2   = los_cnt_width-2;
   localparam  rst_cnt_width_2   = rst_cnt_width-2;
   localparam  hold_cnt_width_2  = rst_cnt_width-2;

// ------------ Inputs/Outputs 
   input  wire                  pb1;
   input  wire                  pb2;
   `ifdef RUN_SYN
   input  wire                  pb3;
   input  wire                  pb4;
   `endif
   `ifndef PASSTHRU_ENABLE
      `ifdef SD_LDR
         input                  sw1_4;     // Used for LDR only
      `endif
      input                     sw1_3;     // lb_lan_in
      input                     patho_cbn; // SW5-1
      input                     tg_hdn_in; 
      input                     hd_sdn_in; 
      input   [1:0]             cb_patho_type;
      input   [4:0]             pg_std_num;    
   `endif
   
   `ifdef CLKEN
      input                     ce;              // clock enable
   `endif

   //===== transmitter input signals
   `ifdef SDWIDTH_DYN
      input                     sd8b_mode;       // if the data is in 8 bit SD video format
   `endif

   `ifdef CRCINSERT_DYN
      input                     crci_en;         // enable CRC insertion
   `endif
   `ifdef LNINSERT_DYN
      input                     lni_en;          // enable line insertion
   `endif

   //===== reference clock  
   // Gennum Clocks
   input                        tx_ref_clkp;     // transmitter differential positive clock
   input                        tx_ref_clkn;     // transmitter differential negative clock
`ifdef BYPASS_RX_4911
   input   wire                 rx_x1;           // 27 Mhz clock from the board for Rx
`else
   input   wire                 rx_4915_clkout_se_in; // rx FPGA ref clock from 4915
`endif

   input   wire                 tx_x1;           // 27 Mhz clock from the board for Tx

   // SerDes I/Os
   `ifdef ENABLETX
      output  wire    /*synthesis nopad=true*/  hdoutp_ch0;
      output  wire    /*synthesis nopad=true*/  hdoutn_ch0;
      output  wire    /*synthesis nopad=true*/  hdoutp_ch1;
      output  wire    /*synthesis nopad=true*/  hdoutn_ch1;
   `endif 
   `ifdef ENABLERX
      input  wire     /*synthesis nopad=true*/  hdinp_ch0;
      input  wire     /*synthesis nopad=true*/  hdinn_ch0;
      input  wire     /*synthesis nopad=true*/  hdinp_ch1;
      input  wire     /*synthesis nopad=true*/  hdinn_ch1;
   `endif 

   `ifdef RUN_SYN
      input   wire              clk_100;
   `endif

   // Gennum GENLOCK reference
   `ifdef ENABLERX
      `ifdef RUN_SIMULATE
      output                    field;
      output                    vblank;
      output                    hblank;
      `endif
   `endif 

   `ifdef ENABLERX
      output                    vidactive;        // receiver not able to detect valid video data
      output  [1:0]             vid_format;
      output  [2:0]             frame_format;
   `endif

`ifdef RUN_SIMULATE 
   //===== receiver output signals
   `ifdef ENABLERX
      input      [2:0]          rx_rate;
   `endif
   //===== receiver output signals
   `ifdef ENABLERX
      output  [19:0]            pd_out;           // receiver parralel output data
      output                    pdo_clk_o;        // output data clock
      output                    trs_out;          // EAV/SAV TRS detect
      output                    rx_3g_hdn;        // indicates if output is in 3G or HD format
      output                    rx_hd_sdn;        // indicates if output is in HD or SD format
      output                    rx_lb_lan;
      output  [10:0]            ln1_out;           // output line number
      output                    crc_error;        // if CRC error is detected
   `endif
   `ifdef ENABLETX
      output  [10:0]            tx_line_number;           
   `endif
`endif 

   `ifdef RUN_SYN
      output  wire              rx_3g_hdn_o;      // indicates if output is in 3G or HD format
      output  wire              rx_hd_sdn_o;
      output  wire              crc_error_o;
      output                    tx_pll_lol;
      output                    rx_cdr_lol;
      output                    rxhalfclk_o;
      output                    rx_los;
      output  wire              RX_GS4911_RESETn;
      output  wire              TX_GS4911_RESETn;
      output  wire              lcd0;  // lcd_r/w
      output  wire              lcd5;  // lcd_rs
      output  wire              lcd6;  // lcd_e
      output  wire              lcd1;  // lcd_db0
      output  wire              lcd2;  // lcd_db2
      output  wire              lcd3;  // lcd_db4
      output  wire              lcd4;  // lcd_db6
      output  wire              lcd7;  // lcd_db1
      output  wire              lcd8;  // lcd_db3
      output  wire              lcd9;  // lcd_db5
      output  wire              lcd10; // lcd_db7
   `endif

   // Status outputs
`ifdef RUN_SIMULATE
   `ifdef ENABLERX
      output                    test_error; // High when there is a pattern checking error
   `endif 
`endif

// ------------ Internal registers and wires
   wire                         ce;              // clock enable
   wire                         sw1_3;
   wire                         sw1_4;
   wire                         patho_cbn; // SW5-1
   wire                         tg_hdn_in; 
   wire                         hd_sdn_in; 
   wire  [1:0]                  cb_patho_type;
   wire  [4:0]                  pg_std_num;

   //===== transmitter input signals
   wire                         sd8b_mode;       // if the data is in 8 bit SD video format
   wire                         crci_en;         // enable CRC insertion
   wire                         lni_en;          // enable line insertion

   //===== reference clock  
   wire   /*synthesis nopad=true*/  tx_ref_clkp; // transmitter differential positive clock
   wire   /*synthesis nopad=true*/  tx_ref_clkn; // transmitter differential negative clock

   // registered inputs
   reg   [4:0]                  pg_std_numr;
   reg   [4:0]                  pg_std_num1;   
   
   // Timing signal outputs
   reg                          field;
   reg                          vblank;
   reg                          hblank;

   //===== receiver output signals
   reg   [19:0]                 pd_out;           // receiver parralel output data
   wire                         pdo_clk_o;        // output data clock
   reg                          vidactive;        // receiver not able to detect valid video data
   reg                          trs_out;          // EAV/SAV TRS detect
   reg                          rx_3g_hdn;        // indicates if output is in 3G or HD format
   reg                          rx_hd_sdn;        // indicates if output is in HD or SD format
   reg                          rx_lb_lan;
   reg   [10:0]                 ln1_out;          // output line number for stream 1
   reg   [10:0]                 ln2_out;          // output line number for stream 2
   reg   [1:0]                  vid_format;
   reg   [2:0]                  frame_format;

   reg                          eav_error;
   reg                          sav_error;
   reg                          crc_error;        // if CRC error is detected
   wire  [10:0]                 tx_line_number;           

   // Status outputs
   reg                          test_error;
   wire                         sr;
   wire                         syncrst;
   wire                         clken;
   wire                         rx_cdr_lol;
   wire                         tx_pll_lol;
   wire                         ser_ref_clkp;
   wire                         ser_ref_clkn;
   wire                         ser_rxref_clk;
   wire                         threeg_hdn_in;
   wire                         highd_sdn_in;
   wire                         levelb_lan_in;
   
   //=== SERDES signals
   wire                         txfullclk;
   wire                         txhalfclk;
   wire                         rxfullclk;
   wire                         rxhalfclk;
   wire                         rxhalfclk_o;
   wire                         rstn;
   wire                         rstn1;
   wire  [ldatawidth-1:0]       rxdata;
   wire  [ldatawidth-1:0]       txdata;
   wire                         txd_ldr;

// --------- pattern gen signals
   reg                          update_controls_in;
   reg   [4:0]                  update_controls_clk_cnt;
   reg   [10:0]                 switch_status;
   reg   [10:0]                 switch_status_delay1;
   reg   [10:0]                 switch_status_delay2;
   wire  [3:0]                  std_number;
   wire  [9:0]                  data_out_high, data_out_low;

   wire                         pattern_group_sel_in;
   wire                         cbtype_smpte_in;
   wire                         cbtype_75_in;
   wire                         pll_test_only_in;
   wire                         equ_test_only_in;
   wire                         pattern_m_factor;

// Signals for line number generation
   wire                         line_number_set;
   wire  [10:0]                 line_number;
   reg                          line_number_set_pat;
   reg   [10:0]                 line_number_pat;
   reg                          trs_in_pat;           // start/end of line
   reg   [19:0]                 pd_in_pat;            // transmitter input data
   wire                         pat_trs;
   wire  [ldatawidth-1:0]       pat_dout;

   wire  [ldatawidth-1:0]       pd_out_int;
   wire                         trs_out_int;
   wire                         rx_3g_hdn_int;
   wire                         rx_hd_sdn_int;
   wire                         rx_lb_lan_int;
   wire                         field_int;
   wire                         vblank_int;
   wire                         hblank_int;
   wire                         eav_error_int;
   wire                         sav_error_int;
   wire                         crc_error_int;
   wire  [llinenumbits-1:0]     ln1_out_int;
   wire  [llinenumbits-1:0]     ln2_out_int;
   wire                         vidactive_int;
   wire  [1:0]                  vid_format_int;
   wire  [2:0]                  frame_format_int;

   reg   [ldatawidth-1:0]       pd_out_int1;
   reg                          trs_out_int1;
   reg                          rx_3g_hdn_int1;
   reg                          rx_hd_sdn_int1;
   reg                          rx_lb_lan_int1;
   reg                          field_int1;
   reg                          vblank_int1;
   reg                          hblank_int1;
   reg                          eav_error_int1;
   reg                          sav_error_int1;
   reg                          crc_error_int1;
   reg   [llinenumbits-1:0]     ln1_out_int1;
   reg   [llinenumbits-1:0]     ln2_out_int1;
   reg                          vidactive_int1;
   reg   [1:0]                  vid_format_int1;
   reg   [2:0]                  frame_format_int1;

`ifdef DPRAM_SELFCHK_TST
   wire  [ldatawidth-1:0]       pat_dout_del;
   wire  [ldatawidthby2-1:0]    pat_dout_del_lo;
   wire  [ldatawidthby2-1:0]    pat_dout_del_hi;
   wire  [ldatawidthby2-1:0]    pat_dout_lo;
   wire  [ldatawidthby2-1:0]    pat_dout_hi;
   reg   [ldatawidth-1:0]       pd_out_p1;
   reg   [ldatawidth-1:0]       pd_out_p2;
   wire  [ldatawidthby2-1:0]    pd_out_p2_lo;
   wire  [ldatawidthby2-1:0]    pd_out_p2_hi;
   reg                          pdout_error_low_hd;
   reg                          pdout_error_low_sd;
   reg                          pdout_error_high;
   reg                          test_errori;
   reg   [lramaddr_width-1:0]   wraddr;
   reg   [lramaddr_width-1:0]   rdaddr;
   reg                          tx_sav;
   reg                          rx_sav;
   reg                          rx_eav;
   reg                          rx_eav_p1;
   reg                          rx_eav_p2;
   reg                          rx_eav_p3;
   reg                          rx_eav_p4;
   reg                          rx_eav_p5;
   reg                          rx_eav_p6;
   reg                          rx_eav_p7;
   reg                          rx_eav_p8;
   reg                          rx_eav_p9;
   reg                          rx_eav_p10;
   reg                          pat_trs_p1;
   reg                          pat_trs_p2;
   reg                          pat_trs_p3;
   reg                          pat_trs_p4;
   reg                          pat_trs_p5;
   reg                          pat_trs_p6;
   reg                          trs_out_p1;
   reg                          trs_out_p2;
   reg                          trs_out_p3;
   reg                          trs_out_p4;
   reg                          trs_out_p5;
   reg                          trs_out_p6;
   reg                          fst_tsav_after_vidac;
   reg                          fst_rsav_after_vidac;
   reg                          fst_rsav_after_vidac_p1;
   reg                          fst_rsav_after_vidac_p2;
   reg                          fst_rsav_after_vidac_p3;
   reg                          fst_rsav_after_vidac_d1;
   reg                          fst_rsav_after_vidac_d2;
   reg                          fst_rsav_after_vidac_d3;
   reg                          fst_rsav_after_vidac_d4;
   reg                          fst_rsav_after_vidac_d5;
   reg                          rx_hd_sdn_p1;
   reg                          rx_hd_sdn_p2;
   reg                          rx_hd_sdn_p3;
   reg                          rx_hd_sdn_p4;
   reg                          rx_3g_hdn_p1;
   reg                          rx_3g_hdn_p2;
   reg                          rx_3g_hdn_p3;
   reg                          rx_3g_hdn_p4;
`endif

   reg                          update_controls_in_rpg;
   reg   [3:0]                  std_number_rpg;
   reg   [4:0]                  format_sel_3g_rpg;
   reg                          pattern_group_sel_in_rpg;
   reg                          cbtype_smpte_in_rpg;
   reg                          cbtype_75_in_rpg;
   reg                          pll_test_only_in_rpg;
   reg                          equ_test_only_in_rpg;
   reg                          threeg_hdn_in_rpg;
   reg                          hd_sdn_in_rpg;
   reg                          lb_lan_in_rpg;
   wire                         top_clk270_out;
   wire                         top_clk27_out;
   wire                         rx_pdo_clk; 

//IP Core Signals 
   wire                         clk27_in;
   wire  [2:0]                  rx_rate;
   wire                         clk270_out;
   wire                         clk27_out;
   wire                         clk_pat_gen;   // Multiplexed clock to pattern gen
   wire                         clk_27_pllin;  // independent 27 MHz clock
   wire                         rxiclk_ch0;
   wire                         txiclk_ch0;
   wire                         rx_full_clk_ch0;
   wire                         rx_half_clk_ch0;
   wire                         tx_full_clk_ch0;
   wire                         tx_half_clk_ch0;
   wire                         fpga_rxrefclk_ch0;
   wire  [ldatawidth-1:0]       txdata_ch0;
   wire  [ldatawidth-1:0]       rxdata_ch0;

   wire                         rxiclk_ch1;
   wire                         txiclk_ch1;
   wire                         rx_full_clk_ch1;
   wire                         rx_half_clk_ch1;
   wire                         tx_full_clk_ch1;
   wire                         tx_half_clk_ch1;
   wire                         fpga_rxrefclk_ch1;
   wire  [ldatawidth-1:0]       txdata_ch1;
   wire  [ldatawidth-1:0]       rxdata_ch1;

   wire                         ffc_macro_rst;
   wire                         ffc_quad_rst;
   wire                         ffc_trst;
   wire                         ffc_rrst_0;
   wire                         ffc_lane_tx_rst_0;
   wire                         ffc_lane_rx_rst_0;
   wire                         rx_los_high_ch1_s;
   wire                         rx_los_low_ch1_s;
   wire                         rx_los;   
   reg   [lpor_cnt_width-1:0]   por_cnt;
   wire                         por_pulse;
   wire                         lcd_rstn;

   wire                         txd_ldr_en;
   wire  [9:0]                  pd_in_sd;
   wire                         rxd_ldr;
   wire                         txd_ldr_ch0;
   wire                         pll_148_clkop;
   
   reg   [ltrig_cnt_width-1:0]  trig_cnt;
   wire                         trig_cnt_tc;
   reg                          wait_en;
   reg   [lwait_cnt_width-1:0]  wait_cnt;
   wire                         wait_cnt_tc;
   reg                          rx_lol_reset;

   wire                         clk27_for_pg;
   wire                         sd_bumped_clk;
   wire                         recov_clk_out;
   wire                         sd_recov_clk;
   wire                         pll_148_rx_refclk;
   
`ifdef PASSTHRU_ENABLE
   reg   [lramaddr_width_pt-1:0] wraddr_pt;
   reg   [lramaddr_width_pt-1:0] rdaddr_pt;
   reg   [lramaddr_width_pt-1:0] rdaddr_pt_ln;

   wire  [ldatawidth-1:0]       pd_out_pt;
   wire  [10:0]                 ln1_out_pt;
   wire  [10:0]                 ln2_out_pt;
   wire                         trs_out_pt;
`endif

   reg                          crc_dis;
   reg   [4:0]                  vpid_cnt;
   reg                          vpid_cnten;
   wire                         vpid_dis;
   wire                         dis_pdout_errchk;
   
   reg    [3:0]                 byte1_3_0;
   reg    [1:0]                 byte2_7_6;
   reg    [3:0]                 byte2_3_0;
   reg                          byte3_7_7;
   reg    [3:0]                 byte3_3_0;
   reg    [1:0]                 byte4_1_0;
   reg    [1:0]                 byte4_7_6;
   wire   [31:0]                vpid1_in;
   wire   [31:0]                vpid2_in;
   wire   [31:0]                vpid1_in_lb;
   wire   [31:0]                vpid2_in_lb;

   wire                         vp1_valid;
   wire                         vp1_cserr;
   wire                         vp1_parerr;
   wire                         vp1_lineok;
   wire                         vp1_csperr;
   wire   [31:0]                vpid1_out;
   wire                         vp2_valid;
   wire                         vp2_cserr;
   wire                         vp2_parerr;
   wire                         vp2_lineok;
   wire                         vp2_csperr;
   wire   [31:0]                vpid2_out;

   wire                         frac_intn;
   wire   [31:0]                vpid_in;
   wire                         update_mode;
   wire                         ychannel;
   wire                         y1_crc_error;
   wire                         c1_crc_error;
   wire                         y2_crc_error;
   wire                         c2_crc_error;
   wire  [2:0]                  pg_rate;

//=================================================================
//                            Start of Code
//=================================================================

   always @(posedge clk_pat_gen or negedge rstn) begin
      if (!rstn) begin
         pg_std_num1 <= 'd0;
         pg_std_numr <= 'd0;
      end
      else begin
		 pg_std_num1 <= pg_std_num;
         pg_std_numr <= pg_std_num1;
      end
   end
// ================================================================
//           Synthesis_ and Simulation Signal Assignments
// ================================================================

// Simulation signals
   assign  tx_line_number= line_number;

   `ifndef RUN_SIMULATE
      assign rx_rate = 3'b111;
   `endif
      
// Synthesis_ signals
   `ifdef RUN_SYN
      `ifdef BYPASS_RX_4911
         assign RX_GS4911_RESETn = 1'b0;    // reset
      `else
         assign RX_GS4911_RESETn = 1'b1;    // active
      `endif
      `ifdef BYPASS_TX_4911
         assign TX_GS4911_RESETn = 1'b0;    // reset
      `else
         `ifdef PASSTHRU_ENABLE
            assign TX_GS4911_RESETn = 1'b0; // reset
         `else
            assign TX_GS4911_RESETn = 1'b1; // active
         `endif
      `endif

      assign crc_error_o = crc_error_int;
      assign rx_3g_hdn_o = rx_3g_hdn_int; 
      assign rx_hd_sdn_o = rx_hd_sdn_int;
   `endif

   generate
      if (pcepresent == 1) begin
         assign clken    = ce;
      end
      else begin
         assign clken    = 1'b1;
      end
   endgenerate

   assign ser_ref_clkp   = tx_ref_clkp;
   assign ser_ref_clkn   = tx_ref_clkn;
   `ifdef BYPASS_RX_4911
      assign ser_rxref_clk = pll_148_rx_refclk;    // Rx ref. clk from PLL
   `else
      assign ser_rxref_clk = rx_4915_clkout_se_in; // Rx ref. clk from 4915
   `endif

// ================================================================
//               Push button and DIP switch assignments
// ================================================================
   `ifdef RUN_SYN
      assign rstn  = pb1 & por_pulse;
      assign rstn1 = pb1;
   `else
      assign rstn  = pb1;
      assign rstn1 = pb2;
   `endif

   `ifdef PASSTHRU_ENABLE
      assign threeg_hdn_in  = (vidactive==1'b1)?rx_3g_hdn:1'b0;
      assign highd_sdn_in   = (vidactive==1'b1)?rx_hd_sdn:1'b0;
      assign vpid1_in       = vpid1_out;
      `ifdef ENABLE_LEVELB
         assign levelb_lan_in = (vidactive==1'b1)?rx_lb_lan:1'b0;
         assign vpid2_in    = vpid2_out;
      `else
         assign levelb_lan_in = 1'b0;
         assign vpid2_in    = 32'b0;
      `endif

   `else
      assign threeg_hdn_in  = tg_hdn_in|levelb_lan_in;
      assign highd_sdn_in   = hd_sdn_in;
      assign vpid1_in       = vpid1_in_lb;
      `ifdef ENABLE_LEVELB
         assign levelb_lan_in  = sw1_3;
         assign vpid2_in       = vpid2_in_lb;
      `else
         assign levelb_lan_in  = 1'b0;
         assign vpid2_in       = 32'b0;
      `endif
      assign pg_rate = {levelb_lan_in,tg_hdn_in,hd_sdn_in};
   `endif

   assign std_number     = pg_std_numr[3:0];
   assign pattern_group_sel_in = patho_cbn;            // SW5-1
   assign {cbtype_smpte_in, cbtype_75_in}      = cb_patho_type;
   assign {pll_test_only_in, equ_test_only_in} = cb_patho_type;

//======================================================================
//                          VPID determination
//======================================================================

`ifdef PASSTHRU_ENABLE
   // to be populated
`else
// video payload and digital interface std
   always @(posedge clk_pat_gen or negedge rstn) begin
      if (rstn == 1'b0)
         byte1_3_0 <= 4'd0;  // video payload and digital interface std
      else begin
      case(pg_rate)
         3'b000: byte1_3_0 <= 4'd1;
         3'b001: if (pg_std_numr[2:0]<=6) byte1_3_0 <= 4'd5;
                 else byte1_3_0 <= 4'd4;
         3'b011: if ((pg_std_numr==2)||(pg_std_numr==3)||(pg_std_numr==5)||(pg_std_numr==7)||(pg_std_numr==9)) byte1_3_0 <= 4'd8;
                 else byte1_3_0 <= 4'd9;
         3'b101: if (pg_std_numr[2:0]<=6) byte1_3_0 <= 4'hC;
                 else byte1_3_0 <= 4'hB;
         3'b111: byte1_3_0 <= 4'hA;
         default: byte1_3_0 <= 4'd0;
      endcase
      end
   end

// interlaced or progressive
   always @(posedge clk_pat_gen or negedge rstn) begin
      if (rstn == 1'b0)
         byte2_7_6 <= 2'b00; // {transport,picture}
      else if (pg_rate==3'b000) // SD
         byte2_7_6 <= 2'b00;
      else if (pg_rate==3'b001) begin // HD
         if((pg_std_numr[2:0]==2)||(pg_std_numr[2:0]==4)||(pg_std_numr[2:0]==6))
            byte2_7_6 <= 2'b11;
         else if ((pg_std_numr[2:0]==0)||(pg_std_numr[2:0]==1)||(pg_std_numr[2:0]==3)||(pg_std_numr[2:0]==5))
            byte2_7_6 <= 2'b00;
         else
//            byte2_7_6 <= 2'b01;
            byte2_7_6 <= 2'b11;
      end
      else if(pg_rate==3'b011) begin // 3G-A
         if ((pg_std_numr==10)||(pg_std_numr==11)||(pg_std_numr==15)||(pg_std_numr==16)||(pg_std_numr==20)||(pg_std_numr==21))
            byte2_7_6 <= 2'b00;
         else
            byte2_7_6 <= 2'b11;
      end
      else if (pg_rate==3'b101) begin // 3G-B-DS
         if((pg_std_numr[2:0]==0)||(pg_std_numr[2:0]==1)||(pg_std_numr[2:0]==3)||(pg_std_numr[2:0]==5))
            byte2_7_6 <= 2'b00;
         else
            byte2_7_6 <= 2'b11;
      end
      else if(pg_rate==3'b111) begin // 3G-B-DL
         if ((pg_std_numr==0)||(pg_std_numr==1))
            byte2_7_6 <= 2'b01;
         else
            byte2_7_6 <= 2'b11;
      end

      else
         byte2_7_6 <= 2'b00;
   end

// picture rate
   always @(posedge clk_pat_gen or negedge rstn) begin
      if (rstn == 1'b0)
         byte2_3_0 <= 4'd0;  // picture rate 
      else if ((pg_rate==3'b011)||(pg_rate==3'b111)) begin // 3G-A or 3G-B DL
         if((pg_std_numr==8)||(pg_std_numr==9)||(pg_std_numr==14)||(pg_std_numr==19)) // 24
            byte2_3_0 <= 4'd3;
         else if((pg_std_numr==6)||(pg_std_numr==7)||(pg_std_numr==13)||(pg_std_numr==18)) // 25
            byte2_3_0 <= 4'd5;
         else if((pg_std_numr==4)||(pg_std_numr==5)||(pg_std_numr==12)||(pg_std_numr==17)) // 30
            byte2_3_0 <= 4'd7;
         else if((pg_std_numr==1)||(pg_std_numr==3)||(pg_std_numr==11)||(pg_std_numr==16)||(pg_std_numr==21)) // 50
            byte2_3_0 <= 4'd9;
         else if((pg_std_numr==0)||(pg_std_numr==2)||(pg_std_numr==10)||(pg_std_numr==15)||(pg_std_numr==20)) // 60
            byte2_3_0 <= 4'd11;
         else
            byte2_3_0 <= 4'd0;
      end
      else if ((pg_rate==3'b001)||(pg_rate==3'b101)) begin // HD or 3G-B DS
         if (pg_std_numr[2:0]==6) // 24
            byte2_3_0 <= 4'd3;
         else if (pg_std_numr[2:0]==4) // 25
            byte2_3_0 <= 4'd5;
         else if (pg_std_numr[2:0]==2) // 30
            byte2_3_0 <= 4'd7;
         else if ((pg_std_numr[2:0]==1)||(pg_std_numr[2:0]==5)) // 50
            byte2_3_0 <= 4'd9;
         else if ((pg_std_numr[2:0]==0)||(pg_std_numr[2:0]==3)||(pg_std_numr[2:0]==7)) // 60
            byte2_3_0 <= 4'd11;
         else
            byte2_3_0 <= 4'd0;
      end
      else if (pg_rate==3'b000) begin // SD 
         if (pg_std_numr[0]==0) // 59.94
            byte2_3_0 <= 4'd10;
         else  // 50
            byte2_3_0 <= 4'd9;
      end
      else
         byte2_3_0 <= 4'd0;
   end

// Image aspect ratio, byte3_7_7, 0- 4:3, 1-16:9
/*   always @(posedge clk_pat_gen or negedge rstn) begin
      if (rstn == 1'b0)
         byte3_7_7 <= 1'd0;
      else if (pg_rate==3'b000) // SD
         byte3_7_7 <= 1'd0;
      else
         byte3_7_7 <= 1'd1;
   end */

// sampling structure, byte3_3_0
   always @(posedge clk_pat_gen or negedge rstn) begin
      if (rstn == 1'b0)
         byte3_3_0 <= 4'd0;
      else if ((pg_rate==3'b011)||(pg_rate==3'b111)) begin // 3G-A or 3G-B DL
         if((pg_std_numr==0)||(pg_std_numr==1)) // 4:2:2, 10-bits
            byte3_3_0 <= 4'd0;
         else if((pg_std_numr>=2)&&(pg_std_numr<=11)) // 4:4:4:4, 10-bits
            byte3_3_0 <= 4'd5;
         else if((pg_std_numr>=12)&&(pg_std_numr<=16)) // 4:4:4, 12-bits
            byte3_3_0 <= 4'd1;
         else if((pg_std_numr>=17)&&(pg_std_numr<=21)) // 4:2:2:4, 12-bits with A
            byte3_3_0 <= 4'd4;
         else
            byte3_3_0 <= 4'd0;
      end
      else
         byte3_3_0 <= 4'd0;
   end

// channel assignment, byte4_bits7_6, channel number for dual-link
   always @(posedge clk_pat_gen or negedge rstn) begin
      if (rstn == 1'b0)
         byte4_7_6 <= 2'd0;
      else if (pg_rate==3'b111)
         byte4_7_6 <= 2'd1;
      else
         byte4_7_6 <= 2'd0;
   end

// bit depth, byte4_bits1_0
   always @(posedge clk_pat_gen or negedge rstn) begin
      if (rstn == 1'b0)
         byte4_1_0 <= 2'd1;
      else if (((pg_rate==3'b011)||(pg_rate==3'b111))&&(pg_std_numr>=12)&&(pg_std_numr<=21))
         byte4_1_0 <= 2'd2;
      else
         byte4_1_0 <= 2'd1;
   end

`endif   

// ------------ VPID assignment
   assign vpid1_in_lb = {2'd0,1'b0,2'd0,1'd0,byte4_1_0,
                      1'b0,3'd0,byte3_3_0,
                      byte2_7_6,2'd0,byte2_3_0,
                      4'd8,byte1_3_0};
   assign vpid2_in_lb = {byte4_7_6,1'b0,2'd0,1'd0,byte4_1_0,
                      1'b0,3'd0,byte3_3_0,
                      byte2_7_6,2'd0,byte2_3_0,
                      4'd8,byte1_3_0};

//======================================================================
//                            Clock handling 
//======================================================================
// ============ Receive Reference Clock
   `ifdef BYPASS_RX_4911
   // Rx ref clock derived from board 27 MHz clock
      pll_148 u2_pll_148 (
         .CLK    (rx_x1),   // RX_X1
         // Use either the assignment above or the one below to source the PLL
         // Sometimes one results in better jitter than the other
         //.CLK    (tx_x1), // TX_X1
         .CLKOP  (pll_148_rx_refclk), 
         .LOCK   ()
         );
   `endif

// ============ Transmit Reference Clock
// ------------ Tx reference clock generated using FPGA PLL
   `ifdef PASSTHRU_ENABLE
      assign sd_recov_clk = ((vidactive & ~rx_hd_sdn)==1'b1)? rxfullclk:1'b0;
      pll_148 u1_pll_148 (
         .CLK    (sd_recov_clk), 
         .CLKOP  (sd_bumped_clk), 
         .LOCK   ()
         );
      MUX21 recov_clk_MUX21 (
         .D0     (sd_bumped_clk),
         .D1     (rxhalfclk),
         .SD     (rx_hd_sdn),
         .Z      (recov_clk_out)
         );
      assign rxhalfclk_o = recov_clk_out; // to Tx 4915 SE input
   `else
      `ifdef BYPASS_TX_4911
         pll_148 u1_pll_148 (
            .CLK    (tx_x1),  // TX_X1
            .CLKOP  (pll_148_clkop), 
            .LOCK   ()
            );
         assign rxhalfclk_o = pll_148_clkop; // to Tx 4915 SE input
      `else
         assign rxhalfclk_o = 1'b0; // to Tx 4915 SE input
      `endif
   `endif 

// ------------ 27 MHz clock user selection 
// The clock input for PLL or clk27_in for LDR below can be selected to be
//   either the txfullclk or an independent 27 MHz clock from the board

`ifdef SCHEME1 // (uses indep. 27 clk or txfullclk for LDR)
      assign clk_27_pllin = txfullclk;     // 27 MHz clock from the SERDES
//      assign clk_27_pllin = tx_x1; // independent 27 MHz clock
   
// ------------ Instantiating a PLL for LDR when PLL is not inside the IP
   generate
      if ((psdpll_exclude == 1)&&(psd_ldr == 1)) begin
      // === SD PLL to generate 270 Mhz clock
         sd_pll u1_sd_pll (
            //=====INPUTS
            .CLK         (clk_27_pllin),
            //=====OUTPUTS
            .CLKOP       (top_clk270_out),
            .CLKOS       (top_clk27_out),
            .LOCK        ()
            );
      end
   endgenerate

// ------------ Selection of clk27_in         
   generate
      if ((psd_ldr == 1) && (psdpll_exclude == 1)) begin
         assign clk27_in = top_clk27_out;
      end
      else begin
         assign clk27_in = clk_27_pllin;
      end
   endgenerate

`else // (second scheme- uses rx_ref_clk for LDR clk)
// ------------ Using the Rx ref. clock to generate 27 and 270 for LDR

   generate
      if (psd_ldr == 1) begin
         pll_148_to_27 u1_pll_148_to_27 (
            //=====INPUTS
            .CLK         (ser_rxref_clk),
            //=====OUTPUTS
            .CLKOP       (top_clk270_out),
            .CLKOK       (top_clk27_out),
            .LOCK        ()
            );
         assign clk27_in = top_clk27_out;
      end
   endgenerate
`endif  // End of LDR clock schemes

// ------------ Selection of 27 MHz to be used in the Pattern generator mux
   generate
      if (psd_ldr == 1) begin
         assign clk27_for_pg = clk27_in;
      end
      else begin
         assign clk27_for_pg = txfullclk;
      end
   endgenerate

// ------------ Multiplexing 3G/HD half clock and SD full clock for patgen
//              and feeding the IP's pdi_clk
   `ifdef USE_DCS_FOR_PG_CLK
      DCS u1_DCS (
         .CLK0         (clk27_for_pg), 
         .CLK1         (txhalfclk), 
         .SEL          (highd_sdn_in), 
         .DCSOUT       (clk_pat_gen)
         );
   `else
      MUX21 u1_MUX21 (
         .D0           (clk27_for_pg),
         .D1           (txhalfclk),
         .SD           (highd_sdn_in),
         .Z            (clk_pat_gen)
         );
   `endif
   
// ============ Receive Clocking
   generate
      if (psd_rx_10bits == 0)  begin
         MUX21 u2_MUX21 (
            .D0           (rxfullclk),
            .D1           (rxhalfclk),
            .SD           (rx_hd_sdn_int),
            .Z            (pdo_clk_o)
            );
      end
      else begin
         assign  pdo_clk_o = rx_pdo_clk;
      end 
   endgenerate 

//======================================================================
//                         SDI IP instantiation 
//======================================================================
   assign pd_in_sd = pd_in_pat[9:0];
`ifdef USER_CORE_NAME
   `include  "core_name.v"
`else
   sdi_core 
           #(
           .pdevice_family  (pdevice_family),
           .pcepresent      (pcepresent),
           .penabletx       (penabletx),
           .penablerx       (penablerx),
           .plninsert_en    (plninsert_en),
           .pcrcinsert_en   (pcrcinsert_en),
           .psd8b_mode      (psd8b_mode),
           .psd_tx_10bits   (psd_tx_10bits),
           .psd_rx_10bits   (psd_rx_10bits),
           .psd_ldr         (psd_ldr),
           .ppdinsd_port    (ppdinsd_port),
           .psdpll_exclude  (psdpll_exclude),
           .penable_levelb  (penable_levelb),
           .penable_vpid_tx (penable_vpid_tx),
           .penable_vpid_rx (penable_vpid_rx),
           .puse_dcs        (puse_dcs),
           .ptg_pgmtime     (ptg_pgmtime),
           .phd_pgmtime     (phd_pgmtime),
           .psd_pgmtime     (psd_pgmtime),
           .plock_thresh    (plock_thresh),
           .punlock_thresh  (punlock_thresh),
           .pcust_hd        (pcust_hd),
           .pvalorrange_hd  (pvalorrange_hd),
           .pe2s_val_hd     (pe2s_val_hd),
           .ps2e_val_hd     (ps2e_val_hd),
           .pe2s_min_hd     (pe2s_min_hd),
           .pe2s_max_hd     (pe2s_max_hd),
           .ps2e_min_hd     (ps2e_min_hd),
           .ps2e_max_hd     (ps2e_max_hd),
           .pcust_tg        (pcust_tg),
           .pvalorrange_tg  (pvalorrange_tg),
           .pe2s_val_tg     (pe2s_val_tg),
           .ps2e_val_tg     (ps2e_val_tg),
           .pe2s_min_tg     (pe2s_min_tg),
           .pe2s_max_tg     (pe2s_max_tg),
           .ps2e_min_tg     (ps2e_min_tg),
           .ps2e_max_tg     (ps2e_max_tg)
           ) 

      u1_sdi_core (
`endif 
            //=====INPUTS
            //===== global input signals
            `ifdef CLKEN
               .ce              (ce),
            `endif 
            //===== transmitter input signals
            `ifdef ENABLETX
               .pdi_clk         (clk_pat_gen),
               .hd_sdn_in       (highd_sdn_in),
               `ifdef ENABLE_LEVELB
                  .lb_lan_in    (levelb_lan_in),
               `endif
               `ifdef PASSTHRU_ENABLE
                  .trs_in       (trs_out_pt),           
                  .pd_in        (pd_out_pt),        
                `else
                  .trs_in       (trs_in_pat),           
                  .pd_in        (pd_in_pat),         
               `endif
               `ifdef SD_TX_10BITS
                  .tx_half_clk  (txhalfclk),
               `endif
               `ifdef SD_LDR
                  .clk27_in     (clk27_in),               
                  `ifdef SDPLL_EXCLUDE
                     .clk270_in (top_clk270_out),
                  `endif
               `endif
               `ifdef PDINSD_PORT
                  .pd_in_sd     (pd_in_sd),
               `endif
               `ifdef ENABLE_VPID_TX
                  .vpid1_in     (vpid1_in),
                  `ifdef ENABLE_LEVELB
                     .vpid2_in  (vpid2_in),
                  `endif
               `endif
            `endif
            `ifdef SDWIDTH_DYN
               .sd8b_mode       (sd8b_mode),        
            `endif
            `ifdef CRCINSERT_DYN
               .crci_en         (crci_en),          
            `endif
            `ifdef LNINSERT_DYN
               .lni_en          (lni_en),           
            `endif
            `ifdef LNINSERT_EN
               `ifdef PASSTHRU_ENABLE
                  .ln1_set       (trs_out_pt),           
                  .ln1_in        (ln1_out_pt),
                  `ifdef ENABLE_LEVELB
                     .ln2_set    (trs_out_pt),
                     .ln2_in     (ln2_out_pt),
                  `endif
               `else
                  .ln1_set       (line_number_set_pat),
                  .ln1_in        (line_number_pat),
                  `ifdef ENABLE_LEVELB
                     .ln2_set    (line_number_set_pat),
                     .ln2_in     (line_number_pat),
                  `endif
               `endif
            `endif
            //===== receiver input signals
            `ifdef ENABLERX
               .rx_clk          (rxhalfclk),
               .rxdata          (rxdata),
               .rx_rate         (rx_rate), 
               `ifdef SD_RX_10BITS
                  .rx_full_clk  (rxfullclk),
               `endif 
            `endif
            `ifdef ENABLETX
               .txdata          (txdata),      
               `ifdef SD_LDR
                  .txd_ldr      (txd_ldr),
                  `ifndef SDPLL_EXCLUDE
                     .clk270_out (clk270_out),
                     .clk27_out (clk27_out),
                  `endif
               `endif
            `endif
            `ifdef ENABLERX
               .pd_out          (pd_out_int),       // receiver parralel output data
               .vid_active      (vidactive_int),    // receiver detected valid video data
               .trs_out         (trs_out_int),      // EAV/SAV TRS detect
               `ifdef ENABLE_LEVELB
                  .ychannel     (ychannel),         // y channel output indicator (place holder-not synchronized!)
                  .rx_lb_lan    (rx_lb_lan_int),   
               `endif
               .rx_tg_hdn       (rx_3g_hdn_int),    // indicates if 3G or HD is being received
               .rx_hd_sdn       (rx_hd_sdn_int),    // indicates if HD or SD is being received
               .vid_format      (vid_format_int),   // Video format 
               .frame_format    (frame_format_int), // Number of fields 
               .field           (field_int),
               .vblank          (vblank_int),
               .hblank          (hblank_int),
               .ln1_out         (ln1_out_int),
               `ifdef ENABLE_LEVELB
                  .ln2_out      (ln2_out_int),      // LN output for stream 2
               `endif
               .eav_error       (eav_error_int),
               .sav_error       (sav_error_int),
               .y1_crc_error    (y1_crc_error),     // CRC error for y channel of stream1
               .c1_crc_error    (c1_crc_error),     // CRC error for c channel of stream1
               `ifdef ENABLE_LEVELB
                  .y2_crc_error (y2_crc_error),     // CRC error for y channel of stream2
                  .c2_crc_error (c2_crc_error),     // CRC error for c channel of stream2
               `endif
               `ifdef ENABLE_VPID_RX
                  .vp1_valid    (vp1_valid),        // VPID valid output for stream 1
                  .vp1_cserr    (vp1_cserr),        // VPID checksum error output for stream 1
                  .vp1_parerr   (vp1_parerr),       // VPID Parity error output for stream 1
                  .vp1_lineok   (vp1_lineok),       // VPID is received in the right line for stream 1 
                  .vpid1_out    (vpid1_out),        // VPID output for stream1
                  `ifdef ENABLE_LEVELB
                     .vp2_valid (vp2_valid),        // VPID valid output for stream 2
                     .vp2_cserr (vp2_cserr),        // VPID checksum error output for stream 2
                     .vp2_parerr(vp2_parerr),       // VPID Parity error output for stream 2
                     .vp2_lineok(vp2_lineok),       // VPID is received in the right line for stream 1 
                     .vpid2_out (vpid2_out),        // VPID output for stream2
                  `endif 
               `endif 
               `ifdef SD_RX_10BITS
                  .pdo_clk      (rx_pdo_clk),
               `endif 
            `endif
            .rstn               (rstn)
            );

      `ifdef ENABLE_LEVELB
         assign crc_error_int = y1_crc_error|c1_crc_error|y2_crc_error|c2_crc_error;
      `else
         assign crc_error_int = y1_crc_error|c1_crc_error;
      `endif

   assign vp1_csperr = vp1_cserr | vp1_parerr;
   assign vp2_csperr = vp2_cserr | vp2_parerr;
     
//======================================================================
//                         SERDES instantiation 
//======================================================================
   //channel 0
   //serdes inputs (Transmit)
      assign rxiclk_ch0        = 1'b0;
      assign txiclk_ch0        = txhalfclk;
      assign fpga_rxrefclk_ch0 = 1'b0;
      assign txdata_ch0        = txdata;
   generate
      if (psd_ldr == 1) begin
         assign txd_ldr_en     = sw1_4 & (~highd_sdn_in); 
         assign txd_ldr_ch0    = (sw1_3==1'b1)?rxd_ldr:txd_ldr; // only for testing
      end
      else begin
         assign txd_ldr_en     = 1'b0;
         assign txd_ldr_ch0    = 1'b0;         
      end
   endgenerate
      
   //serdes outputs
      assign txfullclk         = tx_full_clk_ch0;
      assign txhalfclk         = tx_half_clk_ch0;

   //channel 1 (Receive)
   //serdes inputs
      assign rxiclk_ch1        = rxhalfclk;
      assign txiclk_ch1        = 1'b0;
      assign fpga_rxrefclk_ch1 = ser_rxref_clk;
      assign txdata_ch1        = 'b0;
      assign txd_ldr_ch1       = 1'b0;
   //serdes outputs
      assign rxfullclk         = rx_full_clk_ch1;
      assign rxhalfclk         = rx_half_clk_ch1;
      assign rxdata            = rxdata_ch1;
      assign rx_los            = rx_los_low_ch1_s;

// ------------ SERDES instantiation
   ecp3pcs 
      u1_ecp3pcs (
            //===== differential clock signals
            .refclkp                     (ser_ref_clkp),
            .refclkn                     (ser_ref_clkn),

            //===== channel 0 signals (Transmit)
            .hdinp_ch0                   (hdinp_ch0),
            .hdinn_ch0                   (hdinn_ch0),
            .hdoutp_ch0                  (hdoutp_ch0),
            .hdoutn_ch0                  (hdoutn_ch0),
            .rxiclk_ch0                  (rxiclk_ch0),
            .txiclk_ch0                  (txiclk_ch0),
            .rx_full_clk_ch0             (rx_full_clk_ch0),
            .rx_half_clk_ch0             (rx_half_clk_ch0),
            .tx_full_clk_ch0             (tx_full_clk_ch0),
            .tx_half_clk_ch0             (tx_half_clk_ch0),
            .fpga_rxrefclk_ch0           (fpga_rxrefclk_ch0),
            .txdata_ch0                  (txdata_ch0),
            .rxdata_ch0                  (rxdata_ch0),
            .rx_serdes_rst_ch0_c         (ffc_rrst_0),
            .sb_felb_ch0_c               (1'b0),
            .sb_felb_rst_ch0_c           (1'b0),
            .tx_pcs_rst_ch0_c            (ffc_lane_tx_rst_0),
            .tx_pwrup_ch0_c              (1'b1),
            .rx_pcs_rst_ch0_c            (ffc_lane_rx_rst_0),
            .rx_pwrup_ch0_c              (1'b1),
            .rx_los_low_ch0_s            (),
            .rx_cdr_lol_ch0_s            (),
            .txd_ldr_ch0                 (txd_ldr_ch0),
            .txd_ldr_en_ch0_c            (txd_ldr_en),
            .rxd_ldr_ch0                 (),
            .tx_div11_mode_ch0_c         (~highd_sdn_in),
            .tx_div2_mode_ch0_c          (~threeg_hdn_in),
            .rx_div11_mode_ch0_c         (~rx_hd_sdn_int),
            .rx_div2_mode_ch0_c          (~rx_3g_hdn_int),

            //===== channel 1 signals (Receive)
            .hdinp_ch1                   (hdinp_ch1),
            .hdinn_ch1                   (hdinn_ch1),
            .hdoutp_ch1                  (hdoutp_ch1),
            .hdoutn_ch1                  (hdoutn_ch1),
            .rxiclk_ch1                  (rxhalfclk),
            .txiclk_ch1                  (txhalfclk),
            .rx_full_clk_ch1             (rx_full_clk_ch1),
            .rx_half_clk_ch1             (rx_half_clk_ch1),
            .tx_full_clk_ch1             (tx_full_clk_ch1),
            .tx_half_clk_ch1             (tx_half_clk_ch1),
            .fpga_rxrefclk_ch1           (fpga_rxrefclk_ch1),
            .txdata_ch1                  (txdata_ch1),
            .rxdata_ch1                  (rxdata_ch1),
            .rx_serdes_rst_ch1_c         (ffc_rrst_0),
            .sb_felb_ch1_c               (1'b0),
            .sb_felb_rst_ch1_c           (1'b0),
            .tx_pcs_rst_ch1_c            (ffc_lane_tx_rst_0),
            .tx_pwrup_ch1_c              (1'b1),
            .rx_pcs_rst_ch1_c            (ffc_lane_rx_rst_0),
            .rx_pwrup_ch1_c              (1'b1),
            .rx_los_low_ch1_s            (rx_los_low_ch1_s),
            .rx_cdr_lol_ch1_s            (rx_cdr_lol),
            .txd_ldr_ch1                 (1'b0),
            .txd_ldr_en_ch1_c            (1'b0),
            .rxd_ldr_ch1                 (rxd_ldr),
            .tx_div11_mode_ch1_c         (~highd_sdn_in),
            .tx_div2_mode_ch1_c          (~threeg_hdn_in),
            .rx_div11_mode_ch1_c         (~rx_hd_sdn_int),
            .rx_div2_mode_ch1_c          (~rx_3g_hdn_int),

            // other misc signals
            .tx_serdes_rst_c             (ffc_trst),
            .tx_pll_lol_qd_s             (tx_pll_lol),
            .tx_sync_qd_c                (1'b0),
            .serdes_rst_qd_c             (ffc_macro_rst),
            .rst_qd_c                    (ffc_quad_rst)
            );

//======================================================================
//                          Reset Logic
//======================================================================
// ------------ generating power on reset
   always @(posedge ser_rxref_clk) begin
      if (por_cnt < 'd1000) 
         por_cnt <= por_cnt+1;
   end
   assign por_pulse = ((por_cnt>'d800)&&(por_cnt<'d900))?1'b0:1'b1;
   
// ------------ SERDES receive reset- generating rrst from rx_los
   // code removed; no need for LOS based reset
   
// ------------ SERDES receive reset- generating rrst from rx_lol
   always @(posedge ser_rxref_clk or negedge rstn) begin
      if (rstn == 1'b0)
         trig_cnt <= 'b0;
      else if (clken) begin
         if((rx_cdr_lol==1'b1)&&(wait_en==1'b0))
            trig_cnt <= trig_cnt+1;
         else
            trig_cnt <= 'b0;
      end
   end
   assign trig_cnt_tc = (trig_cnt==((2**ltrig_cnt_width)-3))?1'b1:1'b0;
   
   always @(posedge ser_rxref_clk or negedge rstn) begin
      if (rstn == 1'b0)
         wait_en <= 1'b0;
      else if (clken) begin
         if(trig_cnt_tc==1'b1)
            wait_en <= 1'b1;
         else if (wait_cnt_tc==1'b1)
            wait_en <= 1'b0;
      end
   end
   always @(posedge ser_rxref_clk or negedge rstn) begin // wait counter
      if (rstn == 1'b0)
         wait_cnt <= 'b0;
      else if (clken) begin
         if(wait_en==1'b1)
            wait_cnt <= wait_cnt+1;
         else
            wait_cnt <= 'b0;
      end
   end
   assign wait_cnt_tc = (wait_cnt==((2**lwait_cnt_width)-3))?1'b1:1'b0;

   always @(posedge ser_rxref_clk or negedge rstn) begin
      if (rstn == 1'b0)
         rx_lol_reset <= 1'b0;
      else if (clken) begin
         if((wait_cnt>1024)&&(wait_cnt<1152))
            rx_lol_reset <= 1'b1;
         else
            rx_lol_reset <= 1'b0;
      end
   end

// --------- Assigning SERDES resets   
   assign ffc_macro_rst = ~pb1;
   assign ffc_quad_rst = ~pb1 | (~por_pulse);
   assign ffc_trst = ~pb1;
   assign ffc_lane_tx_rst_0 = ~pb1;

   // Receive resets
   assign ffc_rrst_0 = ~pb2 | rx_lol_reset; 
   assign ffc_lane_rx_rst_0 = ~pb2;

//======================================================================
//                          Pattern Generator
//======================================================================
   assign syncrst  = 1'b0;

`ifndef PASSTHRU_ENABLE   
// ------------ pipeline registers for pat gen inputs
   always @( posedge clk_pat_gen or  negedge rstn ) begin
      if ( rstn == 1'b0) begin
         update_controls_in_rpg   <= 1'b0;
         std_number_rpg           <= 'b0;
         format_sel_3g_rpg        <= 'b0;
         pattern_group_sel_in_rpg <= 1'b0;
         cbtype_smpte_in_rpg      <= 1'b0;
         cbtype_75_in_rpg         <= 1'b0;
         pll_test_only_in_rpg     <= 1'b0;
         equ_test_only_in_rpg     <= 1'b0;
         threeg_hdn_in_rpg        <= 1'b0;
         lb_lan_in_rpg            <= 1'b0;
         hd_sdn_in_rpg            <= 1'b0;
      end
      else if (clken) begin
         update_controls_in_rpg   <= update_controls_in;
         std_number_rpg           <= std_number;
         format_sel_3g_rpg        <= pg_std_numr;
         pattern_group_sel_in_rpg <= pattern_group_sel_in;
         cbtype_smpte_in_rpg      <= cbtype_smpte_in;
         cbtype_75_in_rpg         <= cbtype_75_in;
         pll_test_only_in_rpg     <= pll_test_only_in;
         equ_test_only_in_rpg     <= equ_test_only_in;
         threeg_hdn_in_rpg        <= tg_hdn_in;
         lb_lan_in_rpg            <= levelb_lan_in;
         hd_sdn_in_rpg            <= highd_sdn_in;
      end
   end

// ------------ Pattern Generator Instant
   assign update_mode = 1'b0;
   assign pattern_m_factor = 1'b0;

   pattern_generator  u1_pattern_generator (
          //=====INPUTS
          // reset, clock and clock enable
          .rstn                       (rstn),
          .sync_rst                   (syncrst),
          .clk                        (clk_pat_gen),
          .clken_in                   (clken),

   // controls signal update enable
          .update_controls_in         (update_controls_in_rpg),

   // update mode(1:update at the boundary of the frame, 0:update at the boundary of the line)
          .update_mode                (update_mode),
   
   // the following 5 groups of definition for _b and no _b are the same :
   // no _b : linkA of the dual 292M HD link at 3G level-B mode, or default for all other mode
   // _b : only for 3G level-B, linkB of the dual 292M HD link 
   // pattern group selection (low for color bars, high for pathological test)
          .pattern_group_sel_in       (pattern_group_sel_in_rpg),
          .pattern_group_sel_in_b     (pattern_group_sel_in_rpg),

   // fractional rate selection, 1 : fractional rate; 0 : integral
          .pattern_m_factor           (pattern_m_factor),   

   // color bars type control (00:100%, 01:75%, 1X:smpte)
          .cbtype_smpte_in            (cbtype_smpte_in_rpg),
          .cbtype_smpte_in_b          (cbtype_smpte_in_rpg),
          .cbtype_75_in               (cbtype_75_in_rpg),
          .cbtype_75_in_b             (cbtype_75_in_rpg),

   // pathological type control (00:matrix, 01:equ, 10:pll)
          .pll_test_only_in           (pll_test_only_in_rpg),
          .pll_test_only_in_b         (pll_test_only_in_rpg),
          .equ_test_only_in           (equ_test_only_in_rpg),
          .equ_test_only_in_b         (equ_test_only_in_rpg),

   // sdi/3G control (1 for 3G, 0 for sdi)
          .sdi_3g_in                  (threeg_hdn_in_rpg),
          
   // 3G level-B control (1 for 3G level-B, 0 for 3G level-A)
          .lb_lan_in                  (lb_lan_in_rpg),

   // 3G image formats selection
          .format_sel_3g              (format_sel_3g_rpg), 

   // hd/sd control (1 for hd, o for sd)
          .hd_sdn_in                  (hd_sdn_in_rpg),

   // standard number
          .std_number                 (std_number_rpg),

   // VPID insertin by pattern gen is disabled and VPID by IP is enabled by default
   // VPID insertion enable
          .vpid_insert_en             (1'b0),

   // SMPTE parallel data outputs
          .data_out                   ({ data_out_high, data_out_low }),

   // trs outputs
          .trs_out                    (pat_trs),

   // Signals for line number generation
          .line_number_set            (line_number_set),
          .line_number                (line_number),

   // 4 bytes video payload identifier
          .vpid_in                    (vpid_in),
   
   // field, vblank, hblank outputs
          .field                      (pat_field ),
          .vblank                     (pat_vblank),
          .hblank                     (pat_hblank),

   // signals used for detecting the type of pathological error
          .patho_xyz                  (patho_xyz),
          .patho_trs                  (patho_trs),
          .patho_hbk                  (patho_hbk),
          .patho_equ                  (patho_equ),
          .patho_pll                  (patho_pll),
          .patho_blk                  (patho_blk)
          );
          
      assign pat_dout         = {data_out_high, data_out_low};

// ------------ Registering Pattern Gen Outputs
      always @( posedge clk_pat_gen or  negedge rstn ) begin
         if ( rstn == 1'b0) begin
            pd_in_pat    <= 0;
            trs_in_pat   <= 1'b0;
            line_number_pat       <= 0;
            line_number_set_pat   <= 1'b0;
         end
         else if (clken) begin
            if (syncrst) begin
               pd_in_pat    <= 0;
               trs_in_pat   <= 1'b0;
               line_number_pat       <= 0;
               line_number_set_pat   <= 1'b0;
            end
            else begin
               pd_in_pat  <= pat_dout;
               trs_in_pat <= pat_trs;
               line_number_pat       <= line_number;
               line_number_set_pat   <= line_number_set;
            end
         end
      end

// ------------ Generating update controls input for Pattern Gen 
   always @(posedge clk_pat_gen or negedge rstn) begin
      if (!rstn) begin
         switch_status <= 'h000;
         switch_status_delay1 <= 'h000;
         switch_status_delay2 <= 'h000;
         update_controls_clk_cnt <= 5'b00000;
         update_controls_in <= 1'b1;
      end
      else begin
         switch_status <= {pattern_group_sel_in, levelb_lan_in,tg_hdn_in, highd_sdn_in, cb_patho_type, pg_std_numr};
         // 1+1+1+1+2+5
         switch_status_delay1 <= switch_status;
         switch_status_delay2 <= switch_status_delay1;
         if (update_controls_in == 1'b1) update_controls_clk_cnt <= update_controls_clk_cnt + 1;
         if (switch_status_delay2 != switch_status_delay1) update_controls_in <= 1'b1;
         else if (update_controls_clk_cnt == 5'b11111) update_controls_in <= 1'b0;
      end
   end
`endif // `ifndef PASSTHRU_ENABLE

//======================================================================
//        Receiver 10-bits Conversion, if not done in IP
//======================================================================
// Note: The sync code below is a placeholder that is meant for simulations only
//       This will not work well on the board
   generate 
      if (psd_rx_10bits == 0)  begin
         always @( posedge pdo_clk_o or  negedge rstn ) begin
            if ( rstn == 1'b0) begin
               rx_hd_sdn_int1    <= 1'b0;
               rx_lb_lan_int1    <= 1'b0;
               rx_3g_hdn_int1    <= 1'b0;
               pd_out_int1       <= 'b0;
               vidactive_int1    <= 'b0;
               trs_out_int1      <=  1'b0;
               vid_format_int1   <= 'b0;
               frame_format_int1 <= 'b0;
               field_int1        <= 1'b0;
               vblank_int1       <= 1'b0;
               hblank_int1       <= 1'b0;
               ln1_out_int1      <= 'b0;
               ln2_out_int1      <= 'b0;
               eav_error_int1    <= 1'b0;
               sav_error_int1    <= 1'b0;
               crc_error_int1    <= 1'b0;
            end
            else if (clken) begin
               rx_hd_sdn_int1    <= rx_hd_sdn_int;
               rx_lb_lan_int1    <= rx_lb_lan_int;
               rx_3g_hdn_int1    <= rx_3g_hdn_int;
               pd_out_int1[19:10]<= (rx_hd_sdn) ? pd_out_int[19:10]: 10'b0;
               pd_out_int1[9:0]  <= (rx_hd_sdn) ? pd_out_int[9:0]: ((rxhalfclk) ? pd_out_int[9:0]: pd_out_int[19:10]);
               vidactive_int1    <= vidactive_int;
               trs_out_int1      <= (rx_hd_sdn) ? trs_out_int    : ((rxhalfclk) ? trs_out_int    : 1'b0);
               vid_format_int1   <= vid_format_int;
               frame_format_int1 <= frame_format_int;
               field_int1        <= field_int;
               vblank_int1       <= vblank_int;
               hblank_int1       <= hblank_int;
               ln1_out_int1      <= ln1_out_int;
               ln2_out_int1      <= ln2_out_int;
               eav_error_int1    <= (rx_hd_sdn) ? eav_error_int: ((rxhalfclk) ? eav_error_int: 1'b0);
               sav_error_int1    <= (rx_hd_sdn) ? sav_error_int: ((rxhalfclk) ? sav_error_int: 1'b0);
               crc_error_int1    <= crc_error_int;
            end
         end

         always @(posedge pdo_clk_o or negedge rstn) begin
            if ( rstn == 1'b0) begin
               rx_hd_sdn    <= 1'b0;
               rx_lb_lan    <= 1'b0;
               rx_3g_hdn    <= 1'b0;
               pd_out       <= 'b0;
               vidactive    <= 'b0;
               trs_out      <=  1'b0;
               vid_format   <= 'b0;
               frame_format <= 'b0;
               field        <= 1'b0;
               vblank       <= 1'b0;
               hblank       <= 1'b0;
               ln1_out      <= 1'b0;
               ln2_out      <= 1'b0;
               eav_error    <= 1'b0;
               sav_error    <= 1'b0;
               crc_error    <= 1'b0;
            end
            else if (clken) begin
               rx_hd_sdn    <= rx_hd_sdn_int1;
               rx_lb_lan    <= rx_lb_lan_int1;
               rx_3g_hdn    <= rx_3g_hdn_int1;
               pd_out       <= pd_out_int1;
               vidactive    <= vidactive_int1;
               trs_out      <= trs_out_int1;
               vid_format   <= vid_format_int1;
               frame_format <= frame_format_int1;
               field        <= field_int1;
               vblank       <= vblank_int1;
               hblank       <= hblank_int1;
               ln1_out      <= ln1_out_int1;
               ln2_out      <= ln2_out_int1;
               eav_error    <= eav_error_int1;
               sav_error    <= sav_error_int1;
               crc_error    <= crc_error_int1;
            end
         end
      end
      else begin // if (psd_rx_10bits == 1) 
         always @(*) begin
               rx_hd_sdn    = rx_hd_sdn_int;
               rx_lb_lan    = rx_lb_lan_int;
               rx_3g_hdn    = rx_3g_hdn_int;
               pd_out       = pd_out_int;
               vidactive    = vidactive_int;
               trs_out      = trs_out_int;
               vid_format   = vid_format_int;
               frame_format = frame_format_int;
               field        = field_int;
               vblank       = vblank_int;
               hblank       = hblank_int;
               ln1_out      = ln1_out_int;
               ln2_out      = ln2_out_int;
               eav_error    = eav_error_int;
               sav_error    = sav_error_int;
               crc_error    = crc_error_int;
         end 
      end 
   endgenerate //  if (psd_rx_10bits == 0) 
// --- end of Receiver 10-bits Conversion, if not done in IP

//======================================================================
//               Tx to Rx Self Checking for Simulation
//======================================================================
`ifdef DPRAM_SELFCHK_TST
// ------------ Tx/Rx testing using EBR 
// Logic to test the Rx data against the Tx data using dual port memory
   pmi_ram_dp #(
           .pmi_wr_addr_depth   (2**lramaddr_width ),
           .pmi_wr_addr_width   (lramaddr_width    ),
           .pmi_wr_data_width   (ldatawidth        ),
           .pmi_rd_addr_depth   (2**lramaddr_width ),
           .pmi_rd_addr_width   (lramaddr_width    ),
           .pmi_rd_data_width   (ldatawidth        ),
           .pmi_regmode         ("reg"             ),
           .pmi_gsr             ("disable"         ),
           .pmi_resetmode       ("sync"            ),
           .pmi_init_file       ("none"            ),
           .pmi_init_file_format("binary"          ),
           .pmi_family          (pdevice_family    ),
           .module_type         ("pmi_ram_dp"      )
           )

       u1_pmi_ram_dp   (
           .WrAddress           (wraddr      ),
           .Data                (pat_dout    ),
           .WE                  (1'b1        ),
           .WrClock             (clk_pat_gen ),
           .WrClockEn           (1'b1        ),
           .RdAddress           (rdaddr      ),
           .RdClock             (pdo_clk_o   ),
           .RdClockEn           (1'b1        ),
           .Reset               (~rstn       ),
           .Q                   (pat_dout_del)
           );

// determining tx_sav, synchronizing write pointer
      always @( posedge clk_pat_gen or  negedge rstn ) begin
         if ( rstn == 1'b0) begin
            pat_trs_p1 <= 1'b0;
            pat_trs_p2 <= 1'b0;
            pat_trs_p3 <= 1'b0;
            pat_trs_p4 <= 1'b0;
            pat_trs_p5 <= 1'b0;
            pat_trs_p6 <= 1'b0;
            tx_sav     <= 1'b0;
            fst_tsav_after_vidac <= 1'b0;
            wraddr     <= 'b0;
         end
         else if (clken) begin
            pat_trs_p1 <= pat_trs;
            pat_trs_p2 <= pat_trs_p1;
            pat_trs_p3 <= pat_trs_p2;
            pat_trs_p4 <= pat_trs_p3;
            pat_trs_p5 <= pat_trs_p4;
            pat_trs_p6 <= pat_trs_p5;
            tx_sav     <= (lb_lan_in_rpg==1'b1)? (pat_trs_p6 & ~pat_dout[6]) : (pat_trs_p3 & ~pat_dout[6]);
            if (!vidactive)
               fst_tsav_after_vidac <= 1'b0;
            else if (tx_sav)
               fst_tsav_after_vidac <= 1'b1;
            if (vidactive) begin
               if ((tx_sav)&&(!fst_tsav_after_vidac))
                  wraddr <= 'b0;
               else
                  wraddr <= wraddr + 1'b1;
            end
         end
      end

// Disable checking during the times when IP has CRC words and pattern generator did not have CRC
      always @(posedge pdo_clk_o or negedge rstn) begin
         if (rstn == 1'b0)
            crc_dis <= 1'b0;
         else if (clken) begin
            if(rx_hd_sdn==1'b1) begin
               if ((rx_lb_lan&rx_eav_p6)|(~rx_lb_lan&rx_eav_p4))
                  crc_dis <= 1'b1;
               else if ((rx_lb_lan&rx_eav_p10)|(~rx_lb_lan&rx_eav_p6))
                  crc_dis <= 1'b0;
            end
         end
      end

// Disable checking of data when VPID is in IP's data and no VPID in PG data 
   generate
   if (penable_vpid_tx == 1) begin
      always @(posedge pdo_clk_o or negedge rstn) begin
         if (rstn == 1'b0) begin
            vpid_cnten <= 1'b0;
            vpid_cnt <= 'b0;
         end
         else if (clken) begin
            if(rx_hd_sdn==1'b1) begin
               if((rx_lb_lan&rx_eav_p10)|(~rx_lb_lan&rx_eav_p6))
                  vpid_cnten <= 1'b1;
               if((rx_lb_lan&(vpid_cnt==21))||(~rx_lb_lan&(vpid_cnt==10)) )
                  vpid_cnten <= 1'b0;
               if(vpid_cnten==1'b1)
                  vpid_cnt <= vpid_cnt+1;
               else
                  vpid_cnt <= 'b0;
            end
         end
      end
      assign vpid_dis = (rx_lb_lan)? (vpid_cnten&vpid_cnt[0]):vpid_cnten;
      assign dis_pdout_errchk = crc_dis | vpid_dis;
   end  // if (penable_vpid_tx == 1)
   else begin
      assign dis_pdout_errchk = crc_dis;
   end  // if not (penable_vpid_tx == 1)
   endgenerate 
   
               
      always @( posedge pdo_clk_o or  negedge rstn ) begin
         if ( rstn == 1'b0) begin
            trs_out_p1 <= 1'b0;
            trs_out_p2 <= 1'b0;
            trs_out_p3 <= 1'b0;
            trs_out_p4 <= 1'b0;
            trs_out_p5 <= 1'b0;
            trs_out_p6 <= 1'b0;
            rx_sav     <= 1'b0;
            rx_eav     <= 1'b0;
            rx_eav_p1  <= 1'b0;
            rx_eav_p2  <= 1'b0;
            rx_eav_p3  <= 1'b0;
            rx_eav_p4  <= 1'b0;
            rx_eav_p5  <= 1'b0;
            rx_eav_p6  <= 1'b0;
            rx_eav_p7  <= 1'b0;
            rx_eav_p8  <= 1'b0;
            rx_eav_p9  <= 1'b0;
            rx_eav_p10 <= 1'b0;
            fst_rsav_after_vidac <= 1'b0;
            fst_rsav_after_vidac_p1 <= 1'b0;
            fst_rsav_after_vidac_p2 <= 1'b0;
            fst_rsav_after_vidac_p3 <= 1'b0;
            rdaddr     <= 'b10;
            pd_out_p1  <= 'b0;
            pd_out_p2  <= 'b0;
            pdout_error_low_hd <= 1'b0;
            pdout_error_low_sd <= 1'b0;
            pdout_error_high<= 1'b0;
            test_errori <= 1'b0;
            test_error  <= 1'b0;
            fst_rsav_after_vidac_d1 <= 1'b0;
            fst_rsav_after_vidac_d2 <= 1'b0;
         end
         else if (clken) begin
            trs_out_p1 <= trs_out;
            trs_out_p2 <= trs_out_p1;
            trs_out_p3 <= trs_out_p2;
            trs_out_p4 <= trs_out_p3;
            trs_out_p5 <= trs_out_p4;
            trs_out_p6 <= trs_out_p5;
            rx_sav     <= (rx_lb_lan==1'b1)?(trs_out_p6 & ~pd_out[6]):(trs_out_p3 & ~pd_out[6]);
            rx_eav     <= (rx_lb_lan==1'b1)?(trs_out_p6 &pd_out[6]):(trs_out_p3 &pd_out[6]);
            rx_eav_p1  <= rx_eav;
            rx_eav_p2  <= rx_eav_p1;
            rx_eav_p3  <= rx_eav_p2;
            rx_eav_p4  <= rx_eav_p3;
            rx_eav_p5  <= rx_eav_p4;
            rx_eav_p6  <= rx_eav_p5;
            rx_eav_p7  <= rx_eav_p6;
            rx_eav_p8  <= rx_eav_p7;
            rx_eav_p9  <= rx_eav_p8;
            rx_eav_p10 <= rx_eav_p9;
            fst_rsav_after_vidac_p1 <= fst_rsav_after_vidac;
            fst_rsav_after_vidac_p2 <= fst_rsav_after_vidac_p1;
            fst_rsav_after_vidac_p3 <= fst_rsav_after_vidac_p2;

            if (!vidactive)
               fst_rsav_after_vidac <= 1'b0;
            else if (rx_sav&&fst_tsav_after_vidac)
               fst_rsav_after_vidac <= 1'b1;
            if (vidactive) begin
               if ((rx_sav)&&(!fst_rsav_after_vidac))
                  rdaddr <= 'b0; 
               else
                  rdaddr <= rdaddr + 1'b1;
            end
            pd_out_p1    <= pd_out;
            pd_out_p2    <= pd_out_p1;
            pdout_error_low_sd <= (pd_out_p2[9:2] == pat_dout_del[9:2]) ? 0 : 1; 
            pdout_error_low_hd <= (pd_out_p2[9:0] == pat_dout_del[9:0]) ? 0 : 1;
            pdout_error_high   <= (pd_out_p2[19:10] == pat_dout_del[19:10]) ? 0 : 1; 
            test_errori  <=  ((rx_hd_sdn)&(!dis_pdout_errchk)&(pdout_error_low_hd|pdout_error_high) | (!rx_hd_sdn)&(pdout_error_low_sd)) & fst_rsav_after_vidac_p3 & vidactive & (highd_sdn_in==rx_hd_sdn_p4) & (threeg_hdn_in==rx_3g_hdn_p4);
            test_error   <= test_errori & fst_rsav_after_vidac_d2;
            if (rx_sav)
               fst_rsav_after_vidac_d1 <= fst_rsav_after_vidac;
            if (rx_sav)
               fst_rsav_after_vidac_d2 <= fst_rsav_after_vidac_d1;
         end
      end

   assign pat_dout_del_lo = pat_dout_del[9:0];
   assign pat_dout_del_hi = pat_dout_del[19:10];
   assign pd_out_p2_lo    = pd_out_p2[9:0];
   assign pd_out_p2_hi    = pd_out_p2[19:10];
   assign pat_dout_lo     = pat_dout[9:0];
   assign pat_dout_hi     = pat_dout[19:10];

   always @(posedge pdo_clk_o or negedge rstn) begin
      if (rstn == 1'b0) begin
         rx_3g_hdn_p1 <= 1'b0;
         rx_3g_hdn_p2 <= 1'b0;
         rx_3g_hdn_p3 <= 1'b0;
         rx_3g_hdn_p4 <= 1'b0;
         rx_hd_sdn_p1 <= 1'b0;
         rx_hd_sdn_p2 <= 1'b0;
         rx_hd_sdn_p3 <= 1'b0;
         rx_hd_sdn_p4 <= 1'b0;
      end
      else if (clken) begin
         rx_3g_hdn_p1 <= rx_3g_hdn;
         rx_3g_hdn_p2 <= rx_3g_hdn_p1;
         rx_3g_hdn_p3 <= rx_3g_hdn_p2;
         rx_3g_hdn_p4 <= rx_3g_hdn_p3;
         rx_hd_sdn_p1 <= rx_hd_sdn;
         rx_hd_sdn_p2 <= rx_hd_sdn_p1;
         rx_hd_sdn_p3 <= rx_hd_sdn_p2;
         rx_hd_sdn_p4 <= rx_hd_sdn_p3;
      end
   end
`endif 

//======================================================================
//                        Passthrough Mode FIFO
//======================================================================
`ifdef PASSTHRU_ENABLE
// ============ Buffer the receive data and then transmit  
// ------------ Data FIFO
   pmi_ram_dp #(
           .pmi_wr_addr_depth   (2**lramaddr_width_pt ),
           .pmi_wr_addr_width   (lramaddr_width_pt    ),
           .pmi_wr_data_width   (ldatawidth+1         ),
           .pmi_rd_addr_depth   (2**lramaddr_width_pt ),
           .pmi_rd_addr_width   (lramaddr_width_pt    ),
           .pmi_rd_data_width   (ldatawidth+1         ),
           .pmi_regmode         ("reg"                ),
           .pmi_gsr             ("disable"            ),
           .pmi_resetmode       ("sync"               ),
           .pmi_init_file       ("none"               ),
           .pmi_init_file_format("binary"             ),
           .pmi_family          (pdevice_family       ),
           .module_type         ("pmi_ram_dp")
           )

       u10_pmi_ram_dp   (
           .WrAddress           (wraddr_pt   ),
           .Data                ({pd_out,trs_out}  ),
           .WE                  (1'b1        ),
           .WrClock             (pdo_clk_o   ),
           .WrClockEn           (1'b1        ),
           .RdAddress           (rdaddr_pt   ),
           .RdClock             (clk_pat_gen ),
           .RdClockEn           (1'b1        ),
           .Reset               (~rstn       ),
           .Q                   ({pd_out_pt,trs_out_pt} )
           );
// ------------ ln1_out, ln2_out and trs_out FIFO
   pmi_ram_dp #(
           .pmi_wr_addr_depth   (2**lramaddr_width_pt ),
           .pmi_wr_addr_width   (lramaddr_width_pt    ),
        `ifdef ENABLE_LEVELB
           .pmi_wr_data_width   (22                   ), //11+11
           .pmi_rd_data_width   (22                   ),
        `else
           .pmi_wr_data_width   (11                   ), //11
           .pmi_rd_data_width   (11                   ),
        `endif
           .pmi_rd_addr_depth   (2**lramaddr_width_pt ),
           .pmi_rd_addr_width   (lramaddr_width_pt    ),
           .pmi_regmode         ("reg"                ),
           .pmi_gsr             ("disable"            ),
           .pmi_resetmode       ("sync"               ),
           .pmi_init_file       ("none"               ),
           .pmi_init_file_format("binary"             ),
           .pmi_family          (pdevice_family       ),
           .module_type         ("pmi_ram_dp"         )
           )

       u11_pmi_ram_dp   (
           .WrAddress           (wraddr_pt    ),
        `ifdef ENABLE_LEVELB
           .Data                ({ln1_out,ln2_out}),
           .Q                   ({ln1_out_pt,ln2_out_pt}),
        `else
           .Data                (ln1_out      ),
           .Q                   (ln1_out_pt   ),
        `endif
           .WE                  (1'b1         ),
           .WrClock             (pdo_clk_o    ),
           .WrClockEn           (1'b1         ),
           .RdAddress           (rdaddr_pt_ln ),
           .RdClock             (clk_pat_gen  ),
           .RdClockEn           (1'b1         ),
           .Reset               (~rstn        )
           );

// ------------ Write address
   always @( posedge pdo_clk_o or negedge rstn) begin
      if (rstn == 1'b0) 
         wraddr_pt    <= 'b0;
      else if (clken)
         wraddr_pt <= wraddr_pt + 1'b1;
   end

// ------------ Read address
   always @(posedge clk_pat_gen or negedge rstn) begin
      if (rstn == 1'b0) begin
//         rdaddr_pt[lramaddr_width_pt-2:0] <= 'b0;
//         rdaddr_pt[lramaddr_width_pt-1]   <= 1'b1;
         rdaddr_pt  <= lrd_ptr_initd;
         rdaddr_pt_ln  <= lrd_ptr_initln;
      end
      else if (clken) begin
         rdaddr_pt <= rdaddr_pt + 1'b1;
         rdaddr_pt_ln <= rdaddr_pt_ln + 1'b1;
      end
   end

`endif 

//======================================================================
//                   Fractional frame rate determination
//======================================================================
`ifdef RUN_SYN
   frac_det #(
      .pfrac_intn  (pfrac_intn)
      )
      frac_det_u1 (
      //=====INPUTS
      .ref_clk     (ser_rxref_clk),   // Reference clock (148.5 or 148.35)    
      .rec_clk     (rxhalfclk),       // Recovered clock ( (div2_mode) ? 74.25 : 148.5 )
      .rstn        (rstn),            // system reset
      .ce          (clken),           // clock enable
      .rx_tg_hdn   (rx_3g_hdn_int),   // 3G or HD (0- HD, 1-3G)
               
      //=====OUTPUTS
      .frac_intn   (frac_intn),       // fractional or internal (0-int, 1-frac)
      .out_valid   ()                 // output valid
      );
`endif 

//======================================================================
//                            LCD Display Module
//======================================================================
`ifdef RUN_SYN
   assign lcd_rstn = rstn;
// ------------ LCD instance
   stat_disp stat_disp_u1 (
      .clk            (clk_100),    // system clock- 100 MHz
      .rstn           (lcd_rstn),   // system reset
      .next_disp      (pb4),        // Next display screen pulse
      .err_rstn       (pb3),
      .crc_error      (crc_error),  // CRC error
      .sav_error      (sav_error),  // SAV error
      .eav_error      (eav_error),  // EAV error
      .vp_valid       (vp1_valid),
      .vp_cserr       (vp1_csperr),
      .rx_vpid        (vpid1_out),
      .vpid_in        (vpid1_in),
      .frac_intn_in   (1'b0),       // Tx side frac or int
      .levelb_lan_in  (levelb_lan_in),
      .threeg_hdn_in  (tg_hdn_in),
      .highd_sdn_in   (highd_sdn_in),
      .pg_std_num     (pg_std_numr),
      .lock           (vidactive),  // lock signal
      .vid_format     (vid_format), // Video format
      .frame_format   (frame_format),  // Frame format
      .rx_lb_lan      (rx_lb_lan_int),
      .rx_tg_hdn      (rx_3g_hdn_int), // Whether Rx rate is 3G or HD
      .rx_hd_sdn      (rx_hd_sdn_int), // Whether Rx rate is HD or SD
      .frac_intn      (frac_intn),

      .lcd0           (lcd0),       // LCD0 output-  lcd_r/w
      .lcd1           (lcd1),       // LCD1 output-  lcd_db0
      .lcd2           (lcd2),       // LCD2 output-  lcd_db2
      .lcd3           (lcd3),       // LCD3 output-  lcd_db4
      .lcd4           (lcd4),       // LCD4 output-  lcd_db6
      .lcd5           (lcd5),       // LCD5 output-  lcd_rs
      .lcd6           (lcd6),       // LCD6 output-  lcd_e
      .lcd7           (lcd7),       // LCD7 output-  lcd_db1
      .lcd8           (lcd8),       // LCD8 output-  lcd_db3
      .lcd9           (lcd9),       // LCD9 output-  lcd_db5
      .lcd10          (lcd10)       // LCD10 output- lcd_db7
      );
`endif  // `ifdef RUN_SYN

endmodule 