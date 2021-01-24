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
//  File:              pattern_data.v
//  Title:             pattern_data
//  Description:       This module generates the required outputs for
//                     the system to display color bars or to run
//                     pathological tests.  These outputs include
//                     (1) the Y, Cb, Cr pattern outputs
//                     (2) the XYZ output
//                     (3) the TRS output
//                     (4) the H_ref output for the line_number
//                     (5) the sync_counter to sync up the data patterns
//
// --------------------------------------------------------------------
// Author : Joseph H., Guolin W.
// $Revision: 1.2 $
// --------------------------------------------------------------------

`timescale 1ns/100ps

module pattern_data (
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
   input wire [10:0] reg_yb_in_b,
   input wire [10:0] reg_yc_in,
   input wire [10:0] reg_yd_in,
   input wire [10:0] reg_yd_in_b,
   input wire [10:0] reg_ye_in,
   input wire [10:0] reg_yf_in,
   input wire [10:0] reg_yg_in,
   input wire [10:0] reg_yg_in_b,
   input wire [10:0] reg_yh_in,
   input wire [10:0] reg_yi_in,
   input wire [10:0] reg_yi_in_b,
   input wire [10:0] reg_yj_in,
   input wire [10:0] reg_yk_in,
   input wire [10:0] reg_yl_in,

   // line number control
   input wire [10:0] reg_ln_in,

   // the following 5 groups of definition for _b and no _b are the same :
   // no _b : linkA of the dual 292M HD link at 3G level-B mode, or default for all other mode
   // _b : only for 3G level-B, linkB of the dual 292M HD link 
   // pattern group selection (low for color bars, high for pathological test)
   input wire pattern_group_sel_in, 
   input wire pattern_group_sel_in_b, 

   // color bars type control (00:100%, 01:75%, 1X:smpte)
   input wire cbtype_smpte_in,
   input wire cbtype_smpte_in_b,     
   input wire cbtype_75_in,
   input wire cbtype_75_in_b,

   // pathological type control (00:matrix, 01:equ, 10:pll)
   input wire pll_test_only_in,
   input wire pll_test_only_in_b,
   input wire equ_test_only_in,
   input wire equ_test_only_in_b,

   // progressive control (1 for progressive, 0 for interlaced)
   input wire progressive_in,

   // hd/sd control (1 for hd, 0 for sd)
   input wire hd_sdn_in,

   // sdi/3G control (1 for 3G)
   input wire sdi_3g_in,
   
   // 3G level-B control (1 for 3G level-B)         
   input wire lb_lan_in,     
                          
   // 3g level-b dual link structure
   input wire sdi_3g_dl,
   
   // 3g level-b dual link HD or 372M dual link structure     
   input wire sdi_3g_hd_dl,   
                                   
   // 3G image formats selection
   input wire [4:0] format_sel_3g,

   // pixel data outputs
   output reg [9:0] y_out,
   output reg [9:0] cb_out,
   output reg [9:0] cr_out,
   output reg [9:0] y_out_b,
   output reg [9:0] cb_out_b,
   output reg [9:0] cr_out_b,
   
   // xyz output
   output wire [9:0] xyz_out,

   // synchronized trs outputs
   output reg trs_out,

   // output for synchronizing the 2-bit counter in pattern_gen_top module
   output wire sync_counter,

   // synchronized hd/sd control output (1 for hd, 0 for sd)
   output reg hd_sdn_out,

   // synchronized 3g/sdi control output (1 for 3g)
   output reg sdi_3g_out,
   
   // synchronized dual link output (1 for dual link)         
   output reg sdi_3g_hd_dl_out,
                       
   // synchronized 3g level control output (1 for 3g level-b)
   output reg lb_lan_out,
   
   // synchronized 3g format output (1 for 3g)
   output reg [1:0] format_3g_out,

   // F,V,H output used as a reference signal when generating other signals
   output wire F_ref,
   output wire V_ref,
   output reg  H_ref,

   // signals used for detecting the type of pathological error
   output reg patho_equ,
   output reg patho_pll,
   output reg patho_blk,
   output reg patho_equ_b,
   output reg patho_pll_b,
   output reg patho_blk_b,

   // synchronized line number control output
   output wire [10:0] reg_ln_sync,

   // "rst_update" signal to reset "update" and line_number
   output wire rst_update
);

// Y, Cb, Cr pixels values of the patterns
   wire [9:0] y_fsm;
   wire [9:0] cb_fsm;
   wire [9:0] cr_fsm;
   wire [9:0] y_fsm_b;   
   wire [9:0] cb_fsm_b;  
   wire [9:0] cr_fsm_b;  

// f, v, h, and trs and their delayed versions
   wire       f_fsm;
   wire       v_fsm;
   wire       h_fsm;
   reg        h_fsm_delay1;
   reg        f;
   reg        v;
   reg        h;
   wire       trs_fsm;
   reg        trs_fsm_delay1;

// sync_hd_sdn_fsm
   wire       sync_hd_sdn_fsm;

// sync_sdi_3g_fsm
   wire       sync_sdi_3g_fsm;

// synchronized dual link output (1 for dual link)    
   wire       sync_sdi_3g_hd_dl_fsm;        

// sync_format_3g_fsm
   wire [1:0] sync_format_3g_fsm;

// sync_lb_lan_fsm              
   wire       sync_lb_lan_fsm;  

// delayed sync_hd_sdn_fsm for matching the number delay clocks
   reg        sync_hd_sdn_fsm_delay1;

// delayed sync_sdi_3g_fsm for matching the number delay clocks
   reg        sync_sdi_3g_fsm_delay1;

// delayed sync_lb_lan_fsm for matching the number delay clocks
   reg        sync_lb_lan_delay1;
   
// delayed sync_sdi_3g_hd_dl_fsm for matching the number delay clocks 
   reg        sync_sdi_3g_hd_dl_fsm_delay1;

// synchronized 3g format output (1 for 3g)
   reg [1:0]  sync_format_3g_fsm_delay1;

// temporary signal for generating sync_counter
   reg        sync_cnt_tmp;

// signals for pathological test error type detecting
   wire       patho_equ_fsm;
   wire       patho_pll_fsm;
   wire       patho_blk_fsm;      
   wire       patho_equ_fsm_b;    
   wire       patho_pll_fsm_b;    
   wire       patho_blk_fsm_b;    

   reg  [7:0] xyz_out_buf;

   assign xyz_out = {xyz_out_buf,2'b00};

// xyz generation and H_ref
// H_ref is used as a reference signal when generating other signals.

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      f            <= 1'b0;
      v            <= 1'b0;
      h_fsm_delay1 <= 1'b0;
      H_ref        <= 1'b0;
      h            <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      f            <= 1'b0;
      v            <= 1'b0;
      h_fsm_delay1 <= 1'b0;
      H_ref        <= 1'b0;
      h            <= 1'b0;
   end
   else begin
      if (clken == 1'b1) begin
         f            <= f_fsm;
         v            <= v_fsm;
         h_fsm_delay1 <= h_fsm;
         H_ref        <= h_fsm_delay1;
         if ((trs_fsm == 1'b1) && (trs_fsm_delay1 == 1'b0)) h <= ~ h_fsm_delay1;
      end
   end

assign F_ref = xyz_out_buf[6];
assign V_ref = xyz_out_buf[5];

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) xyz_out_buf <= 8'h0;
   else if (sync_rst == 1'b1) xyz_out_buf <= 8'h0;
   else if (clken == 1'b1) xyz_out_buf <= { 1'b1 , f, v, h, v^h, f^h, f^v, f^v^h};

// delayed Y, Cb, Cr for 2 clocks

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      y_out    <= 10'h0;
      cb_out   <= 10'h0;
      cr_out   <= 10'h0;   
      y_out_b  <= 10'h0; 
      cb_out_b <= 10'h0; 
      cr_out_b <= 10'h0; 
   end
   else if (sync_rst == 1'b1) begin
      y_out    <= 10'h0;
      cb_out   <= 10'h0;
      cr_out   <= 10'h0;
      y_out_b  <= 10'h0;  
      cb_out_b <= 10'h0;  
      cr_out_b <= 10'h0;   
   end
   else if (clken == 1'b1) begin
      y_out    <= y_fsm;
      cb_out   <= cb_fsm;
      cr_out   <= cr_fsm;
      y_out_b  <= y_fsm_b;     
      cb_out_b <= cb_fsm_b;    
      cr_out_b <= cr_fsm_b;    
   end

// Instantiation of the pattern FSM

   pattern_fsm pattern_fsm_inst (
      // reset, clock and clock enable
      .rstn(rstn),
      .sync_rst(sync_rst),
      .clk(clk),
      .clken(clken),
      .clken_cp0(clken_cp0),
      .clken_cp1(clken_cp1),
      // controls signal update enable
      .update_controls_in(update_controls_in),
      
      // update mode(1:update at the boundary of the frame, 0:update at the boundary of the line) 
      .update_mode(update_mode),                                                                     
      
      // pixel data controls
      .reg_xa_in(reg_xa_in),
      .reg_xb_in(reg_xb_in),
      .reg_xc_in(reg_xc_in),
      .reg_xd_in(reg_xd_in),
      .reg_xe_in(reg_xe_in),
      .reg_xf_in(reg_xf_in),
      .reg_xg_in(reg_xg_in),
      .reg_xh_in(reg_xh_in),
      .reg_xi_in(reg_xi_in),

      // line data controls
      .reg_ya_in(reg_ya_in),
      .reg_yb_in(reg_yb_in),
      .reg_yc_in(reg_yc_in),
      .reg_yd_in(reg_yd_in),
      .reg_ye_in(reg_ye_in),
      .reg_yf_in(reg_yf_in),
      .reg_yg_in(reg_yg_in),
      .reg_yh_in(reg_yh_in),
      .reg_yi_in(reg_yi_in),
      .reg_yj_in(reg_yj_in),
      .reg_yk_in(reg_yk_in),
      .reg_yl_in(reg_yl_in),

      // line number control
      .reg_ln_in(reg_ln_in),

      // pattern group selection (low for color bars, high for pathological test)
      .pattern_group_sel_in(pattern_group_sel_in),
      // color bars type control (00:100%, 01:75%, 1X:smpte)
      .cbtype_smpte_in(cbtype_smpte_in),
      .cbtype_75_in(cbtype_75_in),

      // pathological type control (00:matrix, 01:equ, 10:pll)
      .pll_test_only_in(pll_test_only_in),
      .equ_test_only_in(equ_test_only_in),

      // progressive control (1 for progressive, 0 for interlaced)
      .progressive_in(progressive_in),

      // hd/sd control (1 for hd, o for sd)
      .hd_sdn_in(hd_sdn_in),

      // 3g/sdi control (1 for 3g)
      .sdi_3g_in(sdi_3g_in),
      
      // 3G level-B control (1 for 3G level-B)          
      .lb_lan_in(lb_lan_in),                            
      
      // 3G image formats selection
      .format_sel_3g(format_sel_3g),

      // synchronized hd/sd control output (1 for hd, 0 for sd)
      .sync_hd_sdn_out(sync_hd_sdn_fsm),

      // synchronized 3g/sdi control output (1 for 3g)
      .sync_sdi_3g_out(sync_sdi_3g_fsm),
      
      // synchronized 3g level control output (1 for 3g level-b)  
      .sync_lb_lan_out(sync_lb_lan_fsm),                                         
      
      // synchronized 3g format output (1 for 3g)
      .sync_format_3g_out(sync_format_3g_fsm),

      // pixel data outputs
      .y_out(y_fsm),
      .cb_out(cb_fsm),
      .cr_out(cr_fsm),   

      // field, vsync, hsync, trs outputs
      .f_out(f_fsm),
      .v_out(v_fsm),
      .h_out(h_fsm),
      .trs_out(trs_fsm),

      // signals used for detecting the type of pathological error
      .patho_equ(patho_equ_fsm),
      .patho_pll(patho_pll_fsm),
      .patho_blk(patho_blk_fsm),      
      
      // synchronized line number control output
      .reg_ln_sync(reg_ln_sync),

      // "rst_update" signal to reset "update" and line_number
      .rst_update(rst_update)
   );
   
   pattern_fsm_b pattern_fsm_b_inst (
      // reset, clock and clock enable
      .rstn(rstn),
      .sync_rst(sync_rst),
      .clk(clk),
      .clken(clken),
      .clken_cp0(clken_cp0),
      .clken_cp1(clken_cp1),
      // controls signal update enable
      .update_controls_in(update_controls_in),
      // update mode(1:update at the boundary of the frame, 0:update at the boundary of the line)      
      .update_mode(update_mode),                                                                       
      
      // pixel data controls
      .reg_xa_in(reg_xa_in),
      .reg_xb_in(reg_xb_in),
      .reg_xc_in(reg_xc_in),
      .reg_xd_in(reg_xd_in),
      .reg_xe_in(reg_xe_in),
      .reg_xf_in(reg_xf_in),
      .reg_xg_in(reg_xg_in),
      .reg_xh_in(reg_xh_in),
      .reg_xi_in(reg_xi_in),

      // line data controls
      .reg_ya_in(reg_ya_in),
      .reg_yb_in(reg_yb_in_b),
      .reg_yc_in(reg_yc_in),
      .reg_yd_in(reg_yd_in_b),
      .reg_ye_in(reg_ye_in),
      .reg_yf_in(reg_yf_in),
      .reg_yg_in(reg_yg_in_b),
      .reg_yh_in(reg_yh_in),
      .reg_yi_in(reg_yi_in_b),
      .reg_yj_in(reg_yj_in),
      .reg_yk_in(reg_yk_in),
      .reg_yl_in(reg_yl_in),

      // line number control
      .reg_ln_in(reg_ln_in),

      // pattern group selection (low for color bars, high for pathological test)
      .pattern_group_sel_in(pattern_group_sel_in_b),
      // color bars type control (00:100%, 01:75%, 1X:smpte)
      .cbtype_smpte_in(cbtype_smpte_in_b),
      .cbtype_75_in(cbtype_75_in_b),

      // pathological type control (00:matrix, 01:equ, 10:pll)
      .pll_test_only_in(pll_test_only_in_b),
      .equ_test_only_in(equ_test_only_in_b),

      // progressive control (1 for progressive, 0 for interlaced)
      .progressive_in(progressive_in),

      // hd/sd control (1 for hd, o for sd)
      .hd_sdn_in(hd_sdn_in),

      // 3g/sdi control (1 for 3g)
      .sdi_3g_in(sdi_3g_in),
      
      // 3G level-B control (1 for 3G level-B)      
      .lb_lan_in(lb_lan_in),  
                             
      // 3g level-b dual link structure
      .sdi_3g_dl (sdi_3g_dl),
      
      // 3g level-b dual link HD or 372M dual link structure              
      .sdi_3g_hd_dl(sdi_3g_hd_dl),  
                                            
      // 3G image formats selection
      .format_sel_3g(format_sel_3g),

      // synchronized hd/sd control output (1 for hd, 0 for sd)
      .sync_hd_sdn_out(),

      // synchronized 3g/sdi control output (1 for 3g)
      .sync_sdi_3g_out(),
      
      // synchronized 3g level control output (1 for 3g level-b)         
      .sync_lb_lan_out(),                                       
      
      // synchronized dual link output (1 for dual link)  
      .sync_sdi_3g_hd_dl_out(sync_sdi_3g_hd_dl_fsm),
      
      // synchronized 3g format output (1 for 3g)
      .sync_format_3g_out(),

      // pixel data outputs
      .y_out(y_fsm_b),   
      .cb_out(cb_fsm_b), 
      .cr_out(cr_fsm_b), 

      // field, vsync, hsync, trs outputs
      .f_out(),
      .v_out(),
      .h_out(),
      .trs_out(),

      // signals used for detecting the type of pathological error
      .patho_equ(patho_equ_fsm_b),      
      .patho_pll(patho_pll_fsm_b),      
      .patho_blk(patho_blk_fsm_b),      
      
      // synchronized line number control output
      .reg_ln_sync(),

      // "rst_update" signal to reset "update" and line_number
      .rst_update()
   );
   
   
// delayed pathological error detecting signals for 2 clocks

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      patho_equ   <= 1'b0;
      patho_pll   <= 1'b0;
      patho_blk   <= 1'b0;  
      patho_equ_b <= 1'b0;      
      patho_pll_b <= 1'b0;      
      patho_blk_b <= 1'b0;      
   end
   else if (sync_rst == 1'b1) begin
      patho_equ   <= 1'b0;
      patho_pll   <= 1'b0;
      patho_blk   <= 1'b0;  
      patho_equ_b <= 1'b0;   
      patho_pll_b <= 1'b0;   
      patho_blk_b <= 1'b0;   
   end
   else if (clken == 1'b1) begin  
      patho_equ   <= patho_equ_fsm;
      patho_pll   <= patho_pll_fsm;
      patho_blk   <= patho_blk_fsm;
      patho_equ_b <= patho_equ_fsm_b;   
      patho_pll_b <= patho_pll_fsm_b;   
      patho_blk_b <= patho_blk_fsm_b;   
   end

// delayed trs_fsm for 2 clocks

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      trs_fsm_delay1 <= 1'h0;
      trs_out        <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      trs_fsm_delay1 <= 1'h0;
      trs_out        <= 1'b0;
   end
   else if (clken == 1'b1) begin    
      trs_fsm_delay1 <= trs_fsm;
      trs_out        <= trs_fsm_delay1;
   end

// "sync_counter" signal is used for reseting the counter in pattern_gen_top module.
// This will make sure the 3FF, 000, 000, XYZ is generated in sync with the Y,Cb,Cr.

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) sync_cnt_tmp <= 1'b0;
   else if (sync_rst == 1'b1) sync_cnt_tmp <= 1'b0;
   else if (clken == 1'b1) sync_cnt_tmp <= trs_fsm & ~trs_fsm_delay1;

   assign sync_counter = sync_cnt_tmp & h_fsm & clken;

// delayed hd_sdn signal for 2 clocks
   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      sync_hd_sdn_fsm_delay1    <= 0;
      hd_sdn_out                <= 0;
      sync_sdi_3g_fsm_delay1    <= 0;
      sdi_3g_out                <= 0;
      sync_format_3g_fsm_delay1 <= 0;
      format_3g_out             <= 0;
      sync_lb_lan_delay1        <= 0;
      lb_lan_out                <= 0;    
      sync_sdi_3g_hd_dl_fsm_delay1<= 0;        
      sdi_3g_hd_dl_out          <= 0;        
   end
   else if (sync_rst == 1'b1) begin
      sync_hd_sdn_fsm_delay1    <= sync_hd_sdn_fsm;
      hd_sdn_out                <= sync_hd_sdn_fsm_delay1;
      sync_sdi_3g_fsm_delay1    <= sync_sdi_3g_fsm;
      sdi_3g_out                <= sync_sdi_3g_fsm_delay1;
      sync_format_3g_fsm_delay1 <= sync_format_3g_fsm;
      format_3g_out             <= sync_format_3g_fsm_delay1;
      sync_lb_lan_delay1        <= sync_lb_lan_fsm;   
      lb_lan_out                <= sync_lb_lan_delay1;
      sync_sdi_3g_hd_dl_fsm_delay1<= sync_sdi_3g_hd_dl_fsm;       
      sdi_3g_hd_dl_out          <= sync_sdi_3g_hd_dl_fsm_delay1;         
   end
   else if (clken == 1'b1) begin
      sync_hd_sdn_fsm_delay1    <= sync_hd_sdn_fsm;
      hd_sdn_out                <= sync_hd_sdn_fsm_delay1;
      sync_sdi_3g_fsm_delay1    <= sync_sdi_3g_fsm;
      sdi_3g_out                <= sync_sdi_3g_fsm_delay1;
      sync_format_3g_fsm_delay1 <= sync_format_3g_fsm;
      format_3g_out             <= sync_format_3g_fsm_delay1;
      sync_lb_lan_delay1        <= sync_lb_lan_fsm;
      lb_lan_out                <= sync_lb_lan_delay1;
      sync_sdi_3g_hd_dl_fsm_delay1<= sync_sdi_3g_hd_dl_fsm;       
      sdi_3g_hd_dl_out          <= sync_sdi_3g_hd_dl_fsm_delay1;         
   end

endmodule
