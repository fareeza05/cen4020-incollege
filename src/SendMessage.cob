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
                       DISPLAY "Pressing this will trigger send-message-flow."
                       *>PERFORM SEND-MESSAGE-FLOW
                   WHEN "2"
                       DISPLAY "View My Messages is under construction."
                   WHEN "3"
                       MOVE "Y" TO WS-EXIT-MSG-MENU
                   WHEN OTHER
                       DISPLAY "Invalid choice. Please enter 1, 2, or 3."
               END-EVALUATE
           END-PERFORM.
           