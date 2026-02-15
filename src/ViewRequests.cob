*> ViewRequests.cob - Copybook for viewing pending requests
      *> This code is meant to be COPYed into the main program

VIEW-PENDING-REQUESTS.
    MOVE "----- PENDING CONNECTION REQUESTS -----" TO WS-OUT-LINE.
    PERFORM PRINT-LINE.
    MOVE " " TO WS-OUT-LINE.
    PERFORM PRINT-LINE.

    PERFORM READ-CONNECTION-REQUESTS.

    IF WS-CONN-REQUEST-COUNT = 0
        MOVE "You have no pending connection requests." TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE " " TO WS-OUT-LINE
        PERFORM PRINT-LINE
    ELSE
        MOVE SPACES TO WS-OUT-LINE
        STRING "Total pending requests: " DELIMITED BY SIZE
               WS-CONN-REQUEST-COUNT DELIMITED BY SIZE
               INTO WS-OUT-LINE
        END-STRING
        PERFORM PRINT-LINE
        MOVE "-------------------" TO WS-OUT-LINE
        PERFORM PRINT-LINE
    END-IF.

READ-CONNECTION-REQUESTS.
    OPEN INPUT CONN-FILE.

    IF WS-CONN-STATUS NOT = "00" AND WS-CONN-STATUS NOT = "35"
        MOVE "Error opening connections file." TO WS-OUT-LINE
        PERFORM PRINT-LINE
        CLOSE CONN-FILE
        EXIT PARAGRAPH
    END-IF.

    IF WS-CONN-STATUS = "35"
        *> File doesn't exist yet
        MOVE 0 TO WS-CONN-REQUEST-COUNT
        EXIT PARAGRAPH
    END-IF.

    MOVE 0 TO WS-CONN-EOF.
    MOVE 0 TO WS-CONN-REQUEST-COUNT.

    PERFORM UNTIL WS-CONN-EOF = 1
        READ CONN-FILE
            AT END
                MOVE 1 TO WS-CONN-EOF
            NOT AT END
                PERFORM PROCESS-ONE-CONNECTION-REQUEST
        END-READ
    END-PERFORM.

    CLOSE CONN-FILE.

PROCESS-ONE-CONNECTION-REQUEST.
    *> Check if this pending request is TO the current user
    IF CONN-RECIPIENT = WS-CURR-USER AND
       CONN-STATUS = "PENDING"
        ADD 1 TO WS-CONN-REQUEST-COUNT
        MOVE SPACES TO WS-OUT-LINE
        STRING "Request from: " DELIMITED BY SIZE
               CONN-SENDER DELIMITED BY " "
               INTO WS-OUT-LINE
        END-STRING
        PERFORM PRINT-LINE
        MOVE " " TO WS-OUT-LINE
        PERFORM PRINT-LINE
    END-IF.
    