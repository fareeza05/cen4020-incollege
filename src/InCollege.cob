       >>SOURCE FORMAT FREE
IDENTIFICATION DIVISION.
PROGRAM-ID. InCollege.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT IN-FILE ASSIGN TO "tests/week3/jawaad/TC-EE-10.txt"
        ORGANIZATION IS LINE SEQUENTIAL.
    SELECT OUT-FILE ASSIGN TO "tests/week3/jawaad/TC-EE-10-Output.txt"
        ORGANIZATION IS LINE SEQUENTIAL.
    SELECT ACC-FILE ASSIGN TO "data/InCollege-Accounts.txt"
        ORGANIZATION IS LINE SEQUENTIAL
        FILE STATUS IS WS-ACC-STATUS.
     
    SELECT PROF-FILE ASSIGN TO "data/InCollege-Profiles.txt"
        ORGANIZATION IS LINE SEQUENTIAL
        FILE STATUS IS WS-PROF-STATUS.

DATA DIVISION.
FILE SECTION.

FD  IN-FILE.
01  IN-REC                 PIC X(500).

FD  OUT-FILE.
01  OUT-REC                PIC X(200).

FD  ACC-FILE.
01  ACC-REC.
    05 ACC-USER            PIC X(20).
    05 ACC-PASS            PIC X(12).

FD  PROF-FILE.
01  PROF-REC.
    05 PROF-USER           PIC X(20).
    05 PROF-FNAME          PIC X(20).
    05 PROF-LNAME          PIC X(20).
    05 PROF-UNIV           PIC X(30).
    05 PROF-MAJOR          PIC X(20).
    05 PROF-GRAD           PIC 9(4).
    05 PROF-ABOUT          PIC X(200).

    05 PROF-EXP-COUNT      PIC 9.
    05 PROF-EXPERIENCE OCCURS 3 TIMES.
        10 PROF-EXP-TITLE  PIC X(50).
        10 PROF-EXP-COMP   PIC X(50).
        10 PROF-EXP-DATES  PIC X(30).
        10 PROF-EXP-DESC   PIC X(100).

    05 PROF-EDU-COUNT      PIC 9.
    05 PROF-EDUCATION OCCURS 3 TIMES.
        10 PROF-EDU-DEGREE PIC X(50).
        10 PROF-EDU-SCHOOL PIC X(50).
        10 PROF-EDU-YEARS  PIC X(20).

WORKING-STORAGE SECTION.

01  WS-FLAGS.
    05 WS-IN-EOF           PIC X VALUE "N".
    05 WS-ACC-EOF          PIC X VALUE "N".
    05 WS-DONE             PIC X VALUE "N".

01  WS-ACC-STATUS           PIC XX VALUE "00".

01  WS-CURR-USER            PIC X(20) VALUE SPACES.

01  WS-INPUT.
    05 WS-TOKEN             PIC X(300) VALUE SPACES.
    05 WS-MENU-CHOICE       PIC X VALUE SPACE.
    05 WS-USER-IN           PIC X(20) VALUE SPACES.
    05 WS-PASS-IN           PIC X(12) VALUE SPACES.

01  WS-OUTPUT.
    05 WS-OUT-LINE          PIC X(200) VALUE SPACES.

01  WS-PROMPT               PIC X(200) VALUE SPACES.
01  WS-DEST-KIND            PIC X VALUE SPACE.

01  WS-ACCOUNTS.
    05 WS-ACC-COUNT         PIC 9 VALUE 0.
    05 WS-ACC-TABLE OCCURS 5 TIMES.
        10 WS-ACC-USER      PIC X(20).
        10 WS-ACC-PASS      PIC X(12).

01  WS-TEMP.
    05 WS-I                 PIC 9(3) VALUE 0.
    05 WS-J                 PIC 9(3) VALUE 0.

    05 WS-CANCEL-ITEM       PIC X VALUE "N".

    05 WS-HAS-LETTER        PIC X VALUE "N".
    05 WS-CH                PIC X VALUE SPACE.

    05 WS-YEAR1             PIC 9(4) VALUE 0.
    05 WS-YEAR2             PIC 9(4) VALUE 0.


    05 WS-K                 PIC 9(3) VALUE 0.
    05 WS-FOUND             PIC X VALUE "N".
    05 WS-VALID             PIC X VALUE "N".
    05 WS-LEN               PIC 9(3) VALUE 0.
    05 WS-HAS-UPPER         PIC X VALUE "N".
    05 WS-HAS-DIGIT         PIC X VALUE "N".
    05 WS-HAS-SPECIAL       PIC X VALUE "N".
    05 WS-CHAR              PIC X VALUE SPACE.

01  WS-PROF-STATUS           PIC XX VALUE "00".
01  WS-PROF-EOF               PIC X VALUE "N".

01  WS-PROFILES.
    05 WS-PROF-COUNT         PIC 9 VALUE 0.
    05 WS-PROF-TABLE OCCURS 5 TIMES.
       10 WS-PROF-USER       PIC X(30).
       10 WS-PROF-FNAME      PIC X(30).
       10 WS-PROF-LNAME      PIC X(30).
       10 WS-PROF-UNIV       PIC X(40).
       10 WS-PROF-MAJOR      PIC X(30).
       10 WS-PROF-GRAD       PIC 9(4).
       10 WS-PROF-ABOUT      PIC X(200).

       10 WS-PROF-EXP-COUNT  PIC 9.
       10 WS-PROF-EXP OCCURS 3 TIMES.
          15 WS-EXP-TITLE    PIC X(50).
          15 WS-EXP-COMP     PIC X(50).
          15 WS-EXP-DATES    PIC X(30).
          15 WS-EXP-DESC     PIC X(100).

       10 WS-PROF-EDU-COUNT  PIC 9.
       10 WS-PROF-EDU OCCURS 3 TIMES.
          15 WS-EDU-DEGREE   PIC X(50).
          15 WS-EDU-SCHOOL   PIC X(50).
          15 WS-EDU-YEARS    PIC X(20).

01  WS-SEARCH.
    05 WS-SEARCH-NAME      PIC X(120) VALUE SPACES.
    05 WS-FULL-NAME        PIC X(120) VALUE SPACES.
    05 WS-SEARCH-IDX       PIC 9(3) VALUE 0.


PROCEDURE DIVISION.

MAIN.
    PERFORM INIT-FILES
    PERFORM LOAD-ACCOUNTS
    PERFORM LOAD-PROFILES
    PERFORM MENU-LOOP
    PERFORM CLOSE-FILES
    STOP RUN.

