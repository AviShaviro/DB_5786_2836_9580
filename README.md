# Chess Learning & Puzzles Platform

Authors: Avraham Shaviro & Shraga Chesrak

## Table of Contents

- [Chess Learning \& Puzzles Platform](#chess-learning--puzzles-platform)
  - [Table of Contents](#table-of-contents)
  - [Phase 1: Design and Build the Database](#phase-1-design-and-build-the-database)
    - [Introduction](#introduction)
      - [Purpose of the Database](#purpose-of-the-database)
      - [Potential Use Cases](#potential-use-cases)
    - [ERD (Entity-Relationship Diagram)](#erd-entity-relationship-diagram)
    - [DSD (Data Structure Diagram)](#dsd-data-structure-diagram)
    - [SQL Scripts](#sql-scripts)
    - [Backup](#backup)
      - [First Way: Using pgadmin interface:](#first-way-using-pgadmin-interface)
      - [Second Way: Using CLI:](#second-way-using-cli)
  - [Phase 2: Integration](#phase-2-integration)
    - [שאילתות SELECT כפולות](#שאילתות-select-כפולות)
    - [שאילתות SELECT נוספות](#שאילתות-select-נוספות)
    - [שאילתות UPDATE ו-DELETE](#שאילתות-update-ו-delete)
    - [אילוצים (Constraints)](#אילוצים-constraints)
    - [טרנזקציות (Commit \& Rollback)](#טרנזקציות-commit--rollback)
    - [אינדקסים (Indexes)](#אינדקסים-indexes)

### Introduction

The **Chess Learning & Puzzles Database** is designed to efficiently manage an educational platform where users can enroll in courses, read chapters, and solve chess puzzles. This system ensures smooth organization and tracking of user progress, course structures, puzzle difficulty, and daily challenges.

#### Purpose of the Database

This database serves as a structured and reliable solution for the platform to:

- **Manage courses and chapters**, allowing structured content delivery to users.
- **Store chess puzzles**, including FEN strings, solution moves, tags, and difficulty ratings (ELO).
- **Track user attempts**, recording success rates and time taken to solve puzzles.
- **Monitor chapter progress**, keeping track of when users start and complete specific chapters.
- **Offer Daily Puzzles** with unique dates and bonus XP rewards for consistent engagement.

#### Potential Use Cases

- **Platform Administrators / Instructors** can use this database to create new courses, upload puzzles, and assign daily challenges.
- **Users (Students/Players)** can track their learning progress, review their puzzle-solving history, and see their chapter completion status.
- **System Analytics** can utilize the puzzle attempt records to adjust the difficulty ELO of puzzles based on how many users succeed or fail, and calculate the average time taken.

This structured database helps streamline the e-learning experience, improving content organization and user tracking.

### ERD (Entity-Relationship Diagram)

![ERD Diagram](phase1/diagrams/ERD.png)

### DSD (Data Structure Diagram)

![DSD Diagram](phase1/diagrams/DSD.png)
