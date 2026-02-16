.model tiny

.data

FRAME_SYMB  db 's', 's', 's', 's', 's', 's'
FRAME_SYMB1 db 0c9h, 0cdh, 0bbh, 0bah, 0bch, 0c8h           ;double frame
FRAME_SYMB2 db 0dah, 0c4h, 0bfh, 0b3h, 0d9h, 0c0h           ;single frame

.code
org 100h

COLUMN      equ 19h
STRING      equ 50h
VRAMSEG     equ 0b800h
TXT_COL     equ 00000100b
FRAME_COL1  equ 00000100b
FRAME_COL2  equ 00000100b
FRAME_COL3  equ 00000100b

Main:               mov   ax, VRAMSEG                      
                    mov   es, ax

                    call  half_column                       ;half column -> bx

                    call  half_string                       ;half str -> dx
                    call  half_cmd_string                   ;half cmd str -> cx
                    sub   dx, cx

                    call  calc_txt_address                  ;address arithmetics -> di

                    call  get_txt_length                    ;length -> cx

                    mov   si, 84h                           ;text drawing
                    mov   ah, TXT_COL

                    push  di

                text_loop:
                    lodsb
                    stosw
                    loop  text_loop

                    pop   di

                    mov   si, 82h                           ;get type of frame
                    xor   cx, cx
                    mov   cl, byte ptr ds:[si]

                    mov   dx, offset FRAME_SYMB
                    call  draw_frame

                end_loop:                                   ;if cx == 0
                    mov   ax, 4c00h
                    int   21h

;-----------------------------------------------------------
;
;
;
;
;
;-----------------------------------------------------------

half_column         proc
                    push  bp
                    mov   bp, sp

                    mov   bx, COLUMN
                    shr   bx, 1

                    pop   bp
                    ret

half_column         endp

;-----------------------------------------------------------
;
;
;
;
;
;-----------------------------------------------------------

half_string         proc
                    push  bp
                    mov   bp, sp

                    mov   dx, STRING
                    shr   dx, 1

                    pop   bp
                    ret

half_string         endp

;-----------------------------------------------------------
;
;
;
;
;
;-----------------------------------------------------------

half_cmd_string     proc
                    push  bp
                    mov   bp, sp

                    call  get_txt_length
                    shr   cx, 1

                    pop   bp
                    ret

half_cmd_string     endp

;-----------------------------------------------------------
;
;
;
;
;
;-----------------------------------------------------------

get_txt_length      proc
                    push  bp
                    mov   bp, sp

                    mov   si, 80h
                    mov   cl, byte ptr ds:[si]

                    jcxz  end_loop

                    dec   cl
                    xor   ch, ch
                    sub   cx, 02h

                    pop   bp
                    ret

get_txt_length      endp

;-----------------------------------------------------------
;
;
;
;
;
;-----------------------------------------------------------

calc_txt_address    proc
                    push  bp
                    mov   bp, sp

                    mov   ax, STRING
                    mul   bl
                    add   ax, dx
                    shl   ax, 1
                    mov   di, ax

                    pop   bp
                    ret

calc_txt_address    endp

;-----------------------------------------------------------
;
;
;
;
;
;-----------------------------------------------------------

draw_frame          proc
                    push  bp
                    mov   bp, sp

                    mov   bx, (STRING + 2)                  ;starting address of the frame
                    shl   bx, 1
                    sub   di, bx

                    mov   ah, FRAME_COL1

                    mov   al, byte ptr ds:[dx]                       ;left top corner
                    stosw

                    call  get_txt_length
                    add   cx, 02h

                    mov   al, byte ptr ds:[dx + 1]                   ;top side
                top_frame_loop:
                    stosw
                    loop  top_frame_loop

                    mov   al, byte ptr ds:[dx + 2]                   ;right top corner
                    stosw

                    mov   bx, (STRING - 1)
                    shl   bx, 1
                    add   di, bx

                    mov   al, byte ptr ds:[dx + 3]                   ;right side
                    stosw

                    add   di, bx

                    std                                     ;df = 1 -> -= 2

                    mov   al, byte ptr ds:[dx + 4]                   ;right bottom corner
                    stosw

                    call  get_txt_length
                    add   cx, 02h

                    mov   al, byte ptr ds:[dx + 1]                   ;bottom side
                bottom_frame_loop:
                    stosw
                    loop  bottom_frame_loop

                    mov   al, byte ptr ds:[dx + 5]                   ;left bottom corner
                    stosw

                    mov   bx, (STRING - 1)
                    shl   bx, 1
                    sub   di, bx

                    mov   al, byte ptr ds:[dx + 3]                   ;left side
                    stosw

                    pop   bp  
                    ret

draw_frame          endp

end Main
