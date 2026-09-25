// 简化 UART TX 外设
// 地址 0x3XXXXXXX
// 寄存器：
//   0x00 TX     (WO) 写数据发送（bit0 表示 busy）
//   0x04 STATUS (RO) [0]=busy
// 波特率：固定分频（450 分频，45MHz 下约 100 kbaud）
module uart_tx #(
    parameter DIV = 450
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sel,
    input  wire        we,
    input  wire [3:0]  addr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata,
    output reg         tx
);
    reg [9:0]      shift;      // {stop, data[7:0], start}
    reg [3:0]      bit_cnt;
    reg [15:0]     div_cnt;
    reg            busy;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift   <= 10'h3FF;
            bit_cnt <= 4'd0;
            div_cnt <= 16'd0;
            busy    <= 1'b0;
            tx      <= 1'b1;
        end else if (sel && we && addr[3:2] == 2'b00 && !busy) begin
            shift   <= {1'b1, wdata[7:0], 1'b0};
            bit_cnt <= 4'd10;
            div_cnt <= DIV[15:0];
            busy    <= 1'b1;
            tx      <= 1'b0;             // 起始位立即拉低
        end else if (busy) begin
            if (div_cnt == 16'd0) begin
                shift   <= {1'b1, shift[9:1]};
                tx      <= shift[1];
                bit_cnt <= bit_cnt - 4'd1;
                div_cnt <= DIV[15:0];
                if (bit_cnt == 4'd1) begin
                    busy <= 1'b0;
                    tx   <= 1'b1;
                end
            end else begin
                div_cnt <= div_cnt - 16'd1;
            end
        end
    end

    always @(*) begin
        case (addr[3:2])
            2'b00:   rdata = {31'b0, busy};
            2'b01:   rdata = {31'b0, busy};
            default: rdata = 32'h0;
        endcase
    end
endmodule
