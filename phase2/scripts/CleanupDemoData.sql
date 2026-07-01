-- =====================================================================
-- CleanupDemoData.sql
-- ---------------------------------------------------------------------
-- Removes all demo rows inserted by SeedDemoData.sql, returning the
-- database to its original (mock-data-only) state. Safe to run anytime.
-- =====================================================================
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

    RAISE NOTICE 'Demo data removed (% demo users).', COALESCE(array_length(demo_users, 1), 0);
END $$;
