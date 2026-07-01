-- =====================================================================
-- SeedDemoData.sql
-- ---------------------------------------------------------------------
-- The generated mock data is very uniform (solve times 15-900s, all
-- attempts in 2023, ~65% success), so several threshold-based queries in
-- Queries.sql return 0 rows. This script seeds a small amount of clearly
-- marked DEMO data so each of those queries returns a few rows for the
-- Phase 2 screenshots.
--
-- Queries this script makes non-empty:
--   Q1  - user with >=20 attempts and <20% success
--   Q2  - puzzle with >=10 plays, <10% success, avg time > 300s
--   Q5  - puzzle never used as daily, >50 plays, >80% success
--   Q6  - tag with >100 attempts and <25% success
--   Update 1 - puzzle whose average solve time is < 10s
--   Delete 1 - attempts dated before 2000
--   Delete 2 - chapter_progress started before 2000
--   Delete 3 - a course with no chapters
--
-- All demo rows are isolated and identifiable:
--   * puzzles      : fen_string LIKE 'DEMO/%'
--   * tag          : tag_name = 'DEMO_HARD_TOPIC'
--   * empty course : title = 'DEMO_EMPTY_COURSE'
--   * demo users   : the users created here (only attempt DEMO puzzles)
--
-- The script is IDEMPOTENT: it first removes any previously seeded demo
-- data, so it is safe to run multiple times. To remove the demo data
-- entirely, run CleanupDemoData.sql.
-- =====================================================================

-- ---------------------------------------------------------------------
-- STEP 1: remove any demo data from a previous run (idempotent)
-- ---------------------------------------------------------------------
DO $$
DECLARE
    demo_users INT[];
BEGIN
    SELECT array_agg(DISTINCT u) INTO demo_users FROM (
        SELECT pa.user_id AS u
        FROM PUZZLE_ATTEMPT pa
        JOIN PUZZLES p ON pa.puzzle_id = p.puzzle_id
        WHERE p.fen_string LIKE 'DEMO/%'
        UNION
        SELECT user_id FROM COURSES WHERE title = 'DEMO_EMPTY_COURSE'
    ) s;
    IF demo_users IS NULL THEN demo_users := ARRAY[]::INT[]; END IF;

    DELETE FROM PUZZLE_ATTEMPT
     WHERE puzzle_id IN (SELECT puzzle_id FROM PUZZLES WHERE fen_string LIKE 'DEMO/%')
        OR user_id = ANY(demo_users)
        OR attempt_date < '2000-01-01';
    DELETE FROM CHAPTER_PROGRESS
     WHERE user_id = ANY(demo_users)
        OR start_date < '2000-01-01';
    DELETE FROM DAILY_PUZZLES
     WHERE puzzle_id IN (SELECT puzzle_id FROM PUZZLES WHERE fen_string LIKE 'DEMO/%');
    DELETE FROM CHAPTERS
     WHERE course_id IN (SELECT course_id FROM COURSES
                          WHERE title = 'DEMO_EMPTY_COURSE' OR user_id = ANY(demo_users));
    DELETE FROM COURSES
     WHERE title = 'DEMO_EMPTY_COURSE' OR user_id = ANY(demo_users);
    DELETE FROM PUZZLES   WHERE fen_string LIKE 'DEMO/%';
    DELETE FROM TAGS      WHERE tag_name = 'DEMO_HARD_TOPIC';
    DELETE FROM USERS     WHERE user_id = ANY(demo_users);
END $$;

-- ---------------------------------------------------------------------
-- STEP 1.5: resync SERIAL sequences with the existing data.
-- The mock data was loaded with explicit IDs without advancing the
-- sequences, so nextval() would collide with existing keys. Fix that.
-- ---------------------------------------------------------------------
DO $$
BEGIN
    PERFORM setval(pg_get_serial_sequence('users','user_id'),
                   GREATEST((SELECT MAX(user_id) FROM users), 1));
    PERFORM setval(pg_get_serial_sequence('tags','tag_id'),
                   GREATEST((SELECT MAX(tag_id) FROM tags), 1));
    PERFORM setval(pg_get_serial_sequence('puzzles','puzzle_id'),
                   GREATEST((SELECT MAX(puzzle_id) FROM puzzles), 1));
    PERFORM setval(pg_get_serial_sequence('courses','course_id'),
                   GREATEST((SELECT MAX(course_id) FROM courses), 1));
    PERFORM setval(pg_get_serial_sequence('chapter_progress','chapter_progress_id'),
                   GREATEST((SELECT MAX(chapter_progress_id) FROM chapter_progress), 1));
    PERFORM setval(pg_get_serial_sequence('puzzle_attempt','attempt_id'),
                   GREATEST((SELECT MAX(attempt_id) FROM puzzle_attempt), 1));
END $$;

