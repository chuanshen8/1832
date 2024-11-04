module read_asyn_fifo(
   input     wire               clk      ,
   input     wire               rstn     ,
   
   input     wire [7:0]         fifo_waterlevel , 
   input     wire [127:0]        rd_data         ,
   output    reg                 rd_en           , 
   output    reg                 rd_done       , 
   output    reg  [127:0]      char0         ,
   output    reg  [127:0]      char1         ,
   output    reg  [127:0]      char2         ,
   output    reg  [127:0]      char3         ,
   output    reg  [127:0]      char4         ,
   output    reg  [127:0]      char5         ,
   output    reg  [127:0]      char6         ,
   output    reg  [127:0]      char7         ,
   output    reg  [127:0]      char8         ,
   output    reg  [127:0]      char9         ,
   output    reg  [127:0]      char10        ,
   output    reg  [127:0]      char11        ,
   output    reg  [127:0]      char12        ,
   output    reg  [127:0]      char13        ,
   output    reg  [127:0]      char14        ,
   output    reg  [127:0]      char15        ,
   output    reg  [127:0]      char16        ,
   output    reg  [127:0]      char17        ,
   output    reg  [127:0]      char18        ,
   output    reg  [127:0]      char19        ,
   output    reg  [127:0]      char20        ,
   output    reg  [127:0]      char21        ,
   output    reg  [127:0]      char22        ,
   output    reg  [127:0]      char23        ,
   output    reg  [127:0]      char24        ,
   output    reg  [127:0]      char25        ,
   output    reg  [127:0]      char26        ,
   output    reg  [127:0]      char27        ,
   output    reg  [127:0]      char28        ,
   output    reg  [127:0]      char29        ,
   output    reg  [127:0]      char30        ,
   output    reg  [127:0]      char31       

   );
reg [5:0]   rd_cnt  ;


always @(posedge clk or negedge rstn) begin
   if(rstn == 'd0)begin
      rd_cnt <= 'd0 ;

   end
   else if(rd_en == 'd1 && rd_cnt == 'd32)begin
      rd_cnt <= 'd0 ;
   end
   else if(rd_en == 'd1)
      rd_cnt <= rd_cnt + 'd1 ;   
end

always @(posedge clk or negedge rstn) begin
   if(rstn == 'd0)
      rd_done <= 'd0 ;
   else if(rd_cnt == 'd32)
      rd_done <= 'd1 ;
   else
      rd_done <= 'd0 ;
end



   always @(posedge clk or negedge rstn) begin
      if(rstn == 'd0)
         rd_en <= 'd0 ;
      else if(fifo_waterlevel >= 'd32)
         rd_en <= 'd1  ;
      else if(rd_cnt == 'd32)
         rd_en <= 'd0  ;
      else 
         rd_en <= rd_en  ;
   end

   always @(posedge clk or negedge rstn) begin
      if(rstn == 'd0)begin
         char0     <=  'd0;
         char1     <=  'd0;
         char2     <=  'd0;
         char3     <=  'd0;
         char4     <=  'd0;
         char5     <=  'd0;
         char6     <=  'd0;
         char7     <=  'd0;
         char8     <=  'd0;
         char9     <=  'd0;
         char10    <=  'd0;
         char11    <=  'd0;
         char12    <=  'd0;
         char13    <=  'd0;
         char14    <=  'd0;
         char15    <=  'd0;
         char16    <=  'd0;
         char17    <=  'd0;
         char18    <=  'd0;
         char19    <=  'd0;
         char20    <=  'd0;
         char21    <=  'd0;
         char22    <=  'd0;
         char23    <=  'd0;
         char24    <=  'd0;
         char25    <=  'd0;
         char26    <=  'd0;
         char27    <=  'd0;
         char28    <=  'd0;
         char29    <=  'd0;
         char30    <=  'd0;
         char31    <=  'd0;
      end
   else begin
      case (rd_cnt)
      'd1   : char0   <= {rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd2   : char1   <=  {rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd3   : char2   <=  {rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd4   : char3   <=  {rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd5   : char4    <= {rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd6   : char5    <= {rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd7   : char6    <= {rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd8   : char7    <= {rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd9   : char8    <= {rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd10  : char9   <=  {rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd11  : char10    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd12  : char11    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd13  : char12    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd14  : char13    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd15  : char14    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd16  : char15    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd17  : char16    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd18  : char17    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd19  : char18    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd20  : char19    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd21  : char20    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd22  : char21    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd23  : char22    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd24  : char23    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd25  : char24    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd26  : char25    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd27  : char26    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd28  : char27    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd29  : char28    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd30  : char29    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd31  : char30    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
      'd32  : char31    <={rd_data[31:0],rd_data[63:32],rd_data[95:64],rd_data[127:96]};
                      
      endcase
   end
   end
endmodule