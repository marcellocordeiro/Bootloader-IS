org 0x7e00
jmp 0x0000: start

        dados:
            aga: db 'Play again?(r)', 0
            r: db 'r: Reset', 0
            c: db 'w: Cima', 0
            s: db 's: Baixo', 0
            d: db 'd: Direita', 0
            a: db 'a: Esquerda', 0
            p: db 's: Start', 0
            e: db 'espaco: Tiro', 0
            grupo: db 'Dupla: Carlos Valadares', 0
            vicente: db 'Vicente Ribeiro', 0
            vence: db 'YOU WIN.', 0
            congra: db 'CONGRATULATIONS!', 0
            inicio: db 'START!', 0
            bo: db 'BOSS!', 0
            lose: db 'YOU LOSE.', 0
            over:   db 'GAME OVER!', 0
            dezena  times 1 db 0
            unidade times 1 db 0
            BossX times 2 db 0
            score times 2 db 0
            scoreprint times 2 db 0
            velocidade times 2 db 0
            EnemyX times 2 db 0
            tiroX times 2 db 0
            tiroY times 2 db 0
            posx times 2 db 0
            posy times 2 db 0
            limit times 2 db 0
            i times 2 db 0
            v times 2 db 0
            contador times 2 db 0
start:
        xor ax, ax
        mov ds, ax

        mov ah, 0               ;Entra no modo video
        mov al, 13
        int 10h

        call apresentacao

    comeco:
        call limpaTela
        mov ah, 0xb                 ;Muda a cor do fundo da tela para branco
        mov bh, 0
        mov bl, 15
        int 10h

        mov cx, 0                               ;Inicializa as variaveis
        mov dx, 199
        mov [posy], dx                       ;posy = 199
        mov [posx], cx                       ;posx = 0
        mov [tiroX], cx                       ;tiroX = 0
        mov [tiroY], dx                       ;tiroY = 199
        mov [EnemyX], cx                  ;EnemyX = 0
        mov [BossX], cx                     ;BossX = 0
        mov [score], cx                      ;score = 0
        inc cx
        mov [velocidade], cx              ;velocidade = 1
        mov cl, 48
        mov [unidade], cl                   ;unidade = 48 (0 em ASCII)
        mov [dezena], cl                    ;Dezena = 48 (0 em ASCII)

        call printAviao

        mov si, inicio
        mov ah, 2
        mov bh, 0                             ;printa inicio
        mov dh, 10
        mov dl, 15
        int 10h
        call printString


               mov ah, 86h                  ;Espera
               mov cx, 10
               mov dx, 0
               int 15h

        jogo:
            mov ah, 01h
            int 16h                             ;Ve se tem algo no buffer
            jnz teclado                       ;Se tiver ele vai para teclado

            mov ah, 86h                     ;Espera
            mov cx, 1
            mov dx, 0
            int 15h
            call atualiza                     ;Ataliza a tela
            jmp jogo

       boss:                                    ;Chefao
            call limpaTela
            call printAviao

            mov si, bo
            mov ah, 2
            mov bh, 0                       ;Move o cursor para o meio da tela
            mov dh, 10
            mov dl, 15
            int 10h
            call printString                ;Printa boss

                mov ah, 86h                ;Espera
                mov cx, 18
                mov dx, 0
                int 15h

            jogoBoss:

                mov ah, 01h                 ;Ve se tem algo no buffer
                int 16h
                jnz tecladoBoss             ;Caso tenha vai para teclado boss

                mov ah, 86h                 ;Espera
                mov cx, 1
                mov dx, 0
                int 15h
                call atualizaBoss           ;Atualiza a tela no modo boss
                jmp jogoBoss

    atualizaBoss:                           ;Macro que atualiza a tela no modo boss
        call limpaTela                      ;Liimpa a  tela
        call printAviao                     ;Printa o aviao na posicao posx e posy
        call AtualizaTiroBoss           ;Faz o tiro subir
        call AtualizaEnemyBoss      ;Atualiza a posicao do boss
        ret

        tecladoBoss:
            mov ah, 0                       ;Pega do buffer e joga em AL
            int 16h

            mov cx, [posx]                 ;cx recebe a posicao x do aviao
            mov dx, [posy]                 ;dx recebe a posicao y do aviao

            cmp al, 64h                     ;se foi digitado d
            je direitaBoss
            cmp al, 61h                     ;se foi digitado a
            je esquerdaBoss
            cmp al, 77h                     ;se foi digitado w
            je cimaBoss
            cmp al, 73h                     ;se foi digitado s
            je baixoBoss
            cmp al, 20h                     ;se foi digitado espaco
            je espacoBoss
            cmp al, 62h                     ;cheat
            je win
            cmp al, 72h                     ;Reset
            je comeco
            jmp finish

            direitaBoss:
                cmp cx, 286                 ;Condicao para movimentacao a direita
                je finish

                add cx, 26                      ;Move 26 pixels para a direita
                mov [posx], cx
                jmp finish
            esquerdaBoss:
                cmp cx, 0                       ;Condicao para movimentacao a esquerda
                je finish

                sub cx, 26                      ;Move 26 pixels para a esquerda
                mov [posx], cx
                jmp finish
            cimaBoss:
                cmp dx, 115                 ;Condicao para movimentacao para cima
                je finish

                sub dx, 7                       ;Move 7 pixels para cima
                mov [posy], dx
                jmp finish
            baixoBoss:
                cmp dx, 199                 ;Condicao para movimentacao para baixo
                je finish

                add dx, 7                      ;Move 7 pixels para baixo
                mov [posy], dx
                jmp finish
            espacoBoss:
                mov cx, [posx]              ;Faz o tiro ser desenhado na ponta da nave
                mov dx, [posy]
                add cx, 12
                sub dx, 8
                mov [tiroX], cx
                mov [tiroY], dx
                call printTiro

         finish:
            jmp jogoBoss                    ;Volta para o loop do jogo no modo boss

         AtualizaEnemyBoss:             ;Macro que atualiza a posicao do chefao
            mov cx, [BossX]
            cmp cx, 270                     ;Caso ele tenha chegado no final o usuario perdeu
            ja gameOver

            mov ax, 1
            add cx, ax                          ;Desloca 1 pixel para direita
            mov [BossX], cx
            call printBoss
            ret

         printBoss:                             ;Macro que desenha o chefao na tela
            mov dx, 60

            linha4:
                cmp dx, 15                      ;Consiste em um retangulo que vai de 60 - 15 de altura
                je finish4                          ;e posicao x dele ate cx  + 50 (50 pixels de comprimento)
                mov cx, [BossX]

                coluna4:
                    mov ah, 0ch
                    mov bh, 0
                    mov al, 1
                    int 10h

                    inc cx
                    mov ax, [BossX]
                    add ax, 50
                    cmp cx, ax
                    jb coluna4
                    dec dx
                    jmp linha4
            finish4:
                ret

          AtualizaTiroBoss:                         ;Macro que atualiza a posicao do tiro
            mov dx, [tiroY]
            cmp dx, 199
            je finish3

            cmp dx, 5                               ;Compara se o tiro excedeu o limite superior
            ja continua4
            mov dx, 199
            mov [tiroY], dx
            jmp finish3

            continua4:
                mov cx, [tiroX]                     ;cx recebe a coordenada x do tiro
                mov dx, [tiroY]                     ;dx recebe a coordenada y do tiro
                mov ax, [BossX]                   ;ax recebe a coordenada x do chefao

                add ax, 23                            ;Compara se o tiro acertou no CM do chefao
                cmp cx, ax                            ;Dados pixels de margem de erro
                jl continue
                add ax, 4
                cmp cx, ax
                ja continue
                cmp dx, 40
                ja continue
                cmp dx, 36
                jl continue
                jmp acertouBoss

                continue:                               ;O tiro nao acertou no chefao
                    mov dx, [tiroY]
                    sub dx, 5                           ;Atualiza a posicao do tiro e printa ele
                    mov [tiroY], dx
                    call printTiro
                    jmp finish3
              acertouBoss:                           ;Caso o tiro tenha acertado o usuario ganhou
                jmp win

            finish3:
                ret



        teclado:
            mov ah, 0                                   ;Pega do buffer e joga em AL
            int 16h

            mov cx, [posx]                          ;cx recebe a posicao x da nave
            mov dx, [posy]                          ;dx recebe a posicao y da nave

            cmp al, 64h                               ;Ve se foi digitado a
            je direita
            cmp al, 61h                               ;Ve se foi digitado d
            je esquerda
            cmp al, 77h                               ;Ve se foi digitado w
            je cima
            cmp al, 73h                               ;Ve se foi digitado s
            je baixo
            cmp al, 20h                               ;Ve se foi digitado espaco
            je espaco
            cmp al, 70h                               ;cheat(P)
            je boss
            cmp al, 72h                               ;Reset
            je comeco
            jmp feito1

            direita:
                cmp cx, 286                          ;Condicao para movimentacao a direita
                je feito1

                add cx, 26                             ;Modifica a coordenada x da nave 26 pixels a direita
                mov [posx], cx
                jmp feito1

             esquerda:
                cmp cx, 0                              ;Condicao para movimentacao a esquerda
                je feito1

                sub cx, 26                             ;Modifica a coordenada x da nave 26 pixels a esquerda
                mov [posx], cx
                jmp feito1

             cima:
                cmp dx, 115                         ;Condicao de movimentacao para cima
                je feito1

                sub dx, 7                              ;Modifica a coordenada y da nave 7 pixels para cima
                mov [posy], dx
                jmp feito1

             baixo:
                cmp dx, 199                        ;Condicao para movimentacao para baixo
                je feito1

                add dx, 7                              ;Modifica a coordenada y da nave 7 pixels para baixo
                mov [posy], dx
                jmp feito1

             espaco:

                mov cx, [posx]                    ;cx recebe a posicao x da nave
                mov dx, [posy]                    ;dx recebe a posicao y da nave
                add cx, 12                           ;adiciona 12 a cx para ele ficar no centro da nave
                sub dx, 8                             ;Subtrai 8 de dx para ele ficar logo acima da nave
                mov [tiroX], cx                    ;Guarda a nova coordenada x do tiro
                mov [tiroY], dx                    ;Guarda a nova coordenada y do tiro
                call printTiro

             feito1:
                jmp jogo

        atualiza:                                       ;Macro que atualiza a tela
            call limpaTela
            call printAviao
            call AtualizaTiro
            call AtualizaEnemy
            call printScore
            ret

        printScore:                                 ;Macro que exibe o score na tela
            mov ah, 2                              ;Move o cursor para o canto superior esquerdo da tela
            mov bh, 0
            mov dh, 1
            mov dl, 1
            int 10h

           mov al, [dezena]                    ;Printa a dezena do score
           mov ah, 0xe
           mov bh, 0
           mov bl, 1
           int 10h

           mov al, [unidade]                   ;Printa a unidade do score
           mov ah, 0xe
           mov bh, 0
           mov bl, 1
           int 10h
            ret





       AtualizaEnemy:                                   ;Macro que atualiza a posicao da nave inimiga
            mov cx, [EnemyX]
            cmp cx, 300                                   ;Se a nave inimiga tiver chegado no fim da tela o usuario perdeu
            ja gameOver

            mov ax, [velocidade]                    ;Adiciona a posicao de acordo com a velocidade
            add cx, ax
            mov [EnemyX], cx
            call printEnemy
            ret

        printEnemy:                                       ;Macro que desenha o inimigo na tela
            mov dx, 30

            linha3:                                            ;Altura -> vai de 30 ate 20(10 pixels)
                cmp dx, 20
                je feito4
                mov cx, [EnemyX]                    ;Comprimento -> vai de cx(coordenada x do inimigo ate cx+20), ou seja, 20 pixels de comprimento

                coluna3:
                    mov ah, 0ch
                    mov bh, 0
                    mov al, 1
                    int 10h

                    inc cx
                    mov ax, [EnemyX]
                    add ax, 20
                    cmp cx, ax
                    jb coluna3
                    dec dx
                    jmp linha3

             feito4:
                ret


       AtualizaTiro:                                                ;Macro que atualiza a posicao do tiro
            mov dx, [tiroY]                                       ;Condicao para o tiro existir
            cmp dx, 199
            je feito2

            cmp dx, 5                                              ;Se ele passou do limite superior da tela
            ja continua
            mov dx, 199
            mov [tiroY], dx
            jmp feito2

            continua:
                mov ax, [EnemyX]                        ;ax recebe a coordenada x do inimigo
                mov cx, [tiroX]                              ;cx recebe a coordenada x do tiro
                cmp cx, ax                                    ;dx recebe a coordenada y do tiro
                jl continua2
                add ax, 20
                cmp cx, ax
                ja continua2                                  ;Verifica se o tiro acertou o inimigo
                mov dx, [tiroY]
                cmp dx, 30
                ja continua2
                cmp dx, 20
                jl continua2
                jmp acertou

                continua2:                                  ;O tiro ainda nao acertou o inimigo
                    mov dx, [tiroY]
                    sub dx, 5                                ;Atualiza a coordenada y do tiro
                    mov [tiroY], dx
                    call printTiro
                    jmp feito2

        acertou:                                               ;O tiro acertou o inimigo
            mov ax, 0
            mov [EnemyX], ax                           ;Inicializa a posicao do inimigo para zero novamente
            add ax, 199
            mov [tiroY], ax                                 ;Tambem Inicializa a posicao do tiro
            mov dx, [unidade]                            ;dx recebe a unidade de score
            mov cx, [score]                                ;cx recebe o score
            inc dx                                               ;Incrementa o score
            inc cx
            mov [score], cx
            mov [unidade], dx
            cmp dx, 58                                       ;Se a unidade tiver passado de 9(ASCII)
            jb conti

            mov al, 48
            mov [unidade], al                             ;A unidade recebe 0(ASCII) e dezena e incrementado
            mov al, [dezena]
            inc al
            mov [dezena], al
            conti:

            cmp cx, 5                                         ;Delimita o score para que haja aumento de velocidade
            je incrementa
            cmp cx, 8
            je incrementa
            cmp cx, 10
            je incrementa
            cmp cx, 12
            je incrementa
            cmp cx, 15                                      ;Score para chegar ao chefao
            je boss

            jmp feito2

                incrementa:
                    mov dx, [velocidade]            ;Velocidade e incrementada
                    inc dx
                    mov [velocidade], dx

        feito2:
            ret

        printTiro:                                          ;Macro que printa o tiro
            mov cx, [tiroX]
            mov dx, [tiroY]                             ;cx recebe a coordenada x do tiro
            mov bx, 0                                     ;dx recebe a coordenada y do tiro
            linha2:                                          ;O tiro tem 5 pixels de altura e 1 de comprimento

                mov ah, 0ch
                mov bh, 0
                mov al, 0xc
                int 10h

                dec dx
                inc bx
                cmp bx, 5
                je feito3
                jmp linha2
        feito3:
            ret

        printAviao:                                 ;Macro que printa o aviao na posisao posx e posy
            mov cx, [posx]                       ;cx recebe posx
            mov dx, [posy]                       ;dx recebe posy
            mov ax, 25                             ;ax recebe o comprimento do aviao
            add ax, cx
            mov [v], ax                            ;v e o limite lateral direito
            mov [i], cx                             ;i e o limite lateral esquerdo
            sub dx, 7
            mov [limit], dx                       ;limit e o limite superior
            mov dx, [posy]
            linha:
                mov ax, [limit]
                cmp dx, ax
                je feito
                coluna:
                    mov ah, 0ch
                    mov bh, 0
                    mov al, 0xc
                    int 10h

                    mov ax, [v]
                    inc cx
                    cmp cx, ax
                    jne coluna

             dec dx

             mov cx, [i]
             add cx, 2
             mov [i],cx

             mov ax, [v]
             sub ax, 2
             mov [v],ax
             jmp linha

             feito:
                ret

                gameOver:                               ;Macro que atualiza a tela na situacao de game over
                    call limpaTela
                    mov ah, 0xb                         ;Modifica a cor da tela para preto
                    mov bh, 0
                    mov bl, 0
                    int 10h




                    mov ah, 2                               ;Move o cursor para o meio da tela
                    mov bh, 0
                    mov dh, 10
                    mov dl, 15
                    int 10h
                    mov si, lose                           ;printa lose
                    call printString

                        mov ah, 2                       ;Move o cursor para o meio da tela porem duas linha abaixo da anterior
                        mov bh, 0
                        mov dh, 12
                        mov dl, 14
                        int 10h

                        mov si, over                    ;Printa over
                        call printString

                        Again:                              ;Caso o usuario queira jogar dnv
                            mov ah, 2
                            mov bh, 0
                            mov dh, 16
                            mov dl, 10
                            int 10h                         ;O jogo comecara do inicio quando apertada a tecla r em um determidado tempo
                            mov si, aga
                            call printString
                            mov dx, 100
                            lop:
                                cmp dx, 0
                                je fim

                                mov ah, 0
                                int 16h

                                cmp al, 72h
                                je comeco
                                dec dx
                                jmp lop
                    jmp fim

            win:                                        ;Macro que atualiza a tela na situacao do usuario ganhar
                call limpaTela

                mov ah, 0xb
                mov bh, 0                           ;Muda a tela para preto
                mov bl, 0
                int 10h

                mov bx, [scoreprint]                    ;Printa a carinha
                mov al, bh
                mov ah, 0xe
                mov bh, 0
                mov bl, 2
                int 10h

                mov al, bl
                mov ah, 0xe
                mov bh, 0
                mov bl, 2
                int 10h

                mov ah, 2                                   ;Move o cursor para o meio da tela
                mov bh, 0
                mov dh, 10
                mov dl, 15
                int 10h
                mov si, vence                             ;Printa vence
                call printString

                    mov ah, 2                               ;Move o cursor para o meio da tela porem duas linhas abaixo da anterior
                    mov bh, 0
                    mov dh, 12
                    mov dl, 11
                    int 10h

                    mov si, congra                          ;Printa congra
                    call printString

                Again2:                                         ;Caso o usuario queira jogar de novo
                            mov ah, 2
                            mov bh, 0
                            mov dh, 16
                            mov dl, 10
                            int 10h                             ;O jogo comecara do inicio ao apertar r em um determidado tempo
                            mov si, aga
                            call printString
                            mov dx, 100
                            lop2:
                                cmp dx, 0
                                je fim

                                mov ah, 0
                                int 16h

                                cmp al, 72h
                                je comeco
                                dec dx
                                jmp lop2
                    jmp fim



            limpaTela:                                      ;Macro que limpa a tela
                    mov ah, 06h
                    mov al, 0
                    mov ch, 0
                    mov cl, 0
                    mov dh, 19h
                    mov dl, 50h
                    int 10h

                    ret





    fim:


        jmp $

