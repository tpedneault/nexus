# =============================================================================
# Hardware Abstraction Layer (HAL)
# =============================================================================

# Platform-specific HAL implementation
if(MCU_FAMILY STREQUAL "TMS570")
    set(HAL_PLATFORM_SOURCES
        tms570/hal_gpio_tms570.c
        tms570/hal_uart_tms570.c
    )
    set(HAL_PLATFORM_DEPS halcogen)
    set(HAL_PLATFORM_INCLUDES ${CMAKE_SOURCE_DIR}/bsp/tms570lc43/halcogen/include)
else()
    message(FATAL_ERROR "Unsupported MCU_FAMILY: ${MCU_FAMILY}")
endif()

# HAL library with platform-specific implementation
add_library(hal STATIC
    ${HAL_PLATFORM_SOURCES}
)

target_include_directories(hal
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE
        ${HAL_PLATFORM_INCLUDES}
)

target_link_libraries(hal
    PUBLIC
        ${HAL_PLATFORM_DEPS}
)
