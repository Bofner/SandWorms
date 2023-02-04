;==============================================================
;All Structs that are sprites MUST have the following
;==============================================================
.struct spriteStruct
    sprNum      db      ;The draw-number of the sprite 
    width       db      ;The width of the OBJ     
    height      db      ;The height of the OBJ
    yPos        db      ;The Y coord of the OBJ
    xPos        db      ;The X coord of the OBJ
    cc          db      ;The first character code for the OBJ 
.endst



;==============================================================
; Palette structure
;==============================================================
.struct paletteStruct
    color0      db
    color1      db
    color2      db
    color3      db
    color4      db
    color5      db
    color6      db
    color7      db
    color8      db
    color9      db
    colorA      db
    colorB      db
    colorC      db
    colorD      db
    colorE      db
    colorF      db
.endst

;==============================================================
; SFS Shimmer
;==============================================================
.struct shimmerStruct
    instanceof spriteStruct
.endst

;==============================================================
; Wriggler Structure
;==============================================================
.struct wrigglerStruct     
    state           db      ;$01-LEFT, $02-RIGHT, $03-UP, $04-DOWN, $FF-DEAD
    prevState       db      ;Holds the last state of the wriggler
    xPos            db      ;Pixel Positions for the head
    yPos            db      ;Pixel Positions for the head
    length          db      ;Number of Parts (head, body, tail)
    ;Location on Tile map
    head            dw
    headcc          dw      ;YOKO r TATE head?
    body0           dw      ;Tile Map Location
    body0cc         dw      ;YOKO or TATE
    body1           dw      ;Tile Map Location
    body1cc         dw      ;YOKO or TATE
    body2           dw      ;Tile Map Location
    body2cc         dw      ;YOKO or TATE
    body3           dw      ;Tile Map Location
    body3cc         dw      ;YOKO or TATE
    body4           dw      ;Tile Map Location
    body4cc         dw      ;YOKO or TATE
    body5           dw      ;Tile Map Location
    body5cc         dw      ;YOKO or TATE
    body6           dw      ;Tile Map Location
    body6cc         dw      ;YOKO or TATE
    body7           dw      ;Tile Map Location
    body7cc         dw      ;YOKO or TATE
    tail            dw      ;Tile Map Location
    tailcc          dw      ;YOKO or TATE tail?
    sand            dw
    sandcc          dw
.endst


/*
;==============================================================
; Chichai Wriggler
;==============================================================
.struct wrigglerStruct
    chichID         db      
    state           db      ;0-Spawning, 1-Move, 2-Turn, 3-Split, $FF-Dead
    xPos            db      ;Pixel Positions
    yPos            db      ;Pixel Positions
    direction       db      ;0-LEFT, 1-RIGHT, 2-UP, 3-DOWN
    length          db      ;Number of Parts (head, body, tail)
.endst

Other useful Wriggler-based variables
spawningWrigs              
activeWrigs  
existedWrigs 


;==============================================================
; Wriggler Buffer
;==============================================================
.struct wrigglerBufferStruct
    firstTile       dw      ;The first tile to write to VRAM
    ;direction       db      ;LEFT, RIGHT, UP, DOWN, TURNING
    length          db      ;Length of Wriggler we are drawing
    ;Wriggler can be at most 1 Head, 5 Body, 1 Tail and 1 Sand
    ;Below is the pieceMAP Buffer
    piece0          dw      ;Body tile data
    tile0           dw      ;Body tile Location  
    piece1          dw      ;Body tile data 
    tile1           dw      ;Body tile Location 
    piece2          dw      ;Body tile data 
    tile2           dw      ;Body tile Location 
    piece3          dw      ;Body tile data 
    tile3           dw      ;Body tile Location 
    piece4          dw      ;Body tile data
    tile4           dw      ;Body tile Location 
    piece5          dw      ;Body tile data
    tile5           dw      ;Body tile Location 
    piece6          dw      ;Body tile data
    tile6           dw      ;Body tile Location 
    piece7          dw      ;Body tile data
    tile7           dw      ;Body tile Location 
    piece8          dw      ;Body tile data  
    tile8           dw      ;Body tile Location 

.endst
*/

