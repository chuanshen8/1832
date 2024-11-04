module data_modulus(
	input			clk_50m				,
	input 			rst_n				,
	//FFT ST 接口
	input  [15:0] 	source_real			/*synthesis PAP_MARK_DEBUG="1"*/,
	input  [15:0] 	source_imag			/*synthesis PAP_MARK_DEBUG="1"*/,
	input 			source_sop			/*synthesis PAP_MARK_DEBUG="1"*/,
	input 			source_eop			/*synthesis PAP_MARK_DEBUG="1"*/,
	input 			source_valid		/*synthesis PAP_MARK_DEBUG="1"*/,
	//取模运算后的数据接口
	output [15:0] 	data_modulus		/*synthesis PAP_MARK_DEBUG="1"*/,
	output wire 	data_sop			/*synthesis PAP_MARK_DEBUG="1"*/,
	output wire 	data_eop			/*synthesis PAP_MARK_DEBUG="1"*/,
	output reg 		data_valid			/*synthesis PAP_MARK_DEBUG="1"*/
);

//reg define
	reg [31:0] source_data/*synthesis PAP_MARK_DEBUG="1"*/;
	reg [15:0] data_real;
	reg [15:0] data_imag;
	
//取实部和虚部的平方和
	always@(posedge clk_50m or negedge rst_n)	begin
		if(!rst_n)	begin
			source_data <= 32'd0;
			data_real <= 16'd0;
			data_imag <= 16'd0;
		end
		else	begin
			if(source_real[15] == 1'b0)				//由补码计算原码
				data_real <= source_real;
			else
				data_real <= ~source_real + 1'b1;
				
			if(source_imag[15] == 1'b0)				//由补码计算原码
				data_imag <= source_imag;
			else
				data_imag <= ~source_imag + 1'b1;
													//计算原码平方和
			source_data <= (data_real * data_real) + (data_imag * data_imag);
		end
	end

reg         [8:0]       cnt_19 /*synthesis PAP_MARK_DEBUG="1"*/;        
reg         [8:0]       cnt /*synthesis PAP_MARK_DEBUG="1"*/; 
   
always@(posedge clk_50m or negedge rst_n)
    if(!rst_n)
        cnt_19 <= 9'd0;
    else if(source_valid == 1'b1)
        cnt_19 <= cnt_19 + 1'b1;
    else
        cnt_19 <= 9'd0;
        
always@(posedge clk_50m or negedge rst_n)
    if(!rst_n)
        data_valid <= 1'b0;
    else if(cnt_19 == 9'd16)
        data_valid <= 1'b1;
    else if(cnt == 9'd255)
        data_valid <= 1'b0;
       
always@(posedge clk_50m or negedge rst_n)
    if(!rst_n)
        cnt <= 9'd0;
    else if(data_valid == 1'b1)
        cnt <= cnt + 1'b1;
    else    
        cnt <= 9'd0;
        
assign data_sop = (cnt_19 == 9'd17) ? 1'b1 : 1'b0;
assign data_eop = (cnt   == 9'd255) ? 1'b1 : 1'b0;
      
	/*
reg[15:0] data_modulus;
always@(posedge clk_50m or negedge rst_n)	begin
	if(!rst_n)	begin
		data_modulus <= 16'd0;
	end
	else if(data_valid)
		data_modulus <= source_data[15:0];
end*/
	
//例化 sqrt 模块，开根号运算
	mysqrt	mysqrt_u1(
	.clk		(clk_50m)	,
	.rst		(~rst_n)	,
	.i_vaild	(source_valid),
	.data_i		(source_data), //输入
	
	
	.o_vaild	()			,
	.data_o	(data_modulus), //输出
	.data_r  	()//余数
	
    );

endmodule
