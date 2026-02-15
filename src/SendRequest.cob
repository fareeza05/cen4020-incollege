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
           SELECT OUTPUT-FILE ASSIGN TO
               "data/InCollege-Output.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-OUT-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  CONNECTION-FILE.
       01  CONNECTION-RECORD.
           05  CONN-SENDER             PIC X(20).
           05  FILLER                  PIC X VALUE "|".
           05  CONN-RECIPIENT          PIC X(20).
           05  FILLER                  PIC X VALUE "|".
           05  CONN-STATUS             PIC X(10).

       FD  OUTPUT-FILE.
       01  OUTPUT-RECORD               PIC X(200).

       WORKING-STORAGE SECTION.
       01  WS-CONN-FILE-STATUS         PIC XX.
       01  WS-OUT-FILE-STATUS          PIC XX.
       01  WS-CURRENT-USER             PIC X(20).
       01  WS-TARGET-USER              PIC X(20).
       01  WS-REQUEST-VALID            PIC 9 VALUE 1.
       01  WS-DISPLAY-LINE             PIC X(200).

       LINKAGE SECTION.
       01  LS-CURRENT-USER             PIC X(20).
       01  LS-TARGET-USER              PIC X(20).

       PROCEDURE DIVISION USING LS-CURRENT-USER
                                LS-TARGET-USER.

       MAIN-SEND-REQUEST.
           MOVE LS-CURRENT-USER TO WS-CURRENT-USER.
           MOVE LS-TARGET-USER TO WS-TARGET-USER.

           OPEN EXTEND OUTPUT-FILE.

           PERFORM VALIDATE-REQUEST.

           IF WS-REQUEST-VALID = 1
               PERFORM WRITE-CONNECTION-REQUEST
               PERFORM DISPLAY-SUCCESS-MESSAGE
           END-IF.

           CLOSE OUTPUT-FILE.
           GOBACK.

       VALIDATE-REQUEST.
      *    Placeholder - teammate will implement validation logic
      *    For now, assume all requests are valid
           MOVE 1 TO WS-REQUEST-VALID.

       WRITE-CONNECTION-REQUEST.
      *    Placeholder - teammate will implement write logic
      *    For now, just acknowledge
           CONTINUE.

       DISPLAY-SUCCESS-MESSAGE.
           MOVE "Connection request sent successfully!"
               TO WS-DISPLAY-LINE.
           PERFORM WRITE-OUTPUT-LINE.

       WRITE-OUTPUT-LINE.
           DISPLAY WS-DISPLAY-LINE.
           MOVE WS-DISPLAY-LINE TO OUTPUT-RECORD.
           WRITE OUTPUT-RECORD.