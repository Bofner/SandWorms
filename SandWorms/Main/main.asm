;==============================================================
; WLA-DX banking setup
;==============================================================
.memorymap
    defaultslot     0
    ;ROM
    slotsize        $4000
    slot            0       $0000
    slot            1       $4000
    slot            2       $8000
    ;RAM
    slotsize        $2000   
    slot            3       $C000    
    slot            4       $E000
    slot            5       $FF01
.endme

.rombankmap
    bankstotal 4
    banksize $4000
    banks 4
.endro


;==============================================================
; SMS defines
;==============================================================
.define VDPCommand  $BF 
.define VDPData     $BE
.define VRAMWrite   $4000
.define CRAMWrite   $C000
.define NameTable   $3800
.define TextBox     $3CCC

.define paletteSize $10

.define UpBounds    $02
.define DownBounds  $BD
.define LeftBounds  $05
.define RightBounds $FD

.define WRIGGLERDATA        $D500


;==============================================================
; SDSC tag and ROM header
;==============================================================

.sdsctag 0.1, "Template", "Place Holder Description","Bofner"

.bank 0 slot 0
.org $0000
;==============================================================
; Boot Section
;==============================================================

    di              ;Disable interrupts
    im 1            ;Interrupt mode 1
    jp init         ;Jump to the initialization program

;==============================================================
; Interrupt Handler
;==============================================================
.orga $0038
;Swap shadow registers and registers
    ex af, af'
    exx 
;Get the status of the VDP
        in a,(VDPCommand)
        ld (VDPStatus), a
;Do specific scanline-based tasks
        call InterruptHandler
;Count the number of interrupts since VBlank
        ld hl, INTNumber
        ld a, (hl)
        inc a
        ld (hl), a
;Swap shadow registers and register back
    exx
    ex af, af'
    ei

;Leave
    reti

;==============================================================
; Pause button handler
;==============================================================
.org $0066


    retn


;==============================================================
; Include our STRUCTS so we can create them in MAIN
;==============================================================
.include "..\\Object_Files\\structs.asm"


;==============================================================
; Boiler Variables 
;============================================================== 
.enum $c000 export
    SATBuff         dsb 256     ;Set aside 256 bytes for SAT buffer $100

    VDPStatus       db          ;Bit 7:     1 = VBlank 0 = HBlank
                                ;Bit 6:     1 = >=9 sprites on raster
                                ;Bit 5:     1 = Sprite collision
                                ;Bit 4-0:   No function

    INTNumber       db          ;Variable that tells us which interrupt are we on

    spriteCount     dw          ;How many sprites are on screen at once? It's a word to assist the SATBuffer
    sprUpdCnt       db          ;Keeps track of how many sprites we have updated per frame

    frameCount      db          ;Used to count frames in intervals of 60

    scrollX         db          ;Generic, no parallax scrollX
    scrollY         db          ;Generic, no parallax scrollY

    currentBGPal instanceof paletteStruct   ;Used for Fade
    currentSPRPal instanceof paletteStruct  ;Used for Fade
    targetBGPal instanceof paletteStruct    ;Used for Fade
    targetSPRPal instanceof paletteStruct   ;Used for Fade

    sceneComplete   db          ;Used to determine if a scene is finished or not
    sceneID         db          ;Used to determine the scene we are on ($00 = SFS, $01 = Title, $FF = Pause, etc.)         

    sprYOff         db          ;Offset for the Y position of sprites when drawing them to the screen 
                                ;(Updates by $10 for 8x16, $08 for 8x8)
    sprXOff         db          ;Offset for the X position of sprites when drawing them to the screen
                                ;(Updates by $08 for 8x16, $08 for 8x8) 
    sprCCOff        db          ;Offset for the CC of sprites when drawing them to the screen
                                ;(Updates by $02 for 8x16, $01 for 8x8)  

    ;Variables used for starting levels in arcade
    nextLevelFile       dw          ;The level that we are currently on (Starts from LevelOne Address)

    spawningWrigs       db          ;The starting number of wrigglers/ number to spawn
    activeWrigs         db          ;The number of wrigglers currently on screen
    existedWrigs        db          ;The number of wrigglers that have been initiated in the level so far


    ;$c000 to $dfff is the space I have to work with for variables and such
    endByte         db          ;The first piece of available data post boiler-plate data
    
.ende



;==============================================================
; Game Constants
;==============================================================



;=============================================================================
; Special numbers 
;=============================================================================

.define postBoiler  endByte     ;Location in memory that is past the boiler plate stuff


;==============================================================
; Start up/Initialization
;==============================================================
init: 
    ld sp, $dff0

