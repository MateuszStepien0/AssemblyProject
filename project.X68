    org $1000

*----------------------------------------------------------
*Name:  Mateusz Stepien
*ID:    C00230799
*Date:  Jan-April
*Desc:  A game based on ZorkQuest: Assault on Egreth Castle
*----------------------------------------------------------

*-------------------------------------------------------
*Validation values to be used, modify as needed
*Add additional validation values as required
*-------------------------------------------------------
exit        EQU 0      used to exit assembly program
max_feed    EQU 100    max amount of money allowed to spend on feed
max_horses  EQU 10     max number of horses
max_stablemen   EQU 5  max number of stablemen allowed
max_knights EQU 10     min soldiers


*Start of Game
start:
    move.w  #100,$4000 put score/health in memory location $4000
    lea     $4000,A3   assign address A3 to that memory location
    move.w  #400,gold_amnt
    
    bsr     welcome    branch to the welcome subroutine
    bsr     input      branch to the input subroutine
    bsr     game       branch to the game subroutine
*Game loop
    org     $3000      the rest of the program is to be located from 3000 onwards

setup_game:
    clr     d1
    rts
*-------------------------------------------------------
*-------------------Game Subroutine---------------------
*-------------------------------------------------------
game:
    bsr     gameloop   branch to gameloop subroutine
    rts                return from game: subroutine
          
end:
    simhalt

*-------------------------------------------------------
*-------------------Welcome Subroutine------------------
*-------------------------------------------------------
welcome:
    bsr     endl            branch to endl subroutine
    lea     welcome_msg,A1  assign message to address register A1
    move.w  #14,D0          move literal 14 to DO
    trap    #15             trap and interpret value in D0
    bsr     endl            branch to endl subroutine
    rts                     return from welcome: subroutine

*-------------------------------------------------------
*---------Gameplay Input Values Subroutine--------------
*-------------------------------------------------------    
input:
    bsr     setup_game
    bsr     start_game          branch to castle choice subroutine
   * bsr     feed            branch to feed input subroutine
   * bsr     horses          branch to ship input subroutine
   * bsr     rate            branch to rate (charging speed) input subroutine
   * bsr     distance        branch to mission distance/location input subroutine
   * bsr     soldiers        branch to soldiers input subroutine
    rts

*-------------------------------------------------------
*----------------Gameloop (main loop)-------------------
*------------------------------------------------------- 
gameloop:
    bsr     update          branch to update game subroutine 
    bsr     clear_screen    clears the screen         
    bsr     draw            branch to draw screen subroutine
    bsr     clear_screen    clears the screen
    bsr     gameplay        branch to gameplay subroutine
    bsr     clear_screen    clears the screen
    bsr     hud             branch to display HUD subroutine
    bsr     clear_screen    clears the screen
    bsr     replay          branch to replay game subroutine
    bsr     clear_screen    clears the screen
    rts                     return from gameloop: subroutine

*-------------------------------------------------------
*---------------Update Mission Progress-----------------
*  Move to battle location, engage enemy, fire and take
*  fire, complete mission and return to base
*------------------------------------------------------- 
update:
    bsr     endl            print a CR and LF
    bsr     decorate        decorate with dots using a loop
    lea     update_msg,A1   
    move.w  #14,D0
    trap    #15
    bsr     decorate
    rts
*-------------------------------------------------------
*---------------Draw Mission Updates--------------------
* Draw the game progress information, status regarding
* mission
*------------------------------------------------------- 
draw:
    bsr     endl
    bsr     decorate
    lea     draw_msg,A1
    move.w  #14,D0
    trap    #15
    bsr     decorate
    rts
   
