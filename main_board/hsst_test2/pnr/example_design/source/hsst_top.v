module hsst_top
(
    //sys
    input                      free_clk       ,   //50M
    input                      rst_n          ,
    
    //key_in
    input       wire           key_in         ,   
    input       wire           key_in_2       ,
    input       wire           key_udp_send    ,
    
    //ad_in
    input       wire  [7:0]    ad_data        ,
    output      wire           ad_clk         , 
    
    //hdmi_in
    input       wire           pixclk_in      ,
    input       wire           vs_in          ,
    input       wire           de_in          ,
    input       wire           hs_in          ,
    input       wire  [7:0]    r_in           ,
    input       wire  [7:0]    g_in           ,
    input       wire  [7:0]    b_in           ,
    
    //hdmi_out
    output      wire           pix_clk        ,
    output      wire           vs_out         ,
    output      wire           de_out         ,
    output      wire           hs_out         ,
    output      wire  [7:0]    r_out          ,
    output      wire  [7:0]    g_out          ,
    output      wire  [7:0]    b_out          ,
                                             
    //hdmi_phy                               
    output      wire           iic_scl        ,
    inout       wire           iic_sda        ,
    output      wire           iic_tx_scl     ,
    inout       wire           iic_tx_sda     ,
    
    //eth 
    input       wire           eth_rxc        ,
    input       wire           eth_rx_ctl     ,
    input       wire  [3:0]    eth_rxd        ,
    output      wire           eth_txc        ,
    output      wire           eth_tx_ctl     ,
    output      wire  [3:0]    eth_txd        ,
    output      wire           eth_rst_n      ,
    
    //HSST
    input       wire           i_p_refckn_0   ,
    input       wire           i_p_refckp_0   ,
    input       wire           i_p_l2rxn      ,
    input       wire           i_p_l2rxp      ,
    input       wire           i_p_l3rxn      ,
    input       wire           i_p_l3rxp      ,
    output      wire           o_p_l2txn      ,
    output      wire           o_p_l2txp      ,
    output      wire           o_p_l3txn      ,
    output      wire           o_p_l3txp      ,
    output      wire           SFP_TX_DISABLE0,
    output      wire           SFP_TX_DISABLE1
    
);
//SYS
wire            free_clk_g ;
wire            pll_lock   ;
wire            sys_rst_n  ;
wire            cfg_clk    ;
wire            key_flag   ;
wire            key_flag_2 ;


reg            key_udp_send_d0 ;
reg            key_udp_send_d1 ;

//HSST_TX
wire            tx2_clk ;
wire    [ 3:0]  hsst_txk;
wire    [31:0]  hsst_txd;

wire            tx3_clk  ;
wire    [ 3:0]  hsst_txk3;
wire    [31:0]  hsst_txd3;

//HSST_RX
wire            rx2_clk   ;
wire    [ 3:0]  hsst_rxk  ;
wire    [31:0]  hsst_rxd  ;
wire    [ 3:0]  align_rxk ;
wire    [31:0]  align_rxd ;  

//ad_data_process
wire    [7:0]   ad_data_1 ;
wire            ad_clk_1  ;
                                    
wire    [15:0]  fft_data_1        ;
wire            fft_data_valid_1  ;    
wire    [15:0]  real_data_1   /*synthesis PAP_MARK_DEBUG="1"*/    ;    
wire            real_data_valid_1 /*synthesis PAP_MARK_DEBUG="1"*/;
                                  
wire    [15:0]  fft_data          ;
wire            fft_data_valid    ;    
wire    [15:0]  real_data         ;    
wire            real_data_valid   ;
                                    
wire            fft_fifo_full_1     ;
wire            real_fifo_full_1    ;
wire            fft_fifo_rden_1     ;
wire    [15:0]  fft_fifo_rddata_1   ;
wire            real_fifo_rden_1    ;
wire    [15:0]  real_fifo_rddata_1  ;

wire            fft_fifo_full       ;
wire            real_fifo_full      ;
wire            fft_fifo_rden       ;
wire    [15:0]  fft_fifo_rddata     ;
wire            real_fifo_rden      ;
wire    [15:0]  real_fifo_rddata    ;

