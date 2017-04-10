org 0x7e00
jmp start

debug db 'fml', 13, 10, 0

start:
	;video mode
	mov ah, 00h
	mov al, 12h
	int 10h

	;background
	;mov ah, 0bh
	;mov bh, 00h
	;mov bl, 00h
	;int 10h

	;set palette
	mov ah, 0bh
	mov bh, 01h
	mov bl, 00h
	int 10h

	xor ax, ax
	mov ds, ax

	mov si, debug
	call printString

	jmp $

printString:
	lodsb ;carrega um caractere e passa o ponteiro para o proximo / Carrega um byte de DS:SI em AL e depois incrementa SI 

	cmp al, 0 ;0 é o código do \0
	je .done ;se cmp for verdadeiro (verifica no registrador de flags)

	mov ah, 0eh ;imprime o caractere de al
	mov bh, 00h
	mov bl, 03h ;cor do caractere (modo grafico)
	int 10h

	mov ah, 86h
	mov cx, 1
	xor dx, dx
	;mov dx, 2
	;int 15h

	jmp printString

	.done:
		ret

dw 0xaa55
