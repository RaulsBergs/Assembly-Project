*-------------------------------------------------------
* STARTING MEMORY ADDRESS FOR THE PROGRAMME $1000
*-------------------------------------------------------
    
    ORG $1000

*-------------------------------------------------------
*VALIDATION VALUES TO BE USED, MODIFY AS NEEDED
*ADD ADDITIONAL VALIDATION VALUES AS REQUIRED
*-------------------------------------------------------
EXIT        EQU 0      USED TO EXIT ASSEMBLY PROGRAM
MIN_POTIONS EQU 1      MIN NUMBER OF POTIONS
MAX_POTIONS EQU 9      MAX NUMBER OF POTIONS
MIN_WEAPONS EQU 1      MIN WEAPONS
MAX_WEAPONS EQU 3      MAX WEAPONS
WIN_POINT   EQU 5      POINTS ACCUMILATED ON WIN
LOSE_POINT  EQU 8      POINTS DEDUCTED ON A LOSS

MINE_LOC    EQU 100    USED BELOW FOR SOME SIMPLE COLLISION DETECTION USING CMP
                       * EXAMPLE FOR A HIT

*START OF GAME
START:
    MOVE.B  #100,$4003 PUT HEALTH IN MEMORY LOCATION $4000
    LEA     $4000,A3   ASSIGN ADDRESS A3 TO THAT MEMORY LOCATION
    
    MOVE.B  #0,$4010   PUT SCORE IN MEMORY LOCATION $4010
    LEA     $4010,A6   ASSIGN ADRESS A6 TO THAT MEMORY LOCATION

    BSR     WELCOME    BRANCH TO THE WELCOME SUBROUTINE
    BSR     GAME       BRANCH TO THE GAME SUBROUTINE
*GAME LOOP
    ORG     $3000      THE REST OF THE PROGRAM IS TO BE LOCATED FROM 3000 ONWARDS

*-------------------------------------------------------
*-------------------GAME SUBROUTINE---------------------
*-------------------------------------------------------
GAME:
    BSR     GAMELOOP   BRANCH TO GAMELOOP SUBROUTINE
    RTS                RETURN FROM GAME: SUBROUTINE
          
END:
    SIMHALT

*-------------------------------------------------------
*-------------------WELCOME SUBROUTINE------------------
*-------------------------------------------------------
WELCOME:
    BSR     ENDL            BRANCH TO ENDL SUBROUTINE
    LEA     WELCOME_MSG,A1  ASSIGN MESSAGE TO ADDRESS REGISTER A1
    MOVE.B  #14,D0          MOVE LITERAL 14 TO DO
    TRAP    #15             TRAP AND INTERPRET VALUE IN D0
    BSR     ENDL            BRANCH TO ENDL SUBROUTINE
    BSR     INPUT
    
    MOVE.B    #100,HEALTH     INITIALIZE HEALTH TO 100
    MOVE.B    HEALTH,D4       PLACE HEALTH IN DATA REGISTER 4
    MOVE.L    D4,(A3)         STORE DATA IN THE MEMORY LOCATION STORED IN ADRESS REGISTER 3
    
    MOVE.B    #0,SCORE
    MOVE.B    SCORE,D6
    MOVE.L    D6,(A6)
    
*    MOVE.B  #100,HEALTH
*    LEA     HEALTH,A3
*    
*    MOVE.B  #0,SCORE
*    LEA     SCORE,A6
    
    MOVE.B  #30,RABBITHEALTH
    LEA     RABBITHEALTH,A4
    
    RTS                     RETURN FROM WELCOME: SUBROUTINE

*-------------------------------------------------------
*---------GAMEPLAY INPUT VALUES SUBROUTINE--------------
*-------------------------------------------------------    
INPUT:
    BSR     POTIONS         BRANCH TO POTION INPUT SUBROUTINE
    BSR     WEAPONS         BRANCH TO WEAPONS INPUT SUBROUTINE
    RTS

*-------------------------------------------------------
*----------------GAMELOOP (MAIN LOOP)-------------------
*------------------------------------------------------- 
GAMELOOP:
    BSR     UPDATE          BRANCH TO UPDATE GAME SUBROUTINE 
    BSR     CLEAR_SCREEN    CLEARS THE SCREEN         
    BSR     DRAW            BRANCH TO DRAW SCREEN SUBROUTINE
    BSR     CLEAR_SCREEN    CLEARS THE SCREEN
    BSR     GAMEPLAY        BRANCH TO GAMEPLAY SUBROUTINE
    BSR     CLEAR_SCREEN    CLEARS THE SCREEN
    BSR     HUD             BRANCH TO DISPLAY HUD SUBROUTINE
    BSR     CLEAR_SCREEN    CLEARS THE SCREEN
    BSR     REPLAY          BRANCH TO REPLAY GAME SUBROUTINE
    BSR     CLEAR_SCREEN    CLEARS THE SCREEN
    RTS                     RETURN FROM GAMELOOP: SUBROUTINE

