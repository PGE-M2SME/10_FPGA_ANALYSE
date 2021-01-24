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
//  File:              pattern_control.v
//  Title:             pattern_control
//  Description:       This module controls the output values of the
//                     reg_x[a:k], reg_y[a:l], reg_ln registers based
//                     on the inputs.
//
// --------------------------------------------------------------------
// Author : Joseph H., Guolin W.
// $Revision: 1.2 $
// --------------------------------------------------------------------

`timescale 1ns/100ps

module pattern_control (
   // reset, clock and clock enable
   input  wire        rstn,
   input  wire        sync_rst,
   input  wire        clk,

   // video standard selection
   input  wire [ 4:0] std_select,
   input  wire        pathologic,
   input  wire        pathologic_b,
   // sdi/3G control (1 for 3G)
   input  wire        sdi_3g_in,
   // 3G level-B control (1 for 3G level-B)      
   input  wire        lb_lan_in,   
                         
   // 3G image formats selection
   input  wire [ 4:0] format_sel_3g,

   // pattern control outputs
   output reg  [12:0] reg_xa,
   output reg  [12:0] reg_xb,
   output reg  [12:0] reg_xc,
   output reg  [12:0] reg_xd,
   output reg  [12:0] reg_xe,
   output reg  [12:0] reg_xf,
   output reg  [12:0] reg_xg,
   output reg  [12:0] reg_xh,
   output reg  [12:0] reg_xi,
   output reg  [10:0] reg_ya,
   output reg  [10:0] reg_yb,
   output reg  [10:0] reg_yb_b,
   output reg  [10:0] reg_yc,
   output reg  [10:0] reg_yd,
   output reg  [10:0] reg_yd_b,
   output reg  [10:0] reg_ye,
   output reg  [10:0] reg_yf,
   output reg  [10:0] reg_yg,
   output reg  [10:0] reg_yg_b,
   output reg  [10:0] reg_yh,
   output reg  [10:0] reg_yi,
   output reg  [10:0] reg_yi_b,
   output reg  [10:0] reg_yj,
   output reg  [10:0] reg_yk,
   output reg  [10:0] reg_yl,
   output reg  [10:0] reg_ln,
   output reg         sdi_3g_dl,
   output reg         sdi_3g_hd_dl,
   output reg         progressive
);

   wire [10:0] reg_xa_sdi;
   wire [10:0] reg_xb_sdi;
   wire [10:0] reg_xc_sdi;
   wire [10:0] reg_xd_sdi;
   wire [10:0] reg_xe_sdi;
   wire [10:0] reg_xf_sdi;
   wire [10:0] reg_xg_sdi;
   wire [10:0] reg_xh_sdi;
   wire [10:0] reg_xi_sdi;
   wire [10:0] reg_ya_sdi;
   wire [10:0] reg_yb_sdi;
   wire [10:0] reg_yb_sdi_b;
   wire [10:0] reg_yc_sdi;
   wire [10:0] reg_yd_sdi;
   wire [10:0] reg_yd_sdi_b;
   wire [10:0] reg_ye_sdi;
   wire [10:0] reg_yf_sdi;
   wire [10:0] reg_yg_sdi;
   wire [10:0] reg_yg_sdi_b;
   wire [10:0] reg_yh_sdi;
   wire [10:0] reg_yi_sdi;
   wire [10:0] reg_yi_sdi_b;
   wire [10:0] reg_yj_sdi;
   wire [10:0] reg_yk_sdi;
   wire [10:0] reg_yl_sdi;
   wire [10:0] reg_ln_sdi;
   wire        progressive_sdi;

   wire [12:0] reg_xa_3g;
   wire [12:0] reg_xb_3g;
   wire [12:0] reg_xc_3g;
   wire [12:0] reg_xd_3g;
   wire [12:0] reg_xe_3g;
   wire [12:0] reg_xf_3g;
   wire [12:0] reg_xg_3g;
   wire [12:0] reg_xh_3g;
   wire [12:0] reg_xi_3g;
   wire [10:0] reg_ya_3g;
   wire [10:0] reg_yb_3g;
   wire [10:0] reg_yc_3g;
   wire [10:0] reg_yd_3g;
   wire [10:0] reg_ye_3g;
   wire [10:0] reg_yf_3g;
   wire [10:0] reg_yg_3g;
   wire [10:0] reg_yh_3g;
   wire [10:0] reg_yi_3g;
   wire [10:0] reg_yj_3g;
   wire [10:0] reg_yk_3g;
   wire [10:0] reg_yl_3g;
   wire [10:0] reg_ln_3g;
   wire        progressive_3g;

   reg  [ 4:0] std_select_r;
   reg  [ 5:0] select;
   reg  [ 5:0] select_b;
   reg  [ 5:0] select_3g;
   reg         sdi_3g_dl_n;
   
   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      select      <= 6'h0; 
      select_b    <= 6'h0; 
      std_select_r<= 5'h0;    
      select_3g   <= 6'h0;
      sdi_3g_dl_n <= 1'b0;
      sdi_3g_dl   <= 1'b0;
      sdi_3g_hd_dl<= 1'b0;
   end
   else begin
      select_3g <= { pathologic, format_sel_3g };   
      sdi_3g_hd_dl <= (sdi_3g_in & lb_lan_in & (format_sel_3g[4:1] == 4'h0)) | (~sdi_3g_in & lb_lan_in & std_select[4]);
      if(sdi_3g_in & lb_lan_in & (format_sel_3g[4:1] == 4'h0)) begin
         sdi_3g_dl_n <= 1'b0;
         sdi_3g_dl   <= 1'b1;
         if(format_sel_3g[0]) begin
            select <= { pathologic, 5'b10101 };   
            select_b <= { pathologic_b, 5'b10101 };       
            std_select_r <= 5'b10101;                  
         end
         else begin
            select <= { pathologic, 5'b10011 }; 
            select_b <= { pathologic_b, 5'b10011 };     
            std_select_r <= 5'b10011;               
         end
      end
      else begin
         select <= { pathologic, std_select };
         select_b <= { pathologic_b, std_select };
         std_select_r <= std_select;
         sdi_3g_dl <= 1'b0;
         if(sdi_3g_in)
            sdi_3g_dl_n <= 1'b1; 
         else
            sdi_3g_dl_n <= 1'b0; 
      end
   end

   assign reg_xa_sdi = (std_select_r == 5'b10000) ? 11'd0280-2 : // HD #0, 1035i, 60
                       (std_select_r == 5'b10001) ? 11'd0456-2 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 5'b10010) ? 11'd0280-2 : // HD #2, 1080p, 30
                       (std_select_r == 5'b10011) ? 11'd0280-2 : // HD #3, 1080i, 60
                       (std_select_r == 5'b10100) ? 11'd0720-2 : // HD #4, 1080p, 25
                       (std_select_r == 5'b10101) ? 11'd0720-2 : // HD #5, 1080i, 50
                       (std_select_r == 5'b10110) ? 11'd0830-2 : // HD #6, 1080p, 24
                       (std_select_r == 5'b10111) ? 11'd0370-2 : // HD #7,  720p, 60  
                       (std_select_r == 5'b11000) ? 11'd0702-2 : // HD #8,  2K format    
                       (std_select_r == 5'b00000) ? 11'd0138-2 : // SD #0,  525i, 60
                       (std_select_r == 5'b00010) ? 11'd0138-2 : // SD #0,  525i, 60
                       (std_select_r == 5'b00100) ? 11'd0138-2 : // SD #0,  525i, 60
                       (std_select_r == 5'b00110) ? 11'd0138-2 : // SD #0,  525i, 60
                       11'd0144-2;                               // SD #1,  625i, 50

   assign reg_xb_sdi = (std_select_r == 5'b10000) ? 11'd1920-2 : // HD #0, 1035i, 60
                       (std_select_r == 5'b10001) ? 11'd1920-2 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 5'b10010) ? 11'd1920-2 : // HD #2, 1080p, 30
                       (std_select_r == 5'b10011) ? 11'd1920-2 : // HD #3, 1080i, 60
                       (std_select_r == 5'b10100) ? 11'd1920-2 : // HD #4, 1080p, 25
                       (std_select_r == 5'b10101) ? 11'd1920-2 : // HD #5, 1080i, 50
                       (std_select_r == 5'b10110) ? 11'd1920-2 : // HD #6, 1080p, 24
                       (std_select_r == 5'b10111) ? 11'd1280-2 : // HD #7,  720p, 60 
                       (std_select_r == 5'b11000) ? 11'd2046 : // HD #8,  2K format         
                       11'd0720-2;                             // SD #0,  525i, 60 and SD #1,  625i, 50

   assign reg_xc_sdi = (std_select_r == 5'b10000) ? 11'd0274-2 : // HD #0, 1035i, 60
                       (std_select_r == 5'b10001) ? 11'd0274-2 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 5'b10010) ? 11'd0274-2 : // HD #2, 1080p, 30
                       (std_select_r == 5'b10011) ? 11'd0274-2 : // HD #3, 1080i, 60
                       (std_select_r == 5'b10100) ? 11'd0274-2 : // HD #4, 1080p, 25
                       (std_select_r == 5'b10101) ? 11'd0274-2 : // HD #5, 1080i, 50
                       (std_select_r == 5'b10110) ? 11'd0274-2 : // HD #6, 1080p, 24
                       (std_select_r == 5'b10111) ? 11'd0182-2 : // HD #7,  720p, 60  
                       (std_select_r == 5'b11000) ? 11'd0292-2 : // HD #8,  2K format         
                       11'd0102-2;                             // SD #0,  525i, 60 and SD #1,  625i, 50

   assign reg_xd_sdi = (std_select_r == 5'b10000) ? 11'd0272-2 : // HD #0, 1035i, 60
                       (std_select_r == 5'b10001) ? 11'd0272-2 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 5'b10010) ? 11'd0272-2 : // HD #2, 1080p, 30
                       (std_select_r == 5'b10011) ? 11'd0272-2 : // HD #3, 1080i, 60
                       (std_select_r == 5'b10100) ? 11'd0272-2 : // HD #4, 1080p, 25
                       (std_select_r == 5'b10101) ? 11'd0272-2 : // HD #5, 1080i, 50
                       (std_select_r == 5'b10110) ? 11'd0272-2 : // HD #6, 1080p, 24
                       (std_select_r == 5'b10111) ? 11'd0184-2 : // HD #7,  720p, 60 
                       (std_select_r == 5'b11000) ? 11'd0292-2 : // HD #8,  2K format     
                       11'd0104-2;                             // SD #0,  525i, 60 and SD #1,  625i, 50

   assign reg_xe_sdi = (std_select_r == 5'b10000) ? 11'd0276-2 : // HD #0, 1035i, 60
                       (std_select_r == 5'b10001) ? 11'd0276-2 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 5'b10010) ? 11'd0276-2 : // HD #2, 1080p, 30
                       (std_select_r == 5'b10011) ? 11'd0276-2 : // HD #3, 1080i, 60
                       (std_select_r == 5'b10100) ? 11'd0276-2 : // HD #4, 1080p, 25
                       (std_select_r == 5'b10101) ? 11'd0276-2 : // HD #5, 1080i, 50
                       (std_select_r == 5'b10110) ? 11'd0276-2 : // HD #6, 1080p, 24
                       (std_select_r == 5'b10111) ? 11'd0186-2 : // HD #7,  720p, 60  
                       (std_select_r == 5'b11000) ? 11'd0294-2 : // HD #8,  2K format    
                       11'd0102-2;                             // SD #0,  525i, 60 and SD #1,  625i, 50

   assign reg_xf_sdi = (std_select_r == 5'b10000) ? 11'd0276-2 : // HD #0, 1035i, 60
                       (std_select_r == 5'b10001) ? 11'd0276-2 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 5'b10010) ? 11'd0276-2 : // HD #2, 1080p, 30
                       (std_select_r == 5'b10011) ? 11'd0276-2 : // HD #3, 1080i, 60
                       (std_select_r == 5'b10100) ? 11'd0276-2 : // HD #4, 1080p, 25
                       (std_select_r == 5'b10101) ? 11'd0276-2 : // HD #5, 1080i, 50
                       (std_select_r == 5'b10110) ? 11'd0276-2 : // HD #6, 1080p, 24
                       (std_select_r == 5'b10111) ? 11'd0182-2 : // HD #7,  720p, 60  
                       (std_select_r == 5'b11000) ? 11'd0294-2 : // HD #8,  2K format        
                       11'd0106-2;                             // SD #0,  525i, 60 and SD #1,  625i, 50

   assign reg_xg_sdi = (std_select_r == 5'b10000) ? 11'd0342-2 : // HD #0, 1035i, 60
                       (std_select_r == 5'b10001) ? 11'd0342-2 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 5'b10010) ? 11'd0342-2 : // HD #2, 1080p, 30
                       (std_select_r == 5'b10011) ? 11'd0342-2 : // HD #3, 1080i, 60
                       (std_select_r == 5'b10100) ? 11'd0342-2 : // HD #4, 1080p, 25
                       (std_select_r == 5'b10101) ? 11'd0342-2 : // HD #5, 1080i, 50
                       (std_select_r == 5'b10110) ? 11'd0342-2 : // HD #6, 1080p, 24
                       (std_select_r == 5'b10111) ? 11'd0228-2 : // HD #7,  720p, 60  
                       (std_select_r == 5'b11000) ? 11'd0365-2 : // HD #8,  2K format         
                       11'd0128-2;                             // SD #0,  525i, 60 and SD #1,  625i, 50

   assign reg_xh_sdi = (std_select_r == 5'b10000) ? 11'd0092-2 : // HD #0, 1035i, 60
                       (std_select_r == 5'b10001) ? 11'd0092-2 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 5'b10010) ? 11'd0092-2 : // HD #2, 1080p, 30
                       (std_select_r == 5'b10011) ? 11'd0092-2 : // HD #3, 1080i, 60
                       (std_select_r == 5'b10100) ? 11'd0092-2 : // HD #4, 1080p, 25
                       (std_select_r == 5'b10101) ? 11'd0092-2 : // HD #5, 1080i, 50
                       (std_select_r == 5'b10110) ? 11'd0092-2 : // HD #6, 1080p, 24
                       (std_select_r == 5'b10111) ? 11'd0062-2 : // HD #7,  720p, 60      
                       (std_select_r == 5'b11000) ? 11'd0098-2 : // HD #8,  2K format         
                       11'd0034-2;                             // SD #0,  525i, 60 and SD #1,  625i, 50

   assign reg_xi_sdi = (std_select_r == 5'b10000) ? 11'd0240-2 : // HD #0, 1035i, 60
                       (std_select_r == 5'b10001) ? 11'd0240-2 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 5'b10010) ? 11'd0240-2 : // HD #2, 1080p, 30
                       (std_select_r == 5'b10011) ? 11'd0240-2 : // HD #3, 1080i, 60
                       (std_select_r == 5'b10100) ? 11'd0240-2 : // HD #4, 1080p, 25
                       (std_select_r == 5'b10101) ? 11'd0240-2 : // HD #5, 1080i, 50
                       (std_select_r == 5'b10110) ? 11'd0240-2 : // HD #6, 1080p, 24
                       (std_select_r == 5'b10111) ? 11'd0160-2 : // HD #7,  720p, 60  
                       (std_select_r == 5'b11000) ? 11'd0256-2 : // HD #8,  2K format    
                       11'd0090-2;                             // SD #0,  525i, 60 and SD #1,  625i, 50

   assign reg_ya_sdi = (std_select_r == 5'b10000) ? 11'd0040-1 : // HD #0, 1035i, 60
                       (std_select_r == 5'b10001) ? 11'd0080-1 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 5'b10010) ? 11'd0041-1 : // HD #2, 1080p, 30
                       (std_select_r == 5'b10011) ? 11'd0020-1 : // HD #3, 1080i, 60
                       (std_select_r == 5'b10100) ? 11'd0041-1 : // HD #4, 1080p, 25
                       (std_select_r == 5'b10101) ? 11'd0020-1 : // HD #5, 1080i, 50
                       (std_select_r == 5'b10110) ? 11'd0041-1 : // HD #6, 1080p, 24
                       (std_select_r == 5'b10111) ? 11'd0025-1 : // HD #7,  720p, 60
                       (std_select_r == 5'b11000) ? 11'd0041-1 : // HD #8, 2K format       
                       (std_select_r == 5'b00000) ? 11'd0016-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00010) ? 11'd0016-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00100) ? 11'd0016-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00110) ? 11'd0016-1 : // SD #0,  525i, 60
                       11'd0022-1;                             // SD #1,  625i, 50

   assign reg_yb_sdi = (select == 6'b010000) ? 11'd0346-1 : // HD #0, 1035i, 60
                       (select == 6'b010001) ? 11'd0362-1 : // HD #1, 1080i, 50, SMPTE-295M
                       (select == 6'b010010) ? 11'd0724-1 : // HD #2, 1080p, 30
                       (select == 6'b010011) ? 11'd0362-1 : // HD #3, 1080i, 60
                       (select == 6'b010100) ? 11'd0724-1 : // HD #4, 1080p, 25
                       (select == 6'b010101) ? 11'd0362-1 : // HD #5, 1080i, 50
                       (select == 6'b010110) ? 11'd0724-1 : // HD #6, 1080p, 24
                       (select == 6'b010111) ? 11'd0482-1 : // HD #7,  720p, 60      
                       (select == 6'b011000) ? 11'd0724-1 : // HD #8, 2K format     
                       (select == 6'b110000) ? 11'd0217-1 : // HD #0, 1035i, 60            , pathological
                       (select == 6'b110001) ? 11'd0227-1 : // HD #1, 1080i, 50, SMPTE-295M, pathological
                       (select == 6'b110010) ? 11'd0454-1 : // HD #2, 1080p, 30            , pathological
                       (select == 6'b110011) ? 11'd0227-1 : // HD #3, 1080i, 60            , pathological
                       (select == 6'b110100) ? 11'd0454-1 : // HD #4, 1080p, 25            , pathological
                       (select == 6'b110101) ? 11'd0227-1 : // HD #5, 1080i, 50            , pathological
                       (select == 6'b110110) ? 11'd0454-1 : // HD #6, 1080p, 24            , pathological
                       (select == 6'b110111) ? 11'd0302-1 : // HD #7,  720p, 60            , pathological     
                       (select == 6'b111000) ? 11'd0454-1 : // HD #8, 2K format            , pathological        
                       (select == 6'b000000) ? 11'd0163-1 : // SD #0,  525i, 60
                       (select == 6'b000010) ? 11'd0163-1 : // SD #0,  525i, 60
                       (select == 6'b000100) ? 11'd0163-1 : // SD #0,  525i, 60
                       (select == 6'b000110) ? 11'd0163-1 : // SD #0,  525i, 60
                       (select == 6'b000001) ? 11'd0193-1 : // SD #1,  625i, 50
                       (select == 6'b000011) ? 11'd0193-1 : // SD #1,  625i, 50
                       (select == 6'b000101) ? 11'd0193-1 : // SD #1,  625i, 50
                       (select == 6'b000111) ? 11'd0193-1 : // SD #1,  625i, 50
                       (select == 6'b100000) ? 11'd0102-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100010) ? 11'd0102-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100100) ? 11'd0102-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100110) ? 11'd0102-1 : // SD #0,  525i, 60            , pathological
                       11'd0121-1;                          // SD #1,  625i, 50            , pathological
   
   assign reg_yb_sdi_b=(select_b == 6'b010000) ? 11'd0346-1 : // HD #0, 1035i, 60
                       (select_b == 6'b010001) ? 11'd0362-1 : // HD #1, 1080i, 50, SMPTE-295M
                       (select_b == 6'b010010) ? 11'd0724-1 : // HD #2, 1080p, 30
                       (select_b == 6'b010011) ? 11'd0362-1 : // HD #3, 1080i, 60
                       (select_b == 6'b010100) ? 11'd0724-1 : // HD #4, 1080p, 25
                       (select_b == 6'b010101) ? 11'd0362-1 : // HD #5, 1080i, 50
                       (select_b == 6'b010110) ? 11'd0724-1 : // HD #6, 1080p, 24
                       (select_b == 6'b010111) ? 11'd0482-1 : // HD #7,  720p, 60      
                       (select_b == 6'b011000) ? 11'd0724-1 : // HD #8, 2K format     
                       (select_b == 6'b110000) ? 11'd0217-1 : // HD #0, 1035i, 60            , pathological
                       (select_b == 6'b110001) ? 11'd0227-1 : // HD #1, 1080i, 50, SMPTE-295M, pathological
                       (select_b == 6'b110010) ? 11'd0454-1 : // HD #2, 1080p, 30            , pathological
                       (select_b == 6'b110011) ? 11'd0227-1 : // HD #3, 1080i, 60            , pathological
                       (select_b == 6'b110100) ? 11'd0454-1 : // HD #4, 1080p, 25            , pathological
                       (select_b == 6'b110101) ? 11'd0227-1 : // HD #5, 1080i, 50            , pathological
                       (select_b == 6'b110110) ? 11'd0454-1 : // HD #6, 1080p, 24            , pathological
                       (select_b == 6'b110111) ? 11'd0302-1 : // HD #7,  720p, 60            , pathological     
                       (select_b == 6'b111000) ? 11'd0454-1 : // HD #8, 2K format            , pathological        
                       (select_b == 6'b000000) ? 11'd0163-1 : // SD #0,  525i, 60
                       (select_b == 6'b000010) ? 11'd0163-1 : // SD #0,  525i, 60
                       (select_b == 6'b000100) ? 11'd0163-1 : // SD #0,  525i, 60
                       (select_b == 6'b000110) ? 11'd0163-1 : // SD #0,  525i, 60
                       (select_b == 6'b000001) ? 11'd0193-1 : // SD #1,  625i, 50
                       (select_b == 6'b000011) ? 11'd0193-1 : // SD #1,  625i, 50
                       (select_b == 6'b000101) ? 11'd0193-1 : // SD #1,  625i, 50
                       (select_b == 6'b000111) ? 11'd0193-1 : // SD #1,  625i, 50
                       (select_b == 6'b100000) ? 11'd0102-1 : // SD #0,  525i, 60            , pathological
                       (select_b == 6'b100010) ? 11'd0102-1 : // SD #0,  525i, 60            , pathological
                       (select_b == 6'b100100) ? 11'd0102-1 : // SD #0,  525i, 60            , pathological
                       (select_b == 6'b100110) ? 11'd0102-1 : // SD #0,  525i, 60            , pathological
                       11'd0121-1;                          // SD #1,  625i, 50            , pathological
   
   
   assign reg_yc_sdi = (std_select_r == 6'b10000) ? 11'd0042-1 : // HD #0, 1035i, 60
                       (std_select_r == 6'b10001) ? 11'd0043-1 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 6'b10010) ? 11'd0086-1 : // HD #2, 1080p, 30
                       (std_select_r == 6'b10011) ? 11'd0043-1 : // HD #3, 1080i, 60
                       (std_select_r == 6'b10100) ? 11'd0086-1 : // HD #4, 1080p, 25
                       (std_select_r == 6'b10101) ? 11'd0043-1 : // HD #5, 1080i, 50
                       (std_select_r == 6'b10110) ? 11'd0086-1 : // HD #6, 1080p, 24
                       (std_select_r == 6'b10111) ? 11'd0058-1 : // HD #7,  720p, 60 
                       (std_select_r == 5'b11000) ? 11'd0086-1 : // HD #8, 2K format        
                       (std_select_r == 6'b00000) ? 11'd0020-1 : // SD #0,  525i, 60
                       (std_select_r == 6'b00010) ? 11'd0020-1 : // SD #0,  525i, 60
                       (std_select_r == 6'b00100) ? 11'd0020-1 : // SD #0,  525i, 60
                       (std_select_r == 6'b00110) ? 11'd0020-1 : // SD #0,  525i, 60
                       11'd0023-1;                             // SD #1,  625i, 50

   assign reg_yd_sdi = (select == 6'b010000) ? 11'd0129-1 : // HD #0, 1035i, 60
                       (select == 6'b010001) ? 11'd0135-1 : // HD #1, 1080i, 50, SMPTE-295M
                       (select == 6'b010010) ? 11'd0270-1 : // HD #2, 1080p, 30
                       (select == 6'b010011) ? 11'd0135-1 : // HD #3, 1080i, 60
                       (select == 6'b010100) ? 11'd0270-1 : // HD #4, 1080p, 25
                       (select == 6'b010101) ? 11'd0135-1 : // HD #5, 1080i, 50
                       (select == 6'b010110) ? 11'd0270-1 : // HD #6, 1080p, 24
                       (select == 6'b010111) ? 11'd0180-1 : // HD #7,  720p, 60         
                       (select == 6'b011000) ? 11'd0270-1 : // HD #8, 2K format         
                       (select == 6'b110000) ? 11'd0258-1 : // HD #0, 1035i, 60            , pathological
                       (select == 6'b110001) ? 11'd0270-1 : // HD #1, 1080i, 50, SMPTE-295M, pathological
                       (select == 6'b110010) ? 11'd0540-1 : // HD #2, 1080p, 30            , pathological
                       (select == 6'b110011) ? 11'd0270-1 : // HD #3, 1080i, 60            , pathological
                       (select == 6'b110100) ? 11'd0540-1 : // HD #4, 1080p, 25            , pathological
                       (select == 6'b110101) ? 11'd0270-1 : // HD #5, 1080i, 50            , pathological
                       (select == 6'b110110) ? 11'd0540-1 : // HD #6, 1080p, 24            , pathological
                       (select == 6'b110111) ? 11'd0360-1 : // HD #7,  720p, 60            , pathological       
                       (select == 6'b111000) ? 11'd0540-1 : // HD #8, 2K format           , pathological          
                       (select == 6'b000000) ? 11'd0061-1 : // SD #0,  525i, 60
                       (select == 6'b000010) ? 11'd0061-1 : // SD #0,  525i, 60
                       (select == 6'b000100) ? 11'd0061-1 : // SD #0,  525i, 60
                       (select == 6'b000110) ? 11'd0061-1 : // SD #0,  525i, 60
                       (select == 6'b000001) ? 11'd0072-1 : // SD #1,  625i, 50
                       (select == 6'b000011) ? 11'd0072-1 : // SD #1,  625i, 50
                       (select == 6'b000101) ? 11'd0072-1 : // SD #1,  625i, 50
                       (select == 6'b000111) ? 11'd0072-1 : // SD #1,  625i, 50
                       (select == 6'b100000) ? 11'd0122-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100010) ? 11'd0122-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100100) ? 11'd0122-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100110) ? 11'd0122-1 : // SD #0,  525i, 60            , pathological
                       11'd0144-1;                          // SD #1,  625i, 50            , pathological
   
   assign reg_yd_sdi_b=(select == 6'b010000) ? 11'd0129-1 : // HD #0, 1035i, 60
                       (select == 6'b010001) ? 11'd0135-1 : // HD #1, 1080i, 50, SMPTE-295M
                       (select == 6'b010010) ? 11'd0270-1 : // HD #2, 1080p, 30
                       (select == 6'b010011) ? 11'd0135-1 : // HD #3, 1080i, 60
                       (select == 6'b010100) ? 11'd0270-1 : // HD #4, 1080p, 25
                       (select == 6'b010101) ? 11'd0135-1 : // HD #5, 1080i, 50
                       (select == 6'b010110) ? 11'd0270-1 : // HD #6, 1080p, 24
                       (select == 6'b010111) ? 11'd0180-1 : // HD #7,  720p, 60         
                       (select == 6'b011000) ? 11'd0270-1 : // HD #8, 2K format         
                       (select == 6'b110000) ? 11'd0258-1 : // HD #0, 1035i, 60            , pathological
                       (select == 6'b110001) ? 11'd0270-1 : // HD #1, 1080i, 50, SMPTE-295M, pathological
                       (select == 6'b110010) ? 11'd0540-1 : // HD #2, 1080p, 30            , pathological
                       (select == 6'b110011) ? 11'd0270-1 : // HD #3, 1080i, 60            , pathological
                       (select == 6'b110100) ? 11'd0540-1 : // HD #4, 1080p, 25            , pathological
                       (select == 6'b110101) ? 11'd0270-1 : // HD #5, 1080i, 50            , pathological
                       (select == 6'b110110) ? 11'd0540-1 : // HD #6, 1080p, 24            , pathological
                       (select == 6'b110111) ? 11'd0360-1 : // HD #7,  720p, 60            , pathological       
                       (select == 6'b111000) ? 11'd0540-1 : // HD #8, 2K format           , pathological          
                       (select == 6'b000000) ? 11'd0061-1 : // SD #0,  525i, 60
                       (select == 6'b000010) ? 11'd0061-1 : // SD #0,  525i, 60
                       (select == 6'b000100) ? 11'd0061-1 : // SD #0,  525i, 60
                       (select == 6'b000110) ? 11'd0061-1 : // SD #0,  525i, 60
                       (select == 6'b000001) ? 11'd0072-1 : // SD #1,  625i, 50
                       (select == 6'b000011) ? 11'd0072-1 : // SD #1,  625i, 50
                       (select == 6'b000101) ? 11'd0072-1 : // SD #1,  625i, 50
                       (select == 6'b000111) ? 11'd0072-1 : // SD #1,  625i, 50
                       (select == 6'b100000) ? 11'd0122-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100010) ? 11'd0122-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100100) ? 11'd0122-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100110) ? 11'd0122-1 : // SD #0,  525i, 60            , pathological
                       11'd0144-1;                          // SD #1,  625i, 50            , pathological
   
   
   assign reg_ye_sdi = (std_select_r == 5'b10000) ? 11'd0006-1 : // HD #0, 1035i, 60
                       (std_select_r == 5'b10001) ? 11'd0005-1 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 5'b10010) ? 11'd0004-1 : // HD #2, 1080p, 30
                       (std_select_r == 5'b10011) ? 11'd0003-1 : // HD #3, 1080i, 60
                       (std_select_r == 5'b10100) ? 11'd0004-1 : // HD #4, 1080p, 25
                       (std_select_r == 5'b10101) ? 11'd0003-1 : // HD #5, 1080i, 50
                       (std_select_r == 5'b10110) ? 11'd0004-1 : // HD #6, 1080p, 24
                       (std_select_r == 5'b10111) ? 11'd0005-1 : // HD #7,  720p, 60
                       (std_select_r == 5'b11000) ? 11'd0004-1 : // HD #8, 2K format                 
                       (std_select_r == 5'b00000) ? 11'd0002-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00010) ? 11'd0002-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00100) ? 11'd0002-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00110) ? 11'd0002-1 : // SD #0,  525i, 60
                       11'd0002-1;                            // SD #1,  625i, 50

   assign reg_yf_sdi = (std_select_r == 5'b10000) ? 11'd0039-1 : // HD #0, 1035i, 60
                       (std_select_r == 5'b10001) ? 11'd0080-1 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 5'b10010) ? 11'd0000-1 : // HD #2, 1080p, 30
                       (std_select_r == 5'b10011) ? 11'd0020-1 : // HD #3, 1080i, 60
                       (std_select_r == 5'b10100) ? 11'd0000-1 : // HD #4, 1080p, 25
                       (std_select_r == 5'b10101) ? 11'd0020-1 : // HD #5, 1080i, 50
                       (std_select_r == 5'b10110) ? 11'd0000-1 : // HD #6, 1080p, 24
                       (std_select_r == 5'b10111) ? 11'd0000-1 : // HD #7,  720p, 60 
                       (std_select_r == 5'b11000) ? 11'd0000-1 : // HD #8, 2K format    
                       (std_select_r == 5'b00000) ? 11'd0017-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00010) ? 11'd0017-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00100) ? 11'd0017-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00110) ? 11'd0017-1 : // SD #0,  525i, 60
                       11'd0023-1;                            // SD #1,  625i, 50

   assign reg_yg_sdi = (select == 6'b010000) ? 11'd0347-1 : // HD #0, 1035i, 60
                       (select == 6'b010001) ? 11'd0362-1 : // HD #1, 1080i, 50, SMPTE-295M
                       (select == 6'b010010) ? 11'd0000-1 : // HD #2, 1080p, 30
                       (select == 6'b010011) ? 11'd0362-1 : // HD #3, 1080i, 60
                       (select == 6'b010100) ? 11'd0000-1 : // HD #4, 1080p, 25
                       (select == 6'b010101) ? 11'd0362-1 : // HD #5, 1080i, 50
                       (select == 6'b010110) ? 11'd0000-1 : // HD #6, 1080p, 24
                       (select == 6'b010111) ? 11'd0000-1 : // HD #7,  720p, 60   
                       (select == 6'b011000) ? 11'd0000-1 : // HD #8, 2K format      
                       (select == 6'b110000) ? 11'd0218-1 : // HD #0, 1035i, 60            , pathological
                       (select == 6'b110001) ? 11'd0227-1 : // HD #1, 1080i, 50, SMPTE-295M, pathological
                       (select == 6'b110010) ? 11'd0000-1 : // HD #2, 1080p, 30            , pathological
                       (select == 6'b110011) ? 11'd0227-1 : // HD #3, 1080i, 60            , pathological
                       (select == 6'b110100) ? 11'd0000-1 : // HD #4, 1080p, 25            , pathological
                       (select == 6'b110101) ? 11'd0227-1 : // HD #5, 1080i, 50            , pathological
                       (select == 6'b110110) ? 11'd0000-1 : // HD #6, 1080p, 24            , pathological
                       (select == 6'b110111) ? 11'd0000-1 : // HD #7,  720p, 60            , pathological 
                       (select == 6'b111000) ? 11'd0000-1 : // HD #8, 2K format            , pathological   
                       (select == 6'b000000) ? 11'd0163-1 : // SD #0,  525i, 60
                       (select == 6'b000010) ? 11'd0163-1 : // SD #0,  525i, 60
                       (select == 6'b000100) ? 11'd0163-1 : // SD #0,  525i, 60
                       (select == 6'b000110) ? 11'd0163-1 : // SD #0,  525i, 60
                       (select == 6'b000001) ? 11'd0193-1 : // SD #1,  625i, 50
                       (select == 6'b000011) ? 11'd0193-1 : // SD #1,  625i, 50
                       (select == 6'b000101) ? 11'd0193-1 : // SD #1,  625i, 50
                       (select == 6'b000111) ? 11'd0193-1 : // SD #1,  625i, 50
                       (select == 6'b100000) ? 11'd0102-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100010) ? 11'd0102-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100100) ? 11'd0102-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100110) ? 11'd0102-1 : // SD #0,  525i, 60            , pathological
                       11'd0121-1;                          // SD #1,  625i, 50            , pathological
   
   assign reg_yg_sdi_b=(select == 6'b010000) ? 11'd0347-1 : // HD #0, 1035i, 60
                       (select == 6'b010001) ? 11'd0362-1 : // HD #1, 1080i, 50, SMPTE-295M
                       (select == 6'b010010) ? 11'd0000-1 : // HD #2, 1080p, 30
                       (select == 6'b010011) ? 11'd0362-1 : // HD #3, 1080i, 60
                       (select == 6'b010100) ? 11'd0000-1 : // HD #4, 1080p, 25
                       (select == 6'b010101) ? 11'd0362-1 : // HD #5, 1080i, 50
                       (select == 6'b010110) ? 11'd0000-1 : // HD #6, 1080p, 24
                       (select == 6'b010111) ? 11'd0000-1 : // HD #7,  720p, 60   
                       (select == 6'b011000) ? 11'd0000-1 : // HD #8, 2K format      
                       (select == 6'b110000) ? 11'd0218-1 : // HD #0, 1035i, 60            , pathological
                       (select == 6'b110001) ? 11'd0227-1 : // HD #1, 1080i, 50, SMPTE-295M, pathological
                       (select == 6'b110010) ? 11'd0000-1 : // HD #2, 1080p, 30            , pathological
                       (select == 6'b110011) ? 11'd0227-1 : // HD #3, 1080i, 60            , pathological
                       (select == 6'b110100) ? 11'd0000-1 : // HD #4, 1080p, 25            , pathological
                       (select == 6'b110101) ? 11'd0227-1 : // HD #5, 1080i, 50            , pathological
                       (select == 6'b110110) ? 11'd0000-1 : // HD #6, 1080p, 24            , pathological
                       (select == 6'b110111) ? 11'd0000-1 : // HD #7,  720p, 60            , pathological 
                       (select == 6'b111000) ? 11'd0000-1 : // HD #8, 2K format            , pathological   
                       (select == 6'b000000) ? 11'd0163-1 : // SD #0,  525i, 60
                       (select == 6'b000010) ? 11'd0163-1 : // SD #0,  525i, 60
                       (select == 6'b000100) ? 11'd0163-1 : // SD #0,  525i, 60
                       (select == 6'b000110) ? 11'd0163-1 : // SD #0,  525i, 60
                       (select == 6'b000001) ? 11'd0193-1 : // SD #1,  625i, 50
                       (select == 6'b000011) ? 11'd0193-1 : // SD #1,  625i, 50
                       (select == 6'b000101) ? 11'd0193-1 : // SD #1,  625i, 50
                       (select == 6'b000111) ? 11'd0193-1 : // SD #1,  625i, 50
                       (select == 6'b100000) ? 11'd0102-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100010) ? 11'd0102-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100100) ? 11'd0102-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100110) ? 11'd0102-1 : // SD #0,  525i, 60            , pathological
                       11'd0121-1;                          // SD #1,  625i, 50            , pathological
   
   assign reg_yh_sdi = (std_select_r == 5'b10000) ? 11'd0042-1 : // HD #0, 1035i, 60
                       (std_select_r == 5'b10001) ? 11'd0043-1 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 5'b10010) ? 11'd0000-1 : // HD #2, 1080p, 30
                       (std_select_r == 5'b10011) ? 11'd0043-1 : // HD #3, 1080i, 60
                       (std_select_r == 5'b10100) ? 11'd0000-1 : // HD #4, 1080p, 25
                       (std_select_r == 5'b10101) ? 11'd0043-1 : // HD #5, 1080i, 50
                       (std_select_r == 5'b10110) ? 11'd0000-1 : // HD #6, 1080p, 24
                       (std_select_r == 5'b10111) ? 11'd0000-1 : // HD #7,  720p, 60  
                       (std_select_r == 5'b11000) ? 11'd0000-1 : // HD #8, 2K format             
                       (std_select_r == 5'b00000) ? 11'd0019-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00010) ? 11'd0019-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00100) ? 11'd0019-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00110) ? 11'd0019-1 : // SD #0,  525i, 60
                       11'd0023-1;                             // SD #1,  625i, 50

   assign reg_yi_sdi = (select == 6'b010000) ? 11'd0129-1 : // HD #0, 1035i, 60
                       (select == 6'b010001) ? 11'd0135-1 : // HD #1, 1080i, 50, SMPTE-295M
                       (select == 6'b010010) ? 11'd0000-1 : // HD #2, 1080p, 30
                       (select == 6'b010011) ? 11'd0135-1 : // HD #3, 1080i, 60
                       (select == 6'b010100) ? 11'd0000-1 : // HD #4, 1080p, 25
                       (select == 6'b010101) ? 11'd0135-1 : // HD #5, 1080i, 50
                       (select == 6'b010110) ? 11'd0000-1 : // HD #6, 1080p, 24
                       (select == 6'b010111) ? 11'd0000-1 : // HD #7,  720p, 60   
                       (select == 6'b011000) ? 11'd0000-1 : // HD #8, 2K format            
                       (select == 6'b110000) ? 11'd0258-1 : // HD #0, 1035i, 60            , pathological
                       (select == 6'b110001) ? 11'd0270-1 : // HD #1, 1080i, 50, SMPTE-295M, pathological
                       (select == 6'b110010) ? 11'd0000-1 : // HD #2, 1080p, 30            , pathological
                       (select == 6'b110011) ? 11'd0270-1 : // HD #3, 1080i, 60            , pathological
                       (select == 6'b110100) ? 11'd0000-1 : // HD #4, 1080p, 25            , pathological
                       (select == 6'b110101) ? 11'd0270-1 : // HD #5, 1080i, 50            , pathological
                       (select == 6'b110110) ? 11'd0000-1 : // HD #6, 1080p, 24            , pathological
                       (select == 6'b110111) ? 11'd0000-1 : // HD #7,  720p, 60            , pathological 
                       (select == 6'b111000) ? 11'd0000-1 : // HD #8, 2K format            , pathological     
                       (select == 6'b000000) ? 11'd0061-1 : // SD #0,  525i, 60
                       (select == 6'b000010) ? 11'd0061-1 : // SD #0,  525i, 60
                       (select == 6'b000100) ? 11'd0061-1 : // SD #0,  525i, 60
                       (select == 6'b000110) ? 11'd0061-1 : // SD #0,  525i, 60
                       (select == 6'b000001) ? 11'd0072-1 : // SD #1,  625i, 50
                       (select == 6'b000011) ? 11'd0072-1 : // SD #1,  625i, 50
                       (select == 6'b000101) ? 11'd0072-1 : // SD #1,  625i, 50
                       (select == 6'b000111) ? 11'd0072-1 : // SD #1,  625i, 50
                       (select == 6'b100000) ? 11'd0122-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100010) ? 11'd0122-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100100) ? 11'd0122-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100110) ? 11'd0122-1 : // SD #0,  525i, 60            , pathological
                       11'd0144-1;                          // SD #1,  625i, 50            , pathological
   
   assign reg_yi_sdi_b=(select == 6'b010000) ? 11'd0129-1 : // HD #0, 1035i, 60
                       (select == 6'b010001) ? 11'd0135-1 : // HD #1, 1080i, 50, SMPTE-295M
                       (select == 6'b010010) ? 11'd0000-1 : // HD #2, 1080p, 30
                       (select == 6'b010011) ? 11'd0135-1 : // HD #3, 1080i, 60
                       (select == 6'b010100) ? 11'd0000-1 : // HD #4, 1080p, 25
                       (select == 6'b010101) ? 11'd0135-1 : // HD #5, 1080i, 50
                       (select == 6'b010110) ? 11'd0000-1 : // HD #6, 1080p, 24
                       (select == 6'b010111) ? 11'd0000-1 : // HD #7,  720p, 60   
                       (select == 6'b011000) ? 11'd0000-1 : // HD #8, 2K format            
                       (select == 6'b110000) ? 11'd0258-1 : // HD #0, 1035i, 60            , pathological
                       (select == 6'b110001) ? 11'd0270-1 : // HD #1, 1080i, 50, SMPTE-295M, pathological
                       (select == 6'b110010) ? 11'd0000-1 : // HD #2, 1080p, 30            , pathological
                       (select == 6'b110011) ? 11'd0270-1 : // HD #3, 1080i, 60            , pathological
                       (select == 6'b110100) ? 11'd0000-1 : // HD #4, 1080p, 25            , pathological
                       (select == 6'b110101) ? 11'd0270-1 : // HD #5, 1080i, 50            , pathological
                       (select == 6'b110110) ? 11'd0000-1 : // HD #6, 1080p, 24            , pathological
                       (select == 6'b110111) ? 11'd0000-1 : // HD #7,  720p, 60            , pathological 
                       (select == 6'b111000) ? 11'd0000-1 : // HD #8, 2K format            , pathological     
                       (select == 6'b000000) ? 11'd0061-1 : // SD #0,  525i, 60
                       (select == 6'b000010) ? 11'd0061-1 : // SD #0,  525i, 60
                       (select == 6'b000100) ? 11'd0061-1 : // SD #0,  525i, 60
                       (select == 6'b000110) ? 11'd0061-1 : // SD #0,  525i, 60
                       (select == 6'b000001) ? 11'd0072-1 : // SD #1,  625i, 50
                       (select == 6'b000011) ? 11'd0072-1 : // SD #1,  625i, 50
                       (select == 6'b000101) ? 11'd0072-1 : // SD #1,  625i, 50
                       (select == 6'b000111) ? 11'd0072-1 : // SD #1,  625i, 50
                       (select == 6'b100000) ? 11'd0122-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100010) ? 11'd0122-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100100) ? 11'd0122-1 : // SD #0,  525i, 60            , pathological
                       (select == 6'b100110) ? 11'd0122-1 : // SD #0,  525i, 60            , pathological
                       11'd0144-1;                          // SD #1,  625i, 50            , pathological
   
   assign reg_yj_sdi = (std_select_r == 5'b10000) ? 11'd0005-1 : // HD #0, 1035i, 60
                       (std_select_r == 5'b10001) ? 11'd0005-1 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 5'b10010) ? 11'd0000-1 : // HD #2, 1080p, 30
                       (std_select_r == 5'b10011) ? 11'd0002-1 : // HD #3, 1080i, 60
                       (std_select_r == 5'b10100) ? 11'd0000-1 : // HD #4, 1080p, 25
                       (std_select_r == 5'b10101) ? 11'd0002-1 : // HD #5, 1080i, 50
                       (std_select_r == 5'b10110) ? 11'd0000-1 : // HD #6, 1080p, 24
                       (std_select_r == 5'b10111) ? 11'd0000-1 : // HD #7,  720p, 60   
                       (std_select_r == 5'b11000) ? 11'd0000-1 : // HD #8, 2K format       
                       (std_select_r == 5'b00000) ? 11'd0003-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00010) ? 11'd0003-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00100) ? 11'd0003-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00110) ? 11'd0003-1 : // SD #0,  525i, 60
                       11'd0002-1;                             // SD #1,  625i, 50

   assign reg_yk_sdi = (std_select_r == 5'b10000) ? 11'd0517-1 : // HD #0, 1035i, 60
                       (std_select_r == 5'b10001) ? 11'd0540-1 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 5'b10010) ? 11'd1080-1 : // HD #2, 1080p, 30
                       (std_select_r == 5'b10011) ? 11'd0540-1 : // HD #3, 1080i, 60
                       (std_select_r == 5'b10100) ? 11'd1080-1 : // HD #4, 1080p, 25
                       (std_select_r == 5'b10101) ? 11'd0540-1 : // HD #5, 1080i, 50
                       (std_select_r == 5'b10110) ? 11'd1080-1 : // HD #6, 1080p, 24
                       (std_select_r == 5'b10111) ? 11'd0720-1 : // HD #7,  720p, 60  
                       (std_select_r == 5'b11000) ? 11'd1080-1 : // HD #8, 2K format           
                       (std_select_r == 5'b00000) ? 11'd0244-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00010) ? 11'd0244-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00100) ? 11'd0244-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00110) ? 11'd0244-1 : // SD #0,  525i, 60
                       11'd0288-1;                             // SD #1,  625i, 50

   assign reg_yl_sdi = (std_select_r == 5'b10000) ? 11'd0518-1 : // HD #0, 1035i, 60
                       (std_select_r == 5'b10001) ? 11'd0540-1 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 5'b10010) ? 11'd0000-1 : // HD #2, 1080p, 30
                       (std_select_r == 5'b10011) ? 11'd0540-1 : // HD #3, 1080i, 60
                       (std_select_r == 5'b10100) ? 11'd0000-1 : // HD #4, 1080p, 25
                       (std_select_r == 5'b10101) ? 11'd0540-1 : // HD #5, 1080i, 50
                       (std_select_r == 5'b10110) ? 11'd0000-1 : // HD #6, 1080p, 24
                       (std_select_r == 5'b10111) ? 11'd0000-1 : // HD #7,  720p, 60
                       (std_select_r == 5'b11000) ? 11'd0000-1 : // HD #8, 2K format          
                       (std_select_r == 5'b00000) ? 11'd0243-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00010) ? 11'd0243-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00100) ? 11'd0243-1 : // SD #0,  525i, 60
                       (std_select_r == 5'b00110) ? 11'd0243-1 : // SD #0,  525i, 60
                       11'd0288-1;                             // SD #1,  625i, 50

   assign reg_ln_sdi = (std_select_r == 5'b10000) ? 11'd1125 : // HD #0, 1035i, 60
                       (std_select_r == 5'b10001) ? 11'd1250 : // HD #1, 1080i, 50, SMPTE-295M
                       (std_select_r == 5'b10010) ? 11'd1125 : // HD #2, 1080p, 30
                       (std_select_r == 5'b10011) ? 11'd1125 : // HD #3, 1080i, 60
                       (std_select_r == 5'b10100) ? 11'd1125 : // HD #4, 1080p, 25
                       (std_select_r == 5'b10101) ? 11'd1125 : // HD #5, 1080i, 50
                       (std_select_r == 5'b10110) ? 11'd1125 : // HD #6, 1080p, 24
                       (std_select_r == 5'b10111) ? 11'd0750 : // HD #7,  720p, 60 
                       (std_select_r == 5'b11000) ? 11'd1125 : // HD #8, 2K format          
                       (std_select_r == 5'b00000) ? 11'd0525 : // SD #0,  525i, 60
                       (std_select_r == 5'b00010) ? 11'd0525 : // SD #0,  525i, 60
                       (std_select_r == 5'b00100) ? 11'd0525 : // SD #0,  525i, 60
                       (std_select_r == 5'b00110) ? 11'd0525 : // SD #0,  525i, 60
                       11'd0625-1;                           // SD #1,  625i, 50

   assign progressive_sdi = (std_select_r == 5'b10000) ? 1'b0 : // HD #0, 1035i, 60
                            (std_select_r == 5'b10001) ? 1'b0 : // HD #1, 1080i, 50, SMPTE-295M
                            (std_select_r == 5'b10010) ? 1'b1 : // HD #2, 1080p, 30
                            (std_select_r == 5'b10011) ? 1'b0 : // HD #3, 1080i, 60
                            (std_select_r == 5'b10100) ? 1'b1 : // HD #4, 1080p, 25
                            (std_select_r == 5'b10101) ? 1'b0 : // HD #5, 1080i, 50
                            (std_select_r == 5'b10110) ? 1'b1 : // HD #6, 1080p, 24
                            (std_select_r == 5'b10111) ? 1'b1 : // HD #7,  720p, 60     
                            (std_select_r == 5'b11000) ? 1'b1 : // HD #8, 2K format      
                            1'b0;                             // SD #0,  525i, 60 and SD #1,  625i, 50


   assign reg_xa_3g = (format_sel_3g == 5'b00000) ? 13'd0280-2 : // 3G #0,  1080p, 60, SMPTE-274M system 1,2     Y'CbCr(4:2:2)     10bit
                      (format_sel_3g == 5'b00001) ? 13'd0720-2 : // 3G #1,  1080p, 50, SMPTE-274M system 3       Y'CbCr(4:2:2)     10bit
                      (format_sel_3g == 5'b00010) ? 13'd0740-2 : // 3G #2,  720p,  60, SMPTE-296M system 1,2     Y'CbCr+A(4:4:4:4) 10bit
                      (format_sel_3g == 5'b00011) ? 13'd1400-2 : // 3G #3,  720p,  50, SMPTE-296M system 3       Y'CbCr+A(4:4:4:4) 10bit
                      (format_sel_3g == 5'b00100) ? 13'd0560-2 : // 3G #4,  1080p, 30, SMPTE-274M system 4,5,7,8 Y'CbCr+A(4:4:4:4) 10bit
                      (format_sel_3g == 5'b00101) ? 13'd4040-2 : // 3G #5,  720p,  30, SMPTE-296M system 4,5     Y'CbCr+A(4:4:4:4) 10bit
                      (format_sel_3g == 5'b00110) ? 13'd1440-2 : // 3G #6,  1080p, 25, SMPTE-274M system 6,9     Y'CbCr+A(4:4:4:4) 10bit
                      (format_sel_3g == 5'b00111) ? 13'd5360-2 : // 3G #7,  720p,  25, SMPTE-296M system 6       Y'CbCr+A(4:4:4:4) 10bit
                      (format_sel_3g == 5'b01000) ? 13'd1660-2 : // 3G #8,  1080p, 24, SMPTE-274M system 10,11   Y'CbCr+A(4:4:4:4) 10bit
                      (format_sel_3g == 5'b01001) ? 13'd5690-2 : // 3G #9,  720p,  24, SMPTE-296M system 7,8     Y'CbCr+A(4:4:4:4) 10bit
                      (format_sel_3g == 5'b01010) ? 13'd0560-2 : // 3G #10, 1080i, 60, SMPTE-274M system 4,5,7,8 Y'CbCr+A(4:4:4:4) 10bit
                      (format_sel_3g == 5'b01011) ? 13'd1440-2 : // 3G #11, 1080i, 50, SMPTE-274M system 6,9     Y'CbCr+A(4:4:4:4) 10bit
                      (format_sel_3g == 5'b01100) ? 13'd0560-2 : // 3G #12, 1080p, 30, SMPTE-274M system 4,5,7,8 Y'CbCr(4:4:4)     12bit
                      (format_sel_3g == 5'b01101) ? 13'd1440-2 : // 3G #13, 1080p, 25, SMPTE-274M system 6,9     Y'CbCr(4:4:4)     12bit
                      (format_sel_3g == 5'b01110) ? 13'd1660-2 : // 3G #14, 1080p, 24, SMPTE-274M system 10,11   Y'CbCr(4:4:4)     12bit
                      (format_sel_3g == 5'b01111) ? 13'd0560-2 : // 3G #15, 1080i, 60, SMPTE-274M system 4,5,7,8 Y'CbCr(4:4:4)     12bit
                      (format_sel_3g == 5'b10000) ? 13'd1440-2 : // 3G #16, 1080i, 50, SMPTE-274M system 6,9     Y'CbCr(4:4:4)     12bit
                      (format_sel_3g == 5'b10001) ? 13'd0560-2 : // 3G #17, 1080p, 30, SMPTE-274M system 4,5,7,8 Y'CbCr(4:2:2)     12bit
                      (format_sel_3g == 5'b10010) ? 13'd1440-2 : // 3G #18, 1080p, 25, SMPTE-274M system 6,9     Y'CbCr(4:2:2)     12bit
                      (format_sel_3g == 5'b10011) ? 13'd1660-2 : // 3G #19, 1080p, 24, SMPTE-274M system 10,11   Y'CbCr(4:2:2)     12bit
                      (format_sel_3g == 5'b10100) ? 13'd0560-2 : // 3G #20, 1080i, 60, SMPTE-274M system 4,5,7,8 Y'CbCr(4:2:2)     12bit
                      (format_sel_3g == 5'b10101) ? 13'd1440-2 : // 3G #21, 1080i, 50, SMPTE-274M system 6,9     Y'CbCr(4:2:2)     12bit
                      (format_sel_3g == 5'b11000) ? 13'd0304-2 : // 3G #24, 1080p, 30, SMPTE-274M 2K formats     Y'CbCr(4:4:4)     12bit   
                      (format_sel_3g == 5'b11001) ? 13'd1184-2 : // 3G #25, 1080p, 25, SMPTE-274M 2K formats     Y'CbCr(4:4:4)     12bit   
                      (format_sel_3g == 5'b11010) ? 13'd1404-2 : // 3G #26, 1080p, 24, SMPTE-274M 2K formats     Y'CbCr(4:4:4)     12bit   
                      (format_sel_3g == 5'b11011) ? 13'd0304-2 : // 3G #27, 1080p, 30, SMPTE-274M 2K formats     Y'CbCr+A(4:4:4:4) 10bit     
                      (format_sel_3g == 5'b11100) ? 13'd1184-2 : // 3G #28, 1080p, 25, SMPTE-274M 2K formats     Y'CbCr+A(4:4:4:4) 10bit     
                      (format_sel_3g == 5'b11101) ? 13'd1404-2 : // 3G #29, 1080p, 24, SMPTE-274M 2K formats     Y'CbCr+A(4:4:4:4) 10bit        
                                                    13'd1440-2 ;
                                                    
   assign reg_xb_3g = (format_sel_3g == 5'b00000) ? 13'd1920-2 : // 3G #0,
                      (format_sel_3g == 5'b00001) ? 13'd1920-2 : // 3G #1,
                      (format_sel_3g == 5'b00010) ? 13'd2560-2 : // 3G #2,
                      (format_sel_3g == 5'b00011) ? 13'd2560-2 : // 3G #3,
                      (format_sel_3g == 5'b00101) ? 13'd2560-2 : // 3G #5,
                      (format_sel_3g == 5'b00111) ? 13'd2560-2 : // 3G #7,
                      (format_sel_3g == 5'b01001) ? 13'd2560-2 : // 3G #9,
                      (format_sel_3g == 5'b11000) ? 13'd4096-2 : // 3G #24,   
                      (format_sel_3g == 5'b11001) ? 13'd4096-2 : // 3G #25,   
                      (format_sel_3g == 5'b11010) ? 13'd4096-2 : // 3G #26,   
                      (format_sel_3g == 5'b11011) ? 13'd4096-2 : // 3G #27,   
                      (format_sel_3g == 5'b11100) ? 13'd4096-2 : // 3G #28,   
                      (format_sel_3g == 5'b11101) ? 13'd4096-2 : // 3G #29,   
                                                    13'd3840-2 ; // 3G others

   assign reg_xc_3g = (format_sel_3g == 5'b00000) ? 13'd0274-2 : // 3G #0,
                      (format_sel_3g == 5'b00001) ? 13'd0274-2 : // 3G #1,
                      (format_sel_3g == 5'b00010) ? 13'd0364-2 : // 3G #2,
                      (format_sel_3g == 5'b00011) ? 13'd0364-2 : // 3G #3,
                      (format_sel_3g == 5'b00101) ? 13'd0364-2 : // 3G #5,
                      (format_sel_3g == 5'b00111) ? 13'd0364-2 : // 3G #7,
                      (format_sel_3g == 5'b01001) ? 13'd0364-2 : // 3G #9,  
                      (format_sel_3g == 5'b11000) ? 13'd0584-2 : // 3G #24,   
                      (format_sel_3g == 5'b11001) ? 13'd0584-2 : // 3G #25,   
                      (format_sel_3g == 5'b11010) ? 13'd0584-2 : // 3G #26, 
                      (format_sel_3g == 5'b11011) ? 13'd0584-2 : // 3G #27,      
                      (format_sel_3g == 5'b11100) ? 13'd0584-2 : // 3G #28,      
                      (format_sel_3g == 5'b11101) ? 13'd0584-2 : // 3G #29,                
                                                    13'd0548-2;  // 3G others

   assign reg_xd_3g = (format_sel_3g == 5'b00000) ? 13'd0272-2 : // 3G #0,
                      (format_sel_3g == 5'b00001) ? 13'd0272-2 : // 3G #1,
                      (format_sel_3g == 5'b00010) ? 13'd0368-2 : // 3G #2,
                      (format_sel_3g == 5'b00011) ? 13'd0368-2 : // 3G #3,
                      (format_sel_3g == 5'b00101) ? 13'd0368-2 : // 3G #5,
                      (format_sel_3g == 5'b00111) ? 13'd0368-2 : // 3G #7,
                      (format_sel_3g == 5'b01001) ? 13'd0368-2 : // 3G #9,
                      (format_sel_3g == 5'b11000) ? 13'd0584-2 : // 3G #24, 
                      (format_sel_3g == 5'b11001) ? 13'd0584-2 : // 3G #25,   
                      (format_sel_3g == 5'b11010) ? 13'd0584-2 : // 3G #26,
                      (format_sel_3g == 5'b11011) ? 13'd0584-2 : // 3G #27,       
                      (format_sel_3g == 5'b11100) ? 13'd0584-2 : // 3G #28,       
                      (format_sel_3g == 5'b11101) ? 13'd0584-2 : // 3G #29,          
                                                    13'd0544-2;  // 3G others

   assign reg_xe_3g = (format_sel_3g == 5'b00000) ? 13'd0276-2 : // 3G #0,
                      (format_sel_3g == 5'b00001) ? 13'd0276-2 : // 3G #1,
                      (format_sel_3g == 5'b00010) ? 13'd0372-2 : // 3G #2,
                      (format_sel_3g == 5'b00011) ? 13'd0372-2 : // 3G #3,
                      (format_sel_3g == 5'b00101) ? 13'd0372-2 : // 3G #5,
                      (format_sel_3g == 5'b00111) ? 13'd0372-2 : // 3G #7,
                      (format_sel_3g == 5'b01001) ? 13'd0372-2 : // 3G #9,
                      (format_sel_3g == 5'b11000) ? 13'd0588-2 : // 3G #24, 
                      (format_sel_3g == 5'b11001) ? 13'd0588-2 : // 3G #25,   
                      (format_sel_3g == 5'b11010) ? 13'd0588-2 : // 3G #26,  
                      (format_sel_3g == 5'b11011) ? 13'd0588-2 : // 3G #27, 
                      (format_sel_3g == 5'b11100) ? 13'd0588-2 : // 3G #28, 
                      (format_sel_3g == 5'b11101) ? 13'd0588-2 : // 3G #29,  
                                                    13'd0552-2;  // 3G others

   assign reg_xf_3g = (format_sel_3g == 5'b00000) ? 13'd0276-2 : // 3G #0,
                      (format_sel_3g == 5'b00001) ? 13'd0276-2 : // 3G #1,
                      (format_sel_3g == 5'b00010) ? 13'd0364-2 : // 3G #2,
                      (format_sel_3g == 5'b00011) ? 13'd0364-2 : // 3G #3,
                      (format_sel_3g == 5'b00101) ? 13'd0364-2 : // 3G #5,
                      (format_sel_3g == 5'b00111) ? 13'd0364-2 : // 3G #7,
                      (format_sel_3g == 5'b01001) ? 13'd0364-2 : // 3G #9,
                      (format_sel_3g == 5'b11000) ? 13'd0588-2 : // 3G #24,
                      (format_sel_3g == 5'b11001) ? 13'd0588-2 : // 3G #25,       
                      (format_sel_3g == 5'b11010) ? 13'd0588-2 : // 3G #26,    
                      (format_sel_3g == 5'b11011) ? 13'd0588-2 : // 3G #27,    
                      (format_sel_3g == 5'b11100) ? 13'd0588-2 : // 3G #28,    
                      (format_sel_3g == 5'b11101) ? 13'd0588-2 : // 3G #29,        
                                                    13'd0552-2;  // 3G others

   assign reg_xg_3g = (format_sel_3g == 5'b00000) ? 13'd0342-2 : // 3G #0,
                      (format_sel_3g == 5'b00001) ? 13'd0342-2 : // 3G #1,
                      (format_sel_3g == 5'b00010) ? 13'd0456-2 : // 3G #2,
                      (format_sel_3g == 5'b00011) ? 13'd0456-2 : // 3G #3,
                      (format_sel_3g == 5'b00101) ? 13'd0456-2 : // 3G #5,
                      (format_sel_3g == 5'b00111) ? 13'd0456-2 : // 3G #7,
                      (format_sel_3g == 5'b01001) ? 13'd0456-2 : // 3G #9,
                      (format_sel_3g == 5'b11000) ? 13'd0730-2 : // 3G #24, 
                      (format_sel_3g == 5'b11001) ? 13'd0730-2 : // 3G #25, 
                      (format_sel_3g == 5'b11010) ? 13'd0730-2 : // 3G #26,
                      (format_sel_3g == 5'b11011) ? 13'd0730-2 : // 3G #27,
                      (format_sel_3g == 5'b11100) ? 13'd0730-2 : // 3G #28,
                      (format_sel_3g == 5'b11101) ? 13'd0730-2 : // 3G #29, 
                                                    13'd0684-2;  // 3G others

   assign reg_xh_3g = (format_sel_3g == 5'b00000) ? 13'd0092-2 : // 3G #0,
                      (format_sel_3g == 5'b00001) ? 13'd0092-2 : // 3G #1,
                      (format_sel_3g == 5'b00010) ? 13'd0124-2 : // 3G #2,
                      (format_sel_3g == 5'b00011) ? 13'd0124-2 : // 3G #3,
                      (format_sel_3g == 5'b00101) ? 13'd0124-2 : // 3G #5,
                      (format_sel_3g == 5'b00111) ? 13'd0124-2 : // 3G #7,
                      (format_sel_3g == 5'b01001) ? 13'd0124-2 : // 3G #9,
                      (format_sel_3g == 5'b11000) ? 13'd0196-2 : // 3G #24,
                      (format_sel_3g == 5'b11001) ? 13'd0196-2 : // 3G #25,    
                      (format_sel_3g == 5'b11010) ? 13'd0196-2 : // 3G #26,
                      (format_sel_3g == 5'b11011) ? 13'd0196-2 : // 3G #27,           
                      (format_sel_3g == 5'b11100) ? 13'd0196-2 : // 3G #28,           
                      (format_sel_3g == 5'b11101) ? 13'd0196-2 : // 3G #29,                
                                                    13'd0184-2;  // 3G others

   assign reg_xi_3g = (format_sel_3g == 5'b00000) ? 13'd0240-2 : // 3G #0,
                      (format_sel_3g == 5'b00001) ? 13'd0240-2 : // 3G #1,
                      (format_sel_3g == 5'b00010) ? 13'd0320-2 : // 3G #2,
                      (format_sel_3g == 5'b00011) ? 13'd0320-2 : // 3G #3,
                      (format_sel_3g == 5'b00101) ? 13'd0320-2 : // 3G #5,
                      (format_sel_3g == 5'b00111) ? 13'd0320-2 : // 3G #7,
                      (format_sel_3g == 5'b01001) ? 13'd0320-2 : // 3G #9, 
                      (format_sel_3g == 5'b11000) ? 13'd0512-2 : // 3G #24, 
                      (format_sel_3g == 5'b11001) ? 13'd0512-2 : // 3G #25,       
                      (format_sel_3g == 5'b11010) ? 13'd0512-2 : // 3G #26, 
                      (format_sel_3g == 5'b11011) ? 13'd0512-2 : // 3G #27,      
                      (format_sel_3g == 5'b11100) ? 13'd0512-2 : // 3G #28,      
                      (format_sel_3g == 5'b11101) ? 13'd0512-2 : // 3G #29,            
                                                    13'd0480-2;  // 3G others

   assign reg_ya_3g = (format_sel_3g == 5'b00010) ? 11'd0025-1 : // 3G #2,
                      (format_sel_3g == 5'b00011) ? 11'd0025-1 : // 3G #3,
                      (format_sel_3g == 5'b00101) ? 11'd0025-1 : // 3G #5,
                      (format_sel_3g == 5'b00111) ? 11'd0025-1 : // 3G #7,
                      (format_sel_3g == 5'b01001) ? 11'd0025-1 : // 3G #9,
                      (format_sel_3g == 5'b01010) ? 11'd0020-1 : // 3G #10,
                      (format_sel_3g == 5'b01011) ? 11'd0020-1 : // 3G #11,
                      (format_sel_3g == 5'b01111) ? 11'd0020-1 : // 3G #15,
                      (format_sel_3g == 5'b10000) ? 11'd0020-1 : // 3G #16,
                      (format_sel_3g == 5'b10100) ? 11'd0020-1 : // 3G #20,
                      (format_sel_3g == 5'b10101) ? 11'd0020-1 : // 3G #21,
                                                    11'd0041-1;  // 3G others

   assign reg_yb_3g = (select_3g == 6'b000010) ? 11'd0482-1 :    // 3G #2,    pathological = '0'
                      (select_3g == 6'b000011) ? 11'd0482-1 :    // 3G #3,    pathological = '0'
                      (select_3g == 6'b000101) ? 11'd0482-1 :    // 3G #5,    pathological = '0'
                      (select_3g == 6'b000111) ? 11'd0482-1 :    // 3G #7,    pathological = '0'
                      (select_3g == 6'b001001) ? 11'd0482-1 :    // 3G #9,    pathological = '0'
                      (select_3g == 6'b100010) ? 11'd0302-1 :    // 3G #2,    pathological = '1'
                      (select_3g == 6'b100011) ? 11'd0302-1 :    // 3G #3,    pathological = '1'
                      (select_3g == 6'b100101) ? 11'd0302-1 :    // 3G #5,    pathological = '1'
                      (select_3g == 6'b100111) ? 11'd0302-1 :    // 3G #7,    pathological = '1'
                      (select_3g == 6'b101001) ? 11'd0302-1 :    // 3G #9,    pathological = '1'
                      (select_3g == 6'b001010) ? 11'd0362-1 :    // 3G #10,   pathological = '0'
                      (select_3g == 6'b001011) ? 11'd0362-1 :    // 3G #11,   pathological = '0'
                      (select_3g == 6'b001111) ? 11'd0362-1 :    // 3G #15,   pathological = '0'
                      (select_3g == 6'b010000) ? 11'd0362-1 :    // 3G #16,   pathological = '0'
                      (select_3g == 6'b010100) ? 11'd0362-1 :    // 3G #20,   pathological = '0'
                      (select_3g == 6'b010101) ? 11'd0362-1 :    // 3G #21,   pathological = '0'
                      (select_3g == 6'b101010) ? 11'd0227-1 :    // 3G #10,   pathological = '1'
                      (select_3g == 6'b101011) ? 11'd0227-1 :    // 3G #11,   pathological = '1'
                      (select_3g == 6'b101111) ? 11'd0227-1 :    // 3G #15,   pathological = '1'
                      (select_3g == 6'b110000) ? 11'd0227-1 :    // 3G #16,   pathological = '1'
                      (select_3g == 6'b110100) ? 11'd0227-1 :    // 3G #20,   pathological = '1'
                      (select_3g == 6'b110101) ? 11'd0227-1 :    // 3G #21,   pathological = '1'
                      (select_3g == 6'b000000) ? 11'd0724-1 :    // 3G #0,    pathological = '0'
                      (select_3g == 6'b000001) ? 11'd0724-1 :    // 3G #1,    pathological = '0'
                      (select_3g == 6'b000100) ? 11'd0724-1 :    // 3G #4,    pathological = '0'
                      (select_3g == 6'b000110) ? 11'd0724-1 :    // 3G #6,    pathological = '0'
                      (select_3g == 6'b001000) ? 11'd0724-1 :    // 3G #8,    pathological = '0'
                      (select_3g == 6'b001100) ? 13'd0724-1 :    // 3G #12,   pathological = '0'
                      (select_3g == 6'b001101) ? 13'd0724-1 :    // 3G #13,   pathological = '0'
                      (select_3g == 6'b001110) ? 13'd0724-1 :    // 3G #14,   pathological = '0'
                      (select_3g == 6'b010001) ? 13'd0724-1 :    // 3G #17,   pathological = '0'
                      (select_3g == 6'b010010) ? 13'd0724-1 :    // 3G #18,   pathological = '0'
                      (select_3g == 6'b010011) ? 13'd0724-1 :    // 3G #19,   pathological = '0' 
                      (select_3g == 6'b011000) ? 13'd0724-1 :    // 3G #24,   pathological = '0' 
                      (select_3g == 6'b011001) ? 13'd0724-1 :    // 3G #25,   pathological = '0'                   
                      (select_3g == 6'b011010) ? 13'd0724-1 :    // 3G #26,   pathological = '0'     
                      (select_3g == 6'b011011) ? 13'd0724-1 :    // 3G #27,   pathological = '0'       
                      (select_3g == 6'b011100) ? 13'd0724-1 :    // 3G #28,   pathological = '0'       
                      (select_3g == 6'b011101) ? 13'd0724-1 :    // 3G #29,   pathological = '0'                            
                                                 11'd0454-1;     // 3G others pathological = '1'
   
   
   assign reg_yc_3g = (format_sel_3g == 5'b00010) ? 11'd0058-1 : // 3G #2,
                      (format_sel_3g == 5'b00011) ? 11'd0058-1 : // 3G #3,
                      (format_sel_3g == 5'b00101) ? 11'd0058-1 : // 3G #5,
                      (format_sel_3g == 5'b00111) ? 11'd0058-1 : // 3G #7,
                      (format_sel_3g == 5'b01001) ? 11'd0058-1 : // 3G #9,
                      (format_sel_3g == 5'b01010) ? 11'd0043-1 : // 3G #10,
                      (format_sel_3g == 5'b01011) ? 11'd0043-1 : // 3G #11,
                      (format_sel_3g == 5'b01111) ? 11'd0043-1 : // 3G #15,
                      (format_sel_3g == 5'b10000) ? 11'd0043-1 : // 3G #16,
                      (format_sel_3g == 5'b10100) ? 11'd0043-1 : // 3G #20,
                      (format_sel_3g == 5'b10101) ? 11'd0043-1 : // 3G #21,
                                                    11'd0086-1;  // 3G others

   assign reg_yd_3g = (select_3g == 6'b000010) ? 11'd0180-1 :    // 3G #2,    pathological = '0'
                      (select_3g == 6'b000011) ? 11'd0180-1 :    // 3G #3,    pathological = '0'
                      (select_3g == 6'b000101) ? 11'd0180-1 :    // 3G #5,    pathological = '0'
                      (select_3g == 6'b000111) ? 11'd0180-1 :    // 3G #7,    pathological = '0'
                      (select_3g == 6'b001001) ? 11'd0180-1 :    // 3G #9,    pathological = '0'
                      (select_3g == 6'b100010) ? 11'd0360-1 :    // 3G #2,    pathological = '1'
                      (select_3g == 6'b100011) ? 11'd0360-1 :    // 3G #3,    pathological = '1'
                      (select_3g == 6'b100101) ? 11'd0360-1 :    // 3G #5,    pathological = '1'
                      (select_3g == 6'b100111) ? 11'd0360-1 :    // 3G #7,    pathological = '1'
                      (select_3g == 6'b101001) ? 11'd0360-1 :    // 3G #9,    pathological = '1'
                      (select_3g == 6'b001010) ? 11'd0135-1 :    // 3G #10,   pathological = '0'
                      (select_3g == 6'b001011) ? 11'd0135-1 :    // 3G #11,   pathological = '0'
                      (select_3g == 6'b001111) ? 11'd0135-1 :    // 3G #15,   pathological = '0'
                      (select_3g == 6'b010000) ? 11'd0135-1 :    // 3G #16,   pathological = '0'
                      (select_3g == 6'b010100) ? 11'd0135-1 :    // 3G #20,   pathological = '0'
                      (select_3g == 6'b010101) ? 11'd0135-1 :    // 3G #21,   pathological = '0'
                      (select_3g == 6'b101010) ? 11'd0270-1 :    // 3G #10,   pathological = '1'
                      (select_3g == 6'b101011) ? 11'd0270-1 :    // 3G #11,   pathological = '1'
                      (select_3g == 6'b101111) ? 11'd0270-1 :    // 3G #15,   pathological = '1'
                      (select_3g == 6'b110000) ? 11'd0270-1 :    // 3G #16,   pathological = '1'
                      (select_3g == 6'b110100) ? 11'd0270-1 :    // 3G #20,   pathological = '1'
                      (select_3g == 6'b110101) ? 11'd0270-1 :    // 3G #21,   pathological = '1'
                      (select_3g == 6'b000000) ? 11'd0270-1 :    // 3G #0,    pathological = '0'
                      (select_3g == 6'b000001) ? 11'd0270-1 :    // 3G #1,    pathological = '0'
                      (select_3g == 6'b000100) ? 11'd0270-1 :    // 3G #4,    pathological = '0'
                      (select_3g == 6'b000110) ? 11'd0270-1 :    // 3G #6,    pathological = '0'
                      (select_3g == 6'b001000) ? 11'd0270-1 :    // 3G #8,    pathological = '0'
                      (select_3g == 6'b001100) ? 13'd0270-1 :    // 3G #12,   pathological = '0'
                      (select_3g == 6'b001101) ? 13'd0270-1 :    // 3G #13,   pathological = '0'
                      (select_3g == 6'b001110) ? 13'd0270-1 :    // 3G #14,   pathological = '0'
                      (select_3g == 6'b010001) ? 13'd0270-1 :    // 3G #17,   pathological = '0'
                      (select_3g == 6'b010010) ? 13'd0270-1 :    // 3G #18,   pathological = '0'
                      (select_3g == 6'b010011) ? 13'd0270-1 :    // 3G #19,   pathological = '0'
                      (select_3g == 6'b011000) ? 13'd0270-1 :    // 3G #24,   pathological = '0' 
                      (select_3g == 6'b011001) ? 13'd0270-1 :    // 3G #25,   pathological = '0'       
                      (select_3g == 6'b011010) ? 13'd0270-1 :    // 3G #26,   pathological = '0'   
                      (select_3g == 6'b011011) ? 13'd0270-1 :    // 3G #27,   pathological = '0'   
                      (select_3g == 6'b011100) ? 13'd0270-1 :    // 3G #28,   pathological = '0'   
                      (select_3g == 6'b011101) ? 13'd0270-1 :    // 3G #29,   pathological = '0'            
                                                 11'd0540-1;     // 3G others pathological = '1'
   
   
   assign reg_ye_3g = (format_sel_3g == 5'b00010) ? 11'd0005-1 : // 3G #2,
                      (format_sel_3g == 5'b00011) ? 11'd0005-1 : // 3G #3,
                      (format_sel_3g == 5'b00101) ? 11'd0005-1 : // 3G #5,
                      (format_sel_3g == 5'b00111) ? 11'd0005-1 : // 3G #7,
                      (format_sel_3g == 5'b01001) ? 11'd0005-1 : // 3G #9,
                      (format_sel_3g == 5'b01010) ? 11'd0003-1 : // 3G #10,
                      (format_sel_3g == 5'b01011) ? 11'd0003-1 : // 3G #11,
                      (format_sel_3g == 5'b01111) ? 11'd0003-1 : // 3G #15,
                      (format_sel_3g == 5'b10000) ? 11'd0003-1 : // 3G #16,
                      (format_sel_3g == 5'b10100) ? 11'd0003-1 : // 3G #20,
                      (format_sel_3g == 5'b10101) ? 11'd0003-1 : // 3G #21,
                                                    11'd0004-1;  // 3G others

   assign reg_yf_3g = (format_sel_3g == 5'b01010) ? 11'd0020-1 : // 3G #10,
                      (format_sel_3g == 5'b01011) ? 11'd0020-1 : // 3G #11,
                      (format_sel_3g == 5'b01111) ? 11'd0020-1 : // 3G #15,
                      (format_sel_3g == 5'b10000) ? 11'd0020-1 : // 3G #16,
                      (format_sel_3g == 5'b10100) ? 11'd0020-1 : // 3G #20,
                      (format_sel_3g == 5'b10101) ? 11'd0020-1 : // 3G #21,
                                                    11'd0000-1;  // 3G others

   assign reg_yg_3g = (select_3g == 6'b001010) ? 11'd0362-1 : // 3G #10,     pathological = '0'
                      (select_3g == 6'b001011) ? 11'd0362-1 : // 3G #11,     pathological = '0'
                      (select_3g == 6'b001111) ? 11'd0362-1 : // 3G #15,     pathological = '0'
                      (select_3g == 6'b010000) ? 11'd0362-1 : // 3G #16,     pathological = '0'
                      (select_3g == 6'b010100) ? 11'd0362-1 : // 3G #20,     pathological = '0'
                      (select_3g == 6'b010101) ? 11'd0362-1 : // 3G #21,     pathological = '0'
                      (select_3g == 6'b101010) ? 11'd0227-1 : // 3G #10,     pathological = '1'
                      (select_3g == 6'b101011) ? 11'd0227-1 : // 3G #11,     pathological = '1'
                      (select_3g == 6'b101111) ? 11'd0227-1 : // 3G #15,     pathological = '1'
                      (select_3g == 6'b110000) ? 11'd0227-1 : // 3G #16,     pathological = '1'
                      (select_3g == 6'b110100) ? 11'd0227-1 : // 3G #20,     pathological = '1'
                      (select_3g == 6'b110101) ? 11'd0227-1 : // 3G #21,     pathological = '1'
                                                 11'd0000-1;  // 3G others

   assign reg_yh_3g = (format_sel_3g == 5'b01010) ? 11'd0043-1 : // 3G #10,
                      (format_sel_3g == 5'b01011) ? 11'd0043-1 : // 3G #11,
                      (format_sel_3g == 5'b01111) ? 11'd0043-1 : // 3G #15,
                      (format_sel_3g == 5'b10000) ? 11'd0043-1 : // 3G #16,
                      (format_sel_3g == 5'b10100) ? 11'd0043-1 : // 3G #20,
                      (format_sel_3g == 5'b10101) ? 11'd0043-1 : // 3G #21,
                                                    11'd0000-1;  // 3G others

   assign reg_yi_3g = (select_3g == 6'b001010) ? 11'd0135-1 : // 3G #10,     pathological = '0'
                      (select_3g == 6'b001011) ? 11'd0135-1 : // 3G #11,     pathological = '0'
                      (select_3g == 6'b001111) ? 11'd0135-1 : // 3G #15,     pathological = '0'
                      (select_3g == 6'b010000) ? 11'd0135-1 : // 3G #16,     pathological = '0'
                      (select_3g == 6'b010100) ? 11'd0135-1 : // 3G #20,     pathological = '0'
                      (select_3g == 6'b010101) ? 11'd0135-1 : // 3G #21,     pathological = '0'
                      (select_3g == 6'b101010) ? 11'd0270-1 : // 3G #10,     pathological = '1'
                      (select_3g == 6'b101011) ? 11'd0270-1 : // 3G #11,     pathological = '1'
                      (select_3g == 6'b101111) ? 11'd0270-1 : // 3G #15,     pathological = '1'
                      (select_3g == 6'b110000) ? 11'd0270-1 : // 3G #16,     pathological = '1'
                      (select_3g == 6'b110100) ? 11'd0270-1 : // 3G #20,     pathological = '1'
                      (select_3g == 6'b110101) ? 11'd0270-1 : // 3G #21,     pathological = '1'
                                                 11'd0000-1;  // 3G others

   assign reg_yj_3g = (format_sel_3g == 5'b01010) ? 11'd0002-1 : // 3G #10,
                      (format_sel_3g == 5'b01011) ? 11'd0002-1 : // 3G #11,
                      (format_sel_3g == 5'b01111) ? 11'd0002-1 : // 3G #15,
                      (format_sel_3g == 5'b10000) ? 11'd0002-1 : // 3G #16,
                      (format_sel_3g == 5'b10100) ? 11'd0002-1 : // 3G #20,
                      (format_sel_3g == 5'b10101) ? 11'd0002-1 : // 3G #21,
                                                    11'd0000-1;  // 3G others

   assign reg_yk_3g = (format_sel_3g == 5'b00010) ? 11'd0720-1 : // 3G #2,
                      (format_sel_3g == 5'b00011) ? 11'd0720-1 : // 3G #3,
                      (format_sel_3g == 5'b00101) ? 11'd0720-1 : // 3G #5,
                      (format_sel_3g == 5'b00111) ? 11'd0720-1 : // 3G #7,
                      (format_sel_3g == 5'b01001) ? 11'd0720-1 : // 3G #9,
                      (format_sel_3g == 5'b01010) ? 11'd0540-1 : // 3G #10,
                      (format_sel_3g == 5'b01011) ? 11'd0540-1 : // 3G #11,
                      (format_sel_3g == 5'b01111) ? 11'd0540-1 : // 3G #15,
                      (format_sel_3g == 5'b10000) ? 11'd0540-1 : // 3G #16,
                      (format_sel_3g == 5'b10100) ? 11'd0540-1 : // 3G #20,
                      (format_sel_3g == 5'b10101) ? 11'd0540-1 : // 3G #21,
                                                    11'd1080-1;  // 3G others

   assign reg_yl_3g = (format_sel_3g == 5'b01010) ? 11'd0540-1 : // 3G #10,
                      (format_sel_3g == 5'b01011) ? 11'd0540-1 : // 3G #11,
                      (format_sel_3g == 5'b01111) ? 11'd0540-1 : // 3G #15,
                      (format_sel_3g == 5'b10000) ? 11'd0540-1 : // 3G #16,
                      (format_sel_3g == 5'b10100) ? 11'd0540-1 : // 3G #20,
                      (format_sel_3g == 5'b10101) ? 11'd0540-1 : // 3G #21,
                                                    11'd0000-1;  // 3G others

   assign reg_ln_3g = (format_sel_3g == 4'b0010) ? 11'd0750 : // 3G #2,
                      (format_sel_3g == 4'b0011) ? 11'd0750 : // 3G #3,
                      (format_sel_3g == 4'b0101) ? 11'd0750 : // 3G #5,
                      (format_sel_3g == 4'b0111) ? 11'd0750 : // 3G #7,
                      (format_sel_3g == 4'b1001) ? 11'd0750 : // 3G #9,
                                                   11'd1125;  // 3G others

   assign progressive_3g = (format_sel_3g == 5'b01010) ? 1'b0 : // 3G #10,
                           (format_sel_3g == 5'b01011) ? 1'b0 : // 3G #11,
                           (format_sel_3g == 5'b01111) ? 1'b0 : // 3G #15,
                           (format_sel_3g == 5'b10000) ? 1'b0 : // 3G #16,
                           (format_sel_3g == 5'b10100) ? 1'b0 : // 3G #20,
                           (format_sel_3g == 5'b10101) ? 1'b0 : // 3G #21,
                                                         1'b1;  // 3G others

   always @(posedge clk or negedge rstn)
   if (rstn == 1'b0) begin
      reg_xa      <= 13'd0278;
      reg_xb      <= 13'd1918;
      reg_xc      <= 13'd0272;
      reg_xd      <= 13'd0270;
      reg_xe      <= 13'd0274;
      reg_xf      <= 13'd0274;
      reg_xg      <= 13'd0340;
      reg_xh      <= 13'd0090;
      reg_xi      <= 13'd0238;
      reg_ya      <= 11'd0039;
      reg_yb      <= 11'd0345;  
      reg_yb_b    <= 11'd0345;
      reg_yc      <= 11'd0041;
      reg_yd      <= 11'd0128;
      reg_yd_b    <= 11'd0128; 
      reg_ye      <= 11'd0005;
      reg_yf      <= 11'd0038;
      reg_yg      <= 11'd0346;
      reg_yg_b    <= 11'd0346;  
      reg_yh      <= 11'd0041;
      reg_yi      <= 11'd0128;
      reg_yi_b    <= 11'd0128;         
      reg_yj      <= 11'd0004;
      reg_yk      <= 11'd0516;
      reg_yl      <= 11'd0517;
      reg_ln      <= 11'd1125;
      progressive <= 1'b1;
   end
   else begin
      if(sdi_3g_dl_n == 1'b1) begin
         reg_xa      <= reg_xa_3g;
         reg_xb      <= reg_xb_3g;
         reg_xc      <= reg_xc_3g;
         reg_xd      <= reg_xd_3g;
         reg_xe      <= reg_xe_3g;
         reg_xf      <= reg_xf_3g;
         reg_xg      <= reg_xg_3g;
         reg_xh      <= reg_xh_3g;
         reg_xi      <= reg_xi_3g;
         reg_ya      <= reg_ya_3g;
         reg_yb      <= reg_yb_3g;
         reg_yc      <= reg_yc_3g;
         reg_yd      <= reg_yd_3g;
         reg_ye      <= reg_ye_3g;
         reg_yf      <= reg_yf_3g;
         reg_yg      <= reg_yg_3g;
         reg_yh      <= reg_yh_3g;
         reg_yi      <= reg_yi_3g;
         reg_yj      <= reg_yj_3g;
         reg_yk      <= reg_yk_3g;
         reg_yl      <= reg_yl_3g;
         reg_ln      <= reg_ln_3g;
         progressive <= progressive_3g;
      end
      else begin
         reg_xa      <= {2'b0,reg_xa_sdi};
         reg_xb      <= {2'b0,reg_xb_sdi};
         reg_xc      <= {2'b0,reg_xc_sdi};
         reg_xd      <= {2'b0,reg_xd_sdi};
         reg_xe      <= {2'b0,reg_xe_sdi};
         reg_xf      <= {2'b0,reg_xf_sdi};
         reg_xg      <= {2'b0,reg_xg_sdi};
         reg_xh      <= {2'b0,reg_xh_sdi};
         reg_xi      <= {2'b0,reg_xi_sdi};
         reg_ya      <= reg_ya_sdi;
         reg_yb      <= reg_yb_sdi;    
         reg_yb_b    <= reg_yb_sdi_b;  
         reg_yc      <= reg_yc_sdi;
         reg_yd      <= reg_yd_sdi;  
         reg_yd_b    <= reg_yd_sdi_b; 
         reg_ye      <= reg_ye_sdi;
         reg_yf      <= reg_yf_sdi;
         reg_yg      <= reg_yg_sdi;
         reg_yg_b    <= reg_yg_sdi_b;     
         reg_yh      <= reg_yh_sdi;
         reg_yi      <= reg_yi_sdi;
         reg_yi_b    <= reg_yi_sdi_b;     
         reg_yj      <= reg_yj_sdi;
         reg_yk      <= reg_yk_sdi;
         reg_yl      <= reg_yl_sdi;
         reg_ln      <= reg_ln_sdi;
         progressive <= progressive_sdi; 
      end
   end


endmodule
