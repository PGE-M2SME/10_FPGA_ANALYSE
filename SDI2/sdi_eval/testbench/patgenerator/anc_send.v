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
//  File:              anc_send.v
//  Title:             anc_send
//  Description:       This module generates the ancilary data packet
//                     of payload identification shown below:  
//
//                     Ancillary_Data_Flag(ADF): 10'h000,10'h3FF,10'h3FF,
//                     Data_ID(DID)            : 10'h041,
//                     Secondary Data_ID(SDID) : 10'h001,
//                     Data_Count(DC)          : 10'h004,
//                     Up to 255 User_Data_Words(UDW),
//                     Check_Sum (CS)
//
//                     The user data words (SDI video payload
//                     identifier) between the DC and CS contains the
//                     information of Sample Rate, Pixel Depth,
//                     Sample Structure, scanning progressive,
//                     the number of total active  line and so on.
//
// --------------------------------------------------------------------
// Author : Guolin W., Cloud Y.
// $Revision: 1.3 $
// --------------------------------------------------------------------
`timescale 1ns/100ps  

`define BYTE1_SD_259M_SDI               8'h81
`define BYTE1_HD_274M_292M              8'h85
`define BYTE1_HD_296M_292M              8'h84
`define BYTE1_HD_1035_1485M             8'h04
`define BYTE1_HD_1080_1485M             8'h85
`define BYTE1_TD_1280                   8'h88
`define BYTE1_TD_1920                   8'h89
`define BYTE1_SMPTE_372_DUAL_LINK       8'h8A      
`define BYTE1_2X720_LINE                8'h8B
`define BYTE1_2X1080_LINE               8'h8C                

//BYTE2 DEFINE
`define BYTE2_PROGRESSIVE               1'b1
`define BYTE2_INTERLACE                 1'b0

`define BYTE2_PICTURE_RATE_24_1001      4'h2
`define BYTE2_PICTURE_RATE_24           4'h3
`define BYTE2_PICTURE_RATE_25           4'h5
`define BYTE2_PICTURE_RATE_30_1001      4'h6
`define BYTE2_PICTURE_RATE_30           4'h7
`define BYTE2_PICTURE_RATE_50           4'h9
`define BYTE2_PICTURE_RATE_60_1001      4'hA
`define BYTE2_PICTURE_RATE_60           4'hB
//BYTE3 DEFINE
`define BYTE3_RATIO_4_3                 1'b0
`define BYTE3_RATIO_16_9                1'b1

`define BYTE3_SAMPLE_STRUCT_422_YCbCr   4'h0
`define BYTE3_SAMPLE_STRUCT_444_YCbCr   4'h1
`define BYTE3_SAMPLE_STRUCT_4224_YCbCrA 4'h4 
`define BYTE3_SAMPLE_STRUCT_4444_YCbCrA 4'h5
//BYTE4 DEFINE
`define BYTE4_SINGLE_LINK_CH1           2'h0

