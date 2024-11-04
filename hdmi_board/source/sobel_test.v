module sobel_test
(
    input   clk,    
    input       clk_fifo, 
    input   rst_n, 
    input  [20:0] threshold,
    
   
    input        ycbcr_vs, //预图像数据列有效信号  //*synthesis PAP_MARK_DEBUG="1"*/
    input        ycbcr_hs,  //预图像数据行有效信号  //*synthesis PAP_MARK_DEBUG="1"*/
    input        ycbcr_de, //预图像数据输入使能效信号//*synthesis PAP_MARK_DEBUG="1"*/
    input [7:0]  ycbcr_y, //*synthesis PAP_MARK_DEBUG="1"*/
    input [7:0]  ycbcr_g, //*synthesis PAP_MARK_DEBUG="1"*/
    input [7:0]  ycbcr_b, //*synthesis PAP_MARK_DEBUG="1"*/
        
    output       sobel_vs_out, //处理后的图像数据列有效信号  //*synthesis PAP_MARK_DEBUG="1"*/
    output       sobel_hs_out,  //处理后的图像数据行有效信号  //*synthesis PAP_MARK_DEBUG="1"*/
    output       sobel_de_out, //处理后的图像数据输出使能效信号//*synthesis PAP_MARK_DEBUG="1"*/
    output     [7:0]  sobel_y_out  ,//*synthesis PAP_MARK_DEBUG="1"*/
    output     [7:0]  sobel_g_out  ,//*synthesis PAP_MARK_DEBUG="1"*/
    output     [7:0]  sobel_b_out  ,//*synthesis PAP_MARK_DEBUG="1"*/
    input    change_sobel  //*synthesis PAP_MARK_DEBUG="1"*/
   
);
 
    wire [7:0]    sobel_y;
	reg	[7:0]	r0;
	wire	[7:0]	r1;
	wire	[7:0]	r2;

	reg	[7:0]	r0_c0;	
	reg	[7:0]	r0_c1;	
	reg	[7:0]	r0_c2;
	
	reg	[7:0]	r1_c0;	
	reg	[7:0]	r1_c1;	
	reg	[7:0]	r1_c2;
	
	reg	[7:0]	r2_c0;	
	reg	[7:0]	r2_c1;	
	reg	[7:0]	r2_c2;	

//三行缓存
line_shift_ram_8bit line_shift_ram_8bit11(
    .clk         (clk),  
    .rst_n     (rst_n), 
    .ycbcr_de         (ycbcr_de),
    .ycbcr_hs        (ycbcr_hs),
    
    .shiftin      (ycbcr_y),  
    .rd_data0       (r2) ,   
    .rd_data1       (r1)
);

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
        r0 <= 0;
    else begin
        if(ycbcr_de_r[0])
            r0 <= ycbcr_y ;
        else
            r0 <= r0;
    end
end
	always@(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			r0_c0	<=	8'd0;
			r0_c1	<=	8'd0;
			r0_c2	<=	8'd0;	
			r1_c0	<=	8'd0;
			r1_c1	<=	8'd0;
			r1_c2	<=	8'd0;
			r2_c0	<=	8'd0;
			r2_c1	<=	8'd0;
			r2_c2	<=	8'd0;			
		end
		else if(ycbcr_de)begin
			r0_c0	<=	r0;
			r0_c1	<=	r0_c0;
			r0_c2	<=	r0_c1;
	
			r1_c0	<=	r1;
			r1_c1	<=	r1_c0;
			r1_c2	<=	r1_c1;	

			r2_c0	<=	r2;
			r2_c1	<=	r2_c0;
			r2_c2	<=	r2_c1;		
		end
	end
reg [9:0]  Gx_temp2; //第三列值
reg [9:0]  Gx_temp1; //第一列值
reg [9:0]  Gx_data;  
reg [9:0]  Gy_temp1; //第一行值
reg [9:0]  Gy_temp2; //第三行值
reg [9:0]  Gy_data;  
reg [20:0] Gxy_square;
reg [3:0]  ycbcr_vs_r;
reg [3:0]  ycbcr_hs_r; 
reg [3:0]  ycbcr_de_r;

assign sobel_vs = ycbcr_vs_r[3];
assign sobel_hs  = ycbcr_hs_r[3] ;
assign sobel_de = ycbcr_de_r[3];
assign sobel_y     = (sobel_hs==0 &&sobel_de==1)? sobel_data_r : 8'h00;//*synthesis PAP_MARK_DEBUG="1"*/

//Gx  -1  0  +1     Gy  +1  +2  +1      P  P11  P12  P13
//    -2  0  +2          0   0   0         P21  P22  P23
//    -1  0  +1         -1  -2  -1         P31  P32  P33
//
//|Gx| = |(P13+2*P23+P33)-(P11+2*P21+P31)|
//|Gy| = |(P11+2*P12+P13)-(P31+2*P32+P33)|
//|G| = |Gx|+ |Gy| 
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        Gy_temp1 <= 10'd0;
        Gy_temp2 <= 10'd0;
        Gy_data <=  10'd0;
    end
    else begin
        Gy_temp1 <= r0_c2 + (r1_c2 << 1) + r2_c2; 
        Gy_temp2 <= r0_c0 + (r1_c2 << 1) + r2_c0; 
        Gy_data <= (Gy_temp1 >= Gy_temp2) ? (Gy_temp1 - Gy_temp2) : 
                   (Gy_temp2 - Gy_temp1);
    end
end


always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        Gx_temp1 <= 10'd0;
        Gx_temp2 <= 10'd0;
        Gx_data <=  10'd0;
    end
    else begin
        Gx_temp1 <= r0_c0 + (r0_c1 << 1) + r0_c2; 
        Gx_temp2 <= r2_c0 + (r2_c1 << 1) + r2_c2; 
        Gx_data <= (Gx_temp1 >= Gx_temp2) ? (Gx_temp1 - Gx_temp2) : 
                   (Gx_temp2 - Gx_temp1);
    end
end



always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
        Gxy_square <= 21'd0;
    else
        Gxy_square <= Gx_data + Gy_data;
end


reg [7:0]sobel_data_r;
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)
       sobel_data_r <= 8'b0; 
    else if(Gxy_square >= threshold)
        sobel_data_r <= 8'h00; 
    else
        sobel_data_r <= 8'hff; 
end

//延迟9个周期同步
always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        ycbcr_vs_r <= 0;
        ycbcr_hs_r <= 0;
        ycbcr_de_r <= 0;
    end
    else begin
        ycbcr_vs_r  <=  {ycbcr_vs_r[3:0],ycbcr_vs};
        ycbcr_hs_r  <=  {ycbcr_hs_r[3:0],ycbcr_hs};
        ycbcr_de_r  <=  {ycbcr_de_r[3:0],ycbcr_de};
    end
end

assign  sobel_y_out=(change_sobel==0)?  ycbcr_y:sobel_y;
assign  sobel_g_out=(change_sobel==0)?  ycbcr_g:sobel_y;
assign  sobel_b_out=(change_sobel==0)?  ycbcr_b:sobel_y;
assign  sobel_vs_out=(change_sobel==0)?  ycbcr_vs:ycbcr_vs_r[3];
assign  sobel_hs_out=(change_sobel==0)?  ycbcr_hs:ycbcr_hs_r[3];
assign  sobel_de_out=(change_sobel==0)?  ycbcr_de:ycbcr_de_r[3];
endmodule 