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
*> This is a simplified placeholder function to test apply-for-job, Dev 2 implement view-job-details here.
VIEW-JOB-DETAILS.
           MOVE 0 TO WS-CURRENT-COUNT
           MOVE "N" TO WS-JOB-EOF
           
           OPEN INPUT JOB-FILE
           PERFORM UNTIL WS-JOB-EOF = "Y" OR WS-CURRENT-COUNT = WS-USER-CHOICE
               READ JOB-FILE
                   AT END 
                       MOVE "Y" TO WS-JOB-EOF
                   NOT AT END
                       ADD 1 TO WS-CURRENT-COUNT
                       *> Only trigger the prompt if we found the matching row
                       IF WS-CURRENT-COUNT = WS-USER-CHOICE
                           PERFORM APPLY-FOR-JOB-PROMPT
                       END-IF
               END-READ
           END-PERFORM
           CLOSE JOB-FILE.


*> Apply for job prompt
APPLY-FOR-JOB-PROMPT.
           MOVE "1. Apply for this Job" TO WS-OUT-LINE
           PERFORM PRINT-LINE
           MOVE "2. Back to Job List" TO WS-OUT-LINE
           PERFORM PRINT-LINE
           
           MOVE "Enter your choice:" TO WS-PROMPT
           MOVE "N" TO WS-DEST-KIND
           PERFORM PRINT-PROMPT-AND-READ
           
           IF WS-TOKEN = "1"
               PERFORM RECORD-APPLICATION
           ELSE
               MOVE "Returning to job list..." TO WS-OUT-LINE
               PERFORM PRINT-LINE
           END-IF.

*> This is the core 'Simulated' process. 
*> We link the current user to the specific job record currently in memory.
RECORD-APPLICATION.
    
           OPEN EXTEND APPLICATION-FILE
           
           *> Transfer data from the JOB-FILE buffer to the APPLICATION-FILE buffer
           MOVE JOB-ID              TO APP-JOB-ID
           MOVE WS-CURR-USER        TO APP-APPLICANT-USER
           MOVE JOB-TITLE-FILE      TO APP-JOB-TITLE
           MOVE JOB-EMPLOYER-FILE   TO APP-EMPLOYER
           MOVE JOB-LOCATION-FILE   TO APP-LOCATION
           
           WRITE APPLICATION-REC
           CLOSE APPLICATION-FILE

           *> Requirements: Provide a confirmation message
           MOVE SPACES TO WS-OUT-LINE
           STRING "Your application for " FUNCTION TRIM(JOB-TITLE-FILE) 
                  " at " FUNCTION TRIM(JOB-EMPLOYER-FILE)
                  " has been submitted." INTO WS-OUT-LINE
           END-STRING
           PERFORM PRINT-LINE.