INIT-FILES.
    OPEN INPUT IN-FILE
    OPEN OUTPUT OUT-FILE

    *> Accounts file: try read existing; if missing, create empty
    OPEN INPUT ACC-FILE
    IF WS-ACC-STATUS = "35"
        CLOSE ACC-FILE
        OPEN OUTPUT ACC-FILE
        CLOSE ACC-FILE
        OPEN INPUT ACC-FILE
        MOVE "00" TO WS-ACC-STATUS
    END-IF.

    *> Profiles file: try read existing; if missing, create empty
    OPEN INPUT PROF-FILE
    IF WS-PROF-STATUS = "35"
       CLOSE PROF-FILE
       OPEN OUTPUT PROF-FILE
       CLOSE PROF-FILE
    ELSE
        CLOSE PROF-FILE
    END-IF.


LOAD-ACCOUNTS.
    MOVE 0 TO WS-ACC-COUNT
    MOVE "N" TO WS-ACC-EOF

    PERFORM UNTIL WS-ACC-EOF = "Y"
        READ ACC-FILE
            AT END
                MOVE "Y" TO WS-ACC-EOF
            NOT AT END
                IF WS-ACC-COUNT < 5
                    ADD 1 TO WS-ACC-COUNT
                    MOVE ACC-USER TO WS-ACC-USER(WS-ACC-COUNT)
                    MOVE ACC-PASS TO WS-ACC-PASS(WS-ACC-COUNT)
                END-IF
        END-READ
    END-PERFORM
    CLOSE ACC-FILE.
 
LOAD-PROFILES.
    MOVE 0 TO WS-PROF-COUNT
    MOVE "N" TO WS-PROF-EOF

    OPEN INPUT PROF-FILE

    PERFORM UNTIL WS-PROF-EOF = "Y"
        READ PROF-FILE
            AT END
                MOVE "Y" TO WS-PROF-EOF
            NOT AT END
                IF WS-PROF-COUNT < 5
                    ADD 1 TO WS-PROF-COUNT
                    MOVE PROF-USER      TO WS-PROF-USER(WS-PROF-COUNT)
                    MOVE PROF-FNAME     TO WS-PROF-FNAME(WS-PROF-COUNT)
                    MOVE PROF-LNAME     TO WS-PROF-LNAME(WS-PROF-COUNT)
                    MOVE PROF-GRAD      TO WS-PROF-GRAD(WS-PROF-COUNT)
                    MOVE PROF-MAJOR     TO WS-PROF-MAJOR(WS-PROF-COUNT)
                    MOVE PROF-UNIV      TO WS-PROF-UNIV(WS-PROF-COUNT)
                    MOVE PROF-ABOUT     TO WS-PROF-ABOUT(WS-PROF-COUNT)

                    MOVE PROF-EXP-COUNT
                        TO WS-PROF-EXP-COUNT(WS-PROF-COUNT)
                    MOVE PROF-EDU-COUNT
                        TO WS-PROF-EDU-COUNT(WS-PROF-COUNT)

                    PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > 3
                        MOVE PROF-EXP-TITLE(WS-J)
                            TO WS-EXP-TITLE(WS-PROF-COUNT, WS-J)
                        MOVE PROF-EXP-COMP(WS-J)
                            TO WS-EXP-COMP(WS-PROF-COUNT, WS-J)
                        MOVE PROF-EXP-DATES(WS-J)
                            TO WS-EXP-DATES(WS-PROF-COUNT, WS-J)
                        MOVE PROF-EXP-DESC(WS-J)
                            TO WS-EXP-DESC(WS-PROF-COUNT, WS-J)

                        MOVE PROF-EDU-DEGREE(WS-J)
                            TO WS-EDU-DEGREE(WS-PROF-COUNT, WS-J)
                        MOVE PROF-EDU-SCHOOL(WS-J)
                            TO WS-EDU-SCHOOL(WS-PROF-COUNT, WS-J)
                        MOVE PROF-EDU-YEARS(WS-J)
                            TO WS-EDU-YEARS(WS-PROF-COUNT, WS-J)
                    END-PERFORM
      
                END-IF
        END-READ
    END-PERFORM
    CLOSE PROF-FILE.
   

MENU-LOOP.
    PERFORM UNTIL WS-DONE = "Y"
        MOVE "Welcome to InCollege" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "Please choose an option:" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "1) Log In" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "2) Create New Account" TO WS-OUT-LINE
        PERFORM PRINT-LINE

        MOVE "Enter choice (1 or 2):" TO WS-PROMPT
        MOVE "M" TO WS-DEST-KIND
        PERFORM PRINT-PROMPT-AND-READ

        EVALUATE WS-MENU-CHOICE
            WHEN "1"
                PERFORM LOGIN-FLOW
            WHEN "2"
                PERFORM CREATE-ACCOUNT-FLOW
            WHEN OTHER
                MOVE "Invalid selection. Please try again." TO WS-OUT-LINE
                PERFORM PRINT-LINE
        END-EVALUATE
    END-PERFORM.

LOGIN-FLOW.
    MOVE "N" TO WS-FOUND
    PERFORM UNTIL WS-FOUND = "Y"
        MOVE "Username:" TO WS-PROMPT
        MOVE "U" TO WS-DEST-KIND
        PERFORM PRINT-PROMPT-AND-READ

        MOVE "Password:" TO WS-PROMPT
        MOVE "P" TO WS-DEST-KIND
        PERFORM PRINT-PROMPT-AND-READ

        PERFORM CHECK-CREDENTIALS

        IF WS-FOUND = "Y"
            MOVE "You have successfully logged in" TO WS-OUT-LINE
            MOVE WS-USER-IN TO WS-CURR-USER
            PERFORM PRINT-LINE

            MOVE SPACES TO WS-OUT-LINE
            STRING "Welcome, "
                   FUNCTION TRIM(WS-USER-IN)
                   "!"
              INTO WS-OUT-LINE
            END-STRING
            PERFORM PRINT-LINE

            PERFORM POST-LOGIN-MENU

            EXIT PARAGRAPH
        ELSE
            MOVE "Incorrect username/password, please try again" TO WS-OUT-LINE
            PERFORM PRINT-LINE
        END-IF
    END-PERFORM.

CREATE-ACCOUNT-FLOW.
    IF WS-ACC-COUNT >= 5
        MOVE "All permitted accounts have been created, please come back later"
            TO WS-OUT-LINE
        PERFORM PRINT-LINE
        EXIT PARAGRAPH
    END-IF

    MOVE "Create a username:" TO WS-PROMPT
    MOVE "U" TO WS-DEST-KIND
    PERFORM PRINT-PROMPT-AND-READ

    PERFORM CHECK-USERNAME-UNIQUE
    IF WS-FOUND = "Y"
        MOVE "That username already exists. Please try again." TO WS-OUT-LINE
        PERFORM PRINT-LINE
        EXIT PARAGRAPH
    END-IF

    MOVE "Create a password (8-12 chars, 1 uppercase, 1 digit, 1 special):"
        TO WS-PROMPT
    MOVE "P" TO WS-DEST-KIND
    PERFORM PRINT-PROMPT-AND-READ

    PERFORM VALIDATE-PASSWORD

    IF WS-VALID = "N"
        MOVE "Password does not meet requirements. Please try again." TO WS-OUT-LINE
        PERFORM PRINT-LINE
        EXIT PARAGRAPH
    END-IF

    ADD 1 TO WS-ACC-COUNT
    MOVE WS-USER-IN TO WS-ACC-USER(WS-ACC-COUNT)
    MOVE WS-PASS-IN TO WS-ACC-PASS(WS-ACC-COUNT)

    PERFORM SAVE-ACCOUNTS

    MOVE "Account created successfully." TO WS-OUT-LINE
    PERFORM PRINT-LINE.

