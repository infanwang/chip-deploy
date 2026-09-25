// GPIO 外设
// 地址 0x2XXXXXXX
// 寄存器：
//   0x00 IN  (RO) 输入电平
//   0x04 OUT (RW) 输出电平
module gpio (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sel,
    input  wire        we,
    input  wire [3:0]  addr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata,
    input  wire [31:0] gpio_in,
    output reg  [31:0] gpio_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gpio_out <= 32'h0;
        end else if (sel && we && addr[3:2] == 2'b01) begin
            gpio_out <= wdata;
        end
    end

    always @(*) begin
        case (addr[3:2])
            2'b00:   rdata = gpio_in;
            2'b01:   rdata = gpio_out;
            default: rdata = 32'h0;
        endcase
    end
endmodule
