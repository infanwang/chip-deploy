# 故障排除手册

汇总 v1.0.0 → v1.4.0 期间遇到的所有问题。

## Docker

### `docker: command not found` in WSL

Docker Desktop → Settings → Resources → WSL Integration → 勾选 Ubuntu-26.04 → Apply。

### `Cannot connect to the Docker daemon`

    sudo service docker start

或启用 systemd：编辑 `/etc/wsl.conf` 加 `[boot] systemd=true`。

## Nix

### `--no-confirm` 无效

Nix 官方安装器参数是 `--yes`：

    sh <(curl -L https://nixos.org/nix/install) --daemon --yes

### `syntax error in configuration line`

`~/.config/nix/nix.conf` 中 `trusted-public-keys` 必须**单行**，多值用空格分隔：

    trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=

### `undefined variable 'magic'`

nixpkgs 中包名是 `magic-vlsi`，不是 `magic`。

### `${VAR:-default}` 语法错误

Nix 多行字符串中 `${` 触发插值。改为：

    if [ -z "$VAR" ]; then
        export VAR=default_value
    fi

## Ciel / PDK

### `ciel enable` 报缺少参数

Ciel 3.0 需要显式 hash：

    HASH=$(ciel ls-remote --pdk-family sky130 | head -1)
    ciel enable --pdk-family sky130 "$HASH"

### PDK 路径不对

实际路径：`$PDK_ROOT/ciel/sky130/versions/<hash>/sky130A`

创建软链接：

    HASH=$(cat $PDK_ROOT/ciel/sky130/current | tr -d '\n')
    ln -sfn "$PDK_ROOT/ciel/sky130/versions/$HASH/sky130A" "$PDK_ROOT/sky130A"

## LibreLane

### `externally-managed-environment` (PEP 668)

Nix Python 禁止 pip 写入。改用独立 venv：

    python3 -m venv ~/chip-design/tools/librelane-venv
    ~/chip-design/tools/librelane-venv/bin/pip install librelane

### `failed building wheel for lln-libparse`

缺 Python.h：

    sudo apt install python3.14-dev

### `invalid command name "remove_from_collection"`

OpenSTA 不支持，SDC 中删除该行，改用：

    set_input_delay -clock clk 5 [all_inputs]

## SoC 流程

### Timer IRQ 不触发

**原因**：counter 复位值 `0xFFFFFFFF`，且 enable 时未重置。

**修复**：`timer.v` 中 enable 上升沿时 `counter <= load_val`。

### IRQ 只触发一次

**原因**：`irq_pending` 持久为 1，无 CPU 写 STATUS 清除。

**修复**：改为**单周期脉冲**：

    always @(posedge clk) begin
        irq <= 1'b0;              // 默认拉低
        if (hit_zero) irq <= 1'b1;  // 单周期置位
    end

### `irq` 端口宽度不匹配

picorv32 的 `irq` 是 **32 位输入**，timer 的 `irq` 是 **1 位输出**。

**正确写法**：

    // picorv32 输入（扩展为 32 位）
    .irq ({31'b0, irq_timer}),
    // timer 输出（原样连接）
    .irq (irq_timer)

### ROM 编码错误（UART 永远发同一字符）

**原因**：RISC-V 机器码手工编码易错，尤其 `jal` 的偏移量。

**修复**：用 Python 生成：

    python3 - <<'PYTHON' > rtl/rom.v
    # U型/I型/S型/B型/J型编码器 + 程序列表
    PYTHON

**常见错误**：

- `jal x0, -8` 编码成 `0xFF1FF06F`（错）→ 正确是 `0xFF9FF06F`
- `jal x0, -32` 编码成 `0xFE1FF06F`（错）→ 正确是 `0xFE5FF06F`（如果是到 -28）

### UART 字符跳跃（+3 而不是 +1）

**不是 Bug**。ROM 不检查 UART busy，连续写被忽略。

**验证方式**：只看**字符是否在递增**，不要求每次 +1。

### SRAM 用寄存器阵列导致布线爆炸

**症状**：首轮 violations > 18,000，面积 4× 膨胀。

**原因**：`reg [31:0] mem [0:255]` 被综合成 8,192 个触发器。

**修复**：使用 **OpenRAM 宏单元**，而非寄存器阵列。推迟到 v1.5.0。

## 流程通用

### Setup/Hold 违例

1. **放宽时钟周期**：`CLOCK_PERIOD: 30`
2. **加强综合优化**：`SYNTH_STRATEGY: "DELAY 0"` + `SYNTH_SIZING: true`
3. **降低布局密度**：`PL_TARGET_DENSITY_PCT: 45`

### Max Slew/Cap 警告（仅 SS 角）

不影响功能，可忽略。SS 工艺角晶体管最慢，Slew/Cap 超标是正常现象。

### 流程中断重跑

用同一 `--run-tag` 自动从断点继续。

## WSL 通用

### 磁盘不自动收缩

    wsl --shutdown
    Optimize-VHD -Path $env:LOCALAPPDATA\Packages\...\ext4.vhdx -Mode Full

### GUI 无法显示

确认 Windows 11 或 Win10 22H2+；`echo $DISPLAY` 应有值。

### 粘贴污染

heredoc 里的 `$` 被 shell 展开。**规则**：

- 用 `<<'EOF'`（单引号保护）
- 避免三反引号，改用 4 空格缩进
- 逐段执行，不要批量粘贴
- 必须用 `Ctrl+Shift+V` 粘贴

## 获取帮助

1. 查看 `.state/deploy_trace.log`（全量日志）
2. 查看 `.state/logs/`（各 stage 独立日志）
3. 查看 LibreLane `runs/<tag>/error.log`
4. 执行 `bash scripts/audit.sh` 生成状态快照
