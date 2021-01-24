// --------------------------------------------------------------------
// Copyright (c) 2009 by Lattice Semiconductor Corporation
// --------------------------------------------------------------------
//
// Permission:
//
//   Lattice Semiconductor grants permission to use this code for use
//   in synthesis for any Lattice programmable logic product.  Other
//   use of this code, including the selling or duplication of any
//   portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL or Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Lattice Semiconductor provides no warranty
//   regarding the use or functionality of this code.
//
// --------------------------------------------------------------------
//
//                     Lattice Semiconductor Corporation
//                     5555 NE Moore Court
//                     Hillsboro, OR 97214
//                     U.S.A
//
//                     TEL: 1-800-Lattice (USA and Canada)
//                          503-268-8001 (other locations)
//
//                     web: http://www.latticesemi.com/
//                     email: techsupport@latticesemi.com
//
// --------------------------------------------------------------------
//
//  Project:           SD/HD-SDI Demo
//  File:              pattern_fsm.v
//  Title:             pattern_fsm
//  Description:       This module is the FSM module that generates the
//                     the parallel data stream for the SD/HD-SDI system
//                     to display color bars or run pathological tests.
//                     The FSM are One-Hot state machine where each state
//                     bit is used for representing one and only one state.
//                     The outputs can be either of the two pattern groups
//                     selected by the "pattern_group_sel_in" signal.
//                     (1) pattern_group_sel_in is low: Color Bars
//                         [cbtype_smpte_in, cbtype_75_in] =
//                            [ 0, 0] => 100% color bars
//                            [ 0, 1] => 75% color bars
//                            [ 1, x] => SMPTE color bars
//                     (2) pattern_group_sel_in is high: Pathological patterns
//                         [pll_test_only_in, equ_test_only_in] =
//                            [ 0, 0] => Matrix Check-Field
//                            [ 0, 1] => EQU Check-Field
//                            [ 1, 0] => PLL Check-Field
//
// --------------------------------------------------------------------
// Author : Joseph H., Guolin W.
// $Revision: 1.3 $
// --------------------------------------------------------------------

