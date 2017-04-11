org 0x7e00
jmp start

username times 32 db 0
command times 32 db 0

debug db 'fml', 13, 10, 0
hello db 'Enter your username: ', 0
input db '@OS:~$ ', 0
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

	mov di, command
	call readStr

	mov si, command
	mov di, username

	.copyUsername:
		lodsb ;carrega um caractere e passa o ponteiro para o proximo / Carrega um byte de DS:SI em AL e depois incrementa SI 

		stosb ;salva al em di

		cmp al, 0 ;0 é o código do \0
		je .done ;se cmp for verdadeiro (verifica no registrador de flags)

		jmp .copyUsername

		.done:
			jmp loopp

loopp:
	mov si, username
	call printString ;imprime o username

	mov si, input
	call printString ;imprime @OS~$

	mov di, command
	call readStr ;recebe o comando do usuário

	;usuário digitou help?
	mov si, help_cmd
	mov di, command
	call strcmp
	jc .help

	;usuário digitou clear?
	mov si, clear_cmd
	mov di, command
	call strcmp
	jc .clear

	;usuário digitou shutdown?
	mov si, shutdown_cmd
	mov di, command
	call strcmp
	jc .shutdown

	;usuário não digitou nenhum comando válio
	jmp .invalidCommand

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

	cmp al, 0dh ;enter?
	je .done

	cmp al, 08h ;backspace?
	je .backspace

	call printChar

	stosb

	jmp readStr

	.backspace:
		cmp di, command ;verifica se nenhuma letra foi digitada
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
		cmp di, command ;verifica se nenhuma letra foi digitada
		je readStr

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
	mov al, [si] ;salva um byte de si
	mov bl, [di] ;salva um byte de di

	cmp al, bl ;os caracteres são iguais?
	jne .notequal ;nay

	cmp al, 0 ;os dois caracteres são 0?
	je .done ;yay

	inc di ;incrementa di
	inc si ;incrementa si

	jmp strcmp

	.notequal:
		clc ;reseta a flag de carry

		ret

	.done:
		stc ;seta a flag de carry

		ret

done:
	jmp $