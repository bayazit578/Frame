.model tiny
.code
org 100h

COLUMN      equ 19h
STRING      equ 50h
VRAMSEG     equ 0b800h
TXT_COL     equ 00000100b
FRAME_COL1  equ 00000100b
FRAME_COL2  equ 00000100b
FRAME_COL3  equ 00000100b

start:
            mov   ax, VRAMSEG                           ;video segment
            mov   es, ax

            call  half_column                           ;half column -> bx

            call  half_string                           ;half str -> dx
            call  half_cmd_string                       ;half cmd str -> cx
            sub   dx, cx

            call  calc_txt_address                      ;address arithmetics -> di

            call  get_cmd_length                        ;length -> cx

            mov   si, 82h
            mov   ah, TXT_COL

            push  di

        text_loop:
            lodsb
            stosw
            loop  text_loop

            pop   di

            call  draw_frame_1

        end_loop:                                               ;if cx == 0
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

calc_txt_address :
            mov   ax, STRING
            mul   bl
            add   ax, dx
            shl   ax, 1
            mov   di, ax
            ret

draw_frame_1:
            mov   bx, (STRING + 2)                      ;starting address of the frame
            shl   bx, 1
            sub   di, bx

            mov   ah, FRAME_COL1

            mov   al, 0c9h                              ;left top corner
            stosw

            call  get_cmd_length
            add   cx, 02h

            mov   al, 0cdh                              ;top side
        top_frame_loop:
            stosw
            loop  top_frame_loop

            mov   al, 0bbh                              ;right top corner
            stosw

            mov   bx, (STRING - 1)
            shl   bx, 1
            add   di, bx

            mov   al, 0bah                              ;right side
            stosw

            add   di, bx

            std                                         ;df = 1 -> -= 2

            mov   al, 0bch                              ;right bottom corner
            stosw

            call  get_cmd_length
            add   cx, 02h

            mov   al, 0cdh                              ;bottom side
        bottom_frame_loop:
            stosw
            loop  bottom_frame_loop

            mov   al, 0c8h                              ;left bottom corner
            stosw

            mov   bx, (STRING - 1)
            shl   bx, 1
            sub   di, bx

            mov   al, 0bah                              ;left side
            stosw

            ret

end start
