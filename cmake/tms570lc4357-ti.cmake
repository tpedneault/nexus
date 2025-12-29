# =============================================================================
# TMS570LC4357 MCU Configuration for TI CGT Compiler
# =============================================================================

message(STATUS "Configuring for TMS570LC4357 with TI CGT")

set(MCU_FAMILY "TMS570" CACHE INTERNAL "")
set(MCU_VARIANT "LC4357" CACHE INTERNAL "")

# -----------------------------------------------------------------------------
# CPU Flags (Cortex-R5F with VFPv3-D16) - TI Compiler Syntax
# -----------------------------------------------------------------------------

set(CPU_FLAGS
        --silicon_version=7R5      # Cortex-R5
        --code_state=32            # ARM mode (not Thumb)
        --float_support=VFPv3D16   # Hardware FP
        --endian=big               # Big-endian (TMS570 requirement)
        --enum_type=packed         # Packed enum size (match CCS)
        --abi=eabi                 # EABI
)

add_compile_options(${CPU_FLAGS})

# -----------------------------------------------------------------------------
# Compiler Options
# -----------------------------------------------------------------------------

# Compiler Options (match CCS Debug exactly)
add_compile_options(
        --diag_warning=225         # Promote warnings
        --diag_wrap=off            # Don't wrap diagnostic messages
        --display_error_number     # Show error numbers
)

# Debug vs Release flags
add_compile_options(
        $<$<CONFIG:Debug>:--symdebug:dwarf>
        $<$<CONFIG:Debug>:-g>
        $<$<CONFIG:Debug>:-DDEBUG>
        $<$<CONFIG:Release>:--opt_level=2>
        $<$<CONFIG:Release>:--opt_for_speed=3>
        $<$<CONFIG:Release>:-DNDEBUG>
)

# -----------------------------------------------------------------------------
# Linker Options
# -----------------------------------------------------------------------------

# Use HALCoGen's linker script
set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/halcogen/source/HL_sys_link.cmd)

# TI Runtime library for Cortex-R5F big-endian with VFPv3-D16 in ARM mode
# Note: Use _A_ (ARM mode) not _T_ (Thumb mode) since --code_state=32
set(TI_RTS_LIB ${TI_CGT_INSTALL_DIR}/lib/rtsv7R4_A_be_v3D16_eabi.lib)

# Note: Linker options order matters for TI compiler!
# --silicon_version comes from CPU_FLAGS (compile options are passed to linker automatically)
add_link_options(
        --stack_size=0x800         # Match CCS default
        --heap_size=0x800          # Match CCS default
        --be32                     # Big-endian 32-bit (match CCS)
        --map_file=${CMAKE_BINARY_DIR}/nexus-fsw.map
        --reread_libs              # Resolve circular dependencies
        --warn_sections            # Warn about section issues
        --diag_wrap=off            # Match CCS
        --display_error_number     # Match CCS
        --rom_model                # ROM-based application
        --search_path=${TI_CGT_INSTALL_DIR}/lib
        --search_path=${TI_CGT_INSTALL_DIR}/include
)

# -----------------------------------------------------------------------------
# Memory Map
# -----------------------------------------------------------------------------

set(FLASH_BASE  0x00000000)
set(FLASH_SIZE  0x00400000)  # 4MB
set(RAM_BASE    0x08000000)
set(RAM_SIZE    0x00080000)  # 512KB

# -----------------------------------------------------------------------------
# MCU Definitions
# -----------------------------------------------------------------------------

add_compile_definitions(
        TMS570LC4357
        __TMS570LC43x__
        CORTEX_R5F
        MCU_FAMILY_TMS570
        _TMS570LC4357_
)
