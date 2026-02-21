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
LIGHT       equ 00001000b
RED         equ 00000100b
GREEN       equ 00000010b
BLUE        equ 00000001b
CMD_STR     equ 80h
STR_END     equ '#'

locals @@

Main:               mov   si, (CMD_STR + 2)                 ; get type of frame
                    xor   ax, ax                            ; no magic 80s
                    lodsb
                    sub   ax, '0'

                    cmp   ax, 01h                           ; check if zero mode in cmd and sets address 
                                                            ; of start of the text in data seg

                    mov   di, (CMD_STR + 2 + 1 + 9)
                    jb    get_string_count
                    mov   di, (CMD_STR + 4)
                    mov   bx, di

                    pushf
                    call  get_txt_length
                    cmp   cx, 00h
                    je    terminate
                    popf

                    mov   di, bx

                get_string_count:
                    push  STR_END
                    push  cx
                    push  di
                    xor   cx, cx
                    xor   si, si

                    call  search_occurences                 ; string count -> cx
                                                            ; longest string -> si

                    add   sp, 06h

                text_drawing:
                    push  cx

                    mov   bx, si
                    call  get_string_length                 ; string length -> dx
                    cmp   dx, 00h
                    je    terminate

                    pop   cx

                    mov   ax, LINE                          ; x in vram -> dx
                    sub   ax, dx
                    shr   ax, 01h
                    mov   dx, ax

                    mov   ax, VRAMSEG
                    mov   es, ax
                    mov   bx, COLUMN                        ; y in vram -> bx 
                    sub   bx, cx
                    shr   bx, 01h
                    
                    call  calc_txt_address                  ; address text in vram -> di

                    ; mov   cx, si

                    mov   ah, TXT_COL
                    mov   dx, cx

                    mov   si, 8dh
                    jb    string_drawing
                    
                    mov   si, 84h

                    push  cx
                    mov   cx, dx

                    string_drawing:
                        lodsb
                        stosw
                        loop string_drawing

                    pop   cx

                    loop  text_drawing

                ;     mov   si, offset FRAME_SYMB1
                ;     je    draw

                ;     mov   si, offset FRAME_SYMB2
                ;     jnbe  draw

                ;     xor   si, si
                ;     mov   si, 84h

                ; draw:
                ;     call  draw_frame

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
                    jne   @@end

                    sub   cx, 09h

                @@end:
                    ret
get_txt_length      endp

;-----------------------------------------------------------
;Descr: calc_txt_address calculates address of start of the 
;       text in vram
;Entry: DX    -  x in vram
;       BX    -  y in vram
;Assum: ES - shoud set in vram segment
;Exit:  ES:DI -> start of the text in vram   
;Destr: AX
;-----------------------------------------------------------

calc_txt_address    proc
                    mov   ax, LINE
                    mul   bl
                    add   ax, dx
                    shl   ax, 01h
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

                    mov   ah, RED

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

;-----------------------------------------------------------
;Descr: search_occurences searches first occurence of char 
;       in string and returns its address
;Entry: DS:[BP + 4]  -> string to search in
;       DS:[BP + 6]  -  length of the string
;       DS:[BP + 8]  -  char to look for
;Assum: DI - should be reset to zero
;       CX - should be reset to zero
;Exit:  SI - current biggest length of string in text
;       CX - current count of strings in text
;Destr: AX, BX, DX, DI, ES
;-----------------------------------------------------------

search_occurences   proc
                    push  bp
                    mov   bp, sp

                    mov   di, ds:[bp + 4]
                    mov   ax, ds
                    mov   es, ax
                    mov   bx, ds:[bp + 6]
                    mov   ax, ds:[bp + 8]

                    push  cx
                    call  get_string_length
                    pop   cx

                    inc   cx                                ; increase a counter in new iteration

                    cmp   dx, si
                    jna   @@continue
                    mov   si, dx

                @@continue:
                    cmp   bx, 00h
                    je    @@end

                    push  ax
                    push  bx
                    push  di

                    call  search_occurences

                    add   sp, 06h

                @@end:
                    pop   bp
                    ret
search_occurences   endp

;-----------------------------------------------------------
;Descr: get_string_length counts the length of first string 
;Entry: DI -> start of a target string
;       AX -  char that means end of the string
;       BX -  maximal length of the string
;Assum: ES - should be setted to data segment
;Exit:  DX -  length of the string till the char in AX or in 
;             case of failure to find it will return the 
;             maximal length
;       BX -  length of the rest of the text
;       DI -> start of the next string or to the symbol 
;             after string ending
;Destr: CX
;-----------------------------------------------------------

get_string_length   proc
                    cld
                    mov   dx, bx
                    mov   cx, bx

                    jcxz  @@end

                    repne scasb
                    sub   dx, cx
                    mov   bx, cx

                @@end:
                    ret
get_string_length   endp

;-----------------------------------------------------------
;Descr: print_string dumps string with the given length to 
;       addres ES:DI 
;Entry: SI -> start of a target string
;       CX -  string length
;Assum: ES - should be setted to vram segment
;Exit:  DX - length of the string till the char in AX or in
;            case of failure to find it will return the
;            maximal length
;       BX - length of the rest of the text
;Destr: CX
;-----------------------------------------------------------

print_string        proc
                text_loop:
                    lodsb
                    stosw
                    loop  text_loop
                    ; mov   cx, dx

                    ret
print_string        endp

end Main
