# 架构说明

对应版本：**v1.4.0**

## 三层模型

    ┌────────────────────────────────────────────────┐
    │  环境基座层    Nix Flakes + flake.lock          │
    │  ─────────────────────────────────────────────  │
    │  • 密码学锁定所有工具版本                        │
    │  • 跨机器可复现                                  │
    ├────────────────────────────────────────────────┤
    │  编排执行层    Bash 脚本 + .state 标记          │
    │  ─────────────────────────────────────────────  │
    │  • 幂等：检查标记 → 跳过或执行                   │
    │  • 容错：指数退避重试                            │
    │  • 可追溯：ISO 8601 时间戳日志                   │
    ├────────────────────────────────────────────────┤
    │  工具运行时层  Docker 容器 + PDK 卷              │
    │  ─────────────────────────────────────────────  │
    │  • LibreLane 容器化执行 RTL-to-GDSII            │
    │  • PDK 共享：$HOME/chip-design/pdk              │
    └────────────────────────────────────────────────┘

## 数据流

    RTL (.v)
      → Yosys 综合 → 门级网表
      → OpenROAD Floorplan/PDN/Place/CTS/Route
      → Magic/Netgen DRC/LVS
      → OpenSTA 时序分析
      → KLayout 导出 → GDSII

## SoC 架构（v1.3.0+）

    ┌─────────────────────────────────────────────────────┐
    │                    SoC Top                          │
    ├─────────────────────────────────────────────────────┤
    │  ┌──────────┐    ┌──────────────────────────────┐  │
    │  │ PicoRV32 │    │      Wishbone Bus            │  │
    │  │  Core    │◄──►│   (32-bit addr, 32-bit data) │  │
    │  └──────────┘    └──────┬───┬───┬───┬────┬───────┘  │
    │                         │   │   │   │    │          │
    │                    ┌────┴┐ ┌┴──┐┌─┴─┐┌─┴┐┌──┴──┐   │
    │                    │ ROM │ │Tim││GPI││UA││ SPI │   │
    │                    │0x00 │ │0x1││0x2││0x││ 0x4 │   │
    │                    └─────┘ └───┘└───┘└──┘└─────┘   │
    └─────────────────────────────────────────────────────┘

**地址解码**（高 4 位）：

    dev_sel = mem_addr[31:28]

    sel_sram  = (dev_sel == 4'h0)   // 当前用 ROM
    sel_timer = (dev_sel == 4'h1)
    sel_gpio  = (dev_sel == 4'h2)
    sel_uart  = (dev_sel == 4'h3)
    sel_spi   = (dev_sel == 4'h4)

## 外设设计

### Timer（v1.4.0）

**寄存器**：

| 偏移 | 名称 | 读/写 | 功能 |
| :--- | :--- | :--- | :--- |
| 0x00 | LOAD | RW | 加载值 |
| 0x04 | CTRL | RW | [0]=enable, [1]=oneshot |
| 0x08 | STATUS | RW | [0]=irq_pending（W1C）|
| 0x0C | VALUE | RO | 当前计数值 |

**关键设计**：
- enable 上升沿时 counter 重置为 load_val
- IRQ 输出为**单周期脉冲**（不依赖 CPU 清除）

### UART TX

**寄存器**：

| 偏移 | 名称 | 读/写 | 功能 |
| :--- | :--- | :--- | :--- |
| 0x00 | TX | WO | 写数据发送 |
| 0x04 | STATUS | RO | [0]=busy |

**波特率**：`DIV = 450`，45 MHz 下约 100 kbaud

### GPIO

**寄存器**：

| 偏移 | 名称 | 读/写 | 功能 |
| :--- | :--- | :--- | :--- |
| 0x00 | IN | RO | 输入电平 |
| 0x04 | OUT | RW | 输出电平 |

### SPI Master

**寄存器**：

| 偏移 | 名称 | 读/写 | 功能 |
| :--- | :--- | :--- | :--- |
| 0x00 | TX | WO | 写数据发送 |
| 0x04 | RX | RO | 接收数据 |
| 0x08 | STATUS | RO | [0]=busy |

**模式**：CPOL=0, CPHA=0, MSB first

## 目录约定

    ~/chip-design/
    ├── pdk/          # PDK（ciel 管理，2.2 GB）
    ├── shared/       # 设计工程 + runs/
    ├── projects/     # 临时测试
    ├── runs/         # 通用输出
    └── tools/        # venv（ciel、librelane）

## 状态管理

**`.state/` 目录**（幂等核心）：

    .state/
    ├── env_check.done          # 环境检查完成
    ├── nix_installed.done      # Nix 安装完成
    ├── nix_config.done         # Nix 配置完成
    ├── workspace_created.done  # 工作目录创建
    ├── pdk_sky130.done         # PDK 安装完成
    ├── docker_stack.done       # Docker 栈就绪
    ├── smoke_test.done         # 冒烟测试通过
    ├── riscv_sdk.done          # RISC-V SDK 就绪
    ├── deploy_trace.log        # 全量日志
    ├── env_report.json         # 环境快照
    └── git_commit.txt          # 脚本版本

**幂等性**：每个 stage 完成后写标记，重跑时跳过。
