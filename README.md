# brief
This project samples a dynamic module load method.
It references the linux module loading mechanism.
- utilize a section.
- put the module reference into the section.
- in application traversal the section to get the module reference.
- load the module.

## how to make
under repository root:
>cmake -DCMAKE_TOOLCHAIN_FILE=./riscv.cmake -B build -S .
>cmake --build build
or  
>bash build.sh

## how to run
under repository root:
>pushd simulator
>./funcsim_lin mcp ../build/dynamic_module.elf
>popd
or  
>bash build.sh

### environment
- cmake
- riscv-gnu-toolchain
- riscv architecture supported simulator (./simulator)