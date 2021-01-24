// $Id: $
// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2000-2009 (c) Lattice Semiconductor Corporation
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
// Project               : Tri-Rate SDI PHY
// File                  : stat_disp.v
// Title                 : Status display module 
// Dependencies          : 1. lcdtop.v 
//                       : 2. PLL 
// Description           : Displays the status of SDI Rx in the LCD module 
// =============================================================================
//                        REVISION HISTORY
// Version               : 0.1
// Changes Made          : Initial Creation
// Author(s)             : Babu Mailachalam
// Mod. Date             : August 3, 2007
// ------------------------------------------------
// Version               : 0.2
// Changes Made          : Level-B/VPID modifications
// Author(s)             : Babu Mailachalam
// Mod. Date             : July 28, 2009
// =============================================================================

`timescale 1 ns/ 1ns

module stat_disp (
      clk,       // system clock- 100 MHz
      rstn,      // system reset
      next_disp, // Next display screen pulse
      err_rstn,  // reset display errors
      crc_error, // CRC error
      sav_error, // SAV error
      eav_error, // EAV error
      vp_valid,
      vp_cserr,
      rx_vpid,
      vpid_in,
      frac_intn_in,
      levelb_lan_in,
      threeg_hdn_in,
      highd_sdn_in,
      pg_std_num,
      lock,      // lock signal
      vid_format,  // current state
      frame_format,// detected standard
      rx_lb_lan,
      rx_hd_sdn,
      rx_tg_hdn,
      frac_intn,
      lcd0,      // LCD0 output- lcd_r/w
      lcd1,      // LCD1 output- lcd_db0
      lcd2,      // LCD2 output- lcd_db2
      lcd3,      // LCD3 output- lcd_db4
      lcd4,      // LCD4 output- lcd_db6
      lcd5,      // LCD5 output- lcd_rs
      lcd6,      // LCD6 output- lcd_e
      lcd7,      // LCD7 output- lcd_db1
      lcd8,      // LCD8 output- lcd_db3
      lcd9,      // LCD9 output- lcd_db5
      lcd10      // LCD10 output- lcd_db7
      );

// ------------ input ports
   input                         clk;    // 100 MHz clock
   input    	                 rstn;
   input                         next_disp;
   input                         err_rstn;
   input                         crc_error;
   input                         sav_error;
   input                         eav_error;
   input                         vp_valid;
   input                         vp_cserr;
   input   [31:0]                rx_vpid;
   input   [31:0]                vpid_in;
   input                         frac_intn_in;
   input    	                 levelb_lan_in;
   input    	                 threeg_hdn_in;
   input    	                 highd_sdn_in;
   input   [4:0]                 pg_std_num;
   input    	                 lock;
   input   [1:0]                 vid_format;
   input   [2:0]                 frame_format;
   input    	                 rx_lb_lan;
   input    	                 rx_hd_sdn;
   input    	                 rx_tg_hdn;
   input    	                 frac_intn;

// ------------ output ports
   output                        lcd0;  // lcd_r/w
   output                        lcd5;  // lcd_rs
   output                        lcd6;  // lcd_e
   output                        lcd1;  // lcd_db0
   output                        lcd2;  // lcd_db2
   output                        lcd3;  // lcd_db4
   output                        lcd4;  // lcd_db6
   output                        lcd7;  // lcd_db1
   output                        lcd8;  // lcd_db3
   output                        lcd9;  // lcd_db5
   output                        lcd10; // lcd_db7

// ------------ local parameters
`ifdef DO_SIM
   localparam lc100_tc = 9999;
`else
   localparam lc100_tc = 99999;
`endif

   localparam licnt_tc = 14;
   localparam _0 = 8'b00110000;
   localparam _1 = 8'b00110001;
   localparam _2 = 8'b00110010;
   localparam _3 = 8'b00110011;
   localparam _4 = 8'b00110100;
   localparam _5 = 8'b00110101;
   localparam _6 = 8'b00110110;
   localparam _7 = 8'b00110111;
   localparam _8 = 8'b00111000;
   localparam _9 = 8'b00111001;

   localparam _A = 8'b01000001;
   localparam _B = 8'b01000010;
   localparam _C = 8'b01000011;
   localparam _D = 8'b01000100;
   localparam _E = 8'b01000101;
   localparam _F = 8'b01000110;
   localparam _G = 8'b01000111;
   localparam _H = 8'b01001000;
   localparam _I = 8'b01001001;
   localparam _J = 8'b01001010;
   localparam _K = 8'b01001011;
   localparam _L = 8'b01001100;
   localparam _M = 8'b01001101;
   localparam _N = 8'b01001110;
   localparam _O = 8'b01001111;
   localparam _P = 8'b01010000;
   localparam _Q = 8'b01010001;
   localparam _R = 8'b01010010;
   localparam _S = 8'b01010011;
   localparam _T = 8'b01010100;
   localparam _U = 8'b01010101;
   localparam _V = 8'b01010110;
   localparam _W = 8'b01010111;
   localparam _X = 8'b01011000;
   localparam _Y = 8'b01011001;
   localparam _Z = 8'b01011010;

   localparam _a = 8'b01100001;
   localparam _b = 8'b01100010;
   localparam _c = 8'b01100011;
   localparam _d = 8'b01100100;
   localparam _e = 8'b01100101;
   localparam _f = 8'b01100110;
   localparam _g = 8'b01100111;
   localparam _h = 8'b01101000;
   localparam _i = 8'b01101001;
   localparam _j = 8'b01101010;
   localparam _k = 8'b01101011;
   localparam _l = 8'b01101100;
   localparam _m = 8'b01101101;
   localparam _n = 8'b01101110;
   localparam _o = 8'b01101111;
   localparam _p = 8'b01110000;
   localparam _q = 8'b01110001;
   localparam _r = 8'b01110010;
   localparam _s = 8'b01110011;
   localparam _t = 8'b01110100;
   localparam _u = 8'b01110101;
   localparam _v = 8'b01110110;
   localparam _w = 8'b01110111;
   localparam _x = 8'b01111000;
   localparam _y = 8'b01111001;
   localparam _z = 8'b01111010;

   localparam _sp = 8'b00100000; // space
   localparam _dp = 8'b00101110; // decimal point
   localparam _ds = 8'b00101101; // dash
   localparam _us = 8'b01011111; // underscore
   localparam _ra = 8'b01111110; // right arrow
   localparam _la = 8'b01111111; // left arrow
   localparam _cn = 8'b00111010; // Colon
   
