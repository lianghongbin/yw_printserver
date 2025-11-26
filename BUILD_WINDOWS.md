# Building Windows Executable

This guide explains how to package the print server into a Windows `.exe` file.

## Prerequisites

1. **Python 3.8+** installed on Windows
2. **Virtual environment** (will be created automatically)

## Quick Start

### On Windows:

1. Open Command Prompt or PowerShell in the project directory
2. Run:
   ```cmd
   build_windows.bat
   ```

### On macOS/Linux (for cross-compilation):

1. Install PyInstaller in virtual environment
2. Run:
   ```bash
   bash build_windows.sh
   ```

## Manual Build Steps

If you prefer to build manually:

1. **Create and activate virtual environment:**
   ```cmd
   python -m venv .venv
   .venv\Scripts\activate
   ```

2. **Install dependencies:**
   ```cmd
   pip install -r requirements.txt
   pip install pyinstaller
   ```

3. **Generate required files:**
   ```cmd
   python convert_logo.py
   REM Generate template_final.zpl (see build_windows.bat for details)
   ```

4. **Build executable:**
   ```cmd
   pyinstaller --clean --noconfirm print_server.spec
   ```

5. **Find the executable:**
   - Location: `dist\print_server.exe`
   - This is a standalone executable that includes Python and all dependencies

## Running the Executable

Simply double-click `dist\print_server.exe` or run from command line:

```cmd
dist\print_server.exe
```

The executable will:
- Display server information
- Listen on port 8023
- Accept print requests from PDA devices

## File Structure

The executable includes:
- Python runtime
- All required libraries (Pillow, zpl, etc.)
- `template_final.zpl` template file
- `img/logo.grf` logo file

## Troubleshooting

### "Python is not installed"
- Install Python 3.8+ from [python.org](https://www.python.org/downloads/)
- Make sure Python is added to PATH during installation

### "Module not found" errors
- Make sure virtual environment is activated
- Run `pip install -r requirements.txt` again

### Executable is too large
- This is normal - PyInstaller bundles Python and all dependencies
- Typical size: 50-100 MB
- You can use `--onefile` option in spec file to create a single file (default)

### Antivirus warnings
- Some antivirus software may flag PyInstaller executables as suspicious
- This is a false positive - you can add an exception or submit for analysis

## Distribution

To distribute the application:
1. Copy `dist\print_server.exe` to target Windows machine
2. No Python installation required on target machine
3. Run directly - all dependencies are bundled

## Notes

- The executable is console-based (shows terminal window)
- To hide console window, set `console=False` in `print_server.spec`
- Logs are printed to console
- Press Ctrl+C to stop the server



