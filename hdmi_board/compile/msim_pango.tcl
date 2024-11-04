# ----------------------------------------
# Create compilation libraries
vlib usim
vmap usim "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/usim"
vlib vsim
vmap vsim "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/vsim"
vlib adc
vmap adc "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/adc"
vlib adc_e2
vmap adc_e2 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/adc_e2"
vlib adc_e3
vmap adc_e3 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/adc_e3"
vlib ddc_e2
vmap ddc_e2 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/ddc_e2"
vlib ddrc
vmap ddrc "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/ddrc"
vlib ddrphy
vmap ddrphy "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/ddrphy"
vlib dll_e2
vmap dll_e2 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/dll_e2"
vlib emacx
vmap emacx "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/emacx"
vlib emacy
vmap emacy "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/emacy"
vlib emacz
vmap emacz "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/emacz"
vlib hsst
vmap hsst "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/hsst"
vlib hsst_e2
vmap hsst_e2 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/hsst_e2"
vlib hssthp_bufds
vmap hssthp_bufds "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/hssthp_bufds"
vlib hssthp_hpll
vmap hssthp_hpll "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/hssthp_hpll"
vlib hssthp_lane
vmap hssthp_lane "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/hssthp_lane"
vlib hsstlp_lane
vmap hsstlp_lane "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/hsstlp_lane"
vlib hsstlp_pll
vmap hsstlp_pll "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/hsstlp_pll"
vlib iolhp_fifo
vmap iolhp_fifo "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/iolhp_fifo"
vlib iolhr_dft
vmap iolhr_dft "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/iolhr_dft"
vlib ipal_e1
vmap ipal_e1 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/ipal_e1"
vlib ipal_e2
vmap ipal_e2 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/ipal_e2"
vlib iserdes_e1
vmap iserdes_e1 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/iserdes_e1"
vlib iserdes_e2
vmap iserdes_e2 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/iserdes_e2"
vlib iserdes_e3
vmap iserdes_e3 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/iserdes_e3"
vlib iserdes_fifo
vmap iserdes_fifo "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/iserdes_fifo"
vlib oserdes_e1
vmap oserdes_e1 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/oserdes_e1"
vlib oserdes_e2
vmap oserdes_e2 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/oserdes_e2"
vlib oserdes_e3
vmap oserdes_e3 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/oserdes_e3"
vlib oserdes_fifo
vmap oserdes_fifo "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/oserdes_fifo"
vlib pciegen2
vmap pciegen2 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/pciegen2"
vlib pciegen3
vmap pciegen3 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/pciegen3"
vlib pciegen5_cfg
vmap pciegen5_cfg "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/pciegen5_cfg"
vlib pciegen5_ctrl
vmap pciegen5_ctrl "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/pciegen5_ctrl"


