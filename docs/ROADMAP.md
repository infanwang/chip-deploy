# 改进路线图

对应版本：**v1.4.0**

## 已完成（v1.0.0 → v1.4.0）

### v1.0.0 - 基础平台
- [x] Nix Flakes 环境（7 个 EDA 工具 + gcc）
- [x] SkyWater SKY130A/B PDK
- [x] LibreLane 3.0.14 Docker 化流程
- [x] SPM 端到端验证
- [x] PicoRV32 @ 33 MHz
- [x] 幂等部署脚本（8 stage）
- [x] 环境检查脚本（JSON 报告）
- [x] 完整文档

### v1.1.0 - 工程化
- [x] GitHub Actions CI（lint + shellcheck + iverilog + verilator）
- [x] Apache-2.0 LICENSE
- [x] README 徽章
- [x] 源码归档与校验和发布机制
- [x] .gitignore 增强

### v1.2.0 - 提频
- [x] PicoRV32 45 MHz 实验配置
- [x] 频率/面积/功耗权衡数据
- [x] 三个频率档位（33/40/45 MHz）

### v1.3.0 - SoC 集成
- [x] PicoRV32 + Timer + GPIO + UART TX + SPI Master + ROM
- [x] Wishbone 风格总线互联
- [x] Timer 外设含中断支持

### v1.3.1 - SoC 功能验证
- [x] SoC 功能仿真测试台
- [x] ROM 测试程序
- [x] GPIO 递增验证（0x0 → 0x2c）

### v1.4.0 - 外设验证
- [x] Timer IRQ 输出验证（78 次）
- [x] UART TX 输出验证（41 字符）
- [x] 单周期 IRQ 脉冲实现
- [x] Python 机器码生成器

## 短期（v1.5.0）

### SRAM 集成
- [ ] 安装 OpenRAM
- [ ] 生成 SRAM 宏单元（GDS + LEF + Liberty）
- [ ] LibreLane macro 集成
- [ ] SRAM 读写验证

### 其他
- [ ] SPI 回环验证
- [ ] SoC 跑真实固件（main.c）
- [ ] flake.lock 提交到 git
- [ ] Docker 镜像 digest 固定

## 中期（v1.6.0）

### 多 PDK 支持
- [ ] GF180MCU（180nm）
- [ ] IHP SG13G2（130nm BiCMOS）

### 验证增强
- [ ] cocotb Python 验证
- [ ] SBY 形式验证用例
- [ ] 后仿（SDF 反标）

### 流程优化
- [ ] deploy.sh `--dry-run` 模式
- [ ] 离线部署支持
- [ ] CI 缓存 Nix store 和 PDK

## 长期（v2.0.0）

### 硬件
- [ ] Tiny Tapeout 流片
- [ ] 迁移原生 Linux
- [ ] Kubernetes 集群（多用户）

### 设计
- [ ] Ibex RISC-V 核
- [ ] CVA6（Linux-capable）
- [ ] OpenTitan 安全 SoC

### 混合信号
- [ ] Xschem + Ngspice 流程
- [ ] 模拟 IP 库

## 已知不足

| 类别 | 问题 | 缓解 |
| :--- | :--- | :--- |
| 环境 | WSL 无 GPU 直通 | 迁移原生 Linux |
| 兼容 | Python 3.14 太新 | 用 Nix python312 |
| PDK | 仅 SKY130 | 加 GF180/IHP |
| 测试 | CI 只跑 lint | 加完整回归 |
| 安全 | 无 SBOM | 生成 SPDX 清单 |
| SoC | SRAM 用寄存器阵列 | 用 OpenRAM 宏 |
