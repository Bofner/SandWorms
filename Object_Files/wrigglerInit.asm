;==============================================================
;                                                              |
;               Wriggler Initialization                        |
;                                                              |
;==============================================================


;==============================================================
; Memory (Structures, Variables & Constants) 
;==============================================================

;---------------
;Constants   
;---------------
.define maxWrigglers        40

;Wriggler States
.define LEFT                $01  
.define RIGHT               $02
.define UP                  $03
.define DOWN                $04   
.define DEAD                $00  

;Wriggler Body Parts
.define YOKOHEAD            $F9
.define YOKOBODY            $FA
.define YOKOTAIL            $FB
.define TATEHEAD            $FC
.define TATEBODY            $FD
.define BODYCORNER          $FF
.define TATETAIL            $FE
.define SAND                $F8

;Tile Types
.define DONTSTEPLEFT        $80
.define DONTSTEPRIGHT       $82
.define STEPABLELEFT        $00
.define STEPABLERIGHT       $02
.define DONTSTEPUP          $80
.define DONTSTEPDOWN        $84
.define STEPABLEUP          $00
.define STEPABLEDOWN        $02
;Just for turning points
.define DONTSTEPLU          $80
.define DONTSTEPLD          $84
.define DONTSTEPRU          $82
.define DONTSTEPRD          $86

;Dummy byte used to skip the rest of the body if we don't need it
.define DUMMY               $D0
;Defines for Same or different
.define DIFFERENT           $50
.define SAME                $10
;Number of byte to get from body1 to tail
.define BODYTOTAIL          28
.define SANDTOLENGTH        -44
.define SANDCCTOPREVSTATE   -47

;--------------------------
;Structures and Variables
;--------------------------
.enum WRIGGLERDATA export

    wriggler instanceof wrigglerStruct maxWrigglers STARTFROM 0

;Used to hold wriggler tile location as it shifts down the worm
    wrigTileHold            dw
;Used to check if the head moved to a new location
    wrigTileChange          db
;Used to hold wriggler body cc as it shifts down the worm
    wrigBodyCCHold          dw
;Used to write the body turning tile in th correct orientation
    bodyTurnOrient          db
;Do we need to re-write the prevState
    prevStateRewrite        db
;Used to check how we should draw the tail
    body0Tile               db
    allBodyPartsSame        db

;Used as a counter four our buffer updater since we don't want to tie-up B
    updateWrigBufCounter    db

;Copies of parts of the wrig structure that need to be used more than once
    currentWrigState        db
    currentWrigPrevState    db
    currentWrigX            db
    currentWrigY            db
    currentWrigLength       db
    currentHeadTile         dw

;Keep track of how many wrigglers we have checked
    checkedWrigglers        db

;Keep hold of a 16-bit number (Used in Tile calculation)
    hold16Bit               db

.ende


;==================================================================================================
;==================================================================================================
;==================================================================================================


;====================================================
; Fill the buffers with basic info
;====================================================
;Parameters: None
;Affects: A, B, HL, DE, IX
;Initializes wriggler buffers, to be done at the beginning of each level
InitializeWrigs:
;IX will hold our level data
    ld ix, (nextLevelFile)
    ld a, (ix + 0)
;Counter for spawning wrigglers
    ld (updateWrigBufCounter), a
InitWrigLoop:
;This way we can write the correct data without worrying about how large the wrig buffer is
    ld a, (existedWrigs)
    ld de, _sizeof_wriggler.0
    call Mult8Bit
    ld de, wriggler.0
    add hl, de                      ;Find the address of the next available Wriggler
;Start writing the Wriggler's data
    ;ld hl, wriggler.state
    ld a, (ix + 1)
    ld (hl), a                          ;ld hl, wriggler.state
    ld (currentWrigState), a
    inc hl                              ;ld hl, wriggler.prevState
    ld (hl), a                          ;Just make prevState the same as state for initialiation
    inc hl                              ;ld hl, wriggler.xPos
    ld a, (ix + 2)                      ;ld a, (level.wrig.xPos)
    ld (hl), a
    ld (currentWrigX), a
    inc hl                              ;ld hl, wriggler.yPos
    ld a, (ix + 3)                      ;ld a, (level.wrig.yPos)
    ld (hl), a
    ld (currentWrigY), a
    inc hl                              ;ld hl, wriggler.length
    ld a, (ix + 4)                      ;ld a, (level.wrig.length)
    ld (currentWrigLength), a
    ld (hl), a