#compile basic library
vlog -incr E:/pds/PDS_2022.1/arch/vendor/pango/verilog/simulation/*.v -work usim
vlog -incr E:/pds/PDS_2022.1/arch/vendor/pango/verilog/simulation/modelsim10.2c/*.vp -work usim


#compile basic library
vlog -incr E:/pds/PDS_2022.1/arch/vendor/pango/verilog/bsim/*.v -work vsim
vlog -incr E:/pds/PDS_2022.1/arch/vendor/pango/verilog/bsim/modelsim10.2c/*.vp -work vsim


#compile common library
cd "E:/pds/PDS_2022.1/arch/vendor/pango/verilog/simulation/modelsim10.2c"
vmap adc "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/adc"
vlog -incr -f ./filelist_adc_gtp.f -work adc
vmap adc_e2 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/adc_e2"
vlog -incr -f ./filelist_adc_e2_gtp.f -work adc_e2
vmap adc_e3 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/adc_e3"
vlog -incr -f ./filelist_adc_e3_gtp.f -work adc_e3
vmap ddc_e2 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/ddc_e2"
vlog -incr -f ./filelist_ddc_e2_gtp.f -work ddc_e2
vmap ddrc "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/ddrc"
vlog -incr -f ./filelist_ddrc_gtp.f -work ddrc -sv -mfcu
vmap ddrphy "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/ddrphy"
vlog -incr -f ./filelist_ddrphy_gtp.f -work ddrphy
vmap dll_e2 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/dll_e2"
vlog -incr -f ./filelist_dll_e2_gtp.f -work dll_e2
vmap emacx "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/emacx"
vlog -incr -f ./filelist_emacx_gtp.f -work emacx -sv -mfcu
vmap emacy "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/emacy"
vlog -incr -f ./filelist_emacy_gtp.f -work emacy -sv -mfcu
vmap emacz "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/emacz"
vlog -incr -f ./filelist_emacz_gtp.f -work emacz -sv -mfcu
vmap hsst "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/hsst"
vlog -incr -f ./filelist_hsst_gtp.f -work hsst
vmap hsst_e2 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/hsst_e2"
vlog -incr -f ./filelist_hsst_e2_gtp.f -work hsst_e2
vmap hssthp_bufds "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/hssthp_bufds"
vlog -incr -f ./filelist_hssthp_bufds_gtp.f -work hssthp_bufds
vmap hssthp_hpll "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/hssthp_hpll"
vlog -incr -f ./filelist_hssthp_hpll_gtp.f -work hssthp_hpll
vmap hssthp_lane "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/hssthp_lane"
vlog -incr -f ./filelist_hssthp_lane_gtp.f -work hssthp_lane
vmap hsstlp_lane "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/hsstlp_lane"
vlog -incr -f ./filelist_hsstlp_lane_gtp.f -work hsstlp_lane
vmap hsstlp_pll "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/hsstlp_pll"
vlog -incr -f ./filelist_hsstlp_pll_gtp.f -work hsstlp_pll
vmap iolhp_fifo "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/iolhp_fifo"
vlog -incr -f ./filelist_iolhp_fifo_gtp.f -work iolhp_fifo
vmap iolhr_dft "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/iolhr_dft"
vlog -incr -f ./filelist_iolhr_dft_gtp.f -work iolhr_dft
vmap ipal_e1 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/ipal_e1"
vlog -incr -f ./filelist_ipal_e1_gtp.f -work ipal_e1
vmap ipal_e2 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/ipal_e2"
vlog -incr -f ./filelist_ipal_e2_gtp.f -work ipal_e2
vmap iserdes_e1 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/iserdes_e1"
vlog -incr -f ./filelist_iserdes_e1_gtp.f -work iserdes_e1
vmap iserdes_e2 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/iserdes_e2"
vlog -incr -f ./filelist_iserdes_e2_gtp.f -work iserdes_e2
vmap iserdes_e3 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/iserdes_e3"
vlog -incr -f ./filelist_iserdes_e3_gtp.f -work iserdes_e3 -sv -mfcu
vmap iserdes_fifo "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/iserdes_fifo"
vlog -incr -f ./filelist_iserdes_fifo_gtp.f -work iserdes_fifo
vmap oserdes_e1 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/oserdes_e1"
vlog -incr -f ./filelist_oserdes_e1_gtp.f -work oserdes_e1
vmap oserdes_e2 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/oserdes_e2"
vlog -incr -f ./filelist_oserdes_e2_gtp.f -work oserdes_e2
vmap oserdes_e3 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/oserdes_e3"
vlog -incr -f ./filelist_oserdes_e3_gtp.f -work oserdes_e3 -sv -mfcu
vmap oserdes_fifo "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/oserdes_fifo"
vlog -incr -f ./filelist_oserdes_fifo_gtp.f -work oserdes_fifo
vmap pciegen2 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/pciegen2"
vlog -incr -f ./filelist_pciegen2_gtp.f -work pciegen2 -sv -mfcu
vmap pciegen3 "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/pciegen3"
vlog -incr -f ./filelist_pciegen3_gtp.f -work pciegen3 -sv -mfcu
vmap pciegen5_cfg "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/pciegen5_cfg"
vlog -incr -f ./filelist_pciegen5_cfg_gtp.f -work pciegen5_cfg -sv -mfcu
vmap pciegen5_ctrl "C:/Users/JIAOFUJUN/Desktop/scaler_version/compile/pciegen5_ctrl"
vlog -incr -f ./filelist_pciegen5_ctrl_gtp.f -work pciegen5_ctrl -sv -mfcu

quit -force

# ----------------------------------------