`define BYTE4_DYNAMIC_RANGE_100         2'h0

`define BYTE4_BIT_DEPTH_10              2'h1
`define BYTE4_BIT_DEPTH_12              2'h2


module anc_send(
	//system
	input  wire       rstn,
	input  wire       clk,
	//req
	input  wire       lb_lan_in,
	input  wire       sdi_3g_hd_dl,
	input  wire [4:0] format_sel,
	input  wire       pattern_m_factor,  
	input  wire       req,
	output wire[31:0] vpid_in,
	output reg [9:0]  anc_data,
	output reg [9:0]  anc_data_b
		);

reg [7:0] data[3:0];
reg p_i,p_i_trans,ratio;
reg [1:0] dynamic_range,bit_depth,link;
reg [3:0] picture_rate,sample_structure;
reg [7:0] format;
reg       state_cur;
reg       clk_en;
reg [3:0] cnt;
reg [7:0] byte_odd,byte_odd_b;
reg [8:0] check_sum,check_sum_b;
reg [9:0] anc_data_buf, anc_data_b_buf;

wire send_finish;
wire byte_odd_check,byte_odd_check_b;
wire [8:0] sum,sum_b;

assign send_finish = (cnt == 4'd10);
assign byte_odd_check = byte_odd[7]^byte_odd[6]^byte_odd[5]^byte_odd[4]^byte_odd[3]^byte_odd[2]^byte_odd[1]^byte_odd[0];
assign byte_odd_check_b = byte_odd_b[7]^byte_odd_b[6]^byte_odd_b[5]^byte_odd_b[4]^byte_odd_b[3]^byte_odd_b[2]^byte_odd_b[1]^byte_odd_b[0];

always @(posedge clk or negedge rstn)
begin
   if(rstn == 1'b0)
      begin
          p_i                  <= `BYTE2_PROGRESSIVE;
          p_i_trans            <= `BYTE2_PROGRESSIVE;
          ratio                <= `BYTE3_RATIO_16_9;
          dynamic_range        <= `BYTE4_DYNAMIC_RANGE_100;
          bit_depth            <= `BYTE4_BIT_DEPTH_10;
          link                 <= `BYTE4_SINGLE_LINK_CH1;
          picture_rate         <= `BYTE2_PICTURE_RATE_30;
          sample_structure     <= `BYTE3_SAMPLE_STRUCT_422_YCbCr;
          format               <= `BYTE1_HD_1035_1485M;
      end
   else
   begin
      case(format_sel)
         5'd0:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   if(lb_lan_in)
         	      p_i_trans    <= `BYTE2_INTERLACE;          
         	   else
         	      p_i_trans    <= `BYTE2_PROGRESSIVE;  
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;  
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_60_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_60;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;
               if(lb_lan_in)
                  format       <= `BYTE1_SMPTE_372_DUAL_LINK;
               else            
                  format       <= `BYTE1_TD_1920;      
            end
         5'd1:
            begin
               p_i             <= `BYTE2_PROGRESSIVE;  
               if(lb_lan_in)                              
                  p_i_trans    <= `BYTE2_INTERLACE;       
               else                                       
                  p_i_trans    <= `BYTE2_PROGRESSIVE;     
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               picture_rate    <= `BYTE2_PICTURE_RATE_50;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;
               if(lb_lan_in)
                  format       <= `BYTE1_SMPTE_372_DUAL_LINK;   
               else                                             
                  format       <= `BYTE1_TD_1920;               
            end
         5'd2: 
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;    
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_60_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_60;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_4444_YCbCrA;
               format          <= `BYTE1_TD_1280;
            end
         5'd3:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;    
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               picture_rate    <= `BYTE2_PICTURE_RATE_50;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_4444_YCbCrA;
               format          <= `BYTE1_TD_1280;
            end
         5'd4:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;    
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_30_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_30;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_4444_YCbCrA;
               if(lb_lan_in)                                       
                  format       <= `BYTE1_SMPTE_372_DUAL_LINK;      
               else                                                
                  format       <= `BYTE1_TD_1920;                  
            end
         5'd5:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;    
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_30_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_30;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_4444_YCbCrA;
               format          <= `BYTE1_TD_1280;
            end
         5'd6:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;    
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               picture_rate    <= `BYTE2_PICTURE_RATE_25;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_4444_YCbCrA;
               if(lb_lan_in)                                        
                  format       <= `BYTE1_SMPTE_372_DUAL_LINK;       
               else                                                 
                  format       <= `BYTE1_TD_1920;                   
            end
         5'd7:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;    
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               picture_rate    <= `BYTE2_PICTURE_RATE_25;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_4444_YCbCrA;
               format          <= `BYTE1_TD_1280;
            end
         5'd8:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;    
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_24_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_24;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_4444_YCbCrA;
               if(lb_lan_in)                                            
                  format       <= `BYTE1_SMPTE_372_DUAL_LINK;           
               else                                                     
                  format       <= `BYTE1_TD_1920;                       
            end
         5'd9:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;    
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_24_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_24;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_4444_YCbCrA;
               format          <= `BYTE1_TD_1280;
            end
         5'd10:
            begin
         	   p_i             <= `BYTE2_INTERLACE;
         	   p_i_trans       <= `BYTE2_INTERLACE;    
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_60_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_60;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_4444_YCbCrA;
               if(lb_lan_in)                                    
                  format       <= `BYTE1_SMPTE_372_DUAL_LINK;   
               else                                             
                  format       <= `BYTE1_TD_1920;               
            end
         5'd11:
            begin
         	   p_i             <= `BYTE2_INTERLACE; 
         	   p_i_trans       <= `BYTE2_INTERLACE;   
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               picture_rate    <= `BYTE2_PICTURE_RATE_50; 
               sample_structure<= `BYTE3_SAMPLE_STRUCT_4444_YCbCrA;              
               if(lb_lan_in)                                             
                  format       <= `BYTE1_SMPTE_372_DUAL_LINK;            
               else                                                      
                  format       <= `BYTE1_TD_1920;                        
            end
         5'd12:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;    
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_12;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_30_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_30;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_444_YCbCr;         
               if(lb_lan_in)                                       
                  format       <= `BYTE1_SMPTE_372_DUAL_LINK;      
               else                                                
                  format       <= `BYTE1_TD_1920;                  
            end
         5'd13:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;    
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_12;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               picture_rate    <= `BYTE2_PICTURE_RATE_25;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_444_YCbCr;         
               if(lb_lan_in)                                    
                  format       <= `BYTE1_SMPTE_372_DUAL_LINK;   
               else                                             
                  format       <= `BYTE1_TD_1920;               
            end
         5'd14:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;    
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_12;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_24_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_24;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_444_YCbCr;         
               if(lb_lan_in)                                      
                  format       <= `BYTE1_SMPTE_372_DUAL_LINK;     
               else                                               
                  format       <= `BYTE1_TD_1920;                 
            end
         5'd15:
            begin
         	   p_i             <= `BYTE2_INTERLACE;
         	   p_i_trans       <= `BYTE2_INTERLACE;   
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_12;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_60_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_60;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_444_YCbCr;  
               if(lb_lan_in)                                    
                  format       <= `BYTE1_SMPTE_372_DUAL_LINK;   
               else                                             
                  format       <= `BYTE1_TD_1920;               
            end
         5'd16:
            begin
         	   p_i             <= `BYTE2_INTERLACE;
         	   p_i_trans       <= `BYTE2_INTERLACE;   
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_12;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               picture_rate    <= `BYTE2_PICTURE_RATE_50;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_444_YCbCr;
               if(lb_lan_in)                                       
                  format       <= `BYTE1_SMPTE_372_DUAL_LINK;      
               else                                                
                  format       <= `BYTE1_TD_1920;                  
            end
         5'd17:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;    
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_12;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_30_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_30;
               if(lb_lan_in)                                    
                  sample_structure<= `BYTE3_SAMPLE_STRUCT_4224_YCbCrA;     
               else                                             
                  sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;     
               if(lb_lan_in)                                              
                  format       <= `BYTE1_SMPTE_372_DUAL_LINK;             
               else                                                       
                  format       <= `BYTE1_TD_1920;                         
            end
         5'd18:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;    
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_12;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               picture_rate    <= `BYTE2_PICTURE_RATE_25;
               if(lb_lan_in)                                    
                  sample_structure<= `BYTE3_SAMPLE_STRUCT_4224_YCbCrA;     
               else                                             
                  sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;    
               if(lb_lan_in)                                             
                  format       <= `BYTE1_SMPTE_372_DUAL_LINK;            
               else                                                      
                  format       <= `BYTE1_TD_1920;                        
            end
         5'd19:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;    
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_12;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_24_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_24;
               if(lb_lan_in)                                    
                  sample_structure<= `BYTE3_SAMPLE_STRUCT_4224_YCbCrA;     
               else                                             
                  sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;    
               if(lb_lan_in)                                     
                  format       <= `BYTE1_SMPTE_372_DUAL_LINK;    
               else                                              
                  format       <= `BYTE1_TD_1920;                
            end
         5'd20:
            begin
         	   p_i             <= `BYTE2_INTERLACE;
         	   p_i_trans       <= `BYTE2_INTERLACE;   
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_12;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_60_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_60;
               if(lb_lan_in)                                    
                  sample_structure<= `BYTE3_SAMPLE_STRUCT_4224_YCbCrA;     
               else                                             
                  sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;    
               if(lb_lan_in)                                            
                  format       <= `BYTE1_SMPTE_372_DUAL_LINK;           
               else                                                     
                  format       <= `BYTE1_TD_1920;                       
            end
         5'd21:
            begin
         	   p_i             <= `BYTE2_INTERLACE;
         	   p_i_trans       <= `BYTE2_INTERLACE;   
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_12;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               picture_rate    <= `BYTE2_PICTURE_RATE_50;
               if(lb_lan_in)                                    
                  sample_structure<= `BYTE3_SAMPLE_STRUCT_4224_YCbCrA;     
               else                                             
                  sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;    
               if(lb_lan_in)                                          
                  format       <= `BYTE1_SMPTE_372_DUAL_LINK;         
               else                                                   
                  format       <= `BYTE1_TD_1920;                     
            end
         5'd22:
            begin
         	   p_i             <= `BYTE2_INTERLACE;
         	   p_i_trans       <= `BYTE2_INTERLACE;   
         	   ratio           <= `BYTE3_RATIO_4_3; 
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_60_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_60;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;
               if(lb_lan_in)                                           
                  format       <= `BYTE1_2X1080_LINE;          
               else                                                    
                  format       <= `BYTE1_HD_1035_1485M;
            end
         5'd23:
            begin
         	   p_i             <= `BYTE2_INTERLACE;
         	   p_i_trans       <= `BYTE2_INTERLACE;   
               ratio           <= `BYTE3_RATIO_4_3; 
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               picture_rate    <= `BYTE2_PICTURE_RATE_50;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;
               if(lb_lan_in)                                 
                  format       <= `BYTE1_2X1080_LINE;        
               else                                          
                  format       <= `BYTE1_HD_1080_1485M;      
            end
         5'd24:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE; 
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;   
               ratio           <= `BYTE3_RATIO_4_3; 
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_30_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_30;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;
               if(lb_lan_in)                                 
                  format       <= `BYTE1_2X1080_LINE;        
               else                                          
                  format       <= `BYTE1_HD_274M_292M;      
            end
         5'd25:
            begin
         	   p_i             <= `BYTE2_INTERLACE;
         	   p_i_trans       <= `BYTE2_INTERLACE;   
               ratio           <= `BYTE3_RATIO_4_3; 
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_60_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_60;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;
               if(lb_lan_in)                                  
                  format       <= `BYTE1_2X1080_LINE;         
               else                                           
                  format       <= `BYTE1_HD_274M_292M;        
            end
         5'd26:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;   
               ratio           <= `BYTE3_RATIO_4_3; 
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               picture_rate    <= `BYTE2_PICTURE_RATE_25;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;
               if(lb_lan_in)                             
                  format       <= `BYTE1_2X1080_LINE;    
               else                                      
                  format       <= `BYTE1_HD_274M_292M;   
            end
         5'd27:
            begin
         	   p_i             <= `BYTE2_INTERLACE;
         	   p_i_trans       <= `BYTE2_INTERLACE;   
               ratio           <= `BYTE3_RATIO_4_3; 
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               picture_rate    <= `BYTE2_PICTURE_RATE_50;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;
               if(lb_lan_in)                                 
                  format       <= `BYTE1_2X1080_LINE;        
               else                                          
                  format       <= `BYTE1_HD_274M_292M;       
            end
         5'd28:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;   
               ratio           <= `BYTE3_RATIO_4_3; 
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_24_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_24;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;
               if(lb_lan_in)                                
                  format       <= `BYTE1_2X1080_LINE;       
               else                                         
                  format       <= `BYTE1_HD_274M_292M;      
            end
         5'd29:
            begin
         	   p_i             <= `BYTE2_PROGRESSIVE;
         	   p_i_trans       <= `BYTE2_PROGRESSIVE;   
               ratio           <= `BYTE3_RATIO_4_3; 
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               if (pattern_m_factor)  
                  picture_rate <= `BYTE2_PICTURE_RATE_60_1001;
               else
                  picture_rate <= `BYTE2_PICTURE_RATE_60;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;
               if(lb_lan_in)                                 
                  format       <= `BYTE1_2X720_LINE;          
               else                                            
                  format       <= `BYTE1_HD_296M_292M;         
            end
         5'd30:
            begin
         	   p_i             <= `BYTE2_INTERLACE;
         	   p_i_trans       <= `BYTE2_INTERLACE;   
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               picture_rate    <= `BYTE2_PICTURE_RATE_60_1001;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;
               format          <= `BYTE1_SD_259M_SDI;
            end
         5'd31:
            begin
         	   p_i             <= `BYTE2_INTERLACE;
         	   p_i_trans       <= `BYTE2_INTERLACE;   
               ratio           <= `BYTE3_RATIO_4_3;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               picture_rate    <= `BYTE2_PICTURE_RATE_50;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;
               format          <= `BYTE1_SD_259M_SDI;
            end
         
         default:
            begin
               p_i             <= `BYTE2_PROGRESSIVE;
               p_i_trans       <= `BYTE2_PROGRESSIVE;   
               ratio           <= `BYTE3_RATIO_16_9;
               dynamic_range   <= `BYTE4_DYNAMIC_RANGE_100;
               bit_depth       <= `BYTE4_BIT_DEPTH_10;
               link            <= `BYTE4_SINGLE_LINK_CH1;
               picture_rate    <= `BYTE2_PICTURE_RATE_60;
               sample_structure<= `BYTE3_SAMPLE_STRUCT_422_YCbCr;
               format          <= `BYTE1_HD_1080_1485M;
            end
      endcase
   end
