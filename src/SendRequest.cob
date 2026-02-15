       >>SOURCE FORMAT FREE
IDENTIFICATION DIVISION.
       PROGRAM-ID. SENDREQUEST.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CONNECTION-FILE ASSIGN TO
               "data/InCollege-Connections.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-CONN-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  CONNECTION-FILE.
       01  CONNECTION-RECORD.
           05  CONN-SENDER             PIC X(20).
           05  FILLER                  PIC X VALUE "|".
           05  CONN-RECIPIENT          PIC X(20).
           05  FILLER                  PIC X VALUE "|".
           05  CONN-STATUS             PIC X(10).

       WORKING-STORAGE SECTION.
       01  WS-CONN-FILE-STATUS         PIC XX.
       01  WS-CURRENT-USER             PIC X(20).
       01  WS-TARGET-USER              PIC X(20).
       01  WS-REQUEST-VALID            PIC 9 VALUE 1.
       01  WS-OUTPUT-FILE              PIC X(50)
           VALUE "out/InCollege-Output.txt".
       01  WS-OUTPUT-FD                PIC 9(4) COMP.

       LINKAGE SECTION.
       01  LS-CURRENT-USER             PIC X(20).
       01  LS-TARGET-USER              PIC X(20).
       01  LS-OUTPUT-FD                PIC 9(4) COMP.

       PROCEDURE DIVISION USING LS-CURRENT-USER
                                LS-TARGET-USER
                                LS-OUTPUT-FD.

       MAIN-SEND-REQUEST.
           MOVE LS-CURRENT-USER TO WS-CURRENT-USER.
           MOVE LS-TARGET-USER TO WS-TARGET-USER.
           MOVE LS-OUTPUT-FD TO WS-OUTPUT-FD.

           PERFORM VALIDATE-REQUEST.

           IF WS-REQUEST-VALID = 1
               PERFORM WRITE-CONNECTION-REQUEST
               PERFORM DISPLAY-SUCCESS-MESSAGE
           END-IF.

           GOBACK.

       VALIDATE-REQUEST.
      *    Placeholder - teammate will implement validation logic
           MOVE 1 TO WS-REQUEST-VALID.

       WRITE-CONNECTION-REQUEST.
      *    Placeholder - teammate will implement write logic
           CONTINUE.

       DISPLAY-SUCCESS-MESSAGE.
           DISPLAY "Connection request sent successfully!".
           CALL "write_to_file" USING WS-OUTPUT-FD
               "Connection request sent successfully!".