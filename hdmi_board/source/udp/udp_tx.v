//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com 
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           udp_tx
// Last modified Date:  2020/2/18 9:20:14
// Last Version:        V1.0
// Descriptions:        ��̫�����ݷ���ģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2020/2/18 9:20:14
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module udp_tx
#(
parameter BOARD_MAC = 48'h00_11_22_33_44_55,
   
parameter BOARD_IP  = {8'd192,8'd168,8'd1,8'd123},

parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff,

parameter  DES_IP    = {8'd192,8'd168,8'd1,8'd102}

)
(    
    input                clk        , //ʱ���ź�
    input                rst_n      , //��λ�źţ��͵�ƽ��Ч
    
    input                tx_start_en, //��̫����ʼ�����ź�
    input        [31:0]  tx_data    , //��̫������������ //*synthesis PAP_MARK_DEBUG="1"*/ 
    input        [15:0]  tx_byte_num, //��̫�����͵���Ч�ֽ���
    input        [47:0]  des_mac    , //���͵�Ŀ��MAC��ַ
    input        [31:0]  des_ip     , //���͵�Ŀ��IP��ַ    
    input        [31:0]  crc_data   , //CRCУ������
    input         [7:0]  crc_next   , //CRC�´�У���������
    output  reg          tx_done    , //��̫����������ź�
    output  reg          tx_req     , //�����������ź�
    output  reg          gmii_tx_en , //GMII���������Ч�ź�
    output  reg  [7:0]   gmii_txd   , //GMII�������
    output  reg          crc_en     , //CRC��ʼУ��ʹ��
    output  reg          crc_clr    , //CRC���ݸ�λ�ź� 
    output                tx_data_en,
    output  reg  [127:0] char0      ,
    output  reg  [127:0] char1      ,
    output  reg  [127:0] char2      ,
    output  reg  [127:0] char3      ,
    output  reg  [127:0] char4      ,
    output  reg  [127:0] char5      ,
    output  reg  [127:0] char6      ,
    output  reg  [127:0] char7      ,
    output  reg  [127:0] char8      ,
    output  reg  [127:0] char9      ,
    output  reg  [127:0] char10     ,
    output  reg  [127:0] char11     ,
    output  reg  [127:0] char12     ,
    output  reg  [127:0] char13     ,
    output  reg  [127:0] char14     ,
    output  reg  [127:0] char15     ,
    output  reg  [127:0] char16     ,
    output  reg  [127:0] char17     ,
    output  reg  [127:0] char18     ,
    output  reg  [127:0] char19     ,
    output  reg  [127:0] char20     ,
    output  reg  [127:0] char21     ,
    output  reg  [127:0] char22     ,
    output  reg  [127:0] char23     ,
    output  reg  [127:0] char24     ,
    output  reg  [127:0] char25     ,
    output  reg  [127:0] char26     ,
    output  reg  [127:0] char27     ,
    output  reg  [127:0] char28     ,
    output  reg  [127:0] char29     ,
    output  reg  [127:0] char30     ,
    output  reg  [127:0] char31       //char������ģ
    );



localparam  st_idle      = 7'b000_0001; //��ʼ״̬���ȴ���ʼ�����ź�
localparam  st_check_sum = 7'b000_0010; //IP�ײ�У���
localparam  st_preamble  = 7'b000_0100; //����ǰ����+֡��ʼ�綨��
localparam  st_eth_head  = 7'b000_1000; //������̫��֡ͷ
localparam  st_ip_head   = 7'b001_0000; //����IP�ײ�+UDP�ײ�
localparam  st_tx_data   = 7'b010_0000; //��������
localparam  st_crc       = 7'b100_0000; //����CRCУ��ֵ

localparam  ETH_TYPE     = 16'h0800  ;  //��̫��Э������ IPЭ��
//��̫��������С46���ֽڣ�IP�ײ�20���ֽ�+UDP�ײ�8���ֽ�
//������������46-20-8=18���ֽ�
localparam  MIN_DATA_NUM = 16'd18    ;    

//reg define
reg  [6:0]   cur_state      ;
reg  [6:0]   next_state     ;
                            
reg  [7:0]   preamble[7:0]  ; //ǰ����
reg  [7:0]   eth_head[13:0] ; //��̫���ײ�
reg  [31:0]  ip_head[6:0]   ; //IP�ײ� + UDP�ײ�
                            