CHECK-CREDENTIALS.
    MOVE "N" TO WS-FOUND
    PERFORM VARYING WS-I FROM 1 BY 1
        UNTIL WS-I > WS-ACC-COUNT OR WS-FOUND = "Y"
        IF WS-USER-IN = WS-ACC-USER(WS-I)
           AND WS-PASS-IN = WS-ACC-PASS(WS-I)
            MOVE "Y" TO WS-FOUND
        END-IF
    END-PERFORM.

CHECK-USERNAME-UNIQUE.
    MOVE "N" TO WS-FOUND
    PERFORM VARYING WS-I FROM 1 BY 1
        UNTIL WS-I > WS-ACC-COUNT OR WS-FOUND = "Y"
        IF WS-USER-IN = WS-ACC-USER(WS-I)
            MOVE "Y" TO WS-FOUND
        END-IF
    END-PERFORM.

VALIDATE-PASSWORD.
    MOVE "Y" TO WS-VALID
    MOVE "N" TO WS-HAS-UPPER
    MOVE "N" TO WS-HAS-DIGIT
    MOVE "N" TO WS-HAS-SPECIAL

    COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-PASS-IN))

    IF WS-LEN < 8 OR WS-LEN > 12
        MOVE "N" TO WS-VALID
        EXIT PARAGRAPH
    END-IF

    PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-LEN
        MOVE WS-PASS-IN(WS-J:1) TO WS-CHAR

        IF WS-CHAR >= "A" AND WS-CHAR <= "Z"
            MOVE "Y" TO WS-HAS-UPPER
        END-IF

        IF WS-CHAR >= "0" AND WS-CHAR <= "9"
            MOVE "Y" TO WS-HAS-DIGIT
        END-IF

        IF (WS-CHAR = "!" OR WS-CHAR = "@" OR WS-CHAR = "#" OR WS-CHAR = "$"
         OR WS-CHAR = "%" OR WS-CHAR = "^" OR WS-CHAR = "&" OR WS-CHAR = "*"
         OR WS-CHAR = "-" OR WS-CHAR = "_" OR WS-CHAR = "+")
            MOVE "Y" TO WS-HAS-SPECIAL
        END-IF
    END-PERFORM

    IF WS-HAS-UPPER = "N" OR WS-HAS-DIGIT = "N" OR WS-HAS-SPECIAL = "N"
        MOVE "N" TO WS-VALID
    END-IF.

SAVE-ACCOUNTS.
    OPEN OUTPUT ACC-FILE
    PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-ACC-COUNT
        MOVE WS-ACC-USER(WS-I) TO ACC-USER
        MOVE WS-ACC-PASS(WS-I) TO ACC-PASS
        WRITE ACC-REC
    END-PERFORM
    CLOSE ACC-FILE.

POST-LOGIN-MENU.
    MOVE SPACE TO WS-MENU-CHOICE
    PERFORM UNTIL WS-MENU-CHOICE = "6"
        MOVE "1. Create/edit my profile" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "2. View my profile" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "3. Search for a job" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "4. Find someone you know" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "5. Learn a new skill" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "6. Logout" TO WS-OUT-LINE
        PERFORM PRINT-LINE

        MOVE "Enter your choice:" TO WS-PROMPT
        MOVE "M" TO WS-DEST-KIND
        PERFORM PRINT-PROMPT-AND-READ

        PERFORM VALIDATE-MENU-1-6
        IF WS-VALID = "N"
           MOVE "Error: Menu choice must be a single digit 1-6. Exiting program" to WS-OUT-LINE
           PERFORM PRINT-LINE
           PERFORM CLOSE-FILES
           STOP RUN  
        END-IF

        MOVE WS-TOKEN(1:1) TO WS-MENU-CHOICE

        EVALUATE WS-MENU-CHOICE
            WHEN "1"
               PERFORM CREATE-OR-EDIT-ACCOUNT
            WHEN "2"
               PERFORM VIEW-PROFILE
            WHEN "3"
                MOVE "Job search is under construction." TO WS-OUT-LINE
                PERFORM PRINT-LINE
            WHEN "4"
                PERFORM SEARCH-USER
            WHEN "5"
                PERFORM LEARN-A-NEW-SKILL
            WHEN "6"
                EXIT PERFORM
            WHEN OTHER
                MOVE "Invalid choice. Please enter 1-6." TO WS-OUT-LINE
                PERFORM PRINT-LINE
        END-EVALUATE
    END-PERFORM.

LEARN-A-NEW-SKILL.
    MOVE SPACE TO WS-MENU-CHOICE
    PERFORM UNTIL WS-MENU-CHOICE = "6"
        MOVE "Learn a New Skill:" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "1. Skill 1" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "2. Skill 2" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "3. Skill 3" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "4. Skill 4" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "5. Skill 5" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "6. Go Back" TO WS-OUT-LINE
        PERFORM PRINT-LINE

        MOVE "Enter your choice:" TO WS-PROMPT
        MOVE "M" TO WS-DEST-KIND
        PERFORM PRINT-PROMPT-AND-READ

        EVALUATE WS-MENU-CHOICE
            WHEN "1" THRU "5"
                MOVE "This feature is under construction." TO WS-OUT-LINE
                PERFORM PRINT-LINE
            WHEN "6"
                EXIT PERFORM
            WHEN OTHER
                MOVE "Invalid choice. Please enter 1-6." TO WS-OUT-LINE
                PERFORM PRINT-LINE
        END-EVALUATE
    END-PERFORM.

 *> Helpers for create/edit account:
FIND-PROFILE-IDX.
      MOVE 0 TO WS-I
      MOVE 0 TO WS-J
      PERFORM VARYING WS-I FROM 1 BY 1
       UNTIL WS-I > WS-PROF-COUNT OR WS-J > 0
       IF WS-PROF-USER(WS-I) = WS-CURR-USER
           MOVE WS-I TO WS-J
       END-IF
      END-PERFORM.
 
