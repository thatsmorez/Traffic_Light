Assume cs:code, ds:data, ss:stack
 
;initializing all of the variables
data segment
pedSignal db 0
westMessage db "West Light On$"
eastMessage db "East Light On$"
nsMessage db "North/South Light On$"
turnMessage db "Turn Light On$"
menu db "Press 1 for Day Mode and 2 for Night Mode$"
pedMessage db "PED SIGNAL ON$"
menuentry db 20 dup(?)
data ends
 
stack segment  
dw 100 dup(?)
stacktop:
stack ends
 
code segment
begin:	
mov ax, data
mov ds,ax
mov ax, stack
mov ss,ax
mov sp, offset stacktop
 
;Sets the board in direction mode
MOV DX, 143H
MOV AL, 02H
OUT DX, AL
 
;Tells the board which ports are inputs/outputs
MOV DX, 140H
MOV AL, 11111111b
OUT DX, AL
MOV DX, 141H
MOV AL, 11111111b
OUT DX, AL
MOV DX, 142H
MOV AL, 00000011b
OUT DX, AL
 
;Sets the board in Operation Mode
MOV DX, 143H
MOV AL, 03H
OUT DX, AL
 
;Beginning of Actual Code
;Prints the Menu to the Screen
mov si, offset menu
CALL PRINT
 
;Waits for an User Input on the Keyboard
entryLoop:
MOV AH, 01H
INT 21H
MOV [si], AL
cmp AL, "1"
;If one is pressed, the program will enter “Day Mode”
JE mydayMode
cmp AL, "2"
;If two is pressed, the program will enter “Night Mode”
JE mynightMode
JMP entryLoop
mydayMode:
Call dayMode
JMP entryLoop
mynightMode:
Call nightMode
JMP entryLoop
 
;terminates the program
exit:
mov ah,4ch
int 21H
 
----------------------------------------------------------------------------------------------------------------------
;The Day Mode Subroutine
dayMode:
push AX
push BX
push CX
push DX
 
;Loops through this routine 4 times prior returning to the menu
MOV CX, 04H
;Sets all Lights to Red
CALL AllRed
DayTime:
 ;Calls the North/South Cycle
Call NandS
Call delayShort
;Calls the East Cycle
Call East
Call delayShort
;Calls the West Cycle
Call West
Call delayShort
;Calls the Turn Cycle
Call Turn
Call delayShort
 
;Checks to see if the Pedestrian Button has been pressed
CMP pedSignal, 1
JE LightsOff
JMP nextCycle
 
LightsOff:
;Tells the user it is safe for pedestrians to cross
MOV SI, offset pedMessage
CALL PRINT
;Sets all lights to red
Call AllRed
Call Extended
Call Extended
;Resets the signal
MOV pedSignal, 0
 
nextCycle:
Loop DayTime
 
pop DX
pop CX
pop BX
pop AX
RET
 
---------------------------------------------------------------------------------------------------------------------
;The Night Mode Subroutine
nightMode:
push AX
push BX
push CX
push DX
 
;Turns all the Red Lights on
Call AllRed
;Turns on the North and South Lights (default)
Call onNandS
MOV CX, 0FFH
 
night:
;Determines if any of the push buttons were pressed
Call checkEast
Call checkWest
Call checkTurn
Call checkButton
 
;Determines if the Pedestrian signal was pressed
CMP pedSignal, 1
JE LightOff
 
Loop night
 
LightsOff:
;Tells the user it is safe for pedestrians to cross
MOV SI, offset pedMessage
CALL PRINT
;Sets all lights to red
Call AllRed
Call Extended
Call Extended
;Resets the signal
MOV pedSignal, 0
 
Loop night
pop DX
pop CX
pop BX
pop AX
RET
---------------------------------------------------------------------------------------------------------------------
;All Red Subroutine
AllRed:
push AX
push BX
push CX
push DX
;Turns on all of the RED lights in port A
MOV DX, 140H
MOV AL, 10110110b
OUT DX, AL
;Turns on all of the RED lights in port B
MOV DX, 141H
MOV AL, 11101101b
OUT DX, AL
;Turns on all of the RED lights in port C
MOV DX, 142H
MOV AL, 00000001b
OUT DX, AL
pop DX
pop CX
pop BX
pop AX
RET
---------------------------------------------------------------------------------------------------------------------
;The NandS Subroutine
;Used within the Day Mode to turn the North and South lights Green/Yellow/Red while leaving      the remaining lights red
NandS:
push AX
push BX
push CX
push DX
 
;Turns the North and South green light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 10011110b
OUT DX, AL
MOV DX, 141H
MOV AL, 10111101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
CALL Extended
 
;Turns the North and South yellow light on while leaving the other directions’  red light     	on
MOV DX, 140H
MOV AL, 10101110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11011101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
Call delayShort
 
