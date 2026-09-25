
PicoRV32 示例
准备源码
bash
cd ~/chip-design/shared
git clone https://gitcode.com/gh_mirrors/pic/picorv32.git
cd picorv32
cp ~/chip-deploy/examples/picorv32/config.yaml .
cp ~/chip-deploy/examples/picorv32/constraint.sdc .
运行
bash
librelane --dockerized --pdk-root $PDK_ROOT --pdk sky130A \
    --run-tag picorv32-run-01 config.yaml
预期结果
11,872 标准单元

191,277 µm² 面积

7.87 mW 功耗

DRC/LVS/Antenna 全通过

~14 分钟