`timescale 1ns/100ps

module pattern_fsm (
   // reset, clock and clock enable
   input wire rstn,
   input wire sync_rst,
   input wire clk,
   input wire clken,
   input wire clken_cp0,
   input wire clken_cp1,
   // signal to update all controls
   input wire update_controls_in,
   // update mode(1:update at the boundary of the frame, 0:update at the boundary of the line)
   input wire update_mode,
   
   // pixel data controls
   input wire [12:0] reg_xa_in,
   input wire [12:0] reg_xb_in,
   input wire [12:0] reg_xc_in,
   input wire [12:0] reg_xd_in,
   input wire [12:0] reg_xe_in,
   input wire [12:0] reg_xf_in,
   input wire [12:0] reg_xg_in,
   input wire [12:0] reg_xh_in,
   input wire [12:0] reg_xi_in,

   // line data controls
   input wire [10:0] reg_ya_in,
   input wire [10:0] reg_yb_in,
   input wire [10:0] reg_yc_in,
   input wire [10:0] reg_yd_in,
   input wire [10:0] reg_ye_in,
   input wire [10:0] reg_yf_in,
   input wire [10:0] reg_yg_in,
   input wire [10:0] reg_yh_in,
   input wire [10:0] reg_yi_in,
   input wire [10:0] reg_yj_in,
   input wire [10:0] reg_yk_in,
   input wire [10:0] reg_yl_in,

   // line number control
   input wire [10:0] reg_ln_in,

   // pattern group selection (low for color bars, high for pathological test)
   input wire pattern_group_sel_in, 

   // color bars type control (00:100%, 01:75%, 1X:smpte)
   input wire cbtype_smpte_in,
   input wire cbtype_75_in,

   // pathological type control (00:matrix, 01:equ, 10:pll)
   input wire pll_test_only_in,
   input wire equ_test_only_in,

   // progressive control (1 for progressive, 0 for interlaced)
   input wire progressive_in,

   // sdi/3G control (1 for 3G, 0 for sdi)
   input wire sdi_3g_in,
   
   // 3G level-B control (1 for 3G level-B)
   input wire lb_lan_in,
   
   // 3G image formats selection
   input wire [4:0] format_sel_3g,

   // hd/sd control (1 for hd, 0 for sd)
   input wire hd_sdn_in,

   // synchronized hd/sd control output (1 for hd, 0 for sd)
   output wire sync_hd_sdn_out,

   // synchronized 3g control output (1 for 3g)
   output wire sync_sdi_3g_out,
   
   // synchronized 3g level control output (1 for 3g level-b)
   output wire sync_lb_lan_out,
   
   // synchronized 3g format output (1 for 3g)
   output reg [1:0] sync_format_3g_out,

   // pixel data outputs
   output reg [9:0] y_out,
   output reg [9:0] cb_out,
   output reg [9:0] cr_out,

   // field, vsync, hsync, trs outputs
   output wire f_out,
   output wire v_out,
   output wire h_out,
   output wire trs_out,

   // signals used for detecting the type of pathological error
   output reg  patho_equ,
   output reg  patho_pll,
   output reg  patho_blk,

   // synchronized line number control output
   output reg [10:0] reg_ln_sync,

   // "rst_update" signal to reset "update" and line_number
   output reg rst_update
)/* synthesis pgroup = "pattern_fsm" */;

// signals for generating "update" signal
   reg  update;
        
   reg  update_controls_delay1;
   reg  update_controls_delay2;
   reg  update_controls_delay3;
   
   wire update_v_mode_0;
   wire update_v_mode_1;
   reg  update_v;
   
// mode control inputs

   // pixel data controls
   reg [12:0] reg_xa;///* synthesis syn_preserve = 1*/;
   reg [12:0] reg_xb;///* synthesis syn_preserve = 1*/;
   reg [12:0] reg_xc;///* synthesis syn_preserve = 1*/;
   reg [12:0] reg_xd;///* synthesis syn_preserve = 1*/;
   reg [12:0] reg_xe;///* synthesis syn_preserve = 1*/;
   reg [12:0] reg_xf;///* synthesis syn_preserve = 1*/;
   reg [12:0] reg_xg;///* synthesis syn_preserve = 1*/;
   reg [12:0] reg_xh;///* synthesis syn_preserve = 1*/;
   reg [12:0] reg_xi;///* synthesis syn_preserve = 1*/;

   // line data controls
   reg [10:0] reg_ya;///* synthesis syn_preserve = 1*/;
   reg [10:0] reg_yb;///* synthesis syn_preserve = 1*/;
   reg [10:0] reg_yc;///* synthesis syn_preserve = 1*/;
   reg [10:0] reg_yd;///* synthesis syn_preserve = 1*/;
   reg [10:0] reg_ye;///* synthesis syn_preserve = 1*/;
   reg [10:0] reg_yf;///* synthesis syn_preserve = 1*/;
   reg [10:0] reg_yg;///* synthesis syn_preserve = 1*/;
   reg [10:0] reg_yh;///* synthesis syn_preserve = 1*/;
   reg [10:0] reg_yi;///* synthesis syn_preserve = 1*/;
   reg [10:0] reg_yj;///* synthesis syn_preserve = 1*/;
   reg [10:0] reg_yk;///* synthesis syn_preserve = 1*/;
   reg [10:0] reg_yl;///* synthesis syn_preserve = 1*/;

   // pattern group selection (low for color bars, high for pathological test)
   reg pattern_group_sel;

   // color bars type control (00:100%, 01:75%, 1X:smpte)
   reg cbtype_smpte;
   reg cbtype_75;

   // pathological type control (00:matrix, 01:equ, 10:pll)
   reg pll_test_only;
   reg equ_test_only;

   // progressive control (1 for progressive, 0 for interlaced)
   reg progressive;

   // hd/sd control (1 for hd, o for sd)
   reg hd_sdn;

   // sdi_3g control
   reg sdi_3g;
   reg lb_lan;
   reg hd_3g;
   wire [1:0] format_3g;
   reg  [4:0] sync_format_sel_3g;
              
// state variables for one-hot FSM
              
   reg state_hblankv1;
   reg state_vblank1;

   reg state_hblankv2;
   reg state_vblank2;

   reg state_hblankb0;
   reg state_white0;
   reg state_yellow0;
   reg state_cyan0;
   reg state_green0;
   reg state_magenta0;
   reg state_red0;
   reg state_blue0;
   reg state_black0;

   reg state_hblankb1;
   reg state_gray1;
   reg state_yellow1;
   reg state_cyan1;
   reg state_green1;
   reg state_magenta1;
   reg state_red1;
   reg state_blue1;

   reg state_hblankb2;
   reg state_blue2;
   reg state_black2a;
   reg state_magenta2;
   reg state_black2b;
   reg state_cyan2;
   reg state_black2c;
   reg state_gray2;

   reg state_hblankb3;
   reg state_minus_i;
   reg state_white3;
   reg state_plus_q;
   reg state_black3a;
   reg state_black_p;
   reg state_black3b;
   reg state_black_n;
   reg state_black3c;

// xcnt asynchronous reset signals

   reg rst_xcnt_hblankv1;
   wire rst_xcnt_vblank1;

   reg rst_xcnt_hblankv2;
   reg rst_xcnt_vblank2;

   reg rst_xcnt_hblankb0;
   reg rst_xcnt_white0;
   reg rst_xcnt_yellow0;
   reg rst_xcnt_cyan0;
   reg rst_xcnt_green0;
   reg rst_xcnt_magenta0;
   reg rst_xcnt_red0;
   reg rst_xcnt_blue0;
   reg rst_xcnt_black0;

   reg rst_xcnt_hblankb1;
   reg rst_xcnt_gray1;
   reg rst_xcnt_yellow1;
   reg rst_xcnt_cyan1;
   reg rst_xcnt_green1;
   reg rst_xcnt_magenta1;
   reg rst_xcnt_red1;
   reg rst_xcnt_blue1;

   reg rst_xcnt_hblankb2;
   reg rst_xcnt_blue2;
   reg rst_xcnt_black2a;
   reg rst_xcnt_magenta2;
   reg rst_xcnt_black2b;
   reg rst_xcnt_cyan2;
   reg rst_xcnt_black2c;
   reg rst_xcnt_gray2;

   reg rst_xcnt_hblankb3;
   reg rst_xcnt_minus_i;
   reg rst_xcnt_white3;
   reg rst_xcnt_plus_q;
   reg rst_xcnt_black3a;
   reg rst_xcnt_black_p;
   reg rst_xcnt_black3b;
   reg rst_xcnt_black_n;
   wire rst_xcnt_black3c;

// ycnt synchronous reset signals

   reg rst_ycnt_vblank1;
   reg rst_ycnt_vblank2;
   reg rst_ycnt_black0;

   reg rst_ycnt_blue1;
   reg rst_ycnt_gray2;
   wire rst_ycnt_black3c;

// ycnt synchronous increasing control signals

   reg inc_ycnt_vblank1;
   reg inc_ycnt_vblank2;
   reg inc_ycnt_black0;

   reg inc_ycnt_blue1;
   reg inc_ycnt_gray2;
   reg inc_ycnt_black3c;

// f inverting controls

   wire invert_f_vblank1;

// v inverting controls

   wire invert_v_vblank2;
   wire invert_v_black0;
   reg invert_v_black3c;

// h inverting controls

   wire invert_h_hblankv1;
   reg invert_h_vblank1;

   wire invert_h_hblankv2;
   wire invert_h_vblank2;

   wire invert_h_hblankb0;
   wire invert_h_black0;

   wire invert_h_hblankb1;
   wire invert_h_blue1;

   wire invert_h_hblankb2;
   wire invert_h_gray2;

   wire invert_h_hblankb3;
   reg invert_h_black3c;

// X-axis counter and Y-axis counter

   reg [12:0] xcnt;
   reg [10:0] ycnt;

// reset control of X-axis counter

   wire rst_xcnt;

// internal field, vsync, hsync, trs

   reg f_int;
   reg v_int;
   reg h_int;

   reg trs_int;

   reg  [12:0] reg_x_trs_clr;
   reg  [12:0] reg_x_trs_set;

// buffer signals for improving performance
   reg xcnt_reg_xa_en;
   reg xcnt_reg_xb_en;
   reg xcnt_reg_xf_en;
   reg xcnt_reg_xg_en;
   reg xcnt_reg_xi_en;
   reg ycnt_reg_ya_en;
   reg ycnt_reg_yb_en;
   reg ycnt_reg_yc_en;
   reg ycnt_reg_yd_en;
   reg ycnt_reg_ye_en;
   reg ycnt_reg_yf_en;
   reg ycnt_reg_yg_en;
   reg ycnt_reg_yh_en;
   reg ycnt_reg_yi_en;
   reg ycnt_reg_yj_en;
   reg ycnt_reg_yk_en;
   reg ycnt_reg_yl_en;
   
   reg xcnt_reg_xb_en_buf;
   reg xcnt_reg_xf_en_buf;
   reg xcnt_reg_xi_en_buf;
   
   wire ycnt_add_en;
   wire ycnt_rst_en;

   reg  [9:0]  y_out_matrix;
   reg  [9:0]  cb_out_matrix;
   reg  [9:0]  cr_out_matrix;
   reg         patho_equ_matrix;
   reg         patho_pll_matrix;
   reg         patho_blk_matrix;
   reg  [9:0]  y_out_equ ;
   reg  [9:0]  cb_out_equ;
   reg  [9:0]  cr_out_equ;
   reg         patho_equ_equ;
   reg         patho_pll_equ;
   reg         patho_blk_equ;
   reg  [9:0]  y_out_pll ;
   reg  [9:0]  cb_out_pll;
   reg  [9:0]  cr_out_pll;
   reg         patho_equ_pll;
   reg         patho_pll_pll;
   reg         patho_blk_pll;
   reg  [9:0]  y_out_sd_75 ;
   reg  [9:0]  cb_out_sd_75;
   reg  [9:0]  cr_out_sd_75;
   reg         patho_equ_sd_75;
   reg         patho_pll_sd_75;
   reg         patho_blk_sd_75;
   reg  [9:0]  y_out_sd_100 ;
   reg  [9:0]  cb_out_sd_100;
   reg  [9:0]  cr_out_sd_100;
   reg         patho_equ_sd_100;
   reg         patho_pll_sd_100;
   reg         patho_blk_sd_100;
   reg  [9:0]  y_out_sd_smpte ;
   reg  [9:0]  cb_out_sd_smpte;
   reg  [9:0]  cr_out_sd_smpte;
   reg         patho_equ_sd_smpte;
   reg         patho_pll_sd_smpte;
   reg         patho_blk_sd_smpte;
   reg  [9:0]  y_out_hd_75 ;
   reg  [9:0]  cb_out_hd_75;
   reg  [9:0]  cr_out_hd_75;
   reg         patho_equ_hd_75;
   reg         patho_pll_hd_75;
   reg         patho_blk_hd_75;
   reg  [9:0]  y_out_hd_100 ;
   reg  [9:0]  cb_out_hd_100;
   reg  [9:0]  cr_out_hd_100;
   reg         patho_equ_hd_100;
   reg         patho_pll_hd_100;
   reg         patho_blk_hd_100;
   reg  [9:0]  y_out_hd_smpte ;
   reg  [9:0]  cb_out_hd_smpte;
   reg  [9:0]  cr_out_hd_smpte;
   reg         patho_equ_hd_smpte;
   reg         patho_pll_hd_smpte;
   reg         patho_blk_hd_smpte;

   reg         hd_3g_reg ;
   reg         pattern_group_sel_reg ;
   reg         cbtype_smpte_reg ;
   reg         cbtype_75_reg ;
   reg         pll_test_only_reg ;
   reg         equ_test_only_reg ;


// Generating "update" signal

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      update_controls_delay1 <= 1'b0;
      update_controls_delay2 <= 1'b0;
      update_controls_delay3 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      update_controls_delay1 <= 1'b0;
      update_controls_delay2 <= 1'b0;
      update_controls_delay3 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         update_controls_delay1 <= update_controls_in;
         update_controls_delay2 <= update_controls_delay1;
         update_controls_delay3 <= update_controls_delay2;
      end
   end

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) update <= 1'b0;
   else if (sync_rst == 1'b1) update <= 1'b0;
   else begin
      if (clken == 1'b1) begin
         if (rst_update == 1'b1)
            update <= 1'b0;
         else if ((update_controls_delay2 == 1'b1) && (update_controls_delay3 == 1'b0))
            update <= 1'b1;
      end
   end
   
   assign update_v_mode_0 = (xcnt_reg_xb_en_buf & (state_vblank1 | state_vblank2)) |              
                            (xcnt_reg_xf_en_buf & (state_blue1 | state_gray2 | state_black3c)) |  
                            (xcnt_reg_xi_en_buf & state_black0);                                  
   assign update_v_mode_1 = state_vblank1 & xcnt_reg_xb_en_buf &                                                       
                            ((progressive & ~f_int & ycnt_reg_ye_en) | (~progressive & f_int & ycnt_reg_yj_en));       
   
   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      update_v <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      update_v <= 1'b0;
   end
   else if (clken == 1'b1) begin
      update_v <= update & ((update_mode & update_v_mode_1) | (~update_mode & update_v_mode_0)); 
   end
  
// buffer signals for improving performance(xcnt_reg_xb_en,ycnt_reg_ye_en,ycnt_reg_yj_en)

   assign ycnt_add_en = (inc_ycnt_vblank1 | inc_ycnt_vblank2 | inc_ycnt_black0 | inc_ycnt_blue1 | inc_ycnt_gray2 | inc_ycnt_black3c);
   assign ycnt_rst_en = (rst_ycnt_vblank1 | rst_ycnt_vblank2 | rst_ycnt_black0 | rst_ycnt_blue1 | rst_ycnt_gray2 | rst_ycnt_black3c);
   
   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      xcnt_reg_xb_en_buf <= 1'h0;
      xcnt_reg_xf_en_buf <= 1'h0;
      xcnt_reg_xi_en_buf <= 1'h0;
   end
   else if (sync_rst == 1'b1) begin
      xcnt_reg_xb_en_buf <= 1'h0;
      xcnt_reg_xf_en_buf <= 1'h0;
      xcnt_reg_xi_en_buf <= 1'h0;
   end
   else if(clken == 1'b1) begin
      if(xcnt == reg_xb - 2)
         xcnt_reg_xb_en_buf <= 1'h1;
      else
         xcnt_reg_xb_en_buf <= 1'h0;
      if(xcnt == reg_xf - 2)
         xcnt_reg_xf_en_buf <= 1'h1;
      else
         xcnt_reg_xf_en_buf <= 1'h0;
      if(xcnt == reg_xi - 2)
         xcnt_reg_xi_en_buf <= 1'h1;
      else
         xcnt_reg_xi_en_buf <= 1'h0;
   end      
         
   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      xcnt_reg_xa_en <= 1'h0;
      xcnt_reg_xb_en <= 1'h0;
      xcnt_reg_xf_en <= 1'h0;
      xcnt_reg_xg_en <= 1'h0;
      xcnt_reg_xi_en <= 1'h0;
      ycnt_reg_ya_en <= 1'h0;
      ycnt_reg_yb_en <= 1'h0;
      ycnt_reg_yc_en <= 1'h0;
      ycnt_reg_yd_en <= 1'h0;
      ycnt_reg_ye_en <= 1'h0;
      ycnt_reg_yf_en <= 1'h0;
      ycnt_reg_yg_en <= 1'h0;
      ycnt_reg_yh_en <= 1'h0;
      ycnt_reg_yi_en <= 1'h0;
      ycnt_reg_yj_en <= 1'h0;
      ycnt_reg_yk_en <= 1'h0;
      ycnt_reg_yl_en <= 1'h0;
   end
   else if (sync_rst == 1'b1) begin
      xcnt_reg_xa_en <= 1'h0;
      xcnt_reg_xb_en <= 1'h0;
      xcnt_reg_xf_en <= 1'h0;
      xcnt_reg_xg_en <= 1'h0;
      xcnt_reg_xi_en <= 1'h0;
      ycnt_reg_ya_en <= 1'h0;
      ycnt_reg_yb_en <= 1'h0;
      ycnt_reg_yc_en <= 1'h0;
      ycnt_reg_yd_en <= 1'h0;
      ycnt_reg_ye_en <= 1'h0;
      ycnt_reg_yf_en <= 1'h0;
      ycnt_reg_yg_en <= 1'h0;
      ycnt_reg_yh_en <= 1'h0;
      ycnt_reg_yi_en <= 1'h0;
      ycnt_reg_yj_en <= 1'h0;
      ycnt_reg_yk_en <= 1'h0;
      ycnt_reg_yl_en <= 1'h0;
   end
   else if(clken == 1'b1) begin
      xcnt_reg_xb_en <= xcnt_reg_xb_en_buf;      
      xcnt_reg_xf_en <= xcnt_reg_xf_en_buf;      
      xcnt_reg_xi_en <= xcnt_reg_xi_en_buf;      
      if(xcnt == reg_xa - 1)
         xcnt_reg_xa_en <= 1'h1;
      else
         xcnt_reg_xa_en <= 1'h0;
      if(xcnt == reg_xg - 1)
         xcnt_reg_xg_en <= 1'h1;
      else
         xcnt_reg_xg_en <= 1'h0;
         
      if((ycnt == reg_ya - 1) & ycnt_add_en & !ycnt_rst_en)
         ycnt_reg_ya_en <= 1'h1;
      else if(ycnt_add_en | ycnt_rst_en)
         ycnt_reg_ya_en <= 1'h0;
      if((ycnt == reg_yb - 1) & ycnt_add_en & !ycnt_rst_en)
         ycnt_reg_yb_en <= 1'h1;
      else if(ycnt_add_en | ycnt_rst_en)
         ycnt_reg_yb_en <= 1'h0;
      if((ycnt == reg_yc - 1) & ycnt_add_en & !ycnt_rst_en)
         ycnt_reg_yc_en <= 1'h1;
      else if(ycnt_add_en | ycnt_rst_en)
         ycnt_reg_yc_en <= 1'h0;
      if((ycnt == reg_yd - 1) & ycnt_add_en & !ycnt_rst_en)
         ycnt_reg_yd_en <= 1'h1;
      else if(ycnt_add_en | ycnt_rst_en)
         ycnt_reg_yd_en <= 1'h0;
      if((ycnt == reg_ye - 1) & ycnt_add_en & !ycnt_rst_en)
         ycnt_reg_ye_en <= 1'h1;
      else if(ycnt_add_en | ycnt_rst_en)
         ycnt_reg_ye_en <= 1'h0;
      if((ycnt == reg_yf - 1) & ycnt_add_en & !ycnt_rst_en)
         ycnt_reg_yf_en <= 1'h1;
      else if(ycnt_add_en | ycnt_rst_en)
         ycnt_reg_yf_en <= 1'h0;
      if((ycnt == reg_yg - 1) & ycnt_add_en & !ycnt_rst_en)
         ycnt_reg_yg_en <= 1'h1;
      else if(ycnt_add_en | ycnt_rst_en)
         ycnt_reg_yg_en <= 1'h0;
      if((ycnt == reg_yh - 1) & ycnt_add_en & !ycnt_rst_en)
         ycnt_reg_yh_en <= 1'h1;
      else if(ycnt_add_en | ycnt_rst_en)
         ycnt_reg_yh_en <= 1'h0;
      if((ycnt == reg_yi - 1) & ycnt_add_en & !ycnt_rst_en)
         ycnt_reg_yi_en <= 1'h1;
      else if(ycnt_add_en | ycnt_rst_en)
         ycnt_reg_yi_en <= 1'h0;
      if((ycnt == reg_yj - 1) & ycnt_add_en & !ycnt_rst_en)
         ycnt_reg_yj_en <= 1'h1;
      else if(ycnt_add_en | ycnt_rst_en)
         ycnt_reg_yj_en <= 1'h0;
      if((ycnt == reg_yk - 1) & ycnt_add_en & !ycnt_rst_en)
         ycnt_reg_yk_en <= 1'h1;
      else if(ycnt_add_en | ycnt_rst_en)
         ycnt_reg_yk_en <= 1'h0;
      if((ycnt == reg_yl - 1) & ycnt_add_en & !ycnt_rst_en)
         ycnt_reg_yl_en <= 1'h1;
      else if(ycnt_add_en | ycnt_rst_en)
         ycnt_reg_yl_en <= 1'h0;
   end

// format_3g generating
   assign format_3g = (format_sel_3g == 5'b00000) ? 2'b00 :
                      (format_sel_3g == 5'b00001) ? 2'b00 :
                      (format_sel_3g == 5'b00010) ? 2'b01 :
                      (format_sel_3g == 5'b00011) ? 2'b01 :
                      (format_sel_3g == 5'b00100) ? 2'b01 :
                      (format_sel_3g == 5'b00101) ? 2'b01 :
                      (format_sel_3g == 5'b00110) ? 2'b01 :
                      (format_sel_3g == 5'b00111) ? 2'b01 :
                      (format_sel_3g == 5'b01000) ? 2'b01 :
                      (format_sel_3g == 5'b01001) ? 2'b01 :
                      (format_sel_3g == 5'b01010) ? 2'b01 :
                      (format_sel_3g == 5'b01011) ? 2'b01 :
                      (format_sel_3g == 5'b01100) ? 2'b10 :
                      (format_sel_3g == 5'b01101) ? 2'b10 :
                      (format_sel_3g == 5'b01110) ? 2'b10 :
                      (format_sel_3g == 5'b01111) ? 2'b10 :
                      (format_sel_3g == 5'b10000) ? 2'b10 :
                      (format_sel_3g == 5'b10001) ? 2'b11 :
                      (format_sel_3g == 5'b10010) ? 2'b11 :
                      (format_sel_3g == 5'b10011) ? 2'b11 :
                      (format_sel_3g == 5'b10100) ? 2'b11 : 
                      (format_sel_3g == 5'b10101) ? 2'b11 : 
                      (format_sel_3g == 5'b11000) ? 2'b10 :
                      (format_sel_3g == 5'b11001) ? 2'b10 :
                      (format_sel_3g == 5'b11010) ? 2'b10 :  
                      (format_sel_3g == 5'b11011) ? 2'b01 :   
                      (format_sel_3g == 5'b11100) ? 2'b01 :   
                      (format_sel_3g == 5'b11101) ? 2'b01 :   
                                                    2'b11;


// updating all controls at the frame boundary

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      rst_update <= 1'b0;
      // pixel data controls
      reg_xa <= 13'd0278;
      reg_xb <= 13'd1918;
      reg_xc <= 13'd0272;
      reg_xd <= 13'd0270;
      reg_xe <= 13'd0274;
      reg_xf <= 13'd0274;
      reg_xg <= 13'd0340;
      reg_xh <= 13'd0090;
      reg_xi <= 13'd0238;
      // line data controls
      reg_ya <= 11'd0039;
      reg_yb <= 11'd0345;
      reg_yc <= 11'd0041;
      reg_yd <= 11'd0128;
      reg_ye <= 11'd0005;
      reg_yf <= 11'd0038;
      reg_yg <= 11'd0346;
      reg_yh <= 11'd0041;
      reg_yi <= 11'd0128;
      reg_yj <= 11'd0004;
      reg_yk <= 11'd0516;
      reg_yl <= 11'd0517;
      // synchronized line number control output
      reg_ln_sync <= 11'd1125;
      // pattern group selection (low for color bars, high for pathological test)
      pattern_group_sel <= 0;
      // color bars type control (00:100%, 01:75%, 1X:smpte)
      cbtype_smpte <= 0;
      cbtype_75 <= 0;
      // pathological type control (00:matrix, 01:equ, 10:pll)
      pll_test_only <= 0;
      equ_test_only <= 0;
      // progressive control (1 for progressive, 0 for interlaced)
      progressive <= 0;
      // hd/sd control (1 for hd, o for sd)
      hd_sdn <= 1;
      sdi_3g <= 0;
      lb_lan <= 0;
      hd_3g  <= 1;
      sync_format_3g_out <= 0;   
      sync_format_sel_3g <= 0;
   end
   else if (sync_rst == 1'b1) begin
      rst_update <= 1'b0;
      // pixel data controls
      reg_xa <= reg_xa_in;
      reg_xb <= reg_xb_in;
      reg_xc <= reg_xc_in;
      reg_xd <= reg_xd_in;
      reg_xe <= reg_xe_in;
      reg_xf <= reg_xf_in;
      reg_xg <= reg_xg_in;
      reg_xh <= reg_xh_in;
      reg_xi <= reg_xi_in;
      // line data controls
      reg_ya <= reg_ya_in;
      reg_yb <= reg_yb_in;
      reg_yc <= reg_yc_in;
      reg_yd <= reg_yd_in;
      reg_ye <= reg_ye_in;
      reg_yf <= reg_yf_in;
      reg_yg <= reg_yg_in;
      reg_yh <= reg_yh_in;
      reg_yi <= reg_yi_in;
      reg_yj <= reg_yj_in;
      reg_yk <= reg_yk_in;
      reg_yl <= reg_yl_in;
      // synchronized line number control output
      reg_ln_sync <= reg_ln_in;
      // pattern group selection (low for color bars, high for pathological test)
      pattern_group_sel <= pattern_group_sel_in;
      // color bars type control (00:100%, 01:75%, 1X:smpte)
      cbtype_smpte <= cbtype_smpte_in;
      cbtype_75 <= cbtype_75_in;
      // pathological type control (00:matrix, 01:equ, 10:pll)
      pll_test_only <= pll_test_only_in;
      equ_test_only <= equ_test_only_in;
      // progressive control (1 for progressive, 0 for interlaced)
      progressive <= progressive_in;
      // hd/sd control (1 for hd, o for sd)
      hd_sdn <= hd_sdn_in;
      sdi_3g <= sdi_3g_in;
      lb_lan <= lb_lan_in;
      hd_3g <= hd_sdn_in | sdi_3g_in;
      sync_format_3g_out <= format_3g;
      sync_format_sel_3g <= format_sel_3g;
   end
   else begin
      if (clken & update_v) begin
         rst_update <= 1'b1;
         // pixel data controls
         reg_xa <= reg_xa_in;
         reg_xb <= reg_xb_in;
         reg_xc <= reg_xc_in;
         reg_xd <= reg_xd_in;
         reg_xe <= reg_xe_in;
         reg_xf <= reg_xf_in;
         reg_xg <= reg_xg_in;
         reg_xh <= reg_xh_in;
         reg_xi <= reg_xi_in;
         // line data controls
         reg_ya <= reg_ya_in;
         reg_yb <= reg_yb_in;
         reg_yc <= reg_yc_in;
         reg_yd <= reg_yd_in;
         reg_ye <= reg_ye_in;
         reg_yf <= reg_yf_in;
         reg_yg <= reg_yg_in;
         reg_yh <= reg_yh_in;
         reg_yi <= reg_yi_in;
         reg_yj <= reg_yj_in;
         reg_yk <= reg_yk_in;
         reg_yl <= reg_yl_in;
         // synchronized line number control output
         reg_ln_sync <= reg_ln_in;
         // pattern group selection (low for color bars, high for pathological test)
         pattern_group_sel <= pattern_group_sel_in;
         // color bars type control (00:100%, 01:75%, 1X:smpte)
         cbtype_smpte <= cbtype_smpte_in;
         cbtype_75 <= cbtype_75_in;
         // pathological type control (00:matrix, 01:equ, 10:pll)
         pll_test_only <= pll_test_only_in;
         equ_test_only <= equ_test_only_in;
         // progressive control (1 for progressive, 0 for interlaced)
         progressive <= progressive_in;
         // hd/sd control (1 for hd, o for sd)
         hd_sdn <= hd_sdn_in;
         sdi_3g <= sdi_3g_in;
         lb_lan <= lb_lan_in;
         hd_3g <= hd_sdn_in | sdi_3g_in;
         sync_format_3g_out <= format_3g;
         sync_format_sel_3g <= format_sel_3g;    
      end
      else if (clken) rst_update <= 1'b0;
   end

   assign sync_hd_sdn_out = hd_sdn;
   assign sync_sdi_3g_out = sdi_3g;
   assign sync_lb_lan_out = lb_lan;

// Counters xcnt and ycnt ****************************************************

   assign rst_xcnt =

                     rst_xcnt_hblankv1 | rst_xcnt_vblank1  |
                     rst_xcnt_hblankv2 | rst_xcnt_vblank2  |
                     rst_xcnt_hblankb0 | rst_xcnt_white0   |
                     rst_xcnt_yellow0  | rst_xcnt_cyan0    |
                     rst_xcnt_green0   | rst_xcnt_magenta0 |
                     rst_xcnt_red0     | rst_xcnt_blue0    |
                     rst_xcnt_black0   |

                     rst_xcnt_hblankb1 | rst_xcnt_gray1    |
                     rst_xcnt_yellow1  | rst_xcnt_cyan1    |
                     rst_xcnt_green1   | rst_xcnt_magenta1 |
                     rst_xcnt_red1     | rst_xcnt_blue1    |

                     rst_xcnt_hblankb2 | rst_xcnt_blue2    |
                     rst_xcnt_black2a  | rst_xcnt_magenta2 |
                     rst_xcnt_black2b  | rst_xcnt_cyan2    |
                     rst_xcnt_black2c  | rst_xcnt_gray2    |

                     rst_xcnt_hblankb3 | rst_xcnt_minus_i  |
                     rst_xcnt_white3   | rst_xcnt_plus_q   |
                     rst_xcnt_black3a  | rst_xcnt_black_p  |
                     rst_xcnt_black3b  | rst_xcnt_black_n  |
                     rst_xcnt_black3c;

// xcnt

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) xcnt <= 13'b0000000000000;
   else if (sync_rst == 1'b1) xcnt <= 13'b0000000000000;
   else if (rst_xcnt == 1'b1) xcnt <= 13'b0000000000000;
   else if (clken == 1'b1) xcnt <= xcnt + 1;

// ycnt

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) ycnt <= 11'b00000000000;
   else if (sync_rst == 1'b1) ycnt <= 11'b00000000000;
   else begin
      if (clken == 1'b1) begin
         if ((rst_ycnt_vblank1 == 1'b1) ||
             (rst_ycnt_vblank2 == 1'b1) ||
             (rst_ycnt_black0 == 1'b1)  ||
             (rst_ycnt_blue1 == 1'b1)   ||
             (rst_ycnt_gray2 == 1'b1)   ||
             (rst_ycnt_black3c == 1'b1) ||
             (rst_update == 1'b1))
            ycnt <= 11'b00000000000;
         else if ((inc_ycnt_vblank1 == 1'b1) ||
                  (inc_ycnt_vblank2 == 1'b1) ||
                  (inc_ycnt_black0 == 1'b1)  ||
                  (inc_ycnt_blue1 == 1'b1)   ||
                  (inc_ycnt_gray2 == 1'b1)   ||
                  (inc_ycnt_black3c == 1'b1))
            ycnt <= ycnt + 1;
      end
   end


// f, v, h, trs generation ***************************************************

   assign f_out = f_int;
   assign v_out = v_int;
   assign h_out = h_int;

   assign trs_out = trs_int;

// f_int

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) f_int <= 1'b0;
   else if (sync_rst == 1'b1) f_int <= 1'b0;
   else begin
      if (clken == 1'b1) begin
         if (progressive == 1'b1) f_int <= 1'b0;
         else if ((progressive == 1'b0) && (rst_update == 1'b1)) f_int <= 1'b0;
         else if (invert_f_vblank1 == 1'b1) f_int <= ~ f_int;
      end
   end

// v_int

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) v_int <= 1'b1;
   else if (sync_rst == 1'b1) v_int <= 1'b1;
   else begin
      if (clken == 1'b1) begin
         if (update_v)
            v_int <= 1'b1;
         else if ((invert_v_vblank2 == 1'b1) ||
             (invert_v_black0 == 1'b1)  ||
             (invert_v_black3c == 1'b1))
            v_int <= ~ v_int;
      end
   end

// h_int

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) h_int <= 1'b1;
   else if (sync_rst == 1'b1) h_int <= 1'b1;
   else begin
      if (clken == 1'b1) begin
         if ((invert_h_hblankv1 == 1'b1) || (invert_h_vblank1 == 1'b1) ||
             (invert_h_hblankv2 == 1'b1) || (invert_h_vblank2 == 1'b1) ||
             (invert_h_hblankb0 == 1'b1) || (invert_h_black0 == 1'b1)  ||
             (invert_h_hblankb1 == 1'b1) || (invert_h_blue1 == 1'b1)   ||
             (invert_h_hblankb2 == 1'b1) || (invert_h_gray2 == 1'b1)   ||
             (invert_h_hblankb3 == 1'b1) || (invert_h_black3c == 1'b1))
            h_int <= ~ h_int;
      end
   end

// trs_int

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) trs_int <= 1'b0;
   else if (sync_rst == 1'b1) trs_int <= 1'b1;
   else begin
      if (clken == 1'b1) begin
         if ((h_int == 1'b0) &&
             ((invert_h_hblankv1 == 1'b1) || (invert_h_vblank1 == 1'b1) ||
              (invert_h_hblankv2 == 1'b1) || (invert_h_vblank2 == 1'b1) ||
              (invert_h_hblankb0 == 1'b1) || (invert_h_black0 == 1'b1)  ||
              (invert_h_hblankb1 == 1'b1) || (invert_h_blue1 == 1'b1)   ||
              (invert_h_hblankb2 == 1'b1) || (invert_h_gray2 == 1'b1)   ||
              (invert_h_hblankb3 == 1'b1) || (invert_h_black3c == 1'b1)))
            trs_int <= 1'b1;
         else if ((h_int == 1'b1) &&
             ((invert_h_hblankv1 == 1'b1) || (invert_h_vblank1 == 1'b1) ||
              (invert_h_hblankv2 == 1'b1) || (invert_h_vblank2 == 1'b1) ||
              (invert_h_hblankb0 == 1'b1) || (invert_h_black0 == 1'b1)  ||
              (invert_h_hblankb1 == 1'b1) || (invert_h_blue1 == 1'b1)   ||
              (invert_h_hblankb2 == 1'b1) || (invert_h_gray2 == 1'b1)   ||
              (invert_h_hblankb3 == 1'b1) || (invert_h_black3c == 1'b1)))
            trs_int <= 1'b0;
         else if (h_int == 1'b1) begin
            if(xcnt == reg_x_trs_set)
               trs_int <= 1'b1;
            else if (xcnt == reg_x_trs_clr)
               trs_int <= 1'b0; 
         end
      end
   end

   always @(posedge clk or negedge rstn) begin
      if (rstn == 1'b0) begin 
         reg_x_trs_set <= 0; 
         reg_x_trs_clr <= 0; 
      end
      else if(sdi_3g & lb_lan & (sync_format_sel_3g[4:1] != 4'h0)) begin
         reg_x_trs_set <= reg_xa - 13'd0007;
         reg_x_trs_clr <= 13'd0007;
      end
      else if(hd_3g) begin
         reg_x_trs_set <= reg_xa - 13'd0003;
         reg_x_trs_clr <= 13'd0003;
      end
      else begin
         reg_x_trs_set <= reg_xa - 13'd0001;
         reg_x_trs_clr <= 13'd0001;
      end
   end
   
//   assign reg_x_trs_clr = (hd_sdn == 1'b1) ? 13'd0003 : 13'd0001;
//   assign reg_x_trs_set = (hd_sdn == 1'b1) ? reg_xa - 13'd0003 : reg_xa - 13'd0001;


// One-Hote FSM **************************************************************

//
// States for generating Vertical Blanking lines
//
//    hblankv1, vblank1, hblankv2, vblank2
//       (Note: State hblankv2 is the initial state after reset.)
//

// state hblankv1
   assign invert_h_hblankv1 = rst_xcnt_hblankv1;

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_hblankv1 <= 1'b0;
      rst_xcnt_hblankv1 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_hblankv1 <= 1'b0;
      rst_xcnt_hblankv1 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if (update_v)
            state_hblankv1 <= 1'b0;
         else if ((state_vblank1 == 1'b1) &&
             (((f_int == 1'b0) && xcnt_reg_xb_en && !ycnt_reg_ye_en) ||
              ((f_int == 1'b1) && xcnt_reg_xb_en && !ycnt_reg_yj_en)))
            state_hblankv1 <= 1'b1;
         else if ((state_black0 == 1'b1) &&
                  (((f_int == 1'b0) && (xcnt_reg_xi_en) && ycnt_reg_yk_en) ||
                   ((f_int == 1'b1) && (xcnt_reg_xi_en) && ycnt_reg_yl_en)))
               state_hblankv1 <= 1'b1;
         else if ((state_black3c == 1'b1) &&
                  (((f_int == 1'b0) && (xcnt_reg_xf_en) && ycnt_reg_yd_en) ||
                   ((f_int == 1'b1) && (xcnt_reg_xf_en) && ycnt_reg_yi_en)))
               state_hblankv1 <= 1'b1;
         else if (xcnt_reg_xa_en) begin
            state_hblankv1 <= 1'b0; // go to state vblank1
            rst_xcnt_hblankv1 <= state_hblankv1;
         end
         else begin
            rst_xcnt_hblankv1 <= 1'b0;
         end
      end
   end

// state vblank1
   assign invert_f_vblank1 = rst_ycnt_vblank1;
   assign rst_xcnt_vblank1 = invert_h_vblank1;

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_vblank1 <= 1'b0;
      rst_ycnt_vblank1 <= 1'b0;
      inc_ycnt_vblank1 <= 1'b0;
      invert_h_vblank1 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_vblank1 <= 1'b0;
      rst_ycnt_vblank1 <= 1'b0;
      inc_ycnt_vblank1 <= 1'b0;
      invert_h_vblank1 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_hblankv1 == 1'b1) && (xcnt_reg_xa_en)) state_vblank1 <= 1'b1;
         else if (((f_int == 1'b0) && xcnt_reg_xb_en && !ycnt_reg_ye_en) ||
                  ((f_int == 1'b1) && xcnt_reg_xb_en && !ycnt_reg_yj_en)) begin
            state_vblank1 <= 1'b0; // go to state hblankv1
            inc_ycnt_vblank1 <= state_vblank1;
            invert_h_vblank1 <= state_vblank1;
         end
         else if (((f_int == 1'b0) && xcnt_reg_xb_en && ycnt_reg_ye_en) ||
                  ((f_int == 1'b1) && xcnt_reg_xb_en && ycnt_reg_yj_en)) begin
            state_vblank1 <= 1'b0; // go to state hblankv2
            rst_ycnt_vblank1 <= state_vblank1;
            invert_h_vblank1 <= state_vblank1;
         end
         else begin
            rst_ycnt_vblank1 <= 1'b0;
            inc_ycnt_vblank1 <= 1'b0;
            invert_h_vblank1 <= 1'b0;
         end
      end
   end

// state hblankv2
   assign invert_h_hblankv2 = rst_xcnt_hblankv2;

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_hblankv2 <= 1'b1; // initial state after reset
      rst_xcnt_hblankv2 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_hblankv2 <= 1'b1; // initial state after reset
      rst_xcnt_hblankv2 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if (update_v)
            state_hblankv2 <= 1'b1;
         else if ((state_vblank2 == 1'b1) &&
             (((f_int == 1'b0) && xcnt_reg_xb_en && !ycnt_reg_ya_en) ||
              ((f_int == 1'b1) && xcnt_reg_xb_en && !ycnt_reg_yf_en)))
            state_hblankv2 <= 1'b1;
         else if ((state_vblank1 == 1'b1) &&
                  (((f_int == 1'b0) && xcnt_reg_xb_en && ycnt_reg_ye_en) ||
                   ((f_int == 1'b1) && xcnt_reg_xb_en && ycnt_reg_yj_en)))
            state_hblankv2 <= 1'b1;
         else if (xcnt_reg_xa_en) begin
            state_hblankv2 <= 1'b0; // go to state vblank2
            rst_xcnt_hblankv2 <= state_hblankv2;
         end
         else begin
            rst_xcnt_hblankv2 <= 1'b0;
         end
      end
   end

// state vblank2
   assign invert_h_vblank2 = rst_xcnt_vblank2;
   assign invert_v_vblank2 = rst_ycnt_vblank2;

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_vblank2 <= 1'b0;
      rst_xcnt_vblank2 <= 1'b0;
      rst_ycnt_vblank2 <= 1'b0;
      inc_ycnt_vblank2 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_vblank2 <= 1'b0;
      rst_xcnt_vblank2 <= 1'b0;
      rst_ycnt_vblank2 <= 1'b0;
      inc_ycnt_vblank2 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_hblankv2 == 1'b1) && (xcnt_reg_xa_en)) state_vblank2 <= 1'b1;
         else if (((f_int == 1'b0) && xcnt_reg_xb_en && !ycnt_reg_ya_en) ||
                  ((f_int == 1'b1) && xcnt_reg_xb_en && !ycnt_reg_yf_en)) begin
            state_vblank2 <= 1'b0; // go to state vblankv2
            rst_xcnt_vblank2 <= state_vblank2;
            inc_ycnt_vblank2 <= state_vblank2;
         end
         else if (((f_int == 1'b0) && xcnt_reg_xb_en && ycnt_reg_ya_en) ||
                  ((f_int == 1'b1) && xcnt_reg_xb_en && ycnt_reg_yf_en)) begin
            state_vblank2 <= 1'b0; // go to state hblankb0 or hblankb1
            rst_xcnt_vblank2 <= state_vblank2;
            rst_ycnt_vblank2 <= state_vblank2;
         end
         else begin
            rst_xcnt_vblank2 <= 1'b0;
            rst_ycnt_vblank2 <= 1'b0;
            inc_ycnt_vblank2 <= 1'b0;
         end
      end
   end

//
// States for generating 100% and 75% Color Bars
//
//    Horizontal Blanking:
//       hblankb0
//    Active Video:
//       white0, yellow0, cyan0, green0, magenta0, red0, blue0, black0
//

// state hblankb0
   assign invert_h_hblankb0 = rst_xcnt_hblankb0;

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_hblankb0 <= 1'b0;
      rst_xcnt_hblankb0 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_hblankb0 <= 1'b0;
      rst_xcnt_hblankb0 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if (update_v)
            state_hblankb0 <= 1'b0;
         else if ((state_black0 == 1'b1) &&
             (((f_int == 1'b0) && (xcnt_reg_xi_en) && !ycnt_reg_yk_en) ||
              ((f_int == 1'b1) && (xcnt_reg_xi_en) && !ycnt_reg_yl_en)))
            state_hblankb0 <= 1'b1;
         else if ((state_vblank2 == 1'b1) &&
                  (((f_int == 1'b0) && xcnt_reg_xb_en && ycnt_reg_ya_en) ||
                   ((f_int == 1'b1) && xcnt_reg_xb_en && ycnt_reg_yf_en)))
            state_hblankb0 <= ~pattern_group_sel & ~cbtype_smpte;
         else if (xcnt_reg_xa_en) begin
            state_hblankb0 <= 1'b0; // go to state white0
            rst_xcnt_hblankb0 <= state_hblankb0;
         end
         else begin
            rst_xcnt_hblankb0 <= 1'b0;
         end
      end
   end

// state white0

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_white0 <= 1'b0;
      rst_xcnt_white0 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_white0 <= 1'b0;
      rst_xcnt_white0 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_hblankb0 == 1'b1) && (xcnt_reg_xa_en)) state_white0 <= 1'b1;
         else if (xcnt_reg_xi_en) begin
            state_white0 <= 1'b0; // go to state yellow0
            rst_xcnt_white0 <= state_white0;
         end
         else rst_xcnt_white0 <= 1'b0;
      end
   end

// state yellow0

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_yellow0 <= 1'b0;
      rst_xcnt_yellow0 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_yellow0 <= 1'b0;
      rst_xcnt_yellow0 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_white0 == 1'b1) && (xcnt_reg_xi_en)) state_yellow0 <= 1'b1;
         else if (xcnt_reg_xi_en) begin
            state_yellow0 <= 1'b0; // go to state cyan0
            rst_xcnt_yellow0 <= state_yellow0;
         end
         else rst_xcnt_yellow0 <= 1'b0;
      end
   end

// state cyan0

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_cyan0 <= 1'b0;
      rst_xcnt_cyan0 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_cyan0 <= 1'b0;
      rst_xcnt_cyan0 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_yellow0 == 1'b1) && (xcnt_reg_xi_en)) state_cyan0 <= 1'b1;
         else if (xcnt_reg_xi_en) begin
            state_cyan0 <= 1'b0; // go to state green0
            rst_xcnt_cyan0 <= state_cyan0;
         end
         else rst_xcnt_cyan0 <= 1'b0;
      end
   end

// state green0

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_green0 <= 1'b0;
      rst_xcnt_green0 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_green0 <= 1'b0;
      rst_xcnt_green0 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_cyan0 == 1'b1) && (xcnt_reg_xi_en)) state_green0 <= 1'b1;
         else if (xcnt_reg_xi_en) begin
            state_green0 <= 1'b0; // go to state magenta0
            rst_xcnt_green0 <= state_green0;
         end
         else rst_xcnt_green0 <= 1'b0;
      end
   end

// state magenta0

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_magenta0 <= 1'b0;
      rst_xcnt_magenta0 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_magenta0 <= 1'b0;
      rst_xcnt_magenta0 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_green0 == 1'b1) && (xcnt_reg_xi_en)) state_magenta0 <= 1'b1;
         else if (xcnt_reg_xi_en) begin
            state_magenta0 <= 1'b0; // go to state red0
            rst_xcnt_magenta0 <= state_magenta0;
         end
         else rst_xcnt_magenta0 <= 1'b0;
      end
   end

// state red0

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_red0 <= 1'b0;
      rst_xcnt_red0 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_red0 <= 1'b0;
      rst_xcnt_red0 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_magenta0 == 1'b1) && (xcnt_reg_xi_en)) state_red0 <= 1'b1;
         else if (xcnt_reg_xi_en) begin
            state_red0 <= 1'b0; // go to state blue0
            rst_xcnt_red0 <= state_red0;
         end
         else rst_xcnt_red0 <= 1'b0;
      end
   end

// state blue0

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_blue0 <= 1'b0;
      rst_xcnt_blue0 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_blue0 <= 1'b0;
      rst_xcnt_blue0 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_red0 == 1'b1) && (xcnt_reg_xi_en)) state_blue0 <= 1'b1;
         else if (xcnt_reg_xi_en) begin
            state_blue0 <= 1'b0; // go to state black0
            rst_xcnt_blue0 <= state_blue0;
         end
         else rst_xcnt_blue0 <= 1'b0;
      end
   end

// state black0
   assign invert_h_black0 = rst_xcnt_black0;
   assign invert_v_black0 = rst_ycnt_black0;

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_black0 <= 1'b0;
      rst_xcnt_black0 <= 1'b0;
      rst_ycnt_black0 <= 1'b0;
      inc_ycnt_black0 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_black0 <= 1'b0;
      rst_xcnt_black0 <= 1'b0;
      rst_ycnt_black0 <= 1'b0;
      inc_ycnt_black0 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_blue0 == 1'b1) && (xcnt_reg_xi_en)) state_black0 <= 1'b1;
         else if (((f_int == 1'b0) && (xcnt_reg_xi_en) && !ycnt_reg_yk_en) ||
                  ((f_int == 1'b1) && (xcnt_reg_xi_en) && !ycnt_reg_yl_en)) begin
            state_black0 <= 1'b0; // go to state hblankb0
            rst_xcnt_black0 <= state_black0;
            inc_ycnt_black0 <= state_black0;
         end
         else if (((f_int == 1'b0) && (xcnt_reg_xi_en) && ycnt_reg_yk_en) ||
                  ((f_int == 1'b1) && (xcnt_reg_xi_en) && ycnt_reg_yl_en)) begin
            state_black0 <= 1'b0; // go to state hblankv1
            rst_xcnt_black0 <= state_black0;
            rst_ycnt_black0 <= state_black0;
         end
         else begin
            rst_xcnt_black0 <= 1'b0;
            rst_ycnt_black0 <= 1'b0;
            inc_ycnt_black0 <= 1'b0;
         end
      end
   end

//
// States for generating SMPTE Color Bars and Pathological Matrix, EQU, PLL Check-Fields
//
//    Horizontal Blanking:
//       hblankb1
//    Active Video:
//       gray1, yellow1, cyan1, green1, magenta1, red1, blue1
//    Horizontal Blanking:
//       hblankb2
//    Active Video:
//       blue2, black2a, magenta2, black2b, cyan2, black2c, gray2
//    Horizontal Blanking:
//       hblankb3
//    Active Video:
//       minus_i, white3, plus_q, black3a, black_p, black3b, black_n, black3c
//

// state hblankb1
   assign invert_h_hblankb1 = rst_xcnt_hblankb1;

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_hblankb1 <= 1'b0;
      rst_xcnt_hblankb1 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_hblankb1 <= 1'b0;
      rst_xcnt_hblankb1 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if (update_v)
            state_hblankb1 <= 1'b0;
         else if ((state_blue1 == 1'b1) &&
             (((f_int == 1'b0) && (xcnt_reg_xf_en) && !ycnt_reg_yb_en) ||
              ((f_int == 1'b1) && (xcnt_reg_xf_en) && !ycnt_reg_yg_en)))
            state_hblankb1 <= 1'b1;
         else if ((state_vblank2 == 1'b1) &&
                  (((f_int == 1'b0) && xcnt_reg_xb_en && ycnt_reg_ya_en) ||
                   ((f_int == 1'b1) && xcnt_reg_xb_en && ycnt_reg_yf_en)))
            state_hblankb1 <= (~pattern_group_sel & cbtype_smpte) | pattern_group_sel;
         else if (xcnt_reg_xa_en) begin
            state_hblankb1 <= 1'b0; // go to state gray1
            rst_xcnt_hblankb1 <= state_hblankb1;
         end
         else begin
            rst_xcnt_hblankb1 <= 1'b0;
         end
      end
   end

// state gray1

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_gray1 <= 1'b0;
      rst_xcnt_gray1 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_gray1 <= 1'b0;
      rst_xcnt_gray1 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_hblankb1 == 1'b1) && (xcnt_reg_xa_en)) state_gray1 <= 1'b1;
         else if (xcnt == reg_xc) begin
            state_gray1 <= 1'b0; // go to state yellow1
            rst_xcnt_gray1 <= state_gray1;
         end
         else rst_xcnt_gray1 <= 1'b0;
      end
   end

// state yellow1

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_yellow1 <= 1'b0;
      rst_xcnt_yellow1 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_yellow1 <= 1'b0;
      rst_xcnt_yellow1 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_gray1 == 1'b1) && (xcnt == reg_xc)) state_yellow1 <= 1'b1;
         else if (xcnt == reg_xc) begin
            state_yellow1 <= 1'b0; // go to state cyan1
            rst_xcnt_yellow1 <= state_yellow1;
         end
         else rst_xcnt_yellow1 <= 1'b0;
      end
   end

// state cyan1

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_cyan1 <= 1'b0;
      rst_xcnt_cyan1 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_cyan1 <= 1'b0;
      rst_xcnt_cyan1 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_yellow1 == 1'b1) && (xcnt == reg_xc)) state_cyan1 <= 1'b1;
         else if (xcnt == reg_xd) begin
            state_cyan1 <= 1'b0; // go to state green1
            rst_xcnt_cyan1 <= state_cyan1;
         end
         else rst_xcnt_cyan1 <= 1'b0;
      end
   end

// state green1

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_green1 <= 1'b0;
      rst_xcnt_green1 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_green1 <= 1'b0;
      rst_xcnt_green1 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_cyan1 == 1'b1) && (xcnt == reg_xd)) state_green1 <= 1'b1;
         else if (xcnt == reg_xc) begin
            state_green1 <= 1'b0; // go to state magenta1
            rst_xcnt_green1 <= state_green1;
         end
         else rst_xcnt_green1 <= 1'b0;
      end
   end

// state magenta1

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_magenta1 <= 1'b0;
      rst_xcnt_magenta1 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_magenta1 <= 1'b0;
      rst_xcnt_magenta1 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_green1 == 1'b1) && (xcnt == reg_xc)) state_magenta1 <= 1'b1;
         else if (xcnt == reg_xc) begin
            state_magenta1 <= 1'b0; // go to state red1
            rst_xcnt_magenta1 <= state_magenta1;
         end
         else rst_xcnt_magenta1 <= 1'b0;
      end
   end

// state red1

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_red1 <= 1'b0;
      rst_xcnt_red1 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_red1 <= 1'b0;
      rst_xcnt_red1 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_magenta1 == 1'b1) && (xcnt == reg_xc)) state_red1 <= 1'b1;
         else if (xcnt == reg_xe) begin
            state_red1 <= 1'b0; // go to state blue1
            rst_xcnt_red1 <= state_red1;
         end
         else rst_xcnt_red1 <= 1'b0;
      end
   end

// state blue1
   assign invert_h_blue1 = rst_xcnt_blue1;

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_blue1 <= 1'b0;
      rst_xcnt_blue1 <= 1'b0;
      rst_ycnt_blue1 <= 1'b0;
      inc_ycnt_blue1 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_blue1 <= 1'b0;
      rst_xcnt_blue1 <= 1'b0;
      rst_ycnt_blue1 <= 1'b0;
      inc_ycnt_blue1 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_red1 == 1'b1) && (xcnt == reg_xe)) state_blue1 <= 1'b1;
         else if (((f_int == 1'b0) && (xcnt_reg_xf_en) && !ycnt_reg_yb_en) ||
                  ((f_int == 1'b1) && (xcnt_reg_xf_en) && !ycnt_reg_yg_en)) begin
            state_blue1 <= 1'b0; // go to state hblankb1
            rst_xcnt_blue1 <= state_blue1;
            inc_ycnt_blue1 <= state_blue1;
         end
         else if (((f_int == 1'b0) && (xcnt_reg_xf_en) && ycnt_reg_yb_en) ||
                  ((f_int == 1'b1) && (xcnt_reg_xf_en) && ycnt_reg_yg_en)) begin
            state_blue1 <= 1'b0; // go to state hblankb2
            rst_xcnt_blue1 <= state_blue1;
            rst_ycnt_blue1 <= state_blue1;
         end
         else begin
            rst_xcnt_blue1 <= 1'b0;
            rst_ycnt_blue1 <= 1'b0;
            inc_ycnt_blue1 <= 1'b0;
         end
      end
   end

// state hblankb2
   assign invert_h_hblankb2 = rst_xcnt_hblankb2;

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_hblankb2 <= 1'b0;
      rst_xcnt_hblankb2 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_hblankb2 <= 1'b0;
      rst_xcnt_hblankb2 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if (update_v)
            state_hblankb2 <= 1'b0;
         else if ((state_gray2 == 1'b1) &&
             (((f_int == 1'b0) && (xcnt_reg_xf_en) && !ycnt_reg_yc_en) ||
              ((f_int == 1'b1) && (xcnt_reg_xf_en) && !ycnt_reg_yh_en)))
            state_hblankb2 <= 1'b1;
         else if ((state_blue1 == 1'b1) &&
                  (((f_int == 1'b0) && (xcnt_reg_xf_en) && ycnt_reg_yb_en) ||
                   ((f_int == 1'b1) && (xcnt_reg_xf_en) && ycnt_reg_yg_en)))
            state_hblankb2 <= 1'b1;
         else if (xcnt_reg_xa_en) begin
            state_hblankb2 <= 1'b0; // go to state blue2
            rst_xcnt_hblankb2 <= state_hblankb2;
         end
         else begin
            rst_xcnt_hblankb2 <= 1'b0;
         end
      end
   end

// state blue2

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_blue2 <= 1'b0;
      rst_xcnt_blue2 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_blue2 <= 1'b0;
      rst_xcnt_blue2 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_hblankb2 == 1'b1) && (xcnt_reg_xa_en)) state_blue2 <= 1'b1;
         else if (xcnt == reg_xc) begin
            state_blue2 <= 1'b0; // go to state black2a
            rst_xcnt_blue2 <= state_blue2;
         end
         else rst_xcnt_blue2 <= 1'b0;
      end
   end

// state black2a

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_black2a <= 1'b0;
      rst_xcnt_black2a <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_black2a <= 1'b0;
      rst_xcnt_black2a <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_blue2 == 1'b1) && (xcnt == reg_xc)) state_black2a <= 1'b1;
         else if (xcnt == reg_xc) begin
            state_black2a <= 1'b0; // go to state magenta2
            rst_xcnt_black2a <= state_black2a;
         end
         else rst_xcnt_black2a <= 1'b0;
      end
   end

// state magenta2

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_magenta2 <= 1'b0;
      rst_xcnt_magenta2 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_magenta2 <= 1'b0;
      rst_xcnt_magenta2 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_black2a == 1'b1) && (xcnt == reg_xc)) state_magenta2 <= 1'b1;
         else if (xcnt == reg_xd) begin
            state_magenta2 <= 1'b0; // go to state black2b
            rst_xcnt_magenta2 <= state_magenta2;
         end
         else rst_xcnt_magenta2 <= 1'b0;
      end
   end

// state black2b

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_black2b <= 1'b0;
      rst_xcnt_black2b <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_black2b <= 1'b0;
      rst_xcnt_black2b <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_magenta2 == 1'b1) && (xcnt == reg_xd)) state_black2b <= 1'b1;
         else if (xcnt == reg_xc) begin
            state_black2b <= 1'b0; // go to state cyan2
            rst_xcnt_black2b <= state_black2b;
         end
         else rst_xcnt_black2b <= 1'b0;
      end
   end

// state cyan2

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_cyan2 <= 1'b0;
      rst_xcnt_cyan2 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_cyan2 <= 1'b0;
      rst_xcnt_cyan2 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_black2b == 1'b1) && (xcnt == reg_xc)) state_cyan2 <= 1'b1;
         else if (xcnt == reg_xc) begin
            state_cyan2 <= 1'b0; // go to state black2c
            rst_xcnt_cyan2 <= state_cyan2;
         end
         else rst_xcnt_cyan2 <= 1'b0;
      end
   end

// state black2c

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_black2c <= 1'b0;
      rst_xcnt_black2c <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_black2c <= 1'b0;
      rst_xcnt_black2c <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_cyan2 == 1'b1) && (xcnt == reg_xc)) state_black2c <= 1'b1;
         else if (xcnt == reg_xe) begin
            state_black2c <= 1'b0; // go to state gray2
            rst_xcnt_black2c <= state_black2c;
         end
         else rst_xcnt_black2c <= 1'b0;
      end
   end

// state gray2
   assign invert_h_gray2 = rst_xcnt_gray2;

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_gray2 <= 1'b0;
      rst_xcnt_gray2 <= 1'b0;
      rst_ycnt_gray2 <= 1'b0;
      inc_ycnt_gray2 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_gray2 <= 1'b0;
      rst_xcnt_gray2 <= 1'b0;
      rst_ycnt_gray2 <= 1'b0;
      inc_ycnt_gray2 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_black2c == 1'b1) && (xcnt == reg_xe)) state_gray2 <= 1'b1;
         else if (((f_int == 1'b0) && (xcnt_reg_xf_en) && !ycnt_reg_yc_en) ||
                  ((f_int == 1'b1) && (xcnt_reg_xf_en) && !ycnt_reg_yh_en)) begin
            state_gray2 <= 1'b0; // go to state hblankb2
            rst_xcnt_gray2 <= state_gray2;
            inc_ycnt_gray2 <= state_gray2;
         end
         else if (((f_int == 1'b0) && (xcnt_reg_xf_en) && ycnt_reg_yc_en) ||
                  ((f_int == 1'b1) && (xcnt_reg_xf_en) && ycnt_reg_yh_en)) begin
            state_gray2 <= 1'b0; // go to state hblankb3
            rst_xcnt_gray2 <= state_gray2;
            rst_ycnt_gray2 <= state_gray2;
         end
         else begin
            rst_xcnt_gray2 <= 1'b0;
            rst_ycnt_gray2 <= 1'b0;
            inc_ycnt_gray2 <= 1'b0;
         end
      end
   end

// state hblankb3
   assign invert_h_hblankb3 = rst_xcnt_hblankb3;

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_hblankb3 <= 1'b0;
      rst_xcnt_hblankb3 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_hblankb3 <= 1'b0;
      rst_xcnt_hblankb3 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if (update_v)
            state_hblankb3 <= 1'b0;
         else if ((state_black3c == 1'b1) &&
             (((f_int == 1'b0) && (xcnt_reg_xf_en) && !ycnt_reg_yd_en) ||
              ((f_int == 1'b1) && (xcnt_reg_xf_en) && !ycnt_reg_yi_en)))
            state_hblankb3 <= 1'b1;
         else if ((state_gray2 == 1'b1) &&
                  (((f_int == 1'b0) && (xcnt_reg_xf_en) && ycnt_reg_yc_en) ||
                   ((f_int == 1'b1) && (xcnt_reg_xf_en) && ycnt_reg_yh_en)))
            state_hblankb3 <= 1'b1;
         else if (xcnt_reg_xa_en) begin
            state_hblankb3 <= 1'b0; // go to state minus_i
            rst_xcnt_hblankb3 <= state_hblankb3;
         end
         else begin
            rst_xcnt_hblankb3 <= 1'b0;
         end
      end
   end

// state minus_i

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_minus_i <= 1'b0;
      rst_xcnt_minus_i <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_minus_i <= 1'b0;
      rst_xcnt_minus_i <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_hblankb3 == 1'b1) && (xcnt_reg_xa_en)) state_minus_i <= 1'b1;
         else if (xcnt_reg_xg_en) begin
            state_minus_i <= 1'b0; // go to state white3
            rst_xcnt_minus_i <= state_minus_i;
         end
         else rst_xcnt_minus_i <= 1'b0;
      end
   end

// state white3

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_white3 <= 1'b0;
      rst_xcnt_white3 <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_white3 <= 1'b0;
      rst_xcnt_white3 <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_minus_i == 1'b1) && (xcnt_reg_xg_en)) state_white3 <= 1'b1;
         else if (xcnt_reg_xg_en) begin
            state_white3 <= 1'b0; // go to state plus_q
            rst_xcnt_white3 <= state_white3;
         end
         else rst_xcnt_white3 <= 1'b0;
      end
   end

// state plus_q

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_plus_q <= 1'b0;
      rst_xcnt_plus_q <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_plus_q <= 1'b0;
      rst_xcnt_plus_q <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_white3 == 1'b1) && (xcnt_reg_xg_en)) state_plus_q <= 1'b1;
         else if (xcnt_reg_xg_en) begin
            state_plus_q <= 1'b0; // go to state black3a
            rst_xcnt_plus_q <= state_plus_q;
         end
         else rst_xcnt_plus_q <= 1'b0;
      end
   end

// state black3a

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_black3a <= 1'b0;
      rst_xcnt_black3a <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_black3a <= 1'b0;
      rst_xcnt_black3a <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_plus_q == 1'b1) && (xcnt_reg_xg_en)) state_black3a <= 1'b1;
         else if (xcnt_reg_xg_en) begin
            state_black3a <= 1'b0; // go to state black_p
            rst_xcnt_black3a <= state_black3a;
         end
         else rst_xcnt_black3a <= 1'b0;
      end
   end

// state black_p

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_black_p <= 1'b0;
      rst_xcnt_black_p <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_black_p <= 1'b0;
      rst_xcnt_black_p <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_black3a == 1'b1) && (xcnt_reg_xg_en)) state_black_p <= 1'b1;
         else if (xcnt == reg_xh) begin
            state_black_p <= 1'b0; // go to state black3b
            rst_xcnt_black_p <= state_black_p;
         end
         else rst_xcnt_black_p <= 1'b0;
      end
   end

// state black3b

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_black3b <= 1'b0;
      rst_xcnt_black3b <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_black3b <= 1'b0;
      rst_xcnt_black3b <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_black_p == 1'b1) && (xcnt == reg_xh)) state_black3b <= 1'b1;
         else if (xcnt == reg_xh) begin
            state_black3b <= 1'b0; // go to state black_n
            rst_xcnt_black3b <= state_black3b;
         end
         else rst_xcnt_black3b <= 1'b0;
      end
   end

// state black_n

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_black_n <= 1'b0;
      rst_xcnt_black_n <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_black_n <= 1'b0;
      rst_xcnt_black_n <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_black3b == 1'b1) && (xcnt == reg_xh)) state_black_n <= 1'b1;
         else if (xcnt == reg_xh) begin
            state_black_n <= 1'b0; // go to state black3c
            rst_xcnt_black_n <= state_black_n;
         end
         else rst_xcnt_black_n <= 1'b0;
      end
   end

// state black3c
   assign rst_ycnt_black3c = invert_v_black3c;
   assign rst_xcnt_black3c = invert_h_black3c;

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      state_black3c <= 1'b0;
      inc_ycnt_black3c <= 1'b0;
      invert_v_black3c <= 1'b0;
      invert_h_black3c <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      state_black3c <= 1'b0;
      inc_ycnt_black3c <= 1'b0;
      invert_v_black3c <= 1'b0;
      invert_h_black3c <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         if ((state_black_n == 1'b1) && (xcnt == reg_xh)) state_black3c <= 1'b1;
         else if (((f_int == 1'b0) && (xcnt_reg_xf_en) && !ycnt_reg_yd_en) ||
                  ((f_int == 1'b1) && (xcnt_reg_xf_en) && !ycnt_reg_yi_en)) begin
            state_black3c <= 1'b0; // go to state hblankb3
            inc_ycnt_black3c <= state_black3c;
            invert_h_black3c <= state_black3c;
         end
         else if (((f_int == 1'b0) && (xcnt_reg_xf_en) && ycnt_reg_yd_en) ||
                  ((f_int == 1'b1) && (xcnt_reg_xf_en) && ycnt_reg_yi_en)) begin
            state_black3c <= 1'b0; // go to state hblankv1
            invert_v_black3c <= state_black3c;
            invert_h_black3c <= state_black3c;
         end
         else begin
            inc_ycnt_black3c <= 1'b0;
            invert_v_black3c <= 1'b0;
            invert_h_black3c <= 1'b0;
         end
      end
   end

//
// Outputs Generation for
//
//    (1) Y, Cb, Cr data generation for SD-SDI and HD-SDI
//    (2) patho_xx signals generation for showing the error location of the
//        pathological test
//

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      y_out_matrix <= 10'h040; cb_out_matrix <= 10'h200; cr_out_matrix <= 10'h200;
      patho_equ_matrix <= 1'b0; patho_pll_matrix <= 1'b0; patho_blk_matrix <= 1'b0;
      y_out_equ <= 10'h040; cb_out_equ <= 10'h200; cr_out_equ <= 10'h200;
      patho_equ_equ <= 1'b0; patho_pll_equ <= 1'b0; patho_blk_equ <= 1'b0;
      y_out_pll <= 10'h040; cb_out_pll <= 10'h200; cr_out_pll <= 10'h200;
      patho_equ_pll <= 1'b0; patho_pll_pll <= 1'b0; patho_blk_pll <= 1'b0;
      y_out_sd_75 <= 10'h040; cb_out_sd_75 <= 10'h200; cr_out_sd_75 <= 10'h200;
      patho_equ_sd_75 <= 1'b0; patho_pll_sd_75 <= 1'b0; patho_blk_sd_75 <= 1'b0;
      y_out_sd_100 <= 10'h040; cb_out_sd_100 <= 10'h200; cr_out_sd_100 <= 10'h200;
      patho_equ_sd_100 <= 1'b0; patho_pll_sd_100 <= 1'b0; patho_blk_sd_100 <= 1'b0;
      y_out_sd_smpte <= 10'h040; cb_out_sd_smpte <= 10'h200; cr_out_sd_smpte <= 10'h200;
      patho_equ_sd_smpte <= 1'b0; patho_pll_sd_smpte <= 1'b0; patho_blk_sd_smpte <= 1'b0;
      y_out_hd_75 <= 10'h040; cb_out_hd_75 <= 10'h200; cr_out_hd_75 <= 10'h200;
      patho_equ_hd_75 <= 1'b0; patho_pll_hd_75 <= 1'b0; patho_blk_hd_75 <= 1'b0;
      y_out_hd_100 <= 10'h040; cb_out_hd_100 <= 10'h200; cr_out_hd_100 <= 10'h200;
      patho_equ_hd_100 <= 1'b0; patho_pll_hd_100 <= 1'b0; patho_blk_hd_100 <= 1'b0;
      y_out_hd_smpte <= 10'h040; cb_out_hd_smpte <= 10'h200; cr_out_hd_smpte <= 10'h200;
      patho_equ_hd_smpte <= 1'b0; patho_pll_hd_smpte <= 1'b0; patho_blk_hd_smpte <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      y_out_matrix <= 10'h040; cb_out_matrix <= 10'h200; cr_out_matrix <= 10'h200;
      patho_equ_matrix <= 1'b0; patho_pll_matrix <= 1'b0; patho_blk_matrix <= 1'b0;
      y_out_equ <= 10'h040; cb_out_equ <= 10'h200; cr_out_equ <= 10'h200;
      patho_equ_equ <= 1'b0; patho_pll_equ <= 1'b0; patho_blk_equ <= 1'b0;
      y_out_pll <= 10'h040; cb_out_pll <= 10'h200; cr_out_pll <= 10'h200;
      patho_equ_pll <= 1'b0; patho_pll_pll <= 1'b0; patho_blk_pll <= 1'b0;
      y_out_sd_75 <= 10'h040; cb_out_sd_75 <= 10'h200; cr_out_sd_75 <= 10'h200;
      patho_equ_sd_75 <= 1'b0; patho_pll_sd_75 <= 1'b0; patho_blk_sd_75 <= 1'b0;
      y_out_sd_100 <= 10'h040; cb_out_sd_100 <= 10'h200; cr_out_sd_100 <= 10'h200;
      patho_equ_sd_100 <= 1'b0; patho_pll_sd_100 <= 1'b0; patho_blk_sd_100 <= 1'b0;
      y_out_sd_smpte <= 10'h040; cb_out_sd_smpte <= 10'h200; cr_out_sd_smpte <= 10'h200;
      patho_equ_sd_smpte <= 1'b0; patho_pll_sd_smpte <= 1'b0; patho_blk_sd_smpte <= 1'b0;
      y_out_hd_75 <= 10'h040; cb_out_hd_75 <= 10'h200; cr_out_hd_75 <= 10'h200;
      patho_equ_hd_75 <= 1'b0; patho_pll_hd_75 <= 1'b0; patho_blk_hd_75 <= 1'b0;
      y_out_hd_100 <= 10'h040; cb_out_hd_100 <= 10'h200; cr_out_hd_100 <= 10'h200;
      patho_equ_hd_100 <= 1'b0; patho_pll_hd_100 <= 1'b0; patho_blk_hd_100 <= 1'b0;
      y_out_hd_smpte <= 10'h040; cb_out_hd_smpte <= 10'h200; cr_out_hd_smpte <= 10'h200;
      patho_equ_hd_smpte <= 1'b0; patho_pll_hd_smpte <= 1'b0; patho_blk_hd_smpte <= 1'b0;
   end
   else begin
      if (clken_cp0 == 1'b1) begin
         // Pathological Pattern: Matrix Check-Field
            if ((state_gray1 == 1'b1)    || (state_gray2 == 1'b1)    ||
                (state_yellow1 == 1'b1)  ||
                (state_cyan1 == 1'b1)    || (state_cyan2 == 1'b1)    ||
                (state_green1 == 1'b1)   ||
                (state_magenta1 == 1'b1) || (state_magenta2 == 1'b1) ||
                (state_red1 == 1'b1)     ||
                (state_blue1 == 1'b1)    || (state_blue2 == 1'b1)    ||
                (state_black2a == 1'b1)  ||
                (state_black2b == 1'b1)  ||
                (state_black2c == 1'b1)) begin
               y_out_matrix <= 10'h198; cb_out_matrix <= 10'h300; cr_out_matrix <= 10'h300;
               patho_equ_matrix <= 1'b1; patho_pll_matrix <= 1'b0; patho_blk_matrix <= 1'b0;
            end
            else if ((state_minus_i == 1'b1) ||
                     (state_white3 == 1'b1)  ||
                     (state_plus_q == 1'b1)  ||
                     (state_black_p == 1'b1) ||
                     (state_black_n == 1'b1) ||
                     (state_black3a == 1'b1) ||
                     (state_black3b == 1'b1) ||
                     (state_black3c == 1'b1)) begin
               y_out_matrix <= 10'h110; cb_out_matrix <= 10'h200; cr_out_matrix <= 10'h200;
               patho_equ_matrix <= 1'b0; patho_pll_matrix <= 1'b1; patho_blk_matrix <= 1'b0;
            end
            else begin
               y_out_matrix <= 10'h040; cb_out_matrix <= 10'h200; cr_out_matrix <= 10'h200;
               patho_equ_matrix <= 1'b0; patho_pll_matrix <= 1'b0; patho_blk_matrix <= 1'b1;
            end
         // Pathological Pattern: EQU Check-Field
            if ((state_gray1 == 1'b1)    || (state_gray2 == 1'b1)    ||
                (state_yellow1 == 1'b1)  ||
                (state_cyan1 == 1'b1)    || (state_cyan2 == 1'b1)    ||
                (state_green1 == 1'b1)   ||
                (state_magenta1 == 1'b1) || (state_magenta2 == 1'b1) ||
                (state_red1 == 1'b1)     ||
                (state_blue1 == 1'b1)    || (state_blue2 == 1'b1)    ||
                (state_black2a == 1'b1)  ||
                (state_black2b == 1'b1)  ||
                (state_black2c == 1'b1)  ||
                (state_minus_i == 1'b1)  ||
                (state_white3 == 1'b1)   ||
                (state_plus_q == 1'b1)   ||
                (state_black_p == 1'b1)  ||
                (state_black_n == 1'b1)  ||
                (state_black3a == 1'b1)  ||
                (state_black3b == 1'b1)  ||
                (state_black3c == 1'b1)) begin
               y_out_equ <= 10'h198; cb_out_equ <= 10'h300; cr_out_equ <= 10'h300;
               patho_equ_equ <= 1'b1; patho_pll_equ <= 1'b0; patho_blk_equ <= 1'b0;
            end
            else begin
               y_out_equ <= 10'h040; cb_out_equ <= 10'h200; cr_out_equ <= 10'h200;
               patho_equ_equ <= 1'b0; patho_pll_equ <= 1'b0; patho_blk_equ <= 1'b1;
            end
         // Pathological Pattern: PLL Check-Field
            if ((state_gray1 == 1'b1)    || (state_gray2 == 1'b1)    ||
                (state_yellow1 == 1'b1)  ||
                (state_cyan1 == 1'b1)    || (state_cyan2 == 1'b1)    ||
                (state_green1 == 1'b1)   ||
                (state_magenta1 == 1'b1) || (state_magenta2 == 1'b1) ||
                (state_red1 == 1'b1)     ||
                (state_blue1 == 1'b1)    || (state_blue2 == 1'b1)    ||
                (state_black2a == 1'b1)  ||
                (state_black2b == 1'b1)  ||
                (state_black2c == 1'b1)  ||
                (state_minus_i == 1'b1)  ||
                (state_white3 == 1'b1)   ||
                (state_plus_q == 1'b1)   ||
                (state_black_p == 1'b1)  ||
                (state_black_n == 1'b1)  ||
                (state_black3a == 1'b1)  ||
                (state_black3b == 1'b1)  ||
                (state_black3c == 1'b1)) begin
               y_out_pll <= 10'h110; cb_out_pll <= 10'h200; cr_out_pll <= 10'h200;
               patho_equ_pll <= 1'b0; patho_pll_pll <= 1'b1; patho_blk_pll <= 1'b0;
            end
            else begin
               y_out_pll <= 10'h040; cb_out_pll <= 10'h200; cr_out_pll <= 10'h200;
               patho_equ_pll <= 1'b0; patho_pll_pll <= 1'b0; patho_blk_pll <= 1'b1;
            end
         // SD Color Bars Pattern: 100% Color Bars
            if (state_white0 == 1'b1) begin
               y_out_sd_100 <= 10'h3AC; cb_out_sd_100 <= 10'h200; cr_out_sd_100 <= 10'h200;
               patho_equ_sd_100 <= 1'b1; patho_pll_sd_100 <= 1'b1; patho_blk_sd_100 <= 1'b0;
            end
            else if (state_yellow0 == 1'b1) begin
               y_out_sd_100 <= 10'h348; cb_out_sd_100 <= 10'h040; cr_out_sd_100 <= 10'h24A;
               patho_equ_sd_100 <= 1'b1; patho_pll_sd_100 <= 1'b1; patho_blk_sd_100 <= 1'b0;
            end
            else if (state_cyan0 == 1'b1) begin
               y_out_sd_100 <= 10'h2A6; cb_out_sd_100 <= 10'h298; cr_out_sd_100 <= 10'h040;
               patho_equ_sd_100 <= 1'b1; patho_pll_sd_100 <= 1'b1; patho_blk_sd_100 <= 1'b0;
            end
            else if (state_green0 == 1'b1) begin
               y_out_sd_100 <= 10'h242; cb_out_sd_100 <= 10'h0D7; cr_out_sd_100 <= 10'h089;
               patho_equ_sd_100 <= 1'b1; patho_pll_sd_100 <= 1'b1; patho_blk_sd_100 <= 1'b0;
            end
            else if (state_magenta0 == 1'b1) begin
               y_out_sd_100 <= 10'h1AA; cb_out_sd_100 <= 10'h329; cr_out_sd_100 <= 10'h378;
               patho_equ_sd_100 <= 1'b1; patho_pll_sd_100 <= 1'b1; patho_blk_sd_100 <= 1'b0;
            end
            else if (state_red0 == 1'b1) begin
               y_out_sd_100 <= 10'h146; cb_out_sd_100 <= 10'h169; cr_out_sd_100 <= 10'h3C0;
               patho_equ_sd_100 <= 1'b1; patho_pll_sd_100 <= 1'b1; patho_blk_sd_100 <= 1'b0;
            end
            else if (state_blue0 == 1'b1) begin
               y_out_sd_100 <= 10'h0A4; cb_out_sd_100 <= 10'h3C0; cr_out_sd_100 <= 10'h1B6;
               patho_equ_sd_100 <= 1'b1; patho_pll_sd_100 <= 1'b1; patho_blk_sd_100 <= 1'b0;
            end
            else begin
               y_out_sd_100 <= 10'h040; cb_out_sd_100 <= 10'h200; cr_out_sd_100 <= 10'h200;
               patho_equ_sd_100 <= 1'b0; patho_pll_sd_100 <= 1'b0; patho_blk_sd_100 <= 1'b1;
            end
         // SD Color Bars Pattern: 75% Color Bars
            if (state_white0 == 1'b1) begin
               y_out_sd_75 <= 10'h3AC; cb_out_sd_75 <= 10'h200; cr_out_sd_75 <= 10'h200;
               patho_equ_sd_75 <= 1'b1; patho_pll_sd_75 <= 1'b1; patho_blk_sd_75 <= 1'b0;
            end
            else if (state_yellow0 == 1'b1) begin
               y_out_sd_75 <= 10'h286; cb_out_sd_75 <= 10'h0B0; cr_out_sd_75 <= 10'h237;
               patho_equ_sd_75 <= 1'b1; patho_pll_sd_75 <= 1'b1; patho_blk_sd_75 <= 1'b0;
            end
            else if (state_cyan0 == 1'b1) begin
               y_out_sd_75 <= 10'h20D; cb_out_sd_75 <= 10'h271; cr_out_sd_75 <= 10'h0B0;
               patho_equ_sd_75 <= 1'b1; patho_pll_sd_75 <= 1'b1; patho_blk_sd_75 <= 1'b0;
            end
            else if (state_green0 == 1'b1) begin
               y_out_sd_75 <= 10'h1C2; cb_out_sd_75 <= 10'h122; cr_out_sd_75 <= 10'h0E7;
               patho_equ_sd_75 <= 1'b1; patho_pll_sd_75 <= 1'b1; patho_blk_sd_75 <= 1'b0;
            end
            else if (state_magenta0 == 1'b1) begin
               y_out_sd_75 <= 10'h14F; cb_out_sd_75 <= 10'h2DE; cr_out_sd_75 <= 10'h319;
               patho_equ_sd_75 <= 1'b1; patho_pll_sd_75 <= 1'b1; patho_blk_sd_75 <= 1'b0;
            end
            else if (state_red0 == 1'b1) begin
               y_out_sd_75 <= 10'h104; cb_out_sd_75 <= 10'h18F; cr_out_sd_75 <= 10'h350;
               patho_equ_sd_75 <= 1'b1; patho_pll_sd_75 <= 1'b1; patho_blk_sd_75 <= 1'b0;
            end
            else if (state_blue0 == 1'b1) begin
               y_out_sd_75 <= 10'h08B; cb_out_sd_75 <= 10'h350; cr_out_sd_75 <= 10'h1C9;
               patho_equ_sd_75 <= 1'b1; patho_pll_sd_75 <= 1'b1; patho_blk_sd_75 <= 1'b0;
            end
            else begin
               y_out_sd_75 <= 10'h040; cb_out_sd_75 <= 10'h200; cr_out_sd_75 <= 10'h200;
               patho_equ_sd_75 <= 1'b0; patho_pll_sd_75 <= 1'b0; patho_blk_sd_75 <= 1'b1;
            end
         // SD Color Bars Pattern: SMPTE Color Bars
            if ((state_gray1 == 1'b1) || (state_gray2 == 1'b1)) begin
               y_out_sd_smpte <= 10'h2D1; cb_out_sd_smpte <= 10'h200; cr_out_sd_smpte <= 10'h200;
               patho_equ_sd_smpte <= 1'b1; patho_pll_sd_smpte <= 1'b1; patho_blk_sd_smpte <= 1'b0;
            end
            else if (state_yellow1 == 1'b1) begin
               y_out_sd_smpte <= 10'h286; cb_out_sd_smpte <= 10'h0B0; cr_out_sd_smpte <= 10'h237;
               patho_equ_sd_smpte <= 1'b1; patho_pll_sd_smpte <= 1'b1; patho_blk_sd_smpte <= 1'b0;
            end
            else if ((state_cyan1 == 1'b1) || (state_cyan2 == 1'b1)) begin
               y_out_sd_smpte <= 10'h20D; cb_out_sd_smpte <= 10'h271; cr_out_sd_smpte <= 10'h0B0;
               patho_equ_sd_smpte <= 1'b1; patho_pll_sd_smpte <= 1'b1; patho_blk_sd_smpte <= 1'b0;
            end
            else if (state_green1 == 1'b1) begin
               y_out_sd_smpte <= 10'h1C2; cb_out_sd_smpte <= 10'h122; cr_out_sd_smpte <= 10'h0E7;
               patho_equ_sd_smpte <= 1'b1; patho_pll_sd_smpte <= 1'b1; patho_blk_sd_smpte <= 1'b0;
            end
            else if ((state_magenta1 == 1'b1) || (state_magenta2 == 1'b1)) begin
               y_out_sd_smpte <= 10'h14F; cb_out_sd_smpte <= 10'h2DE; cr_out_sd_smpte <= 10'h319;
               patho_equ_sd_smpte <= 1'b1; patho_pll_sd_smpte <= 1'b1; patho_blk_sd_smpte <= 1'b0;
            end
            else if (state_red1 == 1'b1) begin
               y_out_sd_smpte <= 10'h104; cb_out_sd_smpte <= 10'h18F; cr_out_sd_smpte <= 10'h350;
               patho_equ_sd_smpte <= 1'b1; patho_pll_sd_smpte <= 1'b1; patho_blk_sd_smpte <= 1'b0;
            end
            else if ((state_blue1 == 1'b1) || (state_blue2 == 1'b1)) begin
               y_out_sd_smpte <= 10'h08B; cb_out_sd_smpte <= 10'h350; cr_out_sd_smpte <= 10'h1C9;
               patho_equ_sd_smpte <= 1'b1; patho_pll_sd_smpte <= 1'b1; patho_blk_sd_smpte <= 1'b0;
            end
            else if (state_minus_i == 1'b1) begin
               y_out_sd_smpte <= 10'h040; cb_out_sd_smpte <= 10'h279; cr_out_sd_smpte <= 10'h17C;
               patho_equ_sd_smpte <= 1'b1; patho_pll_sd_smpte <= 1'b1; patho_blk_sd_smpte <= 1'b0;
            end
            else if (state_white3 == 1'b1) begin
               y_out_sd_smpte <= 10'h3AC; cb_out_sd_smpte <= 10'h200; cr_out_sd_smpte <= 10'h200;
               patho_equ_sd_smpte <= 1'b1; patho_pll_sd_smpte <= 1'b1; patho_blk_sd_smpte <= 1'b0;
            end
            else if (state_plus_q == 1'b1) begin
               y_out_sd_smpte <= 10'h040; cb_out_sd_smpte <= 10'h2BA; cr_out_sd_smpte <= 10'h256;
               patho_equ_sd_smpte <= 1'b1; patho_pll_sd_smpte <= 1'b1; patho_blk_sd_smpte <= 1'b0;
            end
            else if (state_black_p == 1'b1) begin
               y_out_sd_smpte <= 10'h01D; cb_out_sd_smpte <= 10'h200; cr_out_sd_smpte <= 10'h200;
               patho_equ_sd_smpte <= 1'b1; patho_pll_sd_smpte <= 1'b1; patho_blk_sd_smpte <= 1'b0;
            end
            else if (state_black_n == 1'b1) begin
               y_out_sd_smpte <= 10'h063; cb_out_sd_smpte <= 10'h200; cr_out_sd_smpte <= 10'h200;
               patho_equ_sd_smpte <= 1'b1; patho_pll_sd_smpte <= 1'b1; patho_blk_sd_smpte <= 1'b0;
            end
            else begin
               y_out_sd_smpte <= 10'h040; cb_out_sd_smpte <= 10'h200; cr_out_sd_smpte <= 10'h200;
               patho_equ_sd_smpte <= 1'b0; patho_pll_sd_smpte <= 1'b0; patho_blk_sd_smpte <= 1'b1;
            end
         // HD Color Bars Pattern: 100% Color Bars
            if (state_white0 == 1'b1) begin
               y_out_hd_100 <= 10'h3AC; cb_out_hd_100 <= 10'h200; cr_out_hd_100 <= 10'h200;
               patho_equ_hd_100 <= 1'b1; patho_pll_hd_100 <= 1'b1; patho_blk_hd_100 <= 1'b0;
            end
            else if (state_yellow0 == 1'b1) begin
               y_out_hd_100 <= 10'h36D; cb_out_hd_100 <= 10'h040; cr_out_hd_100 <= 10'h229;
               patho_equ_hd_100 <= 1'b1; patho_pll_hd_100 <= 1'b1; patho_blk_hd_100 <= 1'b0;
            end
            else if (state_cyan0 == 1'b1) begin
               y_out_hd_100 <= 10'h2F2; cb_out_hd_100 <= 10'h267; cr_out_hd_100 <= 10'h040;
               patho_equ_hd_100 <= 1'b1; patho_pll_hd_100 <= 1'b1; patho_blk_hd_100 <= 1'b0;
            end
            else if (state_green0 == 1'b1) begin
               y_out_hd_100 <= 10'h2B3; cb_out_hd_100 <= 10'h0A7; cr_out_hd_100 <= 10'h069;
               patho_equ_hd_100 <= 1'b1; patho_pll_hd_100 <= 1'b1; patho_blk_hd_100 <= 1'b0;
            end
            else if (state_magenta0 == 1'b1) begin
               y_out_hd_100 <= 10'h139; cb_out_hd_100 <= 10'h359; cr_out_hd_100 <= 10'h397;
               patho_equ_hd_100 <= 1'b1; patho_pll_hd_100 <= 1'b1; patho_blk_hd_100 <= 1'b0;
            end
            else if (state_red0 == 1'b1) begin
               y_out_hd_100 <= 10'h0FA; cb_out_hd_100 <= 10'h199; cr_out_hd_100 <= 10'h3C0;
               patho_equ_hd_100 <= 1'b1; patho_pll_hd_100 <= 1'b1; patho_blk_hd_100 <= 1'b0;
            end
            else if (state_blue0 == 1'b1) begin
               y_out_hd_100 <= 10'h07F; cb_out_hd_100 <= 10'h3C0; cr_out_hd_100 <= 10'h1D7;
               patho_equ_hd_100 <= 1'b1; patho_pll_hd_100 <= 1'b1; patho_blk_hd_100 <= 1'b0;
            end
            else begin
               y_out_hd_100 <= 10'h040; cb_out_hd_100 <= 10'h200; cr_out_hd_100 <= 10'h200;
               patho_equ_hd_100 <= 1'b0; patho_pll_hd_100 <= 1'b0; patho_blk_hd_100 <= 1'b1;
            end
         // HD Color Bars Pattern: 75% Color Bars
            if (state_white0 == 1'b1) begin
               y_out_hd_75 <= 10'h3AC; cb_out_hd_75 <= 10'h200; cr_out_hd_75 <= 10'h200;
               patho_equ_hd_75 <= 1'b1; patho_pll_hd_75 <= 1'b1; patho_blk_hd_75 <= 1'b0;
            end
            else if (state_yellow0 == 1'b1) begin
               y_out_hd_75 <= 10'h2A2; cb_out_hd_75 <= 10'h0B0; cr_out_hd_75 <= 10'h21F;
               patho_equ_hd_75 <= 1'b1; patho_pll_hd_75 <= 1'b1; patho_blk_hd_75 <= 1'b0;
            end
            else if (state_cyan0 == 1'b1) begin
               y_out_hd_75 <= 10'h245; cb_out_hd_75 <= 10'h24D; cr_out_hd_75 <= 10'h0B0;
               patho_equ_hd_75 <= 1'b1; patho_pll_hd_75 <= 1'b1; patho_blk_hd_75 <= 1'b0;
            end
            else if (state_green0 == 1'b1) begin
               y_out_hd_75 <= 10'h216; cb_out_hd_75 <= 10'h0FD; cr_out_hd_75 <= 10'h0CF;
               patho_equ_hd_75 <= 1'b1; patho_pll_hd_75 <= 1'b1; patho_blk_hd_75 <= 1'b0;
            end
            else if (state_magenta0 == 1'b1) begin
               y_out_hd_75 <= 10'h0FB; cb_out_hd_75 <= 10'h303; cr_out_hd_75 <= 10'h331;
               patho_equ_hd_75 <= 1'b1; patho_pll_hd_75 <= 1'b1; patho_blk_hd_75 <= 1'b0;
            end
            else if (state_red0 == 1'b1) begin
               y_out_hd_75 <= 10'h0CC; cb_out_hd_75 <= 10'h1B3; cr_out_hd_75 <= 10'h350;
               patho_equ_hd_75 <= 1'b1; patho_pll_hd_75 <= 1'b1; patho_blk_hd_75 <= 1'b0;
            end
            else if (state_blue0 == 1'b1) begin
               y_out_hd_75 <= 10'h06F; cb_out_hd_75 <= 10'h350; cr_out_hd_75 <= 10'h1E1;
               patho_equ_hd_75 <= 1'b1; patho_pll_hd_75 <= 1'b1; patho_blk_hd_75 <= 1'b0;
            end
            else begin
               y_out_hd_75 <= 10'h040; cb_out_hd_75 <= 10'h200; cr_out_hd_75 <= 10'h200;
               patho_equ_hd_75 <= 1'b0; patho_pll_hd_75 <= 1'b0; patho_blk_hd_75 <= 1'b0;
            end
         // HD Color Bars Pattern: SMPTE Color Bars
            if ((state_gray1 == 1'b1) || (state_gray2 == 1'b1)) begin
               y_out_hd_smpte <= 10'h2D1; cb_out_hd_smpte <= 10'h200; cr_out_hd_smpte <= 10'h200;
               patho_equ_hd_smpte <= 1'b1; patho_pll_hd_smpte <= 1'b1; patho_blk_hd_smpte <= 1'b0;
            end
            else if (state_yellow1 == 1'b1) begin
               y_out_hd_smpte <= 10'h2A2; cb_out_hd_smpte <= 10'h0B0; cr_out_hd_smpte <= 10'h21F;
               patho_equ_hd_smpte <= 1'b1; patho_pll_hd_smpte <= 1'b1; patho_blk_hd_smpte <= 1'b0;
            end
            else if ((state_cyan1 == 1'b1) || (state_cyan2 == 1'b1)) begin
               y_out_hd_smpte <= 10'h245; cb_out_hd_smpte <= 10'h24D; cr_out_hd_smpte <= 10'h0B0;
               patho_equ_hd_smpte <= 1'b1; patho_pll_hd_smpte <= 1'b1; patho_blk_hd_smpte <= 1'b0;
            end
            else if (state_green1 == 1'b1) begin
               y_out_hd_smpte <= 10'h216; cb_out_hd_smpte <= 10'h0FD; cr_out_hd_smpte <= 10'h0CF;
               patho_equ_hd_smpte <= 1'b1; patho_pll_hd_smpte <= 1'b1; patho_blk_hd_smpte <= 1'b0;
            end
            else if ((state_magenta1 == 1'b1) || (state_magenta2 == 1'b1)) begin
               y_out_hd_smpte <= 10'h0FB; cb_out_hd_smpte <= 10'h303; cr_out_hd_smpte <= 10'h331;
               patho_equ_hd_smpte <= 1'b1; patho_pll_hd_smpte <= 1'b1; patho_blk_hd_smpte <= 1'b0;
            end
            else if (state_red1 == 1'b1) begin
               y_out_hd_smpte <= 10'h0CC; cb_out_hd_smpte <= 10'h1B3; cr_out_hd_smpte <= 10'h350;
               patho_equ_hd_smpte <= 1'b1; patho_pll_hd_smpte <= 1'b1; patho_blk_hd_smpte <= 1'b0;
            end
            else if ((state_blue1 == 1'b1) || (state_blue2 == 1'b1)) begin
               y_out_hd_smpte <= 10'h06F; cb_out_hd_smpte <= 10'h350; cr_out_hd_smpte <= 10'h1E1;
               patho_equ_hd_smpte <= 1'b1; patho_pll_hd_smpte <= 1'b1; patho_blk_hd_smpte <= 1'b0;
            end
            else if (state_minus_i == 1'b1) begin
               y_out_hd_smpte <= 10'h04D; cb_out_hd_smpte <= 10'h26C; cr_out_hd_smpte <= 10'h182;
               patho_equ_hd_smpte <= 1'b1; patho_pll_hd_smpte <= 1'b1; patho_blk_hd_smpte <= 1'b0;
            end
            else if (state_white3 == 1'b1) begin
               y_out_hd_smpte <= 10'h3AC; cb_out_hd_smpte <= 10'h200; cr_out_hd_smpte <= 10'h200;
               patho_equ_hd_smpte <= 1'b1; patho_pll_hd_smpte <= 1'b1; patho_blk_hd_smpte <= 1'b0;
            end
            else if (state_plus_q == 1'b1) begin
               y_out_hd_smpte <= 10'h019; cb_out_hd_smpte <= 10'h2C8; cr_out_hd_smpte <= 10'h266;
               patho_equ_hd_smpte <= 1'b1; patho_pll_hd_smpte <= 1'b1; patho_blk_hd_smpte <= 1'b0;
            end
            else if (state_black_p == 1'b1) begin
               y_out_hd_smpte <= 10'h01D; cb_out_hd_smpte <= 10'h200; cr_out_hd_smpte <= 10'h200;
               patho_equ_hd_smpte <= 1'b1; patho_pll_hd_smpte <= 1'b1; patho_blk_hd_smpte <= 1'b0;
            end
            else if (state_black_n == 1'b1) begin
               y_out_hd_smpte <= 10'h063; cb_out_hd_smpte <= 10'h200; cr_out_hd_smpte <= 10'h200;
               patho_equ_hd_smpte <= 1'b1; patho_pll_hd_smpte <= 1'b1; patho_blk_hd_smpte <= 1'b0;
            end
            else begin
               y_out_hd_smpte <= 10'h040; cb_out_hd_smpte <= 10'h200; cr_out_hd_smpte <= 10'h200;
               patho_equ_hd_smpte <= 1'b0; patho_pll_hd_smpte <= 1'b0; patho_blk_hd_smpte <= 1'b1;
            end
      end
   end

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      hd_3g_reg <= 1'b1; pattern_group_sel_reg <= 1'b0; cbtype_smpte_reg <= 1'b0;
      cbtype_75_reg <= 1'b0; pll_test_only_reg <= 1'b0; equ_test_only_reg <= 1'b0;
   end
   else begin
      hd_3g_reg <= hd_3g; pattern_group_sel_reg <= pattern_group_sel; cbtype_smpte_reg <= cbtype_smpte;
      cbtype_75_reg <= cbtype_75; pll_test_only_reg <= pll_test_only; equ_test_only_reg <= equ_test_only;
   end

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      y_out <= 10'h040; cb_out <= 10'h200; cr_out <= 10'h200;
      patho_equ <= 1'b0; patho_pll <= 1'b0; patho_blk <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      y_out <= 10'h040; cb_out <= 10'h200; cr_out <= 10'h200;
      patho_equ <= 1'b0; patho_pll <= 1'b0; patho_blk <= 1'b0;
   end
   else begin
      if (clken_cp1 == 1'b1) begin
         if (hd_3g_reg == 1'b0) // SD systems
            casex ({pattern_group_sel_reg, cbtype_smpte_reg, cbtype_75_reg, pll_test_only_reg, equ_test_only_reg})
               5'b1xx00:  // Pathological Pattern: Matrix Check-Field
                  begin
                     y_out <= y_out_matrix; cb_out <= cb_out_matrix; cr_out <= cr_out_matrix;
                     patho_equ <= patho_equ_matrix; patho_pll <= patho_pll_matrix; patho_blk <= patho_blk_matrix;
                  end
               5'b1xx01:  // Pathological Pattern: EQU Check-Field
                  begin
                     y_out <= y_out_equ; cb_out <= cb_out_equ; cr_out <= cr_out_equ;
                     patho_equ <= patho_equ_equ; patho_pll <= patho_pll_equ; patho_blk <= patho_blk_equ;
                  end
               5'b1xx10:  // Pathological Pattern: PLL Check-Field
                  begin
                     y_out <= y_out_pll; cb_out <= cb_out_pll; cr_out <= cr_out_pll;
                     patho_equ <= patho_equ_pll; patho_pll <= patho_pll_pll; patho_blk <= patho_blk_pll;
                  end
               5'b000xx:  // SD Color Bars Pattern: 100% Color Bars
                  begin
                     y_out <= y_out_sd_100; cb_out <= cb_out_sd_100; cr_out <= cr_out_sd_100;
                     patho_equ <= patho_equ_sd_100; patho_pll <= patho_pll_sd_100; patho_blk <= patho_blk_sd_100;
                  end
               5'b001xx:  // SD Color Bars Pattern: 75% Color Bars
                  begin
                     y_out <= y_out_sd_75; cb_out <= cb_out_sd_75; cr_out <= cr_out_sd_75;
                     patho_equ <= patho_equ_sd_75; patho_pll <= patho_pll_sd_75; patho_blk <= patho_blk_sd_75;
                  end
               5'b010xx:  // SD Color Bars Pattern: SMPTE Color Bars
                  begin
                     y_out <= y_out_sd_smpte; cb_out <= cb_out_sd_smpte; cr_out <= cr_out_sd_smpte;
                     patho_equ <= patho_equ_sd_smpte; patho_pll <= patho_pll_sd_smpte; patho_blk <= patho_blk_sd_smpte;
                  end
            endcase
         else // HD systems
            casex ({pattern_group_sel_reg, cbtype_smpte_reg, cbtype_75_reg, pll_test_only_reg, equ_test_only_reg})
               5'b1xx00:  // Pathological Pattern: Matrix Check-Field
                  begin
                     y_out <= y_out_matrix; cb_out <= cb_out_matrix; cr_out <= cr_out_matrix;
                     patho_equ <= patho_equ_matrix; patho_pll <= patho_pll_matrix; patho_blk <= patho_blk_matrix;
                  end
               5'b1xx01:  // Pathological Pattern: EQU Check-Field
                  begin
                     y_out <= y_out_equ; cb_out <= cb_out_equ; cr_out <= cr_out_equ;
                     patho_equ <= patho_equ_equ; patho_pll <= patho_pll_equ; patho_blk <= patho_blk_equ;
                  end
               5'b1xx10:  // Pathological Pattern: PLL Check-Field
                  begin
                     y_out <= y_out_pll; cb_out <= cb_out_pll; cr_out <= cr_out_pll;
                     patho_equ <= patho_equ_pll; patho_pll <= patho_pll_pll; patho_blk <= patho_blk_pll;
                  end
               5'b000xx:  // HD Color Bars Pattern: 100% Color Bars
                  begin
                     y_out <= y_out_hd_100; cb_out <= cb_out_hd_100; cr_out <= cr_out_hd_100;
                     patho_equ <= patho_equ_hd_100; patho_pll <= patho_pll_hd_100; patho_blk <= patho_blk_hd_100;
                  end
               5'b001xx:  // HD Color Bars Pattern: 75% Color Bars
                  begin
                     y_out <= y_out_hd_75; cb_out <= cb_out_hd_75; cr_out <= cr_out_hd_75;
                     patho_equ <= patho_equ_hd_75; patho_pll <= patho_pll_hd_75; patho_blk <= patho_blk_hd_75;
                  end
               5'b010xx:  // HD Color Bars Pattern: SMPTE Color Bars
                  begin
                     y_out <= y_out_hd_smpte; cb_out <= cb_out_hd_smpte; cr_out <= cr_out_hd_smpte;
                     patho_equ <= patho_equ_hd_smpte; patho_pll <= patho_pll_hd_smpte; patho_blk <= patho_blk_hd_smpte;
                  end
            endcase
      end
   end
   
   
endmodule
