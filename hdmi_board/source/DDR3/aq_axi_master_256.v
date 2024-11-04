module aq_axi_master_256 #(
parameter DATA_WIDTH=256
)(
  // Reset, Clock
  input                         ARESETN,
  input                         ACLK,
  // Master Write Address
  output [0:0]                  M_AXI_AWID,
  output [31:0]                 M_AXI_AWADDR,
  output [7:0]                  M_AXI_AWLEN,    // Burst Length: 0-255
  output                        M_AXI_AWVALID,
  input                         M_AXI_AWREADY,
  // Master Write Data
  output [DATA_WIDTH-1:0]       M_AXI_WDATA,
  output [DATA_WIDTH/8-1:0]     M_AXI_WSTRB,
  output                        M_AXI_WLAST,
  input                         M_AXI_WREADY,

  // Master Read Address
  output [0:0]                  M_AXI_ARID,
  output [31:0]                 M_AXI_ARADDR,
  output [7:0]                  M_AXI_ARLEN,
   
  output                        M_AXI_ARVALID,
  input                         M_AXI_ARREADY,
                     
  // Master Read Data 
  input [0:0]                   M_AXI_RID,
  input [DATA_WIDTH-1:0]        M_AXI_RDATA,//
  input                         M_AXI_RLAST,
  input                         M_AXI_RVALID,
                
        
  // Local Bus
  input                         MASTER_RST,
  input                         WR_START,
  input [31:0]                  WR_ADRS,
  input [31:0]                  WR_LEN, 
  output                        WR_FIFO_RE,
  input [DATA_WIDTH-1:0]        WR_FIFO_DATA,
  output                        WR_DONE,

  input                         RD_START,
  input [31:0]                  RD_ADRS,
  input [31:0]                  RD_LEN, 
  output                        RD_FIFO_WE,
  output [DATA_WIDTH-1:0]       RD_FIFO_DATA,
  output                        RD_DONE


);

  localparam S_WR_IDLE  = 3'd0;
  localparam S_WA_WAIT  = 3'd1;
  localparam S_WA_START = 3'd2;
  localparam S_WD_WAIT  = 3'd3;
  localparam S_WD_PROC  = 3'd4;
  localparam S_WR_WAIT  = 3'd5;
  localparam S_WR_DONE  = 3'd6;
  
  reg [2:0]       wr_state;
  reg [31:0]      reg_wr_adrs;
  reg [31:0]      reg_wr_len;
  reg             reg_awvalid;
  reg             reg_wvalid;
  reg [7:0]       reg_w_len;
  reg [7:0]       reg_w_stb;
  reg             rd_first_data;
  reg             rd_fifo_enable;
  reg[31:0]       rd_fifo_cnt;



assign WR_DONE = (wr_state == S_WR_DONE);
assign WR_FIFO_RE         = rd_first_data | ( M_AXI_WREADY & rd_fifo_enable);  //写fifo的读使能

always @(posedge ACLK or negedge ARESETN)
begin
	if(!ARESETN)
		rd_fifo_cnt <= 32'd0;
	else if(WR_FIFO_RE)     //计数一次突发中读的数据个数
		rd_fifo_cnt <= rd_fifo_cnt + 32'd1;
	else if(wr_state == S_WR_IDLE)
		rd_fifo_cnt <= 32'd0;	
end

