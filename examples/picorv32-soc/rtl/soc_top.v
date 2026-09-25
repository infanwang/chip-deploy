// PicoRV32 SoC 顶层
// 集成：PicoRV32 + ROM + Timer + GPIO + UART TX + SPI Master
module soc_top (
    input  wire        clk,
    input  wire        rst_n,
    // GPIO
    input  wire [15:0] gpio_in,
    output wire [15:0] gpio_out,
    // UART
    output wire        uart_tx,
    // SPI
    output wire        spi_sclk,
    output wire        spi_mosi,
    input  wire        spi_miso,
    output wire        spi_cs_n,
    // 调试
    output wire        trap,
    // 调试端口（用于 bus trace）
    output wire        dbg_mem_valid,
    output wire        dbg_mem_ready,
    output wire [31:0] dbg_mem_addr,
    output wire [31:0] dbg_mem_wdata,
    output wire [3:0]  dbg_mem_wstrb,
    output wire [31:0] dbg_mem_rdata
);
    // ═══ PicoRV32 memory interface ═══
    wire        mem_valid;
    wire        mem_instr;
    wire        mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0]  mem_wstrb;
    wire [31:0] mem_rdata;
    wire        irq_timer;

    // ═══ 地址解码（高 4 位）═══
    wire [3:0] dev_sel = mem_addr[31:28];
    wire sel_rom   = (dev_sel == 4'h0);
    wire sel_timer = (dev_sel == 4'h1);
    wire sel_gpio  = (dev_sel == 4'h2);
    wire sel_uart  = (dev_sel == 4'h3);
    wire sel_spi   = (dev_sel == 4'h4);
    wire sel_ram   = (dev_sel == 4'h5);

    wire mem_we = mem_valid && (|mem_wstrb);

    // ═══ 各外设的 ready 和 rdata ═══
    wire [31:0] rom_rdata;
    wire [31:0] timer_rdata;
    wire [31:0] gpio_rdata;
    wire [31:0] uart_rdata;
    wire [31:0] spi_rdata;
    wire [31:0] ram_rdata;
    wire [31:0] gpio_out_full;

    assign mem_ready = mem_valid && (sel_rom | sel_timer | sel_gpio | sel_uart | sel_spi | sel_ram);

    assign mem_rdata = sel_rom   ? rom_rdata   :
                       sel_timer ? timer_rdata :
                       sel_gpio  ? gpio_rdata  :
                       sel_uart  ? uart_rdata  :
                       sel_spi   ? spi_rdata   :
                       sel_ram   ? ram_rdata   : 32'h0;

    assign gpio_out = gpio_out_full[15:0];
    
    // 调试信号（转发内部 bus 信号到输出端口）
    assign dbg_mem_valid = mem_valid;
    assign dbg_mem_ready = mem_ready;
    assign dbg_mem_addr  = mem_addr;
    assign dbg_mem_wdata = mem_wdata;
    assign dbg_mem_wstrb = mem_wstrb;
    assign dbg_mem_rdata = mem_rdata;

    // ═══ PicoRV32 例化 ═══
    picorv32 #(
        .ENABLE_COUNTERS       (1),
        .ENABLE_COUNTERS64     (1),
        .ENABLE_REGS_16_31     (1),
        .ENABLE_REGS_DUALPORT  (1),
        .LATCHED_MEM_RDATA     (0),
        .TWO_STAGE_SHIFT       (1),
        .BARREL_SHIFTER        (0),
        .TWO_CYCLE_COMPARE     (0),
        .TWO_CYCLE_ALU         (0),
        .COMPRESSED_ISA        (0),
        .CATCH_MISALIGN        (1),
        .CATCH_ILLINSN         (1),
        .ENABLE_PCPI           (0),
        .ENABLE_MUL            (0),
        .ENABLE_DIV            (0),
        .ENABLE_IRQ            (0),
        .ENABLE_IRQ_QREGS      (0),
        .ENABLE_IRQ_TIMER      (0),
        .ENABLE_TRACE          (0),
        .REGS_INIT_ZERO        (0),
        .MASKED_IRQ            (32'h0000_0000),
        .LATCHED_IRQ           (32'hFFFF_FFFF),
        .PROGADDR_RESET        (32'h0000_0000),
        .PROGADDR_IRQ          (32'h0000_0010),
        .STACKADDR             (32'h0000_0FFC)
    ) cpu (
        .clk           (clk),
        .resetn        (rst_n),
        .trap          (trap),
        .mem_valid     (mem_valid),
        .mem_instr     (mem_instr),
        .mem_ready     (mem_ready),
        .mem_addr      (mem_addr),
        .mem_wdata     (mem_wdata),
        .mem_wstrb     (mem_wstrb),
        .mem_rdata     (mem_rdata),
        .mem_la_read   (),
        .mem_la_write  (),
        .mem_la_addr   (),
        .mem_la_wdata  (),
        .mem_la_wstrb  (),
        .pcpi_valid    (),
        .pcpi_insn     (),
        .pcpi_rs1      (),
        .pcpi_rs2      (),
        .pcpi_wr       (1'b0),
        .pcpi_rd       (32'h0),
        .pcpi_wait     (1'b0),
        .pcpi_ready    (1'b0),
        .irq           ({31'b0, irq_timer}),
        .eoi           (),
        .trace_valid   (),
        .trace_data    ()
    );

    // ═══ ROM（程序存储器）═══
    rom u_rom (
        .addr   (mem_addr[9:2]),
        .rdata  (rom_rdata)
    );

    // ═══ Timer ═══
    timer u_timer (
        .clk    (clk),
        .rst_n  (rst_n),
        .sel    (sel_timer && mem_valid),
        .we     (mem_we),
        .addr   (mem_addr[3:0]),
        .wdata  (mem_wdata),
        .rdata  (timer_rdata),
        .irq    (irq_timer)
    );

    // ═══ GPIO ═══
    gpio u_gpio (
        .clk        (clk),
        .rst_n      (rst_n),
        .sel        (sel_gpio && mem_valid),
        .we         (mem_we),
        .addr       (mem_addr[3:0]),
        .wdata      (mem_wdata),
        .rdata      (gpio_rdata),
        .gpio_in    ({16'b0, gpio_in}),
        .gpio_out   (gpio_out_full)
    );

    // ═══ UART TX ═══
    uart_tx #(.DIV(450)) u_uart (
        .clk    (clk),
        .rst_n  (rst_n),
        .sel    (sel_uart && mem_valid),
        .we     (mem_we),
        .addr   (mem_addr[3:0]),
        .wdata  (mem_wdata),
        .rdata  (uart_rdata),
        .tx     (uart_tx)
    );

    // ═══ SPI Master ═══

    ram u_ram (
        .clk    (clk),
        .sel    (sel_ram && mem_valid),
        .we     (mem_we),
        .wstrb  (mem_wstrb),
        .addr   (mem_addr),
        .wdata  (mem_wdata),
        .rdata  (ram_rdata)
    );

    spi_master u_spi (
        .clk    (clk),
        .rst_n  (rst_n),
        .sel    (sel_spi && mem_valid),
        .we     (mem_we),
        .addr   (mem_addr[3:0]),
        .wdata  (mem_wdata),
        .rdata  (spi_rdata),
        .miso   (spi_miso),
        .mosi   (spi_mosi),
        .sclk   (spi_sclk),
        .cs_n   (spi_cs_n)
    );

endmodule