;==============================================================
; Set up VDP Registers
;==============================================================
;This is VDP Intialization data
    ld hl,VDPInitData                       ; point to register init data.
    ld b,VDPInitDataEnd - VDPInitData       ; 11 bytes of register data.
    ld c, $80                               ; VDP register command byte.
    call SetVDPRegisters
    

;==============================================================
; Clear VRAM
;==============================================================
;Set first color in sprite palette to black
    ld hl, $c010 | CRAMWrite
    call SetVDPAddress
;Next we send the BG palette data
    ld (hl), $00
    ld bc, $01
    call CopyToVDP

    call BlankScreen
    
    call ClearVRAM

;==============================================================
; Setup general sprite variables
;==============================================================
;Let a hold zero
    xor a
    ld hl, INTNumber
    ld (hl), a

    ld hl, frameCount
    ld (hl), a

;Initiate scrolls to zero
    ld hl, scrollX
    ld (hl), a
    ld hl, scrollY
    ld (hl), a

;Initialize the number of sprites on the screen
    ld hl, spriteCount      ;Set sprite count to 0
    ld (hl), a              ;
    inc hl                  ;Saving a memory address ($c000, beginning of SAT buffer)
    ld (hl), $C0

;Initialize the number of sprites that have been updated
    ld hl, sprUpdCnt        ;Set num of updated sprites to 0
    ld (hl), a              ;

;Initialize the offsets for our sprites to be zero
    ld hl, sprYOff
    ld (hl), a
    inc hl                  ;ld hl, sprXOff
    ld (hl), a
    inc hl                  ;ld hl, sprCCOff
    ld (hl), a

;==============================================================
; Game sequence
;==============================================================

    ei

    ;call SteelFingerStudios

    ;call TitleScreen

    ;call ArcadeTate

    call ArcadeYoko


;==============================================================
; Include Game Mechanic Files
;==============================================================


;==============================================================
; Include Helper Files
;==============================================================
.include "..\\Helper_Files\\helperFunctions.asm"
.include "..\\Helper_Files\\spriteDefines.asm"
.include "..\\Helper_Files\\interruptHandler.asm"


;==============================================================
; Include Level Files
;==============================================================
.include "..\\Level_Files\\steelFingerStudios.asm"
.include "..\\Level_Files\\arcadeYoko.asm"
.include "..\\Level_Files\\arcadeTate.asm"


;==============================================================
; Registers
;==============================================================
; There are 11 registers, so 11 data
VDPInitData:
              .db %00010100             ; reg. 0

              .db %10100000             ; reg. 1

              .db $ff                   ; reg. 2, Name table at $3800

              .db $ff                   ; reg. 3 Always set to $ff

              .db $ff                   ; reg. 4 Always set to $ff

              .db $ff                   ; reg. 5 Address for SAT, $ff = SAT at $3f00 

              .db $ff                   ; reg. 6 Base address for sprite patterns

              .db $f0                   ; reg. 7 Overrscan Color at Sprite Palette 0   

              .db $00                   ; reg. 8 Horizontal Scroll

              .db $00                   ; reg. 9 Vertical Scroll

              .db $ff                   ; reg. 10 Raster line interrupt off

VDPInitDataEnd:


;==============================================================
; Text Configuration
;==============================================================
.asciitable
    map " " = $d5
    map "0" to "9" = $d6
    map "!" = $e0
    map "," = $e1
    map "." = $e2
    map "'" = $e3
    map "?" = $e4
    map "A" to "Z" = $e5
.enda

TestMessage:
    ;50Ch"0123456789ABCDEF789012345 123456789ABCDEF789012345"
    .asc "Ready to enter the world   of a Template?"
    .db $ff     ;Terminator byte


;==============================================================
; Constant Data
;==============================================================
;Data for an all black palette
FadedPalette:
    .db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 
FadedPaletteEnd:


;Test palette for checking functionality of something
TestPalette:
    .db $00 $15 $2A $3F $00 $15 $2A $3F $3F $2A $15 $00 $3F $2A $15 $00
TestPaletteEnd:


/*
 OPTIONS:
-b  Program file output
-bS Starting address of the program (optional)
-bE Ending address of the program (optional)    
-d  Discard unreferenced sections
-D  Don't create _sizeof_* definitions
-nS Don't sort the sections
-i  Write list files
-r  ROM file output (default)
-R  Make file paths in link file relative to its location
-s  Write also a NO$GMB/NO$SNES symbol file
-S  Write also a WLA symbol file
-A  Add address-to-line mapping data to WLA symbol file
-v  Verbose messages (all)
-v1 Verbose messages (only discard sections)
-v2 Verbose messages (-v1 plus short summary)
-L <DIR>  Library directory
-t <TYPE> Output type (supported types: 'CBMPRG')
-a <ADDR> Load address (can also be label) for CBM PRG
*/


