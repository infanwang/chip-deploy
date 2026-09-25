#!/usr/bin/env bash

scripts/baseline.sh — 基线化到 git
set -euo pipefail

REPO_DIR="
(
c
d
"
(cd"(dirname "0")/.." && pwd)" cd "REPO_DIR"

VERSION=
(
c
a
t
V
E
R
S
I
O
N
2
>
/
d
e
v
/
n
u
l
l
∣
∣
e
c
h
o
"
0.0.0
"
)
T
I
M
E
S
T
A
M
P
=
(catVERSION2>/dev/null∣∣echo"0.0.0")TIMESTAMP=(date -u +%Y%m%d-%H%M%S)
TAG="v${VERSION}"

echo "════════════════════════════════════════════════"
echo " 基线化 chip-deploy v${VERSION}"
echo "════════════════════════════════════════════════"

if [ ! -d .git ]; then
echo "▶ 初始化 git 仓库..."
git init -b main
git config user.email "chip-deploy@localhost"
git config user.name "chip-deploy"
fi

echo "▶ 清理运行时产物..."
rm -rf .state/ examples//runs/ examples//obj_dir/ 2>/dev/null || true

echo "▶ 暂存所有文件..."
git add -A

echo "▶ 提交..."
git commit -m "baseline: v
V
E
R
S
I
O
N
a
t
VERSIONat{TIMESTAMP}" || echo " (无变化)"

echo "▶ 打标签..."
git tag -a "
T
A
G
"
−
m
"
B
a
s
e
l
i
n
e
TAG"−m"BaselineVERSION" 2>/dev/null || echo " (标签已存在)"

echo ""
echo "✅ 基线完成"
echo " 分支: 
(
g
i
t
b
r
a
n
c
h
−
−
s
h
o
w
−
c
u
r
r
e
n
t
)
"
e
c
h
o
"
提交
:
(gitbranch−−show−current)"echo"提交:(git rev-parse --short HEAD)"
echo " 标签: $TAG"
echo ""
echo "▶ 统计"
git ls-files | wc -l | xargs echo " 已追踪文件:"
du -sh .git | cut -f1 | xargs echo " .git 体积:"