*-------------------------------------------------------
*--------------------Stats Output-----------------------
* Outputs various stats like gold, horses to the screen
*------------------------------------------------------- 
output_stats:
    lea     gold_info,a1    *loads gold to a1
    move.w  gold_amnt,d1    *loads gold amount to d1
    move.w  #17,d0
    trap    #15             *outputs to screen
    lea     crlf,a1
    move.w  #13,d0
    trap    #15
    lea     feed_info,a1    *loads feed to a1
    move.w  feed_amnt,d1    *loads feed amount to d1
    move.w  #17,d0
    trap    #15
    lea     crlf,a1
    move.w  #13,d0
    trap    #15
    lea     horse_info,a1   *loads horses to a1
    move.w  horse_amnt,d1   *loads horse amount to d1
    move.w  #17,d0
    trap    #15
    lea     crlf,a1
    move.w  #13,d0
    trap    #15
    lea     knight_info,a1   *loads knights to a1
    move.w  knight_amnt,d1   *loads knight amount to d1
    move.w  #17,d0
    trap    #15
    lea     crlf,a1
    move.w  #13,d0
    trap    #15
    lea     stablemen_info,a1   *loads stablemen to a1
    move.w  stablemen_amnt,d1   *loads stablemen amount to d1
    move.w  #17,d0
    trap    #15
    lea     crlf,a1
    move.w  #13,d0
    trap    #15
     
    rts
   
*-------------------------------------------------------
*-----------------Start of the game---------------------
* start of the game in the market, where player buys
* feed, horses, stablemen and knights to then move out
*-------------------------------------------------------  
start_game:
    move.w  #23,D0
    move.l  #100,D1
    trap    #15
    bsr     clear_screen
    clr     d1
    bsr     endl
    bsr     decorate
    bsr     output_stats
    lea     start_msg,A1
    clr     D1
    move.w  #14,D0
    trap    #15
    move.w  #98,D2
    move.w  #102,D3
    move.w  #104,D4
    move.w  #115,D5
    move.w  #5,D0
    trap    #15
    cmp     D1,D2
    beq     knights  
    cmp     D1,D3
    beq     feed
    cmp     D1,D4
    beq     stablemen
    cmp     D1,D5
    beq     horses
    
*-------------------------------------------------------
*-----------------------Horse feed-----------------------
* Buy the feed load for each horse. Feed costs money
*------------------------------------------------------- 
feed:
    move.w  #23,D0
    move.w  #100,D1
    trap    #15
    bsr     clear_screen
    clr     d1
    bsr     endl
    bsr     decorate
    bsr     output_stats
    lea     feed_msg,A1
    move.w  #14,D0
    trap    #15
    move.w  #4, D0
    trap    #15
    cmp     #0,D1
    beq     start_game
    move.w  d1,d4
    cmp     #100,d4
    bgt     feed_error
    cmp     #0,d4
    blt     feed_error
    move.w  d4,d5
    cmp     #max_feed,d5
    bgt     feed_error
    mulu.w  #20,d5
    cmp     gold_amnt,d4
    bgt     feed_error
    sub.w   d4,gold_amnt
    add.w   d5,feed_amnt

    bra     feed
    bsr     decorate
    rts

*-------------------------------------------------------
*-------------------------Horses------------------------
* Number of horses bought 
*------------------------------------------------------- 
horses:
    move.w  #23,D0
    move.w  #100,D1
    trap    #15
    bsr     clear_screen
    clr     d1
    bsr     endl
    bsr     decorate
    bsr     output_stats
    lea     horses_msg,A1
    move.w  #14,D0
    trap    #15
    move.w  #4, D0
    trap    #15
    cmp     #0,D1
    beq     start_game
    move.w  d1,d4
    cmp     #100,d4
    bgt     horses_error
    cmp     #0,d4
    blt     horses_error
    move.w  d4,d5
    cmp     #max_horses,d5
    bgt     horses_error
    mulu.w  #20,d4
    cmp     gold_amnt,d4
    bgt     horses_error
    sub.w   d4,gold_amnt
    add.w   d5,horse_amnt
    
    bra     horses
    bsr     decorate
    rts

*-------------------------------------------------------
*----------------------Stablemen------------------------
* Stablemen to take care of horses
*------------------------------------------------------- 
stablemen:
    move.w  #23,D0
    move.w  #100,D1
    trap    #15
    bsr     clear_screen
    clr     d1
    bsr     endl
    bsr     decorate
    bsr     output_stats
    lea     stablemen_msg,A1
    move.w  #14,D0
    trap    #15
    move.w  #4, D0
    trap    #15
    cmp     #0,D1
    beq     start_game
    move.w  d1,d4
    cmp     #100,d4
    bgt     stablemen_error
    cmp     #0,d4
    blt     stablemen_error
    move.w  d4,d5
    cmp     #max_stablemen,d5
    bgt     stablemen_error
    mulu.w  #15,d4
    cmp     gold_amnt,d4
    bgt     stablemen_error
    sub.w   d4,gold_amnt
    add.w   d5,stablemen_amnt
    
    bra     stablemen
    bsr     decorate
    rts

