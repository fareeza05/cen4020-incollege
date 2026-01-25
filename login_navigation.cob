*> =========================
*> LOGIN FLOW (Unlimited retry)
*> =========================
LOG-IN.
    OPEN INPUT SAVED-ACCOUNTS-FILE
    IF SA-FILE-STATUS = "35"
        MOVE "No accounts exist. Please create an account first."
            TO MESSAGE-TO-DISPLAY
        PERFORM DISPLAY-AND-WRITE-MESSAGE
        CLOSE SAVED-ACCOUNTS-FILE
        EXIT PARAGRAPH
    END-IF
    CLOSE SAVED-ACCOUNTS-FILE
 
    MOVE 0 TO LOGIN-FLAG
 
    *> Loop until they succeed in logging in (unlimited attempts)
    PERFORM UNTIL LOGIN-FLAG = 1
        MOVE "Please enter your username:" TO MESSAGE-TO-DISPLAY
        PERFORM DISPLAY-AND-WRITE-MESSAGE
        PERFORM READ-INPUT-FROM-FILE
        MOVE INPUT-DATA TO CURRENT-USERNAME
 
        MOVE "Please enter your password:" TO MESSAGE-TO-DISPLAY
        PERFORM DISPLAY-AND-WRITE-MESSAGE
        PERFORM READ-INPUT-FROM-FILE
        MOVE INPUT-DATA TO CURRENT-PASSWORD
 
        *> Reset flags for this attempt
        MOVE 0 TO END-FLAG
        MOVE 0 TO LOGIN-FLAG
 
        *> Verify credentials against savedAccounts.dat
        OPEN INPUT SAVED-ACCOUNTS-FILE
        PERFORM UNTIL END-FLAG = 1 OR LOGIN-FLAG = 1
            READ SAVED-ACCOUNTS-FILE INTO ACCOUNTS-RECORD
                AT END
                    MOVE 1 TO END-FLAG
            END-READ
 
            IF END-FLAG = 0 AND FUNCTION TRIM(ACCOUNTS-RECORD) NOT = SPACES
                UNSTRING ACCOUNTS-RECORD DELIMITED BY "|"
                    INTO ACCOUNT-USERNAME, ACCOUNT-PASSWORD
                END-UNSTRING
 
                IF FUNCTION TRIM(CURRENT-USERNAME) =
                   FUNCTION TRIM(ACCOUNT-USERNAME)
                   AND FUNCTION TRIM(CURRENT-PASSWORD) =
                       FUNCTION TRIM(ACCOUNT-PASSWORD)
                    MOVE 1 TO LOGIN-FLAG
                END-IF
            END-IF
        END-PERFORM
        CLOSE SAVED-ACCOUNTS-FILE
 
        IF LOGIN-FLAG = 1
            MOVE "You have successfully logged in." TO MESSAGE-TO-DISPLAY
            PERFORM DISPLAY-AND-WRITE-MESSAGE
            MOVE SPACES TO MESSAGE-TO-DISPLAY
            PERFORM DISPLAY-AND-WRITE-MESSAGE
            PERFORM POST-LOGIN-MENU
        ELSE
            MOVE "Incorrect username/password, please try again" TO MESSAGE-TO-DISPLAY
            PERFORM DISPLAY-AND-WRITE-MESSAGE
            MOVE SPACES TO MESSAGE-TO-DISPLAY
            PERFORM DISPLAY-AND-WRITE-MESSAGE
        END-IF
    END-PERFORM
    .
 
