*> Logic for applying to and viewing job listings

*> Browse jobs feature: display all jobs and allow user to select one for details
BROWSE-JOBS.
           MOVE "--- Available Job Listings ---" TO WS-OUT-LINE
           PERFORM PRINT-LINE
           
           MOVE 0 TO WS-DISPLAY-COUNT
           MOVE "N" TO WS-BROWSE-EOF
           
           OPEN INPUT JOB-FILE
           PERFORM UNTIL WS-BROWSE-EOF = "Y"
               READ JOB-FILE
                   AT END
                       MOVE "Y" TO WS-BROWSE-EOF
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

           IF FUNCTION TEST-NUMVAL(WS-TOKEN) NOT = 0
               MOVE "Invalid input. Please enter a number." TO WS-OUT-LINE
               PERFORM PRINT-LINE
           ELSE
               MOVE FUNCTION NUMVAL(WS-TOKEN) TO WS-USER-CHOICE

               IF WS-USER-CHOICE = 0
                   CONTINUE
               ELSE IF WS-USER-CHOICE < 0 OR WS-USER-CHOICE > WS-DISPLAY-COUNT
                   MOVE SPACES TO WS-OUT-LINE
                   STRING "Invalid choice. Enter a number between 0 and "
                          DELIMITED BY SIZE
                          WS-DISPLAY-COUNT
                          DELIMITED BY SIZE
                          "."
                          DELIMITED BY SIZE
                     INTO WS-OUT-LINE
                   END-STRING
                   PERFORM PRINT-LINE
               ELSE
                   PERFORM VIEW-JOB-DETAILS
               END-IF
           END-IF.

*> View job details and allow user to apply
*> This is a simplified placeholder function to test apply-for-job, Dev 2 implement view-job-details here.
VIEW-JOB-DETAILS.
           MOVE 0 TO WS-CURRENT-COUNT
           MOVE "N" TO WS-JOB-EOF
           OPEN INPUT JOB-FILE
           PERFORM UNTIL WS-JOB-EOF = "Y" OR WS-CURRENT-COUNT = WS-USER-CHOICE
               READ JOB-FILE
                   AT END MOVE "Y" TO WS-JOB-EOF
                   NOT AT END
                       ADD 1 TO WS-CURRENT-COUNT
                       IF WS-CURRENT-COUNT = WS-USER-CHOICE
                           *> CAPTURE THE DATA HERE while the buffer is active
                           MOVE JOB-ID            TO WS-SEL-ID
                           MOVE JOB-TITLE-FILE    TO WS-SEL-TITLE
                           MOVE JOB-DESC-FILE     TO WS-SEL-DESC
                           MOVE JOB-EMPLOYER-FILE TO WS-SEL-EMPLOYER
                           MOVE JOB-LOCATION-FILE TO WS-SEL-LOCATION
                           MOVE JOB-SALARY-FILE   TO WS-SEL-SALARY

                           PERFORM APPLY-FOR-JOB-PROMPT
                       END-IF
               END-READ
           END-PERFORM
           CLOSE JOB-FILE.


*> Apply for job prompt
APPLY-FOR-JOB-PROMPT.
           MOVE "--- Job Details ---" TO WS-OUT-LINE
           PERFORM PRINT-LINE
           MOVE SPACES TO WS-OUT-LINE
           STRING "Title: " FUNCTION TRIM(WS-SEL-TITLE)
               INTO WS-OUT-LINE
           END-STRING
           PERFORM PRINT-LINE
           MOVE SPACES TO WS-OUT-LINE
           STRING "Employer: " FUNCTION TRIM(WS-SEL-EMPLOYER)
               INTO WS-OUT-LINE
           END-STRING
           PERFORM PRINT-LINE
           MOVE SPACES TO WS-OUT-LINE
           STRING "Location: " FUNCTION TRIM(WS-SEL-LOCATION)
               INTO WS-OUT-LINE
           END-STRING
           PERFORM PRINT-LINE
           MOVE SPACES TO WS-OUT-LINE
           STRING "Salary: " FUNCTION TRIM(WS-SEL-SALARY)
               INTO WS-OUT-LINE
           END-STRING
           PERFORM PRINT-LINE
           MOVE SPACES TO WS-OUT-LINE
           STRING "Description: " FUNCTION TRIM(WS-SEL-DESC)
               INTO WS-OUT-LINE
           END-STRING
           PERFORM PRINT-LINE
           MOVE "1. Apply for this Job" TO WS-OUT-LINE
           PERFORM PRINT-LINE
           MOVE "2. Back to Job List" TO WS-OUT-LINE
           PERFORM PRINT-LINE
           
           MOVE "Enter your choice:" TO WS-PROMPT
           MOVE "N" TO WS-DEST-KIND
           PERFORM PRINT-PROMPT-AND-READ
           
           IF WS-TOKEN = "1"
               PERFORM APPLY-TO-JOB
           ELSE IF WS-TOKEN = "2"
               MOVE "Returning to job list..." TO WS-OUT-LINE
               PERFORM PRINT-LINE
           ELSE
               MOVE "Invalid choice. Please enter 1 or 2." TO WS-OUT-LINE
               PERFORM PRINT-LINE
           END-IF.

