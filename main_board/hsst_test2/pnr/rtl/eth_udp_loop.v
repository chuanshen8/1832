module eth_udp_loop
(
    input               sys_clk     , //系统时钟
    input               sys_rst_n   , //系统复位信号，低电平有效 
    //PL以太网RGMII接口    
    input               eth_rxc     , //RGMII接收数据时钟
    input               eth_rx_ctl  , //RGMII输入数据有效信号
    input       [ 3:0]  eth_rxd     , //RGMII输入数据
    output              eth_txc     , //RGMII发送数据时钟    
    output              eth_tx_ctl  , //RGMII输出数据有效信号
    output      [ 3:0]   eth_txd    , //RGMII输出数据          
    output              eth_rst_n   ,  //以太网芯片复位信号，低电平有效   
    output              gmii_tx_clk ,
    output              tx_req      ,
    input       [31:0]  tx_data     ,
    output              tx_req1      ,
    input       [31:0]  tx_data1     ,
    input               tx_start_en ,
    output              udp_tx_done ,
    output      [ 2:0]  done_cnt    ,
    //HSST
    input               tx3_clk     ,
    output  reg [ 3:0]  hsst_txk3   ,
    output  reg [31:0]  hsst_txd3
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

wire  [31:0]  rx_buf_rddata;
reg           rx_buf_rden;
reg   [ 2:0]  tx_state;
reg           rec_pkt_done_d1;
reg           rec_pkt_done_d2;
reg   [ 8:0]  hsst_tx_cnt;

//*****************************************************
//**                    main code
//*****************************************************

// assign tx_start_en = rec_pkt_done;
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
u_arp
(
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
u_udp
(
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
    .tx_data1       (tx_data1     ),         
    .tx_byte_num   (tx_byte_num ),  
    .des_mac       (des_mac     ),
    .des_ip        (des_ip      ),    
    .tx_done       (udp_tx_done ),        
    .tx_req        (tx_req      ),
    .tx_req1        (tx_req1      ),
    .done_cnt       (done_cnt)  ,
    .tx_data_en    (tx_data_en)  
); 

eth_ctrl u_eth_ctrl
(
    .clk            (gmii_rx_clk   ),
    .rst_n          (sys_rst_n     ),

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

eth_rx_buf eth_rx_buf_inst 
(
  .wr_clk       (gmii_rx_clk    ),               
  .wr_rst       (~sys_rst_n     ),               
  .wr_en        (rec_en         ),                 
  .wr_data      (rec_data       ),             
  .wr_full      (               ),             
  .almost_full  (               ),  
  
  .rd_clk       (tx3_clk        ),               
  .rd_rst       (~sys_rst_n     ),               
  .rd_en        (rx_buf_rden    ),                 
  .rd_data      (rx_buf_rddata  ),             
  .rd_empty     (               ),           
  .almost_empty (               )    
);

always@(posedge tx3_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        begin
            rec_pkt_done_d1 <= 1'b0;
            rec_pkt_done_d2 <= 1'b0;
        end
    else 
        begin
            rec_pkt_done_d1 <= rec_pkt_done;
            rec_pkt_done_d2 <= rec_pkt_done_d1;        
        end

always@(posedge tx3_clk or negedge sys_rst_n)
    if(!sys_rst_n)
        begin
            tx_state    <= 3'd0;
            rx_buf_rden <= 1'b0;
            hsst_txd3   <= 32'hff_00_00_bc;
            hsst_txk3   <= 4'b0001;
            hsst_tx_cnt <= 9'd0;
        end
    else
        case(tx_state)
            3'd0 :
                begin
                    if(rec_pkt_done_d2)
                        begin
                            tx_state    <= 3'd1;
                            rx_buf_rden <= 1'b1;
                            hsst_txd3   <= 32'hff_00_00_bc;
                            hsst_txk3   <= 4'b0001;
                            hsst_tx_cnt <= 9'd0;
                        end
                    else 
                        begin
                            tx_state    <= 3'd0;
                            rx_buf_rden <= 1'b0;
                            hsst_txd3   <= 32'hff_00_00_bc;
                            hsst_txk3   <= 4'b0001;
                            hsst_tx_cnt <= 9'd0;
                        end
                end
            3'd1 :
                begin
                    tx_state    <= 3'd2;
                    rx_buf_rden <= 1'b1;
                    hsst_txd3   <= 32'hff_00_00_bc;
                    hsst_txk3   <= 4'b0001;
                    hsst_tx_cnt <= 9'd0;
                end
            3'd2 :
                begin
                    if(hsst_tx_cnt == 9'd128)
                        begin
                            tx_state    <= 3'd0;
                            rx_buf_rden <= 1'b0;
                            hsst_txd3   <= 32'hff_00_00_bc;
                            hsst_txk3   <= 4'b0001;
                            hsst_tx_cnt <= 9'd0;
                        end          
                    else if(hsst_tx_cnt == 9'd126)
                        begin
                            tx_state    <= 3'd2;
                            rx_buf_rden <= 1'b0;
                            hsst_txd3   <= rx_buf_rddata;
                            hsst_txk3   <= 4'b0000;
                            hsst_tx_cnt <= hsst_tx_cnt + 1'b1;
                        end
                    else
                        begin
                            tx_state    <= 3'd2;
                            rx_buf_rden <= 1'b1;
                            hsst_txd3   <= rx_buf_rddata;
                            hsst_txk3   <= 4'b0000;
                            hsst_tx_cnt <= hsst_tx_cnt + 1'b1;
                        end
                end
            default : 
                begin
                   tx_state    <= 3'd0;
                   rx_buf_rden <= 1'b0;
                   hsst_txd3   <= 32'hff_00_00_bc;
                   hsst_txk3   <= 4'b0001;
                   hsst_tx_cnt <= 9'd0;
                end
        endcase

endmodule