always @(posedge ACLK or negedge ARESETN)
begin
	if(!ARESETN)
		rd_fifo_enable <= 1'b0;
	else if(wr_state == S_WR_IDLE && WR_START)
		rd_fifo_enable <= 1'b1;
	else if(WR_FIFO_RE && (rd_fifo_cnt == RD_LEN[31:5] - 32'd1) )//为了fifo的读使能的周期正确
		rd_fifo_enable <= 1'b0;		
end
  // Write State
  always @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) begin
      wr_state            <= S_WR_IDLE;
      reg_wr_adrs[31:0]   <= 32'd0;
      reg_wr_len[31:0]    <= 32'd0;
      reg_awvalid         <= 1'b0;
      reg_w_len[7:0]      <= 8'd0;
	    rd_first_data       <= 1'b0;
  end else begin
    if(MASTER_RST) begin
      wr_state <= S_WR_IDLE;
    end else begin
      case(wr_state)
        S_WR_IDLE: begin
          if(WR_START) begin     //就是突发请求来的时候
            wr_state            <= S_WA_WAIT;
            reg_wr_adrs[31:0]   <= WR_ADRS[31:0];
            reg_wr_len[31:0]    <= WR_LEN[31:0] -32'd1;
			      rd_first_data       <= 1'b1;
          end
            reg_awvalid         <= 1'b0;
            reg_w_len[7:0]      <= 8'd0;
            reg_w_stb[7:0]      <= 8'd0;
        end
        S_WA_WAIT: begin
            wr_state            <= S_WA_START;
		        rd_first_data       <= 1'b0;
        end
        S_WA_START: begin
            wr_state             <= S_WD_WAIT;
            reg_awvalid          <= 1'b1;
            reg_w_len[7:0]       <= reg_wr_len[10:5];//5

        end
        S_WD_WAIT: begin
          if(M_AXI_AWREADY) begin
            wr_state        <= S_WD_PROC;
            reg_awvalid     <= 1'b0;
          end
        end
        S_WD_PROC: begin
          if(M_AXI_WREADY) begin
            if(reg_w_len[7:0] == 8'd0) begin
              wr_state        <= S_WR_WAIT;
            end else begin
              reg_w_len[7:0]  <= reg_w_len[7:0] -8'd1;
            end
          end
        end
        S_WR_WAIT: begin
              wr_state        <= S_WR_DONE;
        end
        S_WR_DONE: begin
            wr_state <= S_WR_IDLE;
          end
        
        default: begin
          wr_state <= S_WR_IDLE;
        end
      endcase

      end
    end
  end
   
  assign M_AXI_AWID         = 1'b0;
  assign M_AXI_AWADDR[31:0] = reg_wr_adrs[31:0];
  assign M_AXI_AWLEN[7:0]   = reg_w_len[7:0];
  assign M_AXI_AWVALID      = reg_awvalid;
  assign M_AXI_WDATA        = WR_FIFO_DATA;
  assign M_AXI_WSTRB        = 32'hffffffff;
  assign M_AXI_WLAST        = (reg_w_len[7:0] == 8'd0)?1'b1:1'b0;
  assign M_AXI_WUSER        = 1;








  localparam S_RD_IDLE  = 3'd0;
  localparam S_RA_WAIT  = 3'd1;
  localparam S_RA_START = 3'd2;
  localparam S_RD_WAIT  = 3'd3;
  localparam S_RD_PROC  = 3'd4;
  localparam S_RD_DONE  = 3'd5;

  
  reg [2:0]   rd_state;
  reg [31:0]  reg_rd_adrs;
  reg [31:0]  reg_rd_len;
  reg         reg_arvalid;
  reg [7:0]   reg_r_len;
 assign RD_DONE = (rd_state == S_RD_DONE) ; 
  // Read State
  always @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) begin
      rd_state          <= S_RD_IDLE;
      reg_rd_adrs[31:0] <= 32'd0;
      reg_rd_len[31:0]  <= 32'd0;
      reg_arvalid       <= 1'b0;
      reg_r_len[7:0]    <= 8'd0;
    end else begin
      case(rd_state)
        S_RD_IDLE: begin
          if(RD_START) begin
            rd_state          <= S_RA_WAIT;
            reg_rd_adrs[31:0] <= RD_ADRS[31:0];
            reg_rd_len[31:0]  <= RD_LEN[31:0] -32'd1;
          end
          reg_arvalid     <= 1'b0;
          reg_r_len[7:0]  <= 8'd0;
        end
        S_RA_WAIT: begin
            rd_state          <= S_RA_START;
        end
        S_RA_START: begin
          rd_state          <= S_RD_WAIT;
          reg_arvalid       <= 1'b1;
          reg_r_len[7:0]    <= reg_rd_len[10:5];

        end
        S_RD_WAIT: begin
          if(M_AXI_ARREADY) begin
            rd_state        <= S_RD_PROC;
            reg_arvalid     <= 1'b0;
          end
        end
        S_RD_PROC: begin
          if(M_AXI_RVALID) begin
            if(M_AXI_RLAST) begin
                rd_state          <= S_RD_DONE;
            end 
          end
        end
		    S_RD_DONE:begin
			      rd_state          <= S_RD_IDLE;
		end
	  endcase
    end
  end
   
  // Master Read Address
  assign M_AXI_ARID         = 1'b0;
  assign M_AXI_ARADDR[31:0] = reg_rd_adrs[31:0];
  assign M_AXI_ARLEN[7:0]   = reg_r_len[7:0];
  assign M_AXI_ARVALID      = reg_arvalid;
  assign RD_FIFO_WE         = M_AXI_RVALID;
  assign RD_FIFO_DATA       = M_AXI_RDATA;


endmodule

