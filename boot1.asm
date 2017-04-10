org 0x7c00
jmp start

start:
	xor ax, ax
	mov ds, ax

reset:
	mov ah, 00h ; AH = 0, codigo da funcao que reinicia o controlador de disco
	mov dl, 0 ; numero do drive a ser resetado
	int 13h

	jc reset ; caso aconteca algum erro, tenta novamente

	mov ax, 0x500 ; ler o setor do endereco 0x500
	mov es, ax ; segmento com dados extra
	xor bx, bx

load:
	mov ah, 0x02 ;comando de ler setor do disco
	mov al, 1 ;quantidade de setores ocupados por boot2
	mov ch, 0 ;trilha 0
	mov cl, 2 ;setor 2
	mov dh, 0 ;cabeca 0
	mov dl, 0 ;drive 0
	int 13h

	jc load ;deu erro, tenta de novo

jmp 0x50:0x0 ; executar o setor do endereco 0x500:0, vai para o boot2

times 510-($-$$) db 0 ; boot tem que ter 512 bytes
dw 0xaa55 ; assinatura do boot no final