module scale_top(
    input                 pixel_clk       ,//原始像素时钟
    input                 sram_clk        ,//缩放后像素时钟
    input                 sys_rst_n       ,//复位信号 
    input                 hs              ,//行信号
    input                 vs              ,//场信号
    input                 de              ,//数据使能信号
    input     [11:0]      s_width         ,//缩放前宽度
    input     [11:0]      s_height        ,//缩放前高度
    input     [11:0]      t_width         ,//缩放后宽度
    input     [11:0]      t_height        ,//缩放后高度
    input     [15:0]      h_scale_k       ,//列缩放因子
    input     [15:0]      v_scale_k       ,//行缩放因子 
    input     [15:0]      pixel_data      ,//缩放前数据
    output    [15:0]      sram_data_out   ,//缩放后数据
    output                data_valid      ,//缩放后数据有效信号   
    output	                frame_flag       //一帧开始信号
);

//wire define 
    wire      [15:0]      sram_data_out   ;//缩放后的 RGB 数据
    wire      [7:0]       data_out_r      ;//缩放后的红色数据
    wire      [7:0]       data_out_g      ;//缩放后的绿色数据
    wire      [7:0]       data_out_b      ;//缩放后的蓝色数据
    wire                  data_valid      ;//缩放后数据有效信号

//*****************************************************
//** main code
//*****************************************************

//将缩放后的数据拼成 16bit 数据输出   
assign  sram_data_out = data_valid ? {data_out_r[7:3],data_out_g[7:2],data_out_b[7:3]} : 16'b0; 
assign  fifo_rden     = ~fifo_empty_r && ~fifo_empty_g && ~fifo_empty_b;    

//红色数据缩放模块    
vin_scale_down u_vin_scale_down_r(
    .pixel_clk             (pixel_clk)                        ,
    .sram_clk              (sram_clk)                         ,
    .sys_rst_n             (sys_rst_n)                        ,
    .hs                    (hs)                               ,
    .vs                    (vs)                               ,
    .de                    (de)                               ,
    .s_width               (s_width)                          ,
    .s_height              (s_height)                         ,
    .t_width               (t_width)                          ,
    .t_height              (t_height)                         ,
    .h_scale_k             (h_scale_k)                        ,
    .v_scale_k             (v_scale_k)                        , 
    .fifo_scale_rden       (fifo_rden)                        ,
    .pixel_data            ({pixel_data[15:11],3'b0})         ,
    .sram_data_out         (data_out_r)                       ,
    .data_valid            (data_valid)                       ,
    .fifo_scale_rdempty    (fifo_empty_r)                     ,
    .frame_flag			 (frame_flag)            

);      

//绿色数据缩放模块      
vin_scale_down u_vin_scale_down_g(
    .pixel_clk             (pixel_clk)                         ,
    .sram_clk              (sram_clk)                          ,
    .sys_rst_n             (sys_rst_n)                         , 
    .hs                    (hs)                                ,
    .vs                    (vs)                                ,
    .de                    (de)                                ,
    .s_width               (s_width)                           ,
    .s_height              (s_height)                          ,
    .t_width               (t_width)                           ,
    .t_height              (t_height)                          ,
    .h_scale_k             (h_scale_k)                         ,
    .v_scale_k             (v_scale_k)                         , 
    .fifo_scale_rden       (fifo_rden)                         , 
    .pixel_data            ({pixel_data[10:5],2'b0})           ,
    .sram_data_out         (data_out_g)                        ,
    .data_valid            ()                                  ,
    .fifo_scale_rdempty    (fifo_empty_g)
);     

//蓝色数据缩放模块 
vin_scale_down u_vin_scale_down_b(
    .pixel_clk             (pixel_clk)                         ,
    .sram_clk              (sram_clk)                          ,
    .sys_rst_n             (sys_rst_n)                         , 
    .hs                    (hs)                                ,
    .vs                    (vs)                                ,
    .de                    (de)                                ,
    .s_width               (s_width)                           ,
    .s_height              (s_height)                          ,
    .t_width               (t_width)                           ,
    .t_height              (t_height)                          ,
    .h_scale_k             (h_scale_k)                         ,
    .v_scale_k             (v_scale_k)                         , 
    .fifo_scale_rden       (fifo_rden)                         , 
    .pixel_data            ({pixel_data[4:0],3'b0})            ,
    .sram_data_out         (data_out_b)                        ,
    .data_valid            ()                                  ,
    .fifo_scale_rdempty    (fifo_empty_b)
); 
 
endmodule
