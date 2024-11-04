`define COE  10*rgb_ctrl_plus10
`define COER 10*r_ctrl_plus10
`define COEG 10*g_ctrl_plus10
`define COEB 10*b_ctrl_plus10
module lighter_and_color(
//input
//	input		r_ctrl_plus10,//����r
//	input		g_ctrl_plus10,//����g
//	input		b_ctrl_plus10,//����b
	input	[2:0]	rgb_ctrl_plus10,//����rgb����4������
	input	[2:0]	r_ctrl_plus10,//����r����5������
	input	[2:0]	g_ctrl_plus10,//����g����6������
	input	[2:0]	b_ctrl_plus10,//����b����7������
	input       clk,
	input       rst_n,

	input     		  hs_in,
	input     	 	  vs_in,
	input     		  de_in,
	input  [23:0]    data_in,

//output
	output   reg  		  hs_out,
	output     reg	 	  vs_out,
	output     reg		  de_out,
	output  [23:0]    data_out
		
);

wire   [8:0] r_data_out;
wire   [8:0] g_data_out;
wire   [8:0] b_data_out;




wire   [7:0] r_data_in;
wire   [7:0] g_data_in;
wire   [7:0] b_data_in;

assign   r_data_in =  data_in[23:16];
assign   g_data_in =  data_in[15:8];
assign   b_data_in =  data_in[7:0];

assign r_data_out=r_data_in+`COE+`COER;//5
assign g_data_out=g_data_in+`COE+`COEG;//10
assign b_data_out=b_data_in+`COE+`COEB;//15
// assign r_data_out=r_data_in+`COE;//5
// assign g_data_out=g_data_in+`COE;//10
// assign b_data_out=b_data_in+`COE;//15


reg   [7:0] rr_data_out;
reg   [7:0] gg_data_out;
reg   [7:0] bb_data_out;
//vga�ź�delay 1��
//�������ʱ��
always@(posedge clk or negedge rst_n)
begin
	if(rst_n)
		begin	
        hs_out<=0;
        vs_out<=0;
        de_out<=0;
      end
    else
    begin
        hs_out<=hs_in;
        vs_out<=vs_in;
        de_out<=de_in;
    end
end

always @(posedge clk or negedge rst_n)begin
  if(rst_n) begin
    rr_data_out<=0;
    gg_data_out<=0;
	bb_data_out<=0;
  end
  else begin
    if(!(rgb_ctrl_plus10|r_ctrl_plus10|g_ctrl_plus10|b_ctrl_plus10)) begin
	   rr_data_out<=r_data_in;
		gg_data_out<=g_data_in;
		bb_data_out<=b_data_in;
	  end
    else
      begin
	  	rr_data_out<=(r_data_out>255)?255:r_data_out[7:0];
		gg_data_out<=(g_data_out>255)?255:g_data_out[7:0];
		bb_data_out<=(b_data_out>255)?255:b_data_out[7:0];
	  end
	
  end
end

assign data_out ={rr_data_out,gg_data_out,bb_data_out};






endmodule
