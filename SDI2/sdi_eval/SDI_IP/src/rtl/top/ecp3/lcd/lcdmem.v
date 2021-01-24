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
// File                  : lcdmem.v
// Title                 : LCD dotmatrix display controller 
// Dependencies          : 1.  x.v 
//                       : 2.  y.v 
// Description           : This is a wrapper for pmi_ram_dp to serve as LCD
//                            content memory
// =============================================================================
//                        REVISION HISTORY
// Version               : 0.1
// Changes Made          : Initial Creation
// Author(s)             : Babu Mailachalam
// Mod. Date             : May 03, 2007
// =============================================================================


`timescale 1 ns/ 1ns

module lcdmem (
         Data,      // Data
         WrAddress, // Write address
         RdAddress, // Read address
         WrClock,   // Write clock
         RdClock,   // Read clock
         WE,        // Write Enable
         rstn,      // system reset
         Q          // Data output
         );

// ------------ input ports
   input   [7:0]                 Data;
   input   [7:0]                 WrAddress;
   input   [7:0]                 RdAddress;
   input           	         WrClock;
   input           	         RdClock;
   input    	                 WE;
   input    	                 rstn;

// ------------ output ports
   output  [7:0]                 Q;

// ------------ internal wires
   wire    [7:0]                 Data;
   wire    [7:0]                 WrAddress;
   wire    [7:0]                 RdAddress;
   wire    [7:0]                 Q;

// ------------ Instantiating the PMI memory
   pmi_ram_dp 
      #(
      .pmi_wr_addr_depth(256),
      .pmi_wr_addr_width(8),
      .pmi_wr_data_width(8),
      .pmi_rd_addr_depth(256),
      .pmi_rd_addr_width(8),
      .pmi_rd_data_width(8),
      .pmi_regmode("reg"),
      .pmi_gsr("disable"),
      .pmi_resetmode("async"),
      .pmi_init_file("lcddata.mem"),
      .pmi_init_file_format("binary"),
      .pmi_family("ECP2M"),
      .module_type("pmi_ram_dp")
      )
   mem_inst1
      (
      .Data(Data),
      .WrAddress(WrAddress),
      .RdAddress(RdAddress),
      .WrClock(WrClock),
      .RdClock(RdClock),
      .WrClockEn(1'b1),
      .RdClockEn(1'b1),
      .WE(WE),
      .Reset(~rstn),
      .Q(Q)
      );


endmodule 

// $Log: $
