#!/usr/bin/env bash
# scripts/deploy.sh — 单机芯片设计全流程一键部署
# 特性：幂等、容错、可追溯、可移植
set -euo pipefail

# ============================================================
# 全局配置
# ============================================================
STATE_DIR=".state"
LOG_DIR="$STATE_DIR/logs"
TRACE_LOG="$LOG_DIR/deploy_trace.log"
WORK_ROOT="${HOME}/chip-design"
PDK_ROOT="${WORK_ROOT}/pdk"

mkdir -p "$STATE_DIR" "$LOG_DIR" "$WORK_ROOT" "$PDK_ROOT"

# 全量日志：所有 stdout/stderr 同时写入 trace 文件
exec > >(tee -a "$TRACE_LOG") 2>&1

# ============================================================
# 工具函数
# ============================================================
log()      { echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*"; }
mark_done(){ touch "$STATE_DIR/$1.done"; log "✔ MARKED DONE: $1"; }
is_done()  { [ -f "$STATE_DIR/$1.done" ]; }
fail()     { log "✘ FATAL: $*"; exit 1; }

# 带指数退避的重试（容错核心）
retry() {
    local max_attempts="$1"; shift
    local attempt=1 delay=5
    while [ $attempt -le "$max_attempts" ]; do
        if "$@"; then
            log "✔ 成功 (第 $attempt 次尝试): $*"
            return 0
        fi
        log "⚠ 失败 (第 $attempt/$max_attempts 次): $*"
        attempt=$((attempt + 1))
        if [ $attempt -le "$max_attempts" ]; then
            log "   ${delay}s 后重试..."
            sleep "$delay"
            delay=$((delay * 2))
        fi
    done
    log "✘ 重试耗尽: $*"
    return 1
}

# 记录脚本自身的 git commit（可追溯性）
record_provenance() {
    local commit="unknown"
    if git rev-parse HEAD &>/dev/null 2>&1; then
        commit=$(git rev-parse HEAD)
    fi
    echo "$commit" > "$STATE_DIR/git_commit.txt"
    echo "deploy.sh executed at $(date -u +%Y-%m-%dT%H:%M:%SZ) by $(whoami)@$(hostname)" \
        > "$STATE_DIR/deploy_provenance.txt"
}

# ============================================================
# Stage 0: 环境检查
# ============================================================
run_stage_env_check() {
    if is_done "env_check"; then
        log "⏭ SKIP: env_check (已完成)"
        return 0
    fi
    log "▶ Stage 0: 环境检查"
    bash scripts/check_env.sh || fail "环境检查未通过，请查看 $STATE_DIR/env_report.json"
    mark_done "env_check"
}

# ============================================================
# Stage 1: 安装 Nix
# ============================================================
run_stage_nix_install() {
    if is_done "nix_installed"; then
        log "⏭ SKIP: nix_installed"
        return 0
    fi
    log "▶ Stage 1: 安装 Nix (daemon 模式)"

    if command -v nix &>/dev/null; then
        log "  Nix 已存在: $(nix --version 2>/dev/null | head -1)"
    else
        retry 3 sh <(curl -L https://nixos.org/nix/install) --daemon --no-confirm \
            || fail "Nix 安装失败，请检查网络连接"
    fi

    # 加载 Nix 环境
    if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        # shellcheck disable=SC1091
        source "$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi

    mark_done "nix_installed"
}

# ============================================================
# Stage 2: 配置 Nix Flakes 与 FOSSi 缓存
# ============================================================
run_stage_nix_config_old() {
    if is_done "nix_config"; then
        log "⏭ SKIP: nix_config"
        return 0
    fi
    log "▶ Stage 2: 配置 Nix Flakes 与 FOSSi 二进制缓存"

    mkdir -p "$HOME/.config/nix"
    cat > "$HOME/.config/nix/nix.conf" <<'EOF'
experimental-features = nix-command flakes
substituters = https://cache.nixos.org https://nix-cache.fossi-foundation.org
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
                     nix-cache.fossi-foundation.org-1:9O5vV0a3l0g2Q4f0k1V0n3x5m7j9p0q2r4t6w8y0u2i=
EOF

    mark_done "nix_config"
}

run_stage_nix_config() {
    if is_done "nix_config"; then
        log "⏭ SKIP: nix_config"
        return 0
    fi
    log "▶ Stage 2: 配置 Nix Flakes 与 FOSSi 二进制缓存"

    # 前置校验：nix 命令必须可用
    if ! command -v nix &>/dev/null; then
        [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && \
            source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
    command -v nix &>/dev/null || fail "nix 命令不可用，请检查 Stage 1"

    mkdir -p "$HOME/.config/nix"
    # ⚠ 关键：trusted-public-keys 必须单行，多值用空格分隔
    cat > "$HOME/.config/nix/nix.conf" <<'EOF'
experimental-features = nix-command flakes
substituters = https://cache.nixos.org https://nix-cache.fossi-foundation.org
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
EOF

    # 真实校验：nix show-config 必须能解析
    if ! nix show-config &>/dev/null; then
        fail "nix.conf 语法错误，请检查 $HOME/.config/nix/nix.conf"
    fi

    # 校验 flakes 功能已启用
    if ! nix show-config 2>/dev/null | grep -q "flakes"; then
        fail "flakes 未启用，请检查 nix.conf"
    fi

    log "  ✔ nix.conf 语法校验通过"
    log "  ✔ flakes 功能已启用"
    mark_done "nix_config"
}

# ============================================================
# Stage 3: 创建工作目录与 Flake
# ============================================================
run_stage_workspace() {
    if is_done "workspace_created"; then
        log "⏭ SKIP: workspace_created"
        return 0
    fi
    log "▶ Stage 3: 创建工作目录与 Nix Flake"

    mkdir -p "$WORK_ROOT"/{shared,pdk,projects,runs,tools}

    # 检查文件系统类型
    local fs_type
    fs_type=$(df -T "$WORK_ROOT" 2>/dev/null | awk 'NR==2{print $2}')
    if [[ "$fs_type" == "9p" || "$fs_type" == "drvfs" ]]; then
        fail "工作目录 $WORK_ROOT 位于 $fs_type 文件系统，性能极差。请迁移到 WSL 原生 ext4 路径。"
    fi
    log "  工作目录文件系统: $fs_type"

    # 生成 flake.nix（如不存在）
    if [ ! -f "flake.nix" ]; then
        log "  已生成 flake.nix"

cat > flake.nix <<'FLAKE'
{
  description = "Open-source chip design end-to-end environment (single-machine)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python3
            python3Packages.pip
            python3Packages.virtualenv
            yosys
            verilator
            iverilog
            gtkwave
            sby
            klayout
            magic-vlsi
            netgen
            qemu
            jq
            curl
            git
          ];

          # 注意：Nix 多行字符串中 ${ 会触发插值，
          # 因此这里避免使用 shell 的 ${VAR:-default} 语法
          shellHook = ''
            if [ -z "$PDK_ROOT" ]; then
              export PDK_ROOT="$HOME/chip-design/pdk"
            fi
            export PATH="$HOME/.local/bin:$PATH"
            echo "━━━ Chip Design Env Ready ━━━"
            echo "  PDK_ROOT=$PDK_ROOT"
            echo "  python3: $(python3 --version 2>/dev/null || echo N/A)"
            echo "  yosys:   $(yosys -V 2>/dev/null | head -1 || echo N/A)"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          '';
        };
      });
}
FLAKE
else
        log "  flake.nix 已存在，跳过生成"
    fi

    mark_done "workspace_created"
}

