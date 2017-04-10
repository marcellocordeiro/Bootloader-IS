org 0x7e00
jmp start

debug db 'fml', 13, 10, 0
username times 16 db 0
hello db 'Enter your username: ', 0
input db '@OS:~$ ', 0
command times 32 db 0
invalidCommand db 'Invalid command. Type ', 39, 'help', 39, ' for a list of valid commands', 13, 10, 0

help_cmd db 'help', 0
clear_cmd db 'clear', 0
shutdown_cmd db 'shutdown', 0

start:
	xor ax, ax
	mov ds, ax
	mov es, ax

	;video mode
	mov ah, 00h
	mov al, 03h ;text mode
	int 10h

	call clear

	mov ah, 01h
	mov cx, 07h
	int 10h

	mov si, hello
	call printString

	mov di, username
	call readStr

	jmp loopp

loopp:
	mov si, username
	call printString

	mov si, input
	call printString

	mov di, command
	call readStr

	mov si, help_cmd
	mov di, command
	call strcmp
	jc .help

	mov si, clear_cmd
	mov di, command
	call strcmp
	jc .clear


	mov si, shutdown_cmd
	mov di, command
	call strcmp
	jc .shutdown

	jmp .invalidCommand

	jmp loopp

	.help:
		mov si, debug
		call printString

		jmp loopp

	.clear:
		call clear

		jmp loopp

	.shutdown:
		mov si, debug
		call printString

		;jmp done

		jmp loopp

	.invalidCommand:
		mov si, invalidCommand
		call printString

		jmp loopp

clear:
	mov ah, 07h ;scroll down
	mov al, 00h ;scroll the whole window
	mov bh, 07h ;00h = modo de vídeo, 07h = modo de texto  ; character attribute = white on black

	;upper left corner
	mov ch, 00h ;row = 0
	mov cl, 00h ;col = 0

	;lower right corner
	mov dh, 1fh ;row = 24 (0x18)
	mov dl, 4fh ;col = 79 (0x4f)
	int 10h ;call BIOS video interrupt

	;set cursor to the beginning
	mov ah, 02h
	mov bh, 00h
	xor dx, dx
	int 10h

	ret

readStr:
	mov ah, 00h ;coloca o caractere lido do teclado no registrador al
	int 16h

	cmp al, 0dh
	je .done

	cmp al, 08h
	je .backspace


	call printChar

	stosb

	jmp readStr

	.backspace:
		cmp di, command
		je readStr

		dec di ;deleta o char anterior

		mov al, 08h ;"imprime" o backspace
		call printChar

		mov al, ' ' ;deleta o caractere da tela
		call printChar

		mov al, 08h ;"imprime" o backspace de novo
		call printChar

		jmp readStr

	.done:
		mov al, 0
		stosb

		call newLine

		ret

printChar:
	mov ah, 0eh ;imprime o caractere de al
	mov bl, 02h ;cor do caractere (modo grafico)
	int 10h

	ret

printString:
	lodsb ;carrega um caractere e passa o ponteiro para o proximo / Carrega um byte de DS:SI em AL e depois incrementa SI 

	cmp al, 0 ;0 é o código do \0
	je .done ;se cmp for verdadeiro (verifica no registrador de flags)

	mov ah, 0eh ;imprime o caractere de al
	mov bh, 00h
	mov bl, 03h ;cor do caractere (modo grafico)
	int 10h

	;mov ah, 86h
	;mov cx, 1
	;xor dx, dx
	;mov dx, 2
	;int 15h

	jmp printString

	.done:
		ret

newLine:
	mov ah, 0eh
	mov al, 13 ;\n
	int 10h
	mov al, 10 ;return (início da linha)
	int 10h

	ret

strcmp:
	mov al, [si]   ; grab a byte from SI
	mov bl, [di]   ; grab a byte from DI

	cmp al, bl     ; are they equal?
	jne .notequal  ; nope, we're done.

	cmp al, 0  ; are both bytes (they were equal before) null?
	je .done   ; yes, we're done.

	inc di     ; increment DI
	inc si     ; increment SI

	jmp strcmp ; loop!

	.notequal:
		clc  ; not equal, clear the carry flag
		
		ret
 
	.done: 	
		stc  ; equal, set the carry flag
		
		ret

done:
	jmp $