SAVE-PROFILES.
    OPEN OUTPUT PROF-FILE
    PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-PROF-COUNT
        MOVE WS-PROF-USER(WS-I)      TO PROF-USER
        MOVE WS-PROF-FNAME(WS-I)     TO PROF-FNAME
        MOVE WS-PROF-LNAME(WS-I)     TO PROF-LNAME
        MOVE WS-PROF-GRAD(WS-I)      TO PROF-GRAD
        MOVE WS-PROF-MAJOR(WS-I)     TO PROF-MAJOR
        MOVE WS-PROF-UNIV(WS-I)      TO PROF-UNIV
        MOVE WS-PROF-ABOUT(WS-I)     TO PROF-ABOUT
        MOVE WS-PROF-EXP-COUNT(WS-I) TO PROF-EXP-COUNT
        MOVE WS-PROF-EDU-COUNT(WS-I) TO PROF-EDU-COUNT

        *> Clear experience and education slots 
        PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 3
               MOVE SPACES TO PROF-EXP-TITLE(WS-K)
               MOVE SPACES TO PROF-EXP-COMP(WS-K)
               MOVE SPACES TO PROF-EXP-DATES(WS-K)
               MOVE SPACES TO PROF-EXP-DESC(WS-K)

               MOVE SPACES TO PROF-EDU-DEGREE(WS-K)
               MOVE SPACES TO PROF-EDU-SCHOOL(WS-K)
               MOVE SPACES TO PROF-EDU-YEARS(WS-K)
        END-PERFORM       

        *> Copy experience entries
        PERFORM VARYING WS-K FROM 1 BY 1
               UNTIL WS-K > WS-PROF-EXP-COUNT(WS-I)
               MOVE WS-EXP-TITLE(WS-I, WS-K) TO PROF-EXP-TITLE(WS-K)
               MOVE WS-EXP-COMP(WS-I, WS-K)  TO PROF-EXP-COMP(WS-K)
               MOVE WS-EXP-DATES(WS-I, WS-K) TO PROF-EXP-DATES(WS-K)
               MOVE WS-EXP-DESC(WS-I, WS-K)  TO PROF-EXP-DESC(WS-K)
        END-PERFORM
      
        *> Copy education entries
        PERFORM VARYING WS-K FROM 1 BY 1
               UNTIL WS-K > WS-PROF-EDU-COUNT(WS-I)
               MOVE WS-EDU-DEGREE(WS-I, WS-K) TO PROF-EDU-DEGREE(WS-K)
               MOVE WS-EDU-SCHOOL(WS-I, WS-K) TO PROF-EDU-SCHOOL(WS-K)
               MOVE WS-EDU-YEARS(WS-I, WS-K)  TO PROF-EDU-YEARS(WS-K)
        END-PERFORM

        WRITE PROF-REC
    END-PERFORM
    CLOSE PROF-FILE.

CHECK-HAS-LETTER.
    MOVE "N" TO WS-HAS-LETTER
    PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-LEN
        MOVE WS-TOKEN(WS-J:1) TO WS-CH
        IF (WS-CH >= "A" AND WS-CH <= "Z")
           OR (WS-CH >= "a" AND WS-CH <= "z")
            MOVE "Y" TO WS-HAS-LETTER
            EXIT PERFORM
        END-IF
    END-PERFORM.

VALIDATE-YEARS-RANGE.
    *> WS-TOKEN holds the input
    COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TOKEN))

    IF WS-LEN NOT = 9
        MOVE "N" TO WS-VALID
        EXIT PARAGRAPH
    END-IF

    IF WS-TOKEN(5:1) NOT = "-"
        MOVE "N" TO WS-VALID
        EXIT PARAGRAPH
    END-IF

    IF WS-TOKEN(1:4) IS NOT NUMERIC
        MOVE "N" TO WS-VALID
        EXIT PARAGRAPH
    END-IF

    IF WS-TOKEN(6:4) IS NOT NUMERIC
        MOVE "N" TO WS-VALID
        EXIT PARAGRAPH
    END-IF

    MOVE WS-TOKEN(1:4) TO WS-YEAR1
    MOVE WS-TOKEN(6:4) TO WS-YEAR2

    *> optional sanity checks (recommended)
    IF WS-YEAR1 < 1900 OR WS-YEAR1 > 2100
        MOVE "N" TO WS-VALID
        EXIT PARAGRAPH
    END-IF

    IF WS-YEAR2 < 1900 OR WS-YEAR2 > 2100
        MOVE "N" TO WS-VALID
        EXIT PARAGRAPH
    END-IF

    IF WS-YEAR2 < WS-YEAR1
        MOVE "N" TO WS-VALID
        EXIT PARAGRAPH
    END-IF

    MOVE "Y" TO WS-VALID.

VALIDATE-MENU-1-6.
    COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TOKEN))

    IF WS-LEN NOT = 1
        MOVE "N" TO WS-VALID
        EXIT PARAGRAPH
    END-IF

    IF WS-TOKEN(1:1) IS NOT NUMERIC
        MOVE "N" TO WS-VALID
        EXIT PARAGRAPH
    END-IF

    IF WS-TOKEN(1:1) < "1" OR WS-TOKEN(1:1) > "6"
        MOVE "N" TO WS-VALID
        EXIT PARAGRAPH
    END-IF

    MOVE "Y" TO WS-VALID.



CREATE-OR-EDIT-ACCOUNT.

    MOVE "----- CREATE/EDIT PROFILE -----" TO WS-OUT-LINE
    PERFORM PRINT-LINE
*> FIND EXISTING PROFILE ROW FOR THIS USER FROM OUR FILE
    PERFORM FIND-PROFILE-IDX
 