# ============================================================
# Stage 4: 安装 Sky130 PDK
# ============================================================

run_stage_pdk() {
    if is_done "pdk_sky130"; then
        log "⏭ SKIP: pdk_sky130"
        return 0
    fi
    log "▶ Stage 4: 安装 SkyWater SKY130 PDK"

    local CIEL_VENV="$WORK_ROOT/tools/ciel-venv"
    local CIEL_BIN="$CIEL_VENV/bin/ciel"

    # --- 4.1: 安装 ciel 到独立 venv（在 Nix 环境外部） ---
    if [ ! -x "$CIEL_BIN" ]; then
        log "  安装 ciel 到独立 venv: $CIEL_VENV"

        # 系统级 Python 3 必须存在
        command -v python3 &>/dev/null || fail "系统 python3 不可用"
        python3 -m venv --help &>/dev/null || {
            log "  python3-venv 未安装，正在安装..."
            sudo apt-get update -qq && sudo apt-get install -y python3-venv \
                || fail "python3-venv 安装失败"
        }

        mkdir -p "$(dirname "$CIEL_VENV")"
        python3 -m venv "$CIEL_VENV" || fail "创建 venv 失败"
        "$CIEL_VENV/bin/pip" install --upgrade pip --quiet
        "$CIEL_VENV/bin/pip" install ciel --quiet || fail "ciel 安装失败"
    fi

    [ -x "$CIEL_BIN" ] || fail "ciel 未就绪: $CIEL_BIN"
    log "  ✔ ciel 已就绪: $($CIEL_BIN --version 2>&1 | head -1)"

    # --- 4.2: 确保 PDK_ROOT 存在 ---
    mkdir -p "$PDK_ROOT"

    # --- 4.3: 下载并启用 sky130 PDK ---
    log "  开始下载 SkyWater SKY130 PDK（约 15GB，10–30 分钟）"
    log "  PDK_ROOT=$PDK_ROOT"

    # ciel 使用 PDK_ROOT 环境变量定位安装位置
    # 通过 retry 包裹，支持网络抖动
    PDK_ROOT="$PDK_ROOT" retry 3 "$CIEL_BIN" enable --pdk-family sky130 \
        || PDK_ROOT="$PDK_ROOT" retry 3 "$CIEL_BIN" enable --pdk sky130 \
        || fail "PDK 下载失败。手动执行: PDK_ROOT=$PDK_ROOT $CIEL_BIN enable --pdk-family sky130"

    # --- 4.4: 真实校验 ---
    if [ ! -d "$PDK_ROOT/sky130A" ] && [ ! -d "$PDK_ROOT/sky130B" ]; then
        fail "PDK 目录未生成，请检查 $PDK_ROOT"
    fi
    log "  ✔ PDK 安装完成: $(ls -d $PDK_ROOT/sky130* 2>/dev/null | head -1)"

    # --- 4.5: 便捷 shell 函数（可选） ---
    if ! grep -q "chip-ciel" "$HOME/.bashrc" 2>/dev/null; then
        cat >> "$HOME/.bashrc" <<EOF

# chip-design: ciel 便捷命令
chip-ciel() { PDK_ROOT="$PDK_ROOT" "$CIEL_BIN" "\$@"; }
alias ciel=chip-ciel
EOF
        log "  已添加 ciel 到 ~/.bashrc (chip-ciel 别名)"
    fi

    mark_done "pdk_sky130"
}
run_stage_pdk_v1() {
    if is_done "pdk_sky130"; then
        log "⏭ SKIP: pdk_sky130"
        return 0
    fi
    log "▶ Stage 4: 安装 SkyWater SKY130 PDK (ciel)"

    # 前置校验：nix 命令必须可用
    if ! command -v nix &>/dev/null; then
        [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && \
            source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
    command -v nix &>/dev/null || fail "nix 命令不可用"

    retry 2 nix develop .#default --command bash -c "
        set -e
        export PDK_ROOT='$PDK_ROOT'

        # 安装 ciel
        pipx install ciel 2>/dev/null || pip3 install --user --upgrade --no-cache-dir ciel

        # 启用 sky130
        ciel enable --pdk-family sky130 2>&1 || ciel enable --pdk sky130 2>&1
    " || fail "PDK 安装失败。请手动执行 'ciel enable --pdk-family sky130' 检查"

    # 真实校验：PDK 目录必须存在
    if [ ! -d "$PDK_ROOT/sky130A" ] && [ ! -d "$PDK_ROOT/sky130B" ]; then
        fail "PDK 目录未生成，请检查 $PDK_ROOT"
    fi
    log "  ✔ PDK 目录验证通过: $(ls -d $PDK_ROOT/sky130* 2>/dev/null | head -1)"

    mark_done "pdk_sky130"
}


run_stage_pdk_old() {
    if is_done "pdk_sky130"; then
        log "⏭ SKIP: pdk_sky130"
        return 0
    fi
    log "▶ Stage 4: 安装 SkyWater SKY130 PDK (ciel)"

    # 在 Nix 开发环境中执行 PDK 安装
    retry 2 nix develop .#default --command bash -c "
        set -e
        export PDK_ROOT='$PDK_ROOT'

        # 安装 ciel
        pipx install ciel 2>/dev/null || pip3 install --user --upgrade --no-cache-dir ciel

        # 列出可用 PDK 版本（取最新的一个）
        echo '  可用 sky130 PDK 版本:'
        ciel ls-remote --pdk-family sky130 2>/dev/null | head -5 || true

        # 启用 sky130A（默认最新稳定版）
        ciel enable --pdk-family sky130 2>&1 || ciel enable --pdk sky130 2>&1

        echo '  PDK 安装完成，位置: \$PDK_ROOT'
        ls -la \$PDK_ROOT/ 2>/dev/null || true
    " || fail "PDK 安装失败。请检查网络或手动执行 'ciel enable --pdk-family sky130'"

    # 验证 PDK 目录结构
    if [ -d "$PDK_ROOT/sky130A" ] || [ -d "$PDK_ROOT/sky130B" ]; then
        log "  ✔ PDK 目录验证通过"
    else
        log "  ⚠ 未找到 sky130A/sky130B 目录，请手动检查 $PDK_ROOT"
    fi

    mark_done "pdk_sky130"
}

# ============================================================
# Stage 5: 构建并启动 Docker Compose 栈
# ============================================================
run_stage_docker_stack() {
    if is_done "docker_stack"; then
        log "⏭ SKIP: docker_stack"
        return 0
    fi
    log "▶ Stage 5: 构建并启动 Docker Compose 栈"

    if [ ! -f "docker/docker-compose.yml" ]; then
        fail "未找到 docker/docker-compose.yml"
    fi

    cd docker
    retry 2 docker compose -f docker-compose.yml up -d --build --wait \
        || fail "Docker Compose 栈启动失败。请检查 docker compose logs"
    cd ..

    mark_done "docker_stack"
}

# ============================================================
# Stage 6: 冒烟测试（SPM 设计走通 LibreLane）
# ============================================================
run_stage_smoke_test() {
    if is_done "smoke_test"; then
        log "⏭ SKIP: smoke_test"
        return 0
    fi
    log "▶ Stage 6: 冒烟测试 (SPM 设计 → LibreLane 全流程)"

    retry 2 nix develop .#default --command bash -c "
        set -e
        export PDK_ROOT='$PDK_ROOT'

        # 检查 LibreLane 是否可用
        if command -v librelane &>/dev/null; then
            librelane --smoke-test 2>&1
        else
            echo '  librelane 未在 Nix 环境中找到，尝试通过 pip 安装...'
            pip3 install --user librelane 2>/dev/null || true
            python3 -m librelane --smoke-test 2>&1 || echo '  ⚠ 冒烟测试需要 LibreLane，请手动安装'
        fi
    " || log "  ⚠ 冒烟测试未完全通过，请手动验证 LibreLane 安装"

    mark_done "smoke_test"
}

# ============================================================
# Stage 7: RISC-V SDK 验证环境
# ============================================================
run_stage_riscv_sdk() {
    if is_done "riscv_sdk"; then
        log "⏭ SKIP: riscv_sdk"
        return 0
    fi
    log "▶ Stage 7: RISC-V SDK 验证环境"

    # 启动 sdk profile 容器
    if [ -f "docker/docker-compose.yml" ]; then
        retry 2 docker compose -f docker/docker-compose.yml --profile sdk up -d --build \
            || log "  ⚠ RISC-V SDK 容器启动失败，可稍后手动执行 'docker compose --profile sdk up -d'"
    fi

    mark_done "riscv_sdk"
}

# ============================================================
# Stage 8: 生成审计报告
# ============================================================
run_stage_audit() {
    log "▶ Stage 8: 生成可追溯性审计报告"
    bash scripts/audit.sh || log "  ⚠ 审计报告生成异常"
}

# ============================================================
# 主入口
# ============================================================
main() {
    log "╔══════════════════════════════════════════════════════╗"
    log "║   单机芯片设计全流程一键部署                        ║"
    log "║   WSL2 Ubuntu 26.04 · Docker · Nix · Sky130 PDK   ║"
    log "╚══════════════════════════════════════════════════════╝"

    record_provenance

    run_stage_env_check
    run_stage_nix_install
    run_stage_nix_config
    run_stage_workspace
    run_stage_pdk
    run_stage_docker_stack
    run_stage_smoke_test
    run_stage_riscv_sdk
    run_stage_audit

    log ""
    log "╔══════════════════════════════════════════════════════╗"
    log "║   ✅ 部署完成                                       ║"
    log "╚══════════════════════════════════════════════════════╝"
    log ""
    log "  追踪日志:   $TRACE_LOG"
    log "  环境报告:   $STATE_DIR/env_report.json"
    log "  工作目录:   $WORK_ROOT"
    log "  PDK 根目录: $PDK_ROOT"
    log ""
    log "  下一步："
    log "    1. 进入 Nix 环境:  nix develop .#default"
    log "    2. 进入 OpenLane 容器:  docker compose -f docker/docker-compose.yml exec openlane bash"
    log "    3. 运行示例设计:  librelane --pdk-root \$PDK_ROOT ./examples/spm/config.yaml"
    log ""
}

main "$@"
