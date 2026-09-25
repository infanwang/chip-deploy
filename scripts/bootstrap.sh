#!/usr/bin/env bash

scripts/bootstrap.sh — 全流程入口
set -euo pipefail
cd "$(dirname "$0")/.."

echo "╔══════════════════════════════════════════════════════╗"
echo "║ chip-deploy 全流程启动 ║"
echo "╚══════════════════════════════════════════════════════╝"

echo "▶ 1/3 环境检查"
bash scripts/check_env.sh || { echo "❌ 环境检查未通过"; exit 1; }

echo ""
echo "▶ 2/3 部署（幂等）"
bash scripts/deploy.sh

echo ""
echo "▶ 3/3 审计"
bash scripts/audit.sh

echo ""
echo "✅ 全流程完成"
