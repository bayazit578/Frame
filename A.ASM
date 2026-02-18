.model tiny

.data

FRAME_SYMB  db 's', 's', 's', 's', 's', 's', 's', 's'
FRAME_SYMB1 db 0dah, 0c4h, 0bfh, 0b3h, 0d9h, 0c4h, 0c0h, 0b3h
FRAME_SYMB2 db 0c9h, 0cdh, 0bbh, 0bah, 0bch, 0cdh, 0c8h, 0bah

.code
org 100h

COLUMN      equ 19h
LINE      equ 50h
VRAMSEG     equ 0b800h
TXT_COL     equ 00000100b
FRAME_COL1  equ 00000100b
FRAME_COL2  equ 00000010b
FRAME_COL3  equ 00000001b

Main:               mov   ax, VRAMSEG
                    mov   es, ax
                    mov   bx, COLUMN                        ;half column -> bx
                    shr   bx, 1

                    mov   dx, LINE
                    shr   dx, 1

                    call  get_txt_length
                    shr   cx, 1
                    sub   dx, cx

                    call  calc_txt_address                  ;address arithmetics -> di

                    call  get_txt_length                    ;length -> cx

                    mov   si, 84h                           ;text drawing
                    mov   ah, TXT_COL

                    push  di

                    ; sub   di, 02h
                    ; mov   ax, 00h
                    ; stosw

                text_loop:
                    lodsb
                    stosw
                    loop  text_loop

                    pop   di

                    mov   si, 82h                           ; get type of frame
                    xor   ax, ax
                    lodsb

                    cmp   ax, 01h


                    mov   si, offset FRAME_SYMB2
                    mov   si, offset FRAME_SYMB1
                    mov   si, 84h

                    call  get_txt_lenght
                    mov   bx, cx
                    call  draw_frame

                end_loop:                                   ; if cx == 0
                    mov   ax, 4c00h
                    int   21h

;-----------------------------------------------------------
;Descr: get_txt_length gets a length of cmd string without
;       parameters of the frame
;Entry:
;Assum: there is end_loop label for the long jump where the 
;       program terminates
;Exit:  CX - length of cmd string
;Destr: SI
;-----------------------------------------------------------

get_txt_length      proc
                    push  bp
                    mov   bp, sp

                    mov   si, 80h
                    mov   cl, byte ptr ds:[si]

                    jcxz  end_loop

                    dec   cl
                    xor   ch, ch
                    sub   cx, 02h                           ; because first two characters are the mode of the frame 

                    pop   bp
                    ret
get_txt_length      endp

;-----------------------------------------------------------
;Descr: calc_txt_address calculates address of start of the 
;       taxt at vram
;Entry: BX    -  length of half display column
;       DX    -  length of half display line
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
;Entry: BX    -  length of text in frame
;       DS:SI -> string with frame parameters
;       ES:DI -> end of text in frame in vram
;Assum: ES should points to vram segment
;Exit: 
;Destr: AX, CX, SI, DI
;-----------------------------------------------------------

draw_frame          proc
                    push  bp
                    mov   bp, sp

                    cld
                                         
                    sub   di, (LINE + 2) * 2                ; starting address of the frame

                    mov   ah, FRAME_COL1

                    lodsb                                   ; left top corner
                    stosw

                    push  si
                    call  get_txt_length
                    pop   si
                    add   cx, 02h

                    lodsb                                   ; top side
                top_frame_loop:
                    stosw
                    loop  top_frame_loop

                    lodsb                                   ; right top corner
                    stosw

                    add   di, (LINE - 1) * 2

                    lodsb                                   ; right side
                    stosw

                    add   di, (LINE - 1) * 2

                    lodsb                                   ; right bottom corner
                    std
                    stosw

                    push  si
                    call  get_txt_length
                    pop   si
                    add   cx, 02h

                    cld
                    lodsb                                   ; bottom side
                bottom_frame_loop:
                    std
                    stosw
                    loop  bottom_frame_loop

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
