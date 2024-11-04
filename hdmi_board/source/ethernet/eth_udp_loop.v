//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           eth_udp_loop
// Last modified Date:  2020/2/18 9:20:14
// Last Version:        V1.0
// Descriptions:        以太网通信UDP通信环回顶层模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2020/2/18 9:20:14
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module eth_udp_loop(
    input              sys_clk   , //系统时钟
    input              sys_rst_n , //系统复位信号，低电平有效 
    //PL以太网RGMII接口   
    input              eth_rxc   , //RGMII接收数据时钟
    input              eth_rx_ctl, //RGMII输入数据有效信号
    input       [3:0]  eth_rxd   , //RGMII输入数据
    output             eth_txc   , //RGMII发送数据时钟    
    output             eth_tx_ctl, //RGMII输出数据有效信号
    output      [3:0]  eth_txd   , //RGMII输出数据          
    output             eth_rst_n ,   //以太网芯片复位信号，低电平有效   
    output             rec_data  ,//*synthesis PAP_MARK_DEBUG="1"*/
    output             rec_en    ,//*synthesis PAP_MARK_DEBUG="1"*/
    output             gmii_rx_clk,
    output       [127:0] char0      ,
    output       [127:0] char1      ,
    output       [127:0] char2      ,
    output       [127:0] char3      ,
    output       [127:0] char4      ,
    output       [127:0] char5      ,
    output       [127:0] char6      ,
    output       [127:0] char7      ,
    output       [127:0] char8      ,
    output       [127:0] char9      ,
    output       [127:0] char10     ,
    output       [127:0] char11     ,
    output       [127:0] char12     ,
    output       [127:0] char13     ,
    output       [127:0] char14     ,
    output       [127:0] char15     ,
    output       [127:0] char16     ,
    output       [127:0] char17     ,
    output       [127:0] char18     ,
    output       [127:0] char19     ,
    output       [127:0] char20     ,
    output       [127:0] char21     ,
    output       [127:0] char22     ,
    output       [127:0] char23     ,
    output       [127:0] char24     ,
    output       [127:0] char25     ,
    output       [127:0] char26     ,
    output       [127:0] char27     ,
    output       [127:0] char28     ,
    output       [127:0] char29     ,
    output       [127:0] char30     ,
    output       [127:0] char31      
    );

//parameter define
//开发板MAC地址 00-11-22-33-44-55
parameter  BOARD_MAC = 48'h00_11_22_33_44_55;     
//开发板IP地址 192.168.1.10
parameter  BOARD_IP  = {8'd192,8'd168,8'd1,8'd10};  
//目的MAC地址 ff_ff_ff_ff_ff_ff
parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff;    
//目的IP地址 192.168.1.102     
parameter  DES_IP    = {8'd192,8'd168,8'd1,8'd102};  
              
wire          gmii_rx_clk   ; //GMII接收时钟
wire          gmii_rx_dv    ; //GMII接收数据有效信号
wire  [7:0]   gmii_rxd      ; //GMII接收数据
wire          gmii_tx_clk   ; //GMII发送时钟
wire          gmii_tx_en    ; //GMII发送数据使能信号
wire  [7:0]   gmii_txd      ; //GMII发送数据     

wire          arp_gmii_tx_en; //ARP GMII输出数据有效信号 
wire  [7:0]   arp_gmii_txd  ; //ARP GMII输出数据
wire          arp_rx_done   ; //ARP接收完成信号
wire          arp_rx_type   ; //ARP接收类型 0:请求  1:应答
wire  [47:0]  src_mac       ; //接收到目的MAC地址
wire  [31:0]  src_ip        ; //接收到目的IP地址    
wire          arp_tx_en     ; //ARP发送使能信号
wire          arp_tx_type   ; //ARP发送类型 0:请求  1:应答
wire  [47:0]  des_mac       ; //发送的目标MAC地址
wire  [31:0]  des_ip        ; //发送的目标IP地址   
wire          arp_tx_done   ; //ARP发送完成信号

