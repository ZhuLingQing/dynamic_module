set( LIB_NAME kernels_lib)

enable_language(ASM)

file( GLOB LIB_SRC "kernel1.c" )

add_library(${LIB_NAME} STATIC ${LIB_SRC})

target_include_directories(${LIB_NAME} PRIVATE 
    ${CMAKE_CURRENT_SOURCE_DIR}/../inc 
)
