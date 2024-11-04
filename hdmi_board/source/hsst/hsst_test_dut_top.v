// Created by IP Generator (Version 2022.1 build 99559)


///////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
///////////////////////////////////////////////////////////////////////////////
//
// Library:
// Filename:
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/100fs

module hsst_test_dut_top 
(
    //用户接口
    output         gt2_txfsmresetdone            ,    //LANE_2 初始化完成       
    output         tx2_clk                       ,    //LANE_2 发送时钟         
    input[31:0]    tx2_data                      ,    //LANE_2 发送数据         
    input[3:0]     tx2_kchar                     ,    //LANE_2 发送数据K码      
    output         rx2_clk                       ,    //LANE_2 接收时钟         
    output [39:0]  o_rxd_2                       ,    //LANE_2 接收数据         
    output [3:0]   o_rxk_2                       ,    //LANE_2 接收数据K码      
    output         gt3_txfsmresetdone            ,    //LANE_3 初始化完成       
    output         tx3_clk                       ,    //LANE_3 发送时钟         
    input[31:0]    tx3_data                      ,    //LANE_3 发送数据         
    input[3:0]     tx3_kchar                     ,    //LANE_3 发送数据K码      
    output         rx3_clk                       ,    //LANE_3 接收时钟         
    output [39:0]  o_rxd_3                       ,    //LANE_3 接收数据         
    output [3:0]   o_rxk_3                       ,    //LANE_3 接收数据K码     
    
    input          i_free_clk                    ,
    input          rst_n                         ,
    output [1:0]   o_wtchdg_st_0                 ,
    output         o_pll_done_0                  ,
    output         o_txlane_done_2               ,
    output         o_txlane_done_3               ,
    output         o_rxlane_done_2               ,
    output         o_rxlane_done_3               ,
    input          i_p_refckn_0                  ,
    input          i_p_refckp_0                  ,
    output         o_p_pll_lock_0                ,
    output         o_p_rx_sigdet_sta_2           ,
    output         o_p_rx_sigdet_sta_3           ,
    output         o_p_lx_cdr_align_2            ,
    output         o_p_lx_cdr_align_3            ,
    output         o_p_pcs_lsm_synced_2          ,
    output         o_p_pcs_lsm_synced_3          ,
    input          i_p_l2rxn                     ,
    input          i_p_l2rxp                     ,
    input          i_p_l3rxn                     ,
    input          i_p_l3rxp                     ,
    output         o_p_l2txn                     ,
    output         o_p_l2txp                     ,
    output         o_p_l3txn                     ,
    output         o_p_l3txp                     ,
    output [2:0]   o_rxstatus_2                  ,
    output [2:0]   o_rxstatus_3                  ,
    output [3:0]   o_rdisper_2                   ,
    output [3:0]   o_rdecer_2                    ,
    output [3:0]   o_rdisper_3                   ,
    output [3:0]   o_rdecer_3                    ,   
    output [3:0]   o_pl_err                      
);


wire          i_wtchdg_clr_0 ;
wire          src_rst             /* synthesis PAP_MARK_DEBUG="true" */ ; //no use          
wire          chk_rst             /* synthesis PAP_MARK_DEBUG="true" */ ; //no used
wire          pll_rst_d;
wire          i_pll_rst_0;
wire          i_p_cfg_rst;
wire          rst_n_dly_d0;

assign        i_p_cfg_rst    = ~rst_n;
assign        i_pll_rst_0    = pll_rst_d;
assign        pll_rst_d      = i_p_cfg_rst;
assign        i_wtchdg_clr_0 = pll_rst_d;
assign        src_rst        = pll_rst_d;
assign        chk_rst        = pll_rst_d;


