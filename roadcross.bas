'#include "fbgfx.bi"
'Using FB

ScreenRes 400, 300, 8, 2
ScreenSet 1, 0 ' Work on page 1 while displaying page 0
RANDOMIZE, 1


'--------------------------------------
'=============-VARIABLES-==============
'--------------------------------------
TYPE truckType
    x AS SINGLE
    y AS INTEGER
    velo AS SINGLE
END TYPE

TYPE playerType
    x AS INTEGER
    y AS INTEGER
    score as INTEGER
    currentStatus AS STRING
END TYPE

TYPE passengerType
    x AS INTEGER
    y AS INTEGER
    waiting AS BOOLEAN
    dest AS STRING
    locationSet AS BOOLEAN
END TYPE

DIM trucks(6) AS truckType
DIM player AS playerType
DIM passenger AS passengerType
DIM playerImg AS Any Ptr = ImageCreate( 40, 30 )
DIM truckImg AS Any Ptr = ImageCreate( 80, 30 )
DIM passengerImg AS Any Ptr = ImageCreate( 20, 30 )

DIM key AS STRING
DIM colorID as Integer
DIM tmpRND AS SINGLE

'-------------------------------------------
'==============-INITIAL SETUP-==============
'-------------------------------------------
FOR i AS INTEGER = 1 to 6
    trucks(i).x = 399
    trucks(i).velo = RND + 0.3
'    IF trucks(i).velo > 1 THEN trucks(i).velo = 1
    IF i = 1 THEN 
        trucks(i).y = 90 
    ELSE
        trucks(i).y = trucks(i-1).y + 30
    END IF
NEXT

passenger.x = 30
passenger.y = 55
passenger.waiting = True
passenger.dest = "south"
passenger.locationSet = True

player.x = 30
player.y = 270
player.currentStatus = " passenger waiting"


'--------------------------------------
'================-LOOP-================
'--------------------------------------
DO
    key = INKEY

    IF key = CHR(255) + CHR(72) THEN ' <<UP>>
        player.y = player.y - 30
    END IF
    IF key = CHR(255) + CHR(80) THEN ' <<DOWN>>
        player.y = player.y + 30
    END IF
    IF key = CHR(255) + CHR(75) THEN ' <<LEFT>>
        player.x = player.x - 10
    END IF
    IF key = CHR(255) + CHR(77) THEN ' <<RIGHT>>
        player.x = player.x + 10
    END IF

    CLS
    BLOAD "background.bmp"
    BLOAD "player7.bmp", playerImg
    BLOAD "truck.bmp", truckImg
    BLOAD "passenger.bmp", passengerImg
    
    LOCATE 2,2
    COLOR 60,1
    PRINT "Score:"; 
    COLOR 24,1
    PRINT player.score
    LOCATE 4,2
    COLOR 60,1  
    PRINT "Status:";
    COLOR 24,1
    PRINT player.currentStatus
    '----------------------------Create new passenger-------------------------
    IF passenger.waiting = True THEN
        IF passenger.locationSet = False THEN

            '------- Randomize passenger Y position
            tmpRND = RND
            IF tmpRND > 0.5 THEN
                passenger.y = 270    
            ELSE
                passenger.y = 55
            END IF
            '-------------------------------------

            '---------- Randomize passenger X position
            DO
                tmpRND = RND
                tmpRND = tmpRND * (400-20)
                IF tmpRND > player.x-20 AND tmpRND < player.x+40 THEN
                    tmpRND = 2
                ELSE
                    passenger.x = tmpRND
                END IF
            LOOP UNTIL tmpRND <> 2
            '---------------------------------------

            passenger.locationSet = True
        END IF
        PUT (passenger.x, passenger.y), passengerImg, TRANS        
    END IF
    '--------------------------------------------------------------------

    PUT (player.x, player.y), playerImg, TRANS

    '------------- MOVE ALL TRUCKS -------------------
    FOR j AS INTEGER = 1 to 6
        trucks(j).x = trucks(j).x - trucks(j).velo
        IF (trucks(j).x < -80) THEN 
            trucks(j).x = 399
            trucks(j).velo = RND + 0.3  'Randomize truck speed
        END IF
        PUT (trucks(j).x, trucks(j).y), truckImg, TRANS
    NEXT
    '--------------------------------------------------

    '-------------- check COLLISION with TRUCK AND passenger
    FOR yi AS INTEGER = 1 to 30
        FOR xi AS INTEGER = 1 to 40
            '---- TRUCK Collision check -------
            IF POINT(player.x+xi, player.y+yi) = 51 THEN
            LOCATE 5,5
            COLOR 6
            PRINT "HIT"
            player.score -= 50
            player.currentStatus = " passenger waiting"
            passenger.waiting = True
            passenger.locationSet = False
            player.x = 50
            player.y = 270
            END IF
            '----------------------------------

            '--------passenger collision check-------
            IF POINT(player.x+xi, player.y+yi) = 3 THEN
                passenger.waiting = False
                IF player.y = 60 THEN
                    passenger.dest = "south"
                ELSE
                    passenger.dest = "north"
                END IF
                player.currentStatus = " destination is " + passenger.dest
            END IF
            '----------------------------------------

        NEXT
    NEXT
    '------------------------------------------------------

    '------------- passenger DELIVERY check--------------------
    IF player.y = 270 OR player.y = 60 THEN
        IF passenger.waiting = False THEN
            IF player.y = 270 AND passenger.dest = "south" THEN
                player.score += 10
                passenger.waiting = True
                passenger.locationSet = False
                player.currentStatus = " passenger waiting"
            END IF
            IF player.y = 60 AND passenger.dest = "north" THEN
                player.score += 10
                passenger.waiting = True
                passenger.locationSet = False
                player.currentStatus = " passenger waiting"
            END IF      
        END IF
    END IF
    '----------------------------------------------------------

    'ScreenControl(GET_TRANSPARENT_COLOR, colorID)
    'PRINT colorID
    ScreenSync    'Wait vert-sync
    ScreenCopy    'Copy work page to active display page

Loop While key <> CHR(27)

