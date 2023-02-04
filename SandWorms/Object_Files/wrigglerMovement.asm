;==============================================================
;                                                              |
;               Wriggler Movement Hadler                       |
;                                                              |
;==============================================================

;====================================================
; Find out which Wrigglers we need to update
;====================================================
;Parameters: None
;Affects: A, BC, DE, HL
;Updates the wrig buffer to prepare for drawing to the screen
UpdateWrigBuffers:
;So far we haven't checked any wriggler
    ld hl, checkedWrigglers
    ld (hl), $00
;Set our counter to be the number of active wrigglers
    ld a, (activeWrigs)
    ld (updateWrigBufCounter), a

CheckWrigglers:
;This way we can write the correct data without worrying about how large the wrig buffer is
    ld hl, wriggler.0                               ;Get to the first wriggler
    ld de, -_sizeof_wriggler.0                      ;Creating an offset to compensate for the way DJNZ works
    add hl, de                                      ;HL is now one wriggler length away from wriggler.0
    ld a, (checkedWrigglers)
    ld b, a                                         ;Want to get to the next available wriggler
    inc b                                           ;If it's 0, it'll add it $FF times
    ld de, _sizeof_wriggler.0
-:
    add hl, de
    djnz -
    ;^^^^^^^^^^^^^^^^^^^^^
    ;ld hl, wriggler.timer
;Check if the current Wriggler is dead or not
    ld a, (hl)
    cp DEAD
    jp z, SkipDeadWriggler

;If it's not DEAD, then let's update it!
;Start by saving its state
SaveCurrentState:
    ld a, (hl)
    ld (currentWrigState), a
SavePrevState:
    inc hl                                      ;ld h, wriggler.prevState
    ld a, (hl)
    ;ld (hl), a                                  ;Nothing has happened to current state yet, so it is actually prev state
    ld (currentWrigPrevState), a
    ld a, DUMMY
    ld (prevStateRewrite), a
;Updating a variable for writing the tail
    ld a, SAME
    ld (allBodyPartsSame), a
WrigPositionUpdate:
;Then update its position based on its state
    inc hl                                      ;ld hl, wriggler.xPos
    ld a, (currentWrigState)
    cp LEFT                                     ;A is still (currentWrigState)
    jp z, WrigLeftUpdate
    cp RIGHT                                    ;A is still (currentWrigState)
    jp z, WrigRightUpdate
    cp UP                                       ;A is still (currentWrigState)
    jp z, WrigUpUpdate
    cp DOWN                                     ;A is still (currentWrigState)
    jp z, WrigDownUpdate

CalculateNewTilePosition:
;Calculation done elsewhere (HelperFunctions)
    call WrigglerTileCalculation
;Save head tile map location to buffer and to wrigTileHold and currentHeadTile
    ld (currentHeadTile), de
    ;Create a counter for the body
    inc hl                                      ;ld hl, wriggler.length
    ld a, (hl)
    sub 3                                       ;Remove head and tail and body 1
    ld (currentWrigLength), a
    inc hl                                      ;ld hl, wriggler.headLOW
    ld a, (hl)
    ld (wrigTileHold + 1), a                    ;Also save old location
    ;What we want: ld (hl), de
    ld (hl), e
    inc hl                                      ;ld hl, wriggler.headHIGH
    ld a, (hl)
    ld (wrigTileHold), a                        ;Also save old location
    ld (hl), d
    ld a, e
    ld (wrigTileChange), a

CheckCollision:
    ld a, (currentWrigState)
    cp LEFT
    jp z, LeftTileCheck
    cp RIGHT
    jp z, RightTileCheck
    cp UP
    jp z, UpTileCheck
    cp DOWN
    jp z, DownTileCheck

UpdateWrigglerHeadCC:
    inc hl                                      ;ld de, wriggler.headccLOW
    ld a, (currentWrigPrevState)
    cp LEFT
    jp z, WrigglerHeadLeft
    cp RIGHT
    jp z, WrigglerHeadRight
    cp UP
    jp z, WrigglerHeadUp
    cp DOWN
    jp z, WrigglerHeadDown

UpdateWrigglerBody0:
;Check if we need to update the body or not
    ld a, (wrigTileHold + 1)
    ld b, a
    ld a, (wrigTileChange)
    cp b
    jp z, SuccessfullyChecked

    inc hl                                      ;ld hl, wriggler.body0