*-------------------------------------------------------
*----------------UPDATE QUEST PROGRESS------------------
*  COMPLETE QUEST
*------------------------------------------------------- 
UPDATE:
    BSR     ENDL            PRINT A CR AND LF
    RTS
*-------------------------------------------------------
*-----------------DRAW QUEST UPDATES--------------------
* DRAW THE GAME PROGRESS INFORMATION, STATUS REGARDING
* QUEST
*------------------------------------------------------- 
DRAW:
    BSR     ENDL
    BSR     DECORATE
    RTS

*--------------------------------------------------------
*--------------------POTIONS INVENTORY-------------------
* NUMBER OF POTIONS TO BE USED IN A QUEST 
*--------------------------------------------------------
POTIONS:
    BSR     ENDL
    BSR     DECORATE
    LEA     POTIONS_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0
    TRAP    #15
    
    CMP     #1,D1
    BLT     POTIONS
    
    CMP     #9,D1
    BGT     POTIONS
    
    MOVE.B  D1,$4500
    
    BSR     DECORATE
    RTS
*-------------------------------------------------------
*-------------------------WEAPONS-----------------------
* NUMBER OF WEAPONS
*-------------------------------------------------------   
WEAPONS:
    BSR     ENDL
    BSR     DECORATE
    LEA     WEAPONS_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    MOVE.B  #4,D0
    TRAP    #15
    BSR     DECORATE
    RTS

*-------------------------------------------------------
*---GAME PLAY (QUEST PROGRESS)--------------------------
*------------------------------------------------------- 
GAMEPLAY:
    MOVE.B  #4,D0
    TRAP    #15
    
    BSR     CLEAR_SCREEN

    BSR     HUD    BRANCH INTO DISPLAY HUD
    
    BSR     RABBIT_HEALTH
    
    BSR     ENDL
    
    LEA     GAMEPLAY_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BSR     ENDL
    
    MOVE.B  #4,D0
    TRAP    #15
    
    CMP     #1,D1               CHECK IF INPUT IS LESS THAN 1
    BLT     ENTER_VALID_INPUT   IF NUMBER IS LESS THAN 1 THEN BRANCH
    
    CMP     #3,D1               CHECK IF INPUT IS GREATER THAN 3
    BGT     ENTER_VALID_INPUT   IF NUMBER IS GREATER THAN 3 THEN BRANCH
    
    CMP     #1,D1
    BEQ     PLAYER_ATTACK
    
    CMP     #2,D1
    BEQ     PLAYER_SHIELD
    
    CMP     #3,D1
    BEQ     PLAYER_USE_POTION
    
    RTS


PLAYER_ATTACK:
    BSR     DECORATE
    
    BSR     COLLISION
    
    BSR     ENDL
    
    BSR     RABBIT_ATTACKS
    
    BSR     DECORATE
    
    BSR     GAMEPLAY
    
    RTS
    
PLAYER_SHIELD:
    BSR     DECORATE
    
    BSR     TEXT_COLOUR_GREEN
    
    LEA     SHIELD_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BSR     TEXT_COLOUR_WHITE
    
    BSR     ENDL
    
    BSR     RABBIT_FAILS_ATTACK
    
    BSR     DECORATE
    
    BSR     GAMEPLAY

PLAYER_USE_POTION:
    BSR     DECORATE
    
    BSR     TEXT_COLOUR_GREEN

    LEA     USE_POTION_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BSR     TEXT_COLOUR_WHITE
    
    SUB.B   #1,$4500            SUBTRACT 1 POTION FROM INVENTORY
    
    ADD     #$1E,D4              SUBTRACT 10 (A IN HEX) FROM 100 (64 IN HEX) IN  DATA REGISTER 1
    MOVE.B  D4,$4003            PLACE NEW HEALTH IN MEMORY ADRESS 4003
    
    BSR     ENDL
    
    BSR     RABBIT_ATTACKS
    
    BSR     DECORATE
    
    BSR     GAMEPLAY
*-------------------------------------------------------
*-----------------HEADS UP DISPLAY (SCORE AND HEALTH)---
* RETRIEVES THE SCORE AND HEALTH FROM MEMORY LOCATION --
*-------------------------------------------------------   
HUD:
    LEA     HUD_MSG_SCORE,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    CLR     D1
    MOVE.L  (A6),D1     RETRIEVE THE VALUE A6 POINT TO AND MOVE TO D1
    MOVE.B  #3,D0       MOVE LITERAL 3 TO D0
    TRAP    #15         INTREPRET VALUE IN D0, WHICH IS 3 SO DISPLAYS D1
    
    BSR     ENDL
    
    LEA     HUD_MSG_HEALTH,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.L  (A3),D1     RETRIEVE THE VALUE A3 POINT TO AND MOVE TO D1
    MOVE.B  #3,D0       MOVE LITERAL 3 TO D0
    TRAP    #15         INTREPRET VALUE IN D0, WHICH IS 3 SO DISPLAYS D1
    
    BSR     ENDL
    
    LEA     POTIONS_AMOUNT_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  $4500,D1
    MOVE.B  #3,D0
    TRAP    #15
    
    BSR     DECORATE
    RTS
    
    