// ********************* UI parameters *********************
localparam CH0_PROTOCOL = "CUSTOMERIZEDx1";
localparam CH1_PROTOCOL = "CUSTOMERIZEDx1";
localparam CH2_PROTOCOL = "CUSTOMERIZEDx2";
localparam CH3_PROTOCOL = "CUSTOMERIZEDx2";
localparam CH0_RXPCS_CTC = "Bypassed";
localparam CH1_RXPCS_CTC = "Bypassed";
localparam CH2_RXPCS_CTC = "GE";   //GE
localparam CH3_RXPCS_CTC = "GE";   //GE
localparam PLL0_REF_FRQ = 125.0;
localparam PLL1_REF_FRQ = 125.0;
 localparam TD_8BIT_ONLY_0 = "FALSE"; 
 localparam TD_10BIT_ONLY_0 = "FALSE"; 
 localparam TD_8B10B_8BIT_0 = "FALSE"; 
 localparam TD_16BIT_ONLY_0 = "FALSE"; 
 localparam TD_20BIT_ONLY_0 = "FALSE"; 
 localparam TD_8B10B_16BIT_0 = "FALSE"; 
 localparam TD_32BIT_ONLY_0 = "FALSE"; 
 localparam TD_40BIT_ONLY_0 = "FALSE"; 
 localparam TD_8B10B_32BIT_0 = "FALSE"; 
 localparam TD_64B66B_16BIT_0 = "FALSE"; 
 localparam TD_64B66B_32BIT_0 = "FALSE"; 
 localparam TD_64B67B_16BIT_0 = "FALSE"; 
 localparam TD_64B67B_32BIT_0 = "FALSE"; 
 localparam TD_8BIT_ONLY_1 = "FALSE"; 
 localparam TD_10BIT_ONLY_1 = "FALSE"; 
 localparam TD_8B10B_8BIT_1 = "FALSE"; 
 localparam TD_16BIT_ONLY_1 = "FALSE"; 
 localparam TD_20BIT_ONLY_1 = "FALSE"; 
 localparam TD_8B10B_16BIT_1 = "FALSE"; 
 localparam TD_32BIT_ONLY_1 = "FALSE"; 
 localparam TD_40BIT_ONLY_1 = "FALSE"; 
 localparam TD_8B10B_32BIT_1 = "FALSE"; 
 localparam TD_64B66B_16BIT_1 = "FALSE"; 
 localparam TD_64B66B_32BIT_1 = "FALSE"; 
 localparam TD_64B67B_16BIT_1 = "FALSE"; 
 localparam TD_64B67B_32BIT_1 = "FALSE"; 
 localparam TD_8BIT_ONLY_2 = "FALSE"; 
 localparam TD_10BIT_ONLY_2 = "FALSE"; 
 localparam TD_8B10B_8BIT_2 = "FALSE"; 
 localparam TD_16BIT_ONLY_2 = "FALSE"; 
 localparam TD_20BIT_ONLY_2 = "FALSE"; 
 localparam TD_8B10B_16BIT_2 = "FALSE"; 
 localparam TD_32BIT_ONLY_2 = "FALSE"; 
 localparam TD_40BIT_ONLY_2 = "FALSE"; 
 localparam TD_8B10B_32BIT_2 = "TRUE"; 
 localparam TD_64B66B_16BIT_2 = "FALSE"; 
 localparam TD_64B66B_32BIT_2 = "FALSE"; 
 localparam TD_64B67B_16BIT_2 = "FALSE"; 
 localparam TD_64B67B_32BIT_2 = "FALSE"; 
 localparam TD_8BIT_ONLY_3 = "FALSE"; 
 localparam TD_10BIT_ONLY_3 = "FALSE"; 
 localparam TD_8B10B_8BIT_3 = "FALSE"; 
 localparam TD_16BIT_ONLY_3 = "FALSE"; 
 localparam TD_20BIT_ONLY_3 = "FALSE"; 
 localparam TD_8B10B_16BIT_3 = "FALSE"; 
 localparam TD_32BIT_ONLY_3 = "FALSE"; 
 localparam TD_40BIT_ONLY_3 = "FALSE"; 
 localparam TD_8B10B_32BIT_3 = "TRUE"; 
 localparam TD_64B66B_16BIT_3 = "FALSE"; 
 localparam TD_64B66B_32BIT_3 = "FALSE"; 
 localparam TD_64B67B_16BIT_3 = "FALSE"; 
 localparam TD_64B67B_32BIT_3 = "FALSE"; 
 localparam RD_8BIT_ONLY_0 = "FALSE"; 
 localparam RD_10BIT_ONLY_0 = "FALSE"; 
 localparam RD_8B10B_8BIT_0 = "FALSE"; 
 localparam RD_16BIT_ONLY_0 = "FALSE"; 
 localparam RD_20BIT_ONLY_0 = "FALSE"; 
 localparam RD_8B10B_16BIT_0 = "FALSE"; 
 localparam RD_32BIT_ONLY_0 = "FALSE"; 
 localparam RD_40BIT_ONLY_0 = "FALSE"; 
 localparam RD_8B10B_32BIT_0 = "FALSE"; 
 localparam RD_64B66B_16BIT_0 = "FALSE"; 
 localparam RD_64B66B_32BIT_0 = "FALSE"; 
 localparam RD_64B67B_16BIT_0 = "FALSE"; 
 localparam RD_64B67B_32BIT_0 = "FALSE"; 
 localparam RD_8BIT_ONLY_1 = "FALSE"; 
 localparam RD_10BIT_ONLY_1 = "FALSE"; 
 localparam RD_8B10B_8BIT_1 = "FALSE"; 
 localparam RD_16BIT_ONLY_1 = "FALSE"; 
 localparam RD_20BIT_ONLY_1 = "FALSE"; 
 localparam RD_8B10B_16BIT_1 = "FALSE"; 
 localparam RD_32BIT_ONLY_1 = "FALSE"; 
 localparam RD_40BIT_ONLY_1 = "FALSE"; 
 localparam RD_8B10B_32BIT_1 = "FALSE"; 
 localparam RD_64B66B_16BIT_1 = "FALSE"; 
 localparam RD_64B66B_32BIT_1 = "FALSE"; 
 localparam RD_64B67B_16BIT_1 = "FALSE"; 
 localparam RD_64B67B_32BIT_1 = "FALSE"; 
 localparam RD_8BIT_ONLY_2 = "FALSE"; 
 localparam RD_10BIT_ONLY_2 = "FALSE"; 
 localparam RD_8B10B_8BIT_2 = "FALSE"; 
 localparam RD_16BIT_ONLY_2 = "FALSE"; 
 localparam RD_20BIT_ONLY_2 = "FALSE"; 
 localparam RD_8B10B_16BIT_2 = "FALSE"; 
 localparam RD_32BIT_ONLY_2 = "FALSE"; 
 localparam RD_40BIT_ONLY_2 = "FALSE"; 
 localparam RD_8B10B_32BIT_2 = "TRUE"; 
 localparam RD_64B66B_16BIT_2 = "FALSE"; 
 localparam RD_64B66B_32BIT_2 = "FALSE"; 
 localparam RD_64B67B_16BIT_2 = "FALSE"; 
 localparam RD_64B67B_32BIT_2 = "FALSE"; 
 localparam RD_8BIT_ONLY_3 = "FALSE"; 
 localparam RD_10BIT_ONLY_3 = "FALSE"; 
 localparam RD_8B10B_8BIT_3 = "FALSE"; 
 localparam RD_16BIT_ONLY_3 = "FALSE"; 
 localparam RD_20BIT_ONLY_3 = "FALSE"; 
 localparam RD_8B10B_16BIT_3 = "FALSE"; 
 localparam RD_32BIT_ONLY_3 = "FALSE"; 
 localparam RD_40BIT_ONLY_3 = "FALSE"; 
 localparam RD_8B10B_32BIT_3 = "TRUE"; 
 localparam RD_64B66B_16BIT_3 = "FALSE"; 
 localparam RD_64B66B_32BIT_3 = "FALSE"; 
 localparam RD_64B67B_16BIT_3 = "FALSE"; 
 localparam RD_64B67B_32BIT_3 = "FALSE"; 

