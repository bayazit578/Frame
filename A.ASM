.model tiny

.data

FRAME_SYMB1 db 0dah, 0c4h, 0bfh, 0b3h, 0d9h, 0c4h, 0c0h, 0b3h
FRAME_SYMB2 db 0c9h, 0cdh, 0bbh, 0bah, 0bch, 0cdh, 0c8h, 0bah

.code
org 100h

COLUMN      equ 19h
LINE        equ 50h
VRAMSEG     equ 0b800h
TXT_COL     equ 00000100b
FRAME_COL1  equ 00000100b
FRAME_COL2  equ 00000010b
FRAME_COL3  equ 00000001b
CMD_STR     equ 80h

locals @@

Main:               mov   ax, VRAMSEG
                    mov   es, ax
                    mov   bx, COLUMN                        ; half column -> bx
                    shr   bx, 1

                    mov   dx, LINE                          ; svertka
                    shr   dx, 1

                    call  get_txt_length
                    mov   si, cx
                    shr   cx, 1
                    sub   dx, cx

                    call  calc_txt_address                  ; address text in vram -> di

                    mov   cx, si

                    mov   si, 82h                           ; get type of frame
                    xor   ax, ax                            ; no magic 80s
                    lodsb
                    sub   ax, '0'

                    push  di

                    cmp   ax, 01h                           ; check if zero mode in cmd and sets address 
                                                            ; of start of the text in data seg
                    mov   ah, TXT_COL
                    mov   dx, cx

                    mov   si, 8dh
                    jb    text_loop
                    
                    mov   si, 84h

                text_loop:                                  ; text drawing
                    lodsb
                    stosw
                    loop  text_loop
                    mov   cx, dx

                    pop   di

                    mov   si, offset FRAME_SYMB1
                    je    draw

                    ; xor   si, si
                    mov   si, offset FRAME_SYMB2
                    jnbe  draw

                    xor   si, si
                    mov   si, 84h

                draw:
                    call  draw_frame

                terminate:                                  ; if cx == 0
                    mov   ax, 4c00h
                    int   21h

;-----------------------------------------------------------
;Descr: get_txt_length gets a length of cmd string without
;       parameters of the frame. In case of zero mode in 
;       cmd decreases length by 9
;Entry:
;Assum: there is end_loop label for the long jump where the 
;       program terminates
;Exit:  CX - length of cmd string
;Destr: SI, AX
;-----------------------------------------------------------

get_txt_length      proc
                    mov   si, 80h
                    mov   cl, byte ptr ds:[si]

                    jcxz  terminate

                    dec   cl
                    xor   ch, ch
                    sub   cx, 02h                           ; because first two characters are the mode of the frame

                    mov   si, 82h                           ; get type of frame
                    xor   ax, ax
                    lodsb
                    sub   ax, '0'

                    cmp   ax, 00h
                    jne    @@end

                    sub   cx, 09h

                @@end:
                    ret
get_txt_length      endp

;-----------------------------------------------------------
;Descr: calc_txt_address calculates address of start of the 
;       text at vram
;Entry: BX    -  x in vram
;       DX    -  y in vram
;Assum: 
;Exit:  ES:DI -> start of the text in vram   
;Destr: AX
;-----------------------------------------------------------

calc_txt_address    proc
                    mov   ax, LINE
                    mul   bl
                    add   ax, dx
                    shl   ax, 1
                    mov   di, ax

                    ret
calc_txt_address    endp

;-----------------------------------------------------------
;Descr: draw_frame draws the frame with symbols from string 
;       in SI
;Entry: CX    -  length of text in frame
;       DS:SI -> string with frame parameters
;       ES:DI -> end of text in frame in vram
;Assum: ES should points to vram segment
;Exit: 
;Destr: AX, CX, DI
;-----------------------------------------------------------

draw_frame          proc
                    push  bp
                    mov   bp, sp

                    add   cx, 02h                           ; i want the frame to look like this

                    cld
                                         
                    sub   di, (LINE + 2) * 2                ; starting address of the frame

                    mov   ah, FRAME_COL1

                    lodsb                                   ; left top corner
                    stosw


                    mov   bx, cx

                    lodsb                                   ; top side
                    rep   stosw

                    mov   cx, bx

                    lodsb                                   ; right top corner
                    stosw

                    add   di, (LINE - 1) * 2

                    lodsb                                   ; right side
                    stosw

                    add   di, (LINE - 1) * 2

                    lodsb                                   ; right bottom corner
                    std
                    stosw

                    cld
                    lodsb                                   ; bottom side
                    std
                    rep stosw

                    cld
                    lodsb                                   ; left bottom corner
                    std
                    stosw

                    sub   di, (LINE - 1) * 2

                    cld
                    lodsb                                   ; left side
                    std
                    stosw

                    pop   bp
                    ret
draw_frame          endp

end Main
