.PHONY: sim lint synth clean
sim:
iverilog -o sim_top top.v tb.v && vvp sim_top
lint:
verilator --lint-only -Wall top.v
synth:
LIB=PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib; \ yosys -p "read_verilog top.v; synth -top top; dfflibmap -liberty LIB; abc -liberty $$LIB; stat"
clean:
rm -f sim_top wave.vcd top_synth.v && rm -rf obj_dir
