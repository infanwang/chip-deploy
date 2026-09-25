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

## 功能仿真

编译并运行：

    iverilog -o sim_soc \
        rtl/picorv32.v rtl/soc_top.v rtl/rom.v \
        rtl/timer.v rtl/gpio.v rtl/uart_tx.v rtl/spi_master.v \
        tb/tb_soc.v
    vvp sim_soc

预期输出：

    >>> GPIO 变化: 0x0000 -> 0x0001 <<<
    >>> GPIO 变化: 0x0001 -> 0x0002 <<<
    ...
    仿真结束
    最终 GPIO: 0x002c
    最终 PC:   0x00000008
    trap:      0

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

1. 克隆 PicoRV32 源码：

    cd ~/chip-design/shared
    git clone https://gitcode.com/gh_mirrors/pic/picorv32.git picorv32-soc
    cd picorv32-soc

2. 复制本示例文件：

    cp -r ~/chip-deploy/examples/picorv32-soc/rtl .
    cp -r ~/chip-deploy/examples/picorv32-soc/tb .
    cp ~/chip-deploy/examples/picorv32-soc/config.yaml .
    cp ~/chip-deploy/examples/picorv32-soc/constraint.sdc .

3. 运行 LibreLane：

    librelane --dockerized --pdk-root $PDK_ROOT --pdk sky130A \
        --run-tag soc-run-01 config.yaml
