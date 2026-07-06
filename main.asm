	assert $ == 16514

    ; hl = hl * 8
    MACRO MULT_HL_8
      add hl,hl
      add hl,hl
      add hl,hl
    ENDM

    ; hl = a
    MACRO LD_HL_A
      ld   h, 0
      ld   l, a
    ENDM

    ; bc = hl
    MACRO LD_BC_HL
      ld   b, h
      ld   c, l
    ENDM

    ; rotate a right 4 times
    MACRO RRCA_4
      RRCA_2
      RRCA_2
    ENDM

    ; rotate a right twice
    MACRO RRCA_2
      rrca
      rrca
    ENDM

    ; rotate a left twice
    MACRO RLCA_2
      rlca
      rlca
    ENDM

    ; hl = hl + a
    MACRO ADD_HL_A
      add  a, l  ; add a to HL
      ld   l, a
      adc  a, h
      sub  l
      ld   h, a  ; end of add
    ENDM

    MACRO ADD_DE_A
      ex   de, hl
      ADD_HL_A
      ex   de, hl
    ENDM

    ; de = de - nn
    MACRO SUB_DE num
      ex   de, hl
      ld   de, num
      or   a
      sbc  hl, de
      ex   de, hl
    ENDM

    MACRO SG2B arg1, arg2
      ld  a, (hl)    ; set graphics 2 bits
      and arg1
      RRCA_2
      ld   c, a
      inc  hl
      ld   a, (hl)
      and  arg1
      or   c
      arg2
      push hl
        ld   hl, charmap

        ADD_HL_A
        ld   a, (hl)
      pop  hl
      ld   (de), a
      inc  de
      dec  hl
    ENDM


main:

;------------------------------------------------------------
; Start
;------------------------------------------------------------

    ld   hl, msg
    call .dispstring

    ; back to BASIC
    ret

; Subroutines

; display a string
; write directly to the screen
.dispstring:

    LD_BC_HL       ; bc now points to the dispstring

    ld   de, (D_FILE)  ; de points to the display file
    inc  de
    ld   a, 08

.loop:
    cp   $00
    jp   nz, .skip
    ld   a, 33*4 - 4*8
    ADD_DE_A
    ld   a, 08

.skip:
    push af

    ld   a, (bc)      ; a now has the ascii character to display
  
    cp   $00
    jp   z, .loopEnd
    call asc2zx81     ; after this, a is now a zx81 character

    ; multiply the character by 8 and add it to char_addr
    LD_HL_A

    MULT_HL_8

    push bc

    ld   bc, $1e00
    
    add  hl, bc       ; hl now points to the start of the char in the rom


    ld   b, 4         ; each character is 4 rows of 2

.loop1:
    SG2B $C0, RRCA_4
    SG2B $30, RRCA_2
    SG2B $0C, nop
    SG2B $03, RLCA_2

    inc  hl
    inc  hl

    ld   a, 33 - 4     ; the next line is 33 - 4 bytes away
    ADD_DE_A

    dec  b
    jp   nz, .loop1

    pop  bc
    inc  bc           ; bc again points to the next char to display

    SUB_DE $0080

    pop  af
    dec  a

    jp   .loop

.loopEnd:
    pop  af
    ret

char_addr: defw $1E00

msg:
    defb " FRIDAY "
    defb "        "
    defb "  9:52  "
    defb "        "
    defb " 29 MAR "
    defb "        ", $00

;         01234567890123456789012345678901

charmap:
    defb $00, $02, $01, $03, $87, $85, $86, $84, $04, $06, $05, $07, $83, $81, $82, $80

testChar:  
    defb $80, $40, $20, $10, $08, $04, $02, $01    

; trashed hl
asc2zx81:
    sub  32
    cp   91
    jr   nc, isTooHigh
    ld   hl, zxmap
    add  a, l                    ; add a to hl - a bit convoluted
    ld   l, a
    adc  a, h
    sub  l
    ld   h, a
    ld   a, (hl)
    ret

isTooHigh:
    ld   a, 0
    ret

zxmap:
    defb $00, $0C, $0B, $00, $0D, $00, $00, $00
    defb $10, $11, $17, $15, $1A, $16, $1B, $18
    defb $1C, $1D, $1E, $1F, $20, $21, $22, $23
    defb $24, $25, $0E, $19, $13, $14, $12, $0F
    defb $00, $26, $27, $28, $29, $2A, $2B, $2C
    defb $2D, $2E, $2F, $30, $31, $32, $33, $34
    defb $35, $36, $37, $38, $39, $3A, $3B, $3C
    defb $3D, $3E, $3F, $00, $00, $00, $00, $00
    defb $00, $A6, $A7, $A8, $A9, $AA, $AB, $AC
    defb $AD, $AE, $AF, $B0, $B1, $B2, $B3, $B4
    defb $B5, $B6, $B7, $B8, $B9, $BA, $BB, $BC
    defb $BD, $BE, $BF
EOF