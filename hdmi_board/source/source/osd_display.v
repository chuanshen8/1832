module osd_display(
	input                       rst_n,   
	input                       pclk,
	input                       adc_clk,
	input[31:0]                  adc_buf_data,
	input                       i_hs,    
	input                       i_vs,    
	input                       i_de,	
	input[15:0]                 i_data,
	output                      o_hs,    
	output                      o_vs,    
	output                      o_de,    
	output[15:0]                o_data,
    input                       rec_en,
    input     [127:0] char0    /*synthesis PAP_MARK_DEBUG="1"*/  ,/*synthesis PAP_MARK_DEBUG="1"*/
    input     [127:0] char1      ,
    input     [127:0] char2      ,
    input     [127:0] char3      ,
    input     [127:0] char4      ,
    input     [127:0] char5      ,
    input     [127:0] char6      ,
    input     [127:0] char7      ,
    input     [127:0] char8      ,
    input     [127:0] char9      ,
    input     [127:0] char10     ,
    input     [127:0] char11     ,
    input     [127:0] char12     ,
    input     [127:0] char13     ,
    input     [127:0] char14     ,
    input     [127:0] char15     ,
    input     [127:0] char16     ,
    input     [127:0] char17     ,
    input     [127:0] char18     ,
    input     [127:0] char19     ,
    input     [127:0] char20     ,
    input     [127:0] char21     ,
    input     [127:0] char22     ,
    input     [127:0] char23     ,
    input     [127:0] char24     ,
    input     [127:0] char25     ,
    input     [127:0] char26     ,
    input     [127:0] char27     ,
    input     [127:0] char28     ,
    input     [127:0] char29     ,
    input     [127:0] char30     ,
    input     [127:0] char31      
);
//reg   [127:0] char0              ;
//reg   [127:0] char1              ;
//reg   [127:0] char2              ;
//reg   [127:0] char3              ;
//reg   [127:0] char4              ;
//reg   [127:0] char5              ;
//reg   [127:0] char6              ;
//reg   [127:0] char7              ;
//reg   [127:0] char8              ;
//reg   [127:0] char9              ;
//reg   [127:0] char10             ;
//reg   [127:0] char11             ;
//reg   [127:0] char12             ;
//reg   [127:0] char13             ;
//reg   [127:0] char14             ;
//reg   [127:0] char15             ;
//reg   [127:0] char16             ;
//reg   [127:0] char17             ;
//reg   [127:0] char18             ;
//reg   [127:0] char19             ;
//reg   [127:0] char20             ;
//reg   [127:0] char21             ;
//reg   [127:0] char22             ;
//reg   [127:0] char23             ;
//reg   [127:0] char24             ;
//reg   [127:0] char25             ;
//reg   [127:0] char26             ;
//reg   [127:0] char27             ;
//reg   [127:0] char28             ;
//reg   [127:0] char29             ;
//reg   [127:0] char30             ;
//reg   [127:0] char31             ;


parameter OSD_WIDTH   =  128;
parameter OSD_HEGIHT  =  32;
wire[11:0] pos_x;
wire[11:0] pos_y;
wire       pos_hs;
wire       pos_vs;
wire       pos_de;
wire[16:0] pos_data;
reg[16:0]  v_data;
reg[11:0]  osd_x;
reg[11:0]  osd_y;
reg[11:0]  osd_ram_addr;//*synthesis PAP_MARK_DEBUG="1"*/
wire[7:0]  q;
reg        region_active;
reg        region_active_d0;
reg        region_active_d1;
reg        region_active_d2;

reg        pos_vs_d0;
reg        pos_vs_d1;
reg        pos_hs_d0;
reg        pos_de_d0;

assign o_data = v_data;
assign o_hs = pos_hs_d0;
assign o_vs = pos_vs;
assign o_de = pos_de_d0;
//delay 1 clock 
always@(posedge pclk or negedge rst_n )
begin
   if(rst_n == 1'b1)
		region_active <= 1'b0;
	else if(pos_x>=0&&pos_x<128&&pos_y>=0&&pos_y<32 && pos_de)
		region_active <= 1'b1;
	else
		region_active <= 1'b0;
end


always@(posedge pclk)
begin
	region_active_d0 <= region_active;
	region_active_d1 <= region_active_d0;
	region_active_d2 <= region_active_d1;
end

always@(posedge pclk)
begin
	pos_vs_d0 <= pos_vs;
	pos_vs_d1 <= pos_vs_d0;
    pos_de_d0 <=pos_de;
    pos_hs_d0<=pos_hs;
end

//delay 2 clock
//region_active_d0


reg   [127:0] char[31:0];  //�ַ�����
always @(posedge pclk  ) begin
    char[0 ]  <= char0 ;
    char[1 ]  <= char1 ;
    char[2 ]  <= char2 ;
    char[3 ]  <= char3 ;
    char[4 ]  <= char4 ;
    char[5 ]  <= char5 ;
    char[6 ]  <= char6 ;
    char[7 ]  <= char7 ;
    char[8 ]  <= char8 ;
    char[9 ]  <= char9 ;
    char[10]  <= char10;
    char[11]  <= char11;
    char[12]  <= char12;
    char[13]  <= char13;
    char[14]  <= char14;
    char[15]  <= char15;
    char[16]  <= char16;
    char[17]  <= char17;
    char[18]  <= char18;
    char[19]  <= char19;
    char[20]  <= char20;
    char[21]  <= char21;
    char[22]  <= char22;
    char[23]  <= char23;
    char[24]  <= char24;
    char[25]  <= char25;
    char[26]  <= char26;
    char[27]  <= char27;
    char[28]  <= char28;
    char[29]  <= char29;
    char[30]  <= char30;
    char[31]  <= char31;
end
always@(posedge pclk or negedge rst_n)
begin
    if(rst_n)
        osd_ram_addr<=0;
	else if(region_active)
		osd_ram_addr <= osd_ram_addr + 13'd1;
   else if(osd_ram_addr>=4096)
        osd_ram_addr<=0;
end


always@(posedge pclk)
begin
	if(region_active == 1'b1&&char[pos_y][8'd128 -1'b1 - pos_x])
		v_data <= 16'h0000;
//    else if(region_active == 1'b1&&rd_data==0)
//       v_data <= 24'h000000;
	else
		v_data <= pos_data;
end

wire   rd_data;
reg [7:0]  wr_addr;
always@(posedge adc_clk or negedge rst_n)
begin
    if(rst_n)
        wr_addr<=0;
    else if(rec_en)
        wr_addr<=wr_addr+1;
    else
        wr_addr<=wr_addr;
end


timing_gen_xy#(.DATA_WIDTH(16)) timing_gen_xy_m1(
	.rst_n    (~rst_n    ),
	.clk      (pclk     ),
	.i_hs     (i_hs     ),
	.i_vs     (i_vs     ),
	.i_de     (i_de     ),
	.i_data   (i_data   ),

	.o_hs     (pos_hs   ),
	.o_vs     (pos_vs   ),
	.o_de     (pos_de   ),
	.o_data   (pos_data ),

	.x        (pos_x    ),
	.y        (pos_y    )
);
endmodule