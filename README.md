# chip-deploy

[![CI](https://github.com/infanwang/chip-deploy/actions/workflows/ci.yml/badge.svg)](https://github.com/infanwang/chip-deploy/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/infanwang/chip-deploy)](https://github.com/infanwang/chip-deploy/releases)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

**开源芯片设计端到端平台** — 从 RTL 到可流片 GDSII 的完整流程。

在 WSL2 Ubuntu 26.04 上，使用 **Nix + Docker + LibreLane + SkyWater SKY130 PDK**，构建工业级开源 EDA 工具链。

## 版本演进

| 版本 | 主题 | 关键成果 |
| :--- | :--- | :--- |
| **v1.0.0** | 基础平台 | SPM 乘法器 + PicoRV32 @ 33 MHz |
| **v1.1.0** | 工程化 | GitHub Actions CI + LICENSE + 归档机制 |
| **v1.2.0** | 提频 | PicoRV32 @ 45 MHz（+36.5%）|
| **v1.3.0** | SoC 集成 | 5 外设（Timer/GPIO/UART/SPI/ROM），15,002 单元 |
| **v1.3.1** | SoC 功能验证 | GPIO 递增 0x0 → 0x2c |
| **v1.4.0** | 外设验证 | Timer IRQ 78 次 + UART 41 字符 |

## 已验证设计

| 设计 | 标准单元 | 面积 | 功耗 | 频率 | 签核 |
| :--- | ---: | ---: | ---: | ---: | :---: |
| SPM 8×8 乘法器 | 1,110 | 9,878 µm² | — | — | ✅ |
| PicoRV32 @ 33 MHz | 11,872 | 176,307 µm² | 7.87 mW | 33 MHz | ✅ |
| PicoRV32 @ 40 MHz | 11,868 | 176,307 µm² | 9.31 mW | 40 MHz | ✅ |
| **PicoRV32 @ 45 MHz** | **11,868** | **176,307 µm²** | **10.58 mW** | **45.45 MHz** | ✅ |
| **PicoRV32 SoC** | **15,002** | **221,653 µm²** | **12.72 mW** | **40 MHz** | ✅ |

**所有设计 DRC / LVS / Antenna / STA 全工艺角通过。**

## 工具链

| 类别 | 工具 | 版本 |
| :--- | :--- | :--- |
| RTL 综合 | Yosys + ABC | 0.51 / 0.62 |
| 仿真 | Verilator / Icarus | 5.034 / 12.0 |
| 波形 | GTKWave | 3.3.121 |
| 形式验证 | SBY | 0.52 |
| 物理设计 | OpenROAD (via LibreLane) | 3.0.14 |
| 版图/DRC/LVS | Magic / KLayout / Netgen | 8.3.526 / 0.30.1 / 6.2 |
| STA | OpenSTA | 内置 |
| 系统仿真 | QEMU RISC-V | 9.2.4 |
| PDK | SkyWater SKY130A/B | hash 1689ac3f |
| 编译器 | gcc / g++ | 14.3.0 |

## 快速开始

    git clone https://github.com/infanwang/chip-deploy.git
    cd chip-deploy
    chmod +x scripts/*.sh
    bash scripts/bootstrap.sh

## 目录约定

    ~/chip-design/
    ├── pdk/          # PDK 存储（ciel 管理，2.2 GB）
    ├── shared/       # 设计工程 + runs/
    ├── projects/     # 临时测试
    ├── runs/         # 通用输出
    └── tools/        # venv（ciel、librelane）

## 文档

- [部署指南](docs/GUIDE.md)
- [故障排除](docs/TROUBLESHOOTING.md)
- [案例集](docs/CASES.md)
- [改进路线](docs/ROADMAP.md)
- [架构说明](docs/ARCHITECTURE.md)

## 授权

Apache-2.0
