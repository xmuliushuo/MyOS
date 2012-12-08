;*********************************************
;	Boot1.asm
;		- A Simple Bootloader
;
;	Operating Systems Development Tutorial
;
; To assemble Boot.asm do this:
; nasm -f bin Boot.asm -o Boot.bin
; To write Boot.bin to a floppy disk:
; dd if=Boot.bin of=a.img bs=512 count=1 conv=notrunc
;*********************************************
 
org	0x7c00	; We are loaded by BIOS at 0x7C00
		; 伪指令org用来规定目标程序存放单元的偏移量
bits	16	; We are still in 16 bit Real Mode
		; 'BITS'指令指定 NASM 产生的代码是被设计运行在 16 位模式的处理
		; 器上还是运行在 32 位模式的处理器上
Start:
	jmp	loader

msg	db	"Welcome to My Operating System!", 0

;***************************************
;	Prints a string
;	DS=>SI: 0 terminated string
;***************************************
; INT 0x10 - VIDEO TELETYPE OUTPUT
; AH = 0x0E
; AL = Character to write
; BH - Page Number (Should be 0)
; BL = Foreground color (Graphics Modes Only)
Print:
	lodsb			; 串操作指令LODSB/LODSW是块装入指令，其具体
				; 操作是把SI指向的存储单元读入累加器,其中
				; LODSB是读入AL,LODSW是读入AX中,然后SI自动
				; 增加或减小1或2位.当方向标志位D=0时，则SI自
				; 动增加；D=1时，SI自动减小。
	or	al, al
	jz	PrintDone
	mov	ah, 0eh
	int	10h
	jmp	Print
PrintDone:
	ret

;*************************************************;
;	Bootloader Entry Point
;*************************************************;

loader:
	xor	ax, ax	; Setup segments to insure they are 0. Remember that
	mov	ds, ax	; we have ORG 0x7c00. This means all addresses are 
	mov	es, ax	; based from 0x7c00:0. Because the data segments 
	mov	si, msg	; are within the same code segment, null em.
	call	Print
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
