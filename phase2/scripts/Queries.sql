--דירוג משתמשים לפי אחוזי הצלחה בחידות
SELECT 
    U.user_id,
    COUNT(PA.attempt_id) AS total_attempts,
    SUM(CASE WHEN PA.is_successful THEN 1 ELSE 0 END) AS success_count,
    ROUND(AVG(CASE WHEN PA.is_successful THEN 1 ELSE 0 END) * 100, 2) AS success_rate,
    EXTRACT(MONTH FROM PA.attempt_date) AS attempt_month
FROM USERS U
JOIN PUZZLE_ATTEMPT PA ON U.user_id = PA.user_id
GROUP BY U.user_id, EXTRACT(MONTH FROM PA.attempt_date)
HAVING COUNT(PA.attempt_id) > 5
ORDER BY success_rate DESC;

--מחפשת חידות  שאחוז ההצלחה בהן נמוך מ-40%.
SELECT P.puzzle_id, P.difficulty_elo, T.tag_name, 
       (SELECT COUNT(*) FROM PUZZLE_ATTEMPT WHERE puzzle_id = P.puzzle_id) as total_plays
FROM PUZZLES P
JOIN TAGS T ON P.tag_id = T.tag_id
WHERE P.puzzle_id IN (
    SELECT puzzle_id 
    FROM PUZZLE_ATTEMPT 
    GROUP BY puzzle_id 
    HAVING AVG(CASE WHEN is_successful THEN 1 ELSE 0 END) < 0.4
)
ORDER BY total_plays DESC;

--השאילתא מנתחת איזה יום בשבוע הוא העמוס ביותר בפתרון חידות יומיות
SELECT 
    TO_CHAR(PA.attempt_date, 'Day') AS day_name,
    COUNT(*) AS attempt_count,
    AVG(PA.time_taken_sec) AS avg_solve_time
FROM PUZZLE_ATTEMPT PA
JOIN DAILY_PUZZLES DP ON PA.puzzle_id = DP.puzzle_id
GROUP BY TO_CHAR(PA.attempt_date, 'Day')
ORDER BY total_attempts DESC;

--סטטוס התקדמות בקורסים
SELECT 
    U.user_id, 
    C.title AS course_name,
    CP.start_date,
    CP.completion_date,
    (CP.completion_date - CP.start_date) AS days_to_complete
FROM COURSE_PROGRESS CP
JOIN USERS U ON CP.user_id = U.user_id
JOIN COURSES C ON CP.course_id = C.course_id
WHERE CP.is_completed = TRUE AND EXTRACT(YEAR FROM CP.completion_date) = 2026;

--משתמשים שסיימו קורסים השנה (שימוש ב-JOIN)
SELECT DISTINCT U.user_id, C.title, CP.completion_date
FROM USERS U
JOIN COURSE_PROGRESS CP ON U.user_id = CP.user_id
JOIN COURSES C ON CP.course_id = C.course_id
WHERE CP.is_completed = TRUE 
AND EXTRACT(YEAR FROM CP.completion_date) = 2026;

--משתמשים שסיימו קורסים השנה (שימוש ב-IN)
SELECT user_id, 
       (SELECT title FROM COURSES WHERE course_id = CP.course_id) AS course_name,
       completion_date
FROM COURSE_PROGRESS CP
WHERE is_completed = TRUE 
AND course_id IN (SELECT course_id FROM COURSES)
AND EXTRACT(YEAR FROM completion_date) = 2026;

--חידות שלא הופיעו כ"חידה יומית" (שימוש ב-EXCEPT / NOT IN)
SELECT puzzle_id, difficulty_elo 
FROM PUZZLES
WHERE puzzle_id NOT IN (SELECT puzzle_id FROM DAILY_PUZZLES);

--חידות שלא הופיעו כ"חידה יומית" (שימוש ב-LEFT JOIN)
SELECT P.puzzle_id, P.difficulty_elo
FROM PUZZLES P
LEFT JOIN DAILY_PUZZLES DP ON P.puzzle_id = DP.puzzle_id
WHERE DP.daily_puzzle_id IS NULL;

-- משתמשים שלא פתרו אף חידה (דרך א: שימוש ב-NOT IN)
SELECT user_id 
FROM USERS
WHERE user_id NOT IN (SELECT user_id FROM PUZZLE_ATTEMPT);

