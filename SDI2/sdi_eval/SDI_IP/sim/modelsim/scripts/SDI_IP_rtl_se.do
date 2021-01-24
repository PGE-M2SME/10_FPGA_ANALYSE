onbreak {resume} 
quit -sim 
cd "/home/diamond/SharedFolder/SDI2/sdi_eval/SDI_IP/sim/modelsim/rtl"
# --------- Simulation work library creation -- 
vlib work
vmap pcsd_mti_work "/usr/local/diamond/3.11_x64/cae_library/simulation/blackbox/pcsd_work"
vlog -novopt +define+HALF_PERIOD1=3.36 \
   +define+HALF_PERIOD1=3.36 \
   +define+HALF_PERIOD2=3.36 \
   +define+HALF_PERIOD_SD=18.48 \
   +define+RTL_SIM \
   +define+CORE_SIM \
   +define+RUN_SIMULATE \
   "../../../src/params/SDI_IP_params.v" \
   "../../../../testbench/sdi_tb.v" \
   "../../../src/rtl/top/ecp3/sdi_sample.v" \
   "../../../src/beh_rtl/ecp3/SDI_IP_beh.v" \
   "../../../../testbench/patgenerator/pattern_generator_top.v" \
   "../../../../testbench/patgenerator/pattern_control.v" \
   "../../../../testbench/patgenerator/pattern_data.v" \
   "../../../../testbench/patgenerator/pattern_fsm.v" \
   "../../../../testbench/patgenerator/pattern_fsm_b.v" \
   "../../../../testbench/patgenerator/anc_enable_gen.v" \
   "../../../../testbench/patgenerator/anc_send.v" \
   "../../../../models/ecp3/pcs/ecp3pcs.v" \
   "../../../../models/ecp3/pll_148/pll_148.v" \
   -y /usr/local/diamond/3.11_x64/cae_library/simulation/verilog/pmi \
   -y /usr/local/diamond/3.11_x64/cae_library/simulation/verilog/ecp3 +libext+.v
vlog -refresh -quiet -work pcsd_mti_work
# --------- Start evaluation test -- 
vsim -novopt -L pcsd_mti_work sdi_tb 
# --------- View the simulation results 
view structure 
view signals 
# --------- Wave display
add wave /sdi_tb/u1_sdi_sample/rstn
add wave /sdi_tb/u1_sdi_sample/ser_ref_clkp
add wave /sdi_tb/u1_sdi_sample/txhalfclk
add wave /sdi_tb/u1_sdi_sample/txfullclk
add wave /sdi_tb/u1_sdi_sample/clk_pat_gen
add wave /sdi_tb/u1_sdi_sample/levelb_lan_in
add wave /sdi_tb/u1_sdi_sample/threeg_hdn_in
add wave /sdi_tb/u1_sdi_sample/highd_sdn_in
add wave /sdi_tb/u1_sdi_sample/trs_in_pat
add wave -radix hexadecimal /sdi_tb/u1_sdi_sample/pd_in_pat
add wave -radix hexadecimal /sdi_tb/u1_sdi_sample/txdata
add wave /sdi_tb/u1_sdi_sample/rxfullclk
add wave /sdi_tb/u1_sdi_sample/rxhalfclk
add wave -radix hexadecimal /sdi_tb/u1_sdi_sample/rxdata
add wave /sdi_tb/u1_sdi_sample/rx_lb_lan
add wave /sdi_tb/u1_sdi_sample/rx_3g_hdn
add wave /sdi_tb/u1_sdi_sample/rx_hd_sdn
add wave /sdi_tb/u1_sdi_sample/rx_rate
add wave /sdi_tb/u1_sdi_sample/rx_pdo_clk
add wave -radix hexadecimal /sdi_tb/u1_sdi_sample/pd_out
add wave /sdi_tb/u1_sdi_sample/vidactive
add wave -radix unsigned /sdi_tb/u1_sdi_sample/vid_format
add wave -radix unsigned /sdi_tb/u1_sdi_sample/frame_format
add wave /sdi_tb/u1_sdi_sample/trs_out_int
add wave /sdi_tb/u1_sdi_sample/ychannel
add wave /sdi_tb/u1_sdi_sample/field
add wave /sdi_tb/u1_sdi_sample/vblank
add wave /sdi_tb/u1_sdi_sample/hblank
add wave -radix unsigned /sdi_tb/u1_sdi_sample/ln1_out_int
add wave -radix unsigned /sdi_tb/u1_sdi_sample/ln2_out_int
add wave /sdi_tb/u1_sdi_sample/eav_error
add wave /sdi_tb/u1_sdi_sample/sav_error
add wave /sdi_tb/u1_sdi_sample/y1_crc_error
add wave /sdi_tb/u1_sdi_sample/c1_crc_error
add wave /sdi_tb/u1_sdi_sample/y2_crc_error
add wave /sdi_tb/u1_sdi_sample/c2_crc_error
add wave -radix hexadecimal /sdi_tb/u1_sdi_sample/vpid1_out
add wave /sdi_tb/u1_sdi_sample/vp1_valid
add wave /sdi_tb/u1_sdi_sample/vp1_cserr
add wave /sdi_tb/u1_sdi_sample/vp1_parerr
add wave /sdi_tb/u1_sdi_sample/vp1_lineok
add wave -radix hexadecimal /sdi_tb/u1_sdi_sample/vpid2_out
add wave /sdi_tb/u1_sdi_sample/vp2_valid
add wave /sdi_tb/u1_sdi_sample/vp2_cserr
add wave /sdi_tb/u1_sdi_sample/vp2_parerr
add wave /sdi_tb/u1_sdi_sample/vp2_lineok
run -all 

