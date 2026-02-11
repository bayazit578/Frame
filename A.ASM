.model tiny
.code
org 100h

hui:
    mov  ax, 0b800h                          ;video segment
    mov  es, ax

    call half_column

    call half_string

    call half_cmd_string

    sub  cx, ax

    call calc_adress

    mov  byte ptr es:[bx], 21h
    mov  byte ptr es:[bx + 1], 2ch

    mov  ax, 4c00h
    int  21h

half_column:
    mov ax, 1dh                             ;half column -> bx
    mov cl, 02h
    div cl
    xor ah, ah

    mov bl, al
    xor bh, bh
    inc bl
    ret

half_string:
    mov ax, 80h                             ;half string -> cx
    mov cl, 02h
    div cl
    xor ah, ah

    mov cl, al
    xor ch, ch
    inc cl
    ret

half_cmd_string:
    push bx

    mov  si, 80h                            ;half cmd str -> ax
    mov  al, byte ptr ds:[si]
    mov  bl, 02h
    div  bl
    xor  ah, ah

    pop  bx
    ret

calc_adress:
    mov al, 80h                             ;adress arithmetics -> bx
    mul bl
    add ax, cx
    mov bx, ax
    ret

end hui
