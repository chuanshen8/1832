module pattern_vg 
(                                       
    input                                rstn, 
    input                                pix_clk/*synthesis PAP_MARK_DEBUG="1"*/,
    input [12:0]                         act_x,
    input [12:0]                         act_y,
    input                                vs_in, 
    input                                hs_in, 
    input                                de_in,
    
    output reg                           vs_out, 
    output reg                           hs_out, 
    output reg                           de_out,
    output wire [7:0]                    r_out, 
    output wire [7:0]                    g_out, 
    output wire [7:0]                    b_out,
	///FFT 请求和数据接口
    input   [ 2:0]                       cnt_key,                               
	input   [15:0]					     dram_data,        //rd_data   [8:0]
	output								 point_done
);
      
localparam COLOR_WHITE  = 24'hFF_FF_FF;
localparam COLOR_BLACK  = 24'h00_00_00;
localparam COLOR_YELLOW = 24'hFF_FF_00;
localparam COLOR_RED    = 24'hFF_00_00;               

wire    [7:0]       real_data;
wire    [8:0]       freq_data;

reg     [23:0]      o_data	;
reg     [ 2:0]      cnt_key_d1;
reg     [ 2:0]      cnt_key_d2;

reg     [ 47:0]   char_1  [15:0] ;   

wire    [127:0]   char_2  [31:0] ;
wire    [127:0]   char_3  [31:0] ;
   
assign  char_3[ 0] = 128'h00000000000000000000000000000000;
assign  char_3[ 1] = 128'h00000000000000000000000000000000;
assign  char_3[ 2] = 128'h00000000000000000000000000000000;
assign  char_3[ 3] = 128'h0000000000380000ffff800000000000;
assign  char_3[ 4] = 128'h00000000003800007fffe00000000000;
assign  char_3[ 5] = 128'h00000000007c00001e07f00000000000;
assign  char_3[ 6] = 128'h00000000007c00001e01f80000000000;
assign  char_3[ 7] = 128'h0000000000fe00001e00f80000000000;
assign  char_3[ 8] = 128'h0000000000fe00001e00fc0000000000;
assign  char_3[ 9] = 128'h0000000001ff00001e007c0000000000;
assign  char_3[10] = 128'h0000000001df00001e007c0000000000;
assign  char_3[11] = 128'h0000000003df00001e007e0000000000;
assign  char_3[12] = 128'h00000000038f80001e003e0000000000;
assign  char_3[13] = 128'h00000000038f80001e003e0000000000;
assign  char_3[14] = 128'h000000000787c0001e003e0000000000;
assign  char_3[15] = 128'h000000000707c0001e007e0000000000;
assign  char_3[16] = 128'h000000000fffe0001e007c0000000000;
assign  char_3[17] = 128'h000000000fffe0001e007c0000000000;
assign  char_3[18] = 128'h000000001e03e0001e00fc0000000000;
assign  char_3[19] = 128'h000000001c01f0001e00f80000000000;
assign  char_3[20] = 128'h000000003c01f0001e01f00000000000;
assign  char_3[21] = 128'h000000003800f8001e07f00000000000;
assign  char_3[22] = 128'h00000000fe01fe007f9fc00000000000;
assign  char_3[23] = 128'h00000001ff03ff00ffff000000000000;
assign  char_3[24] = 128'h00000000000000000000000000000000;
assign  char_3[25] = 128'h00000000000000000000000000000000;
assign  char_3[26] = 128'h00000000000000000000000000000000;
assign  char_3[27] = 128'h00000000000000000000000000000000;
assign  char_3[28] = 128'h00000000000000000000000000000000;
assign  char_3[29] = 128'h00000000000000000000000000000000;
assign  char_3[30] = 128'h00000000000000000000000000000000;
assign  char_3[31] = 128'h00000000000000000000000000000000;
   
