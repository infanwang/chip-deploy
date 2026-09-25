
Changelog
[1.0.0] - 2026-09-25
Added
Nix Flakes 环境（Yosys/Verilator/Magic/KLayout/Netgen/SBY/QEMU/gcc）

SkyWater SKY130A/B PDK（ciel 3.0.0，hash 1689ac3f）

LibreLane 3.0.14 Docker 化流程

SPM 端到端验证（1,110 单元，签核全通过）

PicoRV32 端到端验证（11,872 单元，7.87 mW，33 MHz）

幂等部署脚本（8 个 stage，.state/ 状态标记）

环境检查脚本（JSON 报告）

完整文档（GUIDE / TROUBLESHOOTING / CASES / ROADMAP）

Fixed
nix.conf 多行 trusted-public-keys 语法错误

flake.nix shellHook 中 ${VAR:-default} 转义问题

magic → magic-vlsi 包名修正

ciel 3.0 需要显式版本 hash

SDC 中 remove_from_collection 在 OpenSTA 不支持

PEP 668 externally-managed-environment（改用独立 venv）

Known Issues
SS 工艺角 Max Slew/Cap 警告（不影响签核）

PicoRV32 LVS 有 67 个悬空引脚（未使用端口，无害）
