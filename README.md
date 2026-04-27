# Chess Learning & Puzzles Platform 

[Your Name / Partner's Name] Example

## Table of Contents  
- [Phase 1: Design and Build the Database](#phase-1-design-and-build-the-database)  
  - [Introduction](#introduction)  
  - [ERD (Entity-Relationship Diagram)](#erd-entity-relationship-diagram)  
  - [DSD (Data Structure Diagram)](#dsd-data-structure-diagram)  
  - [SQL Scripts](#sql-scripts)  
  - [Data](#data)
  - [Backup](#backup)  
- [Phase 2: Integration](#phase-2-integration)  

## Phase 1: Design and Build the Database  

### Introduction

The **Chess Learning & Puzzles Database** is designed to efficiently manage an educational platform where users can enroll in courses, read chapters, and solve chess puzzles. This system ensures smooth organization and tracking of user progress, course structures, puzzle difficulty, and daily challenges.

#### Purpose of the Database
This database serves as a structured and reliable solution for the platform to:  
- **Manage courses and chapters**, allowing structured content delivery to users.  
- **Store chess puzzles**, including FEN strings, solution moves, tags, and difficulty ratings (ELO).  
- **Track user attempts**, recording success rates and time taken to solve puzzles.  
- **Monitor course progress**, keeping track of when users start and complete specific courses.  
- **Offer Daily Puzzles** with unique dates and bonus XP rewards for consistent engagement.  

#### Potential Use Cases
- **Platform Administrators / Instructors** can use this database to create new courses, upload puzzles, and assign daily challenges.  
- **Users (Students/Players)** can track their learning progress, review their puzzle-solving history, and see their course completion status.  
- **System Analytics** can utilize the puzzle attempt records to adjust the difficulty ELO of puzzles based on how many users succeed or fail, and calculate the average time taken.  

This structured database helps streamline the e-learning experience, improving content organization and user tracking.

###  ERD (Entity-Relationship Diagram)   
![ERD Diagram](phase1\diagrams\ERD.png)  

###  DSD (Data Structure Diagram)   
![DSD Diagram](phase1\diagrams\DSD.png)  

###  SQL Scripts  
Provide the following SQL scripts:  
- **Create Tables Script** - The SQL script for creating the database tables is available in the repository:  

📜 **[View `create_tables.sql`](Phase1/scripts/ChessPlatformCreateTable.sql)** - **Insert Data Script** - The SQL script for insert data to the database tables is available in the repository:  

📜 **[View `insert_tables.sql`](Phase1/scripts/ChessPlatformInserts.sql)** - **Drop Tables Script** - The SQL script for droping all tables is available in the repository:  

📜 **[View `drop_tables.sql`](Phase1/scripts/ChessPlatformDropTable.sql)** - **Select All Data Script** - The SQL script for selectAll tables is available in the repository:  

📜 **[View `selectAll_tables.sql`](Phase1/scripts/ChessPlatformSelectAll.sql)** ###  Data  
####  First tool: using [mockaro](https://www.mockaroo.com/) to create csv file
#####  Entering data to USERS table
-  user_id scope 1-5000
📜[View `usersMock_data.csv`](Phase1/mockData/Users_MOCK_DATA.csv)

#####  Entering data to TAGS table
-  tag_id scope 1-100
📜[View `tagsMock_data.csv`](Phase1/mockData/Tags_MOCK_DATA.csv)

![image](https://github.com/user-attachments/assets/[YOUR-IMAGE-LINK-HERE])
results for the command `SELECT COUNT(*) FROM USERS;`:
<br>
![image](https://github.com/user-attachments/assets/[YOUR-IMAGE-LINK-HERE])

####  Second tool: using [generatedata](https://generatedata.com/generator). to create csv file 
#####  Entering data to COURSES and CHAPTERS tables
-  course_id scope 1-500 
-  chapter_id scope 1-2000
📜[View `coursesGenerateData.csv`](Phase1/generateData/coursesGenerateData.csv)

![image](https://github.com/user-attachments/assets/[YOUR-IMAGE-LINK-HERE])

#####  Entering data to PUZZLES table
-  puzzle_id scope 1-1000
-  tag_id range 1-100

📜[View `puzzlesGenerateData.csv`](Phase1/generateData/puzzlesGenerateData.csv)
![image](https://github.com/user-attachments/assets/[YOUR-IMAGE-LINK-HERE])

results for the command `SELECT COUNT(*) FROM PUZZLES;`:
<br>
![image](https://github.com/user-attachments/assets/[YOUR-IMAGE-LINK-HERE])


####  Third tool: using python to create csv file
#####  Entering data to DAILY_PUZZLES table
- 20,000 records with unique puzzle_date
- bonus_xp randomly assigned
📜[View `daily_puzzles.csv`](Phase1/pythonData/daily_puzzles.csv)

#####  Entering data to PUZZLE_ATTEMPT table
- 20,000 records integrating user_id and puzzle_id
- Randomized is_successful and time_taken_sec
📜[View `puzzle_attempt.csv`](Phase1/pythonData/puzzle_attempt.csv)

![image](https://github.com/user-attachments/assets/[YOUR-IMAGE-LINK-HERE])
results for the command `SELECT COUNT(*) FROM PUZZLE_ATTEMPT;`:
<br>
![image](https://github.com/user-attachments/assets/[YOUR-IMAGE-LINK-HERE])

### Backup 
-   backups files are kept with the date and hour of the backup:  

[עבור לתיקיית הגיבויים](Phase1/Backup)

## Phase 2: Integration 
[Your Phase 2 details will go here]