assign  char_2[ 0] = 128'h00000000000000000000000000000000;
assign  char_2[ 1] = 128'h00000000000000000000000000000000;
assign  char_2[ 2] = 128'h00000000000000000000000000000000;
assign  char_2[ 3] = 128'hffc7fe000ffe00000ffe0000ffffe000;
assign  char_2[ 4] = 128'h7f83fc001ffe00001ffe0000ffffe000;
assign  char_2[ 5] = 128'h1f00f0003c1e00003c1e0000f0f0e000;
assign  char_2[ 6] = 128'h1e00f0007c0e00007c0e0000e0f06000;
assign  char_2[ 7] = 128'h1e00f0007806000078060000c0f06000;
assign  char_2[ 8] = 128'h1e00f0007c0600007c06000000f00000;
assign  char_2[ 9] = 128'h1e00f0007e0600007e06000000f00000;
assign  char_2[10] = 128'h1e00f0003f8000003f80000000f00000;
assign  char_2[11] = 128'h1e00f0003fe000003fe0000000f00000;
assign  char_2[12] = 128'h1ffff0001ff000001ff0000000f00000;
assign  char_2[13] = 128'h1ffff00007fc000007fc000000f00000;
assign  char_2[14] = 128'h1e00f00003fe000003fe000000f00000;
assign  char_2[15] = 128'h1e00f00000ff000000ff000000f00000;
assign  char_2[16] = 128'h1e00f000003f8000003f800000f00000;
assign  char_2[17] = 128'h1e00f000701f8000701f800000f00000;
assign  char_2[18] = 128'h1e00f000700f8000700f800000f00000;
assign  char_2[19] = 128'h1e00f000700780007007800000f00000;
assign  char_2[20] = 128'h1e00f000780f8000780f800000f00000;
assign  char_2[21] = 128'h1e01f0007c1f00007c1f000001f00000;
assign  char_2[22] = 128'h7f83fc007ffe00007ffe000003f80000;
assign  char_2[23] = 128'hffc7fe007ffc00007ffc000007fe0000;
assign  char_2[24] = 128'h00000000000000000000000000000000;
assign  char_2[25] = 128'h00000000000000000000000000000000;
assign  char_2[26] = 128'h00000000000000000000000000000000;
assign  char_2[27] = 128'h00000000000000000000000000000000;
assign  char_2[28] = 128'h00000000000000000000000000000000;
assign  char_2[29] = 128'h00000000000000000000000000000000;
assign  char_2[30] = 128'h00000000000000000000000000000000;
assign  char_2[31] = 128'h00000000000000000000000000000000;
 