;Save current Tile Location and replace it with Head's location
    ld de, (wrigTileHold)                       ;Save HEAD previous location
    ld a, (hl)
    ld (wrigTileHold + 1), a                    ;Save LOW byte
    ld (hl), d                                  ;Update position
    inc hl                                      ;ld hl, wriggler.body0HIGH
    ld a, (hl)
    ld (wrigTileHold), a                        ;Save HIGH byte
    ld (hl), e                                  ;Update position
;Check if current and previous state are the same
    ld a, (currentWrigPrevState)
    ld c, a                                     ;ld c, currentWrigPrevState
    ld a, (currentWrigState)
    cp c                                        ;Compare prevState and currentState
    jp nz, CalculateBodyTurn
UpdateWrigBody0CC:
    ld a, (currentWrigState)
    cp UP
    jp nc, UpdateBody0TATE                      ;If UP or DOWN, go to TATE
    ;ELSE, go to YOKO

UpdateBody0YOKO:
    inc hl                              ;ld hl, wriggler.body0ccLOW
    ld a, (hl)
    ld (wrigBodyCCHold + 1), a          ;Save OLD LOWCC tile first
    ld (body0Tile), a
    ld (hl), YOKOBODY
    inc hl                              ;ld hl, wriggler.body0ccHIGH
    ld a, (hl)
    ld (wrigBodyCCHold), a          ;Save OLD HIGHC tile first
    ld a, (currentWrigState)
    cp RIGHT
    jp z, BodyRight
    ld (hl), DONTSTEPLEFT
    jp WrigBodyLoop
BodyRight:
    ld (hl), DONTSTEPRIGHT
    jp WrigBodyLoop

UpdateBody0TATE:
    inc hl                              ;ld hl, wriggler.body0ccLOW
    ld a, (hl)
    ld (wrigBodyCCHold + 1), a          ;Save OLD LOWCC tile first
    ld (body0Tile), a
    ld (hl), TATEBODY
    inc hl                              ;ld hl, wriggler.body0ccHIGH
    ld a, (hl)
    ld (wrigBodyCCHold), a              ;Save OLD HIGHC tile first
    ld a, (currentWrigState)
    cp DOWN
    jp z, BodyDown
    ld (hl), DONTSTEPUP
    jp WrigBodyLoop
BodyDown:
    ld (hl), DONTSTEPDOWN
    ;jp WrigBodyLoop


WrigBodyLoop:
;This is whe rest of the body gets made, essentially jut replacing the tiles and CC with the one before it
    ld c, BODYTOTAIL                    ;C holds the number of bytes to get to wriggler.tail from body1
    ld b, 7                             ;Number of remaining potential body parts
;Everytime we INC HL, we must also DEC C
-:
    inc hl                              ;ld hl, wriggler.bodyXLOW
    dec c
    inc hl                              ;ld hl, wriggler.bodyXHIGH
    dec c
    ld a, (hl)
    cp DUMMY
    jp z, SkipToWrigglerTail
    dec hl                              ;ld hl, wriggler.bodyXLOW
    inc c
;Save current Tile Location and replace it with previous segment's location
    ld de, (wrigTileHold)
    ld a, (hl)
    ld (wrigTileHold + 1), a                        ;Save LOW byte
    ld (hl), d                                  ;write new byte
    inc hl                                      ;ld hl, wriggler.bodyXHIGH
    dec c
    ld a, (hl)
    ld (wrigTileHold), a
    ld (hl), e                                  ;write new byte
;Donate previous segment's previous CC
    inc hl                                      ;ld hl, wriggler.bodyXccLOW
    dec c
    ld de, (wrigBodyCCHold)
    ld a, (hl)
    ld (wrigBodyCCHold + 1), a                  ;Save LOW byte
    ld (hl), d                                  ;Write new byte

;Check if all the body parts are the same (for writing the tail)
    ld a, (body0Tile)
    cp d
    jr z, +                                     ;If they aren't the same, write it!
    ld a, DIFFERENT
    ld (allBodyPartsSame), a
+:
    inc hl                                      ;ld hl, wriggler.bodyXccHIGH
    dec c
    ld a, (hl)
    ld (wrigBodyCCHold), a
    ld (hl), e                                  ;Write new byte

    djnz -

;Don't need to do the skip stuff if we made it all the way through
    jp UpdateWrigglerTail

SkipToWrigglerTail:
;Load DE with the umber of BYTES to get to wriggler.tail
    ld d, $00
    ld e, c
    add hl, de                                  ;ld hl, wriggler.body7ccHIGH

UpdateWrigglerTail:
    inc hl                                      ;ld hl, wriggler.tailLOW
