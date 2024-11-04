`timescale 1ns/1ps

module fifo_tb();

    reg	  clk;
	reg	[7:0]  rd_data0,rd_data1,shiftin;
	


fifo_shift          u_fifo_shift0   (
    .clk            (clk           ),
    .rst            (           ),
    .wr_en          (1           ),
    .wr_data        (shiftin       ),
    .wr_full        (               ),
    .almost_full    (almost_full0   ), // set this value to HOR_PIXELS-1
    .rd_en          (rd_en0         ),
    .rd_data        (rd_data0       ),
    .rd_empty       (               ),
    .almost_empty   (               )
);
 

//²úÉúÊ±ÖÓ¼¤Àø
assign rd_en0 = almost_full0;
initial begin
    clk =   0;
    shiftin=8'b11111111;
end

always #10 clk = ~clk;
always #10 shiftin = ~shiftin;
endmodule