#build
cmake -DCMAKE_TOOLCHAIN_FILE=./riscv.cmake -B build -S . && \
cmake --build build

#run test
pushd simulator
./funcsim_lin mcp ../build/dynamic_module.elf
popd

echo DONE