// ********************* DUT *********************

assign         o_txlane_done_0               =0; // 
assign         o_txlane_done_1               =0; // 
assign         o_tx_ckdiv_done_0             =0; // 
assign         o_tx_ckdiv_done_1             =0; // 
assign         o_tx_ckdiv_done_2             =0; // 
assign         o_tx_ckdiv_done_3             =0; // 
assign         o_rxlane_done_0               =0; // 
assign         o_rxlane_done_1               =0; // 
assign         o_rx_ckdiv_done_0              =0; // 
assign         o_rx_ckdiv_done_1              =0; // 
assign         o_rx_ckdiv_done_2              =0; // 
assign         o_rx_ckdiv_done_3              =0; // 
assign         o_p_rx_sigdet_sta_0           =0; // 
assign         o_p_rx_sigdet_sta_1           =0; // 
assign         o_p_lx_cdr_align_0            =0; // 
assign         o_p_lx_cdr_align_1            =0; // 
assign         o_p_pcs_lsm_synced_0          =0; // 
assign         o_p_pcs_lsm_synced_1          =0; // 
assign         o_p_pcs_rx_mcb_status_0       =0; // 
assign         o_p_pcs_rx_mcb_status_1       =0; // 
assign         o_p_pcs_rx_mcb_status_2       =0; // 
assign         o_p_pcs_rx_mcb_status_3       =0; //  
wire           i_pll_lock_tx_0               = 1'b1;
wire           i_pll_lock_tx_1               = 1'b1;
wire           i_pll_lock_tx_2               = 1'b1;
wire           i_pll_lock_tx_3               = 1'b1;
wire           i_pll_lock_rx_0               = 1'b1;
wire           i_pll_lock_rx_1               = 1'b1;
wire           i_pll_lock_rx_2               = 1'b1;
wire           i_pll_lock_rx_3               = 1'b1;

