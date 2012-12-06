;*********************************************
;	Boot1.asm
;		- A Simple Bootloader
;
;	Operating Systems Development Tutorial
;*********************************************
 
org	0x7c00	; We are loaded by BIOS at 0x7C00
		; 伪指令org用来规定目标程序存放单元的偏移量
bits	16	; We are still in 16 bit Real Mode
		; 'BITS'指令指定 NASM 产生的代码是被设计运行在 16 位模式的处理
		; 器上还是运行在 32 位模式的处理器上
Start:
cli		; Clear all Interrupts
hlt		; halt the system
times 510 - ($-$$) db 0	; We have to be 512 bytes. Clear the rest of the bytes
			; with 0 In NASM, the dollar operator ($) represents
			; the address of the current line. $$ represents the
			; address of the first instruction (Should be 0x7C00).
			; So, $-$$ returns the number of bytes from the current
			; line to the start (In this case, the size of the 
			; program).
dw 0xAA55	; Boot Signiture
		; The BIOS INT 0x19 searches for a bootable disk. How does it
		; know if the disk is bootable? The boot signiture. If the 511
		; byte is 0xAA and the 512 byte is 0x55, INT 0x19 will load and
		; execute the bootloader. Because the boot signiture must be
		; the last two bytes in the bootsector, We use the times 
		; keyword to calculate the size different to fill in up to the 
		; 510th byte, rather then the 512th byte.