*-------------------------------------------------------
*------------------Mission Distance---------------------
* Distance to battle location
*------------------------------------------------------- 
distance:
    bsr     endl
    bsr     decorate
    lea     distance_msg,A1
    move.w  #14,D0
    trap    #15
    move.w  #4, D0
    trap    #15
    bsr     decorate
    rts

*-------------------------------------------------------
*-----------------------Knights-------------------------
* Number of knights
*-------------------------------------------------------   
knights:
    move.w  #23,D0
    move.w  #100,D1
    trap    #15
    bsr     clear_screen
    clr     d1
    bsr     endl
    bsr     decorate
    bsr     output_stats
    lea     soldiers_msg,A1
    move.w  #14,D0
    trap    #15
    move.w  #4, D0
    trap    #15
    cmp     #0,D1
    beq     start_game
    move.w  d1,d4
    cmp     #100,d4
    bgt     knight_error
    cmp     #0,d4
    blt     knight_error
    move.w  d4,d5
    cmp     #max_knights,d5
    bgt     knight_error
    mulu.w  #30,d4
    cmp     gold_amnt,d4
    bgt     knight_error
    sub.w   d4,gold_amnt
    add.w   d5,knight_amnt
    
    bra     knights
    bsr     decorate
    rts

*-------------------------------------------------------
*------------------Data Boundary Check------------------
*------------------------------------------------------- 
boundary_check:
    lea     boundary_msg,a1
    move    #13,d0
    trap    #15
    rts

horses_error:
    bsr     boundary_check
    jmp     horses
    
feed_error:
    bsr     boundary_check
    jmp     feed
    
knight_error:
    bsr     boundary_check
    jmp     knights
    
stablemen_error:
    bsr     boundary_check
    jmp     stablemen
*-------------------------------------------------------
*---Game Play (Mission Progress, Battle Maneuvers)------
*------------------------------------------------------- 
gameplay:
    bsr     endl
    bsr     decorate
    lea     gameplay_msg,A1
    move.w  #14,D0
    trap    #15
    bsr     decorate
    bsr     collision
    rts

*-------------------------------------------------------
*-----------------Heads Up Display (Score)--------------
* Retrieves the score from memory location
*-------------------------------------------------------   
hud:

    bsr     endl
    bsr     decorate
    lea     hud_msg,A1
    move.w  #14,D0
    trap    #15
    move.w  (A3),D1     retrieve the value A3 point to and move to D1
    move.w  #3,D0       move literal 3 to D0
    trap    #15         intrepret value in D0, which 3 which displays D1
    bsr     decorate
    rts

*-------------------------------------------------------
*-----------------------Taking Fire---------------------
* This could be used for collision detection, if 
*-------------------------------------------------------
collision:
    move.w  #mine_loc,D1
    cmp     #100,D1 is( x == 100)?
	bne     collision_miss if x is equal to 100, then hit
collision_hit:
    *hit
    lea     hit_msg,A1
    move    #14,D0
    trap    #15
    rts
    
collision_miss:
    *miss
    lea     miss_msg,A1
    move    #14,D0
    trap    #15
    rts
    
*-------------------------------------------------------
*--------------------------Loop-------------------------
*-------------------------------------------------------
loop:
    move.w  #5, D3 loop counter D3=5
next:
    lea     loop_msg,A1
    move.w  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
    bne     next    repeat until D0=0

*-------------------------------------------------------
*------------------Screen Decoration--------------------
*-------------------------------------------------------
decorate:
    move.w  #60, D3
    bsr     endl
out:
    lea     loop_msg,A1
    move.w  #14,D0
    trap    #15
	sub     #1,D3   decrement loop counter
    bne     out	    repeat until D0=0
    bsr     endl
    rts
    
clear_screen: 
    move.w  #11,D0      clear screen
    move.w  #$ff00,D1
    trap    #15
    rts
*-------------------------------------------------------
*------------------------Replay-------------------------
*-------------------------------------------------------
replay:
    bsr     endl
    lea     replay_msg,A1
    move.w  #14,D0
    trap    #15
    
    move.w  #4,D0
    trap    #15

    cmp     #exit,D1
    beq     end         if SR Z register contains 1 beq => Branch Equals
    bsr     gameloop

