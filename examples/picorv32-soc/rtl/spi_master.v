// 简化 SPI Master 外设
// 地址 0x4XXXXXXX
// 寄存器：
//   0x00 TX     (WO) 写数据发送
//   0x04 RX     (RO) 接收数据
//   0x08 STATUS (RO) [0]=busy
// SPI 模式：CPOL=0, CPHA=0, MSB first
module spi_master (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sel,
    input  wire        we,
    input  wire [3:0]  addr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata,
    input  wire        miso,
    output reg         mosi,
    output reg         sclk,
    output reg         cs_n
);
    reg [7:0]  tx_data;
    reg [7:0]  rx_data;
    reg [3:0]  bit_cnt;
    reg        busy;
    reg [3:0]  div_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy    <= 1'b0;
            cs_n    <= 1'b1;
            sclk    <= 1'b0;
            mosi    <= 1'b0;
            bit_cnt <= 4'd0;
            div_cnt <= 4'd0;
            tx_data <= 8'h0;
            rx_data <= 8'h0;
        end else if (sel && we && addr[3:2] == 2'b00 && !busy) begin
            tx_data <= wdata[7:0];
            busy    <= 1'b1;
            cs_n    <= 1'b0;
            sclk    <= 1'b0;
            bit_cnt <= 4'd8;
            div_cnt <= 4'd15;
            mosi    <= wdata[7];
        end else if (busy) begin
            if (div_cnt == 4'd0) begin
                if (sclk == 1'b0) begin
                    sclk    <= 1'b1;
                    rx_data <= {rx_data[6:0], miso};
                    tx_data <= {tx_data[6:0], 1'b0};
                    mosi    <= tx_data[6];
                end else begin
                    sclk    <= 1'b0;
                    bit_cnt <= bit_cnt - 4'd1;
                    if (bit_cnt == 4'd1) begin
                        busy <= 1'b0;
                        cs_n <= 1'b1;
                        sclk <= 1'b0;
                    end
                end
                div_cnt <= 4'd15;
            end else begin
                div_cnt <= div_cnt - 4'd1;
            end
        end
    end

    always @(*) begin
        case (addr[3:2])
            2'b00:   rdata = {31'b0, busy};
            2'b01:   rdata = {24'b0, rx_data};
            2'b10:   rdata = {31'b0, busy};
            default: rdata = 32'h0;
        endcase
    end
endmodule
