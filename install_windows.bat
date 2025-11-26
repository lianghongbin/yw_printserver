@echo off
chcp 936 >nul 2>&1
REM Windows 安装脚本 - 打印服务器
REM 此脚本将安装打印服务器并配置开机自启动

echo ========================================
echo   打印服务器 - Windows 安装程序
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

REM 设置安装目录
set "INSTALL_DIR=C:\Program Files\PrintServer"
set "EXE_NAME=print_server.exe"
set "SERVICE_NAME=PrintServer"

echo [1/5] 创建安装目录...
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
)

echo [2/5] 复制文件...
if not exist "dist\%EXE_NAME%" (
    echo [错误] 找不到 dist\%EXE_NAME%
    echo 请先运行 build_windows.bat 构建可执行文件
    pause
    exit /b 1
)

copy /Y "dist\%EXE_NAME%" "%INSTALL_DIR%\%EXE_NAME%" >nul
if errorlevel 1 (
    echo [错误] 复制文件失败
    pause
    exit /b 1
)

echo [3/5] 创建启动脚本...
(
echo @echo off
echo cd /d "%INSTALL_DIR%"
echo "%INSTALL_DIR%\%EXE_NAME%"
) > "%INSTALL_DIR%\start_server.bat"

echo [4/5] 配置开机自启动...
REM 使用任务计划程序创建开机自启动任务（用户登录时启动）
schtasks /create /tn "%SERVICE_NAME%" /tr "\"%INSTALL_DIR%\%EXE_NAME%\"" /sc onlogon /f >nul 2>&1
if errorlevel 1 (
    echo [警告] 创建开机自启动任务失败，尝试使用启动文件夹方式...
    REM 备用方案：使用启动文件夹
    set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
    copy /Y "%INSTALL_DIR%\start_server.bat" "%STARTUP_FOLDER%\PrintServer.bat" >nul 2>&1
    if errorlevel 1 (
        echo [警告] 启动文件夹方式也失败，请手动配置开机自启动
        echo 可以运行 setup_autostart.bat 重新配置
    ) else (
        echo [成功] 已添加到启动文件夹
    )
) else (
    echo [成功] 已创建开机自启动任务: %SERVICE_NAME%
    echo         任务将在用户登录时自动启动
)

echo [5/5] 创建卸载脚本...
(
echo @echo off
echo REM 打印服务器卸载脚本
echo echo ========================================
echo echo   打印服务器 - 卸载程序
echo echo ========================================
echo echo.
echo net session ^>nul 2^>^&1
echo if %%errorlevel%% neq 0 ^(
echo     echo [错误] 需要管理员权限！
echo     echo 请右键点击此文件，选择"以管理员身份运行"
echo     pause
echo     exit /b 1
echo ^)
echo.
echo echo [1/3] 停止服务...
echo taskkill /F /IM %EXE_NAME% /T ^>nul 2^>^&1
echo.
echo echo [2/3] 删除开机自启动任务...
echo schtasks /delete /tn "%SERVICE_NAME%" /f ^>nul 2^>^&1
echo.
echo echo [3/3] 删除安装目录...
echo if exist "%INSTALL_DIR%" ^(
echo     rd /s /q "%INSTALL_DIR%"
echo ^)
echo.
echo echo [完成] 卸载完成
echo pause
) > "%INSTALL_DIR%\uninstall.bat"

echo.
echo ========================================
echo   安装完成！
echo ========================================
echo.
echo 安装目录: %INSTALL_DIR%
echo 可执行文件: %INSTALL_DIR%\%EXE_NAME%
echo.
echo 服务将在下次登录时自动启动
echo 要立即启动服务，请运行: "%INSTALL_DIR%\%EXE_NAME%"
echo.
echo 要卸载服务，请运行: "%INSTALL_DIR%\uninstall.bat"
echo.
pause

