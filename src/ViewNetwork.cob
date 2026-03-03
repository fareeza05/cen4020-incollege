*> ViewNetwork.cob - Copybook for displaying established network
*> This code is meant to be COPYed into the main program

VIEW-NETWORK.
    MOVE 0 TO WS-NET-COUNT
    MOVE "----- YOUR NETWORK -----" TO WS-OUT-LINE
    PERFORM PRINT-LINE
    MOVE " " TO WS-OUT-LINE
    PERFORM PRINT-LINE

    PERFORM READ-ESTABLISHED-CONNECTIONS

    IF WS-NET-COUNT = 0
        MOVE "You have no established connections in your network." TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE " " TO WS-OUT-LINE
        PERFORM PRINT-LINE
    END-IF

    MOVE "Press 'X' to return to menu." TO WS-PROMPT
    MOVE "X" TO WS-DEST-KIND
    PERFORM PRINT-PROMPT-AND-READ

    MOVE "------------------------" TO WS-OUT-LINE
    PERFORM PRINT-LINE
    .

READ-ESTABLISHED-CONNECTIONS.
    OPEN INPUT CONN-FILE

    IF WS-CONN-STATUS NOT = "00" AND WS-CONN-STATUS NOT = "35"
        MOVE "Error opening connections file." TO WS-OUT-LINE
        PERFORM PRINT-LINE
        CLOSE CONN-FILE
        EXIT PARAGRAPH
    END-IF

    IF WS-CONN-STATUS = "35"
        *> No connections file yet -> no network
        MOVE 0 TO WS-NET-COUNT
        EXIT PARAGRAPH
    END-IF

    MOVE 0 TO WS-CONN-EOF

    PERFORM UNTIL WS-CONN-EOF = 1
        READ CONN-FILE
            AT END
                MOVE 1 TO WS-CONN-EOF
            NOT AT END
                PERFORM PROCESS-ONE-NETWORK-ROW
        END-READ
    END-PERFORM

    CLOSE CONN-FILE
    .

PROCESS-ONE-NETWORK-ROW.
    *> Only consider established connections
    IF CONN-STATUS NOT = "ACCEPTED"
        EXIT PARAGRAPH
    END-IF

    *> Is the current user part of this connection?
    IF CONN-SENDER = WS-CURR-USER
        MOVE CONN-RECIPIENT TO WS-FRIEND-USER
    ELSE
        IF CONN-RECIPIENT = WS-CURR-USER
            MOVE CONN-SENDER TO WS-FRIEND-USER
        ELSE
            EXIT PARAGRAPH
        END-IF
    END-IF

    *> At this point, WS-FRIEND-USER holds the username of the connected user
    PERFORM FIND-FRIEND-PROFILE

    ADD 1 TO WS-NET-COUNT

    IF WS-FRIEND-IDX > 0
        *> We found a profile; print full info
        MOVE SPACES TO WS-OUT-LINE
        STRING "Connected with: "
               FUNCTION TRIM(WS-PROF-FNAME(WS-FRIEND-IDX)) " "
               FUNCTION TRIM(WS-PROF-LNAME(WS-FRIEND-IDX))
               " (University: "
               FUNCTION TRIM(WS-PROF-UNIV(WS-FRIEND-IDX))
               ", Major: "
               FUNCTION TRIM(WS-PROF-MAJOR(WS-FRIEND-IDX))
               ")"
          INTO WS-OUT-LINE
        END-STRING
        PERFORM PRINT-LINE
    ELSE
        *> No profile created yet; show username only
        MOVE SPACES TO WS-OUT-LINE
        STRING "Connected with username: "
               FUNCTION TRIM(WS-FRIEND-USER)
               " (no profile information available)"
          INTO WS-OUT-LINE
        END-STRING
        PERFORM PRINT-LINE
    END-IF

    MOVE " " TO WS-OUT-LINE
    PERFORM PRINT-LINE
    .

FIND-FRIEND-PROFILE.
    MOVE 0 TO WS-FRIEND-IDX
    PERFORM VARYING WS-I FROM 1 BY 1
        UNTIL WS-I > WS-PROF-COUNT OR WS-FRIEND-IDX > 0
        IF WS-PROF-USER(WS-I) = WS-FRIEND-USER
            MOVE WS-I TO WS-FRIEND-IDX
        END-IF
    END-PERFORM
    .
