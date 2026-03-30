MESSAGING-MENU.
           MOVE "N" TO WS-EXIT-MSG-MENU.
           
           PERFORM UNTIL WS-EXIT-MSG-MENU = "Y"
               DISPLAY " "
               DISPLAY "--- Messages Menu ---"
               DISPLAY "1. Send a New Message"
               DISPLAY "2. View My Messages"
               DISPLAY "3. Back to Main Menu"
               
               MOVE "Enter your choice: " TO WS-PROMPT
               PERFORM PRINT-PROMPT-AND-READ
               
               EVALUATE WS-TOKEN
                   WHEN "1"
                       PERFORM SEND-MESSAGE-FLOW
                   WHEN "2"
                       DISPLAY "View My Messages is under construction."
                   WHEN "3"
                       MOVE "Y" TO WS-EXIT-MSG-MENU
                   WHEN OTHER
                       DISPLAY "Invalid choice. Please enter 1, 2, or 3."
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
           MOVE WS-TOKEN TO WS-MSG-RECIPIENT.

           *> Trigger the Gatekeeper
           PERFORM CHECK-CONNECTION-VALIDITY.

           IF WS-CONNECTION-FOUND = "Y"
               *> Feature 3: This is where you'd call the content input
               MOVE "User is able to send a message to this connection." TO WS-OUT-LINE
               PERFORM PRINT-LINE
               *>PERFORM GET-MESSAGE-CONTENT
           ELSE
               MOVE "Error: You can only message users you are connected with." TO WS-OUT-LINE
               PERFORM PRINT-LINE
           END-IF.
