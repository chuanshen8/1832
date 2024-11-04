module dram_ctrl
(
    input       wire                clk                 ,
    input       wire                rst_n               ,
    input       wire                pix_clk             ,
    input       wire                key_flag            ,
    input       wire                key_flag_2          ,
    output      reg     [ 2:0]      cnt_key             ,
    //fifo_freq_1                                       
    input       wire                fifo_full_freq_1    ,
    input       wire    [15:0]      fifo_rddata_freq_1  ,
    output      reg                 fifo_rden_freq_1    /*synthesis PAP_MARK_DEBUG="1"*/,      
    //fifo_real_1                                       
    input       wire                fifo_full_real_1    ,
    input       wire    [15:0]      fifo_rddata_real_1  ,
    output      reg                 fifo_rden_real_1    /*synthesis PAP_MARK_DEBUG="1"*/,   
    //fifo_freq     
    input       wire                fifo_full_freq      ,    
    input       wire    [15:0]      fifo_rddata_freq    ,    
    output      reg                 fifo_rden_freq      /*synthesis PAP_MARK_DEBUG="1"*/,    
    //fifo_real                                         
    input       wire                fifo_full_real      ,
    input       wire    [15:0]      fifo_rddata_real    ,
    output      reg                 fifo_rden_real      /*synthesis PAP_MARK_DEBUG="1"*/,   
    //vesa                                              
    input       wire     [11:0]     act_y               ,
    input       wire                de_in               ,
    input       wire                vs_in               ,
    input       wire                point_done          ,
    //dram                                              
    output      wire                dram_rd_clk         ,
    output      reg      [10:0]     dram_rd_addr        ,
    output      reg                 dram_wr_en          /*synthesis PAP_MARK_DEBUG="1"*/,      
    output      reg      [10:0]     dram_wr_addr        /*synthesis PAP_MARK_DEBUG="1"*/,    
    output      reg      [15:0]     dram_wr_data  
);

parameter       CNT_MAX = 25_000_000;

reg     [24:0]      cnt ; 
reg                 cnt_flag;

reg     [ 3:0]      state/*synthesis PAP_MARK_DEBUG="1"*/;
reg                 vs_in_d1;
reg                 vs_in_d2;
//
reg                 cnt_add;
reg                 cnt_add_d1;
reg                 cnt_add_2;
reg                 cnt_add_2_d1;

wire                cnt_add_neg;
wire                cnt_add_2_neg;
wire                vs_in_d1_neg;

reg                 cnt_add_neg_pix;
reg                 cnt_add_neg_pix_d1;
reg                 cnt_add_neg_pix_d2;
wire                cnt_add_neg_pix_d1_neg;

reg                 cnt_add_neg_pix_2;
reg                 cnt_add_neg_pix_2_d1;
reg                 cnt_add_neg_pix_2_d2;
wire                cnt_add_neg_pix_d1_2_neg;

always@(posedge clk or negedge rst_n)
    if(!rst_n)
        begin
            vs_in_d1     <= 1'b0;
            vs_in_d2     <= 1'b0;
            cnt_add_d1   <= 1'b0;
            cnt_add_2_d1 <= 1'b0;
        end
    else 
        begin
            vs_in_d1     <= vs_in;
            vs_in_d2     <= vs_in_d1;
            cnt_add_d1   <= cnt_add;
            cnt_add_2_d1 <= cnt_add_2;
        end

assign vs_in_d1_neg = (!vs_in_d1 && vs_in_d2)   ? 1'b1 : 1'b0;

assign  cnt_add_neg   = (!cnt_add   && cnt_add_d1  ) ? 1'b1 : 1'b0;
assign  cnt_add_2_neg = (!cnt_add_2 && cnt_add_2_d1) ? 1'b1 : 1'b0;
      
always@(posedge pix_clk or negedge rst_n)
    if(!rst_n)  
        begin
            cnt_add_neg_pix    <= 1'b0;
            cnt_add_neg_pix_d1 <= 1'b0;
            cnt_add_neg_pix_d2 <= 1'b0;
        end
    else 
        begin   
            cnt_add_neg_pix    <= cnt_add_neg;
            cnt_add_neg_pix_d1 <= cnt_add_neg_pix;
            cnt_add_neg_pix_d2 <= cnt_add_neg_pix_d1;
        end
   