wire           o_p_clk2core_tx_0             =1'b0;
wire           o_p_clk2core_tx_1             =1'b0;
wire           o_p_clk2core_tx_2              ;  ////////////////
wire           o_p_clk2core_tx_3             =1'b0;
wire           i_p_tx0_clk_fr_core           ;
wire           i_p_tx1_clk_fr_core           ;
wire           i_p_tx2_clk_fr_core           ;
wire           i_p_tx3_clk_fr_core           ;

//wire           i_p_tx0_clk2_fr_core          ;
//wire           i_p_tx1_clk2_fr_core          ;
//wire           i_p_tx2_clk2_fr_core          ;
//wire           i_p_tx3_clk2_fr_core          ;

wire           o_p_clk2core_rx_0             =1'b0;
wire           o_p_clk2core_rx_1             =1'b0;
wire           o_p_clk2core_rx_2             =1'b0;
wire           o_p_clk2core_rx_3             =1'b0;
wire           i_p_clk2core_rx_0             ;
wire           i_p_clk2core_rx_1             ;
wire           i_p_clk2core_rx_2             ;
wire           i_p_clk2core_rx_3             ;
wire           i_p_rx0_clk_fr_core           ;
wire           i_p_rx1_clk_fr_core           ;
wire           i_p_rx2_clk_fr_core           ;
wire           i_p_rx3_clk_fr_core           ;
wire           i_p_rx0_clk2_fr_core          ;
wire           i_p_rx1_clk2_fr_core          ;
wire           i_p_rx2_clk2_fr_core          ;
wire           i_p_rx3_clk2_fr_core          ;

