#!/usr/bin/env bash
# scripts/check_env.sh — 独立可运行的环境检查，输出 JSON 审计报告
set -euo pipefail

REPORT_DIR=".state"
REPORT_FILE="$REPORT_DIR/env_report.json"
mkdir -p "$REPORT_DIR"

# ---- 工具清单（分层） ----
TIER1_TOOLS=(docker git python3 pipx curl)
TIER2_TOOLS=(nix yosys verilator iverilog openroad klayout magic netgen)
TIER3_TOOLS=(sby gtkwave qemu-system-riscv64 spike riscv64-unknown-elf-gcc)

# ---- 检查函数 ----
check_tool() {
    local tool="$1"
    if command -v "$tool" &>/dev/null; then
        printf '{"tool":"%s","status":"ok","path":"%s"}' \
            "$tool" "$(command -v "$tool")"
    else
        printf '{"tool":"%s","status":"missing"}' "$tool"
    fi
}

check_wsl() {
    if grep -qi microsoft /proc/version 2>/dev/null; then
        printf '{"check":"wsl","status":"ok","kernel":"%s"}' "$(uname -r)"
    else
        printf '{"check":"wsl","status":"warn","message":"Not running under WSL"}'
    fi
}

check_wsl_resources() {
    local mem_kb mem_gb cpu disk_gb status="ok" hints=""
    mem_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    mem_gb=$((mem_kb / 1024 / 1024))
    cpu=$(nproc)
    disk_gb=$(df -BG / 2>/dev/null | awk 'NR==2{print $4}' | tr -d 'G')

    [ "$mem_gb" -lt 16 ] && { status="warn"; hints="${hints}内存 ${mem_gb}GB 低于推荐值 16GB; "; }
    [ "$cpu" -lt 4 ]    && { status="warn"; hints="${hints}CPU ${cpu}核 低于推荐值 4核; "; }
    if [ -z "$disk_gb" ] || [ "$disk_gb" -lt 100 ]; then
        status="fail"
        hints="${hints}根分区剩余空间 ${disk_gb:-0}GB 不足 100GB; "
    fi

    printf '{"check":"wsl_resources","status":"%s","mem_gb":%d,"cpu":%d,"disk_gb":%d,"hint":"%s"}' \
        "$status" "$mem_gb" "$cpu" "${disk_gb:-0}" "$hints"
    [ "$status" = "fail" ] && return 1
    return 0
}

check_docker() {
    if ! command -v docker &>/dev/null; then
        printf '{"check":"docker","status":"missing","hint":"Enable WSL Integration for this distro in Docker Desktop Settings, or install Docker Engine natively"}'
        return 1
    fi
    if ! docker info &>/dev/null 2>&1; then
        printf '{"check":"docker","status":"daemon_unreachable","hint":"Ensure Docker Desktop is running on Windows, or start docker service in WSL"}'
        return 1
    fi
    printf '{"check":"docker","status":"ok","version":"%s"}' "$(docker --version 2>/dev/null | head -1)"
    return 0
}

check_storage() {
    local target="${HOME}/chip-design"
    if [ -d "$target" ]; then
        local fs_type
        fs_type=$(df -T "$target" 2>/dev/null | awk 'NR==2{print $2}')
        if [[ "$fs_type" == "9p" || "$fs_type" == "drvfs" ]]; then
            printf '{"check":"storage","status":"fail","fs":"%s","hint":"工作目录位于跨文件系统路径，性能极差，请迁移到 WSL 原生 ext4"}' "$fs_type"
            return 1
        fi
        printf '{"check":"storage","status":"ok","fs":"%s","path":"%s"}' "$fs_type" "$target"
    else
        printf '{"check":"storage","status":"warn","message":"~/chip-design 尚未创建"}'
    fi
    return 0
}

# ---- 生成报告 ----
{
    printf '{\n'
    printf '"timestamp":"%s",\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf '"hostname":"%s",\n' "$(hostname)"
    printf '"checks":[\n'

    first=1
    emit() { [ $first -eq 0 ] && printf ',\n'; first=0; printf '%s' "$1"; }

    emit "$(check_wsl)"
    emit "$(check_wsl_resources)" || true
    emit "$(check_docker)"       || true
    emit "$(check_storage)"      || true
    for t in "${TIER1_TOOLS[@]}"; do emit "$(check_tool "$t")"; done
    for t in "${TIER2_TOOLS[@]}"; do emit "$(check_tool "$t")"; done
    for t in "${TIER3_TOOLS[@]}"; do emit "$(check_tool "$t")"; done

    printf '\n]}\n'
} > "$REPORT_FILE"

# ---- 退出码语义 ----
if command -v jq &>/dev/null; then
    if jq -e '.checks[] | select(.status=="fail")' "$REPORT_FILE" &>/dev/null; then
        echo "❌ ENV CHECK FAILED — 存在致命问题：" >&2
        jq '.checks[] | select(.status=="fail")' "$REPORT_FILE" >&2
        exit 1
    fi
fi

echo "✅ ENV CHECK PASSED"
echo "   报告: $REPORT_FILE"
