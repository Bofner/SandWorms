;Get here after coming from $0038
InterruptHandler:
;Check if we are at VBlank, Bit 7 tells us that
    ld a, (VDPStatus)
    bit 7, a                ;Z is set if bit is 0
    jp nz, VBlank           ;If bit 7 is 1, then we are at VBlank

;=========================================================
; HBlank
;=========================================================

    ret


;=========================================================
; VBlank
;=========================================================
;If we are on the last scanline
VBlank:
;Set  IntNumber to zero
    xor a
    ld hl, INTNumber
    ld (hl), a
    inc hl                  ;ld hl, INTPattern
    ld (hl), a


;Update frame count up to 60
UpdateFrameCount:
    ld hl, frameCount           ;Update frame count
    ld a, 60                    ;Check if we are at 60
    cp (hl)
    jr nz, +                    ;If we are, then reset
ResetFrameCount:
    ld (hl), -1
+:
    inc (hl)                    ;Otherwise, increase


;Scene Specifics
    ld a, (sceneID)
    ;cp $XX
    jp nz, EndVBlank 
    
;Specific scene things go here


EndVBlank:
    ret