// ------------ internal registers and wires
   wire                          clk;

   wire                          lcd0;
   wire                          lcd1;
   wire                          lcd2;
   wire                          lcd3;
   wire                          lcd4;
   wire                          lcd5;
   wire                          lcd6;
   wire                          lcd7;
   wire                          lcd8;
   wire                          lcd9;
   wire                          lcd10;
   wire    [7:0]                 wraddr;
   reg     [7:0]                 wrdata;
   wire                          wren;
   reg     [4:0]                 mem_cnt;
   wire                          mcnt_tc;
   reg     [127:0]               mem_line1;
   reg     [127:0]               mem_line2;
   reg                           next_disp_p1;
   reg                           next_disp_p2;
   reg                           next_disp_p3;
   wire                          nd_pulse;
   reg     [1:0]                 disp_page;
   reg     [3:0]                 pav_erru;
   reg     [3:0]                 pav_errt;
   reg     [3:0]                 pav_errh;
   wire                          pav_utc;
   wire                          pav_ttc;
   wire                          pav_htc;
   reg     [3:0]                 crc_erru;
   reg     [3:0]                 crc_errt;
   reg     [3:0]                 crc_errh;
   wire                          crc_utc;
   wire                          crc_ttc;
   wire                          crc_htc;
   reg     [13:0]                div_10k;
   reg     [13:0]                div_100m;
   wire                          tc_10k;
   wire                          tc_100m;
   wire                          sh_sec;
   reg     [3:0]                 minu;
   reg     [2:0]                 mint;
   reg     [3:0]                 hour;
   wire                          minu_tc;
   wire                          mint_tc;
   wire                          hour_tc;
   reg     [5:0]                 secs;
   wire                          secs_tc;

// ------------------------- Start of Code ------------------------------

