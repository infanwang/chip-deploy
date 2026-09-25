
改进路线图
v1.1.0（短期）
□ flake.lock 提交到 git
□ Docker 镜像 digest 固定
□ deploy.sh --dry-run 模式
□ 离线部署支持
v1.2.0（中期）
□ GitHub Actions CI
□ GF180MCU / IHP SG13G2 PDK 支持
□ PicoRV32 提频到 40 MHz
□ SoC 集成示例
□ cocotb / SBY 用例
v2.0.0（长期）
□ 迁移原生 Linux
□ Kubernetes 集群
□ Tiny Tapeout 流片模板
□ AMS 混合信号流程
已知不足
类别	问题	缓解
环境	WSL 无 GPU	迁移 Linux
兼容	Python 3.14 太新	用 Nix python312
PDK	仅 SKY130	加 GF180/IHP
测试	无 CI	加 GitHub Actions
安全	无 SBOM	生成 SPDX
