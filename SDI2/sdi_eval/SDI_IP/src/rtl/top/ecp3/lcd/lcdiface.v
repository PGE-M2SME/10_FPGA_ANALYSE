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
// File                  : lcdiface.v
// Title                 : LCD dotmatrix display top-level module 
// Dependencies          : 1.  lcdcon.v 
//                       : 2.  lcdmem.v 
// Description           : This is the top-level LCD dot-matrix display 
//                           interface module for displaying text in the LCD. 
//                           The data is read from a RAM 
// =============================================================================
//                        REVISION HISTORY
// Version               : 0.1
// Changes Made          : Initial Creation
// Author(s)             : Babu Mailachalam
// Mod. Date             : May 04, 2007
// =============================================================================


`timescale 1 ns/ 1ns

module lcdiface (
      clk,       // system clock- 100 MHz
      rstn,      // system reset
      wraddr,    // write address for RAM
      wrdata,    // write data for RAM
      wren,      // write enable for RAM
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

// ------------ Local parameters   
   localparam lnum_chars  = 32;  // Number of characters to write

// ------------ input ports
   input           	         clk;    // 100 MHz clock
   input    	                 rstn;
   input   [7:0]                 wraddr;                  
   input   [7:0]                 wrdata;
   input                         wren;
   
// ------------ output ports
   output                        lcd0;  // lcd_r/w
   output                        lcd5;  // lcd_rs
   output                        lcd6;  // lcd_e

// ------------ inout ports
   output                        lcd1;  // lcd_db0
   output                        lcd2;  // lcd_db2
   output                        lcd3;  // lcd_db4
   output                        lcd4;  // lcd_db6
   output                        lcd7;  // lcd_db1
   output                        lcd8;  // lcd_db3
   output                        lcd9;  // lcd_db5
   output                        lcd10; // lcd_db7

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

   reg     [15:0]                init_cntr;
   wire                          icntr_tc;
   reg     [15:0]                fst_cntr;
   wire                          fcntr_tc;

   reg                           icntr_enb;
   reg                           disp_en;
   wire                          memcntr_tc;
   reg     [7:0]                 mem_cntr;
   reg                           cmmd;
   reg     [7:0]                 disp_char;
   wire    [7:0]                 mem_out;
   reg                           rs;
   wire                          rwb;
   wire    [7:0]                 db_out;
   wire                          lcd_rs;
   wire                          lcd_rwb;
   wire                          lcd_e;
   wire    [7:0]                 rd_addr;

   reg                           inst_en;
   wire                          inst_tc;
   reg     [5:0]                 inst_cntr;
   reg                           cstall;
   reg                           cstalld;

// ------------------------- Start of Code ------------------------------

// ------------ first 16 counter for init pulse generation
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         fst_cntr <= 'b0;
      else if(fcntr_tc==1'b1)
         fst_cntr <= 'b0;
      else
         fst_cntr <= fst_cntr+1;
   end

`ifdef DO_SIM
   assign fcntr_tc=(fst_cntr==16'hff)?1'b1:1'b0;    // for sim
`else
   assign fcntr_tc=(fst_cntr==16'hffff)?1'b1:1'b0;  // for impl
`endif

// ------------ modulo 16 counter for init pulse generation
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         init_cntr <= 'b0;
      else if(icntr_tc==1'b1)
         init_cntr <= 'b0;
      else if((icntr_enb==1'b0)&&(fcntr_tc==1'b1))
         init_cntr <= init_cntr+1;
   end


`ifdef DO_SIM
   assign icntr_tc=(init_cntr==16'h20)?1'b1:1'b0;   // for sim
`else
//   assign icntr_tc=(init_cntr==16'h3ff)?1'b1:1'b0;  // for impl
   assign icntr_tc=(init_cntr==16'h08ff)?1'b1:1'b0;  // for impl
`endif

   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         icntr_enb <= 1'b0;
      else if(icntr_tc==1'b1)
         icntr_enb <= 1'b1;
   end

// ------------ Instruction enable signal
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0) 
         inst_en <= 1'b0;
      else if (icntr_tc==1'b1)
         inst_en <= 1'b1;
      else if (inst_tc==1'b1)
         inst_en <= 1'b0;
   end

// ------------ Instruction counter 
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         inst_cntr <= 'b0;
      else if((inst_en==1'b1)&&(fcntr_tc==1'b1))
         inst_cntr <= inst_cntr+1;
   end

   assign inst_tc=((inst_cntr==30)&&(inst_en==1'b1))?1'b1:1'b0;

// ------------ Instruction dispatch
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         disp_char <= 8'b0;
      else if(inst_cntr==1)
         disp_char <= 8'b00111000; // function set 1
      else if(inst_cntr==16)
         disp_char <= 8'b00111000; // function set 2
      else if(inst_cntr==18)
         disp_char <= 8'b00111000; // function set 3
      else if(inst_cntr==20)
         disp_char <= 8'b00111000; // function set 4
      else if(inst_cntr==22)
         disp_char <= 8'b00001000; // display off
      else if(inst_cntr==24)
         disp_char <= 8'b00000001; // disp clear
      else if(inst_cntr==26)
         disp_char <= 8'b00000111; // entry mode set
      else if(inst_cntr==28)
         disp_char <= 8'b00001100; // disp on
      else if(cstalld==1'b1)
         disp_char <= 8'b11000000; // set DRAM address
      else if(memcntr_tc==1'b1)
         disp_char <= 8'b10000000; // set DRAM address
      else
         disp_char <= mem_out;
   end

// ------------ display enable signal
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0) 
         disp_en <= 1'b0;
      else if (inst_tc==1'b1)
         disp_en <= 1'b1;
//   Commented the following 2 lines to refresh the display forever
//      else if (memcntr_tc==1'b1)
//         disp_en <= 1'b0;
   end

// ------------ memory address counter 
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         mem_cntr <= 'b0;
//      else if(memcntr_tc==1'b1)
      else if ((cmmd==1'b1)&&(memcntr_tc==1'b1))
         mem_cntr <= 'b0;
      else if((cmmd==1'b1)&&(disp_en==1'b1)&&(cstall==1'b0))
         mem_cntr <= mem_cntr+1;
   end

   assign memcntr_tc=(mem_cntr==lnum_chars)?1'b1:1'b0;

// ------------ cstall signal
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         cstall <= 1'b0;
      else if(cmmd==1'b1) 
         if(mem_cntr==14)
            cstall <= 1'b1;
         else
            cstall <= 1'b0;
   end

   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0)
         cstalld <= 1'b0;
      else if(cmmd==1'b1) 
         cstalld <= cstall;
   end

// ------------ cmmd signal generation
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0) 
         cmmd <= 1'b0;
      else if ((inst_cntr==1)&&(fcntr_tc==1'b1)) // first instr- func set
         cmmd <= 1'b1;
      else if ((inst_cntr==16)&&(fcntr_tc==1'b1)) // second instr- func set
         cmmd <= 1'b1;
      else if ((inst_cntr==18)&&(fcntr_tc==1'b1)) // third instr- func set
         cmmd <= 1'b1;
      else if ((inst_cntr==20)&&(fcntr_tc==1'b1)) // fourth instr- func set
         cmmd <= 1'b1;
      else if ((inst_cntr==22)&&(fcntr_tc==1'b1)) // fifth instr- display off
         cmmd <= 1'b1;
      else if ((inst_cntr==24)&&(fcntr_tc==1'b1)) // sixth instr- display clear
         cmmd <= 1'b1;
      else if ((inst_cntr==26)&&(fcntr_tc==1'b1)) // seventh instr- entry mode set
         cmmd <= 1'b1;
      else if ((inst_cntr==28)&&(fcntr_tc==1'b1)) // final instr- display on
         cmmd <= 1'b1;
      else if ((fcntr_tc==1'b1)&&(disp_en==1'b1)) // data write instructions
         cmmd <= 1'b1;
      else 
         cmmd <= 1'b0;
   end

// ------------ instantiate memory
   assign rd_addr=mem_cntr;
   lcdmem lcdmem_u1 (
      .Data(wrdata),
      .WrAddress(wraddr),
      .RdAddress(rd_addr),
      .WrClock(clk),
      .RdClock(clk),
      .WE(wren),
      .rstn(rstn),         
      .Q(mem_out)
      );

// ------------ rs signal generation
   always @(posedge clk or negedge rstn) begin
      if(rstn==1'b0) 
         rs <= 1'b0;
//      else if ((inst_en==1'b1)||(icntr_tc==1'b1)||(cstalld==1'b1)) 
      else if ((inst_en==1'b1)||(icntr_tc==1'b1)||(cstalld==1'b1)||(memcntr_tc==1'b1)) 
         rs <= 1'b0;
      else
         rs <= 1'b1;
   end

   assign rwb = 1'b0;

// ------------ instantiate LCD controller
   lcdcon lcdcon_u1 (
      .clk(clk),         // system clock- 100 MHz
      .rstn(rstn),       // system reset
      .db_in(disp_char), // input data to write to display
      .rs_in(rs),        // register select input
      .rwb_in(rwb),      // R/Wbar input
      .cmmd(cmmd),       // Command issued pulse
      .instr(inst_en),   // instruction is being given
      .db_out(db_out),   // output data for display
      .lcd_rwb(lcd_rwb), // LCD r/wb output
      .lcd_rs(lcd_rs),   // LCD register select output
      .lcd_e(lcd_e)      // LCD enable output
      );

// ------------ inout assignment
   assign {lcd10,lcd4,lcd9,lcd3,lcd8,lcd2,lcd7,lcd1}=db_out;

   assign lcd0=lcd_rwb;
   assign lcd5=lcd_rs;
   assign lcd6=lcd_e;


endmodule 

// $Log: $
