@echo off
chcp 936 >nul 2>&1
REM 配置开机自启动（独立脚本，可在已安装后单独运行）

echo ========================================
echo   配置开机自启动
echo ========================================
echo.

REM 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 需要管理员权限！
    echo 请右键点击此文件，选择"以管理员身份运行"
    pause
    exit /b 1
)

REM 设置路径
set "INSTALL_DIR=C:\Program Files\PrintServer"
set "EXE_NAME=print_server.exe"
set "SERVICE_NAME=PrintServer"

REM 检查文件是否存在
if not exist "%INSTALL_DIR%\%EXE_NAME%" (
    echo [错误] 找不到 %INSTALL_DIR%\%EXE_NAME%
    echo 请先运行 install_windows.bat 安装服务
    pause
    exit /b 1
)

echo 正在配置开机自启动...
echo.

REM 删除现有任务（如果存在）
schtasks /delete /tn "%SERVICE_NAME%" /f >nul 2>&1

REM 创建新的开机自启动任务
echo 创建任务计划程序任务...
schtasks /create /tn "%SERVICE_NAME%" /tr "\"%INSTALL_DIR%\%EXE_NAME%\"" /sc onlogon /f
if errorlevel 1 (
    echo [错误] 创建任务失败
    echo.
    echo 尝试使用启动文件夹方式...
    set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
    (
        echo @echo off
        echo cd /d "%INSTALL_DIR%"
        echo start "" "%INSTALL_DIR%\%EXE_NAME%"
    ) > "%STARTUP_FOLDER%\PrintServer.bat"
    if errorlevel 1 (
        echo [错误] 启动文件夹方式也失败
        pause
        exit /b 1
    ) else (
        echo [成功] 已添加到启动文件夹: %STARTUP_FOLDER%
    )
) else (
    echo [成功] 已创建开机自启动任务: %SERVICE_NAME%
    echo.
    echo 任务将在用户登录时自动启动
    echo 要查看任务，请运行: schtasks /query /tn "%SERVICE_NAME%"
)

echo.
pause

