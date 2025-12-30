/**
 * @file hal_uart.h
 * @brief UART Hardware Abstraction Layer
 *
 * Platform-independent UART interface. This header defines the public API
 * that is implemented by platform-specific HAL implementations.
 */

#ifndef HAL_UART_H
#define HAL_UART_H

#include <stdint.h>
#include <stddef.h>

/**
 * @brief UART instance identifiers
 */
typedef enum {
    HAL_UART_1,  /* UART/SCI1 (debug console) */
    HAL_UART_2,  /* UART/SCI2 */
    HAL_UART_3,  /* UART/SCI3 */
    HAL_UART_4,  /* UART/SCI4 */
    HAL_UART_COUNT
} hal_uart_instance_t;

/**
 * @brief UART configuration structure
 */
typedef struct {
    uint32_t baudrate;      /* Baud rate (e.g., 115200) */
} hal_uart_config_t;

/**
 * @brief Initialize UART peripheral
 * @param instance UART instance
 * @param config UART configuration
 * @return 0 on success, negative error code on failure
 */
int32_t hal_uart_init(hal_uart_instance_t instance, const hal_uart_config_t *config);

/**
 * @brief Write data to UART
 * @param instance UART instance
 * @param data Pointer to data buffer
 * @param len Number of bytes to write
 * @return Number of bytes written, or negative error code on failure
 */
int32_t hal_uart_write(hal_uart_instance_t instance, const uint8_t *data, size_t len);

/**
 * @brief Write a null-terminated string to UART
 * @param instance UART instance
 * @param str Null-terminated string
 * @return Number of bytes written, or negative error code on failure
 */
int32_t hal_uart_write_string(hal_uart_instance_t instance, const char *str);

/**
 * @brief Read data from UART (non-blocking)
 * @param instance UART instance
 * @param data Pointer to buffer to store received data
 * @param len Maximum number of bytes to read
 * @return Number of bytes read, or negative error code on failure
 */
int32_t hal_uart_read(hal_uart_instance_t instance, uint8_t *data, size_t len);

/**
 * @brief Check if data is available to read
 * @param instance UART instance
 * @return 1 if data available, 0 if not, negative error code on failure
 */
int32_t hal_uart_data_available(hal_uart_instance_t instance);

#endif /* HAL_UART_H */
