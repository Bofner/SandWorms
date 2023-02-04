;================================================================
;	WRIGGLE WRIGGLE LEVEL TWO
;================================================================
;Number of Wrigglers
.db		$03		

;Wriggler #1         
;-----------------------------------------------------
;State
.db LEFT

;xPos    		 Pixel Positions        
.db 190    
 
;yPos    		 Pixel Positions        
.db 65  
   
;Length         Number of Parts (head, body, tail) 	
.db 5     
;-----------------------------------------------------


;Wriggler #2         
;-----------------------------------------------------
;State
.db RIGHT

;xPos    		 Pixel Positions        
.db 85    
 
;yPos    		 Pixel Positions        
.db 85  
   
;Length         Number of Parts (head, body, tail) 	
.db 3       
;-----------------------------------------------------


;Wriggler #3         
;-----------------------------------------------------
;State
.db LEFT

;xPos    		 Pixel Positions        
.db 52    
 
;yPos    		 Pixel Positions        
.db 100  
   
;Length         Number of Parts (head, body, tail) 	
.db 4      
;-----------------------------------------------------

;Next Level Address
.dw		LevelThree

