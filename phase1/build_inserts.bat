::build_inserts
@echo off
:: תמיכה בקידוד UTF-8 כדי למנוע בעיות עם עברית או תווים מיוחדים
chcp 65001 > nul

echo 🔨 Building insert_tables.sql...

:: מחיקת קובץ היעד הישן אם הוא קיים כדי להתחיל מאפס
if exist "scripts\insert_tables.sql" del "scripts\insert_tables.sql"

echo Adding USERS...
type "mockarooFiles\USERS.sql" >> "scripts\insert_tables.sql"
echo. >> "scripts\insert_tables.sql"

echo Adding COURSES...
type "mockarooFiles\COURSES.sql" >> "scripts\insert_tables.sql"
echo. >> "scripts\insert_tables.sql"

echo Adding CSV CHAPTERS COPY command...
type "copy_csv_commands\copy_csv_chapters.sql" >> "scripts\insert_tables.sql"

echo Adding CHAPTER_PROGRESS...
type "mockarooFiles\CHAPTER_PROGRESS.sql" >> "scripts\insert_tables.sql"
echo. >> "scripts\insert_tables.sql"

:: הוספת ירידת שורה ריקה למקרה שהקובץ האחרון לא נגמר בשורה חדשה
echo. >> "scripts\insert_tables.sql"

echo Adding PAZZLES RELATED CSV COPY commands...
type "copy_csv_commands\copy_csv_puzzles.sql" >> "scripts\insert_tables.sql"

echo ✅ Done! The file insert_tables.sql is ready in the scripts folder.
pause