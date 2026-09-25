# Changelog

## [1.3.0] - 2026-09-25

### Added
- PicoRV32 SoC 集成：PicoRV32 + Timer + GPIO + UART TX + SPI Master + ROM
- Wishbone 风格总线互联
- Timer 外设含中断支持
- 新增 `examples/picorv32-soc/` 完整示例

### Performance

SoC 集成 @ 25 ns（40 MHz）：

| 指标 | 纯核（v1.2.0）| SoC（v1.3.0）| 变化 |
| :--- | ---: | ---: | :--- |
| 标准单元 | 11,868 | 15,002 | +26% |
| 面积 | 176,307 µm² | 221,653 µm² | +26% |
| 功耗 | 10.58 mW | 12.72 mW | +20% |
| Setup 裕量（SS）| +0.912 ns | +2.767 ns | +1.86 ns |
| Hold 裕量（FF）| +0.134 ns | +0.122 ns | ≈ |
| DRC / LVS / Antenna | ✅ | ✅ | — |

### 外设地址映射

| 外设 | 基地址 | 功能 |
| :--- | :--- | :--- |
| ROM | 0x00000000 | 程序存储（256 指令）|
| Timer | 0x10000000 | 定时器 + 中断 |
| GPIO | 0x20000000 | 32 位输入输出 |
| UART TX | 0x30000000 | 串口发送 |
| SPI Master | 0x40000000 | SPI 主机 |

## [1.2.0] - 2026-09-25

### Added
- PicoRV32 45 MHz 实验配置（22 ns 周期）

### Performance

| 周期 | 频率 | Setup(SS) | 面积 | 功耗 |
| :--- | ---: | ---: | ---: | ---: |
| 30 ns | 33 MHz | +8.78 ns | 176,307 µm² | 7.87 mW |
| 25 ns | 40 MHz | +3.91 ns | 176,307 µm² | 9.31 mW |
| 22 ns | 45.45 MHz | +0.912 ns | 176,307 µm² | 10.58 mW |

## [1.1.0] - 2026-09-25

### Added
- GitHub Actions CI
- Apache-2.0 LICENSE
- README 徽章

## [1.0.0] - 2026-09-25

### Added
- Nix Flakes 环境
- SkyWater SKY130A/B PDK
- LibreLane 3.0.14 Docker 化流程
- SPM 端到端验证（1,110 单元）
- PicoRV32 端到端验证（11,872 单元，33 MHz）
