// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.11.3.469
// Netlist written on Mon Mar 29 17:13:02 2021
//
// Verilog Description of module Top
//

module Top (Clk_FPGA, Clk, Hsync, De, Vsync, PinDat, Led);   // /home/diamond/SharedFolder/DiamondProjFolder/TOP.vhd(6[8:11])
    input Clk_FPGA;   // /home/diamond/SharedFolder/DiamondProjFolder/TOP.vhd(10[3:11])
    input Clk;   // /home/diamond/SharedFolder/DiamondProjFolder/TOP.vhd(11[6:9])
    input Hsync;   // /home/diamond/SharedFolder/DiamondProjFolder/TOP.vhd(12[6:11])
    input De;   // /home/diamond/SharedFolder/DiamondProjFolder/TOP.vhd(13[3:5])
    input Vsync;   // /home/diamond/SharedFolder/DiamondProjFolder/TOP.vhd(14[6:11])
    input [23:0]PinDat;   // /home/diamond/SharedFolder/DiamondProjFolder/TOP.vhd(15[3:9])
    output Led;   // /home/diamond/SharedFolder/DiamondProjFolder/TOP.vhd(16[3:6])
    
    wire GND_net /* synthesis RESET_NET_FOR_BUS20=20, DSPPORT_20=RST3 */ ;
    wire VCC_net /* synthesis CE_NET_FOR_BUS20=20, DSPPORT_20=CE3 */ ;
    wire Clk_FPGA_c /* synthesis DSPPORT_20=CLK3, CLOCK_NET_FOR_BUS20=20, is_clock=1, SET_AS_NETWORK=Clk_FPGA_c */ ;   // /home/diamond/SharedFolder/DiamondProjFolder/TOP.vhd(10[3:11])
    
    wire Led_c;
    wire [23:0]cpt;   // /home/diamond/SharedFolder/DiamondProjFolder/TOP.vhd(29[10:13])
    
    wire n177, n24, n23, cpt_23__N_49, Led_N_50, n22, n186, n21, 
        n182, n20, n179, n19, n180, n102, n103, n104, n105, 
        n106, n107, n108, n109, n110, n111, n112, n113, n114, 
        n115, n116, n117, n118, n119, n120, n121, n122, n123, 
        n124, n125, n192, n190, n170, n169, n168, n167, n166, 
        n165, n164, n163, n162, n161, n160, n159;
    
    VHI i2 (.Z(VCC_net));
    FD1S3IX cpt_21__i23 (.D(n102), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[23])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i23.GSR = "ENABLED";
    LUT4 i1_2_lut (.A(cpt[21]), .B(cpt[20]), .Z(n182)) /* synthesis lut_function=(A+(B)) */ ;
    defparam i1_2_lut.init = 16'heeee;
    PUR PUR_INST (.PUR(VCC_net));
    defparam PUR_INST.RST_PULSE = 1;
    LUT4 Led_I_0_2_lut (.A(Led_c), .B(cpt_23__N_49), .Z(Led_N_50)) /* synthesis lut_function=(!(A (B)+!A !(B))) */ ;   // /home/diamond/SharedFolder/DiamondProjFolder/TOP.vhd(50[4] 53[11])
    defparam Led_I_0_2_lut.init = 16'h6666;
    LUT4 i1_2_lut_adj_1 (.A(cpt[19]), .B(cpt[18]), .Z(n192)) /* synthesis lut_function=(A (B)) */ ;
    defparam i1_2_lut_adj_1.init = 16'h8888;
    LUT4 i1_3_lut (.A(cpt[16]), .B(cpt[15]), .C(cpt[17]), .Z(n186)) /* synthesis lut_function=(A+(B+(C))) */ ;
    defparam i1_3_lut.init = 16'hfefe;
    LUT4 i1_4_lut (.A(n190), .B(n180), .C(cpt[11]), .D(cpt[10]), .Z(n179)) /* synthesis lut_function=(A+(B (C)+!B (C (D)))) */ ;
    defparam i1_4_lut.init = 16'hfaea;
    VLO i1 (.Z(GND_net));
    GSR GSR_INST (.GSR(VCC_net));
    LUT4 i1_2_lut_adj_2 (.A(cpt[13]), .B(cpt[12]), .Z(n190)) /* synthesis lut_function=(A+(B)) */ ;
    defparam i1_2_lut_adj_2.init = 16'heeee;
    IB Clk_FPGA_pad (.I(Clk_FPGA), .O(Clk_FPGA_c));   // /home/diamond/SharedFolder/DiamondProjFolder/TOP.vhd(10[3:11])
    LUT4 i1_4_lut_adj_3 (.A(n192), .B(n186), .C(n179), .D(cpt[14]), 
         .Z(n177)) /* synthesis lut_function=(A (B+(C (D)))) */ ;
    defparam i1_4_lut_adj_3.init = 16'ha888;
    OB Led_pad (.I(Led_c), .O(Led));   // /home/diamond/SharedFolder/DiamondProjFolder/TOP.vhd(16[3:6])
    FD1S3AX sLed_15 (.D(Led_N_50), .CK(Clk_FPGA_c), .Q(Led_c));   // /home/diamond/SharedFolder/DiamondProjFolder/TOP.vhd(48[3] 54[10])
    defparam sLed_15.GSR = "ENABLED";
    LUT4 i1_4_lut_adj_4 (.A(cpt[9]), .B(cpt[6]), .C(cpt[8]), .D(cpt[7]), 
         .Z(n180)) /* synthesis lut_function=(A (B (C)+!B (C (D)))) */ ;
    defparam i1_4_lut_adj_4.init = 16'ha080;
    LUT4 i46_4_lut (.A(n182), .B(cpt[23]), .C(cpt[22]), .D(n177), .Z(cpt_23__N_49)) /* synthesis lut_function=(A (B+(C))+!A (B+(C (D)))) */ ;
    defparam i46_4_lut.init = 16'hfcec;
    CCU2C cpt_21_add_4_25 (.A0(cpt[23]), .B0(GND_net), .C0(GND_net), .D0(VCC_net), 
          .A1(GND_net), .B1(GND_net), .C1(GND_net), .D1(GND_net), .CIN(n170), 
          .S0(n102));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21_add_4_25.INIT0 = 16'haaa0;
    defparam cpt_21_add_4_25.INIT1 = 16'h0000;
    defparam cpt_21_add_4_25.INJECT1_0 = "NO";
    defparam cpt_21_add_4_25.INJECT1_1 = "NO";
    CCU2C cpt_21_add_4_23 (.A0(cpt[21]), .B0(GND_net), .C0(GND_net), .D0(VCC_net), 
          .A1(cpt[22]), .B1(GND_net), .C1(GND_net), .D1(VCC_net), .CIN(n169), 
          .COUT(n170), .S0(n104), .S1(n103));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21_add_4_23.INIT0 = 16'haaa0;
    defparam cpt_21_add_4_23.INIT1 = 16'haaa0;
    defparam cpt_21_add_4_23.INJECT1_0 = "NO";
    defparam cpt_21_add_4_23.INJECT1_1 = "NO";
    CCU2C cpt_21_add_4_21 (.A0(cpt[19]), .B0(GND_net), .C0(GND_net), .D0(VCC_net), 
          .A1(cpt[20]), .B1(GND_net), .C1(GND_net), .D1(VCC_net), .CIN(n168), 
          .COUT(n169), .S0(n106), .S1(n105));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21_add_4_21.INIT0 = 16'haaa0;
    defparam cpt_21_add_4_21.INIT1 = 16'haaa0;
    defparam cpt_21_add_4_21.INJECT1_0 = "NO";
    defparam cpt_21_add_4_21.INJECT1_1 = "NO";
    CCU2C cpt_21_add_4_19 (.A0(cpt[17]), .B0(GND_net), .C0(GND_net), .D0(VCC_net), 
          .A1(cpt[18]), .B1(GND_net), .C1(GND_net), .D1(VCC_net), .CIN(n167), 
          .COUT(n168), .S0(n108), .S1(n107));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21_add_4_19.INIT0 = 16'haaa0;
    defparam cpt_21_add_4_19.INIT1 = 16'haaa0;
    defparam cpt_21_add_4_19.INJECT1_0 = "NO";
    defparam cpt_21_add_4_19.INJECT1_1 = "NO";
    CCU2C cpt_21_add_4_17 (.A0(cpt[15]), .B0(GND_net), .C0(GND_net), .D0(VCC_net), 
          .A1(cpt[16]), .B1(GND_net), .C1(GND_net), .D1(VCC_net), .CIN(n166), 
          .COUT(n167), .S0(n110), .S1(n109));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21_add_4_17.INIT0 = 16'haaa0;
    defparam cpt_21_add_4_17.INIT1 = 16'haaa0;
    defparam cpt_21_add_4_17.INJECT1_0 = "NO";
    defparam cpt_21_add_4_17.INJECT1_1 = "NO";
    CCU2C cpt_21_add_4_15 (.A0(cpt[13]), .B0(GND_net), .C0(GND_net), .D0(VCC_net), 
          .A1(cpt[14]), .B1(GND_net), .C1(GND_net), .D1(VCC_net), .CIN(n165), 
          .COUT(n166), .S0(n112), .S1(n111));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21_add_4_15.INIT0 = 16'haaa0;
    defparam cpt_21_add_4_15.INIT1 = 16'haaa0;
    defparam cpt_21_add_4_15.INJECT1_0 = "NO";
    defparam cpt_21_add_4_15.INJECT1_1 = "NO";
    CCU2C cpt_21_add_4_13 (.A0(cpt[11]), .B0(GND_net), .C0(GND_net), .D0(VCC_net), 
          .A1(cpt[12]), .B1(GND_net), .C1(GND_net), .D1(VCC_net), .CIN(n164), 
          .COUT(n165), .S0(n114), .S1(n113));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21_add_4_13.INIT0 = 16'haaa0;
    defparam cpt_21_add_4_13.INIT1 = 16'haaa0;
    defparam cpt_21_add_4_13.INJECT1_0 = "NO";
    defparam cpt_21_add_4_13.INJECT1_1 = "NO";
    CCU2C cpt_21_add_4_11 (.A0(cpt[9]), .B0(GND_net), .C0(GND_net), .D0(VCC_net), 
          .A1(cpt[10]), .B1(GND_net), .C1(GND_net), .D1(VCC_net), .CIN(n163), 
          .COUT(n164), .S0(n116), .S1(n115));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21_add_4_11.INIT0 = 16'haaa0;
    defparam cpt_21_add_4_11.INIT1 = 16'haaa0;
    defparam cpt_21_add_4_11.INJECT1_0 = "NO";
    defparam cpt_21_add_4_11.INJECT1_1 = "NO";
    CCU2C cpt_21_add_4_9 (.A0(cpt[7]), .B0(GND_net), .C0(GND_net), .D0(VCC_net), 
          .A1(cpt[8]), .B1(GND_net), .C1(GND_net), .D1(VCC_net), .CIN(n162), 
          .COUT(n163), .S0(n118), .S1(n117));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21_add_4_9.INIT0 = 16'haaa0;
    defparam cpt_21_add_4_9.INIT1 = 16'haaa0;
    defparam cpt_21_add_4_9.INJECT1_0 = "NO";
    defparam cpt_21_add_4_9.INJECT1_1 = "NO";
    CCU2C cpt_21_add_4_7 (.A0(n19), .B0(GND_net), .C0(GND_net), .D0(VCC_net), 
          .A1(cpt[6]), .B1(GND_net), .C1(GND_net), .D1(VCC_net), .CIN(n161), 
          .COUT(n162), .S0(n120), .S1(n119));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21_add_4_7.INIT0 = 16'haaa0;
    defparam cpt_21_add_4_7.INIT1 = 16'haaa0;
    defparam cpt_21_add_4_7.INJECT1_0 = "NO";
    defparam cpt_21_add_4_7.INJECT1_1 = "NO";
    CCU2C cpt_21_add_4_5 (.A0(n21), .B0(GND_net), .C0(GND_net), .D0(VCC_net), 
          .A1(n20), .B1(GND_net), .C1(GND_net), .D1(VCC_net), .CIN(n160), 
          .COUT(n161), .S0(n122), .S1(n121));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21_add_4_5.INIT0 = 16'haaa0;
    defparam cpt_21_add_4_5.INIT1 = 16'haaa0;
    defparam cpt_21_add_4_5.INJECT1_0 = "NO";
    defparam cpt_21_add_4_5.INJECT1_1 = "NO";
    CCU2C cpt_21_add_4_3 (.A0(n23), .B0(GND_net), .C0(GND_net), .D0(VCC_net), 
          .A1(n22), .B1(GND_net), .C1(GND_net), .D1(VCC_net), .CIN(n159), 
          .COUT(n160), .S0(n124), .S1(n123));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21_add_4_3.INIT0 = 16'haaa0;
    defparam cpt_21_add_4_3.INIT1 = 16'haaa0;
    defparam cpt_21_add_4_3.INJECT1_0 = "NO";
    defparam cpt_21_add_4_3.INJECT1_1 = "NO";
    CCU2C cpt_21_add_4_1 (.A0(GND_net), .B0(GND_net), .C0(GND_net), .D0(GND_net), 
          .A1(n24), .B1(GND_net), .C1(GND_net), .D1(VCC_net), .COUT(n159), 
          .S1(n125));   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21_add_4_1.INIT0 = 16'h0000;
    defparam cpt_21_add_4_1.INIT1 = 16'h555f;
    defparam cpt_21_add_4_1.INJECT1_0 = "NO";
    defparam cpt_21_add_4_1.INJECT1_1 = "NO";
    FD1S3IX cpt_21__i22 (.D(n103), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[22])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i22.GSR = "ENABLED";
    FD1S3IX cpt_21__i21 (.D(n104), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[21])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i21.GSR = "ENABLED";
    FD1S3IX cpt_21__i20 (.D(n105), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[20])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i20.GSR = "ENABLED";
    FD1S3IX cpt_21__i19 (.D(n106), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[19])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i19.GSR = "ENABLED";
    FD1S3IX cpt_21__i18 (.D(n107), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[18])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i18.GSR = "ENABLED";
    FD1S3IX cpt_21__i17 (.D(n108), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[17])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i17.GSR = "ENABLED";
    FD1S3IX cpt_21__i16 (.D(n109), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[16])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i16.GSR = "ENABLED";
    FD1S3IX cpt_21__i15 (.D(n110), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[15])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i15.GSR = "ENABLED";
    FD1S3IX cpt_21__i14 (.D(n111), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[14])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i14.GSR = "ENABLED";
    FD1S3IX cpt_21__i13 (.D(n112), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[13])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i13.GSR = "ENABLED";
    FD1S3IX cpt_21__i12 (.D(n113), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[12])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i12.GSR = "ENABLED";
    FD1S3IX cpt_21__i11 (.D(n114), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[11])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i11.GSR = "ENABLED";
    FD1S3IX cpt_21__i10 (.D(n115), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[10])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i10.GSR = "ENABLED";
    FD1S3IX cpt_21__i9 (.D(n116), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[9])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i9.GSR = "ENABLED";
    FD1S3IX cpt_21__i8 (.D(n117), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[8])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i8.GSR = "ENABLED";
    FD1S3IX cpt_21__i7 (.D(n118), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[7])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i7.GSR = "ENABLED";
    FD1S3IX cpt_21__i6 (.D(n119), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(cpt[6])) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i6.GSR = "ENABLED";
    FD1S3IX cpt_21__i5 (.D(n120), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(n19)) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i5.GSR = "ENABLED";
    FD1S3IX cpt_21__i4 (.D(n121), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(n20)) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i4.GSR = "ENABLED";
    FD1S3IX cpt_21__i3 (.D(n122), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(n21)) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i3.GSR = "ENABLED";
    FD1S3IX cpt_21__i2 (.D(n123), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(n22)) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i2.GSR = "ENABLED";
    FD1S3IX cpt_21__i1 (.D(n124), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(n23)) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i1.GSR = "ENABLED";
    FD1S3IX cpt_21__i0 (.D(n125), .CK(Clk_FPGA_c), .CD(cpt_23__N_49), 
            .Q(n24)) /* synthesis syn_use_carry_chain=1, REG_OUTPUT_CLK=CLK3, REG_OUTPUT_CE=CE3, REG_OUTPUT_RST=RST3 */ ;   // /usr/local/diamond/3.11_x64/ispfpga/vhdl_packages/syn_unsi.vhd(118[20:31])
    defparam cpt_21__i0.GSR = "ENABLED";
    
