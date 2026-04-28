@echo off
setlocal enabledelayedexpansion

:: מעבר לתיקייה שבה נמצא הסקריפט
pushd %~dp0

:: 1. טעינת משתני סביבה מה-.env (שני שלבים למעלה)
if exist "..\..\.env" (
    for /f "usebackq tokens=*" %%a in ("..\..\.env") do set %%a
) else (
    echo [ERROR] .env file not found at ..\..\.env
    pause
    exit /b
)

:: 2. קבלת שם הקובץ לשחזור
set BACKUP_FILE=%1

if "%BACKUP_FILE%"=="" (
    echo [PROMPT] Please drag and drop the backup file onto this script, 
    echo          or run: restore.bat filename.sql
    set /p BACKUP_FILE="Enter backup filename (including .sql): "
)

:: בדיקה אם הקובץ קיים
if not exist "!BACKUP_FILE!" (
    echo [ERROR] File !BACKUP_FILE! not found in current folder.
    pause
    exit /b
)

:: 3. אזהרת משתמש
echo ======================================================
echo [WARNING] You are about to restore to: %DB_RESTORE_NAME_SECRET%
echo [WARNING] This will overwrite existing data!
echo ======================================================
set /p CONFIRM="Are you sure you want to proceed? (Y/N): "

if /i not "!CONFIRM!"=="Y" (
    echo [INFO] Restore cancelled.
    popd
    exit /b
)

echo [INFO] Starting restore into container: PostgreSQL_DB...

:: 4. הרצת השחזור (שימוש ב-psql עבור קבצי SQL רגילים)
type "!BACKUP_FILE!" | docker exec -i PostgreSQL_DB psql -U %DB_USER_SECRET% -d %DB_RESTORE_NAME_SECRET%

if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] Database restored successfully from !BACKUP_FILE!
) else (
    echo [ERROR] Restore failed! Check Docker status and user permissions.
)

popd
pause