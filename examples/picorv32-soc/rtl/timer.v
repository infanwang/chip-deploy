module timer (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sel,
    input  wire        we,
    input  wire [3:0]  addr,
    input  wire [31:0] wdata,
    output reg  [31:0] rdata,
    output reg         irq
);
    reg [31:0] load_val;
    reg [31:0] counter;
    reg        enable;
    reg        oneshot;
    reg        irq_pending;     // 状态寄存器（CPU 可读）

    wire hit_zero = enable && (counter == 32'd0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            load_val    <= 32'd10;
            counter     <= 32'd10;
            enable      <= 1'b0;
            oneshot     <= 1'b0;
            irq_pending <= 1'b0;
            irq         <= 1'b0;
        end else begin
            // 默认 IRQ 拉低（单周期脉冲）
            irq <= 1'b0;

            // 写寄存器
            if (sel && we) begin
                case (addr[3:2])
                    2'b00: load_val <= wdata;
                    2'b01: begin
                        // enable 上升沿时重置 counter
                        if (wdata[0] && !enable)
                            counter <= (addr[3:2] == 2'b01 && load_val != 0) ? load_val : load_val;
                        enable  <= wdata[0];
                        oneshot <= wdata[1];
                    end
                    2'b10: irq_pending <= 1'b0;  // W1C
                    default: ;
                endcase
            end

            // 计数逻辑（写周期不计数）
            if (!(sel && we)) begin
                if (hit_zero) begin
                    counter     <= load_val;
                    irq_pending <= 1'b1;
                    irq         <= 1'b1;       // ← 单周期脉冲
                    if (oneshot) enable <= 1'b0;
                end else if (enable) begin
                    counter <= counter - 32'd1;
                end
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
endmodule
