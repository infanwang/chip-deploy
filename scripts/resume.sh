#!/usr/bin/env bash
# scripts/resume.sh — 显示当前状态并提示如何续跑
set -euo pipefail

STATE_DIR=".state"
echo "当前部署状态："
echo ""
for f in "$STATE_DIR"/*.done; do
    [ -f "$f" ] || continue
    printf "  ✅ %s\n" "$(basename "$f" .done)"
done
echo ""
echo "未完成的阶段将在下次执行 deploy.sh 时自动继续。"
echo "执行: bash scripts/deploy.sh"
