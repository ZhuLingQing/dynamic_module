#include(CMakeForceCompiler)

# usage
# cmake -DCMAKE_TOOLCHAIN_FILE=../cmake/rv32imac.cmake ../

# Look for GCC in path
# https://xpack.github.io/riscv-none-embed-gcc/
FIND_FILE( RISCV_XPACK_GCC_COMPILER "riscv-none-embed-gcc" PATHS ENV INCLUDE)

# New versions of xpack
FIND_FILE( RISCV_XPACK_NEW_GCC_COMPILER "riscv-none-elf-gcc" PATHS ENV INCLUDE)

# New versions of xpack
FIND_FILE( RISCV_XPACK_GLIB_GCC_COMPILER "riscv64-linux-gcc" PATHS ENV INCLUDE)

# Look for RISC-V github GCC
# https://github.com/riscv/riscv-gnu-toolchain
FIND_FILE( RISCV_XPACK_GCC_COMPILER "riscv64-unknown-elf-gcc" PATHS ENV INCLUDE)

# Select which is found
if (EXISTS ${RISCV_XPACK_NEW_GCC_COMPILER})
set( RISCV_GCC_COMPILER ${RISCV_XPACK_NEW_GCC_COMPILER})
elseif (EXISTS ${RISCV_XPACK_GCC_COMPILER})
set( RISCV_GCC_COMPILER ${RISCV_XPACK_GCC_COMPILER})
elseif (EXISTS ${RISCV_XPACK_GLIB_GCC_COMPILER})
set( RISCV_GCC_COMPILER ${RISCV_XPACK_GLIB_GCC_COMPILER})
elseif (EXISTS ${RISCV_GITHUB_GCC_COMPILER})
set( RISCV_GCC_COMPILER ${RISCV_GITHUB_GCC_COMPILER})
else()
message(FATAL_ERROR "RISC-V GCC not found. ${RISCV_GITHUB_GCC_COMPILER} ${RISCV_XPACK_GCC_COMPILER} ")
endif()

message( "RISC-V GCC found: ${RISCV_GCC_COMPILER}")

get_filename_component(RISCV_TOOLCHAIN_BIN_PATH ${RISCV_GCC_COMPILER} DIRECTORY)
get_filename_component(RISCV_TOOLCHAIN_BIN_GCC ${RISCV_GCC_COMPILER} NAME_WE)
get_filename_component(RISCV_TOOLCHAIN_BIN_EXT ${RISCV_GCC_COMPILER} EXT)

message( "RISC-V GCC Path: ${RISCV_TOOLCHAIN_BIN_PATH}" )

STRING(REGEX REPLACE "\-gcc" "-" CROSS_COMPILE ${RISCV_TOOLCHAIN_BIN_GCC})
message( "RISC-V Cross Compile: ${CROSS_COMPILE}" )

# The Generic system name is used for embedded targets (targets without OS) in
# CMake
set( CMAKE_SYSTEM_NAME          Generic )
# set( CMAKE_SYSTEM_PROCESSOR     rv64gcv0p10 )
set( CMAKE_SYSTEM_PROCESSOR     rv64gcv0p10zfh0p1 )
# set( CMAKE_EXECUTABLE_SUFFIX    ".elf")

# specify the cross compiler. We force the compiler so that CMake doesn't
# attempt to build a simple test program as this will fail without us using
# the -nostartfiles option on the command line
#CMAKE_FORCE_C_COMPILER( "${RISCV_TOOLCHAIN_BIN_PATH}/${CROSS_COMPILE}gcc${RISCV_TOOLCHAIN_BIN_EXT}" GNU )
#CMAKE_FORCE_CXX_COMPILER( "${RISCV_TOOLCHAIN_BIN_PATH}/${CROSS_COMPILE}g++${RISCV_TOOLCHAIN_BIN_EXT}" GNU )
# tzhu comment these, due to we use clang
#set(CMAKE_ASM_COMPILER {CROSS_COMPILE}gcc )
#set(CMAKE_AR ${CROSS_COMPILE}ar)
#set(CMAKE_ASM_COMPILER ${CROSS_COMPILE}gcc)
#set(CMAKE_C_COMPILER ${CROSS_COMPILE}gcc)
#set(CMAKE_CXX_COMPILER ${CROSS_COMPILE}g++)
# 
set(CLANG_PATH "/nfs/swg/lt-compiler/checkin-latest/lt-release-main/bin")

set(CMAKE_C_COMPILER ${CLANG_PATH}/clang)
set(CMAKE_CXX_COMPILER ${CLANG_PATH}/clang)
set(CMAKE_ASM_COMPILER ${CLANG_PATH}/clang)
# set(CMAKE_AR /nfs/swg/lt-compiler/llvm-project/bin/riscv64-unknown-elf-gcc-ar)
# set(CMAKE_LD /nfs/swg/lt-compiler/llvm-project/bin/llvm-ld)

# We must set the OBJCOPY setting into cache so that it's available to the
# whole project. Otherwise, this does not get set into the CACHE and therefore
# the build doesn't know what the OBJCOPY filepath is
set( CMAKE_OBJCOPY      ${RISCV_TOOLCHAIN_BIN_PATH}/${CROSS_COMPILE}objcopy
     CACHE FILEPATH "The toolchain objcopy command " FORCE )

set( CMAKE_OBJDUMP      ${CLANG_PATH}/${CROSS_COMPILE}objdump
     CACHE FILEPATH "The toolchain objdump command " FORCE )

# Set the common build flags

# Set the CMAKE C flags (which should also be used by the assembler!
set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g" )
set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=${CMAKE_SYSTEM_PROCESSOR}" )
#set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mabi=lp64d" )
set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -menable-experimental-extensions" )
#set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --gcc-toolchain=/nfs/swg/lt-compiler/lt-release-isa-0.7/bin/" )
#set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mcpu=pace2" )
set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -v" )
set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall" )
set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ffunction-sections" )
set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O1" )
set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-builtin" )
set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-rtti" )
set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mcmodel=medany" )

# set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -nobuiltininc" )
set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "" )
set( CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "" )
set( CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "" )
set( CMAKE_EXE_LINKER_FLAGS   "${CMAKE_EXE_LINKER_FLAGS} -march=${CMAKE_SYSTEM_PROCESSOR} -fno-rtti -mabi=lp64d -nostartfiles -lm" )
