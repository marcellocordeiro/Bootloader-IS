org 0x7e00
jmp start

username times 32 db 0
command times 32 db 0
commandCopy times 32 db 0

;strings
debug db 'fml', 13, 10, 0
hello db 'Enter your username: ', 0
input db '@OS:~$ ', 0
invalidCommand db 'Invalid command. Type ', 39, 'help', 39, ' for a list of valid commands', 13, 10, 0
nothingHere db 'nothing here, sorry', 0

;commands
help_cmd db 'help', 0
clear_cmd db 'clear', 0
shutdown_cmd db 'shutdown', 0

;bsod
bsod1 db 10, 10, 10, 10, '            Wh-what happened?', 13, 10, 0
bsod2 db '            Did I just crash?', 13, 10, 0
bsod3 db '            ... or am I being invaded?', 13, 10, 0
bsod4 db '            Oh sh...', 13, 10, 10, 10, 0
bsod5 db 10, 10, 10, 10, '            Hello, and thank you for letting me install a virus', 13, 10, 0
bsod6 db '            Just sit tight while I wipe all your data', 13, 10, 0
bsod7 db '            ur loss, playboy!', 13, 10, 0

;variaveis aux
stringColor times 8 db 0
bgColors db 00h, 04h, 0fh, 0bh, 03h, 0ah, 07h, 09h, 06h, 0ch, 02h, 0eh, 05h, 0dh, 01h

start:
	xor ax, ax
	mov ds, ax
	mov es, ax

	;text mode
	mov ah, 00h
	mov al, 03h
	int 10h

	;blinking cursor: full block
	mov ah, 01h
	mov cx, 07h
	int 10h

	call clearTxt

	mov si, hello
	call printString

	mov si, nothingHere
	mov di, commandCopy
	call copy

	mov di, command
	call readStr

	mov si, command
	mov di, username
	call copy

main:
	;imprime o username
	mov si, username
	call printString

	;imprime @OS~$
	mov si, input
	call printString

	;recebe o comando do usuário
	mov di, command
	call readStr

	;salva o command atual em commandCopy
	mov si, command
	mov di, commandCopy
	call copy

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

	;usuário não digitou nada?
	mov si, command
	cmp byte[si], 0
	je main

	;usuário não digitou nenhum comando válio
	jmp .invalidCommand

	.help:
		mov si, clear_cmd
		call printString
		call newLine

		mov si, shutdown_cmd
		call printString
		call newLine

		jmp main

	.clear:
		call clearTxt

		jmp main

	.shutdown:
		call bsod ;;;;; call bsod_

		jmp done

	.invalidCommand:
		mov si, invalidCommand
		call printString

		jmp main

clearTxt:
	mov bh, 07h ;00h = modo de vídeo, 07h = modo de texto  ; character attribute = white on black
	jmp clear

clearVideo:
	mov bh, 00h
	jmp clear

clear:
	mov ah, 07h ;scroll down
	mov al, 00h ;scroll the whole window

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

clearLine:
	cmp di, command ;verifica se di está no início de command
	je .done

	dec di ;deleta o char anterior

	mov al, 08h ;"imprime" o backspace
	call printChar

	mov al, ' ' ;deleta o caractere da tela
	call printChar

	mov al, 08h ;"imprime" o backspace de novo
	call printChar

	jmp clearLine

	.done:
		ret

copy:
	lodsb ;carrega um caractere e passa o ponteiro para o proximo / Carrega um byte de DS:SI em AL e depois incrementa SI 

	stosb ;salva al em di

	cmp al, 0 ;0 é o código do \0
	je .done ;se cmp for verdadeiro (verifica no registrador de flags)

	jmp copy

	.done:
		ret

readStr:
	mov ah, 00h ;coloca o caractere lido do teclado no registrador al
	int 16h

	cmp al, 0dh ;enter?
	je .done

	cmp al, 08h ;backspace?
	je .backspace

	cmp ah, 48h ;up arrow?
	je .prevCommand

	cmp ah, 50h ;down arrow?
	je .clearLine

	cmp ah, 4bh ;left arrow?
	je readStr ;??

	cmp ah, 4dh ;right arrow?
	je readStr ;??

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

	.prevCommand:
		call clearLine
		
		mov si, commandCopy
		mov di, command

		.copyCommand:
			lodsb ;carrega um caractere e passa o ponteiro para o proximo / Carrega um byte de DS:SI em AL e depois incrementa SI 

			stosb ;salva al em di

			cmp al, 0 ;0 é o código do \0
			jne .copyCommand ;se cmp for verdadeiro (verifica no registrador de flags)

		mov si, command
		call printString

		dec di
		jmp readStr

	.clearLine:
		call clearLine

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
	;mov bl, 03h ;cor do caractere (modo grafico)
	int 10h

	jmp printString

	.done:
		ret

