module cmos_add(
    input           sys_rst_n,
    input           cmos0_pclk,
    input           cmos0_href,
    input[15:0]     cmos0_data,
    input           cmos0_vsync,
    input           cmos0_valid,
 
    input           cmos1_pclk,
    input           cmos1_href,
    input[15:0]     cmos1_data,
    input           cmos1_vsync,
    input           cmos1_valid,

    output          pixel_vsync,
    output          pixel_href,
    output [15:0]   data
);

 reg [11:0] clk_cnt/* synthesis syn_preserve = 1 */;

always @(posedge cmos0_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        clk_cnt <= 1'b0;
    end
    else if (clk_cnt==(PIXEL_OFFSET+'d959)) begin
        clk_cnt <= 'd0;
    end
    else if(cmos0_href )begin
        clk_cnt <= clk_cnt+ 1'b1;
    end
    else if(~cmos0_href && clk_cnt > 'd959)begin
        clk_cnt <= clk_cnt+ 1'b1;
    end
    else begin
        clk_cnt <= clk_cnt;
    end
end


///cmos_vsync信号2分频作pixel_vsync信号
reg [1:0] vsync_add_clk_cnt;
always @(posedge cmos0_vsync or negedge sys_rst_n) begin
    if (!sys_rst_n) begin
        vsync_add_clk_cnt <= 2'b0;
    end
    else if (!cmos1_href) begin
        vsync_add_clk_cnt <= 2'b0;
    end
    else begin
        vsync_add_clk_cnt <= vsync_add_clk_cnt + 2'b1;
    end
end

assign pixel_vsync = (vsync_add_clk_cnt ^ 2'd1) ? 1'b0 : cmos0_vsync ;//输出帧有效
//cam1行像素点计数
/*
reg [11:0]      cam1_pixel_cnt;//行像素计数器
always @(posedge cmos1_pclk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        cam1_pixel_cnt <= 12'd0;
    else if (cam1_pixel_cnt=='d1919) begin
        cam1_pixel_cnt <= 12'd0;
    end
    else begin
        cam1_pixel_cnt <= cam1_pixel_cnt + 12'd1;
    end
end
*/
//像素偏差位置设置
localparam PIXEL_OFFSET = 12'd20;

//wire pixel_increase_flag = (cam1_pixel_cnt > (PIXEL_OFFSET-1) && cam1_pixel_cnt <= ('d961 + PIXEL_OFFSET)) ? 1'b1 : 1'b0;
wire pixel_increase_flag = (clk_cnt > (PIXEL_OFFSET-1) && clk_cnt <= ('d959 + PIXEL_OFFSET)) ? 1'b1 : 1'b0;//在右半边叠加的时候有效
wire [15:0]     cmos1_data_splicing;
wire            fifo_splicing_full;
wire            fifo_splicing_empty;
/*
fifo_pong u_fifo_splicing(
    .Data       (cmos0_data         ), //input [15:0] Data
    .Reset      (~sys_rst_n         ), //input Reset
    .WrClk      (cmos0_pclk         ), //input WrClk
    .RdClk      (cmos1_pclk         ), //input RdClk
    .WrEn       (cmos0_href         ), //input WrEn
    .RdEn       (pixel_increase_flag), //input RdEn
//    .RdEn       (1'b1), //input RdEn
    .Q          (cmos0_data_splicing), //output [15:0] Q
    .Empty      (fifo_splicing_empty), //output Empty
    .Full       (fifo_splicing_full ) //output Full
);
*/

fifo_pong the_instance_name (
  .wr_clk(cmos1_pclk),                // input
  .wr_rst(~sys_rst_n),                // input
  .wr_en(cmos1_href),                  // input
  .wr_data(cmos1_data),              // input [15:0]
  .wr_full(fifo_splicing_full),              // output

  .rd_clk(cmos0_pclk),                // input
  .rd_rst(~sys_rst_n),                // input
  .rd_en(pixel_increase_flag),                  // input
  .rd_data(cmos1_data_splicing),              // output [15:0]
  .rd_empty(fifo_splicing_empty)            // output

);
reg [15:0] fusion_data;
//RBG加权平均
/*
always @(*) begin
    if(cam1_pixel_cnt < PIXEL_OFFSET) begin
        fusion_data = cmos1_data;
    end 
    else if((cam1_pixel_cnt >= PIXEL_OFFSET) && (cam1_pixel_cnt <= PIXEL_OFFSET + 12'd10)) begin
        fusion_data[4:0] = (cmos1_data[4:0] >> 1) + (cmos0_data_splicing[4:0] >> 1);
        fusion_data[10:5] = (cmos1_data[10:5] >> 1) + (cmos0_data_splicing[10:5] >> 1);
        fusion_data[15:11] = (cmos1_data[15:11] >> 1) + (cmos0_data_splicing[15:11] >> 1);
    end
    else begin
        fusion_data = cmos0_data_splicing;
    end
end

assign data = (cam1_pixel_cnt<='d961 + PIXEL_OFFSET)?fusion_data:16'b0;

assign pixel_href = (cam1_pixel_cnt>='d0 && cam1_pixel_cnt<='d1919)?1'b1:1'b0;
*/
always @(*) begin
    if(clk_cnt < PIXEL_OFFSET) begin
        fusion_data = cmos0_data;
    end 
    else if((clk_cnt >= PIXEL_OFFSET) && (clk_cnt <= PIXEL_OFFSET + 12'd10)) begin
        fusion_data[4:0] = (cmos0_data[4:0] >> 1) + (cmos1_data_splicing[4:0] >> 1);
        fusion_data[10:5] = (cmos0_data[10:5] >> 1) + (cmos1_data_splicing[10:5] >> 1);
        fusion_data[15:11] = (cmos0_data[15:11] >> 1) + (cmos1_data_splicing[15:11] >> 1);
    end
    else begin
        fusion_data = cmos1_data_splicing;
    end
end

assign data = (clk_cnt<='d959 + PIXEL_OFFSET)?fusion_data:16'b0;

assign pixel_href = ((clk_cnt>='d0 && cmos0_href) || (clk_cnt>='d1 && clk_cnt <= 'd959 + PIXEL_OFFSET))?1'b1:1'b0;
//assign pixel_href = (clk_cnt>='d0 && cmos0_href)?1'b1:1'b0;

endmodule
