module line_shift_ram_8bit(
    input clk,
    input rst_n,
    input          ycbcr_de,
    input          ycbcr_hs,
    
    input   [7:0]  shiftin,  
    output  [7:0]  rd_data0,   
    output  [7:0]  rd_data1    
);


wire             wr_en0          ;//*synthesis PAP_MARK_DEBUG="1"*/
wire [8  -1:0]   wr_data0        ;//*synthesis PAP_MARK_DEBUG="1"*/
wire            rd_en0          ;//*synthesis PAP_MARK_DEBUG="1"*/
wire[8  -1:0]   rd_data0        ;//*synthesis PAP_MARK_DEBUG="1"*/
wire            almost_full0    ;//*synthesis PAP_MARK_DEBUG="1"*/
wire            almost_full1    ;//*synthesis PAP_MARK_DEBUG="1"*/
wire    full0;//*synthesis PAP_MARK_DEBUG="1"*/
wire    full1;//*synthesis PAP_MARK_DEBUG="1"*/
wire   full1_reg;//*synthesis PAP_MARK_DEBUG="1"*/
wire             wr_en1          ;//*synthesis PAP_MARK_DEBUG="1"*/
wire[8  -1:0]   wr_data1        ;//*synthesis PAP_MARK_DEBUG="1"*/
wire            rd_en1          ;//*synthesis PAP_MARK_DEBUG="1"*/
wire[8  -1:0]   rd_data1        ;//*synthesis PAP_MARK_DEBUG="1"*/

parameter H_ACTIVE=1920;
parameter V_ACTIVE=1080;

reg  [11:0]  v_cnt;//*synthesis PAP_MARK_DEBUG="1"*/
reg  [11:0]  h_cnt;//*synthesis PAP_MARK_DEBUG="1"*/
//显示区域行计数
always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n)
	begin
        h_cnt <= 12'd0;    
    end
    else if(ycbcr_de)
	begin
		if(h_cnt == H_ACTIVE - 1'b1)
			h_cnt <= 12'd0;
		else 
			h_cnt <= h_cnt + 11'd1;
    end
end

//显示区域场计数
always@(posedge clk or negedge rst_n) 
begin
    if(!rst_n)
	begin
        v_cnt <= 12'd0;
    end
    else if(h_cnt == H_ACTIVE - 1'b1)
	begin
		if(v_cnt == V_ACTIVE - 1'b1)
			v_cnt <= 12'd0;
		else 
			v_cnt <= v_cnt + 11'd1;
    end
end

//always @(posedge clk or negedge rst_n) begin
//    if(!rst_n)
//        wr_en0 <= 0;
//    else
//        wr_en0 <= ycbcr_de;
//end
//always @(posedge clk or negedge rst_n) begin
//    if(!rst_n)
//        wr_data0 <= 0;
//    else 
//        wr_data0 <= shiftin;
//end
//
//always @(posedge clk or negedge rst_n) begin
//    if(!rst_n)
//        wr_en1 <= 0;
//    else
//        wr_en1 <= rd_en0;
//end

assign wr_data1 = rd_data0;

assign wr_en0	= (v_cnt < V_ACTIVE - 1) ? ycbcr_de : 1'b0;
assign wr_en1 = rd_en0 && (v_cnt < V_ACTIVE - 2);
assign   wr_data1=rd_data0;
//assign rd_en0 = almost_full0 && wr_en0;
assign rd_en0	= (v_cnt > 0 ) ? ycbcr_de : 1'b0;
//assign rd_en1 = almost_full1 && wr_en1;
assign rd_en1	= (v_cnt > 1 ) ? ycbcr_de : 1'b0;
//wire [7:0] data_out0;
//wire [7:0] data_out1;
//always @(posedge clk or negedge rst_n) begin
//    if(!rst_n) begin
//        rd_data0 <= 0;
//        rd_data1<=0;
//    end
//    else if(rd_en1) begin
//        rd_data0 <= data_out0;
//        rd_data1 <= data_out1;
//    end
//end

fifo_shift          u_fifo_shift0   (
    .clk            (clk            ),
    .rst            (~rst_n         ),
    .wr_en          (wr_en0         ),
    .wr_data        (shiftin       ),
    .wr_full        (    full0           ),
    .almost_full    (almost_full0   ), // set this value to HOR_PIXELS-1
    .rd_en          (rd_en0         ),
    .rd_data        (rd_data0       ),
    .rd_empty       (               ),
    .almost_empty   (               ),
    .rd_water_level(),    // output [11:0]
    .wr_water_level()   // output [11:0]
);


fifo_shift          u_fifo_shift1   (
    .clk            (clk            ),
    .rst            (~rst_n         ),
    .wr_en          (wr_en1         ),
    .wr_data        (wr_data1       ),
    .wr_full        (    full1       ),
    .almost_full    (almost_full1   ), // set this value to HOR_PIXELS-1
    .rd_en          (rd_en1         ),
    .rd_data        (rd_data1       ),
    .rd_empty       (               ),
    .almost_empty   (               ),
    .rd_water_level(),    // output [11:0]
    .wr_water_level()    // output [11:0]
);




endmodule 