endmodule
//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.11.3.469 */
/* Module Version: 6.5 */
/* /usr/local/diamond/3.11_x64/ispfpga/bin/lin64/scuba -w -bus_exp 7 -bb -arch ep5c00 -type bram -wp 10 -rp 0011 -data_width 1 -num_rows 2 -rdata_width 1 -read_reg1 outreg -gsr DISABLED -memformat bin -cascade -1 -n pmi_ram_dpEbnonesadr112112115216de -pmi -lang verilog  */
/* Mon Mar 29 17:24:28 2021 */


`timescale 1 ns / 1 ps
module pmi_ram_dpEbnonesadr112112115216de (WrAddress, RdAddress, Data, 
    WE, RdClock, RdClockEn, Reset, WrClock, WrClockEn, Q)/* synthesis NGD_DRC_MASK=1 */;
    input wire [0:0] WrAddress;
    input wire [0:0] RdAddress;
    input wire [0:0] Data;
    input wire WE;
    input wire RdClock;
    input wire RdClockEn;
    input wire Reset;
    input wire WrClock;
    input wire WrClockEn;
    output wire [0:0] Q;

    wire scuba_vhi;
    wire scuba_vlo;

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.CSDECODE_B = "0b000" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.CSDECODE_A = "0b000" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.WRITEMODE_B = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.WRITEMODE_A = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.GSR = "DISABLED" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.REGMODE_B = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.REGMODE_A = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.DATA_WIDTH_B = 1 ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.DATA_WIDTH_A = 1 ;
    DP16KC pmi_ram_dpEbnonesadr112112115216de_0_0_0 (.DIA0(scuba_vlo), .DIA1(scuba_vlo), 
        .DIA2(scuba_vlo), .DIA3(scuba_vlo), .DIA4(scuba_vlo), .DIA5(scuba_vlo), 
        .DIA6(scuba_vlo), .DIA7(scuba_vlo), .DIA8(scuba_vlo), .DIA9(scuba_vlo), 
        .DIA10(scuba_vlo), .DIA11(Data[0]), .DIA12(scuba_vlo), .DIA13(scuba_vlo), 
        .DIA14(scuba_vlo), .DIA15(scuba_vlo), .DIA16(scuba_vlo), .DIA17(scuba_vlo), 
        .ADA0(WrAddress[0]), .ADA1(scuba_vlo), .ADA2(scuba_vlo), .ADA3(scuba_vlo), 
        .ADA4(scuba_vlo), .ADA5(scuba_vlo), .ADA6(scuba_vlo), .ADA7(scuba_vlo), 
        .ADA8(scuba_vlo), .ADA9(scuba_vlo), .ADA10(scuba_vlo), .ADA11(scuba_vlo), 
        .ADA12(scuba_vlo), .ADA13(scuba_vlo), .CEA(WrClockEn), .CLKA(WrClock), 
        .OCEA(WrClockEn), .WEA(WE), .CSA0(scuba_vlo), .CSA1(scuba_vlo), 
        .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), .DIB1(scuba_vlo), 
        .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), .DIB5(scuba_vlo), 
        .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), .DIB9(scuba_vlo), 
        .DIB10(scuba_vlo), .DIB11(scuba_vlo), .DIB12(scuba_vlo), .DIB13(scuba_vlo), 
        .DIB14(scuba_vlo), .DIB15(scuba_vlo), .DIB16(scuba_vlo), .DIB17(scuba_vlo), 
        .ADB0(RdAddress[0]), .ADB1(scuba_vlo), .ADB2(scuba_vlo), .ADB3(scuba_vlo), 
        .ADB4(scuba_vlo), .ADB5(scuba_vlo), .ADB6(scuba_vlo), .ADB7(scuba_vlo), 
        .ADB8(scuba_vlo), .ADB9(scuba_vlo), .ADB10(scuba_vlo), .ADB11(scuba_vlo), 
        .ADB12(scuba_vlo), .ADB13(scuba_vlo), .CEB(RdClockEn), .CLKB(RdClock), 
        .OCEB(RdClockEn), .WEB(scuba_vlo), .CSB0(scuba_vlo), .CSB1(scuba_vlo), 
        .CSB2(scuba_vlo), .RSTB(Reset), .DOA0(), .DOA1(), .DOA2(), .DOA3(), 
        .DOA4(), .DOA5(), .DOA6(), .DOA7(), .DOA8(), .DOA9(), .DOA10(), 
        .DOA11(), .DOA12(), .DOA13(), .DOA14(), .DOA15(), .DOA16(), .DOA17(), 
        .DOB0(Q[0]), .DOB1(), .DOB2(), .DOB3(), .DOB4(), .DOB5(), .DOB6(), 
        .DOB7(), .DOB8(), .DOB9(), .DOB10(), .DOB11(), .DOB12(), .DOB13(), 
        .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="pmi_ram_dpEbnonesadr112112115216de__PMIP__2__1__1B" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis RESETMODE="SYNC" */;



    // exemplar begin
    // exemplar attribute pmi_ram_dpEbnonesadr112112115216de_0_0_0 MEM_LPC_FILE pmi_ram_dpEbnonesadr112112115216de__PMIP__2__1__1B
    // exemplar attribute pmi_ram_dpEbnonesadr112112115216de_0_0_0 MEM_INIT_FILE 
    // exemplar attribute pmi_ram_dpEbnonesadr112112115216de_0_0_0 RESETMODE SYNC
    // exemplar end

endmodule
/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.11.3.469 */
/* Module Version: 6.5 */
/* /usr/local/diamond/3.11_x64/ispfpga/bin/lin64/scuba -w -bus_exp 7 -bb -arch ep5c00 -type bram -wp 10 -rp 0011 -data_width 4 -num_rows 256 -rdata_width 4 -read_reg1 outreg -gsr DISABLED -memformat bin -cascade -1 -n pmi_ram_dpEbnonesadr4825648256119a95be -pmi -lang verilog  */
/* Mon Mar 29 17:24:28 2021 */


`timescale 1 ns / 1 ps
module pmi_ram_dpEbnonesadr4825648256119a95be (WrAddress, RdAddress, 
    Data, WE, RdClock, RdClockEn, Reset, WrClock, WrClockEn, Q)/* synthesis NGD_DRC_MASK=1 */;
    input wire [7:0] WrAddress;
    input wire [7:0] RdAddress;
    input wire [3:0] Data;
    input wire WE;
    input wire RdClock;
    input wire RdClockEn;
    input wire Reset;
    input wire WrClock;
    input wire WrClockEn;
    output wire [3:0] Q;

    wire scuba_vhi;
    wire scuba_vlo;

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    defparam pmi_ram_dpEbnonesadr4825648256119a95be_0_0_0.CSDECODE_B = "0b000" ;
    defparam pmi_ram_dpEbnonesadr4825648256119a95be_0_0_0.CSDECODE_A = "0b000" ;
    defparam pmi_ram_dpEbnonesadr4825648256119a95be_0_0_0.WRITEMODE_B = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr4825648256119a95be_0_0_0.WRITEMODE_A = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr4825648256119a95be_0_0_0.GSR = "DISABLED" ;
    defparam pmi_ram_dpEbnonesadr4825648256119a95be_0_0_0.REGMODE_B = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr4825648256119a95be_0_0_0.REGMODE_A = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr4825648256119a95be_0_0_0.DATA_WIDTH_B = 4 ;
    defparam pmi_ram_dpEbnonesadr4825648256119a95be_0_0_0.DATA_WIDTH_A = 4 ;
    DP16KC pmi_ram_dpEbnonesadr4825648256119a95be_0_0_0 (.DIA0(Data[0]), 
        .DIA1(Data[1]), .DIA2(Data[2]), .DIA3(Data[3]), .DIA4(scuba_vlo), 
        .DIA5(scuba_vlo), .DIA6(scuba_vlo), .DIA7(scuba_vlo), .DIA8(scuba_vlo), 
        .DIA9(scuba_vlo), .DIA10(scuba_vlo), .DIA11(scuba_vlo), .DIA12(scuba_vlo), 
        .DIA13(scuba_vlo), .DIA14(scuba_vlo), .DIA15(scuba_vlo), .DIA16(scuba_vlo), 
        .DIA17(scuba_vlo), .ADA0(scuba_vlo), .ADA1(scuba_vlo), .ADA2(WrAddress[0]), 
        .ADA3(WrAddress[1]), .ADA4(WrAddress[2]), .ADA5(WrAddress[3]), .ADA6(WrAddress[4]), 
        .ADA7(WrAddress[5]), .ADA8(WrAddress[6]), .ADA9(WrAddress[7]), .ADA10(scuba_vlo), 
        .ADA11(scuba_vlo), .ADA12(scuba_vlo), .ADA13(scuba_vlo), .CEA(WrClockEn), 
        .CLKA(WrClock), .OCEA(WrClockEn), .WEA(WE), .CSA0(scuba_vlo), .CSA1(scuba_vlo), 
        .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), .DIB1(scuba_vlo), 
        .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), .DIB5(scuba_vlo), 
        .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), .DIB9(scuba_vlo), 
        .DIB10(scuba_vlo), .DIB11(scuba_vlo), .DIB12(scuba_vlo), .DIB13(scuba_vlo), 
        .DIB14(scuba_vlo), .DIB15(scuba_vlo), .DIB16(scuba_vlo), .DIB17(scuba_vlo), 
        .ADB0(scuba_vlo), .ADB1(scuba_vlo), .ADB2(RdAddress[0]), .ADB3(RdAddress[1]), 
        .ADB4(RdAddress[2]), .ADB5(RdAddress[3]), .ADB6(RdAddress[4]), .ADB7(RdAddress[5]), 
        .ADB8(RdAddress[6]), .ADB9(RdAddress[7]), .ADB10(scuba_vlo), .ADB11(scuba_vlo), 
        .ADB12(scuba_vlo), .ADB13(scuba_vlo), .CEB(RdClockEn), .CLKB(RdClock), 
        .OCEB(RdClockEn), .WEB(scuba_vlo), .CSB0(scuba_vlo), .CSB1(scuba_vlo), 
        .CSB2(scuba_vlo), .RSTB(Reset), .DOA0(), .DOA1(), .DOA2(), .DOA3(), 
        .DOA4(), .DOA5(), .DOA6(), .DOA7(), .DOA8(), .DOA9(), .DOA10(), 
        .DOA11(), .DOA12(), .DOA13(), .DOA14(), .DOA15(), .DOA16(), .DOA17(), 
        .DOB0(Q[0]), .DOB1(Q[1]), .DOB2(Q[2]), .DOB3(Q[3]), .DOB4(), .DOB5(), 
        .DOB6(), .DOB7(), .DOB8(), .DOB9(), .DOB10(), .DOB11(), .DOB12(), 
        .DOB13(), .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="pmi_ram_dpEbnonesadr4825648256119a95be__PMIP__256__4__4B" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis RESETMODE="SYNC" */;



    // exemplar begin
    // exemplar attribute pmi_ram_dpEbnonesadr4825648256119a95be_0_0_0 MEM_LPC_FILE pmi_ram_dpEbnonesadr4825648256119a95be__PMIP__256__4__4B
    // exemplar attribute pmi_ram_dpEbnonesadr4825648256119a95be_0_0_0 MEM_INIT_FILE 
    // exemplar attribute pmi_ram_dpEbnonesadr4825648256119a95be_0_0_0 RESETMODE SYNC
    // exemplar end

