# InCollege (CEN4020) – File-Driven COBOL App

This project simulates a basic “InCollege” networking app. All interaction is **file-driven**:
- **Input** is read from `data/InCollege-Input.txt`
- Output is shown in the console **and** written to `out/InCollege-Output.txt`
- Account/profile data is stored persistently in the `data/` folder

---

## How to Run

### 1) Compile
From the project root:
```bash
cobc -x -o InCollege src/*.cob
2) Prepare Input
Edit or replace the input file:

data/InCollege-Input.txt

All menu selections, text responses, and search queries must be placed in this file in the exact order the program prompts for them (one line per user entry).

3) Run
./InCollege
Files You Should Know
Input
data/InCollege-Input.txt
Contains the pre-scripted inputs (menu choices, usernames/passwords, profile entries, search queries, etc.)

Output
out/InCollege-Output.txt
Contains the exact same output that is printed to the console during execution.

Persistent Data
These files store data between runs (they can be deleted and re-generated on the next run):

data/InCollege-Accounts.txt – stores account/user login data

data/InCollege-Profiles.txt – stores profile data (about me, education, experience, etc.)

Tip: For clean testing, you can clear these files before running so you start fresh.

New Functionality: Profile Viewing & Basic Search (Week 3)
1) View My Profile (Enhanced)
The “View My Profile” option displays the full profile for the currently logged-in user, including:

First Name + Last Name

University/College

Major

Graduation Year

About Me

Experience entries

Education entries

How to test via input file:

Log in to an existing account (or create one).

Navigate to profile creation/edit steps and enter profile details.

Choose “View My Profile” from the menu.

Where to find the result:

Console output, and also in out/InCollege-Output.txt
Search in the output file for the “View My Profile” section to verify formatting and completeness.

2) Find S

