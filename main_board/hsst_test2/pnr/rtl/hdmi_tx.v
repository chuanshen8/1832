module hdmi_tx
(
	input rst,
	input tx_clk,
	
	input pclk,
	input vs,
	input de,
	input[15:0] vin_data,
	input[15:0] vin_width,
	
    output reg[31:0] gt_tx_data,
    output reg[3:0] gt_tx_ctrl
);
localparam SEND_FRAME_SYNC0 = 0;
localparam SEND_FRAME_SYNC1 = 1;
localparam SEND_LINE_START  = 2;
localparam SEND_LINE_DATA   = 3;
localparam SEND_LINE_END    = 4;
localparam SEND_OTHER0      = 5;
localparam SEND_OTHER1      = 6;

reg[31:0] gt_tx_data_d0;
reg[ 3:0] gt_tx_ctrl_d0;
reg[ 2:0] state;
reg[15:0] data_cnt;

reg vs_tx_clk_d0;
reg vs_tx_clk_d1;
reg vs_tx_clk_d2;

reg vs_pclk_d0;
reg vs_pclk_d1;
reg vs_pclk_d2;

wire video_frame_sync;
assign video_frame_sync = vs_tx_clk_d1 & ~vs_tx_clk_d2;       //�ж�ov5640��Ƶͼ�����ͬ���ź�vs��������

wire[10:0] rd_data_count;
wire[15:0] buffer_cnt;
wire[31:0] buffer_dout;
reg buffer_rd_en;
always@(posedge tx_clk)
begin
	vs_tx_clk_d0 <= vs;
	vs_tx_clk_d1 <= vs_tx_clk_d0;
	vs_tx_clk_d2 <= vs_tx_clk_d1;
end

always@(posedge pclk)
begin
	vs_pclk_d0 <= vs;
	vs_pclk_d1 <= vs_pclk_d0;
	vs_pclk_d2 <= vs_pclk_d1;
end
//always@(posedge pclk)
//begin
//	gt_tx_data_d0 <= gt_tx_data;
//	gt_tx_data_d1 <= gt_tx_data_d0;
//	gt_tx_ctrl_d0<=gt_tx_ctrl;
//	gt_tx_ctrl_d1<=gt_tx_ctrl_d0;
//end
assign buffer_cnt = {4'd0,rd_data_count[10:0],1'b0};

fifo_4096_16i_32o  fifo_4096_16i_32o_inst 
(
    .wr_clk(pclk),
    .wr_rst(vs_pclk_d1 & ~vs_pclk_d2),
    .wr_en(de),
    .wr_data(vin_data),
    .wr_full(),
    .wr_water_level(),
    .almost_full(),
    .rd_clk(tx_clk),
    .rd_rst(vs_pclk_d1 & ~vs_pclk_d2),
    .rd_en(buffer_rd_en),
    .rd_data(buffer_dout),
    .rd_empty(),
    .rd_water_level(rd_data_count),
    .almost_empty());

always@(posedge tx_clk or posedge rst)
begin
	if(rst)
	begin
		data_cnt <= 16'd0;
	end
	else if(buffer_rd_en)
		data_cnt <= data_cnt + 16'd1;
	else
		data_cnt <= 16'd0;
end

always@(posedge tx_clk or posedge rst)
begin
	if(rst)
	begin
		buffer_rd_en <= 1'b0;
		state <= SEND_OTHER0;
		gt_tx_data <= 32'd0;
		gt_tx_ctrl <= 4'd0;
	end
	else if(video_frame_sync)
	begin
		state <= SEND_FRAME_SYNC0;
		buffer_rd_en <= 1'b0;
	end
	else
	begin
		case(state)
			SEND_FRAME_SYNC0:                    //������Ƶ��֡ͬ���ź�0
			begin
				state <= SEND_FRAME_SYNC1;
				gt_tx_data <= 32'hff_00_00_bc;
				gt_tx_ctrl <= 4'b0001;
			end
			SEND_FRAME_SYNC1:                    //������Ƶ��֡ͬ���ź�1
			begin
				state <= SEND_OTHER0;
				gt_tx_data <= 32'hff_00_01_bc;
				gt_tx_ctrl <= 4'b0001;
			end
			SEND_OTHER0:                        //������Ƶ�����õ��ź�ff_55_55_bc
			begin
				state <= SEND_OTHER1;
				gt_tx_data <= 32'hff_55_55_bc;
				gt_tx_ctrl <= 4'b0001;
			end
			SEND_OTHER1:                        //������Ƶ�����õ��ź�ff_aa_aa_bc
			begin
				if(buffer_cnt >= vin_width)     //�ж�FIFO���Ƿ���һ�е���Ƶͼ������
				begin
					state <= SEND_LINE_START;
					buffer_rd_en <= 1'b1;
				end
				else
				begin
					state <= SEND_OTHER0;
					buffer_rd_en <= 1'b0;
				end
				gt_tx_data <= 32'hff_aa_aa_bc;
			end
			SEND_LINE_START:               //����һ�����ݿ�ʼ�����ź�
			begin
				state <= SEND_LINE_DATA;
				gt_tx_data <= 32'hff_00_02_bc;
				gt_tx_ctrl <= 4'b0001;
			end
			SEND_LINE_DATA:                //����FIFO�е�һ����Ƶͼ������
			begin
				if(data_cnt == ({1'b0,vin_width[15:1]} - 16'd1))
					buffer_rd_en <= 1'b0;
				if(buffer_rd_en)
				begin
					state <= SEND_LINE_DATA;
					gt_tx_data <= buffer_dout;
					gt_tx_ctrl <= 4'b0000;
				end
				else
				begin
					state <= SEND_LINE_END;
					gt_tx_data <= buffer_dout;
					gt_tx_ctrl <= 4'b0000;
				end				
			end
			SEND_LINE_END:                //����һ����Ƶͼ�����ݽ����ź�
			begin
				state <= SEND_OTHER0;
				gt_tx_data <= 32'hff_00_03_bc;
				gt_tx_ctrl <= 4'b0001;
			end				
		endcase
	end
end
endmodule 