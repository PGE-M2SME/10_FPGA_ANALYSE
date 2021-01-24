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
// File                  : frac_det.v
// Title                 : Fractional rate determination module 
// Dependencies          : 1.
//                       : 
// Description           : This module determines whether received rate is 
//                         fractional or integer
// =============================================================================
//                        REVISION HISTORY
// Version               : 0.1
// Changes Made          : Initial Creation
// Author(s)             : Babu Mailachalam
// Mod. Date             : Jun 03, 2009
// =============================================================================

`timescale 1ns/1ns

//`define FRAC_REF_CLK

module frac_det (
            //=====INPUTS
            ref_clk,             // Reference clock (148.5 or 148.35)    
            rec_clk,             // Recovered clock ( (div2_mode) ? 74.25 : 148.5 )
            rstn,                // system reset
            ce,                  // clock enable
            rx_tg_hdn,           // 3G or HD (0- HD, 1-3G)
               
            //=====OUTPUTS
            frac_intn,           // fractional or internal (0-int, 1-frac)
            out_valid            // output valid
            );

// ------------ Module parameters
   parameter pfrac_intn     = 1;  // Integer or fractional ref clock (0-int, 1-frac) 

// ------------ Local parameters
   localparam liref_nom  = 148500;
   localparam lfref_nom  = 148350;
//   localparam lint_nom  = 74250;
//   localparam lfrac_nom = 74175;
//   localparam if_diff  = int_nom-frac_nom;   // 75
//   localparam if_tol   = 0.2*if_diff;        // 15
   localparam int_min  = 74235;
   localparam int_max  = 74265;
   localparam frac_min = 74160;
   localparam frac_max = 74190;

// ------------ input ports
   input                                     ref_clk;
   input                                     rec_clk;
   input                                     rstn;
   input                                     ce;
   input                                     rx_tg_hdn;

// ------------ output ports
   output                                    frac_intn;
   output                                    out_valid;

// ------------ Internal registers and wires
   reg     [17:0]                            refcnt;
   wire                                      rc_tc;
   reg                                       rc_tc_p1;
   reg                                       rc_tc_p2;
   reg                                       rc_tc_p3;
   reg                                       rc_tc_d2;
   reg                                       rc_tc_d3;
   reg     [17:0]                            reccnt;
   reg                                       rec_toggle;
   reg                                       frac_intn;
   reg                                       out_valid;
   wire                                      ref_clk_fin;
   wire    [17:0]                            ref_nom;
   
// ------------ Start of code
   generate
   if(pfrac_intn==1) begin
      assign ref_clk_fin = 1'b1;
      assign ref_nom = lfref_nom;
   end
   else begin
      assign ref_clk_fin = 1'b0;
      assign ref_nom = liref_nom;
   end
   endgenerate
   
// ------------ Counter for ref clock
// ------------ Output registers
   always @(posedge ref_clk or negedge rstn) begin
      if(rstn==1'b0) begin
         refcnt <= 'b0;
      end
      else if (ce==1'b1) begin
         if(rc_tc_p3==1'b1)
            refcnt <= 'b0;
         else
            refcnt <= refcnt+1;
      end
   end

   assign rc_tc = (refcnt==ref_nom-4);

   always @(posedge ref_clk or negedge rstn) begin
      if(rstn==1'b0) begin
         rc_tc_p1 <= 1'b0;
         rc_tc_p2 <= 1'b0;
         rc_tc_p3 <= 1'b0;
      end
      else if (ce==1'b1) begin
         rc_tc_p1 <= rc_tc;
         rc_tc_p2 <= rc_tc_p1;
         rc_tc_p3 <= rc_tc_p2;
      end
   end

// ------------ clock domain transfer
   always @(posedge rec_clk or negedge rstn) begin
      if(rstn==1'b0) begin
         rc_tc_d2 <= 1'b0;
         rc_tc_d3 <= 1'b0;
      end
      else if (ce==1'b1) begin
         rc_tc_d2 <= rc_tc_p1;
         rc_tc_d3 <= rc_tc_d2;
      end
   end

// ------------ recovered clock toggle
   always @(posedge rec_clk or negedge rstn) begin
      if(rstn==1'b0) begin
         rec_toggle <= 1'b0;
      end
      else if (ce==1'b1) begin
         if(rx_tg_hdn==1'b1)
            rec_toggle <= ~rec_toggle;
         else 
            rec_toggle <= 1'b1;
      end
   end

// ------------ recovered clock counter
   always @(posedge rec_clk or negedge rstn) begin
      if(rstn==1'b0) begin
         reccnt <= 'b0;
      end
      else if (ce==1'b1) begin
         if(rc_tc_d3==1'b1)
            reccnt <= 'b0;
         else if (rec_toggle==1'b1)
            reccnt <= reccnt+1;
      end
   end

// ------------ recovered clock counter
   always @(posedge rec_clk or negedge rstn) begin
      if(rstn==1'b0) begin
         frac_intn <= 1'b0;
         out_valid <= 1'b0;
      end
      else if (rc_tc_d3==1'b1) begin
         if((reccnt>int_min)&&(reccnt<int_max)) begin
            frac_intn <= 1'b0;
            out_valid <= 1'b1;
         end
         else if ((reccnt>frac_min)&&(reccnt<frac_max)) begin
            frac_intn <= 1'b1;
            out_valid <= 1'b1;
         end
         else
            out_valid <= 1'b0;
      end
   end


endmodule 