*-------------------------------------------------------
*-----------------REQUEST VALID INPUT-------------------
* ASKS PLAYER TO ENTER A VALID NUMBER-------------------
*-------------------------------------------------------  
ENTER_VALID_INPUT:
    BSR     DECORATE
    
    BSR     TEXT_COLOUR_RED
    
    LEA     INVALID_INPUT,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    BSR     TEXT_COLOUR_WHITE
    
    BSR     DECORATE

    BSR     GAMEPLAY
*-------------------------------------------------------
*-----------------------BEING ATTACKED------------------
* THIS COULD BE USED FOR COLLISION DETECTION
*-------------------------------------------------------
COLLISION:
    MOVE.B  #MINE_LOC,D1
    CMP     #100,D1           IS( X == 100)?
	BNE     COLLISION_MISS    IF X IS EQUAL TO 100, THEN HIT
COLLISION_HIT:
    *HIT
    BSR     TEXT_COLOUR_GREEN
    
    LEA     HIT_MSG,A1        LOAD STRIKE MESSAGE
    MOVE    #14,D0            TRAP TASK 14
    TRAP    #15
    
    MOVE.B  (A4),D7
    SUB.B   #$A,D7
    MOVE.B  D7,(A4)
    
    BSR     TEXT_COLOUR_WHITE
    
    RTS
    
COLLISION_MISS:
    *MISS
    LEA     MISS_MSG,A1
    MOVE    #14,D0
    TRAP    #15
    RTS

*-------------------------------------------------------
*--------------------------RABBIT-----------------------
*-------------------------------------------------------
RABBIT_ATTACKS:
    BSR     TEXT_COLOUR_RED
    
    LEA     RABBITSUCCESFULATTACK_MSG,A1    LOAD MESSAGE
    MOVE.B  #14,D0                          TRAP TASK 14
    TRAP    #15                             EXECUTE
    
    BSR     TEXT_COLOUR_WHITE
    
    SUB     #$A,D4            SUBTRACT 10 (A IN HEX) FROM 100 (64 IN HEX) IN  DATA REGISTER 1
    MOVE.B  D4,$4003          PLACE NEW HEALTH IN MEMORY ADRESS 4003
    
    RTS

RABBIT_FAILS_ATTACK:
    BSR     TEXT_COLOUR_GREY
    
    LEA     RABBITFAILATTACK_MSG,A1         LOAD MESSAGE
    MOVE.B  #14,D0                          TRAP TASK 14
    TRAP    #15                             EXECUTE
    
    BSR     TEXT_COLOUR_WHITE
    
    RTS

RABBIT_HEALTH:
    LEA     RABBIT_HEALTH_MSG,A1            LOAD MESSAGE
    MOVE.B  #14,D0                          TRAP TASK 14
    TRAP    #15                             EXECUTE
    
    MOVE.L  D7,D1     RETRIEVE THE VALUE A3 POINT TO AND MOVE TO D1
    MOVE.B  #3,D0       MOVE LITERAL 3 TO D0
    TRAP    #15         INTREPRET VALUE IN D0, WHICH IS 3 SO DISPLAYS D1
*-------------------------------------------------------
*--------------------------LOOP-------------------------
*-------------------------------------------------------
LOOP:
    MOVE.B  #5, D3 LOOP COUNTER D3=5
NEXT:
    LEA     LOOP_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
	SUB     #1,D3   DECREMENT LOOP COUNTER
    BNE     NEXT    REPEAT UNTIL D0=0

*-------------------------------------------------------
*------------------SCREEN DECORATION--------------------
*-------------------------------------------------------
DECORATE:
    MOVE.B  #60, D3
    BSR     ENDL
OUT:
    LEA     LOOP_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
	SUB     #1,D3                           DECREMENT LOOP COUNTER
    BNE     OUT	                            REPEAT UNTIL D0=0
    BSR     ENDL
    RTS
    
CLEAR_SCREEN: 
    MOVE.B  #11,D0                          CLEAR SCREEN
    MOVE.W  #$FF00,D1
    TRAP    #15
    RTS
    
TEXT_COLOUR_RED:
    MOVE.l  #$0000FF,D1                     SET TEXT COLOUR TO RED
    MOVE    #21,D0                          TRAP TASK 21
    TRAP    #15                             EXECUTE
    RTS

