*> ViewRequests.cob - Copybook for viewing and managing pending requests
*> This code is meant to be COPYed into the main program

*> ---------------------------------------------------------------
*> VIEW-PENDING-REQUESTS
*>   Entry point called from POST-LOGIN-MENU (option 6).
*>   1. Loads all connection records into the in-memory table.
*>   2. For every PENDING record addressed to the current user,
*>      presents a 1-Accept / 2-Reject prompt.
*>   3. Rewrites the connections file: accepted entries become
*>      ACCEPTED; rejected entries are dropped entirely.
*> ---------------------------------------------------------------
VIEW-PENDING-REQUESTS.
    MOVE "--- Pending Connection Requests ---" TO WS-OUT-LINE
    PERFORM PRINT-LINE
    MOVE " " TO WS-OUT-LINE
    PERFORM PRINT-LINE

    PERFORM LOAD-ALL-CONNECTIONS

    MOVE 0 TO WS-CONN-REQUEST-COUNT

    PERFORM VARYING WS-CONN-IDX FROM 1 BY 1
        UNTIL WS-CONN-IDX > WS-CONN-COUNT
        IF WS-CRECIPIENT(WS-CONN-IDX) = WS-CURR-USER
           AND WS-CSTATUS(WS-CONN-IDX) = "PENDING"
            ADD 1 TO WS-CONN-REQUEST-COUNT
            PERFORM PROCESS-PENDING-REQUEST
        END-IF
    END-PERFORM

    IF WS-CONN-REQUEST-COUNT = 0
        MOVE "You have no pending connection requests." TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE " " TO WS-OUT-LINE
        PERFORM PRINT-LINE
    END-IF

    PERFORM SAVE-CONNECTIONS.

*> ---------------------------------------------------------------
*> LOAD-ALL-CONNECTIONS
*>   Reads every record in CONN-FILE into the WS-CONN-DATA table
*>   (up to 25 entries).  Safe when the file does not yet exist.
*> ---------------------------------------------------------------
LOAD-ALL-CONNECTIONS.
    MOVE 0 TO WS-CONN-COUNT
    MOVE 0 TO WS-CONN-EOF

    OPEN INPUT CONN-FILE

    IF WS-CONN-STATUS NOT = "00" AND WS-CONN-STATUS NOT = "35"
        MOVE "Error opening connections file." TO WS-OUT-LINE
        PERFORM PRINT-LINE
        CLOSE CONN-FILE
        EXIT PARAGRAPH
    END-IF

    *> Status 35 = file not found; nothing to load
    IF WS-CONN-STATUS = "35"
        EXIT PARAGRAPH
    END-IF

    PERFORM UNTIL WS-CONN-EOF = 1
        READ CONN-FILE
            AT END
                MOVE 1 TO WS-CONN-EOF
            NOT AT END
                IF WS-CONN-COUNT < 25
                    ADD 1 TO WS-CONN-COUNT
                    MOVE CONN-SENDER    TO WS-CSENDER(WS-CONN-COUNT)
                    MOVE CONN-RECIPIENT TO WS-CRECIPIENT(WS-CONN-COUNT)
                    MOVE CONN-STATUS    TO WS-CSTATUS(WS-CONN-COUNT)
                END-IF
        END-READ
    END-PERFORM

    CLOSE CONN-FILE.

*> ---------------------------------------------------------------
*> PROCESS-PENDING-REQUEST
*>   Handles a single pending request.  WS-CONN-IDX must point to
*>   the entry in WS-CONN-DATA being processed.
*>   Updates WS-CSTATUS to "ACCEPTED" or "REJECTED" in memory.
*> ---------------------------------------------------------------
PROCESS-PENDING-REQUEST.
    *> Show who sent the request (once, outside the retry loop)
    MOVE SPACES TO WS-OUT-LINE
    STRING "Request from: " DELIMITED BY SIZE
           WS-CSENDER(WS-CONN-IDX) DELIMITED BY " "
           INTO WS-OUT-LINE
    END-STRING
    PERFORM PRINT-LINE

    *> Loop until the user enters a valid choice (1 or 2)
    MOVE "N" TO WS-VALID
    PERFORM UNTIL WS-VALID = "Y"
        MOVE "1. Accept" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "2. Reject" TO WS-OUT-LINE
        PERFORM PRINT-LINE

        MOVE SPACES TO WS-PROMPT
        STRING "Enter your choice for " DELIMITED BY SIZE
               WS-CSENDER(WS-CONN-IDX) DELIMITED BY " "
               ":" DELIMITED BY SIZE
               INTO WS-PROMPT
        END-STRING
        MOVE "M" TO WS-DEST-KIND
        PERFORM PRINT-PROMPT-AND-READ

        *> Reject input that is not exactly one character (e.g. "10", "1ABCD")
        COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TOKEN))
        IF WS-LEN NOT = 1
            MOVE "Invalid choice. Please enter 1 or 2." TO WS-OUT-LINE
            PERFORM PRINT-LINE
        ELSE
            EVALUATE WS-MENU-CHOICE
                WHEN "1"
                    MOVE "ACCEPTED" TO WS-CSTATUS(WS-CONN-IDX)
                    MOVE SPACES TO WS-OUT-LINE
                    STRING "Connection request from " DELIMITED BY SIZE
                           WS-CSENDER(WS-CONN-IDX) DELIMITED BY " "
                           " accepted." DELIMITED BY SIZE
                           INTO WS-OUT-LINE
                    END-STRING
                    PERFORM PRINT-LINE
                    MOVE "Y" TO WS-VALID
                WHEN "2"
                    MOVE "REJECTED" TO WS-CSTATUS(WS-CONN-IDX)
                    MOVE SPACES TO WS-OUT-LINE
                    STRING "Connection request from " DELIMITED BY SIZE
                           WS-CSENDER(WS-CONN-IDX) DELIMITED BY " "
                           " rejected." DELIMITED BY SIZE
                           INTO WS-OUT-LINE
                    END-STRING
                    PERFORM PRINT-LINE
                    MOVE "Y" TO WS-VALID
                WHEN OTHER
                    MOVE "Invalid choice. Please enter 1 or 2." TO WS-OUT-LINE
                    PERFORM PRINT-LINE
            END-EVALUATE
        END-IF
    END-PERFORM.

*> ---------------------------------------------------------------
*> SAVE-CONNECTIONS
*>   Rewrites CONN-FILE from the in-memory table.
*>   Entries marked REJECTED are skipped (effectively deleted).
*>   All other entries (PENDING, ACCEPTED) are written back.
*>   Follows the same pipe-separator pattern as SendRequest.cob.
*> ---------------------------------------------------------------
SAVE-CONNECTIONS.
    OPEN OUTPUT CONN-FILE
    PERFORM VARYING WS-CONN-IDX FROM 1 BY 1
        UNTIL WS-CONN-IDX > WS-CONN-COUNT
        IF WS-CSTATUS(WS-CONN-IDX) NOT = "REJECTED"
            MOVE WS-CSENDER(WS-CONN-IDX)    TO CONN-SENDER
            MOVE WS-CRECIPIENT(WS-CONN-IDX) TO CONN-RECIPIENT
            MOVE WS-CSTATUS(WS-CONN-IDX)    TO CONN-STATUS
            MOVE "|" TO CONN-REC(21:1)
            MOVE "|" TO CONN-REC(42:1)
            WRITE CONN-REC
        END-IF
    END-PERFORM
    CLOSE CONN-FILE.
