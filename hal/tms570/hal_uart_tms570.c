/**
 * @file hal_uart_tms570.c
 * @brief UART Hardware Abstraction Layer Implementation for TMS570
 *
 * Wraps HALCoGen SCI/LIN functions with the HAL UART interface.
 * Note: LIN1 is used in SCI mode for UART communication with XDS110.
 */

#include "hal_uart.h"
#include "HL_sci.h"
#include <string.h>

/* Map HAL UART instance to HALCoGen SCI base */
static sciBASE_t* get_sci_base(hal_uart_instance_t instance)
{
    switch (instance) {
        case HAL_UART_1:
            return sciREG1;  /* LIN1 in SCI mode (connected to XDS110) */
        case HAL_UART_2:
            return sciREG2;  /* LIN2 in SCI mode */
        default:
            return NULL;
    }
}

int32_t hal_uart_init(hal_uart_instance_t instance, const hal_uart_config_t *config)
{
    sciBASE_t *sci = get_sci_base(instance);

    if (sci == NULL || config == NULL) {
        return -1;
    }

    /* Initialize all SCI peripherals configured in HALCoGen */
    /* This includes SCI1, SCI3, and SCI4 based on HALCoGen settings */
    sciInit();

    /* The config parameter is currently unused but kept for future flexibility */

    return 0;
}

int32_t hal_uart_write(hal_uart_instance_t instance, const uint8_t *data, size_t len)
{
    sciBASE_t *sci = get_sci_base(instance);

    if (sci == NULL || data == NULL) {
        return -1;
    }

    /* Send data using HALCoGen SCI function */
    sciSend(sci, (uint32)len, (uint8 *)data);

    return (int32_t)len;
}

int32_t hal_uart_write_string(hal_uart_instance_t instance, const char *str)
{
    if (str == NULL) {
        return -1;
    }

    size_t len = strlen(str);
    return hal_uart_write(instance, (const uint8_t *)str, len);
}

int32_t hal_uart_read(hal_uart_instance_t instance, uint8_t *data, size_t len)
{
    sciBASE_t *sci = get_sci_base(instance);

    if (sci == NULL || data == NULL) {
        return -1;
    }

    /* Check if data is available */
    if ((sci->FLR & (uint32)SCI_RX_INT) == 0U) {
        return 0;  /* No data available */
    }

    /* Receive data using HALCoGen SCI function */
    sciReceive(sci, (uint32)len, data);

    return (int32_t)len;
}

int32_t hal_uart_data_available(hal_uart_instance_t instance)
{
    sciBASE_t *sci = get_sci_base(instance);

    if (sci == NULL) {
        return -1;
    }

    /* Check RX interrupt flag */
    return ((sci->FLR & (uint32)SCI_RX_INT) != 0U) ? 1 : 0;
}
