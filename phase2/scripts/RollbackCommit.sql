-- =================================================================
-- RollbackCommit.sql
-- דוגמאות להמחשת מנגנון הטרנזקציות: Rollback ו-Commit
-- =================================================================

-- -----------------------------------------------------------------
-- חלק 8: הדגמת ROLLBACK
-- -----------------------------------------------------------------
\echo '--- תחילת חלק 8: הדגמת ROLLBACK ---'

-- 1. הצגת מצב התחלתי (לדוגמה על טבלת ה-TAGS)
SELECT * FROM TAGS WHERE tag_name = 'Test Tag';

-- 2. עדכון בסיס הנתונים
BEGIN;
INSERT INTO TAGS (tag_name, description) VALUES ('Test Tag', 'This should be rolled back');

-- הצגת מצב בסיס הנתונים לאחר העדכון (הנתונים קיימים בתוך הטרנזקציה)
SELECT * FROM TAGS WHERE tag_name = 'Test Tag';

-- 3. ביצוע ROLLBACK
ROLLBACK;

-- הצגת המצב לאחר ה-ROLLBACK (הנתון אמור להיעלם)
SELECT * FROM TAGS WHERE tag_name = 'Test Tag';
\echo '--- סיום חלק 8: הנתונים חזרו לקדמותם ---'


-- -----------------------------------------------------------------
-- חלק 9: הדגמת COMMIT
-- -----------------------------------------------------------------
\echo '--- תחילת חלק 9: הדגמת COMMIT ---'

-- 1. עדכון בסיס הנתונים
BEGIN;
INSERT INTO TAGS (tag_name, description) VALUES ('Commit Tag', 'This should be saved');

-- הצגת המצב בתוך הטרנזקציה
SELECT * FROM TAGS WHERE tag_name = 'Commit Tag';

-- 2. ביצוע COMMIT
COMMIT;

-- 3. הצגת המצב לאחר ה-COMMIT (הנתון נשמר בבסיס הנתונים)
SELECT * FROM TAGS WHERE tag_name = 'Commit Tag';
\echo '--- סיום חלק 9: הנתונים נשמרו בהצלחה ---'