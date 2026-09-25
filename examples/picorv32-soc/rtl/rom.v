// 组合逻辑 ROM，256 条指令
// 测试程序：无限递增计数器输出到 GPIO
// 0x00: lui   x1, 0x20000   # GPIO_BASE
// 0x04: addi  x2, x0, 0     # counter = 0
// 0x08: addi  x2, x2, 1     # counter++
// 0x0C: sw    x2, 4(x1)     # gpio_out = counter
// 0x10: jal   x0, -8        # 跳回 0x08
module rom (
    input  wire [7:0]  addr,     // 指令地址 pc[9:2]
    output reg  [31:0] rdata
);
    always @(*) begin
        case (addr)
            8'h00:   rdata = 32'h000200B7;  // lui  x1, 0x20000
            8'h01:   rdata = 32'h00000113;  // addi x2, x0, 0
            8'h02:   rdata = 32'h00110113;  // addi x2, x2, 1
            8'h03:   rdata = 32'h0020A223;  // sw   x2, 4(x1)
            8'h04:   rdata = 32'hFF1FF06F;  // jal  x0, -8
            default: rdata = 32'h00000013;  // NOP
        endcase
    end
endmodule
