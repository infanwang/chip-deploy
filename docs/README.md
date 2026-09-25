# chip-deploy

**开源芯片设计端到端平台** — 从 RTL 到可流片 GDSII 的完整流程。

在 WSL2 Ubuntu 26.04 上，使用 **Nix + Docker + LibreLane + SkyWater SKY130 PDK**，构建工业级开源 EDA 工具链。已验证两个设计：

- **SPM 8×8 串并乘法器**：1,110 单元，6,756 µm²，签核全通过
- **PicoRV32 RISC-V 核**：11,872 单元，191,277 µm²，7.87 mW，33 MHz，签核全通过

## 快速开始

```bash
git clone <repo-url> chip-deploy && cd chip-deploy
chmod +x scripts/*.sh
bash scripts/bootstrap.sh      # 全流程：检查 → 部署 → 审计
