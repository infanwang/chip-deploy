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
            # ── Python ──
            python3
            python3Packages.pip
            python3Packages.virtualenv

            # ── RTL 综合与形式验证 ──
            yosys
            sby

            # ── 仿真与波形 ──
            verilator
            iverilog
            gtkwave

            # ── 物理设计与版图 ──
            magic-vlsi
            klayout
            netgen

            # ── 系统级仿真 ──
            qemu

            # ── 编译工具链（Verilator C++ testbench 与本地编译必需）──
            gcc
            gnumake
            pkg-config
            gnum4

            # ── 工具 ──
            jq
            curl
            git
          ];

          shellHook = ''
            if [ -z "$PDK_ROOT" ]; then
              export PDK_ROOT="$HOME/chip-design/pdk"
            fi
            if [ -z "$PDK" ]; then
              export PDK="sky130A"
            fi
            export PATH="$HOME/.local/bin:$PATH"
            echo "━━━ Chip Design Env Ready ━━━"
            echo "  PDK_ROOT=$PDK_ROOT"
            echo "  PDK=$PDK"
            echo "  yosys:     $(yosys -V 2>/dev/null | head -1 || echo N/A)"
            echo "  verilator: $(verilator --version 2>/dev/null | head -1 || echo N/A)"
            echo "  gcc:       $(gcc --version 2>/dev/null | head -1 || echo N/A)"
            echo "  make:      $(make --version 2>/dev/null | head -1 || echo N/A)"
            echo "  magic:     $(command -v magic >/dev/null && echo available || echo N/A)"
            echo "  klayout:   $(command -v klayout >/dev/null && echo available || echo N/A)"
            echo "  netgen:    $(command -v netgen >/dev/null && echo available || echo N/A)"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          '';
        };
      });
}
