       >>SOURCE FORMAT FREE
IDENTIFICATION DIVISION.
PROGRAM-ID. InCollege.

ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    SELECT IN-FILE ASSIGN TO "data/InCollege-Input.txt"
        ORGANIZATION IS LINE SEQUENTIAL.
    SELECT OUT-FILE ASSIGN TO "out/InCollege-Output.txt"
        ORGANIZATION IS LINE SEQUENTIAL.
    SELECT ACC-FILE ASSIGN TO "data/InCollege-Accounts.txt"
        ORGANIZATION IS LINE SEQUENTIAL
        FILE STATUS IS WS-ACC-STATUS.

DATA DIVISION.
FILE SECTION.

FD  IN-FILE.
01  IN-REC                 PIC X(120).

FD  OUT-FILE.
01  OUT-REC                PIC X(200).

FD  ACC-FILE.
01  ACC-REC.
    05 ACC-USER            PIC X(20).
    05 ACC-PASS            PIC X(12).

WORKING-STORAGE SECTION.

01  WS-FLAGS.
    05 WS-IN-EOF           PIC X VALUE "N".
    05 WS-ACC-EOF          PIC X VALUE "N".
    05 WS-DONE             PIC X VALUE "N".

01  WS-ACC-STATUS           PIC XX VALUE "00".

01  WS-INPUT.
    05 WS-TOKEN             PIC X(120) VALUE SPACES.
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
    05 WS-FOUND             PIC X VALUE "N".
    05 WS-VALID             PIC X VALUE "N".
    05 WS-LEN               PIC 9(3) VALUE 0.
    05 WS-HAS-UPPER         PIC X VALUE "N".
    05 WS-HAS-DIGIT         PIC X VALUE "N".
    05 WS-HAS-SPECIAL       PIC X VALUE "N".
    05 WS-CHAR              PIC X VALUE SPACE.

PROCEDURE DIVISION.

MAIN.
    PERFORM INIT-FILES
    PERFORM LOAD-ACCOUNTS
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
    PERFORM UNTIL WS-MENU-CHOICE = "4"
        MOVE "1. Search for a job" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "2. Find someone you know" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "3. Learn a new skill" TO WS-OUT-LINE
        PERFORM PRINT-LINE
        MOVE "4. Logout" TO WS-OUT-LINE
        PERFORM PRINT-LINE

        MOVE "Enter your choice:" TO WS-PROMPT
        MOVE "M" TO WS-DEST-KIND
        PERFORM PRINT-PROMPT-AND-READ

        EVALUATE WS-MENU-CHOICE
            WHEN "1"
                MOVE "Job search is under construction." TO WS-OUT-LINE
                PERFORM PRINT-LINE
            WHEN "2"
                MOVE "Find someone you know is under construction." TO WS-OUT-LINE
                PERFORM PRINT-LINE
            WHEN "3"
                PERFORM LEARN-A-NEW-SKILL
            WHEN "4"
                EXIT PERFORM
            WHEN OTHER
                MOVE "Invalid choice. Please enter 1-4." TO WS-OUT-LINE
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