// ------------ wraddr, wrdata and wren
   assign wraddr={3'b000,mem_cnt};
   assign wren=1'b1;

// ------------ Keeping tab of the display screen
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0) begin
         next_disp_p1 <= 1'b1;
         next_disp_p2 <= 1'b1;
         next_disp_p3 <= 1'b1;
      end
      else begin
         next_disp_p1 <= next_disp;
         next_disp_p2 <= next_disp_p1;
         next_disp_p3 <= next_disp_p2;
      end
   end
   assign nd_pulse = next_disp_p2 & ~next_disp_p3;
   
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0) 
         disp_page <= 'b0;
      else if (nd_pulse==1'b1)
         disp_page <= disp_page+1;
   end

// ------------ LCD top instantiation
   lcdiface lcdiface_u1 (
      .clk(clk),        // system clock- 100 MHz
      .rstn(rstn),      // system reset
      .wraddr(wraddr),  // write address for RAM
      .wrdata(wrdata),  // write data for RAM
      .wren(wren),      // write enable for RAM
      .lcd0(lcd0),      // LCD0 output- lcd_r/w
      .lcd1(lcd1),      // LCD1 output- lcd_db0
      .lcd2(lcd2),      // LCD2 output- lcd_db2
      .lcd3(lcd3),      // LCD3 output- lcd_db4
      .lcd4(lcd4),      // LCD4 output- lcd_db6
      .lcd5(lcd5),      // LCD5 output- lcd_rs
      .lcd6(lcd6),      // LCD6 output- lcd_e
      .lcd7(lcd7),      // LCD7 output- lcd_db1
      .lcd8(lcd8),      // LCD8 output- lcd_db3
      .lcd9(lcd9),      // LCD9 output- lcd_db5
      .lcd10(lcd10)     // LCD10 output- lcd_db7
      );

// ------------ Writing to LCD memory
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         mem_cnt <= 'b0;
      else if(mcnt_tc==1'b1)
         mem_cnt <= 'b0;
      else
         mem_cnt <= mem_cnt+1;
   end
   assign mcnt_tc=(mem_cnt==31)?1'b1:1'b0;

// ------------ mem array splitting
   always @(*) begin
      case(mem_cnt)
         0:  wrdata = mem_line1[127:120];
         1:  wrdata = mem_line1[119:112];
         2:  wrdata = mem_line1[111:104];
         3:  wrdata = mem_line1[103:96];
         4:  wrdata = mem_line1[95:88];
         5:  wrdata = mem_line1[87:80];
         6:  wrdata = mem_line1[79:72];
         7:  wrdata = mem_line1[71:64];
         8:  wrdata = mem_line1[63:56];
         9:  wrdata = mem_line1[55:48];
         10: wrdata = mem_line1[47:40];
         11: wrdata = mem_line1[39:32];
         12: wrdata = mem_line1[31:24];
         13: wrdata = mem_line1[23:16];
         14: wrdata = mem_line1[15:8];
         15: wrdata = mem_line1[7:0];

         16: wrdata = mem_line2[127:120];
         17: wrdata = mem_line2[119:112];
         18: wrdata = mem_line2[111:104];
         19: wrdata = mem_line2[103:96];
         20: wrdata = mem_line2[95:88];
         21: wrdata = mem_line2[87:80];
         22: wrdata = mem_line2[79:72];
         23: wrdata = mem_line2[71:64];
         24: wrdata = mem_line2[63:56];
         25: wrdata = mem_line2[55:48];
         26: wrdata = mem_line2[47:40];
         27: wrdata = mem_line2[39:32];
         28: wrdata = mem_line2[31:24];
         29: wrdata = mem_line2[23:16];
         30: wrdata = mem_line2[15:8];
         31: wrdata = mem_line2[7:0];
         default: wrdata = _X;
      endcase
   end

// ------------ Decimal counters for placer error
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0) begin
         pav_erru <= 'b0;
         pav_errt <= 'b0;
         pav_errh <= 'b0;
      end
      else if(err_rstn==1'b0) begin
         pav_erru <= 'b0;
         pav_errt <= 'b0;
         pav_errh <= 'b0;
      end
      else if (sav_error|eav_error) begin
         if (pav_utc&pav_ttc&pav_htc)
            pav_erru <= 9;
         else if (pav_utc)
            pav_erru <= 'b0;
         else
            pav_erru <= pav_erru+1;
            
         if (pav_utc) begin
            if (pav_ttc&pav_htc)
               pav_errt <= 9;
            else if (pav_ttc)
               pav_errt <= 'b0;
            else
               pav_errt <= pav_errt+1;
         end
            
         if (pav_utc&pav_ttc) begin
            if (pav_htc)
               pav_errh <= 9;
            else
               pav_errh <= pav_errh+1;
         end
      end
   end
   assign pav_utc = (pav_erru==9);
   assign pav_ttc = (pav_errt==9);
   assign pav_htc = (pav_errh==9);

   
// ------------ Decimal counters for CRC error
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0) begin
         crc_erru <= 'b0;
         crc_errt <= 'b0;
         crc_errh <= 'b0;
      end
      else if(err_rstn==1'b0) begin
         crc_erru <= 'b0;
         crc_errt <= 'b0;
         crc_errh <= 'b0;
      end
      else if (crc_error) begin
         if (crc_utc&crc_ttc&crc_htc)
            crc_erru <= 9;
         else if (crc_utc)
            crc_erru <= 'b0;
         else
            crc_erru <= crc_erru+1;
            
         if (crc_utc) begin
            if (crc_ttc&crc_htc)
               crc_errt <= 9;
            else if (crc_ttc)
               crc_errt <= 'b0;
            else 
               crc_errt <= crc_errt+1;
         end
            
         if (crc_utc&crc_ttc) begin
            if (crc_htc)
               crc_errh <= 9;
            else 
               crc_errh <= crc_errh+1;
         end
      end
   end
   assign crc_utc = (crc_erru==9);
   assign crc_ttc = (crc_errt==9);
   assign crc_htc = (crc_errh==9);
   
// ------------ Time counters
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0) begin
         div_10k  <= 'b0;
         div_100m <= 'b0;
         secs     <= 'b0;
      end
      else if(err_rstn==1'b0) begin
         div_10k  <= 'b0;
         div_100m <= 'b0;
         secs     <= 'b0;
      end
      else begin
         if(tc_10k)
            div_10k  <= 'b0;
         else
            div_10k  <= div_10k+1;
            
         if(tc_10k&tc_100m)
            div_100m <= 'b0;
         else if (tc_10k)
            div_100m <= div_100m+1;

         if(tc_10k&tc_100m) begin
            if (secs_tc)
               secs <= 'b0;
            else
               secs <= secs+1;
         end
      end
   end
   assign tc_10k  = (div_10k==9999);
   assign tc_100m = (div_100m==9999);
   assign sh_sec  = (div_100m>=5000);
   assign secs_tc = (secs==59); 
   
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0) begin
         minu <= 'b0;
         mint <= 'b0;
         hour <= 'b0;
      end
      else if(err_rstn==1'b0)begin
         minu <= 'b0;
         mint <= 'b0;
         hour <= 'b0;
      end
      else if (tc_10k&tc_100m&secs_tc) begin
         if (minu_tc&mint_tc&hour_tc)
            minu <= 9;
         else if (minu_tc)
            minu <= 'b0;
         else
            minu <= minu+1;
            
         if(minu_tc) begin
            if (mint_tc&hour_tc)
               mint <= 5;
            else if (mint_tc)
               mint <= 'b0;
            else 
               mint <= mint+1;
         end
         
         if (minu_tc&mint_tc) begin
            if (hour_tc)
               hour <= 9;
            else 
               hour <= hour+1;
         end
      end
   end
   assign minu_tc = (minu==9);
   assign mint_tc = (mint==5);
   assign hour_tc = (hour==9);
   
// ------------ LCD first line data for Tx
// constant Tx display (0,1,2)
// Line 1- 0
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         mem_line1[127:120] <= 'b0;
      else if (disp_page[1]==0)
         mem_line1[127:120] <= _T;
      else if (disp_page==2'b10)
         mem_line1[127:120] <= _R;
      else
         mem_line1[127:120] <= _P;
   end

// Line 1- 1
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         mem_line1[119:112] <= 'b0;
      else if (disp_page[1]==0)
         mem_line1[119:112] <= _ra;
      else if (disp_page==2'b10) begin
         if(vp_cserr)
            mem_line1[119:112] <= _ds;
         else
            mem_line1[119:112] <= _la;
      end
      else 
         mem_line1[119:112] <= _C;
   end

// Line 1- 2,3
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         mem_line1[111:96] <= 'b0;
      else begin
         if(disp_page==2'b00)
            casex({levelb_lan_in,threeg_hdn_in,highd_sdn_in})
            3'b000:   mem_line1[111:96] <= {_sp, _S};
            3'b001:   mem_line1[111:96] <= {_sp, _H};
            3'b011,3'b101,3'b111:   mem_line1[111:96] <= { _3, _G};
            default: mem_line1[111:96] <= {_sp, _x};
            endcase
         else if(disp_page==2'b11)
            mem_line1[111:96] <= { _T,_la};
         else
            mem_line1[111:96] <= { _V, _P};
      end
   end

// Line 1, 4 thru 15

   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         mem_line1[95:0] <= 'b0;
      else begin
      if(disp_page==2'b00) // Tx standards display
         casex ({levelb_lan_in,threeg_hdn_in,highd_sdn_in,pg_std_num,frac_intn_in})
         // SD
         9'b000_xxxx0_x: //SD 1440x576 50i (for clarity changed to 1440x625 50i)
            mem_line1[95:0] <= { _D,_sp,_sp, _5, _2, _5,_sp, _5, _9,_dp, _9, _i};
         9'b000_xxxx1_x: //SD 1440x486 60i (for clarity changed to 1440x525 60i)
            mem_line1[95:0] <= { _D,_sp,_sp, _6, _2, _5,_sp, _5, _0, _i,_sp,_sp};

         // HD
         9'b001_x0111_0: //HD 720 60p
            mem_line1[95:0] <= { _D,_sp,_sp, _7, _2, _0,_sp, _6, _0, _p,_sp,_sp};
         9'b001_x0111_1: //HD 720 59.94p
            mem_line1[95:0] <= { _D,_sp,_sp, _7, _2, _0,_sp, _5, _9,_dp, _9, _p};
         9'b001_x0000_0: //HD 1035 60i
            mem_line1[95:0] <= { _D,_sp, _1, _0, _3, _5,_sp, _6, _0, _i,_sp,_sp};
         9'b001_x0000_1: //HD 1035 59.94i
            mem_line1[95:0] <= { _D,_sp, _1, _0, _3, _5,_sp, _5, _9,_dp, _9, _i};
         9'b001_x0110_0: //HD 1080 24p
            mem_line1[95:0] <= { _D,_sp, _1, _0, _8, _0,_sp, _2, _4, _p,_sp,_sp};
         9'b001_x0110_1: //HD 1080 23.98p
            mem_line1[95:0] <= { _D,_sp, _1, _0, _8, _0,_sp, _2, _3,_dp, _9, _p};
         9'b001_x0100_x: //HD 1080 25p
            mem_line1[95:0] <= { _D,_sp, _1, _0, _8, _0,_sp, _2, _5, _p,_sp,_sp};
         9'b001_x0010_0: //HD 1080 30p
            mem_line1[95:0] <= { _D,_sp, _1, _0, _8, _0,_sp, _3, _0, _p,_sp,_sp};
         9'b001_x0010_1: //HD 1080 29.97p
            mem_line1[95:0] <= { _D,_sp, _1, _0, _8, _0,_sp, _2, _9,_dp, _9, _p};
         9'b001_x0001_x: //HD 1080 50i, 295M
            mem_line1[95:0] <= { _D,_sp, _1, _0, _8, _0,_sp, _5, _0, _i,_sp, _5};
         9'b001_x0101_x: //HD 1080 50i
            mem_line1[95:0] <= { _D,_sp, _1, _0, _8, _0,_sp, _5, _0, _i,_sp,_sp};
         9'b001_x0011_0: //HD 1080 60i
            mem_line1[95:0] <= { _D,_sp, _1, _0, _8, _0,_sp, _6, _0, _i,_sp,_sp};
         9'b001_x0011_1: //HD 1080 59.94i
            mem_line1[95:0] <= { _D,_sp, _1, _0, _8, _0,_sp, _5, _9,_dp, _9, _i};
         9'b001_x1000_x: //HD 2048x1080 24p
            mem_line1[95:0] <= { _D,_sp, _1, _0, _8, _0,_sp, _2, _4, _p, _2, _K};

         // 3G
         9'b011_01001_0: //3G 720 24p
            mem_line1[95:0] <= { _a,_sp,_sp, _7, _2, _0,_sp, _2, _4, _p,_sp,_sp};
         9'b011_01001_1: //3G 720 23.98p
            mem_line1[95:0] <= { _a,_sp,_sp, _7, _2, _0,_sp, _2, _3,_dp, _9, _p};
         9'b011_00111_x: //3G 720 25p
            mem_line1[95:0] <= { _a,_sp,_sp, _7, _2, _0,_sp, _2, _5, _p,_sp,_sp};
         9'b011_00101_0: //3G 720 30p
            mem_line1[95:0] <= { _a,_sp,_sp, _7, _2, _0,_sp, _3, _0, _p,_sp,_sp};
         9'b011_00101_1: //3G 720 29.97p
            mem_line1[95:0] <= { _a,_sp,_sp, _7, _2, _0,_sp, _2, _9,_dp, _9, _p};
         9'b011_00011_x: //3G 720 50p
            mem_line1[95:0] <= { _a,_sp,_sp, _7, _2, _0,_sp, _5, _0, _p,_sp,_sp};
         9'b011_00010_0: //3G 720 60p
            mem_line1[95:0] <= { _a,_sp,_sp, _7, _2, _0,_sp, _6, _0, _p,_sp,_sp};
         9'b011_00010_1: //3G 720 59.94p
            mem_line1[95:0] <= { _a,_sp,_sp, _7, _2, _0,_sp, _5, _9,_dp, _9, _p};
         9'b011_01000_0, 9'b011_01110_0, 9'b011_10011_0: //3G 1080 24p
            mem_line1[95:0] <= { _a,_sp, _1, _0, _8, _0,_sp, _2, _4, _p,_sp,_sp};
         9'b011_01000_1, 9'b011_01110_1, 9'b011_10011_1: //3G 1080 23.98p
            mem_line1[95:0] <= { _a,_sp, _1, _0, _8, _0,_sp, _2, _3,_dp, _9, _p};      
         9'b011_00110_x, 9'b011_01101_x, 9'b011_10010_x: //3G 1080 25p
            mem_line1[95:0] <= { _a,_sp, _1, _0, _8, _0,_sp, _2, _5, _p,_sp,_sp};
         9'b011_00100_0, 9'b011_01100_0, 9'b011_10001_0: //3G 1080 30p
            mem_line1[95:0] <= { _a,_sp, _1, _0, _8, _0,_sp, _3, _0, _p,_sp,_sp};
         9'b011_00100_1, 9'b011_01100_1, 9'b011_10001_1: //3G 1080 29.97p
            mem_line1[95:0] <= { _a,_sp, _1, _0, _8, _0,_sp, _2, _9,_dp, _9, _p};      
         9'b011_01011_x, 9'b011_10000_x, 9'b011_10101_x: //3G 1080 50i
            mem_line1[95:0] <= { _a,_sp, _1, _0, _8, _0,_sp, _5, _0, _i,_sp,_sp};
         9'b011_01010_0, 9'b011_01111_0, 9'b011_10100_0: //3G 1080 60i
            mem_line1[95:0] <= { _a,_sp, _1, _0, _8, _0,_sp, _6, _0, _i,_sp,_sp};
         9'b011_01010_1, 9'b011_01111_1, 9'b011_10100_1: //3G 1080 59.94i
            mem_line1[95:0] <= { _a,_sp, _1, _0, _8, _0,_sp, _5, _9,_dp, _9, _i};      
         9'b011_00001_x: //3G 1080 50p
            mem_line1[95:0] <= { _a,_sp, _1, _0, _8, _0,_sp, _5, _0, _p,_sp,_sp};
         9'b011_00000_0: //3G 1080 60p
            mem_line1[95:0] <= { _a,_sp, _1, _0, _8, _0,_sp, _6, _0, _p,_sp,_sp};
         9'b011_00000_1: //3G 1080 59.94p
            mem_line1[95:0] <= { _a,_sp, _1, _0, _8, _0,_sp, _5, _9,_dp, _9, _p};      

         9'b011_11000_0, 9'b011_11011_0: //3G 1080 30p 2K (444 12bit, 4444 10bit)
            mem_line1[95:0] <= { _a,_sp, _1, _0, _8, _0, _p, _3, _0,_sp, _2, _K};
         9'b011_11001_0, 9'b011_11100_0: //3G 1080 25p 2K (444 12bit, 4444 10bit)
            mem_line1[95:0] <= { _a,_sp, _1, _0, _8, _0, _p, _2, _5,_sp, _2, _K};
         9'b011_11010_0, 9'b011_11101_0: //3G 1080 24p 2K (444 12bit, 4444 10bit)
            mem_line1[95:0] <= { _a,_sp, _1, _0, _8, _0, _p, _2, _4,_sp, _2, _K};

         // 3G- Level-B (dual-stream)
         9'b101_x0111_0: //3G-b, 2xHD 720 60p
            mem_line1[95:0] <= { _b,_sp,_sp, _7, _2, _0,_sp, _6, _0, _p,_sp,_sp};
         9'b101_x0111_1: //3G-b, 2xHD 720 59.94p
            mem_line1[95:0] <= { _b,_sp,_sp, _7, _2, _0,_sp, _5, _9,_dp, _9, _p};
         9'b101_x0110_0: //3G-B, 2xHD 1080 24p
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _2, _4, _p,_sp,_sp};
         9'b101_x0110_1: //3G-B, 2xHD 1080 23.98p
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _2, _3,_dp, _9, _p};      
         9'b101_x0100_x: //3G-B, 2xHD 1080 25p
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _2, _5, _p,_sp,_sp};
         9'b101_x0010_0: //3G-B, 2xHD 1080 30p
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _3, _0, _p,_sp,_sp};
         9'b101_x0010_1: //3G-B, 2xHD 1080 29.97p
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _2, _9,_dp, _9, _p};
         9'b101_x0001_x: //3G-B, 2xHD 1080 50i, 295M
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _5, _0, _i,_sp, _5};
         9'b101_x0101_x: //3G-B, 2xHD 1080 50i
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _5, _0, _i,_sp,_sp};
         9'b101_x0011_0: //3G-B, 2xHD 1080 60i
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _6, _0, _i,_sp,_sp};
         9'b101_x0011_1: //3G-B, 2xHD 1080 59.94i
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _5, _9,_dp, _9, _i};
         9'b101_x0000_0: //3G-B, 2xHD 1035 60i
            mem_line1[95:0] <= { _b,_sp, _1, _0, _3, _5,_sp, _6, _0, _i,_sp,_sp};
         9'b101_x0000_1: //3G-B, 2xHD 1035 59.94i
            mem_line1[95:0] <= { _b,_sp, _1, _0, _3, _5,_sp, _5, _9,_dp, _9, _i};

         9'b101_x1000_x: //3G-B 2x2048x1080 24p
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _2, _4, _p, _2, _K};

         // 3G- Level-B (dual-link)
         9'b111_01000_0, 9'b111_01110_0, 9'b111_10011_0: //3G 1080 24p
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _2, _4, _p,_sp,_sp};
         9'b111_01000_1, 9'b111_01110_1, 9'b111_10011_1: //3G 1080 23.98p
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _2, _3,_dp, _9, _p};      
         9'b111_00110_x, 9'b111_01101_x, 9'b111_10010_x: //3G 1080 25p
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _2, _5, _p,_sp,_sp};
         9'b111_00100_0, 9'b111_01100_0, 9'b111_10001_0: //3G 1080 30p
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _3, _0, _p,_sp,_sp};
         9'b111_00100_1, 9'b111_01100_1, 9'b111_10001_1: //3G 1080 29.97p
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _2, _9,_dp, _9, _p};      
         9'b111_01011_x, 9'b111_10000_x, 9'b111_10101_x: //3G 1080 50i
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _5, _0, _i,_sp,_sp};
         9'b111_01010_0, 9'b111_01111_0, 9'b111_10100_0: //3G 1080 60i
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _6, _0, _i,_sp,_sp};
         9'b111_01010_1, 9'b111_01111_1, 9'b111_10100_1: //3G 1080 59.94i
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _5, _9,_dp, _9, _i};      
         9'b111_00001_x: //3G 1080 50p
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _5, _0, _p,_sp,_sp};
         9'b111_00000_0: //3G 1080 60p
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _6, _0, _p,_sp,_sp};
         9'b111_00000_1: //3G 1080 59.94p
            mem_line1[95:0] <= { _b,_sp, _1, _0, _8, _0,_sp, _5, _9,_dp, _9, _p};      
         
         default:
            mem_line1[95:0] <= {_sp, _U, _n, _k, _n, _o, _w, _n,_sp, _S, _D, _I};
         endcase
     
      else if(disp_page==2'b01) begin // Tx VPID display
         mem_line1[95:88] <= _sp;
         mem_line1[87:80] <= (vpid_in[7:4]<10)?(vpid_in[7:4]+48):(vpid_in[7:4]+55);
         mem_line1[79:72] <= (vpid_in[3:0]<10)?(vpid_in[3:0]+48):(vpid_in[3:0]+55);
         mem_line1[71:64] <= _sp;
         mem_line1[63:56] <= (vpid_in[15:12]<10)?(vpid_in[15:12]+48):(vpid_in[15:12]+55);
         mem_line1[55:48] <= (vpid_in[11:8]<10)?(vpid_in[11:8]+48):(vpid_in[11:8]+55);
         mem_line1[47:40] <= _sp;
         mem_line1[39:32] <= (vpid_in[23:20]<10)?(vpid_in[23:20]+48):(vpid_in[23:20]+55);
         mem_line1[31:24] <= (vpid_in[19:16]<10)?(vpid_in[19:16]+48):(vpid_in[19:16]+55);
         mem_line1[23:16] <= _sp;
         mem_line1[15:8]  <= (vpid_in[31:28]<10)?(vpid_in[31:28]+48):(vpid_in[31:28]+55);
         mem_line1[7:0]   <= (vpid_in[27:24]<10)?(vpid_in[27:24]+48):(vpid_in[27:24]+55);
      end
      else if(disp_page==2'b10) begin // Rx VPID display
//         mem_line1[95:88] <= _sp;
         mem_line1[95:88] <= (vp_valid)?_sp:_cn;
         mem_line1[87:80] <= (rx_vpid[7:4]<10)?(rx_vpid[7:4]+48):(rx_vpid[7:4]+55);
         mem_line1[79:72] <= (rx_vpid[3:0]<10)?(rx_vpid[3:0]+48):(rx_vpid[3:0]+55);
         mem_line1[71:64] <= _sp;
         mem_line1[63:56] <= (rx_vpid[15:12]<10)?(rx_vpid[15:12]+48):(rx_vpid[15:12]+55);
         mem_line1[55:48] <= (rx_vpid[11:8]<10)?(rx_vpid[11:8]+48):(rx_vpid[11:8]+55);
         mem_line1[47:40] <= _sp;
         mem_line1[39:32] <= (rx_vpid[23:20]<10)?(rx_vpid[23:20]+48):(rx_vpid[23:20]+55);
         mem_line1[31:24] <= (rx_vpid[19:16]<10)?(rx_vpid[19:16]+48):(rx_vpid[19:16]+55);
         mem_line1[23:16] <= _sp;
         mem_line1[15:8]  <= (rx_vpid[31:28]<10)?(rx_vpid[31:28]+48):(rx_vpid[31:28]+55);
         mem_line1[7:0]   <= (rx_vpid[27:24]<10)?(rx_vpid[27:24]+48):(rx_vpid[27:24]+55); 

      end
      else begin // Placer error, CRC error and time after reset display
         mem_line1[95:88] <= pav_errh+48;
         mem_line1[87:80] <= pav_errt+48;
         mem_line1[79:72] <= pav_erru+48;
         mem_line1[71:64] <= _sp;
         mem_line1[63:56] <= crc_errh+48;
         mem_line1[55:48] <= crc_errt+48;
         mem_line1[47:40] <= crc_erru+48;
         mem_line1[39:32] <= _sp;
         mem_line1[31:24] <= hour+48;
         mem_line1[23:16] <= (sh_sec)?_cn:_sp;
         mem_line1[15:8]  <= mint+48;
         mem_line1[7:0]   <= minu+48;
      end
      end
   end

// End of line 1, 5 thru 15

// ------------ LCD second line data for Rx
//   always @(*) begin
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         mem_line2 <= 'b0;
      else begin
      casex ({lock,rx_lb_lan,rx_tg_hdn,rx_hd_sdn,vid_format,frame_format,frac_intn})
      10'b0_xx0_xx_xxx_x:  // Scanning ... SD
         mem_line2 <= { _R,_ds, _S, _c, _a, _n,_dp,_dp,_dp,_sp,_sp,_sp,_sp,_sp, _S, _D};
      10'b0_001_xx_xxx_x:  // Scanning ... HD
         mem_line2 <= { _R,_ds, _S, _c, _a, _n,_dp,_dp,_dp,_sp,_sp,_sp, _H, _D,_sp,_sp};
      10'b0_x11_xx_xxx_x:  // Scanning ... 3G
         mem_line2 <= { _R,_ds, _S, _c, _a, _n,_dp,_dp,_dp,_sp, _3, _G,_sp,_sp,_sp,_sp};
         
// Locks
// SD
      10'b1_000_00_100_x:  //SD 1440x576 50i (for clarity changed to 1440x625 50i)
         mem_line2 <= { _R,_la,_sp, _S, _D,_sp,_sp, _6, _2, _5,_sp, _5, _0, _i,_sp,_sp};
      10'b1_000_00_101_x: //SD 1440x486 60i (for clarity changed to 1440x525 60i)
         mem_line2 <= { _R,_la,_sp, _S, _D,_sp,_sp, _5, _2, _5,_sp, _5, _9,_dp, _9, _i};
      10'b1_000_00_000_x: //SD, Unknown
         mem_line2 <= { _R,_la,_sp, _S, _D,_sp,_sp, _U, _n, _k, _n, _o, _w, _n,_sp,_sp};

// HD
      10'b1_001_01_001_0: //HD 720 24p
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp,_sp, _7, _2, _0,_sp, _2, _4, _p,_sp,_sp};
      10'b1_001_01_001_1: //HD 720 23.98p
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp,_sp, _7, _2, _0,_sp, _2, _3,_dp, _9, _p};
      10'b1_001_01_010_x: //HD 720 25p
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp,_sp, _7, _2, _0,_sp, _2, _5, _p,_sp,_sp};
      10'b1_001_01_011_0: //HD 720 30p
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp,_sp, _7, _2, _0,_sp, _3, _0, _p,_sp,_sp};
      10'b1_001_01_011_1: //HD 720 29.97p
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp,_sp, _7, _2, _0,_sp, _2, _9,_dp, _9, _p};
      10'b1_001_01_110_x: //HD 720 50p
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp,_sp, _7, _2, _0,_sp, _5, _0, _p,_sp,_sp};
      10'b1_001_01_111_0: //HD 720 60p
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp,_sp, _7, _2, _0,_sp, _6, _0, _p,_sp,_sp};
      10'b1_001_01_111_1: //HD 720 59.94p
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp,_sp, _7, _2, _0,_sp, _5, _9,_dp, _9, _p};
      10'b1_001_10_101_0: //HD 1035 60i
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp, _1, _0, _3, _5,_sp, _6, _0, _i,_sp,_sp};
      10'b1_001_10_101_1: //HD 1035 59.94i
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp, _1, _0, _3, _5,_sp, _5, _9,_dp, _9, _i};
      10'b1_001_11_001_0: //HD 1080 24p
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp, _1, _0, _8, _0,_sp, _2, _4, _p,_sp,_sp};
      10'b1_001_11_001_1: //HD 1080 23.98p
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp, _1, _0, _8, _0,_sp, _2, _3,_dp, _9, _p};
      10'b1_001_11_010_x: //HD 1080 25p
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp, _1, _0, _8, _0,_sp, _2, _5, _p,_sp,_sp};
      10'b1_001_11_011_0: //HD 1080 30p
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp, _1, _0, _8, _0,_sp, _3, _0, _p,_sp,_sp};
      10'b1_001_11_011_1: //HD 1080 29.97p
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp, _1, _0, _8, _0,_sp, _2, _9,_dp, _9, _p};
      10'b1_001_11_100_x: //HD 1080 50i
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp, _1, _0, _8, _0,_sp, _5, _0, _i,_sp,_sp};
      10'b1_001_11_101_0: //HD 1080 60i
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp, _1, _0, _8, _0,_sp, _6, _0, _i,_sp,_sp};
      10'b1_001_11_101_1: //HD 1080 59.94i
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp, _1, _0, _8, _0,_sp, _5, _9,_dp, _9, _i};
      10'b1_001_xx_000_x: //HD Custom
         mem_line2 <= { _R,_la,_sp, _H, _D,_sp, _C, _u, _s, _t, _o, _m,_sp,_sp,_sp,_sp};

