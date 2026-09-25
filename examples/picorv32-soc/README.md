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

## 结果

| 指标 | 值 |
| :--- | ---: |
| 标准单元 | 15,002 |
| 面积 | 221,653 µm² |
| 功耗 | 12.72 mW |
| 周期 | 25 ns（40 MHz）|
| Setup 裕量（SS）| +2.767 ns |
| Hold 裕量（FF）| +0.122 ns |
| DRC / LVS / Antenna | 全通过 |
| 运行时长 | 16 分 27 秒 |

## 运行

    cd ~/chip-design/shared
    git clone https://gitcode.com/gh_mirrors/pic/picorv32.git picorv32-soc
    cd picorv32-soc
    cp -r ~/chip-deploy/examples/picorv32-soc/rtl .
    cp ~/chip-deploy/examples/picorv32-soc/config.yaml .
    cp ~/chip-deploy/examples/picorv32-soc/constraint.sdc .
    librelane --dockerized --pdk-root $PDK_ROOT --pdk sky130A \
        --run-tag soc-run-01 config.yaml
