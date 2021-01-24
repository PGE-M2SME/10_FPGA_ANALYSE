
module SDI_IP (
      //=====INPUTS
      //===== global input signals 
      //===== transmitter input signals 

      //===== receiver input signals 
            rx_clk,        // receive clock input synchronous with rxdata
            rxdata,        // parallel data received from SERDES
            rx_rate,       // receiver scan control: {3G enable, HD enable, SD enable}

      //=====OUTPUTS
      //===== transmitter output signals 

      //===== receiver output signals 
            pd_out,        // parralel output data from the receiver
            vid_active,    // Indicates the receiver is locked to a valid video
            trs_out,       // TRS (either EAV or SAV) output
            rx_tg_hdn,     // indicates whether 3G or HD is being received
            rx_hd_sdn,     // indicates whether Hd or SD is being received
            vid_format,    // Video format (0-SD, 1-1280x720, 2-1920x1035, 3-1920x1080)
            frame_format,  // Frame format (0,1,,7 ---> res,24p,25p,30p,50i,60i,50p,60p)
            field,         // field 
            vblank,        // vertical blanking
            hblank,        // horizontal blanking
            ln1_out,       // line number output for stream1
            eav_error,     // EAV error
            sav_error,     // SAV error
            y1_crc_error,  // CRC error for y channel of stream1
            c1_crc_error,  // CRC error for c channel of stream1

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

// ------------ output ports

         output [ldatawidth-1:0]     pd_out;
         output                      vid_active;
         output                      trs_out;
         output                      rx_tg_hdn;
         output                      rx_hd_sdn;
         output [1:0]                vid_format;
         output [2:0]                frame_format;
         output                      field;
         output                      vblank;
         output                      hblank;
         output [llinenumbits-1:0]   ln1_out;
         output                      eav_error;
         output                      sav_error;
         output                      y1_crc_error;
         output                      c1_crc_error;


   sdi_core
      #(
      .pdevice_family      ("ECP3"),
      .pcepresent          (0),
      .penabletx           (0),
      .penablerx           (1),
      .plninsert_en        (1),
      .pcrcinsert_en       (1),
      .psd8b_mode          (0),
      .psd_tx_10bits       (0),
      .psd_rx_10bits       (0),
      .psd_ldr             (0),
      .ppdinsd_port        (0),
      .psdpll_exclude      (1),
      .penable_levelb      (0),
      .penable_vpid_tx     (1),
      .penable_vpid_rx     (0),
      .ptg_pgmtime         (3),
      .phd_pgmtime         (3),
      .psd_pgmtime         (3),
      .plock_thresh        (3),
      .punlock_thresh      (3),
      .pcust_hd            (0),
      .pvalorrange_hd      (1),
      .pe2s_val_hd         (),
      .ps2e_val_hd         (),
      .pe2s_min_hd         (146),
      .pe2s_max_hd         (698),
      .ps2e_min_hd         (2050),
      .ps2e_max_hd         (2052),
      .pcust_tg            (0),
      .pvalorrange_tg      (1),
      .pe2s_val_tg         (),
      .ps2e_val_tg         (),
      .pe2s_min_tg         (294),
      .pe2s_max_tg         (1400),
      .ps2e_min_tg         (4098),
      .ps2e_max_tg         (4104)
      )

   SDI_IP_inst (
   //=====INPUTS
   //===== global input signals
   //===== transmitter input signals
   //===== receiver input signals
         .rx_clk           (rx_clk),
         .rxdata           (rxdata),
         .rx_rate          (rx_rate),        

   //=====OUTPUTS
   //===== transmitter output signals
   //===== receiver output signals
         .pd_out           (pd_out), 
         .vid_active       (vid_active),
         .trs_out          (trs_out),
         .rx_tg_hdn        (rx_tg_hdn),
         .rx_hd_sdn        (rx_hd_sdn),
         .vid_format       (vid_format),
         .frame_format     (frame_format),
         .field            (field),
         .vblank           (vblank),
         .hblank           (hblank),
         .ln1_out          (ln1_out),
         .eav_error        (eav_error),
         .sav_error        (sav_error),
         .y1_crc_error     (y1_crc_error),
         .c1_crc_error     (c1_crc_error),

      .rstn                (rstn)
      );

endmodule 