wire          udp_gmii_tx_en; //UDP GMII输出数据有效信号 
wire  [7:0]   udp_gmii_txd  ; //UDP GMII输出数据
wire          rec_pkt_done  ; //UDP单包数据接收完成信号
wire          rec_en        ; //UDP接收的数据使能信号
wire  [31:0]  rec_data      ; //UDP接收的数据
wire  [15:0]  rec_byte_num  ; //UDP接收的有效字节数 单位:byte 
wire  [15:0]  tx_byte_num   ; //UDP发送的有效字节数 单位:byte 
wire          udp_tx_done   ; //UDP发送完成信号
wire          tx_req        ; //UDP读数据请求信号
wire  [31:0]  tx_data       ; //UDP待发送数据//*synthesis PAP_MARK_DEBUG="1"*/
wire          tx_start_en   ; //UDP发送开始使能信号
wire  [127:0] char0         ;
wire  [127:0] char1         ;
wire  [127:0] char2         ;
wire  [127:0] char3         ;
wire  [127:0] char4         ;
wire  [127:0] char5         ;
wire  [127:0] char6         ;
wire  [127:0] char7         ;
wire  [127:0] char8         ;
wire  [127:0] char9   /*synthesis syn_keep=1*/      ;
wire  [127:0] char10        ;
wire  [127:0] char11        ;
wire  [127:0] char12        ;
wire  [127:0] char13        ;
wire  [127:0] char14        ;
wire  [127:0] char15        ;
wire  [127:0] char16        ;
wire  [127:0] char17        ;
wire  [127:0] char18        ;
wire  [127:0] char19        ;
wire  [127:0] char20        ;
wire  [127:0] char21        ;
wire  [127:0] char22        ;
wire  [127:0] char23        ;
wire  [127:0] char24   /*synthesis syn_keep=1*/     ;
wire  [127:0] char25        ;
wire  [127:0] char26        ;
wire  [127:0] char27        ;
wire  [127:0] char28        ;
wire  [127:0] char29        ;
wire  [127:0] char30        ;
wire  [127:0] char31        ;
//*****************************************************
//**                    main code
//*****************************************************

assign tx_start_en = rec_pkt_done;
assign tx_byte_num = rec_byte_num;
assign des_mac = src_mac;
assign des_ip = src_ip;
assign eth_rst_n = sys_rst_n;

//GMII接口转RGMII接口
gmii_to_rgmii u_gmii_to_rgmii(
    .gmii_rx_clk   (gmii_rx_clk ),
    .gmii_rx_dv    (gmii_rx_dv  ),
    .gmii_rxd      (gmii_rxd    ),
    .gmii_tx_clk   (gmii_tx_clk ),
    .gmii_tx_en    (gmii_tx_en  ),
    .gmii_txd      (gmii_txd    ),
    
    .rgmii_rxc     (eth_rxc     ),
    .rgmii_rx_ctl  (eth_rx_ctl  ),
    .rgmii_rxd     (eth_rxd     ),
    .rgmii_txc     (eth_txc     ),
    .rgmii_tx_ctl  (eth_tx_ctl  ),
    .rgmii_txd     (eth_txd     )
    );

//ARP通信
arp                                             
   #(
    .BOARD_MAC     (BOARD_MAC),      //参数例化
    .BOARD_IP      (BOARD_IP ),
    .DES_MAC       (DES_MAC  ),
    .DES_IP        (DES_IP   )
    )
   u_arp(
    .rst_n         (sys_rst_n  ),

    .gmii_rx_clk   (gmii_rx_clk),
    .gmii_rx_dv    (gmii_rx_dv ),
    .gmii_rxd      (gmii_rxd   ),
    .gmii_tx_clk   (gmii_tx_clk),
    .gmii_tx_en    (arp_gmii_tx_en ),
    .gmii_txd      (arp_gmii_txd),
                    
    .arp_rx_done   (arp_rx_done),
    .arp_rx_type   (arp_rx_type),
    .src_mac       (src_mac    ),
    .src_ip        (src_ip     ),
    .arp_tx_en     (arp_tx_en  ),
    .arp_tx_type   (arp_tx_type),
    .des_mac       (des_mac    ),
    .des_ip        (des_ip     ),
    .tx_done       (arp_tx_done)
    );