;Turns the North and South red light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 10110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
Call delayShort
 
pop DX
pop CX
pop BX
pop AX
RET
---------------------------------------------------------------------------------------------------------------------
;The Turn Subroutine
;Used within the Day Mode to turn the Turning Lane lights Green/Yellow/Red while leaving the remaining lights red
Turn:
Push AX
Push BX
Push CX
Push DX
 
;Turns the Turning Lane’s green light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 10110011b
OUT DX, AL
MOV DX, 141H
MOV AL, 11100111b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
Call Extended
 
;Turns the Turning Lane’s yellow light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 10110101b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101011b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
Call delayShort
 
;Turns the Turning Lane’s red light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 10110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
Call delayShort
pop DX
pop CX
pop BX
pop AX
RET
---------------------------------------------------------------------------------------------------------------------
;The East Subroutine
;Used within the Day Mode to turn the East lights Green/Yellow/Red while leaving the remaining lights red
East:
Push AX
Push BX
Push CX
Push DX
 
;Turns the East’s green light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 11110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101100b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
CALL Extended
 
;Turns the East’s yellow light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 01110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
CALL delayShort
 
;Turns the East’s red light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 10110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
CALL delayShort
 
pop DX
pop CX
pop BX
pop AX
RET
---------------------------------------------------------------------------------------------------------------------
;The West Subroutine
;Used within the Day Mode to turn the West lights Green/Yellow/Red while leaving the remaining lights red
West:
Push AX
Push BX
Push CX
Push DX
 
;Turns the West’s green light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 10110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 01101101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111111b
OUT DX, AL
CALL Extended
 
;Turns the West’s yellow light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 10110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111110b
OUT DX, AL
CALL delayShort
 
;Turns the West’s red light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 10110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
CALL delayShort
 
pop DX
pop CX
pop BX
pop AX
RET
---------------------------------------------------------------------------------------------------------------------
;The North and South Subroutine
;Used within the Night Mode to turn the north and south lights Green while leaving the remaining lights red
;Night Mode default
onNandS:
Push AX
Push BX
Push CX
Push DX
;Prints to the HyperTerminal that the North and South Lights are on
MOV SI, offset nsMessage
CALL PRINT
 
;Turns the North’s and South’s  green light on while leaving the other directions’  red        	light on
MOV DX, 140H
MOV AL, 10011110b
OUT DX, AL
MOV DX, 141H
MOV AL, 10111101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
 
Pop DX
Pop CX
Pop BX
Pop AX
RET
--------------------------------------------------------------------------------------------------------------------
;The Check East Subroutine
;Used within the Night Mode Subroutine
;Determines whether the East pushbutton has been pressed
;If the East pushbutton has been pressed, its light will turn green. Otherwise, the program will continue searching.
checkEast:
Push AX
Push BX
Push CX
Push DX
 
;Determines if the East pushbutton has been pressed
MOV DX, 142H
IN AL, DX
AND AL, 00100000b
CMP AL, 00000000b
;If the button is pressed, the code will jump to turnOnEast… Otherwise it will jump to        	finish
JE turnOnEast
JMP finish1
 
turnOnEast:
;Prints to the HyperTerminal telling the user that the East Light is turning on
MOV SI, offset eastMessage
CALL PRINT
 
;Turns the North’s and South’s  yellow light on while leaving the other directions’  red      	light on
MOV DX, 140H
MOV AL, 10101110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11011101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
CaLL delayShort
 
;Turns the North’s and South’s  red light on while leaving the other directions’ red 	light on
MOV DX, 140H
MOV AL, 10110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
Call delayShort
 
;Turns the East’s  green light on while leaving the other directions’ red light on
MOV DX, 140H
MOV AL, 11110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101100b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
CALL Extended
 
;Turns the East’s  yellow light on while leaving the other directions’ red light on
MOV DX, 140H
MOV AL, 01110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
CALL delayShort
 
;Turns the East’s  red light on while leaving the other directions’ red light on
MOV DX, 140H
MOV AL, 10110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
CALL delayShort
 
 
Finish1:
;Calling the onNandS subroutine to return to the default state
Call onNandS
Pop DX
Pop CX
Pop BX
Pop AX
RET
---------------------------------------------------------------------------------------------------------------------
;The Check West Subroutine
;Used within the Night Mode Subroutine
;Determines whether the West pushbutton has been pressed
;If the West pushbutton has been pressed, its light will turn green. Otherwise, the program will       continue searching.
checkWest:
Push AX
Push BX
Push CX
Push DX
 
;Determines if the West pushbutton has been pressed
MOV DX, 142H
IN AL, DX
AND AL, 01000000b
CMP AL, 00000000b
;If the button is pressed, the code will jump to turnOnWest… Otherwise it will jump to       	finish
JE turnOnWest
JMP finish2
 
