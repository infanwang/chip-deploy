# Changelog

## [1.4.0] - 2026-09-25

### Added
- Timer IRQ 输出验证（周期性中断）
- UART TX 输出验证（字符序列）
- 单周期 IRQ 脉冲实现（Timer）

### Verified

| 外设 | 验证方法 | 结果 |
| :--- | :--- | :--- |
| Timer | IRQ 周期性触发 | 78 次（每 ~120 µs）|
| UART | 字符序列输出 | 41 字符（B, E, H, K, ...）|
| GPIO | 递增计数 | 0x0 → 0x2a |

### Fixed
- Timer counter 未在 enable 时重置
- Timer IRQ 触发后无法自动清除
- irq 端口宽度不匹配（1 位 → 32 位）

### Deferred
- SRAM 集成推迟至 v1.5.0（需 OpenRAM 宏单元）

## [1.3.1] - 2026-09-25

### Added
- SoC 功能仿真测试台
- ROM 中的测试程序（5 条 RISC-V 指令）

### Fixed
- ROM 编码错误（lui, jal）
- irq 端口宽度不匹配

## [1.3.0] - 2026-09-25

### Added
- PicoRV32 SoC 集成：PicoRV32 + Timer + GPIO + UART TX + SPI Master + ROM

## [1.2.0] - 2026-09-25

### Added
- PicoRV32 45 MHz 配置（22 ns 周期）

## [1.1.0] - 2026-09-25

### Added
- GitHub Actions CI
- Apache-2.0 LICENSE

## [1.0.0] - 2026-09-25

### Added
- 基础平台 + SPM + PicoRV32 @ 33 MHz
