`timescale 1ns / 1ps
module hdmi_in_1920_to_960 #(
    parameter   OUT_WIDTH = 960,
    parameter   OUT_HEIGH = 540
)(
    input           clk,
    input           rst_n,
    
    input  [7:0]    data_in_r,
    input  [7:0]    data_in_g,
    input  [7:0]    data_in_b,
    input           data_in_valid,
    
    output [7:0]    data_out_r,
    output [7:0]    data_out_g,
    output [7:0]    data_out_b,
    output          data_out_valid
    );

reg  [7:0]  data_in_r_d1      ;
reg  [7:0]  data_in_g_d1      ;
reg  [7:0]  data_in_b_d1      ;
reg         data_in_valid_d1  ;
reg         data_in_valid_d2  ;
reg  [8:0]  data_add_r_temp1  ;
reg  [8:0]  data_add_g_temp1  ;
reg  [8:0]  data_add_b_temp1  ;
reg         de_convert        ;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        data_in_r_d1     <= 8'd0;
        data_in_g_d1     <= 8'd0;
        data_in_b_d1     <= 8'd0;
        data_in_valid_d1 <= 1'b0;
        data_in_valid_d2 <= 1'b0;
    end
    else begin
        data_in_r_d1     <= data_in_r;
        data_in_g_d1     <= data_in_g;
        data_in_b_d1     <= data_in_b;
        data_in_valid_d1 <= data_in_valid;
        data_in_valid_d2 <= data_in_valid_d1;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        data_add_r_temp1 <= 9'd0;
        data_add_g_temp1 <= 9'd0;
        data_add_b_temp1 <= 9'd0;
    end
    else if(data_in_valid_d1)begin
        data_add_r_temp1 <= data_in_r + data_in_r_d1;
        data_add_g_temp1 <= data_in_g + data_in_g_d1;
        data_add_b_temp1 <= data_in_b + data_in_b_d1;
    end
    else begin    
        data_add_r_temp1 <= data_add_r_temp1;
        data_add_g_temp1 <= data_add_g_temp1;
        data_add_b_temp1 <= data_add_b_temp1;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
        de_convert <= 1'b0;
    else if(data_in_valid_d1) 
        de_convert <= ~de_convert;
    else
        de_convert <= 1'b0;
end

reg  [9:0]  wr_addr;
reg  [9:0]  rd_addr;
wire [9:0]  rd_addr_pre2;
wire [23:0] ram_rd_data; 

assign rd_addr_pre2 = wr_addr + 1;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        wr_addr <= 10'd0;
        rd_addr <= 10'd0;
    end
    else if(de_convert)begin
        if(wr_addr == OUT_WIDTH - 1)
            wr_addr <= 10'd0;
        else
            wr_addr <= wr_addr + 1'b1;
        if(rd_addr_pre2 > OUT_WIDTH - 1)
            rd_addr <= rd_addr_pre2 - OUT_WIDTH;
        else 
            rd_addr <= rd_addr_pre2;
    end
end

hdmi_linebuffer hdmi_linebuffer_u (
   .wr_clk   (clk             ), // input
   .wr_rst   (rst_n           ), // input
   .wr_en    (de_convert      ), // input
   .wr_addr  (wr_addr         ), // input [9:0]
   .wr_data  ({data_add_r_temp1[8:1],data_add_g_temp1[8:1],data_add_b_temp1[8:1]}), // input [23:0] //相邻两个点的像素相加除以二

   .rd_clk   (clk             ), // input
   .rd_rst   (rst_n           ), // input
   .rd_addr  (rd_addr         ), // input [9:0]
   .rd_data  (ram_rd_data     )  // output [23:0]
);

reg  [8:0]  data_add_r_temp2;
reg  [8:0]  data_add_g_temp2;
reg  [8:0]  data_add_b_temp2;
reg  [9:0]  hs_cnt; 
reg         de_convert_d1; 
reg         hsync_de;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        data_add_r_temp2 <= 9'd0;
        data_add_g_temp2 <= 9'd0;
        data_add_b_temp2 <= 9'd0;
    end
    else if(de_convert)begin
        data_add_r_temp2 <= data_add_r_temp1[8:1] + ram_rd_data[23:16];
        data_add_g_temp2 <= data_add_g_temp1[8:1] + ram_rd_data[15: 8];
        data_add_b_temp2 <= data_add_b_temp1[8:1] + ram_rd_data[ 7: 0];
    end
    else begin
        data_add_r_temp2 <= data_add_r_temp2; 
        data_add_g_temp2 <= data_add_g_temp2;
        data_add_b_temp2 <= data_add_b_temp2;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
        de_convert_d1 <= 1'b0;
    else 
        de_convert_d1 <= de_convert;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
        hs_cnt <= 10'd0;
    else if(de_convert_d1)begin
        if(hs_cnt == OUT_WIDTH - 1)
            hs_cnt <= 10'd0;
        else 
            hs_cnt <= hs_cnt + 1'b1;
    end
    else    
        hs_cnt <= hs_cnt;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)
        hsync_de <= 1'b0;
    else if(hs_cnt == OUT_WIDTH - 1 && de_convert_d1)
        hsync_de <= ~hsync_de;
    else
        hsync_de <= hsync_de;
end

assign data_out_r       = data_add_r_temp2[7:0];
assign data_out_g       = data_add_g_temp2[7:0];
assign data_out_b       = data_add_b_temp2[7:0];
assign data_out_valid = (hsync_de && de_convert_d1) ? 1'b1 : 1'b0;

endmodule
