# chip-deploy
[![CI](https://github.com/infanwang/chip-deploy/actions/workflows/ci.yml/badge.svg)](https://github.com/infanwang/chip-deploy/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/infanwang/chip-deploy)](https://github.com/infanwang/chip-deploy/releases)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
**开源芯片设计端到端平台** — 从 RTL 到可流片 GDSII。

在 WSL2 Ubuntu 26.04 上，使用 **Nix + Docker + LibreLane + SkyWater SKY130 PDK** 构建工业级开源 EDA 工具链。

## 已验证设计

| 设计 | 单元数 | 面积 | 功耗 | 签核 |
| :--- | ---: | ---: | ---: | :---: |
| SPM 8×8 乘法器 | 1,110 | 9,878 µm² | — | ✅ |
| **PicoRV32 RISC-V 核** | **11,872** | **191,277 µm²** | **7.87 mW** | ✅ |

## 快速开始

```bash
git clone <repo-url> chip-deploy && cd chip-deploy
chmod +x scripts/*.sh
bash scripts/bootstrap.sh
工具链
工具	版本
Yosys	0.51 / 0.62
Verilator	5.034
Icarus Verilog	12.0
SBY	0.52
LibreLane	3.0.14
Magic	8.3.526
KLayout	0.30.1
Netgen	6.2
QEMU RISC-V	9.2.4
PDK	SkyWater SKY130A/B
文档
部署指南

故障排除

案例集

改进路线

特性
✅ 幂等部署：.state/<stage>.done 标记

✅ 容错重试：指数退避（5s→10s→20s）

✅ 可追溯：deploy_trace.log + git_commit.txt

✅ 可移植：flake.lock 密码学锁定版本

授权
Apache-2.0