endmodule
/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.11.3.469 */
/* Module Version: 6.5 */
/* /usr/local/diamond/3.11_x64/ispfpga/bin/lin64/scuba -w -bus_exp 7 -bb -arch ep5c00 -type bram -wp 10 -rp 0011 -data_width 1 -num_rows 2 -rdata_width 1 -read_reg1 outreg -gsr DISABLED -memformat bin -cascade -1 -n pmi_ram_dpEbnonesadr112112115216de -pmi -lang verilog  */
/* Mon Mar 29 17:42:35 2021 */


`timescale 1 ns / 1 ps
module pmi_ram_dpEbnonesadr112112115216de (WrAddress, RdAddress, Data, 
    WE, RdClock, RdClockEn, Reset, WrClock, WrClockEn, Q)/* synthesis NGD_DRC_MASK=1 */;
    input wire [0:0] WrAddress;
    input wire [0:0] RdAddress;
    input wire [0:0] Data;
    input wire WE;
    input wire RdClock;
    input wire RdClockEn;
    input wire Reset;
    input wire WrClock;
    input wire WrClockEn;
    output wire [0:0] Q;

    wire scuba_vhi;
    wire scuba_vlo;

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.CSDECODE_B = "0b000" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.CSDECODE_A = "0b000" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.WRITEMODE_B = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.WRITEMODE_A = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.GSR = "DISABLED" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.REGMODE_B = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.REGMODE_A = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.DATA_WIDTH_B = 1 ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.DATA_WIDTH_A = 1 ;
    DP16KC pmi_ram_dpEbnonesadr112112115216de_0_0_0 (.DIA0(scuba_vlo), .DIA1(scuba_vlo), 
        .DIA2(scuba_vlo), .DIA3(scuba_vlo), .DIA4(scuba_vlo), .DIA5(scuba_vlo), 
        .DIA6(scuba_vlo), .DIA7(scuba_vlo), .DIA8(scuba_vlo), .DIA9(scuba_vlo), 
        .DIA10(scuba_vlo), .DIA11(Data[0]), .DIA12(scuba_vlo), .DIA13(scuba_vlo), 
        .DIA14(scuba_vlo), .DIA15(scuba_vlo), .DIA16(scuba_vlo), .DIA17(scuba_vlo), 
        .ADA0(WrAddress[0]), .ADA1(scuba_vlo), .ADA2(scuba_vlo), .ADA3(scuba_vlo), 
        .ADA4(scuba_vlo), .ADA5(scuba_vlo), .ADA6(scuba_vlo), .ADA7(scuba_vlo), 
        .ADA8(scuba_vlo), .ADA9(scuba_vlo), .ADA10(scuba_vlo), .ADA11(scuba_vlo), 
        .ADA12(scuba_vlo), .ADA13(scuba_vlo), .CEA(WrClockEn), .CLKA(WrClock), 
        .OCEA(WrClockEn), .WEA(WE), .CSA0(scuba_vlo), .CSA1(scuba_vlo), 
        .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), .DIB1(scuba_vlo), 
        .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), .DIB5(scuba_vlo), 
        .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), .DIB9(scuba_vlo), 
        .DIB10(scuba_vlo), .DIB11(scuba_vlo), .DIB12(scuba_vlo), .DIB13(scuba_vlo), 
        .DIB14(scuba_vlo), .DIB15(scuba_vlo), .DIB16(scuba_vlo), .DIB17(scuba_vlo), 
        .ADB0(RdAddress[0]), .ADB1(scuba_vlo), .ADB2(scuba_vlo), .ADB3(scuba_vlo), 
        .ADB4(scuba_vlo), .ADB5(scuba_vlo), .ADB6(scuba_vlo), .ADB7(scuba_vlo), 
        .ADB8(scuba_vlo), .ADB9(scuba_vlo), .ADB10(scuba_vlo), .ADB11(scuba_vlo), 
        .ADB12(scuba_vlo), .ADB13(scuba_vlo), .CEB(RdClockEn), .CLKB(RdClock), 
        .OCEB(RdClockEn), .WEB(scuba_vlo), .CSB0(scuba_vlo), .CSB1(scuba_vlo), 
        .CSB2(scuba_vlo), .RSTB(Reset), .DOA0(), .DOA1(), .DOA2(), .DOA3(), 
        .DOA4(), .DOA5(), .DOA6(), .DOA7(), .DOA8(), .DOA9(), .DOA10(), 
        .DOA11(), .DOA12(), .DOA13(), .DOA14(), .DOA15(), .DOA16(), .DOA17(), 
        .DOB0(Q[0]), .DOB1(), .DOB2(), .DOB3(), .DOB4(), .DOB5(), .DOB6(), 
        .DOB7(), .DOB8(), .DOB9(), .DOB10(), .DOB11(), .DOB12(), .DOB13(), 
        .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="pmi_ram_dpEbnonesadr112112115216de__PMIP__2__1__1B" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis RESETMODE="SYNC" */;



    // exemplar begin
    // exemplar attribute pmi_ram_dpEbnonesadr112112115216de_0_0_0 MEM_LPC_FILE pmi_ram_dpEbnonesadr112112115216de__PMIP__2__1__1B
    // exemplar attribute pmi_ram_dpEbnonesadr112112115216de_0_0_0 MEM_INIT_FILE 
    // exemplar attribute pmi_ram_dpEbnonesadr112112115216de_0_0_0 RESETMODE SYNC
    // exemplar end

endmodule
/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.11.3.469 */
/* Module Version: 6.5 */
/* /usr/local/diamond/3.11_x64/ispfpga/bin/lin64/scuba -w -bus_exp 7 -bb -arch ep5c00 -type bram -wp 10 -rp 0011 -data_width 3 -num_rows 256 -rdata_width 3 -read_reg1 outreg -gsr DISABLED -memformat bin -cascade -1 -n pmi_ram_dpEbnonesadr3825638256119a8c8f -pmi -lang verilog  */
/* Mon Mar 29 17:42:35 2021 */


`timescale 1 ns / 1 ps
module pmi_ram_dpEbnonesadr3825638256119a8c8f (WrAddress, RdAddress, 
    Data, WE, RdClock, RdClockEn, Reset, WrClock, WrClockEn, Q)/* synthesis NGD_DRC_MASK=1 */;
    input wire [7:0] WrAddress;
    input wire [7:0] RdAddress;
    input wire [2:0] Data;
    input wire WE;
    input wire RdClock;
    input wire RdClockEn;
    input wire Reset;
    input wire WrClock;
    input wire WrClockEn;
    output wire [2:0] Q;

    wire scuba_vhi;
    wire scuba_vlo;

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    defparam pmi_ram_dpEbnonesadr3825638256119a8c8f_0_0_0.CSDECODE_B = "0b000" ;
    defparam pmi_ram_dpEbnonesadr3825638256119a8c8f_0_0_0.CSDECODE_A = "0b000" ;
    defparam pmi_ram_dpEbnonesadr3825638256119a8c8f_0_0_0.WRITEMODE_B = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr3825638256119a8c8f_0_0_0.WRITEMODE_A = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr3825638256119a8c8f_0_0_0.GSR = "DISABLED" ;
    defparam pmi_ram_dpEbnonesadr3825638256119a8c8f_0_0_0.REGMODE_B = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr3825638256119a8c8f_0_0_0.REGMODE_A = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr3825638256119a8c8f_0_0_0.DATA_WIDTH_B = 4 ;
    defparam pmi_ram_dpEbnonesadr3825638256119a8c8f_0_0_0.DATA_WIDTH_A = 4 ;
    DP16KC pmi_ram_dpEbnonesadr3825638256119a8c8f_0_0_0 (.DIA0(Data[0]), 
        .DIA1(Data[1]), .DIA2(Data[2]), .DIA3(scuba_vlo), .DIA4(scuba_vlo), 
        .DIA5(scuba_vlo), .DIA6(scuba_vlo), .DIA7(scuba_vlo), .DIA8(scuba_vlo), 
        .DIA9(scuba_vlo), .DIA10(scuba_vlo), .DIA11(scuba_vlo), .DIA12(scuba_vlo), 
        .DIA13(scuba_vlo), .DIA14(scuba_vlo), .DIA15(scuba_vlo), .DIA16(scuba_vlo), 
        .DIA17(scuba_vlo), .ADA0(scuba_vlo), .ADA1(scuba_vlo), .ADA2(WrAddress[0]), 
        .ADA3(WrAddress[1]), .ADA4(WrAddress[2]), .ADA5(WrAddress[3]), .ADA6(WrAddress[4]), 
        .ADA7(WrAddress[5]), .ADA8(WrAddress[6]), .ADA9(WrAddress[7]), .ADA10(scuba_vlo), 
        .ADA11(scuba_vlo), .ADA12(scuba_vlo), .ADA13(scuba_vlo), .CEA(WrClockEn), 
        .CLKA(WrClock), .OCEA(WrClockEn), .WEA(WE), .CSA0(scuba_vlo), .CSA1(scuba_vlo), 
        .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), .DIB1(scuba_vlo), 
        .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), .DIB5(scuba_vlo), 
        .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), .DIB9(scuba_vlo), 
        .DIB10(scuba_vlo), .DIB11(scuba_vlo), .DIB12(scuba_vlo), .DIB13(scuba_vlo), 
        .DIB14(scuba_vlo), .DIB15(scuba_vlo), .DIB16(scuba_vlo), .DIB17(scuba_vlo), 
        .ADB0(scuba_vlo), .ADB1(scuba_vlo), .ADB2(RdAddress[0]), .ADB3(RdAddress[1]), 
        .ADB4(RdAddress[2]), .ADB5(RdAddress[3]), .ADB6(RdAddress[4]), .ADB7(RdAddress[5]), 
        .ADB8(RdAddress[6]), .ADB9(RdAddress[7]), .ADB10(scuba_vlo), .ADB11(scuba_vlo), 
        .ADB12(scuba_vlo), .ADB13(scuba_vlo), .CEB(RdClockEn), .CLKB(RdClock), 
        .OCEB(RdClockEn), .WEB(scuba_vlo), .CSB0(scuba_vlo), .CSB1(scuba_vlo), 
        .CSB2(scuba_vlo), .RSTB(Reset), .DOA0(), .DOA1(), .DOA2(), .DOA3(), 
        .DOA4(), .DOA5(), .DOA6(), .DOA7(), .DOA8(), .DOA9(), .DOA10(), 
        .DOA11(), .DOA12(), .DOA13(), .DOA14(), .DOA15(), .DOA16(), .DOA17(), 
        .DOB0(Q[0]), .DOB1(Q[1]), .DOB2(Q[2]), .DOB3(), .DOB4(), .DOB5(), 
        .DOB6(), .DOB7(), .DOB8(), .DOB9(), .DOB10(), .DOB11(), .DOB12(), 
        .DOB13(), .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="pmi_ram_dpEbnonesadr3825638256119a8c8f__PMIP__256__3__3B" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis RESETMODE="SYNC" */;



    // exemplar begin
    // exemplar attribute pmi_ram_dpEbnonesadr3825638256119a8c8f_0_0_0 MEM_LPC_FILE pmi_ram_dpEbnonesadr3825638256119a8c8f__PMIP__256__3__3B
    // exemplar attribute pmi_ram_dpEbnonesadr3825638256119a8c8f_0_0_0 MEM_INIT_FILE 
    // exemplar attribute pmi_ram_dpEbnonesadr3825638256119a8c8f_0_0_0 RESETMODE SYNC
    // exemplar end

