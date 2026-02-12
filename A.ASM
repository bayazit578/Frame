.model tiny
.code
org 100h

COLUMN  equ 19h
STRING  equ 50h
VRAMSEG equ 0b800h

start:
            mov   ax, VRAMSEG                           ;video segment
            mov   es, ax

            call  half_column                           ;half column -> bx

            call  half_string                           ;half str -> dx
            call  half_cmd_string                       ;half cmd str -> cx
            sub   dx, cx

            call  calc_adress                           ;adress arithmetics -> di

            call  get_cmd_length                        ;length -> cx

            mov   si, 82h
            mov   ah, 0c0h

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
            mov   dx, STRING
            shr   dx, 1
            ret

half_cmd_string:
            call  get_cmd_length
            shr   cx, 1
            ret

get_cmd_length:
            mov   si, 80h
            mov   cl, byte ptr ds:[si]
            jcxz  end_loop
            dec   cl
            xor   ch, ch
            ret

calc_adress:
            mov   ax, STRING
            mul   bl
            add   ax, dx
            shl   ax, 1
            mov   di, ax
            ret

end start
