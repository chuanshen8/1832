module yuv
(
//module clock
input             clk              , 
input             rst_n            , 
input        	  key3			   ,
input             change_yuv       , 

input             pre_frame_vsync  , 
input             pre_frame_hsync  , 
input             pre_frame_de     , 
input [4:0]       img_red          , 
input [5:0]       img_green        , 
input [4:0]       img_blue         , 


output            post_frame_vsync , 
output            post_frame_hsync , 
output            post_frame_de    ,
output [7:0]      img_y            , 
output [7:0]      img_cb           , 
output [7:0]      img_cr 
);
 
//reg define
reg [15:0] rgb_r_m0, rgb_r_m1, rgb_r_m2;
reg [15:0] rgb_g_m0, rgb_g_m1, rgb_g_m2;
reg [15:0] rgb_b_m0, rgb_b_m1, rgb_b_m2;
reg [15:0] img_y0 ;
reg [15:0] img_cb0;
reg [15:0] img_cr0;
reg [ 7:0] img_y1 ;
reg [ 7:0] img_cb1;
reg [ 7:0] img_cr1;
reg  pre_frame_vsync_d;
reg  pre_frame_hsync_d;
reg  pre_frame_de_d ;
//wire define
reg [ 7:0] rgb888_r0;
reg [ 7:0] rgb888_g0;
reg [ 7:0] rgb888_b0;

reg [ 7:0] rgb888_r1;
reg [ 7:0] rgb888_g1;
reg [ 7:0] rgb888_b1;

reg [ 7:0] rgb888_r2;
reg [ 7:0] rgb888_g2;
reg [ 7:0] rgb888_b2;

reg [ 7:0] rgb888_rr;
reg [ 7:0] rgb888_gg;
reg [ 7:0] rgb888_bb;

wire [ 7:0] rgb888_r;
wire [ 7:0] rgb888_g;
wire [ 7:0] rgb888_b;

always@(posedge clk or negedge rst_n) begin
if(rst_n) begin
rgb888_rr <= 1'd0;
rgb888_gg <= 1'd0;
rgb888_bb <= 1'd0;
end
else begin
//pre_frame_vsync_d <= {pre_frame_vsync_d[1:0], pre_frame_vsync};
//pre_frame_hsync_d <= {pre_frame_hsync_d[1:0], pre_frame_hsync};
//pre_frame_de_d <= {pre_frame_de_d[1:0] , pre_frame_de };
rgb888_r0<=rgb888_r;
rgb888_r1<=rgb888_r0;
rgb888_r2<=rgb888_r1;
rgb888_rr <= rgb888_r2;

rgb888_g0<=rgb888_g;
rgb888_g1<=rgb888_g0;
rgb888_g2<=rgb888_g1;
rgb888_gg <= rgb888_g2;

rgb888_b0<=rgb888_b;
rgb888_b1<=rgb888_b0;
rgb888_b2<=rgb888_b1;
rgb888_bb <= rgb888_b2;

end 
end 
//*****************************************************
//** main code
//*****************************************************

//RGB565 to RGB 888
assign rgb888_r = {img_red , img_red[4:2] };
assign rgb888_g = {img_green, img_green[5:4]};
assign rgb888_b = {img_blue , img_blue[4:2] };
//ͬ��������ݽӿ��ź�
assign post_frame_vsync = pre_frame_vsync_d ;
assign post_frame_hsync = pre_frame_hsync_d;
assign post_frame_de = pre_frame_de_d ;
//assign img_y = post_frame_hsync ? img_y1 : 8'd0;
//assign img_cb = post_frame_hsync ? img_cb1: 8'd0;
//assign img_cr = post_frame_hsync ? img_cr1: 8'd0;
assign img_y  = change_yuv ? img_y1:rgb888_rr ;
assign img_cb = change_yuv ? img_y1:rgb888_gg;
assign img_cr = change_yuv ? img_y1:rgb888_bb;

//--------------------------------------------
//RGB 888 to YCbCr

