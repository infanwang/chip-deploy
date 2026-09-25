// Timer 外设
// 地址 0x1XXXXXXX
// 寄存器：
//   0x00 LOAD   (RW) 加载值
//   0x04 CTRL   (RW) [0]=enable, [1]=oneshot
//   0x08 STATUS (RW) [0]=irq_pending（写 1 清除）
//   0x0C VALUE  (RO) 当前计数值
module timer (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sel,
    input  wire        we,
    input  wire [3:0]  addr,        // addr[3:2] 选择寄存器
    input  wire [31:0] wdata,
    output reg  [31:0] rdata,
    output reg         irq
);
    reg [31:0] load_val;
    reg [31:0] counter;
    reg        enable;
    reg        oneshot;
    reg        irq_pending;

    wire hit_zero = enable && (counter == 32'd0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            load_val    <= 32'hFFFF_FFFF;
            counter     <= 32'hFFFF_FFFF;
            enable      <= 1'b0;
            oneshot     <= 1'b0;
            irq_pending <= 1'b0;
        end else begin
            // 写寄存器
            if (sel && we) begin
                case (addr[3:2])
                    2'b00: load_val <= wdata;
                    2'b01: begin
                        enable  <= wdata[0];
                        oneshot <= wdata[1];
                    end
                    2'b10: irq_pending <= 1'b0;  // W1C
                    default: ;
                endcase
            end

            // 计数逻辑
            if (hit_zero) begin
                counter     <= load_val;
                irq_pending <= 1'b1;
                if (oneshot) enable <= 1'b0;
            end else if (enable) begin
                counter <= counter - 32'd1;
            end
        end
    end

    always @(*) begin
        case (addr[3:2])
            2'b00:   rdata = load_val;
            2'b01:   rdata = {30'b0, oneshot, enable};
            2'b10:   rdata = {31'b0, irq_pending};
            2'b11:   rdata = counter;
            default: rdata = 32'h0;
        endcase
    end

    always @(*) irq = irq_pending;
endmodule
