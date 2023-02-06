;================================================================
;	WRIGGLE WRIGGLE LEVEL ONE
;================================================================
;Number of Wrigglers
.db		$03		

;Wriggler #1         
;-----------------------------------------------------
;State
.db LEFT

;xPos    		 Pixel Positions        
.db $9F    
 
;yPos    		 Pixel Positions        
.db $4F  
   
;Length         Number of Parts (head, body, tail) 	
.db 5     
;-----------------------------------------------------


;Wriggler #2         
;-----------------------------------------------------
;State
.db LEFT

;xPos    		 Pixel Positions        
.db $6F    
 
;yPos    		 Pixel Positions        
.db $47  
   
;Length         Number of Parts (head, body, tail) 	
.db 3       
;-----------------------------------------------------


;Wriggler #3         
;-----------------------------------------------------
;State
.db DOWN

;xPos    		 Pixel Positions        
.db $3F    
 
;yPos    		 Pixel Positions        
.db $5F  
   
;Length         Number of Parts (head, body, tail) 	
.db 5      
;-----------------------------------------------------

;Next Level Address
.dw		LevelTwo