// 3G
      10'b1_011_01_001_0: //3G 720 24p
         mem_line2 <= { _R,_la, _3, _G, _a,_sp,_sp, _7, _2, _0,_sp, _2, _4, _p,_sp,_sp};
      10'b1_011_01_001_1: //3G 720 23.98p
         mem_line2 <= { _R,_la, _3, _G, _a,_sp,_sp, _7, _2, _0,_sp, _2, _3,_dp, _9, _p};
      10'b1_011_01_010_x: //3G 720 25p
         mem_line2 <= { _R,_la, _3, _G, _a,_sp,_sp, _7, _2, _0,_sp, _2, _5, _p,_sp,_sp};
      10'b1_011_01_011_0: //3G 720 30p
         mem_line2 <= { _R,_la, _3, _G, _a,_sp,_sp, _7, _2, _0,_sp, _3, _0, _p,_sp,_sp};
      10'b1_011_01_011_1: //3G 720 29.97p
         mem_line2 <= { _R,_la, _3, _G, _a,_sp,_sp, _7, _2, _0,_sp, _2, _9,_dp, _9, _p};
      10'b1_011_01_110_x: //3G 720 50p
         mem_line2 <= { _R,_la, _3, _G, _a,_sp,_sp, _7, _2, _0,_sp, _5, _0, _p,_sp,_sp};
      10'b1_011_01_111_0: //3G 720 60p
         mem_line2 <= { _R,_la, _3, _G, _a,_sp,_sp, _7, _2, _0,_sp, _6, _0, _p,_sp,_sp};
      10'b1_011_01_111_1: //3G 720 59.94p
         mem_line2 <= { _R,_la, _3, _G, _a,_sp,_sp, _7, _2, _0,_sp, _5, _9,_dp, _9, _p};
      10'b1_011_11_001_0: //3G 1080 24p
         mem_line2 <= { _R,_la, _3, _G, _a,_sp, _1, _0, _8, _0,_sp, _2, _4, _p,_sp,_sp};
      10'b1_011_11_001_1: //3G 1080 23.98p
         mem_line2 <= { _R,_la, _3, _G, _a,_sp, _1, _0, _8, _0,_sp, _2, _3,_dp, _9, _p};      
      10'b1_011_11_010_x: //3G 1080 25p
         mem_line2 <= { _R,_la, _3, _G, _a,_sp, _1, _0, _8, _0,_sp, _2, _5, _p,_sp,_sp};
      10'b1_011_11_011_0: //3G 1080 30p
         mem_line2 <= { _R,_la, _3, _G, _a,_sp, _1, _0, _8, _0,_sp, _3, _0, _p,_sp,_sp};
      10'b1_011_11_011_1: //3G 1080 29.97p
         mem_line2 <= { _R,_la, _3, _G, _a,_sp, _1, _0, _8, _0,_sp, _2, _9,_dp, _9, _p};      
      10'b1_011_11_100_x: //3G 1080 50i
         mem_line2 <= { _R,_la, _3, _G, _a,_sp, _1, _0, _8, _0,_sp, _5, _0, _i,_sp,_sp};
      10'b1_011_11_101_0: //3G 1080 60i
         mem_line2 <= { _R,_la, _3, _G, _a,_sp, _1, _0, _8, _0,_sp, _6, _0, _i,_sp,_sp};
      10'b1_011_11_101_1: //3G 1080 59.94i
         mem_line2 <= { _R,_la, _3, _G, _a,_sp, _1, _0, _8, _0,_sp, _5, _9,_dp, _9, _i};      
      10'b1_011_11_110_x: //3G 1080 50p
         mem_line2 <= { _R,_la, _3, _G, _a,_sp, _1, _0, _8, _0,_sp, _5, _0, _p,_sp,_sp};
      10'b1_011_11_111_0: //3G 1080 60p
         mem_line2 <= { _R,_la, _3, _G, _a,_sp, _1, _0, _8, _0,_sp, _6, _0, _p,_sp,_sp};
      10'b1_011_11_111_1: //3G 1080 59.94p
         mem_line2 <= { _R,_la, _3, _G, _a,_sp, _1, _0, _8, _0,_sp, _5, _9,_dp, _9, _p};      
      10'b1_011_xx_000_x: //3G-a, Custom
         mem_line2 <= { _R,_la, _3, _G, _a,_sp, _C, _u, _s, _t, _o, _m,_sp,_sp,_sp,_sp};      
         
