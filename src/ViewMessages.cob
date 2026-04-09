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
                               MOVE MESSAGE-REC(265:4)   TO WS-MSG-VIEW-STATUS

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

                               MOVE SPACES TO WS-OUT-LINE
                               STRING "Status: "
                                      FUNCTION TRIM(WS-MSG-VIEW-STATUS,
                                                    TRAILING)
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
           ELSE
               PERFORM UPDATE-MESSAGE-STATUS
           END-IF

           MOVE "---------------------" TO WS-OUT-LINE
           PERFORM PRINT-LINE.

UPDATE-MESSAGE-STATUS.
           MOVE 0 TO WS-MSG-TEMP-COUNT
           MOVE "N" TO WS-MSG-VIEW-EOF

           OPEN INPUT MESSAGE-FILE
           PERFORM UNTIL WS-MSG-VIEW-EOF = "Y"
               READ MESSAGE-FILE
                   AT END
                       MOVE "Y" TO WS-MSG-VIEW-EOF
                   NOT AT END
                       IF MESSAGE-REC(1:20) NOT = SPACES
                           ADD 1 TO WS-MSG-TEMP-COUNT
                           MOVE MESSAGE-REC
                               TO WS-MSG-TEMP-REC(WS-MSG-TEMP-COUNT)
                           IF MESSAGE-REC(22:20) = WS-CURR-USER
                               MOVE "READ"
                                   TO WS-MSG-TEMP-REC(
                                      WS-MSG-TEMP-COUNT)(265:4)
                           END-IF
                       END-IF
               END-READ
           END-PERFORM
           CLOSE MESSAGE-FILE

           OPEN OUTPUT MESSAGE-FILE
           PERFORM VARYING WS-I FROM 1 BY 1
               UNTIL WS-I > WS-MSG-TEMP-COUNT
               MOVE WS-MSG-TEMP-REC(WS-I) TO MESSAGE-REC
               WRITE MESSAGE-REC
           END-PERFORM
           CLOSE MESSAGE-FILE.
