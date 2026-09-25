# PicoRV32 @ 45 MHz 示例

22 ns 时钟周期（45.45 MHz），PicoRV32 在 SKY130 的实用上限。

## 结果

| 指标 | 值 |
| :--- | ---: |
| 周期 | 22 ns（45.45 MHz）|
| 标准单元 | 11,868 |
| 面积 | 176,307 µm² |
| 功耗 | 10.58 mW |
| Setup 裕量（SS 角）| +0.912 ns |
| Hold 裕量（FF 角）| +0.134 ns |
| DRC / LVS / Antenna | 全通过 |
| 运行时长 | 11 分 45 秒 |

## 运行

    cd ~/chip-design/shared
    git clone https://gitcode.com/gh_mirrors/pic/picorv32.git picorv32-45mhz
    cd picorv32-45mhz
    cp ~/chip-deploy/examples/picorv32-45mhz/* .
    librelane --dockerized --pdk-root $PDK_ROOT --pdk sky130A \
        --run-tag picorv32-45mhz-01 config.yaml
