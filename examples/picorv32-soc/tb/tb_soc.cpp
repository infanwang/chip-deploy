#include "Vsoc_top.h"
#include "verilated.h"
#include <cstdio>
#include <cstdint>

static Vsoc_top* dut;
static uint64_t main_time = 0;
static const uint64_t MAX_TIME = 50000000;  // 50 ms

// UART RX 解码
struct UartRx {
    enum State { IDLE, START, DATA } state = IDLE;
    uint32_t div = 0;
    int bit = 0;
    uint8_t shift = 0;
    int count = 0;
} uart;

void tick() {
    dut->clk = 0; dut->eval(); main_time += 5;
    dut->clk = 1; dut->eval(); main_time += 5;

    int tx = dut->uart_tx;
    switch (uart.state) {
        case UartRx::IDLE:
            if (tx == 0) { uart.state = UartRx::START; uart.div = 675; uart.bit = 0; uart.shift = 0; }
            break;
        case UartRx::START:
            if (uart.div > 0) uart.div--;
            else { uart.state = UartRx::DATA; uart.div = 450; uart.shift = tx; uart.bit = 1; }
            break;
        case UartRx::DATA:
            if (uart.div > 0) uart.div--;
            else {
                uart.div = 450;
                if (uart.bit < 8) { uart.shift |= (tx << uart.bit); uart.bit++; }
                else {
                    uart.state = UartRx::IDLE;
                    uart.count++;
                    if (uart.shift >= 32 && uart.shift < 127) putchar(uart.shift);
                    else if (uart.shift == 0x0d) putchar('\r');
                    else if (uart.shift == 0x0a) putchar('\n');
                    else printf("[%02x]", uart.shift);
                    fflush(stdout);
                }
            }
            break;
    }
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    dut = new Vsoc_top;

    dut->rst_n = 0; dut->gpio_in = 0;
    for (int i = 0; i < 20; i++) tick();
    dut->rst_n = 1;

    printf("═══ L4: 完整 C 固件验证 ═══\n");
    printf("--- UART 输出 ---\n");

    uint16_t last_gpio = 0;
    while (main_time < MAX_TIME) {
        tick();
        if (dut->gpio_out != last_gpio) last_gpio = dut->gpio_out;
    }

    printf("\n\n=== 结束 ===\n");
    printf("GPIO: 0x%04x\n", dut->gpio_out);
    printf("UART 字符数: %d\n", uart.count);

    delete dut;
    return 0;
}
