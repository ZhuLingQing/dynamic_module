/*
  Copyright 2022  Lightelligence 

    RISC-V linker script
    - for aurora PE 
*/

OUTPUT_FORMAT("elf64-littleriscv", "elf64-littleriscv",
	      "elf64-littleriscv")
OUTPUT_ARCH("riscv")

ENTRY(_start)

MEMORY
{
    ilm (airwx) : ORIGIN = 0x3E0080, LENGTH = 0x03FF80
    ram (airwx) : ORIGIN = 0x420000, LENGTH = 0x040000
    rsv (airwx) : ORIGIN = 0x3E0000, LENGTH = 0x000080
}

/* 
   Region Alias 
*/
REGION_ALIAS("PMEM", ram);
REGION_ALIAS("ILM", ilm);
REGION_ALIAS("CDAT", rsv);

SECTIONS
{
    /* Each hart is allocated its own stack of size __stack_size. This value
     * can be overriden at build-time by adding the following to CFLAGS:
     *
     *     -Xlinker --defsym=__stack_size=0xf00
     *
     * where 0xf00 can be replaced with a multiple of 16 of your choice.
     *
     * __stack_size is PROVIDE-ed as a symbol so that initialization code
     * initializes the stack pointers for each hart at the right offset from
     * the _sp symbol.
     */
    __stack_size = DEFINED(__stack_size) ? __stack_size : 0x400;
    PROVIDE(__stack_size = __stack_size);

    /* The size of the heap can be overriden at build-time by adding the
     * following to CFLAGS:
     *
     *     -Xlinker --defsym=__heap_size=0xf00
     *
     * where 0xf00 can be replaced with the value of your choice.
     *
     * Altertatively, the heap can be grown to fill the entire remaining region
     * of RAM by adding the following to CFLAGS:
     *
     *     -Xlinker --defsym=__heap_max=1
     *
     * Note that depending on the memory layout, the bitness (32/64bit) of the
     * target, and the code model in use, this might cause a relocation error.
     */
    __heap_size = DEFINED(__heap_size) ? __heap_size : 0x0;

    /* The boot hart sets which hart runs the pre-main initialization routines,
     * including copying .data into RAM, zeroing the BSS region, running
     * constructors, etc. After initialization, the boot hart is also the only
     * hart which runs application code unless the application overrides the
     * secondary_main() function to start execution on secondary harts.
     */
    PROVIDE(__boot_hart = 0);

    /* The memory_ecc_scrub bit is used by _entry code to enable/disable
     * memories scrubbing to zero  */
    PROVIDE(__eccscrub_bit = 0);

    /* ITIM SECTION
     *
     * The following sections contain data which is copied from read-only
     * memory into an instruction tightly-integrated memory (ITIM), if one
     * is present in the design, during pre-main program initialization.
     *
     * Generally, the data copied into the ITIM should be performance-critical
     * functions which benefit from low instruction-fetch latency.
     */

    .rodata2 : ALIGN(8) {
        *(.rdata2)
        . = ALIGN(8);
        PROVIDE( __kernel_reg_entry = . );
        *(.kernel_reg .kernel_reg.*)
    } >CDAT 

    .ilm : ALIGN(8) {
        *(.ilm .ilm.*)
    } >ILM

    /* TEXT SECTION
     *
     * The following section contains the code of the program, excluding
     * everything that's been allocated into the ITIM/LIM already
     */

    .text : ALIGN(8){
        *(.text.unlikely .text.unlikely.*)
        *(.text.startup .text.startup.*)
        *(.text .text.*)
        *(.gnu.linkonce.t.*)
    } >ILM

    /* ROM SECTION
     *
     * The following sections contain data which lives in read-only memory, if
     * such memory is present in the design, for the entire duration of program
     * execution.
     */

    .init : {
        /* The _enter symbol is placed in the .text.init.enter section
         * and must be placed at the beginning of the program */
        KEEP (*(.text.init.enter))
        KEEP (*(.text.init.*))
        KEEP (*(SORT_NONE(.init)))
        KEEP (*(.text.libgloss.start))
    } >ILM 

    .fini : {
        KEEP (*(SORT_NONE(.fini)))
    } >ILM 

    .preinit_array : ALIGN(8) {
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP (*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);
    } >ILM

    .init_array : ALIGN(8) {
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
        KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
        PROVIDE_HIDDEN (__init_array_end = .);
    } >ILM

    .fini_array : ALIGN(8) {
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
        KEEP (*(.fini_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .dtors))
        PROVIDE_HIDDEN (__fini_array_end = .);
    } >ILM

    .ctors : {
        KEEP (*crtbegin.o(.ctors))
        KEEP (*crtbegin?.o(.ctors))
        KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
        KEEP (*(SORT(.ctors.*)))
        KEEP (*(.ctors))
    } >ILM

    .dtors : {
        KEEP (*crtbegin.o(.dtors))
        KEEP (*crtbegin?.o(.dtors))
        KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
        KEEP (*(SORT(.dtors.*)))
        KEEP (*(.dtors))
    } >ILM

    .rodata : ALIGN(8) {
        *(.rdata)
        *(.rodata .rodata.*)
        *(.gnu.linkonce.r.*)
        . = ALIGN(8);
        *(.srodata.cst16)
        *(.srodata.cst8)
        *(.srodata.cst4)
        *(.srodata.cst2)
        *(.srodata .srodata.*)
    } >ILM

    /* RAM SECTION
     *
     * The following sections contain data which is copied from read-only
     * memory into a read-write-capable memory such as data tightly-integrated
     * memory (DTIM) or another main memory, as well as the BSS, stack, and
     * heap.
     *
     * You might notice that .data, .tdata, .tbss, .tbss_space, and .bss all
     * have an apparently unnecessary ALIGN at their top. This is because
     * the implementation of _start in Freedom Metal libgloss depends on the
     * ADDR and LOADADDR being 8-byte aligned.
     */
  
    .data : ALIGN(8) {
        *(.data .data.*)
        *(.gnu.linkonce.d.*)
        . = ALIGN(8);
        PROVIDE( __global_pointer$ = . + 0x800 );
        *(.sdata .sdata.* .sdata2.*)
        *(.gnu.linkonce.s.*)
    } >PMEM
    PROVIDE( __data_lsource = LOADADDR(.data));
    PROVIDE( __data_source = ADDR(.data));
    PROVIDE( __data_size = SIZEOF(.data));


    .tdata : ALIGN(8) {
        PROVIDE( __tls_base = . );
	*(.tdata .tdata.* .gnu.linkonce.td.*)
    } >PMEM 

    PROVIDE( __tdata_source = LOADADDR(.tdata) );
    PROVIDE( __tdata_size = SIZEOF(.tdata) );

    _edata = .; PROVIDE (edata = .);

    .tbss : ALIGN(8) {
	*(.tbss .tbss.* .gnu.linkonce.tb.*)
	*(.tcommon .tcommon.*)
	PROVIDE( __tls_end = . );
    } >PMEM
    PROVIDE( __tbss_size = SIZEOF(.tbss) );
    PROVIDE( __tls_size = __tls_end - __tls_base );

    .tbss_space : ALIGN(8) {
	. = . + __tbss_size;
    } >PMEM

    .bss (NOLOAD): ALIGN(8) {
        *(.sbss*)
        *(.gnu.linkonce.sb.*)
        *(.bss .bss.*)
        *(.gnu.linkonce.b.*)
        *(COMMON)
    } >PMEM

    _end = .; PROVIDE (end = .);

    .stack (NOLOAD) : ALIGN(16) {
        . += __stack_size; /* Hart 0 */
        PROVIDE( _sp = . );
        PROVIDE( _stack = . );
    } >PMEM

    _hdata = .;

    .heap (NOLOAD) : ALIGN(8) {
        PROVIDE( __end = . );
        PROVIDE( __heap_start = . );
        /* If __heap_max is defined, grow the heap to use the rest of RAM,
         * otherwise set the heap size to __heap_size */
        . = DEFINED(__heap_max) ? MIN( LENGTH(ram) - ( . - ORIGIN(ram)) , 0x10000000) : __heap_size;
        PROVIDE( _heap_end = . );
        PROVIDE( __heap_end = . );
    } >PMEM

    _hend = .;

    /* C++ exception handling information is
     * not useful with our current runtime environment,
     * and it consumes flash space. Discard it until
     * we have something that can use it
     */
    .eh_frame_hdr   : { *(.eh_frame_hdr) *(.eh_frame_entry .eh_frame_entry.*) }
    .eh_frame       : ONLY_IF_RO { KEEP (*(.eh_frame)) *(.eh_frame.*) }
}
