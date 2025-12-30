/**
 * @file hal_gpio_tms570.c
 * @brief GPIO Hardware Abstraction Layer Implementation for TMS570
 *
 * Wraps HALCoGen GIO functions with the HAL GPIO interface.
 */

#include "hal_gpio.h"
#include "HL_gio.h"

/* Map HAL port enum to HALCoGen port pointers */
static gioPORT_t* get_halcogen_port(hal_gpio_port_t port)
{
    switch (port) {
        case HAL_GPIO_PORT_A:
            return gioPORTA;
        case HAL_GPIO_PORT_B:
            return gioPORTB;
        default:
            return NULL;
    }
}

int32_t hal_gpio_init(void)
{
    gioInit();
    return 0;
}

int32_t hal_gpio_set_direction(hal_gpio_port_t port, hal_gpio_pin_t pin, hal_gpio_direction_t dir)
{
    gioPORT_t* halport = get_halcogen_port(port);

    if (halport == NULL) {
        return -1;  /* Invalid port */
    }

    if (dir == HAL_GPIO_DIR_OUTPUT) {
        halport->DIR |= (1U << pin);
    } else {
        halport->DIR &= ~(1U << pin);
    }

    return 0;
}

int32_t hal_gpio_write(hal_gpio_port_t port, hal_gpio_pin_t pin, hal_gpio_state_t state)
{
    gioPORT_t* halport = get_halcogen_port(port);

    if (halport == NULL) {
        return -1;  /* Invalid port */
    }

    gioSetBit(halport, pin, (uint32_t)state);
    return 0;
}

int32_t hal_gpio_toggle(hal_gpio_port_t port, hal_gpio_pin_t pin)
{
    gioPORT_t* halport = get_halcogen_port(port);

    if (halport == NULL) {
        return -1;  /* Invalid port */
    }

    gioToggleBit(halport, pin);
    return 0;
}

int32_t hal_gpio_read(hal_gpio_port_t port, hal_gpio_pin_t pin, hal_gpio_state_t *state)
{
    gioPORT_t* halport = get_halcogen_port(port);

    if (halport == NULL || state == NULL) {
        return -1;  /* Invalid port or null pointer */
    }

    *state = (hal_gpio_state_t)gioGetBit(halport, pin);
    return 0;
}
