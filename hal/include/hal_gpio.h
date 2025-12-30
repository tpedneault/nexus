/**
 * @file hal_gpio.h
 * @brief GPIO Hardware Abstraction Layer
 * 
 * Platform-independent GPIO interface. This header defines the public API
 * that is implemented by platform-specific HAL implementations.
 */

#ifndef HAL_GPIO_H
#define HAL_GPIO_H

#include <stdint.h>

/**
 * @brief GPIO port identifiers
 */
typedef enum {
    HAL_GPIO_PORT_A,
    HAL_GPIO_PORT_B
} hal_gpio_port_t;

/**
 * @brief GPIO pin identifiers
 */
typedef enum {
    HAL_GPIO_PIN_0 = 0,
    HAL_GPIO_PIN_1 = 1,
    HAL_GPIO_PIN_2 = 2,
    HAL_GPIO_PIN_3 = 3,
    HAL_GPIO_PIN_4 = 4,
    HAL_GPIO_PIN_5 = 5,
    HAL_GPIO_PIN_6 = 6,
    HAL_GPIO_PIN_7 = 7
} hal_gpio_pin_t;

/**
 * @brief GPIO pin direction
 */
typedef enum {
    HAL_GPIO_DIR_INPUT = 0,
    HAL_GPIO_DIR_OUTPUT = 1
} hal_gpio_direction_t;

/**
 * @brief GPIO pin state
 */
typedef enum {
    HAL_GPIO_STATE_LOW = 0,
    HAL_GPIO_STATE_HIGH = 1
} hal_gpio_state_t;

/**
 * @brief Initialize GPIO peripheral
 * @return 0 on success, negative error code on failure
 */
int32_t hal_gpio_init(void);

/**
 * @brief Set pin direction
 * @param port GPIO port
 * @param pin Pin number
 * @param dir Direction (input/output)
 * @return 0 on success, negative error code on failure
 */
int32_t hal_gpio_set_direction(hal_gpio_port_t port, hal_gpio_pin_t pin, hal_gpio_direction_t dir);

/**
 * @brief Write pin state
 * @param port GPIO port
 * @param pin Pin number
 * @param state Pin state (low/high)
 * @return 0 on success, negative error code on failure
 */
int32_t hal_gpio_write(hal_gpio_port_t port, hal_gpio_pin_t pin, hal_gpio_state_t state);

/**
 * @brief Toggle pin state
 * @param port GPIO port
 * @param pin Pin number
 * @return 0 on success, negative error code on failure
 */
int32_t hal_gpio_toggle(hal_gpio_port_t port, hal_gpio_pin_t pin);

/**
 * @brief Read pin state
 * @param port GPIO port
 * @param pin Pin number
 * @param state Pointer to store pin state
 * @return 0 on success, negative error code on failure
 */
int32_t hal_gpio_read(hal_gpio_port_t port, hal_gpio_pin_t pin, hal_gpio_state_t *state);

#endif /* HAL_GPIO_H */
