//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com 
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           udp
// Last modified Date:  2020/2/18 9:20:14
// Last Version:        V1.0
// Descriptions:        udpģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2020/2/18 9:20:14
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module udp(
    input                rst_n       , //��λ�źţ��͵�ƽ��Ч
    //GMII�ӿ�
    input                gmii_rx_clk , //GMII��������ʱ�� //*synthesis PAP_MARK_DEBUG="1"*/
    input                gmii_rx_dv  , //GMII����������Ч�ź�
    input        [7:0]   gmii_rxd    , //GMII��������
    input                gmii_tx_clk , //GMII��������ʱ��    
    output               gmii_tx_en  , //GMII���������Ч�ź�
    output       [7:0]   gmii_txd    , //GMII������� 
    //�û��ӿ�
    output               rec_pkt_done, //��̫���������ݽ�������ź�
    output               rec_en      , //��̫�����յ�����ʹ���ź�//*synthesis PAP_MARK_DEBUG="1"*/
    output       [31:0]  rec_data    , //��̫�����յ�����//*synthesis PAP_MARK_DEBUG="1"*/
    output       [15:0]  rec_byte_num, //��̫�����յ���Ч�ֽ��� ��λ:byte     
    input                tx_start_en , //��̫����ʼ�����ź�
    input        [31:0]  tx_data     , //��̫������������  //*synthesis PAP_MARK_DEBUG="1"*/
    input        [15:0]  tx_byte_num , //��̫�����͵���Ч�ֽ��� ��λ:byte  
    input        [47:0]  des_mac     , //���͵�Ŀ��MAC��ַ
    input        [31:0]  des_ip      , //���͵�Ŀ��IP��ַ    
    output               tx_done     , //��̫����������ź�
    output               tx_req       ,//�����������ź�
    output               tx_data_en    ,
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
//������MAC��ַ 00-11-22-33-44-55
parameter BOARD_MAC = 48'h00_11_22_33_44_55;    
//������IP��ַ 192.168.1.10     
parameter BOARD_IP  = {8'd192,8'd168,8'd1,8'd10};
//Ŀ��MAC��ַ ff_ff_ff_ff_ff_ff
parameter  DES_MAC  = 48'hff_ff_ff_ff_ff_ff;
//Ŀ��IP��ַ 192.168.1.102     
parameter  DES_IP   = {8'd192,8'd168,8'd1,8'd102};

//wire define
wire          crc_en  ; //CRC��ʼУ��ʹ��
wire          crc_clr ; //CRC���ݸ�λ�ź� 
wire  [7:0]   crc_d8  ; //�����У��8λ����

wire  [31:0]  crc_data; //CRCУ������
wire  [31:0]  crc_next; //CRC�´�У���������
wire  [127:0] char0   ;
wire  [127:0] char1   ;
wire  [127:0] char2   ;
wire  [127:0] char3   ;
wire  [127:0] char4   ;
wire  [127:0] char5   ;
wire  [127:0] char6   ;
wire  [127:0] char7   ;
wire  [127:0] char8   ;
wire  [127:0] char9   ;
wire  [127:0] char10  ;
wire  [127:0] char11  ;
wire  [127:0] char12  ;
wire  [127:0] char13  ;
wire  [127:0] char14  ;
wire  [127:0] char15  ;
wire  [127:0] char16  ;
wire  [127:0] char17  ;
wire  [127:0] char18  ;
wire  [127:0] char19  ;
wire  [127:0] char20  ;
wire  [127:0] char21  ;
wire  [127:0] char22  ;
wire  [127:0] char23  ;
wire  [127:0] char24  ;
wire  [127:0] char25  ;
wire  [127:0] char26  ;
wire  [127:0] char27  ;
wire  [127:0] char28  ;
wire  [127:0] char29  ;
wire  [127:0] char30  ;
wire  [127:0] char31  ;

//*****************************************************
//**                    main code
//*****************************************************

assign  crc_d8 = gmii_txd;

//��̫������ģ��    
udp_rx 
   #(
    .BOARD_MAC       (BOARD_MAC),         //��������
    .BOARD_IP        (BOARD_IP )
    )
   u_udp_rx(
    .clk             (gmii_rx_clk ),        
    .rst_n           (rst_n       ),             
    .gmii_rx_dv      (gmii_rx_dv  ),                                 
    .gmii_rxd        (gmii_rxd    ),       
    .rec_pkt_done    (rec_pkt_done),      
    .rec_en          (rec_en      ),            
    .rec_data        (rec_data    ),          
    .rec_byte_num    (rec_byte_num)       
    );                                    

//��̫������ģ��
udp_tx
   #(
    .BOARD_MAC       (BOARD_MAC),         //��������
    .BOARD_IP        (BOARD_IP ),
    .DES_MAC         (DES_MAC  ),
    .DES_IP          (DES_IP   )
    )
   u_udp_tx(
    .clk             (gmii_tx_clk),        
    .rst_n           (rst_n      ),             
    .tx_start_en     (tx_start_en),                   
    .tx_data         (tx_data    ),           
    .tx_byte_num     (tx_byte_num),    
    .des_mac         (des_mac    ),
    .des_ip          (des_ip     ),    
    .crc_data        (crc_data   ),          
    .crc_next        (crc_next[31:24]),
    .tx_done         (tx_done    ),           
    .tx_req          (tx_req     ),            
    .gmii_tx_en      (gmii_tx_en ),         
    .gmii_txd        (gmii_txd   ),       
    .crc_en          (crc_en     ),            
    .crc_clr         (crc_clr    ),
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
    .char31          (char31     ),
    .tx_data_en(tx_data_en)
    );                                      

//��̫������CRCУ��ģ��
crc32_d8   u_crc32_d8(
    .clk             (gmii_tx_clk),                      
    .rst_n           (rst_n      ),                          
    .data            (crc_d8     ),            
    .crc_en          (crc_en     ),                          
    .crc_clr         (crc_clr    ),                         
    .crc_data        (crc_data   ),                        
    .crc_next        (crc_next   )                         
    );

endmodule