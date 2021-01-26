// --------------------------------------------------------------------
// Simple MachXO control for VPB
//    By Babu Mailachalam on 12/05/2008
// --------------------------------------------------------------------

`timescale 1 ns / 10 ps

// ============= Integer and fractional frame rate for Tx =============
// ------------- Comment the following for integer frame rate
//`define TX_FRAC_FRATE

// ============= Passthrough and loopback Tx clock settings ===========
// ------------- Comment the following for loopback configurations
`define PASSTHRU_ENABLE


module machxo_pt (
//   input  wire          tms,
//   input  wire          tck,
//   input  wire          tdi,
//   input  wire          lclk, 
//   input  wire          ecp3_xo_sig_11,
//   input  wire          ecp3_xo_sig_10,

   output wire          tdo, 
   output wire          gspi_di,
   output wire          gspi_clk,
   //Back-side Interface
   output wire [7:1]    TX_GS4911_CTRL,
   output wire [7:1]    RX_GS4911_CTRL,
   output wire [7:0]    TX_GS4915_CTRL,
   output wire [7:0]    RX_GS4915_CTRL,
   output wire          ASR_SEL2,
   output wire          ASR_SEL1,
   output wire          ASR_SEL0,
   output wire          GSPI_HST_JTAG,
   output wire          TX_GSPI_CSn,
   output wire          RX_GSPI_CSn,
   output wire          SD_HD_CH0,
   output wire          SD_HD_CH1,
   output wire          DISABLE_CH0,
   output wire          DISABLE_CH1,
   output wire          SDI_DRV_RSTI,
   output wire          MUTE_CH0,
   output wire          MUTE_CH1,
   output wire          BYPASS_CH0,
   output wire          BYPASS_CH1
   );


// ----- 4911 controls 
//    Bit-7    | Bit-6    | Bit-5    | Bit-4    | Bit-3    | Bit-2    | Bit-1
//             |          |          |          |          |          |
//    VID_STD0 | VID_STD1 | VID_STD2 | VID_STD3 | VID_STD4 | VID_STD5 | GENLOCKn
//

assign RX_GS4911_CTRL = 7'b1010101; // Set VID_STD[5:0] to Rx GS4911 to 21 for 148.5MHz 

// ============= Integer and fractional frame rate for Tx =============
`ifdef TX_FRAC_FRATE
   assign TX_GS4911_CTRL = 7'b0110101; // Set Tx GS4911 to 22 for 148.35 
`else
   assign TX_GS4911_CTRL = 7'b1010101; // Set Tx GS4911 to 21 for 148.5
`endif
// ====================================================================

// ----- 4915 controls 
//   Bit-7   | Bit-6  | Bit-5  | Bit-4  | Bit-3      | Bit-2  | Bit-1 | Bit-0
//           |        |        |        |            |        |       |
//   SKEW_EN | DOUBLE | FCTRL1 | FCTRL0 | AUTOBYPASS | BYPASS | IPSEL | RESETn
//
//  IPSEL - 0- Diff clock, 1- SE clock

assign RX_GS4915_CTRL = 8'b00000001;

// ============= Passthrough and loopback Tx clock settings ===========
`ifdef PASSTHRU_ENABLE
   assign TX_GS4915_CTRL = 8'b01000011;  // double=ON,  IPsel=1
`else
   assign TX_GS4915_CTRL = 8'b00000001;  // double=OFF, IPsel=0
`endif
// ====================================================================

assign ASR_SEL2 = 1'b0;
assign ASR_SEL1 = 1'b0;
assign ASR_SEL0 = 1'b0;

assign GSPI_HST_JTAG = 1'b0;
assign TX_GSPI_CSn = 1'b1;
assign RX_GSPI_CSn = 1'b1;

assign SD_HD_CH0 = 1'b0;    // 0- HD, 1-SD
assign SD_HD_CH1 = 1'b0;    // 0- HD, 1-SD

assign DISABLE_CH0 = 1'b1;  // 1- Enable, 0-Disable
assign DISABLE_CH1 = 1'b1;  // 1- Enable, 0-Disable

assign SDI_DRV_RSTI = 1'b1;
assign MUTE_CH0 = 1'b0;     // 1- Muted, 0- Normal operation
assign MUTE_CH1 = 1'b0;     // 1- Muted, 0- Normal operation
assign BYPASS_CH0 = 1'b0;   // 1- Bypass, 0- Normal equilizer operation
assign BYPASS_CH1 = 1'b0;   // 1- Bypass, 0- Normal equilizer operation


assign gspi_di  = 1'b0;
assign gspi_clk = 1'b0;

endmodule

