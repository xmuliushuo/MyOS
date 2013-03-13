; Note: Here, we are executed like a normal COM program, but we are still in
; Ring 0. We will use this loader to set up 32 bit mode and basic exception 
; handling

; nasm -f bin Stage2.asm -o STAGE2.SYS

; This loaded program will be our 32 bit Kernel.
 
; We do not have the limitation of 512 bytes here,
; so we can add anything we want here!
 
org 0x500
 
bits 16		; we are still in real mode
 
; we are loaded at linear address 0x10000
 
jmp main	; jump to main
 
;*************************************************;
;	Prints a string
;	DS=>SI: 0 terminated string
;************************************************;
 
Print:
	pusha
.loop:
	lodsb		; load next byte from string from SI to AL
	or	al, al	; Does AL=0?
	jz	PrintDone	; Yep, null terminator found-bail out
	mov	ah,	0eh	; Nope-Print the character
	int	10h
	jmp	.loop	; Repeat until null terminator found
PrintDone:
	popa
	ret		; we are done, so return
 
;************************************************;
;	Second Stage Loader Entry Point
;************************************************;


;************************************************;
;	GDT
;************************************************;
gdt:
	dd	0
	dd	0
; code desriptor
	dw	0FFFFh 		; limit low
	dw	0 		; base low
	db	0 		; base middle
	db	10011010b 	; access
	db	11001111b 	; granularity
	db	0 		; base high
; data descriptor
	dw	0FFFFh		; limit low (Same as code)
	dw	0 		; base low
	db	0 		; base middle
	db	10010010b	; access
	db	11001111b	; granularity
	db	0		; base high
end_of_gdt:
toc:
	dw	end_of_gdt - gdt - 1
	dd	gdt

%include "A20.inc"

main:
	cli		; 设置段寄存器
	xor	ax, ax
	mov	ds, ax
	mov	es, ax
	mov	ax, 0x9000
	mov	ss, ax
	mov	sp, 0xFFFF
	sti
 
	mov	si, Msg
	call	Print
 	
	cli		
	lgdt	[toc]
	
	call	EnableA20_KKbrd_Out
	cli
	
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax
	jmp	08h:pmode

bits	32
pmode:
	mov	ax, 0x10
	mov	ds, ax
	mov	ss, ax
	mov	es, ax
	mov	esp, 9000h
	
stop:	cli
	hlt
 
;*************************************************;
;	Data Section
;************************************************;
 
Msg	db	"Preparing to load operating system...",13,10,0
