# Changelog

## [1.5.0] - 2026-09-25

### Added
- 软硬件协同验证流程（C 固件 → ELF → ROM → RTL 仿真）
- RISC-V GCC 工具链集成
- 链接脚本（ROM 0x0, RAM 0x50000000）
- 启动代码（start.S）
- C 固件（UART + GPIO 测试）
- Python RISC-V 机器码生成器
- Verilator C++ 协同仿真 Testbench
- Bus Trace 调试基础设施
- RAM 模块（1 KB，0x50000000）
- 5 层分层调试方法（L0-L4）

### Fixed
- **`ram_rdata` 隐式 1 位信号**（关键 bug）→ 加 32 位声明
- `ENABLE_IRQ=1` 导致 CPU 跳非法地址 → `ENABLE_IRQ=0`
- Timer counter 初值错误 → enable 时重置
- Timer IRQ 无法清除 → 单周期脉冲
- 栈指向 ROM/SPI → 指向 RAM（0x50000400）

### Verified

**软硬件协同验证通过**：

| 层 | 测试 | 结果 |
| :--- | :--- | :--- |
| L0 | 纯 GPIO 写 | GPIO=0x1234 ✅ |
| L2 | RAM 读写 | 写 0xdead 读回 0xdead ✅ |
| L4 | 完整 C 固件 | UART 输出 "PicoRV32 SoC" + "tick=N" ✅ |

### Commits
- 引入 5 层分层调试方法
- Bus Trace 基础设施（dbg_mem_* 端口）

## [1.4.1] - 2026-09-25
...（保留原有内容）