;Set up the head's initial tile position
    push bc
        call WrigglerTileCalculation
    pop bc
    inc hl                              ;ld hl, wriggler.headLOW
;What we want: ld (hl), de
    ld (hl), d
    ld a, d
    ld (wrigTileHold + 1), a
    inc hl                              ;ld hl, wriggler.headHIGH
    ld (hl), e
    ld a, e
    ld (wrigTileHold), a
;Now we have to set up the body parts so they doesn't start with garbage that get passed down
    inc hl                              ;ld hl, wriggler.headccLOW
    inc hl                              ;ld hl, wriggler.headccHIGH
    inc hl                              ;ld hl, wriggler.body0LOW
    ld a, (wrigTileHold + 1)
    ld (hl), a
    inc hl                              ;ld hl, wriggler.body0HIGH
    ld a, (wrigTileHold)
    ld (hl), a
    inc hl                              ;ld hl, wriggler.body0ccLOW
    ld a, (currentWrigState)
    cp UP
    jp nc, InitBody0TATE                      ;If UP or DOWN, go to TATE
    ;ELSE, go to YOKO

InitBody0YOKO:
    ld (hl), YOKOBODY
    ld a, (hl)
    ld (wrigBodyCCHold + 1), a
    inc hl                              ;ld hl, wriggler.body0ccHIGH
    ld (hl), DONTSTEPLEFT
    ld a, (hl)
    ld (wrigBodyCCHold), a
    jr SetBodyToHeadLocation

InitBody0TATE:
    ld (hl), TATEBODY
    ld (wrigBodyCCHold + 1), a
    inc hl                              ;ld hl, wriggler.body0ccHIGH
    ld (hl), DONTSTEPUP
    ld a, (hl)
    ld (wrigBodyCCHold), a

SetBodyToHeadLocation:
    ld a, 10                            ;Wriggler max length
    sub 1                                ;No head, no body 1 (Tail and Sand will use this too)
    ld b, a
-:
    inc hl                              ;ld hl, wriggler.bodyXLOW
    ld a, (wrigTileHold + 1)
    ld (hl), a
    inc hl                              ;ld hl, wriggler.bodyXHIGH
    ld a, (wrigTileHold)
    ld (hl), a
    inc hl                              ;ld h, wriggler.bodyXccLOW
    ld a, (wrigBodyCCHold + 1)
    ld (hl), a
    inc hl                              ;ld h, wriggler.bodyXccHIGH
    ld a, (wrigBodyCCHold)
    ld (hl), a

    djnz -


;Here HL is length, so we want t get to the LAST body part to insert the DUMMY piece
    ld de, SANDTOLENGTH
    add hl, de                          ;Take us back to body0cc
    ld a, (currentWrigLength)
    add a, a                            ;double length
    add a, a                            ;quadruple length
    sub 2                               ;subtract 4 (for the HIGH byte)
    ld d, $00
    ld e, a                             ;DE holds the offset to the firts empty body part
    add hl, de                          ;ld hl, wriggler.bodyDUMMYHIGH
    ld (hl), DUMMY


;Set up next Wriggler in the level file
    ld de, $04
    add ix, de

;Update activeWrigs
    ld hl, activeWrigs
    inc (hl)
;Update existedWrigs
    inc hl
    inc (hl)

;Loop
    ld a, (updateWrigBufCounter)
    dec a
    ld (updateWrigBufCounter), a
    cp $00
    jp nz, InitWrigLoop
;Set up the next level for later loading if the curret level is beaten
    ld a, (ix + 1)
    ld (nextLevelFile), a
    ld a, (ix + 2)
    ld (nextLevelFile + 2), a
;^^^^^^ NOTE ths isnt little endian because of the way the number is stored in the level file

;Just to make sure the level loaded properly
    ;ld ix, (nextLevelFile)


    ret


;==================================================================================================
;==================================================================================================
;==================================================================================================