module scaler_up#(
    parameter   H_DISP = 1280,
    parameter   V_DISP = 720
)
(
    input               pix_clk,
    input               rst_n,

    input  [23:0]       data_in,
    input               data_in_valid,
    input               frame_flag,  //һ֡��ʼ�ź�
    input               scale_state,

    input  [11:0]       t_width,     //�Ŵ��ͼ����
    input  [11:0]       t_height,

    output [23:0]       data_out,
    output              data_out_valid
);

reg  [11:0] r_t_width ; 
reg  [11:0] r_t_height;
reg  [11:0] r_cnt_v; //�г�ͬ��������
reg  [11:0] r_cnt_h;
reg         r_data_out_valid;
reg  [23:0] r_adta_out;

reg         r_scale_state;  //�Ĵ�����״̬

wire [11:0] frame_border_l; //���߽�ĺ�����
wire [11:0] frame_border_r; //�Ҳ�߽�ĺ�����
wire [11:0] frame_border_t; //�϶˱߽��������
wire [11:0] frame_border_b; //�¶˱߽��������

//���߽�ĺ�����
assign frame_border_l = (r_t_width - H_DISP)/2;

//���߽�ĺ�����
assign frame_border_r = (r_t_width - H_DISP)/2 + H_DISP; 

//�϶˱߽��������
assign frame_border_t = (r_t_height - V_DISP)/2;

//�¶˱߽��������
assign frame_border_b = (r_t_height - V_DISP)/2 + V_DISP;

//��һ֡��ʼʱ�Ĵ����ź���
always @(posedge pix_clk or negedge rst_n)begin
    if(!rst_n)begin
        r_t_width  <= 12'd0;
        r_t_height <= 12'd0;
    end
    else if(frame_flag)begin
        r_t_width  <= t_width;
        r_t_height <= t_height;
    end
    else begin
        r_t_width  <= r_t_width;
        r_t_height <= r_t_height;
    end
end

always @(posedge pix_clk or negedge rst_n)begin
    if(!rst_n || frame_flag)
        r_cnt_h <= 12'd0;
    else if(r_cnt_h == r_t_width - 1)
        r_cnt_h <= 12'd0;
    else if(data_in_valid)
        r_cnt_h <= r_cnt_h + 1'b1;
    else 
        r_cnt_h <= r_cnt_h;
end

always @(posedge pix_clk or negedge rst_n)begin
    if(!rst_n || frame_flag)
        r_cnt_v <= 12'd0;
    else if(r_cnt_h == r_t_width - 1)begin
        if(r_cnt_v == r_t_height - 1)
            r_cnt_v <= 12'd0;
        else 
            r_cnt_v <= r_cnt_v + 1'b1;
    end
    else
        r_cnt_v <= r_cnt_v;
end

//�������������Ч�ź�
always @(posedge pix_clk or negedge rst_n)begin
    if(!rst_n)
        r_data_out_valid <= 1'b0;
    else if(r_cnt_h >= frame_border_l && r_cnt_h < frame_border_r && 
            r_cnt_v >= frame_border_t && r_cnt_v < frame_border_b)
        r_data_out_valid <= data_in_valid;
    else 
        r_data_out_valid <= 1'b0;
end

always @(posedge pix_clk or negedge rst_n)begin
    if(!rst_n)
        r_adta_out <= 24'd0;
    else if(r_cnt_h >= frame_border_l && r_cnt_h < frame_border_r && 
            r_cnt_v >= frame_border_t && r_cnt_v < frame_border_b)
        r_adta_out <= data_in;
    else 
        r_adta_out <= 24'd0;
end

always @(posedge pix_clk or negedge rst_n)begin
    if(!rst_n)
        r_scale_state <= 1'b1;
    else if(frame_flag)
        r_scale_state <= scale_state;
end

assign data_out       = r_scale_state ? r_adta_out : data_in;
assign data_out_valid = r_scale_state ? r_data_out_valid : data_in_valid;

endmodule