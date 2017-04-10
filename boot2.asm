org 0x500
jmp 0x0000:start
    dados:
        string1: db 'Loading structures for the kernel...', 0
        string2: db 'Setting up protected mode...', 0
        string3: db 'Loading kernel in memory...', 0
        string4: db 'Running kernel...', 0
start:
    xor ax, ax
    mov ds, ax

    mov ah, 0
    mov al, 13                      ;Entra no modo video
    int 10h

    call espera
    mov ah, 2
    mov bh, 0                           ;move cursor
    mov dh, 3
    mov dl, 0
    int 10h
    mov si, string1                     ;printa string1
    call printString
    call espera

    mov ah, 2
    mov bh, 0                           ;Move cursor
    mov dh, 5
    mov dl, 0
    int 10h
    mov si, string2                     ;Printa string2
    call printString
    call espera

    mov ah, 2
    mov bh, 0
    mov dh, 7                           ;Move cursor
    mov dl, 0
    int 10h
    mov si, string3                    ;Printa string3
    call printString
    call espera

    mov ah, 2
    mov bh, 0
    mov dh, 9                           ;move cursor
    mov dl, 0
    int 10h
    mov si, string4                     ;Printa string4
    call printString

    call espera
    call espera

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

  espera:                                           ;Macro que espera 1 segundo
    mov ah, 86h
    mov cx, 10
    mov dx, 0
    int 15h

    ret

  printString:                              ;Macro que printa a string localizada em si
     mov cl, 0
     imprime:
        lodsb
        cmp al, cl
        je feito

        mov ah, 0xe
        mov bh, 0
        mov bl, 3
        int 10h
        jmp imprime

      feito:
        ret


