dw 0xaa55

apresentacao:                                 ;Macro que faz a apresentacao do jogo para o usuario
        mov ah, 2
        mov bh, 0                                ;Move o cursor
        mov dh, 4
        mov dl, 4
        int 10h
        mov si, p                                 ;Printa p
        call printString

        mov ah, 2
        mov bh, 0                               ;Move o cursor
        mov dh, 6
        mov dl, 4
        int 10h
        mov si, r                                  ;Printa r
        call printString

        mov ah, 2
        mov bh, 0                               ;Move o cursor
        mov dh, 8
        mov dl, 4
        int 10h
        mov si, c                               ;Printa c
        call printString

        mov ah, 2
        mov bh, 0                              ;Move o cursor
        mov dh, 10
        mov dl, 4
        int 10h
        mov si, s                               ;Printa s
        call printString

        mov ah, 2
        mov bh, 0                               ;Move o cursor
        mov dh, 12
        mov dl, 4
        int 10h
        mov si, d                                 ;Printa d
        call printString

        mov ah, 2
        mov bh, 0                               ;Move o cursor
        mov dh, 14
        mov dl, 4
        int 10h
        mov si, a                                 ;Printa a
        call printString

        mov ah, 2
        mov bh, 0                               ;Move o cursor
        mov dh, 16
        mov dl, 4
        int 10h
        mov si, e                                ;Pritna e
        call printString

        mov ah, 2
        mov bh, 0                               ;Move o cursor
        mov dh, 20
        mov dl, 4
        int 10h
        mov si, grupo                       ;Printa grupo
        call printString

        mov ah, 2
        mov bh, 0                             ;Move cursor
        mov dh, 22
        mov dl, 11
        int 10h
        mov si, vicente                     ;Printa vicente
        call printString

        ler:                                        ;Espera o usuario apertar s para comecar
            mov ah, 0
            int 16h

            cmp al, 73h
            je pronto
            jmp ler
          pronto:
                ret

  printString:                                      ;Macro que printa a string presente em si
     mov cl, 0
     impress:
        lodsb
        cmp al, cl
        je feit

        mov ah, 0xe
        mov bh, 0
        mov bl, 2
        int 10h
        jmp impress

      feit:
        ret

  espera:                                                   ;Macro que espera 4 segundos
    mov ah, 86h
    mov cx, 40
    mov dx, 0
    int 15h

    ret