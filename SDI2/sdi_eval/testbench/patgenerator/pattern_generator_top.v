// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
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
//  File:              pattern_generator.v
//  Title:             pattern_generator
//  Description:       This is the top level of the pattern generator
//                     that generates the color bars and the pathological
//                     test patterns.
//
// --------------------------------------------------------------------
// Author : Joseph H., Guolin W.
// $Revision: 1.2 $
// --------------------------------------------------------------------

`timescale 1ns/100ps

module pattern_generator (
   // reset signal and pixel clock
   input wire rstn,
   input wire sync_rst,
   input wire clk,
   input wire clken_in,

   // signal to update all controls
   input wire update_controls_in,
   
   // update mode(1:update at the boundary of the frame, 0:update at the boundary of the line)
   input wire update_mode,
   
   // the following 5 groups of definition for _b and no _b are the same :
   // no _b : linkA of the dual 292M HD link at 3G level-B mode, or default for all other mode
   // _b : only for 3G level-B, linkB of the dual 292M HD link 
   // pattern group selection (low for color bars, high for pathological test)
   input wire pattern_group_sel_in, 
   input wire pattern_group_sel_in_b, 
   
   // fractional rate selection, 1 : fractional rate; 0 : integral
   input wire pattern_m_factor,   
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

   // sdi/3G control (1 for 3G)
   input wire sdi_3g_in,

   // 3G level-B control (1 for 3G level-B)
   input wire lb_lan_in,

   // 3G image formats selection
   input wire [4:0] format_sel_3g,

   // hd/sd control (1 for hd, 0 for sd)
   input wire hd_sdn_in,

   // standard number
   input wire [3:0] std_number,
   
   // VPID insertion enable
   input wire vpid_insert_en,     
   
   // SMPTE parallel data outputs
   output reg [19:0] data_out/* synthesis syn_useioff = 0 */,

   // synchronized trs outputs
   output reg trs_out,

   // Signals for line number generation
   output reg line_number_set,
   output reg [10:0] line_number,
   
   // 4 bytes video payload identifier
   output wire [31:0] vpid_in,
   
   // field, vblank, hblank outputs
   output wire field,
   output wire vblank,
   output wire hblank,

   // signals used for detecting the type of pathological error
   output reg  patho_xyz,
   output wire patho_trs,
   output wire patho_hbk,
   output reg  patho_equ,
   output reg  patho_pll,
   output reg  patho_blk
);

// 3g level-b 372M dual link structure
   wire       sdi_3g_dl;

// 3g level-b dual link structure
   wire       sdi_3g_hd_dl;
   wire       sdi_3g_hd_dl_int;
// Y, Cb, Cr, xyz, trs and hd_sdn outputs of "color_bar" module
   wire [9:0] y_int;
   wire [9:0] cb_int;
   wire [9:0] cr_int;   
   wire [9:0] y_int_b;       
   wire [9:0] cb_int_b;      
   wire [9:0] cr_int_b;      
   wire [9:0] xyz_int;
   wire       trs_int;
   wire       hd_sdn_int;
   wire       sdi_3g_int;
   wire       lb_lan_int;
   wire [1:0] format_3g_int;
   wire [4:0] data_3g_sel;
   wire [4:0] data_3g_sel_lb;
   reg  [9:0] data_3g_1_video;
   reg  [9:0] data_3g_2_video;
   reg  [9:0] data_3g_1_video_lb;  // for 3g level-b
   reg  [9:0] data_3g_2_video_lb;  

// delayed Cr used for data pattern generation
   reg [9:0] cr_int_delay1;

// delayed hd_sdn, sdi_3g,trs, F_ref, V_ref, H_ref sdi_3g_hd_dl, lb_lan_int used for data pattern selection
   reg sdi_3g_int_delay1;
   reg hd_sdn_int_delay1;
   reg trs_int_delay1;
   reg trs_int_delay2;
   reg trs_int_delay3;
   reg trs_int_delay4;
   reg F_ref_delay1;
   reg F_ref_delay2;
   reg V_ref_delay1;
   reg V_ref_delay2;
   reg H_ref_delay1;
   reg H_ref_delay2; 
   reg H_ref_delay3;
   reg H_ref_delay4;
   reg H_ref_delay5;
   reg sdi_3g_hd_dl_delay1;
   reg lb_lan_int_delay1;  

// 2-bit counter used for data pattern selection
   reg [1:0] counter;
   reg [1:0] counter_dl;

// data pattern for HD/SD system
   reg [9:0] data_hd_y_video;
   reg [9:0] data_hd_cbcr_video;
   reg [9:0] data_sd_video;
   wire [9:0] data_trs;
   reg [8:0] data_trs_buf;

// line words generation:
   wire [9:0] line_word;
   wire [9:0] line_word0;
   wire [9:0] line_word1;

   wire       line_stb;
   reg        line_stb_lb;

// clock enable control of "color_bar" module 
   reg  clken_dl; 
   reg  clken/*synthesis syn_preserve = 1 */;
   reg  clken_cp0/*synthesis syn_preserve = 1 */;
   reg  clken_cp1/*synthesis syn_preserve = 1 */;

// synchronous reset signal for the 2-bit counter
//   This signal is required because the number of clocks in the H blanking
//   period (controled by reg_xa_in) may not be a multiple of 4. This sync
//   signal controls the counter and makes sure the 3FF, 000, 000, XYZ datum
//   are generated in the correct order.
   wire sync_counter;

// F, V, H outputs from color_bar module
   wire F_ref;
   wire V_ref;
   wire H_ref;

   // pixel data controls
   wire [12:0] reg_xa_in;
   wire [12:0] reg_xb_in;
   wire [12:0] reg_xc_in;
   wire [12:0] reg_xd_in;
   wire [12:0] reg_xe_in;
   wire [12:0] reg_xf_in;
   wire [12:0] reg_xg_in;
   wire [12:0] reg_xh_in;
   wire [12:0] reg_xi_in;

   // line data controls
   wire [10:0] reg_ya_in;
   wire [10:0] reg_yb_in;
   wire [10:0] reg_yb_in_b;
   wire [10:0] reg_yc_in;
   wire [10:0] reg_yd_in;
   wire [10:0] reg_yd_in_b;
   wire [10:0] reg_ye_in;
   wire [10:0] reg_yf_in;
   wire [10:0] reg_yg_in;
   wire [10:0] reg_yg_in_b;
   wire [10:0] reg_yh_in;
   wire [10:0] reg_yi_in;
   wire [10:0] reg_yi_in_b;
   wire [10:0] reg_yj_in;
   wire [10:0] reg_yk_in;
   wire [10:0] reg_yl_in;

   // line number control
   wire [10:0] reg_ln_in;

   // progressive control (1 for progressive, 0 for interlaced)
   wire progressive_in;

   // video standard selection
   wire [4:0] std_select;

   // signals for pathological test error type detecting
   wire patho_equ_int;
   wire patho_pll_int;
   wire patho_blk_int;
   reg  patho_equ_int_delay1;
   reg  patho_pll_int_delay1;
   reg  patho_blk_int_delay1;

   // synchronized line number control output
   wire [10:0] reg_ln_sync;

   // "rst_update" signal to reset "update" and line_number
   wire rst_update;

   // signals added for inserting ancillary datas
   wire pat_gen_anc_req;
   wire pat_gen_anc_en;
   wire pat_gen_anc_en_lb_b;
   wire pat_gen_anc_en_dl;
   wire [4:0] format_sel;
   wire [9:0] anc_data;
   wire [9:0] anc_data_b;
   
   // signals added for dual link data generation
   reg  line_word0_en;
   reg  line_word1_en;
   reg  [9:0] dual_link_la;
   reg  [9:0] dual_link_lb;
   
   reg  trs_temp;      

// clock enable generation

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      clken <= 1'b1;
      clken_cp0 <= 1'b1;
      clken_cp1 <= 1'b1;
   end
   else begin
      if (sync_rst == 1'b1) begin clken <= 1'b1; clken_cp0 <= 1'b1; clken_cp1 <= 1'b1; end
      else if (clken_in == 1'b0) begin clken <= 1'b0;  clken_cp0 <= 1'b0; clken_cp1 <= 1'b0; end
      else if ((~hd_sdn_int & ~sdi_3g_int) | sdi_3g_hd_dl_int) begin
         clken <= ~ clken; // SD's pixel clock freq. = 50% data clock freq.        
         clken_cp0 <= ~clken_cp0; clken_cp1 <= ~clken_cp1;                         
      end
      else begin
         clken <= 1'b1;    // HD's pixel clock freq. = data clock freq.         
         clken_cp0 <= 1'b1; clken_cp1 <= 1'b1;                                  
      end
   end
   
// delayed Cr used for data pattern generation

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      cr_int_delay1 <= 10'b0000000000;
   end
   else begin
      if (sync_rst == 1'b1) cr_int_delay1 <= 10'b0000000000;
      else if (clken == 1'b1) begin
         cr_int_delay1 <= cr_int;
      end
   end

//   assign hd_sdn_in_sel = sdi_3g ? 1'h1 : hd_sdn_in;

   assign std_select = { hd_sdn_in, std_number };

// Pattern Control

   pattern_control pattern_control_inst (
      // reset, clock and clock enable
      .rstn(rstn),
      .sync_rst(1'b0),
      .clk(clk),

      // sdi/3G control (1 for 3G)
      .sdi_3g_in(sdi_3g_in),
      // 3G image formats selection
      .format_sel_3g(format_sel_3g),
      
      // 3G level-B control (1 for 3G level-B)            
      .lb_lan_in(lb_lan_in),                       
      
      // video standard selection
      .std_select  (std_select),
      .pathologic  (pattern_group_sel_in),
      .pathologic_b(pattern_group_sel_in_b),
      // pattern control outputs
      .reg_xa      (reg_xa_in),
      .reg_xb      (reg_xb_in),
      .reg_xc      (reg_xc_in),
      .reg_xd      (reg_xd_in),
      .reg_xe      (reg_xe_in),
      .reg_xf      (reg_xf_in),
      .reg_xg      (reg_xg_in),
      .reg_xh      (reg_xh_in),
      .reg_xi      (reg_xi_in),
      .reg_ya      (reg_ya_in),
      .reg_yb      (reg_yb_in),
      .reg_yb_b    (reg_yb_in_b),
      .reg_yc      (reg_yc_in),
      .reg_yd      (reg_yd_in),
      .reg_yd_b    (reg_yd_in_b),
      .reg_ye      (reg_ye_in),
      .reg_yf      (reg_yf_in),
      .reg_yg      (reg_yg_in),
      .reg_yg_b    (reg_yg_in_b),
      .reg_yh      (reg_yh_in),
      .reg_yi      (reg_yi_in),
      .reg_yi_b    (reg_yi_in_b),
      .reg_yj      (reg_yj_in),
      .reg_yk      (reg_yk_in),
      .reg_yl      (reg_yl_in),
      .reg_ln      (reg_ln_in),
      .sdi_3g_dl   (sdi_3g_dl),
      .sdi_3g_hd_dl(sdi_3g_hd_dl),
      .progressive (progressive_in)
   );

// color_bar module

   pattern_data pattern_data_inst (
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
      .reg_yb_in_b(reg_yb_in_b),
      .reg_yc_in(reg_yc_in),
      .reg_yd_in(reg_yd_in),
      .reg_yd_in_b(reg_yd_in_b),
      .reg_ye_in(reg_ye_in),
      .reg_yf_in(reg_yf_in),
      .reg_yg_in(reg_yg_in),
      .reg_yg_in_b(reg_yg_in_b),
      .reg_yh_in(reg_yh_in),
      .reg_yi_in(reg_yi_in),
      .reg_yi_in_b(reg_yi_in_b),
      .reg_yj_in(reg_yj_in),
      .reg_yk_in(reg_yk_in),
      .reg_yl_in(reg_yl_in),

      // line number control
      .reg_ln_in(reg_ln_in),

      // pattern group selection (low for color bars, high for pathological test)
      .pattern_group_sel_in(pattern_group_sel_in),
      .pattern_group_sel_in_b(pattern_group_sel_in_b),
      // color bars type control (00:100%, 01:75%, 1X:smpte)
      .cbtype_smpte_in(cbtype_smpte_in),
      .cbtype_smpte_in_b(cbtype_smpte_in_b),
      .cbtype_75_in(cbtype_75_in),
      .cbtype_75_in_b(cbtype_75_in_b),

      // pathological type control (00:matrix, 01:equ, 10:pll)
      .pll_test_only_in(pll_test_only_in),
      .pll_test_only_in_b(pll_test_only_in_b),
      .equ_test_only_in(equ_test_only_in),
      .equ_test_only_in_b(equ_test_only_in_b),

      // progressive control (1 for progressive, 0 for interlaced)
      .progressive_in(progressive_in),

      // hd/sd control (1 for hd, o for sd)
      .hd_sdn_in(hd_sdn_in),

      // sdi/3G control (1 for 3G)
      .sdi_3g_in(sdi_3g_in),
      
      // 3G level-B control (1 for 3G level-B)  
      .lb_lan_in(lb_lan_in),
      
      // 3g level-b 372M dual link structure      
      .sdi_3g_dl (sdi_3g_dl),
      
      // 3g level-b dual link HD or 372M dual link structure              
      .sdi_3g_hd_dl(sdi_3g_hd_dl),                                            
      
      // 3g level-b dual link HD or 372M dual link structure  
      .sdi_3g_hd_dl_out(sdi_3g_hd_dl_int),
         
      // 3G image formats selection
      .format_sel_3g(format_sel_3g),

      // pixel data outputs
      .y_out(y_int),
      .cb_out(cb_int),
      .cr_out(cr_int),
      
      .y_out_b (y_int_b),    
      .cb_out_b(cb_int_b),  
      .cr_out_b(cr_int_b),  

      // xyz output
      .xyz_out(xyz_int),

      // trs outputs
      .trs_out(trs_int),

      // output for synchronizing the 2-bit counter in pattern_generator module
      .sync_counter(sync_counter),

      // synchronized hd/sd control output (1 for hd, 0 for sd)
      .hd_sdn_out(hd_sdn_int),

      // synchronized 3g/sdi control output (1 for 3g)
      .sdi_3g_out(sdi_3g_int),
      
      // synchronized 3g level control output (1 for 3g level-b)             
      .lb_lan_out(lb_lan_int),                                     
      
      // synchronized 3g format output (1 for 3g)
      .format_3g_out(format_3g_int),

      // F, V, H output used as a reference signal when generating other signals
      .F_ref(F_ref),
      .V_ref(V_ref),
      .H_ref(H_ref),

      // signals used for detecting the type of pathological error
      .patho_equ(patho_equ_int),
      .patho_pll(patho_pll_int),
      .patho_blk(patho_blk_int),
      .patho_equ_b(patho_equ_int_b),  
      .patho_pll_b(patho_pll_int_b),  
      .patho_blk_b(patho_blk_int_b),  
      
      // synchronized line number control output
      .reg_ln_sync(reg_ln_sync),

      // "rst_update" signal to reset "update" and line_number
      .rst_update(rst_update)
   );

   anc_enable_gen anc_enable_gen_inst (
      .rstn               (rstn               ),
      .clk                (clk                ),
      .sdi_3g_in          (sdi_3g_in          ),
      .sdi_3g_dl          (sdi_3g_dl          ),
      .lb_lan             (lb_lan_int         ),
      .sdi_3g_hd_dl       (sdi_3g_hd_dl_int   ),
      .vpid_insert_en     (vpid_insert_en     ),
      .format_sel_3g      (format_sel_3g      ),
      .hd_sdn_in          (hd_sdn_in          ),
      .std_number         (std_number[2:0]    ),
      .line_number        (line_number        ),
      .trs_out            (trs_temp           ),
      .hblank             (hblank             ),
      .pat_gen_anc_req    (pat_gen_anc_req    ),
      .pat_gen_anc_en     (pat_gen_anc_en     ),
      .pat_gen_anc_en_dl  (pat_gen_anc_en_dl  ),
      .pat_gen_anc_en_lb_b(pat_gen_anc_en_lb_b),
      .format_sel         (format_sel         )
      );


   anc_send anc_send_inst (
	  .rstn               (rstn               ),
	  .clk                (clk                ), 
	  .lb_lan_in          (lb_lan_in          ),
	  .sdi_3g_hd_dl       (sdi_3g_hd_dl_int   ),
	  .format_sel         (format_sel         ),
	  .pattern_m_factor   (pattern_m_factor   ),   
	  .req                (pat_gen_anc_req    ),
	  .vpid_in            (vpid_in            ),
	  .anc_data           (anc_data           ),
	  .anc_data_b         (anc_data_b         )
      );

// 2-bit counter used for data selection
   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      clken_dl <= 1'b1;
   end
   else begin
      if (sync_rst == 1'b1) begin if (sdi_3g_hd_dl_int) clken_dl <= 1'b1; 
      else clken_dl <= 1'b0;  end
      else if (clken_in == 1'b0) begin clken_dl <= 1'b0; end
      else if (lb_lan_int) begin
         if(~clken_dl)
            clken_dl <= 1'b1; 
         else if(clken)    
            clken_dl <= 1'b0;      
      end
      else 
         clken_dl <= 1'b1; 
   end
   
   always @(posedge clk or negedge rstn)                 
   if (rstn == 1'b0) counter_dl <= 2'b00;                   
   else if (sync_rst == 1'b1) counter_dl <= 2'b00;          
   else if (sync_counter == 1'b1) counter_dl <= 2'b00;      
   else if (clken_dl) counter_dl <= counter_dl + 1;            
   
   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) counter <= 2'b00;
   else if (sync_rst == 1'b1) counter <= 2'b00;
   else if (sync_counter == 1'b1) counter <= 2'b00;
   else counter <= counter + 1;

// hd_sdn, trs, F_ref, V_ref, H_ref delay

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      hd_sdn_int_delay1  <= 1'b0;
      sdi_3g_int_delay1  <= 1'b0;
      trs_int_delay1     <= 1'b0;
      trs_int_delay2     <= 1'b0;
      F_ref_delay1       <= 1'b0;
      F_ref_delay2       <= 1'b0;
      V_ref_delay1       <= 1'b0;
      V_ref_delay2       <= 1'b0;
      H_ref_delay1       <= 1'b0;
      H_ref_delay2       <= 1'b0;
      sdi_3g_hd_dl_delay1<= 1'b0;  
      lb_lan_int_delay1  <= 1'b0; 
   end
   else if (sync_rst == 1'b1) begin
      hd_sdn_int_delay1  <= hd_sdn_int;
      sdi_3g_int_delay1  <= sdi_3g_int;
      trs_int_delay1     <= trs_int;
      trs_int_delay1     <= trs_int;
      trs_int_delay2     <= trs_int_delay1;
      F_ref_delay1       <= F_ref;
      F_ref_delay2       <= F_ref_delay1;
      V_ref_delay1       <= V_ref;
      V_ref_delay2       <= V_ref_delay1;
      H_ref_delay1       <= H_ref;
      H_ref_delay2       <= H_ref_delay1;
      sdi_3g_hd_dl_delay1<= sdi_3g_hd_dl_int;  
      lb_lan_int_delay1  <= lb_lan_int; 
   end
   else begin
      hd_sdn_int_delay1  <= hd_sdn_int;
      sdi_3g_int_delay1  <= sdi_3g_int;
      trs_int_delay1     <= trs_int;
      trs_int_delay2     <= trs_int_delay1;
      F_ref_delay1       <= F_ref;
      F_ref_delay2       <= F_ref_delay1;
      V_ref_delay1       <= V_ref;
      V_ref_delay2       <= V_ref_delay1;
      H_ref_delay1       <= H_ref;
      H_ref_delay2       <= H_ref_delay1;
      sdi_3g_hd_dl_delay1<= sdi_3g_hd_dl_int; 
      lb_lan_int_delay1  <= lb_lan_int;         
   end

   assign field  = F_ref_delay2;
   assign vblank = V_ref_delay2;
   assign hblank = H_ref_delay2;

// dual link generation
   
   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      trs_int_delay3 <= 1'b0;
      trs_int_delay4 <= 1'b0;   
      H_ref_delay3   <= 1'b0;  
      H_ref_delay4   <= 1'b0;  
      H_ref_delay5   <= 1'b0;
      line_word0_en  <= 1'b0; 
      line_word1_en  <= 1'b0; 
      dual_link_la   <= 10'h0;
      dual_link_lb   <= 10'h0;
   end
   else if (sync_rst == 1'b1) begin   
      trs_int_delay3 <= 1'b0;  
      trs_int_delay4 <= 1'b0; 
      H_ref_delay3   <= 1'b0;   
      H_ref_delay4   <= 1'b0;   
      H_ref_delay5   <= 1'b0;    
      line_word0_en  <= 1'b0;      
      line_word1_en  <= 1'b0;      
      dual_link_la   <= 10'h0;  
      dual_link_lb   <= 10'h0;
   end 
   else begin  
      if (clken_dl) begin
         trs_int_delay3 <= trs_int_delay2;         
         trs_int_delay4 <= trs_int_delay3; 
         H_ref_delay3   <= H_ref_delay2;  
         H_ref_delay4   <= H_ref_delay3;  
         H_ref_delay5   <= H_ref_delay4;  
         line_word0_en  <= ~H_ref_delay5 & trs_int & trs_int_delay4;  
         line_word1_en  <= line_word0_en;       
      end
      if (line_word0_en) begin
         dual_link_la <= line_word0;  
         dual_link_lb <= line_word0;
      end
      else if (line_word1_en) begin
         dual_link_la <= line_word1;  
         dual_link_lb <= line_word1;
      end
      else if(pat_gen_anc_en_dl) begin
         dual_link_la <= anc_data;  
         dual_link_lb <= anc_data_b;
      end
      else begin
         case (counter)
            2'b00: begin
               dual_link_la <= cb_int;
               dual_link_lb <= cb_int_b;
            end
            2'b01: begin
               dual_link_la <= y_int;      
               dual_link_lb <= y_int_b;    
            end
            2'b10: begin
               dual_link_la <= cr_int;      
               dual_link_lb <= cr_int_b;    
            end
            default: begin
               dual_link_la <= y_int;      
               dual_link_lb <= y_int_b;    
            end
         endcase
      end
   end

// trs generation
   
   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      trs_temp <= 1'b0;      
      trs_out  <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      trs_temp <= 1'b0;      
      trs_out  <= 1'b0;
   end
   else begin
      trs_temp <= trs_int_delay1 & ~trs_int_delay2;  
      if(lb_lan_int)   
         trs_out <= trs_temp;
      else
         trs_out <= trs_int_delay1 & ~trs_int_delay2;   
   end

// patho_xyz generation

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      patho_xyz <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      patho_xyz <= 1'b0;
   end
   else begin
      patho_xyz <= ~trs_int & trs_int_delay1;
   end

// line number generation

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      line_number_set <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      line_number_set <= 1'b0;
   end
   else begin
      line_number_set <= trs_int_delay1 & ~trs_int_delay2 & ~H_ref_delay2;
   end

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      line_number <= 11'b00000000000;
   end
   else if (sync_rst == 1'b1) begin
      line_number <= 11'b00000000000;
   end
   else begin
      if (rst_update == 1'b1) line_number <= 11'b00000000000;
      else if ((trs_int_delay1 == 1'b1) &&
               (trs_int_delay2 == 1'b0) &&
               (H_ref_delay4 == 1'b0))
         line_number <= (line_number >= reg_ln_sync) ? 11'b00000000001 :
                        line_number + 1;
   end

   assign line_word0[1:0] = 2'b00;
   assign line_word0[8:2] = line_number[6:0];
   assign line_word0[9]   = ~line_word0[8];

   assign line_word1[1:0] = 2'b00;
   assign line_word1[5:2] = line_number[10:7];
   assign line_word1[9:6] = 4'b1000;

   assign line_word = (counter[0] == 1'b0) ? line_word0 : line_word1;

   assign line_stb = ~trs_int & trs_int_delay2 & H_ref;
   
   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      line_stb_lb <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      line_stb_lb <= 1'b0;
   end
   else if (lb_lan_int & ~sdi_3g_hd_dl_int & ~H_ref_delay5 & clken_dl & trs_int_delay2 & trs_int_delay3 & trs_int_delay4) begin
      line_stb_lb <= 1'b1;
   end
   else if(clken_dl & ~trs_int_delay2) begin
      line_stb_lb <= 1'b0;   
   end

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) data_hd_y_video <= 10'h000;
   else if (sync_rst == 1'b1) data_hd_y_video <= 10'h000;
   else data_hd_y_video <= (line_stb == 1'b1) ? line_word : y_int;

   assign data_trs = {data_trs_buf[8:0],data_trs_buf[0]};
   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) data_trs_buf <= 9'h000;
   else if (sync_rst == 1'b1) data_trs_buf <= 9'h000;
   else
      case (counter_dl)
         2'b00: data_trs_buf <= 9'h1FF;
         2'b01: data_trs_buf <= 9'h000;
         2'b10: data_trs_buf <= 9'h000;
         2'b11: data_trs_buf <= xyz_int[9:1];
      endcase

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) data_out[19:10] <= 10'h000;
   else if (sync_rst == 1'b1) data_out[19:10] <= 10'h000;
   else
      casex ({trs_int_delay1,sdi_3g_hd_dl_delay1,pat_gen_anc_en,lb_lan_int_delay1,sdi_3g_int_delay1})
         5'b1xxxx: data_out[19:10] <= data_trs; 
         5'b01xxx: data_out[19:10] <= dual_link_la;    
         5'b001xx: data_out[19:10] <= anc_data;    
         5'b00000: data_out[19:10] <= data_hd_y_video;
         5'b00001: data_out[19:10] <= data_3g_1_video;
         5'b00011: data_out[19:10] <= data_3g_1_video_lb;  
      endcase

// low byte data generation (valid only for HD system)

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) data_sd_video <= 10'h000;
   else if (sync_rst == 1'b1) data_sd_video <= 10'h000;
   else
      case (counter)
         2'b00: data_sd_video <= cb_int;
         2'b01: data_sd_video <= y_int;
         2'b10: data_sd_video <= cr_int_delay1;
         2'b11: data_sd_video <= y_int;
      endcase

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) data_hd_cbcr_video <= 10'h000;
   else if (sync_rst == 1'b1) data_hd_cbcr_video <= 10'h000;
   else
      case (counter)
         2'b00: data_hd_cbcr_video <= (line_stb == 1'b1) ? line_word0 : cb_int;
         2'b01: data_hd_cbcr_video <= (line_stb == 1'b1) ? line_word1 : cr_int_delay1;
         2'b10: data_hd_cbcr_video <= cb_int;
         2'b11: data_hd_cbcr_video <= cr_int_delay1;
      endcase

   assign data_3g_sel = {line_stb,counter,format_3g_int};

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) data_3g_1_video <= 10'h000;
   else if (sync_rst == 1'b1) data_3g_1_video <= 10'h000;
   else
      casex (data_3g_sel)
         5'b0xx00: data_3g_1_video <= y_int;
         5'b0x001: data_3g_1_video <= cb_int;
         5'b0x101: data_3g_1_video <= y_int;
         5'b0x010: data_3g_1_video <= {~cr_int[9],cr_int[9:7],y_int[9:7],cb_int[9:7]};
         5'b0x110: data_3g_1_video <= {~cr_int[3],cr_int[3:1],y_int[3:1],cb_int[3:1]};
         5'b0x011: data_3g_1_video <= {4'b1000,y_int[9:4]};
         5'b0x111: data_3g_1_video <= {4'b1000,y_int[3:0],2'b00};
         5'b1x0xx: data_3g_1_video <= line_word0;
         5'b1x1xx: data_3g_1_video <= line_word1;
      endcase

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) data_3g_2_video <= 10'h000;
   else if (sync_rst == 1'b1) data_3g_2_video <= 10'h000;
   else
      casex (data_3g_sel)
         5'b0x000: data_3g_2_video <= cb_int;
         5'b0x100: data_3g_2_video <= cr_int;
         5'b0x001: data_3g_2_video <= 10'h040;
         5'b0x101: data_3g_2_video <= cr_int;
         5'b0x010: data_3g_2_video <= {~cr_int[6],cr_int[6:4],y_int[6:4],cb_int[6:4]};
         5'b0x110: data_3g_2_video <= {~cr_int[0],cr_int[0],2'b0,y_int[0],2'b0,cb_int[0],2'b0};
         5'b00011: data_3g_2_video <= {4'b1000,cb_int[9:4]};
         5'b00111: data_3g_2_video <= {4'b1000,cb_int[3:0],2'b00};
         5'b01011: data_3g_2_video <= {4'b1000,cr_int[9:4]};
         5'b01111: data_3g_2_video <= {4'b1000,cr_int[3:0],2'b00};
         5'b1x0xx: data_3g_2_video <= line_word0;
         5'b1x1xx: data_3g_2_video <= line_word1;
      endcase
   
   assign data_3g_sel_lb = {line_stb_lb,counter,format_3g_int};
   
   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) data_3g_1_video_lb <= 10'h000;
   else if (sync_rst == 1'b1) data_3g_1_video_lb <= 10'h000;
   else
      casex (data_3g_sel_lb)
         5'b0xx00: data_3g_1_video_lb <= y_int;
         5'b00001: data_3g_1_video_lb <= cb_int;
         5'b0x101: data_3g_1_video_lb <= y_int;
         5'b01001: data_3g_1_video_lb <= cr_int;  
         5'b00010: data_3g_1_video_lb <= cb_int;  
         5'b0x110: data_3g_1_video_lb <= y_int;   
         5'b01010: data_3g_1_video_lb <= cr_int;  
         5'b00011: data_3g_1_video_lb <= cb_int;  
         5'b0x111: data_3g_1_video_lb <= y_int;   
         5'b01011: data_3g_1_video_lb <= cr_int;  
         5'b10xxx: data_3g_1_video_lb <= line_word0;
         5'b11xxx: data_3g_1_video_lb <= line_word1;
      endcase

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) data_3g_2_video_lb <= 10'h000;
   else if (sync_rst == 1'b1) data_3g_2_video_lb <= 10'h000;
   else
      casex (data_3g_sel_lb)
         5'b0x000: data_3g_2_video_lb <= cb_int;
         5'b0x100: data_3g_2_video_lb <= cr_int;
         5'b00001: data_3g_2_video_lb <= cb_int;  
         5'b00101: data_3g_2_video_lb <= 10'h040;  
         5'b01001: data_3g_2_video_lb <= cr_int;        
         5'b01101: data_3g_2_video_lb <= 10'h040;       
         5'b00010: data_3g_2_video_lb <= cb_int;        
         5'b00110: data_3g_2_video_lb <= 10'h200;       
         5'b01010: data_3g_2_video_lb <= cr_int;        
         5'b01110: data_3g_2_video_lb <= 10'h200;       
         5'b0x011: data_3g_2_video_lb <= 10'h040;    
         5'b0x111: data_3g_2_video_lb <= 10'h200;     
         5'b10xxx: data_3g_2_video_lb <= line_word0;
         5'b11xxx: data_3g_2_video_lb <= line_word1;
      endcase
   
   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) data_out[9:0] <= 10'h000;
   else if (sync_rst == 1'b1) data_out[9:0] <= 10'h000;
   else
      casex ({trs_int_delay1,sdi_3g_hd_dl_delay1,pat_gen_anc_en_lb_b,lb_lan_int_delay1,sdi_3g_int_delay1, hd_sdn_int_delay1})
         6'b1xxxxx: data_out[9:0] <= data_trs;  
         6'b01xxxx: data_out[9:0] <= dual_link_lb;    
         6'b001xxx: data_out[9:0] <= anc_data_b;  
         6'b000000: data_out[9:0] <= data_sd_video;
         6'b000001: data_out[9:0] <= data_hd_cbcr_video;
         6'b00001x: data_out[9:0] <= data_3g_2_video;
         6'b00011x: data_out[9:0] <= data_3g_2_video_lb;      
      endcase

// signals used for detecting the type of pathological error

   assign patho_trs = trs_int_delay2;
   assign patho_hbk = H_ref_delay2;

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      patho_equ_int_delay1 <= 1'b0;
      patho_pll_int_delay1 <= 1'b0;
      patho_blk_int_delay1 <= 1'b0;
      patho_equ <= 1'b0;
      patho_pll <= 1'b0;
      patho_blk <= 1'b0;
   end
   else if (sync_rst == 1'b1) begin
      patho_equ_int_delay1 <= 1'b0;
      patho_pll_int_delay1 <= 1'b0;
      patho_blk_int_delay1 <= 1'b0;
      patho_equ <= 1'b0;
      patho_pll <= 1'b0;
      patho_blk <= 1'b0;
   end
   else begin
      patho_equ_int_delay1 <= patho_equ_int;
      patho_pll_int_delay1 <= patho_pll_int;
      patho_blk_int_delay1 <= patho_blk_int;
      patho_equ <= patho_equ_int_delay1;
      patho_pll <= patho_pll_int_delay1;
      patho_blk <= patho_blk_int_delay1;
   end

endmodule
