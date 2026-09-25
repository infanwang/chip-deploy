#!/usr/bin/env bash
# scripts/audit.sh — 生成可追溯性审计报告
set -euo pipefail

STATE_DIR=".state"
WORK_ROOT="${HOME}/chip-design"

echo "╔══════════════════════════════════════════════════════╗"
echo "║   部署审计报告 (Deployment Audit Report)             ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "生成时间:   $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "主机:       $(hostname)"
echo "用户:       $(whoami)"
echo "内核:       $(uname -r)"
echo "脚本提交:   $(cat "$STATE_DIR/git_commit.txt" 2>/dev/null || echo 'N/A')"
echo ""

echo "── 阶段完成情况 ──────────────────────────────────────"
for f in "$STATE_DIR"/*.done; do
    [ -f "$f" ] || continue
    local name
    name=$(basename "$f" .done)
    printf "  %-24s %s\n" "$name" "$(stat -c %y "$f" 2>/dev/null | cut -d. -f1)"
done
echo ""

echo "── 工具版本 ──────────────────────────────────────────"
if [ -f "$WORK_ROOT/../flake.nix" ]; then
    nix develop .#default --command bash -c '
        echo "  yosys:      $(yosys -V 2>/dev/null | head -1 || echo N/A)"
        echo "  verilator:  $(verilator --version 2>/dev/null | head -1 || echo N/A)"
        echo "  iverilog:   $(iverilog -V 2>/dev/null | head -1 || echo N/A)"
        echo "  klayout:    $(klayout -v 2>/dev/null | head -1 || echo N/A)"
        echo "  openroad:   $(openroad -version 2>/dev/null | head -1 || echo N/A)"
        echo "  python3:    $(python3 --version 2>/dev/null || echo N/A)"
    ' 2>/dev/null || echo "  (Nix 环境不可用，跳过工具版本检查)"
fi
echo ""

echo "── Docker 服务状态 ──────────────────────────────────"
if command -v docker &>/dev/null; then
    docker compose -f docker/docker-compose.yml ps 2>/dev/null || echo "  (Compose 栈未运行)"
else
    echo "  Docker 不可用"
fi
echo ""

echo "── PDK 版本 ─────────────────────────────────────────"
if [ -d "$WORK_ROOT/pdk" ]; then
    for d in "$WORK_ROOT/pdk"/*/; do
        [ -d "$d" ] || continue
        printf "  %s\n" "$(basename "$d")"
    done
else
    echo "  PDK 目录不存在"
fi
echo ""

echo "── 环境报告摘要 ─────────────────────────────────────"
if [ -f "$STATE_DIR/env_report.json" ] && command -v jq &>/dev/null; then
    jq -r '.checks[] | "  [\(.status)] \(.tool // .check): \(.path // .message // .hint // "")"' \
        "$STATE_DIR/env_report.json" 2>/dev/null | head -30
else
    echo "  (报告文件或 jq 不可用)"
fi
echo ""

echo "══ 审计完成 ══"