always@(posedge pix_clk or negedge rst_n)
    if(!rst_n)  
        begin
            cnt_add_neg_pix_2    <= 1'b0;
            cnt_add_neg_pix_2_d1 <= 1'b0;
            cnt_add_neg_pix_2_d2 <= 1'b0;
        end
    else 
        begin   
            cnt_add_neg_pix_2    <= cnt_add_2_neg;
            cnt_add_neg_pix_2_d1 <= cnt_add_neg_pix_2;
            cnt_add_neg_pix_2_d2 <= cnt_add_neg_pix_2_d1;
        end

assign  cnt_add_neg_pix_d1_neg = (!cnt_add_neg_pix_d1 && cnt_add_neg_pix_d2) ? 1'b1 : 1'b0;

assign  cnt_add_neg_pix_d1_2_neg = (!cnt_add_neg_pix_2_d1 && cnt_add_neg_pix_2_d2) ? 1'b1 : 1'b0;
//
always@(posedge clk or negedge rst_n)
    if(!rst_n)
        cnt_add <= 1'b0;
    else if(vs_in_d1_neg)
        cnt_add <= 1'b0;
    else if(key_flag)
        cnt_add <= 1'b1;
    else 
        cnt_add <= cnt_add;
        
always@(posedge clk or negedge rst_n)
    if(!rst_n)
        cnt_add_2 <= 1'b0;
    else if(vs_in_d1_neg)
        cnt_add_2 <= 1'b0;
    else if(key_flag_2)
        cnt_add_2 <= 1'b1;
    else 
        cnt_add_2 <= cnt_add_2;
        
always@(posedge clk or negedge rst_n)
    if(!rst_n)
        cnt_key <= 3'd0;
    else 
        case(cnt_key)
            3'd0 : 
                begin
                    if(cnt_add_neg)
                        cnt_key <= 3'd1;
                    else if(cnt_add_2_neg)
                        cnt_key <= 3'd2;
                end
            3'd1 : 
                begin
                    if(cnt_add_neg)
                        cnt_key <= 3'd0;
                    else if(cnt_add_2_neg)
                        cnt_key <= 3'd2;
                end
            3'd2 : 
                begin
                    if(cnt_add_neg)
                        cnt_key <= 3'd0;
                    else if(cnt_add_2_neg)
                        cnt_key <= 3'd3;
                end
            3'd3 : 
                begin
                    if(cnt_add_neg)
                        cnt_key <= 3'd0;
                    else if(cnt_add_2_neg)
                        cnt_key <= 3'd2;
                end
            default :
                cnt_key <= 3'd0;
        endcase
        
always@(posedge clk or negedge rst_n)
    if(!rst_n)
        cnt <= 25'd0;
    else if(cnt_flag)
        cnt <= 25'd0;
    else if(cnt < CNT_MAX)
        cnt <= cnt + 1'b1;
     else 
        cnt <= cnt;