*> IF NO PROFILE EXISTS, CREATE NEW
    IF WS-J = 0
       IF WS-PROF-COUNT < 5
              ADD 1 TO WS-PROF-COUNT
              MOVE WS-PROF-COUNT TO WS-J
              MOVE WS-CURR-USER TO WS-PROF-USER(WS-J)
       END-IF
    END-IF

    *> First Name
    MOVE "Enter First Name: (Required)" TO WS-PROMPT
    MOVE "X" TO WS-DEST-KIND
    PERFORM PRINT-PROMPT-AND-READ
      
    COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TOKEN))
    IF WS-LEN = 0
        MOVE "Error: First Name is required. Exiting program" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        PERFORM CLOSE-FILES
        STOP RUN
    END-IF
    IF WS-LEN > 30
        MOVE "Error: First Name cannot exceed 30 characters. Exiting program" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        PERFORM CLOSE-FILES
        STOP RUN
    END-IF 

    MOVE WS-TOKEN TO WS-PROF-FNAME(WS-J)

    *> Last Name
    MOVE "Enter Last Name: (Required)" TO WS-PROMPT
    MOVE "X" TO WS-DEST-KIND
    PERFORM PRINT-PROMPT-AND-READ

    COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TOKEN))
    IF WS-LEN = 0
        MOVE "Error: Last Name is required. Exiting program" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        PERFORM CLOSE-FILES
        STOP RUN
    END-IF
    IF WS-LEN > 30
        MOVE "Error: Last Name cannot exceed 30 characters. Exiting program." TO WS-OUT-LINE
        PERFORM PRINT-LINE
        PERFORM CLOSE-FILES
        STOP RUN
    END-IF 

    MOVE WS-TOKEN TO WS-PROF-LNAME(WS-J)

    *> University
    MOVE "Enter University/College Attended: (Required)" TO WS-PROMPT
    MOVE "X" TO WS-DEST-KIND
    PERFORM PRINT-PROMPT-AND-READ

    COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TOKEN))
    IF WS-LEN = 0
        MOVE "Error: University/College is required. Exiting program." TO WS-OUT-LINE
        PERFORM PRINT-LINE
        PERFORM CLOSE-FILES
        STOP RUN
    END-IF
    IF WS-LEN > 40
        MOVE "Error: University name cannot exceed 40 characters. Exiting program." TO WS-OUT-LINE
        PERFORM PRINT-LINE
        PERFORM CLOSE-FILES
        STOP RUN
    END-IF 

    MOVE WS-TOKEN TO WS-PROF-UNIV(WS-J)

    *> Major
    MOVE "Enter Major: (Required)" TO WS-PROMPT
    MOVE "X" TO WS-DEST-KIND
    PERFORM PRINT-PROMPT-AND-READ

    COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TOKEN))
    IF WS-LEN = 0
        MOVE "Error: Major is required. Exiting program." TO WS-OUT-LINE
        PERFORM PRINT-LINE
        PERFORM CLOSE-FILES
        STOP RUN
    END-IF
    IF WS-LEN > 30
        MOVE "Error: First Name cannot exceed 30 characters. Exiting program." TO WS-OUT-LINE
        PERFORM PRINT-LINE
        PERFORM CLOSE-FILES
        STOP RUN
    END-IF 

    MOVE WS-TOKEN TO WS-PROF-MAJOR(WS-J)


    *> Graduation Year (YYYY)
    MOVE "Enter Graduation Year (YYYY): (Required)" TO WS-PROMPT
    MOVE "X" TO WS-DEST-KIND
    PERFORM PRINT-PROMPT-AND-READ

    COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TOKEN))

    IF WS-LEN = 0
       MOVE "Error: Graduation year is required. Exiting program." TO WS-OUT-LINE
       PERFORM PRINT-LINE
       PERFORM CLOSE-FILES
       STOP RUN
    END-IF

    IF WS-LEN NOT = 4
       MOVE "Error: Graduation year must be exactly 4 digits (YYYY). Exiting program." TO WS-OUT-LINE
       PERFORM PRINT-LINE 
       PERFORM CLOSE-FILES
       STOP RUN
    END-IF

    IF FUNCTION TRIM(WS-TOKEN) IS NOT NUMERIC 
       MOVE "Error: Graduation year must be numeric. Exiting program." TO WS-OUT-LINE
       PERFORM PRINT-LINE
       PERFORM CLOSE-FILES
       STOP RUN
    END-IF

    IF WS-TOKEN < "1900" OR WS-TOKEN > "2100"
    MOVE "Error: Graduation Year must be between 1900 and 2100." TO WS-OUT-LINE
    PERFORM PRINT-LINE
    PERFORM CLOSE-FILES
    STOP RUN
    END-IF

    MOVE WS-TOKEN(1:4) TO WS-PROF-GRAD(WS-J)

    *> About (short bio)
    MOVE "Enter About (short bio): (Optional)" TO WS-PROMPT
    MOVE "X" TO WS-DEST-KIND
    PERFORM PRINT-PROMPT-AND-READ

    COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TOKEN))
    IF WS-LEN > 200
       MOVE "Error: About section cannot exceed 200 characters. Exiting program." TO WS-OUT-LINE
       PERFORM PRINT-LINE
       PERFORM CLOSE-FILES
       STOP RUN   
    END-IF 

    MOVE WS-TOKEN TO WS-PROF-ABOUT(WS-J)

    *> Experience (optional, up to 3)
    MOVE 0 TO WS-PROF-EXP-COUNT(WS-J)

    PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
           MOVE "Add Experience (optional, enter DONE to finish):"
                  TO WS-PROMPT
           MOVE "X" TO WS-DEST-KIND
           PERFORM PRINT-PROMPT-AND-READ

           IF FUNCTION UPPER-CASE(WS-TOKEN) = "DONE"
               EXIT PERFORM
           END-IF


           IF WS-TOKEN NOT = "ADD"
           MOVE "Error: Enter ADD to add an experience or DONE to finish. Exiting program."
               TO WS-OUT-LINE
               PERFORM PRINT-LINE
               PERFORM CLOSE-FILES
               STOP RUN
           END-IF

           ADD 1 TO WS-PROF-EXP-COUNT(WS-J)

           *> Title
           MOVE "Experience Title:" TO WS-PROMPT
           PERFORM PRINT-PROMPT-AND-READ

           IF FUNCTION UPPER-CASE(FUNCTION TRIM(WS-TOKEN)) = "DONE"
               SUBTRACT 1 FROM WS-PROF-EXP-COUNT(WS-J)
               MOVE "Warning: Experience is incomplete, your profile will not display this. Moving to next prompt." TO WS-OUT-LINE
               PERFORM PRINT-LINE
               CONTINUE
           END-IF

           COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TOKEN))

           IF WS-LEN = 0 
               MOVE "Error: Experience Title is required. Exiting program." TO WS-OUT-LINE
               PERFORM PRINT-LINE
               PERFORM CLOSE-FILES
               STOP RUN
           END-IF 

           IF WS-LEN > 50
               MOVE "Error: Experience Title cannot exceed 50 characters. Exiting program." TO WS-OUT-LINE
               PERFORM PRINT-LINE
               PERFORM CLOSE-FILES
               STOP RUN 
           END-IF

           PERFORM CHECK-HAS-LETTER
               IF WS-HAS-LETTER = "N"
                   MOVE "Error: Experience Title cannot be numbers only. Exiting program" TO WS-OUT-LINE
                   PERFORM PRINT-LINE
                   PERFORM CLOSE-FILES
                   STOP RUN 
               END-IF

           MOVE WS-TOKEN TO WS-EXP-TITLE(WS-J, WS-I)

           *> Organization/Company
           MOVE "Company/Organization:" TO WS-PROMPT
           PERFORM PRINT-PROMPT-AND-READ

           IF FUNCTION UPPER-CASE(FUNCTION TRIM(WS-TOKEN)) = "DONE"
              SUBTRACT 1 FROM WS-PROF-EXP-COUNT(WS-J)
              MOVE "Warning: Experience is incomplete, your profile will not display this. Moving to next prompt." TO WS-OUT-LINE
              PERFORM PRINT-LINE
              CONTINUE
           END-IF

           COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TOKEN))

           IF WS-LEN = 0 
               MOVE "Error: Company/Organization is required. Exiting program." TO WS-OUT-LINE
               PERFORM PRINT-LINE
               PERFORM CLOSE-FILES
               STOP RUN
           END-IF 

           IF WS-LEN > 50
               MOVE "Error: Company/Organization cannot exceed 50 characters. Exiting program." TO WS-OUT-LINE
               PERFORM PRINT-LINE
               PERFORM CLOSE-FILES
               STOP RUN 
           END-IF

           PERFORM CHECK-HAS-LETTER
               IF WS-HAS-LETTER = "N"
                   MOVE "Error: Company/Organization cannot be numbers only. Exiting program" TO WS-OUT-LINE
                   PERFORM PRINT-LINE
                   PERFORM CLOSE-FILES
                   STOP RUN 
               END-IF

           MOVE WS-TOKEN TO WS-EXP-COMP(WS-J, WS-I)

           *> DATES
           MOVE "Dates:" TO WS-PROMPT
           PERFORM PRINT-PROMPT-AND-READ
           IF FUNCTION UPPER-CASE(FUNCTION TRIM(WS-TOKEN)) = "DONE"
              SUBTRACT 1 FROM WS-PROF-EXP-COUNT(WS-J)
              MOVE "WWarning: Experience is incomplete, your profile will not display this. Moving to next prompt." TO WS-OUT-LINE
              PERFORM PRINT-LINE
              CONTINUE
           END-IF
           MOVE WS-TOKEN TO WS-EXP-DATES(WS-J, WS-I)

          *> DESCRIPTION
           MOVE "Description (optional):" TO WS-PROMPT
           PERFORM PRINT-PROMPT-AND-READ

           IF FUNCTION UPPER-CASE(FUNCTION TRIM(WS-TOKEN)) = "DONE"
              SUBTRACT 1 FROM WS-PROF-EXP-COUNT(WS-J)
              MOVE "Warning: Experience is incomplete. Moving to next prompt." TO WS-OUT-LINE
              PERFORM PRINT-LINE
              CONTINUE
           END-IF

           COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TOKEN))

           IF WS-LEN > 100
               MOVE "Description cannot exceed 100 characters. Exiting program." TO WS-OUT-LINE
               PERFORM PRINT-LINE
               PERFORM CLOSE-FILES
               STOP RUN 
           END-IF
           MOVE WS-TOKEN TO WS-EXP-DESC(WS-J, WS-I)
    END-PERFORM 

    IF WS-PROF-EXP-COUNT(WS-J) = 3
       MOVE "Note: Maximum of 3 experiences reached." TO WS-OUT-LINE
       PERFORM PRINT-LINE
    END-IF 

    *> Education (optional, up to 3)
    MOVE 0 TO WS-PROF-EDU-COUNT(WS-J)

    PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
           MOVE "Add Education (optional, enter DONE to finish):"
                  TO WS-PROMPT
           MOVE "X" TO WS-DEST-KIND
           PERFORM PRINT-PROMPT-AND-READ

           IF FUNCTION UPPER-CASE(WS-TOKEN) = "DONE"
                  EXIT PERFORM
           END-IF
           
           IF WS-TOKEN NOT = "ADD"
               MOVE "Error: Enter ADD to add education or DONE to finish. Exiting program."
                   TO WS-OUT-LINE
               PERFORM PRINT-LINE
               PERFORM CLOSE-FILES
               STOP RUN
           END-IF  

           ADD 1 TO WS-PROF-EDU-COUNT(WS-J)

           *>Degree
           MOVE "Degree:" TO WS-PROMPT
           PERFORM PRINT-PROMPT-AND-READ

           IF FUNCTION UPPER-CASE(FUNCTION TRIM(WS-TOKEN)) = "DONE"
              SUBTRACT 1 FROM WS-PROF-EXP-COUNT(WS-J)
              MOVE "Warning: Education is incomplete, your profile will not display this. Moving to next prompt." TO WS-OUT-LINE
              PERFORM PRINT-LINE
              CONTINUE
           END-IF

           COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TOKEN))

           IF WS-LEN = 0 
               MOVE "Error: Degree is required. Exiting program." TO WS-OUT-LINE
               PERFORM PRINT-LINE
               PERFORM CLOSE-FILES
               STOP RUN
           END-IF 

           IF WS-LEN > 50
               MOVE "Error: Degree cannot exceed 50 characters. Exiting program." TO WS-OUT-LINE
               PERFORM PRINT-LINE
               PERFORM CLOSE-FILES
               STOP RUN 
           END-IF

           PERFORM CHECK-HAS-LETTER
               IF WS-HAS-LETTER = "N"
                   MOVE "Error: Degree cannot be numbers only. Exiting program" TO WS-OUT-LINE
                   PERFORM PRINT-LINE
                   PERFORM CLOSE-FILES
                   STOP RUN 
               END-IF

           MOVE WS-TOKEN TO WS-EDU-DEGREE(WS-J, WS-I)

           *>University/College
           MOVE "University/College:" TO WS-PROMPT
           PERFORM PRINT-PROMPT-AND-READ

           IF FUNCTION UPPER-CASE(FUNCTION TRIM(WS-TOKEN)) = "DONE"
              SUBTRACT 1 FROM WS-PROF-EXP-COUNT(WS-J)
              MOVE "Warning: Education is incomplete, your profile will not display this. Moving to next prompt." TO WS-OUT-LINE
              PERFORM PRINT-LINE
              CONTINUE
           END-IF

           COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-TOKEN))

           IF WS-LEN = 0 
               MOVE "Error: University/College is required. Exiting program." TO WS-OUT-LINE
               PERFORM PRINT-LINE
               PERFORM CLOSE-FILES
               STOP RUN
           END-IF 

           IF WS-LEN > 50
               MOVE "Error: University/College cannot exceed 50 characters. Exiting program." TO WS-OUT-LINE
               PERFORM PRINT-LINE
               PERFORM CLOSE-FILES
               STOP RUN 
           END-IF

           PERFORM CHECK-HAS-LETTER
               IF WS-HAS-LETTER = "N"
                   MOVE "Error: University/College cannot be numbers only. Exiting program" TO WS-OUT-LINE
                   PERFORM PRINT-LINE
                   PERFORM CLOSE-FILES
                   STOP RUN 
               END-IF
           MOVE WS-TOKEN TO WS-EDU-SCHOOL(WS-J, WS-I)

           *> Years
           MOVE "Years Attended:" TO WS-PROMPT
           PERFORM PRINT-PROMPT-AND-READ

           IF FUNCTION UPPER-CASE(FUNCTION TRIM(WS-TOKEN)) = "DONE"
              SUBTRACT 1 FROM WS-PROF-EXP-COUNT(WS-J)
              MOVE "Warning: Education is incomplete, your profile will not display this. Moving to next prompt." TO WS-OUT-LINE
              PERFORM PRINT-LINE
              CONTINUE
           END-IF

           MOVE "Y" TO WS-VALID
           PERFORM VALIDATE-YEARS-RANGE
           
           IF WS-VALID = "N" AND FUNCTION UPPER-CASE(FUNCTION TRIM(WS-TOKEN)) NOT = "DONE"
               MOVE "Error: Years Attended must be in YYYY-YYYY format (digits only). Exiting program."
                   TO WS-OUT-LINE
               PERFORM PRINT-LINE
               PERFORM CLOSE-FILES
               STOP RUN
           END-IF
           MOVE WS-TOKEN TO WS-EDU-YEARS(WS-J, WS-I)
    END-PERFORM  

    IF WS-PROF-EXP-COUNT(WS-J) = 3
       MOVE "Note: Maximum of 3 experiences reached." TO WS-OUT-LINE
       PERFORM PRINT-LINE
    END-IF     
      
    PERFORM SAVE-PROFILES

    MOVE "Profile saved." TO WS-OUT-LINE
    PERFORM PRINT-LINE

    MOVE "Press 'X' to return to menu." TO WS-PROMPT
    PERFORM PRINT-PROMPT-AND-READ

    MOVE "-------------------" TO WS-OUT-LINE
    PERFORM PRINT-LINE

    EXIT PARAGRAPH.


