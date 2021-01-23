        extern  _screenTab
        public  _scroll
        public  _scrollInit
        public  _scrollReset
        section code_user

        defc    X=0x08                  ; Start column of message
        defc    Y=0x01                  ; Start character row of message
        defc    WIDTH=0x10              ; Width, in columns, of message area
        defc    MESSAGE_ATTR=PAPER_BLACK|INK_WHITE|BRIGHT
                                        ; Attribute for the message
        include "defs.asm"

        ;
        ; Inputs:
        ; 			hl - Pointer to message or 0 to use default message.
        ;
_scrollInit:
        push    af
        push    bc
        push    de
        push    hl

        ;
        ; Initialize the message pointer
        ;
        ld      a, l                    ; If the user passed in a pointer to a message
        or      h                       ; in hl we should use it. If hl is 0 use the
        jr      nz, customMessage       ; default message.
        ld      hl, defaultMessage      ; Use the default message
customMessage:
        ld      (messageStart), hl

        ;
        ; Initialize the screen address to top right corner
        ;
        ld      de, _screenTab
        ld      hl, Y                   ; Get Y offset
        hlx     16                      ; x16
        add     hl, de                  ; Index into the screen table
        ld      e, (hl)                 ; Get the screen address from the table
        inc     hl                      ; into de
        ld      d, (hl)

        ld      hl, X+WIDTH-1           ; Add the X offset and WIDTH to get
        add     hl, de                  ; the right hand side of the message
        ld      (screenAddr), hl        ; Save this screen address for use by the scroll routine

        ;
        ; Clear the message area on the screen
        ;
        xor     a                       ; Zero accumulator
        ld      c, 8                    ; Height of character
clearRow:
        ld      de, hl                  ; Store the screen address

        ld      b, WIDTH                ; Width of scrolling window
clearCol:
        ld      (hl), a                 ; Store 0 to the screen
        dec     hl                      ; Next character to the left
        djnz    clearCol                ; Loop for the width of the message

        ld      hl, de                  ; Restore screen address
        inc     h                       ; Increment to next row
        dec     c
        jr      nz, clearRow

        call    _scrollReset

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret     

_scrollReset:
        push    af
        push    bc
        push    de
        push    hl

        ;
        ; Reset the message pointer
        ;
        ld      hl, (messageStart)
        ld      (messagePointer), hl

        ;
        ; Initialize the rotate counter
        ; It will be updated by the scroll routine
        ;
        ld      a, 0x80
        ld      (rotate), a

        ;
        ; Set the screen attributes for the message
        ;
        ld      de, SCREEN_ATTR_START   ; Get the start of the screen attributes
        ld      hl, Y                   ; Get the Y position and multiply by 32
        hlx     32
        add     hl, de                  ; Add it to the attr start address
        ld      a, X
        add     l
        ld      l, a
        ld      de, hl
        inc     de

        ld      (hl), MESSAGE_ATTR
        ld      bc, WIDTH-1
        ldir    

        pop     hl
        pop     de
        pop     bc
        pop     af
        ret     

_scroll:
        ; Check if we need to get the next character of the message
        ld      hl, rotate
        rlc     (hl)
        jp      c, getNextChar

shift:
        ld      hl, (screenAddr)        ; Screen address of right hand side of message calculated by scrollInit
        ld      de, charBuffer

        ld      c, 8                    ; Height of character
rowLoop:
        ld      a, (de)                 ; Get buffer data
        rla                             ; Rotate it left through the carry flag
        ld      (de), a                 ; Store buffer data
        inc     de                      ; Next buffer address
        ; The carry flag contains the data we will shift
        ; into the next character on the screen

        ld      a, l                    ; save l which includes the screen X starting offset
        ld      b, WIDTH/8              ; Width of scrolling window
colLoop:
        rl      (hl)                    ; Rotate left the contents of hl through the carry flag
        dec     l                       ; Next character to the left

        rl      (hl)                    ; Rotate left the contents of hl through the carry flag
        dec     l                       ; Next character to the left

        rl      (hl)                    ; Rotate left the contents of hl through the carry flag
        dec     l                       ; Next character to the left

        rl      (hl)                    ; Rotate left the contents of hl through the carry flag
        dec     l                       ; Next character to the left

        rl      (hl)                    ; Rotate left the contents of hl through the carry flag
        dec     l                       ; Next character to the left

        rl      (hl)                    ; Rotate left the contents of hl through the carry flag
        dec     l                       ; Next character to the left

        rl      (hl)                    ; Rotate left the contents of hl through the carry flag
        dec     l                       ; Next character to the left

        rl      (hl)                    ; Rotate left the contents of hl through the carry flag
        dec     l                       ; Next character to the left
        djnz    colLoop                 ; Loop for the width of the message

        ld      l, a                    ; Restore low order byte of screen address
        inc     h                       ; +0x100 To increment to next row
        dec     c
        jp      nz, rowLoop

        ret     

getNextChar:
        ; Need to get the next character from the message
        ld      hl, (messagePointer)    ; Get the message pointer
        ld      a, (hl)                 ; Read the character
        and     a                       ; Check if the end of the message has been reached
        jp      z, resetMessagePointer  ; Reset pointer if we reach the end of the message
        inc     hl                      ; Otherwise increment the message pointer
        ld      (messagePointer), hl    ; and save it

        sub     0x20                    ; Font starts at ASCII 32

        ;
        ; Copy 8 bytes of font data corresponding to the
        ; character from the ROM font to our character buffer.
        ; This allows us to rotate and save the character
        ; without corrupting the actual font.
        ;
        ld      l, a                    ; Get the font character index
        ld      h, 0                    ; and multiply it by 8
        hlx     8
        ld      de, FONT                ; Pointer to the font
        add     hl, de                  ; hl points to the font data address
        ld      de, charBuffer          ; Point to our character buffer address
        ldi     
        ldi     
        ldi     
        ldi     
        ldi     
        ldi     
        ldi     
        ldi     
        jp      shift

resetMessagePointer:
        ld      hl, (messageStart)
        ld      (messagePointer), hl
        jp      getNextChar             ; Loop to get a character

        section rodata_user

        db      "Escape the castle...                ", 0x00
message1:
        db      "Hurry...                            ", 0x00
message2:
        db      "Collect the coins for points...                ", 0x00
message3:
defaultMessage:
        db      "Purple eggs give you wiiings...                ", 0x00

        section bss_user
messagePointer:
        dw      0                       ; Pointer to the current location in the message
messageStart:
        dw      0                       ; Pointer to the start of the message
screenAddr:
        dw      0                       ; Pointer to the top right-hand location on the screen
charBuffer:
        ds      8                       ; Buffer to store font data while we are rotating it
rotate:
        db      0                       ; Counter so we know when to get the next character from the message
