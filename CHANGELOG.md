# Changelog

## [1.2.0] - 2026-09-25

### Added
- PicoRV32 45 MHz 实验配置（22 ns 周期）
- 完整的频率/面积/功耗权衡数据
- 33 MHz / 40 MHz / 45 MHz 三档性能对比

### Performance

PicoRV32 RISC-V 核频率演进（SKY130）：

| 周期 | 频率 | Setup(SS) | Hold(FF) | 面积 | 功耗 |
| :--- | ---: | ---: | ---: | ---: | ---: |
| 30 ns | 33 MHz | +8.78 ns | +0.128 ns | 176,307 µm² | 7.87 mW |
| 25 ns | 40 MHz | +3.91 ns | +0.134 ns | 176,307 µm² | 9.31 mW |
| **22 ns** | **45.45 MHz** | **+0.912 ns** | **+0.134 ns** | **176,307 µm²** | **10.58 mW** |

**频率提升**：33 MHz → 45.45 MHz（**+36.5%**）
**面积代价**：0%（完全一致）

### Changed
- 新增 `examples/picorv32-45mhz/` 示例

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

### Known Issues
- SS 工艺角 Max Slew/Cap 警告（不影响签核）
- PicoRV32 有 67 个悬空引脚（未使用端口）
