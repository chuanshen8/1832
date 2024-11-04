module video_rect_read_data
#(
	parameter DATA_WIDTH = 16                       // Video data one clock data width
)
(
	input                       	video_clk,          // Video pixel clock
	input                       	rst,

	input	[11:0]                 	video_left_offset, 
	input	[11:0]                 	video_top_offset,
	input	[11:0]                 	video_width,
	input	[11:0]                 	video_height,
	
	output reg                  	read_req,           // Start reading a frame of data     
	input                       	read_req_ack,       // Read request response
	output                      	read_en,            // Read data enable
	input	[DATA_WIDTH - 1:0]     	read_data,          // Read data

	input                       	timing_hs,    
	input                       	timing_vs,    
	input                       	timing_de,    
	input	[DATA_WIDTH - 1:0]     	timing_data, 

	output                      	hs,                 // horizontal synchronization
	output                      	vs,                 // vertical synchronization
	output                      	de,                 // video valid
	output	[DATA_WIDTH - 1:0]    	vout_data           // video data
);

wire[11:0]             pos_x;
wire[11:0]             pos_y;
wire                   pos_hs;
wire                   pos_vs;
wire                   pos_de;
wire[DATA_WIDTH - 1:0] pos_data;
reg[DATA_WIDTH - 1:0]  pos_data_d0;
reg[DATA_WIDTH - 1:0]  pos_data_d1;



//delay video_hs video_vs  video_de 2 clock cycles
reg                    pos_hs_d0;
reg                    pos_vs_d0;
reg                    pos_de_d0;
reg                    pos_hs_d1;
reg                    pos_vs_d1;
reg                    pos_de_d1;
reg                    pos_hs_d2;
reg                    pos_vs_d2;
reg                    pos_de_d2;
reg                    read_en_r;
reg                    read_en_r_d0;

reg[DATA_WIDTH - 1:0]  vout_data_r;
assign hs = pos_hs_d2;
assign vs = pos_vs_d2;
assign de = pos_de_d2;

always@(posedge video_clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		pos_hs_d0 <= 1'b0;
		pos_vs_d0 <= 1'b0;
		pos_de_d0 <= 1'b0;
		pos_hs_d1 <= 1'b0;
		pos_vs_d1 <= 1'b0;
		pos_de_d1 <= 1'b0;
		pos_data_d0 <= {DATA_WIDTH{1'b0}};
		pos_data_d1 <= {DATA_WIDTH{1'b0}};
		read_en_r_d0 <= 1'b0;
	end
	else
	begin
		//delay pos hs vs de 3 clock cycles
		pos_hs_d0   <= pos_hs;
		pos_vs_d0   <= pos_vs;
		pos_de_d0   <= pos_de;
		pos_hs_d1   <= pos_hs_d0;
		pos_vs_d1   <= pos_vs_d0;
		pos_de_d1   <= pos_de_d0;	
		pos_hs_d2   <= pos_hs_d1;
		pos_vs_d2   <= pos_vs_d1;
		pos_de_d2   <= pos_de_d1;
		pos_data_d0 <= pos_data;
		pos_data_d1 <= pos_data_d0;
		read_en_r_d0 <= read_en_r;
	end
end

assign read_en = read_en_r; 

//当显示时序数据pos_de有效,且横纵坐标(pos_x,pos_y)在需要显示的区域内,拉高读使能
always@(posedge video_clk or posedge rst)
begin
	if(rst == 1'b1)
		read_en_r <= 1'b0;
	else if(pos_de == 1'b1 && pos_x >= video_left_offset && pos_x < video_left_offset + video_width 
	        && pos_y >= video_top_offset && pos_y < video_top_offset + video_height)
		read_en_r <= 1'b1;
	else
		read_en_r <= 1'b0;
end

assign vout_data = vout_data_r;
always@(posedge video_clk or posedge rst)
begin
	if(rst == 1'b1)
		vout_data_r <= {DATA_WIDTH{1'b0}};
	else if(read_en_r_d0 == 1'b1)  //因为读使能read_en_r拉高后,下个时钟才给出读FIFO读端口的数据,这里延迟一拍赋值数据
		vout_data_r <= read_data;
	else
		vout_data_r <= pos_data_d1;
end

always@(posedge video_clk or posedge rst)
begin
	if(rst == 1'b1)
		read_req <= 1'b0;
	else if(pos_vs_d0 == 1'b1 & pos_vs == 1'b0) //vertical synchronization edge (the rising or falling edges are OK)
		read_req <= 1'b1;
	else if(read_req_ack == 1'b1)
		read_req <= 1'b0;
end

//这个模块主要是为了获取显示有效区域的横纵坐标
//输出的显示同步信号比输入的显示同步信号延迟两拍
timing_gen_xy#(.DATA_WIDTH(DATA_WIDTH)) timing_gen_xy_m0(
	.rst_n    (~rst          ), //input 
	.clk      (video_clk     ), //input

	.i_hs     (timing_hs     ), //input 
	.i_vs     (timing_vs     ), //input 
	.i_de     (timing_de     ), //input 
	.i_data   (timing_data   ), //input

	.o_hs     (pos_hs        ), //output
	.o_vs     (pos_vs        ), //output
	.o_de     (pos_de        ), //output
	.o_data   (pos_data      ), //output

	.x        (pos_x         ), //output
	.y        (pos_y         )  //output
);
endmodule 