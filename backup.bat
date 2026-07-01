@echo off
setlocal enabledelayedexpansion
:: תמיכה בטקסט בעברית בקונסול
chcp 65001 >nul

:: מעבר לתיקיית השורש (היכן שהסקריפט נמצא)
pushd "%~dp0"

:: טעינת המשתנים מקובץ ה-.env (עכשיו נמצא באותה תיקייה)
if exist ".env" (
    for /f "usebackq tokens=1,* delims==" %%a in (".env") do (
        if not "%%b"=="" set "%%a=%%b"
    )
) else (
    echo [ERROR] .env file not found in the root directory.
    pause
    exit /b
)

:: 1. קבלת מספר השלב (מארגומנט או מקלט משתמש)
set PHASE_NUMBER=%1
if "%PHASE_NUMBER%"=="" (
    echo ========================================
    set /p PHASE_NUMBER="Enter phase number (e.g. 1, 2, 3): "
    echo ========================================
)

:: 2. יצירת תיקיית היעד אם אינה קיימת
set TARGET_DIR=phase%PHASE_NUMBER%\backups
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
    echo [INFO] Created directory: %TARGET_DIR%
)

:: 3. שליפת תאריך ושעה גנריים
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set DATE_STR=%datetime:~0,4%.%datetime:~4,2%.%datetime:~6,2%

:: 4. בניית נתיב ושם הקובץ (למשל: phase2\backups\backup2_user_2023.10.25.sql)
set FILENAME=backup%PHASE_NUMBER%_%USERNAME%_%DATE_STR%.sql
set FULL_PATH=%TARGET_DIR%\%FILENAME%

echo [INFO] Starting backup from container: PostgreSQL_DB
echo [INFO] Database: %DB_NAME_SECRET%, User: %DB_USER_SECRET%
echo [INFO] Destination: %FULL_PATH%

:: 5. הרצת הגיבוי
docker exec -t PostgreSQL_DB pg_dump -U %DB_USER_SECRET% %DB_NAME_SECRET% > "%FULL_PATH%"

if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Backup created successfully: %FULL_PATH%
) else (
    echo [ERROR] Backup failed! Check if Docker is running.
    :: מחיקת הקובץ הריק ש-CMD יצר במקרה של כישלון
    del "%FULL_PATH%"
)

popd
pause