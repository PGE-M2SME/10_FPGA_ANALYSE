
SDI_IP u1_USERNAME (

   //=====INPUTS
   //===== global input signals
   //===== transmitter input signals
   //===== receiver input signals
         .rx_clk           (rx_clk),
         .rxdata           (rxdata),
         .rx_rate          (rx_rate),        
         .rx_full_clk      (rx_full_clk),

   //=====OUTPUTS
   //===== transmitter output signals
   //===== receiver output signals
         .pd_out           (pd_out), 
         .vid_active       (vid_active),
         .trs_out          (trs_out),
         .ychannel         (ychannel),
         .rx_lb_lan        (rx_lb_lan),
         .rx_tg_hdn        (rx_tg_hdn),
         .rx_hd_sdn        (rx_hd_sdn),
         .vid_format       (vid_format),
         .frame_format     (frame_format),
         .field            (field),
         .vblank           (vblank),
         .hblank           (hblank),
         .ln1_out          (ln1_out),
         .ln2_out          (ln2_out),
         .eav_error        (eav_error),
         .sav_error        (sav_error),
         .y1_crc_error     (y1_crc_error),
         .c1_crc_error     (c1_crc_error),
         .y2_crc_error     (y2_crc_error),
         .c2_crc_error     (c2_crc_error),

         .pdo_clk          (pdo_clk),
      .rstn                (rstn)
      );