;Update position first
    ld de, (wrigTileHold)
    ld a, (hl)
    ld (wrigTileHold + 1), a                    ;Save LOW byte
    ld (hl), d                                  ;write new byte
    inc hl                                      ;ld hl, wriggler.tailHIGH
    ld a, (hl)
    ld (wrigTileHold), a
    ld (hl), e        
;Next draw the correct tile
    ld a, (allBodyPartsSame)
    cp SAME
    jp z, TailSameAsState
    ld a, (wrigBodyCCHold + 1)                      ;Tail won't change when the currentState changes
    cp YOKOBODY
    jp z, TailYoko
    cp TATEBODY
    jp z, TailTate
    cp BODYCORNER
    jp z, TailContinue

TailSameAsState:
    ld a, (currentWrigState)
    cp LEFT
    jp z, TailLeft
    cp RIGHT
    jp z, TailRight
    cp UP
    jp z,TailUp
    cp DOWN
    jp z, TailDown

UpdateWrigglerSand:
;Update position first
    inc hl                                      ;ld hl, wriggler.sandLOW
    ld de, (wrigTileHold)
    ld (hl), d                                  ;write new byte
    inc hl                                      ;ld hl, wriggler.sandHIGH
    ld (hl), e        
;Next draw the correct tile (Always the same one)
    inc hl                              ;ld hl, wriggler.sandccLOW
    ld (hl), SAND
    inc hl                              ;ld hl, wriggler.sandccHIGH
    ld (hl), STEPABLELEFT

SetPreviousState:
    ld bc, SANDCCTOPREVSTATE
    add hl, bc                          ;ld hl, wriggler.prevState
    ld a, (prevStateRewrite)
    cp DUMMY
    jr z, +                             ;If it has been updated, then change, else, don't
    ld (hl), a
    jp SuccessfullyChecked

+:
    ld a, (currentWrigState)
    ld (hl), a

SuccessfullyChecked:
;We have successfully checked a wriggler
    ld hl, checkedWrigglers
    inc (hl)
    ld a, (updateWrigBufCounter)
    dec a
    ld (updateWrigBufCounter), a
    ld b, a
    ld a, 0
    cp b
    jp nz, CheckWrigglers
    ;djnz CheckWrigglers

    ret


;==================================================================================================
;==================================================================================================
;                                                                                                   |
;                   Special Direction call subroutines / skips                                      |
;                                                                                                   |
;==================================================================================================
;==================================================================================================

;====================================================
; Special skip dead wrigglers
;====================================================
;Skip over dead wriggler and check if the next one is alive
SkipDeadWriggler:
    ld hl, checkedWrigglers
    inc (hl)
    jp CheckWrigglers


;====================================================
; Directional Collision Detection
;====================================================
LeftTileCheck:
/*
    ld a, (currentWrigX)
    and $01
    cp $01
    jr z, +
    ld a, (currentWrigX)
    or $09
    cp $09
    jr z, +
*/
+:
    ld de, (currentHeadTile)                    ;Check the tile immediately to our left
    ex de, hl                                   ;Gotta do math with HL
    ld bc, $0000                                ;Tile to the left is minus $0002
    add hl, bc
    call SetVDPAddress
    in a, (VDPData)                             ;Grab tile data (not sure if I can actually do this)
    ex de, hl                                   ;return HL back to normal
    and %10000000
    cp $80                                      ;Check if our DONTSTEP flag is set
    jp z, ChangeStateUp                         ;If it is, change state,
    jp UpdateWrigglerHeadCC                     ;Else, continue as normal

RightTileCheck:
    ld de, (currentHeadTile)                    ;Check the tile immediately to our Right
    ex de, hl                                   ;Gotta do math with HL
    ld bc, $0004                               ;Tile to the right is plus $0002
    add hl, bc
    call SetVDPAddress
    in a, (VDPData)                             ;Grab tile data (not sure if I can actually do this)
    ex de, hl                                   ;return HL back to normal
    and %10000000
    cp $80                                      ;Check if our DONTSTEP flag is set
    jp z, ChangeStateDown                       ;If it is, change state,
    jp UpdateWrigglerHeadCC

UpTileCheck:
    ld de, (currentHeadTile)                    ;Check the tile immediately above
    ex de, hl                                   ;Gotta do math with HL
    ld bc, -$0038                               ;Tile to the up is minus $0040
    add hl, bc
    call SetVDPAddress
    in a, (VDPData)                             ;Grab tile data (not sure if I can actually do this)
    ex de, hl                                   ;return HL back to normal
    and %10000000
    cp $80                                      ;Check if our DONTSTEP flag is set
    jp z, ChangeStateRight                      ;If it is, change state,
    jp UpdateWrigglerHeadCC
