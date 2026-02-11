.model tiny
.code
org 100h

COLUMN  equ 29h
STRING  equ 50h
VRAMSEG equ 0b800h

start:
    mov   ax, VRAMSEG                           ;video segment
    mov   es, ax

    call  half_column                           ;half column -> bx

    call  half_string                           ;half str -> cx
    call  half_cmd_string                       ;half cmd str -> dx
    sub   cx, dx

    call  calc_adress                           ;adress arithmetics -> di

    call  get_cmd_length                        ;length -> dl

    xor   cx, cx
    mov   cl, dl
    mov   si, 82h
    mov   ah, 0c0h

    jcxz  end_loop
    dec   cx
copy_loop:
    lodsb
    stosw
    loop  copy_loop
end_loop:

    mov   ax, 4c00h
    int   21h

half_column:
    mov   bx, COLUMN
    shr   bx, 1
    ret

half_string:
    mov   cx, STRING
    shr   cx, 1
    ret

half_cmd_string:
    call  get_cmd_length
    shr   dx, 1
    ret

get_cmd_length:
    mov   si, 80h
    mov   dl, byte ptr ds:[si]
    ret

calc_adress:
    mov   ax, STRING
    mul   bl
    add   ax, cx
    shl   ax, 1
    mov   di, ax
    ret

end start
