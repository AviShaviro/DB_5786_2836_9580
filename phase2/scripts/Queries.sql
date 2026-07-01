-- 1. איתור משתמשים שמתקשים במיוחד: שיעור הצלחה נמוך מ-20% למרות שניסו לפתור לפחות 20 חידות
SELECT 
    U.user_id,
    COUNT(PA.attempt_id) AS total_attempts,
    SUM(CASE WHEN PA.is_successful THEN 1 ELSE 0 END) AS success_count,
    ROUND(AVG(CASE WHEN PA.is_successful THEN 1 ELSE 0 END) * 100, 2) AS success_rate
FROM USERS U
JOIN PUZZLE_ATTEMPT PA ON U.user_id = PA.user_id
GROUP BY U.user_id
HAVING COUNT(PA.attempt_id) >= 20 
   AND AVG(CASE WHEN PA.is_successful THEN 1 ELSE 0 END) < 0.2
ORDER BY success_rate ASC;

-- 2. איתור חידות קשות באופן חריג: אחוז הצלחה נמוך מ-10% וזמן פתרון ממוצע גבוה מ-5 דקות (300 שניות)
SELECT 
    P.puzzle_id, 
    P.difficulty_elo, 
    T.tag_name, 
    COUNT(PA.attempt_id) as total_plays,
    ROUND(AVG(PA.time_taken_sec), 2) AS avg_time_sec
FROM PUZZLES P
JOIN TAGS T ON P.tag_id = T.tag_id
JOIN PUZZLE_ATTEMPT PA ON P.puzzle_id = PA.puzzle_id
GROUP BY P.puzzle_id, P.difficulty_elo, T.tag_name
HAVING COUNT(PA.attempt_id) >= 10 
   AND AVG(CASE WHEN PA.is_successful THEN 1 ELSE 0 END) < 0.1
   AND AVG(PA.time_taken_sec) > 300
ORDER BY avg_time_sec DESC;

-- 3. ניתוח עומס שבועי: איזה יום בשבוע הוא העמוס ביותר בפתרון חידות יומיות
-- (מחזיר לכל היותר 7 שורות - ימי השבוע, ללא צורך ב-LIMIT)
SELECT 
    TO_CHAR(PA.attempt_date, 'Day') AS day_name,
    COUNT(*) AS attempt_count,
    ROUND(AVG(PA.time_taken_sec), 2) AS avg_solve_time
FROM PUZZLE_ATTEMPT PA
JOIN DAILY_PUZZLES DP ON PA.puzzle_id = DP.puzzle_id
GROUP BY TO_CHAR(PA.attempt_date, 'Day')
ORDER BY attempt_count DESC;

-- 4. לומדים מצטיינים: משתמשים שסיימו פרק מהר מאוד (בתוך פחות מ-7 ימים) בשנת 2023
SELECT
    U.user_id,
    C.title AS course_name,
    CP.start_date,
    CP.completion_date,
    (CP.completion_date - CP.start_date) AS days_to_complete
FROM CHAPTER_PROGRESS CP
JOIN USERS U ON CP.user_id = U.user_id
JOIN CHAPTERS CH ON CP.chapter_id = CH.chapter_id
JOIN COURSES C ON CH.course_id = C.course_id
WHERE CP.is_completed = TRUE
  AND EXTRACT(YEAR FROM CP.completion_date) = 2023
  AND (CP.completion_date - CP.start_date) < 7
ORDER BY days_to_complete ASC;

-- 5. חידות פופולריות שלא קודמו: חידות שלא הופיעו מעולם כ"חידה יומית", אך שוחקו מעל 50 פעמים ויש להן אחוז הצלחה גבוה מ-80%
SELECT 
    P.puzzle_id, 
    P.difficulty_elo,
    COUNT(PA.attempt_id) AS attempt_count,
    ROUND(AVG(CASE WHEN PA.is_successful THEN 1 ELSE 0 END) * 100, 2) AS success_rate
FROM PUZZLES P
JOIN PUZZLE_ATTEMPT PA ON P.puzzle_id = PA.puzzle_id
LEFT JOIN DAILY_PUZZLES DP ON P.puzzle_id = DP.puzzle_id
WHERE DP.daily_puzzle_id IS NULL
GROUP BY P.puzzle_id, P.difficulty_elo
HAVING COUNT(PA.attempt_id) > 50 
   AND AVG(CASE WHEN PA.is_successful THEN 1 ELSE 0 END) > 0.8
ORDER BY attempt_count DESC;

-- 6. איתור תגיות (נושאים) בעייתיות: תגיות עם אחוז ההצלחה הנמוך ביותר בחידות (פחות מ-25%)
-- משמש את העסק להחלטה אילו קורסים חדשים לייצר
SELECT 
    T.tag_name,
    COUNT(PA.attempt_id) AS total_attempts,
    ROUND(AVG(CASE WHEN PA.is_successful THEN 1 ELSE 0 END) * 100, 2) AS success_rate
FROM TAGS T
JOIN PUZZLES P ON T.tag_id = P.tag_id
JOIN PUZZLE_ATTEMPT PA ON P.puzzle_id = PA.puzzle_id
GROUP BY T.tag_name
HAVING COUNT(PA.attempt_id) > 100
   AND AVG(CASE WHEN PA.is_successful THEN 1 ELSE 0 END) < 0.25
ORDER BY success_rate ASC;

--------------------------------------------------------------------------------------------------------
-- שאילתות כפולות (4 זוגות): אותה תוצאה בשתי צורות שונות, להשוואת יעילות. ללא LIMIT.
--------------------------------------------------------------------------------------------------------

