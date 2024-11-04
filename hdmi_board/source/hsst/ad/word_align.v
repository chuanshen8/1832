module word_align
(
    input       wire            rx_clk,
    input       wire            rst_n,
    
    input       wire   [31:0]   hsst_rxd,
    input       wire   [ 3:0]   hsst_rxk,
    
    output      reg    [31:0]   align_rxd,
    output      reg    [ 4:0]   align_rxk
);

reg         [31:0]      hsst_rxd_d1;

reg         [ 4:0]      hsst_rxk_d1;

reg         [ 2:0]      shift_cnt; 

always@(posedge rx_clk or negedge rst_n)
    if(!rst_n)
        begin
            hsst_rxd_d1 <= 32'd0;
            hsst_rxk_d1 <=  4'd0;
        end
    else 
        begin
            hsst_rxd_d1 <= hsst_rxd;
            hsst_rxk_d1 <= hsst_rxk;
        end
        
always@(posedge rx_clk or negedge rst_n)
    if(!rst_n)
        shift_cnt <= 3'd4;
    else if(hsst_rxk == 4'b0001)
        shift_cnt <= 3'd0;
    else if(hsst_rxk == 4'b0010)
        shift_cnt <= 3'd1;
    else if(hsst_rxk == 4'b0100)
        shift_cnt <= 3'd2;  
    else if(hsst_rxk == 4'b1000)
        shift_cnt <= 3'd3;
    else 
        shift_cnt <= shift_cnt;  
        
always@(posedge rx_clk or negedge rst_n)
    if(!rst_n)
        align_rxk <= 4'd1;
    else if(shift_cnt == 3'd0)
        align_rxk <= hsst_rxk;
    else if(shift_cnt == 3'd1)
        align_rxk <= {hsst_rxk[0] , hsst_rxk_d1[3:1]};
    else if(shift_cnt == 3'd2)
        align_rxk <= {hsst_rxk[1:0] , hsst_rxk_d1[3:2]};  
    else if(shift_cnt == 3'd3)
        align_rxk <= {hsst_rxk[2:0] , hsst_rxk_d1[3]};
    else 
        align_rxk <= align_rxk;  
        
always@(posedge rx_clk or negedge rst_n)
    if(!rst_n)
        align_rxd <= 32'd0;
    else if(shift_cnt == 3'd0)
        align_rxd <= hsst_rxd;
    else if(shift_cnt == 3'd1)
        align_rxd <= {hsst_rxd[7:0] , hsst_rxd_d1[31:8]};
    else if(shift_cnt == 3'd2)
        align_rxd <= {hsst_rxd[15:0] , hsst_rxd_d1[31:16]};  
    else if(shift_cnt == 3'd3)
        align_rxd <= {hsst_rxd[23:0] , hsst_rxd_d1[31:24]};
    else 
        align_rxd <= align_rxd;    

endmodule