module line_shift(
     input        clock         ,  
    input        sys_rst_n     , 
    input        clken         ,
    input        per_frame_href,
    
    input  [7:0] shiftin       ,  
    output [7:0] taps0x        ,   
    output [7:0] taps1x    
);

//reg define
reg  [ 2:0]  clken_dly     ;
reg  [10:0]  ram_rd_addr   ;
reg  [10:0]  ram_rd_addr_d0;
reg  [10:0]  ram_rd_addr_d1;
reg  [ 7:0]  shiftin_d0    ;
reg  [ 7:0]  shiftin_d1    ;
reg  [ 7:0]  shiftin_d2    ;
reg  [ 7:0]  taps0x_d0     ;

//*****************************************************
//**                    main code
//*****************************************************

//?迆那y?Y角∩米?那㊣㏒?ram米??﹞角??車
always@(posedge clock)begin
    if(per_frame_href)
        if(clken)
            ram_rd_addr <= ram_rd_addr + 1 ;
        else
            ram_rd_addr <= ram_rd_addr ;
    else
        ram_rd_addr <= 0 ;
end

//那㊣?車那1?邦D?o??車3迄豕y??
always@(posedge clock) begin
    clken_dly <= { clken_dly[1:0] , clken };
end


//??ram米??﹞?車3迄?t??
always@(posedge clock ) begin
    ram_rd_addr_d0 <= ram_rd_addr;
    ram_rd_addr_d1 <= ram_rd_addr_d0;
end

//那?豕?那y?Y?車3迄豕y??
always@(posedge clock)begin
    shiftin_d0 <= shiftin;
    shiftin_d1 <= shiftin_d0;
    shiftin_d2 <= shiftin_d1;
end

blk_mem_gen_0  u_ram_2048x8_0 (
  .wr_data    (shiftin_d2    ), // input [7:0]  ramD∩那y?Y
  .wr_addr    (ram_rd_addr_d1), // input [4:0]  ramD∩米??﹞
  .wr_en      (clken_dly[2]  ), // input        
  .wr_clk     (clock         ), // input
  .wr_rst     (~sys_rst_n    ), // input
  .rd_addr    (ram_rd_addr   ), // input [4:0]  ram?芍米??﹞
  .rd_data    (taps0x        ), // output [7:0] ram?芍那y?Y 
  .rd_clk     (clock         ), // input
  .rd_rst     (~sys_rst_n    )  // input
);

//??∩?辰?∩??～辰?DD赤???米?那y?Y
always@(posedge clock ) begin
    taps0x_d0 <= taps0x;
end

blk_mem_gen_0  u_ram_2048x8_1 (
  .wr_data    (taps0x_d0     ), // input [7:0]  ramD∩那y?Y
  .wr_addr    (ram_rd_addr_d0), // input [4:0]  ramD∩米??﹞
  .wr_en      (clken_dly[1]  ), // input        
  .wr_clk     (clock         ), // input
  .wr_rst     (~sys_rst_n    ), // input
  .rd_addr    (ram_rd_addr   ), // input [4:0]  ram?芍米??﹞
  .rd_data    (taps1x        ), // output [7:0] ram?芍那y?Y 
  .rd_clk     (clock         ), // input
  .rd_rst     (~sys_rst_n    )  // input
);

endmodule 