endmodule
/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.11.3.469 */
/* Module Version: 6.5 */
/* /usr/local/diamond/3.11_x64/ispfpga/bin/lin64/scuba -w -bus_exp 7 -bb -arch ep5c00 -type bram -wp 10 -rp 0011 -data_width 1 -num_rows 2 -rdata_width 1 -read_reg1 outreg -gsr DISABLED -memformat bin -cascade -1 -n pmi_ram_dpEbnonesadr112112115216de -pmi -lang verilog  */
/* Mon Mar 29 18:04:06 2021 */


`timescale 1 ns / 1 ps
module pmi_ram_dpEbnonesadr112112115216de (WrAddress, RdAddress, Data, 
    WE, RdClock, RdClockEn, Reset, WrClock, WrClockEn, Q)/* synthesis NGD_DRC_MASK=1 */;
    input wire [0:0] WrAddress;
    input wire [0:0] RdAddress;
    input wire [0:0] Data;
    input wire WE;
    input wire RdClock;
    input wire RdClockEn;
    input wire Reset;
    input wire WrClock;
    input wire WrClockEn;
    output wire [0:0] Q;

    wire scuba_vhi;
    wire scuba_vlo;

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.CSDECODE_B = "0b000" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.CSDECODE_A = "0b000" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.WRITEMODE_B = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.WRITEMODE_A = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.GSR = "DISABLED" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.REGMODE_B = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.REGMODE_A = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.DATA_WIDTH_B = 1 ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.DATA_WIDTH_A = 1 ;
    DP16KC pmi_ram_dpEbnonesadr112112115216de_0_0_0 (.DIA0(scuba_vlo), .DIA1(scuba_vlo), 
        .DIA2(scuba_vlo), .DIA3(scuba_vlo), .DIA4(scuba_vlo), .DIA5(scuba_vlo), 
        .DIA6(scuba_vlo), .DIA7(scuba_vlo), .DIA8(scuba_vlo), .DIA9(scuba_vlo), 
        .DIA10(scuba_vlo), .DIA11(Data[0]), .DIA12(scuba_vlo), .DIA13(scuba_vlo), 
        .DIA14(scuba_vlo), .DIA15(scuba_vlo), .DIA16(scuba_vlo), .DIA17(scuba_vlo), 
        .ADA0(WrAddress[0]), .ADA1(scuba_vlo), .ADA2(scuba_vlo), .ADA3(scuba_vlo), 
        .ADA4(scuba_vlo), .ADA5(scuba_vlo), .ADA6(scuba_vlo), .ADA7(scuba_vlo), 
        .ADA8(scuba_vlo), .ADA9(scuba_vlo), .ADA10(scuba_vlo), .ADA11(scuba_vlo), 
        .ADA12(scuba_vlo), .ADA13(scuba_vlo), .CEA(WrClockEn), .CLKA(WrClock), 
        .OCEA(WrClockEn), .WEA(WE), .CSA0(scuba_vlo), .CSA1(scuba_vlo), 
        .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), .DIB1(scuba_vlo), 
        .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), .DIB5(scuba_vlo), 
        .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), .DIB9(scuba_vlo), 
        .DIB10(scuba_vlo), .DIB11(scuba_vlo), .DIB12(scuba_vlo), .DIB13(scuba_vlo), 
        .DIB14(scuba_vlo), .DIB15(scuba_vlo), .DIB16(scuba_vlo), .DIB17(scuba_vlo), 
        .ADB0(RdAddress[0]), .ADB1(scuba_vlo), .ADB2(scuba_vlo), .ADB3(scuba_vlo), 
        .ADB4(scuba_vlo), .ADB5(scuba_vlo), .ADB6(scuba_vlo), .ADB7(scuba_vlo), 
        .ADB8(scuba_vlo), .ADB9(scuba_vlo), .ADB10(scuba_vlo), .ADB11(scuba_vlo), 
        .ADB12(scuba_vlo), .ADB13(scuba_vlo), .CEB(RdClockEn), .CLKB(RdClock), 
        .OCEB(RdClockEn), .WEB(scuba_vlo), .CSB0(scuba_vlo), .CSB1(scuba_vlo), 
        .CSB2(scuba_vlo), .RSTB(Reset), .DOA0(), .DOA1(), .DOA2(), .DOA3(), 
        .DOA4(), .DOA5(), .DOA6(), .DOA7(), .DOA8(), .DOA9(), .DOA10(), 
        .DOA11(), .DOA12(), .DOA13(), .DOA14(), .DOA15(), .DOA16(), .DOA17(), 
        .DOB0(Q[0]), .DOB1(), .DOB2(), .DOB3(), .DOB4(), .DOB5(), .DOB6(), 
        .DOB7(), .DOB8(), .DOB9(), .DOB10(), .DOB11(), .DOB12(), .DOB13(), 
        .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="pmi_ram_dpEbnonesadr112112115216de__PMIP__2__1__1B" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis RESETMODE="SYNC" */;



    // exemplar begin
    // exemplar attribute pmi_ram_dpEbnonesadr112112115216de_0_0_0 MEM_LPC_FILE pmi_ram_dpEbnonesadr112112115216de__PMIP__2__1__1B
    // exemplar attribute pmi_ram_dpEbnonesadr112112115216de_0_0_0 MEM_INIT_FILE 
    // exemplar attribute pmi_ram_dpEbnonesadr112112115216de_0_0_0 RESETMODE SYNC
    // exemplar end

endmodule
/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.11.3.469 */
/* Module Version: 6.5 */
/* /usr/local/diamond/3.11_x64/ispfpga/bin/lin64/scuba -w -bus_exp 7 -bb -arch ep5c00 -type bram -wp 10 -rp 0011 -data_width 3 -num_rows 16384 -rdata_width 3 -read_reg1 outreg -gsr DISABLED -memformat bin -cascade -1 -n pmi_ram_dpEbnonesadr314163843141638412067ab1 -pmi -lang verilog  */
/* Mon Mar 29 18:04:05 2021 */


`timescale 1 ns / 1 ps
module pmi_ram_dpEbnonesadr314163843141638412067ab1 (WrAddress, 
    RdAddress, Data, WE, RdClock, RdClockEn, Reset, WrClock, WrClockEn, 
    Q)/* synthesis NGD_DRC_MASK=1 */;
    input wire [13:0] WrAddress;
    input wire [13:0] RdAddress;
    input wire [2:0] Data;
    input wire WE;
    input wire RdClock;
    input wire RdClockEn;
    input wire Reset;
    input wire WrClock;
    input wire WrClockEn;
    output wire [2:0] Q;

    wire scuba_vhi;
    wire scuba_vlo;

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.CSDECODE_B = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.CSDECODE_A = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.WRITEMODE_B = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.WRITEMODE_A = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.GSR = "DISABLED" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.REGMODE_B = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.REGMODE_A = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.DATA_WIDTH_B = 1 ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.DATA_WIDTH_A = 1 ;
    DP16KC pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2 (.DIA0(scuba_vlo), 
        .DIA1(scuba_vlo), .DIA2(scuba_vlo), .DIA3(scuba_vlo), .DIA4(scuba_vlo), 
        .DIA5(scuba_vlo), .DIA6(scuba_vlo), .DIA7(scuba_vlo), .DIA8(scuba_vlo), 
        .DIA9(scuba_vlo), .DIA10(scuba_vlo), .DIA11(Data[0]), .DIA12(scuba_vlo), 
        .DIA13(scuba_vlo), .DIA14(scuba_vlo), .DIA15(scuba_vlo), .DIA16(scuba_vlo), 
        .DIA17(scuba_vlo), .ADA0(WrAddress[0]), .ADA1(WrAddress[1]), .ADA2(WrAddress[2]), 
        .ADA3(WrAddress[3]), .ADA4(WrAddress[4]), .ADA5(WrAddress[5]), .ADA6(WrAddress[6]), 
        .ADA7(WrAddress[7]), .ADA8(WrAddress[8]), .ADA9(WrAddress[9]), .ADA10(WrAddress[10]), 
        .ADA11(WrAddress[11]), .ADA12(WrAddress[12]), .ADA13(WrAddress[13]), 
        .CEA(WrClockEn), .CLKA(WrClock), .OCEA(WrClockEn), .WEA(WE), .CSA0(scuba_vlo), 
        .CSA1(scuba_vlo), .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), 
        .DIB1(scuba_vlo), .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), 
        .DIB5(scuba_vlo), .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), 
        .DIB9(scuba_vlo), .DIB10(scuba_vlo), .DIB11(scuba_vlo), .DIB12(scuba_vlo), 
        .DIB13(scuba_vlo), .DIB14(scuba_vlo), .DIB15(scuba_vlo), .DIB16(scuba_vlo), 
        .DIB17(scuba_vlo), .ADB0(RdAddress[0]), .ADB1(RdAddress[1]), .ADB2(RdAddress[2]), 
        .ADB3(RdAddress[3]), .ADB4(RdAddress[4]), .ADB5(RdAddress[5]), .ADB6(RdAddress[6]), 
        .ADB7(RdAddress[7]), .ADB8(RdAddress[8]), .ADB9(RdAddress[9]), .ADB10(RdAddress[10]), 
        .ADB11(RdAddress[11]), .ADB12(RdAddress[12]), .ADB13(RdAddress[13]), 
        .CEB(RdClockEn), .CLKB(RdClock), .OCEB(RdClockEn), .WEB(scuba_vlo), 
        .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), .RSTB(Reset), 
        .DOA0(), .DOA1(), .DOA2(), .DOA3(), .DOA4(), .DOA5(), .DOA6(), .DOA7(), 
        .DOA8(), .DOA9(), .DOA10(), .DOA11(), .DOA12(), .DOA13(), .DOA14(), 
        .DOA15(), .DOA16(), .DOA17(), .DOB0(Q[0]), .DOB1(), .DOB2(), .DOB3(), 
        .DOB4(), .DOB5(), .DOB6(), .DOB7(), .DOB8(), .DOB9(), .DOB10(), 
        .DOB11(), .DOB12(), .DOB13(), .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis RESETMODE="SYNC" */;

    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.CSDECODE_B = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.CSDECODE_A = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.WRITEMODE_B = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.WRITEMODE_A = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.GSR = "DISABLED" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.REGMODE_B = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.REGMODE_A = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.DATA_WIDTH_B = 1 ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.DATA_WIDTH_A = 1 ;
    DP16KC pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1 (.DIA0(scuba_vlo), 
        .DIA1(scuba_vlo), .DIA2(scuba_vlo), .DIA3(scuba_vlo), .DIA4(scuba_vlo), 
        .DIA5(scuba_vlo), .DIA6(scuba_vlo), .DIA7(scuba_vlo), .DIA8(scuba_vlo), 
        .DIA9(scuba_vlo), .DIA10(scuba_vlo), .DIA11(Data[1]), .DIA12(scuba_vlo), 
        .DIA13(scuba_vlo), .DIA14(scuba_vlo), .DIA15(scuba_vlo), .DIA16(scuba_vlo), 
        .DIA17(scuba_vlo), .ADA0(WrAddress[0]), .ADA1(WrAddress[1]), .ADA2(WrAddress[2]), 
        .ADA3(WrAddress[3]), .ADA4(WrAddress[4]), .ADA5(WrAddress[5]), .ADA6(WrAddress[6]), 
        .ADA7(WrAddress[7]), .ADA8(WrAddress[8]), .ADA9(WrAddress[9]), .ADA10(WrAddress[10]), 
        .ADA11(WrAddress[11]), .ADA12(WrAddress[12]), .ADA13(WrAddress[13]), 
        .CEA(WrClockEn), .CLKA(WrClock), .OCEA(WrClockEn), .WEA(WE), .CSA0(scuba_vlo), 
        .CSA1(scuba_vlo), .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), 
        .DIB1(scuba_vlo), .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), 
        .DIB5(scuba_vlo), .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), 
        .DIB9(scuba_vlo), .DIB10(scuba_vlo), .DIB11(scuba_vlo), .DIB12(scuba_vlo), 
        .DIB13(scuba_vlo), .DIB14(scuba_vlo), .DIB15(scuba_vlo), .DIB16(scuba_vlo), 
        .DIB17(scuba_vlo), .ADB0(RdAddress[0]), .ADB1(RdAddress[1]), .ADB2(RdAddress[2]), 
        .ADB3(RdAddress[3]), .ADB4(RdAddress[4]), .ADB5(RdAddress[5]), .ADB6(RdAddress[6]), 
        .ADB7(RdAddress[7]), .ADB8(RdAddress[8]), .ADB9(RdAddress[9]), .ADB10(RdAddress[10]), 
        .ADB11(RdAddress[11]), .ADB12(RdAddress[12]), .ADB13(RdAddress[13]), 
        .CEB(RdClockEn), .CLKB(RdClock), .OCEB(RdClockEn), .WEB(scuba_vlo), 
        .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), .RSTB(Reset), 
        .DOA0(), .DOA1(), .DOA2(), .DOA3(), .DOA4(), .DOA5(), .DOA6(), .DOA7(), 
        .DOA8(), .DOA9(), .DOA10(), .DOA11(), .DOA12(), .DOA13(), .DOA14(), 
        .DOA15(), .DOA16(), .DOA17(), .DOB0(Q[1]), .DOB1(), .DOB2(), .DOB3(), 
        .DOB4(), .DOB5(), .DOB6(), .DOB7(), .DOB8(), .DOB9(), .DOB10(), 
        .DOB11(), .DOB12(), .DOB13(), .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis RESETMODE="SYNC" */;

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.CSDECODE_B = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.CSDECODE_A = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.WRITEMODE_B = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.WRITEMODE_A = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.GSR = "DISABLED" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.REGMODE_B = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.REGMODE_A = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.DATA_WIDTH_B = 1 ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.DATA_WIDTH_A = 1 ;
    DP16KC pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0 (.DIA0(scuba_vlo), 
        .DIA1(scuba_vlo), .DIA2(scuba_vlo), .DIA3(scuba_vlo), .DIA4(scuba_vlo), 
        .DIA5(scuba_vlo), .DIA6(scuba_vlo), .DIA7(scuba_vlo), .DIA8(scuba_vlo), 
        .DIA9(scuba_vlo), .DIA10(scuba_vlo), .DIA11(Data[2]), .DIA12(scuba_vlo), 
        .DIA13(scuba_vlo), .DIA14(scuba_vlo), .DIA15(scuba_vlo), .DIA16(scuba_vlo), 
        .DIA17(scuba_vlo), .ADA0(WrAddress[0]), .ADA1(WrAddress[1]), .ADA2(WrAddress[2]), 
        .ADA3(WrAddress[3]), .ADA4(WrAddress[4]), .ADA5(WrAddress[5]), .ADA6(WrAddress[6]), 
        .ADA7(WrAddress[7]), .ADA8(WrAddress[8]), .ADA9(WrAddress[9]), .ADA10(WrAddress[10]), 
        .ADA11(WrAddress[11]), .ADA12(WrAddress[12]), .ADA13(WrAddress[13]), 
        .CEA(WrClockEn), .CLKA(WrClock), .OCEA(WrClockEn), .WEA(WE), .CSA0(scuba_vlo), 
        .CSA1(scuba_vlo), .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), 
        .DIB1(scuba_vlo), .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), 
        .DIB5(scuba_vlo), .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), 
        .DIB9(scuba_vlo), .DIB10(scuba_vlo), .DIB11(scuba_vlo), .DIB12(scuba_vlo), 
        .DIB13(scuba_vlo), .DIB14(scuba_vlo), .DIB15(scuba_vlo), .DIB16(scuba_vlo), 
        .DIB17(scuba_vlo), .ADB0(RdAddress[0]), .ADB1(RdAddress[1]), .ADB2(RdAddress[2]), 
        .ADB3(RdAddress[3]), .ADB4(RdAddress[4]), .ADB5(RdAddress[5]), .ADB6(RdAddress[6]), 
        .ADB7(RdAddress[7]), .ADB8(RdAddress[8]), .ADB9(RdAddress[9]), .ADB10(RdAddress[10]), 
        .ADB11(RdAddress[11]), .ADB12(RdAddress[12]), .ADB13(RdAddress[13]), 
        .CEB(RdClockEn), .CLKB(RdClock), .OCEB(RdClockEn), .WEB(scuba_vlo), 
        .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), .RSTB(Reset), 
        .DOA0(), .DOA1(), .DOA2(), .DOA3(), .DOA4(), .DOA5(), .DOA6(), .DOA7(), 
        .DOA8(), .DOA9(), .DOA10(), .DOA11(), .DOA12(), .DOA13(), .DOA14(), 
        .DOA15(), .DOA16(), .DOA17(), .DOB0(Q[2]), .DOB1(), .DOB2(), .DOB3(), 
        .DOB4(), .DOB5(), .DOB6(), .DOB7(), .DOB8(), .DOB9(), .DOB10(), 
        .DOB11(), .DOB12(), .DOB13(), .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis RESETMODE="SYNC" */;



    // exemplar begin
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2 MEM_LPC_FILE pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2 MEM_INIT_FILE 
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2 RESETMODE SYNC
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1 MEM_LPC_FILE pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1 MEM_INIT_FILE 
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1 RESETMODE SYNC
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0 MEM_LPC_FILE pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0 MEM_INIT_FILE 
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0 RESETMODE SYNC
    // exemplar end

