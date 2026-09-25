/* PicoRV32 SoC 固件：UART + GPIO */
#include <stdint.h>

#define GPIO_BASE   0x20000000
#define UART_BASE   0x30000000

#define REG32(addr) (*(volatile uint32_t *)(addr))

#define GPIO_OUT     REG32(GPIO_BASE + 0x04)
#define UART_TX      REG32(UART_BASE + 0x00)
#define UART_STATUS  REG32(UART_BASE + 0x04)

static void delay(volatile int n) {
    while (n-- > 0);
}

void uart_putc(char c) {
    while (UART_STATUS & 0x1);
    UART_TX = c;
    delay(100);
}

void uart_puts(const char *s) {
    while (*s) uart_putc(*s++);
}

void uart_putu(uint32_t n) {
    char buf[12];
    int i = 0;
    if (n == 0) { uart_putc('0'); return; }
    while (n > 0) {
        buf[i++] = '0' + (n % 10);
        n /= 10;
    }
    while (i > 0) uart_putc(buf[--i]);
}

int main(void) {
    uart_puts("PicoRV32 SoC @ 40 MHz\r\n");
    uart_puts("UART + GPIO test started\r\n");

    uint32_t counter = 0;
    while (1) {
        counter++;
        if ((counter % 100) == 0) {
            uart_puts("tick=");
            uart_putu(counter);
            uart_puts("\r\n");
        }
        GPIO_OUT = counter & 0xFFFF;
    }
    return 0;
}
