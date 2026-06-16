# Chess Learning & Puzzles Platform

Authors: Avraham Shaviro & Shraga Chesrak

## Phase 2: שאילתות ואילוצים

## Table of Contents

- [Chess Learning \& Puzzles Platform](#chess-learning--puzzles-platform)
  - [Phase 2: שאילתות ואילוצים](#phase-2-integration)
    - [שאילתות SELECT כפולות](#שאילתות-select-כפולות)
    - [שאילתות SELECT נוספות](#שאילתות-select-נוספות)
    - [שאילתות UPDATE ו-DELETE](#שאילתות-update-ו-delete)
    - [אילוצים (Constraints)](#אילוצים-constraints)
    - [טרנזקציות (Commit \& Rollback)](#טרנזקציות-commit--rollback)
    - [אינדקסים (Indexes)](#אינדקסים-indexes)




### שאילתות SELECT כפולות

חלק זה מציג 4 זוגות של שאילתות המבצעות את אותה הפעולה בדרכים שונות, תוך השוואת היעילות ביניהן.

**1. משתמשים שסיימו קורסים בשנת 2026**
* **תיאור:** שאילתא המחזירה את מזהה המשתמש, שם הקורס ותאריך הסיום, עבור משתמשים שסיימו קורס בהצלחה במהלך שנת 2026.
* **קוד שאילתא א' (שימוש ב-JOIN):**
    ```sql
    SELECT DISTINCT U.user_id, C.title, CP.completion_date
    FROM USERS U
    JOIN COURSE_PROGRESS CP ON U.user_id = CP.user_id
    JOIN COURSES C ON CP.course_id = C.course_id
    WHERE CP.is_completed = TRUE 
    AND EXTRACT(YEAR FROM CP.completion_date) = 2026;
    ```
* **קוד שאילתא ב' (שימוש ב-IN ובתת-שאילתא ב-SELECT):**
    ```sql
    SELECT user_id, 
           (SELECT title FROM COURSES WHERE course_id = CP.course_id) AS course_name,
           completion_date
    FROM COURSE_PROGRESS CP
    WHERE is_completed = TRUE 
    AND course_id IN (SELECT course_id FROM COURSES)
    AND EXTRACT(YEAR FROM completion_date) = 2026;
    ```
* **הסבר והבדלי יעילות:** השימוש ב-JOIN לרוב יעיל יותר מכיוון שמנוע בסיס הנתונים יודע לבצע אופטימיזציה לחיבור בין טבלאות באופן מקביל. שימוש ב-IN, ובמיוחד תת-שאילתא בשורת ה-SELECT, מאלץ את המנוע לבצע פעולת שליפה עבור כל שורה בנפרד (N+1 בעיות), מה שעשוי להאט משמעותית את הביצועים על כמויות מידע גדולות.

* **צילום תוצאה:** ![Result](screenshots/res_completed_courses.png)

**2. חידות שלא הופיעו כ"חידה יומית"**
* **תיאור:** שליפת מזהה החידה והדירוג (ELO) שלה עבור חידות שמעולם לא שובצו כחידה יומית.
* **קוד שאילתא א' (שימוש ב-NOT IN):**
    ```sql
    SELECT puzzle_id, difficulty_elo 
    FROM PUZZLES
    WHERE puzzle_id NOT IN (SELECT puzzle_id FROM DAILY_PUZZLES);
    ```
* **קוד שאילתא ב' (שימוש ב-LEFT JOIN):**
    ```sql
    SELECT P.puzzle_id, P.difficulty_elo
    FROM PUZZLES P
    LEFT JOIN DAILY_PUZZLES DP ON P.puzzle_id = DP.puzzle_id
    WHERE DP.daily_puzzle_id IS NULL;
    ```
* **הסבר והבדלי יעילות:** כאשר ישנם ערכי NULL בעמודות המעורבות, `NOT IN` עלול להחזיר תוצאות לא צפויות (קבוצה ריקה) או לדרוש סריקה מלאה. `LEFT JOIN` בתוספת `IS NULL` בטוח יותר מבחינה לוגית כשיש NULLs, ומנועי DB מודרניים מבצעים לו אופטימיזציה מצוינת (Anti-Join), לכן הוא נחשב לאמין ויעיל מאוד למטרה זו.
* **צילום תוצאה:** ![Result](screenshots/res_not_daily.png)

**3. משתמשים שלא פתרו אף חידה**
* **תיאור:** מציאת מזהי המשתמשים שאין להם אף רשומה בטבלת הניסיונות לפתרון חידות.
* **קוד שאילתא א' (שימוש ב-NOT IN):**
    ```sql
    SELECT user_id 
    FROM USERS
    WHERE user_id NOT IN (SELECT user_id FROM PUZZLE_ATTEMPT);
    ```
* **קוד שאילתא ב' (שימוש ב-NOT EXISTS):**
    ```sql
    SELECT U.user_id 
    FROM USERS U
    WHERE NOT EXISTS (
        SELECT 1 
        FROM PUZZLE_ATTEMPT PA 
        WHERE PA.user_id = U.user_id
    );
    ```
* **הסבר והבדלי יעילות:** השימוש ב-`NOT EXISTS` יעיל בהרבה עקב מנגנון "פרישה מוקדמת" (Early Exit). ברגע שמנוע ה-DB מוצא רשומה אחת שתואמת לתנאי בתוך התת-שאילתא, הוא עוצר את הבדיקה עבור אותו משתמש וממשיך הלאה. לעומת זאת, `NOT IN` יחפש בכל הרשימה במלואה וישווה ערך ערך.

* **צילום תוצאה:** ![Result](screenshots/res_no_attempts.png)

**4. חידות קשות מהממוצע**
* **תיאור:** שליפת מזהי החידות שהדירוג (ELO) שלהן גבוה מהדירוג הממוצע של כלל החידות במערכת.
* **קוד שאילתא א' (תת-שאילתה ב-WHERE):**
    ```sql
    SELECT puzzle_id, difficulty_elo 
    FROM PUZZLES 
    WHERE difficulty_elo > (
        SELECT AVG(difficulty_elo) 
        FROM PUZZLES
    );
    ```
* **קוד שאילתא ב' (טבלה נגזרת / CTE):**
    ```sql
    WITH(avg_elo AS (SELECT AVG(difficulty_elo) FROM PUZZLES))
    SELECT puzzle_id, difficulty_elo 
    FROM PUZZLES 
    WHERE difficulty_elo > (SELECT avg_elo FROM avg_elo);
    ```
* **הסבר והבדלי יעילות:** שימוש ב-CTE (או בטבלה נגזרת ב-FROM כפי שמופיע בקובץ) מחשב את הממוצע פעם אחת בלבד ושומר אותו בזיכרון לשימוש השאילתא העיקרית. תת-שאילתא ב-WHERE עלולה להיות מחושבת מחדש עבור כל שורה בטבלה (תלוי באופטימייזר), מה שהופך את גישת ה-CTE או הטבלה הנגזרת ליעילה וקריאה יותר.

* **צילום תוצאה:** ![Result](screenshots/res_hard_puzzles.png)

---

### שאילתות SELECT נוספות

**1. דירוג משתמשים לפי אחוזי הצלחה**
* **תיאור:** הצגת נתוני הצלחה בפתרון חידות למשתמשים (עם מעל 5 ניסיונות), כולל סך הניסיונות, כמות ההצלחות ואחוז ההצלחה מקובץ לפי חודש.
* **קוד שאילתא:**
    ```sql
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
    ```
* **צילום תוצאה:** ![](screenshots/res_success_rate.png)

**2. חידות עם אחוז הצלחה נמוך מ-40%**
* **תיאור:** איתור החידות הקשות ביותר במערכת שאחוז ההצלחה בהן נמוך מ-40%, כולל כמות הפעמים ששיחקו בהן.
* **קוד שאילתא:**
    ```sql
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
    ```
* **צילום תוצאה:** ![Result](screenshots/res_low_success.png)

**3. היום העמוס ביותר בפתרון חידות יומיות**
* **תיאור:** ניתוח המציג באיזה יום בשבוע ישנה את כמות הניסיונות הגדולה ביותר לפתרון חידות יומיות, וכן את ממוצע הזמן שלקח לפתור אותן.
* **קוד שאילתא:**
    ```sql
    SELECT 
        TO_CHAR(PA.attempt_date, 'Day') AS day_name,
        COUNT(*) AS attempt_count,
        AVG(PA.time_taken_sec) AS avg_solve_time
    FROM PUZZLE_ATTEMPT PA
    JOIN DAILY_PUZZLES DP ON PA.puzzle_id = DP.puzzle_id
    GROUP BY TO_CHAR(PA.attempt_date, 'Day')
    ORDER BY attempt_count DESC;
    ```

* **צילום תוצאה:** ![Result](screenshots/res_busiest_day.png)

**4. סטטוס התקדמות בקורסים**
* **תיאור:** הצגת פרטי משתמשים שסיימו קורסים במהלך שנת 2026, כולל תאריך התחלה, תאריך סיום וחישוב של מספר הימים שלקח להם לסיים את הקורס.
* **קוד שאילתא:**
    ```sql
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
    ```

* **צילום תוצאה:** ![Result](screenshots/res_course_status.png)

---

### שאילתות UPDATE ו-DELETE

**1. עדכון מטה: הפחתת ELO לחידות קלות**
* **תיאור:** הורדת דרגת הקושי (ELO) ב-100 נקודות לחידות שנפתרו בממוצע בפחות מ-10 שניות.
* **קוד:**
    ```sql
    UPDATE PUZZLES
    SET difficulty_elo = difficulty_elo - 100
    WHERE puzzle_id IN (
        SELECT puzzle_id FROM PUZZLE_ATTEMPT 
        GROUP BY puzzle_id HAVING AVG(time_taken_sec) < 10
    );
    ```
* **צילום הרצה:** ![Run Output](screenshots/run_update_elo_down.png)


**2. עדכון מעלה: העלאת ELO לחידות קשות**
* **תיאור:** העלאת דרגת הקושי (ELO) ב-100 נקודות לחידות שלקח למשתמשים מעל 60 שניות בממוצע לפתור.
* **קוד:**
    ```sql
    UPDATE PUZZLES
    SET difficulty_elo = difficulty_elo + 100
    WHERE puzzle_id IN (
        SELECT puzzle_id FROM PUZZLE_ATTEMPT 
        GROUP BY puzzle_id HAVING AVG(time_taken_sec) > 60
    );
    ```
* **צילום הרצה:** ![Run Output](screenshots/run_update_elo_down.png)

**3. עדכון בונוס: הוספת XP לחידות ביום ראשון**
* **תיאור:** הוספת 10 נקודות בונוס ניסיון (XP) לחידות יומיות שפורסמו ביום ראשון (DOW = 0).
* **קוד:**
    ```sql
    UPDATE DAILY_PUZZLES
    SET bonus_xp = bonus_xp +10
    WHERE EXTRACT(DOW FROM puzzle_date) IN (0); 
    ```
* **צילום הרצה:**![Run Output](screenshots/run_update_elo_down.png)

**4. מחיקת ניסיונות פתרון ישנים**
* **תיאור:** מחיקת רשומות של ניסיונות פתרון שהתבצעו לפני שנת 2000.
* **קוד:**
    ```sql
    DELETE FROM PUZZLE_ATTEMPT
    WHERE attempt_date < '2000-01-01';
    ```
* **צילום הרצה:** ![Run Output](screenshots/run_delete_attempts.png)


**5. מחיקת התקדמות קורסים ישנה**
* **תיאור:** מחיקת רישומי התקדמות קורסים שהחלו לפני שנת 2000.
* **קוד:**
    ```sql
    DELETE FROM COURSE_PROGRESS
    WHERE start_date < '2000-01-01';
    ```
* **צילום הרצה:** ![Run Output](screenshots/run_delete_attempts.png)

**6. מחיקת קורסים ריקים**
* **תיאור:** מחיקת קורסים שאין להם אף פרק מקושר בטבלת הפרקים.
* **קוד:**
    ```sql
    DELETE FROM COURSES
    WHERE course_id NOT IN (SELECT course_id FROM CHAPTERS);
    ```
* **צילום הרצה:** ![Run Output](screenshots/run_delete_attempts.png)

---

### אילוצים (Constraints)

**1. תאימות נתוני סיום קורס**
* **תיאור:** אילוץ המוודא שאם קורס מסומן כהושלם, תאריך הסיום אינו ריק, ולהיפך.
* **קוד:** ```sql
    ALTER TABLE COURSE_PROGRESS 
    ADD CONSTRAINT check_completion_consistency 
    CHECK ((is_completed = TRUE AND completion_date IS NOT NULL) OR (is_completed = FALSE AND completion_date IS NULL));
    ```
* **הפרת האילוץ ושגיאה:** `![Error Output](screenshots/err_constraint_consistency.png)`

**2. הגיוניות תאריכים**
* **תיאור:** אילוץ המוודא שתאריך סיום הקורס יהיה גדול או שווה לתאריך ההתחלה.
* **קוד:**
    ```sql
    ALTER TABLE COURSE_PROGRESS 
    ADD CONSTRAINT check_dates_order CHECK (completion_date >= start_date);
    ```
* **הפרת האילוץ ושגיאה:** `![Error Output](screenshots/err_constraint_dates.png)`

**3. ייחודיות סדר פרקים**
* **תיאור:** אילוץ המונע מצב שבו לאותו קורס יש שני פרקים בעלי אותו מספר סדרתי.
* **קוד:**
    ```sql
    ALTER TABLE CHAPTERS 
    ADD CONSTRAINT unique_chapter_order_per_course UNIQUE (course_id, chapter_order);
    ```
* **הפרת האילוץ ושגיאה:** `![Error Output](screenshots/err_constraint_chapters.png)`

---

### טרנזקציות (Commit & Rollback)

חלק זה מדגים את השימוש בטרנזקציות בבסיס הנתונים.

**הדגמת ROLLBACK:**
ביצוע הכנסת נתון שגוי לטבלת TAGS, בדיקה שהוא קיים בתוך הטרנזקציה, וביצוע ביטול (Rollback). הנתון נעלם בסוף התהליך.
* **קוד הרצה:** ```sql
    BEGIN;
    INSERT INTO TAGS (tag_name, description) VALUES ('Test Tag', 'This should be rolled back');
    SELECT * FROM TAGS WHERE tag_name = 'Test Tag';
    ROLLBACK;
    SELECT * FROM TAGS WHERE tag_name = 'Test Tag';
    ```
* **מצב בסיס נתונים בכל שלב:** `![Rollback States](screenshots/rollback_states.png)`

**הדגמת COMMIT:**
הכנסת נתון חדש ושמירתו לצמיתות בבסיס הנתונים באמצעות הפקודה Commit.
* **קוד הרצה:**
    ```sql
    BEGIN;
    INSERT INTO TAGS (tag_name, description) VALUES ('Commit Tag', 'This should be saved');
    SELECT * FROM TAGS WHERE tag_name = 'Commit Tag';
    COMMIT;
    SELECT * FROM TAGS WHERE tag_name = 'Commit Tag';
    ```
* **מצב בסיס נתונים בכל שלב:** `![Commit States](screenshots/commit_states.png)`

---

### אינדקסים (Indexes)

על מנת לייעל את זמן הריצה של השאילתות, הוספנו אינדקסים לשדות המשמשים בתדירות גבוהה לתנאים (WHERE) וקישורים (JOIN).

* **קוד האינדקסים:**
    ```sql
    CREATE INDEX idx_puzzles_difficulty ON PUZZLES(difficulty_elo);
    CREATE INDEX idx_puzzle_attempts_user ON PUZZLE_ATTEMPT(user_id);
    CREATE INDEX idx_chapters_course ON CHAPTERS(course_id);
    ```

* **בדיקת זמני ריצה (לפני ואחרי):**
    בדקנו את שאילתת חיפוש חידות קשות מהממוצע ואת שאילתת אחוזי ההצלחה של משתמשים. טרם יצירת האינדקסים, בסיס הנתונים ביצע סריקה מלאה (Sequential Scan). לאחר הוספת האינדקס, מנוע ה-DB השתמש ב-Index Scan מה שהוביל להקטנת זמן הריצה משמעותית.
* **צילומי מסך זמני ריצה (EXPLAIN ANALYZE):** `![Index Compare](screenshots/index_compare.png)`