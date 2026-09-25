# Changelog

## [1.3.1] - 2026-09-25

### Added
- SoC 功能仿真测试台（tb/tb_soc.v）
- ROM 中的测试程序（5 条 RISC-V 指令）
- 仿真波形记录（soc_wave.vcd）

### Fixed
- ROM 中 lui x1, 0x20000 编码错误（0x000200B7 -> 0x200000B7）
- ROM 中 jal x0, -8 编码错误（0xFF1FF06F -> 0xFF9FF06F）
- soc_top.v 中 irq 端口宽度不匹配（1 位 -> 32 位）

### Verified

SoC 功能仿真通过：

| 验证项 | 结果 |
| :--- | :--- |
| GPIO 递增 | 0x0000 到 0x002c（44 次）|
| PC 循环 | 0x08 到 0x0c 到 0x10 到 0x08 |
| 指令解码 | 5 条指令正确 |
| trap | 全程为 0 |
| 循环周期 | 每 5 周期一次 |

## [1.3.0] - 2026-09-25

### Added
- PicoRV32 SoC 集成：PicoRV32 + Timer + GPIO + UART TX + SPI Master + ROM
- Wishbone 风格总线互联
- Timer 外设含中断支持
- 新增 examples/picorv32-soc/ 完整示例

### Performance

SoC 集成 @ 25 ns（40 MHz）：

| 指标 | 纯核（v1.2.0）| SoC（v1.3.0）| 变化 |
| :--- | ---: | ---: | :--- |
| 标准单元 | 11,868 | 15,002 | +26% |
| 面积 | 176,307 um2 | 221,653 um2 | +26% |
| 功耗 | 10.58 mW | 12.72 mW | +20% |
| Setup 裕量（SS）| +0.912 ns | +2.767 ns | +1.86 ns |

### 外设地址映射

| 外设 | 基地址 | 功能 |
| :--- | :--- | :--- |
| ROM | 0x00000000 | 程序存储 |
| Timer | 0x10000000 | 定时器 + 中断 |
| GPIO | 0x20000000 | 32 位 IO |
| UART TX | 0x30000000 | 串口发送 |
| SPI Master | 0x40000000 | SPI 主机 |

## [1.2.0] - 2026-09-25

### Added
- PicoRV32 45 MHz 实验配置（22 ns 周期）

### Performance

| 周期 | 频率 | Setup(SS) | 面积 | 功耗 |
| :--- | ---: | ---: | ---: | ---: |
| 30 ns | 33 MHz | +8.78 ns | 176,307 um2 | 7.87 mW |
| 25 ns | 40 MHz | +3.91 ns | 176,307 um2 | 9.31 mW |
| 22 ns | 45.45 MHz | +0.912 ns | 176,307 um2 | 10.58 mW |

## [1.1.0] - 2026-09-25

### Added
- GitHub Actions CI
- Apache-2.0 LICENSE
- README 徽章

### Fixed
- Verilog testbench 语法错误
- baseline.sh 粘贴污染

## [1.0.0] - 2026-09-25

### Added
- Nix Flakes 环境
- SkyWater SKY130A/B PDK
- LibreLane 3.0.14 Docker 化流程
- SPM 端到端验证（1,110 单元）
- PicoRV32 端到端验证（11,872 单元，33 MHz）
