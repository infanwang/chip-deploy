`timescale 1ns/1ps
module tb_soc;
    reg         clk = 0;
    reg         rst_n = 0;
    reg  [15:0] gpio_in = 16'h0;
    wire [15:0] gpio_out;
    wire        uart_tx;
    wire        spi_sclk, spi_mosi, spi_cs_n;
    wire        trap;

    // 50 MHz 时钟
    always #10 clk = ~clk;

    // DUT
    soc_top dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .gpio_in    (gpio_in),
        .gpio_out   (gpio_out),
        .uart_tx    (uart_tx),
        .spi_sclk   (spi_sclk),
        .spi_mosi   (spi_mosi),
        .spi_miso   (1'b0),
        .spi_cs_n   (spi_cs_n),
        .trap       (trap)
    );

    integer cycle = 0;
    reg [15:0] gpio_prev = 16'h0;
    reg [31:0] pc_prev = 32'hFFFFFFFF;

    always @(posedge clk) begin
        cycle = cycle + 1;

        // 显示 PC 变化
        if (dut.cpu.reg_pc !== pc_prev) begin
            $display("[%5t ns] cycle=%3d  PC 0x%08x -> 0x%08x  GPIO=0x%04x  trap=%b",
                     $time, cycle, pc_prev, dut.cpu.reg_pc, gpio_out, trap);
            pc_prev = dut.cpu.reg_pc;
        end

        // 监控 GPIO 变化
        if (gpio_out !== gpio_prev) begin
            $display(">>> GPIO 变化: 0x%04x -> 0x%04x <<<", gpio_prev, gpio_out);
            gpio_prev = gpio_out;
        end

        if (cycle > 500) begin
            $display("");
            $display("═══ 仿真结束 ═══");
            $display("最终 GPIO: 0x%04x", gpio_out);
            $display("最终 PC:   0x%08x", dut.cpu.reg_pc);
            $display("累计周期:  %0d", cycle);
            $display("trap:      %b", trap);
            $finish;
        end
    end

    initial begin
        $dumpfile("soc_wave.vcd");
        $dumpvars(0, tb_soc);
        rst_n = 0;
        #100 rst_n = 1;
        $display("═══ SoC 仿真启动 ═══");
        $display("时钟周期: 20 ns (50 MHz)");
        $display("");
    end
endmodule
