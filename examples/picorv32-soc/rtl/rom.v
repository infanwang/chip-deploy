// RISC-V 程序：循环发送 'A'..'`' 到 UART
// 0x00: lui   x1, 0x30000
// 0x04: addi  x2, x0, 0
// 0x08: addi  x2, x2, 1
// 0x0c: andi  x3, x2, 0x1F
// 0x10: addi  x3, x3, 0x41
// 0x14: sw    x3, 0(x1)
// 0x18: addi  x4, x0, 200
// 0x1c: addi  x4, x4, -1
// 0x20: bne   x4, x0, -4
// 0x24: jal   x0, -28

module rom (
    input  wire [7:0]  addr,
    output reg  [31:0] rdata
);
    always @(*) begin
        case (addr)
            8'h00: rdata = 32'h300000B7;  // lui   x1, 0x30000
            8'h01: rdata = 32'h00000113;  // addi  x2, x0, 0
            8'h02: rdata = 32'h00110113;  // addi  x2, x2, 1
            8'h03: rdata = 32'h01F17193;  // andi  x3, x2, 0x1F
            8'h04: rdata = 32'h04118193;  // addi  x3, x3, 0x41
            8'h05: rdata = 32'h0030A023;  // sw    x3, 0(x1)
            8'h06: rdata = 32'h0C800213;  // addi  x4, x0, 200
            8'h07: rdata = 32'hFFF20213;  // addi  x4, x4, -1
            8'h08: rdata = 32'hFE021EE3;  // bne   x4, x0, -4
            8'h09: rdata = 32'hFE5FF06F;  // jal   x0, -28
            default: rdata = 32'h00000013;
        endcase
    end
endmodule
