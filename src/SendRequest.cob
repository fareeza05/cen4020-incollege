*> SendRequest.cob - Copybook for sending connection requests
      *> This code is meant to be COPYed into the main program

SEND-CONNECTION-REQUEST.
    MOVE "Y" TO WS-VALID

    PERFORM CHECK-CONNECTION-EXISTS

    IF WS-VALID = "N"
        EXIT PARAGRAPH
    END-IF

    *> Write new connection request
    OPEN EXTEND CONN-FILE
    MOVE WS-CURR-USER TO CONN-SENDER
    MOVE WS-PROF-USER(WS-SEARCH-IDX) TO CONN-RECIPIENT
    MOVE "PENDING" TO CONN-STATUS
    MOVE "|" TO CONN-REC(21:1)
    MOVE "|" TO CONN-REC(42:1)
    WRITE CONN-REC
    CLOSE CONN-FILE

    MOVE SPACES TO WS-OUT-LINE
    STRING "Connection request sent to "
           FUNCTION TRIM(WS-PROF-FNAME(WS-SEARCH-IDX)) " "
           FUNCTION TRIM(WS-PROF-LNAME(WS-SEARCH-IDX)) "."
      INTO WS-OUT-LINE
    END-STRING
    PERFORM PRINT-LINE.

CHECK-CONNECTION-EXISTS.
    OPEN INPUT CONN-FILE.

    IF WS-CONN-STATUS NOT = "00" AND WS-CONN-STATUS NOT = "35"
        MOVE "Error opening connections file." TO WS-OUT-LINE
        PERFORM PRINT-LINE
        CLOSE CONN-FILE
        MOVE "N" TO WS-VALID
        EXIT PARAGRAPH
    END-IF.

    IF WS-CONN-STATUS = "35"
        *> File doesn't exist yet, no connections
        EXIT PARAGRAPH
    END-IF.

    MOVE 0 TO WS-CONN-EOF.

    PERFORM UNTIL WS-CONN-EOF = 1
        READ CONN-FILE
            AT END
                MOVE 1 TO WS-CONN-EOF
            NOT AT END
                *> Check if we already sent them a pending request
                IF CONN-SENDER = WS-CURR-USER AND
                   CONN-RECIPIENT = WS-PROF-USER(WS-SEARCH-IDX)
                   AND CONN-STATUS = "PENDING"
                    MOVE "You have already sent a connection request to this user." TO WS-OUT-LINE
                    PERFORM PRINT-LINE
                    MOVE "N" TO WS-VALID
                    MOVE 1 TO WS-CONN-EOF
                END-IF
                *> Check if they already sent us a pending request
                IF CONN-SENDER = WS-PROF-USER(WS-SEARCH-IDX)
                   AND CONN-RECIPIENT = WS-CURR-USER
                   AND CONN-STATUS = "PENDING"
                    MOVE "This user has already sent you a connection request." TO WS-OUT-LINE
                    PERFORM PRINT-LINE
                    MOVE "N" TO WS-VALID
                    MOVE 1 TO WS-CONN-EOF
                END-IF
                *> Check if already connected
                IF (CONN-SENDER = WS-CURR-USER AND
                    CONN-RECIPIENT = WS-PROF-USER(WS-SEARCH-IDX)
                    AND CONN-STATUS = "ACCEPTED")
                    OR
                   (CONN-SENDER = WS-PROF-USER(WS-SEARCH-IDX)
                    AND CONN-RECIPIENT = WS-CURR-USER
                    AND CONN-STATUS = "ACCEPTED")
                    MOVE "You are already connected with this user." TO WS-OUT-LINE
                    PERFORM PRINT-LINE
                    MOVE "N" TO WS-VALID
                    MOVE 1 TO WS-CONN-EOF
                END-IF
        END-READ
    END-PERFORM.

    CLOSE CONN-FILE.
