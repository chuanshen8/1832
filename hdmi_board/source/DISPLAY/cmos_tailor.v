module cmos_tailor#(
    parameter   INPUT_WDITH  = 1280,
    parameter   INPUT_HIGHT  = 720,
    parameter   OUTPUT_WDITH = 960,
    parameter   OUTPUT_HIGHT = 540
)
(
    input                 rst_n            ,  //复位信号                                            
    input                 cam_pclk         ,  //cmos 数据像素时钟

    input                 cam_vsync        ,  //cmos 场同步信号
    input                 cam_href         ,  //cmos 行同步信号
    input       [15:0]    cam_data         , 
    input                 cam_data_valid   ,    
    //用户接口                              
    output reg            cmos_frame_valid ,  //数据有效使能信号
    output reg  [15:0]    cmos_frame_data     //有效数据        
    );

localparam h_disp = OUTPUT_WDITH;
localparam v_disp = OUTPUT_HIGHT;

//reg define                     
reg             cam_vsync_d0     ;
reg             cam_vsync_d1     ;
reg             cam_href_d0      ;
reg             cam_href_d1      ;
reg    [10:0]   h_cnt            ;            //对行计数       
reg    [10:0]   v_cnt            ;            //对场计数
    
//wire define                    
wire            pos_vsync        ;           
wire            neg_hsync        ;           
wire   [10:0]   cmos_h_pixel     ;           
wire   [10:0]   cmos_v_pixel     ;           					      
wire   [10:0]   cam_border_pos_l ;           
wire   [10:0]   cam_border_pos_r ;           
wire   [10:0]   cam_border_pos_t ;           
wire   [10:0]   cam_border_pos_b ;           

assign  cmos_h_pixel = INPUT_WDITH;  //CMOS水平方向像素个数
assign  cmos_v_pixel = INPUT_HIGHT;  //CMOS垂直方向像素个数 

assign pos_vsync = (~cam_vsync_d1) & cam_vsync_d0; 

assign neg_hsync = (~cam_href_d0) & cam_href_d1;

assign cam_border_pos_l  = (cmos_h_pixel - h_disp)/2-1;

assign cam_border_pos_r = h_disp + (cmos_h_pixel - h_disp)/2-1;
 
assign cam_border_pos_t  = (cmos_v_pixel - v_disp)/2;

assign cam_border_pos_b = v_disp + (cmos_v_pixel - v_disp)/2;

always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        cam_vsync_d0 <= 1'b0;
        cam_vsync_d1 <= 1'b0;
        cam_href_d0 <= 1'b0;
        cam_href_d1 <= 1'b0;     
    end
    else begin
        cam_vsync_d0 <= cam_vsync;
        cam_vsync_d1 <= cam_vsync_d0;
        cam_href_d0 <= cam_href;
        cam_href_d1 <= cam_href_d0;       
    end
end


//对行计数
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) 
        h_cnt <= 11'b0;
    else begin
        if(pos_vsync||neg_hsync)
            h_cnt <= 11'b0;      
        else if(cam_data_valid)
            h_cnt <= h_cnt + 1'b1;           
        else if (cam_href_d0)
            h_cnt <= h_cnt; 
        else		
            h_cnt <= h_cnt; 	  
    end
end

//对场计数
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) 
        v_cnt <= 11'b0;
    else begin
        if(pos_vsync)
            v_cnt <= 11'b0;      
        else if(neg_hsync)
            v_cnt <= v_cnt + 1'b1;           
        else
            v_cnt <= v_cnt; 	  
    end
end

//产生输出数据有效信号(cmos_frame_valid)
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        cmos_frame_valid <= 1'b0;
    else if(h_cnt[10:0]>=cam_border_pos_l && h_cnt[10:0]<cam_border_pos_r&&
		    v_cnt[10:0]>=cam_border_pos_t && v_cnt[10:0]<cam_border_pos_b)
            cmos_frame_valid <= cam_data_valid;
    else
            cmos_frame_valid <= 1'b0;

end 

always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n)
        cmos_frame_data <= 1'b0;
    else if(h_cnt[10:0]>=cam_border_pos_l && h_cnt[10:0]<cam_border_pos_r&&
		    v_cnt[10:0]>=cam_border_pos_t && v_cnt[10:0]<cam_border_pos_b)
            cmos_frame_data <= cam_data;
    else
            cmos_frame_data <= 1'b0;

end 

endmodule
