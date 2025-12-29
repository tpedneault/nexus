# =============================================================================
# TI ARM Code Generation Tools (CGT) Toolchain for TMS570
# =============================================================================

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Skip compiler checks and IDE probing (TI compiler doesn't support GCC-style flags)
set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_ASM_COMPILER_WORKS 1)
set(CMAKE_C_COMPILER_FORCED TRUE)
set(CMAKE_ASM_COMPILER_FORCED TRUE)
set(CMAKE_C_ABI_COMPILED TRUE)
set(CMAKE_ASM_ABI_COMPILED TRUE)

# Toolchain paths
set(TI_CGT_INSTALL_DIR "$ENV{TI_ARM_CGT_INSTALL_DIR}" CACHE PATH "TI CGT installation directory")

if(NOT TI_CGT_INSTALL_DIR)
    set(TI_CGT_INSTALL_DIR "/opt/ti-cgt-arm/ti-cgt-arm_20.2.7.LTS")
endif()

# Find toolchain programs
find_program(CMAKE_C_COMPILER   armcl   PATHS ${TI_CGT_INSTALL_DIR}/bin REQUIRED NO_DEFAULT_PATH)
find_program(CMAKE_ASM_COMPILER armcl   PATHS ${TI_CGT_INSTALL_DIR}/bin REQUIRED NO_DEFAULT_PATH)
find_program(CMAKE_AR           armar   PATHS ${TI_CGT_INSTALL_DIR}/bin REQUIRED NO_DEFAULT_PATH)
find_program(CMAKE_LINKER       armcl   PATHS ${TI_CGT_INSTALL_DIR}/bin REQUIRED NO_DEFAULT_PATH)
find_program(TI_OBJCOPY         armobjcopy PATHS ${TI_CGT_INSTALL_DIR}/bin REQUIRED NO_DEFAULT_PATH)
find_program(TI_SIZE            armsize PATHS ${TI_CGT_INSTALL_DIR}/bin REQUIRED NO_DEFAULT_PATH)
find_program(TI_HEX             armhex  PATHS ${TI_CGT_INSTALL_DIR}/bin REQUIRED NO_DEFAULT_PATH)

# Set objcopy and size for CMake
set(CMAKE_OBJCOPY ${TI_OBJCOPY})
set(CMAKE_SIZE ${TI_SIZE})

# Executable suffix
set(CMAKE_EXECUTABLE_SUFFIX_C ".out")
set(CMAKE_EXECUTABLE_SUFFIX_ASM ".out")

# Don't search host paths for libraries/includes
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# TI compiler uses different flags than GCC
set(CMAKE_C_FLAGS_INIT "")
set(CMAKE_ASM_FLAGS_INIT "")

# Disable IDE probing that uses GCC-style flags
set(CMAKE_C_COMPILER_ID "TI")
set(CMAKE_C_COMPILER_VERSION "20.2.7")
set(CMAKE_C_STANDARD_COMPUTED_DEFAULT "11")
set(CMAKE_C_COMPILER_ID_RUN TRUE)
set(CMAKE_C_SIZEOF_DATA_PTR 4)
set(CMAKE_C_BYTE_ORDER "BIG_ENDIAN")

# Tell CMake this is a cross-compiler
set(CMAKE_CROSSCOMPILING TRUE)

# Configure TI compiler behavior
set(CMAKE_C_OUTPUT_EXTENSION ".obj")
set(CMAKE_C_OUTPUT_EXTENSION_REPLACE 1)
set(CMAKE_ASM_OUTPUT_EXTENSION ".obj")
set(CMAKE_ASM_OUTPUT_EXTENSION_REPLACE 1)

# TI compiler command templates
set(CMAKE_C_COMPILE_OBJECT "<CMAKE_C_COMPILER> <DEFINES> <INCLUDES> <FLAGS> --output_file=<OBJECT> <SOURCE>")
set(CMAKE_ASM_COMPILE_OBJECT "<CMAKE_ASM_COMPILER> <DEFINES> <INCLUDES> <FLAGS> --output_file=<OBJECT> <SOURCE>")
set(CMAKE_C_CREATE_STATIC_LIBRARY "<CMAKE_AR> -r <TARGET> <OBJECTS>")
# TI linker: objects must come before libraries
set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_LINKER> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> <LINK_LIBRARIES> -o <TARGET>")

# Include flag for TI compiler (TI uses --include_path, not -I or -isystem)
set(CMAKE_INCLUDE_FLAG_C "--include_path=")
set(CMAKE_INCLUDE_SYSTEM_FLAG_C "--include_path=")

# Add TI compiler's include directory for standard headers
add_compile_options(--include_path=${TI_CGT_INSTALL_DIR}/include)
