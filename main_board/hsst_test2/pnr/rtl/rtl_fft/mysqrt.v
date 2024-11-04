/*
逐次逼近算法，逐位变1，平方后与被开方数比较，当前位是否可以为1;
可以流水计算，被开方数位宽时占用大量乘法器。
*/
module mysqrt
	#( 	
			parameter  		 							d_width = 32,
			parameter       							q_width = d_width/2 - 1,
			parameter       							r_width = d_width/2)
	(
	input			wire									clk,
	input			wire									rst,
	input			wire									i_vaild,
	input			wire		[d_width-1:0]				data_i, //输入
	
	
	output		reg											o_vaild,
	output		reg			[q_width:0]						data_o, //输出
	output		reg			[r_width:0]						data_r  //余数
	
    );
//--------------------------------------------------------------------------------
	reg 							[d_width-1:0] 		D			[r_width:1]; //被开方数
	reg 							[q_width:0] 		Q_z			[r_width:1]; //临时
	reg	 						  	[q_width:0] 		Q_q			[r_width:1]; //确认
	reg 												ivalid_t	[r_width:1]; //杈撳叆鏁版嵁鏈夋晥
//--------------------------------------------------------------------------------
	always@(posedge	clk or posedge	rst)
		begin
			if(rst)
				begin
					D[r_width] 				<= 0;
					Q_z[r_width] 			<= 0;
					Q_q[r_width] 			<= 0;
					ivalid_t[r_width] <= 0;
				end
			else	if(i_vaild)
				begin
					D[r_width] 	 			<= data_i;  								//被开方数进入缓存
					Q_z[r_width] 			<= {1'b1,{q_width{1'b0}}};  //实验值设置，开方值的一半，从最高位依次向下;
					Q_q[r_width] 			<= 0; 											//实际计算结果
					ivalid_t[r_width] <= 1;												// 有效
				end
			else
				begin
					D[r_width] 				<= 0;
					Q_z[r_width] 			<= 0;
					Q_q[r_width] 			<= 0;
					ivalid_t[r_width] <= 0;
				end
		end
//-------------------------------------------------------------------------------
//		迭代计算过程
//-------------------------------------------------------------------------------
		generate
			genvar i;
				for(i=r_width-1;i>=1;i=i-1)//从最高位开始向下比较
					begin:U
						always@(posedge clk or posedge	rst)
							begin
								if(rst)
									begin
										D[i] 				<= 0;
										Q_z[i] 			<= 0;
										Q_q[i] 			<= 0;
										ivalid_t[i] <= 0;
									end
								else	if(ivalid_t[i+1])
									begin
										if(Q_z[i+1]*Q_z[i+1] > D[i+1])//注意此处有平方的乘运算，被开方数位宽时占用大量乘法器。
											begin
												Q_z[i] <= {Q_q[i+1][q_width:i],1'b1,{{i-1}{1'b0}}};
												Q_q[i] <=  Q_q[i+1];//试验平方大于被开方数，当前实验值不可确认，确认值不变，并将第i bit置1进行下一次试验比较 
											end
										else
											begin
												Q_z[i] <= {Q_z[i+1][q_width:i],1'b1,{{i-1}{1'b0}}};
												Q_q[i] <=  Q_z[i+1]; //试验平方小于被开方数，当前实验值可确认，并将第i bit置1进行下一次试验比较
											end
										D[i] 				<= D[i+1];//流水移动
										ivalid_t[i] <= 1;
									end
								else
									begin
										ivalid_t[i] <= 0;
										D[i] 				<= 0;
										Q_q[i] 			<= 0;
										Q_z[i] 			<= 0;
									end
							end
					end
		endgenerate
//--------------------------------------------------------------------------------
//	计算余数与最终平方根
//--------------------------------------------------------------------------------
		always@(posedge	clk or posedge	rst) 
			begin
				if(rst)
					begin
						data_o <= 0;
						data_r <= 0;
						o_vaild <= 0;
					end
				else	if(ivalid_t[1])
					begin
						if(Q_z[1]*Q_z[1] > D[1])//  Q_z比Q_q提前变化一位用于对比测试
							begin
								data_o <= Q_q[1];
								data_r <= D[1] - Q_q[1]*Q_q[1];//余数
								o_vaild <= 1;
							end
						else
							begin
								data_o <= {Q_q[1][q_width:1],Q_z[1][0]};//试验值的[0]有效补给确认确认值
								data_r <= D[1] - {Q_q[1][q_width:1],Q_z[1][0]}*{Q_q[1][q_width:1],Q_z[1][0]};
								o_vaild <= 1;
							end
					end
				else
					begin
						data_o <= 0;
						data_r <= 0;
						o_vaild <= 0;
					end
			end
endmodule
//--------------------------------------------------------------------------------
