module fft_data_gen
(   
    input           wire           clk      ,
    input           wire           rst_n    ,
    input           wire           key_flag ,
    
    input           wire           ad_clk ,
    input           wire   [7:0]   ad_data,
    
    input           wire           o_axi4s_data_tvalid,
    
    output          wire           i_axi4s_cfg_tvalid , 
    output          reg            i_axi4s_data_tlast /*synthesis PAP_MARK_DEBUG="1"*/,
    output          reg    [15:0]  i_axi4s_data_tdata /*synthesis PAP_MARK_DEBUG="1"*/,
    output          reg            i_axi4s_data_tvalid/*synthesis PAP_MARK_DEBUG="1"*/
);

//WR

reg     [ 7:0]      data_in    [255:0]  ;      
reg     [ 8:0]      cnt_256_wr /*synthesis PAP_MARK_DEBUG="1"*/;
reg                 i_axi4s_data_tlast_d1;
wire                i_axi4s_data_tlast_neg;
reg                 o_axi4s_data_tvalid_d1;
wire                o_axi4s_data_tvalid_neg;
reg                 fft_working /*synthesis PAP_MARK_DEBUG="1"*/;

//RD
reg     [ 8:0]      cnt_256_rd/*synthesis PAP_MARK_DEBUG="1"*/;
reg                 rd_valid;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        begin
            i_axi4s_data_tlast_d1  <= 1'b0;
            o_axi4s_data_tvalid_d1 <= 1'b0;
        end
    else 
        begin
            i_axi4s_data_tlast_d1  <= i_axi4s_data_tlast;
            o_axi4s_data_tvalid_d1 <= o_axi4s_data_tvalid;
        end

assign  i_axi4s_data_tlast_neg  = (!i_axi4s_data_tlast  && i_axi4s_data_tlast_d1) ? 1'b1 : 1'b0;
assign  o_axi4s_data_tvalid_neg = (!o_axi4s_data_tvalid && o_axi4s_data_tvalid_d1   ) ? 1'b1 : 1'b0;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        fft_working <= 1'b0;
    else if(o_axi4s_data_tvalid_neg)
        fft_working <= 1'b0;
    else if(cnt_256_wr == 9'd256)
        fft_working <= 1'b1;
    else 
        fft_working <= fft_working;
        
always@(posedge ad_clk or negedge rst_n)
    if(rst_n == 1'b0)
        cnt_256_wr <= 9'd0;
    else if(cnt_256_wr == 9'd256) 
        cnt_256_wr <= 9'd0;
    else if(!fft_working)
        begin
            cnt_256_wr <= cnt_256_wr + 1'b1;
            data_in[cnt_256_wr] <= ad_data;
        end
//RD
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        cnt_256_rd <= 9'd0;
    else if(cnt_256_rd == 9'd256 && !fft_working) 
        cnt_256_rd <= 9'd0;
    else if(fft_working && rd_valid) 
        cnt_256_rd <= cnt_256_rd + 1'b1;
    
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        rd_valid <= 1'b0;
    else if(fft_working && (cnt_256_rd < 9'd255))
        rd_valid <= 1'b1;
    else 
        rd_valid <= 1'b0;
    
always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        i_axi4s_data_tdata <= 16'd0;
    else if(rd_valid == 1'b1)
        i_axi4s_data_tdata <= {8'b0000_0000 , data_in[cnt_256_rd]};
    else
        i_axi4s_data_tdata <= 16'd0;

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        i_axi4s_data_tlast <= 1'b0;
    else if(cnt_256_rd == 9'd255)
        i_axi4s_data_tlast <= 1'b1;
    else 
        i_axi4s_data_tlast <= 1'b0;

assign      i_axi4s_cfg_tvalid  = 1'b0; 

always@(posedge clk or negedge rst_n)
    if(rst_n == 1'b0)
        i_axi4s_data_tvalid <= 1'b0;
    else
        i_axi4s_data_tvalid <= rd_valid;

endmodule
