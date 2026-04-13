-- קובץ selectAll.sql
-- שליפת נתונים מכל הטבלאות במערכת

-- בחירת כל המשתמשים
SELECT * FROM USERS;

-- בחירת כל הקורסים
SELECT * FROM COURSES;

-- בחירת כל הפרקים (Chapters)
SELECT * FROM CHAPTERS;

-- בחירת כל התגיות
SELECT * FROM TAGS;

-- בחירת כל החידות (Puzzles)
SELECT * FROM PUZZLES;

-- בחירת כל החידות היומיות
SELECT * FROM DAILY_PUZZLES;

-- בחירת נתוני התקדמות בקורסים
SELECT * FROM COURSE_PROGRESS;

-- בחירת כל ניסיונות הפתרון של החידות
SELECT * FROM PUZZLE_ATTEMPT;