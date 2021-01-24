// $Id: $
// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2000-2001 (c) Lattice Semiconductor Corporation
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
// Project               : SDI Framer 
// File                  : lcdcon.v
// Title                 : LCD dotmatrix display controller 
// Dependencies          : 1.  x.v 
//                       : 2.  y.v 
// Description           : This module is the LCD dot-matrix display controller
//                           for displaying text in the LCD unit.
//                           The data is read from a RAM defined outside this
//                           module.
// =============================================================================
//                        REVISION HISTORY
// Version               : 0.1
// Changes Made          : Initial Creation
// Author(s)             : Babu Mailachalam
// Mod. Date             : April 30, 2007
// -----------------------------------------------------------------------------
// Version               : 0.2
// Changes Made          : Made simpler without "busy" check
// Author(s)             : Babu Mailachalam
// Mod. Date             : May 10, 2007
// =============================================================================


`timescale 1 ns/ 1ns

module lcdcon (
         clk,       // system clock- 100 MHz
         rstn,      // system reset
         db_in,     // input data to write to display
         rs_in,     // register select input
         rwb_in,    // R/Wbar input
         cmmd,      // Command issued pulse
         instr,     // instruction is being given
         db_out,    // output data for display
         lcd_rwb,   // LCD r/wb output
         lcd_rs,    // LCD register select output
         lcd_e      // LCD enable output
         );

// ------------ module parameters
//   parameter ppat_awidth  = 10;    // pattern address width
      
// ------------ Local parameters   
   localparam ls_idle    = 0;    // idle
   localparam ls_init    = 1;    // init- apply RS, R/W
   localparam ls_enable  = 2;    // enable- apply E
   localparam ls_datarw  = 3;    // data read/write- actual data read or write
   localparam ls_disable = 4;    // disable- disbale E
   localparam ls_settle  = 5;    // wait for read/write cycle to settle

// ------------ input ports
   input           	         clk;    // 100 MHz clock
   input    	                 rstn;
   input   [7:0]                 db_in;
   input                         rs_in;
   input                         rwb_in;
   input                         cmmd;
   input                         instr;
   
// ------------ output ports
   output  [7:0]                 db_out;
   output                        lcd_rwb;
   output                        lcd_rs;
   output                        lcd_e;

// ------------ internal registers and wires
   reg    [3:0]                  div8;  // first clock divider (divides by 8)
   reg    [3:0]                  div16; // driven by div8 to achieve a div48
   
   reg    [2:0]                  cs;
   reg    [2:0]                  ns;

   reg                           new_cmmd;
   reg    [7:0]                  db_inr;
   reg                           rs_inr;
   reg                           rwb_inr;

   wire                          lcd_rs;
   wire                          lcd_rwb;
   reg                           lcd_e;
   wire   [7:0]                  db_in;
   wire   [7:0]                  db_out;
   wire                          div8_tc;
   wire                          div16_tc;
   reg                           instrr;

// ------------------------- Start of Code ------------------------------

// --- Note: It is assumed that the display gets initialized on reset

// ------------ Latching input data
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0) begin
         db_inr  <= 8'b0;
         rs_inr  <= 1'b0;
         rwb_inr <= 1'b0;
         instrr  <= 1'b0;
      end
      else if (cmmd==1'b1) begin
         db_inr  <= db_in;
         rs_inr  <= rs_in;
         rwb_inr <= rwb_in;
         instrr   <= instr;
      end
   end

   assign db_out = db_inr;

// ------------ Main interface state machine
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         cs <= ls_idle;
      else if (div8_tc==1'b1)
         cs <= ns;
   end

   always @(cs or new_cmmd or div16 or instr) begin
      case (cs)
         ls_idle: begin
            lcd_e = 1'b0;
            if(new_cmmd==1'b1) ns=ls_init;
            else ns=ls_idle;
         end
         ls_init: begin
            lcd_e = 1'b0;
            ns=ls_enable;
         end
         ls_enable: begin
            lcd_e = 1'b1;
            if(div16==5) ns=ls_datarw;
            else ns=ls_enable;
         end
         ls_datarw: begin
            lcd_e = 1'b1;
            if(div16==9) ns=ls_disable;
            else ns=ls_datarw;
         end
         ls_disable: begin
            lcd_e = 1'b0;
            if(div16==13) ns=ls_settle;
            else ns=ls_disable;
         end
         ls_settle: begin
            lcd_e = 1'b0;
            if(div16==15) ns=ls_idle;
            else ns=ls_settle;
         end
         default: begin
            lcd_e = 1'b0;
            ns=ls_idle;
         end
      endcase
   end

// ------------ Muxing of lcd_rs and lcd_rw signals
   assign lcd_rs=rs_inr;
   assign lcd_rwb=rwb_inr;

// ------------ new_cmmd signal
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         new_cmmd <= 1'b0;
      else if (cmmd==1'b1)
         new_cmmd <= 1'b1;
      else if (div8_tc==1'b1)
         new_cmmd <= 1'b0;
   end

// ------------ divide by 8 clock
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         div8 <= 'b0;
      else if (cmmd==1'b1)
         div8 <= 'b0;
      else
         div8 <= div8+1;
   end

   assign div8_tc=(div8==4'b1111)?1'b1:1'b0;

// ------------ modulo 16 counter
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         div16 <= 'b0;
      else if (cmmd==1'b1)
         div16 <= 'b0;
      else if (div8_tc==1'b1)
         div16 <= div16+1;
   end

   assign div16_tc=(div16==4'b1111)?1'b1:1'b0;


endmodule 

// $Log: $