VIEW-PROFILE.
    PERFORM FIND-PROFILE-IDX

    IF WS-J = 0
        MOVE "No profile found for this user." TO WS-OUT-LINE
        PERFORM PRINT-LINE
        EXIT PARAGRAPH
    END-IF

    MOVE "----- PROFILE -----" TO WS-OUT-LINE
    PERFORM PRINT-LINE

    *> Name
    MOVE SPACES TO WS-OUT-LINE
    STRING "Name: "
           FUNCTION TRIM(WS-PROF-FNAME(WS-J)) " "
           FUNCTION TRIM(WS-PROF-LNAME(WS-J))
      INTO WS-OUT-LINE
    END-STRING
    PERFORM PRINT-LINE

    *> Graduation Year (numeric)
    MOVE SPACES TO WS-OUT-LINE
    STRING "Graduation Year: "
           WS-PROF-GRAD(WS-J)
      INTO WS-OUT-LINE
    END-STRING
    PERFORM PRINT-LINE

    *> Major
    MOVE SPACES TO WS-OUT-LINE
    STRING "Major: "
           FUNCTION TRIM(WS-PROF-MAJOR(WS-J))
      INTO WS-OUT-LINE
    END-STRING
    PERFORM PRINT-LINE

    *> University
    MOVE SPACES TO WS-OUT-LINE
    STRING "University: "
           FUNCTION TRIM(WS-PROF-UNIV(WS-J))
      INTO WS-OUT-LINE
    END-STRING
    PERFORM PRINT-LINE

    *> About
    MOVE SPACES TO WS-OUT-LINE
    STRING "About: "
           FUNCTION TRIM(WS-PROF-ABOUT(WS-J))
      INTO WS-OUT-LINE
    END-STRING
    PERFORM PRINT-LINE

    *> Experience
    MOVE SPACES TO WS-OUT-LINE
    STRING "Experience: "
      INTO WS-OUT-LINE
    END-STRING
    PERFORM PRINT-LINE

    IF WS-PROF-EXP-COUNT(WS-J) > 0
       PERFORM VARYING WS-K FROM 1 BY 1 
       UNTIL WS-K > WS-PROF-EXP-COUNT(WS-J)

       MOVE SPACES TO WS-OUT-LINE
       STRING "    Title: " FUNCTION TRIM(WS-EXP-TITLE(WS-J, WS-K))
         INTO WS-OUT-LINE
       END-STRING
       PERFORM PRINT-LINE

       MOVE SPACES TO WS-OUT-LINE
       STRING "    Company: " FUNCTION TRIM(WS-EXP-COMP(WS-J, WS-K))
         INTO WS-OUT-LINE
       END-STRING
       PERFORM PRINT-LINE

       MOVE SPACES TO WS-OUT-LINE
       STRING "    Dates: " FUNCTION TRIM(WS-EXP-DATES(WS-J, WS-K))
         INTO WS-OUT-LINE
       END-STRING
       PERFORM PRINT-LINE

       MOVE SPACES TO WS-OUT-LINE
       STRING "    Description: " FUNCTION TRIM(WS-EXP-DESC(WS-J, WS-K))
         INTO WS-OUT-LINE
       END-STRING
       PERFORM PRINT-LINE
     END-PERFORM 
    END-IF

    *> Education
    MOVE SPACES TO WS-OUT-LINE
    STRING "Education: "
      INTO WS-OUT-LINE
    END-STRING
    PERFORM PRINT-LINE

    IF WS-PROF-EXP-COUNT(WS-J) > 0
       PERFORM VARYING WS-K FROM 1 BY 1 
       UNTIL WS-K > WS-PROF-EXP-COUNT(WS-J)

       MOVE SPACES TO WS-OUT-LINE
       STRING "    Degree: " FUNCTION TRIM(WS-EDU-DEGREE(WS-J, WS-K))
         INTO WS-OUT-LINE
       END-STRING
       PERFORM PRINT-LINE

       MOVE SPACES TO WS-OUT-LINE
       STRING "    School: " FUNCTION TRIM(WS-EDU-SCHOOL(WS-J, WS-K))
         INTO WS-OUT-LINE
       END-STRING
       PERFORM PRINT-LINE

       MOVE SPACES TO WS-OUT-LINE
       STRING "    Years: " FUNCTION TRIM(WS-EDU-YEARS(WS-J, WS-K))
         INTO WS-OUT-LINE
       END-STRING
       PERFORM PRINT-LINE

     END-PERFORM 
    END-IF

    MOVE "-------------------" TO WS-OUT-LINE
    PERFORM PRINT-LINE

    EXIT PARAGRAPH.