wire   [31:0]  i_txd_2                       ;
wire   [3:0]   i_tdispsel_2                  ;
wire   [3:0]   i_tdispctrl_2                 ;
wire   [3:0]   i_txk_2                       ;
wire   [31:0]  i_txd_3                       ;
wire   [3:0]   i_tdispsel_3                  ;
wire   [3:0]   i_tdispctrl_3                 ;
wire   [3:0]   i_txk_3                       ;
//fabric clock
generate
    if((CH0_PROTOCOL=="XAUI")||(CH0_PROTOCOL=="PCIEx4")||(CH0_PROTOCOL=="CUSTOMERIZEDx4")) begin : BONDING_LANE0123
        assign          i_p_tx0_clk_fr_core           = o_p_clk2core_tx_0; 
        assign          i_p_tx1_clk_fr_core           = o_p_clk2core_tx_0; 
        assign          i_p_tx2_clk_fr_core           = o_p_clk2core_tx_0; 
        assign          i_p_tx3_clk_fr_core           = o_p_clk2core_tx_0; 
        assign          i_p_rx0_clk_fr_core           = (CH0_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_0 : o_p_clk2core_tx_0;
        assign          i_p_rx1_clk_fr_core           = (CH1_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_0 : o_p_clk2core_tx_0;
        assign          i_p_rx2_clk_fr_core           = (CH2_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_0 : o_p_clk2core_tx_0;
        assign          i_p_rx3_clk_fr_core           = (CH3_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_0 : o_p_clk2core_tx_0;
    end
    else if((CH0_PROTOCOL=="CUSTOMERIZEDx2" || CH0_PROTOCOL=="PCIEx2") && (CH2_PROTOCOL!="CUSTOMERIZEDx2" && CH2_PROTOCOL!="PCIEx2"))begin : BONDING_LANE01
        assign          i_p_tx0_clk_fr_core           = o_p_clk2core_tx_0; 
        assign          i_p_tx1_clk_fr_core           = o_p_clk2core_tx_0; 
        assign          i_p_tx2_clk_fr_core           = o_p_clk2core_tx_2; 
        assign          i_p_tx3_clk_fr_core           = o_p_clk2core_tx_3; 
        assign          i_p_rx0_clk_fr_core           = (CH0_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_0 : o_p_clk2core_tx_0;
        assign          i_p_rx1_clk_fr_core           = (CH1_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_0 : o_p_clk2core_tx_0;
        assign          i_p_rx2_clk_fr_core           = (CH2_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_2 : o_p_clk2core_tx_2;
        assign          i_p_rx3_clk_fr_core           = (CH3_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_3 : o_p_clk2core_tx_3;
    end
    else if((CH0_PROTOCOL!="CUSTOMERIZEDx2" && CH0_PROTOCOL!="PCIEx2") && (CH2_PROTOCOL=="CUSTOMERIZEDx2" || CH2_PROTOCOL=="PCIEx2")) begin : BONDING_LANE23
        assign          i_p_tx0_clk_fr_core           = o_p_clk2core_tx_0; 
        assign          i_p_tx1_clk_fr_core           = o_p_clk2core_tx_1; 
        assign          i_p_tx2_clk_fr_core           = o_p_clk2core_tx_2; 
        assign          i_p_tx3_clk_fr_core           = o_p_clk2core_tx_2; 
        assign          i_p_rx0_clk_fr_core           = (CH0_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_0 : o_p_clk2core_tx_0;
        assign          i_p_rx1_clk_fr_core           = (CH1_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_1 : o_p_clk2core_tx_1;
        assign          i_p_rx2_clk_fr_core           = (CH2_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_2 : o_p_clk2core_tx_2;
        assign          i_p_rx3_clk_fr_core           = (CH3_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_2 : o_p_clk2core_tx_2;
    end
    else if((CH0_PROTOCOL=="CUSTOMERIZEDx2" || CH0_PROTOCOL=="PCIEx2") && (CH2_PROTOCOL=="CUSTOMERIZEDx2" || CH2_PROTOCOL=="PCIEx2")) begin : BONDING_LANE01_23
        assign          i_p_tx0_clk_fr_core           = o_p_clk2core_tx_0; 
        assign          i_p_tx1_clk_fr_core           = o_p_clk2core_tx_0; 
        assign          i_p_tx2_clk_fr_core           = o_p_clk2core_tx_2; 
        assign          i_p_tx3_clk_fr_core           = o_p_clk2core_tx_2; 
        assign          i_p_rx0_clk_fr_core           = (CH0_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_0 : o_p_clk2core_tx_0;
        assign          i_p_rx1_clk_fr_core           = (CH1_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_0 : o_p_clk2core_tx_0;
        assign          i_p_rx2_clk_fr_core           = (CH2_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_2 : o_p_clk2core_tx_2;
        assign          i_p_rx3_clk_fr_core           = (CH3_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_2 : o_p_clk2core_tx_2;
    end
    else begin : NO_BONDING
        assign          i_p_tx0_clk_fr_core           = o_p_clk2core_tx_0; 
        assign          i_p_tx1_clk_fr_core           = o_p_clk2core_tx_1; 
        assign          i_p_tx2_clk_fr_core           = o_p_clk2core_tx_2; 
        assign          i_p_tx3_clk_fr_core           = o_p_clk2core_tx_3; 
        assign          i_p_rx0_clk_fr_core           = (CH0_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_0 : o_p_clk2core_tx_0;
        assign          i_p_rx1_clk_fr_core           = (CH1_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_1 : o_p_clk2core_tx_1;
        assign          i_p_rx2_clk_fr_core           = (CH2_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_2 : o_p_clk2core_tx_2;
        assign          i_p_rx3_clk_fr_core           = (CH3_RXPCS_CTC=="Bypassed") ? o_p_clk2core_rx_3 : o_p_clk2core_tx_3;
    end
endgenerate

generate
    if(CH0_PROTOCOL=="PCIEx4") begin : PCIEx4
        assign          i_p_rx0_clk2_fr_core           = o_p_clk2core_rx_0;
        assign          i_p_rx1_clk2_fr_core           = o_p_clk2core_rx_0;
        assign          i_p_rx2_clk2_fr_core           = o_p_clk2core_rx_0;
        assign          i_p_rx3_clk2_fr_core           = o_p_clk2core_rx_0;
    end
    else if(CH0_PROTOCOL=="PCIEx2" && CH2_PROTOCOL!="PCIEx2")begin : PCIEx2_01
        assign          i_p_rx0_clk2_fr_core           = o_p_clk2core_rx_0;
        assign          i_p_rx1_clk2_fr_core           = o_p_clk2core_rx_0;
        assign          i_p_rx2_clk2_fr_core           = 1'b0;
        assign          i_p_rx3_clk2_fr_core           = 1'b0;
    end
    else if(CH0_PROTOCOL!="PCIEx2" && CH2_PROTOCOL=="PCIEx2") begin : PCIEx2_23
        assign          i_p_rx0_clk2_fr_core           = 1'b0;
        assign          i_p_rx1_clk2_fr_core           = 1'b0;
        assign          i_p_rx2_clk2_fr_core           = o_p_clk2core_rx_2;
        assign          i_p_rx3_clk2_fr_core           = o_p_clk2core_rx_2;
    end
    else if(CH0_PROTOCOL=="PCIEx2" && CH2_PROTOCOL=="PCIEx2") begin : PCIEx2_01_23
        assign          i_p_rx0_clk2_fr_core           = o_p_clk2core_rx_0;
        assign          i_p_rx1_clk2_fr_core           = o_p_clk2core_rx_0;
        assign          i_p_rx2_clk2_fr_core           = o_p_clk2core_rx_2;
        assign          i_p_rx3_clk2_fr_core           = o_p_clk2core_rx_2;
    end
    else begin : NO_PCIEx2x4 
        assign          i_p_rx0_clk2_fr_core           = o_p_clk2core_rx_0;
        assign          i_p_rx1_clk2_fr_core           = o_p_clk2core_rx_1;
        assign          i_p_rx2_clk2_fr_core           = o_p_clk2core_rx_2;
        assign          i_p_rx3_clk2_fr_core           = o_p_clk2core_rx_3;
    end
endgenerate

//assign i_p_tx0_clk2_fr_core = i_p_rx0_clk2_fr_core;
//assign i_p_tx1_clk2_fr_core = i_p_rx1_clk2_fr_core;
//assign i_p_tx2_clk2_fr_core = i_p_rx2_clk2_fr_core;
//assign i_p_tx3_clk2_fr_core = i_p_rx3_clk2_fr_core;


hsst_test U_INST (
    
    .i_free_clk                    (i_free_clk                    ), // input          
    .i_wtchdg_clr_0                (i_wtchdg_clr_0                ), // input          
    .o_wtchdg_st_0                 (o_wtchdg_st_0                 ), // output [1:0]   
    .o_pll_done_0                  (o_pll_done_0                  ), // output         
    .o_txlane_done_2               (o_txlane_done_2               ), // output         
    .o_txlane_done_3               (o_txlane_done_3               ), // output         
    .o_rxlane_done_2               (o_rxlane_done_2               ), // output         
    .o_rxlane_done_3               (o_rxlane_done_3               ), // output         
    .i_p_refckn_0                  (i_p_refckn_0                  ), // input          
    .i_p_refckp_0                  (i_p_refckp_0                  ), // input          
    .o_p_clk2core_tx_2             (o_p_clk2core_tx_2             ), // output         
    .i_p_tx2_clk_fr_core           (i_p_tx2_clk_fr_core           ), // input          
    .i_p_tx3_clk_fr_core           (i_p_tx3_clk_fr_core           ), // input          
    .i_p_rx2_clk_fr_core           (i_p_rx2_clk_fr_core           ), // input          
    .i_p_rx3_clk_fr_core           (i_p_rx3_clk_fr_core           ), // input          
    .o_p_pll_lock_0                (o_p_pll_lock_0                ), // output         
    .o_p_rx_sigdet_sta_2           (o_p_rx_sigdet_sta_2           ), // output         
    .o_p_rx_sigdet_sta_3           (o_p_rx_sigdet_sta_3           ), // output         
    .o_p_lx_cdr_align_2            (o_p_lx_cdr_align_2            ), // output         
    .o_p_lx_cdr_align_3            (o_p_lx_cdr_align_3            ), // output         
    .o_p_pcs_lsm_synced_2          (o_p_pcs_lsm_synced_2          ), // output         
    .o_p_pcs_lsm_synced_3          (o_p_pcs_lsm_synced_3          ), // output         
    .i_p_l2rxn                     (i_p_l2rxn                     ), // input          
    .i_p_l2rxp                     (i_p_l2rxp                     ), // input          
    .i_p_l3rxn                     (i_p_l3rxn                     ), // input          
    .i_p_l3rxp                     (i_p_l3rxp                     ), // input          
    .o_p_l2txn                     (o_p_l2txn                     ), // output         
    .o_p_l2txp                     (o_p_l2txp                     ), // output         
    .o_p_l3txn                     (o_p_l3txn                     ), // output         
    .o_p_l3txp                     (o_p_l3txp                     ), // output         
    .i_txd_2                       (i_txd_2                       ), // input  [31:0]  
    .i_tdispsel_2                  (i_tdispsel_2                  ), // input  [3:0]   
    .i_tdispctrl_2                 (i_tdispctrl_2                 ), // input  [3:0]   
    .i_txk_2                       (i_txk_2                       ), // input  [3:0]   
    .i_txd_3                       (i_txd_3                       ), // input  [31:0]  
    .i_tdispsel_3                  (i_tdispsel_3                  ), // input  [3:0]   
    .i_tdispctrl_3                 (i_tdispctrl_3                 ), // input  [3:0]   
    .i_txk_3                       (i_txk_3                       ), // input  [3:0]   
    .o_rxstatus_2                  (o_rxstatus_2[2:0]             ), // output [2:0]   
    .o_rxd_2                       (o_rxd_2[31:0]                 ), // output [31:0]  
    .o_rdisper_2                   (o_rdisper_2[3:0]              ), // output [3:0]   
    .o_rdecer_2                    (o_rdecer_2[3:0]               ), // output [3:0]   
    .o_rxk_2                       (o_rxk_2[3:0]                  ), // output [3:0]   
    .o_rxstatus_3                  (o_rxstatus_3[2:0]             ), // output [2:0]   
    .o_rxd_3                       (o_rxd_3[31:0]                 ), // output [31:0]  
    .o_rdisper_3                   (o_rdisper_3[3:0]              ), // output [3:0]   
    .o_rdecer_3                    (o_rdecer_3[3:0]               ), // output [3:0]   
    .o_rxk_3                       (o_rxk_3[3:0]                  ), // output [3:0]   
    .i_pll_rst_0                   (i_pll_rst_0                   )  // input  
);

assign gt2_txfsmresetdone = o_txlane_done_2      ;
assign gt3_txfsmresetdone = o_txlane_done_3      ;
assign tx2_clk            = i_p_tx2_clk_fr_core  ; 
assign tx3_clk            = i_p_tx3_clk_fr_core  ;
assign i_txd_2            = tx2_data             ;
assign i_tdispsel_2       = 4'b0                 ;
assign i_tdispctrl_2      = 4'b0                 ;
assign i_txk_2            = tx2_kchar            ;
assign i_txd_3            = tx3_data             ;
assign i_tdispsel_3       = 4'b0                 ;
assign i_tdispctrl_3      = 4'b0                 ;
assign i_txk_3            = tx3_kchar            ;

assign rx2_clk            = i_p_rx2_clk_fr_core  ;  
assign rx3_clk            = i_p_rx3_clk_fr_core  ; 


endmodule    
