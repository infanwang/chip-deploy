#!/usr/bin/env bash
# scripts/fix_nix.sh — 修复 Nix 安装问题
set -euo pipefail

STATE_DIR=".state"

echo "=== 修复 Nix 安装 ==="

# 1. 清理错误的完成标记
echo "[1/4] 清理下游错误标记..."
for f in nix_installed nix_config workspace_created pdk_sky130 \
         docker_stack smoke_test riscv_sdk; do
    [ -f "$STATE_DIR/$f.done" ] && rm -f "$STATE_DIR/$f.done" && echo "  删除 $f.done"
done

# 2. 检查并安装 Nix
echo "[2/4] 检查 Nix 安装状态..."
if command -v nix &>/dev/null; then
    echo "  Nix 已安装: $(nix --version | head -1)"
elif [ -d /nix ] && [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    echo "  /nix 存在但 profile 未加载，正在加载..."
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    echo "  加载后: $(nix --version | head -1)"
else
    echo "  Nix 未安装，开始安装..."
    sh <(curl -L https://nixos.org/nix/install) --daemon --yes
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# 3. 验证
echo "[3/4] 验证 Nix..."
if ! command -v nix &>/dev/null; then
    echo "  ✘ Nix 仍然不可用，请手动检查 /nix 目录"
    exit 1
fi
echo "  ✔ nix: $(nix --version | head -1)"

# 4. 持久化到 .bashrc
echo "[4/4] 持久化 Nix profile..."
if ! grep -q "nix-daemon.sh" "$HOME/.bashrc" 2>/dev/null; then
    {
        echo ''
        echo '# Nix'
        echo '[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    } >> "$HOME/.bashrc"
    echo "  已添加到 ~/.bashrc"
else
    echo "  已存在于 ~/.bashrc"
fi

echo ""
echo "=== 修复完成，重新执行 deploy.sh ==="
echo "  bash scripts/deploy.sh"