SEARCH-USER.
    MOVE "Enter the full name of the person you are looking for:"
        TO WS-PROMPT
    MOVE "X" TO WS-DEST-KIND
    PERFORM PRINT-PROMPT-AND-READ

    MOVE FUNCTION TRIM(WS-TOKEN) TO WS-SEARCH-NAME
    MOVE 0 TO WS-SEARCH-IDX
    MOVE "N" TO WS-FOUND

    PERFORM VARYING WS-I FROM 1 BY 1
        UNTIL WS-I > WS-PROF-COUNT OR WS-FOUND = "Y"

        MOVE SPACES TO WS-FULL-NAME
        STRING FUNCTION TRIM(WS-PROF-FNAME(WS-I))
               " "
               FUNCTION TRIM(WS-PROF-LNAME(WS-I))
          INTO WS-FULL-NAME
        END-STRING

        IF FUNCTION TRIM(WS-FULL-NAME) =
           FUNCTION TRIM(WS-SEARCH-NAME)
            MOVE "Y" TO WS-FOUND
            MOVE WS-I TO WS-SEARCH-IDX
        END-IF
    END-PERFORM

    IF WS-FOUND = "Y"
        PERFORM DISPLAY-FOUND-PROFILE
    ELSE
        MOVE "No one by that name could be found."
            TO WS-OUT-LINE
        PERFORM PRINT-LINE
    END-IF.

