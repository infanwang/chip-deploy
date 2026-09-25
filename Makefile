.PHONY: help check deploy audit resume baseline clean

help:
@echo "chip-deploy 快捷入口"
@echo " make check — 环境检查"
@echo " make deploy — 一键部署"
@echo " make audit — 审计报告"
@echo " make resume — 查看状态"
@echo " make baseline — 基线化到 git"
@echo " make clean — 清理 .state"

check:
bash scripts/check_env.sh

deploy:
bash scripts/deploy.sh

audit:
bash scripts/audit.sh

resume:
bash scripts/resume.sh

baseline:
bash scripts/baseline.sh

clean:
@read -p "确认清理 .state/？[y/N] " ans && [ "$$ans" = "y" ] && rm -rf .state/ || echo "已取消"