-- ---------------------------------------------------------------------
-- STEP 2: seed fresh demo data
-- ---------------------------------------------------------------------
DO $$
DECLARE
    v_chapter   INT;          -- an existing chapter (for the pre-2000 progress rows)
    v_real_tag  INT;          -- an existing tag (Q2 INNER-JOINs TAGS, so demo puzzles need a tag)
    u_struggle  INT;          -- the user for Q1
    u_bulk      INT[] := ARRAY[]::INT[];   -- users for the bulk attempts
    p_fast      INT;          -- Update 1
    p_hard      INT;          -- Q2
    p_popular   INT;          -- Q5
    p_struggle  INT;          -- Q1 (isolated puzzle so it skews nothing else)
    v_demo_tag  INT;          -- Q6
    p_tag       INT[] := ARRAY[]::INT[];   -- Q6 puzzles
    i           INT;
    uid         INT;
    pid         INT;
BEGIN
    SELECT chapter_id INTO v_chapter  FROM CHAPTERS ORDER BY chapter_id LIMIT 1;
    SELECT tag_id     INTO v_real_tag FROM TAGS
        WHERE tag_name <> 'DEMO_HARD_TOPIC' ORDER BY tag_id LIMIT 1;

    -- ----- demo users -----
    INSERT INTO USERS DEFAULT VALUES RETURNING user_id INTO u_struggle;
    FOR i IN 1..5 LOOP
        INSERT INTO USERS DEFAULT VALUES RETURNING user_id INTO uid;
        u_bulk := array_append(u_bulk, uid);
    END LOOP;

    -- ----- demo tag (Q6) -----
    INSERT INTO TAGS (tag_name, description)
    VALUES ('DEMO_HARD_TOPIC', 'Seeded low-success topic (demo data for Phase 2 screenshots)')
    RETURNING tag_id INTO v_demo_tag;

    -- ----- demo puzzles -----
    INSERT INTO PUZZLES (fen_string, solution_moves, difficulty_elo, tag_id)
    VALUES ('DEMO/fast',     'e2e4 e7e5', 1200, v_real_tag) RETURNING puzzle_id INTO p_fast;
    INSERT INTO PUZZLES (fen_string, solution_moves, difficulty_elo, tag_id)
    VALUES ('DEMO/hard',     'e2e4 e7e5', 2700, v_real_tag) RETURNING puzzle_id INTO p_hard;
    INSERT INTO PUZZLES (fen_string, solution_moves, difficulty_elo, tag_id)
    VALUES ('DEMO/popular',  'e2e4 e7e5', 1400, v_real_tag) RETURNING puzzle_id INTO p_popular;
    INSERT INTO PUZZLES (fen_string, solution_moves, difficulty_elo, tag_id)
    VALUES ('DEMO/struggle', 'e2e4 e7e5', 1600, v_real_tag) RETURNING puzzle_id INTO p_struggle;
    FOR i IN 1..3 LOOP
        INSERT INTO PUZZLES (fen_string, solution_moves, difficulty_elo, tag_id)
        VALUES ('DEMO/tag_' || i, 'e2e4 e7e5', 1800, v_demo_tag) RETURNING puzzle_id INTO pid;
        p_tag := array_append(p_tag, pid);
    END LOOP;

    -- ----- Update 1: p_fast, average solve time < 10s (6 attempts, 3..8 sec) -----
    FOR i IN 1..6 LOOP
        INSERT INTO PUZZLE_ATTEMPT (user_id, puzzle_id, is_successful, time_taken_sec, attempt_date)
        VALUES (u_bulk[1 + (i % 5)], p_fast, (i % 2 = 0), 3 + (i % 6),
                TIMESTAMP '2023-06-01 10:00:00' + (i || ' minutes')::interval);
    END LOOP;

    -- ----- Q2: p_hard, >=10 plays, <10% success, avg time > 300s (12 attempts, 1 success) -----
    FOR i IN 1..12 LOOP
        INSERT INTO PUZZLE_ATTEMPT (user_id, puzzle_id, is_successful, time_taken_sec, attempt_date)
        VALUES (u_bulk[1 + (i % 5)], p_hard, (i = 1), 320 + (i * 12),
                TIMESTAMP '2023-06-02 10:00:00' + (i || ' minutes')::interval);
    END LOOP;

    -- ----- Q5: p_popular, >50 plays, >80% success, never daily (55 attempts, ~89%) -----
    FOR i IN 1..55 LOOP
        INSERT INTO PUZZLE_ATTEMPT (user_id, puzzle_id, is_successful, time_taken_sec, attempt_date)
        VALUES (u_bulk[1 + (i % 5)], p_popular, (i % 8 <> 0), 25 + (i % 40),
                TIMESTAMP '2023-06-03 10:00:00' + (i || ' minutes')::interval);
    END LOOP;

    -- ----- Q6: demo tag, >100 attempts, <25% success (120 attempts over 3 puzzles, 20%) -----
    FOR i IN 1..120 LOOP
        INSERT INTO PUZZLE_ATTEMPT (user_id, puzzle_id, is_successful, time_taken_sec, attempt_date)
        VALUES (u_bulk[1 + (i % 5)], p_tag[1 + (i % 3)], (i % 5 = 0), 90 + (i % 120),
                TIMESTAMP '2023-06-04 10:00:00' + (i || ' minutes')::interval);
    END LOOP;

    -- ----- Q1: u_struggle, >=20 attempts, <20% success (25 attempts on p_struggle, 8%) -----
    FOR i IN 1..25 LOOP
        INSERT INTO PUZZLE_ATTEMPT (user_id, puzzle_id, is_successful, time_taken_sec, attempt_date)
        VALUES (u_struggle, p_struggle, (i % 9 = 0), 100 + (i % 50),
                TIMESTAMP '2023-06-05 10:00:00' + (i || ' minutes')::interval);
    END LOOP;

    -- ----- Delete 1: attempts dated before 2000 (3 rows) -----
    FOR i IN 1..3 LOOP
        INSERT INTO PUZZLE_ATTEMPT (user_id, puzzle_id, is_successful, time_taken_sec, attempt_date)
        VALUES (u_bulk[i], p_struggle, TRUE, 120,
                TIMESTAMP '1999-06-15 12:00:00' + (i || ' minutes')::interval);
    END LOOP;

    -- ----- Delete 2: chapter_progress started before 2000 (2 rows; not completed -> obeys constraints) -----
    FOR i IN 1..2 LOOP
        INSERT INTO CHAPTER_PROGRESS (user_id, chapter_id, is_completed, start_date, completion_date)
        VALUES (u_bulk[i], v_chapter, FALSE, ('1999-03-0' || i)::date, NULL);
    END LOOP;

    -- ----- Delete 3: a course with no chapters -----
    INSERT INTO COURSES (title, description, publish_date, user_id)
    VALUES ('DEMO_EMPTY_COURSE', 'Course with no chapters (demo data for Delete 3)',
            DATE '2023-01-15', u_bulk[1]);

    RAISE NOTICE 'Demo data seeded. struggle_user=%, bulk_users=%, demo_tag=%',
                 u_struggle, u_bulk, v_demo_tag;
