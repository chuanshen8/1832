module vin_scale_down(
    input                 pixel_clk        ,
    input                 sram_clk         ,
    input                 sys_rst_n        ,//复位信号 
    input                 hs               ,//行信号
    input                 vs               ,//场信号
    input                 de               ,//数据使能信号
    input      [11:0]     s_width          ,//缩放前宽度
    input      [11:0]     s_height         ,//缩放前高度
    input      [11:0]     t_width          ,//缩放后宽度
    input      [11:0]     t_height         ,//缩放后高度 
    input      [7:0]      pixel_data       ,//缩放前数据
    input      [15:0]     h_scale_k        ,//列缩放因子
    input      [15:0]     v_scale_k        ,//行缩放因子
    input                 fifo_scale_rden  ,//缩放后 fifo 读使能
    output     [7:0]      sram_data_out    ,//缩放后数据
    output                data_valid       ,//缩放后数据有效信号
    output                fifo_scale_rdempty,//缩放后 fifo 空信号      
    output   		      frame_flag	   //帧头标志信号	
);

//reg define 
    reg                   de_d0                 ;
    reg                   vs_d0                 ;
    reg        [15:0]     vs_d                  ;
    reg                   frame_flag            ;//帧头标志信号
    reg        [7:0]      pixel_data_d0         ; 
    reg                   data_valid            ;//缩放后数据有效信号
    reg                   data_ready            ;//fifo 一行数据准备完成信       
                                
//wire define                    
    wire                  scaler_rd_req         ;//缩放前数据请求信号
    wire                  fifo_rdempty          ;//缩放前 fifo 的空信号
    wire       [7:0]      fifo_data             ;//缩放前 fifo 的输出数据
    wire       [7:0]      scaler_data_out       ;//缩放后数据
    wire                  scaler_wren           ;//缩放后 fifo 写使能
    wire                  fifo_scale_rdempty    ;//缩放后 fifo 空信号
    wire       [10:0]     rd_data_count         ;//fifo 缓存计数器       


//*****************************************************
//** main code
//*****************************************************
//对信号打拍
always@(posedge pixel_clk)begin
	de_d0 <= de;
	pixel_data_d0 <= pixel_data;
end

//产生数据有效信号
always@(posedge sram_clk)begin
	data_valid <= fifo_scale_rden; 
	vs_d0 <= vs;
	vs_d <= {vs_d[14:0], vs_d0};
	frame_flag <= vs_d[1] && ~vs_d[0];
end	

//产生 fifo 一行数据准备完成信号
always@(posedge sram_clk)begin
	if(frame_flag)
	   data_ready <= 1'b0;
	else if(rd_data_count >= s_width - 3)  
	   data_ready <= 1'b1;	
	else 
	   data_ready <= 1'b0;	     
end	

//缓存缩放前数据
fifo u_fifo_data_in(
	.wr_rst				(frame_flag||!sys_rst_n	), // input
	.rd_rst				(frame_flag||!sys_rst_n	), // input

	.wr_clk				(pixel_clk				), // input
	.wr_en				(de_d0					), // input
	.wr_data			(pixel_data_d0			), // input [7:0]
	.wr_full			(						), // output
	.almost_full		(						), // output
	.wr_water_level		(						), // output [12:0]

	.rd_clk				(sram_clk				), // input
	.rd_en				(scaler_rd_req			), // input
	.rd_data			(fifo_data				), // output [7:0]
	.rd_empty			(fifo_rdempty			), // output
	.almost_empty		(						), // output
	.rd_water_level		(rd_data_count			)  // output [12:0]
);


//缓存缩放后数据
fifo u_lite_scale_data(
	.wr_rst				(frame_flag||!sys_rst_n	), // input
	.rd_rst				(frame_flag||!sys_rst_n	), // input

	.wr_clk				(sram_clk				), // input
	.wr_en				(scaler_wren			), // input
	.wr_data			(scaler_data_out		), // input [7:0]
	.wr_full			(						), // output
	.almost_full		(						), // output
	.wr_water_level		(						), // output [12:0]

	.rd_clk				(sram_clk				), // input
	.rd_en				(fifo_scale_rden		), // input
	.rd_data			(sram_data_out			), // output [7:0]
	.rd_empty			(fifo_scale_rdempty		), // output
	.almost_empty		(						), // output
	.rd_water_level		(						)  // output [12:0]
);

//缩放模块
scaler u_scaler(
	.sys_clk		(sram_clk		),   
	.rst_n			(sys_rst_n		), 
	//data in
	.fifo_rdempty	(fifo_rdempty	),  
	.scaler_rd_req	(scaler_rd_req	), //output 
	.data_in		(fifo_data		),   
	.frame_flag		(frame_flag		),   
	.data_ready		(data_ready		),   
	//data out
	.scaler_wren	(scaler_wren	), //output 
	.data_out		(scaler_data_out), //output 
	//config
	.s_width		(s_width		),   
	.s_height		(s_height		),   
	.t_width		(t_width		),   
	.t_height		(t_height		),   
	.k_h			(h_scale_k		),   
	.k_v			(v_scale_k		)    
);



endmodule 