module hsst_ad
(
    input           wire            rx_clk,
    input           wire            sys_clk,
    input           wire            rst_n,
    
    input           wire    [31:0]  hsst_align_data,
    input           wire    [ 3:0]  hsst_align_k,
    
    output          wire            ad_clk,         //fifo_rd_clk && ad_data_valid
    output          wire    [7:0]   ad_data
);

wire            fifo_wr_en;
wire            wr_full;

reg             fifo_rd_en;
reg             fifo_rd_en_d1;
reg     [8:0]   rd_cnt;

assign          fifo_wr_en = (hsst_align_k == 4'b0000 && !fifo_rd_en_d1) ? 1'b1 : 1'b0;

always@(posedge sys_clk or negedge rst_n)
    if(!rst_n)
        rd_cnt <= 9'd0;
    else if(fifo_rd_en)
        rd_cnt <= rd_cnt + 1'b1;
    else 
        rd_cnt <= 9'd0;

always@(posedge sys_clk or negedge rst_n)
    if(!rst_n)
        fifo_rd_en <= 1'b0;
    else if(rd_cnt == 9'd255)
        fifo_rd_en <= 1'b0;
    else if(wr_full)
        fifo_rd_en <= 1'b1;
    else 
        fifo_rd_en <= fifo_rd_en;
    
hsst2ad  hsst2ad_inst 
(
  .wr_clk       (rx_clk              ),     // input           
  .wr_rst       (~rst_n              ),     // input          
  .wr_en        (fifo_wr_en          ),     // input            
  .wr_data      (hsst_align_data[7:0]),     // input [7:0]         
  .wr_full      (wr_full             ),     // output        
  .almost_full  (                    ),     // output
  
  .rd_clk       (sys_clk             ),     // input          
  .rd_rst       (~rst_n              ),     // input          
  .rd_en        (fifo_rd_en          ),     // input            
  .rd_data      (ad_data             ),     // output [7:0]      256x8bit   
  .rd_empty     (                    ),     // output      
  .almost_empty (                    )      // output
);

always@(posedge sys_clk or negedge rst_n)
    if(!rst_n)
        fifo_rd_en_d1 <= 1'b0;
    else 
        fifo_rd_en_d1 <= fifo_rd_en;

assign      ad_clk = sys_clk && (fifo_rd_en_d1);

endmodule