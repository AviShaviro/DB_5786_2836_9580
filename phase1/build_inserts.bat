::build_inserts
@echo off
:: תמיכה בקידוד UTF-8 כדי למנוע בעיות עם עברית או תווים מיוחדים
chcp 65001 > nul

echo 🔨 Building insert_tables.sql...

:: מחיקת קובץ היעד הישן אם הוא קיים כדי להתחיל מאפס
if exist "scripts\insert_tables.sql" del "scripts\insert_tables.sql"

:: שרשור כל קבצי ה-SQL של Mockaroo לתוך קובץ היעד
echo Adding Mockaroo inserts...
type "mockarooFiles\*.sql" >> "scripts\insert_tables.sql"

:: הוספת ירידת שורה ריקה למקרה שהקובץ האחרון לא נגמר בשורה חדשה
echo. >> "scripts\insert_tables.sql"

:: שרשור פקודות ה-COPY מהקובץ הנפרד
echo Adding CSV COPY commands...
type "scripts_parts\copy_csv_commands.sql" >> "scripts\insert_tables.sql"

echo ✅ Done! The file insert_tables.sql is ready in the scripts folder.
pause