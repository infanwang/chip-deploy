
故障排除手册
Docker
docker: command not found in WSL
Docker Desktop → Settings → Resources → WSL Integration → 勾选 Ubuntu-26.04。

Cannot connect to the Docker daemon
bash
sudo service docker start
Nix
--no-confirm 无效
Nix 安装器参数是 --yes：

bash
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
syntax error in configuration line
~/.config/nix/nix.conf 中 trusted-public-keys 必须单行。

undefined variable 'magic'
nixpkgs 中包名是 magic-vlsi。

${VAR:-default} 语法错误
Nix 多行字符串中 ${ 触发插值，改为 if [ -z "$VAR" ]; then export VAR=...; fi。

Ciel / PDK
ciel enable 报缺少参数
Ciel 3.0 需显式 hash：

bash
HASH=$(ciel ls-remote --pdk-family sky130 | head -1)
ciel enable --pdk-family sky130 "$HASH"
LibreLane
externally-managed-environment (PEP 668)
装到独立 venv：

bash
python3 -m venv ~/chip-design/tools/ciel-venv
~/chip-design/tools/ciel-venv/bin/pip install librelane
failed building wheel for lln-libparse
缺 Python.h：sudo apt install python3.14-dev

invalid command name "remove_from_collection"
OpenSTA 不支持，SDC 中删除该行，改用 [all_inputs]。

流程
Setup/Hold 违例
放宽周期（CLOCK_PERIOD: 30）或加强优化（SYNTH_STRATEGY: "DELAY 0"）。

Max Slew/Cap 警告（仅 SS 角）
不影响功能，可忽略。

流程中断重跑
用同一 --run-tag 自动续跑。