END $$;

-- ---------------------------------------------------------------------
-- STEP 3: verification - every count below should be > 0
-- ---------------------------------------------------------------------
SELECT 'Q1_struggling_users' AS check, COUNT(*) AS rows FROM (
    SELECT U.user_id FROM USERS U JOIN PUZZLE_ATTEMPT PA ON U.user_id = PA.user_id
    GROUP BY U.user_id
    HAVING COUNT(PA.attempt_id) >= 20 AND AVG(CASE WHEN PA.is_successful THEN 1 ELSE 0 END) < 0.2) x
UNION ALL SELECT 'Q2_hard_puzzles', COUNT(*) FROM (
    SELECT P.puzzle_id FROM PUZZLES P JOIN TAGS T ON P.tag_id = T.tag_id
    JOIN PUZZLE_ATTEMPT PA ON P.puzzle_id = PA.puzzle_id
    GROUP BY P.puzzle_id
    HAVING COUNT(PA.attempt_id) >= 10 AND AVG(CASE WHEN PA.is_successful THEN 1 ELSE 0 END) < 0.1
       AND AVG(PA.time_taken_sec) > 300) x
UNION ALL SELECT 'Q5_popular_not_daily', COUNT(*) FROM (
    SELECT P.puzzle_id FROM PUZZLES P JOIN PUZZLE_ATTEMPT PA ON P.puzzle_id = PA.puzzle_id
    LEFT JOIN DAILY_PUZZLES DP ON P.puzzle_id = DP.puzzle_id WHERE DP.daily_puzzle_id IS NULL
    GROUP BY P.puzzle_id
    HAVING COUNT(PA.attempt_id) > 50 AND AVG(CASE WHEN PA.is_successful THEN 1 ELSE 0 END) > 0.8) x
UNION ALL SELECT 'Q6_problematic_tags', COUNT(*) FROM (
    SELECT T.tag_name FROM TAGS T JOIN PUZZLES P ON T.tag_id = P.tag_id
    JOIN PUZZLE_ATTEMPT PA ON P.puzzle_id = PA.puzzle_id
    GROUP BY T.tag_name
    HAVING COUNT(PA.attempt_id) > 100 AND AVG(CASE WHEN PA.is_successful THEN 1 ELSE 0 END) < 0.25) x
UNION ALL SELECT 'Upd1_avg_lt_10', COUNT(*) FROM (
    SELECT puzzle_id FROM PUZZLE_ATTEMPT GROUP BY puzzle_id HAVING AVG(time_taken_sec) < 10) x
UNION ALL SELECT 'Del1_attempts_pre2000', COUNT(*) FROM PUZZLE_ATTEMPT WHERE attempt_date < '2000-01-01'
UNION ALL SELECT 'Del2_progress_pre2000', COUNT(*) FROM CHAPTER_PROGRESS WHERE start_date < '2000-01-01'
UNION ALL SELECT 'Del3_empty_courses', COUNT(*) FROM COURSES WHERE course_id NOT IN (SELECT course_id FROM CHAPTERS);
