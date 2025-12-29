# =============================================================================
# HALCoGen Generated Code Library
# =============================================================================

# Only build for TMS570
if(NOT MCU_FAMILY STREQUAL "TMS570")
    message(STATUS "Skipping HALCoGen (not TMS570 target)")
    return()
endif()

# Assembly files (from HALCoGen)
# Note: HL_sys_intvecs.asm, HL_sys_core.asm, HL_sys_mpu.asm, HL_sys_pmu.asm
# are compiled as part of the main executable to ensure they are linked

# C source files (from HALCoGen)
# Note: HL_sys_startup.c, HL_sys_main.c, HL_sys_phantom.c are in main executable
set(HALCOGEN_C_SOURCES
    source/HL_adc.c
    source/HL_can.c
    source/HL_crc.c
    source/HL_dcc.c
    source/HL_ecap.c
    source/HL_emac.c
    source/HL_emif.c
    source/HL_epc.c
    source/HL_eqep.c
    source/HL_errata_SSWF021_45.c
    source/HL_errata.c
    source/HL_esm.c
    source/HL_etpwm.c
    source/HL_gio.c
    source/HL_het.c
    source/HL_i2c.c
    source/HL_lin.c
    source/HL_mdio.c
    source/HL_mibspi.c
    source/HL_nmpu.c
    source/HL_notification.c
    source/HL_phy_dp83640.c
    source/HL_phy_tlk111.c
    source/HL_pinmux.c
    source/HL_pom.c
    source/HL_rti.c
    source/HL_sci.c
    source/HL_sys_dma.c
    source/HL_sys_pcr.c
    source/HL_sys_pmm.c
    source/HL_sys_vim.c
    source/HL_system.c
)

# Filter out files that don't exist
set(HALCOGEN_SOURCES_FILTERED)

foreach(src ${HALCOGEN_C_SOURCES})
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${src})
        list(APPEND HALCOGEN_SOURCES_FILTERED ${src})
    else()
        message(STATUS "HALCoGen: File not found, skipping: ${src}")
    endif()
endforeach()

if(NOT HALCOGEN_SOURCES_FILTERED)
    message(WARNING "")
    message(WARNING "============================================")
    message(WARNING "No HALCoGen sources found!")
    message(WARNING "============================================")
    message(WARNING "")

    # Create placeholder library to avoid build errors
    add_library(halcogen INTERFACE)
    return()
endif()

add_library(halcogen STATIC ${HALCOGEN_SOURCES_FILTERED})

target_include_directories(halcogen
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Suppress warnings in generated code
target_compile_options(halcogen PRIVATE
    --diag_suppress=552    # Variable set but never used
    --diag_suppress=238    # Controlling expression is constant
    --diag_suppress=179    # Enumerated type mixed with another type
)
