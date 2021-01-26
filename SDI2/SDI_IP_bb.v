
module SDI_IP (
      //=====INPUTS
      //===== global input signals 
      //===== transmitter input signals 

      //===== receiver input signals 
            rx_clk,        // receive clock input synchronous with rxdata
            rxdata,        // parallel data received from SERDES
            rx_rate,       // receiver scan control: {3G enable, HD enable, SD enable}
            rx_full_clk,   // 27 MHz SD clock when 10-bits Rx mode is used

      //=====OUTPUTS
      //===== transmitter output signals 

      //===== receiver output signals 
            pd_out,        // parralel output data from the receiver
            vid_active,    // Indicates the receiver is locked to a valid video
            trs_out,       // TRS (either EAV or SAV) output
            ychannel,      // y channel output indicator
            rx_lb_lan,     // indicates if output is 3G Level-B or not
            rx_tg_hdn,     // indicates whether 3G or HD is being received
            rx_hd_sdn,     // indicates whether Hd or SD is being received
            vid_format,    // Video format (0-SD, 1-1280x720, 2-1920x1035, 3-1920x1080)
            frame_format,  // Frame format (0,1,,7 ---> res,24p,25p,30p,50i,60i,50p,60p)
            field,         // field 
            vblank,        // vertical blanking
            hblank,        // horizontal blanking
            ln1_out,       // line number output for stream1
            ln2_out,       // line number output for stream2
            eav_error,     // EAV error
            sav_error,     // SAV error
            y1_crc_error,  // CRC error for y channel of stream1
            c1_crc_error,  // CRC error for c channel of stream1
            y2_crc_error,  // CRC error for y channel of stream2
            c2_crc_error,  // CRC error for c channel of stream2

            pdo_clk,       // Multiplexed output clock synchronous with output data
      //===== global input signal 
            rstn           // system reset
      );

// ------------ Local parameters
   localparam ldatawidth          = 20 ;
   localparam llinenumbits        = 11 ;
   localparam ldatawidthby2       = ldatawidth >> 1 ;

// ------------ input ports
         input                       rstn;

         input                       rx_clk;
         input  [ldatawidth-1:0]     rxdata;
         input  [2:0]                rx_rate;
         input                       rx_full_clk;

// ------------ output ports

         output [ldatawidth-1:0]     pd_out;
         output                      vid_active;
         output                      trs_out;
         output                      ychannel;
         output                      rx_lb_lan;
         output                      rx_tg_hdn;
         output                      rx_hd_sdn;
         output [1:0]                vid_format;
         output [2:0]                frame_format;
         output                      field;
         output                      vblank;
         output                      hblank;
         output [llinenumbits-1:0]   ln1_out;
         output [llinenumbits-1:0]   ln2_out;
         output                      eav_error;
         output                      sav_error;
         output                      y1_crc_error;
         output                      c1_crc_error;
         output                      y2_crc_error;
         output                      c2_crc_error;
         output                      pdo_clk;


endmodule 