-- 7. לכל קורס: כמה משתמשים שונים השלימו בו פרקים ב-2023, וכמה פרקים סך הכול.
-- 7א. צורה א' — JOIN ישיר
SELECT
    C.title                    AS course_name,
    COUNT(DISTINCT CP.user_id) AS users_completed,
    COUNT(*)                   AS chapters_completed
FROM CHAPTER_PROGRESS CP
JOIN CHAPTERS CH ON CP.chapter_id = CH.chapter_id
JOIN COURSES  C  ON CH.course_id  = C.course_id
WHERE CP.is_completed = TRUE
  AND EXTRACT(YEAR FROM CP.completion_date) = 2023
GROUP BY C.title
ORDER BY users_completed DESC;

-- 7ב. צורה ב' — CTE שמסנן קודם ואז מצרף
WITH completed_2023 AS (
    SELECT CP.user_id, CH.course_id
    FROM CHAPTER_PROGRESS CP
    JOIN CHAPTERS CH ON CP.chapter_id = CH.chapter_id
    WHERE CP.is_completed = TRUE
      AND EXTRACT(YEAR FROM CP.completion_date) = 2023
)
SELECT
    C.title                    AS course_name,
    COUNT(DISTINCT cc.user_id) AS users_completed,
    COUNT(*)                   AS chapters_completed
FROM completed_2023 cc
JOIN COURSES C ON cc.course_id = C.course_id
GROUP BY C.title
ORDER BY users_completed DESC;

-- 8. לכל תגית: כמה חידות מאותה תגית מעולם לא שובצו כחידה יומית, ומה ה-ELO הממוצע שלהן.
-- 8א. צורה א' — anti-join עם LEFT JOIN + IS NULL
SELECT
    T.tag_name,
    COUNT(*)                        AS never_daily_count,
    ROUND(AVG(P.difficulty_elo), 0) AS avg_elo
FROM PUZZLES P
JOIN TAGS T ON P.tag_id = T.tag_id
LEFT JOIN DAILY_PUZZLES DP ON P.puzzle_id = DP.puzzle_id
WHERE DP.daily_puzzle_id IS NULL
GROUP BY T.tag_name
ORDER BY never_daily_count DESC;

-- 8ב. צורה ב' — NOT EXISTS
SELECT
    T.tag_name,
    COUNT(*)                        AS never_daily_count,
    ROUND(AVG(P.difficulty_elo), 0) AS avg_elo
FROM PUZZLES P
JOIN TAGS T ON P.tag_id = T.tag_id
WHERE NOT EXISTS (
    SELECT 1 FROM DAILY_PUZZLES DP WHERE DP.puzzle_id = P.puzzle_id
)
GROUP BY T.tag_name
ORDER BY never_daily_count DESC;

-- 9. חידות שה-ELO שלהן גבוה מהממוצע הכללי — מקובצות לפי רמת קושי.
-- 9א. צורה א' — תת-שאילתה סקלרית ב-WHERE
SELECT
    CASE WHEN difficulty_elo < 1500 THEN 'easy'
         WHEN difficulty_elo < 2000 THEN 'medium'
         ELSE 'hard' END          AS elo_band,
    COUNT(*)                       AS puzzles_above_avg,
    ROUND(AVG(difficulty_elo), 0)  AS avg_band_elo
FROM PUZZLES
WHERE difficulty_elo > (SELECT AVG(difficulty_elo) FROM PUZZLES)
GROUP BY elo_band
ORDER BY avg_band_elo;

-- 9ב. צורה ב' — CTE שמחשב את הממוצע פעם אחת בלבד
WITH avg_elo AS (SELECT AVG(difficulty_elo) AS a FROM PUZZLES)
SELECT
    CASE WHEN difficulty_elo < 1500 THEN 'easy'
         WHEN difficulty_elo < 2000 THEN 'medium'
         ELSE 'hard' END          AS elo_band,
    COUNT(*)                       AS puzzles_above_avg,
    ROUND(AVG(difficulty_elo), 0)  AS avg_band_elo
FROM PUZZLES, avg_elo
WHERE difficulty_elo > avg_elo.a
GROUP BY elo_band
ORDER BY avg_band_elo;

-- 10. עומס לפי יום בשבוע בפתרון חידות יומיות (פירוק תאריך ליום בשבוע).
-- 10א. צורה א' — קיבוץ לפי שם היום (TO_CHAR)
SELECT
    TRIM(TO_CHAR(PA.attempt_date, 'Day')) AS day_name,
    COUNT(*)                              AS attempt_count,
    ROUND(AVG(PA.time_taken_sec), 1)      AS avg_solve_time
FROM PUZZLE_ATTEMPT PA
JOIN DAILY_PUZZLES DP ON PA.puzzle_id = DP.puzzle_id
GROUP BY TRIM(TO_CHAR(PA.attempt_date, 'Day'))
ORDER BY attempt_count DESC;

-- 10ב. צורה ב' — קיבוץ לפי מספר היום בשבוע (EXTRACT DOW)
SELECT
    EXTRACT(DOW FROM PA.attempt_date) AS day_of_week,
    COUNT(*)                          AS attempt_count,
    ROUND(AVG(PA.time_taken_sec), 1)  AS avg_solve_time
FROM PUZZLE_ATTEMPT PA
JOIN DAILY_PUZZLES DP ON PA.puzzle_id = DP.puzzle_id
GROUP BY EXTRACT(DOW FROM PA.attempt_date)
ORDER BY attempt_count DESC;


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
WHERE attempt_date < '2000-01-01';

--מחיקת התקדמות של קורסים לפני שנת 2000
DELETE FROM CHAPTER_PROGRESS
WHERE start_date < '2000-01-01';

--מחיקת קורסים שאין בהם פרקים
DELETE FROM COURSES
WHERE course_id NOT IN (SELECT course_id FROM CHAPTERS);