reg          start_en_d0    ;
reg          start_en_d1    ;
reg  [15:0]  tx_data_num    ; //���͵���Ч�����ֽڸ���
reg  [15:0]  total_num      ; //���ֽ���
reg          trig_tx_en     ;
reg  [15:0]  udp_num        ; //UDP�ֽ���
reg          skip_en        ; //����״̬��תʹ���ź�
reg  [4:0]   cnt            ;
reg  [31:0]  check_buffer   ; //�ײ�У���
reg  [1:0]   tx_bit_sel     ;
reg  [15:0]  data_cnt       ; //�������ݸ���������
reg          tx_done_t      ;
reg  [4:0]   real_add_cnt   ; //��̫������ʵ�ʶ෢���ֽ���
reg                tx_data_en;
                          
//wire define                       
wire         pos_start_en    ;//��ʼ��������������
wire [15:0]  real_tx_data_num;//ʵ�ʷ��͵��ֽ���(��̫�������ֽ�Ҫ��)
reg  [6:0]   char_cnt        ;
//*****************************************************
//**                    main code
//*****************************************************

assign  pos_start_en = (~start_en_d1) & start_en_d0;
assign  real_tx_data_num = (tx_data_num >= MIN_DATA_NUM) 
                           ? tx_data_num : MIN_DATA_NUM; 
                           
//��tx_start_en��������
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        start_en_d0 <= 1'b0;
        start_en_d1 <= 1'b0;
    end    
    else begin
        start_en_d0 <= tx_start_en;
        start_en_d1 <= start_en_d0;
    end
end 

//�Ĵ�������Ч�ֽ�
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        tx_data_num <= 16'd0;
        total_num <= 16'd0;
        udp_num <= 16'd0;
    end
    else begin
        if(pos_start_en && cur_state==st_idle) begin
            //���ݳ���
            tx_data_num <= tx_byte_num;        
            //IP���ȣ���Ч����+IP�ײ�����            
            total_num <= tx_byte_num + 16'd28;  
            //UDP���ȣ���Ч����+UDP�ײ�����            
            udp_num <= tx_byte_num + 16'd8;               
        end    
    end
end

//���������ź�
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        trig_tx_en <= 1'b0;
    else
        trig_tx_en <= pos_start_en;

end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cur_state <= st_idle;  
    else
        cur_state <= next_state;
end

always @(*) begin
    next_state = st_idle;
    case(cur_state)
        st_idle     : begin                               //�ȴ���������
            if(skip_en)                
                next_state = st_check_sum;
            else
                next_state = st_idle;
        end  
        st_check_sum: begin                               //IP�ײ�У��
            if(skip_en)
                next_state = st_preamble;
            else
                next_state = st_check_sum;    
        end                             
        st_preamble : begin                               //����ǰ����+֡��ʼ�綨��
            if(skip_en)
                next_state = st_eth_head;
            else
                next_state = st_preamble;      
        end
        st_eth_head : begin                               //������̫���ײ�
            if(skip_en)
                next_state = st_ip_head;
            else
                next_state = st_eth_head;      
        end              
        st_ip_head : begin                                //����IP�ײ�+UDP�ײ�               
            if(skip_en)
                next_state = st_tx_data;
            else
                next_state = st_ip_head;      
        end
        st_tx_data : begin                                //��������                  
            if(skip_en)
                next_state = st_crc;
            else
                next_state = st_tx_data;      
        end
        st_crc: begin                                     //����CRCУ��ֵ
            if(skip_en)
                next_state = st_idle;
            else
                next_state = st_crc;      
        end
        default : next_state = st_idle;   
    endcase
end                      

