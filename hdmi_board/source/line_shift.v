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

//?����y?Y�����?������?ram��??����??��
always@(posedge clock)begin
    if(per_frame_href)
        if(clken)
            ram_rd_addr <= ram_rd_addr + 1 ;
        else
            ram_rd_addr <= ram_rd_addr ;
    else
        ram_rd_addr <= 0 ;
end

//����?����1?��D?o??��3����y??
always@(posedge clock) begin
    clken_dly <= { clken_dly[1:0] , clken };
end


//??ram��??��?��3��?t??
always@(posedge clock ) begin
    ram_rd_addr_d0 <= ram_rd_addr;
    ram_rd_addr_d1 <= ram_rd_addr_d0;
end

//��?��?��y?Y?��3����y??
always@(posedge clock)begin
    shiftin_d0 <= shiftin;
    shiftin_d1 <= shiftin_d0;
    shiftin_d2 <= shiftin_d1;
end

blk_mem_gen_0  u_ram_2048x8_0 (
  .wr_data    (shiftin_d2    ), // input [7:0]  ramD�䨺y?Y
  .wr_addr    (ram_rd_addr_d1), // input [4:0]  ramD���??��
  .wr_en      (clken_dly[2]  ), // input        
  .wr_clk     (clock         ), // input
  .wr_rst     (~sys_rst_n    ), // input
  .rd_addr    (ram_rd_addr   ), // input [4:0]  ram?����??��
  .rd_data    (taps0x        ), // output [7:0] ram?����y?Y 
  .rd_clk     (clock         ), // input
  .rd_rst     (~sys_rst_n    )  // input
);

//??��?��?��??�㨰?DD��???��?��y?Y
always@(posedge clock ) begin
    taps0x_d0 <= taps0x;
end

blk_mem_gen_0  u_ram_2048x8_1 (
  .wr_data    (taps0x_d0     ), // input [7:0]  ramD�䨺y?Y
  .wr_addr    (ram_rd_addr_d0), // input [4:0]  ramD���??��
  .wr_en      (clken_dly[1]  ), // input        
  .wr_clk     (clock         ), // input
  .wr_rst     (~sys_rst_n    ), // input
  .rd_addr    (ram_rd_addr   ), // input [4:0]  ram?����??��
  .rd_data    (taps1x        ), // output [7:0] ram?����y?Y 
  .rd_clk     (clock         ), // input
  .rd_rst     (~sys_rst_n    )  // input
);

endmodule 