endl:
    movem.l D0/A1,-(A7)
    move    #14,D0
    lea     crlf,A1
    trap    #15
    movem.l (A7)+,D0/A1
    rts
    
*-------------------------------------------------------
*-------------------Data Delarations--------------------
*-------------------------------------------------------

crlf:           dc.b    $0D,$0A,0
welcome_msg:    dc.b    '************************************************************'
                dc.b    $0D,$0A
                dc.b    'SortOfZorkQuest: Assault on Egreth Castle'
                dc.b    $0D,$0A
                dc.b    '************************************************************'
                dc.b    $0D,$0A,0
gold_info       dc.b    'Gold you currently have : ',0
feed_info       dc.b    'Feed you currently have : ',0
horse_info      dc.b    'Horses you currently have : ',0
knight_info     dc.b    'Knights you currently have : ',0
stablemen_info  dc.b    'Stablemen you currently have : ',0
                dc.b    $0D,$0A
                dc.b    '************************************************************',0
start_msg       dc.b    'You are currently in the market.'
                dc.b    $0D,$0A
                dc.b    'You can go buy [F]eed, go to the [S]table to buy horses,'
                dc.b    $0D,$0A
                dc.b    'Farm[H]ouse to buy stablehands or [B]arracks to buy knights.'
                dc.b    $0D,$0A
                dc.b    'Choice : ',0
choice_msg:     dc.b    'Which castle will you head to? ([N]orth, [E]ast or [W]est)'
                dc.b    $0D,$0A
                dc.b    'Direction : ',0
feed_msg:       dc.b    'Feed costs 1 gold per 20 units of feed.'
                dc.b    $0D,$0A
                dc.b    'A horse uses 2 units of feed per kilometre.'
                dc.b    $0D,$0A
                dc.b    'Enter amount of money spent for feed, or 0 to go back to the market.'
                dc.b    $0D,$0A
                dc.b    'Amount of feed : ',0
horses_msg:     dc.b    'One horse costs 20 gold.'
                dc.b    $0D,$0A
                dc.b    'Each horse must be accompanied with a knight and a stableman'
                dc.b    $0D,$0A
                dc.b    'Enter amount of horses you want to buy, or 0 to go back to the market.'
                dc.b    $0D,$0A
                dc.b    'Amount of horses : ',0
stablemen_msg:  dc.b    'One Stableman costs 15 gold.'
                dc.b    $0D,$0A
                dc.b    'A stableman can take care of 2 horses at once.'
                dc.b    $0D,$0A
                dc.b    'Enter amount of stablemen you want to buy, or 0 to go back to the market.'
                dc.b    $0D,$0A
                dc.b    'Amount of stablemen : ',0
distance_msg:   dc.b    'Mission distance e.g. 40 (with 100 units of feed  '
                dc.b    $0D,$0A
                dc.b    'One Third speed 20 units remain for manuvouirs) horses '
                dc.b    $0D,$0A
                dc.b    'Horses without feed are lost.'
                dc.b    $0D,$0A
                dc.b    'Enter mission distance : ',0
soldiers_msg:   dc.b    'Each knight is 30 gold.'
                dc.b    $0D,$0A
                dc.b    'Each knight has to be assigned to a horse.'
                dc.b    $0D,$0A
                dc.b    'Enter no. of knights you want to buy, or 0 to go back to the market.'
                dc.b    $0D,$0A
                dc.b    'Amount of knights : ',0
boundary_msg   dc.b    'Out of bounds, please change your choice!'
gameplay_msg:   dc.b    'Add Gameplay !',0
update_msg:     dc.b    'Update Gameplay !',0
draw_msg:       dc.b    'Draw Screen !',0
hit_msg:        dc.b    'Strike!',0
miss_msg:       dc.b    'Miss!',0
loop_msg:       dc.b    '.',0
replay_msg:     dc.b    'Enter 0 to Quit any other number to replay : ',0
hud_msg:        dc.b    'Score : ',0

health:     ds.w    1
score:      ds.w    1 reserve space for score
feed_amnt:          dc.w    0
gold_amnt:          dc.w    0
horse_amnt:         dc.w    0
stablemen_amnt:     dc.w    0
knight_amnt:        dc.w    0


    end start




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
