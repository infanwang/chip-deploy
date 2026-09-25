// 1 KB 单端口 RAM（256 words × 32 bit）
// 映射到 0x40000000，供栈和数据使用
module ram (
    input  wire        clk,
    input  wire        sel,
    input  wire        we,
    input  wire [3:0]  wstrb,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata
);
    reg [31:0] mem [0:255];

    // 组合逻辑读
    always @(*) begin
        rdata = mem[addr[9:2]];
    end

    // 同步写
    always @(posedge clk) begin
        if (sel && we) begin
            if (wstrb[0]) mem[addr[9:2]][7:0]   <= wdata[7:0];
            if (wstrb[1]) mem[addr[9:2]][15:8]  <= wdata[15:8];
            if (wstrb[2]) mem[addr[9:2]][23:16] <= wdata[23:16];
            if (wstrb[3]) mem[addr[9:2]][31:24] <= wdata[31:24];
        end
    end
endmodule