//UDP通信
udp                                             
   #(
    .BOARD_MAC     (BOARD_MAC),      //参数例化
    .BOARD_IP      (BOARD_IP ),
    .DES_MAC       (DES_MAC  ),
    .DES_IP        (DES_IP   )
    )
   u_udp(
    .rst_n         (sys_rst_n   ),  
    
    .gmii_rx_clk   (gmii_rx_clk ),           
    .gmii_rx_dv    (gmii_rx_dv  ),         
    .gmii_rxd      (gmii_rxd    ),                   
    .gmii_tx_clk   (gmii_tx_clk ), 
    .gmii_tx_en    (udp_gmii_tx_en),         
    .gmii_txd      (udp_gmii_txd),  

    .rec_pkt_done  (rec_pkt_done),    
    .rec_en        (rec_en      ),     
    .rec_data      (rec_data    ),         
    .rec_byte_num  (rec_byte_num),      
    .tx_start_en   (tx_start_en ),        
    .tx_data       (tx_data     ),         
    .tx_byte_num   (tx_byte_num ),  
    .des_mac       (des_mac     ),
    .des_ip        (des_ip      ),    
    .tx_done       (udp_tx_done ),        
    .tx_req        (tx_req      ),
    .tx_data_en    (tx_data_en)  ,
    .char0           (char0      ),   
    .char1           (char1      ),
    .char2           (char2      ),
    .char3           (char3      ),
    .char4           (char4      ),
    .char5           (char5      ),
    .char6           (char6      ),
    .char7           (char7      ),
    .char8           (char8      ),
    .char9           (char9      ),
    .char10          (char10     ),
    .char11          (char11     ),
    .char12          (char12     ),
    .char13          (char13     ),
    .char14          (char14     ),
    .char15          (char15     ),
    .char16          (char16     ),
    .char17          (char17     ),
    .char18          (char18     ),
    .char19          (char19     ),
    .char20          (char20     ),
    .char21          (char21     ),
    .char22          (char22     ),
    .char23          (char23     ),
    .char24          (char24     ),
    .char25          (char25     ),
    .char26          (char26     ),
    .char27          (char27     ),
    .char28          (char28     ),
    .char29          (char29     ),
    .char30          (char30     ),
    .char31          (char31     )        
    ); 

////同步FIFO  
sync_fifo_2048x32b u_sync_fifo_2048x32b (
  .clk             (gmii_rx_clk),   // input
  .rst             (~sys_rst_n),    // input
  .wr_en           (rec_en),        // input
  .wr_data         (rec_data),      // input [31:0]
  .wr_full         (),              // output
  .almost_full     (),              // output
  .rd_en           (tx_req),        // input
  .rd_data         (tx_data),       // output [31:0]
  .rd_empty        (),              // output
  .almost_empty    ()               // output
);

eth_ctrl u_eth_ctrl(
    .clk            (gmii_rx_clk),
    .rst_n          (sys_rst_n),

    .arp_rx_done    (arp_rx_done   ),
    .arp_rx_type    (arp_rx_type   ),
    .arp_tx_en      (arp_tx_en     ),
    .arp_tx_type    (arp_tx_type   ),
    .arp_tx_done    (arp_tx_done   ),
    .arp_gmii_tx_en (arp_gmii_tx_en),
    .arp_gmii_txd   (arp_gmii_txd  ),
    
    .udp_tx_start_en(tx_start_en   ),
    .udp_tx_done    (udp_tx_done   ),    
    .udp_gmii_tx_en (udp_gmii_tx_en),
    .udp_gmii_txd   (udp_gmii_txd  ),

    .gmii_tx_en     (gmii_tx_en    ),
    .gmii_txd       (gmii_txd      )
    );

endmodule