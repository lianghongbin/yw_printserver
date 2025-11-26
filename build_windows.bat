@echo off
chcp 936 >nul 2>&1
REM Windows 构建脚本 - 打印服务器
REM 此脚本将打印服务器打包为 Windows .exe 文件

echo ========================================
echo   Windows 可执行文件构建程序
echo ========================================
echo.

REM 检查 Python 是否已安装
python --version >nul 2>&1
if errorlevel 1 (
    echo [错误] 未检测到 Python，或 Python 未添加到 PATH
    echo 请先安装 Python 3.8 或更高版本
    echo 下载地址: https://www.python.org/downloads/
    pause
    exit /b 1
)

REM 检查虚拟环境是否存在
if not exist ".venv" (
    echo [1/4] 创建虚拟环境...
    python -m venv .venv
    if errorlevel 1 (
        echo [错误] 创建虚拟环境失败
        pause
        exit /b 1
    )
) else (
    echo [1/4] 虚拟环境已存在，跳过创建
)

REM 激活虚拟环境
echo [2/4] 激活虚拟环境...
call .venv\Scripts\activate.bat
if errorlevel 1 (
    echo [错误] 激活虚拟环境失败
    pause
    exit /b 1
)

REM 安装依赖
echo [3/4] 安装依赖包...
pip install -q --upgrade pip
if errorlevel 1 (
    echo [警告] pip 升级失败，继续执行...
)
pip install -q -r requirements.txt
if errorlevel 1 (
    echo [错误] 安装依赖包失败
    pause
    exit /b 1
)
pip install -q pyinstaller
if errorlevel 1 (
    echo [错误] 安装 PyInstaller 失败
    pause
    exit /b 1
)

REM 检查 GRF 文件是否存在
if not exist "img\yw_logo_final.grf" (
    echo [错误] 找不到 img\yw_logo_final.grf
    echo 请确保 GRF 文件存在后再构建
    pause
    exit /b 1
)

REM 生成 template_final.zpl（如果需要，使用二进制 GRF 注入）
if not exist "template_final.zpl" (
    echo [4/5] 生成 template_final.zpl...
    python -c "t=open('template.zpl','r',encoding='utf-8').read(); g=open(r'img\yw_logo_final.grf','rb').read(); p=t.split('{{LOGO_GRF}}'); f=open('template_final.zpl','wb'); f.write(p[0].encode('utf-8')); f.write(g); f.write(p[1].encode('utf-8')) if len(p)==2 else f.write(t.replace('{{LOGO_GRF}}',g.decode('latin-1',errors='ignore')).encode('latin-1',errors='ignore'))"
    if errorlevel 1 (
        echo [错误] 生成 template_final.zpl 失败
        pause
        exit /b 1
    )
) else (
    echo [4/5] template_final.zpl 已存在，跳过生成
)

REM 使用 PyInstaller 构建可执行文件
echo [5/5] 构建可执行文件...
echo.
pyinstaller --clean --noconfirm print_server.spec
if errorlevel 1 (
    echo [错误] PyInstaller 构建失败
    pause
    exit /b 1
)

if exist "dist\print_server.exe" (
    echo.
    echo ========================================
    echo   构建完成！
    echo ========================================
    echo.
    echo 可执行文件位置: dist\print_server.exe
    echo.
    echo 下一步: 运行 install_windows.bat 安装服务
    echo.
) else (
    echo.
    echo ========================================
    echo   构建失败！
    echo ========================================
    echo.
    echo 未找到生成的可执行文件
    pause
    exit /b 1
)

pause

