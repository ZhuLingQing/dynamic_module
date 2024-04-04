set( LIB_NAME arch_riscv_lib)

enable_language(ASM)

file( GLOB LIB_SRC 
    "./src/reset.c"
    "./src/start_up.c"
    "./src/trap.c"
    "./src/start.S"
    "./src/vector_table_baremetal.S"
)

add_library(${LIB_NAME} STATIC ${LIB_SRC})



target_include_directories(${LIB_NAME} PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}/inc 
)
