@echo off
chcp 936 >nul 2>&1
REM Windows build and start script - Print Server

REM Check if virtual environment exists
if not exist ".venv" (
    echo Error: Virtual environment not found, please run: python -m venv .venv
    pause
    exit /b 1
)

REM Step 1: Build template
.venv\Scripts\python.exe build_template.py
if errorlevel 1 (
    echo Build template failed
    pause
    exit /b 1
)

REM Step 2: Check port 8023
echo.
echo Checking port 8023...

set PORT=8023
set PID=

REM Find process using port 8023
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%PORT%" ^| findstr "LISTENING"') do (
    set PID=%%a
    goto :found_port
)

:found_port
if defined PID (
    if "%1"=="--force" (
        echo Warning: Port %PORT% is occupied by process %PID%
        echo Force closing process %PID%...
        taskkill /PID %PID% /F >nul 2>&1
        timeout /t 1 /nobreak >nul
        REM Verify port is released
        netstat -ano | findstr ":%PORT%" | findstr "LISTENING" >nul 2>&1
        if errorlevel 1 (
            echo Port %PORT% is now available
        ) else (
            echo Failed to close process on port %PORT%
            pause
            exit /b 1
        )
    ) else (
        echo Warning: Port %PORT% is already in use (PID: %PID%)
        echo    To force close and start server, use: build.bat --force
        echo    Or manually close the process: taskkill /PID %PID% /F
        pause
        exit /b 1
    )
) else (
    echo Port %PORT% is available
)

REM Step 3: Start print service
echo.
echo Starting print service...
echo Press Ctrl+C to stop the server
echo.

REM Start server
REM Ctrl+C will be passed to Python process, which handles graceful shutdown
.venv\Scripts\python.exe print_server.py

