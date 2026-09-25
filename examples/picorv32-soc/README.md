# PicoRV32 SoC 集成示例

PicoRV32 + Timer + GPIO + UART TX + SPI Master + ROM + RAM。

## 外设地址映射

| 外设 | 基地址 | 说明 |
| :--- | :--- | :--- |
| ROM | 0x00000000 | 程序存储（4 KB）|
| Timer | 0x10000000 | 定时器 |
| GPIO | 0x20000000 | 32 位 IO |
| UART TX | 0x30000000 | 串口发送 |
| SPI Master | 0x40000000 | SPI 主机 |
| RAM | 0x50000000 | 1 KB 数据/栈 |

## 软硬件协同验证

**编译 C 固件**：

    cd firmware
    make

生成：
- `firmware.elf`（RISC-V ELF）
- `firmware.bin`（二进制）
- `firmware.hex`（ROM 初始化）

**生成 ROM Verilog**：

    python3 - <<'PY_EOF' > ../rtl/rom.v
    lines = open('firmware.hex').read().strip().split('\n')
    print("module rom (")
    print("    input wire [7:0] addr,")
    print("    output reg [31:0] rdata")
    print(");")
    print("    always @(*) begin")
    print("        case (addr)")
    for i, line in enumerate(lines):
        print("            8'h%02x: rdata = 32'h%s;" % (i, line.strip()))
    print("            default: rdata = 32'h00000013;")
    print("        endcase")
    print("    end")
    print("endmodule")
    PY_EOF

**Verilator 协同仿真**：

    verilator --cc --exe --build -Wno-fatal \
        -Wno-DECLFILENAME -Wno-PINCONNECTEMPTY -Wno-IMPLICIT -Wno-WIDTHEXPAND \
        rtl/picorv32.v rtl/soc_top.v rtl/rom.v rtl/ram.v \
        rtl/timer.v rtl/gpio.v rtl/uart_tx.v rtl/spi_master.v \
        tb/tb_soc.cpp -o sim_soc --top-module soc_top

    ./obj_dir/sim_soc

**预期输出**：

    ═══ L4: 完整 C 固件验证 ═══
    --- UART 输出 ---
    PicoRV32 SoC @ 40 MHz
    UART + GPIO test started
    tick=100
    tick=200
    ...

## 综合结果

| 指标 | 值 |
| :--- | ---: |
| 标准单元 | 15,002 |
| 面积 | 221,653 um² |
| 功耗 | 12.72 mW |
| 频率 | 40 MHz（25 ns）|
| DRC / LVS / Antenna | ✅ 全通过 |