TEXT_COLOUR_GREEN:
    MOVE.l  #$00FF00,D1                     SET FONT COLOUR TO GREEN
    MOVE    #21,D0                          TRAP TASK 21
    TRAP    #15
    RTS
    
TEXT_COLOUR_WHITE:
    MOVE.l  #$FFFFFF,D1                     SET COLOUR BACK TO WHITE
    MOVE    #21,D0                          TRAP TASK 21
    TRAP    #15                             EXECUTE
    RTS
TEXT_COLOUR_GREY:
    MOVE.l  #$666666,D1                     SET COLOUR BACK TO WHITE
    MOVE    #21,D0                          TRAP TASK 21
    TRAP    #15                             EXECUTE
    RTS
*-------------------------------------------------------
*------------------------REPLAY-------------------------
*-------------------------------------------------------
REPLAY:
    BSR     ENDL
    LEA     REPLAY_MSG,A1
    MOVE.B  #14,D0
    TRAP    #15
    
    MOVE.B  #4,D0
    TRAP    #15

    CMP     #EXIT,D1
    BEQ     END         IF SR Z REGISTER CONTAINS 1 BEQ => BRANCH EQUALS
    BSR     GAMELOOP

ENDL:
    MOVEM.L D0/A1,-(A7)
    MOVE    #14,D0
    LEA     CRLF,A1
    TRAP    #15
    MOVEM.L (A7)+,D0/A1
    RTS
    
*-------------------------------------------------------
*-------------------DATA DELARATIONS--------------------
*-------------------------------------------------------

CRLF:           DC.B    $0D,$0A,0
WELCOME_MSG:    DC.B    '************************************************************'
                DC.B    $0D,$0A
                DC.B    '                   WARRIOR ON A RAMPAGE'
                DC.B    $0D,$0A
                DC.B    '************************************************************'
                DC.B    $0D,$0A,0
POTION_MSG:     DC.B    'POTION ....'
                DC.B    $0D,$0A
                DC.B    'ENTER POTION : ',0
POTIONS_MSG:    DC.B    'NUMBER OF POTIONS : ',0
WEAPONS_MSG:    DC.B    'ENTER 1 FOR SPEER || ENTER 2 FOR SWORD'
                DC.B    $0D,$0A
                DC.B    'CHOOSE WEAPON: ',0
                
         *RABBIT MESSAGES
RABBITSUCCESFULATTACK_MSG:      DC.B    'RABBIT BITES YOU AND YOU LOOSE 10 HEALTH',0
RABBITFAILATTACK_MSG:           DC.B    'RABBIT BITES YOU BUY YOU SHIELDED , NO HEALTH LOST',0
GAMEPLAY_MSG:            DC.B    'YOU HAVE ENCOUNTERED "ANGRY RABBIT"'
                         DC.B    $0D,$0A
                         DC.B    'ENTER "1" TO ATTACK || ENTER "2" TO SHIELD || ENTER "3" TO USE POTION:  ',0
                
         *GAME PLAY MESSAGES
UPDATE_MSG:              DC.B    'UPDATE GAMEPLAY !',0
DRAW_MSG:                DC.B    'DRAW SCREEN !',0
HIT_MSG:                 DC.B    'STRIKE!',0
MISS_MSG:                DC.B    'MISS!',0
SHIELD_MSG:              DC.B    'SHIELD!',0
USE_POTION_MSG           DC.B    'USED POTION, GAINED BACK 30 HEALTH!',0
HEAL_MSG:                DC.B    'HEAL!',0
LOOP_MSG:                DC.B    '.',0
REPLAY_MSG:              DC.B    'ENTER 0 TO QUIT ANY OTHER NUMBER TO REPLAY : ',0
HUD_MSG_HEALTH:          DC.B    'PLAYER HEALTH: ',0
HUD_MSG_SCORE:           DC.B    'SCORE: ',0
RABBIT_HEALTH_MSG:       DC.B    'RABBIT HEALTH: ',0
SHOP_MSG:                DC.B    'WOULD YOU LIKE TO BUY POTIONS?'
                         DC.B    $0D,$0A
                         DC.B    'ENTER "1" IF YES , ANY OTHER NUMBER FOR NO',0
INVALID_INPUT:           DC.B    'ENTER A VALID NUMBER',0
POTIONS_AMOUNT_MSG       DC.B    'POTIONS LEFT: ',0
         *PLAYER AND ENEMY VARIABLES
HEALTH:                  DS.W    1   PLAYERS HEALTH

RABBITHEALTH:            DS.W    1   RABBITS HEALTH

SCORE:                   DS.W    1   RESERVE SPACE FOR SCORE

XP:                      DS.W    1   RESERVE SPACE FOR COINS

    END START








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