end
//============state machine===================
//state machine
always @(posedge clk or negedge rstn)
begin
   if(rstn == 1'b0) begin
      state_cur <= 1'b0;
      clk_en    <= 1'b1;
   end
   else begin
      if(state_cur & lb_lan_in) 
         clk_en <= ~clk_en;
      else
         clk_en <= 1'b1;
      if(req == 1'b1)
         state_cur <= 1'b1;
      else if((send_finish == 1'b1) & clk_en)
         state_cur <= 1'b0;
   end
end

//===================================================
//cnt
always @(posedge clk or negedge rstn)
begin
   if(rstn == 1'b0)
      cnt <= 0;
   else if(clk_en) begin
      if(state_cur) 
         cnt <= cnt + 1;
      else
         cnt <= 0;
   end
end

//check_sum
assign sum = check_sum + {byte_odd_check,byte_odd};
assign sum_b = check_sum_b + {byte_odd_check_b,byte_odd_b};
always @(posedge clk or negedge rstn)
begin
   if(rstn == 1'b0) 
      check_sum <= 0;
   else if(clk_en) begin
      if(state_cur)
         check_sum <= sum;  
      else                 
         check_sum <= 0;   
   end
end

always @(posedge clk or negedge rstn)
begin
   if(rstn == 1'b0) 
      check_sum_b <= 0;
   else if(clk_en) begin
      if(state_cur)
         check_sum_b <= sum_b;  
      else                 
         check_sum_b <= 0;   
   end
end

//data
assign vpid_in = {data[3],data[2],data[1],data[0]};
always @(posedge clk or negedge rstn)
begin
   if(rstn == 1'b0) begin
      data[0] <= 0;
      data[1] <= 0;
      data[2] <= 0;
      data[3] <= 0;
   end
   else if(~state_cur) begin
      data[0] <= format;
      data[1] <= {p_i_trans,p_i,2'b0,picture_rate};
      data[2] <= {ratio,3'b0,sample_structure};
      data[3] <= {link,1'b0,dynamic_range,1'b0,bit_depth};
   end
end

//byte_odd
always @(posedge clk or negedge rstn)
begin
   if(rstn == 1'b0) begin
      byte_odd <= 0;
   end
   else if (clk_en) begin
      case(cnt)
         4'd2    : byte_odd <= 8'h41;  
         4'd3    : byte_odd <= 8'h01;    
         4'd4    : byte_odd <= 8'h04; 
         4'd5    : byte_odd <= data[0];    
         4'd6    : byte_odd <= data[1];  
         4'd7    : byte_odd <= data[2];      
         4'd8    : byte_odd <= data[3];   
         4'd9    : byte_odd <= sum;     
         default : byte_odd <= 0;         
      endcase
   end
end

//byte_odd
always @(posedge clk or negedge rstn)
begin
   if(rstn == 1'b0) begin
      byte_odd_b <= 0;
   end
   else if (clk_en) begin
      case(cnt)
         4'd2    : byte_odd_b <= 8'h41;  
         4'd3    : byte_odd_b <= 8'h01;    
         4'd4    : byte_odd_b <= 8'h04; 
         4'd5    : byte_odd_b <= data[0];    
         4'd6    : byte_odd_b <= data[1];  
         4'd7    : byte_odd_b <= data[2];      
         4'd8    : 
            if(lb_lan_in)
               byte_odd_b <= {2'b01,data[3][5:0]};
            else
               byte_odd_b <= data[3];         
         4'd9    : byte_odd_b <= sum_b;     
         default : byte_odd_b <= 0;         
      endcase
   end
end
//anc_data
always @(posedge clk or negedge rstn)
begin
   if(rstn == 1'b0)
      anc_data_buf <= 0;
   else if(state_cur) begin
      if(clk_en) begin
         case(cnt)
           4'd0    : anc_data_buf <= 10'h000;  
   	       4'd1    : anc_data_buf <= 10'h3ff;       
   	       4'd2    : anc_data_buf <= 10'h3ff;  
   	       4'd10   : anc_data_buf <= {!check_sum[8],check_sum};  
   	       default : anc_data_buf <= {!byte_odd_check,byte_odd_check,byte_odd};   
         endcase
      end
      else
         anc_data_buf <= 10'h200;
   end
   else
      anc_data_buf <= 10'h200;  
end


always @(posedge clk or negedge rstn)
begin
   if(rstn == 1'b0)
      anc_data <= 0;
   else if(lb_lan_in & ~sdi_3g_hd_dl)
      anc_data <= anc_data_buf;
   else if(state_cur) begin
      if(clk_en) begin
         case(cnt)
           4'd0    : anc_data <= 10'h000;  
   	       4'd1    : anc_data <= 10'h3ff;       
   	       4'd2    : anc_data <= 10'h3ff;  
   	       4'd10   : anc_data <= {!check_sum[8],check_sum};  
   	       default : anc_data <= {!byte_odd_check,byte_odd_check,byte_odd};   
         endcase
      end
      else
         anc_data <= 10'h200;
   end
   else
      anc_data <= 10'h200;  
end

always @(posedge clk or negedge rstn)
begin
   if(rstn == 1'b0)
      anc_data_b_buf <= 0;
   else if(state_cur) begin
      if(clk_en) begin
         case(cnt)
           4'd0    : anc_data_b_buf <= 10'h000;  
   	       4'd1    : anc_data_b_buf <= 10'h3ff;       
   	       4'd2    : anc_data_b_buf <= 10'h3ff;  
   	       4'd10   : anc_data_b_buf <= {!check_sum_b[8],check_sum_b};  
   	       default : anc_data_b_buf <= {!byte_odd_check_b,byte_odd_check_b,byte_odd_b};   
         endcase
      end
      else
         anc_data_b_buf <= 10'h200;
   end
   else
      anc_data_b_buf <= 10'h200;  
end

always @(posedge clk or negedge rstn)
begin
   if(rstn == 1'b0)
      anc_data_b <= 0;
   else if(lb_lan_in & ~sdi_3g_hd_dl)
      anc_data_b <= anc_data_b_buf;
   else if(state_cur) begin
      if(clk_en) begin
         case(cnt)
           4'd0    : anc_data_b <= 10'h000;  
   	       4'd1    : anc_data_b <= 10'h3ff;       
   	       4'd2    : anc_data_b <= 10'h3ff;  
   	       4'd10   : anc_data_b <= {!check_sum_b[8],check_sum_b};  
   	       default : anc_data_b <= {!byte_odd_check_b,byte_odd_check_b,byte_odd_b};   
         endcase
      end
      else
         anc_data_b <= 10'h200;
   end
   else
      anc_data_b <= 10'h200;  
end

endmodule
