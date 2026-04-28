@echo off
:: מעבר זמני לתיקייה שבה נמצא הסקריפט
pushd %~dp0

:: טעינת המשתנים מקובץ ה-.env שנמצא שתי תיקיות למעלה
if exist "..\..\.env" (
    for /f "usebackq tokens=*" %%a in ("..\..\.env") do set %%a
) else (
    echo [ERROR] .env file not found at ..\..\.env
    pause
    exit /b
)

:: הגדרת שם קובץ עם תאריך (YYYYMMDD)
set FILENAME=backup_%date:~10,4%%date:~7,2%%date:~4,2%.sql

echo [INFO] Starting backup from container: PostgreSQL_DB
echo [INFO] Database: %DB_NAME_SECRET%, User: %DB_USER_SECRET%

:: הרצת הגיבוי
docker exec -t PostgreSQL_DB pg_dump -U %DB_USER_SECRET% %DB_NAME_SECRET% > %FILENAME%

if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Backup created successfully: %FILENAME%
) else (
    echo [ERROR] Backup failed! Check if Docker is running.
)

pause