DownTileCheck:
    ld de, (currentHeadTile)                    ;Check the tile immediately below
    ex de, hl                                   ;Gotta do math with HL
    ld bc, $0040                               ;Tile to the down is add $0040
    add hl, bc
    call SetVDPAddress
    in a, (VDPData)                             ;Grab tile data (not sure if I can actually do this)
    ex de, hl                                   ;return HL back to normal
    and %10000000
    cp $80                                      ;Check if our DONTSTEP flag is set
    jp z, ChangeStateLeft                       ;If it is, change state,
    jp UpdateWrigglerHeadCC


;====================================================
; Directional Post-Collision State Change
;====================================================
ChangeStateUp:
    ld bc, -$0006
    add hl, bc                                  ;ld hl, wriggler.state
    ld a, (hl)                                  ;Prepare wriggler.prevState to be updated
    ld (prevStateRewrite), a
    ld (hl), UP                                 ;update current state
    ld a, (hl)
    ;ld (currentWrigState), a                    ;Update temp varable
    ld (hl), a
    ld bc, $0006
    add hl, bc                                  ;ld hl, wriggler.headHIGH
    jp UpdateWrigglerHeadCC

ChangeStateDown:
    ld bc, -$0006
    add hl, bc                                  ;ld hl, wriggler.state
    ld a, (hl)                                  ;Prepare wriggler.prevState to be updated
    ld (prevStateRewrite), a
    ld (hl), DOWN                               ;update current state
    ld a, (hl)
    ;ld (currentWrigState), a                    ;Update temp varable
    ld (hl), a
    ld bc, $0006
    add hl, bc                                  ;ld hl, wriggler.headHIGH
    jp UpdateWrigglerHeadCC

ChangeStateRight:
    ld bc, -$0006
    add hl, bc                                  ;ld hl, wriggler.state
    ld a, (hl)                                  ;Prepare wriggler.prevState to be updated
    ld (prevStateRewrite), a
    ld (hl), RIGHT                               ;update current state
    ld a, (hl)
    ;ld (currentWrigState), a                    ;Update temp varable
    ld bc, $0006
    add hl, bc                                  ;ld hl, wriggler.headHIGH
    jp UpdateWrigglerHeadCC

ChangeStateLeft:
    ld bc, -$0006
    add hl, bc                                  ;ld hl, wriggler.state
    ld a, (hl)                                  ;Prepare wriggler.prevState to be updated
    ld (prevStateRewrite), a
    ld (hl), LEFT                               ;update current state
    ld a, (hl)
    ;ld (currentWrigState), a                    ;Update temp varable
    ld bc, $0006
    add hl, bc                                  ;ld hl, wriggler.headHIGH
    jp UpdateWrigglerHeadCC


;====================================================
; Calculate which turning drawing to use
;==================================================== 
CalculateBodyTurn: 
;Remember LEFT = 01, Right = 02, Up = 03, Down = 4
    ld de, bodyTurnOrient                
    ld a, $80       
    ld (de), a                         ;Set the body to be LEFTUP with COLLISION FLAG  
CheckPrevRight:   
    ld a, (currentWrigPrevState)
    cp RIGHT                            ;If prev state is RIGHT, flip the bit
    call z, SetHBit
CheckPrevUp:
    ld a, (currentWrigPrevState)
    cp UP                               ;If prev state is RIGHT, flip the bit
    call z, SetVBit
CheckStateLeft:
    ld a, (currentWrigState)
    cp LEFT                            ;If prev state is RIGHT, flip the bit
    call z, SetHBit

CheckStateDown:
    ld a, (currentWrigState)
    cp DOWN                               ;If prev state is RIGHT, flip the bit
    call z, SetVBit

UpdateBodyTurnTile:
    inc hl                              ;ld hl, wriggler.body0ccLOW
    ld a, (hl)
    ld (wrigBodyCCHold + 1), a          ;Save OLD LOWCC tile first
    ld (hl), BODYCORNER
    ld a, (hl)
    ld (body0Tile), a
    inc hl                              ;ld hl, wriggler.body0ccHIGH
    ld a, (hl)
    ld (wrigBodyCCHold), a              ;Save OLD HIGHC tile first
    ld a, (de)                          ;Load calculated Body Turn orientation
    ld (hl), a

    jp WrigBodyLoop

;Set the H-Flip bit for our body turn 
SetHBit:
    ld a, (de)
    set 1, a
    ld (de), a

    ret

