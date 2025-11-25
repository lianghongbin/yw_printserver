@echo off
REM Build script for Windows executable
REM This script packages the print server into a Windows .exe file

echo ===== Building Windows Executable =====
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    pause
    exit /b 1
)

REM Check if virtual environment exists
if not exist ".venv" (
    echo Creating virtual environment...
    python -m venv .venv
)

REM Activate virtual environment
echo Activating virtual environment...
call .venv\Scripts\activate.bat

REM Install dependencies
echo Installing dependencies...
pip install -q --upgrade pip
pip install -q -r requirements.txt
pip install -q pyinstaller

REM Generate logo.grf if needed
if not exist "img\logo.grf" (
    echo Generating logo.grf...
    python convert_logo.py
)

REM Generate template_final.zpl if needed
if not exist "template_final.zpl" (
    echo Generating template_final.zpl...
    python -c "import re; t=open('template.zpl','r',encoding='utf-8').read(); g=open('img/logo.grf','r',encoding='utf-8').read(); open('template_final.zpl','w',encoding='utf-8').write(t.replace('{{LOGO_GRF}}',g))"
)

REM Build executable with PyInstaller
echo.
echo Building executable...
pyinstaller --clean --noconfirm print_server.spec

if exist "dist\print_server.exe" (
    echo.
    echo ===== Build Complete =====
    echo Executable: dist\print_server.exe
    echo.
    echo To run: dist\print_server.exe
) else (
    echo.
    echo ===== Build Failed =====
    pause
    exit /b 1
)

pause