endmodule
/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.11.3.469 */
/* Module Version: 6.5 */
/* /usr/local/diamond/3.11_x64/ispfpga/bin/lin64/scuba -w -bus_exp 7 -bb -arch ep5c00 -type bram -wp 10 -rp 0011 -data_width 1 -num_rows 2 -rdata_width 1 -read_reg1 outreg -gsr DISABLED -memformat bin -cascade -1 -n pmi_ram_dpEbnonesadr112112115216de -pmi -lang verilog  */
/* Mon Mar 29 18:12:13 2021 */


`timescale 1 ns / 1 ps
module pmi_ram_dpEbnonesadr112112115216de (WrAddress, RdAddress, Data, 
    WE, RdClock, RdClockEn, Reset, WrClock, WrClockEn, Q)/* synthesis NGD_DRC_MASK=1 */;
    input wire [0:0] WrAddress;
    input wire [0:0] RdAddress;
    input wire [0:0] Data;
    input wire WE;
    input wire RdClock;
    input wire RdClockEn;
    input wire Reset;
    input wire WrClock;
    input wire WrClockEn;
    output wire [0:0] Q;

    wire scuba_vhi;
    wire scuba_vlo;

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.CSDECODE_B = "0b000" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.CSDECODE_A = "0b000" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.WRITEMODE_B = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.WRITEMODE_A = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.GSR = "DISABLED" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.REGMODE_B = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.REGMODE_A = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.DATA_WIDTH_B = 1 ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.DATA_WIDTH_A = 1 ;
    DP16KC pmi_ram_dpEbnonesadr112112115216de_0_0_0 (.DIA0(scuba_vlo), .DIA1(scuba_vlo), 
        .DIA2(scuba_vlo), .DIA3(scuba_vlo), .DIA4(scuba_vlo), .DIA5(scuba_vlo), 
        .DIA6(scuba_vlo), .DIA7(scuba_vlo), .DIA8(scuba_vlo), .DIA9(scuba_vlo), 
        .DIA10(scuba_vlo), .DIA11(Data[0]), .DIA12(scuba_vlo), .DIA13(scuba_vlo), 
        .DIA14(scuba_vlo), .DIA15(scuba_vlo), .DIA16(scuba_vlo), .DIA17(scuba_vlo), 
        .ADA0(WrAddress[0]), .ADA1(scuba_vlo), .ADA2(scuba_vlo), .ADA3(scuba_vlo), 
        .ADA4(scuba_vlo), .ADA5(scuba_vlo), .ADA6(scuba_vlo), .ADA7(scuba_vlo), 
        .ADA8(scuba_vlo), .ADA9(scuba_vlo), .ADA10(scuba_vlo), .ADA11(scuba_vlo), 
        .ADA12(scuba_vlo), .ADA13(scuba_vlo), .CEA(WrClockEn), .CLKA(WrClock), 
        .OCEA(WrClockEn), .WEA(WE), .CSA0(scuba_vlo), .CSA1(scuba_vlo), 
        .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), .DIB1(scuba_vlo), 
        .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), .DIB5(scuba_vlo), 
        .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), .DIB9(scuba_vlo), 
        .DIB10(scuba_vlo), .DIB11(scuba_vlo), .DIB12(scuba_vlo), .DIB13(scuba_vlo), 
        .DIB14(scuba_vlo), .DIB15(scuba_vlo), .DIB16(scuba_vlo), .DIB17(scuba_vlo), 
        .ADB0(RdAddress[0]), .ADB1(scuba_vlo), .ADB2(scuba_vlo), .ADB3(scuba_vlo), 
        .ADB4(scuba_vlo), .ADB5(scuba_vlo), .ADB6(scuba_vlo), .ADB7(scuba_vlo), 
        .ADB8(scuba_vlo), .ADB9(scuba_vlo), .ADB10(scuba_vlo), .ADB11(scuba_vlo), 
        .ADB12(scuba_vlo), .ADB13(scuba_vlo), .CEB(RdClockEn), .CLKB(RdClock), 
        .OCEB(RdClockEn), .WEB(scuba_vlo), .CSB0(scuba_vlo), .CSB1(scuba_vlo), 
        .CSB2(scuba_vlo), .RSTB(Reset), .DOA0(), .DOA1(), .DOA2(), .DOA3(), 
        .DOA4(), .DOA5(), .DOA6(), .DOA7(), .DOA8(), .DOA9(), .DOA10(), 
        .DOA11(), .DOA12(), .DOA13(), .DOA14(), .DOA15(), .DOA16(), .DOA17(), 
        .DOB0(Q[0]), .DOB1(), .DOB2(), .DOB3(), .DOB4(), .DOB5(), .DOB6(), 
        .DOB7(), .DOB8(), .DOB9(), .DOB10(), .DOB11(), .DOB12(), .DOB13(), 
        .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="pmi_ram_dpEbnonesadr112112115216de__PMIP__2__1__1B" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis RESETMODE="SYNC" */;



    // exemplar begin
    // exemplar attribute pmi_ram_dpEbnonesadr112112115216de_0_0_0 MEM_LPC_FILE pmi_ram_dpEbnonesadr112112115216de__PMIP__2__1__1B
    // exemplar attribute pmi_ram_dpEbnonesadr112112115216de_0_0_0 MEM_INIT_FILE 
    // exemplar attribute pmi_ram_dpEbnonesadr112112115216de_0_0_0 RESETMODE SYNC
    // exemplar end

endmodule
/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.11.3.469 */
/* Module Version: 6.5 */
/* /usr/local/diamond/3.11_x64/ispfpga/bin/lin64/scuba -w -bus_exp 7 -bb -arch ep5c00 -type bram -wp 10 -rp 0011 -data_width 3 -num_rows 16384 -rdata_width 3 -read_reg1 outreg -gsr DISABLED -memformat bin -cascade -1 -n pmi_ram_dpEbnonesadr314163843141638412067ab1 -pmi -lang verilog  */
/* Mon Mar 29 18:12:13 2021 */


`timescale 1 ns / 1 ps
module pmi_ram_dpEbnonesadr314163843141638412067ab1 (WrAddress, 
    RdAddress, Data, WE, RdClock, RdClockEn, Reset, WrClock, WrClockEn, 
    Q)/* synthesis NGD_DRC_MASK=1 */;
    input wire [13:0] WrAddress;
    input wire [13:0] RdAddress;
    input wire [2:0] Data;
    input wire WE;
    input wire RdClock;
    input wire RdClockEn;
    input wire Reset;
    input wire WrClock;
    input wire WrClockEn;
    output wire [2:0] Q;

    wire scuba_vhi;
    wire scuba_vlo;

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.CSDECODE_B = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.CSDECODE_A = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.WRITEMODE_B = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.WRITEMODE_A = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.GSR = "DISABLED" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.REGMODE_B = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.REGMODE_A = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.DATA_WIDTH_B = 1 ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.DATA_WIDTH_A = 1 ;
    DP16KC pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2 (.DIA0(scuba_vlo), 
        .DIA1(scuba_vlo), .DIA2(scuba_vlo), .DIA3(scuba_vlo), .DIA4(scuba_vlo), 
        .DIA5(scuba_vlo), .DIA6(scuba_vlo), .DIA7(scuba_vlo), .DIA8(scuba_vlo), 
        .DIA9(scuba_vlo), .DIA10(scuba_vlo), .DIA11(Data[0]), .DIA12(scuba_vlo), 
        .DIA13(scuba_vlo), .DIA14(scuba_vlo), .DIA15(scuba_vlo), .DIA16(scuba_vlo), 
        .DIA17(scuba_vlo), .ADA0(WrAddress[0]), .ADA1(WrAddress[1]), .ADA2(WrAddress[2]), 
        .ADA3(WrAddress[3]), .ADA4(WrAddress[4]), .ADA5(WrAddress[5]), .ADA6(WrAddress[6]), 
        .ADA7(WrAddress[7]), .ADA8(WrAddress[8]), .ADA9(WrAddress[9]), .ADA10(WrAddress[10]), 
        .ADA11(WrAddress[11]), .ADA12(WrAddress[12]), .ADA13(WrAddress[13]), 
        .CEA(WrClockEn), .CLKA(WrClock), .OCEA(WrClockEn), .WEA(WE), .CSA0(scuba_vlo), 
        .CSA1(scuba_vlo), .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), 
        .DIB1(scuba_vlo), .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), 
        .DIB5(scuba_vlo), .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), 
        .DIB9(scuba_vlo), .DIB10(scuba_vlo), .DIB11(scuba_vlo), .DIB12(scuba_vlo), 
        .DIB13(scuba_vlo), .DIB14(scuba_vlo), .DIB15(scuba_vlo), .DIB16(scuba_vlo), 
        .DIB17(scuba_vlo), .ADB0(RdAddress[0]), .ADB1(RdAddress[1]), .ADB2(RdAddress[2]), 
        .ADB3(RdAddress[3]), .ADB4(RdAddress[4]), .ADB5(RdAddress[5]), .ADB6(RdAddress[6]), 
        .ADB7(RdAddress[7]), .ADB8(RdAddress[8]), .ADB9(RdAddress[9]), .ADB10(RdAddress[10]), 
        .ADB11(RdAddress[11]), .ADB12(RdAddress[12]), .ADB13(RdAddress[13]), 
        .CEB(RdClockEn), .CLKB(RdClock), .OCEB(RdClockEn), .WEB(scuba_vlo), 
        .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), .RSTB(Reset), 
        .DOA0(), .DOA1(), .DOA2(), .DOA3(), .DOA4(), .DOA5(), .DOA6(), .DOA7(), 
        .DOA8(), .DOA9(), .DOA10(), .DOA11(), .DOA12(), .DOA13(), .DOA14(), 
        .DOA15(), .DOA16(), .DOA17(), .DOB0(Q[0]), .DOB1(), .DOB2(), .DOB3(), 
        .DOB4(), .DOB5(), .DOB6(), .DOB7(), .DOB8(), .DOB9(), .DOB10(), 
        .DOB11(), .DOB12(), .DOB13(), .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis RESETMODE="SYNC" */;

    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.CSDECODE_B = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.CSDECODE_A = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.WRITEMODE_B = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.WRITEMODE_A = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.GSR = "DISABLED" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.REGMODE_B = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.REGMODE_A = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.DATA_WIDTH_B = 1 ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.DATA_WIDTH_A = 1 ;
    DP16KC pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1 (.DIA0(scuba_vlo), 
        .DIA1(scuba_vlo), .DIA2(scuba_vlo), .DIA3(scuba_vlo), .DIA4(scuba_vlo), 
        .DIA5(scuba_vlo), .DIA6(scuba_vlo), .DIA7(scuba_vlo), .DIA8(scuba_vlo), 
        .DIA9(scuba_vlo), .DIA10(scuba_vlo), .DIA11(Data[1]), .DIA12(scuba_vlo), 
        .DIA13(scuba_vlo), .DIA14(scuba_vlo), .DIA15(scuba_vlo), .DIA16(scuba_vlo), 
        .DIA17(scuba_vlo), .ADA0(WrAddress[0]), .ADA1(WrAddress[1]), .ADA2(WrAddress[2]), 
        .ADA3(WrAddress[3]), .ADA4(WrAddress[4]), .ADA5(WrAddress[5]), .ADA6(WrAddress[6]), 
        .ADA7(WrAddress[7]), .ADA8(WrAddress[8]), .ADA9(WrAddress[9]), .ADA10(WrAddress[10]), 
        .ADA11(WrAddress[11]), .ADA12(WrAddress[12]), .ADA13(WrAddress[13]), 
        .CEA(WrClockEn), .CLKA(WrClock), .OCEA(WrClockEn), .WEA(WE), .CSA0(scuba_vlo), 
        .CSA1(scuba_vlo), .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), 
        .DIB1(scuba_vlo), .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), 
        .DIB5(scuba_vlo), .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), 
        .DIB9(scuba_vlo), .DIB10(scuba_vlo), .DIB11(scuba_vlo), .DIB12(scuba_vlo), 
        .DIB13(scuba_vlo), .DIB14(scuba_vlo), .DIB15(scuba_vlo), .DIB16(scuba_vlo), 
        .DIB17(scuba_vlo), .ADB0(RdAddress[0]), .ADB1(RdAddress[1]), .ADB2(RdAddress[2]), 
        .ADB3(RdAddress[3]), .ADB4(RdAddress[4]), .ADB5(RdAddress[5]), .ADB6(RdAddress[6]), 
        .ADB7(RdAddress[7]), .ADB8(RdAddress[8]), .ADB9(RdAddress[9]), .ADB10(RdAddress[10]), 
        .ADB11(RdAddress[11]), .ADB12(RdAddress[12]), .ADB13(RdAddress[13]), 
        .CEB(RdClockEn), .CLKB(RdClock), .OCEB(RdClockEn), .WEB(scuba_vlo), 
        .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), .RSTB(Reset), 
        .DOA0(), .DOA1(), .DOA2(), .DOA3(), .DOA4(), .DOA5(), .DOA6(), .DOA7(), 
        .DOA8(), .DOA9(), .DOA10(), .DOA11(), .DOA12(), .DOA13(), .DOA14(), 
        .DOA15(), .DOA16(), .DOA17(), .DOB0(Q[1]), .DOB1(), .DOB2(), .DOB3(), 
        .DOB4(), .DOB5(), .DOB6(), .DOB7(), .DOB8(), .DOB9(), .DOB10(), 
        .DOB11(), .DOB12(), .DOB13(), .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis RESETMODE="SYNC" */;

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.CSDECODE_B = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.CSDECODE_A = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.WRITEMODE_B = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.WRITEMODE_A = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.GSR = "DISABLED" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.REGMODE_B = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.REGMODE_A = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.DATA_WIDTH_B = 1 ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.DATA_WIDTH_A = 1 ;
    DP16KC pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0 (.DIA0(scuba_vlo), 
        .DIA1(scuba_vlo), .DIA2(scuba_vlo), .DIA3(scuba_vlo), .DIA4(scuba_vlo), 
        .DIA5(scuba_vlo), .DIA6(scuba_vlo), .DIA7(scuba_vlo), .DIA8(scuba_vlo), 
        .DIA9(scuba_vlo), .DIA10(scuba_vlo), .DIA11(Data[2]), .DIA12(scuba_vlo), 
        .DIA13(scuba_vlo), .DIA14(scuba_vlo), .DIA15(scuba_vlo), .DIA16(scuba_vlo), 
        .DIA17(scuba_vlo), .ADA0(WrAddress[0]), .ADA1(WrAddress[1]), .ADA2(WrAddress[2]), 
        .ADA3(WrAddress[3]), .ADA4(WrAddress[4]), .ADA5(WrAddress[5]), .ADA6(WrAddress[6]), 
        .ADA7(WrAddress[7]), .ADA8(WrAddress[8]), .ADA9(WrAddress[9]), .ADA10(WrAddress[10]), 
        .ADA11(WrAddress[11]), .ADA12(WrAddress[12]), .ADA13(WrAddress[13]), 
        .CEA(WrClockEn), .CLKA(WrClock), .OCEA(WrClockEn), .WEA(WE), .CSA0(scuba_vlo), 
        .CSA1(scuba_vlo), .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), 
        .DIB1(scuba_vlo), .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), 
        .DIB5(scuba_vlo), .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), 
        .DIB9(scuba_vlo), .DIB10(scuba_vlo), .DIB11(scuba_vlo), .DIB12(scuba_vlo), 
        .DIB13(scuba_vlo), .DIB14(scuba_vlo), .DIB15(scuba_vlo), .DIB16(scuba_vlo), 
        .DIB17(scuba_vlo), .ADB0(RdAddress[0]), .ADB1(RdAddress[1]), .ADB2(RdAddress[2]), 
        .ADB3(RdAddress[3]), .ADB4(RdAddress[4]), .ADB5(RdAddress[5]), .ADB6(RdAddress[6]), 
        .ADB7(RdAddress[7]), .ADB8(RdAddress[8]), .ADB9(RdAddress[9]), .ADB10(RdAddress[10]), 
        .ADB11(RdAddress[11]), .ADB12(RdAddress[12]), .ADB13(RdAddress[13]), 
        .CEB(RdClockEn), .CLKB(RdClock), .OCEB(RdClockEn), .WEB(scuba_vlo), 
        .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), .RSTB(Reset), 
        .DOA0(), .DOA1(), .DOA2(), .DOA3(), .DOA4(), .DOA5(), .DOA6(), .DOA7(), 
        .DOA8(), .DOA9(), .DOA10(), .DOA11(), .DOA12(), .DOA13(), .DOA14(), 
        .DOA15(), .DOA16(), .DOA17(), .DOB0(Q[2]), .DOB1(), .DOB2(), .DOB3(), 
        .DOB4(), .DOB5(), .DOB6(), .DOB7(), .DOB8(), .DOB9(), .DOB10(), 
        .DOB11(), .DOB12(), .DOB13(), .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis RESETMODE="SYNC" */;



    // exemplar begin
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2 MEM_LPC_FILE pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2 MEM_INIT_FILE 
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2 RESETMODE SYNC
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1 MEM_LPC_FILE pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1 MEM_INIT_FILE 
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1 RESETMODE SYNC
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0 MEM_LPC_FILE pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0 MEM_INIT_FILE 
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0 RESETMODE SYNC
    // exemplar end

