>>SOURCE FORMAT FREE
       IDENTIFICATION DIVISION.
       PROGRAM-ID. VIEWREQUESTS.

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
       01  WS-EOF                      PIC 9 VALUE 0.
       01  WS-REQUEST-COUNT            PIC 99 VALUE 0.
       01  WS-DISPLAY-LINE             PIC X(100).
       01  WS-OUTPUT-FILE              PIC X(50)
           VALUE "out/InCollege-Output.txt".
       01  WS-OUTPUT-FD                PIC 9(4) COMP.
       01  WS-TEMP-SENDER              PIC X(20).
       01  WS-TEMP-RECIPIENT           PIC X(20).
       01  WS-TEMP-STATUS              PIC X(10).

       LINKAGE SECTION.
       01  LS-CURRENT-USER             PIC X(20).
       01  LS-OUTPUT-FD                PIC 9(4) COMP.

       PROCEDURE DIVISION USING LS-CURRENT-USER
                                LS-OUTPUT-FD.

       MAIN-VIEW-REQUESTS.
           MOVE LS-CURRENT-USER TO WS-CURRENT-USER.
           MOVE LS-OUTPUT-FD TO WS-OUTPUT-FD.

           PERFORM DISPLAY-HEADER.
           PERFORM READ-AND-DISPLAY-REQUESTS.

           IF WS-REQUEST-COUNT = 0
               PERFORM DISPLAY-NO-REQUESTS
           ELSE
               PERFORM DISPLAY-FOOTER
           END-IF.

           GOBACK.

       DISPLAY-HEADER.
           DISPLAY "----- PENDING CONNECTION REQUESTS -----".
           CALL "write_to_file" USING WS-OUTPUT-FD
               "----- PENDING CONNECTION REQUESTS -----".
           DISPLAY " ".
           CALL "write_to_file" USING WS-OUTPUT-FD " ".

       READ-AND-DISPLAY-REQUESTS.
           OPEN INPUT CONNECTION-FILE.

           IF WS-CONN-FILE-STATUS NOT = "00" AND
              WS-CONN-FILE-STATUS NOT = "35"
               DISPLAY "Error opening connections file."
               CALL "write_to_file" USING WS-OUTPUT-FD
                   "Error opening connections file."
               GO TO CLOSE-CONNECTION-FILE
           END-IF.

           IF WS-CONN-FILE-STATUS = "35"
      *        File doesn't exist yet - no requests
               MOVE 0 TO WS-REQUEST-COUNT
               GO TO CLOSE-CONNECTION-FILE
           END-IF.

           MOVE 0 TO WS-EOF.
           MOVE 0 TO WS-REQUEST-COUNT.

           PERFORM UNTIL WS-EOF = 1
               READ CONNECTION-FILE
                   AT END
                       MOVE 1 TO WS-EOF
                   NOT AT END
                       PERFORM PROCESS-CONNECTION-RECORD
               END-READ
           END-PERFORM.

       CLOSE-CONNECTION-FILE.
           CLOSE CONNECTION-FILE.

       PROCESS-CONNECTION-RECORD.
      *    Parse the record
           MOVE CONN-SENDER TO WS-TEMP-SENDER.
           MOVE CONN-RECIPIENT TO WS-TEMP-RECIPIENT.
           MOVE CONN-STATUS TO WS-TEMP-STATUS.

      *    Check if this is a pending request TO the current user
           IF WS-TEMP-RECIPIENT = WS-CURRENT-USER AND
              WS-TEMP-STATUS = "PENDING"
               ADD 1 TO WS-REQUEST-COUNT
               PERFORM DISPLAY-SINGLE-REQUEST
           END-IF.

       DISPLAY-SINGLE-REQUEST.
           STRING "Request from: " DELIMITED BY SIZE
                  WS-TEMP-SENDER DELIMITED BY " "
                  INTO WS-DISPLAY-LINE
           END-STRING.

           DISPLAY WS-DISPLAY-LINE.
           CALL "write_to_file" USING WS-OUTPUT-FD
               WS-DISPLAY-LINE.

           DISPLAY " ".
           CALL "write_to_file" USING WS-OUTPUT-FD " ".

       DISPLAY-NO-REQUESTS.
           DISPLAY "You have no pending connection requests.".
           CALL "write_to_file" USING WS-OUTPUT-FD
               "You have no pending connection requests.".
           DISPLAY " ".
           CALL "write_to_file" USING WS-OUTPUT-FD " ".

       DISPLAY-FOOTER.
           STRING "Total pending requests: " DELIMITED BY SIZE
                  WS-REQUEST-COUNT DELIMITED BY SIZE
                  INTO WS-DISPLAY-LINE
           END-STRING.

           DISPLAY WS-DISPLAY-LINE.
           CALL "write_to_file" USING WS-OUTPUT-FD
               WS-DISPLAY-LINE.
           DISPLAY "-------------------".
           CALL "write_to_file" USING WS-OUTPUT-FD
               "-------------------".