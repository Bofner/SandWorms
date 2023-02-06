;==============================================================
;                                                              |
;               Wriggler Drawing                               |
;                                                              |
;==============================================================
;====================================================
; Draw Wriggler to the tile map
;====================================================
;Parameters: None
;Affects: A, BC, DE, HL
;Actually drawing the wriggler to the tile map
DrawWrigToTileMap:

    ld de, wriggler.2.sand
;What we want: ld hl, (de)
    ld a, (de)
    ld l, a
    inc de
    ld a, (de)
    ld h, a
    ;HL = VDP Address that we want to write to
    call SetVDPAddress

    ld a, (wriggler.2.sandcc)
    out (VDPData), a
    ld a, (wriggler.2.sandcc + 1)
    out (VDPData), a

    ld de, wriggler.2.tail
;What we want: ld hl, (de)
    ld a, (de)
    ld l, a
    inc de
    ld a, (de)
    ld h, a
    ;HL = VDP Address that we want to write to
    call SetVDPAddress

    ld a, (wriggler.2.tailcc)
    out (VDPData), a
    ld a, (wriggler.2.tailcc + 1)
    out (VDPData), a

    
    ld de, wriggler.2.body0
;What we want: ld hl, (de)
    ld a, (de)
    ld l, a
    inc de
    ld a, (de)
    ld h, a
    ;HL = VDP Address that we want to write to
    call SetVDPAddress

    ld a, (wriggler.2.body0cc)
    out (VDPData), a
    ld a, (wriggler.2.body0cc + 1)
    out (VDPData), a


    ld de, wriggler.2.body1
;What we want: ld hl, (de)
    ld a, (de)
    ld l, a
    inc de
    ld a, (de)
    ld h, a
    ;HL = VDP Address that we want to write to
    call SetVDPAddress

    ld a, (wriggler.2.body1cc)
    out (VDPData), a
    ld a, (wriggler.2.body1cc + 1)
    out (VDPData), a

    ld de, wriggler.2.body2
;What we want: ld hl, (de)
    ld a, (de)
    ld l, a
    inc de
    ld a, (de)
    ld h, a
    ;HL = VDP Address that we want to write to
    call SetVDPAddress

    ld a, (wriggler.2.body2cc)
    out (VDPData), a
    ld a, (wriggler.2.body2cc + 1)
    out (VDPData), a



    ld de, wriggler.2.head
;How to write to the screen
/*
;Set our bit to the map
    ld hl, $38FA                    ;Location just before we want to write to
    call SetVDPAddress
    out (VDPData), a
*/
;^^^^^^^^^^^^^^^^^^^^^^^^^
;What we want: ld hl, (de)
    ld a, (de)
    ld l, a
    inc de
    ld a, (de)
    ld h, a
    ;HL = VDP Address that we want to write to
    call SetVDPAddress

    ld a, (wriggler.2.headcc)
    out (VDPData), a
    ld a, (wriggler.2.headcc + 1)
    out (VDPData), a
    

;How to write to the screen
/*
;Set our bit to the map
    ld hl, $38FA                    ;Location just before we want to write to
    call SetVDPAddress
    out (VDPData), a
*/

    ret