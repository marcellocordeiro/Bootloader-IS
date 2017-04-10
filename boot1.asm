org 0x7c00
jmp start

start:
	xor ax, ax
	mov ds, ax

reset:
	mov ah, 0 ; AH = 0, codigo da funcao que reinicia o controlador de disco
	mov dl, 0 ; numero do drive a ser resetado
	int 13h
	jc reset ; caso aconteca algum erro, tenta novamente

	mov ax, 0x50 ; ler o setor do endereco 0x500
	mov es, ax ; segmento com dados extra
	xor bx, bx

load:
	mov ah, 0x02 ; codigo da funcao que le do disco
	mov al, 1 ; numero de setores a serem lidos
	mov ch, 0 ; numero do cilindro a ser lido
	mov cl, 2 ; numero do setor
	mov dh, 0 ; numero do cabecote
	mov dl, 0 ; numero do drive
	int 13h
	jc load ; caso aconteca algum erro, tenta novamente

jmp 0x50:0x0 ; executar o setor do endereco 0x500:0, vai para o boot2

times 510-($-$$) db 0 ; boot tem que ter 512 bytes
dw 0xaa55 ; assinatura do boot no final