always@(posedge pix_clk)
    if(act_y < 120)
        begin
            // 5V
            char_1[ 0] <=  48'h000000000000;
            char_1[ 1] <=  48'h000000000000;
            char_1[ 2] <=  48'h000000000000;
            char_1[ 3] <=  48'h00007e00e700;
            char_1[ 4] <=  48'h000040004200;
            char_1[ 5] <=  48'h000040004200;
            char_1[ 6] <=  48'h000040004400;
            char_1[ 7] <=  48'h000078002400;
            char_1[ 8] <=  48'h000044002400;
            char_1[ 9] <=  48'h000002002800;
            char_1[10] <=  48'h000002002800;
            char_1[11] <=  48'h000042001800;
            char_1[12] <=  48'h000044001000;
            char_1[13] <=  48'h000038001000;
            char_1[14] <=  48'h000000000000;
            char_1[15] <=  48'h000000000000;
        end
    else if(act_y < 240)
        begin
            //0V
            char_1[ 0] <=  48'h000000000000;
            char_1[ 1] <=  48'h000000000000;
            char_1[ 2] <=  48'h000000000000;
            char_1[ 3] <=  48'h00001800e700;
            char_1[ 4] <=  48'h000024004200;
            char_1[ 5] <=  48'h000042004200;
            char_1[ 6] <=  48'h000042004400;
            char_1[ 7] <=  48'h000042002400;
            char_1[ 8] <=  48'h000042002400;
            char_1[ 9] <=  48'h000042002800;
            char_1[10] <=  48'h000042002800;
            char_1[11] <=  48'h000042001800;
            char_1[12] <=  48'h000024001000;
            char_1[13] <=  48'h000018001000;
            char_1[14] <=  48'h000000000000;
            char_1[15] <=  48'h000000000000;
        end
    else if(act_y < 359)
        begin
            //-5V
            char_1[ 0] <=  48'h000000000000;
            char_1[ 1] <=  48'h000000000000;
            char_1[ 2] <=  48'h000000000000;
            char_1[ 3] <=  48'h00007e00e700;
            char_1[ 4] <=  48'h000040004200;
            char_1[ 5] <=  48'h000040004200;
            char_1[ 6] <=  48'h000040004400;
            char_1[ 7] <=  48'h000078002400;
            char_1[ 8] <=  48'h3e0044002400;
            char_1[ 9] <=  48'h000002002800;
            char_1[10] <=  48'h000002002800;
            char_1[11] <=  48'h000042001800;
            char_1[12] <=  48'h000044001000;
            char_1[13] <=  48'h000038001000;
            char_1[14] <=  48'h000000000000;
            char_1[15] <=  48'h000000000000;
        end
    else if(act_y < 475)
        begin
            // 5V
            char_1[ 0] <=  48'h000000000000;
            char_1[ 1] <=  48'h000000000000;
            char_1[ 2] <=  48'h000000000000;
            char_1[ 3] <=  48'h00007e00e700;
            char_1[ 4] <=  48'h000040004200;
            char_1[ 5] <=  48'h000040004200;
            char_1[ 6] <=  48'h000040004400;
            char_1[ 7] <=  48'h000078002400;
            char_1[ 8] <=  48'h000044002400;
            char_1[ 9] <=  48'h000002002800;
            char_1[10] <=  48'h000002002800;
            char_1[11] <=  48'h000042001800;
            char_1[12] <=  48'h000044001000;
            char_1[13] <=  48'h000038001000;
            char_1[14] <=  48'h000000000000;
            char_1[15] <=  48'h000000000000;
        end
    else if(act_y < 603)
        begin
            //0V
            char_1[ 0] <=  48'h000000000000;
            char_1[ 1] <=  48'h000000000000;
            char_1[ 2] <=  48'h000000000000;
            char_1[ 3] <=  48'h00001800e700;
            char_1[ 4] <=  48'h000024004200;
            char_1[ 5] <=  48'h000042004200;
            char_1[ 6] <=  48'h000042004400;
            char_1[ 7] <=  48'h000042002400;
            char_1[ 8] <=  48'h000042002400;
            char_1[ 9] <=  48'h000042002800;
            char_1[10] <=  48'h000042002800;
            char_1[11] <=  48'h000042001800;
            char_1[12] <=  48'h000024001000;
            char_1[13] <=  48'h000018001000;
            char_1[14] <=  48'h000000000000;
            char_1[15] <=  48'h000000000000;
        end
    else 
        begin
            //-5V
            char_1[ 0] <=  48'h000000000000;
            char_1[ 1] <=  48'h000000000000;
            char_1[ 2] <=  48'h000000000000;
            char_1[ 3] <=  48'h00007e00e700;
            char_1[ 4] <=  48'h000040004200;
            char_1[ 5] <=  48'h000040004200;
            char_1[ 6] <=  48'h000040004400;
            char_1[ 7] <=  48'h000078002400;
            char_1[ 8] <=  48'h3e0044002400;
            char_1[ 9] <=  48'h000002002800;
            char_1[10] <=  48'h000002002800;
            char_1[11] <=  48'h000042001800;
            char_1[12] <=  48'h000044001000;
            char_1[13] <=  48'h000038001000;
            char_1[14] <=  48'h000000000000;
            char_1[15] <=  48'h000000000000;
        end

assign {r_out,g_out,b_out} = o_data;

always@(posedge pix_clk)
    begin
        vs_out     <= vs_in;
        hs_out     <= hs_in;
        de_out     <= de_in;
        cnt_key_d1 <= cnt_key;
        cnt_key_d2 <= cnt_key_d1;
    end 

reg     [3:0]       cnt;
    
