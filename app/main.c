/**
 * @file main.c
 * @brief Nexus Flight Software - Application Entry Point
 *
 * This is the main application entry point. BSP startup code
 * calls this after system initialization.
 */

#include "hal_gpio.h"
#include "hal_uart.h"

/**
 * @brief Entry point
 */
int main(void)
{
    volatile int i;

    /* Initialize UART for debug output (115200 baud via XDS110 SCI1) */
    hal_uart_config_t uart_config = {
        .baudrate = 115200
    };
    hal_uart_init(HAL_UART_1, &uart_config);

    /* Send simple test message */
    hal_uart_write_string(HAL_UART_1, "\r\n=== Nexus Flight Software ===\r\n");

    /* Initialize GPIO */
    hal_gpio_init();

    /* Configure USER LED as output (GIOB[6]) */
    hal_gpio_set_direction(HAL_GPIO_PORT_B, HAL_GPIO_PIN_6, HAL_GPIO_DIR_OUTPUT);

    /* Main application loop, blink LED and send status */
    while (1) {
        /* Toggle LED */
        hal_gpio_toggle(HAL_GPIO_PORT_B, HAL_GPIO_PIN_6);

        /* Simple delay */
        for (i = 0; i < 10000000; i++);
    }

    return 0;
}
