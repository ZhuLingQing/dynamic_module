cmake -DCMAKE_TOOLCHAIN_FILE=./riscv.cmake -B build -S . && \
cmake --build build

echo DONE