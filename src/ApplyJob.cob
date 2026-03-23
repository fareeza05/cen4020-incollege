*> Logic for applying to and viewing job listings

*> Browse jobs feature: display all jobs and allow user to select one for details
BROWSE-JOBS.
           MOVE "--- Available Job Listings ---" TO WS-OUT-LINE
           PERFORM PRINT-LINE
           
           MOVE 0 TO WS-DISPLAY-COUNT
           MOVE "N" TO WS-JOB-EOF
           
           OPEN INPUT JOB-FILE
           PERFORM UNTIL WS-JOB-EOF = "Y"
               READ JOB-FILE
                   AT END
                       MOVE "Y" TO WS-JOB-EOF
                   NOT AT END
                       ADD 1 TO WS-DISPLAY-COUNT
                       MOVE SPACES TO WS-OUT-LINE
                       STRING WS-DISPLAY-COUNT ". " 
                              FUNCTION TRIM(JOB-TITLE-FILE) " at " 
                              FUNCTION TRIM(JOB-EMPLOYER-FILE)
                         INTO WS-OUT-LINE
                       END-STRING
                       PERFORM PRINT-LINE
               END-READ
           END-PERFORM
           CLOSE JOB-FILE

           IF WS-DISPLAY-COUNT = 0
               MOVE "No jobs available." TO WS-OUT-LINE
               PERFORM PRINT-LINE
           ELSE
               PERFORM GET-SELECTION
           END-IF.

*> Helper function for browse jobs that prompts user to select a job for details
GET-SELECTION.
           MOVE "Enter job number to view details, or 0 to go back:" TO WS-PROMPT
           MOVE "N" TO WS-DEST-KIND
           PERFORM PRINT-PROMPT-AND-READ
           
           MOVE FUNCTION NUMVAL(WS-TOKEN) TO WS-USER-CHOICE

           IF WS-USER-CHOICE > 0 AND WS-USER-CHOICE <= WS-DISPLAY-COUNT
               PERFORM VIEW-JOB-DETAILS
           END-IF.

*> View job details and allow user to apply
VIEW-JOB-DETAILS