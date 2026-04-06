MESSAGING-MENU.
           MOVE "N" TO WS-EXIT-MSG-MENU.

           PERFORM UNTIL WS-EXIT-MSG-MENU = "Y"
               MOVE " " TO WS-OUT-LINE
               PERFORM PRINT-LINE
               MOVE "--- Messages Menu ---" TO WS-OUT-LINE
               PERFORM PRINT-LINE
               MOVE "1. Send a New Message" TO WS-OUT-LINE
               PERFORM PRINT-LINE
               MOVE "2. View My Messages" TO WS-OUT-LINE
               PERFORM PRINT-LINE
               MOVE "3. Back to Main Menu" TO WS-OUT-LINE
               PERFORM PRINT-LINE

               MOVE "Enter your choice: " TO WS-PROMPT
               PERFORM PRINT-PROMPT-AND-READ

               EVALUATE WS-TOKEN
                   WHEN "1"
                       PERFORM SEND-MESSAGE-FLOW
                   WHEN "2"
                       PERFORM VIEW-MY-MESSAGES
                   WHEN "3"
                       MOVE "Y" TO WS-EXIT-MSG-MENU
                   WHEN OTHER
                       MOVE "Invalid choice. Please enter 1, 2, or 3."
                           TO WS-OUT-LINE
                       PERFORM PRINT-LINE
               END-EVALUATE
           END-PERFORM.


 CHECK-CONNECTION-VALIDITY.
           MOVE "N" TO WS-CONNECTION-FOUND.
           MOVE "N" TO WS-CONN-EOF.
           
           OPEN INPUT CONN-FILE.
           
           PERFORM UNTIL WS-CONN-EOF = "Y" OR WS-CONNECTION-FOUND = "Y"
               READ CONN-FILE
                   AT END
                       MOVE "Y" TO WS-CONN-EOF
                   NOT AT END
                       *> Check both directions of the connection
                       IF (CONN-SENDER = WS-CURR-USER AND
                           CONN-RECIPIENT = WS-MSG-RECIPIENT) OR
                          (CONN-SENDER = WS-MSG-RECIPIENT AND
                           CONN-RECIPIENT = WS-CURR-USER)
                           
                           *> Requirement: Must be an ACCEPTED connection
                           IF CONN-STATUS = "ACCEPTED"
                               MOVE "Y" TO WS-CONNECTION-FOUND
                           END-IF
                       END-IF
               END-READ
           END-PERFORM.
           
           CLOSE CONN-FILE.

SEND-MESSAGE-FLOW.
           MOVE "Enter recipient's username (must be a connection):" TO WS-OUT-LINE
           PERFORM PRINT-LINE.
           
           MOVE " " TO WS-PROMPT.
           PERFORM PRINT-PROMPT-AND-READ.
           *> Reject blank username
           IF FUNCTION TRIM(WS-TOKEN, TRAILING) = SPACES
               MOVE "Error: Username cannot be blank." TO WS-OUT-LINE
               PERFORM PRINT-LINE
               EXIT PARAGRAPH
           END-IF.

           *> Reject input longer than 20 characters (overflow guard)
           IF FUNCTION LENGTH(FUNCTION TRIM(WS-TOKEN, TRAILING)) > 20
               MOVE "Error: Username cannot exceed 20 characters." TO WS-OUT-LINE
               PERFORM PRINT-LINE
               EXIT PARAGRAPH
           END-IF.

           MOVE WS-TOKEN TO WS-MSG-RECIPIENT.

           *> Reject purely numeric usernames
           IF FUNCTION TRIM(WS-MSG-RECIPIENT, TRAILING) IS NUMERIC
               MOVE "Error: Username cannot be purely numeric." TO WS-OUT-LINE
               PERFORM PRINT-LINE
               EXIT PARAGRAPH
           END-IF.

           *> Trigger the Gatekeeper
           PERFORM CHECK-CONNECTION-VALIDITY.

           IF WS-CONNECTION-FOUND = "Y"
               PERFORM GET-MESSAGE-CONTENT
           ELSE
               MOVE "Error: You can only message users you are connected with." TO WS-OUT-LINE
               PERFORM PRINT-LINE
           END-IF.

GET-MESSAGE-CONTENT.
           MOVE "Enter your message (max 200 chars):" TO WS-PROMPT
           MOVE "X" TO WS-DEST-KIND
           PERFORM PRINT-PROMPT-AND-READ

           IF FUNCTION TRIM(WS-TOKEN, TRAILING) = SPACES
               MOVE "Error: Message cannot be blank." TO WS-OUT-LINE
               PERFORM PRINT-LINE
               EXIT PARAGRAPH
           END-IF

           MOVE WS-TOKEN TO WS-MSG-CONTENT
           PERFORM SAVE-MESSAGE

           MOVE SPACES TO WS-OUT-LINE
           STRING "Message sent to "
                  FUNCTION TRIM(WS-MSG-RECIPIENT)
                  " successfully!"
             INTO WS-OUT-LINE
           END-STRING
           PERFORM PRINT-LINE.

SAVE-MESSAGE.
           MOVE FUNCTION CURRENT-DATE TO WS-RAW-DATE

           MOVE SPACES TO WS-MSG-TIMESTAMP
           STRING WS-RAW-DATE(1:4) "-"
                  WS-RAW-DATE(5:2) "-"
                  WS-RAW-DATE(7:2) " "
                  WS-RAW-DATE(9:2) ":"
                  WS-RAW-DATE(11:2) ":"
                  WS-RAW-DATE(13:2)
             INTO WS-MSG-TIMESTAMP
           END-STRING

           OPEN EXTEND MESSAGE-FILE

           MOVE SPACES TO MESSAGE-REC
           STRING WS-CURR-USER DELIMITED BY SIZE
                  "|" DELIMITED BY SIZE
                  WS-MSG-RECIPIENT DELIMITED BY SIZE
                  "|" DELIMITED BY SIZE
                  WS-MSG-CONTENT DELIMITED BY SIZE
                  "|" DELIMITED BY SIZE
                  WS-MSG-TIMESTAMP DELIMITED BY SIZE
             INTO MESSAGE-REC
           END-STRING

           WRITE MESSAGE-REC
           CLOSE MESSAGE-FILE.