-- משתמשים שלא פתרו אף חידה (דרך ב: שימוש ב-NOT EXISTS)
-- יעיל יותר פרישה מוקדמת
SELECT U.user_id 
FROM USERS U
WHERE NOT EXISTS (
    SELECT 1 
    FROM PUZZLE_ATTEMPT PA 
    WHERE PA.user_id = U.user_id
);

-- חידות קשות מהממוצע (דרך א: תת-שאילתה ב-WHERE)
SELECT puzzle_id, difficulty_elo 
FROM PUZZLES 
WHERE difficulty_elo > (
    SELECT AVG(difficulty_elo) 
    FROM PUZZLES
);

-- חידות קשות מהממוצע (דרך ב: טבלה נגזרת ב-FROM)
SELECT P.puzzle_id, P.difficulty_elo 
FROM PUZZLES P, (SELECT AVG(difficulty_elo) AS avg_elo FROM PUZZLES) A
WHERE P.difficulty_elo > A.avg_elo;

WITH(avg_elo AS (SELECT AVG(difficulty_elo) FROM PUZZLES))
SELECT puzzle_id, difficulty_elo 
FROM PUZZLES 
WHERE difficulty_elo > (SELECT avg_elo FROM avg_elo);

-- משתמשים שלא פתרו אף חידה (דרך א: שימוש ב-NOT IN)
SELECT user_id 
FROM USERS
WHERE user_id NOT IN (SELECT user_id FROM PUZZLE_ATTEMPT);

-- משתמשים שלא פתרו אף חידה (דרך ב: שימוש ב-NOT EXISTS)
-- יעיל יותר פרישה מוקדמת
SELECT U.user_id 
FROM USERS U
WHERE NOT EXISTS (
    SELECT 1 
    FROM PUZZLE_ATTEMPT PA 
    WHERE PA.user_id = U.user_id
);

-- חידות קשות מהממוצע (דרך א: תת-שאילתה ב-WHERE)
SELECT puzzle_id, difficulty_elo 
FROM PUZZLES 
WHERE difficulty_elo > (
    SELECT AVG(difficulty_elo) 
    FROM PUZZLES
);

-- חידות קשות מהממוצע (דרך ב: טבלה נגזרת ב-FROM)
SELECT P.puzzle_id, P.difficulty_elo 
FROM PUZZLES P, (SELECT AVG(difficulty_elo) AS avg_elo FROM PUZZLES) A
WHERE P.difficulty_elo > A.avg_elo;

WITH(avg_elo AS (SELECT AVG(difficulty_elo) FROM PUZZLES))
SELECT puzzle_id, difficulty_elo 
FROM PUZZLES 
WHERE difficulty_elo > (SELECT avg_elo FROM avg_elo);

--------------------------------------------------------------------------------------------------------
--אם חידה נפתרה בתוך פחות מ-10 שניות בממוצע, נוריד את ה-ELO שלה ב-100

UPDATE PUZZLES
SET difficulty_elo = difficulty_elo - 100
WHERE puzzle_id IN (
    SELECT puzzle_id FROM PUZZLE_ATTEMPT 
    GROUP BY puzzle_id HAVING AVG(time_taken_sec) < 10
);

--אם החידה נפתרה יותר מדקה בממוצע נעלה את ה ELO ב100

UPDATE PUZZLES
SET difficulty_elo = difficulty_elo + 100
WHERE puzzle_id IN (
    SELECT puzzle_id FROM PUZZLE_ATTEMPT 
    GROUP BY puzzle_id HAVING AVG(time_taken_sec) > 60
);

--הוספת בונוס XP לחידות יומיות בתאריכים ספציפיים
UPDATE DAILY_PUZZLES
SET bonus_xp = bonus_xp +10
WHERE EXTRACT(DOW FROM puzzle_date) IN (0); 


---------------------------------------------------------------------------------------------------


--מחיקת ניסיונות פתרון ישנים של משתמשים לא פעילים:
DELETE FROM PUZZLE_ATTEMPT
WHERE attempt_date < '2000-01-01' 

--מחיקת התקדמות של קורסים לפני שנת 2000
DELETE FROM COURSE_PROGRESS
WHERE start_date < '2000-01-01'

--מחיקת קורסים שאין בהם פרקים
DELETE FROM COURSES
WHERE course_id NOT IN (SELECT course_id FROM CHAPTERS);






