//��������
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        skip_en <= 1'b0; 
        cnt <= 5'd0;
        check_buffer <= 32'd0;
        ip_head[1][31:16] <= 16'd0;
        tx_bit_sel <= 2'b0;
        crc_en <= 1'b0;
        gmii_tx_en <= 1'b0;
        gmii_txd <= 8'd0;
        tx_req <= 1'b0;
        tx_done_t <= 1'b0; 
        data_cnt <= 16'd0;
        real_add_cnt <= 5'd0;
        char_cnt <= 7'd0;
        //��ʼ������    
        //ǰ���� 7��8'h55 + 1��8'hd5
        preamble[0] <= 8'h55;                 
        preamble[1] <= 8'h55;
        preamble[2] <= 8'h55;
        preamble[3] <= 8'h55;
        preamble[4] <= 8'h55;
        preamble[5] <= 8'h55;
        preamble[6] <= 8'h55;
        preamble[7] <= 8'hd5;
        //Ŀ��MAC��ַ
        eth_head[0] <= DES_MAC[47:40];
        eth_head[1] <= DES_MAC[39:32];
        eth_head[2] <= DES_MAC[31:24];
        eth_head[3] <= DES_MAC[23:16];
        eth_head[4] <= DES_MAC[15:8];
        eth_head[5] <= DES_MAC[7:0];
        //ԴMAC��ַ
        eth_head[6] <= BOARD_MAC[47:40];
        eth_head[7] <= BOARD_MAC[39:32];
        eth_head[8] <= BOARD_MAC[31:24];
        eth_head[9] <= BOARD_MAC[23:16];
        eth_head[10] <= BOARD_MAC[15:8];
        eth_head[11] <= BOARD_MAC[7:0];
        //��̫������
        eth_head[12] <= ETH_TYPE[15:8];
        eth_head[13] <= ETH_TYPE[7:0];        
    end
    else begin
        skip_en <= 1'b0;
        tx_req <= 1'b0;
        tx_data_en<=0;
        crc_en <= 1'b0;
        gmii_tx_en <= 1'b0;
        tx_done_t <= 1'b0;
        case(next_state)
            st_idle     : begin
                if(trig_tx_en) begin
                    skip_en <= 1'b1; 
                    //�汾�ţ�4 �ײ����ȣ�5(��λ:32bit,20byte/4=5)
                    ip_head[0] <= {8'h45,8'h00,total_num};   
                    //16λ��ʶ��ÿ�η����ۼ�1      
                    ip_head[1][31:16] <= ip_head[1][31:16] + 1'b1; 
                    //bit[15:13]: 010��ʾ����Ƭ
                    ip_head[1][15:0] <= 16'h4000;    
                    //Э�飺17(udp)                  
                    ip_head[2] <= {8'h40,8'd17,16'h0};   
                    //ԴIP��ַ               
                    ip_head[3] <= BOARD_IP;
                    //Ŀ��IP��ַ    
                    if(des_ip != 32'd0)
                        ip_head[4] <= des_ip;
                    else
                        ip_head[4] <= DES_IP;       
                    //16λԴ�˿ںţ�1234  16λĿ�Ķ˿ںţ�1234                      
                    ip_head[5] <= {16'd1234,16'd1234};  
                    //16λudp���ȣ�16λudpУ���              
                    ip_head[6] <= {udp_num,16'h0000};  
                    //����MAC��ַ
                    if(des_mac != 48'b0) begin
                        //Ŀ��MAC��ַ
                        eth_head[0] <= des_mac[47:40];
                        eth_head[1] <= des_mac[39:32];
                        eth_head[2] <= des_mac[31:24];
                        eth_head[3] <= des_mac[23:16];
                        eth_head[4] <= des_mac[15:8];
                        eth_head[5] <= des_mac[7:0];
                    end
                end    
            end                                                       
            st_check_sum: begin                           //IP�ײ�У��
                cnt <= cnt + 5'd1;
                if(cnt == 5'd0) begin                   
                    check_buffer <= ip_head[0][31:16] + ip_head[0][15:0]
                                    + ip_head[1][31:16] + ip_head[1][15:0]
                                    + ip_head[2][31:16] + ip_head[2][15:0]
                                    + ip_head[3][31:16] + ip_head[3][15:0]
                                    + ip_head[4][31:16] + ip_head[4][15:0];
                end
                else if(cnt == 5'd1)                      //���ܳ��ֽ�λ,�ۼ�һ��
                    check_buffer <= check_buffer[31:16] + check_buffer[15:0];
                else if(cnt == 5'd2) begin                //�����ٴγ��ֽ�λ,�ۼ�һ��
                    check_buffer <= check_buffer[31:16] + check_buffer[15:0];
                end                             
                else if(cnt == 5'd3) begin                //��λȡ�� 
                    skip_en <= 1'b1;
                    cnt <= 5'd0;            
                    ip_head[2][15:0] <= ~check_buffer[15:0];
                end    
            end              
            st_preamble : begin                           //����ǰ����+֡��ʼ�綨��
                gmii_tx_en <= 1'b1;
                gmii_txd <= preamble[cnt];
                if(cnt == 5'd7) begin                        
                    skip_en <= 1'b1;
                    cnt <= 5'd0;    
                end
                else    
                    cnt <= cnt + 5'd1;                     
            end
            st_eth_head : begin                           //������̫���ײ�
                gmii_tx_en <= 1'b1;
                crc_en <= 1'b1;
                gmii_txd <= eth_head[cnt];
                if (cnt == 5'd13) begin
                    skip_en <= 1'b1;
                    cnt <= 5'd0;
                end    
                else    
                    cnt <= cnt + 5'd1;    
            end                    
            st_ip_head  : begin                           //����IP�ײ� + UDP�ײ�
                crc_en <= 1'b1;
                gmii_tx_en <= 1'b1;
                tx_bit_sel <= tx_bit_sel + 2'd1;
                if(tx_bit_sel == 3'd0)
                    gmii_txd <= ip_head[cnt][31:24];
                else if(tx_bit_sel == 3'd1)
                    gmii_txd <= ip_head[cnt][23:16];
                else if(tx_bit_sel == 3'd2) begin
                    gmii_txd <= ip_head[cnt][15:8];
                    if(cnt == 5'd6) begin
                        //��ǰ���������ݣ��ȴ�������Чʱ����
                        tx_req <= 1'b1;                     
                    end
                end 
                else if(tx_bit_sel == 3'd3) begin
                    gmii_txd <= ip_head[cnt][7:0];  
                    if(cnt == 5'd6) begin
                        skip_en <= 1'b1;   
                        cnt <= 5'd0;
                    end    
                    else
                        cnt <= cnt + 5'd1;  
                end        
            end
            st_tx_data  : begin                           //��������
                crc_en <= 1'b1;
                gmii_tx_en <= 1'b1;
                tx_bit_sel <= tx_bit_sel + 3'd1;  
                if(data_cnt < tx_data_num - 16'd1)
                    data_cnt <= data_cnt + 16'd1;                        
                else if(data_cnt == tx_data_num - 16'd1)begin
                    //������͵���Ч��������18���ֽڣ��ں������λ
                    //�����ֵΪ���һ�η��͵���Ч����
                    gmii_txd <= 8'd0;
                    if(data_cnt + real_add_cnt < real_tx_data_num - 16'd1)
                        real_add_cnt <= real_add_cnt + 5'd1;  
                    else begin
                        skip_en <= 1'b1;
                        data_cnt <= 16'd0;
                        real_add_cnt <= 5'd0;
                        tx_bit_sel <= 3'd0;                        
                    end    
                end
                if(tx_bit_sel == 1'b0)
                    gmii_txd <= tx_data[31:24];
                else if(tx_bit_sel == 3'd1)
                    gmii_txd <= tx_data[23:16];                   
                else if(tx_bit_sel == 3'd2) begin
                    gmii_txd <= tx_data[15:8];   
                    if(data_cnt != tx_data_num - 16'd1)
                        tx_req <= 1'b1;  
                end
                else if(tx_bit_sel == 3'd3)   begin
                    gmii_txd <= tx_data[7:0];
                    tx_data_en<=1;
                    case(char_cnt)
                        7'd0   : char0[127:96] <= tx_data;
                        7'd1   : char0[95:64] <= tx_data;
                        7'd2   : char0[63:32] <= tx_data;
                        7'd3   : char0[31:0] <= tx_data;
                        7'd4   : char1[127:96] <= tx_data;
                        7'd5   : char1[95:64] <= tx_data;
                        7'd6   : char1[63:32] <= tx_data;
                        7'd7   : char1[31:0] <= tx_data; 
                        7'd8   : char2[127:96] <= tx_data;
                        7'd9   : char2[95:64] <= tx_data;
                        7'd10  : char2[63:32] <= tx_data;
                        7'd11  : char2[31:0] <= tx_data;
                        7'd12  : char3[127:96] <= tx_data;
                        7'd13  : char3[95:64] <= tx_data;
                        7'd14  : char3[63:32] <= tx_data;
                        7'd15  : char3[31:0] <= tx_data;   
                        7'd16  : char4[127:96] <= tx_data;
                        7'd17  : char4[95:64] <= tx_data;
                        7'd18  : char4[63:32] <= tx_data;
                        7'd19  : char4[31:0] <= tx_data;
                        7'd20  : char5[127:96] <= tx_data;
                        7'd21  : char5[95:64] <= tx_data;
                        7'd22  : char5[63:32] <= tx_data;
                        7'd23  : char5[31:0] <= tx_data; 
                        7'd24  : char6[127:96] <= tx_data;
                        7'd25  : char6[95:64] <= tx_data;
                        7'd26  : char6[63:32] <= tx_data;
                        7'd27  : char6[31:0] <= tx_data;
                        7'd28  : char7[127:96] <= tx_data;
                        7'd29  : char7[95:64] <= tx_data;
                        7'd30  : char7[63:32] <= tx_data;
                        7'd31  : char7[31:0] <= tx_data;  
                        7'd32  : char8[127:96] <= tx_data;
                        7'd33  : char8[95:64] <= tx_data;
                        7'd34  : char8[63:32] <= tx_data;
                        7'd35  : char8[31:0] <= tx_data;
                        7'd36  : char9[127:96] <= tx_data;
                        7'd37  : char9[95:64] <= tx_data;
                        7'd38  : char9[63:32] <= tx_data;
                        7'd39  : char9[31:0] <= tx_data; 
                        7'd40  : char10[127:96] <= tx_data;
                        7'd41  : char10[95:64] <= tx_data;
                        7'd42  : char10[63:32] <= tx_data;
                        7'd43  : char10[31:0] <= tx_data;
                        7'd44  : char11[127:96] <= tx_data;
                        7'd45  : char11[95:64] <= tx_data;
                        7'd46  : char11[63:32] <= tx_data;
                        7'd47  : char11[31:0] <= tx_data;  
                        7'd48  : char12[127:96] <= tx_data;
                        7'd49  : char12[95:64] <= tx_data;
                        7'd50  : char12[63:32] <= tx_data;
                        7'd51  : char12[31:0] <= tx_data;
                        7'd52  : char13[127:96] <= tx_data;
                        7'd53  : char13[95:64] <= tx_data;
                        7'd54  : char13[63:32] <= tx_data;
                        7'd55  : char13[31:0] <= tx_data; 
                        7'd56  : char14[127:96] <= tx_data;
                        7'd57  : char14[95:64] <= tx_data;
                        7'd58  : char14[63:32] <= tx_data;
                        7'd59  : char14[31:0] <= tx_data;
                        7'd60  : char15[127:96] <= tx_data;
                        7'd61  : char15[95:64] <= tx_data;
                        7'd62  : char15[63:32] <= tx_data;
                        7'd63  : char15[31:0] <= tx_data;  
                        7'd64  : char16[127:96] <= tx_data;
                        7'd65  : char16[95:64] <= tx_data;
                        7'd66  : char16[63:32] <= tx_data;
                        7'd67  : char16[31:0] <= tx_data;
                        7'd68  : char17[127:96] <= tx_data;
                        7'd69  : char17[95:64] <= tx_data;
                        7'd70  : char17[63:32] <= tx_data;
                        7'd71  : char17[31:0] <= tx_data; 
                        7'd72  : char18[127:96] <= tx_data;
                        7'd73  : char18[95:64] <= tx_data;
                        7'd74  : char18[63:32] <= tx_data;
                        7'd75  : char18[31:0] <= tx_data;
                        7'd76  : char19[127:96] <= tx_data;
                        7'd77  : char19[95:64] <= tx_data;
                        7'd78  : char19[63:32] <= tx_data;
                        7'd79  : char19[31:0] <= tx_data;  
                        7'd80  : char20[127:96] <= tx_data;
                        7'd81  : char20[95:64] <= tx_data;
                        7'd82  : char20[63:32] <= tx_data;
                        7'd83  : char20[31:0] <= tx_data;
                        7'd84  : char21[127:96] <= tx_data;
                        7'd85  : char21[95:64] <= tx_data;
                        7'd86  : char21[63:32] <= tx_data;
                        7'd87  : char21[31:0] <= tx_data; 
                        7'd88  : char22[127:96] <= tx_data;
                        7'd89  : char22[95:64] <= tx_data;
                        7'd90  : char22[63:32] <= tx_data;
                        7'd91  : char22[31:0] <= tx_data;
                        7'd92  : char23[127:96] <= tx_data;
                        7'd93  : char23[95:64] <= tx_data;
                        7'd94  : char23[63:32] <= tx_data;
                        7'd95  : char23[31:0] <= tx_data;  
                        7'd96  : char24[127:96] <= tx_data;
                        7'd97  : char24[95:64] <= tx_data;
                        7'd98  : char24[63:32] <= tx_data;
                        7'd99  : char24[31:0] <= tx_data;
                        7'd100 : char25[127:96] <= tx_data;
                        7'd101 : char25[95:64] <= tx_data;
                        7'd102 : char25[63:32] <= tx_data;
                        7'd103 : char25[31:0] <= tx_data; 
                        7'd104 : char26[127:96] <= tx_data;
                        7'd105 : char26[95:64] <= tx_data;
                        7'd106 : char26[63:32] <= tx_data;
                        7'd107 : char26[31:0] <= tx_data;
                        7'd108 : char27[127:96] <= tx_data;
                        7'd109 : char27[95:64] <= tx_data;
                        7'd110 : char27[63:32] <= tx_data;
                        7'd111 : char27[31:0] <= tx_data;
                        7'd112 : char28[127:96] <= tx_data;
                        7'd113 : char28[95:64] <= tx_data;
                        7'd114 : char28[63:32] <= tx_data;
                        7'd115 : char28[31:0] <= tx_data;
                        7'd116 : char29[127:96] <= tx_data;
                        7'd117 : char29[95:64] <= tx_data;
                        7'd118 : char29[63:32] <= tx_data;
                        7'd119 : char29[31:0] <= tx_data; 
                        7'd120 : char30[127:96] <= tx_data;
                        7'd121 : char30[95:64] <= tx_data;
                        7'd122 : char30[63:32] <= tx_data;
                        7'd123 : char30[31:0] <= tx_data;
                        7'd124 : char31[127:96] <= tx_data;
                        7'd125 : char31[95:64] <= tx_data;
                        7'd126 : char31[63:32] <= tx_data;
                        7'd127 : char31[31:0] <= tx_data;                           
                    endcase 
                    char_cnt <= char_cnt + 1'b1;
                end                                                                                                
            end  
            st_crc      : begin                          //����CRCУ��ֵ
                gmii_tx_en <= 1'b1;
                tx_bit_sel <= tx_bit_sel + 3'd1;
                if(tx_bit_sel == 3'd0)
                    gmii_txd <= {~crc_next[0], ~crc_next[1], ~crc_next[2],~crc_next[3],
                                 ~crc_next[4], ~crc_next[5], ~crc_next[6],~crc_next[7]};
                else if(tx_bit_sel == 3'd1)
                    gmii_txd <= {~crc_data[16], ~crc_data[17], ~crc_data[18],~crc_data[19],
                                 ~crc_data[20], ~crc_data[21], ~crc_data[22],~crc_data[23]};
                else if(tx_bit_sel == 3'd2) begin
                    gmii_txd <= {~crc_data[8], ~crc_data[9], ~crc_data[10],~crc_data[11],
                                 ~crc_data[12], ~crc_data[13], ~crc_data[14],~crc_data[15]};                              
                end
                else if(tx_bit_sel == 3'd3) begin
                    gmii_txd <= {~crc_data[0], ~crc_data[1], ~crc_data[2],~crc_data[3],
                                 ~crc_data[4], ~crc_data[5], ~crc_data[6],~crc_data[7]};  
                    tx_done_t <= 1'b1;
                    skip_en <= 1'b1;
                end                                                                                                                                            
            end                          
            default :;  
        endcase                                             
    end
end            

//��������źż�crcֵ��λ�ź�
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        tx_done <= 1'b0;
        crc_clr <= 1'b0;
    end
    else begin
        tx_done <= tx_done_t;
        crc_clr <= tx_done_t;
    end
end

endmodule