/********************************************************
RGB888 to YCbCr
Y = 0.299R + 0.587G + 0.114B
Cb = -0.169R - 0.331G + 0.5B + 128
CR = 0.5R - 0.419G - 0.081B + 128

Y = (77 *R + 150*G + 29 *B)>>8
Cb = (-43*R - 85 *G + 128*B)>>8 + 128
Cr = (128*R - 107*G - 21 *B)>>8 + 128

Y = (77 *R + 150*G + 29 *B )>>8
Cb = (-43*R - 85 *G + 128*B + 32768)>>8
Cr = (128*R - 107*G - 21 *B + 32768)>>8
 *********************************************************/

//step1 pipeline mult
always @(posedge clk or negedge rst_n) begin
if(rst_n) begin
rgb_r_m0 <= 16'd0;
rgb_r_m1 <= 16'd0;
rgb_r_m2 <= 16'd0;
rgb_g_m0 <= 16'd0;
rgb_g_m1 <= 16'd0;
rgb_g_m2 <= 16'd0;
rgb_b_m0 <= 16'd0;
rgb_b_m1 <= 16'd0;
rgb_b_m2 <= 16'd0;
end
else begin
rgb_r_m0 <= rgb888_r * 8'd77 ;
rgb_r_m1 <= rgb888_r * 8'd43 ;
rgb_r_m2 <= rgb888_r << 3'd7 ;
rgb_g_m0 <= rgb888_g * 8'd150;
rgb_g_m1 <= rgb888_g * 8'd85 ;
rgb_g_m2 <= rgb888_g * 8'd107;
rgb_b_m0 <= rgb888_b * 8'd29 ;
rgb_b_m1 <= rgb888_b << 3'd7 ;
rgb_b_m2 <= rgb888_b * 8'd21 ;
end
end
//step2 pipeline add
always @(posedge clk or negedge rst_n) begin
if(rst_n) begin
img_y0 <= 16'd0;
img_cb0 <= 16'd0;
img_cr0 <= 16'd0;
end
else begin
img_y0 <= rgb_r_m0 + rgb_g_m0 + rgb_b_m0;
img_cb0 <= rgb_b_m1 - rgb_r_m1 - rgb_g_m1 + 16'd32768;
img_cr0 <= rgb_r_m2 - rgb_g_m2 - rgb_b_m2 + 16'd32768;
end
end

//step3 pipeline div
always @(posedge clk or negedge rst_n) begin
if(rst_n) begin
img_y1 <= 8'd0; 
img_cb1 <= 8'd0;
img_cr1 <= 8'd0;
end
else begin 
img_y1 <= img_y0 [15:8];
img_cb1 <= img_cb0[15:8];
img_cr1 <= img_cr0[15:8];
end
end
//��ʱ 3 ����ͬ�������ź�
reg   pre_frame_vsync_d0;
reg   pre_frame_hsync_d0;
reg   pre_frame_de_d0;
reg   pre_frame_vsync_d1;
reg   pre_frame_hsync_d1;
reg   pre_frame_de_d1;
reg   pre_frame_vsync_d2;
reg   pre_frame_hsync_d2;
reg   pre_frame_de_d2;

always@(posedge clk or negedge rst_n) begin
if(rst_n) begin
pre_frame_vsync_d <= 1'd0;
pre_frame_hsync_d <= 1'd0;
pre_frame_de_d <= 1'd0;
end
else begin
//pre_frame_vsync_d <= {pre_frame_vsync_d[1:0], pre_frame_vsync};
//pre_frame_hsync_d <= {pre_frame_hsync_d[1:0], pre_frame_hsync};
//pre_frame_de_d <= {pre_frame_de_d[1:0] , pre_frame_de };
pre_frame_vsync_d0<=pre_frame_vsync;
pre_frame_vsync_d1<=pre_frame_vsync_d0;
pre_frame_vsync_d2<=pre_frame_vsync_d1;
pre_frame_vsync_d <= pre_frame_vsync_d2;

pre_frame_hsync_d0<=pre_frame_hsync;
pre_frame_hsync_d1<=pre_frame_hsync_d0;
pre_frame_hsync_d2<=pre_frame_hsync_d1;
pre_frame_hsync_d <= pre_frame_hsync_d2;

pre_frame_de_d0<=pre_frame_de;
pre_frame_de_d1<=pre_frame_de_d0;
pre_frame_de_d2<=pre_frame_de_d1;
pre_frame_de_d <= pre_frame_de_d2;

end 
end 




endmodule