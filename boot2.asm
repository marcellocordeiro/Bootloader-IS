org 0x500
jmp 0x0000:start

string1: db 'Loading structures for the kernel...', 13, 10, 0
string2: db 'Setting up protected mode...', 13, 10, 0
string3: db 'Loading kernel in memory...', 13, 10, 0
string4: db 'Running kernel...', 13, 10, 0

start:
	xor ax, ax
	mov ds, ax

	;video mode
	mov ah, 00h
	mov al, 12h
	;int 10h

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

	mov si, string1
	call printString ; imprimindo a primeira mensagem
	call delay
	
	mov si, string2
	call printString ; imprimindo a segunda mensagem
	call delay

	mov si, string4
	call printString
	call delay
	
	mov si, string3
	call printString ; imprimindo terceira mensagem
	call delay

	reset:
		mov ah, 0
		mov dl, 0
		int 13h
		jc reset

		mov ax, 0x7e0
		mov es, ax
		xor bx, bx

		ler:
			mov ah, 0x02
			mov al, 6
			mov ch, 0
			mov cl, 3
			mov dh, 0
			mov dl, 0
			int 13h
			jc ler

			jmp 0x0000:0x7e00

delay:
	mov ah, 86h
	mov cx, 20
	xor dx, dx
	mov dx, 40
	;int 15h
	
	ret

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