*> =========================
*> POST-LOGIN TOP MENU (Epic #1)
*> =========================
POST-LOGIN-MENU.
    MOVE SPACES TO MENU-CHOICE
 
    *> Loop until user logs out
    PERFORM UNTIL FUNCTION TRIM(MENU-CHOICE) = "4"
        MOVE "1. Search for a job" TO MESSAGE-TO-DISPLAY
        PERFORM DISPLAY-AND-WRITE-MESSAGE
        MOVE "2. Find someone you know" TO MESSAGE-TO-DISPLAY
        PERFORM DISPLAY-AND-WRITE-MESSAGE
        MOVE "3. Learn a new skill" TO MESSAGE-TO-DISPLAY
        PERFORM DISPLAY-AND-WRITE-MESSAGE
        MOVE "4. Logout" TO MESSAGE-TO-DISPLAY
        PERFORM DISPLAY-AND-WRITE-MESSAGE
        MOVE "Enter your choice:" TO MESSAGE-TO-DISPLAY
        PERFORM DISPLAY-AND-WRITE-MESSAGE
 
        PERFORM READ-INPUT-FROM-FILE
        MOVE INPUT-DATA TO MENU-CHOICE
 
        EVALUATE FUNCTION TRIM(MENU-CHOICE)
            WHEN "1"
                MOVE "Job search/internship is under construction." TO MESSAGE-TO-DISPLAY
                PERFORM DISPLAY-AND-WRITE-MESSAGE
                MOVE SPACES TO MESSAGE-TO-DISPLAY
                PERFORM DISPLAY-AND-WRITE-MESSAGE
 
            WHEN "2"
                MOVE "Find someone you know is under construction." TO MESSAGE-TO-DISPLAY
                PERFORM DISPLAY-AND-WRITE-MESSAGE
                MOVE SPACES TO MESSAGE-TO-DISPLAY
                PERFORM DISPLAY-AND-WRITE-MESSAGE
 
            WHEN "3"
                PERFORM LEARN-A-NEW-SKILL
 
            WHEN "4"
                *> terminate program
                GO TO FINISH-PROGRAM
 
            WHEN OTHER
                MOVE "Invalid choice. Please enter 1-4." TO MESSAGE-TO-DISPLAY
                PERFORM DISPLAY-AND-WRITE-MESSAGE
                MOVE SPACES TO MESSAGE-TO-DISPLAY
                PERFORM DISPLAY-AND-WRITE-MESSAGE
        END-EVALUATE
    END-PERFORM
    .
 
*> =========================
*> LEARN SKILLS SUBMENU (5 skills + Go Back)
*> =========================
LEARN-A-NEW-SKILL.
    MOVE SPACES TO MENU-CHOICE
 
    PERFORM UNTIL FUNCTION TRIM(MENU-CHOICE) = "6"
        MOVE "Learn a New Skill:" TO MESSAGE-TO-DISPLAY
        PERFORM DISPLAY-AND-WRITE-MESSAGE
        MOVE "1. Skill 1" TO MESSAGE-TO-DISPLAY
        PERFORM DISPLAY-AND-WRITE-MESSAGE
        MOVE "2. Skill 2" TO MESSAGE-TO-DISPLAY
        PERFORM DISPLAY-AND-WRITE-MESSAGE
        MOVE "3. Skill 3" TO MESSAGE-TO-DISPLAY
        PERFORM DISPLAY-AND-WRITE-MESSAGE
        MOVE "4. Skill 4" TO MESSAGE-TO-DISPLAY
        PERFORM DISPLAY-AND-WRITE-MESSAGE
        MOVE "5. Skill 5" TO MESSAGE-TO-DISPLAY
        PERFORM DISPLAY-AND-WRITE-MESSAGE
        MOVE "6. Go Back" TO MESSAGE-TO-DISPLAY
        PERFORM DISPLAY-AND-WRITE-MESSAGE
        MOVE "Enter your choice:" TO MESSAGE-TO-DISPLAY
        PERFORM DISPLAY-AND-WRITE-MESSAGE
 
        PERFORM READ-INPUT-FROM-FILE
        MOVE INPUT-DATA TO MENU-CHOICE
 
        EVALUATE FUNCTION TRIM(MENU-CHOICE)
            WHEN "1" THRU "5"
                MOVE "This skill is under construction." TO MESSAGE-TO-DISPLAY
                PERFORM DISPLAY-AND-WRITE-MESSAGE
                MOVE SPACES TO MESSAGE-TO-DISPLAY
                PERFORM DISPLAY-AND-WRITE-MESSAGE
 
            WHEN "6"
                EXIT PERFORM
 
            WHEN OTHER
                MOVE "Invalid choice. Please enter 1-6." TO MESSAGE-TO-DISPLAY
                PERFORM DISPLAY-AND-WRITE-MESSAGE
                MOVE SPACES TO MESSAGE-TO-DISPLAY
                PERFORM DISPLAY-AND-WRITE-MESSAGE
        END-EVALUATE
    END-PERFORM
    .