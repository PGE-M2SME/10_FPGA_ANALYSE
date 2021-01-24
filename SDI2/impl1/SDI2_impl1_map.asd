[ActiveSupport MAP]
Device = LFE3-70E;
Package = FPBGA672;
Performance = 8;
LUTS_avail = 66528;
LUTS_used = 693;
FF_avail = 50276;
FF_used = 357;
INPUT_LVCMOS25 = 1;
OUTPUT_LVCMOS25 = 2;
IO_avail = 380;
IO_used = 3;
Serdes_avail = 2;
Serdes_used = 1;
PLL_avail = 10;
PLL_used = 1;
EBR_avail = 240;
EBR_used = 0;
;
; start of DSP statistics
MULT18X18C = 0;
MULT9X9C = 0;
ALU54A = 0;
ALU24A = 0;
DSP_MULT_avail = 256;
DSP_MULT_used = 0;
DSP_ALU_avail = 128;
DSP_ALU_used = 0;
; end of DSP statistics
;
; Begin PLL Section
Instance_Name = PLL1/PLLInst_0;
Type = EHXPLLF;
Output_Clock(P)_Actual_Frequency = 148.4375;
CLKOP_BYPASS = DISABLED;
CLKOS_BYPASS = DISABLED;
CLKOK_BYPASS = DISABLED;
CLKOK_Input = CLKOP;
FB_MODE = CLKOP;
CLKI_Divider = 16;
CLKFB_Divider = 19;
CLKOP_Divider = 4;
CLKOK_Divider = 2;
Phase_Duty_Control = STATIC;
CLKOS_Phase_Shift_(degree) = 0.0;
CLKOS_Duty_Cycle = 8;
CLKOS_Delay_Adjust_Power_Down = DISABLED;
CLKOS_Delay_Adjust_Static_Delay_(ps) = 0;
CLKOP_Duty_Trim_Polarity = RISING;
CLKOP_Duty_Trim_Polarity_Delay_(ps) = 0;
CLKOS_Duty_Trim_Polarity = RISING;
CLKOS_Duty_Trim_Polarity_Delay_(ps) = 0;
; End PLL Section
