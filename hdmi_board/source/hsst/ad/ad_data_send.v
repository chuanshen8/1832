module ad_data_send
(
    input           wire            tx_clk,
    input           wire            ad_clk/*synthesis PAP_MARK_DEBUG="1"*/,
    input           wire            rst_n,
    
    input           wire    [ 7:0]  ad_data/*synthesis PAP_MARK_DEBUG="1"*/,
    
    output          reg     [31:0]  hsst_txd/*synthesis PAP_MARK_DEBUG="1"*/,
    output          reg     [ 3:0]  hsst_txk/*synthesis PAP_MARK_DEBUG="1"*/

);

wire            wr_full/*synthesis PAP_MARK_DEBUG="1"*/;
wire    [7:0]   fifo_rd_data;

reg             fifo_wr_en;
reg             fifo_rd_en;
reg     [3:0]   state/*synthesis PAP_MARK_DEBUG="1"*/;
reg     [8:0]   rd_cnt/*synthesis PAP_MARK_DEBUG="1"*/;

ad_data_buf ad_data_buf 
(
  .wr_clk       (ad_clk         ),      // input           
  .wr_rst       (~rst_n         ),      // input          
  .wr_en        (fifo_wr_en     ),      // input            
  .wr_data      (ad_data        ),      // input  [7:0]        
  .wr_full      (wr_full        ),      // output        
  .almost_full  (               ),      // output
  
  .rd_clk       (tx_clk         ),      // input          
  .rd_rst       (~rst_n         ),      // input          
  .rd_en        (fifo_rd_en     ),      // input            
  .rd_data      (fifo_rd_data   ),      // output [7:0]        
  .rd_empty     (               ),      // output      
  .almost_empty (               )       // output
);

always@(posedge tx_clk or negedge rst_n)
    if(!rst_n)
        rd_cnt <= 9'd0;
    else if(fifo_rd_en)
        rd_cnt <= rd_cnt + 1'b1;
    else 
        rd_cnt <= 9'd0;
        
always@(posedge tx_clk or negedge rst_n)
	if(!rst_n)
        begin
            fifo_wr_en   <=  1'b0;
            fifo_rd_en   <=  1'b0;
            state        <=  4'd0;
            hsst_txd     <= 32'd0;
            hsst_txk     <=  4'd0;
        end
    else 
        case(state)
            4'd0 :     //等待fifo存满数据
                begin   
                    if(wr_full)
                        begin
                            fifo_wr_en <= 1'b0;
                            state      <= 4'd1;
                            fifo_rd_en <= 1'b1;           
                            hsst_txd   <= 32'hff_00_01_bc;   //发送一帧开始信号  1
                            hsst_txk   <=  4'b0001;      
                        end
                    else   
                        begin  
                            fifo_wr_en <=  1'b1;
                            state      <=  4'd0;
                            fifo_rd_en <=  1'b0;
                            hsst_txd   <= 32'hff_55_55_bc;  //未存满,发送无用信号
                            hsst_txk   <=  4'b0001;
                        end
                end
            4'd1 :                                          //发送一帧AD数据
                begin
                    if(rd_cnt == 9'd255)
                        begin
                            fifo_wr_en <=  1'b0;
                            fifo_rd_en <= 1'b0;
                            state      <= 4'd2;
                            hsst_txd   <= {24'd0 , fifo_rd_data};   
                            hsst_txk   <= 4'b0000;
                        end
                    else 
                        begin
                            fifo_wr_en <=  1'b0;
                            state      <= 4'd1;
                            hsst_txd   <= {24'd0 , fifo_rd_data};   
                            hsst_txk   <= 4'b0000;
                            fifo_rd_en <= 1'b1;
                        end    
                end
            4'd2 :   
                begin
                    fifo_wr_en <=  1'b0;
                    state      <=  4'd0;
                    hsst_txd   <= 32'hff_00_02_bc;          //发送帧结束信号  2
                    hsst_txk   <=  4'b0001;
                    fifo_rd_en <=  1'b0;
                end  
            default :
                begin
                    fifo_wr_en <=  1'b0;
                    state      <=  4'd0;
                    hsst_txd   <= 32'hff_55_55_bc;   
                    hsst_txk   <=  4'b0001;
                    fifo_rd_en <=  1'b0;
                end  
        endcase

/* always@(posedge tx_clk or negedge rst_n)
	if(!rst_n)
        begin
            fifo_rd_en   <=  1'b0;
            state        <=  4'd0;
            hsst_txd     <= 32'd0;
            hsst_txk     <=  4'd0;
        end
    else 
        case(state)
            4'd0 :      //发送帧开始信号 0
                begin
                    state      <=  4'd1;
                    hsst_txd   <= 32'hff_00_00_bc;
                    hsst_txk   <=  4'b0001;
                    fifo_rd_en <=  1'b0;
                end
            4'd1 :      //发送帧开始信号 1
                begin
                    state    <=  4'd2;
                    hsst_txd <= 32'hff_00_01_bc;
                    hsst_txk <=  4'b0001;
                    fifo_rd_en <=  1'b0;
                end
            4'd2 :     //等待fifo存满数据
                begin   
                    if(wr_full)
                        begin
                            state      <= 4'd3;
                            fifo_rd_en <= 1'b1;           
                            hsst_txd   <= 32'hff_00_02_bc;   //发送一帧开始信号  2
                            hsst_txk   <=  4'b0001;      
                        end
                    else   
                        begin  
                            state      <=  4'd2;
                            fifo_rd_en <=  1'b0;
                            hsst_txd   <= 32'hff_55_55_bc;    //未存满,发送无用信号
                            hsst_txk   <=  4'b0001;
                        end
                end
            4'd3 :     //发送一帧AD数据
                begin
                    if(rd_cnt == 7'd63)
                        begin
                            fifo_rd_en <= 1'b0;
                            state      <= 4'd4;
                            hsst_txd   <= fifo_rd_data;   
                            hsst_txk   <= 4'b0000;
                        end
                    else 
                        begin
                            state      <= 4'd3;
                            hsst_txd   <= fifo_rd_data;   
                            hsst_txk   <= 4'b0000;
                            fifo_rd_en <= 1'b1;
                        end    
                end
            4'd4 :   //发送帧结束信号
                begin
                    state    <=  4'd2;
                    hsst_txd <= 32'hff_00_03_bc;   
                    hsst_txk <=  4'b0001;
                    fifo_rd_en <=  1'b0;
                end  
            default :
                begin
                    state    <=  4'd0;
                    hsst_txd <= 32'hff_00_00_bc;   
                    hsst_txk <=  4'b0001;
                    fifo_rd_en <=  1'b0;
                end  
        endcase */  
        
endmodule