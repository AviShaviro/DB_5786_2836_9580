@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

:: מעבר לתיקייה שבה נמצא הסקריפט (תיקיית השורש)
pushd "%~dp0"

:: 1. טעינת משתני סביבה מה-.env
if exist ".env" (
    for /f "usebackq tokens=1,* delims==" %%a in (".env") do (
        if not "%%b"=="" set "%%a=%%b"
    )
) else (
    echo [ERROR] .env file not found in the root directory.
    pause
    exit /b
)

:: 2. קבלת נתיב הקובץ לשחזור
set BACKUP_FILE=%1

if "%BACKUP_FILE%"=="" (
    echo [PROMPT] You can drag and drop the backup file onto this script!
    set /p BACKUP_FILE="Or enter the path to the backup file: "
)

:: הסרת מרכאות מהנתיב (חשוב במקרה של Drag and Drop)
set BACKUP_FILE=%BACKUP_FILE:"=%

:: בדיקה אם הקובץ קיים
if not exist "%BACKUP_FILE%" (
    echo [ERROR] File "%BACKUP_FILE%" not found.
    pause
    exit /b
)

echo [INFO] Starting restore into container: PostgreSQL_DB...
echo [INFO] Source file: %BACKUP_FILE%

:: 3. הרצת השחזור
type "%BACKUP_FILE%" | docker exec -i PostgreSQL_DB psql -U %DB_USER_SECRET% -d %DB_RESTORE_NAME_SECRET%

if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Database restored successfully!
) else (
    echo [ERROR] Restore failed! Check Docker status and user permissions.
)

popd
pause