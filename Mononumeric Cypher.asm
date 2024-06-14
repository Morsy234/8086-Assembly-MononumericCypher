
org 100h


jmp start

;               ---->   'abcdefghijklmnopqrstvuwxyz'

encryption_table    DB  'qwertyuiopasdfghjklzxcvbnm'

decryption_table    DB  'kxvmcnophqrszyijadlegwbuft'




welcome_msg DB  '>>>>>>>>>>WELCOME TO THE MONOALPHABETIC ENCRIPTION/DECRYPTION PROGRAM<<<<<<<<<<', '$'

msg1        DB  'Enter the message: ', '$' 

msg2        DB  'original message: ', '$'

msg3        DB  'Encrypted message: ', '$'

msg4        DB  'Decrypted message: ', '$'

msg5        DB  'Message after removing spaces: ', '$'



new_line           DB  0DH,0AH,'$'          ;for new line

str                DB  128,?,128 DUP('$')   ;buffer string (Reserving a byte for buffer size,
                                            ; a byte for number of characters that are read and 128 byte initialized as $)

encription_str     DB  128 DUP('$')         ;encrypted string

decription_str     DB  128 DUP('$')         ;decrypted string

omit_str           DB  128 DUP('$')         ;removedSpaces string


start:

;print welcome message
LEA    DX,welcome_msg
MOV    AH,09h
INT    21h
; print new line
LEA    DX,new_line                    
MOV    AH,09h       ; value of AH is adjusted as operation of int 21H depends on its value                    
INT    21h          ; at AH = 09, int 21H outputs string at DS:DX


;------------------------------------------------------------           
; print message
LEA    DX,msg1
MOV    AH,09h       ; value of AH is adjusted as operation of int 21H depends on its value            
INT    21h          ; at AH = 09, int 21H outputs string at DS:DX

; read the string
                        ;0AH requires  this syntax:  str  DB  128,?,128 DUP('$') where 128->max buffer size
                        ;? is already read bytes and 128 dup('$') mean initialize 128 bytes with $
MOV    AH, 0AH          ;used to scan input from user
MOV    DX, offset str   ;will write in str
INT    21h    

; print new line
LEA    DX,new_line
MOV    AH,09h
INT    21h

 
;------------------------------------------------------------           
; print original message
LEA    DX,msg2
MOV    AH,09h
INT    21h
; print original message
LEA    DX,str+2          ;because the first two bytes reserved for the size of string
MOV    AH,09h
INT    21h 


; print new line
LEA    DX,new_line
MOV    AH,09h
INT    21h

;------------------------------------------------------------
; print removed spaces message
LEA    DX,msg5
MOV    AH,09h
INT    21h
; print message after removing spaces
LEA    SI, str+2
LEA    DI, omit_str
CALL   omit_space
; show result:
LEA    DX, omit_str
MOV    AH, 09
INT    21h


; print new line
LEA    DX,new_line
MOV    AH,09h
INT    21h                      
  

;-------------------------------------------------------------                     
                     
; encrypt:
LEA    BX, encryption_table
LEA    SI, omit_str
LEA    DI, encription_str
CALL   Encrypt_Decrybt
                                          
; print encrypted message
LEA    DX,msg3
MOV    AH,09h
INT    21h
; show result:
LEA    DX, encription_str
MOV    AH, 09
INT    21h
; print new line
LEA    DX,new_line
MOV    AH,09h
INT    21h     
                
;-------------------------------------------------------------          
                
; decrypt:
LEA    BX, decryption_table
LEA    SI, encription_str
LEA    DI, decription_str
CALL   Encrypt_Decrybt

; print decrypted message
LEA    DX,msg4
MOV    AH,09h
INT    21h
; show result:
LEA    DX, decription_str
MOV    AH, 09
INT    21h
; print new line
LEA    DX,new_line
MOV    AH,09h
INT    21h
           
           
           
; wait for any key...
MOV    AH, 0
INT    16h















Encrypt_Decrybt proc near

  

next_char:
	CMP     [SI], '$'      ; end of string?
	JE      end_of_string
	CMP     [SI], ' '      
	JE      skip
	
	mov     AL, [SI]
	CMP     AL, 'a'
	JB      skip
	CMP     AL, 'z'
	JA      skip
	SUB     AL, 61H	       ;subtract ASCII code of 'a'= 61H in order to get the right offset 
	 
	XLAT       
	MOV    [DI], AL
	INC     DI

skip:
	INC     SI	
	JMP     next_char

end_of_string:
    INC     SI
    MOV    [SI], '$'
    MOV    [DI], '$'
    RET
Encrypt_Decrybt endp  






omit_space proc near
    
search_space: ; loop to skip spaces
    MOV     AL, [SI] 
    CMP     AL, ' ' 
    JE      space_found 
    MOV    [DI], AL 
    INC     DI 
space_found:
    INC SI 
    CMP [SI], '$' 
    JNE search_space 

 MOV [DI], '$' ; Terminate the result string
 RET 

omit_space endp


END