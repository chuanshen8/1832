module adc_fft_top
(
    input           wire                clk,
    input           wire                rst_n,
    input           wire        [7:0]   ad_data,
    input           wire                ad_clk,
    
    output          reg                 fft_data_valid,  
    output          wire        [15:0]  fft_data,   
    output          wire                real_data_valid,  
    output          wire        [15:0]  real_data   
);

wire                key_flag/*synthesis PAP_MARK_DEBUG="1"*/;
wire                sample_clk  /*synthesis PAP_MARK_DEBUG="1"*/;
                    
wire    [15:0]      source_real;
wire    [15:0]      source_imag;
wire                o_axi4s_data_tvalid;
wire                i_axi4s_data_tlast;
wire                i_axi4s_cfg_tvalid;

wire                source_eop;
wire                source_sop;

wire                fft_data_valid_d1;


fft_data_gen   fft_data_gen_inst
(   
    .clk                  (clk                ) ,   //input           wire           
    .rst_n                (rst_n              ) ,   //input           wire             
                                              
    .ad_clk               (ad_clk             ) ,   //input           wire           
    .ad_data              (ad_data            ) ,   //input           wire   [7:0]   

    .o_axi4s_data_tvalid  (o_axi4s_data_tvalid) ,   //input           wire           
  
    .i_axi4s_cfg_tvalid   (i_axi4s_cfg_tvalid ) ,   //output          wire           
    .i_axi4s_data_tlast   (i_axi4s_data_tlast ) ,   //output          reg            
    .i_axi4s_data_tdata   (real_data          ) ,   //output          reg    [15:0]  
    .i_axi4s_data_tvalid  (real_data_valid    )     //output          reg            
);
   
fft_demo_00  u_fft_wrapper
( 
	.i_aclk              (clk                       ),
                                                   
	.i_axi4s_data_tvalid (real_data_valid           ),  //input
	.i_axi4s_data_tdata  (real_data                 ),  //input
	.i_axi4s_data_tlast  (i_axi4s_data_tlast        ),
	.o_axi4s_data_tready (                          ),
	.i_axi4s_cfg_tvalid  (i_axi4s_cfg_tvalid        ),
	.i_axi4s_cfg_tdata   (1'b1                      ),
    
	.o_axi4s_data_tvalid (o_axi4s_data_tvalid       ),
	.o_axi4s_data_tdata  ({source_real, source_imag}),
	.o_axi4s_data_tlast  (source_eop                ),
	.o_axi4s_data_tuser  (                          ),
	.o_alm               (                          ),
	.o_stat              (source_sop                )
);
   
data_modulus	data_modulus_inst
(
	.clk_50m	  (clk                 ),
	.rst_n		  (rst_n               ),
	//FFT ST 接口                      
	.source_real  (source_real         ),
	.source_imag  (source_imag         ),
	.source_sop	  (source_sop          ),
	.source_eop	  (source_eop          ),
	.source_valid (o_axi4s_data_tvalid ),
	//取模运算后的数据接口              
	.data_modulus (fft_data            ),
	.data_sop     (                    ),
	.data_eop     (                    ),
	.data_valid   (fft_data_valid_d1   )
);

always@(posedge clk or negedge rst_n)
    if(!rst_n)
        fft_data_valid <= 1'b0;
    else               
        fft_data_valid <= fft_data_valid_d1;

endmodule