always@(posedge pix_clk or negedge rstn)
    if(!rstn)
        cnt <= 4'd0;
    else if(cnt == 4'd4)
        cnt <= 4'd0;
    else if(de_in == 1'b1)
        cnt <= cnt + 1'b1;

assign      point_done = (cnt == 4'd4) ? 1'b1 : 1'b0;            

assign      real_data = dram_data[7:0];

assign      freq_data = dram_data[9:1];

always@(posedge pix_clk or negedge rstn)
    if(!rstn)
        o_data <= COLOR_WHITE;  
    else if(cnt_key_d2 == 3'd0)
        begin
            //"HSST" 字模
            if(act_x >= 1152 && act_y <= 31 && char_2[act_y][1279 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;
            //背景
            else if(act_x >= 1152 && act_y <= 31 && char_2[act_y][1279 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;
            //5v 
            else if(act_x < 48 && act_y > 403 && act_y <= 419 && char_1[act_y - 404][48 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;
            //背景
            else if(act_x < 48 && act_y > 403 && act_y <= 419 && char_1[act_y - 404][48 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;
            //0v    
            else if(act_x < 48 && act_y > 531 && act_y <= 547 && char_1[act_y - 532][48 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;
            //背景
            else if(act_x < 48 && act_y > 531 && act_y <= 547 && char_1[act_y - 532][48 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;
            //-5v    
            else if(act_x < 48 && act_y > 659 && act_y <= 675 && char_1[act_y - 660][48 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;
            //背景
            else if(act_x < 48 && act_y > 659 && act_y <= 675 && char_1[act_y - 660][48 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;
            //频谱    
            else if((act_y < 359) && ((cnt == 4'd4) || (cnt == 4'd3)) && (act_y > (360 - freq_data)))
                o_data <= COLOR_BLACK;
            //中间横线
            else if(act_y == 359)
                o_data <= COLOR_BLACK; 
            //时域谱    
            else if(act_x > 47 && act_y >= 411 && act_y <= 667 && (real_data == 667 - act_y || (real_data == 666 - act_y)))
                o_data <= COLOR_BLACK;   
            //5V虚线
            else if(act_y == 411 && act_x > 47 && (cnt == 4'd1 || cnt == 4'd2))
                o_data <= COLOR_BLACK;       
            //0V虚线    
            else if(act_y == 539 && act_x > 47 && (cnt == 4'd1 || cnt == 4'd2))
                o_data <= COLOR_BLACK; 
            //-5V虚线
            else if(act_y == 667 && act_x > 47 && (cnt == 4'd1 || cnt == 4'd2))
                o_data <= COLOR_BLACK; 
            //背景
            else 
                o_data <= COLOR_WHITE;
        end
    else if(cnt_key_d2 == 3'd1)
        begin
            //"AD" 字模
            if(act_x >= 1152 && act_y <= 31 && char_3[act_y][1279 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;
            //背景
            else if(act_x >= 1152 && act_y <= 31 && char_3[act_y][1279 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;
            //5v 
            else if(act_x < 48 && act_y > 403 && act_y <= 419 && char_1[act_y - 404][48 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;
            //背景
            else if(act_x < 48 && act_y > 403 && act_y <= 419 && char_1[act_y - 404][48 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;
            //0v    
            else if(act_x < 48 && act_y > 531 && act_y <= 547 && char_1[act_y - 532][48 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;
            //背景
            else if(act_x < 48 && act_y > 531 && act_y <= 547 && char_1[act_y - 532][48 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;
            //-5v    
            else if(act_x < 48 && act_y > 659 && act_y <= 675 && char_1[act_y - 660][48 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;
            //背景
            else if(act_x < 48 && act_y > 659 && act_y <= 675 && char_1[act_y - 660][48 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;
            //频谱    
            else if((act_y < 359) && ((cnt == 4'd4) || (cnt == 4'd3)) && (act_y > (360 - freq_data)))
                o_data <= COLOR_BLACK;
            //中间横线
            else if(act_y == 359)
                o_data <= COLOR_BLACK; 
            //时域    
            else if(act_x > 47 && act_y >= 411 && act_y <= 667 && (real_data == 667 - act_y || (real_data == 666 - act_y)))
                o_data <= COLOR_BLACK;   
            //5V虚线
            else if(act_y == 411 && act_x > 47 && (cnt == 4'd1 || cnt == 4'd2))
                o_data <= COLOR_BLACK;       
            //0V虚线    
            else if(act_y == 539 && act_x > 47 && (cnt == 4'd1 || cnt == 4'd2))
                o_data <= COLOR_BLACK; 
            //-5V虚线
            else if(act_y == 667 && act_x > 47 && (cnt == 4'd1 || cnt == 4'd2))
                o_data <= COLOR_BLACK; 
            //背景
            else 
                o_data <= COLOR_WHITE;
        end
    else if(cnt_key_d2 == 3'd2)
        begin
            //"HSST" 字模
            if(act_x >= 1152 && act_y <= 31 && char_2[act_y][1279 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;
            //背景
            else if(act_x >= 1152 && act_y <= 31 && char_2[act_y][1279 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;
            //"AD" 字模
            else if(act_x >= 1152 && act_y >= 360 && act_y <= 391 && char_3[act_y - 360][1279 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;
            //背景
            else if(act_x >= 1152 && act_y >= 360 && act_y <= 391 && char_3[act_y - 360][1279 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;
            //5V
            else if(act_x < 48 && act_y > 44 && act_y <= 60 && char_1[act_y - 45][48 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;
            //背景
            else if(act_x < 48 && act_y > 44 && act_y <= 60 && char_1[act_y - 45][48 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;
            //0V
            else if(act_x < 48 && act_y > 171 && act_y <= 187 && char_1[act_y - 172][48 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;
            //背景
            else if(act_x < 48 && act_y > 171 && act_y <= 187 && char_1[act_y - 172][48 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;
            //-5V
            else if(act_x < 48 && act_y > 299 && act_y <= 315 && char_1[act_y - 300][48 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;  
            //背景
            else if(act_x < 48 && act_y > 299 && act_y <= 315 && char_1[act_y - 300][48 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;    
            //5v 
            else if(act_x < 48 && act_y > 403 && act_y <= 419 && char_1[act_y - 404][48 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;
            //背景
            else if(act_x < 48 && act_y > 403 && act_y <= 419 && char_1[act_y - 404][48 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;
            //0v    
            else if(act_x < 48 && act_y > 531 && act_y <= 547 && char_1[act_y - 532][48 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;
            //背景
            else if(act_x < 48 && act_y > 531 && act_y <= 547 && char_1[act_y - 532][48 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;
            //-5v    
            else if(act_x < 48 && act_y > 659 && act_y <= 675 && char_1[act_y - 660][48 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;
            //背景
            else if(act_x < 48 && act_y > 659 && act_y <= 675 && char_1[act_y - 660][48 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;
            //HSST时域    
            else if(act_x > 47 && act_y >= 51 && act_y <= 307 && (real_data == 307 - act_y || real_data == 306 - act_y))
                o_data <= COLOR_BLACK;
            //中间横线
            else if(act_y == 359)
                o_data <= COLOR_BLACK; 
            //AD时域   
            else if(act_x > 47 && act_y >= 411 && act_y <= 667 && (real_data == 667 - act_y || real_data == 666 - act_y))
                o_data <= COLOR_BLACK;  
            //5V虚线
            else if(act_y == 51 && act_x > 47 && (cnt == 4'd1 || cnt == 4'd2))
                o_data <= COLOR_BLACK;  
            //0V虚线    
            else if(act_y == 179 && act_x > 47 && (cnt == 4'd1 || cnt == 4'd2))
                o_data <= COLOR_BLACK; 
            //-5V虚线
            else if(act_y == 307 && act_x > 47 && (cnt == 4'd1 || cnt == 4'd2))
                o_data <= COLOR_BLACK;      
            //5V虚线
            else if(act_y == 411 && act_x > 47 && (cnt == 4'd1 || cnt == 4'd2))
                o_data <= COLOR_BLACK;       
            //0V虚线    
            else if(act_y == 539 && act_x > 47 && (cnt == 4'd1 || cnt == 4'd2))
                o_data <= COLOR_BLACK; 
            //-5V虚线
            else if(act_y == 667 && act_x > 47 && (cnt == 4'd1 || cnt == 4'd2))
                o_data <= COLOR_BLACK; 
            //背景
            else 
                o_data <= COLOR_WHITE;
        end 
    else if(cnt_key_d2 == 3'd3)
        begin
            //"HSST" 字模
            if(act_x >= 1152 && act_y <= 31 && char_2[act_y][1279 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;
            //背景
            else if(act_x >= 1152 && act_y <= 31 && char_2[act_y][1279 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;
            //"AD" 字模
            else if(act_x >= 1152 && act_y >= 360 && act_y <= 391 && char_3[act_y - 360][1279 - act_x] == 1'b1)
                o_data <= COLOR_BLACK;
            //背景
            else if(act_x >= 1152 && act_y >= 360 && act_y <= 391 && char_3[act_y - 360][1279 - act_x] == 1'b0)
                o_data <= COLOR_WHITE;
            //HSST频谱    
            else if((act_y < 359) && ((cnt == 4'd4) || (cnt == 4'd3)) && (act_y > (360 - freq_data)))
                o_data <= COLOR_BLACK;
            //中间横线
            else if(act_y == 359)
                o_data <= COLOR_BLACK; 
            //AD频谱    
            else if((act_y > 359) && (act_y < 719) && ((cnt == 4'd4) || (cnt == 4'd3)) && (act_y > (719 - freq_data)))
                o_data <= COLOR_BLACK;
            //下方横线
            else if(act_y == 719)
                o_data <= COLOR_BLACK; 
            //背景
            else 
                o_data <= COLOR_WHITE;
        end    
        
endmodule    