turnOnWest:
;Prints to the HyperTerminal telling the user that the West Light is turning on
MOV SI, offset westMessage
CALL PRINT
 
;Turns the North’s and South’s  yellow light on while leaving the other directions’  red      	light on
MOV DX, 140H
MOV AL, 10101110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11011101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
CaLL delayShort
 
;Turns the North’s and South’s  red light on while leaving the other directions’  red    light on
MOV DX, 140H
MOV AL, 10110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
Call delayShort
 
;Turns the West’s green light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 10110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 01101101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111111b
OUT DX, AL
CALL Extended
 
;Turns the West’s yellow light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 10110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111110b
OUT DX, AL
CALL delayShort
 
;Turns the West’s red light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 10110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
CALL delayShort
 
 
Finish2:
;Calls the onNandS subroutine to return to the default state.
Call onNandS
Pop DX
Pop CX
Pop BX
Pop AX
RET
---------------------------------------------------------------------------------------------------------------------
;The Check Turn Subroutine
;Used within the Night Mode Subroutine
;Determines whether the Turn pushbutton has been pressed
;If the Turn pushbutton has been pressed, its light will turn green. Otherwise, the program will       continue searching.
checkTurn:
Push AX
Push BX
Push CX
Push DX
 
;Determines if the Turn pushbutton has been pressed
MOV DX, 142H
IN AL, DX
AND AL, 00010000b
CMP AL, 00000000b
;If the button is pressed, the code will jump to onTurn3… Otherwise it will jump to finish
JE onTurn3
JMP finish3
 
onTurn3:
;Prints to the HyperTerminal telling the user that the East Light is turning on
MOV SI, offset turnMessage
CALL PRINT
 
;Turns the North’s and South’s  yellow light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 10101110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11011101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
CaLL delayShort
 
;Turns the North’s and South’s  red light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 10110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
Call delayShort
 
;Turns the Turn’s  green light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 10110011b
OUT DX, AL
MOV DX, 141H
MOV AL, 11100111b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
Call Extended
 
;Turns the Turn’s  yellow light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 10110101b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101011b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
Call delayShort
 
;Turns the Turn’s  red light on while leaving the other directions’  red light on
MOV DX, 140H
MOV AL, 10110110b
OUT DX, AL
MOV DX, 141H
MOV AL, 11101101b
OUT DX, AL
MOV DX, 142H
MOV AL, 11111101b
OUT DX, AL
Call delayShort
 
Finish3:
;Calls the onNandS to return to default
Call onNandS
Pop DX
Pop CX
Pop BX
Pop AX
RET
---------------------------------------------------------------------------------------------------------------------
;The Check Button Subroutine
;Checks to see if the Pedestrian Button has been pressed
checkButton:
Push AX
Push BX
Push CX
Push DX
 
;Inputs the data from the push button corresponding to the Pedestrian Button
MOV DX, 142H
IN AL, DX
AND AL, 00000100b
CMP AL, 00000000b
JE setPed
JMP finish
 
setPed:
;If the button has been pressed, the variable pedSignal gets set to “1”
MOV pedSignal, 1
 
finish:
Pop DX
Pop CX
Pop BX
Pop AX
RET
---------------------------------------------------------------------------------------------------------------------
;The Short Delay Subroutine
;Creates a delay that last approximately 1 second
delayShort:
Push AX
Push BX
Push CX
Push DX
 
;Sets the two counters
MOV BX, 0FH
MOV CX, 0FFFFH
;Starts decrementing both counters until BX is Zero
ShortLoop:
NOP
DEC CX
CMP CX, 0000H
 
JNE ShortLoop
CALL checkButton
MOV CX, 0FFFFH
DEC BX
CMP BX, 0000H
JNE ShortLoop
 
Pop DX
Pop CX
Pop BX
Pop AX
RET
---------------------------------------------------------------------------------------------------------------------
;The Extended Delay Subroutine
;Creates a delay that last approximately 4 seconds
Extended:
Push AX
Push BX
Push CX
Push DX
 
;Simply Cycles through the Short Delay 4 times
Call delayShort
Call delayShort
Call delayShort
Call delayShort
 
Pop DX
Pop CX
Pop BX
Pop AX
RET
---------------------------------------------------------------------------------------------------------------------
;The Print Subroutine
;Prints messages to the HyperTerminal.
;Primarily used in night mode and to signal the Pedestrian
PRINT:
push ax
push bx
push cx
push dx
;Tells the program to print to the HyperTerminal
mov ah, 2
xxx :
mov dl, [si]
;Determines if the message is complete
cmp dl, '$'
je here
;Actually prints to the HyperTerminal
int 21H
inc si
jmp xxx
here:
mov dl, 13
int 21H
mov dl, 10
int 21H
pop dx
pop cx
pop bx
pop ax
RET
---------------------------------------------------------------------------------------------------------------------
;The Code Ends Here
code ends
end begin
