/*
    @file   STM32F401ccu6_linker.ld
    @author Youssef Ibrahemm Khalil
    @brief  Linker script for MCU:STM32F401ccu6 based on arm cortex-M4 CPU
*/

/*define entry point for the program*/
/*Entry(Reset_Handler) *//*make sure that the name match reset handler name in startup file*/

/*HIGHEST address of the stack*/
_estack = ORIGIN(RAM) + LENGTH(RAM); /*full-descending stack*/
_sstack = _estack - _Min_Stack_Size; /*start address of the stack*/



_Min_Stack_Size = 0x200;/*min required stack size*/ /*0x200 = 512 byte*/

_Min_Heap_Size = 0x400;/*min required heap size */ /*0x400 = 1024 byte*/

/*memory*/
MEMORY
{
    /*
        x  -> memory containing executable code
        r -> readable memory
        w -> writable memory
    */
    /*define Ram memory , origin -> start address , Length-> size of RAM ,(rw) -> ram is readable and writable but cant execute code from ram change to (xrw) if you need to execute code from ram*/
    RAM     (rw)     :  ORIGIN = 0x20000000,        LENGTH = 64K
    /*define flash memory , flash -> start address , Length-> size of flash ,(rx) ->  you can read from flash and execute code only you cant write */
    FLASH   (rx)     :  ORIGIN = 0x8000000,         LENGTH = 256K 
}

/* memory sections */
SECTIONS 
{
    /*text section , code section */
    .text :
    {
        /*. = 0x8000000*/
        _stext = .;     /*global sumbol at the start of text*/
        /*
            . = ALIGN(x); , means: insert padding bytes until current location becomes aligned on x-byte boundary.
        */
        . = ALIGN(4);   /*align section on 4*/
        *(.text);       /*combine all sections with .text name*/
        *(.text*);      /*combine all sections with .text xxx example .text_y will be combined too */
        . = ALIGN(4);
        /*. = 0x8000000 +*(.text)+ *(.text*)*/
        _etext = .;      /*global sumbol at the end of text*/
    } >FLASH /*save .text section in flash  memory*/

    /* read only data section*/
    .rodata :
    {
        _srodata = .;       /*global sumbol at the start of rodata*/
        /*
        . = ALIGN(x); , means: insert padding bytes until current location becomes aligned on x-byte boundary.
        */
         . = ALIGN(4);      /*align section on 4*/
        *(.rodata);         /*combine all sections with .rodata name*/
        *(.rodata*);        /*combine all sections with .rodata xxx example .rodata_y will be combined too */
         . = ALIGN(4);
         _erodata = .;      /*global sumbol at the end of rodata*/
    } >FLASH /*save .rodata section in flash memory */

    /*data section , initialized data*/
  /* Used by the startup to initialize data */
  _sidata = LOADADDR(.data); /*stat of LMA of .data section*/

    .data :
    {
        _sdata = .; /*global symbol at the start of data section "VMA"*/
        /*
        . = ALIGN(x); , means: insert padding bytes until current location becomes aligned on x-byte boundary.
        */
         . = ALIGN(4); /*align section on 4*/
        *(.data); /*combine all sections with .data name*/
        *(.data*); /*combine all sections with .data xxx example .data_y will be combined too */
         . = ALIGN(4);
         _edata = .; /*global symbol at the end of data section "VMA"*/         
    } >RAM AT> FLASH /*>VMA AT> LMA , load data from flash to ram */
    _eidata = _sidata + ( _edata - _sdata); /*end of LMA of .data section*/
    /*.bss section , uninitalized data*/
    .bss :
    {
        _sbss = .; /*global symbol at the start of bss section*/
        /*
        . = ALIGN(x); , means: insert padding bytes until current location becomes aligned on x-byte boundary.
        */
         . = ALIGN(4); /*align section on 4*/
        *(.bss); /*combine all sections with .bss name*/
        *(.bss*); /*combine all sections with .bss xxx example .bss will be combined too */
         . = ALIGN(4);
         _ebss = .; /*global symbol at the end of bss section*/ 
    } >RAM /*save .bss section in ram*/

    /* _user_heap  and _user_stack sections used to check that there is enough "RAM"  type memory left */
    ._user_heap :
    {

        . = ALIGN(8); /*must be aliged on 8 bytes to support , LDRD , STRD , etc for double and uint64_t variables*/
        _sheap = . ;
        /* `PROVIDE` prevents this by ensuring that the symbol is only defined if it hasn't been defined elsewhere.*/
        PROVIDE ( end = . ); 
        PROVIDE ( _end = . ); /*symbol point to the end of .bss section and start of the heap*/
        . = . + _Min_Heap_Size;
        . = ALIGN(8);
        _eheap = . ; /*symbol point to the end of heap section*/
    } > RAM

    ._user_stack :
    {
        . = ALIGN(8); /*must be aliged on 8 bytes to support , LDRD , STRD , etc for double and uint64_t variables*/
        . = . + _Min_Stack_Size;
        . = ALIGN(8);        
    } > RAM
}