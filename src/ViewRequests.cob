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
       01  WS-EOF                      PIC 9 VALUE 0.
       01  WS-REQUEST-COUNT            PIC 99 VALUE 0.
       01  WS-DISPLAY-LINE             PIC X(200).
       01  WS-TEMP-SENDER              PIC X(20).
       01  WS-TEMP-RECIPIENT           PIC X(20).
       01  WS-TEMP-STATUS              PIC X(10).

       LINKAGE SECTION.
       01  LS-CURRENT-USER             PIC X(20).

       PROCEDURE DIVISION USING LS-CURRENT-USER.

       MAIN-VIEW-REQUESTS.
           MOVE LS-CURRENT-USER TO WS-CURRENT-USER.

           OPEN EXTEND OUTPUT-FILE.

           PERFORM DISPLAY-HEADER.
           PERFORM READ-AND-DISPLAY-REQUESTS.

           IF WS-REQUEST-COUNT = 0
               PERFORM DISPLAY-NO-REQUESTS
           ELSE
               PERFORM DISPLAY-FOOTER
           END-IF.

           CLOSE OUTPUT-FILE.
           GOBACK.

       DISPLAY-HEADER.
           MOVE "----- PENDING CONNECTION REQUESTS -----"
               TO WS-DISPLAY-LINE.
           PERFORM WRITE-OUTPUT-LINE.
           MOVE " " TO WS-DISPLAY-LINE.
           PERFORM WRITE-OUTPUT-LINE.

       READ-AND-DISPLAY-REQUESTS.
           OPEN INPUT CONNECTION-FILE.

           IF WS-CONN-FILE-STATUS NOT = "00" AND
              WS-CONN-FILE-STATUS NOT = "35"
               MOVE "Error opening connections file."
                   TO WS-DISPLAY-LINE
               PERFORM WRITE-OUTPUT-LINE
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
           MOVE SPACES TO WS-DISPLAY-LINE.
           STRING "Request from: " DELIMITED BY SIZE
                  WS-TEMP-SENDER DELIMITED BY " "
                  INTO WS-DISPLAY-LINE
           END-STRING.
           PERFORM WRITE-OUTPUT-LINE.

           MOVE " " TO WS-DISPLAY-LINE.
           PERFORM WRITE-OUTPUT-LINE.

       DISPLAY-NO-REQUESTS.
           MOVE "You have no pending connection requests."
               TO WS-DISPLAY-LINE.
           PERFORM WRITE-OUTPUT-LINE.
           MOVE " " TO WS-DISPLAY-LINE.
           PERFORM WRITE-OUTPUT-LINE.

       DISPLAY-FOOTER.
           MOVE SPACES TO WS-DISPLAY-LINE.
           STRING "Total pending requests: " DELIMITED BY SIZE
                  WS-REQUEST-COUNT DELIMITED BY SIZE
                  INTO WS-DISPLAY-LINE
           END-STRING.
           PERFORM WRITE-OUTPUT-LINE.

           MOVE "-------------------" TO WS-DISPLAY-LINE.
           PERFORM WRITE-OUTPUT-LINE.

       WRITE-OUTPUT-LINE.
           DISPLAY WS-DISPLAY-LINE.
           MOVE WS-DISPLAY-LINE TO OUTPUT-RECORD.
           WRITE OUTPUT-RECORD.