printString_Delay:
	lodsb ;carrega um caractere e passa o ponteiro para o proximo / Carrega um byte de DS:SI em AL e depois incrementa SI 

	cmp al, 0 ;0 é o código do \0
	je .done ;se cmp for verdadeiro (verifica no registrador de flags)

	mov ah, 0eh ;imprime o caractere de al
	mov bh, 00h
	mov bl, byte[stringColor]
	;mov bl, 03h ;cor do caractere (modo grafico)
	int 10h

	;delay
	mov ah, 86h
	mov cx, 1
	mov dx, 2
	int 15h

	jmp printString_Delay

	.done:
		ret

printString_Delay_C:
	lodsb ;carrega um caractere e passa o ponteiro para o proximo / Carrega um byte de DS:SI em AL e depois incrementa SI 

	cmp al, 0 ;0 é o código do \0
	je .done ;se cmp for verdadeiro (verifica no registrador de flags)

	mov ah, 0eh ;imprime o caractere de al
	mov bh, 00h
	mov bl, byte[stringColor]
	;mov bl, 03h ;cor do caractere (modo grafico)
	int 10h

	;mudar cor do fundo
	mov bl, byte[di]
	cmp bl, 01h
	je .resetColor
	jne .continue

	.resetColor:
		mov di, bgColors
		jmp .continue

	.continue:
		call changeColor
		inc di

	jmp printString_Delay_C

	.done:
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

newLine:
	mov ah, 0eh
	mov al, 13 ;\n
	int 10h

	mov al, 10 ;return (início da linha)
	int 10h

	ret

delay:
	mov ah, 86h
	mov cx, 20
	xor dx, dx
	mov dx, 40
	int 15h
	
	ret

delay_p:
	mov ah, 86h
	mov cx, 2
	xor dx, dx
	mov dx, 40
	int 15h
	
	ret

changeColor:
	;background color
	mov ah, 0bh
	mov bh, 00h
	int 10h
	call delay_p

	ret

blink:
	;pisca cores alokado

	call clearVideo

	mov bl, [di]
	cmp bl, 01h
	je .resetColor
	jne .continue

	.resetColor:
		mov di, bgColors
		jmp .continue

	.continue:
		call changeColor
		inc di

	ret

bsod:
	;video mode
	mov ah, 00h
	mov al, 12h
	int 10h

	;background
	mov ah, 0bh
	mov bh, 00h
	mov bl, 01h
	int 10h

	;di aponta para o vetor das cores do bg
	mov di, bgColors

	;imprime strings (invadido)
	mov byte[stringColor], 0fh ;parametro printString_Delay_C (cor)

	mov si, bsod1
	call printString_Delay

	mov si, bsod2
	call printString_Delay

	mov si, bsod3
	call printString_Delay_C

	mov si, bsod4
	call printString_Delay_C

	;pisca colorido
	call blink

	;imprime strings (invasor)
	mov byte[stringColor], 0eh ;parametro printString_Delay_C (cor)

	mov si, bsod5
	call printString_Delay_C

	mov si, bsod6
	call printString_Delay_C

	mov si, bsod7
	call printString_Delay_C

	;video mode
	mov ah, 00h
	mov al, 13h
	int 10h

	;background
	mov ah, 0bh
	mov bh, 00h
	mov bl, 00h
	int 10h

	ret

bsod_:
	;video mode
	mov ah, 00h
	mov al, 12h
	int 10h

	;background
	mov ah, 0bh
	mov bh, 00h
	mov bl, 01h
	int 10h

	;imprime strings (invadido)
	mov bl, 0fh ;parametro printString_Delay (cor)

	mov si, bsod1
	call printString_Delay
	call delay

	mov si, bsod2
	call printString_Delay
	call delay

	mov si, bsod3
	call printString_Delay
	call delay

	mov si, bsod4
	call printString_Delay
	call delay

	;pisca colorido
	call blink

	;imprime strings (invasor)
	mov bl, 0eh ;parametro printString_Delay (cor)

	mov si, bsod5
	call printString_Delay
	call delay

	mov si, bsod6
	call printString_Delay
	call delay

	mov si, bsod7
	call printString_Delay
	call delay

	ret

done:
	jmp $