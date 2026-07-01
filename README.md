# Chess Learning & Puzzles Platform

**Authors:** Avraham Shaviro & Shraga Chesrak  
**IDs:** 325239580 , 322232836 
**Course:** Database Mini-Project — 2026

---

## Project Overview

A relational database mini project — a platform where users enroll in courses, study chapters, and solve chess puzzles. The project is built incrementally across five phases, each adding a new layer to the system.

The database manages:
- Users, courses, chapters, and chapter progress
- A puzzle repository (FEN strings, difficulty ELO, tags)
- Daily puzzles with XP bonuses
- Full attempt tracking per user per puzzle

---

## Phases

### Phase 1 — Design, Build & Data Population
**Folder:** [`phase1/`](phase1/) | **Report:** [`phase1/README.md`](phase1/README.md)

ERD and DSD design, table creation scripts, and data population via three methods (Python/Mockaroo, pgAdmin CSV import, and SQL `INSERT` statements)

### Phase 2 — Queries, Constraints & Transactions
**Folder:** [`phase2/`](phase2/) | **Report:** [`phase2/README.md`](phase2/README.md)

Analytical `SELECT` queries, paired queries for efficiency comparison, `UPDATE`/`DELETE` statements, `CHECK`/`UNIQUE` constraints, `COMMIT`/`ROLLBACK` transaction demos, and indexes.

### Phase 3 — Integration & Views
**Folder:** [`phase3/`](phase3/) | **Report:** [`phase3/README.md`](phase3/README.md)

Schema-level integration (Method A) of a second department's system (Users & Clubs, pair 8309_7002) into the database. Includes a reverse-engineering walkthrough, integration decisions, and two SQL views with analytical queries on the merged schema.

### Phase 4 — PL/pgSQL Programming
**Folder:** [`phase4/`](phase4/) | **Report:** [`phase4/README.md`](phase4/README.md)

Stored programming logic: 2 functions, 2 procedures, 2 triggers, and 2 main programs. Covers implicit/explicit cursors, ref cursors, records, DML inside PL/pgSQL, exception handling, and `BEFORE UPDATE` triggers.

### Phase 5 — Application Layer
**Folder:** [`phase5/`](phase5/) | **Report:** [`phase5/README.md`](phase5/README.md)

A **Streamlit** web app that provides a graphical interface over the `combined_db` PostgreSQL database. Connects automatically to `localhost:5432` using the `shraga` user.

**Pages:**

| Page | Description |
|------|-------------|
| Dashboard (`app.py`) | Stat cards, course overview, daily puzzle preview |
| Courses | Browse courses, track chapter progress, add courses/chapters |
| Puzzles | Puzzle viewer with rendered chess board (SVG via `python-chess`) |
| Daily Puzzle | Daily challenge, weekly streak, awards XP via `pr_award_daily_puzzle_xp` |
| Admin CRUD | Full create/read/update/delete for all 14 tables with FK resolution |
| Queries | 6 analytical queries from Phase 2 |
| Views | 2 views and their queries from Phase 3 |
| Functions | All 4 PL/pgSQL routines from Phase 4 (2 functions + 2 procedures) |

**To run:**
```bash
cd phase5
python3.11 -m streamlit run app.py
# Opens at http://localhost:8501
```

---

## Quick Start

> Requires Docker Desktop.

1. Copy `.env.example` to `.env` and fill in the values.
2. Start the database:
   ```bash
   docker compose up -d
   ```
3. Restore the latest backup (e.g. phase 4):
   ```bash
   docker exec -i PostgreSQL_DB psql -U shraga -d combined_db < phase4/backup4.sql
   ```
4. Connect via pgAdmin at `http://localhost:8080`.

See the individual phase READMEs for phase-specific setup steps.

---

## Repository Structure

```
.
├── phase1/          Design, build, data population
├── phase2/          Queries, constraints, transactions
├── phase3/          Integration with second department + views
├── phase4/          PL/pgSQL functions, procedures, triggers
├── phase5/          Application layer
├── docker-compose.yml
├── backup.bat       Windows backup helper
├── restore.bat      Windows restore helper
└── .env             (gitignored — copy from .env.example)
```