DISPLAY-FOUND-PROFILE.
    MOVE "--- Found User Profile ---" TO WS-OUT-LINE
    PERFORM PRINT-LINE

    *> Name
    MOVE SPACES TO WS-OUT-LINE
    STRING "Name: "
           FUNCTION TRIM(WS-PROF-FNAME(WS-SEARCH-IDX)) " "
           FUNCTION TRIM(WS-PROF-LNAME(WS-SEARCH-IDX))
      INTO WS-OUT-LINE
    END-STRING
    PERFORM PRINT-LINE

    *> University
    MOVE SPACES TO WS-OUT-LINE
    STRING "University: "
           FUNCTION TRIM(WS-PROF-UNIV(WS-SEARCH-IDX))
      INTO WS-OUT-LINE
    END-STRING
    PERFORM PRINT-LINE

    *> Major
    MOVE SPACES TO WS-OUT-LINE
    STRING "Major: "
           FUNCTION TRIM(WS-PROF-MAJOR(WS-SEARCH-IDX))
      INTO WS-OUT-LINE
    END-STRING
    PERFORM PRINT-LINE

    *> Graduation Year
    MOVE SPACES TO WS-OUT-LINE
    STRING "Graduation Year: "
           WS-PROF-GRAD(WS-SEARCH-IDX)
      INTO WS-OUT-LINE
    END-STRING
    PERFORM PRINT-LINE

    *> About Me
    MOVE SPACES TO WS-OUT-LINE
    STRING "About Me: "
           FUNCTION TRIM(WS-PROF-ABOUT(WS-SEARCH-IDX))
      INTO WS-OUT-LINE
    END-STRING
    PERFORM PRINT-LINE

    *> Experience
    IF WS-PROF-EXP-COUNT(WS-SEARCH-IDX) = 0
        MOVE "Experience: None" TO WS-OUT-LINE
        PERFORM PRINT-LINE
    ELSE
        MOVE "Experience:" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        PERFORM VARYING WS-K FROM 1 BY 1
            UNTIL WS-K > WS-PROF-EXP-COUNT(WS-SEARCH-IDX)

            MOVE SPACES TO WS-OUT-LINE
            STRING "    Title: " FUNCTION TRIM(WS-EXP-TITLE(WS-SEARCH-IDX, WS-K))
              INTO WS-OUT-LINE
            END-STRING
            PERFORM PRINT-LINE

            MOVE SPACES TO WS-OUT-LINE
            STRING "    Company: " FUNCTION TRIM(WS-EXP-COMP(WS-SEARCH-IDX, WS-K))
              INTO WS-OUT-LINE
            END-STRING
            PERFORM PRINT-LINE

            MOVE SPACES TO WS-OUT-LINE
            STRING "    Dates: " FUNCTION TRIM(WS-EXP-DATES(WS-SEARCH-IDX, WS-K))
              INTO WS-OUT-LINE
            END-STRING
            PERFORM PRINT-LINE

            MOVE SPACES TO WS-OUT-LINE
            STRING "    Description: " FUNCTION TRIM(WS-EXP-DESC(WS-SEARCH-IDX, WS-K))
              INTO WS-OUT-LINE
            END-STRING
            PERFORM PRINT-LINE
        END-PERFORM
    END-IF

    *> Education
    IF WS-PROF-EDU-COUNT(WS-SEARCH-IDX) = 0
        MOVE "Education: None" TO WS-OUT-LINE
        PERFORM PRINT-LINE
    ELSE
        MOVE "Education:" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        PERFORM VARYING WS-K FROM 1 BY 1
            UNTIL WS-K > WS-PROF-EDU-COUNT(WS-SEARCH-IDX)

            MOVE SPACES TO WS-OUT-LINE
            STRING "    Degree: " FUNCTION TRIM(WS-EDU-DEGREE(WS-SEARCH-IDX, WS-K))
              INTO WS-OUT-LINE
            END-STRING
            PERFORM PRINT-LINE

            MOVE SPACES TO WS-OUT-LINE
            STRING "    School: " FUNCTION TRIM(WS-EDU-SCHOOL(WS-SEARCH-IDX, WS-K))
              INTO WS-OUT-LINE
            END-STRING
            PERFORM PRINT-LINE

            MOVE SPACES TO WS-OUT-LINE
            STRING "    Years: " FUNCTION TRIM(WS-EDU-YEARS(WS-SEARCH-IDX, WS-K))
              INTO WS-OUT-LINE
            END-STRING
            PERFORM PRINT-LINE
        END-PERFORM
    END-IF

    MOVE "------------------------" TO WS-OUT-LINE
    PERFORM PRINT-LINE.


PRINT-PROMPT-AND-READ.
    MOVE WS-PROMPT TO WS-OUT-LINE
    PERFORM PRINT-LINE

    PERFORM GET-NEXT-INPUT

    *> echo the user's input token
    MOVE WS-TOKEN TO WS-OUT-LINE
    PERFORM PRINT-LINE

    EVALUATE WS-DEST-KIND
        WHEN "M"
            MOVE WS-TOKEN(1:1) TO WS-MENU-CHOICE
        WHEN "U"
            MOVE WS-TOKEN TO WS-USER-IN
        WHEN "P"
            MOVE WS-TOKEN TO WS-PASS-IN
        WHEN OTHER
            CONTINUE
    END-EVALUATE.

GET-NEXT-INPUT.
    READ IN-FILE
        AT END
            MOVE "Y" TO WS-IN-EOF
            PERFORM EXIT-AT-EOF
        NOT AT END
            MOVE IN-REC TO WS-TOKEN
    END-READ.

EXIT-AT-EOF.
    MOVE "Input file ended. Exiting program." TO WS-OUT-LINE
    PERFORM PRINT-LINE
    PERFORM CLOSE-FILES
    STOP RUN.

PRINT-LINE.
    DISPLAY WS-OUT-LINE
    MOVE WS-OUT-LINE TO OUT-REC
    WRITE OUT-REC.

CLOSE-FILES.
    CLOSE IN-FILE
    CLOSE OUT-FILE.
    