// 3G- Level-B
      10'b1_111_01_001_0: //3G-B, 2xHD 720 24p
         mem_line2 <= { _R,_la, _3, _G, _b,_sp,_sp, _7, _2, _0,_sp, _2, _4, _p,_sp,_sp};
      10'b1_111_01_001_1: //3G-B, 2xHD 720 23.98p
         mem_line2 <= { _R,_la, _3, _G, _b,_sp,_sp, _7, _2, _0,_sp, _2, _3,_dp, _9, _p};
      10'b1_111_01_010_x: //3G-B, 2xHD 720 25p
         mem_line2 <= { _R,_la, _3, _G, _b,_sp,_sp, _7, _2, _0,_sp, _2, _5, _p,_sp,_sp};
      10'b1_111_01_011_0: //3G-b, 2xHD 720 30p
         mem_line2 <= { _R,_la, _3, _G, _b,_sp,_sp, _7, _2, _0,_sp, _3, _0, _p,_sp,_sp};
      10'b1_111_01_011_1: //3G-b, 2xHD 720 29.97p
         mem_line2 <= { _R,_la, _3, _G, _b,_sp,_sp, _7, _2, _0,_sp, _2, _9,_dp, _9, _p};
      10'b1_111_01_110_x: //3G-B, 2xHD 720 50p
         mem_line2 <= { _R,_la, _3, _G, _b,_sp,_sp, _7, _2, _0,_sp, _5, _0, _p,_sp,_sp};
      10'b1_111_01_111_0: //3G-b, 2xHD 720 60p
         mem_line2 <= { _R,_la, _3, _G, _b,_sp,_sp, _7, _2, _0,_sp, _6, _0, _p,_sp,_sp};
      10'b1_111_01_111_1: //3G-b, 2xHD 720 59.94p
         mem_line2 <= { _R,_la, _3, _G, _b,_sp,_sp, _7, _2, _0,_sp, _5, _9,_dp, _9, _p};
      10'b1_111_11_001_0: //3G-B, 2xHD 1080 24p
         mem_line2 <= { _R,_la, _3, _G, _b,_sp, _1, _0, _8, _0,_sp, _2, _4, _p,_sp,_sp};
      10'b1_111_11_001_1: //3G-B, 2xHD 1080 23.98p
         mem_line2 <= { _R,_la, _3, _G, _b,_sp, _1, _0, _8, _0,_sp, _2, _3,_dp, _9, _p};      
      10'b1_111_11_010_x: //3G-B, 2xHD 1080 25p
         mem_line2 <= { _R,_la, _3, _G, _b,_sp, _1, _0, _8, _0,_sp, _2, _5, _p,_sp,_sp};
      10'b1_111_11_011_0: //3G-B, 2xHD 1080 30p
         mem_line2 <= { _R,_la, _3, _G, _b,_sp, _1, _0, _8, _0,_sp, _3, _0, _p,_sp,_sp};
      10'b1_111_11_011_1: //3G-B, 2xHD 1080 29.97p
         mem_line2 <= { _R,_la, _3, _G, _b,_sp, _1, _0, _8, _0,_sp, _2, _9,_dp, _9, _p};
      10'b1_111_11_100_x: //3G-B, 2xHD 1080 50i
         mem_line2 <= { _R,_la, _3, _G, _b,_sp, _1, _0, _8, _0,_sp, _5, _0, _i,_sp,_sp};
      10'b1_111_11_101_0: //3G-B, 2xHD 1080 60i
         mem_line2 <= { _R,_la, _3, _G, _b,_sp, _1, _0, _8, _0,_sp, _6, _0, _i,_sp,_sp};
      10'b1_111_11_101_1: //3G-B, 2xHD 1080 59.94i
         mem_line2 <= { _R,_la, _3, _G, _b,_sp, _1, _0, _8, _0,_sp, _5, _9,_dp, _9, _i};
      10'b1_111_xx_000_x: //3G-B, Custom
         mem_line2 <= { _R,_la, _3, _G, _b,_sp, _C, _u, _s, _t, _o, _m,_sp,_sp,_sp,_sp};
         
      default:
         mem_line2 <= { _T, _r, _i,_ds, _R, _a, _t, _e,_sp, _S, _D, _I,_sp, _P, _H, _Y};

      endcase
      end
   end

endmodule 

// $Log: $