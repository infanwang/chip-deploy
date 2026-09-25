# PicoRV32 SoC 集成示例

PicoRV32 + Timer + GPIO + UART TX + SPI Master + ROM。

## 外设地址映射

| 外设 | 基地址 | 说明 |
| :--- | :--- | :--- |
| ROM | 0x00000000 | 程序存储 |
| Timer | 0x10000000 | 定时器（含中断）|
| GPIO | 0x20000000 | 32 位 IO |
| UART TX | 0x30000000 | 串口发送 |
| SPI Master | 0x40000000 | SPI 主机 |

## 功能验证

Timer IRQ 验证（78 次触发）：

    iverilog -o sim_soc rtl/*.v tb/tb_soc.v
    vvp sim_soc

预期输出片段：

    Timer IRQ #1 触发！GPIO=0x0000
    Timer IRQ #2 触发！GPIO=0x0000
    ...
    Timer IRQ 总数: 78

UART 验证（字符序列）：

    UART RX #1: 'B' (0x42)
    UART RX #2: 'E' (0x45)
    UART RX #3: 'H' (0x48)
    ...
    UART 累计接收: 41 字符

## 综合结果

| 指标 | 值 |
| :--- | ---: |
| 标准单元 | 15,002 |
| 面积 | 221,653 um2 |
| 功耗 | 12.72 mW |
| 频率 | 40 MHz（25 ns）|
| Setup 裕量（SS）| +2.767 ns |
| Hold 裕量（FF）| +0.122 ns |
| DRC / LVS / Antenna | 全通过 |
| 运行时长 | 16 分 27 秒 |

## 完整流程

    cd ~/chip-design/shared
    git clone https://gitcode.com/gh_mirrors/pic/picorv32.git picorv32-soc
    cd picorv32-soc
    cp -r ~/chip-deploy/examples/picorv32-soc/rtl .
    cp -r ~/chip-deploy/examples/picorv32-soc/tb .
    cp ~/chip-deploy/examples/picorv32-soc/config.yaml .
    cp ~/chip-deploy/examples/picorv32-soc/constraint.sdc .
    librelane --dockerized --pdk-root $PDK_ROOT --pdk sky130A \
        --run-tag soc-run-01 config.yaml