endmodule
/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.11.3.469 */
/* Module Version: 6.5 */
/* /usr/local/diamond/3.11_x64/ispfpga/bin/lin64/scuba -w -bus_exp 7 -bb -arch ep5c00 -type bram -wp 10 -rp 0011 -data_width 1 -num_rows 2 -rdata_width 1 -read_reg1 outreg -gsr DISABLED -memformat bin -cascade -1 -n pmi_ram_dpEbnonesadr112112115216de -pmi -lang verilog  */
/* Mon Mar 29 18:17:36 2021 */


`timescale 1 ns / 1 ps
module pmi_ram_dpEbnonesadr112112115216de (WrAddress, RdAddress, Data, 
    WE, RdClock, RdClockEn, Reset, WrClock, WrClockEn, Q)/* synthesis NGD_DRC_MASK=1 */;
    input wire [0:0] WrAddress;
    input wire [0:0] RdAddress;
    input wire [0:0] Data;
    input wire WE;
    input wire RdClock;
    input wire RdClockEn;
    input wire Reset;
    input wire WrClock;
    input wire WrClockEn;
    output wire [0:0] Q;

    wire scuba_vhi;
    wire scuba_vlo;

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.CSDECODE_B = "0b000" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.CSDECODE_A = "0b000" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.WRITEMODE_B = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.WRITEMODE_A = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.GSR = "DISABLED" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.REGMODE_B = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.REGMODE_A = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.DATA_WIDTH_B = 1 ;
    defparam pmi_ram_dpEbnonesadr112112115216de_0_0_0.DATA_WIDTH_A = 1 ;
    DP16KC pmi_ram_dpEbnonesadr112112115216de_0_0_0 (.DIA0(scuba_vlo), .DIA1(scuba_vlo), 
        .DIA2(scuba_vlo), .DIA3(scuba_vlo), .DIA4(scuba_vlo), .DIA5(scuba_vlo), 
        .DIA6(scuba_vlo), .DIA7(scuba_vlo), .DIA8(scuba_vlo), .DIA9(scuba_vlo), 
        .DIA10(scuba_vlo), .DIA11(Data[0]), .DIA12(scuba_vlo), .DIA13(scuba_vlo), 
        .DIA14(scuba_vlo), .DIA15(scuba_vlo), .DIA16(scuba_vlo), .DIA17(scuba_vlo), 
        .ADA0(WrAddress[0]), .ADA1(scuba_vlo), .ADA2(scuba_vlo), .ADA3(scuba_vlo), 
        .ADA4(scuba_vlo), .ADA5(scuba_vlo), .ADA6(scuba_vlo), .ADA7(scuba_vlo), 
        .ADA8(scuba_vlo), .ADA9(scuba_vlo), .ADA10(scuba_vlo), .ADA11(scuba_vlo), 
        .ADA12(scuba_vlo), .ADA13(scuba_vlo), .CEA(WrClockEn), .CLKA(WrClock), 
        .OCEA(WrClockEn), .WEA(WE), .CSA0(scuba_vlo), .CSA1(scuba_vlo), 
        .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), .DIB1(scuba_vlo), 
        .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), .DIB5(scuba_vlo), 
        .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), .DIB9(scuba_vlo), 
        .DIB10(scuba_vlo), .DIB11(scuba_vlo), .DIB12(scuba_vlo), .DIB13(scuba_vlo), 
        .DIB14(scuba_vlo), .DIB15(scuba_vlo), .DIB16(scuba_vlo), .DIB17(scuba_vlo), 
        .ADB0(RdAddress[0]), .ADB1(scuba_vlo), .ADB2(scuba_vlo), .ADB3(scuba_vlo), 
        .ADB4(scuba_vlo), .ADB5(scuba_vlo), .ADB6(scuba_vlo), .ADB7(scuba_vlo), 
        .ADB8(scuba_vlo), .ADB9(scuba_vlo), .ADB10(scuba_vlo), .ADB11(scuba_vlo), 
        .ADB12(scuba_vlo), .ADB13(scuba_vlo), .CEB(RdClockEn), .CLKB(RdClock), 
        .OCEB(RdClockEn), .WEB(scuba_vlo), .CSB0(scuba_vlo), .CSB1(scuba_vlo), 
        .CSB2(scuba_vlo), .RSTB(Reset), .DOA0(), .DOA1(), .DOA2(), .DOA3(), 
        .DOA4(), .DOA5(), .DOA6(), .DOA7(), .DOA8(), .DOA9(), .DOA10(), 
        .DOA11(), .DOA12(), .DOA13(), .DOA14(), .DOA15(), .DOA16(), .DOA17(), 
        .DOB0(Q[0]), .DOB1(), .DOB2(), .DOB3(), .DOB4(), .DOB5(), .DOB6(), 
        .DOB7(), .DOB8(), .DOB9(), .DOB10(), .DOB11(), .DOB12(), .DOB13(), 
        .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="pmi_ram_dpEbnonesadr112112115216de__PMIP__2__1__1B" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis RESETMODE="SYNC" */;



    // exemplar begin
    // exemplar attribute pmi_ram_dpEbnonesadr112112115216de_0_0_0 MEM_LPC_FILE pmi_ram_dpEbnonesadr112112115216de__PMIP__2__1__1B
    // exemplar attribute pmi_ram_dpEbnonesadr112112115216de_0_0_0 MEM_INIT_FILE 
    // exemplar attribute pmi_ram_dpEbnonesadr112112115216de_0_0_0 RESETMODE SYNC
    // exemplar end

endmodule
/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.11.3.469 */
/* Module Version: 6.5 */
/* /usr/local/diamond/3.11_x64/ispfpga/bin/lin64/scuba -w -bus_exp 7 -bb -arch ep5c00 -type bram -wp 10 -rp 0011 -data_width 3 -num_rows 16384 -rdata_width 3 -read_reg1 outreg -gsr DISABLED -memformat bin -cascade -1 -n pmi_ram_dpEbnonesadr314163843141638412067ab1 -pmi -lang verilog  */
/* Mon Mar 29 18:17:35 2021 */


`timescale 1 ns / 1 ps
module pmi_ram_dpEbnonesadr314163843141638412067ab1 (WrAddress, 
    RdAddress, Data, WE, RdClock, RdClockEn, Reset, WrClock, WrClockEn, 
    Q)/* synthesis NGD_DRC_MASK=1 */;
    input wire [13:0] WrAddress;
    input wire [13:0] RdAddress;
    input wire [2:0] Data;
    input wire WE;
    input wire RdClock;
    input wire RdClockEn;
    input wire Reset;
    input wire WrClock;
    input wire WrClockEn;
    output wire [2:0] Q;

    wire scuba_vhi;
    wire scuba_vlo;

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.CSDECODE_B = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.CSDECODE_A = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.WRITEMODE_B = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.WRITEMODE_A = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.GSR = "DISABLED" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.REGMODE_B = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.REGMODE_A = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.DATA_WIDTH_B = 1 ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2.DATA_WIDTH_A = 1 ;
    DP16KC pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2 (.DIA0(scuba_vlo), 
        .DIA1(scuba_vlo), .DIA2(scuba_vlo), .DIA3(scuba_vlo), .DIA4(scuba_vlo), 
        .DIA5(scuba_vlo), .DIA6(scuba_vlo), .DIA7(scuba_vlo), .DIA8(scuba_vlo), 
        .DIA9(scuba_vlo), .DIA10(scuba_vlo), .DIA11(Data[0]), .DIA12(scuba_vlo), 
        .DIA13(scuba_vlo), .DIA14(scuba_vlo), .DIA15(scuba_vlo), .DIA16(scuba_vlo), 
        .DIA17(scuba_vlo), .ADA0(WrAddress[0]), .ADA1(WrAddress[1]), .ADA2(WrAddress[2]), 
        .ADA3(WrAddress[3]), .ADA4(WrAddress[4]), .ADA5(WrAddress[5]), .ADA6(WrAddress[6]), 
        .ADA7(WrAddress[7]), .ADA8(WrAddress[8]), .ADA9(WrAddress[9]), .ADA10(WrAddress[10]), 
        .ADA11(WrAddress[11]), .ADA12(WrAddress[12]), .ADA13(WrAddress[13]), 
        .CEA(WrClockEn), .CLKA(WrClock), .OCEA(WrClockEn), .WEA(WE), .CSA0(scuba_vlo), 
        .CSA1(scuba_vlo), .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), 
        .DIB1(scuba_vlo), .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), 
        .DIB5(scuba_vlo), .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), 
        .DIB9(scuba_vlo), .DIB10(scuba_vlo), .DIB11(scuba_vlo), .DIB12(scuba_vlo), 
        .DIB13(scuba_vlo), .DIB14(scuba_vlo), .DIB15(scuba_vlo), .DIB16(scuba_vlo), 
        .DIB17(scuba_vlo), .ADB0(RdAddress[0]), .ADB1(RdAddress[1]), .ADB2(RdAddress[2]), 
        .ADB3(RdAddress[3]), .ADB4(RdAddress[4]), .ADB5(RdAddress[5]), .ADB6(RdAddress[6]), 
        .ADB7(RdAddress[7]), .ADB8(RdAddress[8]), .ADB9(RdAddress[9]), .ADB10(RdAddress[10]), 
        .ADB11(RdAddress[11]), .ADB12(RdAddress[12]), .ADB13(RdAddress[13]), 
        .CEB(RdClockEn), .CLKB(RdClock), .OCEB(RdClockEn), .WEB(scuba_vlo), 
        .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), .RSTB(Reset), 
        .DOA0(), .DOA1(), .DOA2(), .DOA3(), .DOA4(), .DOA5(), .DOA6(), .DOA7(), 
        .DOA8(), .DOA9(), .DOA10(), .DOA11(), .DOA12(), .DOA13(), .DOA14(), 
        .DOA15(), .DOA16(), .DOA17(), .DOB0(Q[0]), .DOB1(), .DOB2(), .DOB3(), 
        .DOB4(), .DOB5(), .DOB6(), .DOB7(), .DOB8(), .DOB9(), .DOB10(), 
        .DOB11(), .DOB12(), .DOB13(), .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis RESETMODE="SYNC" */;

    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.CSDECODE_B = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.CSDECODE_A = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.WRITEMODE_B = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.WRITEMODE_A = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.GSR = "DISABLED" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.REGMODE_B = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.REGMODE_A = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.DATA_WIDTH_B = 1 ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1.DATA_WIDTH_A = 1 ;
    DP16KC pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1 (.DIA0(scuba_vlo), 
        .DIA1(scuba_vlo), .DIA2(scuba_vlo), .DIA3(scuba_vlo), .DIA4(scuba_vlo), 
        .DIA5(scuba_vlo), .DIA6(scuba_vlo), .DIA7(scuba_vlo), .DIA8(scuba_vlo), 
        .DIA9(scuba_vlo), .DIA10(scuba_vlo), .DIA11(Data[1]), .DIA12(scuba_vlo), 
        .DIA13(scuba_vlo), .DIA14(scuba_vlo), .DIA15(scuba_vlo), .DIA16(scuba_vlo), 
        .DIA17(scuba_vlo), .ADA0(WrAddress[0]), .ADA1(WrAddress[1]), .ADA2(WrAddress[2]), 
        .ADA3(WrAddress[3]), .ADA4(WrAddress[4]), .ADA5(WrAddress[5]), .ADA6(WrAddress[6]), 
        .ADA7(WrAddress[7]), .ADA8(WrAddress[8]), .ADA9(WrAddress[9]), .ADA10(WrAddress[10]), 
        .ADA11(WrAddress[11]), .ADA12(WrAddress[12]), .ADA13(WrAddress[13]), 
        .CEA(WrClockEn), .CLKA(WrClock), .OCEA(WrClockEn), .WEA(WE), .CSA0(scuba_vlo), 
        .CSA1(scuba_vlo), .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), 
        .DIB1(scuba_vlo), .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), 
        .DIB5(scuba_vlo), .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), 
        .DIB9(scuba_vlo), .DIB10(scuba_vlo), .DIB11(scuba_vlo), .DIB12(scuba_vlo), 
        .DIB13(scuba_vlo), .DIB14(scuba_vlo), .DIB15(scuba_vlo), .DIB16(scuba_vlo), 
        .DIB17(scuba_vlo), .ADB0(RdAddress[0]), .ADB1(RdAddress[1]), .ADB2(RdAddress[2]), 
        .ADB3(RdAddress[3]), .ADB4(RdAddress[4]), .ADB5(RdAddress[5]), .ADB6(RdAddress[6]), 
        .ADB7(RdAddress[7]), .ADB8(RdAddress[8]), .ADB9(RdAddress[9]), .ADB10(RdAddress[10]), 
        .ADB11(RdAddress[11]), .ADB12(RdAddress[12]), .ADB13(RdAddress[13]), 
        .CEB(RdClockEn), .CLKB(RdClock), .OCEB(RdClockEn), .WEB(scuba_vlo), 
        .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), .RSTB(Reset), 
        .DOA0(), .DOA1(), .DOA2(), .DOA3(), .DOA4(), .DOA5(), .DOA6(), .DOA7(), 
        .DOA8(), .DOA9(), .DOA10(), .DOA11(), .DOA12(), .DOA13(), .DOA14(), 
        .DOA15(), .DOA16(), .DOA17(), .DOB0(Q[1]), .DOB1(), .DOB2(), .DOB3(), 
        .DOB4(), .DOB5(), .DOB6(), .DOB7(), .DOB8(), .DOB9(), .DOB10(), 
        .DOB11(), .DOB12(), .DOB13(), .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis RESETMODE="SYNC" */;

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.CSDECODE_B = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.CSDECODE_A = "0b000" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.WRITEMODE_B = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.WRITEMODE_A = "NORMAL" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.GSR = "DISABLED" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.REGMODE_B = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.REGMODE_A = "OUTREG" ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.DATA_WIDTH_B = 1 ;
    defparam pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0.DATA_WIDTH_A = 1 ;
    DP16KC pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0 (.DIA0(scuba_vlo), 
        .DIA1(scuba_vlo), .DIA2(scuba_vlo), .DIA3(scuba_vlo), .DIA4(scuba_vlo), 
        .DIA5(scuba_vlo), .DIA6(scuba_vlo), .DIA7(scuba_vlo), .DIA8(scuba_vlo), 
        .DIA9(scuba_vlo), .DIA10(scuba_vlo), .DIA11(Data[2]), .DIA12(scuba_vlo), 
        .DIA13(scuba_vlo), .DIA14(scuba_vlo), .DIA15(scuba_vlo), .DIA16(scuba_vlo), 
        .DIA17(scuba_vlo), .ADA0(WrAddress[0]), .ADA1(WrAddress[1]), .ADA2(WrAddress[2]), 
        .ADA3(WrAddress[3]), .ADA4(WrAddress[4]), .ADA5(WrAddress[5]), .ADA6(WrAddress[6]), 
        .ADA7(WrAddress[7]), .ADA8(WrAddress[8]), .ADA9(WrAddress[9]), .ADA10(WrAddress[10]), 
        .ADA11(WrAddress[11]), .ADA12(WrAddress[12]), .ADA13(WrAddress[13]), 
        .CEA(WrClockEn), .CLKA(WrClock), .OCEA(WrClockEn), .WEA(WE), .CSA0(scuba_vlo), 
        .CSA1(scuba_vlo), .CSA2(scuba_vlo), .RSTA(Reset), .DIB0(scuba_vlo), 
        .DIB1(scuba_vlo), .DIB2(scuba_vlo), .DIB3(scuba_vlo), .DIB4(scuba_vlo), 
        .DIB5(scuba_vlo), .DIB6(scuba_vlo), .DIB7(scuba_vlo), .DIB8(scuba_vlo), 
        .DIB9(scuba_vlo), .DIB10(scuba_vlo), .DIB11(scuba_vlo), .DIB12(scuba_vlo), 
        .DIB13(scuba_vlo), .DIB14(scuba_vlo), .DIB15(scuba_vlo), .DIB16(scuba_vlo), 
        .DIB17(scuba_vlo), .ADB0(RdAddress[0]), .ADB1(RdAddress[1]), .ADB2(RdAddress[2]), 
        .ADB3(RdAddress[3]), .ADB4(RdAddress[4]), .ADB5(RdAddress[5]), .ADB6(RdAddress[6]), 
        .ADB7(RdAddress[7]), .ADB8(RdAddress[8]), .ADB9(RdAddress[9]), .ADB10(RdAddress[10]), 
        .ADB11(RdAddress[11]), .ADB12(RdAddress[12]), .ADB13(RdAddress[13]), 
        .CEB(RdClockEn), .CLKB(RdClock), .OCEB(RdClockEn), .WEB(scuba_vlo), 
        .CSB0(scuba_vlo), .CSB1(scuba_vlo), .CSB2(scuba_vlo), .RSTB(Reset), 
        .DOA0(), .DOA1(), .DOA2(), .DOA3(), .DOA4(), .DOA5(), .DOA6(), .DOA7(), 
        .DOA8(), .DOA9(), .DOA10(), .DOA11(), .DOA12(), .DOA13(), .DOA14(), 
        .DOA15(), .DOA16(), .DOA17(), .DOB0(Q[2]), .DOB1(), .DOB2(), .DOB3(), 
        .DOB4(), .DOB5(), .DOB6(), .DOB7(), .DOB8(), .DOB9(), .DOB10(), 
        .DOB11(), .DOB12(), .DOB13(), .DOB14(), .DOB15(), .DOB16(), .DOB17())
             /* synthesis MEM_LPC_FILE="pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B" */
             /* synthesis MEM_INIT_FILE="" */
             /* synthesis RESETMODE="SYNC" */;



    // exemplar begin
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2 MEM_LPC_FILE pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2 MEM_INIT_FILE 
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_0_2 RESETMODE SYNC
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1 MEM_LPC_FILE pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1 MEM_INIT_FILE 
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_1_1 RESETMODE SYNC
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0 MEM_LPC_FILE pmi_ram_dpEbnonesadr314163843141638412067ab1__PMIP__16384__3__3B
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0 MEM_INIT_FILE 
    // exemplar attribute pmi_ram_dpEbnonesadr314163843141638412067ab1_0_2_0 RESETMODE SYNC
    // exemplar end

endmodule