;Set the V-Flip bit for our body turn 
SetVBit
    ld a, (de)
    set 2, a
    ld (de), a

    ret

;====================================================
; Normal Wriggler Movement
;====================================================
;Update Wriggler buffer one pixel to the left
WrigLeftUpdate:
    ld a, (hl)
    ld (currentWrigX), a            ;Save xPos
    dec (hl)                        ;Move wriggler one pixel left

    inc hl                          ;ld hl, yPos
    ld a, (hl)
    ld (currentWrigY), a            ;Save yPos    

    jp CalculateNewTilePosition

;Update Wriggler buffer one pixel to the right
WrigRightUpdate:
    ld a, (hl)
    ld (currentWrigX), a            ;Save xPos
    inc (hl)                        ;Move wriggler one pixel right
    inc hl                          ;ld hl, yPos
    ld a, (hl)
    ld (currentWrigY), a            ;Save yPos    

    jp CalculateNewTilePosition

;Update Wriggler buffer one pixel to the up
WrigUpUpdate:
    ld a, (hl)
    ld (currentWrigX), a            ;Save xPos
    inc hl                          ;ld hl, yPos
    ld a, (hl)
    ld (currentWrigY), a            ;Save yPos 
    dec (hl)                        ;Move wriggler one pixel up
    
    
       

    jp CalculateNewTilePosition

;Update Wriggler buffer one pixel to the down
WrigDownUpdate:
    ld a, (hl)
    ld (currentWrigX), a            ;Save xPos
    inc hl                          ;ld hl, yPos
    ld a, (hl)
    ld (currentWrigY), a            ;Save yPos
    inc (hl)                        ;Move wriggler one pixel down
        

    jp CalculateNewTilePosition


;====================================================
; Write CC info for Wriggler head to the buffer
;====================================================
;Update Wriggler head buffer 
WrigglerHeadLeft:
    ld (hl), YOKOHEAD               
    inc hl                          ;ld de, wriggler.headccHIGH
    ld (hl), DONTSTEPLEFT
    jp UpdateWrigglerBody0

WrigglerHeadRight:
    ld (hl), YOKOHEAD               
    inc hl                          ;ld de, wriggler.headccHIGH
    ld (hl), DONTSTEPRIGHT
    jp UpdateWrigglerBody0

WrigglerHeadUp:
    ld (hl), TATEHEAD               
    inc hl                          ;ld de, wriggler.headccHIGH
    ld (hl), DONTSTEPUP
    jp UpdateWrigglerBody0

WrigglerHeadDown:
    ld (hl), TATEHEAD               
    inc hl                          ;ld de, wriggler.headccHIGH
    ld (hl), DONTSTEPDOWN
    jp UpdateWrigglerBody0

;====================================================
; Update Tail diretion
;====================================================
TailYoko:
    ld a, (wrigBodyCCHold)
    cp DONTSTEPLEFT
    jp z, TailLeft
    cp DONTSTEPRIGHT
    jp z, TailRight

TailTate:
    ld a, (wrigBodyCCHold)
    cp DONTSTEPUP
    jp z, TailUp
    cp DONTSTEPDOWN
    jp z, TailDown

TailContinue:
    inc hl                              ;ld hl, wriggler.tailccLOW
    inc hl                              ;wriggler.tailccHIGH
    jp UpdateWrigglerSand

TailLeft:
    inc hl                              ;ld hl, wriggler.tailccLOW
    ld (hl), YOKOTAIL
    inc hl                              ;ld hl, wriggler.tailccHIGH
    ld (hl), DONTSTEPLEFT
    jp UpdateWrigglerSand

TailRight:
    inc hl                              ;ld hl, wriggler.tailccLOW
    ld (hl), YOKOTAIL
    inc hl                              ;ld hl, wriggler.tailccHIGH
    ld (hl), DONTSTEPRIGHT
    jp UpdateWrigglerSand

TailUp:
    inc hl                              ;ld hl, wriggler.tailccLOW
    ld (hl), TATETAIL
    inc hl                              ;ld hl, wriggler.tailccHIGH
    ld (hl), DONTSTEPUP
    jp UpdateWrigglerSand

TailDown:
    inc hl                              ;ld hl, wriggler.tailccLOW
    ld (hl), TATETAIL
    inc hl                              ;ld hl, wriggler.tailccHIGH
    ld (hl), DONTSTEPDOWN
    jp UpdateWrigglerSand

;==================================================================================================
;==================================================================================================
;==================================================================================================


