;================================================================
; Arcade Yoko
;================================================================
ArcadeTate:

;==============================================================
; Scene beginning
;==============================================================
    ld hl, sceneComplete
    ld (hl), $00

;Start off with no sprites
    ld hl, spriteCount
    ld (hl), $00
    ld hl, sprUpdCnt
    ld (hl), $00

;==============================================================
; Memory (Structures, Variables & Constants) 
;==============================================================

;Structures and Variables
.enum postBoiler export
    
    ;hold16Bit           dw          ;Store 16-bit Numbers

    ;currentWrigBuf      dw          ;Location of the current Wriggler Buffer
    ;initRightLeft       db          ;Is the wriggler facing left or right on initialization

    ;repeatCounter       db          ;Used for djnz when djnz can't be used

    ;yokoWrigBuf instanceof wrigglerBufferStruct 40 STARTFROM 0
    

.ende


;==============================================================
; Clear VRAM
;==============================================================
    call BlankScreen

    call ClearVRAM

    call ClearSATBuff


;==============================================================
; Load Palette
;==============================================================
;All black palette to be used once we are making things pretty
;Write current BG palette to currentPalette struct
    ld hl, currentBGPal.color0
    ld de, FadedPalette
    ld b, $10
    call PalBufferWrite

;Write current SPR palette to currentPalette struct
    ld hl, currentSPRPal.color0
    ld de, FadedPalette
    ld b, $10
    call PalBufferWrite


;Write target BG palette to targetPalette struct
    ld hl, targetBGPal.color0
    ld de, ArcadeYokoBgPal
    ld b, $10
    call PalBufferWrite


;Write target SPR palette to targetPalette struct
    ld hl, targetSPRPal.color0
    ld de, ArcadeYokoSprPal
    ld b, $10
    call PalBufferWrite


;Actually update the palettes in VRAM
    call LoadBackgroundPalette
    call LoadSpritePalette

;==============================================================
; Load BG tiles 
;==============================================================

    ld hl, $0000 | VRAMWrite
    call SetVDPAddress
    ld hl, ArcadeTateTiles
    ld bc, ArcadeTateTilesEnd-ArcadeTateTiles
    call CopyToVDP

    ld hl, $1F20 | VRAMWrite
    call SetVDPAddress
    ld hl, ChichaiWrigglerTiles
    ld bc, ChichaiWrigglerTilesEnd-ChichaiWrigglerTiles
    call CopyToVDP

    ld hl, $1EC0 | VRAMWrite
    call SetVDPAddress
    ld hl, WrigglerSandTiles
    ld bc, WrigglerSandTilesEnd-WrigglerSandTiles
    call CopyToVDP


;==============================================================
; Write background map
;==============================================================
 
    ld hl, $3800 | VRAMWrite
    call SetVDPAddress
    ld hl, ArcadeTateMap
    ld bc, ArcadeTateMapEnd-ArcadeTateMap
    call CopyToVDP

    ;------------------------------------------
    ;Set a bit on a specific tile on the BG Map
    ;------------------------------------------
    ;Grab the data from the BG Map
    ld hl, $38FB                    ;Location we want to read from
    call SetVDPAddress
    in a, (VDPData)
    set 7, a
    ;Set our bit to the map
    ld hl, $38FA                    ;Location just before we want to write to
    call SetVDPAddress
    out (VDPData), a



;==============================================================
; Load Sprite tiles 
;==============================================================
    
/*
    ld hl, $2000 | VRAMWrite
    call SetVDPAddress
    ld hl, TemplateSpriteTiles
    ld bc, TemplateSpriteTilesEnd-TemplateSpriteTiles
    call CopyToVDP
*/

;==============================================================
; Intialize our Variables
;==============================================================
    xor a

    ld hl, LevelOne                 ;This is an address 
    ld (nextLevelFile), hl             

    ld hl, spawningWrigs
    ld (hl), 0              
    ld hl, activeWrigs  
    ld (hl), a                 
    ld hl, existedWrigs  
    ld (hl), a      

/*
    ld hl, yokoWrigBuf              ;Set te currentWrigBuf to be yokoWrigBuf
    ld (currentWrigBuf), hl

    ld hl, yokoWrigBuf
    ld b, _sizeof_wrigglerBufferStruct
-:
    ld (hl), a
    inc hl
    djnz -
*/
    
;Boilers
    ld hl, scrollX          ;Set horizontal scroll to zero
    ld (hl), a              ;

    ld hl, scrollY          ;Set vertical scroll to zero
    ld (hl), a              ;

    ld hl, frameCount       ;Set frame count to 0
    ld (hl), a              ;   


;==============================================================
; Intialize our objects
;==============================================================

/*
;LevelObj
    ld hl, levelObj.sprNum
    inc hl                              ;ld hl, topShimmer.hw
    ld (hl), $11                        ;Sprite is 1x1 for 8x16
    inc hl                              ;ld hl, topShimmer.y
    ld (hl), 62
    inc hl                              ;ld hl, topShimmer.x
    ld (hl), 1
    inc hl                              ;ld hl, topShimmer.cc
    ld (hl), $00
*/
;==============================================================
; Set Registers gy7
;==============================================================
;HBlank timingy
    ld a, $FF                               ;$07 = HBlank every 8 scanlines
    ld c, $8A
    call UpdateVDPRegister

;Don't Blank Left Column
    ld a, %00000100                         ;BIT 5 BLANK column
    ld c, $80
    call UpdateVDPRegister

;Which sprite index chooses background color
    ld a, $F1                               ;Sprite color 1
    ld c, $87
    call UpdateVDPRegister

;=============================================================
; Set Scene
;=============================================================
    ld hl, sceneID
    ld (hl), $02

    ;call InitializeWrigglers


;==============================================================
; Turn on screen
;==============================================================
 ;(Maxim's explanation is too good not to use)
    ld a, %01100010
;           ||||||`- Zoomed sprites -> 16x16 pixels
;           |||||`-- Doubled sprites -> 8x16
;           ||||`--- Mega Drive mode 5 enable
;           |||`---- 30 row/240 line mode
;           ||`----- 28 row/224 line mode
;           |`------ VBlank interrupts
;            `------- Enable display    
    ld c, $81
    call UpdateVDPRegister

    ei

;========================================================
; Game Logic
;========================================================

    call FadeIn
    call InitializeWrigs
    call UpdateWrigBuffers

ArcadeTateLoop:
;Start LOOP
    halt

    call DrawWrigToTileMap
    call UpdateWrigBuffers

;End Loop
    jp ArcadeTateLoop


;========================================================
; Game Object Files
;========================================================


;========================================================
; Level Data
;========================================================


;========================================================
; Background Palette
;========================================================





;========================================================
; Background Tiles
;========================================================

ArcadeTateTiles:
    .include "..\\assets\\tiles\\backgrounds\\arcadeTate.inc"
ArcadeTateTilesEnd:


;========================================================
; Tile Maps
;========================================================

ArcadeTateMap:
    .include "..\\assets\\maps\\arcadeTate.inc"
ArcadeTateMapEnd:


;========================================================
; Chichai Wriggler Tiles
;========================================================



;========================================================
; Sprite Palette
;========================================================




;========================================================
; Sprite Tiles
;========================================================
/*
LevelTemplateTiles:
    .include "..\\assets\\tiles\\sprites\\sunFish\\templateSprite.inc"
LevelTemplateTilesEnd:
*/


