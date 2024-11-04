`timescale 1ns / 1ps
module hdmi_ddr_ov5640_top#(
	parameter MEM_ROW_ADDR_WIDTH     = 15        ,
	parameter MEM_COL_ADDR_WIDTH     = 10        ,
	parameter MEM_BADDR_WIDTH        = 3         ,
	parameter MEM_DQ_WIDTH           = 32        ,
	parameter MEM_DQS_WIDTH          = 32/8      ,
     parameter MEM_DM_WIDTH           = MEM_DQ_WIDTH/8
)(
    input                                sys_clk            ,//50Mhz
    input                                sys_rst_n          ,

    //DDR3
    output                               mem_rst_n          ,
    output                               mem_ck             ,
    output                               mem_ck_n           ,
    output                               mem_cke            ,
    output                               mem_cs_n           ,
    output                               mem_ras_n          ,
    output                               mem_cas_n          ,
    output                               mem_we_n           ,
    output                               mem_odt            ,
    output      [MEM_ROW_ADDR_WIDTH-1:0] mem_a              ,
    output      [MEM_BADDR_WIDTH-1:0]    mem_ba             ,
    inout       [MEM_DQ_WIDTH/8-1:0]     mem_dqs            ,
    inout       [MEM_DQ_WIDTH/8-1:0]     mem_dqs_n          ,
    inout       [MEM_DQ_WIDTH-1:0]       mem_dq             ,
    output      [MEM_DQ_WIDTH/8-1:0]     mem_dm             ,
    // output reg                           heart_beat_led     ,
    // output                               ddr_init_done      ,



    //MS72xx配置
    output            rstn_out1,
    output            rstn_out2,
    output            rstn_out3,
    output            iic_scl,
    inout             iic_sda, 

    output            iic_rx_scl,
    inout             iic_rx_sda, 

   //HDMI_IN
    input                                pixclk_in1		    ,                      
    input                                vs_in1			    , 
    input                                hs_in1			    , 
    input                                de_in1			    ,
    input   [7:0]                        r_in1			    , 
    input   [7:0]                        g_in1			    , 
    input   [7:0]                        b_in1			    , 

	   //HDMI_IN
    input                                pixclk_in2		    ,                      
    input                                vs_in2			    , 
    input                                hs_in2			    , 
    input                                de_in2			    ,
    input   [7:0]                        r_in2			    , 
    input   [7:0]                        g_in2			    , 
    input   [7:0]                        b_in2			    , 

	   //HDMI_IN
    input                                pixclk_in3		    ,                      
    input                                vs_in3			    , 
    input                                hs_in3			    , 
    input                                de_in3			    ,
    input   [7:0]                        r_in3			    , 
    input   [7:0]                        g_in3			    , 
    input   [7:0]                        b_in3			    , 

    //HDMI_OUT
    output                               pix_clk            ,                          
    output     reg                       vs_out             , 
    output     reg                       hs_out             , 
    output     reg                       de_out             ,
    output     reg[7:0]                  r_out              , 
    output     reg[7:0]                  g_out              , 
    output     reg[7:0]                  b_out  		    ,

    input							key1			   ,//控制缩小
    input							key2			   ,//控制放大
    input							key3			   ,//控制灰度显示
    input							key4			   ,//控制亮度
    input							key5			   ,
    input							key6			   ,
    input							key7			   	,
	
	input       wire  [7:0]    ad_data        /*synthesis PAP_MARK_DEBUG="1"*/,
    output      wire           ad_clk         /*synthesis PAP_MARK_DEBUG="1"*/, 
    
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
   output      wire           SFP_TX_DISABLE2 ,
   output      wire           SFP_TX_DISABLE3 

);
/////////////////////////////////////////////////////////////////////////////////////
// ENABLE_DDR
parameter CTRL_ADDR_WIDTH = MEM_ROW_ADDR_WIDTH + MEM_BADDR_WIDTH + MEM_COL_ADDR_WIDTH;//28
parameter TH_1S = 27'd33000000;
/////////////////////////////////////////////////////////////////////////////////////
    reg    [15:0]               rstn_1ms            ;

//测试代码
    wire   [15:0]               o_rgb565            ;
    wire                        pclk_in_test        ;    
    wire                        vs_in_test          ;
    wire                        de_in_test          ;
    wire   [15:0]               i_rgb565            ;
    wire                        de_re               ;


//axi bus   
    wire [CTRL_ADDR_WIDTH-1:0]  axi_awaddr                 /*synthesis PAP_MARK_DEBUG="1"*/;
    wire                        axi_awuser_ap              ;
    wire [3:0]                  axi_awuser_id              ;
    wire [3:0]                  axi_awlen                  /*synthesis PAP_MARK_DEBUG="1"*/;
    wire                        axi_awready                /*synthesis PAP_MARK_DEBUG="1"*/;
    wire                        axi_awvalid                /*synthesis PAP_MARK_DEBUG="1"*/;
    wire [MEM_DQ_WIDTH*8-1:0]   axi_wdata                  /*synthesis PAP_MARK_DEBUG="1"*/;
    wire [MEM_DQ_WIDTH*8/8-1:0] axi_wstrb                  ;
    wire                        axi_wready                 /*synthesis PAP_MARK_DEBUG="1"*/;
    wire [3:0]                  axi_wusero_id              ;
    wire                        axi_wusero_last            /*synthesis PAP_MARK_DEBUG="1"*/;
    wire [CTRL_ADDR_WIDTH-1:0]  axi_araddr                 /*synthesis PAP_MARK_DEBUG="1"*/;
    wire                        axi_aruser_ap              ;
    wire [3:0]                  axi_aruser_id              ;
    wire [3:0]                  axi_arlen                  /* synthesis syn_keep = 1 */;
    wire                        axi_arready                /* synthesis syn_keep = 1 */;
    wire                        axi_arvalid                /*synthesis PAP_MARK_DEBUG="1"*/;
    wire [MEM_DQ_WIDTH*8-1:0]   axi_rdata                  /* synthesis syn_keep = 1 *//*synthesis PAP_MARK_DEBUG="1"*/;
    wire                        axi_rvalid                 /* synthesis syn_keep = 1 */;
    wire [3:0]                  axi_rid                    ;
    wire                        axi_rlast                  ;
    reg  [26:0]                 cnt                        ;
    reg  [15:0]                 cnt_1                      ;
/////////////////////////////////////////////////////////////////////////////////////
//PLL
pll u_pll (
    .clkin1   (  sys_clk    ),//50MHz
    .clkout0  (  pix_clk    ),//148.5M 1080P@60fps
    .clkout1  (  cfg_clk    ),//10MHz
    .clkout2  (  clk_25M    ),//25M
    .clkout3  (  clk_50M    ),//50M
    .clkout4  (  clk_100M   ),//100M
    .pll_lock (  locked     )
);

wire init_over/*synthesis PAP_MARK_DEBUG="true"*/;
wire  init_over_2   ;

ms72xx_ctl ms72xx_ctl_inst1(
	.clk(cfg_clk),              // input
	.rst_n(rstn_out1 && init_over_2),          // input
	.init_over(init_over),  // output
	.iic_scl(iic_scl),      // output
	.iic_sda(iic_sda)       // inout
);
//����HDMI_IN1 ��HDMI_IN2
ms7200_double_crtl ms7200_double_crtl_inst(
	.clk(cfg_clk),              // input
	.rst_n(rstn_out1),          // input
	.init_over(init_over_2),  // output
	.iic_scl(iic_rx_scl),      // output
	.iic_sda(iic_rx_sda)       // inout
);



always @(posedge cfg_clk)
begin
	if(!locked)
		rstn_1ms <= 16'd0;
	else
	begin
		if(rstn_1ms == 16'h4000)
			rstn_1ms <= rstn_1ms;
		else
			rstn_1ms <= rstn_1ms + 1'b1;
	end
end

assign rstn_out1 = (rstn_1ms == 16'h4000);
assign rstn_out2 = rstn_out1;
assign rstn_out3 = rstn_out1;
wire    rstn_out   ;
assign   rstn_out  =   rstn_out1;


/////////////////////////////////////////////////////////////////////////////////////
//笔记本电脑HDMI图像输入双线性插值缩放 1920*1080--->960*540
//channel3和channel4是一样的
wire     [7:0]      data_out_r1                ;
wire     [7:0]      data_out_g1                ;
wire     [7:0]      data_out_b1                ;
wire                data_out_valid1            ;

wire     [7:0]      data_out_r2                ;
wire     [7:0]      data_out_g2                ;
wire     [7:0]      data_out_b2                ;
wire                data_out_valid2            ;

wire     [7:0]      data_out_r3                ;
wire     [7:0]      data_out_g3                ;
wire     [7:0]      data_out_b3                ;
wire                data_out_valid3            ;

wire     [7:0]      data_out_r4                ;
wire     [7:0]      data_out_g4                ;
wire     [7:0]      data_out_b4                ;
wire                data_out_valid4            ;

wire     [15:0]     channel_1_data            ;
wire 		        channel_1_data_valid      ;
wire     [15:0]     channel_2_data            ;
wire                channel_2_data_valid      ;


wire     [15:0]     channel_3_data            ;
wire                channel_3_data_valid      ;
wire     [15:0]     channel_4_data            ;
wire                channel_4_data_valid      ;


reg     [15:0]     channel_6_data            ;
reg                channel_6_data_valid      ;



assign channel_3_data_valid   =    data_out_valid3                                        ;
assign channel_3_data         =    {data_out_r3[7:3],data_out_g3[7:2],data_out_b3[7:3]}    ;
assign channel_4_data_valid   =    data_out_valid4                                 ;
assign channel_4_data         =    {data_out_r4[7:3],data_out_g4[7:2],data_out_b4[7:3]}                                      ;
assign channel_1_data_valid   =    data_out_valid1                                        ;
assign channel_1_data         =    {data_out_r1[7:3],data_out_g1[7:2],data_out_b1[7:3]}    ;
assign channel_2_data_valid   =    data_out_valid2                                 ;
assign channel_2_data         =    {data_out_r2[7:3],data_out_g2[7:2],data_out_b2[7:3]}                                      ;
// assign channel_6_data_valid   =    de_in1                                ;
// assign channel_6_data         =    {r_in1[7:3],g_in1[7:2],b_in1[7:3]}                                      ;


hdmi_in_1920_to_960 #(
    .OUT_WIDTH			(960						),
    .OUT_HEIGH			(540						)
)
channel_1_data_input(
    .clk				(pixclk_in1					),
    .rst_n				(rstn_out					),

    .data_in_r			(r_in1						),
    .data_in_g			(g_in1						),
    .data_in_b			(b_in1						),
    .data_in_valid		(de_in1						),

    .data_out_r			(data_out_r1	                ),
    .data_out_g			(data_out_g1	                ),
    .data_out_b			(data_out_b1	                ),
    .data_out_valid		(data_out_valid1		     )
    );


hdmi_in_1920_to_960 #(
    .OUT_WIDTH			(960						),
    .OUT_HEIGH			(540						)
)
channel_2_data_input(
    .clk				(pixclk_in2					),
    .rst_n				(rstn_out					),

    .data_in_r			(r_in2						),
    .data_in_g			(g_in2						),
    .data_in_b			(b_in2						),
    .data_in_valid		(de_in2						),

    .data_out_r			(data_out_r2	                ),
    .data_out_g			(data_out_g2	                ),
    .data_out_b			(data_out_b2	                ),
    .data_out_valid		(data_out_valid2		     )
    );


hdmi_in_1920_to_960 #(
    .OUT_WIDTH			(960						),
    .OUT_HEIGH			(540						)
)
channel_3_data_input(
    .clk				(pixclk_in3					),
    .rst_n				(rstn_out					),

    .data_in_r			(r_in3						),
    .data_in_g			(g_in3						),
    .data_in_b			(b_in3						),
    .data_in_valid		(de_in3						),

    .data_out_r			(data_out_r3	                ),
    .data_out_g			(data_out_g3	                ),
    .data_out_b			(data_out_b3	                ),
    .data_out_valid		(data_out_valid3		     )
    );


hdmi_in_1920_to_960 #(
    .OUT_WIDTH			(960						),
    .OUT_HEIGH			(540						)
)
channel_4_data_input(
    .clk				(pixclk_in1					),
    .rst_n				(rstn_out					),

    .data_in_r			({rgb_data4[15:11],3'd0}			),
    .data_in_g			({rgb_data4[10:5],2'd0}						),
    .data_in_b			({rgb_data4[4:0],3'd0}						),
    .data_in_valid		(de_in4						),

    .data_out_r			(data_out_r4	                ),
    .data_out_g			(data_out_g4	                ),
    .data_out_b			(data_out_b4	                ),
    .data_out_valid		(data_out_valid4		     )
    );


// mix
//////////////////////////////////////////////////////////////////////////////////////////////////////////
parameter MEM_DATA_BITS          = 256                                    ; //external memory user interface data width
parameter ADDR_BITS              = 25                                     ;  //external memory user interface address width
parameter BUSRT_BITS             = 10                                     ;  //external memory user interface burst width
//总
wire                                        wr_burst_data_req             ;
wire                                        wr_burst_finish               ;
wire                                        rd_burst_finish               ;
wire                                        rd_burst_req                  ;
wire                                        wr_burst_req                  ;
wire        [BUSRT_BITS - 1:0]              rd_burst_len                  ;
wire        [BUSRT_BITS - 1:0]              wr_burst_len                  ;
wire        [ADDR_BITS - 1:0]               rd_burst_addr                 ;
wire        [ADDR_BITS - 1:0]               wr_burst_addr                 ;
wire                                        rd_burst_data_valid           ;
wire        [MEM_DATA_BITS - 1 : 0]         rd_burst_data                 ;
wire        [MEM_DATA_BITS - 1 : 0]         wr_burst_data                 ;

//channel 1
wire                                        ch1_wr_burst_req              ;
wire        [ADDR_BITS - 1:0]               ch1_wr_burst_addr             ;
wire        [BUSRT_BITS - 1:0]              ch1_wr_burst_len              ;
wire                                        ch1_wr_burst_data_req         ;
wire        [MEM_DATA_BITS - 1 : 0]         ch1_wr_burst_data             ;
wire                                        ch1_wr_burst_finish           ;
wire                                        ch1_rd_burst_req              ;
wire        [ADDR_BITS - 1:0]               ch1_rd_burst_addr             ;
wire        [BUSRT_BITS - 1:0]              ch1_rd_burst_len              ;
wire                                        ch1_rd_burst_data_valid       ;
wire        [MEM_DATA_BITS - 1 : 0]         ch1_rd_burst_data             ;
wire                                        ch1_rd_burst_finish           ;

wire                                        ch1_read_req                  ;
wire                                        ch1_read_req_ack              ;
wire                                        ch1_read_en                   ;
wire        [15:0]                          ch1_read_data                 ;
wire                                        ch1_write_en                  ;
wire        [15:0]                          ch1_write_data                ;
wire                                        ch1_write_req                 ;
wire                                        ch1_write_req_ack             ;
wire                                        ch1_write_addr_index          ;    
wire                                        ch1_read_addr_index           ;

//channel 2
wire                                        ch2_wr_burst_req              ;
wire        [ADDR_BITS - 1:0]               ch2_wr_burst_addr             ;
wire        [BUSRT_BITS - 1:0]              ch2_wr_burst_len              ;
wire                                        ch2_wr_burst_data_req         ;
wire        [MEM_DATA_BITS - 1 : 0]         ch2_wr_burst_data             ;
wire                                        ch2_wr_burst_finish           ;
wire                                        ch2_rd_burst_req              ;
wire        [ADDR_BITS - 1:0]               ch2_rd_burst_addr             ;
wire        [BUSRT_BITS - 1:0]              ch2_rd_burst_len              ;
wire                                        ch2_rd_burst_data_valid       ;
wire        [MEM_DATA_BITS - 1 : 0]         ch2_rd_burst_data             ;
wire                                        ch2_rd_burst_finish           ;

wire                                        ch2_read_req                  ;
wire                                        ch2_read_req_ack              ;
wire                                        ch2_read_en                   ;
wire        [15:0]                          ch2_read_data                 ;
wire                                        ch2_write_en                  ;
wire        [15:0]                          ch2_write_data                ;
wire                                        ch2_write_req                 ;
wire                                        ch2_write_req_ack             ;
wire                                        ch2_write_addr_index          ;
wire                                        ch2_read_addr_index           ;

//channel 3
wire                                        ch3_wr_burst_req              ;
wire        [ADDR_BITS - 1:0]               ch3_wr_burst_addr             ;
wire        [BUSRT_BITS - 1:0]              ch3_wr_burst_len              ;
wire                                        ch3_wr_burst_data_req         ;
wire        [MEM_DATA_BITS - 1 : 0]         ch3_wr_burst_data             ;
wire                                        ch3_wr_burst_finish           ;
wire                                        ch3_rd_burst_req              ;
wire        [ADDR_BITS - 1:0]               ch3_rd_burst_addr             ;
wire        [BUSRT_BITS - 1:0]              ch3_rd_burst_len              ;
wire                                        ch3_rd_burst_data_valid       ;
wire        [MEM_DATA_BITS - 1 : 0]         ch3_rd_burst_data             ;
wire                                        ch3_rd_burst_finish           ;

wire                                        ch3_read_req                  ;
wire                                        ch3_read_req_ack              ;
wire                                        ch3_read_en                   ;
wire        [15:0]                          ch3_read_data                 ;
wire                                        ch3_write_en                  ;
wire        [15:0]                          ch3_write_data                ;
wire                                        ch3_write_req                 ;
wire                                        ch3_write_req_ack             ;
wire                                        ch3_write_addr_index          ;
wire                                        ch3_read_addr_index           ;

//channel 4
wire                                        ch4_wr_burst_req              ;
wire        [ADDR_BITS - 1:0]               ch4_wr_burst_addr             ;
wire        [BUSRT_BITS - 1:0]              ch4_wr_burst_len              ;
wire                                        ch4_wr_burst_data_req         ;
wire        [MEM_DATA_BITS - 1 : 0]         ch4_wr_burst_data             ;
wire                                        ch4_wr_burst_finish           ;        
wire                                        ch4_rd_burst_req              ;
wire        [ADDR_BITS - 1:0]               ch4_rd_burst_addr             ;
wire        [BUSRT_BITS - 1:0]              ch4_rd_burst_len              ;
wire                                        ch4_rd_burst_data_valid       ;
wire        [MEM_DATA_BITS - 1 : 0]         ch4_rd_burst_data             ;
wire                                        ch4_rd_burst_finish           ;

wire                                        ch4_read_req                  ;
wire                                        ch4_read_req_ack              ;
wire                                        ch4_read_en                   ;
wire        [15:0]                          ch4_read_data                 ;
wire                                        ch4_write_en                  ;
wire        [15:0]                          ch4_write_data                ;
wire                                        ch4_write_req                 ;
wire                                        ch4_write_req_ack             ;
wire        [1:0]                           ch4_write_addr_index          ;
wire        [1:0]                           ch4_read_addr_index           ;
        
//channel 5
wire                                        ch5_wr_burst_req              ;
wire        [ADDR_BITS - 1:0]               ch5_wr_burst_addr             ;
wire        [BUSRT_BITS - 1:0]              ch5_wr_burst_len              ;
wire                                        ch5_wr_burst_data_req         ;
wire        [MEM_DATA_BITS - 1 : 0]         ch5_wr_burst_data             ;
wire                                        ch5_wr_burst_finish           ;    
wire                                        ch5_rd_burst_req              ;
wire        [ADDR_BITS - 1:0]               ch5_rd_burst_addr             ;
wire        [BUSRT_BITS - 1:0]              ch5_rd_burst_len              ;
wire                                        ch5_rd_burst_data_valid       ;
wire        [MEM_DATA_BITS - 1 : 0]         ch5_rd_burst_data             ;    
wire                                        ch5_rd_burst_finish           ;

wire                                        ch5_read_req                  ;
wire                                        ch5_read_req_ack              ;
wire                                        ch5_read_en                   ;
wire        [15:0]                          ch5_read_data                 ;
wire                                        ch5_write_en                  ;
wire        [15:0]                          ch5_write_data                ;
wire                                        ch5_write_req                 ;
wire                                        ch5_write_req_ack             ;
wire        [1:0]                           ch5_write_addr_index          ;
wire        [1:0]                           ch5_read_addr_index           ;



wire                                        ch6_wr_burst_req              ;
wire        [ADDR_BITS - 1:0]               ch6_wr_burst_addr             ;
wire        [BUSRT_BITS - 1:0]              ch6_wr_burst_len              ;
wire                                        ch6_wr_burst_data_req         ;
wire        [MEM_DATA_BITS - 1 : 0]         ch6_wr_burst_data             ;
wire                                        ch6_wr_burst_finish           ;    
wire                                        ch6_rd_burst_req              ;
wire        [ADDR_BITS - 1:0]               ch6_rd_burst_addr             ;
wire        [BUSRT_BITS - 1:0]              ch6_rd_burst_len              ;
wire                                        ch6_rd_burst_data_valid       ;
wire        [MEM_DATA_BITS - 1 : 0]         ch6_rd_burst_data             ;    
wire                                        ch6_rd_burst_finish           ;

wire                                        ch6_read_req                  ;
wire                                        ch6_read_req_ack              ;
wire                                        ch6_read_en                   ;
wire        [15:0]                          ch6_read_data                 ;
wire                                        ch6_write_en                  ;
wire        [15:0]                          ch6_write_data                ;
wire                                        ch6_write_req                 ;
wire                                        ch6_write_req_ack             ;
wire        [1:0]                           ch6_write_addr_index          ;
wire        [1:0]                           ch6_read_addr_index           ;

//--------------------------------------------------------------------
wire                                        color_bar_hs                  ;
wire                                        color_bar_vs                  ;
wire                                        color_bar_de                  ;
wire        [7:0]                           color_bar_r                   ;
wire        [7:0]                           color_bar_g                   ;
wire        [7:0]                           color_bar_b                   ;
wire                                        v0_hs                         ;
wire                                        v0_vs                         ;
wire                                        v0_de                         ;
wire        [23:0]                          v0_data                       ;
wire                                        v1_hs                         ;
wire                                        v1_vs                         ;
wire                                        v1_de                         ;
wire        [23:0]                          v1_data                       ;
wire                                        v2_hs                         ;
wire                                        v2_vs                         ;
wire                                        v2_de                         ;
wire        [23:0]                          v2_data                       ;

wire                                        v6_hs                         ;
wire                                        v6_vs                         ;
wire                                        v6_de                         ;
wire        [23:0]                          v6_data                       ;
wire                                        hs                            ;
wire                                        vs	                            ;
wire                                        de	                            ;
wire        [15:0]                          vout_data                     ;

write_req_gen write_req_gen_channel_1(
	.rst                        (~rstn_out        ), // input 
	.pclk                       (pixclk_in1         ), // input 
	.cmos_vsync                 (vs_in1           ), // input 
	.write_req                  (ch1_write_req            ), // output
	.write_addr_index           (ch1_write_addr_index     ), // output 
	.read_addr_index            (ch1_read_addr_index      ), // output 
	.write_req_ack              (ch1_write_req_ack        )  // input 
);

write_req_gen write_req_gen_channel_2(
	.rst                        (~rstn_out        ), // input 
	.pclk                       (pixclk_in2         ), // input 
	.cmos_vsync                 (vs_in2           ), // input 
	.write_req                  (ch2_write_req            ), // output
	.write_addr_index           (ch2_write_addr_index     ), // output
	.read_addr_index            (ch2_read_addr_index      ), // output
	.write_req_ack              (ch2_write_req_ack        )  // input 
);

write_req_gen write_req_gen_channel_3(
	.rst                        (~rstn_out        		  ), // input 
	.pclk                       (pixclk_in3                ), // input 
	.cmos_vsync                 (vs_in3		              ), // input 
	.write_req                  (ch3_write_req            ), // output
	.write_addr_index           (ch3_write_addr_index     ), // output
	.read_addr_index            (ch3_read_addr_index      ), // output
	.write_req_ack              (ch3_write_req_ack        )  // input 
);

write_req_gen write_req_gen_channel_4(
	.rst                        (~rstn_out        		  ), // input 
	.pclk                       (pixclk_in1                ), // input 
	.cmos_vsync                 (vs_in4		          ), // input 
	.write_req                  (ch4_write_req            ), // output
	.write_addr_index           (ch4_write_addr_index     ), // output
	.read_addr_index            (ch4_read_addr_index      ), // output
	.write_req_ack              (ch4_write_req_ack        )  // input 
);

write_req_gen write_req_gen_channel_5(
	.rst                        (~rstn_out        	  	  ), // input 
	.pclk                       (clk_50M                  ), // input 
	.cmos_vsync                 (vs				          ), // input 
	.write_req                  (ch5_write_req            ), // output
	.write_addr_index           (ch5_write_addr_index     ), // output
	.read_addr_index            (ch5_read_addr_index      ), // output
	.write_req_ack              (ch5_write_req_ack        )  // input 
);
reg      pixclk_in6  ;
reg      vs_in6      ;


write_req_gen write_req_gen_channel_6(
	.rst                        (~rstn_out      	  	  ), // input 
	.pclk                       (pixclk_in6                  ), // input 
	.cmos_vsync                 (vs_in6				          ), // input 
	.write_req                  (ch6_write_req            ), // output
	.write_addr_index           (ch6_write_addr_index     ), // output
	.read_addr_index            (ch6_read_addr_index      ), // output
	.write_req_ack              (ch6_write_req_ack        )  // input 
);
wire [2:0]   change_choose;




// assign  vs_in6 = (change_choose == 'd2)? vs_in1 : (change_choose == 'd3)?  vs_in2 : (change_choose == 'd4)?  vs_in3 : (change_choose == 'd5)? vs_in4 : vs_in1 ;
// assign  pixclk_in6 = (change_choose == 'd2)? pixclk_in1 : (change_choose == 'd3)?  pixclk_in2 : (change_choose == 'd4)?  pixclk_in3 : (change_choose == 'd5)? pixclk_in1 : pixclk_in1 ;
// assign  channel_6_data_valid   = (change_choose == 'd2)? de_in1 : (change_choose == 'd3)?  de_in2 : (change_choose == 'd4)?  de_in3 : (change_choose == 'd5)? de_in4 : de_in1 ;
// assign  channel_6_data   = (change_choose == 'd2)?  {r_in1[7:3],g_in1[7:2],b_in1[7:3]}  : (change_choose == 'd3)?   {r_in2[7:3],g_in2[7:2],b_in2[7:3]} : (change_choose == 'd4)?   {r_in3[7:3],g_in3[7:2],b_in3[7:3]}  : (change_choose == 'd5)? rgb_data4 : {r_in1[7:3],g_in1[7:2],b_in1[7:3]};
always @(*) begin
	case (change_choose)
	'd0	:   begin
		vs_in6 <= vs_in1 ;
		pixclk_in6 <= pixclk_in1 ;
		channel_6_data_valid   <=    de_in1                                ;
		channel_6_data        <=    {r_in1[7:3],g_in1[7:2],b_in1[7:3]}                                                                   ;
	end
	'd2	: begin
		vs_in6 <= vs_in1 ;
		pixclk_in6 <= pixclk_in1 ;
		channel_6_data_valid   <=    de_in1                               ;
		channel_6_data        <=     {r_in1[7:3],g_in1[7:2],b_in1[7:3]}                            ;
	end
	'd3	: begin
		vs_in6 <= vs_in2 ;
		pixclk_in6 <= pixclk_in2 ;
		channel_6_data_valid   <=     de_in2                               ;
		channel_6_data         <=     {r_in2[7:3],g_in2[7:2],b_in2[7:3]}                             ;
	end
	'd4	: begin
		vs_in6 <= vs_in3 ;
		pixclk_in6 <= pixclk_in3 ;
		channel_6_data_valid   <=    de_in3                                 ;
		channel_6_data         <=    {r_in3[7:3],g_in3[7:2],b_in3[7:3]}                               ;
	end
	'd5	: begin
		vs_in6 <= vs_in4 ;
		pixclk_in6 <= pixclk_in1 ;
		channel_6_data_valid   <=    de_in4                              ;
		channel_6_data         <=   rgb_data4                           ;
	end
		default: begin
			vs_in6 <= vs_in1 ;
			pixclk_in6 <= pixclk_in1 ;
			channel_6_data_valid   <=   de_in1                                                             ;
			channel_6_data         <=   {r_in1[7:3],g_in1[7:2],b_in1[7:3]}                        ;
		end
	endcase
end

wire     [15:0]              scale_data                  ;
wire	                     scale_data_valid            ;
wire                         frame_flag                        ;
wire     [15:0]              scaler_up_data                        ;
wire                         scaler_up_data_valid                  ;

wire     [12:0]              s_width	                       ;
wire     [12:0]              s_height                          ;
wire     [12:0]              t_width				           ;
wire     [12:0]              t_height		                   ;
wire     [15:0]              h_scale_k			               ;
wire     [15:0]              v_scale_k			               ; 
wire     [12:0]              change_en			               ;
wire                         scale_state			           ;
wire     [24:0]              wr_bust_total_len	               ;
wire     [11:0]              t_width_rd                        ;
wire     [11:0]              t_height_rd                       ;

scale_top scale_top_u(
	.pixel_clk		(clk_50M				),//原始像素时钟
	.sram_clk		(clk_100M				),//缩放后像素时钟
	.sys_rst_n		(ddr_init_done   		),//复位信号 
	.hs				((change_choose)?v6_hs:hs					),//行信号
	.vs				((change_choose )?v6_vs:vs					),//场信号
	.de				((change_choose )?v6_de:de						),//数据使能信号
	.s_width		(1920					),//缩放前宽度[11:0] 
	.s_height		(1080					),//缩放前高度[11:0] 
	.t_width		(t_width				),//缩放后宽度[11:0] 
	.t_height		(t_height				),//缩放后高度[11:0] 
	.h_scale_k		(h_scale_k				),//列缩放因子[15:0]//（s_width前 * 256）/ t_width后
	.v_scale_k		(v_scale_k				),//行缩放因子[15:0]//（s_height * 256）/ t_height 
    .pixel_data		((change_choose )?v6_data : vout_data	),//缩放前数据[15:0]
	.sram_data_out	(scale_data		        ),//缩放后数据[15:0]output 
	.data_valid		(scale_data_valid	    ),//缩放后数据有效信号output 
	.frame_flag     (frame_flag				)  
);

param_change param_change_u(
    .clk_wr			    (clk_50M            ),//时钟信号 50Mhz  
    .clk_rd			    (clk_100M           ),            
    .rst_n			    (ddr_init_done      ),	           
    .change_en		    (change_en          ),//切换使能       
    .wr_vsync		    ((change_choose)?v6_vs:vs                 ),//拼接好四幅图像后的场同步	          
	.s_width		    (1920               ),//缩放前宽度           
	.s_height		    (1080               ),//缩放前高度          
	.t_width_wr		    (t_width            ),//写端缩放后宽度        
	.t_height_wr	    (t_height           ),//写端缩放后高度	          	
	.h_scale_k		    (h_scale_k          ),//列缩放因子         
	.v_scale_k		    (v_scale_k          ),//行缩放因子	      
    .wr_bust_total_len  (wr_bust_total_len  )//从 ddr3 中读数据时的突发长度  

);

wire  [1:0] working_mode;
wire   change_yuv;

wire  [12:0]    width_change;
wire  [12:0]    height_change;
key_ctl key_ctl_top(
    .sys_clk               (sys_clk)            ,
    .sys_rst_n             (sys_rst_n)          ,  //复位信号
    .key1                  (key1)			    ,
    .key2                  (key2)			    ,
    .key3                  (key3)			    ,
    .key4                  (key4)			    ,
    .key5                  (key5)			    ,
    .key6                  (key6)			    ,
    .key7                  (key7)			    , 		
    

    .change_en             (change_en)   ,  //切换信号,一共有11种切换状态
    .scale_state           (scale_state)  ,  //缩放状态,1表示处于放大,0表示处于缩小状态或原始大小状态
    .working_mode          (working_mode),
    .rgb_ctrl_plus10       (rgb_ctrl_plus10),
    .r_ctrl_plus10         (r_ctrl_plus10),
    .g_ctrl_plus10         (g_ctrl_plus10),
    .b_ctrl_plus10         (b_ctrl_plus10),
    .change_yuv            (change_yuv),
    .change_gauss_filter   (change_gauss_filter),
    .change_sobel          (change_sobel),
    .threshold             (threshold),
	.change_choose         (change_choose)

);

scaler_up#(
    .H_DISP 		(1920		),
    .V_DISP 		(1080		)
)
scaler_up(
    .pix_clk		(clk_100M				),
    .rst_n			(ddr_init_done			),

    .data_in		(scale_data		),
    .data_in_valid	(scale_data_valid	),
    .frame_flag		(frame_flag				),  //一帧开始信号
	.scale_state    (scale_state			),

    .t_width		(t_width				),     //input 缩放后图像宽高
    .t_height		(t_height				),

    .data_out 		(scaler_up_data				),
    .data_out_valid (scaler_up_data_valid		)
);
assign ch1_write_en   =channel_1_data_valid;
// assign ch1_write_data   ={channel_1_data[4:0],channel_1_data[10:5],channel_1_data[15:11]};
assign ch1_write_data   =  channel_1_data ;



assign ch2_write_en   = channel_2_data_valid;
// assign ch2_write_data = {channel_2_data[4:0],channel_2_data[10:5],channel_2_data[15:11]};
assign ch2_write_data   =  channel_2_data ;
//
assign ch3_write_en   = channel_3_data_valid;
assign ch3_write_data = channel_3_data;

//
assign ch4_write_en   = channel_4_data_valid;
assign ch4_write_data = channel_4_data;

assign ch5_write_en   = scaler_up_data_valid;
assign ch5_write_data = scaler_up_data;

assign ch6_write_en   = channel_6_data_valid;
assign ch6_write_data = channel_6_data;


//////////////////////////////////////////////////////////////////////////////////////////////////////////
//对接DDR AXI接口, AXI与读写FIFO之间数据控制
aq_axi_master_256 u_aq_axi_master
(													
	.ARESETN                     (ddr_init_done       ), 
	.ACLK                        (core_clk            ),
	.M_AXI_AWID                  (axi_awuser_id       ),
	.M_AXI_AWADDR                (axi_awaddr          ),
	.M_AXI_AWLEN                 (axi_awlen           ),
	.M_AXI_AWVALID               (axi_awvalid         ),
	.M_AXI_AWREADY               (axi_awready         ),
	.M_AXI_WDATA                 (axi_wdata           ),
	.M_AXI_WSTRB                 (axi_wstrb           ),
	.M_AXI_WLAST                 (                    ),
	.M_AXI_WREADY                (axi_wready          ),
	.M_AXI_ARID                  (axi_aruser_id       ),
	.M_AXI_ARADDR                (axi_araddr          ),
	.M_AXI_ARLEN                 (axi_arlen           ),
	.M_AXI_ARVALID               (axi_arvalid         ),
	.M_AXI_ARREADY               (axi_arready         ),
	.M_AXI_RID                   (axi_rid             ),
	.M_AXI_RDATA                 (axi_rdata           ),
	.M_AXI_RLAST                 (axi_rlast           ),
	.M_AXI_RVALID                (axi_rvalid          ),
	.MASTER_RST                  (1'b0                ),
	.WR_START                    (wr_burst_req        ), 
	.WR_ADRS                     ({wr_burst_addr,5'd0}), 
	.WR_LEN                      ({wr_burst_len, 5'd0}), 
	.WR_FIFO_RE                  (wr_burst_data_req   ),  
	.WR_FIFO_DATA                (wr_burst_data       ), 
	.WR_DONE                     (wr_burst_finish     ),
	.RD_START                    (rd_burst_req        ), 
	.RD_ADRS                     ({rd_burst_addr,5'd0}), 
	.RD_LEN                      ({rd_burst_len,5'd0} ),  
	.RD_FIFO_WE                  (rd_burst_data_valid ), 
	.RD_FIFO_DATA                (rd_burst_data       ), 
	.RD_DONE                     (rd_burst_finish     )

);

mem_write_arbi
#(
	.MEM_DATA_BITS               (MEM_DATA_BITS),
	.ADDR_BITS                   (ADDR_BITS    ),
	.BUSRT_BITS                  (BUSRT_BITS   )
)
mem_write_arbi
(
	.rst_n                       (ddr_init_done         ), 
	.mem_clk                     (core_clk              ),
	
	.ch1_wr_burst_req            (ch1_wr_burst_req      ), 
	.ch1_wr_burst_len            (ch1_wr_burst_len      ), 
	.ch1_wr_burst_addr           (ch1_wr_burst_addr     ), 
	.ch1_wr_burst_data_req       (ch1_wr_burst_data_req ), 
	.ch1_wr_burst_data           (ch1_wr_burst_data     ), 
	.ch1_wr_burst_finish         (ch1_wr_burst_finish   ), 

	.ch2_wr_burst_req			 (ch2_wr_burst_req		),
	.ch2_wr_burst_len			 (ch2_wr_burst_len		),
	.ch2_wr_burst_addr			 (ch2_wr_burst_addr		),
	.ch2_wr_burst_data_req		 (ch2_wr_burst_data_req	),
	.ch2_wr_burst_data			 (ch2_wr_burst_data		),
	.ch2_wr_burst_finish		 (ch2_wr_burst_finish	),

	.ch3_wr_burst_req			 (ch3_wr_burst_req		),
	.ch3_wr_burst_len			 (ch3_wr_burst_len		),
	.ch3_wr_burst_addr			 (ch3_wr_burst_addr		),
	.ch3_wr_burst_data_req		 (ch3_wr_burst_data_req	),
	.ch3_wr_burst_data			 (ch3_wr_burst_data		),
	.ch3_wr_burst_finish		 (ch3_wr_burst_finish	),

	.ch4_wr_burst_req			 (ch4_wr_burst_req		),
	.ch4_wr_burst_len			 (ch4_wr_burst_len		),
	.ch4_wr_burst_addr			 (ch4_wr_burst_addr		),
	.ch4_wr_burst_data_req		 (ch4_wr_burst_data_req	),
	.ch4_wr_burst_data			 (ch4_wr_burst_data		),
	.ch4_wr_burst_finish		 (ch4_wr_burst_finish	),


    .ch5_wr_burst_req            (ch5_wr_burst_req      ), 
	.ch5_wr_burst_len            (ch5_wr_burst_len      ), 
	.ch5_wr_burst_addr           (ch5_wr_burst_addr     ), 
	.ch5_wr_burst_data_req       (ch5_wr_burst_data_req ), 
	.ch5_wr_burst_data           (ch5_wr_burst_data     ), 
	.ch5_wr_burst_finish         (ch5_wr_burst_finish   ), 

	.ch6_wr_burst_req            (ch6_wr_burst_req      ), 
	.ch6_wr_burst_len            (ch6_wr_burst_len      ), 
	.ch6_wr_burst_addr           (ch6_wr_burst_addr     ), 
	.ch6_wr_burst_data_req       (ch6_wr_burst_data_req ), 
	.ch6_wr_burst_data           (ch6_wr_burst_data     ), 
	.ch6_wr_burst_finish         (ch6_wr_burst_finish   ), 

	.wr_burst_req                (wr_burst_req          ), 
	.wr_burst_len                (wr_burst_len          ), 
	.wr_burst_addr               (wr_burst_addr         ), 
	.wr_burst_data_req           (wr_burst_data_req     ), 
	.wr_burst_data               (wr_burst_data         ), 
	.wr_burst_finish             (wr_burst_finish       )  
);

//
mem_read_arbi 
#(
	.MEM_DATA_BITS               (MEM_DATA_BITS             ),
	.ADDR_BITS                   (ADDR_BITS                 ),
	.BUSRT_BITS                  (BUSRT_BITS                )
)
mem_read_arbi
(
	.rst_n                        (ddr_init_done            ),
	.mem_clk                      (core_clk                 ),

	
	.ch1_rd_burst_req             (ch1_rd_burst_req         ), // input  
	.ch1_rd_burst_len             (ch1_rd_burst_len         ), // input
	.ch1_rd_burst_addr            (ch1_rd_burst_addr        ), // input
	.ch1_rd_burst_data_valid      (ch1_rd_burst_data_valid  ), // output
	.ch1_rd_burst_data            (ch1_rd_burst_data        ), // output
	.ch1_rd_burst_finish          (ch1_rd_burst_finish      ), // output

	.ch2_rd_burst_req             (ch2_rd_burst_req         ), // input  
	.ch2_rd_burst_len             (ch2_rd_burst_len         ), // input
	.ch2_rd_burst_addr            (ch2_rd_burst_addr        ), // input
	.ch2_rd_burst_data_valid      (ch2_rd_burst_data_valid  ), // output
	.ch2_rd_burst_data            (ch2_rd_burst_data        ), // output
	.ch2_rd_burst_finish          (ch2_rd_burst_finish      ), // output
	
	.ch3_rd_burst_req             (ch3_rd_burst_req         ), // input  
	.ch3_rd_burst_len             (ch3_rd_burst_len         ), // input
	.ch3_rd_burst_addr            (ch3_rd_burst_addr        ), // input
	.ch3_rd_burst_data_valid      (ch3_rd_burst_data_valid  ), // output
	.ch3_rd_burst_data            (ch3_rd_burst_data        ), // output
	.ch3_rd_burst_finish          (ch3_rd_burst_finish      ), // output

	.ch4_rd_burst_req             (ch4_rd_burst_req         ), // input  
	.ch4_rd_burst_len             (ch4_rd_burst_len         ), // input
	.ch4_rd_burst_addr            (ch4_rd_burst_addr        ), // input
	.ch4_rd_burst_data_valid      (ch4_rd_burst_data_valid  ), // output
	.ch4_rd_burst_data            (ch4_rd_burst_data        ), // output
	.ch4_rd_burst_finish          (ch4_rd_burst_finish      ), // output

    .ch5_rd_burst_req             (ch5_rd_burst_req         ), // input  
	.ch5_rd_burst_len             (ch5_rd_burst_len         ), // input
	.ch5_rd_burst_addr            (ch5_rd_burst_addr        ), // input
	.ch5_rd_burst_data_valid      (ch5_rd_burst_data_valid  ), // output
	.ch5_rd_burst_data            (ch5_rd_burst_data        ), // output
	.ch5_rd_burst_finish          (ch5_rd_burst_finish      ), // output

	.ch6_rd_burst_req             (ch6_rd_burst_req         ), // input  
	.ch6_rd_burst_len             (ch6_rd_burst_len         ), // input
	.ch6_rd_burst_addr            (ch6_rd_burst_addr        ), // input
	.ch6_rd_burst_data_valid      (ch6_rd_burst_data_valid  ), // output
	.ch6_rd_burst_data            (ch6_rd_burst_data        ), // output
	.ch6_rd_burst_finish          (ch6_rd_burst_finish      ), // output

	.rd_burst_req                 (rd_burst_req             ), // output 
	.rd_burst_len                 (rd_burst_len             ), // output
	.rd_burst_addr                (rd_burst_addr            ), // output
	.rd_burst_data_valid          (rd_burst_data_valid      ), // input 
	.rd_burst_data                (rd_burst_data            ), // input
	.rd_burst_finish              (rd_burst_finish          )  // input 
);

frame_read_write#(
	.MEM_DATA_BITS              (256                      ),
	.READ_DATA_BITS             (16                       ),
	.WRITE_DATA_BITS            (16                       ),
	.ADDR_BITS                  (25                       ),
	.BUSRT_BITS                 (10                       ),
	.BURST_SIZE                 (16                       )  //?
)
frame_read_write_channel_1 
(
	.rst                        (~ddr_init_done           ),
	.mem_clk                    (core_clk                 ),

	.rd_burst_req               (ch1_rd_burst_req         ), // output     to external memory controller,send out a burst read request
	.rd_burst_len               (ch1_rd_burst_len         ), // output     to external memory controller,data length of the burst read request, not bytes
	.rd_burst_addr              (ch1_rd_burst_addr        ), // output     to external memory controller,base address of the burst read request 
	.rd_burst_data_valid        (ch1_rd_burst_data_valid  ), // input      from external memory controller,read data valid 
	.rd_burst_data              (ch1_rd_burst_data        ), // input      from external memory controller,read request data
	.rd_burst_finish            (ch1_rd_burst_finish      ), // input      from external memory controller,burst read finish

    //用户视频输出控制端口ch0
	// .read_clk                   (pix_clk                  ), // input      data read module clock
	.read_clk                   (clk_50M                  ), // input      data read module clock
	.read_req                   (ch1_read_req             ), // input  
	.read_req_ack               (ch1_read_req_ack         ), // output     data read module read request response
	.read_finish                (                         ), // output     data read module read request finish
	.read_addr_0                (25'd0                    ), // input      data read module read request base address 0, used when read_addr_index = 0
	.read_addr_1                (25'd1036800), // input      data read module read request base address 1, used when read_addr_index = 1
	.read_addr_index            (ch1_read_addr_index      ), // input      select valid base address from read_addr_0 read_addr_1
	.read_len                   (25'd32400), // input      data read module read request data length  //frame size  
	.read_en                    (ch1_read_en              ), // input      data read module read request for one data, read_data valid next clock
	.read_data                  (ch1_read_data            ), // output     read data

    //ch0写FIFO读接口对接 mem_write_arbi_m0 模块,进行多路选择对接AXI接口
	.wr_burst_req               (ch1_wr_burst_req         ), // output     to external memory controller,send out a burst write request
	.wr_burst_len               (ch1_wr_burst_len         ), // output     to external memory controller,data length of the burst write request, not bytes
	.wr_burst_addr              (ch1_wr_burst_addr        ), // output     to external memory controller,base address of the burst write request 
	.wr_burst_data_req          (ch1_wr_burst_data_req    ), // input      from external memory controller,write data request ,before data 1 clock
	.wr_burst_data              (ch1_wr_burst_data        ), // output     to external memory controller,write data
	.wr_burst_finish            (ch1_wr_burst_finish      ), // input      from external memory controller,burst write finish

    //用户视频输入控制端口ch0 720P:d57600 540P:d32400
	.write_clk                  (pixclk_in1         ), // input      data write module clock
	.write_req                  (ch1_write_req            ), // input      data write module write request,keep '1' until read_req_ack = '1'
	.write_req_ack              (ch1_write_req_ack        ), // output     data write module write request response
	.write_finish               (                         ), // output     data write module write request finish
	.write_addr_0               (25'd0                    ), // input      data write module write request base address 0, used when write_addr_index = 0
	.write_addr_1               (25'd1036800), // input      data write module write request base address 1, used when write_addr_index = 1
	.write_addr_index           (ch1_write_addr_index     ), // input      select valid base address from write_addr_0 write_addr_1
	.write_len                  (25'd32400), // input      data write module write request data length
	.write_en                   (ch1_write_en            ), // input      data write module write request for one data
	.write_data                 (ch1_write_data           )  // input      write data
);

frame_read_write#(
	.MEM_DATA_BITS              (256                      ),
	.READ_DATA_BITS             (16                       ),
	.WRITE_DATA_BITS            (16                       ),
	.ADDR_BITS                  (25                       ),
	.BUSRT_BITS                 (10                       ),
	.BURST_SIZE                 (16                       ) //?
) 
frame_read_write_channel_2
(
	.rst                        (~ddr_init_done           ),
	.mem_clk                    (core_clk                 ),

	.rd_burst_req               (ch2_rd_burst_req         ),
	.rd_burst_len               (ch2_rd_burst_len         ),
	.rd_burst_addr              (ch2_rd_burst_addr        ),
	.rd_burst_data_valid        (ch2_rd_burst_data_valid  ),
	.rd_burst_data              (ch2_rd_burst_data        ),
	.rd_burst_finish            (ch2_rd_burst_finish      ),

	// .read_clk                   (pix_clk                  ),
	.read_clk                   (clk_50M                  ),
	.read_req                   (ch2_read_req             ),
	.read_req_ack               (ch2_read_req_ack         ),
	.read_finish                (                         ),
	.read_addr_0                (25'd3073600              ), //The first frame address is 0
	.read_addr_1                (25'd4110400              ), //The second frame address is 25'd2073600 ,large enough address space for one frame of video
	.read_addr_index            (ch2_read_addr_index      ),
	.read_len                   (25'd32400                ),//frame size  1024 * 768 * 16 / 64
	.read_en                    (ch2_read_en              ),
	.read_data                  (ch2_read_data            ),

	.wr_burst_req               (ch2_wr_burst_req         ),
	.wr_burst_len               (ch2_wr_burst_len         ),
	.wr_burst_addr              (ch2_wr_burst_addr        ),
	.wr_burst_data_req          (ch2_wr_burst_data_req    ),
	.wr_burst_data              (ch2_wr_burst_data        ),
	.wr_burst_finish            (ch2_wr_burst_finish      ),

	.write_clk                  (pixclk_in2         ),
	.write_req                  (ch2_write_req            ),
	.write_req_ack              (ch2_write_req_ack        ),
	.write_finish               (                         ),
	.write_addr_0               (25'd3073600              ),
	.write_addr_1               (25'd4110400              ),
	.write_addr_index           (ch2_write_addr_index     ),
	.write_len                  (25'd32400                ),
	.write_en                   (ch2_write_en             ),
	.write_data                 (ch2_write_data           )
);

frame_read_write#(
	.MEM_DATA_BITS              (256                      ),
	.READ_DATA_BITS             (16                       ),
	.WRITE_DATA_BITS            (16                       ),
	.ADDR_BITS                  (25                       ),
	.BUSRT_BITS                 (10                       ),
	.BURST_SIZE                 (16                       )  //?
)
frame_read_write_channel_3 
(
	.rst                        (~ddr_init_done           ),
	.mem_clk                    (core_clk                 ),

	.rd_burst_req               (ch3_rd_burst_req         ), // output     to external memory controller,send out a burst read request
	.rd_burst_len               (ch3_rd_burst_len         ), // output     to external memory controller,data length of the burst read request, not bytes
	.rd_burst_addr              (ch3_rd_burst_addr        ), // output     to external memory controller,base address of the burst read request 
	.rd_burst_data_valid        (ch3_rd_burst_data_valid  ), // input      from external memory controller,read data valid 
	.rd_burst_data              (ch3_rd_burst_data        ), // input      from external memory controller,read request data
	.rd_burst_finish            (ch3_rd_burst_finish      ), // input      from external memory controller,burst read finish

	// .read_clk                   (pix_clk                  ), // input      data read module clock
	.read_clk                   (clk_50M                  ), // input      data read module clock
	.read_req                   (ch3_read_req             ), // input 
	.read_req_ack               (ch3_read_req_ack         ), // output     data read module read request response
	.read_finish                (                         ), // output     data read module read request finish
	.read_addr_0                (25'd5147200              ), // input      data read module read request base address 0, used when read_addr_index = 0
	.read_addr_1                (25'd7000000              ), // input      data read module read request base address 1, used when read_addr_index = 1
	.read_addr_index            (ch3_read_addr_index      ), // input      select valid base address from read_addr_0 read_addr_1
	.read_len                   (25'd32400                ), // input      data read module read request data length  //frame size  1024 * 768 * 16 / 64  一帧地址长度
	.read_en                    (ch3_read_en              ), // input      data read module read request for one data, read_data valid next clock
	.read_data                  (ch3_read_data            ), // output     read data

	.wr_burst_req               (ch3_wr_burst_req         ), // output     to external memory controller,send out a burst write request
	.wr_burst_len               (ch3_wr_burst_len         ), // output     to external memory controller,data length of the burst write request, not bytes
	.wr_burst_addr              (ch3_wr_burst_addr        ), // output     to external memory controller,base address of the burst write request 
	.wr_burst_data_req          (ch3_wr_burst_data_req    ), // input      from external memory controller,write data request ,before data 1 clock
	.wr_burst_data              (ch3_wr_burst_data        ), // output     to external memory controller,write data
	.wr_burst_finish            (ch3_wr_burst_finish      ), // input      from external memory controller,burst write finish

	.write_clk                  (pixclk_in3                ), // input      data write module clock
	.write_req                  (ch3_write_req            ), // input      data write module write request,keep '1' until read_req_ack = '1'
	.write_req_ack              (ch3_write_req_ack        ), // output     data write module write request response
	.write_finish               (                         ), // output     data write module write request finish
	.write_addr_0               (25'd5147200              ), // input      data write module write request base address 0, used when write_addr_index = 0
	.write_addr_1               (25'd7000000              ), // input      data write module write request base address 1, used when write_addr_index = 1
	.write_addr_index           (ch3_write_addr_index     ), // input      select valid base address from write_addr_0 write_addr_1
	.write_len                  (25'd32400                ), // input      data write module write request data length
	.write_en                   (ch3_write_en             ), // input      data write module write request for one data
	.write_data                 (ch3_write_data           )  // input      write data
);

frame_read_write#(
	.MEM_DATA_BITS              (256                      ),
	.READ_DATA_BITS             (16                       ),
	.WRITE_DATA_BITS            (16                       ),
	.ADDR_BITS                  (25                       ),
	.BUSRT_BITS                 (10                       ),
	.BURST_SIZE                 (16                       )  //?
)
frame_read_write_channel_4 
(
	.rst                        (~ddr_init_done           ),
	.mem_clk                    (core_clk                 ),

	.rd_burst_req               (ch4_rd_burst_req         ), // output     to external memory controller,send out a burst read request
	.rd_burst_len               (ch4_rd_burst_len         ), // output     to external memory controller,data length of the burst read request, not bytes
	.rd_burst_addr              (ch4_rd_burst_addr        ), // output     to external memory controller,base address of the burst read request 
	.rd_burst_data_valid        (ch4_rd_burst_data_valid  ), // input      from external memory controller,read data valid 
	.rd_burst_data              (ch4_rd_burst_data        ), // input      from external memory controller,read request data
	.rd_burst_finish            (ch4_rd_burst_finish      ), // input      from external memory controller,burst read finish

	// .read_clk                   (pix_clk                  ), // input      data read module clock
	.read_clk                   (clk_50M                  ), // input      data read module clock
	.read_req                   (ch4_read_req             ), // input  
	.read_req_ack               (ch4_read_req_ack         ), // output     data read module read request response
	.read_finish                (                         ), // output     data read module read request finish
	.read_addr_0                (25'd7220800              ), // input      data read module read request base address 0, used when read_addr_index = 0
	.read_addr_1                (25'd8257600              ), // input      data read module read request base address 1, used when read_addr_index = 1
	.read_addr_index            (ch4_read_addr_index      ), // input      select valid base address from read_addr_0 read_addr_1
	.read_len                   (25'd32400                ), // input      data read module read request data length  //frame size  1024 * 768 * 16 / 64  一帧地址长度
	.read_en                    (ch4_read_en              ), // input      data read module read request for one data, read_data valid next clock
	.read_data                  (ch4_read_data            ), // output     read data

	.wr_burst_req               (ch4_wr_burst_req         ), // output     to external memory controller,send out a burst write request
	.wr_burst_len               (ch4_wr_burst_len         ), // output     to external memory controller,data length of the burst write request, not bytes
	.wr_burst_addr              (ch4_wr_burst_addr        ), // output     to external memory controller,base address of the burst write request 
	.wr_burst_data_req          (ch4_wr_burst_data_req    ), // input      from external memory controller,write data request ,before data 1 clock
	.wr_burst_data              (ch4_wr_burst_data        ), // output     to external memory controller,write data
	.wr_burst_finish            (ch4_wr_burst_finish      ), // input      from external memory controller,burst write finish

	.write_clk                  (pixclk_in1                ), // input      data write module clock
	.write_req                  (ch4_write_req            ), // input      data write module write request,keep '1' until read_req_ack = '1'
	.write_req_ack              (ch4_write_req_ack        ), // output     data write module write request response
	.write_finish               (                         ), // output     data write module write request finish
	.write_addr_0               (25'd7220800              ), // input      data write module write request base address 0, used when write_addr_index = 0
	.write_addr_1               (25'd8257600              ), // input      data write module write request base address 1, used when write_addr_index = 1
	.write_addr_index           (ch4_write_addr_index     ), // input      select valid base address from write_addr_0 write_addr_1
	.write_len                  (25'd32400                ), // input      data write module write request data length
	.write_en                   (ch4_write_en             ), // input      data write module write request for one data
	.write_data                 (ch4_write_data           )  // input      write data
);

frame_read_write #(
	.MEM_DATA_BITS              (256                      ),
	.READ_DATA_BITS             (16                       ),
	.WRITE_DATA_BITS            (16                       ),
	.ADDR_BITS                  (25                       ),
	.BUSRT_BITS                 (10                       ),
	.BURST_SIZE                 (16                       )  //?
)
frame_read_write_channel_5
(
	.rst                        (~ddr_init_done           ),
	.mem_clk                    (core_clk                 ),

	.rd_burst_req               (ch5_rd_burst_req         ), // output     to external memory controller,send out a burst read request
	.rd_burst_len               (ch5_rd_burst_len         ), // output     to external memory controller,data length of the burst read request, not bytes
	.rd_burst_addr              (ch5_rd_burst_addr        ), // output     to external memory controller,base address of the burst read request 
	.rd_burst_data_valid        (ch5_rd_burst_data_valid  ), // input      from external memory controller,read data valid 
	.rd_burst_data              (ch5_rd_burst_data        ), // input      from external memory controller,read request data
	.rd_burst_finish            (ch5_rd_burst_finish      ), // input      from external memory controller,burst read finish

//	.read_clk                   (pix_clk                  ), // input      data read module clock
   .read_clk                   (pix_clk                  ), // input      data read module clock
	.read_req                   (ch5_read_req             ), // input  
	.read_req_ack               (ch5_read_req_ack         ), // output     data read module read request response
	.read_finish                (                         ), // output     data read module read request finish
	.read_addr_0                (25'd9000000              ), // input      data read module read request base address 0, used when read_addr_index = 0
	.read_addr_1                (25'd11000000             ), // input      data read module read request base address 1, used when read_addr_index = 1
	.read_addr_index            (ch5_read_addr_index      ), // input      select valid base address from read_addr_0 read_addr_1
	.read_len                   ((scale_state ? 25'd129600 : wr_bust_total_len)), // input      data read module read request data length  //frame size  1024 * 768 * 16 / 64  一帧地址长度
	.read_en                    (ch5_read_en              ), // input      data read module read request for one data, read_data valid next clock
	.read_data                  (ch5_read_data            ), // output     read data

	.wr_burst_req               (ch5_wr_burst_req         ), // output     to external memory controller,send out a burst write request
	.wr_burst_len               (ch5_wr_burst_len         ), // output     to external memory controller,data length of the burst write request, not bytes
	.wr_burst_addr              (ch5_wr_burst_addr        ), // output     to external memory controller,base address of the burst write request 
	.wr_burst_data_req          (ch5_wr_burst_data_req    ), // input      from external memory controller,write data request ,before data 1 clock
	.wr_burst_data              (ch5_wr_burst_data        ), // output     to external memory controller,write data
	.wr_burst_finish            (ch5_wr_burst_finish      ), // input      from external memory controller,burst write finish

	.write_clk                  (clk_100M                 ), // input      data write module clock
	.write_req                  (ch5_write_req            ), // input      data write module write request,keep '1' until read_req_ack = '1'
	.write_req_ack              (ch5_write_req_ack        ), // output     data write module write request response
	.write_finish               (                         ), // output     data write module write request finish
	.write_addr_0               (25'd9000000              ), // input      data write module write request base address 0, used when write_addr_index = 0
	.write_addr_1               (25'd11000000             ), // input      data write module write request base address 1, used when write_addr_index = 1
	.write_addr_index           (ch5_write_addr_index     ), // input      select valid base address from write_addr_0 write_addr_1
	.write_len                  ((scale_state ? 25'd129600 : wr_bust_total_len)), // input      data write module write request data length
	.write_en                   (ch5_write_en             ), // input      data write module write request for one data
	.write_data                 (ch5_write_data           )  // input      write data
);


frame_read_write#(
	.MEM_DATA_BITS              (256                      ),
	.READ_DATA_BITS             (16                       ),
	.WRITE_DATA_BITS            (16                       ),
	.ADDR_BITS                  (25                       ),
	.BUSRT_BITS                 (10                       ),
	.BURST_SIZE                 (16                       )  //?
)
frame_read_write_channel_6 
(
	.rst                        (~ddr_init_done         ),
	.mem_clk                    (core_clk                 ),

	.rd_burst_req               (ch6_rd_burst_req         ), // output     to external memory controller,send out a burst read request
	.rd_burst_len               (ch6_rd_burst_len         ), // output     to external memory controller,data length of the burst read request, not bytes
	.rd_burst_addr              (ch6_rd_burst_addr        ), // output     to external memory controller,base address of the burst read request 
	.rd_burst_data_valid        (ch6_rd_burst_data_valid  ), // input      from external memory controller,read data valid 
	.rd_burst_data              (ch6_rd_burst_data        ), // input      from external memory controller,read request data
	.rd_burst_finish            (ch6_rd_burst_finish      ), // input      from external memory controller,burst read finish

	// .read_clk                   (pix_clk                  ), // input      data read module clock
	.read_clk                   (clk_50M                  ), // input      data read module clock
	.read_req                   (ch6_read_req             ), // input  
	.read_req_ack               (ch6_read_req_ack         ), // output     data read module read request response
	.read_finish                (                         ), // output     data read module read request finish
	.read_addr_0                (25'd13000000              ), // input      data read module read request base address 0, used when read_addr_index = 0
	.read_addr_1                (25'd15000000              ), // input      data read module read request base address 1, used when read_addr_index = 1
	.read_addr_index            (ch6_read_addr_index      ), // input      select valid base address from read_addr_0 read_addr_1
	.read_len                   (25'd129600                ), // input      data read module read request data length  //frame size  1024 * 768 * 16 / 64  一帧地址长度
	.read_en                    (ch6_read_en              ), // input      data read module read request for one data, read_data valid next clock
	.read_data                  (ch6_read_data            ), // output     read data

	.wr_burst_req               (ch6_wr_burst_req         ), // output     to external memory controller,send out a burst write request
	.wr_burst_len               (ch6_wr_burst_len         ), // output     to external memory controller,data length of the burst write request, not bytes
	.wr_burst_addr              (ch6_wr_burst_addr        ), // output     to external memory controller,base address of the burst write request 
	.wr_burst_data_req          (ch6_wr_burst_data_req    ), // input      from external memory controller,write data request ,before data 1 clock
	.wr_burst_data              (ch6_wr_burst_data        ), // output     to external memory controller,write data
	.wr_burst_finish            (ch6_wr_burst_finish      ), // input      from external memory controller,burst write finish

	.write_clk                  (pixclk_in6                ), // input      data write module clock
	.write_req                  (ch6_write_req            ), // input      data write module write request,keep '1' until read_req_ack = '1'
	.write_req_ack              (ch6_write_req_ack        ), // output     data write module write request response
	.write_finish               (                         ), // output     data write module write request finish
	.write_addr_0               (25'd13000000             ), // input      data write module write request base address 0, used when write_addr_index = 0
	.write_addr_1               (25'd15000000              ), // input      data write module write request base address 1, used when write_addr_index = 1
	.write_addr_index           (ch6_write_addr_index     ), // input      select valid base address from write_addr_0 write_addr_1
	.write_len                  (25'd129600                ), // input      data write module write request data length
	.write_en                   (ch6_write_en             ), // input      data write module write request for one data
	.write_data                 (ch6_write_data           )  // input      write data
);

color_bar color_bar_m0(
	// .clk                        (pix_clk                  ), // input 
	.clk                        (clk_50M                  ), // input 
	.rst                        (~ddr_init_done         ), // input 
	.hs                         (color_bar_hs             ), // output
	.vs                         (color_bar_vs             ), // output
	.de                         (color_bar_de             ), // output
	.rgb_r                      (color_bar_r              ), // output
	.rgb_g                      (color_bar_g              ), // output
	.rgb_b                      (color_bar_b              )  // output
);
video_rect_read_data video_rect_read_data_channel_6
(
	// .video_clk                  (pix_clk                    ),
	.video_clk                  (clk_50M                    ),
	.rst                        (~ddr_init_done           ),

	.video_left_offset          (12'd0                      ), //input
	.video_top_offset           (12'd0                      ), //input
	.video_width                (12'd1920), //input
	.video_height	            (12'd1080                    ), //input

	.read_req                   (ch6_read_req               ), //output
	.read_req_ack               (ch6_read_req_ack           ), //input
	.read_en                    (ch6_read_en                ), //output ch0数据请求信号,数据在下一个时钟从读FIFO读端口输出
	.read_data                  (ch6_read_data              ), //input  ch0读FIFO读端口输出数据

	.timing_hs                  (color_bar_hs               ), //input
	.timing_vs                  (color_bar_vs               ), //input
	.timing_de                  (color_bar_de               ), //input
	.timing_data 	            ({color_bar_r[4:0],color_bar_g[5:0],color_bar_b[4:0]}), //input

	.hs                         (v6_hs                      ), //output
	.vs                         (v6_vs                      ), //output
	.de                         (v6_de                      ), //output
	.vout_data                  (v6_data                    )  //output
);

//generate a frame read data request 
video_rect_read_data video_rect_read_data_channel_1
(
	// .video_clk                  (pix_clk                    ),
	.video_clk                  (clk_50M                    ),
	.rst                        (~ddr_init_done             ),

	.video_left_offset          (12'd0                      ), //input
	.video_top_offset           (12'd0                      ), //input
	.video_width                (12'd960), //input
	.video_height	            (12'd540                    ), //input

	.read_req                   (ch1_read_req               ), //output
	.read_req_ack               (ch1_read_req_ack           ), //input
	.read_en                    (ch1_read_en                ), //output ch0数据请求信号,数据在下一个时钟从读FIFO读端口输出
	.read_data                  (ch1_read_data              ), //input  ch0读FIFO读端口输出数据

	.timing_hs                  (color_bar_hs               ), //input
	.timing_vs                  (color_bar_vs               ), //input
	.timing_de                  (color_bar_de               ), //input
	.timing_data 	            ({color_bar_r[4:0],color_bar_g[5:0],color_bar_b[4:0]}), //input

	.hs                         (v0_hs                      ), //output
	.vs                         (v0_vs                      ), //output
	.de                         (v0_de                      ), //output
	.vout_data                  (v0_data                    )  //output
);

video_rect_read_data video_rect_read_data_channel_2
(
	// .video_clk                  (pix_clk                    ),
	.video_clk                  (clk_50M                  ),//input
	.rst                        (~ddr_init_done           ),//input 
	
	.video_left_offset          (12'd960                  ),//input 
	.video_top_offset           (12'd0                    ),//input 
	.video_width                (12'd960                  ),//input 
	.video_height	            (12'd540                  ),//input 

	.read_req                   (ch2_read_req             ),//output Start reading a frame of data    
	.read_req_ack               (ch2_read_req_ack         ),//input  数据请求响应
	.read_en                    (ch2_read_en              ),//output 输出视频数据有效
	.read_data                  (ch2_read_data            ),//input  视频数据

	.timing_hs                  (v0_hs                    ),//input  
	.timing_vs                  (v0_vs                    ),//input 
	.timing_de                  (v0_de                    ),//input 
	.timing_data 	            (v0_data                  ),//input 

	.hs                         (v1_hs                    ),//output
	.vs                         (v1_vs                    ),//output
	.de                         (v1_de                    ),//output
	.vout_data                  (v1_data                  )	//output
);
//
video_rect_read_data video_rect_read_data_channel_3
(
	// .video_clk                  (pix_clk                    ),
	.video_clk                  (clk_50M                  ),//input 
	.rst                        (~ddr_init_done           ),//input 
	
	.video_left_offset          (12'd0                    ),//input 
	.video_top_offset           (12'd540                  ),//input 
	.video_width                (12'd960                  ),//input 
	.video_height	            (12'd540                  ),//input 

	.read_req                   (ch3_read_req             ),//output Start reading a frame of data    
	.read_req_ack               (ch3_read_req_ack         ),//input  数据请求响应
	.read_en                    (ch3_read_en              ),//output 输出视频数据有效
	.read_data                  (ch3_read_data            ),//input  视频数据

	.timing_hs                  (v1_hs),//input  
	.timing_vs                  (v1_vs),//input 
	.timing_de                  (v1_de),//input 
	.timing_data 	            (v1_data                  ),//input 

	.hs                         (v2_hs                    ),//output
	.vs                         (v2_vs                    ),//output
	.de                         (v2_de                    ),//output
	.vout_data                  (v2_data                  )	//output
);

video_rect_read_data video_rect_read_data_channel_4
(
	// .video_clk                  (pix_clk                    ),
	.video_clk                  (clk_50M                  ),//input 
	.rst                        (~ddr_init_done           ),//input 
	
	.video_left_offset          (12'd960                  ),//input 
	.video_top_offset           (12'd540                  ),//input 
	.video_width                (12'd960                  ),//input 
	.video_height	            (12'd540                  ),//input 

	.read_req                   (ch4_read_req             ),//output Start reading a frame of data    
	.read_req_ack               (ch4_read_req_ack         ),//input  数据请求响应
	.read_en                    (ch4_read_en              ),//output 输出视频数据有效
	.read_data                  (ch4_read_data            ),//input  视频数据

	.timing_hs                  (v2_hs                    ),//input  
	.timing_vs                  (v2_vs                    ),//input 
	.timing_de                  (v2_de                    ),//input 
	.timing_data 	            (v2_data                  ),//input 

	.hs                         (hs                       ),//output
	.vs                         (vs                       ),//output
	.de                         (de                       ),//output
	.vout_data                  (vout_data                )	//output
);

wire                        color_bar_hs1;
wire                        color_bar_vs1;
wire                        color_bar_de1;
wire [7:0]                  color_bar_r1 ;
wire [7:0]                  color_bar_g1 ;
wire [7:0]                  color_bar_b1 ;

wire [15:0]					scale_data_final  ;
wire  						   scale_vs_final	;
wire 						   scale_hs_final	;
wire  						   scale_de_final	;

color_bar color_bar_scale(
	.clk                        (pix_clk                  ), // input 
	.rst                        (~ddr_init_done           ), // input 
	.hs                         (color_bar_hs1		  ), // output
	.vs                         (color_bar_vs1		  ), // output
	.de                         (color_bar_de1		  ), // output
	.rgb_r                      (color_bar_r1 		  ), // output
	.rgb_g                      (color_bar_g1 		  ), // output
	.rgb_b                      (color_bar_b1 		  )  // output
);

video_rect_read_data video_rect_read_data_channel_5
(
	.video_clk                  (pix_clk                  ),//input 
	.rst                        (~ddr_init_done           ),//input 
	
   	.video_left_offset          (0),//input 
	.video_top_offset           (0),//input 
	.video_width                (t_width                  ),//input 
	.video_height	              (t_height                 ),//input 

	.read_req                   (ch5_read_req             ),//output Start reading a frame of data    
	.read_req_ack               (ch5_read_req_ack         ),//input  
	.read_en                    (ch5_read_en              ),//output 
	.read_data                  (ch5_read_data            ),//input  

	.timing_hs                  (color_bar_hs1       ),//input  
	.timing_vs                  (color_bar_vs1       ),//input 
	.timing_de                  (color_bar_de1       ),//input 
	.timing_data 	            ({color_bar_r1[4:0],color_bar_g1[5:0],color_bar_b1[4:0]}),//input 

	.hs                         (scale_hs_final                 ),//output
	.vs                         (scale_vs_final                 ),//output
	.de                         (scale_de_final                 ),//output
	.vout_data                  (scale_data_final               )	//output
);



//调整亮度
wire    [7:0]  ligher_data_y;
wire    [7:0]  ligher_data_g;
wire    [7:0]  ligher_data_b;

wire    lighter_hs;
wire    lighter_vs;
wire    lighter_de;

wire    change_yuv;

yuv  ycbcr
(
.clk (pix_clk), // 模块驱动时钟
.rst_n (~ddr_init_done), // 复位信号
.key3(key3),
.change_yuv(change_yuv),
//图像处理前的数据接口
.pre_frame_vsync (scale_vs_final), // vsync 信号
.pre_frame_hsync (scale_hs_final), // hsync 信号
.pre_frame_de (scale_de_final), // data enable 信号
.img_red (scale_data_final[15:11]), // 输入图像数据 R
.img_green (scale_data_final[10: 5]), // 输入图像数据 G
.img_blue (scale_data_final[ 4: 0]), // 输入图像数据 B

//图像处理后的数据接口
.post_frame_vsync(lighter_vs), // vsync 信号
.post_frame_hsync(lighter_hs), // hsync 信号
.post_frame_de (lighter_de), // data enable 信号
.img_y (ligher_data_y), // 输出图像 Y 数据
.img_cb (ligher_data_g), // 输出图像 Cb 数据
.img_cr(ligher_data_b) // 输出图像 Cr 数据
);


wire    lighter_and_color_hs;
wire    lighter_and_color_vs;
wire    lighter_and_color_de;
wire   [23:0] lighter_and_color_data;

wire   [2:0]  rgb_ctrl_plus10;
wire   [2:0]  r_ctrl_plus10;
wire   [2:0]  g_ctrl_plus10;
wire   [2:0]  b_ctrl_plus10;
lighter_and_color lighter_and_color(

  .rgb_ctrl_plus10(rgb_ctrl_plus10),//控制rgb按键4来控制
  .r_ctrl_plus10(r_ctrl_plus10)     ,
  .g_ctrl_plus10(g_ctrl_plus10)     ,
  .b_ctrl_plus10(b_ctrl_plus10)     ,   


	.clk(pix_clk),
	.rst_n(~ddr_init_done),

	.hs_in(lighter_hs),
	.vs_in(lighter_vs),
	.de_in(lighter_de),
	.data_in({ligher_data_y,ligher_data_g,ligher_data_b}),

//output
	.hs_out(lighter_and_color_hs),
	.vs_out(lighter_and_color_vs),
	.de_out(lighter_and_color_de),
	.data_out(lighter_and_color_data)
		
);


wire [7:0] gauss_r;
wire [7:0] gauss_g;
wire [7:0] gauss_b;
wire [7:0] gauss_y;
wire [7:0] gauss_rr;
wire [7:0] gauss_gg;
wire [7:0] gauss_bb;


assign gauss_r=lighter_and_color_data[23:16];
assign gauss_g=lighter_and_color_data[15:8];
assign gauss_b=lighter_and_color_data[7:0];

//sobel
wire [7:0] sobel_y;
wire [7:0] sobel_g;
wire [7:0] sobel_b;
wire     sobel_de;
wire     sobel_hs;
wire     sobel_vs;
wire    change_sobel;
wire   [20:0] threshold;
sobel_test sobel_test_m0 (
    .clk                (pix_clk             ),                // INPUT
    .clk_fifo           (clk_50M             ), 
    .rst_n              (ddr_init_done       ),            // INPUT
    .ycbcr_vs           (lighter_and_color_vs),      // INPUT
    .ycbcr_hs           (lighter_and_color_hs),      // INPUT
    .ycbcr_de           (lighter_and_color_de),      // INPUT
    .ycbcr_y            (gauss_r             ),        // INPUT[7:0] 
    .ycbcr_g            (gauss_g             ),
    .ycbcr_b            (gauss_b             ),
    .sobel_vs_out       (sobel_vs            ),      // OUTPUT
    .sobel_hs_out       (sobel_hs            ),      // OUTPUT
    .sobel_de_out       (sobel_de            ),      // OUTPUT
    .threshold          (threshold           ),    // INPUT[20:0] 
    .sobel_y_out        (sobel_y             ),  // OUTPUT[7:0]
    .sobel_g_out        (sobel_g             ),  // OUTPUT[7:0]
    .sobel_b_out        (sobel_b             ),  // OUTPUT[7:0]
    .change_sobel       (change_sobel        ) 
);

wire  [127:0] char0         ;
wire  [127:0] char1         ;
wire  [127:0] char2         ;
wire  [127:0] char3         ;
wire  [127:0] char4         ;
wire  [127:0] char5         ;
wire  [127:0] char6         ;
wire  [127:0] char7         ;
wire  [127:0] char8         ;
wire  [127:0] char9         ;
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
wire  [127:0] char24        ;
wire  [127:0] char25        ;
wire  [127:0] char26        ;
wire  [127:0] char27        ;
wire  [127:0] char28        ;
wire  [127:0] char29        ;
wire  [127:0] char30        ;
wire  [127:0] char31        ;

wire [31:0]ether_data;
wire  ether_hs;
wire  ether_vs;
wire  ether_de;
wire  [23:0] final_data;
wire  gmii_rx_clk;
osd_display osd_display(
	.rst_n(~ddr_init_done),   
	.pclk(pix_clk),
	.adc_clk(sys_clk),
	.adc_buf_data(ether_data),
   .rec_en(rec_en),
	.i_hs(sobel_hs),    
	.i_vs(sobel_vs),    
	.i_de(sobel_de),	
	.i_data({sobel_y[7:3],sobel_g[7:2],sobel_b[7:3]}),  
	.o_hs(ether_hs),    
	.o_vs(ether_vs),    
	.o_de(ether_de),    
	.o_data(final_data),
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


always@(posedge pix_clk) begin 


   r_out<={final_data[15:11],3'b000}; 
   g_out<={final_data[10:5],2'b00};   
   b_out<={final_data[5:0],3'b000};   
   vs_out<=ether_vs;
   hs_out<=ether_hs;
   de_out<=ether_de;
end

DDR3_50H #
  (
   //***************************************************************************
   // The following parameters are Memory Feature
   //***************************************************************************
   .MEM_ROW_WIDTH          (MEM_ROW_ADDR_WIDTH),     
   .MEM_COLUMN_WIDTH       (MEM_COL_ADDR_WIDTH),     
   .MEM_BANK_WIDTH         (MEM_BADDR_WIDTH   ),     
   .MEM_DQ_WIDTH           (MEM_DQ_WIDTH      ),     
   .MEM_DM_WIDTH           (MEM_DM_WIDTH      ),     
   .MEM_DQS_WIDTH          (MEM_DQS_WIDTH     ),     
   .CTRL_ADDR_WIDTH        (CTRL_ADDR_WIDTH   )     
  )

  u_DDR3_50H(
   .ref_clk                (sys_clk               ),
   .resetn                 (sys_rst_n             ),
   .ddr_init_done          (ddr_init_done         ),
   .ddrphy_clkin           (core_clk              ),
   .pll_lock               (pll_lock              ), 

   .axi_awaddr             (axi_awaddr                 ),
   .axi_awuser_ap          (1'b0                       ),
   .axi_awuser_id          (axi_awuser_id              ),
   .axi_awlen              (axi_awlen                  ),
   .axi_awready            (axi_awready                ),
   .axi_awvalid            (axi_awvalid                ),

   .axi_wdata              (axi_wdata                  ),
   .axi_wstrb              (axi_wstrb                  ),
   .axi_wready             (axi_wready                 ),
   .axi_wusero_id          (                       ),
   .axi_wusero_last        (axi_wusero_last        ),

   .axi_araddr             (axi_araddr                 ),
   .axi_aruser_ap          (1'b0                       ),
   .axi_aruser_id          (axi_aruser_id         ),
   .axi_arlen              (axi_arlen                  ),
   .axi_arready            (axi_arready                ),
   .axi_arvalid            (axi_arvalid                ),
   .axi_rdata              (axi_rdata                  ),
   .axi_rid                (axi_rid                    ),
   .axi_rlast              (axi_rlast                  ),
   .axi_rvalid             (axi_rvalid                 ),

   .apb_clk                (1'b0                   ),
   .apb_rst_n              (1'b0                   ),
   .apb_sel                (1'b0                   ),
   .apb_enable             (1'b0                   ),
   .apb_addr               (8'd0                   ),
   .apb_write              (1'b0                   ),
   .apb_ready              (                       ),
   .apb_wdata              (16'd0                  ),
   .apb_rdata              (                       ),
   .apb_int                (                       ),
   .debug_data             (                       ),
   .debug_slice_state      (                       ),
   .debug_calib_ctrl       (                       ),
   .ck_dly_set_bin         (                       ),
   .dll_step               (                       ),
   .dll_lock               (                       ),
   .init_read_clk_ctrl     (                       ),                                                       
   .init_slip_step         (                       ), 
   .force_read_clk_ctrl    (                       ),  

   .mem_rst_n              (mem_rst_n              ),
   .mem_ck                 (mem_ck                 ),
   .mem_ck_n               (mem_ck_n               ),
   .mem_cke                (mem_cke                ),

   .mem_cs_n               (mem_cs_n               ),

   .mem_ras_n              (mem_ras_n              ),
   .mem_cas_n              (mem_cas_n              ),
   .mem_we_n               (mem_we_n               ),
   .mem_odt                (mem_odt                ),
   .mem_a                  (mem_a                  ),
   .mem_ba                 (mem_ba                 ),
   .mem_dqs                (mem_dqs                ),
   .mem_dqs_n              (mem_dqs_n              ),
   .mem_dq                 (mem_dq                 ),
   .mem_dm                 (mem_dm                 ),
    //debug
    .debug_data                (                   ),// output [135:0]
    .debug_slice_state         (                   ),// output [51:0]
    .debug_calib_ctrl          (                   ),// output [21:0]
    .ck_dly_set_bin            (                   ),// output [7:0]
    .force_ck_dly_en           (1'b0               ),// input
    .force_ck_dly_set_bin      (8'h05              ),// input [7:0]
    .dll_step                  (                   ),// output [7:0]
    .dll_lock                  (                   ),// output
    .init_read_clk_ctrl        (2'b0               ),// input [1:0]
    .init_slip_step            (4'b0               ),// input [3:0]
    .force_read_clk_ctrl       (1'b0               ),// input
    .ddrphy_gate_update_en     (1'b0               ),// input
    .update_com_val_err_flag   (                   ),// output [3:0]
    .rd_fake_stop              (1'b0               ) // input

  );



  wire            free_clk_g;
wire            pll_locked  ;
wire            sys_rstn ;

//HSST_TX
wire            tx2_clk   ;
wire    [ 3:0]  hsst_txk  /*synthesis PAP_MARK_DEBUG="1"*/;
wire    [31:0]  hsst_txd  /*synthesis PAP_MARK_DEBUG="1"*/;

//HSST_RX
wire            rx2_clk/*synthesis PAP_MARK_DEBUG="1"*/;
wire    [ 3:0]  hsst_rxk/*synthesis PAP_MARK_DEBUG="1"*/;
wire    [31:0]  hsst_rxd/*synthesis PAP_MARK_DEBUG="1"*/;

wire            rx3_clk/*synthesis PAP_MARK_DEBUG="1"*/;
wire    [ 3:0]  hsst_rxk3/*synthesis PAP_MARK_DEBUG="1"*/;
wire    [31:0]  hsst_rxd3/*synthesis PAP_MARK_DEBUG="1"*/;

wire    [ 3:0]  align_rxk;
wire    [31:0]  align_rxd;

wire    [ 3:0]  align_rxk3;
wire    [31:0]  align_rxd3;

//RGB
wire                    vs_in4/*synthesis PAP_MARK_DEBUG="1"*/;
wire                    de_in4/*synthesis PAP_MARK_DEBUG="1"*/;
wire        [15:0]      rgb_data4/*synthesis PAP_MARK_DEBUG="1"*/;

assign          SFP_TX_DISABLE2 = 1'b0 ;
assign          SFP_TX_DISABLE3 = 1'b0 ;

assign          sys_rstn = sys_rst_n && pll_lock; 

  pll_1 pll_1_inst 
  (
	.clkin1   (free_clk_g ),      // input
	.pll_lock (pll_locked   ),      // output
	.clkout0  (ad_clk     )       // output   20M
  ); 
  
  GTP_CLKBUFG free_clk_ibufg 
  (
	  .CLKOUT(free_clk_g),
	  .CLKIN (sys_clk  )
  );
  
  ad_data_send    ad_data_send_inst
  (
	  .tx_clk    (tx2_clk  ) ,    //input           wire            
	  .ad_clk    (ad_clk   ) ,    //input           wire            
	  .rst_n     (sys_rstn) ,    //input           wire            
  
	  .ad_data   (ad_data  ) ,    //input           wire    [ 7:0]  
   
	  .hsst_txd  (hsst_txd ) ,    //output          reg     [31:0]  
	  .hsst_txk  (hsst_txk )      //output          reg     [ 3:0]  
  
  ); 
	 
  hsst_test_dut_top    hsst_test_dut_top_inst
  (
	  //GT2_TX
	  .gt2_txfsmresetdone    (              ),    //LANE_2 初始化完成    output         
	  .tx2_clk               (tx2_clk    ),    //LANE_2 发送时钟      output         
	  .tx2_data              (hsst_txd   ),    //LANE_2 发送数据      input  [31:0]  
	  .tx2_kchar             (hsst_txk   ),    //LANE_2 发送数据K码   input  [3:0]   
	  //GT2_RX                              
	  .rx2_clk               (rx2_clk  ),    //LANE_2 接收时钟      output         
	  .o_rxd_2               (hsst_rxd ),    //LANE_2 接收数据      output [39:0]  
	  .o_rxk_2               (hsst_rxk ),    //LANE_2 接收数据K码   output [3:0]   
	  //GT3_TX
	  .gt3_txfsmresetdone    (              ),    //LANE_3 初始化完成    output         
	  .tx3_clk               (             ),    //LANE_3 发送时钟      output         
	  .tx3_data              (             ),    //LANE_3 发送数据      input  [31:0]  
	  .tx3_kchar             (             ),    //LANE_3 发送数据K码   input  [3:0]   
	  //GT3_RX                              
	  .rx3_clk               (rx3_clk     ),    //LANE_3 接收时钟      output         
	  .o_rxd_3               (hsst_rxd3    ),    //LANE_3 接收数据      output [39:0]  
	  .o_rxk_3               (hsst_rxk3    ),    //LANE_3 接收数据K码   output [3:0]   
	  //user
	  .i_free_clk            (free_clk_g    ),    //input          
	  .rst_n                 (sys_rstn     ),
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
  
  word_align  word_align_inst
  (
	  .rx_clk    (rx2_clk  ) ,    //input       wire            
	  .rst_n     (sys_rstn) ,    //input       wire            
  
	  .hsst_rxd  (hsst_rxd ) ,    //input       wire   [31:0]   
	  .hsst_rxk  (hsst_rxk ) ,    //input       wire   [ 3:0]   
  
	  .align_rxd (align_rxd) ,    //output      reg    [31:0]   
	  .align_rxk (align_rxk)      //output      reg    [ 4:0]   
  );

  word_align  word_align_inst1
  (
	  .rx_clk    (rx3_clk  ) ,    //input       wire            
	  .rst_n     (sys_rstn) ,    //input       wire            
  
	  .hsst_rxd  (hsst_rxd3 ) ,    //input       wire   [31:0]   
	  .hsst_rxk  (hsst_rxk3 ) ,    //input       wire   [ 3:0]   
  
	  .align_rxd (align_rxd3) ,    //output      reg    [31:0]   
	  .align_rxk (align_rxk3)      //output      reg    [ 4:0]   
  );
 assign wr_en = (align_rxk3 == 4'd0)? 'd1 : 'd0;

 wire   [127:0]     rd_data ;
 wire               rd_en   ;
 wire   [7:0]       fifo_waterlevel /*synthesis PAP_MARK_DEBUG="1"*/;
 wire   [9:0]       wr_water_level /*synthesis PAP_MARK_DEBUG="1"*/ ;
  async_fifo the_instance_name (
  .wr_clk            (rx3_clk),                // input
  .wr_rst            (~sys_rstn ),                // input
  .wr_en             (wr_en),                  // input
  .wr_data           (align_rxd3),              // input [31:0]
  .wr_water_level    (wr_water_level),    // output [9:0]
  .wr_full           (),              // output
  .almost_full       (),      // output
  .rd_clk            (pix_clk),                // input
  .rd_rst            (~sys_rstn  ),                // input
  .rd_en             (rd_en),                  // input
  .rd_data           (rd_data),              // output [127:0]
  .rd_empty          (),            // output
  .rd_water_level    (fifo_waterlevel),    // output [7:0]
  .almost_empty      ()     // output
);

read_asyn_fifo  read_asyn_fifo_inst (
    .clk(pix_clk),
    .rstn(sys_rstn),
    .fifo_waterlevel(fifo_waterlevel),
    .rd_data(rd_data),
    .rd_en(rd_en),
	.rd_done (rd_done),
    .char0(char0),
    .char1(char1),
    .char2(char2),
    .char3(char3),
    .char4(char4),
    .char5(char5),
    .char6(char6),
    .char7(char7),
    .char8(char8),
    .char9(char9),
    .char10(char10),
    .char11(char11),
    .char12(char12),
    .char13(char13),
    .char14(char14),
    .char15(char15),
    .char16(char16),
    .char17(char17),
    .char18(char18),
    .char19(char19),
    .char20(char20),
    .char21(char21),
    .char22(char22),
    .char23(char23),
    .char24(char24),
    .char25(char25),
    .char26(char26),
    .char27(char27),
    .char28(char28),
    .char29(char29),
    .char30(char30),
    .char31(char31)
  );
  
  video_packet_rec video_packet_rec_inst
  (
	  .rst       (~sys_rstn   ),
	  .rx_clk    (rx2_clk      ),
	  .pix_clk   (pixclk_in1     ),
	  .gt_rx_data(align_rxd    ),
	  .gt_rx_ctrl(align_rxk    ),
	  .vout_width(16'd1920     ),
	  
	  .vs        (vs_in4           ),    //output
	  .de        (de_in4  ),    //output
	  .vout_data (rgb_data4     )     //output
  );
                 

endmodule
