@echo off
setlocal enabledelayedexpansion

REM Set database connection variables
set SERVER=DylanS\MSSQLSERVER2022

REM Prompt for database name
set /p DATABASE=Enter the name of the database to restore: 

REM Prompt user to select .bak file using Windows Explorer
echo Select the .bak file to restore:
echo.
set "FILE="
for /f "delims=" %%I in ('powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $dlg = New-Object System.Windows.Forms.OpenFileDialog; $dlg.Filter = 'SQL Backup Files (*.bak)|*.bak'; $dlg.ShowDialog() | Out-Null; $dlg.FileName"') do set "FILE=%%I"

REM Check if a file was selected
if "%FILE%"=="" (
    echo No file selected. Exiting script.
    exit /b 1
)

REM Check if database name is provided
if "%DATABASE%"=="" (
    echo Database name cannot be empty. Exiting script.
    exit /b 1
)

REM Put the database in single user mode
echo.
echo Putting database %DATABASE% in single user mode ...
sqlcmd -S %SERVER% -Q "ALTER DATABASE [%DATABASE%] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;" -b -d master

if ERRORLEVEL 1 (
    echo Failed to set database %DATABASE% to single user mode. Exiting script.
    exit /b 1
)

REM Restore the database
echo.
echo Restoring database %DATABASE% from %FILE% ...
sqlcmd -S %SERVER% -Q "RESTORE DATABASE [%DATABASE%] FROM DISK='%FILE%' WITH REPLACE, RECOVERY;" -b -d master

if ERRORLEVEL 1 (
    echo Database restore failed. Check the SQL Server error log for details.
) else (
    echo Database %DATABASE% restored successfully from %FILE%.
)

REM Set the database back to multi-user mode
echo.
echo Putting database %DATABASE% back in multi-user mode ...
sqlcmd -S %SERVER% -Q "ALTER DATABASE [%DATABASE%] SET MULTI_USER;" -b -d master

if ERRORLEVEL 1 (
    echo Failed to set database %DATABASE% back to multi-user mode. Manual intervention may be required.
)

pause
