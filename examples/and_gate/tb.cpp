#include "Vtop.h"
#include "verilated.h"
#include <cstdio>
int main(int argc, char** argv) {
Verilated::commandArgs(argc, argv);
Vtop* dut = new Vtop;
int failures = 0;
for (int a = 0; a < 2; a++)
for (int b = 0; b < 2; b++) {
dut->a = a; dut->b = b; dut->eval();
int expected = a & b;
printf("a=%d b=%d y=%d %s\n", a, b, dut->y, dut->y==expected?"PASS":"FAIL");
if (dut->y != expected) failures++;
}
delete dut;
return failures;
}
