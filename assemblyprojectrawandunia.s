AREA Program, CODE, READONLY

; Declare two strings in the memory
STR1        DCB "Arm Assembly Programming",0
STR2        DCB "Hello World",0

; Define variables to store strings and letters
TXT1        SPACE   60 ;  since the maximum srting is 27 size we define array with 60 for conveniance // it has to be t least 28
TXT2        SPACE   60 
Count1      DCD     0   
Count2      DCD     0   ;declare a counter 
COMMON      DCD     0          ; Define a variable to store the number of common characters
ENCRYPT1    DCB 32          ; Buffer for the encrypted string 1
ENCRYPT2    DCB 32          ; Buffer for the encrypted string 2

; Define the procedure to convert a string to all small letters and count the number of capital letters converted

ConvertToLower PROC
            PUSH    {LR}           
            MOV     R2, #0           
ConvertLoop LDRB    R3, [R0], #1    ; R0 is the string we want to convert to small letters
            CMP     R3, #0          ; compare with 0 to find the end of string
            BEQ     ConvertDone     ; if end of string, exit the loop
            CMP     R3, #'A'        ; check if the byte is a capital letter
            BLT     ConvertSkip     ; if not a capital letter, skip
            CMP     R3, #'Z'        
            BGT     ConvertSkip     
            ADD     R3, #'a'-'A'    ; convert the capital letter to small letter
            ADD     R2, #1          ; increment the count of converted letters
ConvertSkip  STRB    R3, [R1], #1    ; store the byte to the output string and increment the pointer
            B       ConvertLoop      
ConvertDone MOV     R0, R2          
            POP     {PC}            ; restore the return address and exit the procedure
            ENDP
            LDR     R0, =STR1       
            LDR     R1, =TXT1       ; define the output string1 as needed
            BL      ConvertToLower  
            STR     R0, Count1      ; this the count of letters converted in string 1

            LDR     R0, =STR2     
            LDR     R1, =TXT2       ; define the output string1 as needed
            BL      ConvertToLower  
            STR     R0, Count2      ; this the count of letters converted in string 2
            END

      ; Define a procedure to compute the number of common characters between two strings
CountCommonChars PROC
        PUSH    {LR}            
        MOV     r3, #0          ; Initialize the counter
Outer   LDRB    r1, [r0], #1    ; Load the next character from string 1
        CMP     r1, #0          ; Compare with the end of string
        BEQ     Done            ; Branch if equal, i.e. end of string 1
        MOV     r4, r0          ; Save the pointer to the current character in string 1
Inner   LDRB    r2, [r5], #1    ; Load the next character from string 2
        CMP     r2, #0          ; Compare with the end of string
        BEQ     Outer           ; Branch if equal, i.e. end of string 2
        CMP     r1, r2          ; Compare the two characters
        BNE     Inner           ; Branch if not equal
        ADD     r3, r3, #1      ; Increment the counter

     Encrypt PROC
    ; R0 - address of the input string
    ; R1 - address of the output string
    ; R2 - length of the input string
    ; R3 - temporary register for storing inverted ASCII value

    MOV R4, #0 ; Initialize counter to 0

loop:
    LDRB R3, [R0], #1 ; Load byte from input string and increment address
    MVN R3, R3 ; Invert ASCII value
    STRB R3, [R1], #1 ; Store inverted byte to output string and increment address
    ADDS R4, R4, #1 ; Increment counter
    CMP R4, R2 ; Compare counter to length of input string
    BNE loop ; Continue loop if not equal

    BX LR ; Return from procedure
 
           	   ; Save the return address
        LDR     R0, =TXT1
        LDR     R1, =ENCRYPT1
        BL      Encrypt
        ; Encrypt TXT2 and store in ENCRYPT2
        LDR     R0, =TXT2
        LDR     R1, =ENCRYPT2
        BL      Encrypt

Decrypt PROC
    ; R0 - address of the input string
    ; R1 - address of the output string
    ; R2 - length of the input string
    ; R3 - temporary register for storing inverted ASCII value

    MOV R4, #0 ; Initialize counter to 0

loop:
    LDRB R3, [R0], #1 ; Load byte from input string and increment address
    MVN R3, R3 ; Invert ASCII value
    STRB R3, [R1], #1 ; Store inverted byte to output string and increment address
    ADDS R4, R4, #1 ; Increment counter
    CMP R4, R2 ; Compare counter to length of input string
    BNE loop ; Continue loop if not equal

    BX LR ; Return from procedure
       
	PUSH    {LR}               ;save the return address 
        LDR     R0, =ENCRYPT1
        LDR     R1, =TXT1
        BL      Decrypt

        ; Decrypt ENCRYPT2 and store in TXT2
        LDR     R0, =ENCRYPT2
        LDR     R1, =TXT2
        BL      Decrypt

        
        B       $
