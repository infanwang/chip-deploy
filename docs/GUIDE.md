
部署指南
前置条件
项目	要求
操作系统	Windows 11 + WSL2
WSL 发行版	Ubuntu 26.04 (VERSION 2)
Docker	Docker Desktop（启用 WSL 集成）或原生 Docker Engine
磁盘	≥ 100 GB
内存	≥ 16 GB（推荐 20 GB）
CPU	≥ 4 核（推荐 12 核）
WSL 资源调优
创建 C:\Users\<用户名>\.wslconfig：

ini
[wsl2]
memory=20GB
processors=12
swap=16GB
swapFile=C:\\temp\\wsl-swap.vhdx
pageReporting=false
应用：wsl --shutdown，然后重开终端。

Docker 配置
Docker Desktop → Settings → Resources → WSL Integration → 勾选 Ubuntu-26.04 → Apply。

验证：docker run --rm hello-world

一键部署
bash
cd ~/chip-deploy
chmod +x scripts/*.sh
bash scripts/bootstrap.sh
Stage 详情
Stage	操作	时长
0	环境检查	5s
1	安装 Nix	5–10 min
2	配置 Nix Flakes	5s
3	创建工作目录与 flake.nix	5s
4	安装 Sky130 PDK（2.2 GB）	10–20 min
5	构建 Docker 栈	5–10 min
6	冒烟测试	1 min
7	RISC-V SDK	1 min
8	审计	1s
跑第一个设计（SPM）
bash
cd ~/chip-design/shared/spm
librelane --dockerized --pdk-root $PDK_ROOT --pdk sky130A \
    --run-tag spm-run-01 config.yaml
查看版图
bash
cd ~/chip-deploy
nix develop .#default --command klayout <gds-file>