always@(posedge clk or negedge rst_n)
    if(!rst_n)
        begin
            state            <=  4'd0;
            fifo_rden_freq_1 <=  1'b0;
            fifo_rden_real_1 <=  1'b0;
            fifo_rden_freq   <=  1'b0;
            fifo_rden_real   <=  1'b0;
            dram_wr_en       <=  1'b0;
            dram_wr_addr     <= 11'd0;
            dram_wr_data     <= 16'd0;
            cnt_flag         <=  1'b0;
        end
    else
        case(state)
            4'd0 :                   //等待hsst_fft_fifo写满
                if(fifo_full_freq_1 == 1'b1)
                    begin
                        state            <= 4'd1;
                        fifo_rden_freq_1 <= 1'b1;
                    end
                else 
                    state <= state;
            4'd1 :    
                state <=  4'd2;
            4'd2 :   //hsst_fft_fifo存储在 1-256
                begin
                    if(dram_wr_addr == 11'd256)  
                        begin
                            state        <= 4'd3;
                            dram_wr_en   <= 1'b0;
                            dram_wr_data <= 16'd0; 
                            dram_wr_addr <= 11'd256;
                        end
                    else if(dram_wr_addr == 11'd254)
                        begin
                            state            <= state;
                            fifo_rden_freq_1 <= 1'b0;
                            dram_wr_data     <= fifo_rddata_freq_1;
                            dram_wr_addr     <= dram_wr_addr + 1'b1;
                        end
                    else 
                        begin
                            state        <= state;
                            dram_wr_en   <= 1'b1;
                            dram_wr_data <= fifo_rddata_freq_1; 
                            dram_wr_addr <= dram_wr_addr + 1'b1;
                        end
                end
            4'd3 :                   //等待ad_fft_fifo写满
                if(fifo_full_freq == 1'b1)
                    begin
                        state          <= 4'd4;
                        fifo_rden_freq <= 1'b1;
                    end
                else 
                    state <= state;
            4'd4 :    
                state <=  4'd5;
            4'd5 :   //ad_fft_fifo存储在 257-512    
                begin
                    if(dram_wr_addr == 11'd512 && cnt == CNT_MAX)
                        begin
                            state        <= 4'd6;
                            cnt_flag     <= 1'b1;
                            dram_wr_en   <= 1'b0;
                            dram_wr_data <= 16'd0; 
                            dram_wr_addr <= 11'd512;
                        end
                    else if(dram_wr_addr == 11'd512)  
                        begin
                            state        <= 4'd0;
                            dram_wr_en   <= 1'b0;
                            dram_wr_data <= 16'd0; 
                            dram_wr_addr <= 11'd0;
                        end
                    else if(dram_wr_addr == 11'd510)
                        begin
                            state          <=  state;
                            fifo_rden_freq <=  1'b0;
                            dram_wr_data   <= fifo_rddata_freq;
                            dram_wr_addr   <= dram_wr_addr + 1'b1;
                        end
                    else 
                        begin
                            state        <= state;
                            dram_wr_en   <= 1'b1;
                            dram_wr_data <= fifo_rddata_freq; 
                            dram_wr_addr <= dram_wr_addr + 1'b1;
                        end
                end   
            4'd6 :      //等待hsst_real_fifo写满
                begin
                    cnt_flag <= 1'b0;
                    if(fifo_full_real_1 == 1'b1)
                        begin
                            state            <= 4'd7;
                            fifo_rden_real_1 <= 1'b1;
                        end
                    else
                        state <= state;
                end
            4'd7 :
                state <= 4'd8;
            4'd8 :      //hsst_real_fifo存储在 513-768
                begin
                    if(dram_wr_addr == 11'd768)  
                        begin
                            state        <= 4'd9;
                            dram_wr_en   <= 1'b0;
                            dram_wr_data <= 16'd0; 
                            dram_wr_addr <= 11'd768;
                        end
                    else if(dram_wr_addr == 11'd766)
                        begin
                            state            <=  state;
                            fifo_rden_real_1 <=  1'b0;
                            dram_wr_data     <= fifo_rddata_real_1; 
                            dram_wr_addr     <= dram_wr_addr + 1'b1;
                        end
                    else 
                        begin
                            state        <= state;
                            dram_wr_en   <= 1'b1;
                            dram_wr_data <= fifo_rddata_real_1; 
                            dram_wr_addr <= dram_wr_addr + 1'b1;
                        end
                end
            4'd9 :      //等待ad_real_fifo写满
                begin
                    if(fifo_full_real == 1'b1)
                        begin
                            state          <= 4'd10;
                            fifo_rden_real <= 1'b1;
                        end
                    else
                        state <= state;
                end
            4'd10 :
                state <= 4'd11;
            4'd11 :      //ad_real_fifo存储在 769-1024
                begin
                    if(dram_wr_addr == 11'd1024)  
                        begin
                            state        <= 4'd0;
                            dram_wr_en   <= 1'b0;
                            dram_wr_data <= 16'd0; 
                            dram_wr_addr <= 11'd0;
                        end
                    else if(dram_wr_addr == 11'd1022)
                        begin
                            state          <=  state;
                            fifo_rden_real <=  1'b0;
                            dram_wr_data   <= fifo_rddata_real;
                            dram_wr_addr   <= dram_wr_addr + 1'b1;
                        end
                    else 
                        begin
                            state        <= state;
                            dram_wr_en   <= 1'b1;
                            dram_wr_data <= fifo_rddata_real; 
                            dram_wr_addr <= dram_wr_addr + 1'b1;
                        end
                end
            default :   state <= 4'd0;
        endcase
        
assign  dram_rd_clk = (de_in == 1'b1) ? pix_clk : 1'b0;

always@(posedge pix_clk or negedge rst_n)
    if(!rst_n)  
        dram_rd_addr <= 11'd0;
    else if(cnt_key == 3'd0)       //1-256 HSST频域 ; 513-768 HSST时域
        begin    
            if(cnt_add_neg_pix_d1_neg)
                dram_rd_addr <= 11'd1;
            else if((dram_rd_addr == 11'd768) && (point_done == 1'b1) && (act_y == 12'd719))
                dram_rd_addr <= 11'd1;
            else if((dram_rd_addr == 11'd768) && (point_done == 1'b1) && (act_y >  12'd359))
                dram_rd_addr <= 11'd513;   
            else if((dram_rd_addr == 11'd256) && (point_done == 1'b1) && (act_y == 12'd359))
                dram_rd_addr <= 11'd513;
            else if((dram_rd_addr == 11'd256) && (point_done == 1'b1) && (act_y <  12'd359))
                dram_rd_addr <= 11'd1;
            else if((de_in == 1'b1) && (point_done == 1'b1))
                dram_rd_addr <= dram_rd_addr + 1'b1;
        end
    else if(cnt_key == 3'd1)      //257-512 AD频域 ; 769-1024 AD时域
        begin     
            if(cnt_add_neg_pix_d1_neg)
                dram_rd_addr <= 11'd257;
            else if((dram_rd_addr == 11'd1024) && (point_done == 1'b1) && (act_y == 12'd719))
                dram_rd_addr <= 11'd257;
            else if((dram_rd_addr == 11'd1024) && (point_done == 1'b1) && (act_y > 12'd359))
                dram_rd_addr <= 11'd769;   
            else if((dram_rd_addr == 11'd512) && (point_done == 1'b1) && (act_y == 12'd359))
                dram_rd_addr <= 11'd769;
            else if((dram_rd_addr == 11'd512) && (point_done == 1'b1) && (act_y <  12'd359))
                dram_rd_addr <= 11'd257;
            else if((de_in == 1'b1) && (point_done == 1'b1))
                dram_rd_addr <= dram_rd_addr + 1'b1;
        end  
    else if(cnt_key == 3'd2)     //513-768 HSST时域上半 ; 769-1024 AD时域下半
        begin     
            if(cnt_add_neg_pix_d1_2_neg)
                dram_rd_addr <= 11'd513;
            else if((dram_rd_addr == 11'd1024) && (point_done == 1'b1) && (act_y == 12'd719))
                dram_rd_addr <= 11'd513;
            else if((dram_rd_addr == 11'd1024) && (point_done == 1'b1) && (act_y > 12'd359))
                dram_rd_addr <= 11'd769;   
            else if((dram_rd_addr == 11'd768) && (point_done == 1'b1) && (act_y == 12'd359))
                dram_rd_addr <= 11'd769;
            else if((dram_rd_addr == 11'd768) && (point_done == 1'b1) && (act_y <  12'd359))
                dram_rd_addr <= 11'd513;
            else if((de_in == 1'b1) && (point_done == 1'b1))
                dram_rd_addr <= dram_rd_addr + 1'b1;
        end  
    else if(cnt_key == 3'd3)     //1-256 HSST频域上半 ; 257-512 AD频域下半
        begin     
            if(cnt_add_neg_pix_d1_2_neg)
                dram_rd_addr <= 11'd1;
            else if((dram_rd_addr == 11'd512) && (point_done == 1'b1) && (act_y == 12'd719))
                dram_rd_addr <= 11'd1;
            else if((dram_rd_addr == 11'd512) && (point_done == 1'b1) && (act_y > 12'd359))
                dram_rd_addr <= 11'd257;   
            else if((dram_rd_addr == 11'd256) && (point_done == 1'b1) && (act_y == 12'd359))
                dram_rd_addr <= 11'd257;
            else if((dram_rd_addr == 11'd256) && (point_done == 1'b1) && (act_y <  12'd359))
                dram_rd_addr <= 11'd1;
            else if((de_in == 1'b1) && (point_done == 1'b1))
                dram_rd_addr <= dram_rd_addr + 1'b1;
        end       
        
 endmodule 