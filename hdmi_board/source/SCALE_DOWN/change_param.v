module param_change(
    input                                   clk_wr                ,//写时钟
    input                                   clk_rd                ,//读时钟
    input         [12:0]                     change_en             ,//切换信号，1 为放大，2 为缩小,4 为原图
    input                                   rst_n                 ,//复位信号
    

    input                                   wr_vsync               ,//写端场信号 
    input         [12:0]                    s_width                ,//缩放前宽度
    input         [12:0]                    s_height               ,//缩放前高度
    
    output        [12:0]                    t_width_wr             ,//写端缩放后宽度
    output        [12:0]                    t_height_wr            ,//写端缩放后高度 
    output        [15:0]                    h_scale_k              ,//列缩放因子 
    output        [15:0]                    v_scale_k              ,//行缩放因子 



	
    output        [24:0]                     wr_bust_total_len      //从 DDR3 中读数据时的突发长度   
);

//reg define
reg             [24:0]               wr_bust_total_len        ;  
reg             [7:0]                wr_vsync_d               ; 
reg             [12:0]               change_en_d0             ;
reg             [12:0]               change_en_d1             ;
reg             [12:0]               change_en_rd_d0          ;
reg             [12:0]               change_en_rd_d1          ;
reg 		                         delay_frame              ;//切换后写入一帧标志信号
reg  		                         delay_frame_d0           ;
reg             [12:0]               t_width_wr               ; 
reg             [12:0]               t_height_wr              ;
reg             [11:0]               t_width_rd               ; 
reg             [11:0]               t_height_rd              ;     
reg             [10:0]                change_en_wr             ;
reg             [10:0]                change_en_rd             ;
reg             [15:0]               h_scale_k=256                ;//（s_width * 256）/ t_width
reg             [15:0]               v_scale_k=256                ;//（s_height * 256）/ t_height



//放大后图像的分辨率 
localparam t_width_up1    = 12'd2240;
localparam t_height_up1   = 12'd1260;
localparam t_width_up2    = 12'd2560;
localparam t_height_up2   = 12'd1440;
localparam t_width_up3    = 12'd2880;
localparam t_height_up3   = 12'd1620;
localparam t_width_up4    = 12'd3200;
localparam t_height_up4   = 12'd1800;
localparam t_width_up5    = 12'd3520;
localparam t_height_up5   = 12'd1980;
localparam t_width_up6    = 12'd3600;
localparam t_height_up6   = 12'd2000;
//缩小后图像的分辨率
localparam t_width_down1  = 12'd1601;
localparam t_height_down1 = 12'd900 ;
localparam t_width_down2  = 12'd1280;
localparam t_height_down2 = 12'd720 ;
localparam t_width_down3  = 12'd960 ;
localparam t_height_down3 = 12'd540 ;
localparam t_width_down4  = 12'd640 ;
localparam t_height_down4 = 12'd360 ;
localparam t_width_down5  = 12'd320 ;
localparam t_height_down5 = 12'd180 ;
localparam t_width_down6  = 12'd200 ;
localparam t_height_down6 = 12'd100 ;


always @(posedge clk_wr or negedge rst_n)begin
    if(!rst_n)begin
        wr_vsync_d <= 8'b0;
        change_en_d0 <= 13'b0;

    end
    else begin
        wr_vsync_d <= {wr_vsync_d[6:0],wr_vsync}; 
        change_en_d0 <= change_en;
        change_en_d1 <= change_en_d0;

    end
end

//产生写端切换使能
always@(posedge clk_wr or negedge rst_n)begin
	if(~rst_n) begin
		change_en_wr <= 13'b0;	

    end			
	else if(wr_vsync_d[1] && ~wr_vsync_d[0]) begin
		change_en_wr <= change_en_d0;	
    end				
	else begin
		change_en_wr <= change_en_wr; 
    end							
end

//写端缩放后的分辨率

always @(posedge clk_wr or negedge rst_n)begin
	if(!rst_n)begin
		t_width_wr  <= 12'b0;	
		t_height_wr <= 12'b0;	
	end
	else if(wr_vsync_d[2] && ~wr_vsync_d[1])begin 
		case(change_en_wr)
			13'b000000_0_000001	:begin
				t_width_wr  <= t_width_down6 ;
				t_height_wr <= t_height_down6;
			end
			13'b000000_0_000010	:begin
				t_width_wr  <= t_width_down5 ;
				t_height_wr <= t_height_down5;
			end
			13'b000000_0_000100	:begin
				t_width_wr  <= t_width_down4 ;
				t_height_wr <= t_height_down4;
			end
			13'b000000_0_001000	:begin
				t_width_wr  <= t_width_down3 ;
				t_height_wr <= t_height_down3;
			end
			13'b000000_0_010000	:begin
				t_width_wr  <= t_width_down2 ;
				t_height_wr <= t_height_down2;
			end
			13'b000000_0_100000	:begin
				t_width_wr  <= t_width_down1 ;
				t_height_wr <= t_height_down1;
			end
			13'b000000_1_000000	:begin
	    		t_width_wr  <= s_width;	
	    		t_height_wr <= s_height;	
			end
			13'b000001_0_000000	:begin
	    		t_width_wr  <= t_width_up1 ;	
	    		t_height_wr <= t_height_up1;	
			end
			13'b000010_0_000000	:begin
	    		t_width_wr  <= t_width_up2 ;	
	    		t_height_wr <= t_height_up2;	
			end
			13'b000100_0_000000	:begin
	    		t_width_wr  <= t_width_up3 ;	
	    		t_height_wr <= t_height_up3;	
			end
			13'b001000_0_000000	:begin
	    		t_width_wr  <= t_width_up4 ;	
	    		t_height_wr <= t_height_up4;	
			end
			13'b010000_0_000000	:begin
	    		t_width_wr  <= t_width_up5 ;	
	    		t_height_wr <= t_height_up5;	
			end
			13'b100000_0_000000	:begin
	    		t_width_wr  <= t_width_up6 ;	
	    		t_height_wr <= t_height_up6;	
			end
			default		 	    :begin
	    		t_width_wr  <= s_width ;	
	    		t_height_wr <= s_height;	
			end
		endcase
	end