//vesa
wire            vs     ;
wire            hs     ;
wire            de     ;
wire    [11:0]  x_act  ;
wire    [11:0]  y_act  ;

//dram
wire    [ 2:0]  cnt_key      ;
wire            point_done   ;
wire            dram_rd_clk  ;
wire    [10:0]  dram_rd_addr ;
wire    [15:0]  dram_rd_data ;
wire    [10:0]  dram_wr_addr ;
wire            dram_wr_en   ;
wire    [15:0]  dram_wr_data ;

//eth 
wire            eth_wr_full    ;
wire            eth_wr_full1    ;
reg             eth_wr_full_d1 ;
wire            eth_rd_trg     ;
wire            gmii_tx_clk    ;
wire            tx_req         ;
wire   [31:0]   tx_data        ;
wire            tx_req1         ;
wire   [31:0]   tx_data1        ;
wire   [ 2:0]   done_cnt       ;
reg    [27:0]   full_cnt       ;

assign          sys_rst_n       = pll_lock && rst_n;
assign          SFP_TX_DISABLE0 = 1'b0 ;
assign          SFP_TX_DISABLE1 = 1'b0 ;


always @(posedge free_clk or negedge rst_n) begin
    if(rst_n == 'd0 )begin
        key_udp_send_d0 <= 'd0 ;
        key_udp_send_d1 <= 'd0 ;
    end
    else  begin
        key_udp_send_d0 <= key_udp_send ;
        key_udp_send_d1 <= key_udp_send_d0 ;      
    end  
end

reg     [23:0] key1_cnt_time;

always @(posedge free_clk or negedge rst_n)begin
    if(!rst_n)begin
        key1_cnt_time <= 24'b0;
    end
    else begin
        if(key_udp_send_d1)
            key1_cnt_time <= 24'b0; 
        else if(key1_cnt_time >= 2500000)  
            key1_cnt_time <= key1_cnt_time;
        else
            key1_cnt_time <= key1_cnt_time + 1;                 
    end 
end

reg   key1_pulse  ;

always @(posedge free_clk or negedge rst_n)begin
    if(!rst_n)
        key1_pulse <= 1'b0;
    else if(key1_cnt_time == 500_000) 
        key1_pulse <= 1'b1;
    else 
        key1_pulse <= 1'b0;
end

GTP_CLKBUFG free_clk_ibufg 
(
    .CLKOUT(free_clk_g),
    .CLKIN (free_clk  )
);

pll_1 pll_1_inst 
(
  .clkin1   (free_clk_g ),      // input
  .pll_lock (pll_lock   ),      // output
  .clkout0  (pix_clk    ),      // output   74.25M
  .clkout1  (cfg_clk    ),      // output
  .clkout2  (ad_clk     )       // output
); 

key_filter  key_filter_inst1
(
    .sys_clk    (free_clk_g ) ,   //input   wire    
    .sys_rst_n  (sys_rst_n  ) ,   //input   wire    
    .key_in     (key_in     ) ,   //input   wire    

    .key_flag   (key_flag   )     //output  reg                                  
);

key_filter  key_filter_inst2
(
    .sys_clk    (free_clk_g ) ,   //input   wire    
    .sys_rst_n  (sys_rst_n  ) ,   //input   wire    
    .key_in     (key_in_2   ) ,   //input   wire    

    .key_flag   (key_flag_2 )     //output  reg                                  
);

ms72xx_ctl  ms72xx_ctl_inst
(
    .clk        (cfg_clk   ), //input       
    .rst_n      (sys_rst_n ), //input       
                
    .init_over  (          ), //output      
    .iic_tx_scl (iic_tx_scl), //output      
    .iic_tx_sda (iic_tx_sda), //inout       
    .iic_scl    (iic_scl   ), //output      
    .iic_sda    (iic_sda   )  //inout       
); 

hdmi_tx hdmi_tx_inst 
(
    .rst       ( ~sys_rst_n      ),
    .tx_clk    ( tx2_clk         ),
    .pclk      ( pixclk_in       ),
    .vs        ( vs_in           ),
    .de        ( de_in           ),
    .vin_data  ( {r_in[7:3] , g_in[7:2] , b_in[7:3]} ),
    .vin_width ( 16'd1920        ),
    
    .gt_tx_data( hsst_txd        ),
    .gt_tx_ctrl( hsst_txk        )
);

hsst_test_dut_top    hsst_test_dut_top_inst
(
    //GT2_TX
    .gt2_txfsmresetdone    (              ),    //LANE_2 初始化完成    output         
    .tx2_clk               (tx2_clk       ),    //LANE_2 发送时钟      output         
    .tx2_data              (hsst_txd      ),    //LANE_2 发送数据      input  [31:0]  
    .tx2_kchar             (hsst_txk      ),    //LANE_2 发送数据K码   input  [3:0]   
    //GT2_RX                              
    .rx2_clk               (rx2_clk       ),    //LANE_2 接收时钟      output         
    .o_rxd_2               (hsst_rxd      ),    //LANE_2 接收数据      output [39:0]  
    .o_rxk_2               (hsst_rxk      ),    //LANE_2 接收数据K码   output [3:0]   
    //GT3_TX
    .gt3_txfsmresetdone    (              ),    //LANE_3 初始化完成    output         
    .tx3_clk               (tx3_clk       ),    //LANE_3 发送时钟      output         
    .tx3_data              (hsst_txd3     ),    //LANE_3 发送数据      input  [31:0]  
    .tx3_kchar             (hsst_txk3     ),    //LANE_3 发送数据K码   input  [3:0]   
    //GT3_RX                                      
    .rx3_clk               (              ),    //LANE_3 接收时钟      output         
    .o_rxd_3               (              ),    //LANE_3 接收数据      output [39:0]  
    .o_rxk_3               (              ),    //LANE_3 接收数据K码   output [3:0]   
    
    .i_free_clk            (free_clk_g    ),    //input          
    .rst_n                 (sys_rst_n     ),
    .i_p_refckn_0          (i_p_refckn_0  ),    //input          
    .i_p_refckp_0          (i_p_refckp_0  ),    //input               
    .i_p_l2rxn             (i_p_l2rxn     ),    //input          
    .i_p_l2rxp             (i_p_l2rxp     ),    //input          
    .i_p_l3rxn             (i_p_l3rxn     ),    //input          
    .i_p_l3rxp             (i_p_l3rxp     ),    //input          
    .o_p_l2txn             (o_p_l2txn     ),    //output         
    .o_p_l2txp             (o_p_l2txp     ),    //output         
    .o_p_l3txn             (o_p_l3txn     ),    //output         
    .o_p_l3txp             (o_p_l3txp     )     //output        

);

//数据对齐
word_align  word_align_inst
(
    .rx_clk    (rx2_clk  ) ,  //input       wire            
    .rst_n     (sys_rst_n ) ,  //input       wire            

    .hsst_rxd  (hsst_rxd ) ,  //input       wire   [31:0]   
    .hsst_rxk  (hsst_rxk ) ,  //input       wire   [ 3:0]   

    .align_rxd (align_rxd ) ,  //output      wire   [31:0]   
    .align_rxk (align_rxk )    //output      wire   [ 4:0]   
);

//数据解码
hsst_ad  hsst_ad_inst
(
    .rx_clk           (rx2_clk         ) ,   //input           wire            
    .sys_clk          (free_clk_g      ) ,   //input           wire            
    .rst_n            (sys_rst_n       ) ,   //input           wire            

    .hsst_align_data  (align_rxd       ) ,   //input           wire    [31:0]  
    .hsst_align_k     (align_rxk       ) ,   //input           wire    [ 3:0]  

    .ad_clk           (ad_clk_1        ) ,   //output          wire    fifo_rd_clk && ad_data_valid
    .ad_data          (ad_data_1       )     //output          wire    [7:0]   
);            

adc_fft_top   adc_fft_top_inst_1
(
    .clk             (free_clk_g        ),  //input           wire                
    .rst_n           (sys_rst_n         ),  //input           wire       
                                        
    .ad_data         (ad_data_1         ),  //input           wire        [7:0]    
    .ad_clk          (ad_clk_1          ),  //input           wire        
    
    .fft_data_valid  (fft_data_valid_1  ),  //output          wire                
    .fft_data        (fft_data_1        ),  //output          wire        [15:0]  
    .real_data_valid (real_data_valid_1 ),  //output          wire                
    .real_data       (real_data_1       )   //output          wire        [15:0]  
);

adc_fft_top   adc_fft_top_inst
(
    .clk             (free_clk_g        ),  //input           wire                
    .rst_n           (sys_rst_n         ),  //input           wire       
                                        
    .ad_data         (ad_data           ),  //input           wire        [7:0]    
    .ad_clk          (ad_clk            ),  //input           wire        
    
    .fft_data_valid  (fft_data_valid    ),  //output          wire                
    .fft_data        (fft_data          ),  //output          wire        [15:0]  
    .real_data_valid (real_data_valid   ),  //output          wire                
    .real_data       (real_data         )   //output          wire        [15:0]  
);

///////////////////////////////////////////////////////////////////////////////////////FIFO
//hsst_fft_fifo
fifo_16x256 freq_fifo_1
(
  .wr_clk       (free_clk_g         ),   // input       
  .wr_rst       (~sys_rst_n         ),   // input       
  .wr_en        (fft_data_valid_1   ),   // input         
  .wr_data      (fft_data_1         ),   // input [15:0]     
  .wr_full      (fft_fifo_full_1    ),   // output     
  .almost_full  (                   ),   // output
  .rd_clk       (free_clk_g         ),   // input       
  .rd_rst       (~sys_rst_n         ),   // input       
  .rd_en        (fft_fifo_rden_1    ),   // input         
  .rd_data      (fft_fifo_rddata_1  ),   // output [15:0]     
  .rd_empty     (                   ),   // output   
  .almost_empty (                   )    // output
);
//hsst_real_fifo
fifo_16x256 real_fifo_1
(
  .wr_clk       (free_clk_g          ),   // input       
  .wr_rst       (~sys_rst_n          ),   // input       
  .wr_en        (real_data_valid_1   ),   // input         
  .wr_data      (real_data_1         ),   // input [15:0]     
  .wr_full      (real_fifo_full_1    ),   // output     
  .almost_full  (                    ),   // output
  .rd_clk       (free_clk_g          ),   // input       
  .rd_rst       (~sys_rst_n          ),   // input       
  .rd_en        (real_fifo_rden_1    ),   // input         
  .rd_data      (real_fifo_rddata_1  ),   // output [15:0]     
  .rd_empty     (                    ),   // output   
  .almost_empty (                    )    // output
);
//ad_freq_fifo
fifo_16x256 freq_fifo 
(
  .wr_clk       (free_clk_g         ),   // input       
  .wr_rst       (~sys_rst_n         ),   // input       
  .wr_en        (fft_data_valid     ),   // input         
  .wr_data      (fft_data           ),   // input [15:0]     
  .wr_full      (fft_fifo_full      ),   // output     
  .almost_full  (                   ),   // output
  .rd_clk       (free_clk_g         ),   // input       
  .rd_rst       (~sys_rst_n         ),   // input       
  .rd_en        (fft_fifo_rden      ),   // input         
  .rd_data      (fft_fifo_rddata    ),   // output [15:0]     
  .rd_empty     (                   ),   // output   
  .almost_empty (                   )    // output
);
//ad_real_fifo
fifo_16x256 real_fifo 
(
  .wr_clk       (free_clk_g          ),   // input       
  .wr_rst       (~sys_rst_n          ),   // input       
  .wr_en        (real_data_valid     ),   // input         
  .wr_data      (real_data           ),   // input [15:0]     
  .wr_full      (real_fifo_full      ),   // output     
  .almost_full  (                    ),   // output
  .rd_clk       (free_clk_g          ),   // input       
  .rd_rst       (~sys_rst_n          ),   // input       
  .rd_en        (real_fifo_rden      ),   // input         
  .rd_data      (real_fifo_rddata    ),   // output [15:0]     
  .rd_empty     (                    ),   // output   
  .almost_empty (                    )    // output
);

dram_ctrl   dram_ctrl_inst
(
    .clk               (free_clk_g        ),   //input       wire                
    .rst_n             (sys_rst_n         ),   //input       wire                
    .pix_clk           (pix_clk           ),   //input       wire 
    .key_flag          (key_flag          ),
    .key_flag_2        (key_flag_2        ),
    .cnt_key           (cnt_key           ),
    //fifo_freq_1     
    .fifo_full_freq_1  (fft_fifo_full_1   ),   //input       wire                
    .fifo_rddata_freq_1(fft_fifo_rddata_1 ),   //input       wire    [15:0]      
    .fifo_rden_freq_1  (fft_fifo_rden_1   ),   //output      reg                 
    //fifo_real_1  
    .fifo_full_real_1  (real_fifo_full_1  ),   //input       wire                
    .fifo_rddata_real_1(real_fifo_rddata_1),   //input       wire    [15:0]      
    .fifo_rden_real_1  (real_fifo_rden_1  ),   //output      reg     
    //fifo_freq     
    .fifo_full_freq    (fft_fifo_full     ),   //input       wire                
    .fifo_rddata_freq  (fft_fifo_rddata   ),   //input       wire    [15:0]      
    .fifo_rden_freq    (fft_fifo_rden     ),   //output      reg                 
    //fifo_real                           
    .fifo_full_real    (real_fifo_full    ),   //input       wire                
    .fifo_rddata_real  (real_fifo_rddata  ),   //input       wire    [15:0]      
    .fifo_rden_real    (real_fifo_rden    ),   //output      reg     
    //vesa           
    .act_y             (y_act             ),   //input       wire     [11:0]     
    .de_in             (de                ),   //input       wire          
    .vs_in             (~vs               ),   //input       wire
    .point_done        (point_done        ),   //input       wire                
    //dram                                
    .dram_rd_clk       (dram_rd_clk       ),   //output      wire                
    .dram_rd_addr      (dram_rd_addr      ),   //output      reg       [9:0]      
    .dram_wr_en        (dram_wr_en        ),   //output      reg                 
    .dram_wr_addr      (dram_wr_addr      ),   //output      reg       [9:0]      
    .dram_wr_data      (dram_wr_data      )    //output      reg      [15:0]     
);

dram_16x512 dram_16x512_inst 
(
  .wr_data (dram_wr_data ),  // input [15:0]  
  .wr_addr (dram_wr_addr ),  // input [10:0]  
  .wr_en   (dram_wr_en   ),  // input      
  .wr_clk  (free_clk_g   ),  // input    
  .wr_rst  (~sys_rst_n   ),  // input    
  
  .rd_addr (dram_rd_addr ),  // input  [10:0]  
  .rd_data (dram_rd_data ),  // output [15:0]  
  .rd_clk  (dram_rd_clk  ),  // input    
  .rd_rst  (~sys_rst_n   )   // input    
);

sync_vg # 
(
    .X_BITS  ( 4'd12  ),
    .Y_BITS  ( 4'd12  ),
    .V_TOTAL (12'd750 ),
    .V_FP    (12'd5   ),
    .V_BP    (12'd20  ),
    .V_SYNC  (12'd5   ),
    .V_ACT   (12'd720 ),
    .H_TOTAL (12'd1650),
    .H_FP    (12'd110 ),
    .H_BP    (12'd220 ),
    .H_SYNC  (12'd40  ),
    .H_ACT   (12'd1280)
)
sync_vg_inst
(
    .clk    (pix_clk  ) , //input                   
    .rstn   (sys_rst_n) , //input                   
    .vs_out (vs       ) , //output reg              
    .hs_out (hs       ) , //output reg              
    .de_out (de       ) , //output reg              
    .x_act  (x_act    ) , //output reg [X_BITS-1:0] 
    .y_act  (y_act    )   //output reg [Y_BITS-1:0] 
);

pattern_vg   pattern_vg_inst
(                                       
    .rstn          (sys_rst_n   ),  //input                                
    .pix_clk       (pix_clk     ),  //input                                
    .act_x         (x_act       ),  //input [X_BITS-1:0]                   
    .act_y         (y_act       ),  //input [Y_BITS-1:0]                   
    .vs_in         (vs          ),  //input                                
    .hs_in         (hs          ),  //input                                
    .de_in         (de          ),  //input                                
                                
    .vs_out        (vs_out      ),  //output reg                           
    .hs_out        (hs_out      ),  //output reg                           
    .de_out        (de_out      ),  //output reg                           
    .r_out         (r_out       ),  //output wire [COCLOR_DEPP-1:0]        
    .g_out         (g_out       ),  //output wire [COCLOR_DEPP-1:0]        
    .b_out         (b_out       ),  //output wire [COCLOR_DEPP-1:0]        

    .cnt_key       (cnt_key     ),  //input [ 2:0]
	.dram_data     (dram_rd_data),  //input [15:0]					       
	.point_done    (point_done  )   //output								 
); 

//ETH_TX
always@(posedge free_clk_g or negedge sys_rst_n)
    if(!sys_rst_n)
        eth_wr_full_d1 <= 1'b0;
    else 
        eth_wr_full_d1 <= eth_wr_full;
 
assign  eth_rd_trg = eth_wr_full && eth_wr_full1 && key1_pulse ;

always @(posedge free_clk_g or negedge sys_rst_n) 
    if(!sys_rst_n)
         full_cnt <= 1'b0;
    else if(eth_wr_full && eth_wr_full1 && full_cnt == 'd100000000)
        full_cnt <= 1'b0;
    else if(eth_wr_full && eth_wr_full1)
        full_cnt <= full_cnt + 1'b1;
       
fifo_eth ad_data_inst
(
  .wr_clk        (ad_clk         ),  // input         
  .wr_rst        (~sys_rst_n     ),  // input        
  .wr_en         (real_data_valid           ),  // input          
  .wr_data       (real_data        ),  // input [7:0]      
  .wr_full       (eth_wr_full    ),  // output      
  .almost_full   (               ),  // output
                                     
  .rd_clk        (gmii_tx_clk    ),  // input        
  .rd_rst        (~sys_rst_n     ),  // input        
  .rd_en         (tx_req         ),  // input          
  .rd_data       (tx_data        ),  // output [31:0]      
  .rd_empty      (               ),  // output    
  .almost_empty  (               )   // output
);

fifo_eth hsst_data_inst
(
  .wr_clk        (free_clk_g        ),  // input         
  .wr_rst        (~sys_rst_n        ),  // input        
  .wr_en         (real_data_valid_1 ),  // input          
  .wr_data       (real_data_1       ),  // input [7:0]      
  .wr_full       (eth_wr_full1                ),  // output      
  .almost_full   (                  ),  // output
                                     
  .rd_clk        ( gmii_tx_clk                ),  // input        
  .rd_rst        (   ~sys_rst_n               ),  // input        
  .rd_en         (  tx_req1               ),  // input          
  .rd_data       (  tx_data1               ),  // output [31:0]      
  .rd_empty      (                 ),  // output    
  .almost_empty  (                 )   // output
);

//ETH_RX
eth_udp_loop eth_udp_loop 
(
    .sys_clk     (free_clk_g ), //系统时钟
    .sys_rst_n   (sys_rst_n  ), //系统复位信号，低电平有效 
    //PL以太网RGMII接口   
    .eth_rxc     (eth_rxc    ), //RGMII接收数据时钟
    .eth_rx_ctl  (eth_rx_ctl ), //RGMII输入数据有效信号
    .eth_rxd     (eth_rxd    ), //RGMII输入数据 [3:0]
    .eth_txc     (eth_txc    ), //RGMII发送数据时钟    
    .eth_tx_ctl  (eth_tx_ctl ), //RGMII输出数据有效信号
    .eth_txd     (eth_txd    ), //RGMII输出数据´ [3:0]         
    .eth_rst_n   (eth_rst_n  ), //以太网芯片复位信号，低电平有效  
    .gmii_tx_clk (gmii_tx_clk),
    .tx_req      (tx_req     ),
    .tx_data     (tx_data    ),
    .tx_req1      (tx_req1     ),
    .tx_data1     (tx_data1    ),
    .tx_start_en (eth_rd_trg ),
    .udp_tx_done (udp_tx_done),
    .done_cnt    (done_cnt   ),
    
    .tx3_clk     (tx3_clk    ),
    .hsst_txk3   (hsst_txk3  ),
    .hsst_txd3   (hsst_txd3  )
);
   
endmodule