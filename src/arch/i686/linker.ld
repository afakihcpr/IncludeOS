/**
 * This file is a part of the IncludeOS unikernel - www.includeos.org
 *
 * Copyright 2015 Oslo and Akershus University College of Applied Sciences
 * and Alfred Bratterud
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http: *www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
**/
ENTRY(_start)

SECTIONS
{
  PROVIDE ( _ELF_START_ = . + 0x100000);
  PROVIDE ( _LOAD_START_ = _ELF_START_); /* For convenience w. multiboot */

  .multiboot (_ELF_START_ + SIZEOF_HEADERS): {
      PROVIDE(_MULTIBOOT_START_ = .);
      *(.multiboot)
   }

  PROVIDE( _TEXT_START_ = . );
  .text (_TEXT_START_ ) :
  {
    *(.text)
    *(.text.*)
    *(.gnu.linkonce.t*)
  }
  PROVIDE( _TEXT_END_ = . );

  .init ALIGN(0x10) : {
    _INIT_START_ = .;
    *(.init)
    _INIT_END_ = .;
  }

  .fini ALIGN(0x10) : {
    *(.fini)
  }

  /* Global offset-table. For dynamic linking */
  .got ALIGN(0x10) : {
      *(.got*)
  }

/**
 *  .ctors, .dtors, .preinit_array, .init_array, .fini_array
 *  from GNU LD default linker script
 */

.ctors          :
  {
    _GCONSTR_START_ = .;
      /* gcc uses crtbegin.o to find the start of
       the constructors, so we make sure it is
       first.  Because this is a wildcard, it
       doesn't matter if the user does not
       actually link against crtbegin.o; the
       linker won't look for a file to match a
       wildcard.  The wildcard also means that it
       doesn't matter which directory crtbegin.o
       is in.  */
       KEEP (*crtbegin.o(.ctors))
       KEEP (*crtbegin?.o(.ctors))
       /* We don't want to include the .ctor section from
       the crtend.o file until after the sorted ctors.
       The .ctor section from the crtend file contains the
       end of ctors marker and it must be last */
       KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
       KEEP (*(SORT(.ctors.*)))
       KEEP (*(.ctors))
    _GCONSTR_END_ = .;
  }

  .dtors :
  {
    KEEP (*crtbegin.o(.dtors))
    KEEP (*crtbegin?.o(.dtors))
    KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
    KEEP (*(SORT(.dtors.*)))
    KEEP (*(.dtors))
  }

  .preinit_array :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  }

  .init_array :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
    KEEP (*(.init_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .ctors))
    PROVIDE_HIDDEN (__init_array_end = .);
  }

  .fini_array     :
  {
   PROVIDE_HIDDEN (__fini_array_start = .);
   KEEP (*(SORT_BY_INIT_PRIORITY(.fini_array.*) SORT_BY_INIT_PRIORITY(.dtors.*)))
   KEEP (*(.fini_array EXCLUDE_FILE (*crtbegin.o *crtbegin?.o *crtend.o *crtend?.o ) .dtors))
   PROVIDE_HIDDEN (__fini_array_end = .);
  }

  .rodata :
  {
    _RODATA_START_ = .;
    *(.rodata*)
    *(.gnu.linkonce.r*)
    _RODATA_END_ = .;
  }

  /* For stack unwinding (exception handling)  */
  .eh_frame_hdr ALIGN(0x8):
  {
    KEEP(*(.eh_frame_hdr*))
  }
  .eh_frame ALIGN(0x8):
  {
    PROVIDE (__eh_frame_start = .);
    KEEP(*(.eh_frame))
    LONG (0);
  }

  .gcc_except_table :
  {
    *(.gcc_except_table)
  }

  .data :
  {
    _DATA_START_ = .;
    *(.data)
    *(.data.*)
    *(.gnu.linkonce.d*)
    _DATA_END_ = .;
  }

  .tdata ALIGN(0x10) :
  {
    _TDATA_START_ = .;
    *(.tdata .tdata.*)
    _TDATA_END_ = .;
    . = ALIGN(0x10);
  }
  .tbss :
  {
    _TBSS_START_ = .;
    *(.tbss .tbss.*)
    _TBSS_END_ = .;
    . = ALIGN(0x10);
  }

  .memdisk :
  {
    _DISK_START_ = .;
    *(.diskdata)
    _DISK_END_ = .;
  }

  .elf_symbols : {
    _ELF_SYM_START_ = .;
    LONG (0);
  }

  .bss :
  {
    _BSS_START_ = .;
    *(.bss .bss.* .gnu.linkonce.b.*)
    *(COMMON)
    _BSS_END_ = .;
  }
  . = ALIGN(0x8);

  _end = .;

  PROVIDE (end = .);
  PROVIDE (_ELF_END_ = .);
  PROVIDE (_LOAD_END_ = .);
}