end

//产生行场缩放因子
always@(posedge clk_wr or negedge rst_n)begin
	if(~rst_n)begin
		h_scale_k  <= 16'b0;	                 
		v_scale_k  <= 16'b0;	
	end
	else if(wr_vsync_d[3] && ~wr_vsync_d[2])begin
		case(change_en_wr)
			13'b000000_0_000001   :begin
	    		h_scale_k <= 16'd2458;	
	    		v_scale_k <= 16'd2765;	
			end
			13'b000000_0_000010   :begin
	    		h_scale_k <= 16'd1536;	
	    		v_scale_k <= 16'd1536;	
			end
			13'b000000_0_000100   :begin
				h_scale_k <= 16'd768;
				v_scale_k <= 16'd768;
			end
			13'b000000_0_001000   :begin
				h_scale_k <= 16'd512;
				v_scale_k <= 16'd512;
			end
			13'b000000_0_010000   :begin
				h_scale_k <= 16'd384;
				v_scale_k <= 16'd384;
			end
			13'b000000_0_100000   :begin
				h_scale_k <= 16'd307;
				v_scale_k <= 16'd307;
			end
			13'b000000_1_000000   :begin
	    		h_scale_k <= 16'd256;	
	    		v_scale_k <= 16'd256;
			end
			13'b000001_0_000000   :begin
	    		h_scale_k <= 16'd219;	
	    		v_scale_k <= 16'd219;	
			end
			13'b000010_0_000000   :begin
	    		h_scale_k <= 16'd192;	
	    		v_scale_k <= 16'd192;	
			end
			13'b000100_0_000000   :begin
	    		h_scale_k <= 16'd170;	
	    		v_scale_k <= 16'd170;	
			end
			13'b001000_0_000000   :begin
	    		h_scale_k <= 16'd153;	
	    		v_scale_k <= 16'd153;	
			end
			13'b010000_0_000000   :begin
	    		h_scale_k <= 16'd139;	
	    		v_scale_k <= 16'd139;	
			end
			13'b100000_0_000000   :begin
	    		h_scale_k <= 16'd136;	
	    		v_scale_k <= 16'd138;	
			end
			default		 	    :begin
	    		h_scale_k <= 16'd256;	
	    		v_scale_k <= 16'd256;	
			end
		endcase
	end
end


//产生切换后写入一帧标志信号


//产生写端的 ddr 参数 
always@(posedge clk_wr or negedge rst_n)begin
	if(~rst_n)
		wr_bust_total_len <= 25'd0;
	else if(wr_vsync_d[5] && ~wr_vsync_d[4])begin
		case(change_en_wr)
        //wr_bust_len <= s_width_wr[10:3];
        //app_addr_wr_max <= s_width_wr * s_height_wr; 16bit一长度1920*1080再除以16
     	    13'b000000_0_000001   :wr_bust_total_len <= 25'd1250 ; 
			13'b000000_0_000010   :wr_bust_total_len <= 25'd3600 ;  
			13'b000000_0_000100   :wr_bust_total_len <= 25'd14400;
			13'b000000_0_001000   :wr_bust_total_len <= 25'd32400;
			13'b000000_0_010000   :wr_bust_total_len <= 25'd57600;
			13'b000000_0_100000   :wr_bust_total_len <= 25'd90000;
			13'b000000_1_000000   :wr_bust_total_len <= 25'd129600;
			13'b000001_0_000000   :wr_bust_total_len <= 25'd176400;
			13'b000010_0_000000   :wr_bust_total_len <= 25'd230400;
			13'b000100_0_000000   :wr_bust_total_len <= 25'd291600;
			13'b001000_0_000000   :wr_bust_total_len <= 25'd360000;
			13'b010000_0_000000   :wr_bust_total_len <= 25'd435600;
			13'b100000_0_000000   :wr_bust_total_len <= 25'd450000;
			default		 	   	  :wr_bust_total_len <= 25'd129600;
		endcase
	end
end





endmodule
