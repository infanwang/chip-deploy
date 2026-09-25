`timescale 1ns/1ps
module tb_soc;
    reg         clk = 0;
    reg         rst_n = 0;
    reg  [15:0] gpio_in = 16'h0;
    wire [15:0] gpio_out;
    wire        uart_tx, spi_sclk, spi_mosi, spi_cs_n, trap;

    always #10 clk = ~clk;

    soc_top dut (
        .clk(clk), .rst_n(rst_n),
        .gpio_in(gpio_in), .gpio_out(gpio_out),
        .uart_tx(uart_tx),
        .spi_sclk(spi_sclk), .spi_mosi(spi_mosi), .spi_miso(1'b0),
        .spi_cs_n(spi_cs_n), .trap(trap)
    );

    // UART RX 解码器（DIV=450，20ns 周期 → 9000ns/bit）
    reg [7:0]  rx_shift = 0;
    reg [3:0]  rx_bit   = 0;
    reg        rx_busy  = 0;
    reg [15:0] rx_div   = 0;
    integer    rx_count = 0;

    always @(posedge clk) begin
        if (!rx_busy) begin
            if (uart_tx == 1'b0) begin
                rx_busy <= 1'b1;
                rx_div  <= 16'd675;
                rx_bit  <= 4'd0;
            end
        end else begin
            if (rx_div == 0) begin
                if (rx_bit < 4'd8) begin
                    rx_shift <= {uart_tx, rx_shift[7:1]};
                    rx_bit   <= rx_bit + 4'd1;
                    rx_div   <= 16'd450;
                end else begin
                    rx_busy  <= 1'b0;
                    rx_count <= rx_count + 1;
                    if (rx_count < 16)
                        $display("[%7t ns] UART RX #%0d: '%c' (0x%02x)",
                                 $time, rx_count + 1, rx_shift, rx_shift);
                end
            end else begin
                rx_div <= rx_div - 16'd1;
            end
        end
    end

    integer cycle = 0;
    always @(posedge clk) begin
        cycle = cycle + 1;
        if (cycle > 200000) begin
            $display("");
            $display("═══ F++ 仿真结束 ═══");
            $display("UART 累计接收: %0d 字符", rx_count);
            $display("trap:          %b", trap);
            $finish;
        end
    end

    initial begin
        $dumpfile("soc_wave.vcd");
        $dumpvars(0, tb_soc);
        rst_n = 0;
        #100 rst_n = 1;
        $display("═══ SoC UART 验证启动 ═══");
    end
endmodule
