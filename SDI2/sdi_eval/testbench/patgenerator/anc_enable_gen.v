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
//  File:              anc_enable_gen.v
//  Title:             anc_enable_gen
//  Description:       This module generates the request signals for the
//                     anc_send and the anc_time_code_send modules to
//                     generate the ancilary data packets of payload
//                     identification and the time code.
//                     This module also generates the enabling signal for
//                     the pattern_generator_top module to insert
//                     the ancilary data packets at appropriate location.
//  
// --------------------------------------------------------------------
// Author : Guolin W., Cloud Y.
// $Revision: 1.3 $
// --------------------------------------------------------------------
`timescale 1ns/100ps  
module anc_enable_gen (
   input  wire        rstn,
   input  wire        clk,

   input  wire        sdi_3g_in,
   input  wire        sdi_3g_dl,
   input  wire        lb_lan,
   input  wire        sdi_3g_hd_dl,
   input  wire        vpid_insert_en,
   input  wire [ 4:0] format_sel_3g,
   input  wire        hd_sdn_in,
   input  wire [ 2:0] std_number,

   input  wire [10:0] line_number,
   input  wire        trs_out,
   input  wire        hblank,

   output reg         pat_gen_anc_req,
   output reg         pat_gen_anc_en,
   output reg         pat_gen_anc_en_lb_b,
   output reg         pat_gen_anc_en_dl,
   output reg  [ 4:0] format_sel
   );


   reg                sdi_3g_in_r         ;
   reg         [ 4:0] format_sel_3g_r     ;
   reg                hd_sdn_in_r         ;
   reg         [ 2:0] std_number_r        ;
   reg         [ 3:0] hblank_r            ;
   reg         [13:0] trs_out_r           ;
   reg                lb_lan_r            ;
   reg                sdi_3g_dl_r         ;
   reg                sdi_3g_hd_dl_r      ;

   reg                sd_525i_anc_line_en ;
   reg                sd_625i_anc_line_en ;
   reg                hd_750p_anc_line_en ;
   reg                hd_1125i_anc_line_en;
   reg                hd_1250i_anc_line_en;

   reg                sd_anc_en_tmp       ;
   reg                sd_anc_en           ;
   reg                hd_750p_anc_en      ;
   reg                hd_1250i_anc_en     ;
   reg                hd_1125i_anc_en     ;
   reg                hd_1125p_anc_en     ;
   reg                hd_anc_en           ;
   reg                td_750p_anc_en      ;
   reg                td_1125i_anc_en     ;
   reg                td_1125p_anc_en     ;
   reg                td_anc_en           ;
   reg                tg_hd_dl_anc_en     ;

   reg         [ 4:0] pat_gen_anc_cnt     ;

   wire        [ 3:0] hd_sd_sel           ;

always @(posedge clk or negedge rstn)
begin
   if (~rstn) begin
      sdi_3g_in_r     <= 1'h0;
      format_sel_3g_r <= 5'h0;
      hd_sdn_in_r     <= 1'h0;
      lb_lan_r        <= 1'h0;  
      sdi_3g_dl_r     <= 1'h0;
      sdi_3g_hd_dl_r  <= 1'h0;    
      std_number_r    <= 3'h0;
      hblank_r        <= 4'h0;
      trs_out_r       <= 14'h0;
   end
   else begin
      sdi_3g_in_r     <= sdi_3g_in    ;
      format_sel_3g_r <= format_sel_3g;  
      lb_lan_r        <= lb_lan;
      sdi_3g_dl_r     <= sdi_3g_dl;
      sdi_3g_hd_dl_r  <= sdi_3g_hd_dl; 
      hd_sdn_in_r     <= hd_sdn_in | sdi_3g_in;
      hblank_r        <= {hblank_r[2:0],hblank};
      trs_out_r       <= {trs_out_r[12:0],trs_out};
      if(sdi_3g_dl)
         if(format_sel_3g[0])
            std_number_r <= 3'h3;
         else
            std_number_r <= 3'h5;
      else
         std_number_r <= std_number;
   end
end

always @(posedge clk or negedge rstn)
begin
   if (~rstn) begin
      sd_525i_anc_line_en  <= 1'h0;
      sd_625i_anc_line_en  <= 1'h0;
      hd_750p_anc_line_en  <= 1'h0;
      hd_1125i_anc_line_en <= 1'h0;
      hd_1250i_anc_line_en <= 1'h0;
   end
   else begin
      sd_525i_anc_line_en  <= (line_number == 11'd13) | (line_number == 11'd276);
      sd_625i_anc_line_en  <= (line_number == 11'd9)  | (line_number == 11'd322);
      hd_750p_anc_line_en  <= line_number == 11'd10;
      hd_1125i_anc_line_en <= (line_number == 11'd10) | (line_number == 11'd572);
      hd_1250i_anc_line_en <= (line_number == 11'd10) | (line_number == 11'd635);
   end
end

always @(posedge clk or negedge rstn)
begin
   if (~rstn) begin
      sd_anc_en_tmp   <= 1'h0;
      sd_anc_en       <= 1'h0;
      hd_750p_anc_en  <= 1'h0;
      hd_1250i_anc_en <= 1'h0;
      hd_1125i_anc_en <= 1'h0;
      hd_1125p_anc_en <= 1'h0;
      hd_anc_en       <= 1'h0;
      td_750p_anc_en  <= 1'h0;
      td_1125i_anc_en <= 1'h0;
      td_1125p_anc_en <= 1'h0;
      td_anc_en       <= 1'h0;
      tg_hd_dl_anc_en <= 1'h0;     
      pat_gen_anc_req <= 1'h0;
   end
   else begin
      sd_anc_en_tmp   <= (~std_number_r[0] & sd_525i_anc_line_en) | (std_number_r[0] & sd_625i_anc_line_en);
      sd_anc_en       <= ~lb_lan_r & ~sdi_3g_in_r & ~hd_sdn_in_r & sd_anc_en_tmp;
      hd_750p_anc_en  <= hd_750p_anc_line_en  & (std_number_r == 3'h7);
      hd_1250i_anc_en <= hd_1250i_anc_line_en & (std_number_r == 3'h1);
      hd_1125i_anc_en <= hd_1125i_anc_line_en & ((std_number_r == 3'h0) | (std_number_r == 3'h3) | (std_number_r == 3'h5));
      hd_1125p_anc_en <= hd_750p_anc_line_en & ((std_number_r == 3'h2) | (std_number_r == 3'h4) | (std_number_r == 3'h6));
      hd_anc_en       <= ~lb_lan_r & ~sdi_3g_in_r & hd_sdn_in_r & (hd_750p_anc_en | hd_1125i_anc_en | hd_1125p_anc_en | hd_1250i_anc_en);
      td_750p_anc_en  <= hd_750p_anc_line_en  & ((format_sel_3g_r == 5'h2) | (format_sel_3g_r == 5'h3)
                      | (format_sel_3g_r == 5'h5) | (format_sel_3g_r == 5'h7) | (format_sel_3g_r == 5'h9));
      td_1125i_anc_en <= hd_1125i_anc_line_en  & ((format_sel_3g_r == 5'ha) | (format_sel_3g_r == 5'hb) | (format_sel_3g_r == 5'hf)
                      | (format_sel_3g_r == 5'h10) | (format_sel_3g_r == 5'h14) | (format_sel_3g_r == 5'h15));
      td_1125p_anc_en <= hd_750p_anc_line_en  & ((format_sel_3g_r == 5'h0) | (format_sel_3g_r == 5'h1)
                      | (format_sel_3g_r == 5'h4) | (format_sel_3g_r == 5'h6) | (format_sel_3g_r == 5'h8)
                      | (format_sel_3g_r == 5'hc) | (format_sel_3g_r == 5'hd) | (format_sel_3g_r == 5'he)
                      | (format_sel_3g_r == 5'h11) | (format_sel_3g_r == 5'h12) | (format_sel_3g_r == 5'h13));
      td_anc_en       <= ~lb_lan_r & sdi_3g_in_r & (td_750p_anc_en | td_1125i_anc_en | td_1125p_anc_en);
      tg_hd_dl_anc_en <= (lb_lan_r & sdi_3g_in_r & (td_1125i_anc_en | td_1125p_anc_en)) | (sdi_3g_hd_dl_r & ~sdi_3g_dl_r & (hd_750p_anc_en | hd_1125i_anc_en | hd_1125p_anc_en | hd_1250i_anc_en));  
      pat_gen_anc_req <= (hblank & ~hblank_r[0] & sd_anc_en) | (hblank_r[0] & trs_out_r[3] & (hd_anc_en | td_anc_en)) | (hblank_r[0] & trs_out_r[11] & tg_hd_dl_anc_en);
   end
end


always @(posedge clk or negedge rstn)
begin
   if (~rstn) begin
      pat_gen_anc_en      <= 1'h0;
      pat_gen_anc_en_dl   <= 1'b0;
      pat_gen_anc_en_lb_b <= 1'b0;
      pat_gen_anc_cnt     <= 5'h0;
   end
   else if(vpid_insert_en) begin
      if(hblank_r[0] & ((trs_out_r[5] & (hd_anc_en | td_anc_en)) | (trs_out_r[13] & tg_hd_dl_anc_en)))
         pat_gen_anc_en <= 1'h1;
      else if((lb_lan_r & (pat_gen_anc_cnt == 5'h15)) | (~lb_lan_r & (pat_gen_anc_cnt == 5'h0a)))
         pat_gen_anc_en  <= 1'h0;
      if(hblank_r[0] & ((trs_out_r[1] & sd_anc_en) | (trs_out_r[13] & tg_hd_dl_anc_en & ~sdi_3g_hd_dl_r)))
         pat_gen_anc_en_lb_b <= 1'h1;
      else if((lb_lan_r & (pat_gen_anc_cnt == 5'h15)) | (~lb_lan_r & (pat_gen_anc_cnt == 5'h0a)))
         pat_gen_anc_en_lb_b  <= 1'h0;   
      if(pat_gen_anc_en_dl | pat_gen_anc_en | pat_gen_anc_en_lb_b)
         pat_gen_anc_cnt <= pat_gen_anc_cnt + 1;
      else
         pat_gen_anc_cnt <= 5'h0;
      if(hblank_r[0] & trs_out_r[12] & tg_hd_dl_anc_en & sdi_3g_hd_dl_r)
         pat_gen_anc_en_dl <= 1'h1;
      else if(pat_gen_anc_cnt == 5'h15)
         pat_gen_anc_en_dl  <= 1'h0;      
   end
   else begin
      pat_gen_anc_en      <= 1'h0;
      pat_gen_anc_en_dl   <= 1'b0;
      pat_gen_anc_en_lb_b <= 1'b0;
      pat_gen_anc_cnt     <= 5'h0;
   end
end

assign hd_sd_sel = {hd_sdn_in,std_number};

always @(posedge clk or negedge rstn)
begin
   if (~rstn) begin
      format_sel <= 5'h16;
   end
   else begin
      if(sdi_3g_in)
         format_sel <= format_sel_3g;
      else begin
         case(hd_sd_sel)
            4'h8 :
               format_sel <= 5'h16;
            4'h9 :
               format_sel <= 5'h17;
            4'ha :
               format_sel <= 5'h18;
            4'hb :
               format_sel <= 5'h19;
            4'hc :
               format_sel <= 5'h1a;
            4'hd :
               format_sel <= 5'h1b;
            4'he :
               format_sel <= 5'h1c;
            4'hf :
               format_sel <= 5'h1d;
            4'h0 :
               format_sel <= 5'h1e;
            4'h1 :
               format_sel <= 5'h1f;
            default :
               format_sel <= 5'h16;
         endcase
      end
   end
end


endmodule
