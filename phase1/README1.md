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


### SQL Scripts

Provide the following SQL scripts:

- **Create Tables Script** - The SQL script for creating the database tables is available in the repository:

📜 **[View `create_tables.sql`](scripts/create_tables.sql)**

- **Insert Data Script** - The SQL script for insert data to the database tables is available in the repository:

📜 **[View `insert_tables.sql`](scripts/insert_tables.sql)**

- **Drop Tables Script** - The SQL script for droping all tables is available in the repository:

📜 **[View `drop_tables.sql`](scripts/drop_tables.sql)**

- **Select All Data Script** - The SQL script for selectAll tables is available in the repository:

📜 **[View `select_all.sql`](scripts/select_all.sql)** - **Count All Data Script** - The SQL script for countAll tables is available in the repository:

📜 **[View `count_all.sql`](scripts/count_all.sql)** #### First tool: using [mockaro](https://www.mockaroo.com/)

![](screenshots/mockaroo.png)

📜 **[View `mockarooFiles`](/mockarooFiles)** #### Second tool: using python script to create csv file from imported real data

📜 **[View `DAILY_PUZZLES.py`](/programming/DAILY_PUZZLES.py)** 📜 **[View `DAILY_PUZZLES.py`](/programming/PUZZLE_ATTEMPT.py)** #### Third tool: using python script to create csv file from imported real data

📜 **[View `puzzles_and_tags.py`](/programming/puzzles_and_tags.py)** ####  After running the `create_tables.sql`, `insert_tables.sql` and `count_all.sql` scripts, we can see the following result:

![Count All Data](screenshots/count_all.png)

### Backup

#### First Way: Using pgadmin interface:

![](screenshots/backuping_pgadmin.png)

![](screenshots/backuping_pgadmin_success.png)

![](screenshots/restore_pgadmin.png)

#### Second Way: Using CLI:

![](screenshots/backup_with_cli.png)

![](screenshots/restore_with_cli.png)

---
