VIEW-MY-MESSAGES.
           MOVE "N" TO WS-MSG-VIEW-EOF
           MOVE 0   TO WS-MSG-VIEW-COUNT

           OPEN INPUT MESSAGE-FILE

           MOVE "--- Your Messages ---" TO WS-OUT-LINE
           PERFORM PRINT-LINE

           PERFORM UNTIL WS-MSG-VIEW-EOF = "Y"
               READ MESSAGE-FILE
                   AT END
                       MOVE "Y" TO WS-MSG-VIEW-EOF
                   NOT AT END
                       *> Skip blank/seed records
                       IF MESSAGE-REC(1:20) NOT = SPACES
                           *> Recipient field: positions 22-41
                           IF MESSAGE-REC(22:20) = WS-CURR-USER
                               *> Print separator between messages
                               IF WS-MSG-VIEW-COUNT > 0
                                   MOVE "---" TO WS-OUT-LINE
                                   PERFORM PRINT-LINE
                               END-IF

                               ADD 1 TO WS-MSG-VIEW-COUNT

                               MOVE MESSAGE-REC(1:20)   TO WS-MSG-SENDER
                               MOVE MESSAGE-REC(43:200)  TO WS-MSG-VIEW-CONTENT
                               MOVE MESSAGE-REC(244:20)  TO WS-MSG-VIEW-TS

                               MOVE SPACES TO WS-OUT-LINE
                               STRING "From: "
                                      FUNCTION TRIM(WS-MSG-SENDER, TRAILING)
                                 INTO WS-OUT-LINE
                               END-STRING
                               PERFORM PRINT-LINE

                               MOVE SPACES TO WS-OUT-LINE
                               STRING "Message: "
                                      FUNCTION TRIM(WS-MSG-VIEW-CONTENT,
                                                    TRAILING)
                                 INTO WS-OUT-LINE
                               END-STRING
                               PERFORM PRINT-LINE

                               MOVE SPACES TO WS-OUT-LINE
                               STRING "Sent: "
                                      FUNCTION TRIM(WS-MSG-VIEW-TS, TRAILING)
                                 INTO WS-OUT-LINE
                               END-STRING
                               PERFORM PRINT-LINE
                           END-IF
                       END-IF
               END-READ
           END-PERFORM

           CLOSE MESSAGE-FILE

           IF WS-MSG-VIEW-COUNT = 0
               MOVE "You have no messages at this time." TO WS-OUT-LINE
               PERFORM PRINT-LINE
           END-IF

           MOVE "---------------------" TO WS-OUT-LINE
           PERFORM PRINT-LINE.