*> This is the core 'Simulated' process. 
*> We link the current user to the specific job record currently in memory.
APPLY-TO-JOB.

    *> Step 0: Check if already applied
    MOVE "N" TO WS-APP-FOUND
    MOVE "N" TO WS-APP-EOF

    OPEN INPUT APPLICATION-FILE

    IF WS-APP-STATUS = "00"
        PERFORM UNTIL WS-APP-EOF = "Y"

            READ APPLICATION-FILE INTO WS-APP-TEMP-REC
                AT END
                    MOVE "Y" TO WS-APP-EOF
                NOT AT END

                    *> Extract fields using positions
                    MOVE WS-APP-TEMP-REC (1:20)   TO WS-APP-TEMP-USER
                    MOVE WS-APP-TEMP-REC (22:40)  TO WS-APP-TEMP-TITLE
                    MOVE WS-APP-TEMP-REC (65:40)  TO WS-APP-TEMP-EMPLOYER

                    IF FUNCTION TRIM(WS-APP-TEMP-USER) = FUNCTION TRIM(WS-CURR-USER)
                      AND FUNCTION TRIM(WS-APP-TEMP-TITLE) = FUNCTION TRIM(WS-SEL-TITLE)
                      AND FUNCTION TRIM(WS-APP-TEMP-EMPLOYER) = FUNCTION TRIM(WS-SEL-EMPLOYER)
                   
                       MOVE "Y" TO WS-APP-FOUND
                       MOVE "Y" TO WS-APP-EOF
                   END-IF

            END-READ

        END-PERFORM

        CLOSE APPLICATION-FILE
    END-IF

    *> If already applied → STOP
    IF WS-APP-FOUND = "Y"
        MOVE "You have already applied to this job." TO WS-OUT-LINE
        PERFORM PRINT-LINE
        EXIT PARAGRAPH
    END-IF

    *> Step 1: Open file (create if needed)
    OPEN EXTEND APPLICATION-FILE

    IF WS-APP-STATUS = "35"
        OPEN OUTPUT APPLICATION-FILE
        CLOSE APPLICATION-FILE
        OPEN EXTEND APPLICATION-FILE
    END-IF

    IF WS-APP-STATUS NOT = "00"
        MOVE "Error saving application." TO WS-OUT-LINE
        PERFORM PRINT-LINE
        EXIT PARAGRAPH
    END-IF

    *> Step 2: Clear record
    MOVE SPACES TO APPLICATION-REC

    *> Step 3: Place fields
    MOVE WS-CURR-USER    TO APPLICATION-REC (1:20)
    MOVE WS-SEL-TITLE    TO APPLICATION-REC (22:40)
    MOVE WS-SEL-EMPLOYER TO APPLICATION-REC (65:40)
    MOVE WS-SEL-LOCATION TO APPLICATION-REC (110:40)

    *> Step 4: Write
    WRITE APPLICATION-REC
    CLOSE APPLICATION-FILE

    *> Step 5: Confirmation
    MOVE SPACES TO WS-OUT-LINE
    STRING
        "Your application for " DELIMITED BY SIZE
        WS-SEL-TITLE DELIMITED BY SPACE
        " at " DELIMITED BY SIZE
        WS-SEL-EMPLOYER DELIMITED BY SPACE
        " has been submitted." DELIMITED BY SIZE
    INTO WS-OUT-LINE
    END-STRING

    PERFORM PRINT-LINE.
    