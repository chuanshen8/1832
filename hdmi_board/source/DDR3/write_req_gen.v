module write_req_gen(
	input              rst,
	input              pclk,   
	input              cmos_vsync,  //一帧的起始信号
	output reg         write_req,
	output reg    	   write_addr_index, //写bank地址索引
	output reg         read_addr_index,  //读bank地址索引
	input              write_req_ack
);
reg cmos_vsync_d0;
reg cmos_vsync_d1;
wire	frame_start	=	( cmos_vsync_d0 == 1'b1 && cmos_vsync_d1 == 1'b0 );  //场同步信号的上升沿
always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		cmos_vsync_d0 <= 1'b0;
		cmos_vsync_d1 <= 1'b0;
	end
	else
	begin
		cmos_vsync_d0 <= cmos_vsync;
		cmos_vsync_d1 <= cmos_vsync_d0;
	end
end
always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
		write_req <= 1'b0;
	else if(frame_start) //检测场同步信号上升沿
		write_req <= 1'b1;
	else if(write_req_ack == 1'b1) //写请求应答后拉低
		write_req <= 1'b0;
end
always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
		write_addr_index <= 1'b0; //初始状态,摄像头数据写入bank0
	else if(frame_start)  //每次写完一帧累加一次,0~1循环
		write_addr_index <= write_addr_index + 1'd1;
	else
		write_addr_index <= write_addr_index;
end

always@(posedge pclk or posedge rst)
begin
	if(rst == 1'b1)
		read_addr_index <= 2'b0;
	else if(frame_start)
		read_addr_index <= write_addr_index;  //读地址bank始终落后于写地址bank一拍
	else
		read_addr_index <= read_addr_index;
end

endmodule 
