# =============================================================================
# Application Layer
# =============================================================================

# Main executable
add_executable(nexus-fsw
    # Application source
    main.c

    # HALCoGen startup files (must be in executable, not library)
    ${CMAKE_SOURCE_DIR}/bsp/tms570lc43/halcogen/source/HL_sys_startup.c
    ${CMAKE_SOURCE_DIR}/bsp/tms570lc43/halcogen/source/HL_sys_intvecs.asm
    ${CMAKE_SOURCE_DIR}/bsp/tms570lc43/halcogen/source/HL_sys_core.asm
    ${CMAKE_SOURCE_DIR}/bsp/tms570lc43/halcogen/source/HL_sys_mpu.asm
    ${CMAKE_SOURCE_DIR}/bsp/tms570lc43/halcogen/source/HL_sys_pmu.asm
    ${CMAKE_SOURCE_DIR}/bsp/tms570lc43/halcogen/source/HL_sys_phantom.c
)

# Include directories for application
target_include_directories(nexus-fsw PRIVATE
    ${CMAKE_SOURCE_DIR}/bsp/tms570lc43/halcogen/include
)

# Link libraries (following dependency order: app -> ccsds -> hal -> bsp)
target_link_libraries(nexus-fsw PRIVATE
    ccsds
    hal
    halcogen
    ${TI_CGT_INSTALL_DIR}/lib/rtsv7R4_A_be_v3D16_eabi.lib
)

# Link with linker script (must come after object files)
target_link_options(nexus-fsw PRIVATE
    ${CMAKE_SOURCE_DIR}/bsp/tms570lc43/halcogen/source/HL_sys_link.cmd
)

# Generate additional output formats
add_custom_command(TARGET nexus-fsw POST_BUILD
    COMMAND ${TI_HEX} -o ${CMAKE_BINARY_DIR}/nexus-fsw.txt $<TARGET_FILE:nexus-fsw>
    COMMENT "Generating TI-TXT output file"
)
