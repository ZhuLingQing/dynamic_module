cmake_minimum_required(VERSION 3.16)

add_subdirectory("./riscv")
#add_subdirectory("./kernels")

enable_language(ASM)

set( STACK_SIZE 0x1ff00 )
set(TEST dynamic_module)

if (DEBUG)
    SET(CMAKE_BUILD_TYPE "Debug")
    message(STATUS "Build with debug mode")
else()
    SET(CMAKE_BUILD_TYPE "Release")
    message(STATUS "Build with release mode as default")
endif()

file( GLOB SRCS "src/main.c")
#file( GLOB KERNELS "kernels/*.c")
file( GLOB KERNELS "kernels/kernel1.c" "kernels/kernel3.c" "kernels/kernel4.c")

add_executable(${TEST}.elf ${SRCS} ${KERNELS} )

target_link_libraries(${TEST}.elf arch_riscv_lib)
#target_link_libraries(${TEST}.elf kernels_lib)

set( LINKER_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/kernel.lds")
message("lds file: ${LINKER_SCRIPT}")
set_target_properties(${TEST}.elf PROPERTIES LINK_DEPENDS "${LINKER_SCRIPT}")

target_include_directories(${TEST}.elf PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/inc)

set( CMAKE_EXE_LINKER_FLAGS  "-nostartfiles -fno-exceptions  -Xlinker --defsym=__stack_size=${STACK_SIZE} -Xlinker --defsym=__heap_max=1 -T ${LINKER_SCRIPT} -Wl,-Map=${TEST}.map")

# Post processing command to create a disassembly file 
add_custom_command(TARGET ${TEST}.elf POST_BUILD
        COMMAND ${CMAKE_OBJDUMP} -S  ${TEST}.elf > ${TEST}.disasm
        COMMENT "Invoking: llvm-Disassemble")


add_custom_command(TARGET ${TEST}.elf POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O binary  ${TEST}.elf ${TEST}.bin
        COMMENT "Invoking: Binarydump")