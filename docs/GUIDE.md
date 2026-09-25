# 部署指南

对应版本：**v1.4.0**

## 前置条件

| 项目 | 要求 |
| :--- | :--- |
| 操作系统 | Windows 11 + WSL2 |
| WSL 发行版 | Ubuntu 26.04（VERSION 2）|
| Docker | Docker Desktop（启用 WSL 集成）或原生 Docker Engine |
| 磁盘 | ≥ 100 GB 可用 |
| 内存 | ≥ 16 GB（推荐 20 GB）|
| CPU | ≥ 4 核（推荐 12 核）|
| 网络 | 可访问 github.com / cache.nixos.org / pypi.org |

## WSL 资源调优

创建 `C:\Users\<用户名>\.wslconfig`：

    [wsl2]
    memory=20GB
    processors=12
    swap=16GB
    swapFile=C:\\temp\\wsl-swap.vhdx
    pageReporting=false

应用：`wsl --shutdown`，然后重开终端。

验证：

    nproc && free -h

## Docker 配置

### 方式 A：Docker Desktop

1. Settings → Resources → WSL Integration
2. 勾选 `Ubuntu-26.04`
3. Apply & Restart
4. 验证：`docker run --rm hello-world`

### 方式 B：原生 Docker Engine

    bash scripts/install_docker_engine.sh
    wsl --shutdown
    docker run --rm hello-world

## 一键部署

    cd ~/chip-deploy
    chmod +x scripts/*.sh
    bash scripts/bootstrap.sh

`bootstrap.sh` 依次执行：
1. `check_env.sh` — 环境检查（JSON 报告）
2. `deploy.sh` — 8 个 stage 的幂等部署
3. `audit.sh` — 生成审计报告

## Stage 详情

| Stage | 操作 | 时长 |
| :--- | :--- | :--- |
| 0 | 环境检查 | 5s |
| 1 | 安装 Nix | 5–10 min |
| 2 | 配置 Nix Flakes | 5s |
| 3 | 创建工作目录与 flake.nix | 5s |
| 4 | 安装 Sky130 PDK（2.2 GB）| 10–20 min |
| 5 | 构建 Docker 栈 | 5–10 min |
| 6 | 冒烟测试（SPM）| 1 min |
| 7 | RISC-V SDK | 1 min |
| 8 | 审计报告 | 1s |

## 第一个设计：SPM

    cd ~/chip-design/shared/spm
    librelane --dockerized --pdk-root $PDK_ROOT --pdk sky130A \
        --run-tag spm-run-01 config.yaml

## 进阶设计：PicoRV32

    cd ~/chip-design/shared
    git clone https://gitcode.com/gh_mirrors/pic/picorv32.git
    cd picorv32
    cp ~/chip-deploy/examples/picorv32/config.yaml .
    cp ~/chip-deploy/examples/picorv32/constraint.sdc .

    librelane --dockerized --pdk-root $PDK_ROOT --pdk sky130A \
        --run-tag picorv32-run-01 config.yaml

## SoC 集成：PicoRV32 + 5 外设

    cd ~/chip-design/shared
    git clone https://gitcode.com/gh_mirrors/pic/picorv32.git picorv32-soc
    cd picorv32-soc

    # 复制 RTL + testbench + 配置
    cp -r ~/chip-deploy/examples/picorv32-soc/rtl .
    cp -r ~/chip-deploy/examples/picorv32-soc/tb .
    cp ~/chip-deploy/examples/picorv32-soc/config.yaml .
    cp ~/chip-deploy/examples/picorv32-soc/constraint.sdc .

    # 跑完整流程
    librelane --dockerized --pdk-root $PDK_ROOT --pdk sky130A \
        --run-tag soc-run-01 config.yaml

## 功能仿真：Timer + UART

    cd ~/chip-deploy && nix develop .#default
    cd ~/chip-design/shared/picorv32-soc

    iverilog -o sim_soc \
        rtl/picorv32.v rtl/soc_top.v rtl/rom.v \
        rtl/timer.v rtl/gpio.v rtl/uart_tx.v rtl/spi_master.v \
        tb/tb_soc.v
    vvp sim_soc

## 查看版图

    cd ~/chip-deploy
    nix develop .#default --command \
        klayout ~/chip-design/shared/picorv32-soc/runs/soc-run-01/final/gds/soc_top.gds

## 迁移到新机器

    # 旧机器
    tar czf chip-deploy.tar.gz ~/chip-deploy
    tar czf chip-design-pdk.tar.gz ~/chip-design/pdk

    # 新机器
    tar xzf chip-deploy.tar.gz -C ~/
    tar xzf chip-design-pdk.tar.gz -C ~/
    cd ~/chip-deploy && bash scripts/deploy.sh

## 相关资源

- [Releases](https://github.com/infanwang/chip-deploy/releases)
- [Troubleshooting](TROUBLESHOOTING.md)
- [Cases](CASES.md)
